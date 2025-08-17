name: "AI-Powered Retainer Letter Drafter for Living Tree - Context-Rich PRP v2"
description: |
  Comprehensive PRP for implementing an AI-powered retainer letter drafter that leverages Living Tree's existing AI infrastructure, email patterns, and legal context capabilities.

---

## Goal

Implement an AI-powered retainer letter drafter that allows legal professionals to generate professional retainer letters through their unique AI agent email addresses. The system will intelligently extract client information from emails, leverage GPT-5 for legal document generation, and create Gmail drafts with professionally formatted PDF attachments.

## Why

- **Streamline Legal Workflows**: Automate the time-consuming retainer letter creation process for lawyers
- **Leverage Existing AI Infrastructure**: Build on Living Tree's proven triage and email analysis capabilities
- **Enhance Professional Productivity**: Enable instant document generation from simple email requests
- **Integrate with Existing Patterns**: Extend the current tool system and email workflows seamlessly
- **Maintain Legal Standards**: Ensure generated documents meet professional and jurisdictional requirements

## What

An AI-powered retainer letter generation system integrated into Living Tree's existing architecture that:

1. **Processes inbound emails** to unique agent addresses (e.g., `john-doe-a7f3@agent.livingtree.io`)
2. **Extracts client information** using AI analysis similar to existing email triage
3. **Generates professional retainer letters** using GPT-5 with legal-specific prompts
4. **Creates PDF documents** with proper legal formatting and firm branding
5. **Sends Gmail drafts** with generated documents for lawyer review and sending

### Success Criteria

- [ ] Users can enable "Agent Email" and "Retainer Letters" tools via existing toggle system
- [ ] Unique email addresses are generated and displayed following existing patterns
- [ ] Inbound emails to agent addresses trigger AI-powered document generation
- [ ] Generated retainer letters include proper legal sections and formatting
- [ ] PDF documents are created and attached to Gmail draft replies
- [ ] System integrates seamlessly with existing auth, database, and tool patterns
- [ ] Document generation completes within 30 seconds of email receipt
- [ ] All generated documents pass legal compliance validation (score > 0.8)

## All Needed Context

### Documentation & References

```yaml
# MUST READ - Include these in your context window

# Living Tree Architecture Patterns
- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/api/utils/gmail_helpers.py
  why: "Core Gmail draft creation patterns, HTML formatting, From header handling"
  critical: "create_draft() function with proper DOCTYPE and div dir='ltr' wrapper"

- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/api/utils/tools.py
  why: "Tool registration patterns, AI function calling, email processing workflows"
  critical: "Lines 1819-2000 for legal triage patterns, 1217-1300 for auto-draft patterns"

- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/api/utils/email_schemas.py
  why: "Pydantic validation models for email tools, parameter structures"
  critical: "CreateDraftParams, EmailIdInput patterns for new legal document schemas"

- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/api/index.py
  why: "Tool registration in OpenAI function calling, available_tools dict patterns"
  critical: "Lines 167-185 for tool registration, 1160-1220 for parameter mapping"

- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/apps/web/lib/tools-config.ts
  why: "Frontend tool configuration, categories, toggle system patterns"
  critical: "defaultTools array structure, ToolConfig interface patterns"

# Email Infrastructure Research
- docfile: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/PRPs/ai_docs/resend-email-service-2025.md
  why: "Modern email service alternative to SendGrid with Next.js integration patterns"
  critical: "Webhook processing, domain setup, React email templates for 2025"

# Legal Document Generation
- docfile: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/PRPs/ai_docs/legal-document-automation-patterns-2025.md
  why: "AI-driven legal document generation patterns, compliance validation, PDF creation"
  critical: "Template selection, client extraction, validation scoring patterns"

# External References
- url: https://resend.com/docs/send-with-nextjs
  section: "Webhook setup and email template patterns"
  why: "Official Next.js integration patterns for modern email infrastructure"

- url: https://react-pdf.org/
  section: "Document generation with React components"
  why: "Modern PDF generation alternative to Puppeteer for legal documents"

- url: https://pdfgeneratorapi.com/sectors/legal
  section: "Legal document automation best practices"
  why: "Professional standards for automated legal document generation"
```

### Current Codebase Tree (Relevant Sections)

