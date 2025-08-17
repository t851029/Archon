name: "Automated Testing Agents - E2E Runner & Integration Validator"
description: |

## Purpose

Implement two specialized testing agents that automatically trigger at appropriate times in the development workflow to ensure comprehensive test coverage and validation without manual intervention.

## Core Principles

1. **Event-Driven Automation**: Agents automatically trigger based on conditions and results
2. **Seamless Integration**: Agents integrate into existing workflow without disrupting current patterns
3. **Comprehensive Coverage**: E2E and integration testing work together for complete validation
4. **Intelligent Chaining**: Agents know when to invoke each other based on results and context

---

## Goal

**Feature Goal**: Implement three automated agents for comprehensive PRP and testing workflows: prp-create-agent (automated PRP creation), e2e-test-runner (automated E2E testing), and integration-test-validator (automated integration validation) that automatically trigger in sequence based on conditions and results.

**Deliverable**: Three new Claude Code agent files (`.claude/agents/prp-create-agent.md`, `.claude/agents/e2e-test-runner.md`, and `.claude/agents/integration-test-validator.md`) that integrate seamlessly into the existing agent ecosystem with intelligent chaining: prp-create-agent → prp-quality-agent → e2e-test-runner → integration-test-validator.

**Success Definition**: Users can request features and the prp-create-agent automatically creates comprehensive PRPs, triggers prp-quality-agent for validation, and then the testing agents automatically execute when PRPs are implemented - creating a fully automated feature development pipeline without manual intervention.

## Why

- **Complete Automation Pipeline**: From feature request to tested implementation without manual intervention
- **Automated PRP Creation**: Eliminate manual PRP writing while maintaining quality standards
- **Automated Quality Gates**: Ensure no feature ships without comprehensive testing and validation
- **Reduced Manual Overhead**: Eliminate need for developers to create PRPs, remember test types, or manage quality checks
- **Faster Development Cycles**: Immediate PRP creation, quality validation, and test execution
- **Integration Confidence**: Validate that all system components work together correctly
- **Deployment Safety**: Prevent broken code from reaching staging/production environments
- **Agent Ecosystem Enhancement**: Create a complete feature development pipeline with intelligent agent chaining

## What

Three specialized agents that automatically execute in a complete development pipeline:

### PRP Create Agent
- **Automatically triggers**: When users request new features or improvements
- **Executes**: Comprehensive PRP creation following .claude/commands/commands/prp-create.md methodology
- **Reports**: Generated PRP with comprehensive research and context
- **Chains to**: PRP Quality Agent for validation before approval

### E2E Test Runner Agent
- **Automatically triggers**: After code generation, validation gate passage, or on deployment events
- **Executes**: Playwright E2E tests across multiple browsers and environments  
- **Reports**: Test results, screenshots on failures, coverage metrics
- **Chains to**: Integration Test Validator when E2E tests pass or when failures indicate integration issues

### Integration Test Validator Agent
- **Automatically triggers**: After E2E test completion, API changes, or database migrations
- **Executes**: API integration tests, database validation, authentication flow tests
- **Reports**: Integration status, gap analysis, validation reports
- **Chains to**: Deployment gatekeeper or alert systems based on results

### Success Criteria

- [ ] PRP Create Agent automatically triggers when users request features and creates comprehensive PRPs
- [ ] PRP Create Agent automatically invokes PRP Quality Agent after PRP creation
- [ ] E2E Test Runner agent automatically triggers after prp-validation-gate-agent completion
- [ ] Integration Test Validator agent automatically triggers after E2E tests complete
- [ ] All three agents execute using proper Living Tree commands and configurations
- [ ] Agents report comprehensive results with actionable failure information
- [ ] Agent chaining works correctly: prp-create → prp-quality → e2e-runner → integration-validator
- [ ] PRP creation follows established methodology from .claude/commands/commands/prp-create.md
- [ ] All tests can be executed in local, staging, and production environments
- [ ] Agents integrate with existing MCP tools (Playwright, Supabase) for enhanced capabilities
- [ ] Failure handling includes proper error reporting and escalation throughout the pipeline

## All Needed Context

### Documentation & References

