#!/bin/bash

# DevOps Health Check Hook
# Automatically run health checks and trigger DevOps agent if issues found

# Get the project root directory
PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$PROJECT_ROOT" || exit 1

echo "🏥 Running automated DevOps health check..."

# Check for common issues
ISSUES_FOUND=()

# 1. Check ports
echo "Checking port availability..."
if command -v lsof >/dev/null 2>&1; then
    if lsof -i :3000 >/dev/null 2>&1; then
        ISSUES_FOUND+=("Port 3000 in use")
    fi
    if lsof -i :8000 >/dev/null 2>&1; then
        ISSUES_FOUND+=("Port 8000 in use") 
    fi
    if lsof -i :54321 >/dev/null 2>&1; then
        ISSUES_FOUND+=("Port 54321 in use") 
    fi
else
    echo "Warning: lsof not available, skipping port check"
fi

# 2. Check JWT format
if [[ -f ".env" ]]; then
    source ".env" 2>/dev/null || true
fi

if [[ -n "$SUPABASE_SERVICE_ROLE_KEY" ]]; then
    echo "Validating JWT token format..."
    if ! echo "$SUPABASE_SERVICE_ROLE_KEY" | grep -qE '^eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$'; then
        ISSUES_FOUND+=("Invalid JWT token format")
    fi
else
    ISSUES_FOUND+=("Missing SUPABASE_SERVICE_ROLE_KEY")
fi

# 3. Check Docker via pnpm scripts
echo "Checking Docker status..."
if command -v pnpm >/dev/null 2>&1; then
    if ! pnpm docker:logs >/dev/null 2>&1; then
        ISSUES_FOUND+=("Docker services not running")
    fi
else
    echo "Warning: pnpm not available, skipping Docker check"
fi

# 4. Check environment sync
echo "Checking environment sync status..."
if [[ ! -f ".env" ]]; then
    ISSUES_FOUND+=("Missing .env file - run pnpm env:sync:dev")
fi

# 5. Check required scripts exist
echo "Validating required scripts..."
REQUIRED_SCRIPTS=("scripts/dev-with-ports.sh" "scripts/validate-deployment-env.sh" "scripts/docker-maintenance.sh")
for script in "${REQUIRED_SCRIPTS[@]}"; do
    if [[ ! -f "$script" ]]; then
        ISSUES_FOUND+=("Missing required script: $script")
    fi
done

# Report results
if [ ${#ISSUES_FOUND[@]} -eq 0 ]; then
    echo "✅ All health checks passed!"
    exit 0
else
    echo "⚠️ Issues found:"
    printf '%s\n' "${ISSUES_FOUND[@]}"
    echo
    
    # Create issue summary for DevOps agent
    ISSUE_SUMMARY=$(printf '%s, ' "${ISSUES_FOUND[@]}")
    ISSUE_SUMMARY=${ISSUE_SUMMARY%, }  # Remove trailing comma
    
    # Write issues to project-relative temp file
    TEMP_FILE="${PROJECT_ROOT}/.devops_issues.tmp"
    echo "$ISSUE_SUMMARY" > "$TEMP_FILE"
    
    echo "🤖 Issues logged to $TEMP_FILE for DevOps agent review"
    exit 1  # Signal that issues were found
fi