# Auto-Drafts Gmail Testing Guide

## 🎯 What Auto-Drafts Actually Does

### The Feature in Simple Terms:

1. **Monitors your Gmail inbox** for new unread emails
2. **AI analyzes each email** to decide if it needs a reply
3. **Generates a draft reply** if the email is important
4. **Saves the draft in your Gmail** (doesn't send automatically)
5. **You review and edit** the draft before sending

### What It DOESN'T Do:

- ❌ Doesn't send emails automatically
- ❌ Doesn't reply to newsletters/notifications
- ❌ Doesn't modify your existing emails
- ❌ Doesn't work on old emails (only new unread ones)

## 🔍 How to Test in Your Gmail

### Step 1: Verify It's Enabled

1. Go to http://localhost:3000/tools
2. Check that Auto Drafts shows:
   - Toggle: ON
   - Badge: "Connected" (green)
   - Stats show "1 Active"

### Step 2: Send Yourself Test Emails

**Email Type 1: Question That Needs Reply**

```
To: your-email@gmail.com
Subject: Project Update Question

Hi,

Can you send me the latest project timeline? Also, are we still on track for the Friday deadline?

Thanks,
Test Sender
```

**Email Type 2: Meeting Request**

```
To: your-email@gmail.com
Subject: Meeting Request for Next Week

Hi,

I'd like to schedule a meeting to discuss the new features. Are you available Tuesday at 2pm?

Best,
Test Sender
```

**Email Type 3: Client Request**

```
To: your-email@gmail.com
Subject: Urgent: Need assistance with account

Hello,

I'm having trouble accessing my account and need help urgently. Can someone assist me today?

Regards,
Test Client
```

### Step 3: Trigger Auto-Draft Processing

**Option A: Manual Test (Immediate)**

```bash
poetry run python test_auto_draft.py
```

**Option B: Wait for Automatic Processing**

- The monitor checks every 5 minutes
- But currently it's not running automatically (known issue)

### Step 4: Check Your Gmail Drafts

1. **Open Gmail in your browser**
2. **Click "Drafts" folder** (left sidebar)
3. **Look for new drafts with these characteristics:**
   - Subject starts with "Re:"
   - Created within last few minutes
   - Has the original email in the conversation

### Step 5: What the AI Draft Should Look Like

**For Question Email:**

```
Hi Test Sender,

Thank you for reaching out. I'll send you the latest project timeline shortly.

Regarding the Friday deadline, yes, we are still on track. I'll include a status update with the timeline document.

Let me know if you need any additional information.

Best regards,
[Your name]
```

**For Meeting Request:**

```
Hi Test Sender,

Thank you for your message. Tuesday at 2pm works well for me to discuss the new features.

Should we meet via video call or in person? Please send me the meeting details when you have a chance.

Looking forward to our discussion.

Best regards,
[Your name]
```

## 📊 How to Verify It's Working

### In Gmail:

1. **Check Drafts folder** - New drafts appear here
2. **Check draft timestamp** - Should be recent
3. **Check draft content** - Should address the original email
4. **Check threading** - Draft should be in same conversation

### In the Database (Advanced):

```bash
# Check recent auto-draft activity
curl http://localhost:8000/api/auto-drafts/status \
  -H "Authorization: Bearer YOUR_TOKEN"
```

### In the App:

1. The tool card might show usage stats (future feature)
2. Check browser console for any errors

## 🐛 Common Issues & Solutions

### "I don't see any drafts"

1. **Check you sent a "reply-worthy" email** - Not all emails get drafts
2. **Wait 1-2 minutes** - Gmail sync can be slow
3. **Check the right Gmail account** - Make sure you're logged into correct account
4. **Run manual test** - Use `poetry run python test_auto_draft.py`

### "The monitor isn't running automatically"

- Known issue: Background monitor needs to be started manually
- Workaround: Run `poetry run python test_auto_draft.py` periodically

### "Drafts aren't what I expected"

- The AI uses default professional tone
- You can customize in settings:
  - Tone: "casual", "formal", "friendly", etc.
  - Custom instructions: "Always mention availability for calls"

## 🎮 Interactive Testing Workflow

### Quick Test (2 minutes):

1. Send yourself email: "Can we meet tomorrow at 3pm?"
2. Run: `poetry run python test_live_draft.py`
3. Watch console for "Found 1 unread email"
4. Check Gmail drafts for AI response

### Full Test (10 minutes):

1. Send 3 different test emails (question, request, FYI)
2. Run auto-draft processor
3. Check which emails got drafts (not all will)
4. Review draft quality
5. Test editing and sending a draft

## 📈 What Success Looks Like

✅ **Working Correctly When:**

- Important emails get draft replies
- Newsletters/notifications are ignored
- Drafts are contextually appropriate
- Drafts appear in Gmail within 30 seconds
- You can edit drafts before sending

❌ **Not Working When:**

- No drafts appear for any emails
- All emails get drafts (even newsletters)
- Drafts are generic/irrelevant
- Errors in console/logs
- Gmail authentication fails

## 🔧 Debug Commands

```bash
# See what emails are available
poetry run python test_list_emails.py

# Process specific email
poetry run python test_specific_email.py

# Watch for new emails in real-time
poetry run python test_live_draft.py

# Manual batch process
poetry run python test_auto_draft.py
```

## 💡 Pro Tips

1. **Test with real scenarios** - Use actual questions you get
2. **Check draft quality** - AI should match your communication style
3. **Monitor which emails get drafts** - AI learns what's important
4. **Customize settings** - Adjust tone and confidence threshold
5. **Use keyboard shortcuts** - Gmail: 'g' then 'd' goes to drafts

## 🚀 The Big Picture

Auto-Drafts is like having an assistant who:

- Reads your emails when they arrive
- Decides which ones need replies
- Writes a first draft for you
- Puts it in your drafts folder
- Lets you review and improve before sending

It's NOT trying to:

- Replace you completely
- Send emails without your approval
- Handle complex negotiations
- Respond to everything

The goal: Save you time on routine replies so you can focus on important work!
