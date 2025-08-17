# PRP: Fix WSL Port Detection Script Issues

## Goal

Enhance the port detection scripts to work reliably in WSL environments by implementing WSL-aware detection logic, improving the tool fallback chain, and adding comprehensive testing to prevent future port conflict issues during development setup.

## Why

- **Current Pain**: Port detection fails in WSL, causing `pnpm dev:ports` to attempt using occupied ports
- **Developer Impact**: Manual port specification required, breaking the "it just works" development experience
- **Root Cause**: WSL networking architecture prevents traditional tools (lsof) from seeing Windows-bound ports
- **Business Value**: Smooth onboarding and development experience for Windows developers using WSL

## What

### User-Visible Behavior

- `pnpm dev:ports` correctly detects ALL occupied ports in WSL environments
- Automatic fallback to available ports without manual intervention
- Clear feedback about port conflicts and resolutions
- Cross-platform compatibility maintained (Linux, macOS, WSL1, WSL2)

### Technical Requirements

- WSL environment detection (WSL1 vs WSL2)
- Multi-method port detection strategy
- Socket-based testing as primary method
- Enhanced error messages for debugging
- Comprehensive test coverage

### Success Criteria

- [ ] Port detection works correctly in WSL1 and WSL2
- [ ] Detects both Linux and Windows process port usage
- [ ] All existing functionality preserved on native Linux/macOS
- [ ] Test suite validates cross-platform behavior
- [ ] Performance within 2 seconds for port detection

## All Needed Context

### Documentation & References

- url: https://github.com/microsoft/WSL/issues/5298
  why: WSL2 networking architecture and port binding limitations
- url: https://learn.microsoft.com/en-us/windows/wsl/networking
  why: Official WSL networking documentation, mirrored mode details

- url: https://github.com/shellspec/shellspec
  why: Modern shell testing framework as alternative to BATS

- url: https://github.com/koalaman/shellcheck
  why: Shell script static analysis tool

### Current Codebase Context

```
scripts/
├── lib/
│   └── check-ports.sh          # Core port detection library (needs WSL enhancements)
├── dev-with-ports.sh           # Main script using the library
├── dev-with-ports.ps1          # PowerShell equivalent (working correctly)
└── test-validate-deployment-env.sh  # Existing test patterns to follow
```

### Existing Port Detection Code

- file: /home/jron/wsl_project/jerin-lt-139-time-reviewer-tool/scripts/lib/check-ports.sh
  why: Current implementation showing tool fallback pattern

- file: /home/jron/wsl_project/jerin-lt-139-time-reviewer-tool/scripts/dev-with-ports.sh
  why: Integration point for port detection, shows usage patterns

- file: /home/jron/wsl_project/jerin-lt-139-time-reviewer-tool/scripts/test-validate-deployment-env.sh
  why: Test framework patterns to follow for new tests

### Implementation Patterns

From codebase analysis:

- Modular script design with library functions in `/scripts/lib/`
- Environment variable-based configuration
- Color output with terminal capability detection
- Help flags and documentation standards
- Strict error handling with `set -euo pipefail`

### Known Gotchas

# CRITICAL: WSL's lsof cannot see Windows process port bindings

# CRITICAL: Docker Desktop binds ports at Windows level, invisible to WSL lsof

# CRITICAL: Exit code logic is inverted - lsof returns 1 when port appears "free"

# CRITICAL: WSL1 and WSL2 have different networking architectures

# CRITICAL: Corporate VPNs can interfere with WSL2 networking

## Implementation Blueprint

### Data Models and Structure

```bash
# Enhanced detection result structure
PortCheckResult() {
    local port=$1
    local is_available=$2
    local detection_method=$3
    local process_info=$4

    echo "{
        \"port\": $port,
        \"available\": $is_available,
        \"method\": \"$detection_method\",
        \"process\": \"$process_info\"
    }"
}
```

### Task List

1. **Create WSL detection utilities** - Detect WSL version and environment
2. **Implement socket-based port checking** - Primary reliable method
3. **Add Windows port detection from WSL** - Use PowerShell interop
4. **Enhance fallback chain** - Socket → Windows check → Linux tools
5. **Update check-ports.sh library** - Integrate new detection methods
6. **Add comprehensive logging** - Debug mode for troubleshooting
7. **Create test suite** - BATS-based tests for all scenarios
8. **Update documentation** - WSL-specific guidance

### Pseudocode

