# SPEC: Docker Build Validation Enhancement

> Ingest the information from this file, implement the Low-Level Tasks, and generate the code that will satisfy the High and Mid-Level Objectives.

## High-Level Objective

Implement comprehensive Docker build validation and CI/CD enhancements to prevent Docker deployment failures by catching build issues early in the development cycle, ensuring robust backend deployments across all environments.

## Mid-Level Objectives

1. **Enhanced CI/CD Pipeline**: Add Docker build validation to GitHub Actions workflow to catch build failures before deployment
2. **Pre-commit Docker Validation**: Create optional pre-commit hooks for Docker build testing
3. **Development Workflow Documentation**: Update team processes to mandate Docker testing before backend changes
4. **Monitoring and Alerting**: Add deployment health checks and failure notifications
5. **Rollback Strategy**: Implement automated rollback for failed deployments

## Implementation Notes

### Technical Requirements

- **Docker**: Multi-stage builds with proper layer caching
- **Poetry**: Handle `--no-root` vs normal installation patterns consistently
- **GitHub Actions**: Extend existing staging/production workflows
- **Shell Scripts**: Cross-platform compatibility (macOS/Linux)
- **Error Handling**: Graceful failure with clear error messages

### Dependencies and Requirements

- Existing GitHub Actions workflows (`.github/workflows/deploy-backend-staging.yml`)
- Docker engine availability in CI and local environments
- Poetry configuration in `pyproject.toml`
- Current Dockerfile structure in `api/Dockerfile`

### Coding Standards

- **YAML**: Follow existing GitHub Actions format and naming conventions
- **Shell Scripts**: Use bash with proper error handling (`set -e`, `set -o pipefail`)
- **Documentation**: Update CLAUDE.md with clear step-by-step instructions
- **Validation**: Each task must include testable validation criteria

### Architecture Considerations

- **Non-breaking**: All changes must be additive, not disruptive to existing workflow
- **Performance**: Docker build caching to minimize CI time impact
- **Security**: No secrets in logs, proper Docker build context
- **Flexibility**: Support for both local development and CI environments

## Context

### Current State

```yaml
files:
  - .github/workflows/deploy-backend-staging.yml # Existing CI/CD with Poetry validation
  - api/Dockerfile # Multi-stage Docker build (fixed with --no-root)
  - CLAUDE.md # Updated with Docker best practices
  - pyproject.toml # Poetry config with readme reference

behavior:
  - CI validates Python code with Poetry --no-root
  - Docker build only tested during actual deployment
  - Local development lacks Docker build validation
  - Documentation exists but adoption varies

issues:
  - Docker build failures caught too late in pipeline
  - Inconsistent local testing practices
  - Gap between CI Poetry testing and Docker build reality
  - No automated rollback for failed deployments
```

### Desired State

```yaml
files:
  - .github/workflows/deploy-backend-staging.yml # Enhanced with Docker build validation
  - .github/workflows/deploy-backend-production.yml # Parallel production enhancements
  - scripts/docker-validate.sh # Reusable Docker validation script
  - .githooks/pre-commit # Optional pre-commit Docker validation
  - .github/workflows/docker-health-check.yml # Post-deployment health validation

behavior:
  - Docker builds tested in CI before deployment
  - Local developers can easily validate Docker builds
  - Automated health checks post-deployment
  - Clear rollback procedures for failed deployments
  - Proactive monitoring and alerting

benefits:
  - Catch Docker issues early in development cycle
  - Reduce production deployment failures
  - Faster feedback loop for developers
  - Consistent validation across environments
  - Improved team confidence in deployments
```

## Low-Level Tasks

> Ordered from start to finish with dependency logic

### 1. Create Reusable Docker Validation Script

```yaml
action: CREATE
file: scripts/docker-validate.sh
description: Create a reusable shell script for Docker build validation
validation:
  command: "bash scripts/docker-validate.sh"
  expect: "Docker build succeeds and script exits with code 0"
```

**Task Details:**

- Create cross-platform shell script with proper error handling
- Support both local development and CI environments
- Include build caching optimization flags
- Output clear success/failure messages with timing
- Clean up test images automatically

### 2. Enhance Staging CI/CD Workflow with Docker Validation

```yaml
action: MODIFY
file: .github/workflows/deploy-backend-staging.yml
description: Add Docker build validation step to existing validate job
validation:
  command: "gh workflow run 'Deploy Backend to Staging' --ref staging"
  expect: "Workflow includes Docker build step and completes successfully"
```

**Task Details:**

- Add Docker build step to the validate job after Poetry validation
- Use Docker layer caching for performance
- Only run Docker validation when backend files change
- Fail workflow immediately if Docker build fails
- Include build time in workflow summary

### 3. Create Production CI/CD Workflow Enhancement

