# Auto-Drafts Phase 2 - Production Readiness & Enhanced Features

## Goal

Complete the production-ready implementation of the Auto-Drafts feature by fixing the background monitor, adding real-time UI updates, implementing smart scheduling with Google Calendar integration, and improving email classification accuracy. This phase transforms the MVP into a reliable, intelligent email assistant that users can depend on daily.

## Why

- **Reliability**: Current manual-only processing prevents true automation
- **User Experience**: No visibility into draft creation status or activity
- **Intelligence**: Missing calendar context for scheduling emails
- **Accuracy**: Basic classification misses nuanced email types
- **Scale**: Current polling architecture won't scale efficiently

## What

A fully automated, production-ready auto-draft system with:

- Reliable background monitoring that starts automatically
- Real-time UI updates showing draft counts and processing status
- Google Calendar integration for intelligent scheduling responses
- Enhanced email classification with thread awareness
- Production-grade error handling and duplicate prevention

### Success Criteria

- [ ] Background monitor starts automatically and recovers from crashes
- [ ] UI shows real-time draft count badge and last processed timestamp
- [ ] Calendar availability included in scheduling-type draft responses
- [ ] No duplicate drafts created for same email
- [ ] 95%+ accuracy in newsletter/notification filtering
- [ ] Processing completes within 10 seconds per email batch
- [ ] Zero data loss during service restarts

## All Needed Context

### Documentation & References

```yaml
# MUST READ - Include these in your context window
- url: https://fastapi.tiangolo.com/tutorial/background-tasks/
  why: FastAPI background tasks official documentation

- url: https://betterstack.com/community/guides/scaling-python/background-tasks-in-fastapi/
  why: Production patterns for FastAPI background tasks (2025)

- url: https://swr.vercel.app/docs/with-nextjs
  why: SWR with Next.js for real-time updates

- url: https://dev.to/brinobruno/real-time-web-communication-longshort-polling-websockets-and-sse-explained-nextjs-code-1l43
  why: Real-time patterns comparison for Next.js

- url: https://clerk.com/docs/authentication/social-connections/google
  why: Google OAuth scopes configuration in Clerk

- url: https://developers.google.com/calendar/api/v3/reference
  why: Google Calendar API reference

- file: /api/utils/auto_draft_monitor.py
  why: Current background monitor implementation to fix

- file: /api/index.py
  why: FastAPI startup/shutdown event handlers

- file: /apps/web/hooks/use-triage-data.ts
  why: SWR pattern for real-time data fetching

- file: /apps/web/components/tools/tool-card.tsx
  why: Where to add draft count badge

- file: /api/utils/tools.py
  why: Email classification and processing functions

- file: /api/core/dependencies.py
  why: Gmail service and OAuth token retrieval patterns
```

### Current Codebase Tree (Relevant Files)

```bash
living-tree/
├── api/
│   ├── core/
│   │   ├── dependencies.py          # Gmail/OAuth helpers
│   │   └── config.py               # Environment config
│   ├── utils/
│   │   ├── auto_draft_monitor.py   # Background monitor (broken)
│   │   ├── tools.py                # Email processing functions
│   │   └── gmail_helpers.py        # Gmail API integration
│   ├── routes/                     # No auto-draft routes yet
│   └── index.py                    # FastAPI app with startup events
├── apps/web/
│   ├── components/tools/
│   │   ├── tool-card.tsx           # Needs draft count badge
│   │   └── auto-drafts-settings.tsx # Settings UI
│   ├── hooks/
│   │   └── use-triage-data.ts      # SWR pattern to follow
│   └── app/api/                    # Next.js API routes
```

### Known Gotchas & Library Quirks

```python
# CRITICAL: FastAPI asyncio background tasks
# The current implementation has a race condition on startup
# asyncio.create_task() in startup event doesn't guarantee execution
# Solution: Use proper task management with error recovery

# GOTCHA: Clerk OAuth token retrieval is async
# Must use await clerkClient.users.getUserOauthAccessToken()
# Tokens expire - need refresh logic

# GOTCHA: Google Calendar API rate limits
# 1,000,000 queries per day, 50 requests per second
# Must implement exponential backoff

# GOTCHA: SWR with server components
# Must use 'use client' directive for components using SWR
# Server components can't use hooks

# CRITICAL: Supabase RLS policies
# All tables must use current_user_id() function, not auth.uid()
# User IDs are TEXT type from Clerk, not UUID

# GOTCHA: Gmail API message IDs are not stable
# Use threadId for duplicate detection instead
```

