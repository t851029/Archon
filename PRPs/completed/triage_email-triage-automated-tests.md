# Email Triage Automated Testing Implementation

## Goal

Create comprehensive automated test coverage for the email triage system to ensure reliability, maintainability, and prevent regressions. Implement the missing test infrastructure that was specified in the original PRP but not completed during implementation.

## Why

- **Quality Assurance**: Automated tests ensure the triage system functions correctly across different scenarios
- **Regression Prevention**: Tests catch breaking changes during future development
- **Documentation**: Tests serve as living documentation of expected behavior
- **CI/CD Integration**: Enables automated validation in deployment pipeline
- **PRP Compliance**: Fulfills the testing requirements specified in the original agentic-inbox-triage.md PRP

## What

Implement comprehensive automated test coverage including:

1. **Unit Tests**: Test individual triage tools with mocked dependencies
2. **Integration Tests**: Test API endpoints and database interactions
3. **Component Tests**: Test React components for triage result display
4. **Error Handling Tests**: Verify graceful failure scenarios
5. **Performance Tests**: Validate batch processing performance

## All Needed Context

### Documentation & References

```yaml
# MUST READ - Include these in your context window
- url: https://docs.pytest.org/en/stable/how.html
  why: Testing framework patterns and best practices

- url: https://playwright.dev/docs/test-components
  why: Component testing patterns for React components

- url: https://fastapi.tiangolo.com/tutorial/testing/
  why: FastAPI testing patterns with TestClient

- file: /Users/jron/mac_code_projects/lt_multiagent/PRPs/agentic-inbox-triage.md
  why: Original PRP with specific test requirements (lines 388-440)

- file: /Users/jron/mac_code_projects/lt_multiagent/api/utils/tools.py
  why: Triage tool implementations to test

- file: /Users/jron/mac_code_projects/lt_multiagent/api/utils/email_schemas.py
  why: Pydantic models for test data structures

- file: /Users/jron/mac_code_projects/lt_multiagent/api/index.py
  why: FastAPI app setup and tool registration patterns

- file: /Users/jron/mac_code_projects/lt_multiagent/apps/web/components/triage-result.tsx
  why: React component to test

- file: /Users/jron/mac_code_projects/lt_multiagent/apps/web/components/priority-badge.tsx
  why: Component testing patterns

- file: /Users/jron/mac_code_projects/lt_multiagent/.cursor/rules/500-testing-security.mdc
  why: Project testing standards and patterns
```

### Current Test Infrastructure

```bash
# Testing frameworks configured in project
Backend: pytest 8.3.0 + pytest-asyncio 0.25.0
Frontend: Playwright 1.53.1
Validation: mypy, black, flake8, ruff
Build: Turbo with test task configuration

# Test commands available
poetry run pytest api/tests/ -v        # Backend tests
pnpm test                              # Frontend tests via Turbo
poetry run mypy api/                   # Type checking
poetry run ruff check api/             # Linting
```

### Known Gotchas & Library Quirks

```python
# CRITICAL: FastAPI dependency injection in tests
# Use TestClient and dependency overrides for mocking

# CRITICAL: Async test functions must use @pytest.mark.asyncio
# All triage tools are async functions with Depends() injection

# CRITICAL: Mock external services completely
# Gmail API, OpenAI API, Supabase client all need mocking

# CRITICAL: Clerk user IDs are TEXT type, not UUID
# Use string user IDs in test data: "user_test_123"

# CRITICAL: Database tests need RLS policy consideration
# Mock or use service role key for database operations

# CRITICAL: OpenAI API responses need proper JSON structure
# Match exact EmailTriageResult schema in mock responses

# CRITICAL: Gmail API rate limiting in tests
# Use mock data to avoid actual API calls during testing
```

## Implementation Blueprint

### Test Directory Structure

```bash
# Files to CREATE:
api/tests/
├── conftest.py                      # Test configuration and fixtures
├── test_triage_tools.py            # Unit tests for triage functions
├── test_email_schemas.py           # Pydantic model validation tests
├── test_triage_integration.py      # Integration tests for API endpoints
└── fixtures/
    ├── email_data.py               # Sample email data for testing
    └── mock_responses.py           # Mock API response data

apps/web/tests/
├── components/
│   ├── triage-result.test.tsx      # Component tests
│   └── priority-badge.test.tsx     # Badge component tests
└── fixtures/
    └── triage-test-data.ts         # Frontend test data
```