```bash
living-tree/
├── api/
│   ├── utils/
│   │   ├── gmail_helpers.py       # CORE: Gmail draft creation patterns
│   │   ├── tools.py               # CORE: Tool system and AI integration
│   │   ├── email_schemas.py       # CORE: Pydantic validation models
│   │   └── prompt.py              # AI prompt templates
│   ├── core/
│   │   ├── dependencies.py        # CORE: JWT auth and service dependencies
│   │   └── config.py              # Environment configuration
│   └── index.py                   # CORE: FastAPI app and tool registration
├── apps/web/
│   ├── lib/
│   │   └── tools-config.ts        # CORE: Frontend tool configuration
│   ├── app/api/tools/[toolId]/toggle/
│   │   └── route.ts               # CORE: Tool toggle API patterns
│   ├── components/tools/
│   │   ├── tool-card.tsx          # Tool display components
│   │   └── auto-drafts-dialog.tsx # Settings dialog patterns
│   └── types/tools.ts             # Tool type definitions
└── supabase/migrations/           # Database schema patterns
```

### Desired Codebase Tree (Files to Add)

```bash
# Backend Extensions
api/utils/
├── legal_document_schemas.py      # Pydantic models for legal docs
├── retainer_letter_generator.py   # AI-powered document generation
└── email_parsing.py               # Inbound email processing

# Database Extensions
supabase/migrations/
└── YYYYMMDD_add_legal_document_tables.sql  # New tables and RLS

# Frontend Extensions
apps/web/components/tools/
├── legal-document-settings.tsx    # Configuration dialog
└── agent-email-display.tsx        # Email address display

apps/web/app/api/
├── webhooks/resend/route.ts        # Inbound email webhook
└── legal-documents/generate/route.ts  # Manual generation API
```

### Known Gotchas & Library Quirks

```python
# CRITICAL: Gmail Draft HTML Requirements
# Living Tree pattern MUST include full HTML document structure
html_content = f"""<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body>
    <div dir="ltr">
        {content.replace(chr(10), '<br>')}
    </div>
</body>
</html>"""

# CRITICAL: Clerk User ID Format
# Living Tree uses TEXT format for user IDs, not UUID
user_id: str = Depends(get_current_user_id)  # Returns Clerk text ID

# CRITICAL: Tool Parameter Structure
# OpenAI function calling requires nested 'params' object
{
    "name": "generate_retainer_letter",
    "parameters": {
        "type": "object",
        "properties": {
            "params": {  # Nested params required!
                "type": "object",
                "properties": {...}
            }
        }
    }
}

# CRITICAL: Supabase RLS Patterns
# Use auth.jwt() ->> 'sub' for Clerk user isolation
CREATE POLICY "Users access own documents" ON legal_documents 
USING (user_id = auth.jwt() ->> 'sub');

# CRITICAL: Email Address Generation
# Must be deterministic and reversible for lookup
import hashlib
hash_input = f"{user_id}-agent-salt"
short_hash = hashlib.sha256(hash_input.encode()).hexdigest()[:8]
agent_email = f"{user_slug}-{short_hash}@agent.livingtree.io"

# CRITICAL: PDF Attachment in Gmail
# Follow existing create_draft() attachment patterns
attachments = [{
    'filename': 'retainer_letter.pdf',
    'content': base64.b64encode(pdf_buffer).decode(),
    'type': 'application/pdf'
}]
```

## Prerequisites

Before implementation, ensure the following environment setup is complete:

### Development Environment
- **Python Environment**: Python 3.11+ with ruff and mypy available
- **Node.js Environment**: Node.js 20+ with pnpm package manager
- **Docker**: Docker Desktop running for local Supabase and API services
- **Authentication**: Access to Clerk dashboard for user management

### External Services Setup
- **Resend Account**: Create account at https://resend.com and verify domain
- **Domain Configuration**: Set up `agent.livingtree.io` subdomain with MX records
- **Webhook Endpoint**: Configure webhook URL in Resend dashboard
- **API Keys**: Obtain Resend API key and webhook secret

### Testing Prerequisites
- **Clerk JWT Token**: For testing, obtain JWT from browser dev tools after login:
  ```bash
  # In browser console after signing in to Living Tree
  localStorage.getItem('__clerk_session_token')
  # Use this token in curl commands as Authorization: Bearer <token>
  ```
- **Test Email Account**: Email address for sending test requests to agent addresses

## Implementation Blueprint

### Data Models and Structure

Create core data models ensuring type safety and consistency with Living Tree patterns.

