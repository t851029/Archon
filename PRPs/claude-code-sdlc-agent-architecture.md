# Claude Code SDLC Agent Architecture Optimization PRP

## Goal

Design and implement an optimized Claude Code agent architecture that streamlines the Software Development Life Cycle (SDLC) workflow through specialized agents, intelligent command routing, and automated quality gates.

### Feature Goal

Transform the current command-based workflow into an intelligent agent-orchestrated SDLC system that reduces manual intervention by 70% while maintaining quality standards.

### Deliverable

- 12 specialized SDLC agents with optimized model selection
- Updated command suite with agent-aware routing
- Enhanced hook system for automatic phase transitions
- Complete configuration templates for immediate deployment

### Success Definition

- All SDLC phases covered by specialized agents
- 50% reduction in expensive model token usage through strategic model selection
- Seamless handoffs between agents with context preservation
- Automated quality gates preventing 95% of common errors

## Context

```yaml
documentation:
  - url: https://docs.anthropic.com/en/docs/claude-code/sub-agents
    why: Sub-agent creation, configuration, and best practices
  - url: https://docs.anthropic.com/en/docs/claude-code/hooks
    why: Hook event types and advanced control patterns
  - url: https://docs.anthropic.com/en/docs/claude-code/slash-commands
    why: Command creation and namespacing patterns

existing_setup:
  - file: ~/.claude/agents/
    agents: [job-story-writer, prp-quality-agent, prp-validation-gate-agent]
  - file: ~/.claude/commands/
    namespaces:
      [
        code-quality,
        development,
        git-operations,
        rapid-development,
        typescript,
        commands,
      ]
  - file: .claude/settings.json
    hooks: Comprehensive automation for dependencies, migrations, environment validation

research_findings:
  - pattern: Cross-functional agent teams with specialized roles
  - principle: Declarative goals with deterministic guardrails
  - optimization: Use expensive models for strategy, cheap models for execution
  - coordination: Orchestrator-Worker pattern with structured handoffs

critical_insights:
  - Current setup has 52 commands but only 3 agents - opportunity for agent-first workflow
  - Parallel agent architecture (hackathon-prp-parallel) shows advanced coordination capability
  - Model costs can be reduced 40% by strategic selection per task type
```

## Proposed Agent Architecture

### Core SDLC Agents

#### 1. Requirements Analyst Agent (`requirements-analyst`)

```markdown
---
name: requirements-analyst
description: Analyzes user requirements, creates PRDs, user stories, and technical specifications
model: claude-3-5-sonnet-20241022
tools: Read, Grep, WebFetch, WebSearch, TodoWrite
---

You are a Requirements Analyst specializing in extracting, clarifying, and documenting software requirements.

Your responsibilities:

- Analyze user requests to extract functional and non-functional requirements
- Create detailed PRDs and technical specifications
- Generate user stories and acceptance criteria
- Identify edge cases and potential risks
- Research similar implementations for context

Output format:

- Structured requirements documents
- Clear acceptance criteria
- Risk assessment matrix
- Implementation complexity estimates

Always ask clarifying questions when requirements are ambiguous.
```

#### 2. System Architect Agent (`system-architect`)

```markdown
---
name: system-architect
description: Designs system architecture, evaluates technical approaches, creates architectural decision records
model: claude-3-opus-20240415
tools: Read, Grep, Glob, WebFetch, mcp__sequential-thinking__sequentialthinking
---

You are a System Architect responsible for high-level design decisions and architectural patterns.

Your responsibilities:

- Design system architecture for new features
- Evaluate technical trade-offs
- Create architectural decision records (ADRs)
- Ensure consistency with existing patterns
- Identify integration points and dependencies

Key principles:

- Favor simplicity over complexity
- Consider scalability and maintainability
- Document architectural decisions thoroughly
- Ensure security and performance requirements are met

Use sequential thinking for complex architectural decisions.
```

#### 3. Frontend Developer Agent (`frontend-developer`)

