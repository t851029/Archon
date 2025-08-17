Please perform a comprehensive onboarding analysis for a new developer joining the Living Tree project. Execute the following steps:

## 1. Project Overview

First, analyze the repository structure and provide:

- **Project name**: Living Tree - AI-powered productivity platform
- **Purpose**: Intelligent email management, chat interface, and extensible tool system
- **Tech stack**:
  - Frontend: Next.js 15, React 19, TypeScript, Tailwind CSS, shadcn/ui
  - Backend: FastAPI (Python), Poetry, Pydantic v2
  - Database: Supabase (PostgreSQL with RLS)
  - Auth: Clerk (JWT-based)
  - AI: OpenAI GPT-4o, Vercel AI SDK
  - Monorepo: Turborepo with pnpm workspaces
- **Architecture**: Monorepo with separate frontend/backend, MCP tool system
- **Key dependencies**: See package.json and pyproject.toml

## 2. Repository Structure

Map out the Living Tree codebase organization:

- **api/** - FastAPI backend
  - core/ - Auth, config, dependencies
  - utils/ - Email schemas, tools, Gmail helpers
  - tests/ - Backend tests
- **apps/web/** - Next.js frontend
  - app/ - App Router pages and API routes
  - components/ - React components
  - services/ - Frontend services
  - hooks/ - Custom React hooks
- **packages/** - Shared packages
  - types/ - Shared TypeScript types
  - ui/ - Shared UI components
- **supabase/** - Database migrations and config
- **docs/** - Mintlify documentation
- **PRPs/** - Planning and review documents
- **config/** - ESLint and TypeScript configs
- **.claude/** - Claude Code automation settings

## 3. Getting Started

Create step-by-step setup instructions:

### Prerequisites

- Node.js 18+ and pnpm
- Python 3.11+ and Poetry
- Docker for Supabase
- Clerk account for auth
- OpenAI API key

### Environment Setup

```bash
# Clone and install
git clone <repo>
cd living-tree
pnpm install
cd api && poetry install

# Setup environment files
cp api/.env.example api/.env.local
cp apps/web/.env.example apps/web/.env.local
# Edit both files with your keys

# Start Supabase
npx supabase start

# Generate types
pnpm types

# Run development
pnpm dev:full
```

### Required Environment Variables

- Local: See CLAUDE.md for complete list
- Staging/Production: Managed via Vercel and Google Secret Manager

## 4. Key Components

Identify and explain the most important files/modules:

- **Entry points**:
  - api/index.py - FastAPI application
  - apps/web/app/layout.tsx - Next.js root
- **Core business logic**:
  - api/utils/tools.py - MCP tool implementations
  - api/utils/email_schemas.py - Email processing
  - apps/web/app/(app)/triage/page.tsx - Email triage dashboard
- **Database models**: supabase/migrations/
- **API endpoints**:
  - api/index.py - Backend routes
  - apps/web/app/api/ - Next.js API routes
- **Configuration**:
  - api/core/config.py - Backend settings
  - apps/web/lib/config.ts - Frontend config
- **Authentication**:
  - api/core/auth.py - JWT validation
  - apps/web/middleware.ts - Clerk middleware

## 5. Development Workflow

Document the Living Tree development process:

- **Git branches**:
  - main - Production
  - staging - Staging environment
  - feature/\* - Feature branches
- **Creating features**:
  1. Branch from staging
  2. Implement with tests
  3. Run validation: `pnpm type-check && pnpm lint`
  4. Create PR to staging
- **Testing**:
  - Frontend: `pnpm test`
  - Backend: `poetry run pytest`
- **Code style**:
  - Frontend: ESLint + Prettier
  - Backend: Black + Flake8 + mypy
- **PR process**: Review required, CI checks must pass
- **CI/CD**:
  - Vercel for frontend
  - Google Cloud Build for backend

## 6. Architecture Decisions

Important patterns and decisions in Living Tree:

- **MCP Tool System**: Extensible tools via Model Context Protocol
- **State Management**: SWR for server state, React hooks for client
- **Error Handling**: Structured responses with toast notifications
- **Logging**: Backend logging to file, frontend console
- **Security**: Clerk JWT validation, Supabase RLS
- **Performance**: Streaming AI responses, optimized builds

## 7. Common Tasks

### Add a new API endpoint

```python
# In api/index.py
@app.post("/api/new-endpoint")
async def new_endpoint(request: Request, user_id: str = Depends(verify_jwt_token)):
    # Implementation
```

### Create a new database table

```bash
npx supabase migration new table_name
# Edit migration file
npx supabase db push
pnpm types
```

### Add a new MCP tool

1. Define tool in api/utils/tools.py
2. Add to TOOLS list
3. Test with chat interface

### Debug issues

- Check browser console for frontend
- Check api/backend.log for backend
- Use Supabase Studio for database

## 8. Potential Gotchas

Living Tree specific issues to watch for:

- **Port conflicts**: Kill existing processes on 3000, 8000, 54321
- **Environment variables**:
  - Frontend needs NEXT*PUBLIC* prefix
  - Use correct Supabase URL in API routes
- **JWT format**: Must be exact base64url encoded
- **Database**: Run migrations on all environments
- **Poetry + Docker**: Use --no-root flag
- **Type generation**: Run after schema changes
- **CORS**: Use staging.livingtree.io URL, not preview URLs

## 9. Documentation and Resources

- **CLAUDE.md files**: Primary documentation
- **API docs**: http://localhost:8000/docs
- **Database**: http://localhost:54323 (Supabase Studio)
- **Deployment guides**: See Deployment Notes in CLAUDE.md
- **MCP tools**: Listed in CLAUDE.md

## 10. Next Steps

Living Tree onboarding checklist:

1. [ ] Set up development environment
2. [ ] Run `pnpm dev:full` successfully
3. [ ] Navigate to http://localhost:3000 and sign in
4. [ ] Test email triage feature
5. [ ] Make a small change to frontend
6. [ ] Run backend tests
7. [ ] Understand MCP tool system
8. [ ] Review existing PRPs for context

## Additional Living Tree Resources

### MCP Server Setup

```bash
# Add Supabase MCP
claude mcp add supabase -s local -e SUPABASE_ACCESS_TOKEN=$token -- npx -y @supabase/mcp-server-supabase@latest --read-only --project-ref=fwdfewruzeaplmcezyne

# Add Postgres MCP
claude mcp add postgres-mcp-local -- npx -y @modelcontextprotocol/server-postgres 'postgresql://...'
```

### Quick Commands

- `pnpm dev:full` - Start everything
- `pnpm type-check` - Validate types
- `pnpm lint` - Check code quality
- `pnpm types` - Generate Supabase types
- `docker build -f api/Dockerfile -t test-backend .` - Test backend build

## Output Format

Please create:

1. A comprehensive ONBOARDING.md file at the root with all above information
2. A QUICKSTART.md with essential Living Tree setup steps
3. Suggest updates to README.md for any missing Living Tree specific information

Focus on clarity and actionability. Assume the developer is experienced but completely new to the Living Tree codebase.