## Implementation Blueprint

### Phase Structure

```
Phase 2A: Fix Background Monitoring (Critical)
├── Fix startup race condition
├── Add health checks and recovery
├── Implement graceful shutdown
└── Add monitoring/logging

Phase 2B: Real-time UI Updates
├── Create draft stats API endpoint
├── Implement SWR polling hook
├── Add draft count badge to tool card
├── Show last processed timestamp

Phase 2C: Google Calendar Integration
├── Add calendar scopes to Clerk
├── Create calendar service wrapper
├── Enhance scheduling draft generation
└── Handle timezone conversions

Phase 2D: Enhanced Classification
├── Implement thread awareness
├── Improve newsletter detection
├── Add language detection
└── Create classification cache
```

### List of Tasks to Complete (In Order)

```yaml
Task 1: Fix Background Monitor Startup
MODIFY api/index.py:
  - REFACTOR startup event to use proper task management
  - ADD error recovery and retry logic
  - IMPLEMENT health check endpoint
  - ADD graceful shutdown handler
  - PRESERVE existing monitor logic

Task 2: Create Draft Statistics API
CREATE api/routes/auto_drafts.py:
  - IMPLEMENT GET /api/auto-drafts/stats endpoint
  - RETURN draft counts, last processed time
  - USE existing Supabase queries
  - FOLLOW error handling patterns from other routes
  - ADD proper JWT authentication

Task 3: Add Real-time UI Updates
CREATE apps/web/hooks/use-auto-draft-stats.ts:
  - IMPLEMENT SWR hook with 30s polling
  - FOLLOW pattern from use-triage-data.ts
  - HANDLE loading and error states
  - RETURN formatted stats for UI

MODIFY apps/web/components/tools/tool-card.tsx:
  - ADD draft count badge component
  - SHOW last processed timestamp
  - USE the new SWR hook
  - PRESERVE existing UI structure

Task 4: Add Process Now Button
MODIFY apps/web/components/tools/auto-drafts-settings.tsx:
  - ADD "Process Now" button
  - IMPLEMENT manual trigger API call
  - SHOW processing state
  - HANDLE success/error feedback

Task 5: Implement Duplicate Prevention
MODIFY api/utils/auto_draft_monitor.py:
  - TRACK processed thread IDs
  - CHECK before creating new drafts
  - USE Supabase for persistence
  - IMPLEMENT TTL for old entries

Task 6: Add Google Calendar Integration
MODIFY api/core/dependencies.py:
  - ADD get_calendar_service() function
  - IMPLEMENT OAuth token refresh
  - FOLLOW Gmail service pattern
  - HANDLE scope errors gracefully

CREATE api/utils/calendar_helpers.py:
  - IMPLEMENT check_availability() function
  - HANDLE timezone conversions
  - PARSE free/busy data
  - RETURN formatted slots

MODIFY api/utils/tools.py:
  - ENHANCE generate_auto_draft() for scheduling
  - INTEGRATE calendar availability
  - PRESERVE existing generation logic
  - ADD calendar data to prompt

Task 7: Enhance Email Classification
MODIFY api/utils/tools.py:
  - IMPROVE classify_email_for_auto_draft()
  - ADD thread context checking
  - IMPLEMENT newsletter patterns
  - ADD language detection
  - CACHE classification results

Task 8: Production Hardening
CREATE api/utils/monitoring.py:
  - ADD performance metrics
  - IMPLEMENT error tracking
  - CREATE health check logic
  - ADD resource monitoring

MODIFY all error handlers:
  - ADD structured logging
  - IMPLEMENT retry logic
  - PRESERVE user context
  - NOTIFY on critical errors
```

### Per Task Pseudocode