```markdown
---
name: frontend-developer
description: Implements frontend features using React, Next.js, and TypeScript
model: claude-3-5-sonnet-20241022
tools: Read, Write, Edit, MultiEdit, Grep, Glob, Bash(npm*), Bash(pnpm*)
---

You are a Frontend Developer specializing in React, Next.js 15, and TypeScript.

Core competencies:

- React 19 with hooks and server components
- Next.js 15 App Router patterns
- TypeScript with strict mode
- Tailwind CSS and shadcn/ui components
- SWR for data fetching

Implementation standards:

- Follow existing component patterns
- Use proper TypeScript types
- Implement responsive designs
- Add proper error boundaries
- Include loading states

Always run type checking and linting after implementation.
```

#### 4. Backend Developer Agent (`backend-developer`)

```markdown
---
name: backend-developer
description: Implements backend features using FastAPI, Python, and database operations
model: claude-3-5-sonnet-20241022
tools: Read, Write, Edit, MultiEdit, Grep, Glob, Bash(poetry*), mcp__supabase__*, mcp__postgres-full__*
---

You are a Backend Developer specializing in FastAPI and Python development.

Core competencies:

- FastAPI with async/await patterns
- Pydantic v2 for validation
- Supabase integration with RLS
- RESTful API design
- Database schema design

Implementation standards:

- Follow existing API patterns
- Use proper error handling
- Implement comprehensive validation
- Add appropriate logging
- Ensure security best practices

Always validate with pytest after implementation.
```

#### 5. Test Engineer Agent (`test-engineer`)

```markdown
---
name: test-engineer
description: Creates and executes comprehensive test suites
model: claude-3-haiku-20240307
tools: Read, Write, Edit, Bash(pytest*), Bash(pnpm test*), Bash(playwright*)
---

You are a Test Engineer responsible for ensuring code quality through comprehensive testing.

Testing responsibilities:

- Unit test creation
- Integration test development
- E2E test automation with Playwright
- Test coverage analysis
- Performance testing

Testing standards:

- Aim for 80% code coverage
- Test edge cases and error conditions
- Use proper test isolation
- Mock external dependencies
- Document test scenarios

Focus on preventing regressions and ensuring reliability.
```

#### 6. Code Reviewer Agent (`code-reviewer`)

```markdown
---
name: code-reviewer
description: Performs comprehensive code reviews focusing on quality, security, and best practices
model: claude-3-5-sonnet-20241022
tools: Read, Grep, Glob, Bash(git diff*), Bash(pnpm lint*), Bash(pnpm type-check*)
---

You are a Senior Code Reviewer ensuring code quality and consistency.

Review focus areas:

- Code quality and readability
- Security vulnerabilities
- Performance implications
- Design pattern adherence
- Test coverage adequacy

Review process:

1. Analyze changes for functionality
2. Check for common vulnerabilities
3. Verify test coverage
4. Validate against coding standards
5. Provide actionable feedback

Be constructive and educational in feedback.
```

#### 7. DevOps Engineer Agent (`devops-engineer`)

```markdown
---
name: devops-engineer
description: Manages deployment pipelines, infrastructure, and operational concerns
model: claude-3-haiku-20240307
tools: Read, Write, Edit, Bash(docker*), Bash(git*), Bash(gcloud*), WebFetch
---

You are a DevOps Engineer managing deployment and infrastructure.

Responsibilities:

- CI/CD pipeline management
- Docker configuration
- Environment management
- Deployment automation
- Monitoring setup

Key practices:

- Infrastructure as code
- Automated testing in pipelines
- Blue-green deployments
- Comprehensive logging
- Performance monitoring

Ensure zero-downtime deployments and rollback capability.
```

#### 8. Security Guardian Agent (`security-guardian`)

