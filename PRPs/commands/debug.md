# Debug Living Tree Issue

Systematically debug and diagnose the reported problem in the Living Tree project.

## Problem Description

$ARGUMENTS

## Living Tree Debugging Process

1. **Reproduce the Issue**
   - Get exact steps to reproduce
   - Note which environment (local/staging/production)
   - Check browser console for frontend errors
   - Check api/backend.log for backend errors
   - Verify Supabase logs: `npx supabase logs`
   - Document expected vs actual behavior

2. **Gather Living Tree Specific Information**

   ```bash
   # Check recent changes
   git log --oneline -10

   # Check service health
   curl http://localhost:3000/api/health
   curl http://localhost:8000/health
   npx supabase status

   # Check environment variables
   cd api && poetry run python -c "from api.core.config import settings; print(settings.model_dump_json(indent=2, include={'OPENAI_API_KEY', 'CLERK_SECRET_KEY', 'SUPABASE_URL'}))"

   # Check for port conflicts
   lsof -i :3000 -i :8000 -i :54321

   # Search for error patterns in logs
   grep -n "ERROR" api/backend.log | tail -20
   ```

3. **Isolate the Problem**

   ### Living Tree Specific Areas
   - **Frontend Issues**: Check Next.js app directory and API routes
   - **Backend Issues**: Check FastAPI endpoints and tools
   - **Database Issues**: Use Supabase Studio or postgres MCP
   - **Auth Issues**: Verify Clerk JWT tokens
   - **AI Issues**: Check OpenAI API calls and streaming

   ### Using MCP Tools for Debugging

   ```bash
   # Use Supabase MCP to check data
   # Use Postgres MCP for direct queries
   # Use Playwright MCP for frontend testing
   # Use Sequential Thinking for complex debugging
   ```

4. **Common Living Tree Debugging Strategies**

   ### For Authentication Errors
   - Verify Clerk keys in environment
   - Check JWT token format (base64url)
   - Test with `verify_jwt_token` function
   - Ensure user_id is text type in Supabase

   ### For Database Errors
   - Check RLS policies: `SELECT * FROM pg_policies`
   - Verify migrations are applied
   - Test with service role key
   - Check Supabase connection

   ### For Email Triage Issues
   - Verify Gmail OAuth tokens via Clerk
   - Check email_triage_results table
   - Test triage tools individually
   - Monitor WebSocket connections

   ### For AI/Streaming Issues
   - Check OpenAI API key and credits
   - Verify streaming implementation
   - Test with non-streaming first
   - Check CORS configuration

   ### For Deployment Issues
   - Staging: Use staging.livingtree.io URL
   - Check Vercel environment variables
   - Verify Google Cloud Run logs
   - Test Docker build locally

5. **Living Tree Root Cause Analysis**
   - Is it environment-specific?
   - Is it a missing migration?
   - Is it a CORS/URL issue?
   - Is it a dependency version mismatch?
   - Are MCP servers connected?

6. **Implement Fix**
   - Fix root cause following Living Tree patterns
   - Update CLAUDE.md if it's a common issue
   - Consider multi-environment impact
   - Test across local/staging before production
   - Follow project conventions (pnpm/poetry)

7. **Verify Resolution**

   ```bash
   # Run type checking
   pnpm type-check
   poetry run mypy api/

   # Run tests
   pnpm test
   poetry run pytest

   # Test in browser
   open http://localhost:3000

   # Check specific features
   # - Login flow
   # - Email triage
   # - Chat interface
   # - Tool execution
   ```

8. **Document Findings**

   ```markdown
   ## Debug Summary - Living Tree

   ### Issue

   [What was broken - include environment]

   ### Root Cause

   [Why it was broken - Living Tree specific]

   ### Fix

   [What was changed - files and line numbers]

   ### Prevention

   [Update CLAUDE.md, add tests, or improve validation]

   ### Affected Environments

   - [ ] Local
   - [ ] Staging
   - [ ] Production
   ```

## Living Tree Debug Checklist

- [ ] Issue reproduced locally with `pnpm dev:full`
- [ ] Checked all relevant logs (frontend console, backend.log, Supabase)
- [ ] Verified environment variables are correct
- [ ] Root cause identified with file:line reference
- [ ] Fix implemented following project patterns
- [ ] Type checking passes (`pnpm type-check`, `poetry run mypy`)
- [ ] Tests added/updated
- [ ] Tested in appropriate environment
- [ ] No regressions in key features
- [ ] CLAUDE.md updated if common issue
- [ ] Docker build tested if backend changed

## Quick Debug Commands

```bash
# Full environment check
pnpm dev:full

# Backend only debug
cd api && poetry run uvicorn api.index:app --reload --port 8000 --log-level debug

# Frontend only debug
cd apps/web && pnpm dev

# Database debug
npx supabase status
npx supabase logs
open http://localhost:54323

# Type and lint check
pnpm type-check && pnpm lint
cd api && poetry run mypy api/ && poetry run flake8 api/
```

Remember: Living Tree has multiple environments - always specify which environment the bug occurs in and test fixes appropriately!
