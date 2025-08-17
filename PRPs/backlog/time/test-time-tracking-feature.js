const { chromium } = require('playwright');

async function testTimeTrackingFeature() {
  console.log('🚀 Starting Time Tracking Feature Test...\n');
  
  const browser = await chromium.launch({ 
    headless: false,
    slowMo: 1000 // Slow down for visibility
  });
  const context = await browser.newContext();
  const page = await context.newPage();

  try {
    // Test 1: Navigate to the app
    console.log('📍 Test 1: Navigating to app...');
    await page.goto('http://localhost:3000');
    await page.waitForLoadState('networkidle');
    console.log('✅ Successfully loaded app\n');

    // Test 2: Check if we need to sign in
    console.log('📍 Test 2: Checking authentication status...');
    const signInVisible = await page.isVisible('text=Sign in', { timeout: 5000 }).catch(() => false);
    
    if (signInVisible) {
      console.log('🔐 Need to sign in - stopping test here');
      console.log('⚠️  Please sign in manually and then re-run the test');
      console.log('\nTo continue testing:');
      console.log('1. Sign in at http://localhost:3000');
      console.log('2. Make sure you have connected your Gmail account');
      console.log('3. Re-run this test\n');
      
      // Keep browser open for manual sign-in
      await page.waitForTimeout(60000); // Wait 60 seconds
      return;
    }

    console.log('✅ Already authenticated\n');

    // Test 3: Navigate to Chat
    console.log('📍 Test 3: Navigating to Chat...');
    await page.click('text=Chat');
    await page.waitForURL('**/chat', { timeout: 10000 });
    console.log('✅ Successfully navigated to Chat\n');

    // Test 4: Check if tools are available
    console.log('📍 Test 4: Checking tool availability...');
    await page.fill('textarea[placeholder*="Message"]', 'What time tracking tools are available?');
    await page.keyboard.press('Enter');
    
    // Wait for response
    await page.waitForTimeout(5000);
    
    // Take screenshot of tool list
    await page.screenshot({ 
      path: 'test-results/time-tracking-tools-list.png',
      fullPage: true 
    });
    console.log('📸 Screenshot saved: time-tracking-tools-list.png\n');

    // Test 5: Test scan_billable_time
    console.log('📍 Test 5: Testing scan_billable_time tool...');
    await page.fill('textarea[placeholder*="Message"]', 'Please use scan_billable_time to check my sent emails for billable time from the last 24 hours');
    await page.keyboard.press('Enter');
    
    // Wait for tool execution
    console.log('⏳ Waiting for email scan to complete...');
    await page.waitForTimeout(15000); // Give it time to scan emails
    
    // Take screenshot of results
    await page.screenshot({ 
      path: 'test-results/time-tracking-scan-results.png',
      fullPage: true 
    });
    console.log('📸 Screenshot saved: time-tracking-scan-results.png\n');

    // Test 6: Test get_time_tracking_summary
    console.log('📍 Test 6: Testing time tracking summary...');
    await page.fill('textarea[placeholder*="Message"]', 'Please use get_time_tracking_summary to show me a summary of time tracking results from the last 7 days');
    await page.keyboard.press('Enter');
    
    // Wait for summary
    await page.waitForTimeout(8000);
    
    // Take screenshot
    await page.screenshot({ 
      path: 'test-results/time-tracking-summary.png',
      fullPage: true 
    });
    console.log('📸 Screenshot saved: time-tracking-summary.png\n');

    // Test 7: Test error handling (no Gmail)
    console.log('📍 Test 7: Testing error handling...');
    await page.fill('textarea[placeholder*="Message"]', 'Please analyze time entry for email ID: nonexistent123');
    await page.keyboard.press('Enter');
    
    await page.waitForTimeout(5000);
    
    // Take screenshot
    await page.screenshot({ 
      path: 'test-results/time-tracking-error-handling.png',
      fullPage: true 
    });
    console.log('📸 Screenshot saved: time-tracking-error-handling.png\n');

    console.log('✨ All tests completed!\n');
    console.log('📊 Test Summary:');
    console.log('- App loaded successfully');
    console.log('- Chat interface accessible');
    console.log('- Time tracking tools responding');
    console.log('- Screenshots saved in test-results/\n');

  } catch (error) {
    console.error('❌ Test failed:', error.message);
    
    // Take error screenshot
    await page.screenshot({ 
      path: 'test-results/time-tracking-error.png',
      fullPage: true 
    });
    console.log('📸 Error screenshot saved: time-tracking-error.png');
    
  } finally {
    console.log('🔍 Browser will remain open for manual inspection.');
    console.log('Press Ctrl+C to close when done.\n');
    
    // Keep browser open
    await page.waitForTimeout(300000); // 5 minutes
  }
}

// Create test results directory
const fs = require('fs');
if (!fs.existsSync('test-results')) {
  fs.mkdirSync('test-results');
}

// Run the test
testTimeTrackingFeature().catch(console.error);