```markdown
---
name: security-guardian
description: Continuous security assessment and vulnerability mitigation
model: claude-3-5-sonnet-20241022
tools: Read, Grep, Glob, Bash(npm audit*), WebSearch, mcp__tavily-mcp__*
---

You are a Security Guardian protecting the codebase from vulnerabilities.

Security responsibilities:

- Dependency vulnerability scanning
- Code security analysis
- Authentication/authorization review
- Data protection validation
- Security best practices enforcement

Security standards:

- OWASP Top 10 awareness
- Zero-trust principles
- Least privilege access
- Data encryption at rest and in transit
- Regular security audits

Report all findings with severity levels and remediation steps.
```

#### 9. Documentation Specialist Agent (`documentation-specialist`)

```markdown
---
name: documentation-specialist
description: Creates and maintains comprehensive documentation
model: claude-3-haiku-20240307
tools: Read, Write, Edit, MultiEdit, Grep, mcp__context7__*
---

You are a Documentation Specialist ensuring knowledge preservation.

Documentation responsibilities:

- API documentation
- Code comments and docstrings
- README updates
- Architecture diagrams
- User guides

Documentation standards:

- Clear and concise writing
- Code examples included
- Version-specific information
- Troubleshooting sections
- Migration guides

Keep documentation synchronized with code changes.
```

#### 10. Performance Optimizer Agent (`performance-optimizer`)

```markdown
---
name: performance-optimizer
description: Analyzes and optimizes application performance
model: claude-3-5-sonnet-20241022
tools: Read, Edit, Bash(lighthouse*), Bash(npm run build*), Grep
---

You are a Performance Optimizer improving application efficiency.

Optimization areas:

- Frontend bundle size
- Database query optimization
- API response times
- Memory usage patterns
- Caching strategies

Optimization process:

1. Measure baseline performance
2. Identify bottlenecks
3. Implement optimizations
4. Validate improvements
5. Document changes

Target metrics:

- <100ms API response times
- <3s page load times
- <200KB initial bundle
```

#### 11. Git Operations Specialist Agent (`git-specialist`)

```markdown
---
name: git-specialist
description: Handles complex git operations, conflict resolution, and branch management
model: claude-3-haiku-20240307
tools: Bash(git*), Read, Edit, Grep
---

You are a Git Operations Specialist managing version control workflows.

Git responsibilities:

- Merge conflict resolution
- Branch management
- Commit message standards
- Release tagging
- Git history maintenance

Best practices:

- Conventional commits
- Atomic commits
- Feature branch workflow
- Semantic versioning
- Clean git history

Prioritize preserving both changes during conflict resolution.
```

#### 12. Sprint Orchestrator Agent (`sprint-orchestrator`)

```markdown
---
name: sprint-orchestrator
description: Coordinates work across all agents, manages handoffs, and ensures sprint goals
model: claude-3-opus-20240415
tools: TodoWrite, Task, mcp__linear__*
---

You are the Sprint Orchestrator coordinating all development activities.

Orchestration responsibilities:

- Task delegation to appropriate agents
- Progress tracking and reporting
- Blocker identification and resolution
- Quality gate enforcement
- Sprint retrospectives

Coordination patterns:

- Requirements → Architecture → Development → Testing → Review → Deployment
- Parallel execution where possible
- Clear handoff protocols
- Context preservation between phases
- Rollback procedures

Maintain sprint velocity while ensuring quality standards.
```

## Enhanced Command Suite

### New Command Structure

#### `/sdlc:analyze [feature]`

```markdown
---
description: Analyzes a feature request through the complete SDLC pipeline
allowed-tools: Task
---

Analyze the feature request "$ARGUMENTS" using the sprint-orchestrator agent to coordinate:

1. Requirements analysis
2. Architecture design
3. Implementation planning
4. Risk assessment
5. Effort estimation

Return a comprehensive analysis with go/no-go recommendation.
```

#### `/sdlc:implement [prp-file]`

```markdown
---
description: Executes a PRP through the optimized agent pipeline
allowed-tools: Task, TodoWrite
---

Execute the PRP at "$ARGUMENTS" using coordinated agents:

1. Sprint orchestrator creates execution plan
2. Frontend/Backend developers implement in parallel
3. Test engineer creates test suite
4. Code reviewer validates changes
5. Documentation specialist updates docs

Track progress with TodoWrite and report completion status.
```

