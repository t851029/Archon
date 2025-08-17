# Troubleshoot Common Living Tree Issues

Quick solutions for the most common Living Tree development problems.

## Quick Diagnostics

```bash
# Run this first to identify issues
echo "=== Living Tree Quick Diagnostics ==="
echo "Checking common issues..."
echo ""

# Port conflicts
lsof -i :3000 >/dev/null 2>&1 && echo "❌ Port 3000 blocked" || echo "✅ Port 3000 free"
lsof -i :8000 >/dev/null 2>&1 && echo "❌ Port 8000 blocked" || echo "✅ Port 8000 free"
lsof -i :54321 >/dev/null 2>&1 && echo "❌ Port 54321 blocked" || echo "✅ Port 54321 free"

# Services
npx supabase status >/dev/null 2>&1 && echo "✅ Supabase running" || echo "❌ Supabase not running"
curl -s http://localhost:3000 >/dev/null 2>&1 && echo "✅ Frontend responding" || echo "❌ Frontend not responding"
curl -s http://localhost:8000/health >/dev/null 2>&1 && echo "✅ Backend responding" || echo "❌ Backend not responding"

# Environment files
test -f api/.env.local && echo "✅ Backend env exists" || echo "❌ Backend env missing"
test -f apps/web/.env.local && echo "✅ Frontend env exists" || echo "❌ Frontend env missing"
```

## 1. Port Conflicts (Most Common)

### Symptoms

- "Port already in use" errors
- Services fail to start
- Multiple development sessions conflict

### Quick Fix

```bash
# Nuclear option - kill all development processes
pkill -f "next dev" || true
pkill -f "uvicorn" || true
pkill -f "node" || true
npx supabase stop || true

# Wait for cleanup
sleep 2

# Verify ports are free
lsof -i :3000 -i :8000 -i :54321 || echo "✅ All ports cleared"
```

### Targeted Fix

```bash
# Find and kill specific port users
lsof -ti :3000 | xargs kill -9 2>/dev/null || true
lsof -ti :8000 | xargs kill -9 2>/dev/null || true
lsof -ti :54321 | xargs kill -9 2>/dev/null || true
```

## 2. Supabase Database Issues

### PostgreSQL Version Mismatch

**Error**: "supabase_db container is not running: exited"

```bash
# Fix PostgreSQL version incompatibility
npx supabase stop
docker volume rm supabase_db_living-tree
npx supabase start

# Reapply migrations
npx supabase db push
pnpm types
```

### Connection Refused

```bash
# Restart Supabase completely
npx supabase stop --backup
docker system prune -f
npx supabase start
```

## 3. Environment Variable Issues

### Missing Variables

```bash
# Quick check for required vars
cat << 'EOF' > check-env.js
const required = {
  backend: ['OPENAI_API_KEY', 'CLERK_SECRET_KEY', 'SUPABASE_URL', 'SUPABASE_ANON_KEY', 'SUPABASE_SERVICE_ROLE_KEY'],
  frontend: ['NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY', 'CLERK_SECRET_KEY', 'NEXT_PUBLIC_SUPABASE_URL', 'NEXT_PUBLIC_SUPABASE_ANON_KEY']
};

console.log('Checking environment variables...\n');

// Check backend
console.log('Backend (api/.env.local):');
try {
  require('dotenv').config({ path: 'api/.env.local' });
  required.backend.forEach(key => {
    console.log(process.env[key] ? `✅ ${key}` : `❌ ${key} - MISSING`);
  });
} catch (e) {
  console.log('❌ Cannot read api/.env.local');
}

console.log('\nFrontend (apps/web/.env.local):');
try {
  require('dotenv').config({ path: 'apps/web/.env.local' });
  required.frontend.forEach(key => {
    console.log(process.env[key] ? `✅ ${key}` : `❌ ${key} - MISSING`);
  });
} catch (e) {
  console.log('❌ Cannot read apps/web/.env.local');
}
EOF

node check-env.js
rm check-env.js
```

### JWT Format Issues

**Error**: "Invalid JWT format"

```bash
# Validate JWT format
echo "Paste your JWT token:"
read JWT_TOKEN
echo $JWT_TOKEN | tr '.' '\n' | wc -l | grep -q 3 && echo "✅ Valid JWT format" || echo "❌ Invalid JWT format"
```

## 4. Type Checking Errors

### Frontend TypeScript Errors

