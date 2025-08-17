# Auto-Drafts Settings Persistence Bug

## Issue Summary

Auto-drafts settings are not persisting correctly when saved. Slider values reset to defaults and tool status doesn't update properly.

## Bug Details

### Expected Behavior

- When user configures auto-drafts settings and clicks "Save Settings":
  - All form values (text inputs, sliders) should be saved
  - Success toast notification should appear
  - Tool card should show "active" status
  - Settings should persist when dialog is reopened

### Actual Behavior

- Text settings (tone instructions) save correctly ✅
- Slider values (reply delay, confidence threshold) reset to defaults ❌
- No toast notification appears ❌
- Tool card remains "inactive" status ❌
- Only partial settings persistence ❌

## Reproduction Steps

1. Navigate to http://localhost:3000/tools
2. Click "Configure Settings" on Auto Drafts card
3. Enable the toggle switch
4. Set tone instructions: "Be professional and concise"
5. Adjust Reply Delay slider to 10 minutes
6. Adjust Confidence Threshold to 80%
7. Click "Save Settings"
8. Close dialog and reopen
9. **Bug**: Sliders show default values (5 min, 70%), tool shows "inactive"

## Technical Investigation

### Components Involved

- `apps/web/components/tools/auto-drafts-settings.tsx` - Settings form
- `apps/web/app/(app)/tools/tools-page-client.tsx` - Parent container
- `apps/web/components/tools/tool-toggle.tsx` - Toggle component
- FastAPI backend: `/api/auto-drafts/settings` endpoint

### Root Cause Hypotheses

1. **Slider State Management**: Slider components not properly updating form state
2. **API Payload**: Form data not serializing slider values correctly
3. **Backend Storage**: FastAPI not saving numerical values properly
4. **State Synchronization**: UI not reflecting saved state after API response
5. **Component Lifecycle**: Settings not loading properly on component mount

### Console Log Evidence

```
Switch checked: true ✅
Tone instructions value: Be professional and concise ✅
Reply delay found: 5 ❌ (should be 10)
Confidence found: 70 ❌ (should be 80%)
```

## Debugging Tasks

- [ ] Check network tab for actual API payload being sent
- [ ] Verify slider change events are updating component state
- [ ] Test FastAPI backend endpoint directly with curl
- [ ] Add debug logging to track form state changes
- [ ] Investigate toast notification system
- [ ] Check parent component state update after save

## Priority

**High** - Core functionality broken, affects user experience

## Labels

- bug
- auto-drafts
- settings-persistence
- ui-state
- form-handling

## Assignee

Claude

## Created

2025-07-19

## Related Files

- `apps/web/components/tools/auto-drafts-settings.tsx`
- `apps/web/app/(app)/tools/tools-page-client.tsx`
- `apps/web/components/tools/tool-toggle.tsx`
- `api/utils/tools.py` (auto-drafts backend logic)
