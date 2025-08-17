name: "Time Tracking Agentic - Speed-First Implementation"
description: |
Time tracking assistant using AI agent tool calling patterns with focus on SPEED OF IMPLEMENTATION.
Leverages existing triage_emails patterns, gmail_helpers, and OpenAI function calling architecture.

---

## Goal

Build a time tracking assistant that uses AI agent tool calling patterns (not background monitoring) to scan sent emails for billable time mentions. Must integrate with existing OpenAI function calling architecture where tools are registered in available_tools dictionary and called via chat API. Emphasize rapid delivery through aggressive code reuse and simplified architecture.

## Why

- **Speed of Implementation**: Leverage 80% of existing email tools pattern (triage_emails) to reduce implementation time from weeks to days
- **Framework Utilization**: Maximize reuse of gmail_helpers, email_schemas, and OpenAI tool patterns
- **Quick Wins**: Deliver MVP functionality in minimal time with iterative enhancement
- **Reduced Complexity**: Simplify architecture by copying proven patterns rather than building from scratch
- **Fast Feedback Loops**: Get working prototype to users quickly for validation and refinement

## What

### Core Features (AI Tools via Chat API)

1. **scan_billable_time**: Scan sent emails for time entries (copy triage_emails pattern)
2. **analyze_time_entry**: Analyze specific email for billable activities (copy get_email_details pattern)
3. **get_time_tracking_summary**: Get recent time tracking results (copy database query pattern)
4. **configure_time_tracking**: Basic settings management (copy settings pattern)

### Success Criteria

- [ ] **Working Tools**: All 4 tools callable via chat interface within 2 days
- [ ] **Database Integration**: Time entries stored in Supabase with RLS policies within 1 day
- [ ] **Email Pattern Matching**: Basic regex patterns extracting time mentions within 4 hours
- [ ] **Frontend Integration**: Tools appear in chat interface immediately (0 new UI needed)
- [ ] **Data Persistence**: Results stored and retrievable within 1 day
- [ ] **Error Handling**: Copy existing error patterns without modification

## All Needed Context

### Documentation & References (Rapid Implementation Focus)

```yaml
# MUST READ - Copy these patterns exactly
- file: /home/jron/wsl_project/jerin-lt-139-time-reviewer-tool/api/utils/tools.py
  why: Copy triage_emails function structure exactly for scan_billable_time
  focus: Lines around triage_emails function - async patterns, error handling, database storage

- file: /home/jron/wsl_project/jerin-lt-139-time-reviewer-tool/api/utils/email_schemas.py
  why: Copy TriageEmailParams and EmailTriageResult patterns for time tracking schemas
  focus: Pydantic model patterns, validation, field definitions

- file: /home/jron/wsl_project/jerin-lt-139-time-reviewer-tool/api/utils/gmail_helpers.py
  why: Copy get_email and email parsing functions without modification
  focus: Email content extraction, header parsing, body text processing

- file: /home/jron/wsl_project/jerin-lt-139-time-reviewer-tool/api/index.py
  why: Copy available_tools registration and OpenAI tool definition patterns
  focus: Tool registration dict, OpenAI function schema definitions

- file: /home/jron/wsl_project/jerin-lt-139-time-reviewer-tool/supabase/migrations/20240101000000_email_triage.sql
  why: Copy table structure and RLS policies for time tracking tables
  focus: Table creation, user_id patterns, RLS policy syntax
```

### Current Codebase Analysis - Reusable Components

**Existing Patterns for Direct Reuse:**

- **Tool Registration**: `available_tools` dict in index.py - copy pattern exactly
- **Email Fetching**: `list_emails` with Gmail query support - reuse with different query
- **Email Parsing**: `get_email` function - reuse without modification
- **Database Storage**: `store_triage_result` pattern - copy for time entries
- **Error Handling**: HTTPException patterns throughout tools.py - copy exactly
- **Dependency Injection**: FastAPI Depends pattern - reuse all existing dependencies
- **Pydantic Schemas**: EmailTriageResult structure - copy for TimeTrackingResult

**Copy-Paste Ready Components:**

```python
# FROM triage_emails function - COPY EXACTLY
async def scan_billable_time(
    params: TimeTrackingParams,  # Copy TriageEmailParams structure
    service: Resource = Depends(get_gmail_service),
    openai_client: OpenAI = Depends(get_openai_client),
    user_id: str = Depends(get_current_user_id),
    supabase_client: Client = Depends(get_supabase_client),
) -> TimeTrackingResult:  # Copy BatchTriageResult structure
    # Copy entire triage_emails function body
    # Replace triage-specific logic with time parsing
    # Keep all error handling, logging, database storage patterns
```

