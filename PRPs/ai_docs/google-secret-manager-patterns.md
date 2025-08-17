# Google Secret Manager Integration Patterns

## Naming Conventions

### Environment-Based Naming

```
Pattern: {environment}-{service}-{component}-{type}

Examples:
- staging-clerk-secret-key-test
- production-supabase-service-role-key
- staging-openai-api-key
- production-gmail-client-secret
```

### Why This Matters

- **Clarity**: Instantly know which environment a secret belongs to
- **Security**: Reduces risk of using wrong environment's secrets
- **Automation**: Easy to script operations based on prefixes
- **Cost**: Can track costs per environment

## GitHub Actions Integration

### Setup Workload Identity Federation

```bash
# Create workload identity pool
gcloud iam workload-identity-pools create github \
  --location="global" \
  --display-name="GitHub Actions Pool" \
  --project="${PROJECT_ID}"

# Create provider
gcloud iam workload-identity-pools providers create-oidc github \
  --location="global" \
  --workload-identity-pool="github" \
  --display-name="GitHub Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.repository=assertion.repository" \
  --issuer-uri="https://token.actions.githubusercontent.com" \
  --project="${PROJECT_ID}"

# Grant access to specific repository
gcloud projects add-iam-policy-binding ${PROJECT_ID} \
  --member="principal://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github/subject/repo:living-tree-app/living-tree:ref:refs/heads/staging" \
  --role="roles/secretmanager.secretAccessor"
```

### Use in GitHub Actions

```yaml
- id: "auth"
  uses: "google-github-actions/auth@v2"
  with:
    workload_identity_provider: "projects/123456789/locations/global/workloadIdentityPools/github/providers/github"
    service_account: "github-actions@project.iam.gserviceaccount.com"

- id: "secrets"
  uses: "google-github-actions/get-secretmanager-secrets@v2"
  with:
    secrets: |-
      STAGING_API_KEY:staging-api-key
      STAGING_DB_PASS:staging-database-password
```

## Access Control Best Practices

### Principle of Least Privilege

```bash
# Grant access to specific secret only
gcloud secrets add-iam-policy-binding staging-api-key \
  --member="serviceAccount:backend@project.iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor"

# Never grant project-wide access
# BAD: --role="roles/secretmanager.admin" at project level
```

### IAM Conditions for Extra Security

```json
{
  "bindings": [
    {
      "role": "roles/secretmanager.secretAccessor",
      "members": ["serviceAccount:backend@project.iam.gserviceaccount.com"],
      "condition": {
        "title": "Only from Cloud Run",
        "description": "Only allow access from Cloud Run services",
        "expression": "request.auth.claims.run_service_account != null"
      }
    }
  ]
}
```

## Secret Rotation

### Automated Rotation Architecture

```
Cloud Scheduler → Pub/Sub → Cloud Function → Update Secret → Notify Services
```

### Implementation Example

```python
# Cloud Function for rotation
import functions_framework
from google.cloud import secretmanager
import secrets
import base64

@functions_framework.cloud_event
def rotate_api_key(cloud_event):
    client = secretmanager.SecretManagerServiceClient()

    # Generate new API key
    new_key = f"sk-{secrets.token_urlsafe(32)}"

    # Add new version
    parent = f"projects/{PROJECT_ID}/secrets/staging-api-key"
    response = client.add_secret_version(
        parent=parent,
        payload={"data": new_key.encode("UTF-8")}
    )

    # Disable old versions
    versions = client.list_secret_versions(parent=parent)
    for version in versions:
        if version.state == secretmanager.SecretVersion.State.ENABLED:
            client.disable_secret_version(name=version.name)

    # Enable new version
    client.enable_secret_version(name=response.name)

    # Notify services to reload
    # ... publish to Pub/Sub for service notification
```

## Cloud Run Integration

### Environment Variables (Static)

```yaml
# Good for secrets that don't change often
env:
  - name: API_KEY
    valueFrom:
      secretKeyRef:
        name: staging-api-key
        version: "latest" # Pin to specific version in production
```

### Volume Mounts (Dynamic)

```yaml
# Good for secrets that need rotation without restart
volumes:
  - name: secrets
    secret:
      secretName: staging-config
      items:
        - key: latest
          path: config.json

containers:
  - volumeMounts:
      - name: secrets
        mountPath: /secrets
        readOnly: true
```

## Cost Optimization

### Free Tier Maximization

- 6 active secret versions free
- 10,000 access operations free
- 3 rotation notifications free

### Cost Reduction Strategies

1. **Delete old versions**: Only active versions are charged

   ```bash
   gcloud secrets versions destroy 1 --secret="old-secret"
   ```

2. **Use caching**: Reduce access operations

   ```python
   # Cache secrets in memory
   _secret_cache = {}

   def get_secret(name: str) -> str:
       if name not in _secret_cache:
           _secret_cache[name] = fetch_from_secret_manager(name)
       return _secret_cache[name]
   ```

3. **Regional secrets**: Better performance and quotas
   ```bash
   gcloud secrets create regional-secret \
     --replication-policy="user-managed" \
     --locations="us-central1"
   ```

## Multi-Environment Management

### Project Structure

```
living-tree-dev/
  ├── dev-*                    # Development secrets

living-tree-staging/
  ├── staging-*                # Staging secrets

living-tree-production/
  ├── production-*             # Production secrets
  └── backup-*                 # Backup secrets
```

### Cross-Project Access

```bash
# Grant staging Cloud Run access to staging secrets
gcloud projects add-iam-policy-binding living-tree-staging \
  --member="serviceAccount:backend@living-tree-staging.iam.gserviceaccount.com" \
  --role="roles/secretmanager.secretAccessor" \
  --condition="expression=resource.name.startsWith('projects/living-tree-staging/secrets/staging-')"
```

## Security Best Practices

1. **Audit Logging**: Enable Cloud Audit Logs for all secret access
2. **VPC Service Controls**: Restrict secret access to specific networks
3. **Binary Authorization**: Only allow verified containers to access secrets
4. **Secret Scanning**: Regularly scan code for exposed secrets
5. **Encryption**: Use customer-managed encryption keys (CMEK) for sensitive data

## Monitoring and Alerts

### Key Metrics to Monitor

- Secret access frequency
- Failed access attempts
- Secret age and rotation status
- Cost per secret

### Example Alert Policy

```yaml
displayName: "High Secret Access Rate"
conditions:
  - displayName: "Secret access spike"
    conditionThreshold:
      filter: 'resource.type="secretmanager.Secret"'
      comparison: COMPARISON_GT
      thresholdValue: 1000
      duration: 300s
      aggregations:
        - alignmentPeriod: 60s
          perSeriesAligner: ALIGN_RATE
```

## References

- [Secret Manager Best Practices](https://cloud.google.com/secret-manager/docs/best-practices)
- [Workload Identity Federation](https://cloud.google.com/iam/docs/workload-identity-federation)
- [Secret Manager Pricing](https://cloud.google.com/secret-manager/pricing)
- [Access Control Guide](https://cloud.google.com/secret-manager/docs/access-control)
