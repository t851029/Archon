name: "Retainer Letter Drafter Completion PRP - Critical Blockers Resolution"
description: |
  Focused PRP to address the 4 critical blockers preventing the retainer letter drafter from functioning end-to-end. This PRP completes the 90% implemented feature by fixing integration gaps.

---

## Goal

Complete the AI-powered retainer letter drafter implementation by addressing the 4 critical blockers identified in validation: missing OpenAI function registration, database migration application, PDF generation infrastructure, and external email setup.

## Why

- **Unblock Core Functionality**: The feature is 90% complete but cannot be used due to missing OpenAI function registration
- **Enable End-to-End Workflow**: All components exist but lack critical integration points
- **Complete User Experience**: Lawyers cannot currently generate retainer letters through the AI chat interface
- **Deliver on PRP Promise**: Original implementation created excellent foundation but missed key integration steps

## What

A focused completion that adds the missing integration pieces to make the retainer letter drafter fully functional:

1. **Add OpenAI Function Registration** - Enable AI chat to call retainer letter generation
2. **Apply Database Migration** - Activate the legal document storage schema
3. **Implement PDF Generation** - Create professional PDF documents with attachments
4. **Configure Email Infrastructure** - Set up Resend webhooks for inbound email processing
5. **Complete Frontend Integration** - Ensure all components are properly connected

### Success Criteria

- [ ] AI chat can successfully call `generate_retainer_letter` tool via OpenAI function calling
- [ ] Database tables exist and store legal document results with proper RLS
- [ ] Generated retainer letters are converted to professional PDF format
- [ ] PDF documents are attached to Gmail drafts automatically
- [ ] Webhook endpoint processes inbound emails from agent addresses
- [ ] Frontend tools page displays retainer letter settings and status
- [ ] End-to-end workflow completes within 30 seconds: email → AI → document → draft

## All Needed Context

### Documentation & References

```yaml
# CRITICAL FILES - Existing implementation to complete

# OpenAI Function Registration Pattern
- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/api/index.py
  why: "Lines 695-1110 show OpenAI tools array structure and parameter patterns"
  critical: "generate_retainer_letter missing from tools array at line 1093"

# Gmail Attachment Patterns
- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/api/utils/gmail_helpers.py
  why: "Line 332 shows base64 encoding pattern for email attachments"
  critical: "create_draft() function handles attachments with proper MIME encoding"

# Database Migration Application
- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/supabase/migrations/20250815000001_add_legal_document_tables.sql
  why: "Complete schema exists but not applied to development environment"
  critical: "Migration ready but requires npx supabase db push to activate"

# Frontend Tools Integration
- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/apps/web/app/(app)/tools/tools-page-client.tsx
  why: "Lines 66-100 show authentication and status management patterns"
  critical: "Retainer letter components created but not integrated into main page"

# Tool Configuration Patterns
- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/apps/web/lib/tools-config.ts
  why: "Legal tools defined but integration verification needed"
  critical: "Ensure retainer-letters tool properly configured with hasSettings: true"

# IMPLEMENTATION FILES - Already created but need integration

# Backend Logic (Complete)
- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/api/utils/retainer_letter_generator.py
  why: "Complete AI-powered document generation logic exists"
  
- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/api/utils/legal_document_schemas.py
  why: "Comprehensive Pydantic schemas for type safety"
  
- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/api/utils/email_parsing.py
  why: "Email processing pipeline with security validation"

# Frontend Components (Complete)
- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/apps/web/components/tools/legal-document-settings.tsx
  why: "Settings dialog for firm configuration"
  
- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/apps/web/components/tools/agent-email-display.tsx
  why: "Agent email display and copy functionality"

# External Documentation
- url: https://reportlab.com/docs/reportlab-userguide.pdf
  section: "PDF Generation with Python"
  why: "Professional PDF generation library for legal documents"

- url: https://resend.com/docs/webhooks
  section: "Webhook signature verification"
  why: "Secure inbound email processing patterns"
```

### Current Implementation Status

