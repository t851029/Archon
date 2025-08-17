# Code Review - Living Tree

Please perform a comprehensive code review of the current changes or specified files in the Living Tree project.

## Review Scope

$ARGUMENTS

## Living Tree Review Process

1. **Understand Changes**
   - If reviewing staged changes: `git diff --staged`
   - If reviewing specific files: Read the specified files
   - If reviewing a PR: `gh pr view $ARGUMENTS --json files,additions,deletions`
   - If reviewing a local directory: `git diff $ARGUMENTS`
   - If reviewing against staging: `git diff origin/staging`
   - Check which environment this targets (staging vs production)

## Living Tree Review Focus Areas

1. **Code Quality**

   ### Frontend (Next.js/TypeScript)
   - Next.js 15 patterns (Promise-based route params)
   - Proper use of 'use client' directive
   - TypeScript strict mode compliance
   - No `any` types
   - Proper error boundaries
   - SWR for data fetching
   - Path aliases (@/\*) used correctly

   ### Backend (FastAPI/Python)
   - Type hints on all functions and classes
   - Pydantic v2 models for data validation
   - No print() statements (use logging)
   - Proper async/await usage
   - Following PEP 8
   - Google-style docstrings
   - JWT token validation on all protected endpoints

2. **Living Tree Specific Patterns**

   ### Authentication
   - Clerk JWT validation in backend
   - Clerk hooks in frontend
   - User IDs as text type (not UUID)
   - Proper middleware usage

   ### Database (Supabase)
   - RLS policies for new tables
   - Migrations follow naming convention
   - Types regenerated after schema changes
   - Service role key only in backend

   ### MCP Tools
   - Proper tool response format
   - Error handling in tool execution
   - Tool permissions checked

3. **Security**

   ### Frontend
   - No exposed API keys (use NEXT*PUBLIC* prefix)
   - CORS properly configured
   - No sensitive data in client components

   ### Backend
   - Input validation on all endpoints
   - SQL injection prevention (use Supabase client)
   - No hardcoded secrets
   - Proper error messages (no stack traces)

4. **Project Structure**
   - Monorepo conventions followed
   - Features self-contained in proper directories
   - Shared code in packages/
   - Tests co-located with code
   - No cross-package imports except from packages/

5. **Environment Management**
   - Environment-specific code properly isolated
   - Staging URLs used correctly
   - Docker builds tested for backend changes
   - Vercel configuration for frontend

6. **Type Safety & Linting**

   ### Pre-review Checks

   ```bash
   # TypeScript
   pnpm type-check

   # Python
   poetry run mypy api/ --strict

   # Linting
   pnpm lint
   poetry run flake8 api/

   # Docker (if backend changed)
   docker build -f api/Dockerfile -t test-backend .
   ```

7. **Testing**
   - New features have tests
   - Integration tests for API endpoints
   - Component tests for UI changes
   - E2E considerations with Playwright MCP

8. **Performance**
   - No N+1 queries in backend
   - Proper React memoization
   - Image optimization in Next.js
   - API response streaming where appropriate

9. **Documentation**
   - CLAUDE.md updated with new patterns
   - API endpoints documented
   - Complex functions have docstrings
   - README updated if setup changed

## Living Tree Specific Review Checklist

### Frontend Checklist

- [ ] Next.js 15 route conventions followed
- [ ] Client/server components properly separated
- [ ] Environment variables properly prefixed
- [ ] Supabase client usage correct
- [ ] Clerk auth properly implemented
- [ ] No console.log in production code
- [ ] Tailwind classes follow project patterns
- [ ] shadcn/ui components used correctly

### Backend Checklist

- [ ] FastAPI route protection with JWT
- [ ] Pydantic v2 patterns (model_dump, ConfigDict)
- [ ] Proper async/await usage
- [ ] Error handling returns proper HTTP codes
- [ ] Logging instead of print statements
- [ ] Tool implementations follow MCP spec
- [ ] Database queries use proper types

### Infrastructure Checklist

- [ ] Docker build succeeds
- [ ] Environment variables documented
- [ ] Migrations tested locally first
- [ ] Deployment configuration correct
- [ ] CORS settings appropriate

## Review Output

Create a concise review report with:

```markdown
# Living Tree Code Review #[number]

## Summary

[2-3 sentence overview including which environment/branch this targets]

## Environment Impact

- Local: [Any local dev impact]
- Staging: [Staging-specific considerations]
- Production: [Production risks or requirements]

## Issues Found

### 🔴 Critical (Must Fix)

- [Issue with file:line and suggested fix]
- [Docker build failures]
- [Type errors]
- [Security issues]

### 🟡 Important (Should Fix)

- [Issue with file:line and suggested fix]
- [Missing tests]
- [Performance concerns]
- [Pattern violations]

### 🟢 Minor (Consider)

- [Code style improvements]
- [Documentation updates]
- [Refactoring opportunities]

## Living Tree Specific Checks

- [ ] Clerk auth properly implemented
- [ ] Supabase RLS policies in place
- [ ] MCP tools follow spec
- [ ] Multi-environment considerations
- [ ] Docker build tested (backend)

## Good Practices Observed

- [What was done well]
- [Patterns correctly followed]

## Test Coverage

- Frontend: X% (Required: 70%)
- Backend: X% (Required: 80%)
- Missing tests: [list specific untested features]

## Pre-Deployment Checklist

- [ ] Type checking passes
- [ ] Docker builds successfully
- [ ] Environment variables documented
- [ ] Migrations ready for all environments
- [ ] CLAUDE.md updated if needed

Save report to PRPs/code*reviews/lt_review*[#].md
```

## Quick Review Commands

```bash
# For staged changes
git diff --staged | head -100
pnpm type-check && poetry run mypy api/

# For PR review
gh pr view <number> --json files
gh pr checks <number>

# For full review
git diff origin/staging..HEAD
pnpm build && docker build -f api/Dockerfile -t test-backend .
```

Remember: Living Tree reviews should consider multi-environment impact and maintain consistency across the monorepo!
