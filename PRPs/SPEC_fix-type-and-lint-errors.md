# SPEC: Fix Type and Lint Errors Before Staging Merge

## Overview

This specification addresses critical type errors in the `@repo/types` package and excessive linting warnings that must be resolved before merging to staging.

## Current State Assessment

### Type Errors in @repo/types Package

```yaml
current_state:
  files:
    - packages/types/src/index.ts
    - packages/types/src/supabase-enhanced.ts
    - packages/types/src/supabase.ts

  issues:
    - ECMAScript module imports missing file extensions (9 errors)
    - Module resolution set to 'NodeNext' requires explicit .js extensions
    - Circular reference in custom 'Required' type alias
    - Import paths reference .generated file without extension

  error_count: 9 type errors across 3 files
```

### Linting Warnings

```yaml
current_state:
  warning_count: >50 warnings (exceeds threshold)

  common_issues:
    - Unused variables and imports
    - Unescaped entities in JSX
    - Missing prop validations
    - Use of 'any' type
    - Variables assigned but never used
    - Missing 'const' assertions
```

## Desired State

```yaml
desired_state:
  type_errors: 0
  lint_warnings: <50

  benefits:
    - Clean TypeScript compilation
    - Improved code quality
    - Reduced technical debt
    - Staging-ready codebase
```

## Hierarchical Objectives

### 1. High-Level Goal

Prepare branch for staging merge by eliminating type errors and reducing lint warnings

### 2. Mid-Level Milestones

- **M1**: Fix all TypeScript compilation errors in @repo/types
- **M2**: Reduce linting warnings below 50 threshold
- **M3**: Validate all changes maintain functionality

### 3. Low-Level Tasks

## Implementation Tasks

### Phase 1: Fix TypeScript Module Resolution Errors

#### Task 1.1: Update Import Extensions in index.ts

```yaml
task_name: fix_index_imports
action: MODIFY
file: packages/types/src/index.ts
changes: |
  - Line 9: './supabase' → './supabase.js'
  - Line 12: './supabase-enhanced' → './supabase-enhanced.js'
  - Line 56: './supabase-enhanced' → './supabase-enhanced.js'
  - Line 65: './supabase-enhanced' → './supabase-enhanced.js'
validation:
  - command: "cd packages/types && pnpm check-types"
  - expect: "No errors for index.ts imports"
```

#### Task 1.2: Update Import Extensions in supabase-enhanced.ts

```yaml
task_name: fix_enhanced_imports
action: MODIFY
file: packages/types/src/supabase-enhanced.ts
changes: |
  - Line 5: './supabase.generated' → './supabase.generated.js'
  - Line 8: './supabase.generated' → './supabase.generated.js'
validation:
  - command: "cd packages/types && pnpm check-types | grep supabase-enhanced"
  - expect: "No import errors for supabase-enhanced.ts"
```

#### Task 1.3: Update Import Extension in supabase.ts

```yaml
task_name: fix_supabase_imports
action: MODIFY
file: packages/types/src/supabase.ts
changes: |
  - Line 1: './supabase.generated' → './supabase.generated.js'
validation:
  - command: "cd packages/types && pnpm check-types | grep 'src/supabase.ts'"
  - expect: "No import errors for supabase.ts"
```

### Phase 2: Fix Type Definition Errors

#### Task 2.1: Fix Circular Reference in Required Type

```yaml
task_name: fix_required_type
action: MODIFY
file: packages/types/src/supabase-enhanced.ts
changes: |
  - Line 199: Rename custom 'Required' to 'RequiredFields'
  - Update type definition to avoid conflict with built-in Required utility

  FROM:
  export type Required<T, K extends keyof T> = Omit<T, K> & Required<Pick<T, K>>;

  TO:
  export type RequiredFields<T, K extends keyof T> = Omit<T, K> & Required<Pick<T, K>>;
validation:
  - command: "cd packages/types && pnpm check-types | grep -E 'TS2456|TS2315'"
  - expect: "No circular reference or generic type errors"
```

#### Task 2.2: Update Required Type Export in index.ts

