# Living Tree Knowledge Base Setup for Archon

## Overview

This document outlines the recommended Archon knowledge base configuration to support the Living Tree project - a Next.js 15 + FastAPI monorepo with Supabase, Clerk Auth, and AI capabilities.

## ✅ Archon Capability Validation

Based on Archon's features, all recommended approaches are fully supported:

- **Web Crawling**: ✅ Supports documentation sites with automatic sitemap detection
- **Document Upload**: ✅ Handles PDFs, Word docs, Markdown files
- **Code Extraction**: ✅ Automatically identifies and indexes code examples
- **Project Management**: ✅ Hierarchical projects with features and tasks
- **MCP Integration**: ✅ 10 MCP tools for RAG queries and task management
- **Tagging System**: ✅ Organize by source, type, and custom tags

## 📚 Phase 1: Core Documentation Crawling

### Priority 1 - Essential Framework Docs
```bash
# Crawl these documentation sites first (via Archon UI → Knowledge Base → Crawl Website)
https://nextjs.org/docs                 # Next.js 15 with App Router
https://fastapi.tiangolo.com/          # FastAPI backend patterns
https://supabase.com/docs               # Database and RLS
https://clerk.com/docs                  # Authentication and JWT
```

### Priority 2 - Build & Deployment Tools
```bash
https://turbo.build/repo/docs           # Turborepo monorepo management
https://vercel.com/docs                 # Deployment platform
https://cloud.google.com/secret-manager/docs  # Secret management
https://cloud.google.com/run/docs       # Backend deployment
```

### Priority 3 - Supporting Libraries
```bash
https://sdk.vercel.ai/docs              # Vercel AI SDK for streaming
https://ui.shadcn.com/docs              # Component library
https://python-poetry.org/docs/         # Python dependency management
https://docs.pydantic.dev/latest/       # Data validation
```

## 📄 Phase 2: Project Documentation Upload

Upload these Living Tree files to Archon (Knowledge Base → Upload Documents):

### Core Project Files
- `/home/gwizz/wsl_projects/living-tree/CLAUDE.md` - Main project context
- `/home/gwizz/wsl_projects/living-tree/README.md` - Project overview
- `/home/gwizz/wsl_projects/living-tree/DEPLOYMENT.md` - Deployment procedures
- `/home/gwizz/wsl_projects/living-tree/TROUBLESHOOTING.md` - Common issues
- `/home/gwizz/wsl_projects/living-tree/ENV_SETUP.md` - Environment setup

### Architecture Documentation
Upload all files from:
- `/home/gwizz/wsl_projects/living-tree/docs/architecture/`
- `/home/gwizz/wsl_projects/living-tree/docs/environments/`
- `/home/gwizz/wsl_projects/living-tree/docs/development/`
- `/home/gwizz/wsl_projects/living-tree/docs/api-reference/`

## 🏗️ Phase 3: Project Structure Creation

Create this project hierarchy in Archon (Projects → Create Project):

```yaml
Project: "Living Tree - AI Productivity Platform"
Description: "Next.js 15 + FastAPI monorepo with email triage, chat, and MCP tools"
GitHub Repo: "https://github.com/living-tree-app/living-tree"

Features:
  - name: "Authentication & Security"
    tasks:
      - "Implement Clerk JWT validation in FastAPI"
      - "Configure Gmail OAuth through Clerk"
      - "Set up Supabase RLS with text-based user IDs"
      - "Handle Clerk webhook events"
      
  - name: "Email Triage System"
    tasks:
      - "Build AI-powered email prioritization"
      - "Create triage dashboard UI"
      - "Implement real-time email processing"
      - "Add auto-draft generation"
      
  - name: "Chat Interface"
    tasks:
      - "Implement streaming AI responses"
      - "Integrate MCP tools"
      - "Build chat history management"
      - "Add context awareness"
      
  - name: "Infrastructure & DevOps"
    tasks:
      - "Set up database migration workflow"
      - "Configure Google Secret Manager"
      - "Implement multi-environment deployment"
      - "Set up Docker builds with Poetry"
      
  - name: "Monorepo Management"
    tasks:
      - "Configure Turborepo pipelines"
      - "Set up shared packages"
      - "Implement type generation workflow"
      - "Configure pnpm workspaces"
```

