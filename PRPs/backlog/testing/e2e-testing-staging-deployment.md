# PRP: E2E Testing for Staging Deployment Validation

## Problem Statement

Staging deployments frequently break due to environment configuration issues, authentication mismatches, and undetected integration failures. We need comprehensive E2E tests that validate critical user flows (chat and email triage) and catch deployment issues before they reach staging.

## Current State

```yaml
current_state:
  testing_infrastructure:
    - Playwright configured but minimal E2E tests
    - Component tests exist for triage features
    - No chat interface tests
    - No staging validation tests
    - No CI/CD test automation

  deployment_failures:
    - JWT format errors causing container crashes
    - Clerk instance mismatches (TEST vs LIVE keys)
    - Missing environment variables
    - CORS configuration issues
    - Email triage tool execution failures

  existing_patterns:
    - Mock HTML page creation for component tests
    - Test data fixtures in api/tests/fixtures/
    - Playwright config at apps/web/playwright.config.ts
```

## Desired State

```yaml
desired_state:
  comprehensive_e2e_suite:
    - Pre-deployment validation tests
    - Critical user flow coverage (auth, chat, triage)
    - Staging environment tests
    - Post-deployment smoke tests

  ci_cd_integration:
    - E2E tests run before deployment
    - Staging validation after deployment
    - Automated failure notifications
    - Test result reporting

  deployment_confidence:
    - 95%+ deployment success rate
    - Early detection of configuration issues
    - Reduced debugging time
```

## Implementation Blueprint

### Phase 1: Core E2E Test Infrastructure

```typescript
// apps/web/tests/e2e/helpers/test-config.ts
export const TEST_CONFIG = {
  staging: {
    baseURL: "https://staging.livingtree.io",
    apiURL: "https://living-tree-backend-staging-eprzpin6uq-nn.a.run.app",
  },
  local: {
    baseURL: "http://localhost:3000",
    apiURL: "http://localhost:8000",
  },
  timeouts: {
    navigation: 30000,
    api: 15000,
    streaming: 60000,
  },
};

// apps/web/tests/e2e/helpers/auth.helper.ts
export class AuthHelper {
  async loginWithClerk(page: Page, email: string, password: string) {
    // Implementation following existing patterns
  }

  async validateJWT(token: string): boolean {
    // Verify JWT format: starts with eyJ, has 3 parts
  }
}
```

### Phase 2: Pre-deployment Validation Tests

```typescript
// apps/web/tests/e2e/pre-deployment/env-validation.test.ts
test.describe("Environment Configuration Validation", () => {
  test("all required environment variables are set", async () => {
    const requiredVars = [
      "NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY",
      "NEXT_PUBLIC_SUPABASE_URL",
      "NEXT_PUBLIC_SUPABASE_ANON_KEY",
      "NEXT_PUBLIC_API_BASE_URL",
      "NEXT_PUBLIC_ENVIRONMENT",
    ];

    for (const envVar of requiredVars) {
      expect(process.env[envVar]).toBeDefined();
    }
  });

  test("JWT tokens have valid format", async () => {
    const jwtRegex = /^eyJ[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+\.[A-Za-z0-9_-]+$/;

    expect(process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY).toMatch(jwtRegex);
    // Server-side validation would check SUPABASE_SERVICE_ROLE_KEY
  });

  test("Clerk keys match instance type", async () => {
    const pubKey = process.env.NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY;
    const env = process.env.NEXT_PUBLIC_ENVIRONMENT;

    if (env === "staging") {
      expect(pubKey).toMatch(/^pk_test_/);
    } else if (env === "production") {
      expect(pubKey).toMatch(/^pk_live_/);
    }
  });
});
```

### Phase 3: Critical User Flow Tests

