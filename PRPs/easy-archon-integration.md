name: "Easy Archon Integration for Claude Code Projects"
description: |

## Purpose

Enable seamless Archon integration in any Claude Code project through a bootstrap system that auto-detects, installs, and starts Archon services with zero friction.

## Core Principles

1. **Zero-Friction Setup**: Clone and run - Archon handles itself
2. **Smart Detection**: Reuse existing installations, avoid duplication
3. **Cross-Platform**: Works on WSL2, Mac, Linux with same commands
4. **Project Isolation**: Each project configures its own Archon connection

---

## Goal

Create a bootstrap script system that allows developers to add Archon to any Claude Code project with minimal setup, automatically handling Docker containers, health checks, and MCP configuration.

## Why

- **Eliminate Friction**: Developers spend time coding, not configuring infrastructure
- **Standardize Integration**: Same Archon experience across all projects
- **Reuse Infrastructure**: Single Supabase database, multiple project connections
- **Enable Rapid Adoption**: Lower barrier to entry for Archon in existing projects

## What

A lightweight `.archon/` directory with bootstrap scripts that can be added to any project, providing automatic Archon setup and management through npm/pnpm commands.

### Success Criteria

- [ ] Bootstrap script detects and installs Archon if needed
- [ ] Docker containers start automatically with health checks
- [ ] Port conflicts are resolved automatically
- [ ] MCP configuration is generated for Claude Code
- [ ] Works identically on WSL2, Mac, and Linux
- [ ] Integrates with npm/pnpm scripts seamlessly

## All Needed Context

### Documentation & References

```yaml
# MUST READ - Include these in your context window
- url: https://docs.docker.com/engine/containers/start-containers-automatically/
  why: Container auto-start patterns with restart policies

- file: /home/gwizz/wsl_projects/Archon/docker-compose.yml
  why: Multi-service orchestration with health checks pattern

- file: /home/gwizz/wsl_projects/Archon/python/src/server/config/service_discovery.py
  why: Environment detection and service URL resolution patterns

- doc: https://modelcontextprotocol.io/docs/specification/architecture
  section: MCP Server Configuration
  critical: SSE and stdio transport configuration for Claude Code

- file: /home/gwizz/wsl_projects/Archon/.env.example
  why: Environment variable template with documentation

- file: /home/gwizz/wsl_projects/Archon/archon-ui-main/Dockerfile
  why: SSL workarounds for WSL2 environments

- url: https://github.com/peter-evans/docker-compose-healthcheck
  why: Native Docker Compose health check dependency patterns

- docfile: PRPs/backlog/archon/easy-archon-integration-plan.md
  why: Detailed plan with all implementation strategies

- docfile: PRPs/ai_docs/cc_mcp.md
  why: Claude Code MCP configuration patterns
```

### Current Codebase Structure

```bash
/home/gwizz/wsl_projects/Archon/
├── docker-compose.yml           # Multi-service orchestration
├── .env.example                # Environment template
├── python/
│   ├── src/
│   │   ├── server/            # Main API service
│   │   ├── mcp/              # MCP server
│   │   └── agents/           # AI agents service
│   └── Dockerfile.*          # Service containers
├── archon-ui-main/           # Frontend
└── migration/
    └── complete_setup.sql    # Database bootstrap
```

### Desired Structure (in target projects)

```bash
any-claude-project/
├── .archon/                    # Archon integration directory
│   ├── bootstrap.sh           # Main setup script
│   ├── config.env.example     # Supabase credentials template
│   ├── config.env            # User's actual credentials (gitignored)
│   ├── mcp-config.json       # Claude Code MCP configuration
│   └── settings.json         # Project-specific Archon settings
├── package.json              # With Archon npm scripts
└── [existing project files]
```

### Known Gotchas & Library Quirks

```bash
# CRITICAL: WSL2 SSL issues require HTTP workarounds (see archon-ui-main/Dockerfile)
# CRITICAL: Docker health checks must use Python urllib, not curl (see docker-compose.yml)
# CRITICAL: Service discovery checks /.dockerenv for environment detection
# CRITICAL: MCP requires exact port matching between config and runtime
# CRITICAL: Supabase service key must be the legacy format (longer one)
# CRITICAL: Port conflicts common on 3737, 8181, 8051, 8052
```

## Implementation Blueprint

### Data Models and Structure

```bash
# Configuration structure in .archon/settings.json
{
  "archonHome": "${HOME}/.archon",           # Global installation path
  "archonRepo": "https://github.com/t851029/archon.git",  # SSL-fixed fork
  "archonVersion": "main",
  "autoStart": true,
  "services": ["server", "mcp", "agents", "ui"],
  "ports": {
    "ui": 3737,
    "server": 8181,
    "mcp": 8051,
    "agents": 8052
  },
  "knowledgeBase": {
    "autoIndex": ["./docs", "./README.md"],
    "crawlOnStart": []
  }
}
```

