# Auto Drafts Feature - PRP Implementation Guide

## Goal

Complete the implementation of the Auto Drafts feature for automatically generating contextually appropriate email responses. The feature should intelligently analyze incoming emails, classify those needing replies, and automatically generate drafts that match the user's communication style and tone preferences.

## Why

- **User Productivity**: Reduce time spent on routine email composition by 60-80%
- **AI Integration**: Leverage existing AI infrastructure to provide proactive email assistance
- **Competitive Advantage**: Differentiate the platform with intelligent, automated email drafting
- **Business Value**: Increase user engagement and platform stickiness through valuable automation

## What

A fully automated email drafting system that:

- Monitors incoming emails in real-time
- Classifies emails requiring responses vs. newsletters/notifications
- Generates contextually relevant drafts matching user's communication style
- Saves drafts to Gmail with tracking metadata
- Provides user controls for tone customization and feature enablement

### Success Criteria

- [ ] Auto-draft feature can be enabled/disabled via tools page
- [ ] Email classification accuracy >85% for reply-worthy vs. ignorable emails
- [ ] Draft generation completes within 60 seconds of email receipt
- [ ] Generated drafts match user's communication style and specified tone
- [ ] Drafts are saved to Gmail with proper threading and metadata
- [ ] User settings persist and control draft generation behavior
- [ ] Background processing handles high email volumes without blocking

## All Needed Context

### Documentation & References

```yaml
# MUST READ - Include these in your context window
- url: https://developers.google.com/gmail/api/reference/rest/v1/users.drafts/create
  why: Core API for creating drafts in Gmail

- url: https://platform.openai.com/docs/guides/function-calling
  why: OpenAI function calling patterns for email generation with structured outputs

- url: https://fastapi.tiangolo.com/tutorial/background-tasks/
  why: FastAPI background task patterns for async email processing

- file: /apps/web/components/tools/auto-drafts-dialog.tsx
  why: Frontend UI patterns for settings and controls

- file: /apps/web/components/tools/auto-drafts-settings.tsx
  why: Settings management UI components

- file: /api/utils/tools.py
  why: Existing tool patterns and draft_email_response function

- file: /api/utils/gmail_helpers.py
  why: Gmail API integration patterns and create_draft function

- file: /supabase/migrations/20250111000000_auto_drafts.sql
  why: Database schema for auto-drafts feature

- file: /api/tests/test_auto_drafts.py
  why: Test patterns and expected function signatures

- url: https://fastdatascience.com/natural-language-processing/fast-stylometry-python-library/
  why: Communication style analysis using Fast Stylometry library

- url: https://towardsdatascience.com/the-best-machine-learning-algorithm-for-email-classification-39888e7b1846
  why: Email classification techniques and ML approaches
```

### Current Codebase Tree (Relevant Files)

```bash
living-tree/
├── api/
│   ├── utils/
│   │   ├── tools.py              # Contains draft_email_response function
│   │   ├── gmail_helpers.py      # Gmail API integration
│   │   └── email_schemas.py      # Email data models
│   ├── tests/
│   │   └── test_auto_drafts.py   # Test coverage for missing functions
│   └── index.py                  # Main FastAPI app
├── apps/web/
│   ├── components/tools/
│   │   ├── auto-drafts-dialog.tsx    # Settings UI
│   │   └── auto-drafts-settings.tsx  # Configuration UI
│   ├── lib/
│   │   └── tools-config.ts       # Tool configuration
│   └── app/(app)/tools/
│       └── page.tsx              # Tools page with toggles
├── supabase/migrations/
│   └── 20250111000000_auto_drafts.sql  # Database schema
```

### Desired Codebase Tree with New Files

```bash
living-tree/
├── api/
│   ├── utils/
│   │   ├── auto_draft_processor.py   # NEW: Main auto-draft orchestration
│   │   ├── email_classifier.py       # NEW: Email classification logic
│   │   ├── style_analyzer.py         # NEW: Communication style analysis
│   │   └── background_monitor.py     # NEW: Background email monitoring
│   ├── routes/
│   │   └── auto_drafts.py           # NEW: Auto-draft API endpoints
├── apps/web/
│   └── app/api/auto-drafts/
│       └── settings/
│           └── route.ts             # NEW: Frontend API proxy
```

