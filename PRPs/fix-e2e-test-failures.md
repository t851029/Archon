# PRP: Fix E2E Test Failures - Clerk Authentication Selectors

## Goal

Fix all failing E2E tests in the GitHub Actions pipeline by correcting Clerk authentication form selectors and implementing robust authentication patterns that work with the latest Clerk UI components.

## Why

- **Business Impact**: E2E tests are currently blocking all deployments to staging and production
- **Developer Productivity**: Teams cannot validate changes without manual testing
- **CI/CD Pipeline**: All GitHub Actions workflows are failing, preventing automated deployments
- **Quality Assurance**: Cannot ensure feature stability without working E2E tests

## What

Update authentication selectors in E2E tests to match actual Clerk form structure, implement proper wait conditions, and ensure tests pass consistently in CI/CD pipeline.

### Success Criteria

- [ ] All E2E tests pass in GitHub Actions with 100% success rate
- [ ] Authentication works reliably with correct selectors
- [ ] Tests run successfully both locally and in CI/CD
- [ ] Proper error handling and retry logic implemented
- [ ] Test artifacts properly generated and uploaded

## All Needed Context

### Documentation & References

```yaml
# MUST READ - Include these in your context window
- url: https://clerk.com/docs/testing/playwright/overview
  why: Official Clerk testing patterns and selector strategies

- file: apps/web/tests/e2e/helpers/auth.helper.ts
  why: Current implementation with incorrect selectors that need fixing

- file: test-results/current-page-state.png
  why: Screenshot showing actual Clerk form structure with placeholder-based inputs

- file: test-results/test-error.png  
  why: Error showing selector timeout for input[name="identifier"]

- docfile: PRPs/backlog/testing/e2e-testing-clerk-auth-extension.md
  why: Comprehensive auth testing patterns to implement

- file: apps/web/tests/e2e/helpers/test-credentials.ts
  why: Existing test credentials management system
```

### Current Codebase Tree

```bash
apps/web/tests/e2e/
├── fixtures/
│   └── auth.fixture.ts
├── flows/
│   ├── auth.test.ts
│   └── chat.test.ts
├── helpers/
│   ├── auth.helper.ts         # BROKEN: Uses wrong selectors
│   ├── test-config.ts
│   └── test-credentials.ts    # Working credential manager
└── global.setup.ts
```

### Desired Codebase Tree with Files to be Added

```bash
apps/web/tests/e2e/
├── fixtures/
│   └── auth.fixture.ts        # Enhanced with retry logic
├── flows/
│   ├── auth.test.ts          # Updated selectors
│   └── chat.test.ts          # Updated selectors
├── helpers/
│   ├── auth.helper.ts        # FIXED: Correct selectors
│   ├── test-config.ts
│   ├── test-credentials.ts
│   └── clerk-selectors.ts    # NEW: Centralized selector management
└── global.setup.ts           # Enhanced error handling
```

### Known Gotchas

```typescript
// CRITICAL: Clerk forms use placeholder attributes, NOT name attributes
// ❌ WRONG: page.locator('input[name="identifier"]')
// ✅ CORRECT: page.getByPlaceholder('Enter your email')

// CRITICAL: Clerk forms have changed structure in recent versions
// The email field now uses placeholder="Enter your email" 
// The password field uses placeholder="Enter your password"

// CRITICAL: Must wait for Clerk components to fully load
// Use .cl-signIn-root or .cl-formFieldInput__identifier selectors

// CRITICAL: Test credentials already exist:
// test1@livingtree.io with password from secrets
// test2@livingtree.io with password from secrets
```

## Implementation Blueprint

### Data Models and Structure

```typescript
// apps/web/tests/e2e/helpers/clerk-selectors.ts
export const ClerkSelectors = {
  // Root containers
  signInRoot: '.cl-signIn-root',
  signUpRoot: '.cl-signUp-root',
  
  // Form inputs using placeholder attributes
  emailInput: '[placeholder="Enter your email"]',
  passwordInput: '[placeholder="Enter your password"]',
  
  // Alternative selectors for robustness
  emailInputAlt: 'input[type="email"]',
  passwordInputAlt: 'input[type="password"]',
  identifierInput: '.cl-formFieldInput__identifier',
  
  // Buttons
  signInButton: 'button:has-text("Sign in")',
  continueButton: 'button:has-text("Continue")',
  googleSignIn: 'button:has-text("Continue with Google")',
  
  // User elements
  userButton: '[data-testid="user-button"]',
  signOutButton: 'text="Sign out"',
  
  // Error messages
  errorMessage: '.cl-formFieldError',
  
  // Loading states
  loadingSpinner: '.cl-spinner',
} as const;
```