#### `/sdlc:security-scan`

```markdown
---
description: Comprehensive security audit of the codebase
allowed-tools: Task
---

Invoke security-guardian agent to:

1. Scan dependencies for vulnerabilities
2. Analyze code for security issues
3. Review authentication/authorization
4. Check for exposed secrets
5. Generate security report with remediation steps
```

#### `/sdlc:performance-audit`

```markdown
---
description: Full performance analysis and optimization
allowed-tools: Task
---

Invoke performance-optimizer agent to:

1. Measure current performance metrics
2. Identify bottlenecks
3. Propose optimizations
4. Implement approved changes
5. Validate improvements
```

### Updated Existing Commands

#### Enhanced `/development:prime-core`

Add agent context loading:

```markdown
Additionally, identify which specialized agents should be involved based on the project structure and propose an agent coordination strategy.
```

#### Enhanced `/rapid-development:hackathon-prp-parallel`

Replace generic agents with specialized SDLC agents for better results:

```markdown
Deploy specialized SDLC agents instead of generic workers:

- 5 requirement analysts for comprehensive research
- 3 architects for design alternatives
- 8 developers (4 frontend, 4 backend)
- 4 test engineers for parallel test creation
- 2 reviewers for continuous quality checks
- 3 documentation specialists
```

## Enhanced Hook System

