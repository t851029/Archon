# PRP: E2E Testing Clerk Authentication Extension

## Goal

**Feature Goal**: Extend existing E2E testing infrastructure with complete Clerk authentication implementation
**Deliverable**: Fully functional Clerk authentication helpers enabling reliable E2E test execution
**Success Definition**: E2E tests run successfully with >99% authentication success rate and support for parallel execution

## User Persona

**Primary**: QA Engineers and developers implementing E2E tests
**Secondary**: CI/CD pipeline maintainers ensuring deployment quality

## Why

The existing E2E testing plan lacks critical Clerk authentication implementation details, preventing successful test execution and causing deployment failures.

## What

Complete implementation of Clerk authentication patterns for E2E testing including test user management, session persistence, token refresh, and parallel execution support.

## All Needed Context

```yaml
existing_files:
  - file: apps/web/tests/e2e/helpers/auth.helper.ts
    purpose: Basic AuthHelper skeleton exists but needs complete implementation
  - file: apps/web/tests/e2e/helpers/test-config.ts  
    purpose: Test configuration with placeholder credentials

references:
  - url: https://clerk.com/docs/testing/playwright/overview
    section: "Configuration Steps"
    purpose: Official Clerk testing patterns
  - url: https://playwright.dev/docs/auth
    section: "Authentication"
    purpose: Playwright authentication best practices
```

## Problem Statement

The existing E2E testing plan in `PRPs/backlog/testing/e2e-testing-staging-deployment.md` lacks critical implementation details for Clerk authentication. Missing components include:

1. **Test User Setup**: No guidance on creating and managing Clerk test users
2. **Environment Variables**: Missing test-specific Clerk credential configuration
3. **Login Flow Implementation**: AuthHelper class lacks actual Clerk UI interaction code
4. **Session Persistence**: No implementation for maintaining auth state across tests
5. **Token Refresh**: Token refresh strategy mentioned but not implemented

These gaps prevent successful E2E test implementation and will cause authentication failures during test execution.

## Current State

```yaml
current_state:
  existing_plan:
    - Basic AuthHelper skeleton without implementation
    - Test credentials hardcoded (should use test1@livingtree.io)
    - No Clerk-specific setup instructions
    - Token refresh mentioned in "Gotchas" only

  codebase_auth:
    - Backend: api/core/auth.py using Clerk SDK
    - Frontend: useAuthenticatedFetch hook with getToken()
    - JWT validation with official Clerk methods
    - Testing infrastructure present but minimal
```

## Desired State

```yaml
desired_state:
  complete_auth_testing:
    - Fully implemented Clerk authentication helpers
    - Test user management strategy with documentation
    - Automated session persistence and refresh
    - CI/CD ready with proper environment setup
    - Support for parallel test execution
    - Comprehensive error handling for auth failures
```

## Implementation Blueprint

### Phase 1: Test Infrastructure Setup

#### 1.1 Create Test User Management Documentation

````markdown
# apps/web/tests/e2e/docs/clerk-test-setup.md

## Setting Up Clerk Test Users

### Prerequisites