### List of Tasks

```yaml
Task 1:
CREATE apps/web/tests/e2e/helpers/clerk-selectors.ts:
  - Define centralized selector constants
  - Include both primary and fallback selectors
  - Add documentation for each selector

Task 2:
MODIFY apps/web/tests/e2e/helpers/auth.helper.ts:
  - FIND pattern: 'input[name="identifier"]'
  - REPLACE with: page.getByPlaceholder('Enter your email')
  - FIND pattern: 'input[name="password"]'
  - REPLACE with: page.getByPlaceholder('Enter your password')
  - ADD robust wait conditions for Clerk components
  - ADD retry logic for transient failures
  - IMPORT ClerkSelectors from clerk-selectors.ts

Task 3:
ENHANCE apps/web/tests/e2e/helpers/auth.helper.ts loginWithClerk method:
  - ADD multiple selector strategies with fallbacks
  - ADD proper error messages for debugging
  - ADD screenshot on failure for debugging
  - IMPLEMENT exponential backoff for retries

Task 4:
UPDATE apps/web/tests/e2e/flows/auth.test.ts:
  - USE new selector patterns
  - ADD explicit waits for Clerk components
  - VERIFY authentication state properly

Task 5:
MODIFY apps/web/tests/e2e/global.setup.ts:
  - ADD better error handling
  - LOG detailed failure information
  - ENSURE test credentials are loaded properly

Task 6:
ADD retry mechanism to all test files:
  - IMPLEMENT test.describe.configure({ retries: 2 })
  - ADD timeout configurations
  - HANDLE transient network failures
```

### Per Task Pseudocode

```typescript
// Task 2 & 3: Enhanced loginWithClerk method
async loginWithClerk(page: Page, email: string, password: string): Promise<void> {
  const maxRetries = 3;
  let lastError: Error | null = null;
  
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      console.log(`🔐 Login attempt ${attempt} for ${email}`);
      
      // Navigate to sign-in
      await page.goto('/sign-in');
      
      // Wait for Clerk to fully load - CRITICAL
      await page.waitForSelector(ClerkSelectors.signInRoot, { 
        timeout: 10000,
        state: 'visible' 
      });
      
      // Strategy 1: Try placeholder selector (preferred)
      try {
        const emailByPlaceholder = page.getByPlaceholder('Enter your email');
        await emailByPlaceholder.waitFor({ state: 'visible', timeout: 5000 });
        await emailByPlaceholder.fill(email);
      } catch {
        // Strategy 2: Fallback to type selector
        console.log('Using fallback email selector');
        const emailByType = page.locator('input[type="email"]').first();
        await emailByType.fill(email);
      }
      
      // Press Enter or click Continue
      await page.keyboard.press('Enter');
      
      // Wait for password field to appear
      await page.waitForSelector(ClerkSelectors.passwordInput, {
        timeout: 5000,
        state: 'visible'
      });
      
      // Fill password using placeholder
      const passwordInput = page.getByPlaceholder('Enter your password');
      await passwordInput.fill(password);
      
      // Click Sign In button
      await page.getByRole('button', { name: 'Sign in' }).click();
      
      // Wait for successful redirect
      await page.waitForURL('/dashboard', { 
        timeout: 10000,
        waitUntil: 'networkidle' 
      });
      
      // Verify authentication
      const token = await this.getJWTToken(page);
      if (!token) throw new Error('No JWT token after login');
      
      console.log(`✅ Login successful for ${email}`);
      return; // Success!
      
    } catch (error) {
      lastError = error as Error;
      console.error(`❌ Login attempt ${attempt} failed:`, error.message);
      
      // Take screenshot for debugging
      await page.screenshot({ 
        path: `test-results/login-failure-${attempt}.png`,
        fullPage: true 
      });
      
      // Exponential backoff
      if (attempt < maxRetries) {
        const delay = Math.pow(2, attempt) * 1000;
        console.log(`⏳ Waiting ${delay}ms before retry...`);
        await page.waitForTimeout(delay);
      }
    }
  }
  
  throw new Error(`Login failed after ${maxRetries} attempts: ${lastError?.message}`);
}
```

