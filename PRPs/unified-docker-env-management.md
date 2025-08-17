# PRP: Unified Docker & Environment Variable Management

## Overview

Implement a unified solution that combines the environment variable type safety and validation from the original plan with a pragmatic Docker setup for a small team (1-3 developers). This approach leverages Docker for consistency while maintaining the Zod validation and TypeScript type safety that prevents runtime errors.

## Solution Architecture

### Key Principles

1. **Type-Safe Environment Variables**: Use Zod validation for all environment variables
2. **Runtime Validation**: Fail fast on startup if configuration is invalid
3. **Docker for Consistency**: Containerize problematic components (Python backend, database)
4. **Hybrid Development**: Keep Next.js native for performance, backend in Docker
5. **Single Source of Truth**: One `.env` file with validation, no scattered configs

### Research Insights (July 2025)

Based on current best practices:

- **Next.js Environment Variables**: Build-time vs runtime handling requires special attention in Docker
- **Docker Compose 2025**: Now supports better environment variable management with `env_file` precedence
- **Zod Integration**: Runtime validation pattern is now standard for production TypeScript apps
- **Security**: Avoid exposing secrets through environment variables in containers

## Implementation Plan

### Phase 1: Environment Variable Foundation

#### Task 1: Implement Zod Validation (Frontend)

This is already implemented in your staged changes (`apps/web/lib/env.ts`). The key enhancement for Docker compatibility:

```yaml
enhance_env_validation:
  action: MODIFY
  file: apps/web/lib/env.ts
  changes: |
    Add Docker-aware API URL resolution:

    // After existing schema definitions, add:

    // Docker-aware API URL resolution
    export const getApiUrl = () => {
      // In Docker, backend is accessible via service name
      if (process.env.DOCKER_ENV === 'true' && typeof window === 'undefined') {
        return 'http://api:8000';
      }
      // In browser or native development, use configured URL
      return env.NEXT_PUBLIC_API_BASE_URL;
    };

    // Export for use in API calls
    export const API_URL = getApiUrl();

  validation:
    - command: "cd apps/web && pnpm type-check"
    - expect: "No type errors"
```

#### Task 2: Backend Environment Validation Enhancement

```yaml
enhance_backend_config:
  action: MODIFY
  file: api/core/config.py
  changes: |
    Add Docker-specific configuration to existing Settings class:

    # Add to Settings class
    # Docker-specific settings
    IS_DOCKER: bool = Field(default=False, description="Running in Docker container")

    @computed_field
    @property
    def database_url(self) -> str:
        """Compute database URL based on environment"""
        if self.IS_DOCKER:
            # Use Docker service names
            return "postgres://postgres:postgres@db:5432/postgres"
        # Use configured URL for non-Docker environments
        return self.SUPABASE_URL

    @computed_field
    @property
    def internal_api_url(self) -> str:
        """Internal API URL for service-to-service communication"""
        if self.IS_DOCKER:
            return "http://api:8000"
        return "http://localhost:8000"

  validation:
    - command: "cd api && poetry run python -c 'from core.config import settings; print(settings)'"
    - expect: "Settings load without error"
```

### Phase 2: Docker Integration

#### Task 3: Create Docker Compose with Validation

```yaml
create_docker_compose:
  action: CREATE
  file: docker-compose.yml
  changes: |
    version: '3.8'

    services:
      # Backend API with environment validation
      api:
        build:
          context: .
          dockerfile: api/Dockerfile.dev
        ports:
          - "${API_PORT:-8000}:8000"
        env_file:
          - .env  # Single source of truth
        environment:
          # Override for Docker context
          - IS_DOCKER=true
          - ENVIRONMENT=${ENVIRONMENT:-local}
          - CORS_ORIGINS_LOCAL=http://localhost:${FRONTEND_PORT:-3000}
        healthcheck:
          test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
          interval: 30s
          timeout: 10s
          retries: 3
          start_period: 40s
        develop:
          watch:
            - action: sync
              path: ./api
              target: /app/api
              ignore:
                - __pycache__/
                - .pytest_cache/
            - action: rebuild
              path: ./api/pyproject.toml
            - action: rebuild
              path: ./api/poetry.lock
        networks:
          - app-network
        depends_on:
          db:
            condition: service_healthy

      # Supabase PostgreSQL
      db:
        image: supabase/postgres:15.1.0.147
        ports:
          - "${DB_PORT:-5432}:5432"
        environment:
          POSTGRES_DB: postgres
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: ${DB_PASSWORD:-postgres}
        healthcheck:
          test: ["CMD-SHELL", "pg_isready -U postgres"]
          interval: 10s
          timeout: 5s
          retries: 5
        volumes:
          - db_data:/var/lib/postgresql/data
        networks:
          - app-network

      # Environment validator service (runs once)
      env-validator:
        build:
          context: .
          dockerfile: Dockerfile.env-validator
        env_file:
          - .env
        command: ["node", "/app/validate-env.js"]
        profiles:
          - validate

    volumes:
      db_data:

    networks:
      app-network:
        driver: bridge

  validation:
    - command: "docker-compose config"
    - expect: "Valid configuration"
```

