# SPEC PRP: Port Configuration Wrapper Scripts

## Overview

Implement flexible port configuration wrapper scripts to support multiple git worktrees and development environments without modifying the core codebase defaults. This allows developers to run multiple instances of the Living Tree project simultaneously on different ports.

## Problem Statement

Developers using multiple git worktrees encounter port conflicts when running the application on default ports (3000 for frontend, 8000 for backend). Currently, changing ports requires modifying hardcoded values in multiple files, which is not sustainable for temporary development needs.

## Current State

```yaml
current_state:
  files:
    - package.json (hardcoded port 8000 in dev:api script)
    - apps/web/package.json (hardcoded port 3000 in dev script)
    - apps/web/lib/env.ts (default API URL http://localhost:8000)
    - api/core/config.py (CORS origins with hardcoded ports)

  behavior:
    - Frontend always starts on port 3000
    - Backend always starts on port 8000
    - No environment variable override mechanism
    - CORS expects specific port combinations
    - Documentation assumes default ports

  issues:
    - Cannot run multiple instances simultaneously
    - Port conflicts with git worktrees
    - Modifying ports requires code changes
    - No centralized port configuration
    - CORS mismatches when ports change
```

## Desired State

```yaml
desired_state:
  files:
    - scripts/dev-custom-ports.sh (new wrapper script)
    - scripts/dev-custom-ports.ps1 (Windows PowerShell version)
    - .env.ports.example (example port configuration)
    - package.json (updated scripts to support PORT env vars)
    - README.md (updated with custom port documentation)

  behavior:
    - Developers can run: ./scripts/dev-custom-ports.sh
    - Script prompts for or uses configured ports
    - Automatic CORS adjustment for custom ports
    - Frontend API URL updates dynamically
    - All services start with custom ports

  benefits:
    - Multiple worktrees can run simultaneously
    - No code modifications needed
    - Preserves default behavior
    - Easy port customization
    - Better developer experience
```

## Implementation Tasks

### Task 1: Create Port Configuration Wrapper Script

```yaml
create_wrapper_script:
  action: CREATE
  file: scripts/dev-custom-ports.sh
  changes: |
    #!/bin/bash

    # Port Configuration Wrapper for Living Tree Development
    # Allows running multiple instances with custom ports

    # Default ports (can be overridden)
    FRONTEND_PORT="${FRONTEND_PORT:-3001}"
    BACKEND_PORT="${BACKEND_PORT:-8001}"

    # Color codes for output
    GREEN='\033[0;32m'
    BLUE='\033[0;34m'
    YELLOW='\033[1;33m'
    NC='\033[0m' # No Color

    echo -e "${BLUE}Living Tree - Custom Port Configuration${NC}"
    echo "=========================================="

    # Check if ports are available
    check_port() {
      local port=$1
      if lsof -i :$port > /dev/null 2>&1; then
        return 1
      else
        return 0
      fi
    }

    # Interactive mode if no env vars set
    if [ -z "$FRONTEND_PORT" ] && [ -z "$BACKEND_PORT" ]; then
      echo -e "${YELLOW}No port configuration found. Using interactive mode.${NC}"
      
      # Frontend port
      read -p "Frontend port (default 3001): " input_frontend
      FRONTEND_PORT="${input_frontend:-3001}"
      
      # Backend port
      read -p "Backend port (default 8001): " input_backend
      BACKEND_PORT="${input_backend:-8001}"
    fi

    # Validate ports are available
    echo -e "\n${BLUE}Checking port availability...${NC}"

    if ! check_port $FRONTEND_PORT; then
      echo -e "${YELLOW}Warning: Port $FRONTEND_PORT is already in use!${NC}"
      exit 1
    fi

    if ! check_port $BACKEND_PORT; then
      echo -e "${YELLOW}Warning: Port $BACKEND_PORT is already in use!${NC}"
      exit 1
    fi

    echo -e "${GREEN}✓ Port $FRONTEND_PORT is available (Frontend)${NC}"
    echo -e "${GREEN}✓ Port $BACKEND_PORT is available (Backend)${NC}"

    # Export environment variables
    export PORT=$FRONTEND_PORT
    export API_PORT=$BACKEND_PORT
    export NEXT_PUBLIC_API_BASE_URL="http://localhost:$BACKEND_PORT"

    # Update CORS for local development
    export CORS_ORIGINS_LOCAL="http://localhost:$FRONTEND_PORT,http://localhost:8080"

    # Display configuration
    echo -e "\n${BLUE}Starting services with custom configuration:${NC}"
    echo "Frontend: http://localhost:$FRONTEND_PORT"
    echo "Backend:  http://localhost:$BACKEND_PORT"
    echo "API Docs: http://localhost:$BACKEND_PORT/docs"

    # Start services
    echo -e "\n${BLUE}Starting development servers...${NC}\n"

    # Run the full development stack
    pnpm dev:full

  validation:
    - command: "chmod +x scripts/dev-custom-ports.sh"
    - expect: "Script is executable"
```