```bash
# 90% Complete Implementation
✅ Database Schema Created (migration file exists)
✅ Backend AI Logic Complete (full document generation)
✅ Frontend Components Created (professional UI)
✅ Tool System Integration (toggle APIs work)
✅ Authentication Integration (Clerk JWT patterns)
✅ Gmail Integration Prepared (draft creation patterns)

# Missing Integration Points (10% remaining)
❌ OpenAI Function Registration (blocks AI calling)
❌ Database Migration Applied (blocks data storage)
❌ PDF Generation Infrastructure (blocks document delivery)
❌ Webhook Endpoint Active (blocks inbound email)
❌ Frontend Fully Connected (blocks user interaction)
```

### Known Integration Patterns

```python
# CRITICAL: OpenAI Function Schema Pattern
# From api/index.py lines 928-985 (existing triage_emails tool)
{
    "type": "function",
    "function": {
        "name": "triage_emails",
        "description": "Analyze batch emails for priority classification...",
        "parameters": {
            "type": "object",
            "properties": {
                "params": {  # ALL tools use params wrapper!
                    "type": "object",
                    "properties": {...},
                    "required": [...]
                }
            },
            "required": ["params"]  # Critical pattern
        }
    }
}

# CRITICAL: Gmail Attachment Pattern  
# From api/utils/gmail_helpers.py:332
attachment_data = base64.urlsafe_b64encode(pdf_content).decode()
msg.add_attachment(attachment_data, maintype='application', subtype='pdf', filename='retainer.pdf')

# CRITICAL: Database Migration Pattern
# Living Tree workflow from CLAUDE.md
npx supabase db push  # Local first
npx supabase link --project-ref fwdfewruzeaplmcezyne  # Then staging

# CRITICAL: Tool Registration Pattern
# From api/index.py:167-185
available_tools = {
    "generate_retainer_letter": generate_retainer_letter,  # Already exists!
    # Tool in available_tools but missing from OpenAI array
}
```

## Implementation Blueprint

### Priority 1: OpenAI Function Registration (CRITICAL - Blocks All Usage)

```yaml
MODIFY /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/api/index.py:
  - LOCATION: Insert after line 1093, before closing bracket at line 1111
  - PATTERN: Follow exact structure of existing triage_emails tool (lines 928-985)
  - COMPLETE_SCHEMA: Add full OpenAI function definition with params wrapper
  - JSON_SCHEMA: Validate syntax before insertion
  
COMPLETE OPENAI FUNCTION SCHEMA:
{
    "type": "function",
    "function": {
        "name": "generate_retainer_letter",
        "description": "Generate professional retainer letters from client emails with AI-powered document creation, legal compliance validation, and automatic Gmail draft creation with PDF attachments.",
        "parameters": {
            "type": "object",
            "properties": {
                "params": {
                    "type": "object",
                    "properties": {
                        "client_email": {
                            "type": "string",
                            "description": "Client's email address for correspondence"
                        },
                        "email_content": {
                            "type": "string", 
                            "description": "Original email content from client describing their legal matter"
                        },
                        "subject": {
                            "type": "string",
                            "description": "Email subject line providing case context"
                        },
                        "document_type": {
                            "type": "string",
                            "enum": ["retainer_letter"],
                            "description": "Type of legal document to generate",
                            "default": "retainer_letter"
                        },
                        "override_jurisdiction": {
                            "type": "string",
                            "description": "Override default jurisdiction if specified by client"
                        },
                        "override_matter_type": {
                            "type": "string", 
                            "description": "Override detected matter type if needed"
                        }
                    },
                    "required": ["client_email", "email_content", "subject"]
                }
            },
            "required": ["params"]
        }
    }
}
```

### Priority 2: Database Migration Application

```yaml
INITIALIZE and apply migration commands:
  - INITIALIZE: npx supabase init (if config.toml missing)
  - CHECK_STATUS: npx supabase status (verify Supabase running)
  - APPLY_MIGRATION: npx supabase db reset (applies all migrations from scratch)
  - VERIFY: npx supabase sql "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name LIKE '%legal%' OR table_name LIKE '%agent%'"
  - TEST_RLS: Insert test record to validate Row Level Security policies
  - STAGING_READY: Migration file ready for staging deployment
```

### Priority 3: PDF Generation Infrastructure

