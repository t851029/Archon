# Living Tree Claude Code Commands

This directory contains the complete set of Claude Code commands for the Living Tree project. These commands combine general software engineering best practices with Living Tree-specific patterns, multi-environment workflows, and integrated tooling.

## Command Categories

### 🚀 Core Development Commands

Essential commands enhanced with Living Tree context:

- **`prime-core.md`** - Initialize Claude Code with Living Tree project context, env checks, and MCP verification
- **`onboarding.md`** - Comprehensive onboarding for new Living Tree developers with project-specific setup
- **`debug.md`** - Debug issues with Living Tree-specific strategies for multi-environment problems
- **`validate-code.md`** - Run complete validation suite including types, lint, tests, and Docker builds
- **`review-general.md`** - Code review with Living Tree patterns, conventions, and multi-env considerations
- **`review-staged-unstaged.md`** - Review staged/unstaged changes with git diff analysis

### 🌍 Environment & Deployment Commands

Living Tree specific environment management:

- **`env-check.md`** - Comprehensive validation of all environments (local, staging, production)
- **`deploy-staging.md`** - Safe staging deployment workflow with validation and rollback procedures
- **`migrate-db.md`** - Database migration management across all Supabase environments
- **`troubleshoot-common.md`** - Quick fixes for the most common Living Tree development issues

### 🧪 Testing Commands

Comprehensive testing workflows:

- **`test-e2e.md`** - End-to-end testing using Playwright MCP and Living Tree test patterns
- **`validate-code.md`** - Type checking, linting, and test execution for the monorepo

### 🛠️ Tool Integration Commands

Leverage Living Tree's tool ecosystem:

- **`mcp-tools.md`** - How to use MCP servers (Supabase, Postgres, Playwright, Tavily, Context7)
- **`create-pr.md`** - Create pull requests with proper formatting and conventions

### 📋 Planning & Documentation Commands

Project planning and documentation:

- **`prd.md`** - Create Product Requirements Documents
- **`planning-create.md`** - Create detailed implementation plans
- **`create-base-prp.md`** - Create base PRP (Plan, Review, Progress) documents
- **`execute-prp.md`** - Execute PRP-based workflows
- **`generate-prp.md`** - Generate comprehensive PRPs
- **`spec-create-adv.md`** - Create advanced technical specifications
- **`spec-execute.md`** - Execute specification-based implementations

### 🔧 Refactoring & Resolution Commands

Code improvement and conflict resolution:

- **`refactor-simple.md`** - Simple refactoring workflows
- **`conflict-resolver-general.md`** - Resolve general merge conflicts
- **`conflict-resolver-specific.md`** - Resolve specific file conflicts
- **`smart-resolver.md`** - Intelligent conflict resolution strategies

## Quick Start Guide

### Daily Development Workflow

```bash
# Start your day
/prime-core              # Load Living Tree project context
/env-check               # Verify all environments are configured
pnpm dev:full            # Start all services

# During development
/validate-code           # Check types, lint, run tests
/debug "error message"   # Debug specific issues
/troubleshoot-common     # Fix common problems quickly

# Before commits
/review-general          # Review your changes
/validate-code           # Final validation
git commit               # Commit with confidence

# Testing
/test-e2e                # Run comprehensive E2E tests
```

### Deployment Workflow

```bash
# Prepare for staging
/validate-code           # Ensure code quality
/migrate-db check        # Check migration status
/deploy-staging          # Deploy to staging environment

# After staging verification
/create-pr --base main   # Create PR for production
```

### Using MCP Tools

```bash
# Database operations
/mcp-tools               # See all available MCP operations
"Use Supabase MCP to check email_triage_results schema"
"Use Postgres MCP to analyze query performance"

# Testing with Playwright
"Use Playwright MCP to test the login flow"
"Use Playwright MCP to capture screenshots of triage dashboard"

# Research and documentation
"Use Tavily to search for Next.js 15 best practices"
"Use Context7 to get FastAPI documentation"
```

## Command Structure

Each command follows a consistent structure:

1. **Purpose** - Clear description of what the command does
2. **Quick Check/Start** - Fast validation or immediate actions
3. **Detailed Steps** - Comprehensive workflow with examples
4. **Common Issues** - Troubleshooting guidance
5. **Living Tree Context** - Project-specific patterns and considerations

## Key Project Information

### Environments

- **Local**: http://localhost:3000 (frontend), http://localhost:8000 (backend)
- **Staging**: https://staging.livingtree.io
- **Production**: https://app.livingtree.io

### Tech Stack

- **Frontend**: Next.js 15, React 19, TypeScript, Tailwind CSS, shadcn/ui
- **Backend**: FastAPI, Python 3.11+, Poetry, Pydantic v2
- **Database**: Supabase (PostgreSQL with RLS)
- **Auth**: Clerk (JWT-based)
- **AI**: OpenAI GPT-4o, Vercel AI SDK
- **Infrastructure**: Vercel (frontend), Google Cloud Run (backend)

### Available MCP Servers

- Supabase - Database operations
- Postgres - Direct SQL queries
- Playwright - Browser automation
- Tavily - Web search
- Context7 - Documentation lookup
- Sequential Thinking - Complex problem solving

## Best Practices

1. **Always start with `/prime-core`** to load project context
2. **Run `/env-check` before development** to catch configuration issues
3. **Use `/validate-code` before all commits** to maintain code quality
4. **Test with `/test-e2e` before deployments** to ensure functionality
5. **Follow staging → production workflow** for safe deployments
6. **Keep CLAUDE.md files updated** with new patterns and gotchas
7. **Leverage MCP tools** for enhanced productivity

## Command Aliases

Some commands support aliases for convenience:

- `/prime` → `/prime-core`
- `/ec` → `/env-check`
- `/debug` → `/debug`
- `/validate` → `/validate-code`
- `/review` → `/review-general`

## Contributing New Commands

When adding new commands:

1. Follow the existing command structure
2. Include Living Tree specific context
3. Consider multi-environment implications
4. Document common issues and solutions
5. Update this README with the new command
6. Test the command in real scenarios

## Emergency Commands

For critical situations:

- `/troubleshoot-common` - Fix port conflicts and common issues
- `/env-check` - Diagnose environment problems
- `/migrate-db rollback` - Rollback database changes
- `/debug` - Systematic debugging approach

Remember: These commands are designed to make Living Tree development faster, more consistent, and safer across all environments!
