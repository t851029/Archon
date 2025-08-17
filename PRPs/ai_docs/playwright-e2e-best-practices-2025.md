# Playwright E2E Testing Best Practices 2025

## Quick Reference for Living Tree Implementation

### 1. Stable Selectors Strategy

```typescript
// ❌ Avoid: Brittle selectors
await page.click(".btn-primary"); // Class names can change
await page.click("#submit"); // IDs might be dynamic
await page.click("button:nth-child(3)"); // Position-dependent

// ✅ Prefer: Stable selectors
await page.getByRole("button", { name: "Submit" }).click();
await page.getByTestId("submit-button").click();
await page.getByLabel("Email address").fill("test@example.com");
```

### 2. Auto-waiting and Actionability

```typescript
// ❌ Avoid: Manual waits
await page.waitForTimeout(5000); // Arbitrary delays
await page.waitForSelector(".loaded"); // Explicit waits

// ✅ Prefer: Built-in auto-waiting
await page.getByTestId("result").click(); // Waits automatically
await expect(page.getByText("Success")).toBeVisible(); // Auto-waits up to timeout
```

### 3. Network Mocking for External Services

```typescript
// Mock OpenAI API responses
await page.route("**/api/chat", async (route) => {
  const postData = route.request().postData();
  if (postData?.includes("triage_emails")) {
    await route.fulfill({
      status: 200,
      contentType: "text/event-stream",
      body: 'data: {"type":"tool_call","tool":"triage_emails"}\n\n',
    });
  }
});

// Mock third-party services
await page.route("https://api.openai.com/**", async (route) => {
  await route.fulfill({
    status: 200,
    body: JSON.stringify({
      choices: [{ message: { content: "Mocked response" } }],
    }),
  });
});
```

### 4. Parallel Execution and Sharding

```typescript
// playwright.config.ts
export default defineConfig({
  // Run tests in parallel
  fullyParallel: true,

  // Shard tests across multiple machines in CI
  shard: process.env.CI
    ? {
        total: 4,
        current: Number(process.env.SHARD_INDEX) || 1,
      }
    : null,

  // Limit workers in CI to avoid resource issues
  workers: process.env.CI ? 2 : undefined,
});
```

### 5. Test Isolation and Cleanup

```typescript
// Use test.beforeEach for setup
test.beforeEach(async ({ page }) => {
  // Reset application state
  await page.goto("/");
  await page.evaluate(() => {
    localStorage.clear();
    sessionStorage.clear();
  });
});

// Use fixtures for reusable setup
const test = base.extend({
  authenticatedPage: async ({ page }, use) => {
    await loginHelper.login(page);
    await use(page);
    // Cleanup happens automatically
  },
});
```

### 6. CI/CD Best Practices

```yaml
# GitHub Actions optimization
- name: Cache Playwright browsers
  uses: actions/cache@v4
  with:
    path: ~/.cache/ms-playwright
    key: ${{ runner.os }}-playwright-${{ hashFiles('**/package-lock.json') }}

- name: Install Playwright
  run: pnpm exec playwright install --with-deps chromium # Install only needed browsers
```

### 7. Debugging Strategies

```typescript
// Debug mode helpers
await page.pause(); // Opens Playwright Inspector

// Screenshot on failure
test.afterEach(async ({ page }, testInfo) => {
  if (testInfo.status !== "passed") {
    await page.screenshot({
      path: `screenshots/${testInfo.title}-failure.png`,
    });
  }
});

// Trace recording for debugging
export default defineConfig({
  use: {
    trace: "on-first-retry", // Record trace on retry
    video: "retain-on-failure", // Keep video of failures
  },
});
```

### 8. Modern Patterns for 2025

```typescript
// Component testing with Playwright
import { test, expect } from '@playwright/experimental-ct-react';

test('Button component', async ({ mount }) => {
  const component = await mount(
    <Button onClick={() => console.log('clicked')}>Click me</Button>
  );
  await component.click();
  await expect(component).toContainText('Click me');
});

// API testing integration
const apiContext = await request.newContext({
  baseURL: 'https://api.example.com',
  extraHTTPHeaders: {
    'Authorization': `Bearer ${token}`,
  },
});

// Visual regression testing
await expect(page).toHaveScreenshot('homepage.png', {
  fullPage: true,
  animations: 'disabled',
});
```

### 9. Living Tree Specific Patterns

```typescript
// Wait for streaming responses
async function waitForStreamingComplete(page: Page) {
  await page.waitForFunction(
    () => {
      const messages = document.querySelectorAll(
        '[data-testid="assistant-message"]',
      );
      const lastMessage = messages[messages.length - 1];
      return lastMessage && !lastMessage.classList.contains("streaming");
    },
    { timeout: 30000 },
  );
}

// Handle Clerk authentication
async function authenticateWithClerk(page: Page) {
  // Check if already authenticated
  const token = await page.evaluate(() =>
    window.localStorage.getItem("__clerk_db_jwt"),
  );

  if (!token) {
    await page.goto("/sign-in");
    await page.getByLabel("Email address").fill("test@example.com");
    await page.getByLabel("Password").fill("testpassword");
    await page.getByRole("button", { name: "Sign in" }).click();
    await page.waitForURL("/dashboard");
  }
}

// Validate Supabase RLS
async function validateRLS(page: Page, userId: string) {
  const response = await page.request.get("/api/user-data");
  const data = await response.json();

  // Ensure only user's data is returned
  expect(data.every((item) => item.user_id === userId)).toBe(true);
}
```

### 10. Performance Considerations

```typescript
// Measure performance metrics
test("page load performance", async ({ page }) => {
  const metrics = await page.evaluate(() => {
    const navigation = performance.getEntriesByType("navigation")[0];
    return {
      domContentLoaded:
        navigation.domContentLoadedEventEnd -
        navigation.domContentLoadedEventStart,
      loadComplete: navigation.loadEventEnd - navigation.loadEventStart,
    };
  });

  expect(metrics.domContentLoaded).toBeLessThan(3000);
  expect(metrics.loadComplete).toBeLessThan(5000);
});

// Test under different network conditions
await page.route("**/*", (route) => {
  route.continue();
});

const client = await page.context().newCDPSession(page);
await client.send("Network.emulateNetworkConditions", {
  offline: false,
  downloadThroughput: (1.5 * 1024 * 1024) / 8, // 1.5 Mbps
  uploadThroughput: (750 * 1024) / 8, // 750 Kbps
  latency: 40, // 40ms
});
```

## Key Takeaways for Living Tree E2E Tests

1. **Use data-testid consistently** across all components
2. **Mock external services** (OpenAI, Gmail API) for reliable tests
3. **Test critical paths first**: Authentication → Email Triage → Chat
4. **Leverage Playwright's auto-waiting** instead of arbitrary delays
5. **Run tests in parallel** but be mindful of resource usage
6. **Implement proper cleanup** between tests to avoid flakiness
7. **Use GitHub Actions caching** to speed up CI runs
8. **Monitor test execution time** and optimize slow tests
9. **Implement retry logic** for network-dependent operations
10. **Capture debugging artifacts** (screenshots, traces) on failures