#### Task 4: Create Environment Validator

```yaml
create_env_validator:
  action: CREATE
  file: Dockerfile.env-validator
  changes: |
    FROM node:20-alpine

    WORKDIR /app

    # Copy package files
    COPY package.json pnpm-lock.yaml ./
    COPY apps/web/package.json ./apps/web/

    # Install dependencies
    RUN npm install -g pnpm
    RUN pnpm install --filter=web --frozen-lockfile

    # Copy validation files
    COPY apps/web/lib/env.ts ./apps/web/lib/
    COPY apps/web/env.d.ts ./apps/web/
    COPY tsconfig.json ./

    # Create validation script
    RUN echo '#!/usr/bin/env node\n\
    console.log("🔍 Validating environment variables...");\n\
    try {\n\
      require("./apps/web/lib/env.ts");\n\
      console.log("✅ Environment validation passed!");\n\
      process.exit(0);\n\
    } catch (error) {\n\
      console.error("❌ Environment validation failed:");\n\
      console.error(error.message);\n\
      process.exit(1);\n\
    }' > validate-env.js

    CMD ["node", "validate-env.js"]

  validation:
    - command: "docker build -f Dockerfile.env-validator -t env-validator ."
    - expect: "Build succeeds"
```

#### Task 5: Create Unified Development Script

```yaml
create_dev_script:
  action: CREATE
  file: scripts/dev-unified.ts
  changes: |
    #!/usr/bin/env -S npx tsx
    import { $, echo, question, chalk } from 'zx';
    import { z } from 'zod';
    import * as fs from 'fs';
    import * as path from 'path';

    // Validate .env file exists
    const envPath = path.join(process.cwd(), '.env');
    if (!fs.existsSync(envPath)) {
      echo(chalk.red('❌ .env file not found!'));
      echo('Please copy .env.example to .env and configure it.');
      process.exit(1);
    }

    async function validateEnvironment() {
      echo(chalk.blue('🔍 Validating environment variables...'));
      
      try {
        // Run Docker environment validation
        await $`docker-compose run --rm env-validator`;
        echo(chalk.green('✅ Environment validation passed!'));
        return true;
      } catch (error) {
        echo(chalk.red('❌ Environment validation failed!'));
        echo('Please check your .env file configuration.');
        return false;
      }
    }

    async function startServices() {
      echo(chalk.blue('🐳 Starting Docker services...'));
      
      // Start backend services in Docker
      await $`docker-compose up -d api db`;
      
      // Wait for services to be healthy
      echo('Waiting for services to be ready...');
      await $`docker-compose exec api curl -f http://localhost:8000/health || sleep 5`;
      
      echo(chalk.green('✅ Docker services started!'));
      
      // Start frontend natively
      echo(chalk.blue('🚀 Starting Next.js frontend...'));
      echo('Frontend will be available at http://localhost:3000');
      await $`pnpm dev:web`;
    }

    async function main() {
      echo(chalk.bold('🌳 Living Tree Unified Development Environment'));
      echo('============================================\n');
      
      // Step 1: Validate environment
      const isValid = await validateEnvironment();
      if (!isValid) {
        process.exit(1);
      }
      
      // Step 2: Check Docker is running
      try {
        await $`docker --version`;
        await $`docker-compose --version`;
      } catch (error) {
        echo(chalk.red('❌ Docker is not running!'));
        echo('Please start Docker Desktop and try again.');
        process.exit(1);
      }
      
      // Step 3: Start services
      await startServices();
    }

    // Handle cleanup on exit
    process.on('SIGINT', async () => {
      echo('\n' + chalk.yellow('🛑 Shutting down services...'));
      await $`docker-compose down`;
      process.exit(0);
    });

    main().catch((error) => {
      echo(chalk.red('❌ Error:'), error.message);
      process.exit(1);
    });

  validation:
    - command: "chmod +x scripts/dev-unified.ts"
    - expect: "Script is executable"
