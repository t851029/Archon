# Archon Setup Progress

**Date**: August 16, 2025
**Status**: Database Setup Complete, Docker Build Pending

## Overview
Successfully set up Archon knowledge management system with Supabase backend. Database is fully configured and ready for use. Docker container builds are blocked by WSL network/SSL issues.

## Completed Tasks ✅

### 1. Supabase Project Creation
- **Organization**: t851029 (free tier)
- **Project Name**: Archon
- **Project ID**: `nommkpcngfvtkttfvrxw`
- **Region**: us-west-1
- **Status**: ACTIVE_HEALTHY
- **Created**: 2025-08-16T23:30:31.509447Z

### 2. Database Configuration
Successfully applied complete database migration including:
- **Extensions**: vector, pgcrypto
- **Core Tables**:
  - `archon_settings` - Configuration and encrypted credentials
  - `archon_sources` - Knowledge source metadata
  - `archon_crawled_pages` - Document chunks with embeddings
  - `archon_code_examples` - Extracted code with summaries
  - `archon_projects` - Project management
  - `archon_tasks` - Task tracking with soft delete
  - `archon_project_sources` - Project-source relationships
  - `archon_document_versions` - Version control for JSONB fields
  - `archon_prompts` - Agent system prompts

- **Search Functions**:
  - `match_archon_crawled_pages()` - Vector similarity search
  - `match_archon_code_examples()` - Code example search
  - `archive_task()` - Soft delete functionality

- **Initial Settings**:
  - RAG strategy configurations
  - Code extraction settings
  - Performance tuning parameters
  - MCP transport settings
  - Default prompts for document, feature, and data builders

### 3. Environment Configuration
`.env` file configured with:
```env
SUPABASE_URL=https://nommkpcngfvtkttfvrxw.supabase.co
SUPABASE_SERVICE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
HOST=localhost
ARCHON_SERVER_PORT=8181
ARCHON_MCP_PORT=8051
ARCHON_AGENTS_PORT=8052
ARCHON_UI_PORT=3737
ARCHON_DOCS_PORT=3838
EMBEDDING_DIMENSIONS=1536
```

## Pending Tasks ⚠️

### Docker Container Build Issue
**Problem**: SSL/TLS errors during Docker build on WSL
```
ERROR: failed to copy: local error: tls: bad record MAC
ssl.SSLError: [SSL] record layer failure (_ssl.c:2590)
```

**Root Cause**: Known WSL2 network/SSL issue affecting Docker builds

## Resolution Options

### Option 1: Fix WSL Network
```bash
# Restart Docker service
sudo service docker restart

# Clear Docker cache and rebuild
docker system prune -a
docker-compose build --no-cache
docker-compose up -d
```

### Option 2: WSL Network Reset
```bash
# In Windows PowerShell (Admin)
wsl --shutdown
netsh winsock reset
netsh int ip reset
# Restart WSL and try again
```

### Option 3: Local Development (No Docker)
```bash
# Backend services
cd python
pip install -r requirements.server.txt
pip install -r requirements.mcp.txt
pip install -r requirements.agents.txt

# Run servers
python -m src.server.main  # Port 8181
python -m src.mcp.main     # Port 8051
python -m src.agents.main  # Port 8052

# Frontend
cd ../archon-ui-main
npm install
npm run dev  # Port 3737
```

### Option 4: Alternative Docker Build
```bash
# Disable BuildKit
export DOCKER_BUILDKIT=0
export COMPOSE_DOCKER_CLI_BUILD=0

# Try with legacy builder
docker-compose up --build -d
```

## Access Points

### Supabase Dashboard
- **URL**: https://supabase.com/dashboard/project/nommkpcngfvtkttfvrxw
- **API Settings**: https://supabase.com/dashboard/project/nommkpcngfvtkttfvrxw/settings/api
- **Database**: PostgreSQL 17.4.1.074

### Local Services (Once Running)
- **Web UI**: http://localhost:3737
- **API Server**: http://localhost:8181
- **MCP Server**: http://localhost:8051
- **Agents Service**: http://localhost:8052

## Next Steps

1. **Resolve Docker Build**
   - Try network reset options
   - Consider local development as fallback

2. **Complete Configuration**
   - Access UI at http://localhost:3737
   - Navigate to Settings
   - Add OpenAI API key for embeddings
   - Configure LLM provider preferences

3. **Initial Testing**
   - Crawl a documentation website
   - Upload a PDF document
   - Create a test project
   - Connect MCP client (Claude Code, Cursor, etc.)

## MCP Integration

Once services are running, connect your AI coding assistant:

### Claude Code
```json
{
  "mcpServers": {
    "archon": {
      "url": "http://localhost:8051",
      "transport": "sse"
    }
  }
}
```

### Available MCP Tools
- `archon:perform_rag_query` - Search knowledge base
- `archon:search_code_examples` - Find code snippets
- `archon:manage_project` - Project operations
- `archon:manage_task` - Task management
- `archon:get_available_sources` - List knowledge sources

## Configuration Notes

### Required API Keys
- **OpenAI API Key**: For text-embedding-3-small model (required)
- **Optional**: Google API Key (for Gemini), Logfire Token (for monitoring)

### Default Settings
- **RAG Strategy**: Hybrid search enabled, reranking enabled
- **Code Extraction**: Enabled with AI summaries
- **Projects**: Enabled by default
- **MCP Transport**: Dual mode (SSE + stdio)

## Troubleshooting

### If Docker continues to fail:
1. Check WSL2 version: `wsl --version`
2. Update WSL2: `wsl --update`
3. Check Docker Desktop WSL2 integration
4. Consider using Docker Desktop's Linux containers directly

### Database Connection Issues:
- Verify Supabase project is active
- Check service key is correct
- Ensure no firewall blocking outbound connections

## Files Modified
- `/home/gwizz/wsl_projects/Archon/.env` - Added Supabase credentials
- Database tables created via migration

## Resources
- [Archon GitHub](https://github.com/coleam00/archon)
- [Supabase Docs](https://supabase.com/docs)
- [MCP Protocol](https://modelcontextprotocol.io)