### Known Gotchas & Library Quirks

```python
# CRITICAL: Poetry environment required - NEVER use pip directly
# FastAPI background tasks run in same event loop - use thread pool for CPU-intensive tasks
# Supabase RLS uses Clerk user IDs as TEXT, not UUID
# Gmail API rate limits: 250 quota units per user per 100 seconds
# OpenAI function calling requires structured outputs with strict: true for reliability
# Pydantic v2 syntax differs from v1 - use Field() for validation
# JWT tokens must be exact base64url format - extra characters cause parsing errors
```

## Implementation Blueprint

### Data Models and Structure

Leverage existing database schema from migration file:

```python
# Based on supabase/migrations/20250111000000_auto_drafts.sql
class AutoDraftSettings(BaseModel):
    user_id: str
    enabled: bool = True
    tone_instructions: str = "professional and friendly"
    reply_delay_minutes: int = 5
    confidence_threshold: float = 0.7

class DraftMetadata(BaseModel):
    user_id: str
    email_id: str
    draft_id: str
    confidence_score: float
    processing_time_seconds: float

class UserCommunicationPattern(BaseModel):
    user_id: str
    pattern_type: str  # "greeting", "closing", "tone", "structure"
    pattern_value: str
    confidence: float
```

### List of Tasks to Complete (In Order)

```yaml
Task 1: Implement Core Auto-Draft Functions
MODIFY api/utils/tools.py:
  - ADD process_auto_draft() function
  - ADD generate_auto_draft() function
  - ADD analyze_user_communication_style() function
  - MIRROR existing draft_email_response pattern
  - PRESERVE async function signatures

Task 2: Create Email Classification System
CREATE api/utils/email_classifier.py:
  - IMPLEMENT classify_email_for_auto_draft() function
  - USE OpenAI for intelligent classification
  - FOLLOW existing tool patterns from tools.py
  - RETURN classification with confidence score

Task 3: Implement Style Analysis System
CREATE api/utils/style_analyzer.py:
  - IMPLEMENT analyze_communication_patterns() function
  - USE Fast Stylometry library for style analysis
  - STORE patterns in user_communication_patterns table
  - RETURN style indicators for draft generation

Task 4: Create Background Processing System
CREATE api/utils/background_monitor.py:
  - IMPLEMENT email monitoring with Gmail API
  - USE FastAPI background tasks for async processing
  - HANDLE rate limiting and error recovery
  - INTEGRATE with existing Gmail helpers

Task 5: Add Auto-Draft API Endpoints
CREATE api/routes/auto_drafts.py:
  - IMPLEMENT GET/POST /api/auto-drafts/settings
  - IMPLEMENT POST /api/auto-drafts/process
  - FOLLOW existing API patterns from index.py
  - USE proper JWT authentication

Task 6: Complete Frontend API Integration
CREATE apps/web/app/api/auto-drafts/settings/route.ts:
  - IMPLEMENT Next.js API route handlers
  - PROXY requests to FastAPI backend
  - HANDLE authentication and errors
  - FOLLOW existing route patterns

Task 7: Integration Testing and Validation
MODIFY existing components:
  - TEST auto-drafts settings flow
  - VALIDATE Gmail draft creation
  - VERIFY background processing works
  - ENSURE proper error handling
```

### Per Task Pseudocode

