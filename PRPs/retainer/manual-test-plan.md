# Retainer Letter Drafter - Manual Test Plan

## Overview
This document provides a comprehensive manual testing plan for the AI-powered retainer letter generation feature. All tests should be performed in sequence to ensure complete functionality.

## Prerequisites

### Environment Setup
- [ ] Local development environment running (`pnpm dev`)
- [ ] Supabase database running (`npx supabase status`)
- [ ] Valid Clerk authentication token
- [ ] Gmail account connected via Clerk OAuth
- [ ] Test client email addresses available

### Test Data
```json
{
  "test_client_email": "testclient@example.com",
  "test_matter_divorce": "I need help with my divorce proceedings in California. My spouse and I have been separated for 6 months.",
  "test_matter_contract": "I need assistance reviewing a business contract worth $50,000 for my startup.",
  "test_matter_urgent": "URGENT: I received a cease and desist letter and need immediate legal representation."
}
```

## Test Scenarios

### 1. Database Setup Verification

**Test ID**: DB-001  
**Priority**: Critical  
**Precondition**: Supabase running locally

**Steps**:
1. Open Supabase Studio (http://localhost:54323)
2. Navigate to Tables view
3. Verify the following tables exist:
   - `agent_email_settings`
   - `retainer_letter_settings`
   - `legal_document_results`

**Expected Results**:
- All three tables visible
- Tables have proper columns as defined in migration
- RLS policies are enabled

**Pass/Fail**: [ ]

---

### 2. Frontend Tools Page Integration

**Test ID**: UI-001  
**Priority**: Critical  
**Precondition**: Logged in to application

**Steps**:
1. Navigate to `/tools` page
2. Locate "Retainer Letters" tool in Legal category
3. Click the toggle to enable the tool
4. Click settings icon for retainer letters

**Expected Results**:
- Tool appears in Legal tools section
- Toggle switches to enabled state
- Settings dialog opens with firm configuration options
- Agent email address displayed when enabled

**Pass/Fail**: [ ]

---

### 3. Firm Settings Configuration

**Test ID**: SETTINGS-001  
**Priority**: High  
**Precondition**: Retainer Letters tool enabled

**Steps**:
1. Open Retainer Letters settings dialog
2. Fill in firm details:
   ```
   Firm Name: Test Law Firm
   Attorney Name: John Doe
   Attorney Title: Senior Attorney
   Firm Address: 123 Legal St, San Francisco, CA 94102
   Firm Phone: (555) 123-4567
   Firm Email: attorney@testfirm.com
   Default Jurisdiction: California
   Default Fee Structure: hourly
   Default Hourly Rate: 350
   Default Retainer Amount: 5000
   ```
3. Save settings

**Expected Results**:
- All fields accept input
- Settings saved successfully
- Toast notification confirms save
- Settings persist on page reload

**Pass/Fail**: [ ]

---

### 4. AI Chat Tool Invocation

**Test ID**: AI-001  
**Priority**: Critical  
**Precondition**: Firm settings configured

**Steps**:
1. Navigate to `/chat`
2. Send message: "Please use the generate_retainer_letter tool to create a retainer letter for client@example.com with content: I need legal representation for my divorce case in California"
3. Wait for AI response

**Expected Results**:
- AI acknowledges the request
- Tool execution begins
- Progress indicators show generation steps
- Success message displayed

**Pass/Fail**: [ ]

---

### 5. Document Generation - Simple Case

**Test ID**: GEN-001  
**Priority**: Critical  
**Precondition**: AI chat ready

**Steps**:
1. Send divorce matter request via chat
2. Monitor console/logs for generation process
3. Wait for completion

**Expected Results**:
- Client information extracted correctly
- Document generated with proper formatting
- Compliance score > 0.8
- No error messages

**Pass/Fail**: [ ]

---

### 6. Document Generation - Complex Case

**Test ID**: GEN-002  
**Priority**: High  
**Precondition**: AI chat ready

**Steps**:
1. Send complex business contract request
2. Include multiple parties and deadlines
3. Monitor generation process

**Expected Results**:
- Complex information extracted accurately
- Document addresses all points
- Proper legal language used
- Jurisdiction-specific content included

**Pass/Fail**: [ ]

---

### 7. PDF Generation

**Test ID**: PDF-001  
**Priority**: Critical  
**Precondition**: Document generated successfully

**Steps**:
1. Generate a retainer letter
2. Check for PDF creation
3. Download/view PDF

**Expected Results**:
- PDF generated without errors
- Professional formatting with:
  - Firm letterhead section
  - Proper margins and spacing
  - Client information section
  - Fee structure clearly stated
  - Signature blocks
- PDF opens correctly in viewer

**Pass/Fail**: [ ]

---

### 8. Gmail Draft Creation

**Test ID**: GMAIL-001  
**Priority**: Critical  
**Precondition**: Gmail connected, document generated

**Steps**:
1. Generate retainer letter with draft creation enabled
2. Open Gmail
3. Navigate to Drafts folder
4. Open the created draft

**Expected Results**:
- Draft appears in Gmail
- Subject line: "Retainer Agreement - [Client Name]"
- PDF attached to draft
- Cover email with professional content
- To field populated with client email

**Pass/Fail**: [ ]

---

### 9. Legal Compliance Validation

**Test ID**: COMPLIANCE-001  
**Priority**: High  
**Precondition**: Multiple documents generated

**Steps**:
1. Generate letters for different jurisdictions
2. Check compliance scores in database
3. Review compliance issues list

**Expected Results**:
- Compliance scores consistently > 0.8
- Jurisdiction-specific requirements met
- Required legal sections present:
  - Scope of representation
  - Fee structure
  - Client responsibilities
  - Termination clause
  - Dispute resolution

**Pass/Fail**: [ ]

---

### 10. Database Storage Verification

**Test ID**: DB-002  
**Priority**: High  
**Precondition**: Multiple documents generated

**Steps**:
1. Open Supabase Studio
2. Query `legal_document_results` table
3. Verify record creation for each generation

**Expected Results**:
- One record per generation
- All fields populated correctly
- Client information stored in JSON
- Generation metadata present
- Timestamps accurate

**Pass/Fail**: [ ]

---

### 11. Error Handling - Invalid Email

**Test ID**: ERROR-001  
**Priority**: Medium  
**Precondition**: AI chat ready

**Steps**:
1. Request generation with invalid email format
2. Submit: "Generate retainer letter for not-an-email"

**Expected Results**:
- Validation error returned
- Clear error message about email format
- No partial document created
- System remains stable

**Pass/Fail**: [ ]

---

### 12. Error Handling - Missing Information

**Test ID**: ERROR-002  
**Priority**: Medium  
**Precondition**: AI chat ready

**Steps**:
1. Request generation with minimal information
2. Omit matter description

**Expected Results**:
- AI requests additional information
- Graceful handling of incomplete data
- Helpful prompts for missing details

**Pass/Fail**: [ ]

---

### 13. Agent Email Integration

**Test ID**: AGENT-001  
**Priority**: Medium  
**Precondition**: Agent email enabled

**Steps**:
1. Enable agent email in tools
2. Copy displayed agent email address
3. Send test email to agent address
4. Check for automatic processing

**Expected Results**:
- Unique agent email generated
- Email format: `firstname.lastname.agent@domain.com`
- Inbound emails trigger processing
- Automatic retainer letter generation

**Pass/Fail**: [ ]

---

### 14. Performance Testing

**Test ID**: PERF-001  
**Priority**: Low  
**Precondition**: System ready

**Steps**:
1. Generate 5 retainer letters in succession
2. Time each generation
3. Monitor system resources

**Expected Results**:
- Each generation < 30 seconds
- No system degradation
- All generations successful
- Memory usage stable

**Pass/Fail**: [ ]

---

### 15. Edge Cases

**Test ID**: EDGE-001  
**Priority**: Low  
**Precondition**: System ready

**Test Cases**:
- [ ] Very long email content (>5000 words)
- [ ] Special characters in client name
- [ ] Multiple email addresses in request
- [ ] Non-English characters
- [ ] Switching jurisdictions mid-conversation
- [ ] Generating without firm settings

**Expected Results**:
- Graceful handling of all edge cases
- Appropriate error messages
- System stability maintained

**Pass/Fail**: [ ]

---

## Regression Testing

After any code changes, perform these quick checks:

### Quick Smoke Test
1. [ ] Tools page loads
2. [ ] Can enable retainer letters tool
3. [ ] Can generate simple document
4. [ ] PDF generates correctly
5. [ ] Gmail draft created

### Database Integrity
1. [ ] Tables still exist
2. [ ] RLS policies active
3. [ ] Can query results

### Integration Points
1. [ ] Clerk authentication works
2. [ ] OpenAI API responds
3. [ ] Gmail API accessible
4. [ ] Supabase connection stable

---

## Test Results Summary

| Category | Tests | Passed | Failed | Skipped |
|----------|-------|--------|--------|---------|
| Database | 2 | | | |
| UI/Frontend | 2 | | | |
| Generation | 2 | | | |
| PDF | 1 | | | |
| Gmail | 1 | | | |
| Compliance | 1 | | | |
| Error Handling | 2 | | | |
| Integration | 1 | | | |
| Performance | 1 | | | |
| Edge Cases | 1 | | | |

**Overall Pass Rate**: ____%

---

## Issues Found

### Critical Issues
- [ ] Issue:
  - Steps to reproduce:
  - Impact:
  - Suggested fix:

### Non-Critical Issues
- [ ] Issue:
  - Steps to reproduce:
  - Impact:
  - Suggested fix:

---

## Sign-off

**Tested By**: _________________  
**Date**: _________________  
**Environment**: _________________  
**Version**: _________________  

**Approval for Staging**: [ ] Yes [ ] No  
**Notes**: _________________