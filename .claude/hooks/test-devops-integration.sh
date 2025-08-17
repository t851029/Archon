#!/bin/bash

# DevOps Integration Test
# Tests the complete DevOps automation system end-to-end

PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
cd "$PROJECT_ROOT" || exit 1

echo "🧪 Running DevOps automation integration tests..."
echo "========================================"

# Test results tracking
TESTS_PASSED=0
TESTS_FAILED=0
FAILED_TESTS=()

# Helper function for test results
test_result() {
    local test_name="$1"
    local result="$2"
    
    if [[ "$result" -eq 0 ]]; then
        echo "✅ $test_name: PASSED"
        ((TESTS_PASSED++))
    else
        echo "❌ $test_name: FAILED"
        ((TESTS_FAILED++))
        FAILED_TESTS+=("$test_name")
    fi
}

echo
echo "Test 1: DevOps Agent Configuration"
echo "----------------------------------"
if [[ -f ".claude/agents/devops-helper.md" ]]; then
    # Check agent has required sections
    if grep -q "JWT Token Validation" ".claude/agents/devops-helper.md" && \
       grep -q "Port Conflict Resolution" ".claude/agents/devops-helper.md" && \
       grep -q "Environment Debugging" ".claude/agents/devops-helper.md" && \
       grep -q "Docker Issues" ".claude/agents/devops-helper.md" && \
       grep -q "CORS Debugging" ".claude/agents/devops-helper.md"; then
        test_result "Agent configuration completeness" 0
    else
        test_result "Agent configuration completeness" 1
    fi
    
    # Check for pnpm usage (not docker-compose)
    if grep -q "pnpm docker:" ".claude/agents/devops-helper.md" && \
       ! grep -q "docker-compose" ".claude/agents/devops-helper.md"; then
        test_result "Agent uses correct pnpm patterns" 0
    else
        test_result "Agent uses correct pnpm patterns" 1
    fi
else
    test_result "Agent configuration exists" 1
fi

echo
echo "Test 2: Hook Configuration"
echo "--------------------------"
if [[ -f ".claude/settings.json" ]]; then
    # Check ToolErrored hooks exist
    if grep -q '"ToolErrored"' ".claude/settings.json" && \
       grep -q 'Port.*already in use' ".claude/settings.json" && \
       grep -q 'JWSError' ".claude/settings.json" && \
       grep -q 'CORS.*origin' ".claude/settings.json" && \
       grep -q 'Environment variable.*not found' ".claude/settings.json" && \
       grep -q 'Docker.*error' ".claude/settings.json"; then
        test_result "ToolErrored hooks configuration" 0
    else
        test_result "ToolErrored hooks configuration" 1
    fi
    
    # Check timeouts are specified
    if grep -A 5 '"ToolErrored"' ".claude/settings.json" | grep -q '"timeout"'; then
        test_result "Hook timeouts specified" 0
    else
        test_result "Hook timeouts specified" 1
    fi
    
    # Check PreToolUse hooks exist
    if grep -q '"PreToolUse"' ".claude/settings.json" && \
       grep -q 'deploy' ".claude/settings.json"; then
        test_result "PreToolUse hooks configuration" 0
    else
        test_result "PreToolUse hooks configuration" 1
    fi
else
    test_result "Hook configuration exists" 1
fi

echo
echo "Test 3: Health Check Script"
echo "---------------------------"
if [[ -f ".claude/hooks/devops-health-check.sh" ]]; then
    if [[ -x ".claude/hooks/devops-health-check.sh" ]]; then
        test_result "Health check script executable" 0
        
        # Test the script runs without errors (may find issues but shouldn't crash)
        if ./.claude/hooks/devops-health-check.sh >/dev/null 2>&1 || [[ $? -eq 1 ]]; then
            test_result "Health check script runs" 0
        else
            test_result "Health check script runs" 1
        fi
        
        # Check script uses project-relative paths
        if grep -q 'CLAUDE_PROJECT_DIR' ".claude/hooks/devops-health-check.sh" && \
           ! grep -q '/tmp/devops_issues.txt' ".claude/hooks/devops-health-check.sh"; then
            test_result "Health check uses relative paths" 0
        else
            test_result "Health check uses relative paths" 1
        fi
    else
        test_result "Health check script executable" 1
    fi
else
    test_result "Health check script exists" 1
fi

echo
echo "Test 4: Validation Script"
echo "-------------------------"
if [[ -f ".claude/hooks/validate-devops-response.sh" ]]; then
    if [[ -x ".claude/hooks/validate-devops-response.sh" ]]; then
        test_result "Validation script executable" 0
        
        # Test the script runs (should pass if no issues file exists)
        if ./.claude/hooks/validate-devops-response.sh >/dev/null 2>&1; then
            test_result "Validation script runs" 0
        else
            test_result "Validation script runs" 1
        fi
    else
        test_result "Validation script executable" 1
    fi
else
    test_result "Validation script exists" 1
fi

echo
echo "Test 5: Required Scripts Availability"
echo "-------------------------------------"
REQUIRED_SCRIPTS=(
    "scripts/dev-with-ports.sh"
    "scripts/validate-deployment-env.sh"
    "scripts/docker-maintenance.sh"
    "scripts/sync-env-enhanced.ts"
    "scripts/deployment-health-check.sh"
)

for script in "${REQUIRED_SCRIPTS[@]}"; do
    if [[ -f "$script" ]]; then
        test_result "Script exists: $script" 0
    else
        test_result "Script exists: $script" 1
    fi
done

echo
echo "Test 6: Integration Functionality"
echo "---------------------------------"
# Test that we can invoke the DevOps agent manually
if command -v claude >/dev/null 2>&1; then
    # Try to validate the agent exists
    if claude list-agents 2>/dev/null | grep -q "devops-helper"; then
        test_result "DevOps agent registered with Claude Code" 0
    else
        echo "⚠️ DevOps agent not registered (run 'claude list-agents' to verify)"
        test_result "DevOps agent registered with Claude Code" 1
    fi
else
    echo "⚠️ Claude Code CLI not available for testing"
    test_result "Claude Code CLI available" 1
fi

echo
echo "========================================"
echo "🏁 DevOps Integration Test Results"
echo "========================================"
echo "Tests Passed: $TESTS_PASSED"
echo "Tests Failed: $TESTS_FAILED"
echo "Total Tests:  $((TESTS_PASSED + TESTS_FAILED))"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo
    echo "🎉 All tests passed! DevOps automation is ready."
    echo
    echo "Try these commands to test the system:"
    echo "  • /agents devops-helper 'validate staging environment'"
    echo "  • /agents devops-helper 'check JWT token format'"
    echo "  • /agents devops-helper 'resolve port conflicts'"
    echo
    exit 0
else
    echo
    echo "❌ Some tests failed. Review the following issues:"
    for test in "${FAILED_TESTS[@]}"; do
        echo "  • $test"
    done
    echo
    exit 1
fi