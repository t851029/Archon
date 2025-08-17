# Auto-Drafts Feature - Manual Testing Plan

## Prerequisites

- Local development environment running (`pnpm dev:full`)
- Gmail account connected via Clerk OAuth
- Test emails in your Gmail inbox

## Test Plan

### 1. Initial State Verification

1. Navigate to http://localhost:3000/tools
2. **Expected**: Auto Drafts tool shows as "inactive" with "Not Connected" badge
3. **Expected**: The toggle switch should be in the OFF position

### 2. Enable Auto-Drafts

1. Click "Configure Settings" button on the Auto Drafts card
2. **Expected**: Dialog opens showing "Auto Drafts Configuration"
3. Click the toggle switch to enable Auto Drafts
4. **Expected**: Switch moves to ON position
5. **Expected**: "Save Settings" button becomes enabled (not grayed out)

### 3. Configure Settings

1. In the "Custom Tone Instructions" field, enter: "Be professional and concise"
2. Adjust "Reply Delay" slider to 10 minutes
3. Adjust "Confidence Threshold" to 80%
4. Click "Save Settings"
5. **Expected**: Success toast notification appears
6. **Expected**: Dialog remains open with settings saved

### 4. Verify Settings Persistence

1. Close the dialog (click X or outside)
2. **Expected**: Auto Drafts card now shows as "active" status
3. **Expected**: Stats at top show "1 Active" tool
4. Click "Configure Settings" again
5. **Expected**: Previously saved settings are displayed:
   - Toggle is ON
   - Tone instructions show "Be professional and concise"
   - Reply delay shows 10 minutes
   - Confidence threshold shows 80%

### 5. Disable and Re-enable

1. Click the toggle switch to disable
2. Click "Save Settings"
3. Close dialog
4. **Expected**: Tool shows as "inactive"
5. Re-open settings and enable again
6. **Expected**: Settings are retained from before

### 6. Backend Verification

Check if settings are actually saved in the database:

```bash
# Check backend logs for API calls
curl -X GET http://localhost:8000/api/auto-drafts/settings \
  -H "Authorization: Bearer YOUR_CLERK_TOKEN"
```

**Expected Response**:

```json
{
  "enabled": true,
  "tone_settings": "Be professional and concise",
  "reply_delay_minutes": 10,
  "min_confidence_score": 0.8
}
```

### 7. Gmail Draft Verification

1. Send yourself a test email asking a question
2. Run: `poetry run python test_auto_draft.py`
3. Open Gmail and go to Drafts folder
4. **Expected**: New draft reply to your test email
5. **Expected**: Draft addresses the question appropriately

### 8. Integration with Email Processing

1. The auto-draft monitor runs every 5 minutes (when working)
2. It checks for unread emails from the last hour
3. **Expected**: Only emails needing replies get drafts
4. **Expected**: Newsletters and notifications are ignored

### 8. Error Handling Tests

1. Disable internet connection
2. Try to save settings
3. **Expected**: Error toast notification appears
4. Re-enable internet
5. Try to save without being logged in (open in incognito)
6. **Expected**: Redirected to login page

## Quick Smoke Test (2 minutes)

If you're in a hurry, just test these critical paths:

1. **Toggle Test**:
   - Go to /tools → Click Configure → Toggle ON → Save
   - **Expected**: No errors, settings saved

2. **Persistence Test**:
   - Close dialog → Reopen
   - **Expected**: Toggle still ON

3. **API Test**:
   - Open browser console (F12)
   - Toggle and save
   - **Expected**: No red errors in console

## Known Issues to Watch For

- Authentication errors (403/401) - Make sure you're logged in
- CORS errors - Make sure backend is running on port 8000
- "Not authenticated" errors - Clerk session might have expired

## Debug Commands

If something isn't working:

```bash
# Check if backend is running
curl http://localhost:8000/health

# Check if Supabase is running
npx supabase status

# Check for TypeScript errors
pnpm type-check

# View backend logs (in api directory)
# The backend should show logs when settings are saved
```

## Success Criteria

✅ Can enable/disable auto-drafts without errors  
✅ Settings persist after closing dialog  
✅ No console errors during operation  
✅ Backend receives and stores settings  
✅ UI reflects current state accurately
✅ Gmail drafts appear for reply-worthy emails
✅ Drafts are contextually appropriate
✅ Non-reply emails are correctly ignored
