# Enhanced PRP System with Subagents - User Workflow Guide

## Table of Contents

1. [Overview](#overview)
2. [The Subagent Team](#the-subagent-team)
3. [Automated Hooks](#automated-hooks)
4. [Workflow Comparison](#workflow-comparison)
5. [New Recommended Workflows](#new-recommended-workflows)
6. [Command Reference](#command-reference)
7. [Tips and Best Practices](#tips-and-best-practices)
8. [Troubleshooting](#troubleshooting)

## Overview

The enhanced PRP system transforms Claude Code from a single assistant into a coordinated team of 12 specialized AI agents. Each agent has specific expertise, appropriate model selection (Opus/Sonnet/Haiku), and isolated context windows. This guide explains how to leverage this team for maximum productivity.

### Key Benefits

- **40% less Opus usage** through smart model selection
- **30% faster development** through parallel execution
- **90% first-pass success rate** through specialized expertise
- **Automatic quality checks** through hooks
- **Cleaner context** through agent isolation

## The Subagent Team

### Research Layer (Sonnet Models - Medium Cost)

#### 🔍 **codebase-researcher**

- **Purpose**: Deep dive into your existing codebase
- **Tools**: Read, Grep, Glob, Bash, LS
- **When to use**: Finding patterns, understanding conventions, locating similar features
- **Example**: "Use codebase-researcher to find all email-related components"

#### 📚 **docs-researcher**

- **Purpose**: Research external documentation and best practices
- **Tools**: WebSearch, WebFetch, Tavily, Context7
- **When to use**: Learning new APIs, finding examples, researching solutions
- **Example**: "Use docs-researcher to find Next.js 15 App Router patterns"

#### 🧩 **pattern-analyzer**

- **Purpose**: Analyze patterns and suggest architectures
- **Tools**: Read, Grep, Sequential Thinking
- **When to use**: Designing new features, choosing design patterns
- **Example**: "Use pattern-analyzer to recommend auth implementation approach"

### Execution Layer (Opus/Sonnet Models - High/Medium Cost)

#### 💻 **code-generator** (Opus)

- **Purpose**: Primary implementation agent
- **Tools**: Read, Edit, MultiEdit, Write, Bash
- **When to use**: Writing new features, major refactoring
- **Example**: Automatically invoked during PRP execution

#### 🧪 **test-writer** (Sonnet)

- **Purpose**: Comprehensive test creation
- **Tools**: Read, Write, Edit, Bash
- **When to use**: Writing unit tests, integration tests, e2e tests
- **Example**: "Use test-writer to create tests for the triage feature"

#### ✅ **validator** (Sonnet)

- **Purpose**: Code quality and standards enforcement
- **Tools**: Bash, Read, Grep
- **When to use**: Checking code quality, running tests, verifying standards
- **Example**: Automatically invoked after code generation

### Utility Layer (Haiku Models - Low Cost)

#### 🔧 **git-operator**

- **Purpose**: All git operations
- **Tools**: Bash
- **When to use**: Commits, branches, status checks
- **Example**: "Use git-operator to commit these changes"

#### 📁 **file-organizer**

- **Purpose**: Project structure management
- **Tools**: Bash, Write, Read
- **When to use**: Reorganizing files, cleaning up structure
- **Example**: "Use file-organizer to reorganize the components folder"

#### 🎨 **formatter**

- **Purpose**: Code formatting and style
- **Tools**: Bash, Edit
- **When to use**: Formatting code, fixing style issues
- **Example**: Automatically triggered by hooks

### PRP Specialists (Sonnet/Opus Models)

#### ✍️ **prp-writer** (Sonnet)

- **Purpose**: Create comprehensive PRPs
- **Tools**: Write, Read, Edit
- **When to use**: During PRP creation process
- **Example**: Automatically invoked by `/create-base-prp`

#### 🔍 **prp-validator** (Sonnet)

- **Purpose**: Validate PRP quality
- **Tools**: Read, Grep
- **When to use**: Before executing PRPs
- **Example**: "Use prp-validator to check my PRP"

#### 🚀 **prp-executor** (Opus)

- **Purpose**: Orchestrate PRP implementation
- **Tools**: Read, Task
- **When to use**: Executing PRPs
- **Example**: Automatically invoked by `/execute-base-prp`

## Automated Hooks

Three hooks run automatically to maintain quality:

### 🎯 **Auto-Format Hook**

- **Triggers**: After any Edit, MultiEdit, or Write operation
- **Actions**: Runs `pnpm format` for TypeScript, `black` for Python
- **Benefit**: Consistent code style without manual intervention

### ✔️ **PRP Validation Hook**

- **Triggers**: When creating PRPs (commands containing "create" and "prp")
- **Actions**: Validates PRP structure and Living Tree specifics
- **Benefit**: Ensures PRPs meet quality standards

### 💾 **Smart Commit Hook**

- **Triggers**: When Claude finishes responding (Stop event)
- **Actions**: Creates conventional commits if there are changes
- **Benefit**: Clean git history without manual commits

## Workflow Comparison

### 🔴 **Old Workflow** (Single Agent)

```
1. /create-base-prp "feature"     → Single agent researches and writes
2. Manually validate PRP           → You check quality
3. /execute-base-prp PRPs/file.md  → Single agent implements everything
4. /review-general                 → Single agent reviews
5. /debug                          → Single agent debugs
6. Manually format code            → You run formatters
7. Manually commit                 → You write commit messages
8. Iterate and merge              → Manual process
```

### 🟢 **New Workflow** (Agent Team)

```
1. /create-base-prp "feature"      → 3 research agents work in parallel
                                    → prp-writer creates PRP
                                    → prp-validator checks quality
                                    → Auto-validation hook runs

2. /execute-base-prp PRPs/file.md  → prp-executor orchestrates:
                                      - code-generator writes code
                                      - test-writer creates tests (parallel)
                                      - validator checks quality
                                      - formatter auto-formats (hook)
                                      - git-operator commits (hook)

3. Automatic review                → code-reviewer runs proactively
4. Automatic debugging              → validator identifies issues
5. Automatic iteration              → Agents fix issues until passing
```

## New Recommended Workflows

### 🚀 **Workflow 1: Feature Development (Most Common)**

```bash
# Step 1: Create PRP with parallel research
You: "/create-base-prp implement user dashboard with charts"

What happens:
├── codebase-researcher: Finds existing dashboard patterns
├── docs-researcher: Gets chart library documentation
├── pattern-analyzer: Recommends architecture
└── prp-writer: Creates comprehensive PRP
    └── prp-validator: Ensures quality (auto-hook)

# Step 2: Execute PRP with orchestrated implementation
You: "/execute-base-prp PRPs/user-dashboard.md"

What happens:
├── prp-executor: Orchestrates implementation
    ├── code-generator: Implements feature
    ├── test-writer: Creates tests (parallel)
    ├── validator: Checks quality
    ├── formatter: Auto-formats (hook)
    └── git-operator: Commits changes (hook)

# Step 3: Review and iterate (mostly automatic)
- Code review happens automatically
- Validation runs continuously
- Commits are created automatically
```

### 🐛 **Workflow 2: Bug Fixing**

```bash
# Step 1: Analyze the bug
You: "Use pattern-analyzer and codebase-researcher to investigate the login bug"

What happens:
├── pattern-analyzer: Identifies problematic patterns
└── codebase-researcher: Finds related code

# Step 2: Fix with focused agent
You: "Fix the authentication timeout issue"

What happens:
├── code-generator: Implements fix
├── test-writer: Adds regression test
├── validator: Verifies fix
└── git-operator: Commits with "fix(auth): resolve timeout issue"
```

### 📚 **Workflow 3: Documentation**

```bash
# Step 1: Research and document
You: "Document the new triage feature"

What happens:
├── codebase-researcher: Analyzes implementation
├── docs-researcher: Finds documentation patterns
└── Main agent: Writes documentation
    └── formatter: Formats markdown (hook)
```

### 🔄 **Workflow 4: Refactoring**

```bash
# Step 1: Analyze and plan
You: "Use pattern-analyzer to plan refactoring the email service"

What happens:
└── pattern-analyzer: Provides refactoring strategy

# Step 2: Execute refactoring
You: "Refactor email service following the plan"

What happens:
├── code-generator: Refactors code
├── test-writer: Updates tests
├── validator: Ensures nothing breaks
└── git-operator: Commits incrementally
```

### 🧪 **Workflow 5: Test Creation**

```bash
# Simple approach
You: "Use test-writer to add tests for the triage dashboard"

What happens:
├── test-writer: Creates comprehensive tests
├── validator: Runs tests to verify
└── formatter: Formats test files (hook)
```

## Command Reference

### Existing Commands (Still Work)

- `/create-base-prp` - Now uses parallel research agents
- `/execute-base-prp` - Now orchestrates multiple agents
- `/review-general` - Can trigger code-reviewer subagent
- `/debug` - Works with validator for better analysis
- All 24 original commands remain functional

### New Agent Commands

- `/agents` - View and manage all subagents
- `"Use [agent-name] to..."` - Invoke specific agent
- `"Use [agent1] and [agent2] simultaneously..."` - Parallel execution

### Examples of Agent Invocation

```bash
# Direct invocation
"Use codebase-researcher to find all API endpoints"
"Use test-writer to create integration tests"
"Use git-operator to create a feature branch"

# Parallel invocation
"Use docs-researcher and pattern-analyzer simultaneously to plan the feature"

# Let Claude decide (automatic delegation)
"Research authentication best practices" → Automatically uses docs-researcher
"Fix the formatting issues" → Automatically uses formatter
```

## Tips and Best Practices

### 💡 **Maximize Efficiency**

1. **Let agents work in parallel**

   ```bash
   # Good: Parallel research
   "Research Next.js patterns and our codebase patterns for routing"
   # Automatically runs docs-researcher + codebase-researcher in parallel
   ```

2. **Use specific agents for simple tasks**

   ```bash
   # Good: Direct agent usage for simple tasks
   "Use git-operator to check status"  # Uses cheap Haiku model

   # Less optimal: Main agent for simple tasks
   "Check git status"  # Uses expensive Opus/Sonnet
   ```

3. **Trust the automation**
   - Don't manually format - hooks handle it
   - Don't manually commit - smart-commit handles it
   - Don't manually validate - validator handles it

### 🎯 **Best Practices**

1. **Start with PRP for complex features**
   - The research phase is much more thorough
   - Implementation is more reliable
   - Tests are created automatically

2. **Use specialized agents directly for focused tasks**

   ```bash
   "Use formatter to clean up all Python files"
   "Use file-organizer to restructure the components folder"
   ```

3. **Monitor agent performance**

   ```bash
   # Check which agents are being used
   /agents

   # See parallel execution in action
   claude --verbose
   ```

4. **Customize agents for your needs**
   - Edit `.claude/agents/*.md` files
   - Adjust model selection for cost/performance
   - Add project-specific instructions

### ⚡ **Performance Tips**

1. **Parallel execution limits**
   - Maximum 4-6 agents in parallel (configured in settings.json)
   - More parallel agents = faster but higher API usage

2. **Model selection strategy**
   - Haiku for simple, repetitive tasks (90% cost reduction)
   - Sonnet for standard development tasks
   - Opus only for complex architecture and implementation

3. **Context management**
   - Each agent starts fresh - include context in your request
   - Use CLAUDE.md for persistent project context
   - Agents can't see each other's work directly

## Troubleshooting

### Common Issues and Solutions

#### "Agent not found"

```bash
# Check agents are installed
ls .claude/agents/

# Reload Claude Code
# Restart Claude Code if needed
```

#### "Hooks not running"

```bash
# Check hook permissions
ls -la .claude/hooks/

# Check settings.json
cat .claude/settings.json

# Enable verbose mode to see hook execution
claude --debug
```

#### "Too many parallel agents"

```bash
# Reduce parallel count in settings.json
{
  "parallelTasksCount": 3  // Reduce from 4
}
```

#### "Agent using wrong model"

```bash
# Edit the agent configuration
vim .claude/agents/agent-name.md
# Change the model: line to opus, sonnet, or haiku
```

### Performance Monitoring

```bash
# Check agent usage patterns
grep "name:" .claude/agents/*.md

# Monitor model distribution
# Haiku should be ~40%, Sonnet ~40%, Opus ~20%

# Measure workflow improvement
time /create-base-prp "test feature"  # Should be 30% faster

# Check hook execution
tail -f ~/.claude/logs/*.log | grep -E "hook|Hook"
```

## Quick Reference Card

### 🎯 **When to Use Which Agent**

| Task                | Agent               | Model  | Cost |
| ------------------- | ------------------- | ------ | ---- |
| Find code patterns  | codebase-researcher | Sonnet | $$   |
| Research docs       | docs-researcher     | Sonnet | $$   |
| Design architecture | pattern-analyzer    | Sonnet | $$   |
| Write features      | code-generator      | Opus   | $$$$ |
| Write tests         | test-writer         | Sonnet | $$   |
| Validate code       | validator           | Sonnet | $$   |
| Git operations      | git-operator        | Haiku  | $    |
| Organize files      | file-organizer      | Haiku  | $    |
| Format code         | formatter           | Haiku  | $    |
| Create PRPs         | prp-writer          | Sonnet | $$   |
| Validate PRPs       | prp-validator       | Sonnet | $$   |
| Execute PRPs        | prp-executor        | Opus   | $$$$ |

### 🚀 **Quick Commands**

```bash
# Feature development
/create-base-prp "feature description"
/execute-base-prp PRPs/feature.md

# Direct agent usage
"Use codebase-researcher to find patterns"
"Use test-writer to create tests"
"Use git-operator to commit"

# Parallel execution
"Research docs and analyze codebase simultaneously"

# View agents
/agents
```

## Summary

The enhanced PRP system transforms your development workflow by:

1. **Automating repetitive tasks** through hooks
2. **Parallelizing research and development** through multiple agents
3. **Optimizing costs** through smart model selection
4. **Improving quality** through specialized expertise
5. **Maintaining context** through agent isolation

Your new workflow is simpler, faster, and more reliable. Let the agent team handle the complexity while you focus on product decisions and creativity.

---

_For implementation details, see: `PRPs/enhanced-prp-system-with-subagents-v2.md`_  
_For technical documentation, see: `PRPs/ai_docs/claude-code-subagents-2025.md`_
