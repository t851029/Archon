const { chromium } = require('playwright');

async function simpleTimeTrackingTest() {
  console.log('🚀 Starting Simple Time Tracking Test...\n');
  
  const browser = await chromium.launch({ 
    headless: false,
    slowMo: 1000
  });
  
  const context = await browser.newContext();
  const page = await context.newPage();

  try {
    // Go to main page first
    console.log('📍 Going to main page...');
    await page.goto('http://localhost:3000');
    await page.waitForLoadState('networkidle');
    await page.waitForTimeout(3000);
    
    // Take screenshot of current state
    await page.screenshot({ 
      path: 'test-results/current-page-state.png',
      fullPage: true 
    });
    console.log('📸 Current page screenshot saved\n');
    
    // Try to find and click Chat link
    console.log('📍 Looking for Chat navigation...');
    const chatLink = await page.$('text=Chat');
    if (chatLink) {
      console.log('✅ Found Chat link, clicking...');
      await chatLink.click();
      await page.waitForTimeout(5000);
    } else {
      console.log('⚠️  Could not find Chat link\n');
    }
    
    // Take screenshot after navigation
    await page.screenshot({ 
      path: 'test-results/after-chat-click.png',
      fullPage: true 
    });
    console.log('📸 After navigation screenshot saved\n');
    
    // Try different selectors for the chat input
    console.log('📍 Looking for chat input with various selectors...');
    
    const selectors = [
      'textarea',
      'input[type="text"]',
      '[contenteditable="true"]',
      'textarea[placeholder*="Message"]',
      'textarea[placeholder*="message"]',
      'textarea[placeholder*="Type"]',
      'textarea[placeholder*="type"]',
      '.chat-input',
      '#chat-input'
    ];
    
    let inputFound = false;
    let workingSelector = null;
    
    for (const selector of selectors) {
      try {
        const element = await page.$(selector);
        if (element) {
          console.log(`✅ Found input with selector: ${selector}`);
          inputFound = true;
          workingSelector = selector;
          break;
        }
      } catch (e) {
        // Continue trying
      }
    }
    
    if (!inputFound) {
      console.log('❌ Could not find chat input with any selector\n');
      
      // List all textareas on the page
      const textareas = await page.$$eval('textarea', elements => 
        elements.map(el => ({
          placeholder: el.placeholder,
          id: el.id,
          className: el.className
        }))
      );
      console.log('Found textareas:', textareas);
      
      // List all inputs
      const inputs = await page.$$eval('input', elements => 
        elements.map(el => ({
          type: el.type,
          placeholder: el.placeholder,
          id: el.id,
          className: el.className
        }))
      );
      console.log('Found inputs:', inputs.slice(0, 5)); // First 5 only
    } else {
      // Try to interact with the input
      console.log('\n📍 Testing time tracking with found input...');
      const input = await page.$(workingSelector);
      
      // Test 1: Ask about tools
      await input.fill('What time tracking tools are available?');
      await page.keyboard.press('Enter');
      await page.waitForTimeout(5000);
      
      await page.screenshot({ 
        path: 'test-results/tools-query-result.png',
        fullPage: true 
      });
      console.log('📸 Tools query screenshot saved\n');
      
      // Test 2: Try scan_billable_time
      await input.fill('Please use scan_billable_time to scan my last 5 sent emails for time entries');
      await page.keyboard.press('Enter');
      
      console.log('⏳ Waiting for scan to complete...');
      await page.waitForTimeout(15000);
      
      await page.screenshot({ 
        path: 'test-results/scan-result.png',
        fullPage: true 
      });
      console.log('📸 Scan result screenshot saved\n');
      
      // Test 3: Try summary
      await input.fill('Please use get_time_tracking_summary to show me any saved time entries');
      await page.keyboard.press('Enter');
      
      await page.waitForTimeout(8000);
      
      await page.screenshot({ 
        path: 'test-results/summary-result.png',
        fullPage: true 
      });
      console.log('📸 Summary screenshot saved\n');
    }
    
    console.log('✅ Test completed - check test-results/ folder for screenshots');
    
  } catch (error) {
    console.error('❌ Test error:', error.message);
    await page.screenshot({ 
      path: 'test-results/final-error.png',
      fullPage: true 
    });
  } finally {
    console.log('\n🔍 Keeping browser open for manual testing...');
    console.log('You can manually test the time tracking tools now.');
    console.log('Press Ctrl+C when done.');
    
    // Wait indefinitely
    await new Promise(() => {});
  }
}

// Run test
simpleTimeTrackingTest().catch(console.error);