# SPEC PRP: Monorepo Cleanup and Organization

## Specification

This PRP addresses the accumulation of straggler files, misplaced documentation, and disorganized directories in the Living Tree monorepo. The goal is to establish a clean, maintainable structure that follows monorepo best practices.

## Current State Assessment

### Root Directory Issues

```yaml
current_state:
  files:
    - linear-lt-138-update.md # Task-specific file in root
    - backend-service.yaml # Deployment config in root
    - deployment-env.yaml # Environment config in root
    - ENV_SETUP.md # Duplicate of environment docs
    - start-backend.sh # Script that belongs in scripts/
    - test-results/ # Empty directory

  behavior:
    - Root directory cluttered with task-specific files
    - Multiple environment documentation files (ENV_SETUP.md vs CLAUDE.md)
    - Deployment configs scattered in root
    - Scripts not centralized in scripts/ directory
    - Empty directories consuming space

  issues:
    - Hard to find relevant files
    - Duplicate documentation confuses developers
    - No clear organization pattern
    - Task-specific files pollute root
```

### Backup Directory Chaos

```yaml
backup_directory:
  structure:
    - env-files/                    # Old env config backups
    - firebase-env-backup.md        # Obsolete Firebase config
    - nx-config/                    # Old NX monorepo artifacts
      - cache/                      # NX cache with 500MB+ data
      - workspace-data/             # NX database files
    - package-versions.log          # Outdated dependency log

  issues:
    - Contains 500MB+ of obsolete NX cache data
    - Firebase configuration no longer used
    - Old monorepo tooling artifacts (NX -> Turborepo migration)
    - No clear retention policy
```

### Documentation Sprawl

```yaml
documentation_issues:
  js_docs/:
    - Unstructured task tracking system
    - Mix of backlog, in-progress, done folders
    - Example files mixed with documentation
    - No clear naming convention
    - Firebase migration artifacts

  PRPs/:
    - Good structure but contains AI-specific docs
    - ai_docs/ folder seems misplaced
    - Mix of specs, commands, and templates

  utilities/:
    - Duplicate templates from PRPs/templates/
    - Scripts that belong in scripts/
```

### Test Organization

```yaml
test_issues:
  root_tests/:
    - Manual test scripts for specific features
    - Should be in api/tests/manual/

  api_artifacts:
    - auto_drafts_validation_results.json in api/
    - backend.log accumulating in api/
    - run_tests.py in api root instead of tests/
```

## Desired State

```yaml
desired_state:
  structure:
    /: # Clean root with only essential files
      - README.md
      - CLAUDE.md
      - TROUBLESHOOTING.md
      - DEPLOYMENT.md
      - package.json
      - turbo.json
      - docker-compose.yml
      - .gitignore
      - poetry files

    .github/: # GitHub specific configs
      - workflows/
      - ISSUE_TEMPLATE/

    config/: # All configuration files
      - deployment/
        - backend-service.yaml
        - deployment-env.yaml
      - eslint-config/
      - typescript-config/

    scripts/: # All executable scripts
      - setup/
      - sync/
      - docker/
      - dev/

    docs/: # User-facing documentation
      - architecture/
      - guides/
      - api-reference/

    .archive/: # Historical artifacts
      - migrations/
        - nx-to-turbo/
        - firebase-to-supabase/
      - task-updates/
        - linear-lt-138-update.md

  benefits:
    - Clear, predictable file locations
    - No duplicate documentation
    - Reduced repository size
    - Easier onboarding
    - Better Git performance
```

## Hierarchical Objectives

### 1. High-Level: Create Clean Monorepo Structure

- Establish clear organization patterns
- Remove obsolete files and directories
- Consolidate scattered documentation
- Improve developer experience

### 2. Mid-Level: Organize by Category

- **Config Migration**: Move deployment configs to config/
- **Script Consolidation**: Centralize all scripts
- **Documentation Cleanup**: Remove duplicates, organize by purpose
- **Archive Creation**: Preserve historical context without clutter

### 3. Low-Level: Specific File Operations

- Delete obsolete caches and logs
- Move misplaced files to proper locations
- Create .archive directory for historical items
- Update references in documentation

## Implementation Tasks

### Task 1: Clean Backup Directory

```yaml
clean_backup:
  action: DELETE
  files:
    - backup/nx-config/cache/
    - backup/nx-config/workspace-data/
    - backup/firebase-env-backup.md
    - backup/nx-build-output.log
    - backup/package-versions.log

  validation:
    - command: "ls -la backup/"
    - expect: "Only env-files/ directory remains"
```

### Task 2: Archive Historical Updates

```yaml
archive_updates:
  action: MOVE
  operations:
    - source: linear-lt-138-update.md
      dest: .archive/task-updates/linear-lt-138-update.md
    - source: js_docs/migration-*.md
      dest: .archive/migrations/
    - source: js_docs/firebase-*.md
      dest: .archive/migrations/firebase/

  validation:
    - command: "ls -la | grep -E '(linear|migration)'"
    - expect: "No matches in root"
```