```yaml
INSTALL dependency and create PDF generator:
  - INSTALL: cd api && poetry add reportlab (backend dependency management)
  - CREATE: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/api/utils/pdf_generator.py
  - PATTERN: Follow base64 encoding from gmail_helpers.py:332
  - INTEGRATION: Connect to retainer_letter_generator.py output
  - OUTPUT: Base64 encoded PDF ready for Gmail attachment
  - PROFESSIONAL: Legal document formatting with headers, footers, proper margins
```

### Priority 4: Webhook Endpoint Activation

```yaml
ENHANCE /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/apps/web/app/api/webhooks/resend/route.ts:
  - SECURITY: Add signature verification following Resend docs
  - PROCESSING: Connect to backend legal document generation
  - ERROR_HANDLING: Proper HTTP status codes and logging
  - TESTING: Mock webhook for development testing
```

### Priority 5: Frontend Integration Completion

```yaml
ENHANCE /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/apps/web/app/(app)/tools/tools-page-client.tsx:
  - IMPORT: Add LegalDocumentSettingsDialog component
  - STATE: Manage retainer letter settings visibility
  - INTEGRATION: Connect to agent email display logic
  - AUTHENTICATION: Use existing authenticatedFetch pattern
```

### List of Tasks (Dependency-Ordered)

```yaml
Task 1: OpenAI Function Registration (IMMEDIATE)
MODIFY api/index.py:
  - FIND: Line 1093 (before closing tools array bracket)
  - INSERT: Complete generate_retainer_letter function schema
  - PRESERVE: Exact formatting and parameter structure from existing tools
  - VALIDATE: JSON schema is valid and follows params wrapper pattern

Task 2: Database Migration Application
INITIALIZE and execute migration:
  - INITIALIZE: npx supabase init (if config.toml missing in project root)
  - STATUS_CHECK: npx supabase status (ensure Supabase is running)
  - APPLY_MIGRATION: npx supabase db reset (applies all migrations including legal document tables)
  - VERIFY: npx supabase sql "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public' AND table_name IN ('agent_email_settings', 'retainer_letter_settings', 'legal_document_results')"
  - TEST_RLS: Verify Row Level Security policies work with Clerk authentication
  - PERFORMANCE: Confirm indexes created for performance optimization

Task 3: PDF Generation Infrastructure
INSTALL dependency and create PDF generator:
  - INSTALL: cd api && poetry add reportlab (backend dependency management with Poetry)
  - CREATE: api/utils/pdf_generator.py with professional PDF generation using reportlab
  - PATTERN: Legal document formatting with headers, footers, signatures
  - INTEGRATION: Convert retainer letter text to formatted PDF
  - OUTPUT: Base64 encoded PDF ready for email attachment

Task 4: Enhance Gmail Integration
MODIFY api/utils/retainer_letter_generator.py:
  - ADD: PDF generation call after document creation
  - INTEGRATE: PDF attachment with existing create_draft pattern
  - PRESERVE: All existing error handling and logging
  - TEST: PDF attachment appears correctly in Gmail drafts

Task 5: Webhook Endpoint Enhancement  
MODIFY apps/web/app/api/webhooks/resend/route.ts:
  - ADD: Signature verification for security
  - CONNECT: Backend document generation pipeline
  - IMPLEMENT: Proper error responses and logging
  - TEST: Webhook processes inbound emails correctly

Task 6: Frontend Integration Completion
MODIFY apps/web/app/(app)/tools/tools-page-client.tsx:
  - IMPORT: LegalDocumentSettingsDialog component
  - ADD: Settings state management for retainer letters
  - INTEGRATE: Agent email display when tools enabled
  - FOLLOW: Existing authentication and loading patterns

Task 7: Add Tool Logging
MODIFY api/index.py:
  - FIND: Line 1288 (tool success logging section)
  - ADD: generate_retainer_letter to logged tools list
  - PATTERN: Follow existing "✅ Gmail Tool Success" format
  - PRESERVE: All existing logging functionality

Task 8: Environment Configuration
ADD environment variables using Living Tree environment management:
  - REFERENCE: Environment management from CLAUDE.md (pnpm env:sync:dev)
  - GCP_SECRET_MANAGER: Add secrets to Google Secret Manager for proper management
  - REQUIRED_VARS: RESEND_API_KEY, RESEND_WEBHOOK_SECRET, AGENT_EMAIL_DOMAIN
  - SYNC_COMMAND: Use pnpm env:sync:dev to pull secrets to local .env
  - VALIDATION: Run pnpm env:validate to verify all variables present
```

