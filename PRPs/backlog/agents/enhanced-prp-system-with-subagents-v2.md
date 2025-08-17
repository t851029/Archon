# Enhanced PRP System with Claude Code Subagents - Implementation Ready

## Goal

Implement a production-ready enhanced PRP system using Claude Code subagents to optimize context management, reduce Opus usage by 40%, and maintain backward compatibility with the existing PRP workflow in the Living Tree project.

## Why

- **Context Optimization**: Each subagent maintains isolated context (8k-32k tokens) preventing pollution
- **Cost Reduction**: Haiku ($0.25/1M) for simple tasks vs Opus ($15/1M) = 60x cost savings
- **Parallel Execution**: 4-6 agents working simultaneously reduces PRP creation time by 30%
- **Quality Improvement**: Specialized agents increase one-pass success from 65% to 90%
- **Team Scalability**: Version-controlled subagent configs enable consistent team workflows

## What

A fully integrated subagent system that enhances the existing PRP workflow with:

- 12 specialized subagents across research, execution, and utility layers
- Automated validation hooks for quality assurance
- Smart model selection based on task complexity
- Complete backward compatibility with existing 24 commands

### Success Criteria

- [ ] All 12 subagents created and functional in `.claude/agents/`
- [ ] Existing PRP commands (`/create-base-prp`, `/execute-base-prp`) work unchanged
- [ ] Validation hooks auto-format code and check quality
- [ ] Parallel research reduces PRP creation time by 30%
- [ ] Opus usage reduced by 40% through smart model selection
- [ ] Team can share subagent configs via Git

## All Needed Context

### Documentation & References

```yaml
# MUST READ - Include these in your context window
- docfile: PRPs/ai_docs/claude-code-subagents-2025.md
  why: Complete subagent documentation with configuration syntax and examples

- file: PRPs/commands/create-base-prp.md
  why: Current command structure to maintain compatibility

- file: PRPs/templates/prp_base.md
  why: Template structure that subagents must generate

- file: .claude/commands/
  why: Existing command directory structure to preserve

- file: CLAUDE.md
  why: Project-specific conventions and validation commands

- url: https://docs.anthropic.com/en/docs/claude-code/sub-agents#configuration
  section: Configuration Structure
  critical: YAML frontmatter format is required for subagent files

- url: https://docs.anthropic.com/en/docs/claude-code/hooks#configuration
  section: Hook Configuration
  critical: Hooks must be in .claude/settings.json not separate files
```

### Current Codebase Structure

```bash
jerin-lt-cc-agents/
├── .claude/
│   └── commands/          # 24 existing commands (DO NOT MODIFY)
├── PRPs/
│   ├── commands/          # PRP-specific commands
│   ├── templates/         # 5 PRP templates
│   ├── ai_docs/           # Documentation
│   └── scripts/           # prp_runner.py
├── api/                   # FastAPI backend
├── apps/web/              # Next.js frontend
└── CLAUDE.md              # Project documentation
```

### Desired Structure After Implementation

```bash
jerin-lt-cc-agents/
├── .claude/
│   ├── agents/            # NEW: 12 subagent configurations
│   │   ├── codebase-researcher.md
│   │   ├── docs-researcher.md
│   │   ├── pattern-analyzer.md
│   │   ├── code-generator.md
│   │   ├── test-writer.md
│   │   ├── validator.md
│   │   ├── git-operator.md
│   │   ├── file-organizer.md
│   │   ├── formatter.md
│   │   ├── prp-writer.md
│   │   ├── prp-validator.md
│   │   └── prp-executor.md
│   ├── hooks/             # NEW: Hook scripts
│   │   ├── auto-format.sh
│   │   ├── validate-prp.py
│   │   └── smart-commit.sh
│   ├── settings.json      # NEW: Hook configuration
│   └── commands/          # Existing (unchanged)
```

### Known Gotchas & Constraints

