name: "Modular Backend-Only Retainer Letter Implementation - Complete Isolation PRP v2"
description: |
  Comprehensive PRP for implementing a fully modular, backend-only retainer letter system with complete isolation from existing codebase. This implementation creates new API endpoints, separate database tables, and independent services without modifying any existing files.

---

## Goal

Implement a completely isolated, modular backend system for AI-powered retainer letter generation that operates independently from the existing Living Tree infrastructure. The system will create new API endpoints under `/api/legal-documents/`, use separate database tables with `legal_` prefix, and function as a standalone module that can be enabled/disabled without affecting any existing features.

## Why

- **Zero Risk Deployment**: Complete isolation ensures no impact on existing production features
- **Modular Architecture**: Can be enabled/disabled per user without affecting the system
- **Independent Testing**: Standalone endpoints allow comprehensive testing before integration
- **Rollback Safety**: Easy to remove or disable if issues arise
- **Progressive Enhancement**: Can be gradually integrated with frontend once proven stable
- **Backend-First Development**: Validates all functionality through API before UI implementation

## What

A backend-only legal document generation system that:

1. **Creates new isolated API endpoints** under `/api/legal-documents/` namespace
2. **Uses separate database schema** with `legal_` prefixed tables and no foreign key constraints
3. **Implements independent services** for PDF generation and email processing
4. **Provides standalone testing endpoints** for validation without frontend
5. **Operates completely independently** from existing tools.py and index.py code

### Success Criteria

- [ ] New API endpoints respond at `/api/legal-documents/*` routes
- [ ] Database tables created with `legal_` prefix and proper RLS
- [ ] PDF generation works independently via API calls
- [ ] Email processing pipeline functions without modifying existing code
- [ ] All endpoints testable via curl/Postman without frontend
- [ ] Zero modifications to existing files (tools.py, index.py main routes)
- [ ] Complete feature can be removed by deleting new files only
- [ ] API documentation available at `/api/legal-documents/docs`

## All Needed Context

### Documentation & References

```yaml
# Existing Patterns to Follow (READ-ONLY - DO NOT MODIFY)
- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/api/index.py
  why: "Study endpoint patterns, dependency injection, CORS setup - DO NOT MODIFY"
  critical: "Lines 188-300 for API route patterns, 29-35 for dependencies import"

- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/api/utils/gmail_helpers.py
  why: "Reference Gmail patterns for our independent implementation - DO NOT MODIFY"
  critical: "create_draft function patterns, HTML formatting requirements"

- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/api/core/dependencies.py
  why: "Import and use existing dependencies without modification"
  critical: "get_current_user_id, get_gmail_service, get_supabase_client"

- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/api/core/config.py
  why: "Use existing configuration without modification"
  critical: "settings object for environment variables"

# Existing Implementation Files (Already Created)
- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/api/utils/legal_document_schemas.py
  why: "Already created Pydantic models for legal documents"
  critical: "All schemas defined and ready to use"

- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/api/utils/retainer_letter_generator.py
  why: "Already created AI-powered document generation"
  critical: "RetainerLetterGenerator class ready to use"

- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/api/utils/pdf_generator.py
  why: "Already created PDF generation with ReportLab"
  critical: "generate_legal_document_pdf function ready"

- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/api/utils/email_parsing.py
  why: "Already created email processing utilities"
  critical: "EmailProcessor class ready for webhook handling"

- file: /home/gwizz/wsl_projects/jerin-lt-144-retainer-letter-drafter/supabase/migrations/20250815000001_add_legal_document_tables.sql
  why: "Database migration already created"
  critical: "Tables and RLS policies defined"

# External Documentation
- url: https://fastapi.tiangolo.com/tutorial/bigger-applications/
  section: "Bigger Applications - Multiple Files"
  why: "FastAPI pattern for modular API organization"

- url: https://fastapi.tiangolo.com/advanced/sub-applications/
  section: "Sub Applications - Mounting"
  why: "Pattern for mounting independent FastAPI apps"
```

### Current Codebase Tree (Relevant Sections)