### Data Models and Test Structure

```python
# Test fixtures for api/tests/conftest.py
@pytest.fixture
def sample_email_data():
    return {
        "id": "test_email_123",
        "sender": "court@example.com",
        "subject": "URGENT: Court Hearing Notice",
        "body": "Your hearing is scheduled for tomorrow at 9 AM.",
        "date": "2024-01-01T10:00:00Z"
    }

@pytest.fixture
def sample_triage_result():
    return {
        "email_id": "test_email_123",
        "priority_level": "Critical",
        "sender_classification": "Court",
        "urgency_score": 0.9,
        "sentiment_score": 0.1,
        "summary_tag": "[Court Notice]",
        "case_associations": ["Case-2024-001"],
        "keywords": ["hearing", "court", "urgent"],
        "deadlines_detected": ["2024-01-02T09:00:00Z"],
        "confidence_score": 0.95,
        "created_at": "2024-01-01T10:00:00Z"
    }
```

### List of Tasks (Complete in Order)

```yaml
Task 1 - Create Test Infrastructure:
CREATE api/tests/conftest.py:
  - ADD pytest fixtures for FastAPI TestClient
  - ADD mock dependency overrides for gmail_service, openai_client, supabase_client
  - ADD sample data fixtures for emails and triage results
  - ADD authentication mocking with Clerk user IDs

Task 2 - Implement Unit Tests:
CREATE api/tests/test_triage_tools.py:
  - ADD test_triage_emails_single() - single email analysis
  - ADD test_triage_emails_batch() - batch processing
  - ADD test_classify_email_priority() - priority classification
  - ADD test_detect_legal_deadlines() - deadline detection
  - ADD test_validation_errors() - input validation
  - ADD test_error_handling() - external API failures

Task 3 - Add Schema Validation Tests:
CREATE api/tests/test_email_schemas.py:
  - ADD test_triage_email_params_validation() - input validation
  - ADD test_email_triage_result_validation() - output validation
  - ADD test_batch_triage_result_validation() - batch results
  - ADD test_invalid_data_handling() - malformed data

Task 4 - Create Integration Tests:
CREATE api/tests/test_triage_integration.py:
  - ADD test_chat_endpoint_with_triage() - full chat integration
  - ADD test_database_persistence() - Supabase storage
  - ADD test_tool_registration() - tool availability
  - ADD test_authentication_required() - JWT validation

Task 5 - Add Performance Tests:
CREATE api/tests/test_triage_performance.py:
  - ADD test_batch_processing_performance() - large email batches
  - ADD test_rate_limiting_compliance() - OpenAI/Gmail limits
  - ADD test_memory_usage() - resource consumption
  - ADD test_concurrent_requests() - multiple users

Task 6 - Create Frontend Component Tests:
CREATE apps/web/tests/components/triage-result.test.tsx:
  - ADD test renders single triage result
  - ADD test renders batch triage results
  - ADD test priority badge colors
  - ADD test confidence score display
  - ADD test legal keywords display
  - ADD test deadline alerts

Task 7 - Add Frontend Component Tests:
CREATE apps/web/tests/components/priority-badge.test.tsx:
  - ADD test priority color coding
  - ADD test badge variants (default, outline, solid)
  - ADD test urgency bar display
  - ADD test confidence indicators

Task 8 - Create Test Data Fixtures:
CREATE api/tests/fixtures/email_data.py:
  - ADD sample emails for different scenarios
  - ADD court emails, client emails, vendor emails
  - ADD emails with deadlines, urgent emails
  - ADD malformed email data for error testing

Task 9 - Add Mock Response Fixtures:
CREATE api/tests/fixtures/mock_responses.py:
  - ADD OpenAI API mock responses
  - ADD Gmail API mock responses
  - ADD Supabase mock responses
  - ADD error response scenarios

Task 10 - Configure Test Environment:
CREATE pytest.ini:
  - ADD async test configuration
  - ADD test discovery patterns
  - ADD coverage reporting
  - ADD environment variable handling
```

### Per Task Implementation Details

