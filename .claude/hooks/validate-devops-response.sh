#!/bin/bash

# DevOps Response Validation Hook
# Verifies that DevOps agent suggestions actually resolve issues

PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$PROJECT_ROOT" || exit 1

echo "🔍 Validating DevOps agent response effectiveness..."

# Read the original issues if available
ISSUES_FILE="${PROJECT_ROOT}/.devops_issues.tmp"
if [[ -f "$ISSUES_FILE" ]]; then
    ORIGINAL_ISSUES=$(cat "$ISSUES_FILE")
    echo "Original issues: $ORIGINAL_ISSUES"
else
    echo "No original issues file found, running general validation"
    ORIGINAL_ISSUES=""
fi

# Re-run health checks to see if issues were resolved
VALIDATION_ERRORS=()

# 1. Re-check ports if that was an issue
if [[ "$ORIGINAL_ISSUES" == *"Port"* ]] && command -v lsof >/dev/null 2>&1; then
    echo "Re-validating port availability..."
    if lsof -i :3000 >/dev/null 2>&1; then
        VALIDATION_ERRORS+=("Port 3000 still in use - DevOps suggestion may not have worked")
    fi
    if lsof -i :8000 >/dev/null 2>&1; then
        VALIDATION_ERRORS+=("Port 8000 still in use - DevOps suggestion may not have worked") 
    fi
fi

# 2. Re-check JWT if that was an issue
if [[ "$ORIGINAL_ISSUES" == *"JWT"* ]]; then
    echo "Re-validating JWT token..."
    if [[ -f ".env" ]]; then
        source ".env" 2>/dev/null || true
    fi
    
    if [[ -n "$SUPABASE_SERVICE_ROLE_KEY" ]]; then
        if ! echo "$SUPABASE_SERVICE_ROLE_KEY" | grep -qE '^eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$'; then
            VALIDATION_ERRORS+=("JWT token format still invalid - DevOps suggestion may not have worked")
        fi
    else
        VALIDATION_ERRORS+=("SUPABASE_SERVICE_ROLE_KEY still missing - DevOps suggestion may not have worked")
    fi
fi

# 3. Re-check Docker if that was an issue
if [[ "$ORIGINAL_ISSUES" == *"Docker"* ]] && command -v pnpm >/dev/null 2>&1; then
    echo "Re-validating Docker status..."
    if ! pnpm docker:logs >/dev/null 2>&1; then
        VALIDATION_ERRORS+=("Docker services still not running - DevOps suggestion may not have worked")
    fi
fi

# 4. Re-check environment if that was an issue
if [[ "$ORIGINAL_ISSUES" == *".env"* ]]; then
    echo "Re-validating environment file..."
    if [[ ! -f ".env" ]]; then
        VALIDATION_ERRORS+=(".env file still missing - DevOps suggestion may not have worked")
    fi
fi

# Report validation results
if [ ${#VALIDATION_ERRORS[@]} -eq 0 ]; then
    echo "✅ DevOps agent response validation passed! Issues appear to be resolved."
    # Clean up temp file
    [[ -f "$ISSUES_FILE" ]] && rm "$ISSUES_FILE"
    exit 0
else
    echo "⚠️ DevOps agent response validation failed:"
    printf '%s\n' "${VALIDATION_ERRORS[@]}"
    echo
    echo "💡 Consider:"
    echo "  - Checking if the suggested commands were run correctly"
    echo "  - Verifying all prerequisites are met"
    echo "  - Running the DevOps agent again with more specific context"
    exit 1
fi