name: "Retainer Letter Minimal Core - MVP Implementation"
description: |
  Minimal viable implementation of retainer letter generation focusing exclusively on core functionality.
  Builds the absolute minimum working system for legal document generation without complex features.

---

## Goal

Implement the absolute minimum viable retainer letter drafter that generates legally compliant retainer letters through a single API endpoint. Focus exclusively on core document generation without email parsing, complex workflows, or fancy UI components.

## Why

- **Rapid MVP Delivery**: Get a working retainer letter generator into production quickly
- **Risk Reduction**: Validate core functionality before building complex features
- **Clear Foundation**: Establish working patterns that can be extended later
- **User Value Fast**: Deliver immediate value with simple, reliable document generation
- **Technical Simplicity**: Minimize dependencies and complexity for easier maintenance

## What

A minimal retainer letter generation system that:

1. **Single API endpoint** at `/api/tools/generate_retainer_letter`
2. **Simple request model** with basic client info and matter details
3. **Basic PDF generation** using ReportLab (already installed)
4. **Minimal database storage** - just save generation results
5. **Manual testing approach** with curl commands
6. **No email integration** - just return PDF data

### Success Criteria

- [ ] API endpoint accepts POST request with client information
- [ ] Generates legally compliant retainer letter (8 required sections)
- [ ] Creates PDF document with professional formatting
- [ ] Stores result in database with user isolation
- [ ] Returns PDF as base64 or binary response
- [ ] Processing completes in under 10 seconds
- [ ] Manual test suite passes all scenarios

## All Needed Context

### Documentation & References

```yaml
# MUST READ - Core patterns to follow
- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/api/utils/tools.py
  why: "Line 325-500 shows existing generate_retainer_letter implementation"
  critical: "Tool already exists but needs OpenAI registration"

- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/api/utils/pdf_generator.py
  why: "Existing PDF generator with ReportLab already configured"
  critical: "Use LegalDocumentPDFGenerator class for PDF creation"

- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/api/utils/retainer_letter_generator.py
  why: "RetainerLetterGenerator class with AI extraction logic"
  critical: "Core generation logic already implemented"

- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/api/utils/legal_document_schemas.py
  why: "Pydantic models for validation and data structure"
  critical: "Use existing schemas, don't create new ones"

- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/api/index.py
  why: "Tool registration in available_tools dict at line 167-185"
  critical: "Tool exists in dict but missing from OpenAI tools array"

- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/supabase/migrations/20250815000001_add_legal_document_tables.sql
  why: "Database schema already created with proper RLS"
  critical: "Tables exist, just need to ensure migration is applied"
```

### Current Codebase Structure

```bash
# Existing files (already implemented)
api/utils/
├── retainer_letter_generator.py  # ✅ AI-powered generation logic
├── pdf_generator.py              # ✅ ReportLab PDF creation
├── legal_document_schemas.py    # ✅ Data validation models
└── tools.py                      # ✅ Tool function exists

# Database
supabase/migrations/
└── 20250815000001_add_legal_document_tables.sql  # ✅ Schema ready
```

### Minimal Legal Requirements (From Research)

```yaml
REQUIRED_SECTIONS:
  1. Scope of Legal Services  # What work will be done
  2. Fee Structure            # How fees are calculated
  3. Billing Practices        # When and how billing occurs
  4. Trust Account Terms      # How retainer funds are held
  5. Refund Provisions        # When/how unused funds returned
  6. Termination Clause       # How relationship can end
  7. Confidentiality          # Protection of client information
  8. Jurisdiction             # Which state law applies
```

### Known Gotchas & Constraints

```python
# CRITICAL: Tool Registration Gap
# Tool exists in available_tools but NOT in OpenAI tools array
# Must add to api/index.py around line 1093

# CRITICAL: ReportLab Already Available
# No need to install new PDF libraries
# api/utils/pdf_generator.py has working implementation

# CRITICAL: Database Tables Exist
# Migration might already be applied
# Check with: SELECT * FROM legal_document_results LIMIT 1;

# CRITICAL: Firm Settings Required
# Tool expects firm settings to exist
# Need fallback for missing settings

# MINIMAL: Skip These Features
# ❌ Email parsing/webhooks
# ❌ Gmail draft creation
# ❌ Frontend UI components
# ❌ Complex validation flows
# ❌ Multiple document types
```

## Implementation Blueprint

### Phase 1: Core Registration Fix (5 minutes)