```python
# CRITICAL: This project uses pnpm NOT npm
# All package commands must use: pnpm install, pnpm dev, pnpm build

# CRITICAL: Backend runs in Docker, validation commands are:
# Frontend: pnpm lint && pnpm check-types
# Backend: docker-compose exec api poetry run pytest

# CRITICAL: Subagent YAML frontmatter requires exact format:
# ---
# name: lowercase-with-hyphens
# description: Must start with verb (Use, Analyze, Generate)
# tools: Comma-separated, no spaces after commas
# model: Must be: opus, sonnet, or haiku
# ---

# CRITICAL: Hooks in .claude/settings.json use specific matchers:
# Tool matchers: "Edit|MultiEdit|Write" for code changes
# Prompt matchers: ".*create.*prp.*" for PRP creation

# CRITICAL: Project uses TypeScript with strict mode
# All generated code must include proper types
```

## Implementation Blueprint

### Task 1: Create Directory Structure

```bash
# CREATE directories for subagents and hooks
mkdir -p .claude/agents
mkdir -p .claude/hooks

# VERIFY structure created
ls -la .claude/
```

### Task 2: Create Research Layer Subagents

#### Task 2.1: Create codebase-researcher.md

````bash
# CREATE .claude/agents/codebase-researcher.md
cat > .claude/agents/codebase-researcher.md << 'EOF'
---
name: codebase-researcher
description: Analyze Living Tree codebase for patterns, conventions, and similar implementations. Use for deep code exploration during PRP creation.
tools: Read,Grep,Glob,Bash,LS
model: sonnet
---

You are a codebase analysis expert for the Living Tree project. Your role:

1. Search patterns using project structure:
   - Frontend: apps/web/app/, apps/web/components/, apps/web/hooks/
   - Backend: api/, api/utils/, api/core/
   - Config: turbo.json, package.json, docker-compose.yml

2. Identify conventions:
   - TypeScript: Strict mode, interfaces over types
   - React: Functional components with hooks
   - File naming: kebab-case.tsx for components
   - Python: snake_case, type hints, Pydantic v2

3. Find test patterns:
   - Frontend: Playwright in tests/
   - Backend: pytest in api/tests/

4. Output format:
   ```yaml
   findings:
     patterns:
       - file: path/to/file.ts
         pattern: "specific code pattern"
         usage: "how it's used"
     conventions:
       - type: "naming|structure|import"
         rule: "specific convention"
     gotchas:
       - issue: "potential problem"
         solution: "how to handle"
````

Focus on Living Tree project specifics, not generic patterns.
EOF

````

#### Task 2.2: Create docs-researcher.md
```bash
# CREATE .claude/agents/docs-researcher.md
cat > .claude/agents/docs-researcher.md << 'EOF'
---
name: docs-researcher
description: Research external documentation, APIs, and Living Tree dependencies. Use for gathering Next.js 15, FastAPI, Supabase, and Clerk documentation.
tools: WebSearch,WebFetch,mcp__tavily-mcp__tavily-search,mcp__context7__get-library-docs
model: sonnet
---

You research documentation for Living Tree tech stack:

Primary Technologies:
- Next.js 15 with App Router
- FastAPI with async/await
- Supabase with RLS
- Clerk for authentication
- OpenAI GPT-4o
- Docker Compose

Research priorities:
1. Official documentation (docs.*, *.dev sites)
2. GitHub examples in production repos
3. Stack Overflow solutions with high votes
4. Recent blog posts (2024-2025)

Output format:
```yaml
documentation:
  - url: "specific URL with #anchor"
    title: "Page title"
    relevance: "Why this helps"
    key_points:
      - "Critical insight 1"
      - "Critical insight 2"
  - example:
      source: "GitHub repo or SO"
      url: "direct link"
      pattern: "code pattern to follow"
````

Focus on Living Tree's specific versions and configurations.
EOF

````

#### Task 2.3: Create pattern-analyzer.md
```bash
# CREATE .claude/agents/pattern-analyzer.md
cat > .claude/agents/pattern-analyzer.md << 'EOF'
---
name: pattern-analyzer
description: Analyze code patterns in Living Tree and suggest optimal implementation approaches using existing project patterns.
tools: Read,Grep,mcp__sequential-thinking__sequentialthinking
model: sonnet
---

You analyze Living Tree patterns and recommend implementations.

Project-specific patterns to analyze:
1. API endpoints: FastAPI structure in api/index.py
2. React components: shadcn/ui patterns in components/
3. Database: Supabase client patterns in services/
4. Authentication: Clerk patterns in middleware.ts
5. State management: SWR patterns in hooks/