## 🏷️ Phase 4: Tagging Strategy

Apply these tags to organize content:

### Technology Tags
- `#nextjs15` - Next.js 15 specific patterns
- `#fastapi` - Python backend
- `#turborepo` - Monorepo management
- `#supabase` - Database and RLS
- `#clerk-auth` - Authentication
- `#docker` - Containerization
- `#gcp` - Google Cloud Platform

### Feature Tags
- `#email-triage` - Email management features
- `#chat-interface` - Chat functionality
- `#mcp-tools` - Model Context Protocol
- `#oauth` - OAuth integrations

### Environment Tags
- `#local-dev` - Local development
- `#staging` - Staging environment
- `#production` - Production environment

## 🔍 Phase 5: Code Pattern Search

Use Archon's search to find and save these patterns:

### Next.js 15 Patterns
- "Next.js 15 dynamic route Promise params"
- "App Router streaming responses"
- "Server Components data fetching"
- "Turbopack configuration"

### FastAPI Patterns
- "FastAPI JWT validation middleware"
- "Streaming responses with SSE"
- "Pydantic v2 validation"
- "Async request handlers"

### Integration Patterns
- "Clerk webhook validation"
- "Supabase RLS with custom user IDs"
- "Google Secret Manager integration"
- "Docker multi-stage builds Poetry"

## 🤖 Phase 6: MCP Tool Usage

Once set up, use these MCP tools in Claude Code:

```javascript
// Search Living Tree knowledge
archon:perform_rag_query("Next.js 15 Promise params pattern")
archon:perform_rag_query("Clerk JWT validation FastAPI")

// Find code examples
archon:search_code_examples("Supabase RLS text user_id")
archon:search_code_examples("Poetry Docker multi-stage")

// Manage tasks
archon:manage_task(action="list", filter_by="feature", filter_value="Email Triage System")
archon:manage_task(action="update", task_id="...", update_fields={status: "in_progress"})

// Get available sources
archon:get_available_sources()
```

## 📊 Expected Outcomes

After completing this setup:

1. **Instant Context**: Access all Living Tree patterns without searching files
2. **Smart Suggestions**: AI-powered recommendations based on your knowledge base
3. **Task Tracking**: Organized workflow with clear priorities
4. **Pattern Library**: Reusable code examples for common tasks
5. **Error Solutions**: Quick access to troubleshooting guides

## 🚀 Implementation Timeline

- **Day 1**: Crawl essential docs (Priority 1) and upload project files
- **Day 2**: Create project structure and crawl remaining docs
- **Day 3**: Search for code patterns and tag everything
- **Ongoing**: Add new patterns and update tasks as development progresses

## 💡 Pro Tips

1. **Start Small**: Begin with Next.js and FastAPI docs, then expand
2. **Use Groups**: Group related sources (e.g., "Living Tree Core", "Deployment Docs")
3. **Update Regularly**: Re-crawl docs monthly to stay current
4. **Link Tasks to Sources**: Connect tasks to relevant documentation
5. **Export Patterns**: Save frequently used code snippets as separate documents

## 🔧 Maintenance

Weekly tasks:
- Review and update task statuses
- Add new documentation as discovered
- Tag new code patterns
- Archive completed tasks

Monthly tasks:
- Re-crawl documentation sites for updates
- Review and consolidate duplicate patterns
- Update project features based on progress

## Success Metrics

- ✅ All core documentation indexed
- ✅ Project files uploaded and tagged
- ✅ Task structure mirrors development workflow
- ✅ MCP tools return relevant results
- ✅ Development speed increased through instant context access

---

This knowledge base configuration will transform how you work with the Living Tree project, providing instant access to all necessary context through Archon's powerful MCP integration!