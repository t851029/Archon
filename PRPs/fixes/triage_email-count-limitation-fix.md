# Email Count Limitation Debug Summary

## Issue

User sees only 11 emails when selecting "Last 11 days" timeframe, expecting more emails to be analyzed.

## Root Causes Identified

1. **Thread vs Message Counting**: Gmail API returns threads (conversations), not individual messages. If you have 11 email threads over 11 days, that's what you see, even if each thread has multiple messages.

2. **Default Limits**:
   - `ListEmailsParams` defaults to 10 emails
   - Triage passes 50 as max, but may be limited by actual thread count

3. **Gmail Query Limitations**:
   - Using `newer_than:264h` for 11 days
   - Gmail might have limits on how far back `newer_than` works effectively

4. **No Pagination**: The system only fetches the first page of results

## Current Flow

1. User selects "Last 11 days" → 264 hours calculated
2. Query built: `newer_than:264h`
3. Gmail API called with `maxResults=50`
4. Returns up to 50 threads (not messages) from last 264 hours
5. Only latest message in each thread is analyzed

## Why Only 11 Emails?

- You likely have exactly 11 email conversation threads in the last 11 days
- Each thread may contain multiple messages, but only the latest is analyzed
- This is working as designed, but may not meet user expectations

## Recommended Solutions

### Option 1: Analyze All Messages (Not Just Threads)

Change from threads to messages API to analyze every email:

```python
# Instead of threads().list()
messages_response = service.users().messages().list(
    userId="me",
    q=gmail_query,
    maxResults=params.max_emails
).execute()
```

### Option 2: Increase Default Limits

```python
# In triage tool config
max_emails: 100  # Increase from 50
```

### Option 3: Add Pagination

Fetch multiple pages of results to get more emails:

```python
all_threads = []
page_token = None
while len(all_threads) < max_emails:
    response = service.users().threads().list(
        userId="me",
        q=query,
        maxResults=min(50, max_emails - len(all_threads)),
        pageToken=page_token
    ).execute()
    all_threads.extend(response.get('threads', []))
    page_token = response.get('nextPageToken')
    if not page_token:
        break
```

### Option 4: Use Date-Based Query

Instead of `newer_than`, use explicit date ranges:

```python
# More reliable for longer periods
after_date = (datetime.now() - timedelta(days=11)).strftime('%Y/%m/%d')
query = f"after:{after_date}"
```

## Immediate Workaround

To analyze more emails right now:

1. Use a more specific query like `is:unread after:2024/12/20`
2. Run triage multiple times with different queries
3. Understand that "11 emails" means "11 conversation threads"
