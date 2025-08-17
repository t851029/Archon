# Simple DevOps Helper Agent PRP

## Goal

**Feature Goal**: Create a practical DevOps helper agent that leverages existing Living Tree scripts and workflows to assist with deployment validation, troubleshooting, and environment management without adding complexity.

**Deliverable**: 
- A lightweight DevOps agent configuration file at `~/.claude/agents/devops-helper.md`
- Integration with existing scripts in `scripts/` directory
- Simple troubleshooting guides for common issues

**Success Definition**:
- [ ] Agent can run all existing validation scripts
- [ ] Provides fixes for top 5 common issues (JWT errors, port conflicts, CORS, env vars, Docker)
- [ ] Reduces debugging time by 50% through automated checks
- [ ] Zero new infrastructure or complex tooling added

## User Persona

**Primary User**: Living Tree developers who need quick help with deployments and troubleshooting
**Pain Points**: 
- Running multiple validation scripts manually
- Remembering which script does what
- Debugging common issues repeatedly
- Not knowing deployment status

## Why

### Problems This Solves
- **Script Discovery**: Developers don't know all available helper scripts
- **Common Issues**: Same problems (JWT errors, port conflicts) happen repeatedly
- **Manual Validation**: Running health checks requires multiple commands
- **Knowledge Gap**: New team members don't know troubleshooting patterns

### What This Doesn't Solve
- Complex orchestration (Vercel/Cloud Run handle this)
- Advanced monitoring (use existing tools)
- Infrastructure provisioning (not needed)

## What

### User-Visible Behavior
```bash
# Simple commands that work
claude --agent devops-helper "check staging deployment"
claude --agent devops-helper "why is my JWT token failing?"
claude --agent devops-helper "validate environment for production"
claude --agent devops-helper "check if ports are available"
```

### Core Capabilities

1. **Run Existing Scripts**
   - `deployment-health-check.sh` - Check deployment health
   - `validate-deployment-env.sh` - Validate environment variables
   - `dev-with-ports.sh` - Find available ports
   - `docker-maintenance.sh` - Clean up Docker
   - `sync-env-enhanced.ts` - Sync environment variables

2. **Troubleshoot Common Issues**
   - JWT token format errors
   - Port conflicts (3000, 8000, 54321)
   - CORS configuration problems
   - Missing environment variables
   - Docker container issues

3. **Check Deployment Status**
   - GitHub Actions workflow status
   - Vercel deployment status
   - Cloud Run service health
   - Database migration status

## All Needed Context

### Existing Scripts to Use
```yaml
scripts:
  - file: scripts/deployment-health-check.sh
    purpose: Validates deployment health for all environments
    usage: ./scripts/deployment-health-check.sh [staging|production]
    
  - file: scripts/validate-deployment-env.sh
    purpose: Checks required environment variables
    usage: ./scripts/validate-deployment-env.sh staging
    
  - file: scripts/dev-with-ports.sh
    purpose: Finds available ports for development
    usage: ./scripts/dev-with-ports.sh
    
  - file: scripts/docker-maintenance.sh
    purpose: Cleans up Docker images and containers
    usage: ./scripts/docker-maintenance.sh
    
  - file: scripts/sync-env-enhanced.ts
    purpose: Syncs secrets from Google Secret Manager
    usage: tsx scripts/sync-env-enhanced.ts staging

common_issues:
  jwt_errors:
    symptom: "JWSError (JSONDecodeError 'Not valid base64url')"
    fix: Check token starts with 'eyJ' and has 3 parts separated by dots
    
  port_conflicts:
    symptom: "Port 3000 already in use"
    fix: Run 'lsof -i :3000' to find process, then 'kill -9 <PID>'
    
  cors_errors:
    symptom: "Disallowed CORS origin"
    fix: Use staging URL, not preview URLs for testing
    
  missing_env_vars:
    symptom: "Invalid environment variables"
    fix: Run 'pnpm env:sync:staging' to sync from GCP
    
  docker_issues:
    symptom: "Container not starting"
    fix: Check 'docker-compose logs api' for errors
```

## Implementation Tasks

### Task 1: Create Agent Configuration File
```bash
# Location: ~/.claude/agents/devops-helper.md
cat > ~/.claude/agents/devops-helper.md << 'EOF'
---
name: devops-helper
description: Simple DevOps helper for Living Tree project
model: claude-3-haiku-20240307
tools: Bash, Read, Grep
---

You are a DevOps helper for the Living Tree project. You assist with:

1. Running validation scripts from the scripts/ directory
2. Troubleshooting common issues (JWT, ports, CORS, env vars, Docker)
3. Checking deployment status

Available scripts:
- deployment-health-check.sh - Check deployment health
- validate-deployment-env.sh - Validate environment
- dev-with-ports.sh - Find available ports
- docker-maintenance.sh - Clean Docker
- sync-env-enhanced.ts - Sync secrets

Common fixes:
- JWT errors: Token must start with 'eyJ' and have 3 parts
- Port conflicts: Use lsof -i :PORT to find process
- CORS: Use staging.livingtree.io not preview URLs
- Env vars: Run pnpm env:sync:staging
- Docker: Check docker-compose logs

Be concise and practical. Run scripts when asked. Provide specific fixes.
EOF
```

