# Easy Archon Integration for Claude Code Projects

## Overview

A streamlined approach to integrate Archon into any Claude Code project, allowing developers to clone a repo and immediately have Archon available with minimal setup.

## Solution Architecture

### Option 1: Project-Level Bootstrap Script (Recommended)

Add a lightweight `.archon/` directory to each project containing:

```
.archon/
├── bootstrap.sh           # Main setup script
├── config.env.example     # Template for Supabase credentials
├── docker-compose.yml     # Optional: embedded Archon services
└── mcp-config.json       # Claude Code MCP configuration
```

### Option 2: Global Archon Installation

Install Archon once globally and reference from all projects:

```bash
~/.archon/                 # Global Archon installation
├── archon/               # Your forked Archon repo
├── config/               # Shared configurations
└── bin/                  # Helper scripts
```

## Implementation Plan

### Phase 1: Bootstrap Script Development

Create `archon-bootstrap.sh` that:

```bash
#!/bin/bash

# Configuration
ARCHON_HOME="${ARCHON_HOME:-$HOME/.archon}"
ARCHON_REPO="https://github.com/t851029/archon.git"
ARCHON_VERSION="${ARCHON_VERSION:-main}"

# 1. Check if Archon is installed
if [ ! -d "$ARCHON_HOME/archon" ]; then
    echo "🚀 Installing Archon..."
    mkdir -p "$ARCHON_HOME"
    git clone "$ARCHON_REPO" "$ARCHON_HOME/archon"
    cd "$ARCHON_HOME/archon"
    git checkout "$ARCHON_VERSION"
fi

# 2. Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running. Please start Docker Desktop."
    exit 1
fi

# 3. Check if Archon containers are running
if [ -z "$(docker ps -f "name=archon-server" -f "status=running" -q)" ]; then
    echo "🔄 Starting Archon services..."
    cd "$ARCHON_HOME/archon"
    
    # Copy project-specific .env if exists
    if [ -f "$PROJECT_ROOT/.archon/config.env" ]; then
        cp "$PROJECT_ROOT/.archon/config.env" .env
    fi
    
    docker-compose up -d
    
    # Wait for services to be healthy
    echo "⏳ Waiting for services to start..."
    sleep 5
    
    # Check health
    if curl -s http://localhost:8181/health > /dev/null; then
        echo "✅ Archon is running!"
    else
        echo "⚠️ Archon started but health check failed"
    fi
else
    echo "✅ Archon is already running"
fi

# 4. Display connection info
echo ""
echo "🎯 Archon Access Points:"
echo "   UI: http://localhost:3737"
echo "   API: http://localhost:8181"
echo "   MCP: http://localhost:8051"
```

### Phase 2: NPM/PNPM Integration

Add to any project's `package.json`:

```json
{
  "scripts": {
    "archon:install": "bash .archon/bootstrap.sh install",
    "archon:start": "bash .archon/bootstrap.sh start",
    "archon:stop": "bash .archon/bootstrap.sh stop",
    "archon:status": "bash .archon/bootstrap.sh status",
    "dev": "npm run archon:start && npm run dev:app",
    "postinstall": "npm run archon:check"
  }
}
```

### Phase 3: Environment Configuration

Create `.archon/config.env.example`:

```bash
# Archon Configuration
# Copy to config.env and fill in your values

# Required: Your Supabase credentials
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_SERVICE_KEY=your-service-key-here

# Optional: Custom ports (defaults shown)
ARCHON_UI_PORT=3737
ARCHON_SERVER_PORT=8181
ARCHON_MCP_PORT=8051
ARCHON_AGENTS_PORT=8052

# Optional: Archon installation location
ARCHON_HOME=~/.archon
```

### Phase 4: MCP Configuration Template

Create `.archon/mcp-config.json`:

```json
{
  "archon": {
    "command": "docker",
    "args": ["exec", "-i", "archon-mcp", "python", "-m", "src.mcp.main"],
    "env": {
      "MCP_SERVER_URL": "http://localhost:8051"
    }
  }
}
```

### Phase 5: Cross-Platform Support

#### Windows/WSL2 Detection
```bash
if [[ "$(uname -r)" == *"microsoft"* ]]; then
    echo "Detected WSL2 environment"
    # Use your SSL-fixed fork
    ARCHON_REPO="https://github.com/t851029/archon.git"
fi
```

