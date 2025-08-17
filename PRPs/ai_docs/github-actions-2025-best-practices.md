# GitHub Actions Best Practices 2025

## Authentication and Security

### Workload Identity Federation (Recommended)

Replace long-lived credentials with short-lived tokens using OIDC:

```yaml
permissions:
  id-token: write
  contents: read

steps:
  - uses: google-github-actions/auth@v2
    with:
      workload_identity_provider: ${{ secrets.WIF_PROVIDER }}
      service_account: ${{ secrets.WIF_SERVICE_ACCOUNT }}
```

### Secret Management Best Practices

1. **Use GitHub Environments** for staging/production separation
2. **Rotate secrets regularly** (30-90 days)
3. **Pin actions to commit SHAs** for security
4. **Implement least privilege** permissions

## Docker Build Optimization

### Multi-stage Builds with Caching

```yaml
- name: Build and push Docker image
  uses: docker/build-push-action@v5
  with:
    context: .
    push: true
    tags: ${{ steps.meta.outputs.tags }}
    cache-from: type=gha
    cache-to: type=gha,mode=max
    platforms: linux/amd64
```

### Registry Cache for Shared Environments

```yaml
cache-from: |
  type=registry,ref=user/app:buildcache
  type=gha
cache-to: |
  type=registry,ref=user/app:buildcache,mode=max
  type=gha,mode=max
```

## Workflow Reusability

### Reusable Workflows

```yaml
# .github/workflows/reusable-deploy.yml
on:
  workflow_call:
    inputs:
      environment:
        required: true
        type: string
    secrets:
      DEPLOY_TOKEN:
        required: true

# Calling workflow
jobs:
  deploy-staging:
    uses: ./.github/workflows/reusable-deploy.yml
    with:
      environment: staging
    secrets:
      DEPLOY_TOKEN: ${{ secrets.STAGING_DEPLOY_TOKEN }}
```

## Error Handling and Notifications

### Structured Error Handling

```yaml
- name: Deploy with retry
  uses: nick-fields/retry@v2
  with:
    timeout_minutes: 10
    max_attempts: 3
    retry_on: error
    command: |
      gcloud run deploy $SERVICE_NAME

- name: Notify on failure
  if: failure()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: "Deployment failed for ${{ github.ref }}"
```

## Concurrency Control

Prevent duplicate runs and manage resource usage:

```yaml
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true
```

## Matrix Strategies

Run tests in parallel across multiple versions:

```yaml
strategy:
  matrix:
    node: [18, 20]
    os: [ubuntu-latest, windows-latest]
  fail-fast: false
```

## Security Scanning

### Dependency Scanning

```yaml
- name: Run security scan
  uses: aquasecurity/trivy-action@master
  with:
    scan-type: "fs"
    scan-ref: "."
    severity: "CRITICAL,HIGH"
```

## Performance Tips

1. **Use workflow_dispatch** for manual triggers
2. **Implement job dependencies** wisely
3. **Cache dependencies** aggressively
4. **Use artifacts** for sharing between jobs
5. **Parallelize** where possible

## References

- [Official GitHub Actions Documentation](https://docs.github.com/actions)
- [Security Hardening Guide](https://docs.github.com/actions/security-guides)
- [Reusable Workflows](https://docs.github.com/en/actions/how-tos/sharing-automations/reusing-workflows)
- [OIDC Token Authentication](https://docs.github.com/actions/deployment/security-hardening-your-deployments/about-security-hardening-with-openid-connect)
