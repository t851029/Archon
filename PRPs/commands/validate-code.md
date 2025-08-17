# Validate Living Tree Code

Run comprehensive validation checks on the Living Tree codebase to ensure quality and type safety.

## Purpose

Ensure Living Tree code quality by running all validation tools before committing changes, creating PRs, or deploying to staging/production.

## Living Tree Validation Steps

1. **Type Checking**

   ```bash
   # Frontend TypeScript (Next.js 15)
   pnpm type-check
   # or
   pnpm check-types

   # Backend Python (FastAPI)
   poetry run mypy api/ --strict
   ```

2. **Linting**

   ```bash
   # Frontend
   pnpm lint

   # Backend
   poetry run flake8 api/
   poetry run black api/ --check
   ```

3. **Formatting**

   ```bash
   # Frontend
   pnpm format

   # Backend
   poetry run black api/
   ```

4. **Testing**

   ```bash
   # Frontend
   pnpm test

   # Backend
   poetry run pytest
   poetry run pytest api/tests/test_triage_integration.py -v  # Specific test
   ```

5. **Docker Build Validation (Critical for Backend)**

   ```bash
   # ALWAYS test Docker builds after backend changes
   docker build -f api/Dockerfile -t test-backend .
   docker run -p 8000:8080 test-backend
   ```

6. **Database Type Generation**
   ```bash
   # After any Supabase schema changes
   pnpm types
   ```

## Living Tree Quick Validation Command

For a complete validation run:

```bash
# Frontend validation
pnpm type-check && pnpm lint && pnpm test

# Backend validation
cd api && poetry run mypy api/ --strict && poetry run flake8 api/ && poetry run black api/ --check && poetry run pytest

# Full project validation
pnpm build && cd api && poetry run mypy api/ --strict

# Docker validation (after backend changes)
docker build -f api/Dockerfile -t test-backend . && echo "✓ Docker build successful"
```

## Common Living Tree Type Errors and Fixes

### TypeScript/React (Next.js 15)

- **Next.js 15 route params**: Use `Promise<{ params: { id: string } }>`
- **Supabase types**: Run `pnpm types` after schema changes
- **Clerk types**: Import from `@clerk/nextjs`
- **Environment variables**: Add to `apps/web/types/env.d.ts`
- **shadcn/ui components**: Check component imports match installed version

### Python (FastAPI)

- **Pydantic v2**: Use `model_dump()` not `dict()`
- **FastAPI dependencies**: Type hint Depends() results
- **Async functions**: Use proper async/await types
- **Supabase client**: Type responses with generated types
- **Tool responses**: Follow MCP tool response schema

## Living Tree Environment-Specific Validation

### Local Development

```bash
# Validate with local environment
npx supabase status  # Ensure local DB running
pnpm dev:full  # Start all services
# Run validation commands above
```

### Staging Deployment

```bash
# Pre-staging checklist
vercel env pull  # Get staging vars
pnpm build  # Build frontend
docker build -f api/Dockerfile -t test-backend .  # Build backend
```

### Production Deployment

```bash
# Additional production checks
pnpm build
pnpm type-check
# Ensure no console.log statements
grep -r "console.log" apps/web/app --exclude-dir=node_modules
```

## Integration with Living Tree Development Flow

1. **Before commits**:

   ```bash
   pnpm type-check && pnpm lint
   poetry run mypy api/
   ```

2. **Before PRs to staging**:

   ```bash
   # Full validation suite
   pnpm build
   docker build -f api/Dockerfile -t test-backend .
   pnpm test && cd api && poetry run pytest
   ```

3. **In CI/CD**:
   - Vercel runs build checks automatically
   - Google Cloud Build validates backend

4. **During development**:
   - VS Code/Cursor: Install recommended extensions
   - Enable format on save
   - Use TypeScript strict mode

## Living Tree Validation Checklist

- [ ] No TypeScript errors (`pnpm type-check` passes)
- [ ] No Python type errors (`poetry run mypy api/` passes)
- [ ] No linting errors (ESLint + Flake8)
- [ ] Code is properly formatted (Prettier + Black)
- [ ] All tests pass (Jest + pytest)
- [ ] Docker build succeeds (backend only)
- [ ] No hardcoded environment values
- [ ] No `console.log` in production code
- [ ] Supabase types are current (`pnpm types`)
- [ ] API route params use Next.js 15 Promise syntax
- [ ] All MCP tools have proper type annotations
- [ ] Clerk user IDs typed as `string` not `UUID`

## Living Tree Specific Validation Rules

### Frontend (Next.js/React)

- Use `'use client'` directive for client components
- API routes must handle Promise params
- Environment variables must have `NEXT_PUBLIC_` prefix for client
- Import from `@/` aliases, not relative paths
- Use SWR for data fetching, not raw fetch

### Backend (FastAPI/Python)

- All endpoints must validate JWT tokens
- Use Pydantic v2 patterns (ConfigDict, model_dump)
- Handle async properly with asyncio
- Log errors to backend.log, not print()
- Follow Google-style docstrings

### Database (Supabase)

- All tables must have RLS policies
- User IDs are text type, not UUID
- Migrations must be tested on local first
- Types must be regenerated after schema changes

## Error Resolution Priority for Living Tree

1. **Docker build failures** - Fix immediately (blocks deployment)
2. **Type errors** - Critical for both frontend and backend
3. **Test failures** - Especially integration tests
4. **Linting errors** - Maintain code quality
5. **Formatting** - Run formatters to fix

## MCP Tools for Validation

Use these MCP tools to help with validation:

- **Sequential Thinking**: Break down complex type errors
- **Context7**: Look up TypeScript/Python best practices
- **Playwright**: Test frontend interactions
- **Supabase/Postgres**: Validate database queries

Remember: Living Tree uses strict type checking to prevent runtime errors across multiple environments!
