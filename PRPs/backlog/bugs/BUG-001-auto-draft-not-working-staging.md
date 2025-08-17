# BUG-001: Auto-Draft Feature Not Working in Staging

**Status**: Partially Resolved  
**Environment**: Staging (https://staging.livingtree.io)  
**Reported**: 2025-07-25  
**Severity**: High  
**Components**: Backend (FastAPI), Database (Supabase), Gmail Integration (OAuth)

## Issue Description

The auto-draft feature in staging environment was completely non-functional:

1. Toggle state wasn't persisting properly when enabling/disabling the feature
2. No email drafts were being created even when feature was enabled
3. Backend deployment had been failing since July 23rd, preventing any fixes from reaching staging

## Root Causes Identified

### 1. Backend Deployment Failures (RESOLVED)

- **Issue**: Backend container was failing startup probe checks
- **Cause**: Initial assumption was container startup failures, but service was actually running
- **Impact**: Created confusion about deployment status
- **Resolution**: Deployment was actually successful, just reported as failed due to probe timing

### 2. Database Constraint Violation (RESOLVED)

- **Issue**: `draft_metadata_draft_type_check` constraint was too restrictive
- **Cause**: AI was generating draft types like `document_request` not in the allowed list
- **Error**: `new row for relation "draft_metadata" violates check constraint "draft_metadata_draft_type_check"`
- **Resolution**: Updated constraint to include comprehensive list of AI-generated draft types

### 3. Gmail OAuth Scope Insufficiency (PENDING USER ACTION)

- **Issue**: Gmail API returning "Request had insufficient authentication scopes"
- **Cause**: Users authorized Gmail without draft creation permissions
- **Error**: `HttpError 403: insufficientPermissions`
- **Resolution**: Users must re-authorize Gmail connection with proper scopes

### 4. RLS Policy Issues (PREVIOUSLY FIXED)

- **Issue**: RLS policies were using `auth.uid()` instead of `current_user_id()` for Clerk
- **Status**: Already fixed in previous migration `20250719000000_fix_auto_drafts_rls.sql`

### 5. Health Check Path Mismatch (RESOLVED - 2025-07-25)

- **Issue**: Cloud Run startup probe checking `/health` but app serves at `/api/health`
- **Cause**: Default Cloud Run configuration doesn't match FastAPI routes
- **Impact**: All new deployments fail health checks, old revision keeps serving
- **Resolution**: Added explicit probe configuration in GitHub Actions workflow (PR #66)

### 6. Integrations Page OAuth Flow Mismatch (RESOLVED - 2025-07-25)

- **Issue**: Integrations page showing "Integration 'google' not supported" error
- **Cause**: Page was using old custom OAuth flow instead of Clerk OAuth
- **Impact**: Users couldn't find how to connect Gmail properly
- **Resolution**: Updated integrations page to guide users to Clerk account settings

## Troubleshooting Steps Taken

### 1. Initial Investigation

```bash
# Checked migration files for auto-draft tables
ls supabase/migrations/*auto*

# Attempted to query staging database
# Found RLS policies already fixed in previous migration
```

### 2. Backend Deployment Investigation

```bash
# Checked deployment status
gh run list --workflow="deploy-backend-staging.yml"

# Found multiple failed deployments
# Discovered backend running old code from July 23rd

# Created PR #63 and #64 to fix mypy type errors
# Fixed __init__.py type annotation issue
```

### 3. Database Constraint Fix

```sql
-- Created migration 20250725131924_add_document_request_draft_type.sql
ALTER TABLE draft_metadata
DROP CONSTRAINT IF EXISTS draft_metadata_draft_type_check;

ALTER TABLE draft_metadata
ADD CONSTRAINT draft_metadata_draft_type_check
CHECK (draft_type IN (
    'reply', 'forward', 'new', 'information_request',
    'acknowledgment', 'scheduling', 'document_request',
    'follow_up', 'confirmation', 'question', 'thank_you',
    'invitation', 'reminder', 'update', 'introduction'
));
```

### 4. Log Analysis

```bash
# Found service is running and processing emails
gcloud logging read 'resource.labels.service_name="living-tree-backend-staging"'

# Discovered two main errors:
# 1. Database constraint violations
# 2. Gmail OAuth scope issues
```

## Current Status

### Working ✅

- Database constraint has been updated to accept all draft types
- GitHub Actions workflow has been fixed to specify correct health check path
- Backend deployment successful with new code (revision 00183-g7z)
- Auto-draft monitor is running and processing users
- Integrations page now properly guides users to Clerk OAuth

### Not Working ❌

- Gmail draft creation blocked by OAuth scope issues
- Users cannot create drafts until they re-authorize through Clerk

### Partially Working ⚠️

- User can read emails (OAuth read scope works)
- Toggle state persists but auto-drafts fail due to missing draft permissions

## Next Steps

### Immediate Actions Required

1. **User Communication**
   - Notify affected users they need to re-authorize Gmail
   - Create user-facing documentation for re-authorization process
   - Consider in-app notification when OAuth error occurs

2. **Code Improvements**

   ```typescript
   // Add better error handling in frontend
   if (error.message.includes("insufficient scopes")) {
     toast.error("Please reconnect your Gmail account with draft permissions");
     // Redirect to settings or show re-auth button
   }
   ```

3. **OAuth Scope Verification**
   - Add scope checking on Gmail connection
   - Prevent auto-draft toggle if scopes insufficient
   - Show warning message about required permissions

### Long-term Improvements

1. **Monitoring**
   - Add metrics for auto-draft success/failure rates
   - Alert on high failure rates
   - Track OAuth scope issues separately

2. **User Experience**
   - Add "Test Auto-Draft" button to verify setup
   - Show last successful draft creation time
   - Better error messages for common issues

3. **Technical Debt**
   - Consider making draft_type an enum in database
   - Add validation for draft types in backend
   - Improve deployment health checks

## Verification Steps

To verify the fix is working:

```bash
# 1. Check constraint is updated
echo "SELECT conname, pg_get_constraintdef(oid)
FROM pg_constraint
WHERE conname = 'draft_metadata_draft_type_check'" | npx supabase db remote query

# 2. Monitor for successful draft creation
gcloud logging read 'resource.labels.service_name="living-tree-backend-staging"
AND textPayload:"Successfully processed auto draft"' --limit=10

# 3. Check for OAuth errors
gcloud logging read 'resource.labels.service_name="living-tree-backend-staging"
AND textPayload:"insufficient authentication scopes"' --limit=10
```

## Related PRs and Commits

- PR #63: Initial attempt to fix deployment (type errors)
- PR #64: Fix mypy error in `__init__.py`
- PR #65: Fix auto-draft constraint and deployment issues
- Commit 57f75f3: Update draft_metadata constraint
- Migration 20250725131924: Add document_request and other draft types

## Lessons Learned

1. **Deployment Monitoring**: Container startup failures can be misleading - service may still be running
2. **Constraint Design**: AI-generated content needs flexible constraints
3. **OAuth Complexity**: Scope changes require user re-authorization
4. **Error Visibility**: Backend errors not surfacing to frontend made debugging difficult
5. **Migration Testing**: Always verify migrations are actually applied and working

## Prevention Measures

1. Add integration tests for auto-draft feature
2. Implement better error reporting from backend to frontend
3. Add monitoring for OAuth scope issues
4. Create runbook for common auto-draft issues
5. Add pre-deployment checks for database constraints vs AI output

## User Workaround

Users experiencing auto-draft issues should:

### Method 1: Through Clerk Account Settings (Recommended)

1. Go to the Integrations page at https://staging.livingtree.io/integrations
2. Click "Connect Gmail in Account Settings" button
3. This opens your Clerk account at https://accounts.livingtree.io/user
4. Find Google under connected accounts
5. Disconnect and reconnect Google
6. **Important**: Grant ALL requested permissions including:
   - Read emails
   - Send emails
   - **Manage drafts** (this is the missing permission)
7. Return to Living Tree and verify connection on integrations page
8. Re-enable auto-draft feature in /tools
9. Wait 1-2 minutes for first draft to be created

### Method 2: Sign Out and Back In

1. Sign out of Living Tree completely
2. Sign back in using "Continue with Google"
3. Grant ALL permissions when prompted
4. Verify connection on integrations page
5. Enable auto-draft feature in /tools

## References

- [Clerk OAuth Documentation](https://clerk.com/docs/authentication/oauth)
- [Gmail API Scopes](https://developers.google.com/gmail/api/auth/scopes)
- [Supabase RLS Policies](https://supabase.com/docs/guides/auth/row-level-security)