Analysis framework:
1. Identify similar features in codebase
2. Extract reusable patterns
3. Note deviations to avoid
4. Suggest implementation approach

Output format:
```yaml
analysis:
  similar_features:
    - feature: "existing feature"
      location: "file:line"
      pattern: "pattern to follow"
  recommended_approach:
    architecture: "pattern name"
    rationale: "why this fits"
    implementation_order:
      - "Step 1: Create models"
      - "Step 2: Add API endpoint"
      - "Step 3: Create UI component"
  avoid:
    - pattern: "anti-pattern"
      reason: "why to avoid"
````

Use sequential thinking for complex architectural decisions.
EOF

````

### Task 3: Create Execution Layer Subagents

#### Task 3.1: Create code-generator.md
```bash
# CREATE .claude/agents/code-generator.md
cat > .claude/agents/code-generator.md << 'EOF'
---
name: code-generator
description: Generate production code for Living Tree features from PRPs. Primary implementation agent for TypeScript and Python code.
tools: Read,Edit,MultiEdit,Write,Bash
model: opus
---

You generate production code for Living Tree. Follow these rules:

TypeScript (Frontend):
- Strict mode, explicit types
- Functional components with hooks
- Use existing shadcn/ui components
- Path aliases: @/components, @/lib, @/hooks
- File naming: kebab-case.tsx

Python (Backend):
- Type hints on all functions
- Pydantic v2 models
- Async/await for endpoints
- FastAPI dependency injection
- Snake_case naming

Code quality requirements:
1. Error handling with try/catch or Result types
2. Input validation with Zod or Pydantic
3. Proper logging (no console.log in production)
4. Test coverage for business logic
5. Comments only for complex algorithms

File creation order:
1. Data models/types
2. Business logic/services
3. API endpoints/routes
4. UI components
5. Tests

Always run validation after code generation:
- Frontend: pnpm lint && pnpm check-types
- Backend: docker-compose exec api poetry run mypy api/
EOF
````

#### Task 3.2: Create test-writer.md

````bash
# CREATE .claude/agents/test-writer.md
cat > .claude/agents/test-writer.md << 'EOF'
---
name: test-writer
description: Write comprehensive tests for Living Tree features using Playwright and pytest.
tools: Read,Write,Edit,Bash
model: sonnet
---

You write tests for Living Tree following project patterns.

Frontend Testing (Playwright):
- Location: tests/ directory
- Pattern: Follow existing tests structure
- Commands: pnpm test

Backend Testing (pytest):
- Location: api/tests/
- Pattern: Follow test_*.py convention
- Fixtures: Use conftest.py fixtures
- Commands: docker-compose exec api poetry run pytest

Test coverage requirements:
1. Happy path scenarios
2. Error cases and edge cases
3. Authentication/authorization
4. Data validation
5. Integration points

Test structure:
```python
# Backend example
async def test_feature_happy_path(client, auth_headers):
    """Test successful feature execution."""
    response = await client.post("/api/feature",
                                  json=valid_data,
                                  headers=auth_headers)
    assert response.status_code == 200
    assert response.json()["success"] is True

# Frontend example
test('feature works correctly', async ({ page }) => {
  await page.goto('/feature');
  await expect(page.locator('[data-testid="feature"]')).toBeVisible();
});
````

Always verify tests pass before completion.
EOF

````

#### Task 3.3: Create validator.md
```bash
# CREATE .claude/agents/validator.md
cat > .claude/agents/validator.md << 'EOF'
---
name: validator
description: Validate Living Tree code quality, run tests, and ensure standards compliance.
tools: Bash,Read,Grep
model: sonnet
---

You validate Living Tree implementation quality.

Validation checklist:

