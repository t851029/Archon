name: "Enhanced DevOps Agent - Infrastructure Intelligence & Incident Response"
description: |

## Purpose

Implement an intelligent DevOps agent that goes beyond basic script execution to provide proactive infrastructure management, incident response, deployment orchestration, and troubleshooting capabilities for the Living Tree project's complex multi-environment architecture.

## Core Principles

1. **Proactive Monitoring**: Detect and resolve issues before they impact users
2. **Intelligent Troubleshooting**: Root cause analysis with actionable remediation
3. **Deployment Safety**: Automated validation, rollback, and recovery procedures
4. **Cost Optimization**: Monitor and optimize infrastructure spending
5. **Knowledge Preservation**: Learn from incidents and build runbooks

---

## Goal

**Feature Goal**: Create an Enhanced DevOps Agent that provides intelligent infrastructure management, automated incident response, advanced deployment strategies, and deep troubleshooting capabilities beyond the basic devops-engineer agent proposed in the SDLC architecture.

**Deliverable**: A sophisticated DevOps agent (`~/.claude/agents/enhanced-devops-agent.md`) that integrates with existing GitHub Actions, Cloud Run, Docker, and monitoring systems to provide autonomous infrastructure management and incident response.

**Success Definition**: 
- 80% reduction in mean time to resolution (MTTR) for infrastructure issues
- Zero-downtime deployments with automatic rollback on failure
- Proactive detection of 90% of common infrastructure problems
- Automated resolution of 60% of incidents without human intervention

## Why

- **Current Gap**: The proposed basic devops-engineer agent only handles script execution
- **Complex Infrastructure**: Multiple environments (local/staging/production) with different configurations
- **Incident Frequency**: Manual troubleshooting of JWT errors, port conflicts, deployment failures
- **Cost Management**: Need for proactive cost optimization in Cloud Run and GCP services
- **Knowledge Loss**: Incident resolutions not systematically captured for future reference
- **Deployment Risk**: Manual rollbacks and health checks prone to human error

## What

An intelligent DevOps agent with capabilities spanning:

### Infrastructure Management
- Cloud Run service orchestration
- Google Secret Manager operations
- Docker container lifecycle management
- Port conflict resolution
- Environment configuration validation

### Deployment Orchestration
- Canary deployment management
- Blue-green deployment coordination
- Feature flag integration
- Automated rollback triggers
- Health check validation

### Incident Response
- Root cause analysis for failures
- Automated remediation workflows
- Incident priority classification
- Escalation management
- Post-mortem generation

### Monitoring & Observability
- Performance degradation detection
- Cost anomaly identification
- Log aggregation and analysis
- Metric correlation
- Alert fatigue reduction

### Success Criteria

- [ ] Agent can automatically diagnose and fix JWT token format errors
- [ ] Agent detects and resolves port conflicts without manual intervention
- [ ] Agent performs intelligent rollbacks based on health check failures
- [ ] Agent provides cost optimization recommendations with impact analysis
- [ ] Agent generates actionable runbooks from resolved incidents
- [ ] Agent coordinates cross-environment deployments safely
- [ ] Agent integrates with existing GitHub Actions workflows
- [ ] Agent handles Cloud Run container debugging autonomously

## All Needed Context

### Documentation & References

