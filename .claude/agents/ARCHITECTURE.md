# Living Tree Agent Architecture (August 2025)

Based on latest Claude Code sub-agent best practices and multi-agent orchestration patterns.

## Agent Tiers

### Tier 1: Orchestrators (Use Task tool primarily)
These agents coordinate work but rarely execute directly:

- **prp-executor-v2** - Smart orchestrator with limited direct execution
  - Tools: `Read, Task, Write, Bash` (Write/Bash only for simple setup)
  - When to use: Executing PRPs

### Tier 2: Specialists (Domain-specific tools)
These agents execute specific types of work:

#### Research Agents (Read-only)
- **codebase-researcher** - Tools: `Read, Grep, Glob, Bash, LS`
- **docs-researcher** - Tools: `WebSearch, WebFetch, mcp__tavily-mcp__*`
- **pattern-analyzer** - Tools: `Read, Grep, mcp__sequential-thinking__*`

#### Creation Agents (Write-heavy)
- **code-generator** - Tools: `Read, Edit, MultiEdit, Write, Bash`
- **test-writer** - Tools: `Read, Write, Edit, Bash`
- **prp-writer** - Tools: `Write, Read, Edit`

#### Validation Agents (Check-heavy)
- **validator** - Tools: `Bash, Read, Grep`
- **prp-quality-agent** - Tools: `Read, Grep, WebFetch, Bash`
- **prp-validation-gate-agent** - Tools: `Bash, Read, Grep, Glob, Task`

#### Utility Agents (Specific tasks)
- **git-operator** - Tools: `Bash` (git commands only)
- **formatter** - Tools: `Bash, Edit`
- **file-organizer** - Tools: `Bash, Write, Read`
- **devops-helper** - Tools: `Bash, Read, Grep` (simple helper)

### Tier 3: Meta Agents (Coordinate other coordinators)
- **sprint-orchestrator** - Tools: `Task` only
  - Coordinates multiple prp-executors for large features

## Orchestration Patterns

### Pattern 1: Simple Task (Direct Execution)
```
User → prp-executor-v2 → Direct execution (file creation, bash)
```

### Pattern 2: Complex Feature (Full Orchestration)
```
User → sprint-orchestrator → [
  prp-executor-v2 → [
    codebase-researcher (parallel)
    docs-researcher (parallel)
  ] → code-generator → test-writer → validator
]
```

### Pattern 3: Quality Gate (Sequential Validation)
```
PRP Created → prp-quality-agent → prp-validation-gate-agent → Ready
```

## Tool Assignment Rules

1. **Minimize Tool Access**: Only give tools absolutely necessary
2. **Read vs Write Separation**: Research agents get read-only tools
3. **Bash Restrictions**: Specify allowed commands in agent prompt
4. **MCP Tool Access**: Only to agents that need external data
5. **Task Tool**: Reserved for orchestrators and meta-validators

## Context Management

- **Orchestrators**: Full PRP context (up to 50k tokens)
- **Specialists**: Isolated context (8k-32k tokens)
- **Parallel Agents**: No shared context (prevents pollution)
- **Sequential Agents**: Can pass context via files

## When to Delegate vs Execute

### Delegate (Use Task) When:
- Task requires specialized knowledge
- Multiple parallel operations needed
- Context isolation is important
- Task involves complex patterns/conventions

### Execute Directly When:
- Simple file/directory operations
- Running existing scripts
- Basic validation checks
- Quick bash commands

## Cost Optimization

```yaml
Model Selection:
  Orchestrators: sonnet (balanced cost/capability)
  Simple Utilities: haiku (cheapest)
  Complex Creation: sonnet
  Critical Validation: opus (only when necessary)
  
Token Usage:
  Research: Parallel agents with small contexts
  Creation: Sequential with context passing
  Validation: Minimal context, focus on diffs
```

## Common Anti-Patterns to Avoid

1. ❌ **Over-Orchestration**: Don't delegate simple mkdir/cat commands
2. ❌ **Tool Overload**: Don't give all tools to all agents
3. ❌ **Context Pollution**: Don't share contexts between parallel agents
4. ❌ **Model Waste**: Don't use Opus for simple tasks
5. ❌ **Missing Validation**: Always include validation agents in workflows

## Implementation Priority

1. Fix prp-executor to use smart delegation (prp-executor-v2)
2. Ensure validators have proper read-only tools
3. Limit bash access in git-operator to git commands only
4. Add context size limits to agent prompts
5. Document which agent to use for common tasks