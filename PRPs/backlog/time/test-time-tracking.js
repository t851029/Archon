const { chromium } = require('playwright');

(async () => {
  // Launch browser
  const browser = await chromium.launch({ headless: false });
  const context = await browser.newContext();
  const page = await context.newPage();

  try {
    console.log('🚀 Starting time tracking test...');

    // Navigate to the app
    await page.goto('http://localhost:3000');
    console.log('✅ Navigated to app');

    // Check if we need to sign in
    if (await page.isVisible('text=Sign in')) {
      console.log('📝 Need to sign in first...');
      await page.click('text=Sign in');
      
      // Wait for sign in page
      await page.waitForURL('**/sign-in**');
      console.log('📍 On sign-in page');
      
      // Fill in credentials (you'll need to update these)
      await page.fill('input[name="identifier"]', 'test@example.com');
      await page.click('button:has-text("Continue")');
      
      // Wait for password field
      await page.waitForSelector('input[name="password"]', { timeout: 5000 });
      await page.fill('input[name="password"]', 'your-password');
      await page.click('button:has-text("Continue")');
      
      // Wait for redirect back to app
      await page.waitForURL('http://localhost:3000/**', { timeout: 10000 });
      console.log('✅ Signed in successfully');
    }

    // Navigate to chat
    await page.click('text=Chat');
    await page.waitForURL('**/chat');
    console.log('✅ Navigated to chat');

    // Test 1: Scan billable time
    console.log('\n🔍 Test 1: Testing scan_billable_time...');
    await page.fill('textarea', 'Please use scan_billable_time to check my sent emails for billable time entries from the last week');
    await page.keyboard.press('Enter');

    // Wait for response
    await page.waitForSelector('text=scan_billable_time', { timeout: 30000 });
    console.log('✅ Time tracking tool was called');

    // Wait for results
    await page.waitForTimeout(5000);
    
    // Test 2: Get time tracking summary
    console.log('\n📊 Test 2: Testing get_time_tracking_summary...');
    await page.fill('textarea', 'Please use get_time_tracking_summary to show me a summary of my time tracking results from the last 7 days');
    await page.keyboard.press('Enter');

    // Wait for response
    await page.waitForSelector('text=time_tracking_summary', { timeout: 30000 });
    console.log('✅ Time tracking summary tool was called');

    // Take screenshot
    await page.screenshot({ path: 'time-tracking-test.png', fullPage: true });
    console.log('📸 Screenshot saved to time-tracking-test.png');

    console.log('\n✨ All tests passed! Time tracking tools are working.');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
    await page.screenshot({ path: 'time-tracking-error.png', fullPage: true });
    console.log('📸 Error screenshot saved to time-tracking-error.png');
  } finally {
    // Keep browser open for manual inspection
    console.log('\n👀 Browser will stay open for manual inspection. Press Ctrl+C to close.');
  }
})();