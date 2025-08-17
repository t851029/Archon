# MCP Tools for Living Tree Development

Leverage Model Context Protocol (MCP) servers to enhance Living Tree development productivity.

## Available MCP Servers

Living Tree has access to these MCP servers:

- **Supabase** - Database operations and management
- **Postgres** - Direct SQL queries and administration
- **Playwright** - Browser automation and E2E testing
- **Tavily** - Web search and research
- **Context7** - Documentation lookup
- **Sequential Thinking** - Step-by-step problem solving

## 1. Supabase MCP Server

### Setup

```bash
# Add Supabase MCP server for staging
claude mcp add supabase -s staging -e SUPABASE_ACCESS_TOKEN=$token -- npx -y @supabase/mcp-server-supabase@latest --read-only --project-ref=fwdfewruzeaplmcezyne

# For production (BE CAREFUL - read-only recommended)
claude mcp add supabase -s production -e SUPABASE_ACCESS_TOKEN=$token -- npx -y @supabase/mcp-server-supabase@latest --read-only --project-ref=zunxilwvjbpkhzrbaxmk
```

### Common Operations

```
# Check table schemas
"Use Supabase MCP to show the schema for email_triage_results table"

# Query data
"Use Supabase MCP to find recent triage results for user X"

# Verify RLS policies
"Use Supabase MCP to list all RLS policies for the auto_drafts table"

# Check database status
"Use Supabase MCP to show database statistics and performance"
```

## 2. Postgres MCP Server

### Setup

```bash
# Local development
claude mcp add postgres-local -- npx -y @modelcontextprotocol/server-postgres 'postgresql://postgres:postgres@localhost:54322/postgres'

# Staging (read-only recommended)
claude mcp add postgres-staging -- npx -y @modelcontextprotocol/server-postgres 'postgresql://postgres:$PASSWORD@db.fwdfewruzeaplmcezyne.supabase.co:5432/postgres'
```

### Common Queries

```sql
-- Check user activity
"Use Postgres MCP to run: SELECT user_id, COUNT(*) as triage_count FROM email_triage_results WHERE created_at > NOW() - INTERVAL '7 days' GROUP BY user_id ORDER BY triage_count DESC LIMIT 10"

-- Debug RLS policies
"Use Postgres MCP to run: SELECT * FROM pg_policies WHERE tablename IN ('email_triage_results', 'auto_drafts')"

-- Performance analysis
"Use Postgres MCP to run: SELECT schemaname, tablename, pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size FROM pg_tables WHERE schemaname = 'public' ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC"
```

## 3. Playwright MCP Server

### E2E Testing Workflows

```
# Start recording session
"Use Playwright MCP to start a code generation session with output to tests/e2e/living-tree"

# Test login flow
"Use Playwright MCP to navigate to http://localhost:3000 and click the Sign In button"

# Test email triage
"Use Playwright MCP to navigate to http://localhost:3000/triage, wait for emails to load, then click Run Triage Analysis"

# Capture screenshots
"Use Playwright MCP to take a full page screenshot of the current state and save as triage-results.png"

# Test responsive design
"Use Playwright MCP to set viewport to 375x667 (iPhone SE) and navigate to http://localhost:3000"
```

### Debugging with Playwright

```
# Check console errors
"Use Playwright MCP to get all console logs of type 'error' from the current page"

# Monitor network requests
"Use Playwright MCP to evaluate: performance.getEntriesByType('resource').filter(r => r.responseStatus >= 400)"

# Test API responses
"Use Playwright MCP to expect a response from **/api/triage/** and then assert it contains success: true"
```

## 4. Tavily MCP Server

### Research and Documentation

```
# Find best practices
"Use Tavily to search for 'Next.js 15 App Router best practices 2024'"

# Debug errors
"Use Tavily to search for 'FastAPI CORS error staging deployment solutions'"

# Research tools
"Use Tavily to find information about Supabase Row Level Security patterns"

# Stay updated
"Use Tavily to search for 'Clerk authentication Next.js 15 integration latest'"
```

### Competitive Analysis

```
# Research similar products
"Use Tavily to search for 'AI email management tools 2024 comparison'"

# Find implementation examples
"Use Tavily to search for 'OpenAI streaming responses FastAPI implementation'"
```

## 5. Context7 MCP Server

### Library Documentation

```
# Get Next.js docs
"Use Context7 to get documentation for Next.js 15 App Router dynamic routes"

# FastAPI patterns
"Use Context7 to find FastAPI dependency injection examples"

# Supabase guides
"Use Context7 to get Supabase Row Level Security documentation"

# React patterns
"Use Context7 to find React 19 server components best practices"
```

### Quick References

```
# Type definitions
"Use Context7 to get TypeScript utility types documentation"

# API references
"Use Context7 to find Clerk JWT validation methods"

# Error solutions
"Use Context7 to find solutions for 'TypeError: Cannot read property of undefined' in React"
```

## 6. Sequential Thinking MCP

### Complex Problem Solving

```
# Debug authentication flow
"Use Sequential Thinking to debug why JWT tokens are failing in production but working in staging"

# Architecture decisions
"Use Sequential Thinking to design a scalable email processing queue for Living Tree"

# Performance optimization
"Use Sequential Thinking to analyze and optimize the email triage performance bottlenecks"

# Migration planning
"Use Sequential Thinking to plan a safe database migration strategy for adding a new feature"
```

## Combining MCP Tools

### Full Feature Testing Workflow

```bash
# 1. Research best practices
"Use Context7 to find testing strategies for Next.js applications"

# 2. Check current test coverage
"Use Postgres MCP to analyze which features have the most user activity"

# 3. Write E2E tests
"Use Playwright MCP to record a complete user journey from login to email triage"

# 4. Debug failures
"Use Sequential Thinking to diagnose why the E2E test fails on CI but passes locally"
```

### Database Performance Analysis

```bash
# 1. Identify slow queries
"Use Postgres MCP to find the slowest queries in the last 24 hours"

# 2. Research optimizations
"Use Tavily to search for PostgreSQL query optimization techniques"

# 3. Test improvements
"Use Supabase MCP to create an index and measure performance impact"

# 4. Document findings
"Use Sequential Thinking to create a performance optimization plan"
```

## MCP Tools Best Practices

### DO's

- ✅ Use read-only mode for production databases
- ✅ Combine tools for comprehensive solutions
- ✅ Save useful queries for reuse
- ✅ Use Sequential Thinking for complex debugging
- ✅ Verify MCP responses with manual checks

### DON'Ts

- ❌ Don't run destructive queries on production
- ❌ Don't share MCP access tokens
- ❌ Don't rely solely on MCP output without verification
- ❌ Don't use Playwright on production without permission
- ❌ Don't ignore rate limits on external services

## Quick MCP Commands Reference

```bash
# List all MCP servers
claude mcp list

# Add a new server
claude mcp add [name] -- [command]

# Remove a server
claude mcp remove [name]

# Test MCP connection
"Use [MCP_NAME] to perform a simple test operation"
```

## Troubleshooting MCP Issues

### Connection Problems

- Verify MCP server is in claude mcp list
- Check environment variables are set
- Ensure proper network access
- Try removing and re-adding the server

### Permission Errors

- Use read-only mode for production
- Verify access tokens are valid
- Check database user permissions
- Ensure CORS is configured for Playwright

### Performance Issues

- Limit query result sizes
- Use pagination for large datasets
- Cache frequently used queries
- Monitor rate limits

Remember: MCP tools are powerful assistants - use them wisely to enhance your Living Tree development workflow!
