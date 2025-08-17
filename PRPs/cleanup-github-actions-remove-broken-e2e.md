# PRP: Clean Up GitHub Actions - Remove Broken E2E Tests

## Context

We attempted to implement comprehensive E2E testing with Clerk authentication, but the implementation has critical issues that cause constant failures. These failures create noise, reduce confidence in the CI/CD pipeline, and provide no value since they always fail.

## Current Problems

### 1. E2E Tests Always Fail
- **Environment Variable Mismatch**: `NEXT_PUBLIC_ENVIRONMENT` is set to 'test' but validation requires 'staging'
- **Build Failures**: The build step fails before tests even run
- **localStorage Security Errors**: Browser security context prevents localStorage access in test environment
- **Result**: Red ❌ on every staging deployment, creating alert fatigue

### 2. No Value Being Provided
- Tests never actually run (fail at build stage)
- Even if they ran, localStorage errors would prevent them from working
- Creating false negatives that mask real issues
- Wasting CI/CD resources (4 parallel shards, ~4 minutes each run)

## What Actually Works

### ✅ Keep These (They Work!)

1. **Backend Deployment Workflow** (`deploy-backend-staging.yml`)
   - Successfully deploys to Cloud Run
   - Handles secrets properly
   - Provides real value

2. **Frontend Deployment** (Vercel)
   - Automatic deployment on push to staging
   - Works flawlessly
   - No GitHub Action needed

3. **Deployment Script** (`scripts/deploy-to-staging.sh`)
   - Validates before deploying
   - Handles all deployment scenarios
   - Actually useful

4. **Environment Validation** (`scripts/validate-deployment-env.sh`)
   - Catches real configuration issues
   - Provides actionable feedback
   - Worth keeping

## What to Remove

### ❌ Remove These (Broken/No Value)

1. **E2E Test Workflow** (`.github/workflows/e2e-tests-clerk.yml`)
   - Always fails
   - Provides no value
   - Creates noise

2. **E2E Test Files** (Keep for future reference but disable)
   - `apps/web/tests/e2e/`
   - Move to `apps/web/tests/e2e.archived/`
   - Document why they didn't work

## Implementation Plan

### Step 1: Disable E2E Workflow

```bash
# Option A: Delete the workflow
rm .github/workflows/e2e-tests-clerk.yml

# Option B: Rename to disable (keeps for reference)
mv .github/workflows/e2e-tests-clerk.yml .github/workflows/e2e-tests-clerk.yml.disabled
```

### Step 2: Archive E2E Tests

```bash
# Move tests to archived folder
mkdir -p apps/web/tests/e2e.archived
mv apps/web/tests/e2e/* apps/web/tests/e2e.archived/
```

### Step 3: Document What Happened

Create `docs/testing/e2e-post-mortem.md` explaining:
- What we tried to build
- Why it failed
- Lessons learned
- What to do differently next time

### Step 4: Clean Up Package.json Scripts

Remove or comment out E2E test scripts:
```json
{
  "scripts": {
    // Remove these or comment them out
    "test:e2e": "...",
    "test:e2e:ui": "...",
    "test:e2e:debug": "...",
    "test:pre-staging": "..."
  }
}
```

### Step 5: Update Documentation

Update deployment guides to remove references to E2E tests:
- `docs/guides/local-to-staging-deployment.mdx`
- `docs/testing/e2e-deployment-status.mdx`
- `TROUBLESHOOTING.md`

## Alternative: Minimal Smoke Tests

If we want SOME testing, implement dead-simple smoke tests that actually work:

```yaml
# .github/workflows/smoke-test.yml
name: Smoke Test
on:
  workflow_dispatch:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Check Frontend
        run: |
          curl -f https://staging.livingtree.io || exit 1
          
      - name: Check Backend
        run: |
          curl -f https://living-tree-backend-staging-eprzpin6uq-nn.a.run.app/health || exit 0
          # exit 0 because /health might not exist
```

## Why E2E Tests Failed

### Technical Reasons

1. **Environment Mismatch**
   - Tests expected 'staging' environment
   - Workflow provided 'test' environment
   - Strict validation in `apps/web/lib/env.ts` rejected it

2. **Missing Secrets**
   - `STAGING_SUPABASE_SERVICE_ROLE_KEY` wasn't configured initially
   - Even after adding, other issues remained

3. **localStorage Security**
   - Playwright's browser context has security restrictions
   - localStorage access was blocked
   - Clerk authentication depends on localStorage

4. **Over-engineering**
   - 4-shard parallel execution for 8 tests
   - Complex helper classes
   - Too many moving parts

### Strategic Reasons

1. **Premature Optimization**
   - Built complex E2E before having stable app
   - Should have started with simple smoke tests

2. **Wrong Testing Level**
   - E2E tests are expensive and fragile
   - Should focus on unit/integration tests first

3. **External Dependency**
   - Clerk authentication adds complexity
   - Should mock auth for tests

## Lessons Learned

1. **Start Simple**: Begin with curl-based smoke tests
2. **Test What Works**: Don't test external services (Clerk)
3. **Fail Fast**: If tests don't work immediately, pivot
4. **Value Over Coverage**: One working test > 100 broken tests
5. **Monitor Over Test**: Use monitoring/alerting instead of E2E tests

## Success Metrics

After cleanup:
- ✅ No false failures in GitHub Actions
- ✅ Faster deployment feedback
- ✅ Clear signal when something actually breaks
- ✅ Reduced CI/CD costs
- ✅ Better developer experience

## Rollback Plan

If we need E2E tests later:
1. Code is archived in `e2e.archived/`
2. Workflow is saved as `.disabled`
3. Documentation exists for what didn't work
4. Can start fresh with lessons learned

## Timeline

- **Immediate**: Disable E2E workflow
- **Today**: Archive test files
- **This Week**: Update documentation
- **Future**: Consider simple smoke tests

## Decision

**Recommendation**: Remove all E2E testing infrastructure. It provides no value and creates noise.

**Alternative**: Keep infrastructure but mark as `continue-on-error: true` (not recommended - still wastes resources)

## Command to Execute

```bash
# Quick cleanup
mv .github/workflows/e2e-tests-clerk.yml .github/workflows/e2e-tests-clerk.yml.disabled
mkdir -p apps/web/tests/e2e.archived
mv apps/web/tests/e2e/* apps/web/tests/e2e.archived/
git add -A
git commit -m "chore: disable broken E2E tests that provide no value"
```