```yaml
# Agent Configuration Patterns
- file: .claude/agents/test-runner.md
  why: Existing test runner patterns and tool configurations
  critical: Uses proper tool restrictions and Living Tree specific commands

- file: .claude/agents/prp-validation-gate-agent/prp-validation-gate-agent.md  
  why: Comprehensive validation reporting format and agent chaining patterns
  critical: Shows how to structure detailed validation reports and trigger other agents

- file: .claude/agents/prp-quality-agent/prp-quality-agent.md
  why: PRP quality validation patterns and comprehensive reporting structure
  critical: Quality gates, scoring system, and approval/rejection patterns for PRPs

- file: .claude/agents/prp-executor.md
  why: Agent orchestration patterns and Task tool usage for delegation
  critical: Sequential/parallel/iterative workflow patterns for agent coordination

- file: .claude/agents/README.md
  why: Agent structure, proactive invocation keywords, and automation best practices
  critical: "Use PROACTIVELY" and "Use this agent when" trigger patterns

# PRP Creation Methodology
- file: .claude/commands/commands/prp-create.md
  why: Complete PRP creation methodology and workflow
  critical: Research process, template selection, context validation, and quality gates

# Testing Infrastructure
- file: /home/gwizz/wsl_projects/jerin/lt-146-improve-local-to-staging-pipeline/apps/web/playwright.config.ts
  why: Playwright configuration for E2E testing across environments
  critical: Environment-specific configurations and browser setup

- file: /home/gwizz/wsl_projects/jerin/lt-146-improve-local-to-staging-pipeline/apps/web/tests/e2e/helpers/test-config.ts
  why: Test configuration patterns and environment-specific URLs
  critical: baseURL configurations for local/staging/production testing

- file: /home/gwizz/wsl_projects/jerin/lt-146-improve-local-to-staging-pipeline/api/tests/conftest.py
  why: Python testing setup with mocking and fixtures
  critical: Mock patterns for Supabase, OpenAI, and Gmail services

- file: /home/gwizz/wsl_projects/jerin/lt-146-improve-local-to-staging-pipeline/apps/web/tests/e2e/helpers/auth.helper.ts
  why: Authentication testing patterns with Clerk integration
  critical: Login/logout flows and JWT validation for authenticated tests

# MCP Tools Available
- doc: CLAUDE.md
  section: "MCP Tools Available"
  why: Playwright and Supabase MCP tools for enhanced testing automation
  critical: mcp__playwright__* and mcp__supabase__* tools for direct browser and database testing

# Living Tree Testing Commands
- file: /home/gwizz/wsl_projects/jerin/lt-146-improve-local-to-staging-pipeline/apps/web/package.json
  section: "scripts"
  why: Exact test commands for E2E testing across environments
  critical: pnpm test:e2e, pnpm test:e2e:staging, pnpm test:e2e:mobile commands

- file: /home/gwizz/wsl_projects/jerin/lt-146-improve-local-to-staging-pipeline/pyproject.toml
  section: "tool.pytest"
  why: Python testing configuration and commands
  critical: poetry run pytest commands and configuration options
```

### Current Codebase tree

```bash
.claude/agents/
├── README.md                    # Agent patterns and automation guidelines
├── code-generator.md            # Code generation agent (orchestrator target)
├── prp-executor.md             # Main orchestrator agent (triggers test agents)
├── prp-validation-gate-agent/   # Validation gate (triggers test agents)
│   └── prp-validation-gate-agent.md
├── test-runner.md              # Existing test runner (complementary)
├── test-writer.md              # Test creation agent (complementary)
└── validator.md                # Code validation agent (parallel workflow)

apps/web/tests/e2e/
├── flows/                      # User workflow tests (E2E target)
├── staging/                    # Environment-specific tests
├── helpers/                    # Test utilities and configuration
│   ├── auth.helper.ts         # Authentication testing patterns
│   └── test-config.ts         # Environment configurations
└── pages/                     # Page object models

api/tests/
├── fixtures/                   # Test data and mocks
├── test_*.py                  # Python test modules (integration targets)
└── conftest.py               # pytest configuration and mocking setup
```

### Desired Codebase tree with files to be added

```bash
.claude/agents/
├── prp-create-agent.md         # NEW: Automated PRP creation agent
├── e2e-test-runner.md          # NEW: Automated E2E test execution agent
├── integration-test-validator.md # NEW: Integration validation agent
└── [existing agents remain unchanged]

# No additional test files needed - agents use existing test infrastructure
# Agents will execute existing tests in apps/web/tests/ and api/tests/
# prp-create-agent will use existing PRP templates in PRPs/templates/
```

### Known Gotchas of our codebase & Library Quirks