1. Access to Clerk Dashboard (https://dashboard.clerk.com)
2. Development instance with TEST keys

### Creating Test Users

1. Navigate to Users in Clerk Dashboard
2. Create users with pattern: `test{number}@livingtree.io`
3. Enable password authentication
4. Set strong passwords and store in GitHub Secrets

**Test Accounts Created:**
- Email: `test1@livingtree.io` - Password: `vibecode` ✅
- Email: `test2@livingtree.io` - Password: `vibecode` ✅
- Additional accounts needed: `test3@livingtree.io`, `test4@livingtree.io`

### Environment Configuration

```bash
# .env.test.local
E2E_CLERK_USER_1_EMAIL=test1@livingtree.io
E2E_CLERK_USER_1_PASSWORD=vibecode
E2E_CLERK_USER_2_EMAIL=test2@livingtree.io
E2E_CLERK_USER_2_PASSWORD=vibecode
# Add more for parallel workers

CLERK_SECRET_KEY=sk_test_... # TEST instance key
NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY=pk_test_...
```
````

### Test Mode Configuration

**Current Test Account Setup:**
- Email: `test1@livingtree.io` (created) ✅
- Email: `test2@livingtree.io` (created) ✅
- Password: `vibecode` (same for both accounts)
- Additional accounts needed: `test3@livingtree.io`, `test4@livingtree.io`

**Test Mode Configuration:**
- Use `+clerk_test` email suffix for test mode (optional)
- Fixed OTP: `424242` for all verification flows
- No rate limiting on test accounts

````

#### 1.2 Enhanced AuthHelper Implementation

```typescript
// apps/web/tests/e2e/helpers/auth.helper.ts
import { Page } from '@playwright/test';
import { clerkSetup, setupClerkTestingToken } from '@clerk/testing/playwright';
import * as fs from 'fs';
import * as path from 'path';

export class AuthHelper {
  private static STORAGE_DIR = 'playwright/.clerk';
  private static TOKEN_LIFETIME = 5 * 60 * 1000; // 5 minutes

  /**
   * Initialize Clerk testing environment
   */
  static async initializeClerk() {
    // Create storage directory
    if (!fs.existsSync(this.STORAGE_DIR)) {
      fs.mkdirSync(this.STORAGE_DIR, { recursive: true });
    }

    // Setup Clerk testing token globally
    await clerkSetup();
  }

  /**
   * Login with Clerk using UI interaction
   */
  async loginWithClerk(page: Page, email: string, password: string): Promise<void> {
    const storageFile = path.join(AuthHelper.STORAGE_DIR, `${email}.json`);

    // Check if we have fresh auth state
    if (this.hasValidAuthState(storageFile)) {
      console.log(`♻️ Reusing auth state for ${email}`);
      await page.context().storageState({ path: storageFile });
      return;
    }

    console.log(`🔐 Performing fresh login for ${email}`);

    // Inject testing token to bypass bot detection
    await setupClerkTestingToken({ page });

    // Navigate to sign-in page
    await page.goto('/sign-in');

    // Wait for Clerk components to load
    await page.waitForSelector('.cl-signIn-root', { timeout: 10000 });

    // Fill email field
    const emailInput = page.locator('input[name="identifier"]');
    await emailInput.fill(email);
    await emailInput.press('Enter');

    // Wait for password field to appear
    await page.waitForSelector('input[name="password"]', { timeout: 5000 });

    // Fill password
    const passwordInput = page.locator('input[name="password"]');
    await passwordInput.fill(password);

    // Submit form
    await page.locator('button[type="submit"]').click();

    // Wait for redirect to authenticated page
    await page.waitForURL('/dashboard', { timeout: 10000 });

    // Verify JWT token is present
    const token = await this.getJWTToken(page);
    if (!token) {
      throw new Error('Authentication failed: No JWT token found');
    }

    // Save auth state
    await page.context().storageState({ path: storageFile });
    console.log(`✅ Auth state saved for ${email}`);
  }

  /**
   * Validate JWT token format and presence
   */
  async validateJWT(token: string): Promise<boolean> {
    if (!token) return false;

    // JWT must have 3 parts separated by dots
    const parts = token.split('.');
    if (parts.length !== 3) return false;

    // Must start with eyJ (base64 encoded '{"')
    if (!token.startsWith('eyJ')) return false;

    // Validate each part is base64url encoded
    const base64urlRegex = /^[A-Za-z0-9_-]+$/;
    return parts.every(part => base64urlRegex.test(part));
  }

  /**
   * Get JWT token from page context
   */
  async getJWTToken(page: Page): Promise<string | null> {
    return await page.evaluate(() => {
      // Try multiple possible storage locations
      const possibleKeys = [
        '__clerk_db_jwt',
        'clerk-db-jwt',
        '__session'
      ];

      for (const key of possibleKeys) {
        const value = localStorage.getItem(key);
        if (value) {
          try {
            // If it's a JSON string, parse it
            const parsed = JSON.parse(value);
            if (parsed.token) return parsed.token;
            if (parsed.jwt) return parsed.jwt;
          } catch {
            // If not JSON, return as-is
            return value;
          }
        }
      }

      // Check sessionStorage as fallback
      const sessionToken = sessionStorage.getItem('__clerk_session_token');
      return sessionToken;
    });
  }

  /**
   * Check if auth state file exists and is fresh
   */
  private hasValidAuthState(filePath: string): boolean {
    if (!fs.existsSync(filePath)) return false;

    const stats = fs.statSync(filePath);
    const age = Date.now() - stats.mtimeMs;

    return age < AuthHelper.TOKEN_LIFETIME;
  }

  /**
   * Refresh token if needed (for long-running tests)
   */
  async refreshTokenIfNeeded(page: Page): Promise<void> {
    const token = await this.getJWTToken(page);

    if (!token || !await this.validateJWT(token)) {
      console.log('⚠️ Token invalid or missing, re-authenticating...');

      // Get credentials from environment
      const email = process.env.E2E_CLERK_USER_1_EMAIL!;
      const password = process.env.E2E_CLERK_USER_1_PASSWORD!;

      await this.loginWithClerk(page, email, password);
    }
  }

  /**
   * Sign out and clear auth state
   */
  async signOut(page: Page): Promise<void> {
    // Click user button
    await page.locator('[data-testid="user-button"]').click();

    // Click sign out
    await page.locator('text="Sign out"').click();

    // Wait for redirect
    await page.waitForURL('/sign-in');

    // Clear storage
    await page.evaluate(() => {
      localStorage.clear();
      sessionStorage.clear();
    });
  }
}
````

### Phase 2: Global Setup Configuration

```typescript
// apps/web/tests/e2e/global.setup.ts
import { clerkSetup } from "@clerk/testing/playwright";
import { test as setup } from "@playwright/test";
import { AuthHelper } from "./helpers/auth.helper";
import * as path from "path";

// Configure serial execution for setup
setup.describe.configure({ mode: "serial" });

// Initialize Clerk testing environment
setup("global clerk setup", async () => {
  await AuthHelper.initializeClerk();
  await clerkSetup();
});

// Set up auth states for parallel workers
setup("prepare auth states", async ({ browser }) => {
  const workers = parseInt(process.env.PLAYWRIGHT_WORKERS || "1");

  for (let i = 1; i <= workers; i++) {
    const email = process.env[`E2E_CLERK_USER_${i}_EMAIL`];
    const password = process.env[`E2E_CLERK_USER_${i}_PASSWORD`];

    if (!email || !password) {
      console.warn(`⚠️ Missing credentials for worker ${i}`);
      continue;
    }

    const context = await browser.newContext();
    const page = await context.newPage();
    const authHelper = new AuthHelper();

    try {
      await authHelper.loginWithClerk(page, email, password);
      console.log(`✅ Auth state prepared for worker ${i}`);
    } catch (error) {
      console.error(`❌ Failed to prepare auth for worker ${i}:`, error);
      throw error;
    } finally {
      await context.close();
    }
  }
});
```

### Phase 3: Enhanced Test Configuration

```typescript
// apps/web/tests/e2e/fixtures/auth.fixture.ts
import { test as base } from "@playwright/test";
import { AuthHelper } from "../helpers/auth.helper";

type AuthFixtures = {
  authHelper: AuthHelper;
  authenticatedPage: Page;
};

export const test = base.extend<AuthFixtures>({
  authHelper: async ({}, use) => {
    const helper = new AuthHelper();
    await use(helper);
  },

  authenticatedPage: async ({ page, authHelper }, use, testInfo) => {
    // Use worker-specific credentials
    const workerId = testInfo.parallelIndex + 1;
    const email = process.env[`E2E_CLERK_USER_${workerId}_EMAIL`]!;
    const password = process.env[`E2E_CLERK_USER_${workerId}_PASSWORD`]!;

    // Load pre-authenticated state
    const storageFile = `playwright/.clerk/${email}.json`;
    await page.context().storageState({ path: storageFile });

    // Verify authentication is valid
    await page.goto("/dashboard");
    const token = await authHelper.getJWTToken(page);

    if (!token) {
      // Re-authenticate if needed
      await authHelper.loginWithClerk(page, email, password);
    }

    await use(page);
  },
});
```

### Phase 4: Updated Test Examples

```typescript
// apps/web/tests/e2e/flows/chat.test.ts
import { test } from "../fixtures/auth.fixture";
import { expect } from "@playwright/test";

test.describe("Chat Interface E2E with Clerk Auth", () => {
  test.beforeEach(async ({ authenticatedPage, authHelper }) => {
    // Ensure token is fresh for each test
    await authHelper.refreshTokenIfNeeded(authenticatedPage);
    await authenticatedPage.goto("/chat");
  });

  test("send message with valid auth", async ({ authenticatedPage }) => {
    // Verify we're authenticated
    await expect(
      authenticatedPage.locator('[data-testid="user-button"]'),
    ).toBeVisible();

    // Send message
    const input = authenticatedPage.getByTestId("chat-input");
    await input.fill("Hello, can you help me with my emails?");
    await authenticatedPage.getByTestId("send-button").click();

    // Wait for response
    const response = authenticatedPage.getByTestId("assistant-message").last();
    await expect(response).toBeVisible({ timeout: 30000 });
  });

  test("handle token expiration gracefully", async ({
    authenticatedPage,
    authHelper,
  }) => {
    // Simulate token expiration
    await authenticatedPage.evaluate(() => {
      localStorage.removeItem("__clerk_db_jwt");
    });

    // Attempt API call
    await authenticatedPage.goto("/chat");

    // Should redirect to sign-in
    await expect(authenticatedPage).toHaveURL(/sign-in/);

    // Re-authenticate with actual test credentials
    const email = "test1@livingtree.io";
    const password = "vibecode";
    await authHelper.loginWithClerk(authenticatedPage, email, password);

    // Verify we're back
    await expect(authenticatedPage).toHaveURL("/dashboard");
  });
});
```

### Phase 5: CI/CD Integration

```yaml
# .github/workflows/e2e-tests-clerk.yml
name: E2E Tests with Clerk Auth

on:
  pull_request:
    branches: [main, staging]
  push:
    branches: [staging]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        shard: [1, 2, 3, 4]
    steps:
      - uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: "20"

      - name: Install pnpm
        uses: pnpm/action-setup@v2

      - name: Install dependencies
        run: pnpm install

      - name: Cache Playwright browsers
        uses: actions/cache@v4
        with:
          path: ~/.cache/ms-playwright
          key: playwright-${{ runner.os }}-${{ hashFiles('pnpm-lock.yaml') }}

      - name: Install Playwright
        run: pnpm exec playwright install --with-deps chromium

      - name: Create test users
        env:
          CLERK_SECRET_KEY: ${{ secrets.CLERK_SECRET_KEY_TEST }}
        run: |
          # Script to ensure test users exist
          node scripts/ensure-test-users.js

      - name: Run E2E tests
        env:
          PLAYWRIGHT_WORKERS: 4
          SHARD_INDEX: ${{ matrix.shard }}
          E2E_CLERK_USER_1_EMAIL: ${{ secrets.E2E_CLERK_USER_1_EMAIL }}
          E2E_CLERK_USER_1_PASSWORD: ${{ secrets.E2E_CLERK_USER_1_PASSWORD }}
          E2E_CLERK_USER_2_EMAIL: ${{ secrets.E2E_CLERK_USER_2_EMAIL }}
          E2E_CLERK_USER_2_PASSWORD: ${{ secrets.E2E_CLERK_USER_2_PASSWORD }}
          E2E_CLERK_USER_3_EMAIL: ${{ secrets.E2E_CLERK_USER_3_EMAIL }}
          E2E_CLERK_USER_3_PASSWORD: ${{ secrets.E2E_CLERK_USER_3_PASSWORD }}
          E2E_CLERK_USER_4_EMAIL: ${{ secrets.E2E_CLERK_USER_4_EMAIL }}
          E2E_CLERK_USER_4_PASSWORD: ${{ secrets.E2E_CLERK_USER_4_PASSWORD }}
          CLERK_SECRET_KEY: ${{ secrets.CLERK_SECRET_KEY_TEST }}
          NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY: ${{ secrets.NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY_TEST }}
        run: |
          pnpm test:e2e --shard=${{ matrix.shard }}/4

      - name: Upload test results
        if: always()
        uses: actions/upload-artifact@v4
        with:
          name: playwright-report-${{ matrix.shard }}
          path: playwright-report/
```

### Phase 6: Test User Management Script

```typescript
// scripts/ensure-test-users.js
const { Clerk } = require("@clerk/backend");

const clerk = new Clerk({
  secretKey: process.env.CLERK_SECRET_KEY,
});

const TEST_USERS = [
  { email: "test1@livingtree.io", firstName: "Test", lastName: "User1" },
  { email: "test2@livingtree.io", firstName: "Test", lastName: "User2" },
  { email: "test3@livingtree.io", firstName: "Test", lastName: "User3" },
  { email: "test4@livingtree.io", firstName: "Test", lastName: "User4" },
];

async function ensureTestUsers() {
  for (const userData of TEST_USERS) {
    try {
      // Check if user exists
      const users = await clerk.users.getUserList({
        emailAddress: [userData.email],
      });

      if (users.length === 0) {
        // Create user
        await clerk.users.createUser({
          emailAddress: [userData.email],
          firstName: userData.firstName,
          lastName: userData.lastName,
          password:
            process.env[
              `E2E_CLERK_USER_${userData.email.match(/\d+/)[0]}_PASSWORD`
            ],
          skipPasswordChecks: true,
        });
        console.log(`✅ Created test user: ${userData.email}`);
      } else {
        console.log(`✓ Test user exists: ${userData.email}`);
      }
    } catch (error) {
      console.error(`❌ Failed to ensure user ${userData.email}:`, error);
      process.exit(1);
    }
  }
}

ensureTestUsers().catch(console.error);
```

## Implementation Tasks

1. **Setup Clerk test environment**
   - Create test users in Clerk Dashboard
   - Configure GitHub Secrets with credentials
   - Add test user documentation

2. **Implement AuthHelper class**
   - Complete login flow implementation
   - Add JWT validation logic
   - Implement token refresh mechanism
   - Add session persistence

3. **Configure global setup**
   - Initialize Clerk testing tokens
   - Prepare auth states for workers
   - Set up storage directory structure

4. **Create auth fixtures**
   - Implement authenticatedPage fixture
   - Add worker-specific credential handling
   - Enable parallel test support

5. **Update existing tests**
   - Replace skeleton AuthHelper usage
   - Add token refresh checks
   - Implement proper error handling

6. **Configure CI/CD**
   - Add test user creation step
   - Configure parallel execution
   - Set up proper environment variables
   - Add artifact collection

7. **Add monitoring**
   - Token expiration tracking
   - Auth failure reporting
   - Performance metrics for login

## Final Validation Checklist

### Level 1 - Syntax/Style Validation
```bash
cd apps/web
pnpm lint                    # ESLint passes without errors
pnpm type-check             # TypeScript compilation succeeds
```

**Validation Criteria:**
- [ ] All TypeScript files compile without errors
- [ ] ESLint rules pass with max 50 warnings
- [ ] No missing imports or undefined variables
- [ ] Proper interface definitions for all auth-related types

### Level 2 - Unit Tests
```bash
# Test auth helper functionality in isolation
pnpm test tests/e2e/helpers/auth.helper.test.ts

# Test JWT validation logic
pnpm test tests/unit/jwt-validation.test.ts
```

**Validation Criteria:**
- [ ] AuthHelper class methods work correctly
- [ ] Token refresh mechanism functions properly
- [ ] Session persistence saves and restores state
- [ ] Error handling catches auth failures gracefully

### Level 3 - Integration Tests
```bash
# Run auth-specific E2E tests
pnpm test:e2e tests/e2e/flows/auth.test.ts

# Test parallel execution with multiple workers
pnpm test:e2e --workers=4

# Full E2E suite with authentication
pnpm test:e2e
```

**Validation Criteria:**
- [ ] Login flow completes successfully for all test users
- [ ] Parallel test execution works without auth conflicts
- [ ] Token refresh occurs automatically during long tests
- [ ] Session persistence works across test runs
- [ ] All existing E2E tests pass with new auth implementation

### Level 4 - Creative Validation
```bash
# Staging environment validation
ENVIRONMENT=staging pnpm test:e2e:staging

# Real user flow validation
pnpm test:e2e:staging tests/e2e/flows/user-journey-complete.test.ts

# Performance validation
pnpm test:e2e --reporter=html --workers=8
```

**Validation Criteria:**
- [ ] Staging environment tests pass with >99% success rate
- [ ] Complete user journey from login to task completion works
- [ ] Authentication performance is <2 seconds per login
- [ ] Parallel execution scales to 8+ workers without issues
- [ ] Auth state persistence reduces login frequency by >80%
- [ ] Error recovery mechanisms handle network failures gracefully

## External References

1. **Clerk Testing Documentation**: https://clerk.com/docs/testing/playwright/overview
   - Official testing patterns and best practices
   - Testing token usage and setup

2. **Clerk + Playwright Example**: https://github.com/clerk/clerk-playwright-nextjs
   - Complete working example repository
   - Reference implementation patterns

3. **Playwright Authentication Docs**: https://playwright.dev/docs/auth#advanced-scenarios
   - Token validation strategies
   - Refresh mechanisms for long tests

4. **Clerk Testing Best Practices**: https://clerk.com/docs/testing/overview
   - Session persistence patterns
   - Parallel test strategies

5. **Latest Playwright Patterns**: PRPs/ai_docs/playwright-e2e-best-practices-2025.md
   - Modern testing approaches
   - Performance optimization tips

## MCP Tool Integration

- **Playwright MCP**: Use for debugging auth flows interactively
- **Sequential Thinking**: Break down complex auth scenarios
- **Tavily**: Research latest Clerk updates and patterns

## Success Metrics

- **Auth Success Rate**: >99% successful logins in tests
- **Token Refresh Success**: 100% graceful handling of expiration
- **Parallel Execution**: Support for 4+ workers without conflicts
- **Setup Time**: <30 seconds for full auth initialization
- **Test Stability**: <1% flakiness due to auth issues

## Configuration Files

```typescript
// apps/web/playwright.config.ts additions
import { defineConfig } from '@playwright/test';

export default defineConfig({
  globalSetup: require.resolve('./tests/e2e/global.setup'),

  projects: [
    {
      name: 'auth-setup',
      testMatch: /global\.setup\.ts/,
    },
    {
      name: 'e2e-tests',
      dependencies: ['auth-setup'],
      use: {
        storageState: 'playwright/.clerk/base-auth.json',
      },
    },
  ],

  use: {
    baseURL: process.env.ENVIRONMENT === 'staging'
      ? 'https://staging.livingtree.io'
      : 'http://localhost:3000',
  },
});

// package.json scripts
{
  "scripts": {
    "test:e2e:auth": "playwright test tests/e2e/flows/auth.test.ts",
    "test:e2e:parallel": "playwright test --workers=4",
    "test:e2e:debug": "playwright test --debug",
    "test:users:create": "node scripts/ensure-test-users.js"
  }
}
```

## Gotchas and Considerations

1. **Clerk Test Mode**: Always use TEST instance keys for E2E tests
2. **Rate Limiting**: Test accounts bypass rate limits but production doesn't
3. **Token Expiration**: Clerk tokens expire after 60 seconds by default
4. **Parallel Conflicts**: Each worker needs unique test user
5. **Storage State**: Auth files must be in .gitignore for security
6. **CORS Issues**: Ensure test URLs are in backend CORS allowlist
7. **Account Portal**: May require `cy.origin()` equivalent for redirects

## Risk Mitigation

- Start with single worker to verify auth flow
- Implement comprehensive error logging
- Add retry logic for transient failures
- Monitor Clerk API status during tests
- Have fallback auth mechanism for CI stability

## Implementation Confidence Score: 9/10

This PRP provides comprehensive implementation details for Clerk authentication in E2E tests, addressing all gaps identified in the original plan. The combination of official Clerk patterns, real-world examples, and Living Tree-specific adaptations should enable successful implementation.