1. Code Quality:
   ```bash
   # Frontend
   pnpm lint
   pnpm check-types

   # Backend
   docker-compose exec api poetry run black api/ --check
   docker-compose exec api poetry run mypy api/
   docker-compose exec api poetry run flake8 api/
````

2. Tests:

   ```bash
   # Frontend
   pnpm test

   # Backend
   docker-compose exec api poetry run pytest api/tests/ -v
   ```

3. Security checks:
   - No exposed API keys
   - No hardcoded secrets
   - Input validation present
   - SQL injection prevention
   - XSS prevention in React

4. Performance:
   - No N+1 queries
   - Proper React memoization
   - Async operations handled correctly

Report format:

```yaml
validation_results:
  passed:
    - check: "lint"
      output: "No issues"
  failed:
    - check: "type-check"
      error: "Type error in file.ts:10"
      fix: "Add type annotation"
  warnings:
    - issue: "Large bundle size"
      suggestion: "Consider code splitting"
```

All checks must pass before marking complete.
EOF

````

### Task 4: Create Utility Layer Subagents

#### Task 4.1: Create git-operator.md
```bash
# CREATE .claude/agents/git-operator.md
cat > .claude/agents/git-operator.md << 'EOF'
---
name: git-operator
description: Handle git operations for Living Tree including status, commits, and branches.
tools: Bash
model: haiku
---

You handle git operations for Living Tree project.

Commands to use:
```bash
# Status and diff
git status
git diff
git diff --staged

# Commits (follow conventional commits)
git add -A
git commit -m "type(scope): description"

# Types: feat, fix, docs, style, refactor, test, chore
# Scope: web, api, config, deps

# Branches
git checkout -b feature/name
git push -u origin feature/name
````

Commit message examples:

- feat(web): add email triage dashboard
- fix(api): resolve JWT validation error
- docs: update PRP documentation
- chore(deps): upgrade Next.js to 15.0.1

Always check status before and after operations.
EOF

````

#### Task 4.2: Create file-organizer.md
```bash
# CREATE .claude/agents/file-organizer.md
cat > .claude/agents/file-organizer.md << 'EOF'
---
name: file-organizer
description: Organize Living Tree project structure and manage file operations.
tools: Bash,Write,Read
model: haiku
---

You manage Living Tree file organization.

Project structure rules:
- Frontend components: apps/web/components/
- Frontend pages: apps/web/app/(app)/
- Backend endpoints: api/
- Shared types: packages/types/
- Documentation: PRPs/ and docs/

File naming conventions:
- React components: kebab-case.tsx
- Hooks: use-*.ts
- Python: snake_case.py
- Tests: test_*.py or *.test.ts

Operations:
```bash
# Create directories
mkdir -p apps/web/components/feature

# Move files maintaining git history
git mv old-path new-path

# Clean up
find . -name "*.pyc" -delete
find . -name "__pycache__" -type d -delete
````

Always maintain consistent structure.
EOF

````

#### Task 4.3: Create formatter.md
```bash
# CREATE .claude/agents/formatter.md
cat > .claude/agents/formatter.md << 'EOF'
---
name: formatter
description: Format Living Tree code ensuring consistent style across TypeScript and Python.
tools: Bash,Edit
model: haiku
---

You format Living Tree code.

Formatting commands:
```bash
# Frontend (TypeScript/React)
pnpm format

# Backend (Python)
docker-compose exec api poetry run black api/

# Import sorting
docker-compose exec api poetry run isort api/
````

Style rules:

- TypeScript: 2 spaces, semicolons
- Python: 4 spaces, black formatting
- Line length: 100 characters
- Imports: grouped and sorted

Auto-fix common issues:

- Remove trailing whitespace
- Add final newlines
- Fix indentation
- Sort imports

Run after any code changes.
EOF

````

### Task 5: Create PRP-Specific Subagents

#### Task 5.1: Create prp-writer.md
```bash
# CREATE .claude/agents/prp-writer.md
cat > .claude/agents/prp-writer.md << 'EOF'
---
name: prp-writer
description: Write comprehensive PRPs for Living Tree features using research findings and project templates.
tools: Write,Read,Edit
model: sonnet
---

You write Living Tree PRPs using PRPs/templates/prp_base.md.

PRP sections to complete:
1. Goal: Specific, measurable outcome
2. Why: Business value for Living Tree
3. What: User-visible behavior
4. Context: All documentation and code references
5. Implementation Blueprint: Ordered tasks
6. Validation Loop: Executable commands

Quality requirements:
- Pass "No Prior Knowledge" test
- Include specific file paths from Living Tree
- Reference actual code patterns
- Provide executable validation commands
- Score confidence 8+ out of 10