```yaml
task_name: update_required_export
action: MODIFY
file: packages/types/src/index.ts
changes: |
  - Line 51: 'Required' → 'RequiredFields'
validation:
  - command: "cd packages/types && pnpm check-types"
  - expect: "0 errors"
```

### Phase 3: Address Critical Linting Warnings

#### Task 3.1: Remove Unused Variables in Components

```yaml
task_name: clean_unused_vars
action: MODIFY
files:
  - apps/web/app/(app)/debug/page.tsx
  - apps/web/app/(app)/tools/tools-page-client.tsx
  - apps/web/components/action-progress-modal.tsx
  - apps/web/components/bulk-action-toolbar.tsx
  - apps/web/components/triage-email-list.tsx
changes: |
  - Remove or comment out unused imports
  - Remove unused variable declarations
  - Add underscore prefix for intentionally unused parameters
validation:
  - command: "pnpm lint | grep -c 'is defined but never used'"
  - expect: "Reduced count of unused variable warnings"
```

#### Task 3.2: Fix Unescaped Entities in JSX

```yaml
task_name: escape_jsx_entities
action: MODIFY
files:
  - apps/web/components/markdown.tsx
  - apps/web/components/multimodal-input.tsx
  - apps/web/components/triage-dashboard.tsx
changes: |
  - Replace ' with &apos; or &rsquo;
  - Replace " with &quot; or &ldquo;/&rdquo;
  - Use HTML entities for special characters
validation:
  - command: "pnpm lint | grep -c 'can be escaped with'"
  - expect: "0 unescaped entity warnings"
```

#### Task 3.3: Replace 'any' Types

```yaml
task_name: remove_any_types
action: MODIFY
files:
  - apps/web/app/auth/sign-in/[[...sign-in]]/page.tsx
  - apps/web/app/auth/sign-up/[[...sign-up]]/page.tsx
  - apps/web/lib/action-types.ts
changes: |
  - Replace 'any' with specific types or 'unknown'
  - Add proper type definitions for error handlers
  - Use generic constraints where applicable
validation:
  - command: "pnpm lint | grep -c 'Unexpected any'"
  - expect: "Reduced 'any' type warnings"
```

### Phase 4: Final Validation

#### Task 4.1: Run Full Type Check

```yaml
task_name: validate_types
action: VALIDATE
commands:
  - "pnpm check-types"
  - "echo 'Type check complete'"
validation:
  - expect: "All packages type check successfully"
```

#### Task 4.2: Run Full Lint Check

```yaml
task_name: validate_lint
action: VALIDATE
commands:
  - "pnpm lint 2>&1 | grep -E 'Warning:|Error:' | wc -l"
validation:
  - expect: "Warning count < 50"
```

## Implementation Strategy

### Execution Order

1. Fix module resolution errors first (Tasks 1.1-1.3)
2. Fix type definition errors (Tasks 2.1-2.2)
3. Address linting warnings in batches (Tasks 3.1-3.3)
4. Validate all changes (Tasks 4.1-4.2)

### Dependencies

- Tasks 1.1-1.3 must complete before type checking succeeds
- Task 2.1 must complete before Task 2.2
- Linting tasks can be done in parallel
- Final validation requires all previous tasks

## Risk Assessment

### Identified Risks

1. **Import path changes**: May break runtime imports
   - **Mitigation**: Test build after changes
2. **Type name changes**: May affect dependent code
   - **Mitigation**: Search for all usages of 'Required' type
3. **Removing unused code**: May remove intentionally unused parameters
   - **Mitigation**: Use underscore prefix instead of removal

### Rollback Strategy

- Git stash changes if issues arise
- Revert individual file changes as needed
- Keep original type definitions as comments

## Integration Points

- All packages importing from @repo/types
- Build pipeline expecting clean type checks
- CI/CD expecting lint warning threshold

## Success Criteria

- [ ] Zero TypeScript compilation errors
- [ ] Lint warnings < 50
- [ ] All tests passing
- [ ] Build succeeds
- [ ] No runtime errors

## Next Steps After Completion

1. Commit fixes with clear message
2. Push to feature branch
3. Create PR to staging
4. Monitor CI/CD pipeline