```python
# Task 1: Fix Background Monitor Startup
# api/index.py
import asyncio
from contextlib import asynccontextmanager
from api.utils.auto_draft_monitor import monitor

# Global reference to background task
background_tasks = set()

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    logger.info("🚀 Starting Living Tree API")

    # Start background monitor with proper error handling
    task = asyncio.create_task(start_monitor_with_recovery())
    background_tasks.add(task)
    task.add_done_callback(background_tasks.discard)

    yield

    # Shutdown
    logger.info("🛑 Shutting down Living Tree API")

    # Cancel all background tasks
    for task in background_tasks:
        task.cancel()

    # Wait for all tasks to complete
    await asyncio.gather(*background_tasks, return_exceptions=True)

async def start_monitor_with_recovery():
    """Start monitor with automatic recovery on failure"""
    max_retries = 3
    retry_delay = 60  # seconds

    while True:
        try:
            logger.info("📧 Starting auto-draft monitor")
            await monitor.start_monitoring()
        except Exception as e:
            logger.error(f"Monitor crashed: {e}", exc_info=True)
            await asyncio.sleep(retry_delay)
            retry_delay = min(retry_delay * 2, 3600)  # Exponential backoff

app = FastAPI(lifespan=lifespan)

# Task 2: Create Draft Statistics API
# api/routes/auto_drafts.py
from fastapi import APIRouter, Depends, HTTPException
from typing import Dict, Any
from datetime import datetime, timedelta

router = APIRouter(prefix="/api/auto-drafts", tags=["auto-drafts"])

@router.get("/stats")
async def get_auto_draft_stats(
    user_id: str = Depends(get_current_user_id),
    supabase: Client = Depends(get_supabase_client)
) -> Dict[str, Any]:
    """Get auto-draft statistics for the current user"""
    try:
        # Get draft counts from last 24 hours
        since = (datetime.utcnow() - timedelta(days=1)).isoformat()

        result = supabase.table("draft_metadata") \
            .select("*", count="exact") \
            .eq("user_id", user_id) \
            .gte("created_at", since) \
            .execute()

        # Get last processed time
        last_processed = supabase.table("email_triage_results") \
            .select("created_at") \
            .eq("user_id", user_id) \
            .order("created_at", desc=True) \
            .limit(1) \
            .execute()

        return {
            "drafts_created_24h": result.count or 0,
            "last_processed": last_processed.data[0]["created_at"] if last_processed.data else None,
            "monitor_status": "active",  # TODO: Get from monitor health check
            "next_check": (datetime.utcnow() + timedelta(minutes=5)).isoformat()
        }

    except Exception as e:
        logger.error(f"Error fetching auto-draft stats: {e}")
        raise HTTPException(status_code=500, detail="Failed to fetch statistics")

# Task 3: Real-time UI Updates
# apps/web/hooks/use-auto-draft-stats.ts
import useSWR from 'swr';
import { useAuth } from '@clerk/nextjs';

interface AutoDraftStats {
  drafts_created_24h: number;
  last_processed: string | null;
  monitor_status: 'active' | 'inactive' | 'error';
  next_check: string;
}

export function useAutoDraftStats() {
  const { getToken } = useAuth();

  const fetcher = async (url: string) => {
    const token = await getToken();
    const response = await fetch(url, {
      headers: {
        'Authorization': `Bearer ${token}`,
      },
    });

    if (!response.ok) {
      throw new Error('Failed to fetch stats');
    }

    return response.json();
  };

  const { data, error, mutate } = useSWR<AutoDraftStats>(
    '/api/auto-drafts/stats',
    fetcher,
    {
      refreshInterval: 30000, // Poll every 30 seconds
      revalidateOnFocus: true,
      revalidateOnReconnect: true,
    }
  );

  return {
    stats: data,
    isLoading: !error && !data,
    isError: error,
    mutate,
  };
}

# Task 5: Duplicate Prevention
# api/utils/auto_draft_monitor.py
class AutoDraftMonitor:
    def __init__(self):
        self.processing_interval = 300
        self.processed_threads: Set[str] = set()  # In-memory cache
        self.cache_ttl = 86400  # 24 hours

    async def _is_thread_processed(self, thread_id: str, user_id: str) -> bool:
        """Check if we've already processed this thread"""
        # Quick in-memory check
        if thread_id in self.processed_threads:
            return True

        # Database check for persistence
        supabase = get_supabase_client()
        result = supabase.table("draft_metadata") \
            .select("id") \
            .eq("user_id", user_id) \
            .eq("thread_id", thread_id) \
            .gte("created_at", datetime.now() - timedelta(seconds=self.cache_ttl)) \
            .execute()

        if result.data:
            self.processed_threads.add(thread_id)
            return True

        return False

# Task 6: Google Calendar Integration
# api/utils/calendar_helpers.py
from googleapiclient.discovery import build
from datetime import datetime, timedelta
import pytz

async def check_availability(
    calendar_service,
    duration_minutes: int = 60,
    days_ahead: int = 7,
    timezone: str = "America/New_York"
) -> List[Dict[str, str]]:
    """
    Check calendar availability and return free slots
    """
    tz = pytz.timezone(timezone)
    now = datetime.now(tz)
    time_min = now.isoformat()
    time_max = (now + timedelta(days=days_ahead)).isoformat()

    # Get free/busy information
    body = {
        "timeMin": time_min,
        "timeMax": time_max,
        "items": [{"id": "primary"}],
        "timeZone": timezone
    }

    freebusy = calendar_service.freebusy().query(body=body).execute()
    busy_times = freebusy['calendars']['primary']['busy']

    # Find free slots (simplified - would need more complex logic)
    free_slots = []
    # ... slot calculation logic ...

    return free_slots

# Task 7: Enhanced Classification
# api/utils/tools.py
NEWSLETTER_PATTERNS = [
    "unsubscribe", "newsletter", "weekly digest", "daily summary",
    "no-reply", "noreply", "do-not-reply", "notification",
    "alert@", "updates@", "news@", "digest@"
]

async def classify_email_for_auto_draft(
    email_data: dict,
    openai_client: OpenAI,
    thread_context: Optional[List[dict]] = None
) -> Dict[str, Any]:
    # Check if already replied in thread
    if thread_context:
        for msg in thread_context:
            if msg.get("from_me") and msg.get("is_reply"):
                return {
                    "needs_reply": False,
                    "reason": "already_replied_in_thread",
                    "confidence": 1.0
                }

    # Quick newsletter check
    sender = email_data.get("sender", "").lower()
    subject = email_data.get("subject", "").lower()
    body = email_data.get("body_plain", "").lower()

    for pattern in NEWSLETTER_PATTERNS:
        if pattern in sender or pattern in subject or pattern in body:
            return {
                "needs_reply": False,
                "reason": "newsletter_pattern",
                "confidence": 0.95
            }

    # Language detection
    # ... (use langdetect or similar)

    # AI classification for complex cases
    # ... (existing logic)
```

