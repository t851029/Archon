# Staging Merge Impact Assessment

## Branch: `jerin/lt-138-naildown-environment-variables`

**Date**: July 29, 2025  
**Commits**: 2 new commits since staging
**Last Validated**: July 29, 2025 (Updated)

## Executive Summary

This branch introduces Docker image lifecycle management improvements and minor environment variable refinements. The changes are mostly **non-breaking** and focus on improving developer experience and preventing disk space issues. However, there is one database-related issue that needs attention.

## Changes Overview

### 1. Docker Image Management (Primary Focus)

- **New Features**:
  - Automated Docker cleanup scripts (`docker-cleanup-immediate.sh`, `docker-maintenance.sh`)
  - GitHub Actions workflow for weekly Docker cleanup
  - Consistent image naming convention (`living-tree/{service}:{tag}`)
  - BuildKit cache optimizations in Dockerfiles
  - `.dockerignore` file to reduce build context size

- **Impact**: Low risk, high benefit
- **Action Required**: None - these are additive improvements

### 2. Environment Variable Changes (Minor)

- **Changes**:
  - Updated API routes to use `env.SUPABASE_URL` instead of `env.server.SUPABASE_URL`
  - Same pattern for `SUPABASE_SERVICE_ROLE_KEY`
  - Added TypeScript return types to functions

- **Impact**: Low risk - appears to be a simplification
- **Action Required**: Verify environment variables are properly set in staging

### 3. Database Changes (⚠️ CRITICAL - Schema Conflict)

- **New Migration**: `20250729011633_create_email_triage_tables.sql`
  - **CONFLICT CONFIRMED**: The migration tries to create `email_triage_results` with a DIFFERENT schema than the existing table
  - **Existing Schema**: Has 23 columns including `priority_level` (text), `urgency_score` (numeric), etc.
  - **Migration Schema**: Has different columns like `priority_score` (integer 1-5), `urgency` (text), `triage_date`
  - **RLS Policy Issue**: Migration uses `auth.uid()` but should use `current_user_id()` for Clerk compatibility
- **Additional Issues Found**:
  - Duplicate empty supabase folder in `apps/web/supabase/` (now removed)
  - All required tables (`auto_draft_settings`, `draft_metadata`, etc.) exist in local dev

- **Impact**: HIGH RISK - Migration will fail due to table already existing
- **Action Required**:
  1. ✅ `email_triage_results` already exists with DIFFERENT schema
  2. ✅ `auto_draft_settings` exists and is working
  3. ❌ MUST skip or modify the migration to avoid conflicts

## Pre-Merge Checklist

### 🔴 Critical Actions (Must Do)

1. **SKIP THE CONFLICTING MIGRATION**:

   ```bash
   # The 20250729011633_create_email_triage_tables.sql migration MUST NOT be applied
   # It conflicts with the existing email_triage_results table schema

   # Option 1: Remove the migration file before merge
   rm supabase/migrations/20250729011633_create_email_triage_tables.sql

   # Option 2: Modify migration to be conditional
   # Add IF NOT EXISTS and match existing schema
   ```

2. **Verify staging has all required tables**:
   ```bash
   # Check staging database for existing tables
   npx supabase link --project-ref fwdfewruzeaplmcezyne
   npx supabase db show | grep -E "(email_triage_results|auto_draft_settings|draft_metadata)"
   ```

### 🟡 Important Actions (Should Do)

1. **Test Environment Variables**:
   - Verify staging has all required env vars set
   - Check that the simplified env access pattern works

2. **Review Docker Setup**:
   - Ensure staging deployment can use new Docker optimizations
   - Consider running cleanup scripts after deployment

### 🟢 Nice to Have

1. **Update CI/CD**:
   - Enable the new Docker cleanup GitHub Action
   - Configure for staging environment

## Breaking Changes Assessment

**BREAKING CHANGE IDENTIFIED**:

- ❌ Database migration `20250729011633_create_email_triage_tables.sql` conflicts with existing schema
- ✅ Environment variable access pattern changed (backward compatible)
- ✅ Docker changes are additive (non-breaking)

## Rollback Plan

If issues occur after merge:

1. **Database**: Migrations can be skipped if tables exist
2. **Docker**: New features are additive, can be ignored
3. **Env Vars**: The old pattern should still work

## Recommended Merge Strategy

1. **BEFORE MERGE**: Remove or fix the conflicting migration

   ```bash
   # Remove the problematic migration
   git rm supabase/migrations/20250729011633_create_email_triage_tables.sql
   git commit -m "fix: remove conflicting email_triage_results migration"
   git push origin jerin/lt-138-naildown-environment-variables
   ```

2. **Verify staging database state**:

   ```bash
   # Connect to staging DB and verify schema matches local
   npx supabase link --project-ref fwdfewruzeaplmcezyne
   npx supabase db show

   # If schema differs, create a proper migration to align them
   ```

3. **Merge with monitoring**:
   - No database migration failures expected after removing conflict
   - Docker improvements will take effect immediately
   - Monitor for any environment variable issues

## Benefits of This Merge

1. **Prevents Docker disk space issues** - Automated cleanup will save GB of space
2. **Improved build performance** - BuildKit cache mounts speed up builds
3. **Better documentation** - Enhanced CLAUDE.md with Docker management section
4. **Cleaner codebase** - Simplified environment variable access

## Risks and Mitigations

| Risk                        | Likelihood  | Impact       | Mitigation                             |
| --------------------------- | ----------- | ------------ | -------------------------------------- |
| Database migration conflict | **CERTAIN** | **CRITICAL** | Remove conflicting migration           |
| Schema mismatch after merge | Medium      | High         | Verify staging matches expected schema |
| Env var issues              | Low         | Low          | Test after deployment                  |
| Docker compatibility        | Low         | Low          | Features are optional                  |

## Conclusion

This merge is **NOT SAFE** without addressing the database migration conflict. The conflicting `email_triage_results` migration MUST be removed or modified before merging.

**Updated Recommendation**:

1. Remove the `20250729011633_create_email_triage_tables.sql` migration file
2. Verify staging database schema matches expectations
3. Then proceed with merge - Docker improvements provide significant value

## Additional Notes

- The existing `email_triage_results` table appears to be the correct schema being used in production
- The new migration seems to be an older/different version that would break existing functionality
- All other changes (Docker, env vars) are safe and beneficial