```yaml
# Infrastructure Documentation
- file: DEPLOYMENT.md
  why: Complete deployment procedures, secret management, rollback processes
  critical: Environment-specific configurations and troubleshooting guides

- file: TROUBLESHOOTING.md
  why: Known issues, solutions, and debugging procedures
  critical: JWT errors, port conflicts, Docker issues patterns

- file: CLAUDE.md
  section: "Google Secret Manager"
  why: Secret management operations and permissions
  critical: Service account requirements and JWT format validation

# GitHub Actions Workflows
- file: .github/workflows/deployment-gate.yml
  why: Deployment validation and gating logic
  critical: Health check patterns and validation criteria

- file: .github/workflows/auto-rollback.yml
  why: Rollback orchestration patterns
  critical: Service-specific rollback procedures

- file: .github/workflows/deployment-monitor.yml
  why: Monitoring frequency and health check patterns
  critical: Environment-specific monitoring configurations

- file: .github/workflows/deploy-backend-staging.yml
  why: Cloud Run deployment process
  critical: GCP project configuration and service accounts

# Scripts and Tools
- file: scripts/deployment-health-check.sh
  why: Health check implementation details
  critical: Check types and expected responses

- file: scripts/validate-deployment-env.sh
  why: Environment validation logic
  critical: Required variables and validation criteria

- file: scripts/docker-maintenance.sh
  why: Docker cleanup and maintenance procedures
  critical: Cleanup thresholds and safety checks

# External Documentation
- url: https://cloud.google.com/run/docs/troubleshooting
  why: Cloud Run debugging procedures
  section: Container startup failures

- url: https://cloud.google.com/secret-manager/docs/troubleshooting
  why: Secret Manager permission issues
  section: Access denied errors

- url: https://docs.github.com/en/actions/deployment/targeting-different-environments
  why: GitHub Actions deployment strategies
  section: Environment protection rules
```

### Current Infrastructure Tree

```bash
living-tree/
├── .github/
│   ├── workflows/
│   │   ├── deployment-gate.yml         # Deployment validation
│   │   ├── auto-rollback.yml          # Rollback automation
│   │   ├── deployment-monitor.yml      # Health monitoring
│   │   ├── deploy-backend-staging.yml  # Backend deployment
│   │   └── e2e-tests-clerk.yml        # E2E test automation
│   └── actions/                        # Reusable actions
├── scripts/
│   ├── deployment-health-check.sh      # Health validation
│   ├── validate-deployment-env.sh      # Environment checks
│   ├── docker-maintenance.sh           # Docker cleanup
│   └── env-sync.sh                     # Secret synchronization
├── api/
│   ├── Dockerfile                      # Production container
│   └── Dockerfile.dev                  # Development container
└── docker-compose.yml                  # Local orchestration
```

### Desired Agent Architecture

```bash
~/.claude/agents/
├── enhanced-devops-agent.md            # NEW: Intelligent DevOps agent
├── devops-engineer.md                  # Basic DevOps (from SDLC)
└── [other agents...]

# Agent will interface with:
# - GitHub Actions API for workflow management
# - GCP APIs for Cloud Run and Secret Manager
# - Docker API for container management
# - Monitoring systems for metrics and alerts
```

### Known Infrastructure Gotchas

```bash
# CRITICAL: JWT Token Format Validation
# Tokens MUST start with "eyJ" and have exactly 3 parts separated by dots
# Common error: Extra characters like "yeyJ..." or "Bearer eyJ..."
# Agent must validate and auto-fix malformed tokens

# CRITICAL: Clerk Instance Matching
# Frontend and backend MUST use same instance (TEST or LIVE)
# Staging: pk_test_* and sk_test_*
# Production: pk_live_* and sk_live_*
# Agent must detect and alert on mismatches

# CRITICAL: Port Conflicts in WSL
# WSL can't detect Windows-bound ports with traditional Linux tools
# Must use socket testing or PowerShell integration
# Ports: 3000 (frontend), 8000 (backend), 54321/54323 (Supabase)

# CRITICAL: Cloud Run Container Failures
# Common causes: Missing env vars, secret permissions, malformed JWTs
# Agent must check: Service account permissions, secret accessor roles
# Force update pattern: gcloud run services update --force-update

# CRITICAL: Docker Volume Accumulation
# PostgreSQL version mismatches cause container failures
# Agent must detect and clean: docker volume rm supabase_db_living-tree
# Weekly cleanup needed to prevent disk space issues

# CRITICAL: CORS with Preview URLs
# Preview deployments have random URLs not in backend allowlist
# Agent must detect and recommend using staging URL instead
# Pattern: living-tree-{RANDOM-HASH}-livingtree.vercel.app
```

