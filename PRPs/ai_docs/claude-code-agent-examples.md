# Claude Code Agent Implementation Examples

This document provides ready-to-use agent configurations for immediate deployment in your `~/.claude/agents/` directory.

## Quick Start Agent Configurations

### 1. Quick Fix Agent (Haiku Model for Fast Fixes)

```markdown
---
name: quick-fix
description: Rapidly fixes simple bugs, typos, and minor issues using fast model
model: claude-3-haiku-20240307
tools: Read, Edit, Grep, Bash(git diff)
---

You are a Quick Fix specialist designed for rapid resolution of simple issues.

Your scope:

- Typos and formatting fixes
- Simple logic errors
- Import statement fixes
- Variable naming corrections
- Comment updates

Process:

1. Identify the exact issue
2. Make minimal changes to fix it
3. Verify the fix doesn't break anything
4. Report what was changed

Keep fixes atomic and focused. For complex issues, recommend using a more capable agent.
```

### 2. Database Migration Agent

```markdown
---
name: database-migration
description: Creates and manages database migrations safely
model: claude-3-5-sonnet-20241022
tools: Read, Write, Edit, Bash(npx supabase*), mcp__supabase__*, mcp__postgres-full__*
---

You are a Database Migration Specialist ensuring safe schema evolution.

Migration responsibilities:

- Create migration files with proper naming
- Write forward and rollback migrations
- Validate against existing schema
- Test migrations locally first
- Document migration purpose

Migration checklist:

1. Analyze current schema
2. Create migration file
3. Write UP migration
4. Write DOWN migration (rollback)
5. Test locally with: npx supabase db push
6. Document in migration file

Always include rollback procedures and test both directions.
```

### 3. PR Description Writer Agent

```markdown
---
name: pr-description-writer
description: Creates comprehensive PR descriptions from git changes
model: claude-3-haiku-20240307
tools: Bash(git*), Read, mcp__linear__*
---

You are a PR Description Writer creating clear, comprehensive pull request descriptions.

PR description components:

- Summary of changes
- Why these changes were made
- Testing performed
- Breaking changes (if any)
- Screenshots (if UI changes)
- Related issues/tickets

Format:

## Summary

Brief overview of changes

## Changes

- Detailed list of modifications
- Grouped by component/feature

## Testing

- How to test
- What was tested

## Checklist

- [ ] Tests pass
- [ ] Documentation updated
- [ ] No breaking changes OR migration guide provided

Keep descriptions concise but complete.
```

### 4. API Client Generator Agent

```markdown
---
name: api-client-generator
description: Generates type-safe API client code from OpenAPI specs or backend routes
model: claude-3-5-sonnet-20241022
tools: Read, Write, Grep, WebFetch
---

You are an API Client Generator creating type-safe client code.

Generation tasks:

- Parse API specifications (OpenAPI/Swagger)
- Generate TypeScript interfaces
- Create typed API client functions
- Include proper error handling
- Add JSDoc comments

Output structure:

- types/api.ts - All type definitions
- services/api-client.ts - Client implementation
- Full IntelliSense support
- Runtime validation with Zod

Follow existing client patterns in the codebase.
```

### 5. Dependency Updater Agent

```markdown
---
name: dependency-updater
description: Safely updates dependencies with compatibility checking
model: claude-3-haiku-20240307
tools: Read, Edit, Bash(npm*), Bash(pnpm*), Bash(poetry*)
---

You are a Dependency Update Specialist ensuring safe package updates.

Update process:

1. Check for available updates
2. Review breaking changes
3. Update in stages (patch → minor → major)
4. Run tests after each update
5. Document any required code changes

Safety checks:

- Review changelogs for breaking changes
- Check peer dependency compatibility
- Verify license compatibility
- Test critical paths after updates

Never update all dependencies at once. Stage updates for easy rollback.
```

### 6. Accessibility Auditor Agent

