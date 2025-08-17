> Command for priming Claude Code with Living Tree project knowledge

# Prime Context for Living Tree Project

Use the command `tree` to get an understanding of the project structure.

Start with reading the CLAUDE.md files in order:

1. Root CLAUDE.md - Overall project context
2. api/CLAUDE.md - Backend specific patterns
3. apps/web/CLAUDE.md - Frontend specific patterns

Read the README.md file to get an understanding of the project.

## Environment Check

Verify the development environment is properly configured:

```bash
# Check required environment files
test -f api/.env.local && echo "✓ Backend env" || echo "✗ Backend env missing"
test -f apps/web/.env.local && echo "✓ Frontend env" || echo "✗ Frontend env missing"

# Check port availability
lsof -i :3000 && echo "⚠️ Port 3000 in use" || echo "✓ Port 3000 available"
lsof -i :8000 && echo "⚠️ Port 8000 in use" || echo "✓ Port 8000 available"
lsof -i :54321 && echo "⚠️ Port 54321 in use" || echo "✓ Port 54321 available"

# Check Supabase status
npx supabase status || echo "⚠️ Supabase not running - run 'npx supabase start'"
```

## MCP Server Verification

Check available MCP servers for Living Tree:

```bash
claude mcp list | grep -E "(supabase|postgres|tavily|context7|playwright|sequential-thinking)"
```

## Read key files

- api/index.py - FastAPI entry point
- apps/web/app/layout.tsx - Next.js root layout
- turbo.json - Monorepo configuration
- supabase/migrations/ - Database schema

## Project-Specific Context

Check current environment and branch:

```bash
git branch --show-current
git status --short
vercel whoami
npx supabase projects list | grep -E "(fwdfewruzeaplmcezyne|zunxilwvjbpkhzrbaxmk)"
```

> List any additional files that are important to understand the project.

Explain back to me:

- Project structure (monorepo with Turborepo)
- Project purpose and goals (AI-powered productivity platform)
- Key files and their purposes
- Important dependencies (Next.js 15, FastAPI, Supabase, Clerk)
- Important configuration files (turbo.json, vercel.json, backend-service.yaml)
- Current environment setup (local/staging/production)
- Available MCP tools for development