### List of Tasks

```yaml
Task 1: Create bootstrap.sh script
CREATE .archon/bootstrap.sh:
  - PATTERN from: python/src/server/config/service_discovery.py (environment detection)
  - IMPLEMENT: check_docker_running() using docker info command
  - IMPLEMENT: check_archon_installed() checking ~/.archon/archon directory
  - IMPLEMENT: install_archon() cloning from GitHub with SSL fixes
  - IMPLEMENT: check_ports_available() using lsof/netstat
  - IMPLEMENT: start_archon_services() with docker-compose up -d
  - IMPLEMENT: wait_for_health() checking /health endpoints
  - ADD: WSL2 detection using uname -r | grep microsoft

Task 2: Create config.env.example template
CREATE .archon/config.env.example:
  - COPY structure from: /home/gwizz/wsl_projects/Archon/.env.example
  - ADD: Clear documentation for each variable
  - ADD: ARCHON_HOME path configuration
  - INCLUDE: Port customization options

Task 3: Create MCP configuration generator
CREATE .archon/generate-mcp-config.sh:
  - GENERATE: mcp-config.json for Claude Code
  - PATTERN: Use docker exec for stdio transport (see PRPs/ai_docs/cc_mcp.md)
  - DETECT: Current ports from environment
  - OUTPUT: Both stdio and SSE configurations

Task 4: Integrate with npm/pnpm scripts
MODIFY package.json:
  - ADD: "archon:install": "bash .archon/bootstrap.sh install"
  - ADD: "archon:start": "bash .archon/bootstrap.sh start"
  - ADD: "archon:stop": "bash .archon/bootstrap.sh stop"
  - ADD: "archon:status": "bash .archon/bootstrap.sh status"
  - ADD: "predev": "npm run archon:start"
  - ADD: "postinstall": "[ -f .archon/bootstrap.sh ] && bash .archon/bootstrap.sh check || true"

Task 5: Create port conflict resolution
IMPLEMENT in bootstrap.sh:
  - FUNCTION: find_available_port() starting from default
  - UPDATE: .env file with discovered ports
  - NOTIFY: User of port changes
  - PATTERN from: service_discovery.py DEFAULT_PORTS

Task 6: Add health check monitoring
IMPLEMENT in bootstrap.sh:
  - PATTERN from: docker-compose.yml health checks
  - CHECK: http://localhost:8181/health for server
  - CHECK: http://localhost:8052/health for agents
  - CHECK: socket connection for MCP port 8051
  - RETRY: With exponential backoff up to 60 seconds

Task 7: Create cross-platform compatibility
IMPLEMENT in bootstrap.sh:
  - DETECT: OS using uname/OSTYPE
  - HANDLE: WSL2 specific SSL workarounds
  - HANDLE: Mac specific Docker Desktop paths
  - HANDLE: Linux native Docker differences
  - USE: Portable commands (POSIX compliant)
```

### Per Task Pseudocode

```bash
# Task 1: Bootstrap script core logic
#!/bin/bash

ARCHON_HOME="${ARCHON_HOME:-$HOME/.archon}"
ARCHON_REPO="${ARCHON_REPO:-https://github.com/t851029/archon.git}"
PROJECT_ROOT="$(pwd)"

check_docker_running() {
    # PATTERN: From external research on Docker detection
    if ! docker info > /dev/null 2>&1; then
        echo "Docker is not running"
        return 1
    fi
    return 0
}

check_archon_installed() {
    # PATTERN: Simple directory existence check
    if [ -d "$ARCHON_HOME/archon" ]; then
        return 0
    fi
    return 1
}

install_archon() {
    # CRITICAL: Use SSL-fixed fork for WSL2
    mkdir -p "$ARCHON_HOME"
    git clone "$ARCHON_REPO" "$ARCHON_HOME/archon"
    cd "$ARCHON_HOME/archon"
    
    # Copy project config if exists
    if [ -f "$PROJECT_ROOT/.archon/config.env" ]; then
        cp "$PROJECT_ROOT/.archon/config.env" .env
    fi
}

wait_for_health() {
    # PATTERN: From service_discovery.py wait_for_service
    local max_attempts=30
    local delay=2
    
    for attempt in $(seq 1 $max_attempts); do
        if curl -s http://localhost:${ARCHON_SERVER_PORT:-8181}/health > /dev/null; then
            return 0
        fi
        sleep $delay
    done
    return 1
}

# Task 5: Port conflict resolution
find_available_port() {
    local default_port=$1
    local port=$default_port
    
    # PATTERN: From research on port conflict resolution
    while lsof -Pi :$port -sTCP:LISTEN -t >/dev/null 2>&1; do
        port=$((port + 1))
    done
    
    echo $port
}

# Task 6: Service startup with health checks
start_services() {
    cd "$ARCHON_HOME/archon"
    
    # PATTERN: From docker-compose.yml
    docker-compose up -d
    
    echo "Waiting for services to become healthy..."
    
    # Check each service health endpoint
    for service in "server:8181" "agents:8052"; do
        IFS=':' read -r name port <<< "$service"
        if ! wait_for_service_health $port; then
            echo "Service $name failed to start"
            return 1
        fi
    done
    
    # MCP uses socket check
    if ! nc -z localhost ${ARCHON_MCP_PORT:-8051}; then
        echo "MCP service not responding"
        return 1
    fi
}
```