### Task 3: Organize Deployment Configs

```yaml
organize_configs:
  action: MOVE
  operations:
    - source: backend-service.yaml
      dest: config/deployment/backend-service.yaml
    - source: deployment-env.yaml
      dest: config/deployment/deployment-env.yaml

  action: CREATE
  file: config/deployment/README.md
  content: |
    # Deployment Configuration

    - `backend-service.yaml` - Cloud Run service definition
    - `deployment-env.yaml` - Environment-specific variables

    See DEPLOYMENT.md for usage instructions.

  validation:
    - command: "ls config/deployment/"
    - expect: "Shows yaml files and README"
```

### Task 4: Consolidate Scripts

```yaml
consolidate_scripts:
  action: MOVE
  operations:
    - source: start-backend.sh
      dest: scripts/dev/start-backend.sh
    - source: utilities/scripts/
      dest: scripts/utilities/

  action: CREATE
  file: scripts/README.md
  content: |
    # Scripts Directory

    - `setup/` - Initial setup and configuration
    - `dev/` - Development helper scripts
    - `docker/` - Docker management
    - `sync/` - Environment synchronization
    - `utilities/` - General utilities

  validation:
    - command: "find scripts -name '*.sh' | wc -l"
    - expect: "All scripts centralized"
```

### Task 5: Clean API Directory

```yaml
clean_api:
  action: DELETE
  files:
    - api/backend.log
    - api/auto_drafts_validation_results.json

  action: MOVE
  operations:
    - source: api/run_tests.py
      dest: api/tests/run_tests.py

  action: MODIFY
  file: .gitignore
  changes: |
    Add:
    # API artifacts
    api/backend.log
    api/*.json

    # Test results
    test-results/
    **/test-results/

  validation:
    - command: "ls api/*.log api/*.json 2>/dev/null | wc -l"
    - expect: "0"
```

### Task 6: Consolidate Documentation

```yaml
consolidate_docs:
  action: DELETE
  files:
    - ENV_SETUP.md  # Content already in CLAUDE.md

  action: MOVE
  operations:
    - source: js_docs/3_docs/
      dest: docs/internal/architecture/
    - source: PRPs/ai_docs/
      dest: docs/internal/ai-tools/

  action: CREATE
  file: docs/internal/README.md
  content: |
    # Internal Documentation

    This directory contains internal technical documentation
    not included in the public-facing Mintlify docs.

    - `architecture/` - System design documents
    - `ai-tools/` - AI and MCP tool documentation
    - `decisions/` - Architectural decision records

  validation:
    - command: "find . -name 'ENV_SETUP.md' 2>/dev/null | wc -l"
    - expect: "0"
```

### Task 7: Clean Empty Directories

```yaml
clean_empty:
  action: DELETE
  directories:
    - test-results/
    - PRPs/backlog/env/ # Empty directory

  validation:
    - command: "find . -type d -empty | grep -v node_modules | grep -v .git"
    - expect: "No empty directories outside of dependencies"
```

### Task 8: Reorganize js_docs

```yaml
reorganize_js_docs:
  action: CREATE
  file: .archive/project-history/README.md
  content: |
    # Project History Archive

    Historical project documents organized by phase:

    - `initial-development/` - Early project documents
    - `migrations/` - Technology migration records
    - `task-updates/` - Linear ticket updates
    - `decisions/` - Historical ADRs

  action: MOVE
  operations:
    - source: js_docs/
      dest: .archive/project-history/initial-development/

  validation:
    - command: "ls -la | grep js_docs"
    - expect: "Directory not found"
```

### Task 9: Update Root Documentation

````yaml
update_docs:
  action: MODIFY
  file: CLAUDE.md
  changes: |
    Update Project Structure section:
    ```
    living-tree/
    ├── apps/web/          # Next.js frontend
    ├── api/               # FastAPI backend
    ├── packages/          # Shared packages
    ├── docs/              # Public documentation
    ├── config/            # Configuration files
    │   ├── deployment/    # Deployment configs
    │   ├── eslint/        # ESLint configs
    │   └── typescript/    # TypeScript configs
    ├── scripts/           # All executable scripts
    │   ├── setup/         # Setup scripts
    │   ├── dev/           # Development helpers
    │   └── docker/        # Docker management
    └── supabase/          # Database migrations
    ```

  validation:
    - command: "grep -A10 'Project Structure' CLAUDE.md"
    - expect: "Shows updated structure"
````

### Task 10: Create Maintenance Script

