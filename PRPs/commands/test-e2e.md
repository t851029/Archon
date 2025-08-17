# End-to-End Testing for Living Tree

Run comprehensive end-to-end tests using Playwright MCP and built-in testing tools.

## Purpose

Validate complete user flows and integrations across the Living Tree platform, ensuring all components work together correctly.

## Quick E2E Test

```bash
# Start all services first
pnpm dev:full

# Wait for services to be ready
sleep 5

# Run quick smoke test
curl http://localhost:3000 && echo "✓ Frontend running"
curl http://localhost:8000/health && echo "✓ Backend running"
npx supabase status && echo "✓ Database running"
```

## 1. Playwright MCP Setup

### Initialize Playwright Session

```playwright
# Start code generation session to record actions
playwright_start_codegen_session --outputPath ./tests/e2e

# Or navigate directly for manual testing
playwright_navigate --url http://localhost:3000
```

### Core User Flows to Test

1. **Authentication Flow**

   ```playwright
   # Test login
   playwright_navigate --url http://localhost:3000
   playwright_click --selector "button:has-text('Sign In')"
   # Complete Clerk auth flow
   playwright_screenshot --name "logged-in-state"
   ```

2. **Email Triage Flow**

   ```playwright
   # Navigate to triage
   playwright_navigate --url http://localhost:3000/triage
   playwright_screenshot --name "triage-dashboard"

   # Run triage analysis
   playwright_click --selector "button:has-text('Run Triage Analysis')"

   # Wait for results
   playwright_expect_response --id "triage-response" --url "**/api/triage/**"
   playwright_assert_response --id "triage-response"
   ```

3. **Chat Interface Flow**

   ```playwright
   # Test chat
   playwright_navigate --url http://localhost:3000/chat
   playwright_fill --selector "textarea[placeholder*='Type your message']" --value "Hello, can you help me?"
   playwright_press_key --key "Enter"

   # Wait for AI response
   playwright_expect_response --id "chat-response" --url "**/api/chat"
   playwright_assert_response --id "chat-response"
   ```

4. **Settings & Preferences**
   ```playwright
   # Test settings
   playwright_navigate --url http://localhost:3000/settings
   playwright_click --selector "button:has-text('Auto-Draft')"
   playwright_screenshot --name "settings-page"
   ```

## 2. API Integration Tests

### Test Backend Endpoints

```bash
# Health check
curl -X GET http://localhost:8000/health

# Test protected endpoint (need valid JWT)
JWT_TOKEN=$(cd apps/web && node -e "
const jwt = require('jsonwebtoken');
// This is a test token - replace with actual token retrieval
console.log('test-jwt-token');
")

# Test chat endpoint
curl -X POST http://localhost:8000/api/chat \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"messages": [{"role": "user", "content": "test"}]}'

# Test triage endpoint
curl -X POST http://localhost:8000/api/gmail/triage \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"email_ids": ["test-id"], "account_email": "test@example.com"}'
```

### Test Database Operations

```sql
-- Using Supabase MCP or Postgres MCP
-- Test user creation
INSERT INTO users (id, email) VALUES ('test-user-id', 'test@example.com');

-- Test triage results
SELECT * FROM email_triage_results WHERE user_id = 'test-user-id';

-- Test auto drafts
SELECT * FROM auto_drafts WHERE user_id = 'test-user-id';

-- Cleanup
DELETE FROM users WHERE id = 'test-user-id';
```

## 3. Living Tree E2E Test Suite

### Run Built-in Tests

```bash
# Frontend component tests
pnpm test

# Frontend E2E tests (if configured)
pnpm test:e2e

# Backend integration tests
cd api
poetry run pytest -v -k "integration"

# Specific Living Tree tests
poetry run pytest api/tests/test_triage_integration.py -v
poetry run pytest api/tests/test_auto_drafts.py -v
```

### Manual E2E Test Checklist