### Desired Codebase tree - Minimal Changes

```bash
api/
├── utils/
│   ├── tools.py                      # ADD 4 new functions (copy existing patterns)
│   ├── email_schemas.py              # ADD 3 new schemas (copy existing patterns)
│   └── time_parsing_utils.py         # NEW FILE - simple regex patterns (50 lines max)
├── index.py                          # ADD 4 tool registrations (copy existing format)
└── supabase/migrations/
    └── 20250204000000_time_tracking.sql  # NEW FILE - copy triage table structure
```

### Known Gotchas & Speed Shortcuts

```python
# CRITICAL: Copy existing patterns exactly to avoid debugging
# Pattern: Use same error handling as triage_emails
try:
    # Tool logic here
except HTTPException:
    raise  # Re-raise as-is
except Exception as e:
    raise HTTPException(
        status_code=500, detail=f"Failed to scan time: {str(e)}"
    )

# CRITICAL: Copy database storage pattern exactly
# Pattern: Use same upsert logic as store_triage_result
result = (
    supabase_client.table("time_tracking_results")
    .upsert(time_data)
    .execute()
)

# SPEED HACK: Use simple regex patterns initially
SIMPLE_TIME_PATTERNS = [
    r'\b(\d+(?:\.\d+)?)\s*(hours?|hrs?|h)\b',
    r'\b(\d+)\s*(minutes?|mins?|m)\b',
    r'\breview(?:ed)?\s+(?:\w+\s+)*(contract|agreement)',
    r'\bdraft(?:ed)?\s+(?:\w+\s+)*(letter|email|document)',
]
```

## Implementation Blueprint

### Data models and structure

Copy existing triage schemas exactly with minimal modifications:

```python
# COPY FROM EmailTriageResult - change field names only
class TimeTrackingResult(BaseModel):
    email_id: str = Field(..., description="Gmail message ID")
    activity_type: str = Field(..., description="Type of billable activity detected")
    duration_minutes: Optional[int] = Field(None, description="Estimated duration in minutes")
    confidence_score: float = Field(..., description="Confidence score 0.0 to 1.0")
    activity_description: str = Field(..., description="Description of the activity")
    # Copy all other fields from EmailTriageResult structure
```

### List of tasks to be completed (SPEED-FIRST ORDER)

```yaml
Task 1: Database Schema (15 minutes)
COPY supabase/migrations/20240101000000_email_triage.sql:
  - FIND table name "email_triage_results"
  - REPLACE with "time_tracking_results"
  - MODIFY column names for time tracking fields
  - KEEP all RLS policies and user_id patterns identical

Task 2: Pydantic Schemas (30 minutes)
MODIFY api/utils/email_schemas.py:
  - COPY TriageEmailParams class
  - RENAME to TimeTrackingParams
  - COPY EmailTriageResult class
  - RENAME to TimeTrackingResult
  - MODIFY field names for time tracking (keep validation patterns)

Task 3: Time Parsing Utility (45 minutes)
CREATE api/utils/time_parsing_utils.py:
  - DEFINE basic regex patterns (5-10 patterns max)
  - CREATE simple parsing function (30 lines max)
  - NO complex NLP - just regex matching
  - RETURN structured results matching TimeTrackingResult

Task 4: Core Tools Implementation (2 hours)
MODIFY api/utils/tools.py:
  - COPY triage_emails function entirely
  - RENAME to scan_billable_time
  - REPLACE triage logic with time parsing calls
  - KEEP all error handling, logging, database patterns identical
  - COPY 3 other functions using same pattern

Task 5: Tool Registration (15 minutes)
MODIFY api/index.py:
  - COPY triage_emails registration from available_tools
  - ADD 4 new tool registrations using identical format
  - COPY OpenAI function definitions from triage tools
  - MODIFY descriptions only - keep parameter structures

Task 6: Database Storage (30 minutes)
MODIFY api/utils/tools.py:
  - COPY store_triage_result function entirely
  - RENAME to store_time_tracking_result
  - CHANGE table name only
  - KEEP all error handling and logging identical
```

### Per task pseudocode (COPY-PASTE PATTERNS)