### Integration Points

```yaml
DATABASE:
  - No database changes required

CONFIG:
  - Update: apps/web/playwright.config.ts
  - Add retries: 2 for all projects
  - Increase timeout to 60000 for auth tests

ENVIRONMENT:
  - Verify: E2E_TEST_PASSWORD secret exists in GitHub
  - Ensure: Test users exist in Clerk dashboard
  - Check: NEXT_PUBLIC_CLERK_PUBLISHABLE_KEY is correct

CI/CD:
  - File: .github/workflows/e2e-tests-clerk.yml
  - Already configured with proper environment variables
  - Artifacts upload working correctly
```

## Validation Loop

### Level 1: Syntax & Style

```bash
# Run these FIRST - fix any errors before proceeding
cd apps/web
pnpm lint --fix              # Auto-fix linting issues
pnpm type-check              # Verify TypeScript compilation

# Expected: No errors. If errors, READ and fix them.
```

### Level 2: Unit Tests

```typescript
// Test selector validation
describe('Clerk Selectors', () => {
  test('selectors match actual DOM', async ({ page }) => {
    await page.goto('/sign-in');
    
    // Verify email input exists with placeholder
    const emailInput = await page.getByPlaceholder('Enter your email');
    expect(await emailInput.isVisible()).toBe(true);
    
    // Verify password appears after email
    await emailInput.fill('test@example.com');
    await page.keyboard.press('Enter');
    
    const passwordInput = await page.getByPlaceholder('Enter your password');
    expect(await passwordInput.isVisible()).toBe(true);
  });
});
```

```bash
# Run auth helper tests
pnpm test:e2e tests/e2e/helpers/auth.helper.test.ts -v

# If failing: Check selector strategies and add more fallbacks
```

### Level 3: Integration Test

```bash
# Test authentication flow locally
pnpm dev  # Start local environment

# Run single auth test with debug output
DEBUG=pw:api pnpm test:e2e tests/e2e/flows/auth.test.ts --headed

# Test in CI environment locally
act -j test --secret-file .env.test.local

# Expected: Login completes, redirects to /dashboard
```

### Level 4: Full E2E Suite

```bash
# Run complete E2E suite
pnpm test:e2e

# Run with multiple workers (parallel execution)
pnpm test:e2e --workers=4

# Generate HTML report
pnpm test:e2e --reporter=html

# Expected: All tests pass with >95% success rate
```

## Final Validation Checklist

- [ ] All E2E tests pass locally: `pnpm test:e2e`
- [ ] No TypeScript errors: `pnpm type-check`
- [ ] No linting errors: `pnpm lint`
- [ ] Authentication works with correct selectors
- [ ] Retry logic handles transient failures
- [ ] Screenshots generated on failures for debugging
- [ ] Tests pass in GitHub Actions CI/CD pipeline
- [ ] Test reports properly uploaded as artifacts

## Anti-Patterns to Avoid

- ❌ Don't use `input[name="identifier"]` - Clerk doesn't use name attributes
- ❌ Don't skip waiting for Clerk components to load
- ❌ Don't hardcode passwords in test files - use environment variables
- ❌ Don't use generic selectors like `input` without specificity
- ❌ Don't ignore retry logic - network failures happen
- ❌ Don't forget to validate JWT token after login

## Risk Mitigation

1. **Selector Changes**: Implement multiple selector strategies
2. **Network Failures**: Add retry logic with exponential backoff
3. **Timing Issues**: Use proper wait conditions, not fixed delays
4. **Debugging**: Take screenshots on failure for analysis
5. **Parallel Conflicts**: Use worker-specific test credentials

## Success Metrics

- **Test Success Rate**: 100% in CI/CD pipeline
- **Authentication Time**: <3 seconds per login
- **Retry Success**: 95% success on first attempt, 100% within 3 attempts
- **False Positives**: 0% - tests only fail for real issues
- **Debugging Time**: <5 minutes with screenshot evidence

## Implementation Confidence: 10/10

This PRP addresses the root cause of test failures (incorrect selectors) with clear evidence from screenshots showing the actual Clerk form structure. The implementation is straightforward and focuses on fixing the specific selector issues while adding robustness through retry logic and multiple selector strategies.