```bash
# CRITICAL: Agent automation trigger patterns
# Agents must use "Use this agent when..." or "Use PROACTIVELY" in descriptions
# Example: "Use this agent when E2E tests are needed after code changes"

# CRITICAL: Living Tree testing commands are environment-specific
pnpm test:e2e                    # Local chromium only
ENVIRONMENT=staging pnpm test:e2e:staging  # Staging environment
poetry run pytest               # Backend tests in Docker context

# CRITICAL: Authentication in E2E tests requires Clerk setup
# Tests must use authHelper.loginWithClerk() before testing authenticated features
# JWT tokens are validated differently in test vs production environments

# CRITICAL: MCP tool integration
# Use mcp__playwright__* tools for enhanced browser automation
# Use mcp__supabase__* tools for database validation during integration tests

# CRITICAL: PRP Creation Agent triggers
# Use "Use this agent when users request features" or similar phrases for auto-triggering
# Must include Task tool to automatically invoke prp-quality-agent after PRP creation
# Follow .claude/commands/commands/prp-create.md methodology exactly

# CRITICAL: Agent chaining via Task tool
# Use Task tool with specific subagent_type to invoke other agents
# Example: Task(subagent_type="integration-test-validator", description="validate API integrations")
# Example: Task(subagent_type="prp-quality-agent", description="validate created PRP")

# CRITICAL: Environment detection
# Agents must detect and adapt to local/staging/production environments
# Use NEXT_PUBLIC_ENVIRONMENT variable and test-config.ts patterns

# CRITICAL: Failure reporting
# Test failures must include specific file paths, line numbers, and actionable fix recommendations
# Follow prp-validation-gate-agent report format for consistency
```

## Implementation Blueprint

### Data models and structure

Agents use existing test infrastructure - no new data models needed. Agents will work with:

```typescript
// Test result structures (existing)
interface TestResult {
  suite: string;
  passed: number;
  failed: number;
  coverage: number;
  issues: Array<{severity: string; description: string}>;
}

// Agent communication structure (new pattern)
interface AgentTriggerContext {
  triggerAgent: string;
  completedTasks: string[];
  results: any;
  nextSteps: string[];
  conditions: string[];
}
```

### List of tasks to be completed to fulfill the PRP in the order they should be completed

```yaml
Task 1: Create PRP Create Agent
CREATE .claude/agents/prp-create-agent.md:
  - COPY methodology from: .claude/commands/commands/prp-create.md
  - MODIFY description to include "Use this agent when users request new features or improvements"
  - ADD tools: Read, Glob, Grep, Task, TodoWrite, Write, WebFetch, WebSearch
  - FOLLOW PRP creation methodology exactly from commands/prp-create.md
  - INCLUDE comprehensive research and context curation process
  - ADD automatic Task tool usage to invoke prp-quality-agent after PRP creation
  - PRESERVE all research phases and quality gates from original command

Task 2: Create E2E Test Runner Agent
CREATE .claude/agents/e2e-test-runner.md:
  - COPY structure from: .claude/agents/test-runner.md
  - MODIFY description to include "Use this agent when E2E tests are needed after code changes or validation completion"
  - ADD tools: Bash, Read, mcp__playwright__*, Task
  - FOLLOW automation trigger patterns from README.md
  - INCLUDE environment detection and test execution logic
  - ADD integration with existing test commands (pnpm test:e2e, test:e2e:staging)

Task 3: Create Integration Test Validator Agent  
CREATE .claude/agents/integration-test-validator.md:
  - COPY validation report structure from: .claude/agents/prp-validation-gate-agent/prp-validation-gate-agent.md
  - MODIFY description to include "Use this agent when integration validation is needed after E2E test completion"
  - ADD tools: Bash, Read, mcp__supabase__*, mcp__playwright__*, Task
  - INCLUDE API testing, database validation, and auth flow testing
  - ADD comprehensive integration reporting format
  - INCLUDE escalation patterns for integration failures

Task 4: Update PRP Executor for Agent Chaining
MODIFY .claude/agents/prp-executor.md:
  - FIND section: "Orchestration patterns"
  - ADD after existing patterns: "PRP Creation: prp-create-agent → prp-quality-agent"
  - ADD after existing patterns: "Testing: e2e-test-runner → integration-test-validator → deployment-gate"
  - FIND section: "Success criteria"  
  - ADD: "All PRP creation and testing agents complete successfully"
  - PRESERVE existing workflow patterns

Task 5: Update Validation Gate Agent for Test Triggering
MODIFY .claude/agents/prp-validation-gate-agent/prp-validation-gate-agent.md:
  - FIND section: "Phase 5: Documentation & Deployment Readiness"
  - ADD after existing phases: "Phase 6: Trigger Comprehensive Testing"
  - INJECT: Task tool usage to automatically invoke e2e-test-runner
  - PRESERVE existing validation workflow
```