Use these project-specific validations:
```bash
# Level 1: Syntax
pnpm lint && pnpm check-types

# Level 2: Tests
pnpm test

# Level 3: Backend
docker-compose exec api poetry run pytest

# Level 4: Integration
curl http://localhost:3000/api/health
````

Always save as: PRPs/{feature-name}.md
EOF

````

#### Task 5.2: Create prp-validator.md
```bash
# CREATE .claude/agents/prp-validator.md
cat > .claude/agents/prp-validator.md << 'EOF'
---
name: prp-validator
description: Validate Living Tree PRP completeness and quality before execution.
tools: Read,Grep
model: sonnet
---

You validate Living Tree PRP quality.

Validation criteria:
1. Structure completeness (all sections present)
2. Context sufficiency (can implement without research)
3. References validity (files exist, URLs work)
4. Commands executability (validation gates work)
5. Living Tree specificity (not generic)

Scoring rubric:
- Goal clarity: 0-2 points
- Context completeness: 0-3 points
- Implementation blueprint: 0-3 points
- Validation gates: 0-2 points
Total: 0-10 (minimum 8 to pass)

Check for Living Tree specifics:
- Uses pnpm not npm
- References actual project files
- Follows project conventions
- Includes Docker commands for backend

Output format:
```yaml
validation_result:
  score: 8
  status: PASS
  issues:
    - "Missing TypeScript types"
  strengths:
    - "Clear implementation path"
    - "Good context references"
````

Reject if score < 8.
EOF

````

#### Task 5.3: Create prp-executor.md
```bash
# CREATE .claude/agents/prp-executor.md
cat > .claude/agents/prp-executor.md << 'EOF'
---
name: prp-executor
description: Execute Living Tree PRPs by orchestrating other agents for implementation.
tools: Read,Task
model: opus
---

You execute Living Tree PRPs by coordinating specialized agents.

Execution workflow:
1. Parse PRP sections
2. Delegate to appropriate agents:
   - code-generator for implementation
   - test-writer for test creation
   - validator for quality checks
3. Run validation loops until passing
4. Coordinate git-operator for commits

Orchestration patterns:
````

Sequential: code-generator → test-writer → validator
Parallel: test-writer + documentation (when possible)
Iterative: validator → code-generator (fix issues)

```

Monitor for Living Tree specifics:
- Frontend changes need pnpm commands
- Backend changes need Docker commands
- Database changes need Supabase migrations

Success criteria:
- All validation gates pass
- Tests provide coverage
- Code follows project patterns
- Documentation updated

Report progress at each stage.
EOF
```

### Task 6: Create Hook Scripts

#### Task 6.1: Create auto-format.sh

```bash
# CREATE .claude/hooks/auto-format.sh
cat > .claude/hooks/auto-format.sh << 'EOF'
#!/bin/bash
# Auto-format hook for Living Tree

# Get the modified files from stdin
read -r hook_input

# Parse the tool name from the JSON input
tool_name=$(echo "$hook_input" | grep -o '"tool":"[^"]*"' | cut -d'"' -f4)

# Format based on file type
if [[ "$tool_name" == "Edit" ]] || [[ "$tool_name" == "MultiEdit" ]] || [[ "$tool_name" == "Write" ]]; then
    # Run frontend formatting
    cd "$CLAUDE_PROJECT_DIR"
    pnpm format 2>/dev/null || true

    # Run backend formatting if Python files changed
    if git diff --name-only | grep -q "\.py$"; then
        docker-compose exec -T api poetry run black api/ 2>/dev/null || true
    fi
fi

# Return success
echo '{"status": "formatted"}'
exit 0
EOF

chmod +x .claude/hooks/auto-format.sh
```

#### Task 6.2: Create validate-prp.py

