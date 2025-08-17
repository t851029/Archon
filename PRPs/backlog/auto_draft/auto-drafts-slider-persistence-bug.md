# Auto-Drafts Slider Values Not Persisting Bug

## Issue Summary

After fixing the RLS authentication issue, auto-drafts toggle and text settings persist correctly, but slider values (reply delay and confidence threshold) reset to defaults when the dialog is reopened.

## Bug Details

### Expected Behavior

- When user adjusts Reply Delay slider to 15 minutes → should persist as 15 minutes
- When user adjusts Confidence Threshold to 85% → should persist as 85%
- Settings should remain when dialog is closed and reopened

### Actual Behavior

- ✅ Toggle state persists correctly (enabled/disabled)
- ✅ Text settings persist correctly (tone instructions)
- ❌ Reply Delay always resets to 5 minutes (default)
- ❌ Confidence Threshold always resets to 70% (default)

## Reproduction Steps

1. Navigate to http://localhost:3000/tools
2. Click "Configure Settings" on Auto Drafts card
3. Enable the toggle switch
4. Set tone instructions: "Test message"
5. Adjust Reply Delay slider (should change from 5 to different value)
6. Adjust Confidence Threshold slider (should change from 70% to different value)
7. Click "Save Settings"
8. Close dialog and reopen
9. **Bug**: Sliders show default values despite successful save

## Technical Investigation

### Test Results

```
Switch checked after reopening: true ✅
Tone instructions after reopening: Test message ✅
Reply delay after reopening: 5 ❌ (should be adjusted value)
Confidence after reopening: 70 ❌ (should be adjusted value)
```

### Components Involved

- `apps/web/components/tools/auto-drafts-settings.tsx` - Form with sliders
- `apps/web/components/ui/slider.tsx` - shadcn/ui Slider component
- React state management with `useState`

### State Management Analysis

```typescript
const [replyDelay, setReplyDelay] = useState([5]); // Array format for Slider
const [confidenceThreshold, setConfidenceThreshold] = useState([0.7]);
```

### API Communication

- **Save Request**: `replyDelay[0]` and `confidenceThreshold[0]` are sent to backend
- **Load Response**: Values loaded into state via `setReplyDelay([settings.reply_delay_minutes])`

### Root Cause Hypotheses

1. **Slider Event Handling**: onChange events not updating React state
2. **API Response Mapping**: Backend response not properly loading into slider state
3. **Component State Lifecycle**: State reset during component remount
4. **Slider Component Integration**: shadcn/ui Slider not properly controlled

## Debugging Evidence

### Slider Interaction Testing

```javascript
// Found range inputs: 0
// This suggests sliders aren't using <input type="range">
```

### Current Implementation

```typescript
// In handleSaveSettings:
body: JSON.stringify({
  enabled,
  tone_settings: toneSettings || null,
  reply_delay_minutes: replyDelay[0] ?? 5, // ← This part works
  min_confidence_score: confidenceThreshold[0] ?? 0.7, // ← This part works
});

// In loadSettings:
setReplyDelay([settings.reply_delay_minutes]); // ← May not be working
setConfidenceThreshold([settings.min_confidence_score]); // ← May not be working
```

## Priority

**Medium** - Core functionality (toggle/text) works, but numerical settings don't persist

## Impact

- Users can enable auto-drafts and set tone preferences ✅
- Users cannot persist timing and confidence preferences ❌
- Partial user experience degradation

## Next Debugging Steps

1. Add console logging to track slider state changes
2. Verify API response contains correct numerical values
3. Check if `setReplyDelay`/`setConfidenceThreshold` calls are working
4. Test slider onChange event handlers
5. Investigate shadcn/ui Slider component docs for proper usage

## Labels

- bug
- auto-drafts
- slider-component
- state-management
- frontend

## Related Files

- `apps/web/components/tools/auto-drafts-settings.tsx`
- `apps/web/components/ui/slider.tsx`

## Created

2025-07-19

## Status

**Active** - Ready for debugging
