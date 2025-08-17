# SPEC PRP: Staging Merge Conflict Resolution

## Specification

Resolve the critical database migration conflict that prevents safe merging of `jerin/lt-138-naildown-environment-variables` branch to staging. The branch contains valuable Docker improvements but has a conflicting migration that would break the existing `email_triage_results` table.

## Current State Assessment

### Files Affected

- `supabase/migrations/20250729011633_create_email_triage_tables.sql` - Conflicting migration
- `apps/web/supabase/` - Duplicate empty folder (already removed)

### Current Behavior

- Local development has correct `email_triage_results` schema with 23 columns
- Migration attempts to create a different schema with incompatible column names
- Migration would fail in staging/production due to table already existing

### Technical Issues

1. **Schema Conflict**: Migration has `priority_score` (integer 1-5) vs existing `priority_level` (text)
2. **Column Mismatch**: Migration has `urgency` (text) vs existing `urgency_score` (numeric)
3. **RLS Policy**: Migration uses `auth.uid()` incompatible with Clerk auth
4. **Duplicate Migration**: Same file exists in two locations

## Desired State

### Target Structure

```yaml
files:
  - supabase/migrations/ # Only valid migrations, no conflicts
  - No duplicate supabase folders in apps/web/

behavior:
  - All migrations can be safely applied to staging/production
  - Existing table schemas are preserved
  - Branch can be merged without database errors
```

### Benefits

- Safe deployment to staging and production
- Preserved existing functionality
- Docker improvements can be deployed
- Clean migration history

## Hierarchical Objectives

### High-Level Goal

Enable safe merge of Docker improvements while preventing database schema conflicts

### Mid-Level Objectives

1. Remove conflicting migration files
2. Verify schema consistency across environments
3. Document the correct schema for future reference

### Low-Level Tasks

#### Task 1: Remove Conflicting Migration

```yaml
action: DELETE
file: supabase/migrations/20250729011633_create_email_triage_tables.sql
validation:
  - command: "ls supabase/migrations/20250729011633_create_email_triage_tables.sql"
  - expect: "No such file or directory"
```

#### Task 2: Verify No Duplicate Migrations

```yaml
action: VERIFY
path: apps/web/supabase/
validation:
  - command: "ls -la apps/web/supabase/ 2>&1"
  - expect: "No such file or directory"
```

#### Task 3: Document Correct Schema

```yaml
action: CREATE
file: supabase/schema-docs/email_triage_results.md
content: |
  # email_triage_results Table Schema

  Current production schema for reference:

  ## Columns
  - id: uuid (primary key)
  - user_id: text (not null)
  - email_id: text (not null)
  - subject: text
  - sender: text
  - snippet: text
  - priority_level: text (not priority_score)
  - urgency_score: numeric(3,2) (not urgency text)
  - [... rest of 23 columns documented ...]

  ## RLS Policy
  Uses current_user_id() function for Clerk compatibility
validation:
  - command: "cat supabase/schema-docs/email_triage_results.md | grep priority_level"
  - expect: "priority_level: text"
```

#### Task 4: Create Migration Validation Script

```yaml
action: CREATE
file: scripts/validate-schema-compatibility.sh
content: |
  #!/bin/bash
  # Validates that migrations don't conflict with existing schema

  echo "Checking for conflicting migrations..."

  # Check for any migrations trying to CREATE TABLE without IF NOT EXISTS
  if grep -r "CREATE TABLE public.email_triage_results" supabase/migrations/ | grep -v "IF NOT EXISTS"; then
    echo "❌ Found migration trying to create existing table"
    exit 1
  fi

  echo "✅ No conflicting migrations found"
validation:
  - command: "chmod +x scripts/validate-schema-compatibility.sh && ./scripts/validate-schema-compatibility.sh"
  - expect: "✅ No conflicting migrations found"
```

#### Task 5: Update Git and Commit

```yaml
action: EXECUTE
commands:
  - git rm supabase/migrations/20250729011633_create_email_triage_tables.sql
  - git add supabase/schema-docs/email_triage_results.md
  - git add scripts/validate-schema-compatibility.sh
  - git commit -m "fix: remove conflicting email_triage_results migration

    - Migration attempted to create table with incompatible schema
    - Table already exists in staging/production with correct schema
    - Added schema documentation for future reference
    - Added validation script to prevent future conflicts"
validation:
  - command: "git log --oneline -1"
  - expect: "fix: remove conflicting email_triage_results migration"
```

## Implementation Strategy

### Order of Operations

1. Remove conflicting files (prevents immediate issues)
2. Document correct schema (prevents future confusion)
3. Add validation tooling (prevents recurrence)
4. Commit changes (makes fix permanent)

### Dependencies

- Must complete task 1 before merging
- Tasks 3-4 improve future development but aren't blocking

### Rollback Plan

If issues occur:

```bash
# Revert the removal
git revert HEAD

# Re-examine the migration for salvageable parts
# Create a new conditional migration if needed
```

## Risk Assessment

### Identified Risks

1. **Staging schema differs from local** - Mitigated by verification step
2. **Migration had important changes** - Mitigated by schema documentation
3. **Future confusion about schema** - Mitigated by documentation

### Go/No-Go Criteria

- ✅ GO if staging already has email_triage_results table
- ✅ GO if existing schema matches documented columns
- ❌ NO-GO if staging is missing the table (would need different approach)

## Integration Points

- Staging database must be checked before merge
- CI/CD pipelines will run remaining migrations
- No changes needed to application code

## Success Criteria

1. Branch can be merged without database errors
2. Existing email triage functionality continues working
3. Docker improvements are successfully deployed
4. No data loss or schema changes

## Post-Implementation

1. Monitor staging deployment for any errors
2. Verify email triage still works correctly
3. Document this issue in team knowledge base
4. Consider adding pre-merge schema validation to CI
