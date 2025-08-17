# Deploy to Living Tree Staging

Deploy changes to the Living Tree staging environment with proper validation and checks.

## Pre-Deployment Checklist

Before deploying to staging, ensure:

- [ ] All changes committed and pushed
- [ ] Type checking passes (`pnpm type-check`)
- [ ] Tests pass (`pnpm test` and `poetry run pytest`)
- [ ] Docker build succeeds (if backend changed)
- [ ] Environment variables documented
- [ ] Database migrations ready

## Staging Deployment Process

### 1. Validate Current Branch

```bash
# Check you're on the right branch
git branch --show-current
git status

# Ensure up to date with remote
git pull origin $(git branch --show-current)

# Check what will be deployed
git diff origin/staging..HEAD --stat
```

### 2. Run Full Validation Suite

```bash
# Frontend validation
pnpm type-check && pnpm lint && pnpm test
pnpm build  # Ensure production build works

# Backend validation
cd api
poetry run mypy api/ --strict
poetry run flake8 api/
poetry run black api/ --check
poetry run pytest

# Docker validation (CRITICAL for backend)
cd ..
docker build -f api/Dockerfile -t living-tree-backend-test .
```

### 3. Check Database Migrations

```bash
# If you have database changes
npx supabase link --project-ref fwdfewruzeaplmcezyne
npx supabase migration list --linked

# Compare with local
npx supabase migration list

# Push migrations if needed (BE CAREFUL)
npx supabase db push --linked
```

### 4. Create Pull Request to Staging

```bash
# Create PR
gh pr create --base staging --title "Deploy: [Feature Name]" --body "
## Summary
[Brief description of changes]

## Changes
- [List key changes]

## Testing
- [ ] Local testing complete
- [ ] Type checking passes
- [ ] Docker build tested (backend)
- [ ] Database migrations ready

## Deployment Notes
[Any special deployment considerations]
"

# Or if PR exists, push updates
git push origin $(git branch --show-current)
```

### 5. Verify Staging Deployment

After PR is merged to staging:

```bash
# Frontend auto-deploys via Vercel
# Check deployment status
vercel list --scope livingtree

# Monitor frontend deployment
open https://vercel.com/livingtree/living-tree-web

# Backend requires manual deployment
# Check Google Cloud Build
open https://console.cloud.google.com/cloud-build/builds
```

### 6. Test Staging Environment

```bash
# Test staging frontend
open https://staging.livingtree.io

# Test staging backend health
curl https://living-tree-backend-staging-eprzpin6uq-nn.a.run.app/health

# Test key features
# 1. Login with Clerk
# 2. Email triage functionality
# 3. Chat interface
# 4. Tool execution
```

### 7. Monitor Staging Logs

```bash
# Frontend logs (Vercel)
vercel logs living-tree-web --scope livingtree

# Backend logs (Google Cloud)
gcloud logging read "resource.type=cloud_run_revision AND resource.labels.service_name=living-tree-backend-staging" --limit 50 --format json

# Database logs
npx supabase logs --linked
```

## Staging Environment URLs

- **Frontend**: https://staging.livingtree.io
- **Backend**: https://living-tree-backend-staging-eprzpin6uq-nn.a.run.app
- **API Docs**: https://living-tree-backend-staging-eprzpin6uq-nn.a.run.app/docs
- **Database**: Supabase project `fwdfewruzeaplmcezyne`

## Common Staging Issues

### CORS Errors

- Use `staging.livingtree.io` NOT preview URLs
- Check backend CORS configuration in `api/core/config.py`

### Environment Variables

```bash
# Verify Vercel has all required vars
vercel env ls --environment=preview

# Check backend secrets in Google Secret Manager
gcloud secrets list | grep staging
```

### Database Connection

```bash
# Verify staging database accessible
npx supabase link --project-ref fwdfewruzeaplmcezyne
npx supabase db test --linked
```

### Docker Build Failures

- Check Poetry dependencies
- Ensure README.md exists
- Verify Dockerfile hasn't changed

## Rollback Procedure

If issues found in staging:

```bash
# Frontend (Vercel)
# Go to Vercel dashboard and redeploy previous version

# Backend (if needed)
# Redeploy previous Cloud Run revision
gcloud run revisions list --service=living-tree-backend-staging
gcloud run services update-traffic living-tree-backend-staging --to-revisions=PREVIOUS_REVISION_ID=100

# Database
# Rollback migrations if needed
npx supabase migration repair --linked
```

## Post-Deployment Checklist

- [ ] Frontend accessible at staging URL
- [ ] Backend health check passes
- [ ] Login flow works
- [ ] Email triage feature functional
- [ ] Chat interface responsive
- [ ] No console errors in browser
- [ ] No critical errors in logs
- [ ] Database queries working
- [ ] Performance acceptable

## Staging to Production Promotion

Once staging is verified:

```bash
# Create PR from staging to main
gh pr create --base main --head staging --title "Production Deploy: [Version]" --body "
## Staging Verification
- [ ] Tested on staging for X hours/days
- [ ] No critical issues found
- [ ] Performance metrics acceptable

## Changes Since Last Production Deploy
[List changes]

## Production Deployment Plan
1. Merge PR
2. Monitor Vercel deployment
3. Trigger backend Cloud Build
4. Run smoke tests
"
```

Remember: Staging is your safety net - thoroughly test here before production!