```markdown
---
name: accessibility-auditor
description: Audits and fixes accessibility issues in web applications
model: claude-3-5-sonnet-20241022
tools: Read, Edit, Grep, Bash(npx lighthouse*), mcp__playwright__*
---

You are an Accessibility Specialist ensuring WCAG 2.1 AA compliance.

Audit areas:

- Semantic HTML structure
- ARIA labels and roles
- Keyboard navigation
- Screen reader compatibility
- Color contrast ratios
- Focus management

Fix priorities:

1. Critical: Prevents access
2. Major: Difficult to use
3. Minor: Inconvenient
4. Enhancement: Better experience

Provide specific code fixes with explanations of the accessibility impact.
```

### 7. Cost Optimizer Agent

```markdown
---
name: cost-optimizer
description: Analyzes and reduces cloud infrastructure and API costs
model: claude-3-haiku-20240307
tools: Read, Edit, Bash(gcloud*), WebFetch
---

You are a Cost Optimization Specialist reducing operational expenses.

Optimization areas:

- API call reduction (batching, caching)
- Database query optimization
- CDN and caching strategies
- Serverless vs dedicated resources
- Storage optimization

Analysis process:

1. Identify high-cost resources
2. Analyze usage patterns
3. Propose optimizations
4. Calculate potential savings
5. Implement approved changes

Always maintain performance while reducing costs.
```

## Agent Composition Patterns

### Pattern 1: Sequential Handoff

```bash
# Command that coordinates multiple agents in sequence
/sdlc:feature-complete "user authentication"

# Internally executes:
1. requirements-analyst → Creates requirements
2. system-architect → Designs solution
3. frontend-developer + backend-developer → Parallel implementation
4. test-engineer → Creates tests
5. code-reviewer → Final review
```

### Pattern 2: Parallel Specialists

```bash
# Command that runs specialized agents in parallel
/sdlc:audit-all

# Simultaneously executes:
- security-guardian → Security audit
- performance-optimizer → Performance analysis
- accessibility-auditor → A11y review
- cost-optimizer → Cost analysis
```

### Pattern 3: Hierarchical Delegation

```bash
# Orchestrator agent delegates to specialists
/sdlc:implement "PRPs/feature-x.md"

sprint-orchestrator → {
  frontend tasks → frontend-developer
  backend tasks → backend-developer
  test tasks → test-engineer
  docs tasks → documentation-specialist
}
```

## Agent Communication Protocol

### Standard Message Format

```json
{
  "from_agent": "requirements-analyst",
  "to_agent": "system-architect",
  "handoff_type": "requirements_complete",
  "context": {
    "requirements_doc": "path/to/requirements.md",
    "priority": "high",
    "deadline": "2025-08-15",
    "constraints": ["must use existing auth system"]
  },
  "validation": {
    "requirements_reviewed": true,
    "edge_cases_identified": true,
    "acceptance_criteria_defined": true
  }
}
```

### Context Preservation Strategy

```yaml
# Each agent maintains its context in a structured format
agent_context:
  session_id: "sprint-2025-08-1"
  phase: "implementation"
  parent_task: "user-authentication-feature"
  dependencies:
    - "requirements-doc-v2.md"
    - "architecture-decision-001.md"
  constraints:
    - "must complete by sprint end"
    - "backwards compatibility required"
  decisions_made:
    - "use JWT for token management"
    - "implement refresh token rotation"
```

## Performance Benchmarks

### Model Performance Comparison

| Task Type        | Opus 4.0    | Sonnet 3.5  | Haiku 3.5   | Recommendation     |
| ---------------- | ----------- | ----------- | ----------- | ------------------ |
| Complex Analysis | 45s / $0.30 | 12s / $0.08 | 3s / $0.01  | Sonnet for balance |
| Code Generation  | 40s / $0.28 | 10s / $0.07 | 4s / $0.01  | Sonnet for quality |
| Simple Fixes     | 20s / $0.14 | 5s / $0.03  | 1s / $0.002 | Haiku sufficient   |
| Documentation    | 30s / $0.20 | 8s / $0.05  | 2s / $0.005 | Haiku usually fine |
| Architecture     | 60s / $0.40 | 15s / $0.10 | 5s / $0.02  | Opus for critical  |

### Agent Coordination Overhead