```yaml
create_maintenance:
  action: CREATE
  file: scripts/maintenance/clean-artifacts.sh
  content: |
    #!/bin/bash
    # Clean common development artifacts

    echo "🧹 Cleaning development artifacts..."

    # Clean logs
    find . -name "*.log" -not -path "./node_modules/*" -not -path "./.git/*" -delete

    # Clean test results
    rm -rf test-results/
    rm -rf playwright-report/

    # Clean API artifacts
    rm -f api/backend.log
    rm -f api/*.json

    # Clean Docker images
    docker image prune -f

    echo "✅ Cleanup complete!"

  validation:
    - command: "bash scripts/maintenance/clean-artifacts.sh"
    - expect: "Cleanup complete message"
```

## Implementation Strategy

1. **Phase 1: Backup Critical Files** (10 min)
   - Create full backup of repository
   - Document current structure
   - Identify files with active references

2. **Phase 2: Clean Obsolete Files** (20 min)
   - Delete NX cache and artifacts
   - Remove empty directories
   - Clean logs and temporary files

3. **Phase 3: Reorganize Structure** (30 min)
   - Create new directory structure
   - Move files to proper locations
   - Update .gitignore patterns

4. **Phase 4: Update References** (20 min)
   - Update documentation
   - Fix import paths if needed
   - Update scripts

5. **Phase 5: Validate** (10 min)
   - Run all tests
   - Verify development workflow
   - Check CI/CD pipelines

## Rollback Plan

```bash
# If issues arise, restore from backup
git stash
git checkout main
git pull origin main

# Or restore specific files
git checkout HEAD -- <file-path>
```

## Success Metrics

- [ ] Root directory contains only essential files
- [ ] No duplicate documentation files
- [ ] All scripts centralized in scripts/
- [ ] Repository size reduced by >500MB
- [ ] Clear organization pattern established
- [ ] Development workflow unchanged
- [ ] All tests passing

## Risk Mitigation

1. **Breaking References**
   - Search codebase for file references before moving
   - Update imports and documentation
   - Test thoroughly after changes

2. **Lost History**
   - Use git mv to preserve history
   - Archive rather than delete when uncertain
   - Document reasons for changes

3. **Team Disruption**
   - Communicate changes before implementation
   - Update team documentation
   - Provide migration guide

## Impact Assessment

### Breaking Changes Analysis

After thorough analysis, this cleanup has **minimal breaking impact**:

#### 1. **start-backend.sh** ❌ Will Break (1 reference)

- **Used in**: `package.json` script `"dev:api:script": "./start-backend.sh"`
- **Fix Required**: Update package.json to point to new location:
  ```json
  "dev:api:script": "./scripts/dev/start-backend.sh"
  ```

#### 2. **backend-service.yaml & deployment-env.yaml** ✅ Safe

- Not referenced in any code or scripts
- Only used manually for deployments
- Moving to `config/deployment/` is safe

#### 3. **ENV_SETUP.md** ✅ Safe to Delete

- Content is duplicated in CLAUDE.md
- Not referenced by any code

#### 4. **linear-lt-138-update.md** ✅ Safe to Archive

- Task-specific documentation
- Not referenced anywhere

#### 5. **backup/ directory** ✅ Safe to Clean

- NX cache is only 1.7MB (not 500MB as initially estimated)
- Firebase files are historical artifacts
- Not used by current build system

#### 6. **js_docs/** ✅ Safe to Archive

- Legacy documentation/task tracking
- Not referenced in active code

### Required Pre-Implementation Updates

```bash
# 1. Update package.json script reference FIRST
sed -i '' 's|"./start-backend.sh"|"./scripts/dev/start-backend.sh"|' package.json

# 2. Create directory structure
mkdir -p config/deployment
mkdir -p scripts/dev
mkdir -p .archive/task-updates
mkdir -p .archive/migrations

# 3. Use git mv to preserve history
git mv start-backend.sh scripts/dev/
git mv backend-service.yaml config/deployment/
git mv deployment-env.yaml config/deployment/
```

### Implementation Recommendation

**VERDICT: LOW RISK - SAFE TO IMPLEMENT**

This cleanup provides significant benefits with minimal disruption:

- Only 1 script reference needs updating
- No production code changes required
- All changes are organizational only

### Additional Hygiene Activities

1. **Establish File Conventions**
   - Task updates go in PRPs or issues, not root
   - Scripts must be in scripts/ directory
   - Test files stay with their code

2. **Regular Maintenance**
   - Weekly artifact cleanup
   - Monthly archive review
   - Quarterly structure assessment

3. **Automation Opportunities**
   - Pre-commit hooks to prevent misplaced files
   - GitHub Actions to clean artifacts
   - Automated documentation updates

## Notes

- The backup/ directory contains 1.7MB (not 500MB) of obsolete NX cache
- Multiple environment setup docs create confusion
- js_docs/ appears to be a legacy task tracking system
- Firebase references indicate incomplete migration
- Consider moving PRPs/ to .github/ or docs/internal/