```

### Phase 3: Integration & Documentation

#### Task 6: Create Consolidated .env.example

```yaml
create_env_example:
  action: CREATE
  file: .env.example
  changes: |
    # Living Tree Environment Configuration
    # Copy this file to .env and fill in your values

    #############################################
    # ENVIRONMENT
    #############################################
    ENVIRONMENT=local  # local | staging | production
    NODE_ENV=development

    #############################################
    # PORTS (for Docker and local development)
    #############################################
    FRONTEND_PORT=3000
    API_PORT=8000
    DB_PORT=5432

    #############################################
    # FRONTEND (NEXT_PUBLIC_* are exposed to browser)
    #############################################
    NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_your-key-here
    NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
    NEXT_PUBLIC_SUPABASE_ANON_KEY=eyJ...your-anon-key
    NEXT_PUBLIC_API_BASE_URL=http://localhost:8000
    NEXT_PUBLIC_ENVIRONMENT=local
    NEXT_PUBLIC_DEBUG_MODE=false

    #############################################
    # BACKEND (Server-side only)
    #############################################
    # Authentication
    CLERK_SECRET_KEY=sk_test_your-secret-key

    # Database
    SUPABASE_URL=https://your-project.supabase.co
    SUPABASE_SERVICE_ROLE_KEY=eyJ...your-service-role-key
    DB_PASSWORD=postgres  # For local Docker PostgreSQL

    # AI Services
    OPENAI_API_KEY=sk-...your-openai-key

    # Gmail Integration (Optional)
    GMAIL_CLIENT_ID=your-client-id
    GMAIL_CLIENT_SECRET=your-client-secret

    #############################################
    # CORS Configuration
    #############################################
    CORS_ORIGINS_LOCAL=http://localhost:3000,http://localhost:8080
    CORS_ORIGINS_STAGING=https://staging.livingtree.io,https://living-tree-web-git-staging-livingtree.vercel.app
    CORS_ORIGINS_PRODUCTION=https://app.livingtree.io

  validation:
    - command: "test -f .env.example"
    - expect: "File exists"
```

#### Task 7: Update Package.json Scripts

```yaml
update_package_scripts:
  action: MODIFY
  file: package.json
  changes: |
    Update scripts section:

    "scripts": {
      // Existing scripts...
      
      // New unified development commands
      "dev": "tsx scripts/dev-unified.ts",
      "dev:validate": "docker-compose run --rm env-validator",
      "dev:docker": "docker-compose up",
      "dev:docker:build": "docker-compose build",
      "dev:docker:down": "docker-compose down",
      "dev:docker:clean": "docker-compose down -v",
      
      // Keep existing scripts for backward compatibility
      "dev:legacy": "concurrently \"pnpm dev:api\" \"pnpm dev:web\"",
      "dev:web": "npx turbo dev --filter=web",
      "dev:api": "poetry run uvicorn api.index:app --reload --port 8000"
    }

  validation:
    - command: "grep 'dev:validate' package.json"
    - expect: "Script found"