```python
# Task 3: Time Parsing (SIMPLIFIED FOR SPEED)
def extract_time_mentions(email_body: str) -> List[Dict]:
    """Copy pattern from triage email analysis - simplified for time"""
    results = []

    # SPEED HACK: Simple regex only
    for pattern in SIMPLE_TIME_PATTERNS:
        matches = re.findall(pattern, email_body, re.IGNORECASE)
        for match in matches:
            results.append({
                'activity_type': 'Time Entry',  # Generic initially
                'duration_minutes': extract_minutes(match),
                'confidence_score': 0.7,  # Fixed confidence for MVP
                'activity_description': match
            })

    return results

# Task 4: Core Tool (COPY EXACT PATTERN)
async def scan_billable_time(
    params: TimeTrackingParams,
    service: Resource = Depends(get_gmail_service),
    openai_client: OpenAI = Depends(get_openai_client),
    user_id: str = Depends(get_current_user_id),
    supabase_client: Client = Depends(get_supabase_client),
) -> TimeTrackingResult:
    """COPY triage_emails function structure exactly"""
    logger.info(f"Tool: Attempting scan_billable_time with params: {params}")
    start_time = time.time()

    try:
        # COPY email fetching logic from triage_emails
        # REPLACE triage analysis with time parsing
        # KEEP all error handling identical
        # COPY database storage pattern exactly

        pass  # Copy implementation here

    except HTTPException:
        raise  # Copy exact error handling
    except Exception as e:
        logger.error(f"Unexpected error in scan_billable_time: {e}", exc_info=True)
        raise HTTPException(
            status_code=500, detail=f"Failed to scan billable time: {str(e)}"
        )
```

### Integration Points (COPY EXISTING)

```yaml
DATABASE:
  - migration: "COPY email_triage_results table structure exactly"
  - policies: "COPY RLS policies without modification"

OPENAI_TOOLS:
  - registration: "COPY triage_emails registration pattern exactly"
  - schema: "COPY triage function definition format exactly"

GMAIL_API:
  - queries: "REUSE existing list_emails query patterns"
  - parsing: "REUSE get_email function without modification"
```

## Validation Loop

### Level 1: Syntax & Style (COPY VALIDATION PATTERNS)

```bash
# COPY validation commands from existing tools
poetry run black api/utils/tools.py
poetry run mypy api/utils/tools.py
poetry run flake8 api/utils/tools.py

# Expected: No errors (copying working code)
```

### Level 2: Unit Tests (COPY TEST PATTERNS)

```python
# COPY test structure from test_triage_tools.py exactly
def test_scan_billable_time_basic():
    """Copy test pattern from triage tests"""
    # Copy mock setup from triage tests
    # Replace assertions for time tracking
    pass

def test_time_parsing_regex():
    """Simple regex validation"""
    test_text = "I spent 2 hours reviewing the contract"
    results = extract_time_mentions(test_text)
    assert len(results) > 0
    assert results[0]['duration_minutes'] == 120
```

### Level 3: Integration Test (COPY CHAT PATTERN)

```bash
# Test via chat interface immediately
# User message: "Please use scan_billable_time to check my sent emails for billable time"
# Expected: Tool executes, returns time tracking results

# Copy curl test from triage integration tests
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -d '{"messages": [{"role": "user", "content": "Scan my emails for billable time"}]}'
```

### Level 4: Database Validation (COPY DB CHECKS)

```bash
# COPY database validation from triage tests
# Check data stored correctly
# Verify RLS policies work
# Test user isolation
```

## Final validation Checklist

- [ ] All 4 tools registered in available_tools: `grep -E "scan_billable_time|analyze_time_entry" api/index.py`
- [ ] Database migration applied: `npx supabase migration list`
- [ ] Types regenerated: `pnpm types && grep -E "time_tracking" apps/web/types/supabase.ts`
- [ ] Tools callable via chat: Manual test with "scan my emails for time"
- [ ] Data persistence: Check Supabase Studio for time_tracking_results table
- [ ] Error handling: Copy patterns ensure graceful failures
- [ ] No breaking changes: All existing tools still work

---

## Anti-Patterns to Avoid (SPEED FOCUS)

- ❌ Don't create new patterns when existing ones work perfectly
- ❌ Don't over-engineer time parsing - simple regex is sufficient for MVP
- ❌ Don't build new UI components - use existing chat interface
- ❌ Don't modify existing code unless absolutely necessary
- ❌ Don't add complex features initially - focus on core functionality
- ❌ Don't write extensive tests initially - copy existing test patterns only
- ❌ Don't optimize prematurely - copy working patterns first

## Speed Implementation Notes

**Day 1 Target (4 hours total):**

- Database schema: 15 min
- Pydantic models: 30 min
- Time parsing utility: 45 min
- Core tool implementation: 2 hours
- Tool registration: 15 min
- Basic testing: 15 min

**Day 2 Target (2 hours total):**

- Integration testing: 1 hour
- Bug fixes: 30 min
- Documentation: 30 min

**Total Implementation Time: 6 hours maximum**

**Success Metric**: Working time tracking tools callable via chat interface within 6 hours of development time by copying existing patterns.