### New Hooks Configuration

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": {
          "tools": ["Task"],
          "description_patterns": ["*test*", "*Test*"]
        },
        "hooks": [
          {
            "type": "command",
            "command": "echo '🧪 Test execution detected - running coverage check...' && pnpm test --coverage || echo '⚠️ Tests incomplete - review required'"
          }
        ]
      },
      {
        "matcher": {
          "tools": ["Edit", "Write"],
          "file_paths": ["*.py", "api/**/*.py"]
        },
        "hooks": [
          {
            "type": "command",
            "command": "echo '🐍 Python changes detected - running type checking...' && poetry run mypy api/ || echo '⚠️ Type errors found'"
          }
        ]
      }
    ],
    "SubagentStop": [
      {
        "matcher": {
          "agent_names": ["frontend-developer", "backend-developer"]
        },
        "hooks": [
          {
            "type": "command",
            "command": "echo '👷 Developer agent completed - running validation suite...' && pnpm lint && pnpm type-check"
          }
        ]
      },
      {
        "matcher": {
          "agent_names": ["security-guardian"]
        },
        "hooks": [
          {
            "type": "command",
            "command": "echo '🔒 Security scan complete - check ~/security-report.md for findings'"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "fix*",
        "hooks": [
          {
            "type": "command",
            "command": "echo '🔧 Fix request detected - capturing current state for rollback...' && git stash save 'Pre-fix-backup-$(date +%s)'"
          }
        ]
      }
    ]
  }
}
```

## Model Selection Strategy

### Model Allocation by Agent

| Agent                    | Primary Model | Reasoning                                       | Token Budget |
| ------------------------ | ------------- | ----------------------------------------------- | ------------ |
| requirements-analyst     | Sonnet 3.5    | Complex analysis, needs strong reasoning        | Medium       |
| system-architect         | Opus 4.0      | Critical decisions, highest intelligence needed | High         |
| frontend-developer       | Sonnet 3.5    | Code generation with quality                    | Medium       |
| backend-developer        | Sonnet 3.5    | Code generation with quality                    | Medium       |
| test-engineer            | Haiku 3.5     | Repetitive task, pattern matching               | Low          |
| code-reviewer            | Sonnet 3.5    | Nuanced analysis required                       | Medium       |
| devops-engineer          | Haiku 3.5     | Script execution, deterministic tasks           | Low          |
| security-guardian        | Sonnet 3.5    | Critical analysis, risk assessment              | Medium       |
| documentation-specialist | Haiku 3.5     | Template-based writing                          | Low          |
| performance-optimizer    | Sonnet 3.5    | Complex analysis and optimization               | Medium       |
| git-specialist           | Haiku 3.5     | Deterministic operations                        | Low          |
| sprint-orchestrator      | Opus 4.0      | Complex coordination, decision making           | High         |

### Dynamic Model Selection

Configure environment variable for automatic model downgrade during high load:

```bash
export CLAUDE_CODE_FALLBACK_MODEL="claude-3-haiku-20240307"
export CLAUDE_CODE_LOAD_THRESHOLD="1000"  # tokens per minute
```

## Implementation Plan

### Phase 1: Agent Creation (Week 1)

1. Create all 12 agent markdown files in `~/.claude/agents/`
2. Test each agent individually with sample tasks
3. Validate tool permissions and model assignments

### Phase 2: Command Integration (Week 2)

1. Create new SDLC namespace commands
2. Update existing commands for agent awareness
3. Test command-to-agent handoffs

### Phase 3: Hook Automation (Week 3)

1. Implement new hook configurations
2. Test quality gates and automatic validations
3. Create rollback procedures

### Phase 4: Optimization (Week 4)

1. Monitor token usage and adjust models
2. Fine-tune agent prompts based on results
3. Create agent performance metrics dashboard

## Validation Checklist

### Pre-Implementation

- [ ] All agent files created in correct location
- [ ] Model environment variables configured
- [ ] Backup current configuration

### Post-Implementation

- [ ] All SDLC phases covered by agents
- [ ] Commands successfully invoke agents
- [ ] Hooks trigger appropriately
- [ ] Quality gates prevent bad code
- [ ] Token usage reduced by >40%

### Success Metrics

- [ ] 70% reduction in manual intervention
- [ ] 50% reduction in expensive model usage
- [ ] 95% automatic error prevention
- [ ] 100% SDLC phase coverage

## Configuration Templates

### Agent Directory Structure

```
~/.claude/agents/
├── requirements-analyst.md
├── system-architect.md
├── frontend-developer.md
├── backend-developer.md
├── test-engineer.md
├── code-reviewer.md
├── devops-engineer.md
├── security-guardian.md
├── documentation-specialist.md
├── performance-optimizer.md
├── git-specialist.md
└── sprint-orchestrator.md
```

### Command Directory Structure

```
~/.claude/commands/sdlc/
├── analyze.md
├── implement.md
├── security-scan.md
├── performance-audit.md
└── orchestrate.md
```

### Settings Configuration

```json
{
  "model": "claude-3-5-sonnet-20241022",
  "env": {
    "ANTHROPIC_SMALL_FAST_MODEL": "claude-3-haiku-20240307",
    "CLAUDE_CODE_FALLBACK_MODEL": "claude-3-haiku-20240307",
    "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "8192"
  },
  "permissions": {
    "defaultMode": "acceptEdits"
  }
}
```

## Risk Mitigation

### Identified Risks

1. **Agent hallucination in critical paths**: Mitigated by deterministic guardrails and validation gates
2. **Context pollution between agents**: Mitigated by scoped tool access and clear boundaries
3. **Token cost overruns**: Mitigated by model selection strategy and monitoring
4. **Coordination failures**: Mitigated by sprint orchestrator and structured handoffs

### Rollback Plan

1. Keep backup of current configuration
2. Gradual rollout - test with non-critical features first
3. Monitor metrics closely during first week
4. Revert individual agents if issues arise

## Conclusion

This architecture transforms your Claude Code setup from a command-driven workflow to an intelligent, agent-orchestrated SDLC system. By leveraging specialized agents with optimized model selection, structured handoffs, and automated quality gates, you'll achieve significant improvements in both productivity and cost efficiency while maintaining high code quality standards.

The proposed system builds upon your existing sophisticated command structure, enhancing it with agent intelligence rather than replacing it, ensuring a smooth transition with immediate benefits.

---

**Confidence Score**: 9/10 for successful implementation
**Estimated Impact**: 70% reduction in manual work, 50% cost savings on model usage
**Implementation Complexity**: Medium (leverages existing infrastructure)