```typescript
// apps/web/tests/e2e/flows/chat.test.ts
test.describe("Chat Interface E2E", () => {
  test.beforeEach(async ({ page }) => {
    await page.goto("/chat");
    await authHelper.loginWithClerk(page, "test@example.com", "password");
  });

  test("send message and receive streaming response", async ({ page }) => {
    // Type message
    const input = page.getByTestId("chat-input");
    await input.fill("Hello, can you help me with my emails?");

    // Send message
    await page.getByTestId("send-button").click();

    // Verify message appears
    await expect(
      page.getByText("Hello, can you help me with my emails?"),
    ).toBeVisible();

    // Wait for streaming response
    const response = page.getByTestId("assistant-message").last();
    await expect(response).toBeVisible({ timeout: 30000 });

    // Verify streaming animation
    await expect(response).toHaveClass(/streaming/, { timeout: 5000 });

    // Wait for completion
    await expect(response).not.toHaveClass(/streaming/, { timeout: 30000 });
  });

  test("execute email triage tool", async ({ page }) => {
    await page
      .getByTestId("chat-input")
      .fill("Please analyze my recent emails");
    await page.getByTestId("send-button").click();

    // Wait for tool execution indicator
    await expect(page.getByText("Analyzing emails...")).toBeVisible();

    // Verify tool results display
    await expect(page.getByTestId("tool-result")).toBeVisible({
      timeout: 45000,
    });
  });
});

// apps/web/tests/e2e/flows/email-triage.test.ts
test.describe("Email Triage Dashboard E2E", () => {
  test("complete triage workflow", async ({ page }) => {
    await page.goto("/triage");
    await authHelper.loginWithClerk(page, "test@example.com", "password");

    // Verify Gmail connection
    await expect(page.getByTestId("gmail-connected")).toBeVisible();

    // Trigger triage analysis
    const triggerBtn = page.getByTestId("triage-trigger");
    await triggerBtn.click();

    // Wait for loading state
    await expect(triggerBtn).toHaveText("Analyzing...");
    await expect(triggerBtn).toBeDisabled();

    // Wait for results
    await expect(page.getByTestId("triage-results")).toBeVisible({
      timeout: 60000,
    });

    // Verify results stored
    const stats = page.getByTestId("triage-stats");
    await expect(stats).toContainText("Critical:");
    await expect(stats).toContainText("High:");
  });

  test("filter by priority", async ({ page }) => {
    await page.goto("/triage");
    await authHelper.loginWithClerk(page, "test@example.com", "password");

    // Select critical priority
    await page.getByTestId("priority-filter").selectOption("critical");

    // Verify filtered results
    const emails = page.getByTestId("email-item");
    await expect(emails).toHaveCount(await emails.count());

    for (const email of await emails.all()) {
      await expect(email.getByTestId("priority-badge")).toHaveText("Critical");
    }
  });
});
```

### Phase 4: Staging-Specific Tests

```typescript
// apps/web/tests/e2e/staging/api-integration.test.ts
test.describe("Staging API Integration", { tag: "@staging" }, () => {
  test.use({
    baseURL: TEST_CONFIG.staging.baseURL,
  });

  test("API health check", async ({ request }) => {
    const response = await request.get(`${TEST_CONFIG.staging.apiURL}/health`);
    expect(response.ok()).toBeTruthy();
    expect(await response.json()).toEqual({ status: "healthy" });
  });

  test("CORS configuration allows staging origin", async ({ request }) => {
    const response = await request.options(
      `${TEST_CONFIG.staging.apiURL}/api/chat`,
      {
        headers: {
          Origin: TEST_CONFIG.staging.baseURL,
          "Access-Control-Request-Method": "POST",
        },
      },
    );

    expect(response.headers()["access-control-allow-origin"]).toBe(
      TEST_CONFIG.staging.baseURL,
    );
  });

  test("authenticated API call succeeds", async ({ page, request }) => {
    // Login first
    await page.goto("/");
    await authHelper.loginWithClerk(page, "test@example.com", "password");

    // Get auth token
    const token = await page.evaluate(() => {
      return window.localStorage.getItem("clerk-auth-token");
    });

    // Make API call
    const response = await request.get(
      `${TEST_CONFIG.staging.apiURL}/api/user`,
      {
        headers: {
          Authorization: `Bearer ${token}`,
        },
      },
    );

    expect(response.ok()).toBeTruthy();
  });
});

// apps/web/tests/e2e/staging/database.test.ts
test.describe("Staging Database Integration", { tag: "@staging" }, () => {
  test("email triage results persist to database", async ({ page }) => {
    await page.goto("/triage");
    await authHelper.loginWithClerk(page, "test@example.com", "password");

    // Run triage
    await page.getByTestId("triage-trigger").click();
    await page.waitForSelector('[data-testid="triage-results"]', {
      timeout: 60000,
    });

    // Verify via API that results were stored
    const response = await page.request.get("/api/triage/latest");
    const data = await response.json();

    expect(data.results).toBeDefined();
    expect(data.results.length).toBeGreaterThan(0);
  });
});
```

