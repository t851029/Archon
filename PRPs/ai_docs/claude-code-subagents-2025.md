# Claude Code Subagents Documentation (August 2025)

## Overview

Claude Code subagents represent a paradigm shift in AI-assisted development, transforming Claude Code from a single AI assistant into a coordinated team of specialized AI experts. Introduced in July 2025, this feature enables complex workflows through task delegation, parallel execution, and context isolation.

## Key Concepts

### What Are Subagents?

Subagents are specialized AI team members that:

- **Operate independently** with their own context windows
- **Focus on specific domains** (backend, security, testing, etc.)
- **Execute in parallel** for complex tasks
- **Preserve main context** while handling delegated work

### Why Use Subagents?

1. **Context Management**: Each agent has its own context window, preventing pollution
2. **Specialized Expertise**: Agents can be optimized for specific tasks
3. **Parallel Execution**: Multiple agents work simultaneously
4. **Model Optimization**: Use appropriate models for task complexity (Haiku for simple, Opus for complex)
5. **Workflow Automation**: Automatic delegation based on task requirements

## Configuration Structure

### Basic Subagent Definition

```markdown
---
name: subagent-name
description: When this subagent should be invoked (be specific and action-oriented)
tools: tool1, tool2, tool3 # Optional - inherits all tools if omitted
model: sonnet # Optional - sonnet, opus, haiku
color: green # Optional - for visual organization
---

System prompt defining the subagent's role, capabilities, and behavior.
Include specific instructions, best practices, and constraints.
```

### Configuration Fields

| Field         | Required | Description                            | Example                          |
| ------------- | -------- | -------------------------------------- | -------------------------------- |
| `name`        | Yes      | Unique identifier (lowercase, hyphens) | `backend-architect`              |
| `description` | Yes      | When/why to invoke                     | `Use PROACTIVELY for API design` |
| `tools`       | No       | Comma-separated tool list              | `Read, Edit, Bash`               |
| `model`       | No       | Model selection                        | `sonnet`, `opus`, `haiku`        |
| `color`       | No       | Visual organization                    | `green`, `blue`, `red`           |

## File Locations & Priority

1. **Project-Level** (`.claude/agents/`) - Highest priority, shared with team
2. **User-Level** (`~/.claude/agents/`) - Personal productivity agents

## Creating Subagents

### Method 1: Interactive Creation (Recommended)

```bash
/agents
```

Opens an interactive interface for creating, editing, and managing subagents.

### Method 2: Direct File Creation

```bash
mkdir -p .claude/agents
cat > .claude/agents/code-reviewer.md << 'EOF'
---
name: code-reviewer
description: Use PROACTIVELY to review code changes for quality, security, and maintainability
tools: Read, Grep, Glob, Bash
model: sonnet
---

You are a senior code reviewer ensuring high standards...
EOF
```

## Model Selection Strategy

### Opus (High Complexity)

- Complex system design
- Security audits
- Performance optimization
- Incident response

### Sonnet (Medium Complexity)

- Code review
- Test automation
- Bug fixes
- UI implementation

### Haiku (Routine Tasks)

- Documentation
- Code formatting
- File organization
- Simple refactoring

## Orchestration Patterns

### Sequential Workflow

```
User Request → Agent A → Agent B → Agent C → Result
Example: backend-architect → security-auditor → test-automator
```

### Parallel Execution

```
User Request → Agent A + Agent B (simultaneously) → Merge Results
Example: performance-engineer + database-optimizer → Combined optimization
```

### Conditional Branching

```
debugger (analyzes) → Routes to: backend-architect OR devops-troubleshooter
```

## Best Practices

### Design Principles

1. **Single Responsibility**: One focus area per agent
2. **Clear Descriptions**: Enable automatic delegation
3. **Tool Limitation**: Grant only necessary tools
4. **Version Control**: Check project agents into Git

### Performance Considerations

1. **Latency Trade-off**: Clean slate adds initial overhead
2. **Rate Limiting**: Parallel agents consume quota faster
3. **Optimal Scaling**: 4-6 parallel agents recommended
4. **Context Gathering**: Allow time for state understanding

### Security Guidelines

1. **Tool Access**: Limit tools to required minimum
2. **File Access**: Restrict sensitive file access
3. **Validation**: Include security checks in workflows
4. **Audit Trail**: Log all agent actions

## Production Examples

### Code Reviewer

```markdown
---
name: code-reviewer
description: Expert code review specialist. Use PROACTIVELY after code modifications.
tools: Read, Grep, Glob, Bash
model: sonnet
---

You are a senior code reviewer ensuring high standards.

When invoked:

1. Run git diff to see recent changes
2. Focus on modified files
3. Begin review immediately

Review checklist:

- Code simplicity and readability
- Proper naming conventions
- No code duplication
- Error handling implemented
- No exposed secrets
- Input validation present
- Test coverage adequate
- Performance optimized
```

### Performance Engineer

```markdown
---
name: performance-engineer
description: Performance optimization specialist for bottlenecks and scaling issues.
tools: Bash, Read, Edit, Grep
model: opus
---

You specialize in:

1. Profiling & Analysis
2. Optimization Strategies
3. Scaling Solutions
4. Performance Monitoring
```

## Limitations & Considerations

### Technical Constraints

- **No Persistent Memory**: Agents start fresh each time
- **No Nested Invocation**: Agents can't call other agents
- **Tool Inheritance**: All tools inherited if not limited
- **Context Isolation**: No shared state between agents

### Rate Limiting Impact

- **Opus Weekly Limit**: 24-40 hours
- **Parallel Consumption**: 4x agents = 4x quota usage
- **Strategy Required**: Careful model selection essential

## Integration with Existing Workflows

Subagents integrate seamlessly with:

- **Custom Commands**: Commands can trigger specific agents
- **Hooks**: Automate agent invocation based on events
- **MCP Servers**: Agents can use MCP tools
- **Git Workflows**: Automatic review on commits

## Future Enhancements (Roadmap)

- Persistent agent memory
- Inter-agent communication
- Dynamic model switching
- Custom training data per agent
- Agent performance analytics

---

_This documentation reflects Claude Code capabilities as of August 9, 2025. Features and best practices may evolve._