## Implementation Blueprint

### Agent Core Structure

```yaml
---
name: enhanced-devops-agent
description: Use this agent for infrastructure management, deployment orchestration, incident response, and DevOps troubleshooting. Automatically triggers on infrastructure events and failures.
model: claude-3-5-sonnet-20241022  # Higher intelligence for complex analysis
tools: 
  - Read
  - Write
  - Edit
  - Bash(gcloud*)
  - Bash(docker*)
  - Bash(git*)
  - Bash(curl*)
  - Grep
  - Glob
  - Task
  - TodoWrite
  - WebFetch
  - mcp__sequential-thinking__sequentialthinking
---
```

### Core Capabilities Implementation

```python
# Capability 1: Incident Response System
class IncidentResponder:
    def analyze_failure(self, error_context):
        # PATTERN: Use sequential thinking for root cause analysis
        # 1. Parse error logs and stack traces
        # 2. Match against known patterns from TROUBLESHOOTING.md
        # 3. Correlate with recent changes (git log)
        # 4. Check related services health
        # 5. Generate remediation plan
        
    def auto_remediate(self, incident_type):
        # PATTERN: Progressive remediation strategies
        # Level 1: Quick fixes (restart, clear cache)
        # Level 2: Configuration fixes (env vars, secrets)
        # Level 3: Rollback to last known good state
        # Level 4: Escalate to human with context

# Capability 2: Deployment Orchestration
class DeploymentOrchestrator:
    def canary_deployment(self, service, version):
        # PATTERN: Safe progressive rollout
        # 1. Deploy to 10% traffic
        # 2. Monitor error rates for 5 minutes
        # 3. If healthy, increase to 50%
        # 4. Monitor for 10 minutes
        # 5. If healthy, complete rollout
        # 6. If unhealthy at any stage, auto-rollback
        
    def blue_green_switch(self, environment):
        # PATTERN: Zero-downtime deployment
        # 1. Deploy to inactive color
        # 2. Run smoke tests
        # 3. Switch traffic atomically
        # 4. Keep old version warm for quick rollback

# Capability 3: Infrastructure Optimization
class InfrastructureOptimizer:
    def analyze_costs(self):
        # PATTERN: Cost optimization with impact analysis
        # 1. Query GCP billing API
        # 2. Identify cost anomalies
        # 3. Analyze resource utilization
        # 4. Generate optimization recommendations
        # 5. Calculate potential savings and risks
        
    def optimize_containers(self):
        # PATTERN: Container resource optimization
        # 1. Analyze CPU/memory usage patterns
        # 2. Identify over-provisioned resources
        # 3. Recommend right-sizing
        # 4. Test changes in staging first
```

### Task Execution Workflow

```yaml
Task 1: Infrastructure Health Assessment
EXECUTE health_check.sh:
  - CHECK all environments (local, staging, production)
  - VALIDATE JWT token formats
  - VERIFY service connectivity
  - ANALYZE recent error logs
  - GENERATE health report

Task 2: Incident Detection and Response
MONITOR error patterns:
  - WATCH GitHub Actions failures
  - SCAN Cloud Run logs for errors
  - DETECT anomalies in metrics
  - TRIGGER auto-remediation for known issues
  - ESCALATE unknown issues with context

Task 3: Deployment Safety Validation
BEFORE deployment:
  - VALIDATE environment configuration
  - CHECK dependent service health
  - VERIFY rollback capability
  - CONFIRM monitoring is active
  - EXECUTE pre-deployment tests

Task 4: Post-Deployment Verification
AFTER deployment:
  - RUN smoke tests
  - MONITOR error rates
  - CHECK performance metrics
  - VALIDATE user journeys
  - TRIGGER rollback if thresholds exceeded

Task 5: Continuous Optimization
PERIODIC tasks:
  - ANALYZE cost trends weekly
  - CLEAN Docker resources daily
  - UPDATE runbooks from incidents
  - OPTIMIZE resource allocation monthly
  - GENERATE executive reports
```