```bash
living-tree/
├── api/
│   ├── index.py                    # Main API - DO NOT MODIFY
│   ├── core/
│   │   ├── dependencies.py         # Use imports only - DO NOT MODIFY
│   │   └── config.py               # Use imports only - DO NOT MODIFY
│   └── utils/
│       ├── tools.py                # DO NOT MODIFY
│       ├── gmail_helpers.py        # Reference only - DO NOT MODIFY
│       ├── legal_document_schemas.py  # ALREADY CREATED
│       ├── retainer_letter_generator.py # ALREADY CREATED
│       ├── pdf_generator.py        # ALREADY CREATED
│       └── email_parsing.py        # ALREADY CREATED
└── supabase/migrations/
    └── 20250815000001_add_legal_document_tables.sql # ALREADY CREATED
```

### Desired Codebase Tree (New Files Only)

```bash
# NEW FILES TO CREATE (No modifications to existing files)
api/
├── legal_documents/                # New module directory
│   ├── __init__.py                # Module initialization
│   ├── router.py                   # All legal document API routes
│   ├── service.py                  # Business logic orchestration
│   └── database.py                 # Database operations layer
```

### Known Gotchas & Implementation Requirements

```python
# CRITICAL: Modular Router Pattern
# Create sub-application that mounts to main app
from fastapi import APIRouter
router = APIRouter(
    prefix="/api/legal-documents",
    tags=["legal-documents"],
    responses={404: {"description": "Not found"}},
)

# CRITICAL: Independent Database Operations
# Use existing Supabase client but separate operations
from api.core.dependencies import get_supabase_client
# All queries use legal_* tables only

# CRITICAL: Standalone Service Layer
# Orchestrate existing utilities without modifying them
from api.utils.retainer_letter_generator import RetainerLetterGenerator
from api.utils.pdf_generator import generate_legal_document_pdf
from api.utils.legal_document_schemas import *

# CRITICAL: Error Isolation
# Catch all errors to prevent impact on main application
try:
    # Legal document operations
except Exception as e:
    logger.error(f"Legal document error (isolated): {e}")
    return {"error": "Legal document service temporarily unavailable"}

# CRITICAL: Authentication Reuse
# Import and use existing auth without modification
from api.core.dependencies import get_current_user_id
user_id: str = Depends(get_current_user_id)

# CRITICAL: Minimal index.py Addition
# Only add router import and mount - 2 lines total
# This is the ONLY modification to existing code
from api.legal_documents import router as legal_router
app.include_router(legal_router)
```

## Implementation Blueprint

### Data Models and Structure

All data models are already defined in `api/utils/legal_document_schemas.py`:
- ExtractedClientInfo - Client information extraction
- FirmSettings - Law firm configuration
- RetainerLetterParams - Tool parameters
- DocumentGenerationResult - Generation results
- Database schemas for all legal_* tables

### List of Tasks (Dependency-Ordered Implementation)

```yaml
Task 1: Create Legal Documents Module Structure
CREATE api/legal_documents/__init__.py:
  - CREATE empty __init__.py for module initialization
  - ADD docstring explaining module purpose
  - EXPORT router for main app import

Task 2: Create Database Operations Layer
CREATE api/legal_documents/database.py:
  - IMPLEMENT get_firm_settings(user_id, supabase_client)
  - IMPLEMENT save_firm_settings(user_id, settings, supabase_client)
  - IMPLEMENT get_agent_email_settings(user_id, supabase_client)
  - IMPLEMENT save_agent_email_settings(user_id, email_data, supabase_client)
  - IMPLEMENT save_document_result(user_id, result, supabase_client)
  - IMPLEMENT get_document_results(user_id, limit, supabase_client)
  - USE only legal_* tables with proper error handling
  - RETURN structured responses using existing schemas

Task 3: Create Service Orchestration Layer
CREATE api/legal_documents/service.py:
  - IMPLEMENT LegalDocumentService class
  - ADD generate_retainer_letter method using existing utilities
  - ADD process_email_request method for webhook handling
  - ADD create_gmail_draft method using gmail_helpers patterns
  - ORCHESTRATE existing utilities without modification
  - IMPLEMENT comprehensive error handling and logging
  - RETURN responses using DocumentGenerationResult schema

Task 4: Create API Router with All Endpoints
CREATE api/legal_documents/router.py:
  - CREATE FastAPI APIRouter with prefix="/api/legal-documents"
  - IMPLEMENT POST /generate-retainer - Generate retainer letter
  - IMPLEMENT POST /webhook/email - Process inbound emails
  - IMPLEMENT GET /settings/firm - Get firm settings
  - IMPLEMENT PUT /settings/firm - Update firm settings
  - IMPLEMENT GET /settings/agent-email - Get agent email
  - IMPLEMENT POST /settings/agent-email/generate - Generate agent email
  - IMPLEMENT GET /documents - List generated documents
  - IMPLEMENT GET /documents/{document_id} - Get specific document
  - IMPLEMENT GET /health - Module health check
  - IMPLEMENT GET /docs - API documentation
  - USE dependency injection for auth and services
  - ADD comprehensive error handling and validation

Task 5: Mount Router to Main Application
MODIFY api/index.py (ONLY addition - 2 lines):
  - ADD import: from api.legal_documents import router as legal_router
  - ADD mount: app.include_router(legal_router)
  - NO other changes to index.py

Task 6: Run Database Migration
EXECUTE migration:
  - RUN: npx supabase db push (migration file already exists)
  - VERIFY tables created with proper RLS
  - TEST with sample inserts/queries
```