### Integration Points

```yaml
NPM_SCRIPTS:
  - file: package.json
  - add: scripts section with archon:* commands
  - pattern: "predev" hook for automatic startup

DOCKER_COMPOSE:
  - source: ~/.archon/archon/docker-compose.yml
  - override: Port mappings from environment
  - health: Native depends_on with service_healthy

MCP_CONFIG:
  - generate: .archon/mcp-config.json
  - transport: stdio with docker exec
  - fallback: SSE with http://localhost:8051

ENVIRONMENT:
  - template: .archon/config.env.example
  - actual: .archon/config.env (gitignored)
  - merge: With ~/.archon/archon/.env
```

## Validation Loop

### Level 1: Syntax & Style

```bash
# Validate shell script syntax
shellcheck .archon/bootstrap.sh
bash -n .archon/bootstrap.sh

# Expected: No errors
```

### Level 2: Unit Tests

```bash
# Test individual functions
source .archon/bootstrap.sh

# Test Docker detection
check_docker_running && echo "Docker OK" || echo "Docker not running"

# Test port detection
original_port=8181
available_port=$(find_available_port $original_port)
echo "Port $original_port -> $available_port"

# Test Archon detection
check_archon_installed && echo "Archon found" || echo "Archon not installed"
```

### Level 3: Integration Test

```bash
# Full bootstrap test in fresh project
mkdir test-project && cd test-project
mkdir .archon
cp ../archon/.archon/* .archon/
cp .archon/config.env.example .archon/config.env
# Edit config.env with Supabase credentials

# Run bootstrap
bash .archon/bootstrap.sh start

# Verify services
curl http://localhost:3737  # UI
curl http://localhost:8181/health  # Server
curl http://localhost:8051/health  # MCP

# Test MCP configuration
claude mcp add archon-test --transport sse http://localhost:8051
claude mcp list
```

### Level 4: Cross-Platform Validation

```bash
# WSL2 Test
if [[ "$(uname -r)" == *"microsoft"* ]]; then
    echo "Testing WSL2 SSL workarounds..."
    # Verify HTTP registries work
    # Check Docker Desktop integration
fi

# Mac Test
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "Testing Mac Docker Desktop..."
    # Verify Docker socket location
    # Check port availability commands
fi

# Linux Test
if [[ "$OSTYPE" == "linux-gnu"* ]] && [[ "$(uname -r)" != *"microsoft"* ]]; then
    echo "Testing native Linux..."
    # Verify systemd integration
    # Check Docker permissions
fi
```

## Final Validation Checklist

- [ ] Bootstrap script installs Archon if not present
- [ ] Docker containers start with health checks passing
- [ ] Port conflicts are detected and resolved
- [ ] MCP configuration is generated correctly
- [ ] npm run dev automatically starts Archon
- [ ] Works on WSL2 with SSL fixes
- [ ] Works on Mac with Docker Desktop
- [ ] Works on native Linux
- [ ] Reuses existing Archon installation
- [ ] Config.env template is clear and documented

---

## Anti-Patterns to Avoid

- ❌ Don't hardcode paths - use environment variables
- ❌ Don't assume Docker is running - check first
- ❌ Don't ignore port conflicts - detect and resolve
- ❌ Don't skip health checks - wait for services
- ❌ Don't force reinstall - reuse existing Archon
- ❌ Don't mix global and project config - keep separate

## Confidence Score

**One-pass implementation success likelihood: 9/10**

The comprehensive research, specific file patterns, and detailed pseudocode provide sufficient context for successful implementation. The only uncertainty is cross-platform edge cases that may require minor adjustments.