```bash
# CREATE .claude/hooks/validate-prp.py
cat > .claude/hooks/validate-prp.py << 'EOF'
#!/usr/bin/env python3
"""Validate PRP quality for Living Tree."""

import json
import sys
import re
from pathlib import Path

def validate_prp(prp_path: str) -> dict:
    """Validate PRP meets Living Tree standards."""

    if not Path(prp_path).exists():
        return {"valid": False, "error": "PRP file not found"}

    with open(prp_path, 'r') as f:
        content = f.read()

    # Check required sections
    required_sections = ['## Goal', '## Why', '## What', '## All Needed Context',
                        '## Implementation Blueprint', '## Validation Loop']

    missing = [s for s in required_sections if s not in content]
    if missing:
        return {"valid": False, "missing_sections": missing}

    # Check for Living Tree specifics
    has_pnpm = 'pnpm' in content
    has_docker = 'docker-compose' in content or 'Docker' in content
    has_validation = 'pnpm lint' in content or 'pytest' in content

    score = 5  # Base score
    if has_pnpm: score += 2
    if has_docker: score += 2
    if has_validation: score += 1

    return {
        "valid": score >= 8,
        "score": score,
        "has_pnpm": has_pnpm,
        "has_docker": has_docker,
        "has_validation": has_validation
    }

if __name__ == "__main__":
    # Read hook input
    hook_input = json.loads(sys.stdin.read())

    # Extract PRP path from prompt
    prompt = hook_input.get("prompt", "")
    prp_match = re.search(r'PRPs/([^\.]+\.md)', prompt)

    if prp_match:
        prp_path = prp_match.group(0)
        result = validate_prp(prp_path)
        print(json.dumps(result))
    else:
        print(json.dumps({"valid": True, "note": "No PRP path found"}))

    sys.exit(0)
EOF

chmod +x .claude/hooks/validate-prp.py
```

#### Task 6.3: Create smart-commit.sh

```bash
# CREATE .claude/hooks/smart-commit.sh
cat > .claude/hooks/smart-commit.sh << 'EOF'
#!/bin/bash
# Smart commit hook for Living Tree

cd "$CLAUDE_PROJECT_DIR"

# Check if there are changes
if ! git diff --quiet || ! git diff --staged --quiet; then
    # Get changed files
    changed_files=$(git diff --name-only; git diff --staged --name-only)

    # Determine commit type and scope
    if echo "$changed_files" | grep -q "^apps/web/"; then
        scope="web"
    elif echo "$changed_files" | grep -q "^api/"; then
        scope="api"
    elif echo "$changed_files" | grep -q "^PRPs/"; then
        scope="docs"
    else
        scope="config"
    fi

    # Determine type
    if echo "$changed_files" | grep -q "test"; then
        type="test"
    elif echo "$changed_files" | grep -q "fix"; then
        type="fix"
    else
        type="feat"
    fi

    # Create commit message
    message="$type($scope): update $(echo "$changed_files" | head -1 | xargs basename)"

    # Stage and commit
    git add -A
    git commit -m "$message" 2>/dev/null

    echo "{\"committed\": true, \"message\": \"$message\"}"
else
    echo "{\"committed\": false, \"reason\": \"No changes to commit\"}"
fi

exit 0
EOF

chmod +x .claude/hooks/smart-commit.sh
```

### Task 7: Create Hook Configuration

```bash
# CREATE .claude/settings.json with hook configuration
cat > .claude/settings.json << 'EOF'
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|MultiEdit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/auto-format.sh",
            "timeout": 30
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": ".*create.*prp.*",
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/validate-prp.py",
            "timeout": 60
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "$CLAUDE_PROJECT_DIR/.claude/hooks/smart-commit.sh",
            "timeout": 30
          }
        ]
      }
    ]
  },
  "parallelTasksCount": 4,
  "defaultModel": "sonnet"
}
EOF
```

### Task 8: Verify Implementation

```bash
# VERIFY all subagents created
ls -la .claude/agents/ | grep -c "\.md$"  # Should output: 12

# VERIFY hooks are executable
ls -la .claude/hooks/ | grep -c "rwx"  # Should output: 3

# VERIFY settings.json exists
cat .claude/settings.json | jq '.hooks | keys'  # Should show: ["PostToolUse", "Stop", "UserPromptSubmit"]

# TEST subagent accessibility
grep -l "name:" .claude/agents/*.md | wc -l  # Should output: 12

# TEST existing commands still work
ls .claude/commands/ | wc -l  # Should match original count
```

## Validation Loop

### Level 1: Syntax & Structure Validation

