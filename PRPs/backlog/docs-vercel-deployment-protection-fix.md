# Docs Vercel Deployment Protection Fix

## Problem Description

The docs app in the monorepo deploys successfully to Vercel but returns a 401 Unauthorized error with a Vercel SSO authentication page, making it inaccessible to users.

## Root Cause Analysis

**Vercel Deployment Protection is enabled** on the project. The deployment completes without build errors but runtime fails with HTTP 401 due to SSO protection settings.

### Evidence

- ✅ **Build succeeds** - Deployment completes without build errors
- ❌ **Runtime fails** - Returns HTTP 401 with Vercel authentication page
- 🔍 **SSO page content** - Shows "Vercel Authentication" with automatic redirect to SSO API

## Verified Solution (July 2025)

### Recommended Fix: Disable Deployment Protection

**Go to Vercel Dashboard** → [livingtree team](https://vercel.com/livingtree) → `docs` project → **Settings** → **Deployment Protection** → Set to **"Disabled"**

### Dashboard Steps:

1. **Go to Vercel Dashboard** → Sign in to [vercel.com](https://vercel.com)
2. **Select your team** → `livingtree`
3. **Select the project** → `docs`
4. **Navigate to Settings** → Click "Settings" in the project navigation
5. **Find Deployment Protection** → Look for "Deployment Protection" section
6. **Choose Protection Level:**
   - **Option A (Recommended)**: Set to **"Disabled"** for completely public access
   - **Option B**: Set to **"Only Preview Deployments"** to keep production public but protect previews

### Why This is Recommended for Documentation:

1. **Documentation should be public** - Docs are meant to be openly accessible to users, developers, and the community
2. **No authentication barriers** - Users shouldn't need to sign in to read documentation
3. **SEO benefits** - Search engines can index your docs for better discoverability
4. **Simplest solution** - No need to manage exceptions or complex rules
5. **Standard practice** - Most successful docs sites (GitHub, Vercel, Stripe, etc.) are publicly accessible

### Alternative Via API:

```bash
# Disable SSO Protection via API
curl -X PATCH \
  https://api.vercel.com/v1/projects/docs \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"ssoProtection": null}'
```

### Alternative Solutions (If needed):

#### Option 2: Add Deployment Protection Exception

- Go to Vercel Dashboard → Project Settings → Deployment Protection
- Add domain exception for the docs URL

#### Option 3: Use Custom Domain

- Add a custom domain like docs.yoursite.com
- Custom domains can bypass some protection settings

## After Making the Change:

1. The change applies **immediately** - no redeploy needed
2. Your docs will be accessible at: `https://docs-livingtree.vercel.app`
3. Consider setting up a custom domain like `docs.yoursite.com` for better branding

## Prevention for Future Deployments

Add to your `vercel.json` to ensure proper Mintlify configuration:

```json
{
  "buildCommand": null,
  "outputDirectory": ".",
  "installCommand": "pnpm install",
  "framework": null
}
```

## Debug Summary

### Issue

The docs app deploys successfully to Vercel but returns a 401 Unauthorized error with a Vercel SSO authentication page, making it inaccessible to users.

### Root Cause

**Vercel Deployment Protection is enabled** on the project. This is configured at the project level with Standard Protection or SSO protection enabled.

### Evidence Found During Debug:

1. ✅ **Build succeeds** - Deployment completes without build errors
2. ❌ **Runtime fails** - Returns HTTP 401 with Vercel authentication page
3. 🔍 **SSO page content** - Shows "Vercel Authentication" with automatic redirect to SSO API
4. **Mintlify builds correctly** - The issue is not with the build process but with access control

### Verification

Steps confirmed accurate based on July 2025 Vercel documentation using Tavily and Context7 research.

## Status

**Ready for implementation** - Dashboard access required to complete the fix.