```

#### Task 8: Update Documentation

````yaml
update_readme:
  action: MODIFY
  file: README.md
  changes: |
    Replace the Quick Start section with:

    ## Quick Start

    ### Prerequisites
    - Node.js >= 20
    - pnpm 10.12.1
    - Docker Desktop
    - Python >= 3.9 & Poetry (only if running backend natively)

    ### Setup (One-Time)

    ```bash
    # 1. Clone and install dependencies
    git clone <your-repo>
    cd living-tree
    pnpm install

    # 2. Configure environment variables
    cp .env.example .env
    # Edit .env with your API keys and configuration

    # 3. Validate your configuration
    pnpm dev:validate
    ```

    ### Development

    ```bash
    # Start everything with one command
    pnpm dev

    # This will:
    # 1. Validate all environment variables with Zod
    # 2. Start PostgreSQL database in Docker
    # 3. Start FastAPI backend in Docker
    # 4. Start Next.js frontend natively (for fast hot-reload)
    ```

    Your app will be available at:
    - **Frontend**: http://localhost:3000
    - **Backend API**: http://localhost:8000
    - **API Docs**: http://localhost:8000/docs

    ### Environment Variables

    All environment variables are:
    - ✅ Type-safe with TypeScript
    - ✅ Validated at startup with Zod
    - ✅ Documented in `.env.example`
    - ✅ Single source of truth (one `.env` file)

    The application will fail fast with clear error messages if any required environment variable is missing or invalid.

    ### Docker Commands

    ```bash
    # View logs
    docker-compose logs -f api

    # Rebuild containers
    pnpm dev:docker:build

    # Stop everything
    pnpm dev:docker:down

    # Clean everything (including database)
    pnpm dev:docker:clean
    ```

    ### Fallback: Native Development

    If you prefer to run everything natively:

    ```bash
    # Start Supabase
    npx supabase start

    # Start services
    pnpm dev:legacy
    ```

  validation:
    - command: "grep 'pnpm dev:validate' README.md"
    - expect: "Documentation updated"
````

## Benefits of This Unified Approach

### 1. Environment Variable Safety

- **Zod Validation**: All variables validated at startup
- **Type Safety**: Full TypeScript types for all env vars
- **Single Source**: One `.env` file, no duplication
- **Clear Errors**: Specific messages for missing/invalid config

### 2. Docker Simplicity

- **One Command**: `pnpm dev` starts everything
- **Hybrid Mode**: Docker for backend, native for frontend
- **Health Checks**: Services wait for dependencies
- **Easy Cleanup**: Simple commands to reset

### 3. Developer Experience

- **Fast Feedback**: Frontend hot-reload remains native speed
- **Consistent Environment**: Same PostgreSQL, Python versions for all
- **Pre-validated**: Environment checked before services start
- **Progressive**: Can still run natively if needed

### 4. Production Parity

- **Same Validation**: Zod runs in production too
- **Docker Ready**: Already containerized for deployment
- **Environment Aware**: Different configs for local/staging/prod

## Migration Path

1. **Week 1**: Team uses new `pnpm dev` alongside existing workflow
2. **Week 2**: Gather feedback, adjust Docker performance if needed
3. **Week 3**: Make Docker the primary development method
4. **Week 4**: Update CI/CD to use same Docker images

## Validation Gates

```bash
# 1. Environment validation passes
pnpm dev:validate
# Expected: "✅ Environment validation passed!"

# 2. Services start successfully
pnpm dev
# Expected: All services healthy, frontend accessible

# 3. API can connect to database
curl http://localhost:8000/health
# Expected: {"status": "healthy", "database": "connected"}

# 4. Frontend can call backend
# Navigate to http://localhost:3000 and test features

# 5. Hot reload works
# Modify api/index.py - should auto-reload
# Modify apps/web/app/page.tsx - should hot-reload
```

## Common Issues & Solutions

### Issue: "Environment validation failed"

**Solution**: Check `.env` file has all required variables from `.env.example`

### Issue: "Port already in use"

**Solution**: Use custom ports: `FRONTEND_PORT=3001 API_PORT=8001 pnpm dev`

### Issue: "Docker not running"

**Solution**: Start Docker Desktop or use `pnpm dev:legacy` for native mode

### Issue: "Slow performance on Mac"

**Solution**: Backend uses `docker compose watch` for optimal performance

## External References

- [Zod Environment Variables Pattern](https://github.com/colinhacks/zod#parsing)
- [Docker Compose Environment Files](https://docs.docker.com/compose/environment-variables/set-environment-variables/)
- [Next.js Docker Best Practices 2025](https://nextjs.org/docs/deployment/docker)
- [TypeScript Monorepo Docker](https://turbo.build/repo/docs/guides/tools/docker)

## Confidence Score: 8/10

This unified approach successfully combines:

- ✅ Environment variable type safety and validation (original goal)
- ✅ Docker consistency for small team (new goal)
- ✅ Maintains fast frontend development
- ✅ Single command startup
- ✅ Production-ready patterns

The solution is pragmatic, addressing real documented pain points while avoiding over-engineering. The hybrid approach (Docker backend + native frontend) provides the best balance of consistency and performance for a small team.
