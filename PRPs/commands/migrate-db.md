# Database Migration Management for Living Tree

Manage database migrations across all Living Tree environments (local, staging, production) safely and consistently.

## Critical Migration Rules

⚠️ **ALWAYS follow this order:**

1. Local (development/testing)
2. Staging (verification)
3. Production (final deployment)

**NEVER skip environments or apply directly to production!**

## Quick Migration Status Check

```bash
# Check all environments at once
echo "=== Living Tree Migration Status ==="
echo ""
echo "LOCAL:"
npx supabase migration list | tail -5

echo -e "\nSTAGING (fwdfewruzeaplmcezyne):"
npx supabase link --project-ref fwdfewruzeaplmcezyne >/dev/null 2>&1
npx supabase migration list --linked | tail -5

echo -e "\nPRODUCTION (zunxilwvjbpkhzrbaxmk):"
npx supabase link --project-ref zunxilwvjbpkhzrbaxmk >/dev/null 2>&1
npx supabase migration list --linked | tail -5
```

## 1. Creating a New Migration

### Generate Migration File

```bash
# Create new migration with descriptive name
npx supabase migration new add_user_preferences_table

# This creates: supabase/migrations/[timestamp]_add_user_preferences_table.sql
```

### Write Migration SQL

```sql
-- Example: Adding a new table with RLS
CREATE TABLE user_preferences (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  theme TEXT DEFAULT 'light',
  email_notifications BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE user_preferences ENABLE ROW LEVEL SECURITY;

-- Create RLS policy
CREATE POLICY "Users can manage their own preferences"
ON user_preferences
FOR ALL
USING (user_id = auth.uid()::text);

-- Create updated_at trigger
CREATE TRIGGER update_user_preferences_updated_at
  BEFORE UPDATE ON user_preferences
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

### Common Migration Patterns

1. **Adding a Column**

```sql
ALTER TABLE email_triage_results
ADD COLUMN priority_score INTEGER DEFAULT 0;

-- Backfill existing data if needed
UPDATE email_triage_results
SET priority_score = 5
WHERE priority = 'high';
```

2. **Creating Indexes**

```sql
CREATE INDEX idx_email_triage_user_created
ON email_triage_results(user_id, created_at DESC);
```

3. **Modifying Constraints**

```sql
-- Add foreign key
ALTER TABLE auto_drafts
ADD CONSTRAINT fk_auto_drafts_user
FOREIGN KEY (user_id) REFERENCES users(id);
```

## 2. Testing Migrations Locally

### Apply to Local Database

```bash
# Apply all pending migrations
npx supabase db push

# Or reset and reapply all
npx supabase db reset
```

### Verify Migration

```bash
# Check migration was applied
npx supabase migration list

# Test in Supabase Studio
open http://localhost:54323

# Regenerate TypeScript types
pnpm types
```

### Test with Application

```bash
# Start dev environment
pnpm dev:full

# Test affected features
# - Create test data
# - Verify RLS policies
# - Check API endpoints
```

## 3. Deploying to Staging

### Pre-Staging Checklist

- [ ] Migration tested locally
- [ ] Types regenerated (`pnpm types`)
- [ ] Code changes committed
- [ ] API/frontend updated for schema changes

### Apply to Staging

```bash
# Link to staging
npx supabase link --project-ref fwdfewruzeaplmcezyne

# Review what will be applied
npx supabase migration list --linked

# Apply migrations
npx supabase db push --linked

# Verify
npx supabase migration list --linked
```

### Test Staging

```bash
# Check staging app
open https://staging.livingtree.io

# Test API endpoints
curl https://living-tree-backend-staging-eprzpin6uq-nn.a.run.app/health