### Phase 5: CI/CD Integration

```yaml
# .github/workflows/e2e-tests.yml
name: E2E Tests

on:
  pull_request:
    branches: [main, staging]
  push:
    branches: [staging]

jobs:
  e2e-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install pnpm
        uses: pnpm/action-setup@v2
        with:
          version: 10.12.1

      - name: Install dependencies
        run: pnpm install

      - name: Install Playwright browsers
        run: pnpm exec playwright install --with-deps

      - name: Run E2E tests
        run: pnpm test:e2e
        env:
          ENVIRONMENT: staging

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: playwright-report
          path: playwright-report/

# .github/workflows/staging-validation.yml
name: Staging Validation

on:
  workflow_run:
    workflows: ["Deploy to Staging"]
    types: [completed]

jobs:
  validate-staging:
    if: ${{ github.event.workflow_run.conclusion == 'success' }}
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Run staging tests
        run: |
          pnpm install
          pnpm exec playwright install --with-deps
          pnpm test:e2e:staging
```

### Phase 6: Page Object Model Implementation

```typescript
// apps/web/tests/e2e/pages/ChatPage.ts
export class ChatPage {
  constructor(private page: Page) {}

  async goto() {
    await this.page.goto("/chat");
  }

  async sendMessage(message: string) {
    await this.page.getByTestId("chat-input").fill(message);
    await this.page.getByTestId("send-button").click();
  }

  async waitForResponse() {
    const response = this.page.getByTestId("assistant-message").last();
    await response.waitFor({ state: "visible", timeout: 30000 });
    await this.page.waitForFunction(
      (el) => !el?.classList.contains("streaming"),
      await response.elementHandle(),
      { timeout: 30000 },
    );
    return response;
  }
}

// apps/web/tests/e2e/pages/TriagePage.ts
export class TriagePage {
  constructor(private page: Page) {}

  async goto() {
    await this.page.goto("/triage");
  }

  async runTriageAnalysis() {
    const triggerBtn = this.page.getByTestId("triage-trigger");
    await triggerBtn.click();
    await this.page.waitForSelector('[data-testid="triage-results"]', {
      timeout: 60000,
    });
  }

  async filterByPriority(priority: "critical" | "high" | "normal" | "low") {
    await this.page.getByTestId("priority-filter").selectOption(priority);
  }

  async getEmailCount() {
    return await this.page.getByTestId("email-item").count();
  }
}
```

## Implementation Tasks

1. **Setup E2E test infrastructure**
   - Create e2e directory structure under apps/web/tests/e2e/
   - Add test configuration and helper files
   - Update playwright.config.ts for staging tests
   - Add data-testid attributes to React components

2. **Implement pre-deployment validation tests**
   - Environment variable validation suite
   - JWT token format validation
   - Clerk instance type matching
   - Build-time checks integration

3. **Create critical user flow tests**
   - Authentication flow with Clerk
   - Chat interface interaction tests
   - Email triage dashboard tests
   - Gmail integration validation