```bash
# Regenerate types and check
pnpm types
pnpm type-check

# Clear TypeScript cache
rm -rf apps/web/.next
rm -rf apps/web/tsconfig.tsbuildinfo
pnpm type-check
```

### Backend mypy Errors

```bash
# Clear mypy cache
rm -rf .mypy_cache
cd api && poetry run mypy api/ --strict

# Install missing type stubs
poetry add --dev types-requests types-pydantic
```

## 5. Docker Build Failures

### Poetry Lock Issues

```bash
# Regenerate lock file
cd api
rm poetry.lock
poetry lock
cd ..
docker build -f api/Dockerfile -t test-backend .
```

### Missing Files

```bash
# Ensure required files exist
touch README.md
touch LICENSE
docker build -f api/Dockerfile -t test-backend .
```

## 6. Authentication Issues

### Clerk Token Problems

```bash
# Test Clerk configuration
curl -X GET https://api.clerk.dev/v1/users \
  -H "Authorization: Bearer $CLERK_SECRET_KEY" \
  -H "Content-Type: application/json" | jq .
```

### CORS Errors

**Using wrong URL in staging**

```bash
# Always use these URLs:
echo "Staging Frontend: https://staging.livingtree.io"
echo "Staging Backend: https://living-tree-backend-staging-eprzpin6uq-nn.a.run.app"
echo "NOT preview URLs like: https://living-tree-*.vercel.app"
```

## 7. Development Server Issues

### Frontend Won't Start

```bash
# Clean install
rm -rf node_modules pnpm-lock.yaml
rm -rf apps/web/node_modules apps/web/.next
pnpm install
pnpm dev:web
```

### Backend Won't Start

```bash
# Reinstall dependencies
cd api
poetry env remove python
poetry install
poetry run uvicorn api.index:app --reload --port 8000
```

## 8. Database Migration Issues

### Migrations Out of Sync

```bash
# Check all environments
npx supabase migration list  # Local
npx supabase link --project-ref fwdfewruzeaplmcezyne
npx supabase migration list --linked  # Staging
```

### Failed Migration

```bash
# Rollback and retry
npx supabase db reset
npx supabase db push
pnpm types
```

## 9. Performance Issues

### Slow Frontend

```bash
# Clear Next.js cache
rm -rf apps/web/.next
pnpm build
pnpm dev
```

### Memory Leaks

```bash
# Monitor memory usage
ps aux | grep -E "(node|python)" | awk '{print $2, $3, $4, $11}'

# Restart services
pnpm dev:full
```

## 10. Quick Reset Scripts

### Complete Environment Reset

```bash
cat << 'EOF' > reset-env.sh
#!/bin/bash
echo "🔄 Resetting Living Tree environment..."

# Stop everything
pkill -f "next dev" || true
pkill -f "uvicorn" || true
npx supabase stop || true

# Clear caches
rm -rf node_modules
rm -rf apps/web/node_modules apps/web/.next
rm -rf packages/*/node_modules
rm -rf api/.mypy_cache
rm -rf .turbo

# Reinstall
pnpm install
cd api && poetry install && cd ..

# Restart services
npx supabase start
pnpm types
echo "✅ Environment reset complete! Run 'pnpm dev:full' to start."
EOF

chmod +x reset-env.sh
./reset-env.sh
```

### Quick Service Restart

```bash
# Save current work and restart
git add . && git stash
pkill -f "next dev" && pkill -f "uvicorn"
pnpm dev:full
```

## Common Error Messages Reference

| Error                        | Likely Cause                   | Quick Fix                 |
| ---------------------------- | ------------------------------ | ------------------------- |
| "Port already in use"        | Previous session still running | `pkill -f "next dev"`     |
| "Cannot connect to Supabase" | Supabase not running           | `npx supabase start`      |
| "Invalid JWT"                | Malformed token or wrong env   | Check `.env.local` files  |
| "CORS blocked"               | Using wrong URL                | Use staging.livingtree.io |
| "Module not found"           | Missing dependencies           | `pnpm install`            |
| "Type error TS2345"          | Outdated types                 | `pnpm types`              |
| "Docker build failed"        | Poetry lock outdated           | `cd api && poetry lock`   |

## Still Having Issues?

1. Check CLAUDE.md for detailed setup
2. Review recent git changes: `git log --oneline -10`
3. Check GitHub issues: `gh issue list`
4. Use MCP tools for debugging:
   - Sequential Thinking for complex issues
   - Context7 for error research
   - Playwright for UI testing

Remember: Most Living Tree issues are environment-related. Start with `/env-check`!