### Per Task Implementation Details

```python
# Task 2: Database Operations Layer (database.py)
import logging
from typing import Optional, Dict, Any, List
from datetime import datetime, timezone
from supabase import Client
from api.utils.legal_document_schemas import (
    FirmSettings, AgentEmailSettingsDB, 
    LegalDocumentResultDB
)

logger = logging.getLogger(__name__)

class LegalDocumentDB:
    """Database operations for legal documents - completely isolated"""
    
    @staticmethod
    async def get_firm_settings(user_id: str, supabase: Client) -> Optional[FirmSettings]:
        try:
            result = supabase.table('retainer_letter_settings')\
                .select('*')\
                .eq('user_id', user_id)\
                .single()\
                .execute()
            
            if result.data:
                return FirmSettings(**result.data)
            return None
        except Exception as e:
            logger.error(f"Error fetching firm settings: {e}")
            return None
    
    # Additional methods following same pattern...

# Task 3: Service Layer (service.py)
import logging
import hashlib
from typing import Dict, Any, Optional
from datetime import datetime, timezone
from openai import OpenAI
from supabase import Client
from googleapiclient.discovery import Resource

from api.utils.retainer_letter_generator import RetainerLetterGenerator
from api.utils.pdf_generator import generate_legal_document_pdf
from api.utils.gmail_helpers import create_draft
from api.utils.legal_document_schemas import *
from api.legal_documents.database import LegalDocumentDB

logger = logging.getLogger(__name__)

class LegalDocumentService:
    """Service layer orchestrating legal document operations"""
    
    def __init__(self, openai_client: OpenAI, supabase_client: Client):
        self.openai_client = openai_client
        self.supabase_client = supabase_client
        self.db = LegalDocumentDB()
        self.generator = RetainerLetterGenerator(openai_client)
    
    async def generate_retainer_letter(
        self,
        params: RetainerLetterParams,
        user_id: str,
        gmail_service: Optional[Resource] = None
    ) -> DocumentGenerationResult:
        """Generate retainer letter with all components"""
        try:
            # Get firm settings
            firm_settings = await self.db.get_firm_settings(user_id, self.supabase_client)
            if not firm_settings:
                # Use defaults if not configured
                firm_settings = FirmSettings(
                    firm_name="Law Firm",
                    attorney_name="Attorney"
                )
            
            # Generate document
            result = await self.generator.generate_retainer_letter(
                params, firm_settings, user_id
            )
            
            # Generate PDF if successful
            if result.success:
                pdf_data = generate_legal_document_pdf(
                    document_type="retainer_letter",
                    content=result.generated_content,
                    client_email=params.client_email,
                    matter_type=result.client_info.matter_type,
                    firm_settings=firm_settings.model_dump()
                )
                result.pdf_url = f"data:application/pdf;base64,{pdf_data}"
                
                # Create Gmail draft if requested and service available
                if params.generate_draft and gmail_service:
                    draft_result = self.create_draft_with_pdf(
                        gmail_service,
                        params.client_email,
                        result,
                        pdf_data
                    )
                    if draft_result:
                        result.gmail_draft_id = draft_result.get('id')
            
            # Save to database
            await self.db.save_document_result(user_id, result, self.supabase_client)
            
            return result
            
        except Exception as e:
            logger.error(f"Service error: {e}", exc_info=True)
            raise

# Task 4: API Router (router.py)
from fastapi import APIRouter, Depends, HTTPException, Request
from fastapi.responses import JSONResponse
from typing import Optional, List
import logging

from api.core.dependencies import (
    get_current_user_id,
    get_supabase_client,
    get_gmail_service,
    get_openai_client
)
from api.utils.legal_document_schemas import *
from api.legal_documents.service import LegalDocumentService
from api.legal_documents.database import LegalDocumentDB

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/api/legal-documents",
    tags=["legal-documents"],
    responses={404: {"description": "Not found"}},
)

@router.get("/health")
async def health_check():
    """Health check for legal documents module"""
    return {
        "status": "healthy",
        "module": "legal-documents",
        "version": "1.0.0",
        "isolated": True
    }

@router.post("/generate-retainer", response_model=DocumentGenerationResult)
async def generate_retainer_letter(
    params: RetainerLetterParams,
    user_id: str = Depends(get_current_user_id),
    supabase = Depends(get_supabase_client),
    openai_client = Depends(get_openai_client),
    gmail_service: Optional[Resource] = Depends(get_gmail_service)
):
    """Generate a retainer letter from email content"""
    try:
        service = LegalDocumentService(openai_client, supabase)
        result = await service.generate_retainer_letter(
            params, user_id, gmail_service
        )
        return result
    except Exception as e:
        logger.error(f"Endpoint error: {e}", exc_info=True)
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/settings/firm", response_model=Optional[FirmSettings])
async def get_firm_settings(
    user_id: str = Depends(get_current_user_id),
    supabase = Depends(get_supabase_client)
):
    """Get firm settings for current user"""
    try:
        db = LegalDocumentDB()
        settings = await db.get_firm_settings(user_id, supabase)
        return settings
    except Exception as e:
        logger.error(f"Error getting firm settings: {e}")
        raise HTTPException(status_code=500, detail=str(e))

# Additional endpoints following same pattern...
```