```python
# api/utils/legal_document_schemas.py - Follow existing email_schemas.py patterns

from pydantic import BaseModel, Field
from typing import Optional, List, Literal
from datetime import datetime

class LegalClientInfo(BaseModel):
    """Extracted client information for document generation"""
    name: str
    email: str
    phone: Optional[str] = None
    address: Optional[str] = None
    matter_type: str
    matter_description: str
    jurisdiction: Optional[str] = None
    complexity_level: Literal["simple", "standard", "complex"] = "standard"
    
class RetainerLetterParams(BaseModel):
    """Parameters for retainer letter generation"""
    client_email: str = Field(..., description="Client's email address")
    email_content: str = Field(..., description="Original email content")
    subject: str = Field(..., description="Email subject line")
    document_type: Literal["retainer_letter"] = "retainer_letter"
    
class DocumentGenerationResult(BaseModel):
    """Result of document generation process"""
    success: bool
    document_type: str
    client_info: LegalClientInfo
    generated_content: str
    pdf_url: Optional[str] = None
    gmail_draft_id: Optional[str] = None
    validation_score: float
    compliance_issues: List[str] = []
    generation_metadata: dict = {}
```

### List of Tasks (Dependency-Ordered Implementation)

```yaml
Task 1: Database Schema Setup
CREATE api/migrations/add_legal_document_tables.sql:
  - FOLLOW pattern from: existing migrations with RLS
  - INCLUDE tables: agent_email_settings, retainer_letter_settings, legal_document_results
  - PRESERVE existing RLS patterns with Clerk user IDs
  - ADD indexes and policies following established patterns

Task 2: Legal Document Schemas
CREATE api/utils/legal_document_schemas.py:
  - MIRROR pattern from: api/utils/email_schemas.py
  - DEFINE Pydantic models for client info, document params, results
  - FOLLOW Living Tree validation and field naming conventions

Task 3: Retainer Letter Generator
CREATE api/utils/retainer_letter_generator.py:
  - BUILD ON existing legal analysis patterns from tools.py:2217-2320
  - IMPLEMENT AI-powered client extraction using established prompts
  - CREATE document generation with GPT-5 following existing OpenAI patterns
  - ADD PDF generation using React-PDF following modern patterns

Task 4: Email Processing Pipeline
CREATE api/utils/email_parsing.py:
  - EXTEND existing email processing patterns from tools.py
  - IMPLEMENT inbound email parsing for agent addresses
  - ADD legal context extraction building on triage classification
  - INTEGRATE with existing Gmail authentication flows

Task 5: Tool Registration Backend
MODIFY api/utils/tools.py:
  - ADD generate_retainer_letter function following existing tool patterns
  - IMPLEMENT using FastAPI dependencies like get_gmail_service
  - INCLUDE proper error handling and logging patterns
  - FOLLOW existing parameter validation and response formatting

Task 6: OpenAI Function Registration
MODIFY api/index.py:
  - ADD to available_tools dict following existing patterns
  - INCLUDE in tools array with proper OpenAI function schema
  - FOLLOW nested 'params' structure pattern from existing tools
  - PRESERVE existing tool calling and streaming response patterns

Task 7: Database Setup Script
RUN database migration:
  - EXECUTE SQL migration in development environment
  - VERIFY RLS policies work with Clerk authentication
  - TEST table creation and constraint validation
  - CONFIRM indexes are created for performance

Task 8: Frontend Tool Configuration
MODIFY apps/web/lib/tools-config.ts:
  - ADD "agent-email" and "retainer-letters" tools to defaultTools
  - CREATE "legal" category following existing category patterns
  - DEFINE tool capabilities and descriptions
  - SET default enabled: false and hasSettings: true

Task 9: Tool Toggle API Enhancement
MODIFY apps/web/app/api/tools/[toolId]/toggle/route.ts:
  - ADD agent email generation logic for "agent-email" tool
  - IMPLEMENT retainer settings upsert for "retainer-letters" tool
  - FOLLOW existing Supabase client patterns and error handling
  - PRESERVE existing JWT validation and user context

Task 10: Agent Email Display Component
CREATE apps/web/components/tools/agent-email-display.tsx:
  - FOLLOW existing tool card patterns from tool-card.tsx
  - IMPLEMENT email copy functionality with toast notifications
  - SHOW email only when agent-email tool is enabled
  - USE existing UI component patterns and styling

Task 11: Legal Document Settings Dialog
CREATE apps/web/components/tools/legal-document-settings.tsx:
  - MIRROR pattern from: auto-drafts-dialog.tsx
  - CREATE firm settings form (name, attorney, jurisdiction)
  - IMPLEMENT save/load functionality via API
  - FOLLOW existing dialog and form patterns

Task 12: Webhook Processing Endpoint
CREATE apps/web/app/api/webhooks/resend/route.ts:
  - IMPLEMENT Resend webhook signature verification
  - ADD inbound email processing following Next.js patterns
  - INTEGRATE with backend legal document generation
  - INCLUDE proper error handling and logging

Task 13: Frontend Integration
MODIFY apps/web/app/(app)/tools/tools-page-client.tsx:
  - ADD agent email display when enabled
  - INTEGRATE legal document settings dialog
  - FOLLOW existing tool display and interaction patterns
  - PRESERVE existing component structure and styling

Task 14: Email Infrastructure Setup
CONFIGURE email service (requires external setup):
  - SET UP Resend account at https://resend.com
  - VERIFY domain ownership for agent.livingtree.io
  - CONFIGURE DNS MX records: agent.livingtree.io → mx.resend.com
  - CREATE webhook endpoint pointing to https://app.livingtree.io/api/webhooks/resend
  - ADD SPF, DKIM, DMARC records for email authentication
  - TEST inbound email processing with test messages
```