```python
# Task 1: Core Auto-Draft Functions
async def process_auto_draft(user_id: str, email_data: dict) -> dict:
    # PATTERN: Always validate input first (see existing tools.py)
    validated_email = validate_email_data(email_data)

    # GOTCHA: Check if feature is enabled for user
    settings = await get_user_auto_draft_settings(user_id)
    if not settings.enabled:
        return {"skipped": True, "reason": "feature_disabled"}

    # PATTERN: Use existing classification with confidence threshold
    classification = await classify_email_for_auto_draft(validated_email)
    if classification.confidence < settings.confidence_threshold:
        return {"skipped": True, "reason": "low_confidence"}

    # CRITICAL: Generate draft using existing draft_email_response pattern
    draft_content = await generate_auto_draft(user_id, validated_email, settings)

    # PATTERN: Save to Gmail using existing create_draft function
    gmail_service = await get_gmail_service(user_id)
    draft_id = await create_draft(gmail_service, draft_content)

    # PATTERN: Store metadata for tracking
    await store_draft_metadata(user_id, email_data["id"], draft_id, classification.confidence)

    return {"success": True, "draft_id": draft_id}

# Task 2: Email Classification
async def classify_email_for_auto_draft(email_data: dict) -> ClassificationResult:
    # PATTERN: Use OpenAI function calling like existing tools
    client = AsyncOpenAI(api_key=settings.OPENAI_API_KEY)

    # CRITICAL: Use structured outputs for reliable classification
    completion = await client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {"role": "system", "content": CLASSIFICATION_PROMPT},
            {"role": "user", "content": f"Classify this email: {email_data['content']}"}
        ],
        functions=[{
            "name": "classify_email",
            "parameters": {
                "type": "object",
                "properties": {
                    "needs_reply": {"type": "boolean"},
                    "confidence": {"type": "number", "minimum": 0, "maximum": 1},
                    "reason": {"type": "string"}
                },
                "required": ["needs_reply", "confidence", "reason"]
            }
        }],
        function_call={"name": "classify_email"},
        strict=True
    )

    return parse_classification_result(completion)

# Task 3: Style Analysis
async def analyze_communication_patterns(user_id: str) -> dict:
    # PATTERN: Get user's sent emails using existing Gmail helpers
    gmail_service = await get_gmail_service(user_id)
    sent_emails = await get_sent_emails(gmail_service, limit=50)

    # GOTCHA: Use Fast Stylometry for style analysis
    from faststylometry import calculate_burrows_delta

    # PATTERN: Extract style features
    style_features = extract_style_features(sent_emails)

    # PATTERN: Store in database using existing patterns
    await store_communication_patterns(user_id, style_features)

    return style_features

# Task 4: Background Processing
async def monitor_emails_for_auto_drafts():
    # PATTERN: Use FastAPI background tasks
    while True:
        try:
            # CRITICAL: Get all users with auto-drafts enabled
            enabled_users = await get_enabled_auto_draft_users()

            # PATTERN: Process each user's emails
            for user_id in enabled_users:
                await process_user_new_emails(user_id)

            # GOTCHA: Rate limiting - don't overwhelm Gmail API
            await asyncio.sleep(60)  # Process every minute

        except Exception as e:
            # PATTERN: Log errors but continue processing
            logger.error(f"Auto-draft monitoring error: {e}")
            await asyncio.sleep(300)  # Wait 5 minutes on error
```

### Integration Points

```yaml
DATABASE:
  - tables: auto_draft_settings, draft_metadata, user_communication_patterns
  - indexes: CREATE INDEX idx_auto_draft_user ON auto_draft_settings(user_id)
  - RLS: Policies use Clerk user_id (TEXT format)

GMAIL_API:
  - methods: users.drafts.create, users.messages.list, users.messages.get
  - rate_limits: 250 quota units per user per 100 seconds
  - authentication: OAuth via Clerk backend API

OPENAI_API:
  - model: gpt-4o with function calling
  - features: structured outputs with strict: true
  - rate_limits: 10,000 TPM for tier 1 accounts

FASTAPI:
  - background_tasks: Use for async email processing
  - dependencies: Existing JWT auth and Supabase client patterns
  - routes: Add to main FastAPI app with proper middleware
```

## Validation Loop

### Level 1: Syntax & Style

```bash
# Run these FIRST - fix any errors before proceeding
poetry run black api/utils/auto_draft_processor.py
poetry run flake8 api/utils/auto_draft_processor.py
poetry run mypy api/utils/auto_draft_processor.py

# Expected: No errors. If errors, READ the error and fix.
```

### Level 2: Unit Tests

