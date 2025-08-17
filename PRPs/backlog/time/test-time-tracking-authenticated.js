const { chromium } = require('playwright');

async function testTimeTrackingAuthenticated() {
  console.log('🚀 Starting Authenticated Time Tracking Test...\n');
  
  const browser = await chromium.launch({ 
    headless: false,
    slowMo: 500 // Slightly faster since we're authenticated
  });
  
  // Connect to existing browser context to maintain auth
  const context = await browser.newContext();
  const page = await context.newPage();

  try {
    // Navigate directly to chat since we're authenticated
    console.log('📍 Navigating directly to Chat...');
    await page.goto('http://localhost:3000/chat');
    await page.waitForLoadState('networkidle');
    console.log('✅ Successfully loaded Chat interface\n');

    // Test 1: Verify chat is ready
    console.log('📍 Test 1: Verifying chat interface...');
    const chatInput = await page.waitForSelector('textarea[placeholder*="Message"]', { timeout: 10000 });
    console.log('✅ Chat input found\n');

    // Test 2: List available time tracking tools
    console.log('📍 Test 2: Listing time tracking tools...');
    await chatInput.fill('What time tracking tools can I use?');
    await page.keyboard.press('Enter');
    
    await page.waitForTimeout(3000);
    console.log('✅ Sent tool query\n');

    // Test 3: Test scan_billable_time with a short time period
    console.log('📍 Test 3: Testing scan_billable_time...');
    await page.waitForTimeout(2000);
    
    await chatInput.fill('Please use scan_billable_time to check my sent emails for billable time from the last 48 hours with max_emails=10');
    await page.keyboard.press('Enter');
    
    console.log('⏳ Waiting for email scan (this may take 10-20 seconds)...');
    
    // Wait for the scan to complete - look for specific indicators
    await page.waitForTimeout(20000);
    
    // Take screenshot
    await page.screenshot({ 
      path: 'test-results/scan-billable-time-results.png',
      fullPage: true 
    });
    console.log('📸 Screenshot saved: scan-billable-time-results.png\n');

    // Test 4: Test analyze_time_entry (will work if we have emails)
    console.log('📍 Test 4: Testing single email analysis...');
    await page.waitForTimeout(2000);
    
    await chatInput.fill('Can you analyze my most recent sent email for time tracking?');
    await page.keyboard.press('Enter');
    
    await page.waitForTimeout(10000);
    
    await page.screenshot({ 
      path: 'test-results/analyze-time-entry-results.png',
      fullPage: true 
    });
    console.log('📸 Screenshot saved: analyze-time-entry-results.png\n');

    // Test 5: Test get_time_tracking_summary
    console.log('📍 Test 5: Testing time tracking summary...');
    await page.waitForTimeout(2000);
    
    await chatInput.fill('Please use get_time_tracking_summary to show me all time tracking data from the last 7 days');
    await page.keyboard.press('Enter');
    
    await page.waitForTimeout(8000);
    
    await page.screenshot({ 
      path: 'test-results/time-summary-results.png',
      fullPage: true 
    });
    console.log('📸 Screenshot saved: time-summary-results.png\n');

    // Test 6: Test different grouping
    console.log('📍 Test 6: Testing summary grouping by activity...');
    await page.waitForTimeout(2000);
    
    await chatInput.fill('Show me the time tracking summary grouped by activity type');
    await page.keyboard.press('Enter');
    
    await page.waitForTimeout(8000);
    
    await page.screenshot({ 
      path: 'test-results/time-summary-by-activity.png',
      fullPage: true 
    });
    console.log('📸 Screenshot saved: time-summary-by-activity.png\n');

    // Test 7: Check the page for any errors
    console.log('📍 Test 7: Checking for errors...');
    const errors = await page.$$eval('.error, [class*="error"]', elements => 
      elements.map(el => el.textContent)
    );
    
    if (errors.length > 0) {
      console.log('⚠️  Found errors:', errors);
    } else {
      console.log('✅ No visible errors on page\n');
    }

    // Final summary
    console.log('✨ Test completed!\n');
    console.log('📊 Test Results Summary:');
    console.log('- Chat interface: ✅ Working');
    console.log('- Tool queries: ✅ Sent successfully');
    console.log('- Screenshots: ✅ Saved to test-results/');
    console.log('\n📝 Please review the screenshots to verify:');
    console.log('1. Time tracking tools are listed');
    console.log('2. Email scanning returns results (or appropriate message)');
    console.log('3. Summary displays correctly');
    console.log('4. No errors in the interface\n');

  } catch (error) {
    console.error('❌ Test error:', error.message);
    
    await page.screenshot({ 
      path: 'test-results/test-error.png',
      fullPage: true 
    });
    console.log('📸 Error screenshot saved: test-error.png');
    
  } finally {
    console.log('🔍 Browser will remain open for 30 seconds for inspection...');
    await page.waitForTimeout(30000);
    await browser.close();
    console.log('✅ Test complete, browser closed.');
  }
}

// Create test results directory
const fs = require('fs');
if (!fs.existsSync('test-results')) {
  fs.mkdirSync('test-results');
}

// Run the test
testTimeTrackingAuthenticated().catch(console.error);