### Task 2: Create Windows PowerShell Version

```yaml
create_powershell_script:
  action: CREATE
  file: scripts/dev-custom-ports.ps1
  changes: |
    # Port Configuration Wrapper for Living Tree Development (Windows)
    # Allows running multiple instances with custom ports

    param(
        [int]$FrontendPort = 3001,
        [int]$BackendPort = 8001
    )

    Write-Host "Living Tree - Custom Port Configuration" -ForegroundColor Blue
    Write-Host "==========================================" 

    # Function to check if port is available
    function Test-Port {
        param($Port)
        $tcpClient = New-Object System.Net.Sockets.TcpClient
        try {
            $tcpClient.Connect("localhost", $Port)
            $tcpClient.Close()
            return $false
        } catch {
            return $true
        }
    }

    # Interactive mode if using defaults
    if ($FrontendPort -eq 3001 -and $BackendPort -eq 8001) {
        Write-Host "Using default ports. Press Enter to continue or input custom ports." -ForegroundColor Yellow
        
        $inputFrontend = Read-Host "Frontend port (default 3001)"
        if ($inputFrontend) { $FrontendPort = [int]$inputFrontend }
        
        $inputBackend = Read-Host "Backend port (default 8001)"
        if ($inputBackend) { $BackendPort = [int]$inputBackend }
    }

    # Validate ports
    Write-Host "`nChecking port availability..." -ForegroundColor Blue

    if (!(Test-Port $FrontendPort)) {
        Write-Host "Warning: Port $FrontendPort is already in use!" -ForegroundColor Yellow
        exit 1
    }

    if (!(Test-Port $BackendPort)) {
        Write-Host "Warning: Port $BackendPort is already in use!" -ForegroundColor Yellow
        exit 1
    }

    Write-Host "✓ Port $FrontendPort is available (Frontend)" -ForegroundColor Green
    Write-Host "✓ Port $BackendPort is available (Backend)" -ForegroundColor Green

    # Set environment variables
    $env:PORT = $FrontendPort
    $env:API_PORT = $BackendPort
    $env:NEXT_PUBLIC_API_BASE_URL = "http://localhost:$BackendPort"
    $env:CORS_ORIGINS_LOCAL = "http://localhost:$FrontendPort,http://localhost:8080"

    # Display configuration
    Write-Host "`nStarting services with custom configuration:" -ForegroundColor Blue
    Write-Host "Frontend: http://localhost:$FrontendPort"
    Write-Host "Backend:  http://localhost:$BackendPort"
    Write-Host "API Docs: http://localhost:$BackendPort/docs"

    # Start services
    Write-Host "`nStarting development servers..." -ForegroundColor Blue
    pnpm dev:full

  validation:
    - command: "Test-Path scripts/dev-custom-ports.ps1"
    - expect: "True"
```

### Task 3: Update Package.json Scripts

```yaml
update_package_scripts:
  action: MODIFY
  file: package.json
  changes: |
    Update the dev:api script to support API_PORT environment variable:

    FROM:
    "dev:api": "poetry run uvicorn api.index:app --reload --port 8000",

    TO:
    "dev:api": "poetry run uvicorn api.index:app --reload --port ${API_PORT:-8000}",

  validation:
    - command: "grep 'API_PORT' package.json"
    - expect: "Match found"