4. **Add staging-specific tests**
   - API endpoint validation
   - CORS configuration tests
   - Database persistence verification
   - Performance benchmarks

5. **Integrate with CI/CD**
   - Create GitHub Actions workflows
   - Add pre-deployment test gates
   - Implement post-deployment validation
   - Configure test reporting

6. **Implement Page Object Model**
   - Create page classes for maintainability
   - Add reusable test helpers
   - Implement mock data factories

7. **Add monitoring and reporting**
   - Test result dashboards
   - Failure notifications
   - Performance tracking
   - Flaky test detection

## Validation Gates

```bash
# Syntax and style checks
cd apps/web && pnpm lint
cd apps/web && pnpm type-check

# Run existing tests
cd apps/web && pnpm test

# Run E2E tests locally
cd apps/web && pnpm test:e2e

# Run staging-specific tests
cd apps/web && ENVIRONMENT=staging pnpm test:e2e:staging

# Validate deployment readiness
./scripts/validate-deployment-env.sh staging

# Post-deployment validation
curl https://staging.livingtree.io/api/health
```

## External References

1. **Playwright Best Practices**: https://playwright.dev/docs/best-practices
   - Use data-testid for stable selectors
   - Leverage auto-waiting features
   - Implement proper error handling

2. **Next.js Testing Guide**: https://nextjs.org/docs/app/guides/testing/playwright
   - Server component testing patterns
   - App Router considerations
   - Environment setup

3. **GitHub Actions for Playwright**: https://playwright.dev/docs/ci-intro
   - Caching browser binaries
   - Parallel test execution
   - Artifact uploading

4. **Existing Patterns**:
   - Component tests: `apps/web/tests/components/`
   - API tests: `api/tests/test_triage_integration.py`
   - E2E guide: `/PRPs/commands/test-e2e.md`

## MCP Tool Integration

- **Playwright MCP**: Use for browser automation during test development
- **Supabase MCP**: Validate database state after test runs
- **Sequential Thinking**: Debug complex test failures

## Success Metrics

- **Deployment Success Rate**: >95% (from current ~70%)
- **Mean Time to Detection**: <5 minutes for configuration issues
- **Test Execution Time**: <10 minutes for full suite
- **Coverage**: 100% of critical user paths
- **Flakiness**: <2% flaky test rate

## Configuration Files

```typescript
// apps/web/playwright.config.ts updates
export default defineConfig({
  projects: [
    {
      name: 'local',
      use: {
        ...devices['Desktop Chrome'],
        baseURL: 'http://localhost:3000',
      },
    },
    {
      name: 'staging',
      use: {
        ...devices['Desktop Chrome'],
        baseURL: 'https://staging.livingtree.io',
      },
    },
  ],
  use: {
    // Add data-testid attribute
    testIdAttribute: 'data-testid',
  },
});

// package.json scripts
{
  "scripts": {
    "test:e2e": "playwright test",
    "test:e2e:staging": "playwright test --project=staging",
    "test:e2e:ui": "playwright test --ui",
    "test:e2e:debug": "playwright test --debug"
  }
}
```

## Gotchas and Considerations

1. **Clerk Test Mode**: Use test mode accounts for E2E tests to avoid rate limiting
2. **OpenAI Mocking**: Mock AI responses to avoid API costs and ensure consistency
3. **Database Cleanup**: Reset test data between runs to ensure isolation
4. **CORS Issues**: Staging tests must run from allowed origins
5. **JWT Expiration**: Handle token refresh in long-running tests

## Risk Mitigation

- Start with smoke tests for critical paths
- Implement retry logic for network-dependent tests
- Use test tags to run subsets (e.g., @smoke, @critical)
- Monitor test execution times and optimize slow tests
- Maintain separate test data that won't interfere with manual testing

## Implementation Confidence Score: 9/10

This PRP provides comprehensive context for implementing E2E tests that will catch staging deployment issues. The existing Playwright setup, clear patterns, and detailed implementation blueprint should enable one-pass success.