### Integration Points

```yaml
DATABASE:
  - migration: "Add agent_email_settings, retainer_letter_settings, legal_document_results tables"
  - indexes: "CREATE INDEX idx_agent_email_lookup ON agent_email_settings(email_address)"
  - rls: "CREATE POLICY using user_id = auth.jwt() ->> 'sub' pattern"

AUTHENTICATION:
  - pattern: "Use existing Depends(get_current_user_id) for JWT validation"
  - oauth: "Leverage existing get_gmail_service() dependency for Gmail access"
  - context: "Follow established user context passing patterns"

TOOL_SYSTEM:
  - registration: "Add to available_tools dict in api/index.py:167-185"
  - schemas: "Define in api/utils/legal_document_schemas.py following email_schemas.py"
  - frontend: "Extend apps/web/lib/tools-config.ts defaultTools array"

EMAIL_PROCESSING:
  - service: "Use Resend instead of SendGrid for modern integration"
  - parsing: "Build on existing email content analysis from tools.py"
  - drafts: "Leverage existing create_draft() function with PDF attachments"

AI_INTEGRATION:
  - client: "Use existing get_openai_client() dependency"
  - prompts: "Extend legal analysis patterns from triage system"
  - streaming: "Follow established streaming response patterns"
```

## Validation Loop

### Level 1: Syntax & Style

```bash
# Run these FIRST - fix any errors before proceeding
# Note: Adjust commands based on your Python environment setup

# Option 1: If ruff and mypy are installed globally or in venv
python -m ruff check api/utils/legal_document_schemas.py --fix
python -m ruff check api/utils/retainer_letter_generator.py --fix
python -m mypy api/utils/legal_document_schemas.py
python -m mypy api/utils/retainer_letter_generator.py

# Option 2: If using poetry (ensure poetry is available)
# cd api && poetry run ruff check api/utils/legal_document_schemas.py --fix
# cd api && poetry run mypy api/utils/legal_document_schemas.py

# Option 3: Run via Docker if tools are containerized
# docker-compose exec api python -m ruff check api/utils/legal_document_schemas.py --fix

# Frontend validation (these should always work)
cd apps/web && pnpm lint
cd apps/web && pnpm type-check

# Expected: No errors. If errors, READ the error and fix.
```

### Level 2: Unit Tests

```python
# CREATE api/tests/test_retainer_letter_generator.py
import pytest
from api.utils.retainer_letter_generator import RetainerLetterGenerator
from api.utils.legal_document_schemas import RetainerLetterParams, LegalClientInfo

def test_client_info_extraction():
    """Test client information extraction from email content"""
    email_content = "Hi, I'm John Doe at john.doe@example.com. I need a retainer letter for my divorce case in California."
    sender = "john.doe@example.com"
    
    info = extract_client_info(email_content, sender)
    
    assert info.name == "John Doe"
    assert info.email == sender
    assert "divorce" in info.matter_type.lower()
    assert info.jurisdiction == "California"

def test_retainer_letter_generation():
    """Test retainer letter generation with valid inputs"""
    params = RetainerLetterParams(
        client_email="test@example.com",
        email_content="Need retainer for contract review",
        subject="Retainer Letter Request"
    )
    
    generator = RetainerLetterGenerator(mock_openai_client)
    result = await generator.generate_retainer_letter(params, mock_firm_settings)
    
    assert result.success is True
    assert result.validation_score > 0.8
    assert "retainer" in result.generated_content.lower()
    assert len(result.compliance_issues) == 0

def test_email_address_generation():
    """Test unique email generation and parsing"""
    user_id = "user_123"
    user_name = "John Doe"
    
    email1 = generate_agent_email(user_id, user_name)
    email2 = generate_agent_email(user_id, user_name)
    
    assert email1 == email2  # Deterministic
    assert email1.endswith("@agent.livingtree.io")
    assert "john-doe" in email1
    
    parsed_hash = parse_agent_email(email1)
    assert parsed_hash is not None
```