### Per task pseudocode as needed added to each task

```markdown
# Task 1: PRP Create Agent Structure
---
name: prp-create-agent
description: Use this agent when users request new features or improvements. Automatically creates comprehensive PRPs following established methodology and triggers quality validation.
tools: Read, Glob, Grep, Task, TodoWrite, Write, WebFetch, WebSearch
model: opus
---

# PATTERN: Auto-trigger based on user feature requests
# PATTERN: Follow .claude/commands/commands/prp-create.md methodology exactly
# PATTERN: Use Task tool to automatically invoke prp-quality-agent after completion

# Pseudocode structure:
async def create_prp(feature_request):
    # CRITICAL: Follow exact methodology from prp-create.md
    # Phase 1: Understand PRP concepts
    await read_file("PRPs/README.md")
    
    # Phase 2: Deep research process with agent spawning
    codebase_analysis = await spawn_research_agents("codebase")
    external_research = await spawn_research_agents("external")
    
    # Phase 3: Create comprehensive PRP using template
    template = await read_file("PRPs/templates/prp_base.md")
    prp_content = await generate_prp_with_research(template, research_data)
    
    # Phase 4: Save PRP and trigger quality validation
    prp_file = await write_file(f"PRPs/{feature_name}.md", prp_content)
    await trigger_agent("prp-quality-agent", {"prp_file": prp_file})

# Task 2: E2E Test Runner Agent Structure
---
name: e2e-test-runner
description: Use this agent when comprehensive E2E tests are needed after code changes, validation completion, or deployment events. Automatically triggers integration validation after test completion.
tools: Bash, Read, mcp__playwright__*, Task
model: sonnet
---

# PATTERN: Auto-trigger based on context (see test-runner.md for examples)
# PATTERN: Environment detection using NEXT_PUBLIC_ENVIRONMENT
# PATTERN: Use existing test commands (see package.json scripts)

# Pseudocode structure:
async def execute_e2e_tests(context):
    # CRITICAL: Detect environment (local/staging/production)
    environment = detect_environment()
    
    # PATTERN: Use Living Tree specific commands
    if environment == "staging":
        await bash_execute("ENVIRONMENT=staging pnpm test:e2e:staging")
    else:
        await bash_execute("pnpm test:e2e")
    
    # PATTERN: Parse results and trigger next agent
    results = parse_test_results()
    if results.has_integration_failures or results.needs_validation:
        await trigger_agent("integration-test-validator", results)

# Task 2: Integration Test Validator Structure  
---
name: integration-test-validator
description: Use this agent when integration validation is needed after E2E test completion, API changes, or database migrations. Validates system integrations and reports comprehensive status.
tools: Bash, Read, mcp__supabase__*, mcp__playwright__*, Task
model: sonnet
---

# PATTERN: Comprehensive validation reporting (see prp-validation-gate-agent)
# PATTERN: Use MCP tools for enhanced validation
# PATTERN: Multi-source validation integration

# Pseudocode structure:
async def validate_integrations(context):
    # CRITICAL: Validate API integrations
    api_status = await validate_api_endpoints()
    
    # CRITICAL: Validate database integrations using MCP
    db_status = await mcp_supabase_execute_sql("SELECT 1")
    
    # CRITICAL: Validate auth flow using Playwright MCP
    auth_status = await mcp_playwright_test_auth_flow()
    
    # PATTERN: Generate comprehensive report (see validation-gate format)
    report = generate_validation_report(api_status, db_status, auth_status)
    
    # PATTERN: Trigger next steps based on results
    if report.all_passed:
        await trigger_agent("deployment-gatekeeper", report)
    else:
        await trigger_agent("alert-manager", report)
```

### Integration Points

```yaml
AGENT_ECOSYSTEM:
  - modify: .claude/agents/prp-executor.md
  - pattern: "Add e2e-test-runner to orchestration workflows"
  - integration: "Sequential testing after validation gates"

  - modify: .claude/agents/prp-validation-gate-agent/prp-validation-gate-agent.md  
  - pattern: "Add Task tool usage to trigger e2e-test-runner"
  - integration: "Automatic test execution after validation completion"

TEST_INFRASTRUCTURE:
  - use: apps/web/tests/e2e/ (existing E2E tests)
  - use: api/tests/ (existing integration tests)
  - pattern: "Agents execute existing tests, don't create new ones"

MCP_TOOLS:
  - integrate: mcp__playwright__* for enhanced E2E testing
  - integrate: mcp__supabase__* for database validation
  - pattern: "Use MCP tools for capabilities beyond basic Bash execution"

ENVIRONMENT_CONFIG:
  - use: apps/web/tests/e2e/helpers/test-config.ts
  - pattern: "Environment detection and URL configuration"
  - critical: "Adapt test execution to local/staging/production contexts"
```

