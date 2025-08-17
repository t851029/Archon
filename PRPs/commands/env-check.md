# Living Tree Environment Check

Comprehensive environment validation for all Living Tree environments (local, staging, production).

## Purpose

Ensure all environments are properly configured and services are running correctly before development or deployment.

## Quick Environment Check

```bash
# Run this first to get a quick overview
echo "=== Living Tree Environment Status ==="
git branch --show-current
echo "---"
test -f api/.env.local && echo "✓ Backend env" || echo "✗ Backend env missing"
test -f apps/web/.env.local && echo "✓ Frontend env" || echo "✗ Frontend env missing"
echo "---"
lsof -i :3000 >/dev/null 2>&1 && echo "⚠️  Port 3000 in use" || echo "✓ Port 3000 available"
lsof -i :8000 >/dev/null 2>&1 && echo "⚠️  Port 8000 in use" || echo "✓ Port 8000 available"
lsof -i :54321 >/dev/null 2>&1 && echo "⚠️  Port 54321 in use" || echo "✓ Port 54321 available"
echo "---"
npx supabase status >/dev/null 2>&1 && echo "✓ Supabase running" || echo "✗ Supabase not running"
```

## 1. Local Environment Check

### Prerequisites

```bash
# Check required tools
command -v pnpm >/dev/null 2>&1 && echo "✓ pnpm installed" || echo "✗ pnpm missing"
command -v poetry >/dev/null 2>&1 && echo "✓ Poetry installed" || echo "✗ Poetry missing"
command -v docker >/dev/null 2>&1 && echo "✓ Docker installed" || echo "✗ Docker missing"
command -v npx >/dev/null 2>&1 && echo "✓ npx installed" || echo "✗ npx missing"
command -v gh >/dev/null 2>&1 && echo "✓ GitHub CLI installed" || echo "✗ GitHub CLI missing"
command -v vercel >/dev/null 2>&1 && echo "✓ Vercel CLI installed" || echo "✗ Vercel CLI missing"
```

### Backend Validation

```bash
cd api
# Check Poetry environment
poetry env info

# Validate environment variables
poetry run python -c "
from api.core.config import settings
required = ['OPENAI_API_KEY', 'CLERK_SECRET_KEY', 'SUPABASE_URL']
for var in required:
    val = getattr(settings, var, None)
    if val and val != 'not-set':
        print(f'✓ {var} configured')
    else:
        print(f'✗ {var} missing or invalid')
"

# Test backend can start
poetry run python -c "from api.index import app; print('✓ Backend imports successfully')"
```

### Frontend Validation

```bash
cd apps/web
# Check environment variables
node -e "
const required = ['NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY', 'CLERK_SECRET_KEY', 'NEXT_PUBLIC_SUPABASE_URL', 'NEXT_PUBLIC_SUPABASE_ANON_KEY'];
required.forEach(key => {
  if (process.env[key]) {
    console.log('✓', key, 'configured');
  } else {
    console.log('✗', key, 'missing');
  }
});
"

# Check build
next build --dry-run >/dev/null 2>&1 && echo "✓ Frontend can build" || echo "✗ Frontend build issues"
```

### Database Validation

```bash
# Check Supabase
npx supabase status || echo "Run 'npx supabase start' to start local database"

# Check migrations
npx supabase migration list

# Test database connection
npx supabase db test >/dev/null 2>&1 && echo "✓ Database connection OK" || echo "✗ Database connection failed"
```

### MCP Servers Check

```bash
# List available MCP servers
claude mcp list | grep -E "(supabase|postgres|tavily|context7|playwright|sequential-thinking)" || echo "No MCP servers configured"
```

## 2. Staging Environment Check

### Vercel Configuration

```bash
# Check Vercel auth and project
vercel whoami
vercel project ls | grep living-tree-web

# Check staging environment variables
vercel env ls --environment=preview | grep -E "(CLERK|SUPABASE)" | wc -l | xargs -I {} echo "{} staging env vars configured"
```

### Staging Backend Health

```bash
# Test staging backend
curl -s https://living-tree-backend-staging-eprzpin6uq-nn.a.run.app/health | jq . || echo "✗ Staging backend unreachable"

# Check staging CORS
curl -s -X OPTIONS https://living-tree-backend-staging-eprzpin6uq-nn.a.run.app/api/chat \
  -H "Origin: https://staging.livingtree.io" \
  -H "Access-Control-Request-Method: POST" \
  -I | grep -i "access-control-allow-origin" || echo "✗ CORS not configured for staging"
```