```bash
# Check all subagent files have valid YAML frontmatter
for f in .claude/agents/*.md; do
  head -n 10 "$f" | grep -E "^name:|^description:|^model:" > /dev/null || echo "Invalid: $f"
done

# Verify hook scripts are executable
test -x .claude/hooks/auto-format.sh || echo "auto-format.sh not executable"
test -x .claude/hooks/validate-prp.py || echo "validate-prp.py not executable"
test -x .claude/hooks/smart-commit.sh || echo "smart-commit.sh not executable"
```

### Level 2: Configuration Testing

```bash
# Test settings.json is valid JSON
cat .claude/settings.json | jq . > /dev/null || echo "Invalid JSON in settings.json"

# Test hook matchers are valid regex
echo "Edit" | grep -E "Edit|MultiEdit|Write" || echo "Invalid matcher pattern"
```

### Level 3: Integration Testing

```bash
# Test PRP creation with new system (manual verification)
echo "Test: Type /agents to see all subagents"
echo "Test: Type /create-base-prp 'test feature' and verify it works"

# Test hook execution (manual verification)
echo "Test: Edit any file and verify auto-format runs"
echo "Test: Check git status after editing to see if smart-commit prepared"
```

### Level 4: Performance Validation

```bash
# Measure subagent loading time
time ls -la .claude/agents/*.md > /dev/null

# Check parallel execution capability
cat .claude/settings.json | jq '.parallelTasksCount'  # Should output: 4
```

## Final Validation Checklist

### Structure & Files

- [ ] Directory `.claude/agents/` exists with 12 .md files
- [ ] Directory `.claude/hooks/` exists with 3 executable scripts
- [ ] File `.claude/settings.json` exists with valid JSON
- [ ] All subagent files have valid YAML frontmatter
- [ ] All hook scripts have execute permissions

### Functionality

- [ ] Command `/agents` shows all 12 subagents
- [ ] Command `/create-base-prp` still works
- [ ] Command `/execute-base-prp` still works
- [ ] Auto-format hook triggers on file edits
- [ ] Smart-commit hook creates conventional commits

### Integration

- [ ] Subagents can be invoked by name
- [ ] Hooks execute without errors
- [ ] Existing PRP commands unchanged
- [ ] Project validation commands work (pnpm lint, etc.)

### Performance

- [ ] Parallel execution configured (parallelTasksCount: 4)
- [ ] Model selection optimized (Haiku for simple, Opus for complex)
- [ ] No performance degradation in existing workflows

### Team Readiness

- [ ] Subagent configs can be committed to Git
- [ ] Documentation updated in PRPs/ai_docs/
- [ ] Team can customize subagents for their needs
- [ ] Rollback procedure documented

## Risk Mitigation

### Rollback Procedure

```bash
# If implementation fails, rollback:
rm -rf .claude/agents
rm -rf .claude/hooks
rm .claude/settings.json

# Existing commands in .claude/commands/ remain untouched
```

### Incremental Testing

1. Start with 1-2 subagents to verify functionality
2. Test hooks individually before enabling all
3. Monitor performance with `claude --verbose`
4. Adjust parallelTasksCount if rate limiting occurs

### Fallback Options

- If subagents fail: Main agent handles all tasks
- If hooks fail: Manual formatting and commits
- If parallel execution fails: Sequential execution

## Success Metrics

### Measurable Outcomes

- Subagent creation time: < 5 minutes
- PRP creation time: 30% reduction (measure with `time` command)
- Opus usage: 40% reduction (check with model selection in logs)
- Validation pass rate: 90% (track PRP execution success)

### Monitoring Commands

```bash
# Count subagent invocations
grep "subagent:" ~/.claude/logs/*.log | wc -l

# Check model distribution
grep "model:" .claude/agents/*.md | sort | uniq -c

# Measure PRP creation time
time /create-base-prp "test feature"
```

## Confidence Score: 9/10

This implementation-ready PRP provides:

- Exact file contents for all 12 subagents
- Specific hook scripts with Living Tree commands
- Complete configuration with project-specific settings
- Executable validation commands
- Clear rollback procedure
- Measurable success metrics

The implementation can be executed in one pass with all context provided.