### Integration Points

```yaml
DATABASE:
  - tables: "legal_* tables already defined in migration"
  - operations: "All queries through LegalDocumentDB class"
  - isolation: "No foreign keys to existing tables"

AUTHENTICATION:
  - reuse: "Import get_current_user_id from dependencies"
  - pattern: "user_id: str = Depends(get_current_user_id)"
  - isolation: "No changes to auth system"

SERVICES:
  - gmail: "Optional dependency - works without it"
  - openai: "Reuse get_openai_client dependency"
  - supabase: "Reuse get_supabase_client dependency"

CONFIGURATION:
  - reuse: "Import settings from api.core.config"
  - isolation: "No new environment variables required"

MOUNTING:
  - minimal: "Two lines added to index.py"
  - removable: "Can comment out to disable entirely"
```

## Validation Loop

### Level 1: Syntax & Style

```bash
# Check Python syntax and imports
cd api
python -m py_compile legal_documents/__init__.py
python -m py_compile legal_documents/router.py
python -m py_compile legal_documents/service.py
python -m py_compile legal_documents/database.py

# Run linting if available
python -m ruff check legal_documents/ --fix
python -m mypy legal_documents/

# Expected: No errors. Module imports work correctly.
```

### Level 2: Module Independence Test

```python
# CREATE api/legal_documents/test_independence.py
"""Test that legal documents module works independently"""

def test_module_imports():
    """Test that module can be imported without errors"""
    try:
        from api.legal_documents import router
        from api.legal_documents.service import LegalDocumentService
        from api.legal_documents.database import LegalDocumentDB
        print("✅ All module imports successful")
        return True
    except ImportError as e:
        print(f"❌ Import error: {e}")
        return False

def test_no_external_modifications():
    """Verify no modifications to existing files"""
    # Check that tools.py hasn't been modified
    with open('api/utils/tools.py', 'r') as f:
        content = f.read()
        assert 'legal_document' not in content.lower()
        print("✅ tools.py unmodified")
    
    # Check minimal index.py changes
    with open('api/index.py', 'r') as f:
        content = f.read()
        legal_mentions = content.lower().count('legal')
        assert legal_mentions <= 2  # Only import and mount
        print("✅ index.py minimally modified")

if __name__ == "__main__":
    test_module_imports()
    test_no_external_modifications()
```

### Level 3: API Endpoint Testing