## Validation Loop

### Level 1: Integration Testing

```bash
# Test OpenAI function registration
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLERK_JWT" \
  -d '{
    "messages": [
      {
        "role": "user", 
        "content": "Please use the generate_retainer_letter tool to create a retainer letter for client@example.com with content: I need legal representation for my divorce case in California"
      }
    ]
  }'

# Expected: Tool function called successfully, document generated, PDF attached to draft
```

### Level 2: Database Validation

```bash
# Check Supabase status first
npx supabase status

# Verify migration applied
npx supabase sql --file - <<EOF
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('agent_email_settings', 'retainer_letter_settings', 'legal_document_results');
EOF

# Expected: All 3 tables listed
# If no tables found, run: npx supabase db reset
```

### Level 3: End-to-End Workflow

```bash
# Complete workflow test
# 1. Enable retainer letters tool via frontend
# 2. Send AI chat request to generate retainer letter
# 3. Verify document generation in database
# 4. Check Gmail draft created with PDF attachment
# 5. Validate legal compliance score > 0.8

# Database check after generation
npx supabase sql --file - <<EOF
SELECT * FROM legal_document_results ORDER BY created_at DESC LIMIT 1;
EOF

# Expected: Recent document result with validation_score > 0.8
```

### Level 4: Legal Document Quality Validation

```bash
# Test legal document generation quality
# 1. Check compliance scoring validation
# 2. Verify PDF structure and formatting
# 3. Validate professional appearance
# 4. Confirm legal requirements met

# Generate sample document and validate
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLERK_JWT" \
  -d '{
    "messages": [{
      "role": "user", 
      "content": "Please use the generate_retainer_letter tool to create a retainer letter for sample@test.com with content: I need representation for a contract dispute in California involving a $50,000 breach of contract claim."
    }]
  }'

# Validate generated document:
# - Legal compliance score > 0.8
# - Professional PDF formatting
# - All required sections present
# - No compliance issues in database record
```

## Final Validation Checklist

- [ ] AI chat successfully calls `generate_retainer_letter` via OpenAI function
- [ ] Database migration applied with all 3 tables active
- [ ] PDF generation creates professional legal documents  
- [ ] Gmail drafts include PDF attachments properly formatted
- [ ] Webhook endpoint processes Resend inbound emails
- [ ] Frontend tools page shows retainer letter configuration
- [ ] Legal compliance validation scores above 0.8
- [ ] End-to-end workflow completes within 30 seconds
- [ ] Error handling provides helpful user feedback
- [ ] All security validations pass (RLS, JWT, webhook signatures)
- [ ] PDF documents have professional formatting with proper legal structure
- [ ] Document generation includes all required legal sections
- [ ] No critical compliance issues reported in validation results

## Anti-Patterns to Avoid

- ❌ Don't modify OpenAI parameter structure - must use params wrapper
- ❌ Don't skip database migration - schema required for data persistence
- ❌ Don't implement custom PDF generation - use established libraries
- ❌ Don't bypass webhook signature verification - security requirement
- ❌ Don't create new authentication patterns - use existing Clerk flows
- ❌ Don't skip error logging - critical for debugging legal document issues

---

**Confidence Score**: 9.5/10

This completion PRP addresses specific, identified blockers in a 90% complete implementation with comprehensive fixes for all critical validation issues. Complete OpenAI function schema provided, database migration commands corrected, dependency management specified, and 4-level validation system implemented. All required patterns are documented and available. The foundation is excellent - only integration gaps need resolution.

**Validation**: Upon completion, lawyers will be able to generate professional retainer letters through AI chat, with documents automatically created as Gmail drafts with PDF attachments, fully integrated with Living Tree's existing systems.