### Integration Points

```yaml
GITHUB_ACTIONS:
  - hook: workflow_run events
  - pattern: "Trigger agent on workflow failure"
  - integration: "Use GitHub API to rerun or modify workflows"

CLOUD_RUN:
  - monitor: Service health and metrics
  - pattern: "Auto-scale based on traffic patterns"
  - integration: "gcloud run services update for configuration changes"

SECRET_MANAGER:
  - validate: JWT token formats
  - pattern: "Auto-fix malformed tokens"
  - integration: "gcloud secrets versions add for updates"

DOCKER:
  - cleanup: Automated maintenance
  - pattern: "Progressive cleanup based on disk usage"
  - integration: "docker system prune with safety checks"

MONITORING:
  - sources: Cloud Logging, GitHub Actions, Custom metrics
  - pattern: "Correlate across multiple sources"
  - integration: "Alert aggregation and deduplication"
```

## Validation Loop

### Level 1: Agent Configuration Validation

```bash
# Validate agent YAML structure
head -15 ~/.claude/agents/enhanced-devops-agent.md

# Expected: Valid YAML with all required fields
# Tools must include gcloud, docker, and Task for orchestration
```

### Level 2: Capability Testing

```bash
# Test JWT validation capability
echo "yeyJhbGciOiJIUzI1NiIs..." | ./test-jwt-validation.sh
# Expected: "Invalid JWT format detected, attempting auto-fix..."

# Test port conflict resolution
./test-port-conflicts.sh
# Expected: "Port 3000 in use, finding alternative... Using port 3001"

# Test health check execution
./scripts/deployment-health-check.sh staging --json
# Expected: JSON output with all checks passing
```

### Level 3: Incident Response Testing

```bash
# Simulate container failure
docker stop living-tree-backend-staging
# Expected: Agent detects within 60 seconds and attempts restart

# Simulate JWT error
export SUPABASE_SERVICE_ROLE_KEY="invalid_token"
# Expected: Agent detects, diagnoses, and provides fix instructions

# Simulate deployment failure
git push staging broken-code
# Expected: Agent triggers rollback after health checks fail
```

### Level 4: End-to-End Orchestration

```bash
# Test complete deployment pipeline with agent
# 1. Agent validates pre-deployment state
# 2. Agent coordinates canary deployment
# 3. Agent monitors health metrics
# 4. Agent completes or rolls back based on results
# Expected: Safe deployment with automatic rollback on failure
```

## Final Validation Checklist

- [ ] Agent can diagnose and fix JWT token format errors automatically
- [ ] Agent resolves port conflicts without manual intervention
- [ ] Agent performs intelligent rollbacks based on health check failures
- [ ] Agent provides cost optimization recommendations with ROI analysis
- [ ] Agent generates runbooks from resolved incidents
- [ ] Agent coordinates multi-environment deployments safely
- [ ] Agent integrates with GitHub Actions workflows seamlessly
- [ ] Agent handles Cloud Run debugging with root cause analysis
- [ ] Agent reduces MTTR by at least 50% in testing
- [ ] Agent prevents at least 3 types of production incidents
- [ ] Agent documentation includes clear escalation procedures
- [ ] Agent testing covers all critical failure scenarios

---

## Anti-Patterns to Avoid

- ❌ Don't create new monitoring systems - integrate with existing
- ❌ Don't bypass safety checks for speed - reliability first
- ❌ Don't auto-fix without understanding root cause
- ❌ Don't ignore warning signs - investigate anomalies
- ❌ Don't skip staging validation - always test there first
- ❌ Don't accumulate technical debt - fix issues properly
- ❌ Don't lose incident knowledge - always update runbooks
- ❌ Don't over-automate - keep human oversight for critical decisions