### Integration Points

```yaml
DATABASE:
  - tables: draft_metadata (add thread_id column), processing_cache
  - indexes: CREATE INDEX idx_thread_processed ON draft_metadata(user_id, thread_id)
  - monitoring: Add draft_monitor_health table for status tracking

GMAIL_API:
  - methods: users.threads.get for context, users.messages.list with q parameter
  - rate_limits: Implement exponential backoff on 429 errors
  - caching: Cache thread data for 5 minutes to reduce API calls

GOOGLE_CALENDAR_API:
  - methods: freebusy.query, events.list
  - scopes: https://www.googleapis.com/auth/calendar.readonly
  - rate_limits: 1,000,000 queries/day, implement daily quota tracking

CLERK_OAUTH:
  - scopes: Add calendar scopes in Clerk dashboard
  - tokens: Implement refresh logic for expired tokens
  - fallback: Graceful degradation if calendar not authorized

FASTAPI:
  - lifespan: Use new lifespan context manager (not deprecated events)
  - monitoring: Add /health endpoint for container orchestration
  - logging: Structured JSON logging for production
```

## Validation Loop

### Level 1: Syntax & Style

```bash
# Backend validation
cd api/
poetry run black .
poetry run ruff check --fix
poetry run mypy .

# Frontend validation
cd apps/web/
pnpm lint
pnpm type-check

# Expected: No errors
```

### Level 2: Unit Tests

