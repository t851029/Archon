# SPEC: Auto-Draft Toggle Persistence Fix

## Overview

Fix the auto-draft toggle persistence issue in the staging environment where the toggle state doesn't persist after page refresh.

## Current State Assessment

### Files Affected

- `apps/web/app/(app)/tools/tools-page-client.tsx` - Main component handling toggle logic
- `apps/web/components/tools/auto-drafts-dialog.tsx` - Dialog wrapper component
- `apps/web/components/tools/auto-drafts-settings.tsx` - Settings component with save functionality
- `api/index.py` - Backend endpoints for auto-draft settings

### Current Behavior

1. User clicks auto-draft toggle on `/tools` page
2. Toggle visually changes state (on/off)
3. Only local React state is updated (line 121-133 in tools-page-client.tsx)
4. No API call is made to persist the change
5. On page refresh, toggle reverts to previous database state
6. Settings only persist when user opens dialog and clicks "Save Settings"

### Issues

- Poor user experience - toggle appears broken
- Inconsistent with other tool toggles that persist immediately
- No error feedback when state doesn't persist
- Requires extra steps (open dialog → save) to persist simple on/off state

## Desired State

### Target Behavior

1. User clicks auto-draft toggle
2. Toggle visually changes state
3. API call immediately persists the enabled/disabled state
4. Success/error toast notification shown
5. State persists across page refreshes
6. Settings dialog remains available for advanced configuration

### Benefits

- Consistent UX with other tool toggles
- Immediate state persistence
- Clear feedback to users
- Reduced user confusion
- Maintains backward compatibility

## Implementation Plan

### High-Level Objectives

1. **Immediate Persistence**: Make auto-draft toggle persist on click
2. **User Feedback**: Show success/error notifications
3. **Error Handling**: Gracefully handle API failures
4. **State Consistency**: Ensure UI and database stay in sync

### Mid-Level Milestones

1. Update toggle handler to make API calls
2. Preserve existing settings when toggling
3. Add proper error handling and rollback
4. Test across environments

### Low-Level Tasks

#### Task 1: Update handleToggleTool for auto-drafts

```yaml
task_name: update_handle_toggle_tool
action: MODIFY
file: apps/web/app/(app)/tools/tools-page-client.tsx
changes: |
  - Replace lines 117-134 with immediate API persistence
  - Add getToken() call for authentication
  - Make POST request to /api/auto-drafts/settings
  - Only update local state after successful API response
  - Add error handling with state rollback
  - Show toast notifications for success/failure
validation:
  - command: "grep -A 50 'handleToggleTool' apps/web/app/(app)/tools/tools-page-client.tsx"
  - expect: "Contains fetch call to auto-drafts/settings endpoint"
```

#### Task 2: Add state preservation logic

```yaml
task_name: preserve_existing_settings
action: MODIFY
file: apps/web/app/(app)/tools/tools-page-client.tsx
changes: |
  - Before API call, fetch current settings
  - Merge enabled state with existing settings
  - Ensure tone_settings, delays, etc. are preserved
  - Only update the 'enabled' field
validation:
  - command: "grep -B 10 -A 20 'auto-drafts/settings' apps/web/app/(app)/tools/tools-page-client.tsx | grep -E '(GET|enabled)'"
  - expect: "Shows GET request before POST to preserve settings"
```

#### Task 3: Add optimistic UI updates with rollback

```yaml
task_name: add_optimistic_updates
action: MODIFY
file: apps/web/app/(app)/tools/tools-page-client.tsx
changes: |
  - Store previous state before update
  - Update UI optimistically
  - Rollback on API failure
  - Disable toggle during API call to prevent race conditions
validation:
  - command: "grep -A 30 'auto-drafts' apps/web/app/(app)/tools/tools-page-client.tsx | grep -E '(prevTools|rollback|disabled)'"
  - expect: "Contains state rollback logic"
```

#### Task 4: Add loading state to prevent double-clicks

```yaml
task_name: add_loading_state
action: MODIFY
file: apps/web/app/(app)/tools/tools-page-client.tsx
changes: |
  - Add isToggling state variable
  - Disable toggle during API calls
  - Show loading indicator on toggle
  - Re-enable after success/failure
validation:
  - command: "grep -E '(isToggling|disabled.*auto-drafts)' apps/web/app/(app)/tools/tools-page-client.tsx"
  - expect: "Contains loading state management"
```

#### Task 5: Update AutoDraftsSettings for consistency

```yaml
task_name: update_settings_component
action: MODIFY
file: apps/web/components/tools/auto-drafts-settings.tsx
changes: |
  - Ensure onToggle callback is called after successful save
  - Add loading state to toggle in settings dialog
  - Sync local and parent state properly
validation:
  - command: "grep -A 5 'onToggle' apps/web/components/tools/auto-drafts-settings.tsx"
  - expect: "onToggle called in handleSaveSettings"
```

#### Task 6: Add integration tests

```yaml
task_name: add_integration_tests
action: CREATE
file: apps/web/tests/auto-draft-toggle.test.ts
changes: |
  - Test toggle persistence
  - Test error handling
  - Test state rollback
  - Test loading states
validation:
  - command: "test -f apps/web/tests/auto-draft-toggle.test.ts && echo 'Test file exists'"
  - expect: "Test file exists"
```

### Implementation Order

1. Task 1 & 2 - Core functionality (can be done together)
2. Task 3 - Error handling and rollback
3. Task 4 - Loading states
4. Task 5 - Settings consistency
5. Task 6 - Tests

## Risk Assessment

### Identified Risks

1. **Race Conditions**: Multiple rapid clicks could cause state inconsistency
   - **Mitigation**: Disable toggle during API calls
2. **Network Failures**: API calls could fail leaving UI in wrong state
   - **Mitigation**: Implement rollback on failure
3. **Settings Loss**: Toggling might overwrite existing tone/delay settings
   - **Mitigation**: Fetch current settings before update
4. **Breaking Changes**: Could affect existing dialog functionality
   - **Mitigation**: Maintain backward compatibility, test thoroughly

### Rollback Strategy

1. Git revert the commit if issues found in staging
2. Feature flag the new behavior if gradual rollout needed
3. Keep old handleToggleTool logic commented for quick revert

## Success Criteria

- [ ] Toggle state persists immediately on click
- [ ] Page refresh maintains toggle state
- [ ] Success/error toasts appear appropriately
- [ ] Loading state prevents double-clicks
- [ ] Existing settings are preserved when toggling
- [ ] Settings dialog continues to work as before
- [ ] No console errors in browser
- [ ] Works in both local and staging environments

## Testing Strategy

1. **Manual Testing**
   - Toggle on/off multiple times
   - Refresh page after toggle
   - Test with slow network (throttling)
   - Test rapid clicking
   - Test with dialog open

2. **Automated Testing**
   - Unit tests for handleToggleTool
   - Integration tests for full flow
   - E2E tests with Playwright

## Monitoring

- Add logging for toggle API calls
- Monitor error rates in staging
- Track user engagement with auto-drafts feature

## Timeline Estimate

- Implementation: 2-3 hours
- Testing: 1-2 hours
- Deployment & Verification: 1 hour
- Total: 4-6 hours

## Dependencies

- FastAPI backend must be running
- Valid Clerk authentication token
- Supabase database connection
- Existing auto_draft_settings table

## Notes

- Consider making all tool toggles use the same pattern for consistency
- Future enhancement: Add WebSocket for real-time sync across tabs
- Document the pattern for future tool additions