```

### Task 4: Create Example Port Configuration

```yaml
create_port_config_example:
  action: CREATE
  file: .env.ports.example
  changes: |
    # Custom Port Configuration for Living Tree
    # Copy this file to .env.ports and customize as needed

    # Frontend port (Next.js)
    FRONTEND_PORT=3001

    # Backend port (FastAPI)
    BACKEND_PORT=8001

    # You can source this file before running the wrapper script:
    # source .env.ports && ./scripts/dev-custom-ports.sh

  validation:
    - command: "test -f .env.ports.example"
    - expect: "Success"
```

### Task 5: Update Documentation

````yaml
update_readme:
  action: MODIFY
  file: README.md
  changes: |
    Add a new section after "## Quick Start":

    ## Running with Custom Ports

    If you need to run multiple instances (e.g., for git worktrees), use the custom port wrapper:

    ```bash
    # Interactive mode - prompts for ports
    ./scripts/dev-custom-ports.sh

    # With environment variables
    FRONTEND_PORT=3001 BACKEND_PORT=8001 ./scripts/dev-custom-ports.sh

    # Using port configuration file
    cp .env.ports.example .env.ports
    # Edit .env.ports with your desired ports
    source .env.ports && ./scripts/dev-custom-ports.sh

    # Windows PowerShell
    .\scripts\dev-custom-ports.ps1 -FrontendPort 3001 -BackendPort 8001
    ```

    The wrapper script will:
    - Check if ports are available
    - Configure environment variables
    - Update CORS settings automatically
    - Start both frontend and backend with custom ports

  validation:
    - command: "grep -A 5 'Running with Custom Ports' README.md"
    - expect: "Section found"
````

### Task 6: Add Script Directory to Git

```yaml
ensure_scripts_directory:
  action: CREATE
  file: scripts/.gitkeep
  changes: |
    # This file ensures the scripts directory is tracked by git

  validation:
    - command: "test -d scripts"
    - expect: "Success"
```

## Validation Checklist

```bash
# 1. Scripts are executable
chmod +x scripts/dev-custom-ports.sh
test -x scripts/dev-custom-ports.sh

# 2. Port detection works
./scripts/dev-custom-ports.sh  # Should prompt for ports

# 3. Environment variables are set correctly
FRONTEND_PORT=3002 BACKEND_PORT=8002 ./scripts/dev-custom-ports.sh

# 4. Services start on custom ports
# Check that Next.js starts on custom frontend port
# Check that FastAPI starts on custom backend port

# 5. CORS works with custom ports
# Test API calls from frontend to backend

# 6. Documentation is clear
grep "Custom Ports" README.md
```

## Rollback Plan

If the wrapper scripts cause issues:

1. Delete the scripts directory: `rm -rf scripts/`
2. Revert package.json changes: `git checkout -- package.json`
3. Remove documentation section from README.md
4. Continue using default ports or manual port overrides

## Risk Mitigation

1. **Risk**: Scripts might not work on all platforms
   - **Mitigation**: Provide both bash and PowerShell versions
2. **Risk**: Environment variables might conflict
   - **Mitigation**: Use unique variable names (FRONTEND_PORT, BACKEND_PORT)
3. **Risk**: CORS might still fail
   - **Mitigation**: Export CORS_ORIGINS_LOCAL with correct ports

4. **Risk**: Port availability check might be inaccurate
   - **Mitigation**: Use reliable commands (lsof, netstat)

## Success Criteria

1. Developers can run multiple instances on different ports
2. No modifications to core codebase required
3. Default behavior (ports 3000/8000) remains unchanged
4. Clear documentation for using custom ports
5. Works on Mac, Linux, and Windows
6. Automatic CORS configuration

## Notes

- This solution maintains backward compatibility
- Scripts are optional - existing workflows continue to work
- Can be extended to support more configuration options
- Provides foundation for future port management improvements

## Confidence Score: 9/10

High confidence as this is a non-invasive solution that adds functionality without breaking existing behavior. The wrapper script approach is a proven pattern for development tooling.