```python
# api/index.py - Add to tools array at line ~1093
{
    "type": "function",
    "function": {
        "name": "generate_retainer_letter",
        "description": "Generate professional retainer letter from client information",
        "parameters": {
            "type": "object",
            "properties": {
                "params": {
                    "type": "object",
                    "properties": {
                        "client_email": {
                            "type": "string",
                            "description": "Client's email address"
                        },
                        "email_content": {
                            "type": "string", 
                            "description": "Description of legal matter"
                        },
                        "subject": {
                            "type": "string",
                            "description": "Matter type or subject"
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

### Phase 2: Simplify Existing Tool (10 minutes)

```python
# Modifications to api/utils/tools.py:generate_retainer_letter
# Add fallback firm settings if not configured:

DEFAULT_FIRM_SETTINGS = FirmSettings(
    firm_name="Law Firm",
    attorney_name="Attorney",
    attorney_title="Attorney at Law",
    firm_address="123 Legal Street, Suite 100, City, State 12345",
    firm_phone="(555) 123-4567",
    firm_email="attorney@lawfirm.com",
    default_jurisdiction="California",
    default_fee_structure="hourly",
    default_hourly_rate=350.00,
    default_retainer_amount=5000.00
)

# Use fallback if no settings found:
firm_settings = await get_firm_settings(user.get('id'), supabase_client)
if not firm_settings:
    logger.warning("Using default firm settings")
    firm_settings = DEFAULT_FIRM_SETTINGS
```

### Phase 3: Minimal Testing Approach

```bash
# Step 1: Verify database tables exist
npx supabase db push  # Apply migration if needed

# Step 2: Get JWT token (from browser after login)
# localStorage.getItem('__clerk_session_token')
export JWT_TOKEN="your_token_here"

# Step 3: Test via chat API (preferred method)
curl -X POST http://localhost:8000/api/chat \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{
      "role": "user",
      "content": "Please use the generate_retainer_letter tool to create a retainer letter for john.doe@example.com regarding a divorce case in California"
    }]
  }'

# Step 4: Direct tool test (if registered)
curl -X POST http://localhost:8000/api/tools/execute \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "tool_name": "generate_retainer_letter",
    "params": {
      "client_email": "jane.smith@example.com",
      "email_content": "I need representation for a contract dispute involving $50,000",
      "subject": "Contract Dispute - Urgent"
    }
  }'
```

## List of Tasks (Minimal Implementation)

```yaml
Task 1: Register Tool in OpenAI Array
MODIFY api/index.py:
  - FIND: Line ~1093 (before tools array closing bracket)
  - ADD: generate_retainer_letter function definition
  - VERIFY: JSON syntax is valid
  - TEST: Tool appears in OpenAI function list

Task 2: Add Parameter Model Mapping
MODIFY api/index.py:
  - FIND: Line ~1160-1220 (param_model_map)
  - ADD: "generate_retainer_letter": RetainerLetterParams
  - IMPORT: from api.utils.legal_document_schemas import RetainerLetterParams

Task 3: Add Default Firm Settings
MODIFY api/utils/tools.py:
  - ADD: DEFAULT_FIRM_SETTINGS constant at module level
  - MODIFY: get_firm_settings call to use fallback
  - TEST: Tool works without configured settings

Task 4: Verify Database Migration
RUN commands:
  - npx supabase status  # Check connection
  - npx supabase db push  # Apply migrations
  - VERIFY: Tables exist in Supabase Studio

Task 5: Manual Testing Suite
CREATE test_retainer.sh:
  - Test 1: Simple divorce case
  - Test 2: Contract dispute with amount
  - Test 3: Personal injury matter
  - Test 4: Estate planning request
  - VERIFY: Each generates valid PDF
```

## Validation Loop

### Level 1: Basic Functionality

```bash
# Check tool registration
curl http://localhost:8000/api/health

# Verify OpenAI sees the tool
curl -X POST http://localhost:8000/api/chat \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"messages": [{"role": "user", "content": "What tools do you have available?"}]}'
```

### Level 2: Document Generation

```bash
# Test minimal generation
curl -X POST http://localhost:8000/api/chat \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{
      "role": "user",
      "content": "Generate a retainer letter for client@test.com for a simple will drafting matter"
    }]
  }' | jq '.result'

# Verify all 8 required sections present in output
```

### Level 3: Database Verification

```sql
-- Check results stored
SELECT id, client_email, document_type, validation_score, created_at 
FROM legal_document_results 
ORDER BY created_at DESC 
LIMIT 5;