```bash
# Enhanced port detection flow
check_port_enhanced() {
    local port=$1

    # 1. Detect environment
    if is_wsl; then
        # 2. Try socket-based check first (most reliable)
        if socket_test_port "$port"; then
            return 0  # Port is in use
        fi

        # 3. Check Windows side via PowerShell
        if check_windows_port "$port"; then
            return 0  # Port is in use
        fi
    fi

    # 4. Fall back to traditional tools
    if command -v nc >/dev/null 2>&1; then
        nc -z localhost "$port" >/dev/null 2>&1
        return $?
    elif command -v lsof >/dev/null 2>&1; then
        # Note: May give false negatives in WSL
        lsof -i ":$port" >/dev/null 2>&1
        return $?
    fi

    return 1  # Port appears free
}

# Socket-based testing (most reliable)
socket_test_port() {
    local port=$1
    # Use timeout with bash's /dev/tcp pseudo-device
    timeout 1 bash -c "echo >/dev/tcp/localhost/$port" 2>/dev/null
}

# Windows port check via PowerShell
check_windows_port() {
    local port=$1
    powershell.exe -NoProfile -Command "
        try {
            \$tcp = New-Object System.Net.Sockets.TcpClient
            \$tcp.Connect('localhost', $port)
            \$tcp.Close()
            exit 0
        } catch {
            exit 1
        }
    " 2>/dev/null
}
```

### Integration Points

1. **scripts/lib/check-ports.sh** - Replace check_port function
2. **Environment detection** - Add to library for reuse
3. **Logging integration** - Use existing color/output patterns
4. **Docker Compose** - No changes needed, respects port variables
5. **Package.json** - Add test commands for shell scripts

## Validation Loop

### Level 1: Syntax & Style

```bash
# Shell script linting
shellcheck -x scripts/**/*.sh

# Check for common issues
shellcheck -S error scripts/lib/check-ports.sh scripts/dev-with-ports.sh
```

### Level 2: Unit Tests

```bash
# Install BATS if needed
git submodule add https://github.com/bats-core/bats-core.git test/bats

# Run port detection tests
test/bats/bin/bats test/unit/port-detection.bats

# Example test case
@test "detects occupied port in WSL" {
    # Mock WSL environment
    WSL_DISTRO_NAME=Ubuntu run check_port 5432
    assert_success  # Should detect port in use
}
```

### Level 3: Integration Tests

```bash
# Full workflow test
@test "dev-with-ports handles conflicts in WSL" {
    # Start services on default ports
    docker run -d -p 3000:80 nginx
    docker run -d -p 8000:80 nginx

    # Run script - should find alternative ports
    run timeout 30 ./scripts/dev-with-ports.sh
    assert_success
    assert_output --partial "Using port 3001"
    assert_output --partial "Using port 8001"
}
```

### Level 4: Cross-Platform Tests

```bash
# Test matrix across environments
for env in "native-linux" "wsl1" "wsl2" "macos"; do
    echo "Testing in $env environment..."
    test/bats/bin/bats test/cross-platform/$env.bats
done
```

## Final Validation Checklist

### Functionality

- [ ] Port detection works in WSL1
- [ ] Port detection works in WSL2
- [ ] Port detection works in native Linux
- [ ] Port detection works in macOS
- [ ] Detects Docker container ports
- [ ] Detects Windows process ports from WSL
- [ ] Handles timeout gracefully
- [ ] Provides clear error messages

### Code Quality

- [ ] ShellCheck passes with no errors
- [ ] Follows existing code patterns
- [ ] Comprehensive error handling
- [ ] Debug logging available
- [ ] Performance under 2 seconds

### Testing

- [ ] Unit tests for each detection method
- [ ] Integration tests for full workflow
- [ ] Cross-platform test coverage
- [ ] Edge case handling verified
- [ ] CI/CD integration ready

### Documentation

- [ ] Updated TROUBLESHOOTING.md
- [ ] WSL-specific guidance added
- [ ] Test documentation complete
- [ ] Inline code comments clear

## Performance Considerations

- Socket testing timeout: 1 second max
- Parallel detection for multiple ports
- Cache results for repeated checks
- Early exit on first successful detection

## Security Notes

- No external network connections
- Local port testing only
- PowerShell execution limited to specific command
- No privilege escalation required

## Rollback Plan

If issues arise:

1. Revert to previous check-ports.sh
2. Document specific failure scenarios
3. Provide manual workaround instructions
4. Keep PowerShell script as fallback option

## Success Metrics

- **Context Richness**: 9/10 - Comprehensive research from multiple sources
- **Implementation Clarity**: 8/10 - Clear path with pseudocode and examples
- **Validation Completeness**: 9/10 - Multi-layer testing strategy
- **One-Pass Success Probability**: 8/10 - High confidence with fallback options

This PRP provides a complete solution for the WSL port detection issues, leveraging the parallel research to create a robust, tested implementation that maintains cross-platform compatibility while solving the specific WSL networking challenges.
