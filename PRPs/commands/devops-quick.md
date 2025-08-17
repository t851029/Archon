# DevOps Quick Commands

## Health Checks
/devops:health staging              # Check staging health
/devops:health production           # Check production health

## Environment Validation
/devops:validate-env staging        # Validate staging env vars
/devops:sync-env staging            # Sync secrets from GCP

## Troubleshooting
/devops:debug jwt                   # Debug JWT errors
/devops:debug ports                 # Debug port conflicts
/devops:debug cors                  # Debug CORS issues

## Docker Management
/devops:docker clean                # Clean Docker resources
/devops:docker logs                 # View Docker logs