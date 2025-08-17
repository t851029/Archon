# BUG: Clerk Rate Limiting Due to Infinite Token Refresh Loop

## Bug Summary

The application is experiencing severe rate limiting (429 errors) from Clerk API due to an infinite loop caused by improper React hook dependencies. The `getToken` function is included in useEffect dependency arrays, causing it to re-run continuously because the function reference changes on every render.

## Severity: Critical 🔴

This bug prevents the application from functioning in staging and causes excessive API usage that could lead to service suspension.

## Affected Environments

- [x] Staging
- [x] Production (potential)
- [ ] Local (less noticeable due to slower execution)

## Root Cause

The `getToken` function from Clerk's `useAuth` hook is being incorrectly included in useEffect dependency arrays. Since this function is recreated on every render, it triggers the effect repeatedly, creating an infinite loop of API calls.

### Technical Explanation

```typescript
// INCORRECT - Current Implementation
const { getToken } = useAuth();

useEffect(() => {
  const loadData = async () => {
    const token = await getToken();
    // ... fetch data
  };
  loadData();
}, [getToken]); // ❌ getToken changes every render = infinite loop
```

Every render creates a new `getToken` function reference → useEffect sees a "changed" dependency → effect runs again → component re-renders → cycle repeats infinitely.

## Affected Files

1. **`/apps/web/app/(app)/tools/tools-page-client.tsx`** (line ~115)
   - Infinite loop when loading tools status
   - Causes repeated token requests on tools page

2. **`/apps/web/components/tools/auto-drafts-settings.tsx`** (line ~71)
   - Infinite loop when loading auto-draft settings
   - Prevents settings from loading properly

## Symptoms

- Console shows repeated network requests to Clerk API
- 429 (Too Many Requests) errors from `api.clerk.com`
- Components stuck in loading state
- Browser becomes unresponsive
- Staging deployment failures
- Rate limit errors: "Rate limit exceeded, please try again later"

## Fix Implementation

### Solution 1: Remove getToken from Dependencies (Recommended)

```typescript
// CORRECT - Access getToken from closure
const { getToken } = useAuth();

useEffect(() => {
  const loadData = async () => {
    const token = await getToken(); // Access from closure
    // ... fetch data
  };
  loadData();
}, []); // ✅ Empty dependency array - getToken accessed from closure
```

### Solution 2: Custom Hook Pattern

```typescript
// Create a stable authenticated fetch hook
export function useAuthenticatedFetch() {
  const { getToken } = useAuth();

  return useCallback(async (url: string, options?: RequestInit) => {
    const token = await getToken();

    return fetch(url, {
      ...options,
      headers: {
        ...options?.headers,
        Authorization: `Bearer ${token}`,
      },
    });
  }, []); // Stable function reference
}
```

## Step-by-Step Fix

1. **Update `/apps/web/app/(app)/tools/tools-page-client.tsx`**:

   ```typescript
   // Line ~115 - Remove getToken from dependencies
   useEffect(() => {
     const loadToolsStatus = async () => {
       try {
         const token = await getToken();
         if (!token) return;

         const response = await fetch("/api/integrations/status", {
           headers: { Authorization: `Bearer ${token}` },
         });
         // ... rest of logic
       } catch (error) {
         console.error("Error loading tools:", error);
       }
     };

     loadToolsStatus();
   }, []); // Empty array instead of [getToken]
   ```

2. **Update `/apps/web/components/tools/auto-drafts-settings.tsx`**:
   ```typescript
   // Line ~71 - Remove getToken from dependencies
   useEffect(() => {
     const loadSettings = async () => {
       try {
         setIsLoadingSettings(true);
         const token = await getToken();
         if (!token) return;

         const response = await fetch("/api/auto-drafts/settings", {
           headers: { Authorization: `Bearer ${token}` },
         });
         // ... rest of logic
       } finally {
         setIsLoadingSettings(false);
       }
     };

     loadSettings();
   }, []); // Empty array instead of [getToken]
   ```

## Testing Steps

1. **Local Testing**:

   ```bash
   cd apps/web
   pnpm dev
   ```
   - Navigate to `/tools`
   - Open browser DevTools Network tab
   - Verify only ONE token request on page load
   - Toggle auto-draft settings
   - Confirm no repeated requests

2. **Check for Rate Limiting**:
   - Monitor console for 429 errors
   - Verify no "Rate limit exceeded" messages
   - Ensure components load without infinite spinning

3. **Performance Testing**:
   - Page should load within 2 seconds
   - No browser lag or unresponsiveness
   - Memory usage should remain stable

## Prevention

1. **Linting Rule**: Add ESLint rule to warn about function dependencies:

   ```json
   {
     "rules": {
       "react-hooks/exhaustive-deps": [
         "warn",
         {
           "additionalHooks": "(useEffect|useCallback)"
         }
       ]
     }
   }
   ```

2. **Code Review Checklist**:
   - [ ] Check all useEffect dependencies
   - [ ] Verify no functions in dependency arrays (unless memoized)
   - [ ] Test for infinite loops locally before PR

3. **Documentation**: Update coding standards to include this pattern

## Related Issues

- Previous rate limiting issues: `/PRPs/fix-clerk-rate-limiting-deployment.md`
- Clerk custom domain issues with Python SDK
- JWT verification failures in staging

## Metrics to Monitor

- Clerk API usage dashboard
- 429 error rate in application logs
- Page load times for tools and settings pages
- Browser memory usage over time

## Additional Context

This bug was discovered during staging deployment when Gmail functionality stopped working. Investigation revealed that the Python SDK couldn't communicate with Clerk's custom domain, but the underlying issue was the infinite loop causing rate limiting even before the custom domain problem.

### Rate Limit Information

- **Production Instances**: 1000 requests per 10 seconds
- **Development Instances**: 100 requests per 10 seconds
- **Current Usage**: Infinite loop can generate 100+ requests per second

---

**Created**: 2025-07-23
**Status**: Open
**Priority**: Critical
**Assignee**: TBD
**Labels**: bug, performance, authentication, rate-limiting