```python
# api/tests/test_auto_draft_monitor.py
import pytest
from unittest.mock import Mock, AsyncMock

@pytest.mark.asyncio
async def test_monitor_recovery():
    """Monitor recovers from crashes"""
    monitor = AutoDraftMonitor()
    monitor._process_batch = AsyncMock(side_effect=Exception("Simulated crash"))

    # Should not raise
    task = asyncio.create_task(monitor.start_monitoring())
    await asyncio.sleep(0.1)
    task.cancel()

@pytest.mark.asyncio
async def test_duplicate_prevention():
    """No duplicate drafts for same thread"""
    monitor = AutoDraftMonitor()

    # First call should return False
    assert not await monitor._is_thread_processed("thread123", "user123")

    # Mark as processed
    monitor.processed_threads.add("thread123")

    # Second call should return True
    assert await monitor._is_thread_processed("thread123", "user123")

# apps/web/__tests__/use-auto-draft-stats.test.ts
import { renderHook } from '@testing-library/react-hooks';
import { useAutoDraftStats } from '@/hooks/use-auto-draft-stats';

describe('useAutoDraftStats', () => {
  it('polls for updates every 30 seconds', async () => {
    const { result, waitForNextUpdate } = renderHook(() => useAutoDraftStats());

    expect(result.current.isLoading).toBe(true);

    await waitForNextUpdate();

    expect(result.current.stats).toBeDefined();
    expect(result.current.stats.drafts_created_24h).toBeGreaterThanOrEqual(0);
  });
});
```

```bash
# Run tests
cd api/ && poetry run pytest -xvs
cd apps/web/ && pnpm test
```

### Level 3: Integration Tests

```bash
# Start services
pnpm dev:full

# Test background monitor health
curl http://localhost:8000/health

# Test draft stats endpoint
curl -H "Authorization: Bearer $CLERK_TOKEN" \
  http://localhost:8000/api/auto-drafts/stats

# Test manual process trigger
curl -X POST -H "Authorization: Bearer $CLERK_TOKEN" \
  http://localhost:8000/api/auto-drafts/process-now

# Expected: All return 200 OK with valid JSON
```

### Level 4: End-to-End Tests

```typescript
// tests/e2e/auto-drafts-realtime.spec.ts
import { test, expect } from "@playwright/test";

test("draft count updates in real-time", async ({ page }) => {
  // Login and navigate to tools
  await page.goto("/tools");

  // Check initial draft count
  const badge = page.locator('[data-testid="draft-count-badge"]');
  const initialCount = await badge.textContent();

  // Send test email via API
  await page.request.post("/api/test/send-email", {
    data: { subject: "Test for auto-draft" },
  });

  // Wait for update (max 35 seconds due to 30s polling)
  await expect(badge).not.toHaveText(initialCount, { timeout: 35000 });

  // Verify count increased
  const newCount = parseInt((await badge.textContent()) || "0");
  expect(newCount).toBeGreaterThan(parseInt(initialCount || "0"));
});
```

## Final Validation Checklist

- [ ] Background monitor starts automatically on server start
- [ ] Monitor recovers from crashes without data loss
- [ ] Draft count badge updates within 30 seconds
- [ ] No duplicate drafts created for same email thread
- [ ] Calendar availability included in scheduling responses
- [ ] Newsletter emails correctly filtered (95%+ accuracy)
- [ ] Processing completes within 10 seconds per batch
- [ ] All errors logged with context for debugging
- [ ] Health endpoint returns accurate monitor status
- [ ] Graceful shutdown completes all pending operations

## Anti-Patterns to Avoid

- ❌ Don't use threading in asyncio context - use asyncio.create_task
- ❌ Don't poll Gmail too frequently - respect rate limits
- ❌ Don't store OAuth tokens in code - use Clerk's secure storage
- ❌ Don't process emails without checking thread context
- ❌ Don't create drafts without duplicate prevention
- ❌ Don't ignore timezone differences in calendar integration
- ❌ Don't use deprecated FastAPI event handlers
- ❌ Don't store sensitive email content in logs
- ❌ Don't process emails in untrusted languages
- ❌ Don't retry failed operations indefinitely

---

## Implementation Confidence Score: 8.5/10

**High confidence due to:**

- Comprehensive context with specific file references
- Detailed pseudocode for complex sections
- Clear validation gates at each level
- Production-tested patterns from 2025 research
- Existing codebase patterns to follow

**Minor risks:**

- Google Calendar API integration complexity
- Potential race conditions in distributed systems
- SWR polling vs SSE tradeoff for real-time updates