```bash
# Run unit tests - adjust based on your testing setup
# Option 1: If pytest available in environment
python -m pytest api/tests/test_retainer_letter_generator.py -v

# Option 2: If using poetry
# cd api && poetry run pytest tests/test_retainer_letter_generator.py -v

# Option 3: Via Docker
# docker-compose exec api python -m pytest tests/test_retainer_letter_generator.py -v

# Frontend tests
cd apps/web && pnpm test legal-document

# If failing: Read error, understand root cause, fix code, re-run
```

### Level 3: Integration Testing

```bash
# Start services in development mode
pnpm dev

# Test agent email generation via tool toggle
# First, obtain JWT token from browser console after logging in:
# localStorage.getItem('__clerk_session_token')
export CLERK_JWT="your_jwt_token_here"

curl -X POST http://localhost:3000/api/tools/agent-email/toggle \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLERK_JWT" \
  -d '{"enabled": true}'

# Expected: {"tool_id": "agent-email", "enabled": true, "agent_email": "user-hash@agent.livingtree.io"}

# Test retainer letter generation
curl -X POST http://localhost:8000/api/tools/generate_retainer_letter \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLERK_JWT" \
  -d '{
    "params": {
      "client_email": "client@example.com",
      "email_content": "I need a retainer letter for my business litigation matter in California",
      "subject": "Retainer Letter Request"
    }
  }'

# Expected: {"success": true, "document_type": "retainer_letter", "gmail_draft_id": "draft_id"}

# Test webhook processing (simulate Resend webhook)
curl -X POST http://localhost:3000/api/webhooks/resend \
  -H "Content-Type: application/json" \
  -H "resend-webhook-signature: test_signature" \
  -d '{
    "type": "email.received",
    "data": {
      "from": "client@example.com",
      "to": "john-doe-a7f3@agent.livingtree.io",
      "subject": "Need retainer letter",
      "text": "Please prepare a retainer letter for my personal injury case"
    }
  }'

# Expected: {"status": "success", "processed": true}
```

### Level 4: End-to-End Validation

```bash
# Full workflow test
# 1. Enable tools via frontend
# 2. Send actual email to generated agent address
# 3. Verify webhook processing
# 4. Check Gmail draft creation
# 5. Validate PDF generation and attachment

# Database validation
npx supabase sql --file - <<EOF
SELECT * FROM agent_email_settings WHERE enabled = true;
SELECT * FROM legal_document_results ORDER BY created_at DESC LIMIT 5;
EOF

# Email infrastructure test
dig MX agent.livingtree.io  # Should show Resend MX records
```

## Final Validation Checklist

- [ ] All tests pass: `python -m pytest api/tests/ -v` (or via poetry/docker)
- [ ] No linting errors: `python -m ruff check api/` (or via poetry/docker)
- [ ] No type errors: `python -m mypy api/` (or via poetry/docker)
- [ ] Frontend builds: `cd apps/web && pnpm build`
- [ ] Agent email generation works via tool toggle
- [ ] Retainer letter generation creates valid documents
- [ ] PDF attachments are properly formatted
- [ ] Gmail drafts include complete legal documents
- [ ] Webhook processing handles inbound emails correctly
- [ ] Database tables store results with proper RLS
- [ ] Error cases return helpful messages
- [ ] Legal compliance validation passes (score > 0.8)

## Anti-Patterns to Avoid

- ❌ Don't create separate AI service - use existing OpenAI integration
- ❌ Don't skip validation loops - legal documents require accuracy
- ❌ Don't hardcode firm details - make them configurable per user
- ❌ Don't ignore jurisdiction requirements - legal varies by location
- ❌ Don't use SendGrid - Resend provides better developer experience
- ❌ Don't create new authentication patterns - use existing Clerk flows
- ❌ Don't skip PDF quality validation - documents must be professional
- ❌ Don't ignore existing tool patterns - follow established conventions

---

**Confidence Score**: 8.5/10

This PRP leverages Living Tree's mature AI infrastructure, follows established patterns for tools and email processing, and provides comprehensive context for legal document generation. The implementation builds directly on proven patterns while modernizing the email infrastructure with Resend and enhancing AI capabilities for legal document automation. Minor confidence reduction due to environment setup dependencies and tooling variations.

**Validation**: The completed implementation will enable lawyers to generate professional retainer letters through simple email interactions, fully integrated with Living Tree's existing authentication, database, and AI systems.