## Validation Loop

### Level 1: Agent Structure & Syntax

```bash
# Validate agent YAML front matter structure
head -10 .claude/agents/e2e-test-runner.md
head -10 .claude/agents/integration-test-validator.md

# Expected: Valid YAML with name, description, tools, model
# Pattern: description must include "Use this agent when..." for auto-triggering
# Tools: Must include Task tool for agent chaining
```

### Level 2: Agent Integration Testing

```bash
# Test that agents can be discovered
# In Claude Code, run:
/agents

# Expected: Both new agents listed in available agents
# Test: Description triggers should be clear and specific
# Test: Tool permissions should be appropriate for each agent
```

### Level 3: Automation Workflow Testing

```bash
# Test E2E agent triggers and executes tests
# Create test scenario that should trigger e2e-test-runner
pnpm test:e2e:staging

# Expected: Agent automatically triggers and executes tests
# Expected: Results reported in structured format
# Expected: Integration validator triggered based on results

# Test integration validator execution
# Expected: API, database, and auth validations execute
# Expected: Comprehensive validation report generated
# Expected: Appropriate next steps triggered based on results
```

### Level 4: End-to-End Agent Workflow Validation

```bash
# Test complete agent chain: prp-validation-gate → e2e-test-runner → integration-test-validator
# Start with completed PRP that should trigger testing workflow

# Expected workflow:
# 1. prp-validation-gate-agent completes validation
# 2. e2e-test-runner automatically triggers and runs E2E tests
# 3. integration-test-validator automatically triggers and validates integrations
# 4. Results and next steps communicated clearly

# Validate with MCP tools integration
# Expected: Agents successfully use mcp__playwright__* and mcp__supabase__* tools
# Expected: Enhanced testing capabilities beyond basic Bash execution
```

## Final validation Checklist

- [ ] PRP Create Agent created with proper YAML front matter and follows prp-create.md methodology
- [ ] PRP Create Agent automatically triggers prp-quality-agent after PRP creation
- [ ] E2E Test Runner agent created with proper YAML front matter and automation triggers
- [ ] Integration Test Validator agent created with comprehensive validation capabilities  
- [ ] All three agents use appropriate tool restrictions and Living Tree specific commands
- [ ] Automation triggers work: agents auto-invoke when conditions are met
- [ ] Agent chaining works: prp-create → prp-quality → e2e-test-runner → integration-test-validator
- [ ] PRP creation follows established methodology and creates high-quality PRPs
- [ ] Test execution works in all environments: local, staging, production
- [ ] MCP tool integration works: Playwright and Supabase tools enhance testing capabilities
- [ ] Failure handling and reporting follows established patterns from existing agents
- [ ] Integration with existing agent ecosystem: prp-executor and prp-validation-gate-agent properly trigger new agents
- [ ] All validation commands execute successfully: `pnpm test:e2e`, `poetry run pytest`
- [ ] Agent discovery works: `/agents` command shows all three new agents with clear descriptions
- [ ] Complete automation pipeline works: feature request → PRP creation → quality validation → testing

---

## Anti-Patterns to Avoid

- ❌ Don't deviate from prp-create.md methodology - follow the established PRP creation process exactly
- ❌ Don't create new test files - use existing test infrastructure
- ❌ Don't hardcode environment URLs - use test-config.ts patterns
- ❌ Don't skip MCP tool integration - leverage enhanced testing capabilities  
- ❌ Don't ignore existing agent patterns - follow established trigger and reporting formats
- ❌ Don't create agents that require manual invocation - ensure automatic triggering works
- ❌ Don't skip comprehensive reporting - follow validation-gate-agent report format
- ❌ Don't ignore failure handling - include proper escalation and error reporting
- ❌ Don't break existing agent workflows - integrate seamlessly with current ecosystem
- ❌ Don't skip PRP quality validation - always trigger prp-quality-agent after PRP creation
- ❌ Don't create incomplete PRPs - ensure research depth matches original methodology standards