```bash
# Start the API server
cd api
uvicorn index:app --reload --port 8000

# Test health endpoint
curl -X GET http://localhost:8000/api/legal-documents/health

# Expected: {"status": "healthy", "module": "legal-documents", "version": "1.0.0"}

# Test with authentication (get JWT from browser)
export JWT_TOKEN="your_jwt_token_here"

# Test retainer generation
curl -X POST http://localhost:8000/api/legal-documents/generate-retainer \
  -H "Authorization: Bearer $JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "client_email": "client@example.com",
    "email_content": "I need a retainer letter for my divorce case in California",
    "subject": "Legal Services Request",
    "document_type": "retainer_letter"
  }'

# Test firm settings
curl -X GET http://localhost:8000/api/legal-documents/settings/firm \
  -H "Authorization: Bearer $JWT_TOKEN"

# Test document listing
curl -X GET http://localhost:8000/api/legal-documents/documents \
  -H "Authorization: Bearer $JWT_TOKEN"
```

### Level 4: Database Isolation Verification

```sql
-- Verify tables exist and are isolated
SELECT table_name FROM information_schema.tables 
WHERE table_name LIKE 'legal_%' OR table_name LIKE '%retainer%' OR table_name LIKE 'agent_email%';

-- Test RLS policies
SELECT * FROM agent_email_settings; -- Should require auth
SELECT * FROM retainer_letter_settings; -- Should require auth
SELECT * FROM legal_document_results; -- Should require auth

-- Verify no foreign keys to existing tables
SELECT 
    tc.constraint_name, 
    tc.table_name, 
    kcu.column_name, 
    ccu.table_name AS foreign_table_name
FROM information_schema.table_constraints AS tc 
JOIN information_schema.key_column_usage AS kcu
    ON tc.constraint_name = kcu.constraint_name
JOIN information_schema.constraint_column_usage AS ccu
    ON ccu.constraint_name = tc.constraint_name
WHERE tc.constraint_type = 'FOREIGN KEY' 
    AND tc.table_name LIKE 'legal_%';

-- Expected: No results (no foreign keys)
```

### Level 5: Rollback Test

```bash
# Test that the feature can be completely disabled

# Step 1: Comment out the two lines in index.py
# from api.legal_documents import router as legal_router
# app.include_router(legal_router)

# Step 2: Restart the server
uvicorn index:app --reload --port 8000

# Step 3: Verify main app still works
curl http://localhost:8000/api/health
# Expected: {"status": "ok", ...}

# Step 4: Verify legal endpoints are gone
curl http://localhost:8000/api/legal-documents/health
# Expected: 404 Not Found

# Step 5: Re-enable by uncommenting the two lines
```

## Final Validation Checklist

- [ ] All new files created in `api/legal_documents/` directory
- [ ] No modifications to existing files except 2-line addition to index.py
- [ ] Database migration successful with legal_* tables created
- [ ] Health endpoint responds at `/api/legal-documents/health`
- [ ] Generate retainer endpoint works with authentication
- [ ] PDF generation creates valid base64 encoded documents
- [ ] Settings endpoints allow firm configuration
- [ ] All operations isolated to legal_* database tables
- [ ] Module can be disabled by commenting 2 lines
- [ ] No errors in server logs during operation
- [ ] API documentation available at `/api/legal-documents/docs`
- [ ] Complete feature removal possible by deleting legal_documents/ directory

## Anti-Patterns to Avoid

- ❌ Don't modify existing tools.py or add to available_tools
- ❌ Don't change existing database tables or add foreign keys
- ❌ Don't modify existing API endpoints in index.py
- ❌ Don't create dependencies from existing code to new module
- ❌ Don't skip error isolation - all errors must be caught
- ❌ Don't use global state or modify shared configuration
- ❌ Don't skip the health check endpoint for monitoring
- ❌ Don't forget to test rollback capability

---

**Confidence Score**: 9.5/10

This PRP provides a completely modular, backend-only implementation that operates in total isolation from the existing codebase. The approach ensures zero risk to production features while providing full legal document generation capabilities through API endpoints. The only modification to existing code is a 2-line addition to mount the router, which can be easily removed if needed.

**Validation**: The implementation creates a standalone module that can be tested, deployed, and removed independently, providing a safe path for introducing new functionality without any risk to existing features.