### Staging Database

```bash
# Link to staging database
npx supabase link --project-ref fwdfewruzeaplmcezyne

# Check staging migrations
npx supabase migration list --linked

# Get staging database info
npx supabase projects list | grep fwdfewruzeaplmcezyne
```

### Staging Frontend

```bash
# Check staging deployment
curl -s -I https://staging.livingtree.io | grep "HTTP/2 200" && echo "✓ Staging frontend accessible" || echo "✗ Staging frontend issue"
```

## 3. Production Environment Check

### Production Backend Health

```bash
# Test production backend
curl -s https://living-tree-backend-production-eprzpin6uq-nn.a.run.app/health | jq . || echo "✗ Production backend unreachable"
```

### Production Database

```bash
# Link to production database (BE CAREFUL!)
npx supabase link --project-ref zunxilwvjbpkhzrbaxmk

# Check production migrations
npx supabase migration list --linked

# Get production database info
npx supabase projects list | grep zunxilwvjbpkhzrbaxmk
```

### Production Frontend

```bash
# Check production deployment
curl -s -I https://app.livingtree.io | grep "HTTP/2 200" && echo "✓ Production frontend accessible" || echo "✗ Production frontend issue"
```

## 4. Docker Environment Check

```bash
# Test backend Docker build
echo "Testing Docker build..."
docker build -f api/Dockerfile -t lt-backend-test . && echo "✓ Docker build successful" || echo "✗ Docker build failed"

# Clean up test image
docker rmi lt-backend-test 2>/dev/null
```

## 5. Complete Environment Report

```bash
# Generate full environment report
cat << 'EOF' > environment-report.md
# Living Tree Environment Report
Generated: $(date)

## Git Status
- Branch: $(git branch --show-current)
- Uncommitted changes: $(git status --porcelain | wc -l)

## Local Environment
- Backend env: $(test -f api/.env.local && echo "✓" || echo "✗")
- Frontend env: $(test -f apps/web/.env.local && echo "✓" || echo "✗")
- Supabase: $(npx supabase status >/dev/null 2>&1 && echo "✓ Running" || echo "✗ Not running")
- Ports: 3000=$(lsof -i :3000 >/dev/null 2>&1 && echo "In use" || echo "Available"), 8000=$(lsof -i :8000 >/dev/null 2>&1 && echo "In use" || echo "Available")

## Tools Installed
- pnpm: $(command -v pnpm >/dev/null 2>&1 && pnpm -v || echo "Not installed")
- Poetry: $(command -v poetry >/dev/null 2>&1 && poetry --version | cut -d' ' -f3 || echo "Not installed")
- Node: $(node -v)
- Python: $(python --version 2>&1 | cut -d' ' -f2)

## Staging Status
- Backend: $(curl -s -o /dev/null -w "%{http_code}" https://living-tree-backend-staging-eprzpin6uq-nn.a.run.app/health)
- Frontend: $(curl -s -o /dev/null -w "%{http_code}" https://staging.livingtree.io)

## Production Status
- Backend: $(curl -s -o /dev/null -w "%{http_code}" https://living-tree-backend-production-eprzpin6uq-nn.a.run.app/health)
- Frontend: $(curl -s -o /dev/null -w "%{http_code}" https://app.livingtree.io)
EOF

echo "Environment report saved to environment-report.md"
```

## Common Environment Issues

### Port Conflicts

```bash
# Quick fix for port conflicts
pkill -f "next dev" || true
pkill -f "uvicorn" || true
npx supabase stop || true
sleep 2
echo "Ports cleared"
```

### Missing Environment Variables

- Check CLAUDE.md for required variables
- Copy from .env.example files
- Get sensitive values from team

### Docker Build Failures

- Ensure Poetry lockfile is up to date
- Check README.md exists in project root
- Verify all Python dependencies installed

### Supabase Connection Issues

```bash
# Reset Supabase
npx supabase stop
docker volume rm supabase_db_living-tree 2>/dev/null || true
npx supabase start
```

## Quick Start After Environment Check

```bash
# If all checks pass, start development
pnpm dev:full

# Or start services individually
npx supabase start
cd apps/web && pnpm dev
cd api && poetry run uvicorn api.index:app --reload --port 8000
```

Remember: Always run environment check before starting development or debugging issues!