#### Port Conflict Resolution
```bash
# Check if ports are available
check_port() {
    if lsof -Pi :$1 -sTCP:LISTEN -t >/dev/null ; then
        echo "Port $1 is in use, finding alternative..."
        echo $((RANDOM % 1000 + 8000))
    else
        echo $1
    fi
}

ARCHON_UI_PORT=$(check_port ${ARCHON_UI_PORT:-3737})
ARCHON_SERVER_PORT=$(check_port ${ARCHON_SERVER_PORT:-8181})
```

## Usage Scenarios

### Scenario 1: New Project Setup

```bash
# Clone any project
git clone https://github.com/user/my-claude-project
cd my-claude-project

# Add Archon integration
mkdir .archon
curl -o .archon/bootstrap.sh https://raw.githubusercontent.com/t851029/archon/main/scripts/bootstrap.sh
chmod +x .archon/bootstrap.sh

# Configure
cp .archon/config.env.example .archon/config.env
# Edit config.env with your Supabase credentials

# Start developing
npm install
npm run dev  # Automatically starts Archon
```

### Scenario 2: Existing Project with Archon

```bash
# Clone project that already has .archon/
git clone https://github.com/user/project-with-archon
cd project-with-archon

# One-time setup
cp .archon/config.env.example .archon/config.env
# Edit config.env

# Start developing
npm install
npm run dev  # Archon starts automatically
```

### Scenario 3: Global Archon with Multiple Projects

```bash
# One-time global setup
curl -o ~/install-archon.sh https://raw.githubusercontent.com/t851029/archon/main/scripts/global-install.sh
bash ~/install-archon.sh

# In any project
echo "source ~/.archon/bin/archon-env.sh" >> .envrc
npm run dev  # Uses global Archon instance
```

## Advanced Features

### 1. Auto-Detection of Archon Projects

Add to bootstrap script:
```bash
# Detect if project uses Archon based on CLAUDE.md mentions
if grep -q "archon:" CLAUDE.md 2>/dev/null || grep -q "Archon" .claude/settings.json 2>/dev/null; then
    echo "🔍 Detected Archon-enabled project"
    NEEDS_ARCHON=true
fi
```

### 2. Project-Specific Archon Configuration

Support `.archon/settings.json`:
```json
{
  "autoStart": true,
  "services": ["server", "mcp", "agents"],
  "ports": {
    "ui": 3737,
    "server": 8181
  },
  "knowledgeBase": {
    "autoIndex": ["./docs", "./README.md"],
    "crawlOnStart": ["https://docs.myproject.com"]
  }
}
```

### 3. Docker Compose Extension

For projects wanting embedded Archon:
```yaml
# docker-compose.archon.yml
version: '3.8'

services:
  archon-server:
    extends:
      file: ${ARCHON_HOME}/archon/docker-compose.yml
      service: archon-server
    environment:
      - SUPABASE_URL=${SUPABASE_URL}
      - SUPABASE_SERVICE_KEY=${SUPABASE_SERVICE_KEY}
```

### 4. Health Check Integration

```javascript
// archon-health.js
const checkArchon = async () => {
  try {
    const response = await fetch('http://localhost:8181/health');
    return response.ok;
  } catch {
    console.log('Archon not available, starting...');
    require('child_process').execSync('npm run archon:start');
  }
};
```

## Git Integration

### .gitignore Additions
```
# Archon
.archon/config.env
.archon/logs/
.archon/.cache/
```

### Git Hooks (optional)
```bash
# .git/hooks/post-checkout
#!/bin/bash
if [ -f .archon/bootstrap.sh ]; then
    echo "🔄 Checking Archon setup..."
    .archon/bootstrap.sh check
fi
```

## Benefits

1. **Zero Friction**: Clone and run - Archon handles itself
2. **Portable**: Works across different environments
3. **Flexible**: Can be global or project-specific
4. **Smart**: Detects and reuses existing installations
5. **Safe**: Doesn't interfere with project code
6. **Configurable**: Supports project-specific settings

## Migration Path

For existing projects:
1. Add `.archon/` directory with bootstrap script
2. Update `package.json` with Archon scripts
3. Add configuration template
4. Document in README: "This project uses Archon for knowledge management"

## Next Steps

1. Create the bootstrap script in your Archon fork
2. Test with a sample project
3. Create a template repository with Archon pre-configured
4. Add to Claude Code project templates
5. Create npm package `@archon/cli` for easier installation

---

This approach makes Archon integration seamless - developers just clone and run, while Archon handles all the complexity behind the scenes!