```python
# Task 2 - Core Unit Tests Implementation
# api/tests/test_triage_tools.py
import pytest
from unittest.mock import AsyncMock, patch
from fastapi.testclient import TestClient
from api.utils.tools import triage_emails, classify_email_priority
from api.utils.email_schemas import TriageEmailParams

@pytest.mark.asyncio
async def test_triage_emails_single(mock_gmail_service, mock_openai_client, sample_email_data, sample_triage_result):
    """Test single email triage analysis"""
    params = TriageEmailParams(email_id="test_email_123")

    # Configure mocks
    mock_gmail_service.get_message.return_value = sample_email_data
    mock_openai_client.chat.completions.create.return_value.choices[0].message.content = json.dumps(sample_triage_result)

    # Execute test
    result = await triage_emails(params, mock_gmail_service, mock_openai_client, "user_test_123")

    # Assertions
    assert len(result) == 1
    assert result[0].priority_level == "Critical"
    assert result[0].sender_classification == "Court"
    assert result[0].urgency_score == 0.9
    assert result[0].confidence_score == 0.95

@pytest.mark.asyncio
async def test_triage_emails_batch(mock_gmail_service, mock_openai_client):
    """Test batch email processing"""
    params = TriageEmailParams(max_emails=10, since_hours=24)

    # Configure batch mock data
    mock_gmail_service.list_messages.return_value = [
        {"id": f"email_{i}", "sender": f"test{i}@example.com", "subject": f"Test {i}", "body": f"Body {i}"}
        for i in range(10)
    ]

    # Execute and verify batch processing
    result = await triage_emails(params, mock_gmail_service, mock_openai_client, "user_test_123")

    assert len(result) == 10
    assert all(r.email_id.startswith("email_") for r in result)

@pytest.mark.asyncio
async def test_validation_errors():
    """Test input validation handling"""
    params = TriageEmailParams(email_id="")  # Invalid empty ID

    with pytest.raises(ValidationError):
        await triage_emails(params, None, None, "user_test_123")

@pytest.mark.asyncio
async def test_gmail_service_error_handling(mock_gmail_service, mock_openai_client):
    """Test Gmail API error handling"""
    params = TriageEmailParams(email_id="test_email_123")

    # Configure mock to raise exception
    mock_gmail_service.get_message.side_effect = Exception("Gmail API error")

    with pytest.raises(HTTPException) as exc_info:
        await triage_emails(params, mock_gmail_service, mock_openai_client, "user_test_123")

    assert exc_info.value.status_code == 500
    assert "Gmail API error" in str(exc_info.value.detail)

# Task 4 - Integration Tests
# api/tests/test_triage_integration.py
def test_chat_endpoint_with_triage(client, auth_headers):
    """Test chat endpoint executes triage tools"""
    response = client.post(
        "/chat",
        headers=auth_headers,
        json={
            "messages": [
                {"role": "user", "content": "Analyze my urgent emails"}
            ]
        }
    )

    assert response.status_code == 200
    response_data = response.json()

    # Verify triage tool was called
    assert "triage_emails" in response_data.get("tool_calls", [])

def test_database_persistence(client, auth_headers, mock_supabase_client):
    """Test triage results are stored in database"""
    # Execute triage through API
    response = client.post(
        "/chat",
        headers=auth_headers,
        json={
            "messages": [
                {"role": "user", "content": "Classify email test_email_123"}
            ]
        }
    )

    # Verify database insert was called
    mock_supabase_client.table.assert_called_with("email_triage_results")
    mock_supabase_client.table().insert.assert_called_once()

# Task 6 - Frontend Component Tests
# apps/web/tests/components/triage-result.test.tsx
import { render, screen } from '@testing-library/react';
import { TriageResult } from '@/components/triage-result';

describe('TriageResult Component', () => {
  const mockSingleResult = {
    email_id: "test_email_123",
    priority_level: "Critical",
    sender_classification: "Court",
    urgency_score: 0.9,
    confidence_score: 0.95,
    summary_tag: "[Court Notice]",
    keywords: ["hearing", "court", "urgent"],
    deadlines_detected: ["2024-01-02T09:00:00Z"],
    case_associations: ["Case-2024-001"]
  };

  test('renders single triage result correctly', () => {
    render(<TriageResult result={mockSingleResult} type="single" />);

    expect(screen.getByText('Critical')).toBeInTheDocument();
    expect(screen.getByText('Court')).toBeInTheDocument();
    expect(screen.getByText('[Court Notice]')).toBeInTheDocument();
    expect(screen.getByText('95%')).toBeInTheDocument(); // Confidence score
  });

  test('displays priority badge with correct color', () => {
    render(<TriageResult result={mockSingleResult} type="single" />);

    const priorityBadge = screen.getByText('Critical');
    expect(priorityBadge).toHaveClass('bg-red-500'); // Critical = red
  });

  test('shows legal keywords', () => {
    render(<TriageResult result={mockSingleResult} type="single" />);

    expect(screen.getByText('hearing')).toBeInTheDocument();
    expect(screen.getByText('court')).toBeInTheDocument();
    expect(screen.getByText('urgent')).toBeInTheDocument();
  });

  test('displays deadline alerts', () => {
    render(<TriageResult result={mockSingleResult} type="single" />);

    expect(screen.getByText('Jan 2, 2024')).toBeInTheDocument();
  });
});
```