```python
# EXTEND existing test_auto_drafts.py with these test cases:
def test_process_auto_draft_happy_path():
    """Basic auto-draft processing works"""
    result = await process_auto_draft("user123", mock_email_data)
    assert result["success"] is True
    assert "draft_id" in result

def test_process_auto_draft_feature_disabled():
    """Skips processing when feature disabled"""
    with mock.patch('get_user_auto_draft_settings', return_value=mock_disabled_settings):
        result = await process_auto_draft("user123", mock_email_data)
        assert result["skipped"] is True
        assert result["reason"] == "feature_disabled"

def test_email_classification_accuracy():
    """Email classification returns accurate results"""
    # Test with various email types
    newsletter_result = await classify_email_for_auto_draft(mock_newsletter)
    assert newsletter_result.needs_reply is False

    direct_question_result = await classify_email_for_auto_draft(mock_direct_question)
    assert direct_question_result.needs_reply is True
    assert direct_question_result.confidence > 0.8

def test_style_analysis_extraction():
    """Style analysis extracts meaningful patterns"""
    patterns = await analyze_communication_patterns("user123")
    assert "greeting" in patterns
    assert "closing" in patterns
    assert patterns["tone"]["confidence"] > 0.5
```

```bash
# Run and iterate until passing:
poetry run pytest api/tests/test_auto_drafts.py -v
# If failing: Read error, understand root cause, fix code, re-run
```

### Level 3: Integration Test

```bash
# Start the service
poetry run uvicorn api.index:app --reload --port 8000

# Test auto-draft settings endpoint
curl -X POST http://localhost:8000/api/auto-drafts/settings \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLERK_JWT_TOKEN" \
  -d '{
    "enabled": true,
    "tone_instructions": "professional and friendly",
    "reply_delay_minutes": 5,
    "confidence_threshold": 0.7
  }'

# Expected: {"success": true, "settings": {...}}

# Test auto-draft processing
curl -X POST http://localhost:8000/api/auto-drafts/process \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLERK_JWT_TOKEN" \
  -d '{
    "email_id": "test_email_123",
    "content": "Can you send me the quarterly report?",
    "sender": "boss@company.com",
    "subject": "Q4 Report Request"
  }'

# Expected: {"success": true, "draft_id": "draft_xyz", "confidence": 0.95}
```

## Final Validation Checklist

- [ ] All tests pass: `poetry run pytest api/tests/ -v`
- [ ] No linting errors: `poetry run flake8 api/`
- [ ] No type errors: `poetry run mypy api/`
- [ ] Manual API test successful: Auto-draft creation works end-to-end
- [ ] Frontend integration works: Settings save and load correctly
- [ ] Background processing works: New emails trigger auto-draft generation
- [ ] Gmail integration works: Drafts appear in user's Gmail drafts folder
- [ ] Error cases handled: Invalid emails, API failures, rate limiting
- [ ] Performance acceptable: Draft generation completes within 60 seconds
- [ ] Security verified: User data isolation and JWT validation working

## Anti-Patterns to Avoid

- ❌ Don't use sync functions in async FastAPI context
- ❌ Don't ignore Gmail API rate limits - implement proper backoff
- ❌ Don't store sensitive email content longer than necessary
- ❌ Don't bypass user settings or confidence thresholds
- ❌ Don't use pip instead of poetry for dependency management
- ❌ Don't hardcode AI prompts - make them configurable
- ❌ Don't process emails without proper authentication
- ❌ Don't create drafts for emails that don't need replies
- ❌ Don't ignore error handling in background tasks
- ❌ Don't violate user privacy by logging email content

---

## Implementation Confidence Score: 9/10

**High confidence for one-pass implementation due to:**

- Extensive existing infrastructure (70% already implemented)
- Clear database schema and API patterns already established
- Comprehensive test coverage expectations defined
- Well-documented external APIs (Gmail, OpenAI)
- Proven patterns from existing tools in the codebase
- Detailed error handling and edge case considerations

**Minor risk factors:**

- Background processing coordination complexity
- Gmail API rate limiting edge cases
- Style analysis accuracy tuning may require iteration