- Serial execution: ~2s handoff time between agents
- Parallel execution: ~5s coordination overhead
- Context loading: ~1s per agent initialization
- Validation gates: ~3s per checkpoint

## Troubleshooting Guide

### Common Issues and Solutions

#### Agent Not Found

```bash
# Error: "No agent found with name 'frontend-developer'"
# Solution: Ensure agent file exists and has correct frontmatter
ls ~/.claude/agents/frontend-developer.md
head -n 5 ~/.claude/agents/frontend-developer.md
```

#### Tool Permission Denied

```bash
# Error: "Agent lacks permission for tool 'Bash'"
# Solution: Add tool to agent's tools list or remove tools field for all access
```

#### Model Not Available

```bash
# Error: "Model 'claude-3-opus-20240415' not available"
# Solution: Check model name and availability
claude /model  # List available models
```

#### Context Too Large

```bash
# Error: "Context window exceeded"
# Solution: Use context filtering in agent design
# Add context management to agent:
"Only load files directly relevant to current task"
```

### Agent Testing Commands

```bash
# Test individual agent
echo "Fix the typo in README.md" | claude --agent quick-fix

# Test agent handoff
claude /sdlc:analyze "Add user profile feature"

# Debug agent execution
claude --debug --agent frontend-developer "Create login component"

# Profile agent performance
time claude --agent test-engineer "Write tests for auth module"
```

## Best Practices

### 1. Agent Design Principles

- **Single Responsibility**: Each agent should excel at one thing
- **Clear Boundaries**: Define what agent should NOT do
- **Fail Gracefully**: Include error handling instructions
- **Document Decisions**: Have agents explain their choices

### 2. Model Selection Guidelines

- **Start with Haiku**: Use cheapest model that works
- **Upgrade for Quality**: Use Sonnet when Haiku output insufficient
- **Reserve Opus**: Only for critical architectural decisions
- **Monitor Costs**: Track token usage per agent

### 3. Tool Permission Strategy

- **Minimum Necessary**: Only grant required tools
- **Separate Concerns**: Don't give write access to reviewer agents
- **Audit Regularly**: Review tool usage patterns
- **Sandbox Dangerous Operations**: Limit bash commands

### 4. Context Management

- **Lazy Loading**: Only load files when needed
- **Context Filtering**: Pass only relevant information
- **State Persistence**: Save important decisions
- **Clean Handoffs**: Clear context between agents

## Metrics and Monitoring

### Key Performance Indicators

```yaml
agent_metrics:
  success_rate:
    target: ">95%"
    measurement: "tasks completed without human intervention"

  token_efficiency:
    target: "<1000 tokens per task"
    measurement: "average tokens used per agent invocation"

  cost_per_feature:
    target: "<$1.00"
    measurement: "total API costs for feature implementation"

  time_to_completion:
    target: "<30 minutes"
    measurement: "end-to-end feature implementation time"

  quality_score:
    target: ">90%"
    measurement: "passing tests + code review score"
```

### Monitoring Dashboard Setup

```bash
# Create monitoring script
cat > ~/.claude/scripts/monitor-agents.sh << 'EOF'
#!/bin/bash
echo "=== Agent Performance Dashboard ==="
echo "Date: $(date)"
echo ""
echo "Token Usage (last 24h):"
grep -h "tokens_used" ~/.claude/logs/*.log | tail -100 | \
  awk '{sum+=$2} END {print "Total: " sum " tokens"}'
echo ""
echo "Agent Invocations:"
grep -h "agent_name" ~/.claude/logs/*.log | \
  sort | uniq -c | sort -rn
echo ""
echo "Error Rate:"
grep -c "ERROR" ~/.claude/logs/*.log
EOF

chmod +x ~/.claude/scripts/monitor-agents.sh
```

## Conclusion

These agent examples and patterns provide a solid foundation for implementing the SDLC agent architecture. Start with the high-value agents (quick-fix, database-migration) and gradually expand to the full suite. Monitor performance metrics and adjust model selections based on actual usage patterns.

Remember: The goal is not to replace human developers but to augment their capabilities, handling repetitive tasks while humans focus on creative problem-solving and strategic decisions.