-- Verify user isolation
SELECT COUNT(*) FROM legal_document_results WHERE user_id = 'test_user_id';
```

### Level 4: PDF Quality Check

```python
# Extract and save PDF for manual review
import base64
import json

# From API response
response = json.loads(api_response)
pdf_base64 = response['result']['pdf_data']
pdf_bytes = base64.b64decode(pdf_base64)

with open('test_retainer.pdf', 'wb') as f:
    f.write(pdf_bytes)

# Manually verify PDF has:
# - Professional formatting
# - All 8 required sections
# - Correct client information
# - Proper signature blocks
```

## What's Explicitly Excluded

### Not Implementing (Save for Later)

```yaml
EXCLUDED_FEATURES:
  Email_Integration:
    - No webhook processing
    - No inbound email parsing
    - No Gmail draft creation
    - No email address generation
    
  Frontend_Components:
    - No React components
    - No settings dialogs
    - No tool cards
    - No UI configuration
    
  Complex_Features:
    - No multiple document types
    - No template selection
    - No jurisdiction detection
    - No automatic fee calculation
    - No conflict checking
    
  Advanced_Validation:
    - No multi-step compliance checking
    - No jurisdiction-specific rules
    - No complex matter classification
    - No deadline detection
```

### Why These Exclusions

1. **Email Integration**: Requires external service setup (Resend), DNS configuration, webhook endpoints
2. **Frontend Components**: Adds complexity without core value validation
3. **Complex Features**: Can be layered on after core works reliably
4. **Advanced Validation**: Legal compliance basics are sufficient for MVP

## Future Enhancement Roadmap

```yaml
Phase_2_Enhancements: # After core works
  - Add Gmail draft creation
  - Implement firm settings UI
  - Add multiple document templates
  - Enable jurisdiction detection

Phase_3_Scaling: # After user validation
  - Email webhook integration
  - Agent email addresses
  - Bulk document generation
  - Template customization

Phase_4_Advanced: # After product-market fit
  - Multi-language support
  - E-signature integration
  - Payment processing
  - Client portal access
```

## Success Metrics for MVP

```yaml
Core_Metrics:
  Functionality:
    - Tool callable via chat: ✓/✗
    - PDF generates correctly: ✓/✗
    - Database stores results: ✓/✗
    - User isolation works: ✓/✗
    
  Performance:
    - Generation time < 10s: target
    - PDF size < 500KB: target
    - Success rate > 95%: target
    
  Quality:
    - All 8 sections present: required
    - Validation score > 0.8: required
    - Professional formatting: required
```

## Manual Test Plan

```bash
#!/bin/bash
# test_retainer_minimal.sh

echo "=== Retainer Letter Minimal Core Test Suite ==="

# Test 1: Basic Generation
echo "Test 1: Basic divorce case..."
curl -X POST http://localhost:8000/api/chat \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{
      "role": "user",
      "content": "Generate retainer letter for john@example.com for divorce case in California"
    }]
  }' -o test1_response.json

# Test 2: Contract Dispute
echo "Test 2: Contract dispute..."
curl -X POST http://localhost:8000/api/chat \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{
      "role": "user",
      "content": "Create retainer letter for jane@test.com regarding $75,000 breach of contract"
    }]
  }' -o test2_response.json

# Test 3: Personal Injury
echo "Test 3: Personal injury..."
curl -X POST http://localhost:8000/api/chat \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "messages": [{
      "role": "user",
      "content": "Generate retainer for bob@client.com for car accident injury case"
    }]
  }' -o test3_response.json

# Verify results
echo "Checking test results..."
for i in 1 2 3; do
  if grep -q "success.*true" test${i}_response.json; then
    echo "✅ Test $i passed"
  else
    echo "❌ Test $i failed"
    cat test${i}_response.json
  fi
done
```

## Final Validation Checklist

- [ ] Tool registered in OpenAI tools array
- [ ] Parameter model mapped correctly
- [ ] Default firm settings provide fallback
- [ ] Database tables exist and accessible
- [ ] Chat API can call the tool
- [ ] PDF generates with all required sections
- [ ] Results stored in database
- [ ] Manual tests pass
- [ ] Generation completes < 10 seconds
- [ ] No dependency on email infrastructure

---

**Confidence Score**: 9.5/10

This minimal implementation leverages existing code that's already 90% complete. The main gap is just the OpenAI tool registration. By focusing only on core functionality and skipping complex features, we can deliver a working MVP in under 30 minutes of implementation time.

**Validation**: The minimal implementation will provide immediate value by enabling lawyers to generate professional retainer letters through the chat interface, with all complex features deferred to future phases.