### Task 2: Test Basic Operations
```bash
# Test script execution
claude --agent devops-helper "check staging deployment health"
# Expected: Runs ./scripts/deployment-health-check.sh staging

# Test troubleshooting
claude --agent devops-helper "my JWT token is failing"
# Expected: Explains token format requirements

# Test port checking
claude --agent devops-helper "find available ports for development"
# Expected: Runs ./scripts/dev-with-ports.sh
```

### Task 3: Add Quick Reference Commands
```bash
# Create quick reference in project
cat > PRPs/commands/devops-quick.md << 'EOF'
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
EOF
```

### Task 4: Create Simple Troubleshooting Functions
```bash
# Add to agent configuration
cat >> ~/.claude/agents/devops-helper.md << 'EOF'

Quick diagnostic commands:
1. Check JWT: echo $SUPABASE_SERVICE_ROLE_KEY | grep -E '^eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$'
2. Check ports: lsof -i :3000 && lsof -i :8000 && lsof -i :54321
3. Check Docker: docker-compose ps
4. Check env: ./scripts/validate-deployment-env.sh local
5. Check GitHub Actions: gh run list --limit 5
EOF
```

## Validation Loop

### Level 1: Configuration Validation (Immediate)
```bash
# Verify agent file exists
ls -la ~/.claude/agents/devops-helper.md

# Test agent loads
claude --agent devops-helper --help
```

### Level 2: Script Execution (5 minutes)
```bash
# Test each script execution
claude --agent devops-helper "validate staging environment"
# Should run: ./scripts/validate-deployment-env.sh staging

claude --agent devops-helper "check deployment health for staging"
# Should run: ./scripts/deployment-health-check.sh staging
```

### Level 3: Troubleshooting (10 minutes)
```bash
# Test common issue resolution
claude --agent devops-helper "JWT token error: Not valid base64url"
# Should explain: Token must start with 'eyJ' and have 3 parts

claude --agent devops-helper "port 3000 is already in use"
# Should suggest: lsof -i :3000 and kill process
```

### Level 4: End-to-End Workflow (15 minutes)
```bash
# Complete deployment validation workflow
claude --agent devops-helper "validate staging deployment end to end"
# Should:
# 1. Run health check
# 2. Validate environment
# 3. Check GitHub Actions status
# 4. Report any issues found
```

## Final Validation Checklist

### Pre-Implementation
- [ ] Verify all referenced scripts exist in scripts/ directory
- [ ] Confirm no new infrastructure dependencies needed
- [ ] Document current debugging time for comparison

### Post-Implementation
- [ ] Agent configuration file created at ~/.claude/agents/devops-helper.md
- [ ] Agent successfully runs all 5 key scripts
- [ ] Troubleshooting guidance provided for all 5 common issues
- [ ] No new tools or infrastructure added
- [ ] Debugging time reduced (measure actual time)

### Success Metrics
- [ ] All existing scripts executable through agent
- [ ] Common issues resolved in < 2 minutes
- [ ] Zero new dependencies or tools required
- [ ] Team adoption within first week

## Risk Mitigation

### What This Agent Won't Do
- Won't modify infrastructure
- Won't create new workflows
- Won't deploy code
- Won't manage secrets directly

### Rollback Plan
```bash
# If agent causes issues, simply remove it
rm ~/.claude/agents/devops-helper.md
```

### Known Limitations
- Only works with existing scripts
- No complex orchestration
- No real-time monitoring
- Manual intervention still needed for deployments

## Appendix: Common Commands Reference

### JWT Validation
```bash
# Check JWT format
echo $SUPABASE_SERVICE_ROLE_KEY | head -c 20
# Should show: eyJ... (starts with eyJ)

# Count JWT parts
echo $SUPABASE_SERVICE_ROLE_KEY | tr '.' '\n' | wc -l
# Should show: 3
```

### Port Management
```bash
# Find process on port
lsof -i :3000

# Kill process on port
kill -9 $(lsof -t -i:3000)

# Find available ports
./scripts/dev-with-ports.sh
```

### Docker Cleanup
```bash
# View logs
docker-compose logs api

# Clean resources
./scripts/docker-maintenance.sh

# Restart services
docker-compose restart
```

### Environment Sync
```bash
# Sync staging secrets
pnpm env:sync:staging

# Validate environment
./scripts/validate-deployment-env.sh staging
```

---

**Implementation Complexity**: Low (uses existing infrastructure)
**Time to Implement**: 1-2 hours
**Maintenance Burden**: Minimal (leverages existing scripts)
**Value Delivered**: High (reduces repetitive debugging tasks)