### Integration Points

```yaml
DATABASE:
  - test data: Use sample user_id and email_id values
  - isolation: Test RLS policies with different user contexts

API:
  - endpoints: Test /chat endpoint with triage tool execution
  - authentication: Mock Clerk JWT tokens for testing

FRONTEND:
  - components: Test TriageResult and PriorityBadge rendering
  - styling: Verify priority color coding and responsive design
```

## Validation Loop

### Level 1: Test Infrastructure

```bash
# Verify test setup works
cd /Users/jron/mac_code_projects/lt_multiagent

# Create test directories
mkdir -p api/tests api/tests/fixtures
mkdir -p apps/web/tests apps/web/tests/components apps/web/tests/fixtures

# Install test dependencies (should already be installed)
poetry install
cd apps/web && pnpm install
```

### Level 2: Unit Test Validation

```bash
# Run unit tests
poetry run pytest api/tests/test_triage_tools.py -v
poetry run pytest api/tests/test_email_schemas.py -v

# Expected: All tests pass with proper mocking
# Expected: No actual API calls made during testing
```

### Level 3: Integration Test Validation

```bash
# Run integration tests
poetry run pytest api/tests/test_triage_integration.py -v
poetry run pytest api/tests/test_triage_performance.py -v

# Expected: FastAPI test client works correctly
# Expected: Database operations are properly mocked
```

### Level 4: Frontend Component Tests

```bash
# Run frontend component tests
cd apps/web
pnpm test tests/components/triage-result.test.tsx
pnpm test tests/components/priority-badge.test.tsx

# Expected: Component rendering tests pass
# Expected: Priority colors and styling correct
```

### Level 5: Full Test Suite

```bash
# Run all tests
poetry run pytest api/tests/ -v --coverage
cd apps/web && pnpm test

# Expected: All tests pass
# Expected: Good test coverage (>80%)
# Expected: No actual external API calls
```

## Final Validation Checklist

- [ ] All unit tests pass: `poetry run pytest api/tests/test_triage_tools.py -v`
- [ ] Schema validation tests pass: `poetry run pytest api/tests/test_email_schemas.py -v`
- [ ] Integration tests pass: `poetry run pytest api/tests/test_triage_integration.py -v`
- [ ] Performance tests pass: `poetry run pytest api/tests/test_triage_performance.py -v`
- [ ] Frontend component tests pass: `pnpm test tests/components/`
- [ ] No linting errors: `poetry run ruff check api/`
- [ ] No type errors: `poetry run mypy api/`
- [ ] Test coverage >80%: `poetry run pytest api/tests/ --cov=api --cov-report=html`
- [ ] All tests use mocked dependencies (no actual API calls)
- [ ] Error handling tests cover all failure scenarios
- [ ] Database persistence tests verify RLS policies
- [ ] Performance tests validate batch processing limits

---

## Anti-Patterns to Avoid

- ❌ Don't make actual API calls in tests - mock all external services
- ❌ Don't use real database in tests - use test database or mocks
- ❌ Don't skip error handling tests - test all failure scenarios
- ❌ Don't ignore async/await patterns - use @pytest.mark.asyncio
- ❌ Don't hardcode test data - use fixtures for reusability
- ❌ Don't test implementation details - test behavior and outputs
- ❌ Don't create brittle tests - make them maintainable and readable
- ❌ Don't ignore CI/CD integration - tests should run in automated pipeline

**Confidence Score: 9/10** - This PRP provides comprehensive test coverage for all triage system components, follows established testing patterns, includes proper mocking strategies, and addresses all validation requirements from the original PRP.