```yaml
action: MODIFY
file: .github/workflows/deploy-backend-production.yml.tmp
description: Rename and enhance production workflow with Docker validation
validation:
  command: "gh workflow list | grep 'Deploy Backend to Production'"
  expect: "Production workflow exists and includes Docker validation"
```

**Task Details:**

- Rename from .tmp to active .yml file
- Mirror staging workflow structure with production settings
- Add Docker build validation step
- Include additional production safety checks
- Require manual approval for production deployments

### 4. Create Optional Pre-commit Hook for Docker Validation

```yaml
action: CREATE
file: .githooks/pre-commit
description: Create optional pre-commit hook for local Docker validation
validation:
  command: "bash .githooks/pre-commit"
  expect: "Hook runs Docker validation and exits cleanly"
```

**Task Details:**

- Create executable pre-commit hook script
- Check if backend files changed in commit
- Run Docker build validation if backend changes detected
- Provide clear opt-in instructions in documentation
- Allow bypass with --no-verify flag

### 5. Add Post-deployment Health Check Workflow

```yaml
action: CREATE
file: .github/workflows/docker-health-check.yml
description: Create workflow for post-deployment health validation
validation:
  command: "gh workflow run 'Docker Health Check' --ref staging"
  expect: "Health check workflow validates deployment endpoints"
```

**Task Details:**

- Trigger after successful deployment completion
- Test backend health endpoints
- Validate Docker container startup
- Check service connectivity and response times
- Send notifications on health check failures

### 6. Implement Automated Rollback Strategy

```yaml
action: MODIFY
file: .github/workflows/deploy-backend-staging.yml
description: Add automated rollback capability for failed deployments
validation:
  command: "grep -q 'rollback' .github/workflows/deploy-backend-staging.yml"
  expect: "Workflow includes rollback step for deployment failures"
```

**Task Details:**

- Add rollback step that triggers on deployment failure
- Store previous successful deployment tag
- Implement Cloud Run revision rollback
- Include rollback notification and logging
- Test rollback procedure in staging environment

### 7. Create Development Workflow Documentation

```yaml
action: MODIFY
file: CLAUDE.md
description: Add comprehensive Docker validation workflow to development practices
validation:
  command: "grep -A 10 'Docker Build Validation Checklist' CLAUDE.md"
  expect: "Documentation includes clear Docker validation steps"
```

**Task Details:**

- Add Docker validation checklist to "Before Making Changes" section
- Include troubleshooting guide for common Docker build issues
- Document pre-commit hook setup instructions
- Add performance optimization tips for Docker builds
- Include rollback procedure documentation

### 8. Create Monitoring and Alerting Configuration

```yaml
action: CREATE
file: .github/workflows/deployment-monitor.yml
description: Create monitoring workflow for deployment health tracking
validation:
  command: "gh workflow list | grep 'Deployment Monitor'"
  expect: "Monitoring workflow exists and can be triggered"
```

**Task Details:**

- Schedule periodic health checks for deployed services
- Monitor Cloud Run service metrics and logs
- Send Slack/email notifications for deployment issues
- Track deployment success rates and failure patterns
- Include dashboard links for manual investigation

## Risk Assessment and Mitigations

### High Risk

- **CI Performance Impact**: Docker builds add ~2-3 minutes to CI time
  - _Mitigation_: Implement aggressive Docker layer caching
- **False Positives**: Docker build failures unrelated to code changes
  - _Mitigation_: Clear error messages and troubleshooting documentation

### Medium Risk

- **Team Adoption**: Developers might skip local Docker validation
  - _Mitigation_: Make it easy with clear scripts and documentation
- **Environment Inconsistencies**: Docker behavior differs between local/CI
  - _Mitigation_: Use identical Docker configurations and base images

### Low Risk

- **Storage Costs**: Additional Docker images in registry
  - _Mitigation_: Implement image cleanup policies
- **Complexity**: Additional moving parts in deployment pipeline
  - _Mitigation_: Comprehensive testing and rollback procedures

## Success Criteria

1. **Zero Docker Build Failures in Production**: All Docker issues caught in CI
2. **Fast Feedback**: Developers get Docker validation results within 5 minutes
3. **High Adoption**: 80%+ of backend PRs include Docker validation
4. **Reliable Rollbacks**: Automated rollback completes within 2 minutes
5. **Improved Monitoring**: 100% deployment health visibility

## Rollback Strategy

If any implementation causes issues:

1. **Immediate**: Disable new CI steps via GitHub Actions settings
2. **Short-term**: Revert specific workflow files to previous versions
3. **Documentation**: Remove new processes from CLAUDE.md
4. **Communication**: Notify team of rollback and alternative procedures

## Integration Points

- **Existing CI/CD**: Extends current GitHub Actions without disruption
- **Docker Registry**: Uses existing GCP Artifact Registry
- **Monitoring**: Integrates with Cloud Run and Google Cloud monitoring
- **Team Workflow**: Builds on existing CLAUDE.md development practices
- **Version Control**: Uses standard Git hooks and GitHub features