1. **User Onboarding**
   - [ ] Can create account via Clerk
   - [ ] Gmail OAuth connection works
   - [ ] Initial dashboard loads

2. **Email Triage**
   - [ ] Email list populates
   - [ ] Triage analysis runs
   - [ ] Results save to database
   - [ ] UI updates with results
   - [ ] Pagination works

3. **Auto-Drafts**
   - [ ] Toggle persists across sessions
   - [ ] Drafts generate correctly
   - [ ] Can edit draft content
   - [ ] Save to Gmail works

4. **Chat Interface**
   - [ ] Messages send/receive
   - [ ] Streaming responses work
   - [ ] Tool calls execute
   - [ ] Chat history persists

5. **Performance**
   - [ ] Page loads < 3s
   - [ ] API responses < 2s
   - [ ] No memory leaks
   - [ ] Smooth scrolling

## 4. Cross-Environment Testing

### Test Staging Environment

```bash
# Use Playwright MCP for staging
playwright_navigate --url https://staging.livingtree.io

# Run same test flows as local
# Note: Use staging-appropriate test accounts
```

### Environment-Specific Tests

```javascript
// Test CORS configuration
const testCORS = async (frontendUrl, backendUrl) => {
  const response = await fetch(`${backendUrl}/api/health`, {
    headers: {
      Origin: frontendUrl,
    },
  });
  console.log("CORS test:", response.ok ? "✓ Pass" : "✗ Fail");
};

// Test each environment
testCORS("http://localhost:3000", "http://localhost:8000");
testCORS(
  "https://staging.livingtree.io",
  "https://living-tree-backend-staging-eprzpin6uq-nn.a.run.app",
);
```

## 5. Performance Testing

### Load Testing with Playwright

```playwright
# Simulate multiple users
for i in {1..10}; do
  playwright_navigate --url http://localhost:3000 --headless true &
done

# Monitor performance
playwright_evaluate --script "
  const perfData = performance.getEntriesByType('navigation')[0];
  console.log('Page load time:', perfData.loadEventEnd - perfData.loadEventStart, 'ms');
"
```

### API Performance Testing

```bash
# Simple load test
for i in {1..100}; do
  curl -s -o /dev/null -w "%{http_code} %{time_total}s\n" http://localhost:8000/health &
done | sort | uniq -c
```

## 6. Debugging E2E Failures

### Capture Debug Information

```playwright
# Take screenshots on failure
playwright_screenshot --name "error-state" --fullPage true

# Get console logs
playwright_console_logs --type "error"

# Get network logs
playwright_evaluate --script "
  const failed = performance.getEntriesByType('resource').filter(r => r.responseStatus >= 400);
  console.log('Failed requests:', failed);
"
```

### Check Application Logs

```bash
# Frontend logs
tail -f apps/web/.next/server/logs/*.log

# Backend logs
tail -f api/backend.log

# Database logs
npx supabase logs
```

## 7. E2E Test Report

Generate test report:

```markdown
# Living Tree E2E Test Report

Date: $(date)
Environment: [Local/Staging/Production]

## Test Results

### Authentication ✓/✗

- Sign up flow:
- Sign in flow:
- OAuth connection:

### Email Triage ✓/✗

- Email loading:
- Triage analysis:
- Results display:

### Auto-Drafts ✓/✗

- Toggle persistence:
- Draft generation:
- Gmail integration:

### Chat Interface ✓/✗

- Message sending:
- AI responses:
- Tool execution:

### Performance Metrics

- Frontend load: \_ms
- API response: \_ms
- Database queries: \_ms

## Issues Found

1. [Issue description with screenshot]

## Recommendations

1. [Suggested fixes]
```

## MCP Tools for E2E Testing

Leverage these MCP tools:

- **Playwright**: Automated browser testing
- **Supabase**: Direct database validation
- **Sequential Thinking**: Debug complex test failures
- **Tavily**: Research testing best practices

Remember: E2E tests validate the entire Living Tree user experience - run before any deployment!