# Monitor logs
vercel logs living-tree-web --scope livingtree
```

## 4. Deploying to Production

### Pre-Production Checklist

- [ ] Tested on staging for 24+ hours
- [ ] No issues reported
- [ ] Backup created
- [ ] Maintenance window scheduled (if needed)

### Backup Production First

```bash
# Create backup
npx supabase link --project-ref zunxilwvjbpkhzrbaxmk
npx supabase db dump --linked > backup_$(date +%Y%m%d_%H%M%S).sql
```

### Apply to Production

```bash
# Link to production
npx supabase link --project-ref zunxilwvjbpkhzrbaxmk

# Final review
npx supabase migration list --linked

# Apply migrations (BE VERY CAREFUL!)
npx supabase db push --linked

# Verify immediately
npx supabase migration list --linked
```

### Post-Production Verification

```bash
# Test production
open https://app.livingtree.io

# Check API health
curl https://living-tree-backend-production-eprzpin6uq-nn.a.run.app/health

# Monitor for errors
# Check Vercel logs
# Check Google Cloud logs
# Check Supabase logs
```

## 5. Rolling Back Migrations

### Emergency Rollback Procedure

1. **Create Rollback Migration**

```bash
# Create inverse migration
npx supabase migration new rollback_user_preferences

# Write rollback SQL
echo "DROP TABLE IF EXISTS user_preferences CASCADE;" > supabase/migrations/*_rollback_user_preferences.sql
```

2. **Apply Rollback**

```bash
# Test locally first
npx supabase db push

# Then staging
npx supabase link --project-ref fwdfewruzeaplmcezyne
npx supabase db push --linked

# Finally production if needed
npx supabase link --project-ref zunxilwvjbpkhzrbaxmk
npx supabase db push --linked
```

## 6. Migration Best Practices

### DO's

- ✅ Always test locally first
- ✅ Use descriptive migration names
- ✅ Include rollback considerations
- ✅ Add RLS policies for new tables
- ✅ Update TypeScript types after changes
- ✅ Document breaking changes
- ✅ Use transactions for complex migrations

### DON'Ts

- ❌ Never edit existing migration files
- ❌ Don't skip environments
- ❌ Avoid destructive changes without backup
- ❌ Don't use CASCADE DELETE without careful thought
- ❌ Never hardcode user IDs or environment-specific data

## 7. Troubleshooting Migration Issues

### Migration Conflicts

```bash
# If migrations are out of sync
npx supabase migration repair --status applied [migration_name]

# Force reapply
npx supabase db reset --linked
```

### Type Generation Failures

```bash
# Clear and regenerate
rm -rf apps/web/types/database.types.ts
pnpm types
```

### RLS Policy Issues

```sql
-- Debug RLS policies
SET ROLE postgres;
SELECT * FROM pg_policies WHERE tablename = 'your_table';

-- Test as specific user
SET ROLE authenticated;
SET request.jwt.claim.sub = 'user_id_here';
SELECT * FROM your_table;
```

## 8. Migration Commands Reference

```bash
# Create new migration
npx supabase migration new [name]

# List migrations
npx supabase migration list [--linked]

# Apply migrations
npx supabase db push [--linked]

# Reset database
npx supabase db reset [--linked]

# Create dump
npx supabase db dump [--linked] > backup.sql

# Repair migration status
npx supabase migration repair --status [applied|pending|reverted] [name]

# Diff databases
npx supabase db diff --schema public
```

## 9. Environment Migration Checklist

### Local Development

- [ ] Create migration file
- [ ] Write and review SQL
- [ ] Apply with `db push`
- [ ] Test functionality
- [ ] Regenerate types
- [ ] Update code for changes

### Staging Deployment

- [ ] Link to staging project
- [ ] Review pending migrations
- [ ] Apply migrations
- [ ] Test on staging URL
- [ ] Monitor for 24 hours
- [ ] Document any issues

### Production Deployment

- [ ] Create backup
- [ ] Schedule maintenance window
- [ ] Link to production project
- [ ] Apply migrations
- [ ] Verify immediately
- [ ] Monitor closely
- [ ] Keep backup for 7 days

Remember: Database migrations are critical operations. Take your time, test thoroughly, and always have a rollback plan!
