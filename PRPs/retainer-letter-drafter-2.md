name: "Secure AI-Powered Retainer Letter Drafter with Zero-Trust Architecture"
description: |

## Purpose

Implement a security-first, AI-powered retainer letter drafting tool for legal professionals with comprehensive data protection, encryption, audit logging, and compliance with legal industry standards including attorney-client privilege protection.

## Core Principles

1. **Security by Design**: Every component implements defense-in-depth security
2. **Zero Trust Architecture**: Never trust, always verify at every layer
3. **Data Minimization**: Collect and process only necessary information
4. **Compliance First**: Meet or exceed legal industry security standards

---

## Goal

Build a secure, AI-powered retainer letter drafting system that enables legal professionals to generate professional retainer agreements while ensuring complete protection of client data through encryption, access controls, audit logging, and compliance with attorney-client privilege requirements.

## Why

- **Client Trust**: Law firms handle highly sensitive information requiring maximum protection
- **Regulatory Compliance**: Legal industry faces strict data protection requirements (ABA Rule 1.6, GDPR, CCPA)
- **Risk Mitigation**: Prevent data breaches that could result in malpractice claims
- **Efficiency with Security**: Automate document generation without compromising confidentiality
- **Competitive Advantage**: Demonstrate commitment to client data protection

## What

A comprehensive retainer letter drafting tool with:
- End-to-end encryption for all client data
- Multi-factor authentication and role-based access control
- Real-time PII detection and masking
- Comprehensive audit logging for compliance
- Secure document storage with versioning
- Zero-trust architecture for API access
- Attorney-client privilege protection mechanisms

### Success Criteria

- [ ] All client data encrypted at rest (AES-256) and in transit (TLS 1.3)
- [ ] PII automatically detected and masked in 100% of documents
- [ ] Complete audit trail for every document access and modification
- [ ] Role-based access control with principle of least privilege
- [ ] Penetration testing passed with no critical vulnerabilities
- [ ] Compliance with ABA Model Rule 1.6 and state bar requirements
- [ ] Zero unauthorized data exposure in security testing
- [ ] Sub-200ms latency for encryption/decryption operations

## All Needed Context

### Documentation & References (list all context needed to implement the feature)

```yaml
# MUST READ - Include these in your context window
- docfile: PRPs/ai_docs/legal-security-patterns.md
  why: Comprehensive security patterns and compliance requirements for legal documents

- file: apps/web/app/api/legal-documents/firm-settings/route.ts
  why: Existing API pattern for legal document endpoints with Clerk auth

- file: apps/web/app/api/webhooks/resend/route.ts
  why: Security validation patterns and webhook signature verification

- file: api/utils/retainer_letter_generator.py
  why: Current retainer letter generation logic to enhance with security

- file: api/utils/legal_document_schemas.py
  why: Pydantic schemas with validation patterns to extend

- url: https://owasp.org/www-project-top-10-for-large-language-model-applications/
  why: OWASP Top 10 for LLM security vulnerabilities to prevent

- url: https://www.americanbar.org/groups/professional_responsibility/publications/model_rules_of_professional_conduct/rule_1_6_confidentiality_of_information/
  why: ABA Rule 1.6 requirements for client confidentiality

- doc: https://supabase.com/docs/guides/database/vault
  section: Supabase Vault for encryption
  critical: Use Vault for storing sensitive keys and PII
```

### Current Codebase Structure

```bash
apps/web/
├── app/
│   ├── api/
│   │   ├── legal-documents/
│   │   │   ├── firm-settings/route.ts    # Firm configuration endpoint
│   │   │   ├── generate/route.ts         # TO CREATE - Document generation
│   │   │   └── documents/route.ts        # TO CREATE - Document management
│   │   └── webhooks/
│   │       └── resend/route.ts           # Email webhook with security
│   ├── (app)/
│   │   └── tools/
│   │       └── legal-documents/          # TO CREATE - UI components
│   └── lib/
│       ├── security/                     # TO CREATE - Security utilities
│       └── supabase/
│           └── client.ts                  # Supabase client
api/
├── utils/
│   ├── retainer_letter_generator.py      # Retainer generation logic
│   ├── legal_document_schemas.py         # Data schemas
│   ├── security/                         # TO CREATE - Security module
│   └── audit/                            # TO CREATE - Audit logging
```

### Desired Codebase Structure with Security Components

```bash
apps/web/
├── app/
│   ├── api/
│   │   ├── legal-documents/
│   │   │   ├── firm-settings/route.ts          # Enhanced with encryption
│   │   │   ├── generate/route.ts               # Secure generation endpoint
│   │   │   ├── documents/[id]/route.ts         # Document CRUD with RBAC
│   │   │   ├── templates/route.ts              # Template management
│   │   │   └── audit/route.ts                  # Audit log access
│   │   └── middleware/
│   │       ├── security.ts                     # Security middleware
│   │       └── rate-limit.ts                   # Rate limiting
│   ├── (app)/
│   │   └── tools/
│   │       └── legal-documents/
│   │           ├── page.tsx                    # Main interface
│   │           ├── components/
│   │           │   ├── document-form.tsx       # Secure input form
│   │           │   ├── document-viewer.tsx     # Encrypted doc viewer
│   │           │   └── audit-log.tsx           # Audit trail viewer
│   │           └── hooks/
│   │               └── use-document-security.ts # Security hooks
│   └── lib/
│       ├── security/
│       │   ├── encryption.ts                   # AES-256 encryption
│       │   ├── pii-detector.ts                 # PII detection/masking
│       │   ├── sanitization.ts                 # Input sanitization
│       │   └── rbac.ts                         # Role-based access
│       └── audit/
│           └── logger.ts                       # Audit logging
api/
├── utils/
│   ├── security/
│   │   ├── encryption.py                       # Encryption utilities
│   │   ├── pii_detector.py                     # PII detection
│   │   ├── prompt_security.py                  # Prompt injection prevention
│   │   └── document_security.py                # Document access control
│   └── audit/
│       ├── audit_logger.py                     # Audit logging
│       └── compliance_checker.py               # Compliance validation
```

### Known Gotchas & Security Requirements

```python
# CRITICAL: Attorney-client privilege must be preserved
# - All communications marked as privileged
# - Separate storage for privileged vs non-privileged
# - Access logging for compliance

# CRITICAL: PII must be encrypted with field-level encryption
# - SSN, DOB, financial info require extra protection
# - Use Supabase Vault for key management
# - Implement key rotation every 90 days

# CRITICAL: Zero-trust API access
# - Validate JWT on every request
# - Check permissions for each resource
# - Rate limit by user and IP

# CRITICAL: Audit logging requirements
# - Log all document access attempts
# - Include timestamp, user, IP, action, result
# - Immutable audit logs (write-only)
# - Retain for 7 years minimum

# CRITICAL: Input validation
# - Sanitize all user inputs for XSS/injection
# - Validate against schema before processing
# - Reject requests with suspicious patterns
```

## Implementation Blueprint

### Data Models and Security Schema

```typescript
// Database schema with security columns
interface RetainerDocument {
  id: string;
  user_id: string;
  client_id: string;
  
  // Encrypted fields (using Supabase Vault)
  client_name_encrypted: string;
  client_email_encrypted: string;
  client_phone_encrypted: string;
  client_address_encrypted: string;
  
  // Document data
  document_type: 'retainer_letter';
  matter_type: string;
  jurisdiction: string;
  
  // Security metadata
  encryption_key_id: string;
  classification: 'public' | 'internal' | 'confidential' | 'highly_restricted';
  privileged: boolean;
  
  // Versioning
  version: number;
  previous_version_id?: string;
  
  // Access control
  access_control: {
    owner: string;
    shared_with: string[];
    permissions: Record<string, string[]>;
  };
  
  // Audit fields
  created_at: string;
  created_by: string;
  updated_at: string;
  updated_by: string;
  accessed_at: string;
  accessed_by: string[];
  
  // Compliance
  retention_date: string;
  legal_hold: boolean;
  compliance_flags: string[];
}

// Audit log schema
interface AuditLog {
  id: string;
  timestamp: string;
  user_id: string;
  user_email: string;
  ip_address: string;
  user_agent: string;
  
  // Event details
  event_type: 'create' | 'read' | 'update' | 'delete' | 'share' | 'download';
  resource_type: 'document' | 'template' | 'settings';
  resource_id: string;
  
  // Security context
  authentication_method: string;
  session_id: string;
  api_key_id?: string;
  
  // Action details
  action: string;
  result: 'success' | 'failure' | 'unauthorized';
  error_message?: string;
  
  // Data changes (encrypted)
  changes_encrypted?: string;
  
  // Risk assessment
  risk_score: number;
  anomaly_flags: string[];
  
  // Compliance
  compliance_relevant: boolean;
  retention_required: boolean;
}
```

### List of Implementation Tasks

```yaml
Task 1: Database Schema and Security Setup
LOCATION: supabase/migrations/
  - CREATE new migration for retainer_documents table with encrypted fields
  - ENABLE Row Level Security (RLS) with user-based policies
  - CREATE audit_logs table with write-only permissions
  - SETUP Supabase Vault for encryption key management
  - CREATE indexes for performance on encrypted lookups

Task 2: Security Utilities Module
CREATE apps/web/lib/security/encryption.ts:
  - IMPLEMENT AES-256-GCM encryption/decryption functions
  - CREATE field-level encryption for PII fields
  - INTEGRATE with Supabase Vault for key management
  - ADD key rotation mechanism with versioning

CREATE apps/web/lib/security/pii-detector.ts:
  - IMPLEMENT regex patterns for PII detection
  - INTEGRATE with AI-based PII detection service
  - CREATE masking functions for different PII types
  - ADD configurable sensitivity levels

CREATE apps/web/lib/security/sanitization.ts:
  - IMPLEMENT input sanitization for XSS prevention
  - CREATE SQL injection prevention utilities
  - ADD prompt injection detection patterns
  - VALIDATE all inputs against schemas

Task 3: Audit Logging System
CREATE apps/web/lib/audit/logger.ts:
  - IMPLEMENT audit event capture
  - CREATE immutable logging to audit_logs table
  - ADD correlation IDs for request tracking
  - INTEGRATE with monitoring/alerting system

CREATE api/utils/audit/audit_logger.py:
  - MIRROR TypeScript audit logging in Python
  - ADD backend-specific audit events
  - IMPLEMENT log aggregation for analysis
  - CREATE compliance report generation

Task 4: Role-Based Access Control
CREATE apps/web/lib/security/rbac.ts:
  - DEFINE roles: admin, attorney, paralegal, client
  - IMPLEMENT permission checking middleware
  - CREATE document-level access control
  - ADD delegation and sharing mechanisms

MODIFY apps/web/app/api/middleware/security.ts:
  - ADD RBAC checks to all endpoints
  - IMPLEMENT rate limiting per role
  - CREATE IP allowlisting for sensitive operations
  - ADD multi-factor authentication checks

Task 5: Secure Document Generation API
CREATE apps/web/app/api/legal-documents/generate/route.ts:
  - IMPLEMENT secure document generation endpoint
  - ADD input validation and sanitization
  - ENCRYPT sensitive fields before storage
  - CREATE audit trail for generation
  - INTEGRATE with PDF generation service

MODIFY api/utils/retainer_letter_generator.py:
  - ADD PII detection before generation
  - IMPLEMENT prompt injection prevention
  - CREATE secure template system
  - ADD compliance validation checks

Task 6: Document Management with Security
CREATE apps/web/app/api/legal-documents/documents/[id]/route.ts:
  - IMPLEMENT CRUD operations with RBAC
  - ADD version control for documents
  - CREATE secure sharing mechanism
  - IMPLEMENT secure deletion (cryptographic erasure)

CREATE apps/web/app/api/legal-documents/templates/route.ts:
  - MANAGE document templates securely
  - ADD template versioning
  - IMPLEMENT approval workflow
  - CREATE template access control

Task 7: Frontend Security Components
CREATE apps/web/app/(app)/tools/legal-documents/components/document-form.tsx:
  - BUILD secure input form with validation
  - ADD client-side PII detection warnings
  - IMPLEMENT secure file upload
  - CREATE progress indicators for security checks

CREATE apps/web/app/(app)/tools/legal-documents/components/document-viewer.tsx:
  - BUILD encrypted document viewer
  - ADD watermarking for confidential docs
  - IMPLEMENT print/download controls
  - CREATE audit trail visibility

Task 8: Security Testing and Validation
CREATE apps/web/tests/security/:
  - WRITE penetration test scenarios
  - ADD SQL injection tests
  - CREATE XSS prevention tests
  - IMPLEMENT authentication bypass tests
  - ADD rate limiting tests

CREATE api/tests/security/:
  - WRITE prompt injection tests
  - ADD PII leakage detection tests
  - CREATE encryption validation tests
  - IMPLEMENT access control tests

Task 9: Compliance and Monitoring
CREATE apps/web/app/api/legal-documents/audit/route.ts:
  - BUILD audit log viewing endpoint
  - ADD compliance reporting
  - CREATE anomaly detection
  - IMPLEMENT retention policy enforcement

CREATE monitoring/security-dashboard:
  - SETUP real-time security monitoring
  - ADD failed authentication alerts
  - CREATE PII detection metrics
  - IMPLEMENT compliance KPI tracking

Task 10: Documentation and Training
CREATE docs/security/:
  - WRITE security architecture documentation
  - CREATE incident response procedures
  - ADD security best practices guide
  - DEVELOP training materials for users
```

### Per-Task Implementation Details

```python
# Task 2: PII Detection Implementation
# apps/web/lib/security/pii-detector.ts

interface PIIDetectionResult {
  hasPII: boolean;
  categories: string[];
  locations: Array<{
    type: string;
    value: string;
    start: number;
    end: number;
    confidence: number;
  }>;
  maskedText: string;
}

async function detectPII(text: string): Promise<PIIDetectionResult> {
  // Step 1: Regex-based detection for common patterns
  const patterns = {
    ssn: /\b\d{3}-\d{2}-\d{4}\b/g,
    email: /\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b/g,
    phone: /\b\d{3}[-.]?\d{3}[-.]?\d{4}\b/g,
    creditCard: /\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b/g,
    // Add more patterns
  };
  
  // Step 2: AI-based detection for context-aware PII
  const aiDetection = await callPIIDetectionAPI(text);
  
  // Step 3: Combine results and generate masked version
  const maskedText = applyMasking(text, detectedPII);
  
  // Step 4: Calculate risk score
  const riskScore = calculatePIIRisk(detectedPII);
  
  return {
    hasPII: detectedPII.length > 0,
    categories: [...new Set(detectedPII.map(p => p.type))],
    locations: detectedPII,
    maskedText,
    riskScore
  };
}

# Task 5: Secure Document Generation
# apps/web/app/api/legal-documents/generate/route.ts

async function generateSecureDocument(request: NextRequest) {
  // Step 1: Authenticate and authorize
  const { userId, role } = await authenticateRequest(request);
  if (!canGenerateDocuments(role)) {
    return unauthorizedResponse();
  }
  
  // Step 2: Validate and sanitize input
  const sanitizedInput = await validateAndSanitize(request.body);
  
  // Step 3: Detect PII in input
  const piiResult = await detectPII(sanitizedInput.content);
  
  // Step 4: Encrypt sensitive fields
  const encryptedData = await encryptSensitiveFields(sanitizedInput, userId);
  
  // Step 5: Generate document with AI
  const document = await generateWithSecurity(encryptedData);
  
  // Step 6: Validate output for compliance
  const compliance = await validateCompliance(document);
  
  // Step 7: Store with audit trail
  const stored = await storeSecurely(document, userId);
  await auditLog('document_generated', userId, stored.id);
  
  // Step 8: Return encrypted response
  return encryptedResponse(stored);
}
```

### Integration Points

```yaml
DATABASE:
  - migration: "Create retainer_documents table with encrypted columns"
  - migration: "Create audit_logs table with write-only RLS"
  - migration: "Add encryption_keys table for key rotation"
  - index: "CREATE INDEX idx_audit_user_timestamp ON audit_logs(user_id, timestamp)"
  - index: "CREATE INDEX idx_documents_classification ON retainer_documents(classification)"

SUPABASE_VAULT:
  - setup: "Enable Vault extension"
  - create: "Master encryption key for document encryption"
  - create: "Separate keys for PII field encryption"
  - policy: "Key rotation every 90 days"

CONFIG:
  - add to: apps/web/lib/env.ts
  - variables: "ENCRYPTION_KEY_ID, PII_DETECTION_API_KEY, AUDIT_RETENTION_DAYS"
  - pattern: "Security config with validation"

MIDDLEWARE:
  - add to: apps/web/middleware.ts
  - security: "Rate limiting, IP filtering, security headers"
  - pattern: "Apply to all /api/legal-documents/* routes"

MONITORING:
  - service: "Datadog or New Relic for security monitoring"
  - alerts: "Failed auth, PII detection, anomaly detection"
  - dashboard: "Security KPIs and compliance metrics"
```

## Validation Loop

### Level 1: Security Linting and Static Analysis

```bash
# Security scanning with multiple tools
npm audit --audit-level=moderate              # Check dependencies
npx snyk test                                 # Vulnerability scanning
npx eslint --ext .ts,.tsx apps/web/ --fix    # Security linting

# Python security scanning
poetry run bandit -r api/                     # Security issues in Python
poetry run safety check                       # Dependency vulnerabilities

# Expected: No high/critical vulnerabilities
```

### Level 2: Unit Tests for Security Components

```typescript
// Test encryption/decryption
describe('Encryption Module', () => {
  test('encrypts and decrypts PII correctly', async () => {
    const plaintext = 'SSN: 123-45-6789';
    const encrypted = await encrypt(plaintext);
    const decrypted = await decrypt(encrypted);
    expect(decrypted).toBe(plaintext);
    expect(encrypted).not.toContain('123-45-6789');
  });
  
  test('different keys produce different ciphertext', async () => {
    const plaintext = 'sensitive data';
    const encrypted1 = await encrypt(plaintext, key1);
    const encrypted2 = await encrypt(plaintext, key2);
    expect(encrypted1).not.toBe(encrypted2);
  });
});

// Test PII detection
describe('PII Detector', () => {
  test('detects common PII patterns', async () => {
    const text = 'Email john@example.com, SSN 123-45-6789';
    const result = await detectPII(text);
    expect(result.hasPII).toBe(true);
    expect(result.categories).toContain('email');
    expect(result.categories).toContain('ssn');
  });
  
  test('masks PII correctly', async () => {
    const text = 'Call me at 555-123-4567';
    const result = await detectPII(text);
    expect(result.maskedText).toBe('Call me at [PHONE_REDACTED]');
  });
});

// Test RBAC
describe('Role-Based Access Control', () => {
  test('attorney can create documents', async () => {
    const canCreate = await checkPermission('attorney', 'document', 'create');
    expect(canCreate).toBe(true);
  });
  
  test('client cannot edit documents', async () => {
    const canEdit = await checkPermission('client', 'document', 'edit');
    expect(canEdit).toBe(false);
  });
});
```

```bash
# Run security-focused tests
pnpm test:security --coverage
pytest api/tests/security/ -v --cov

# Expected: 100% test coverage for security modules
```

### Level 3: Integration Security Tests

```bash
# Test secure document generation flow
curl -X POST http://localhost:3000/api/legal-documents/generate \
  -H "Authorization: Bearer $VALID_JWT" \
  -H "Content-Type: application/json" \
  -d '{
    "client_email": "client@example.com",
    "email_content": "Need help with contract dispute. My SSN is 123-45-6789.",
    "matter_type": "contract_dispute"
  }'

# Expected: 
# - 200 OK with encrypted response
# - SSN detected and masked in stored document
# - Audit log entry created
# - No PII in response

# Test unauthorized access
curl -X GET http://localhost:3000/api/legal-documents/documents/123 \
  -H "Authorization: Bearer $INVALID_JWT"

# Expected: 401 Unauthorized

# Test rate limiting
for i in {1..100}; do
  curl -X POST http://localhost:3000/api/legal-documents/generate \
    -H "Authorization: Bearer $VALID_JWT" \
    -d '{"test": "data"}'
done

# Expected: 429 Too Many Requests after limit
```

### Level 4: Penetration Testing

```bash
# OWASP ZAP automated security testing
docker run -t owasp/zap2docker-stable zap-baseline.py \
  -t http://localhost:3000 \
  -r security-report.html

# SQL injection testing
sqlmap -u "http://localhost:3000/api/legal-documents/documents?id=1" \
  --batch --random-agent

# XSS testing
python3 XSStrike.py -u "http://localhost:3000/api/legal-documents/search" \
  --data "query=test"

# Prompt injection testing
python3 test_prompt_injection.py \
  --endpoint "http://localhost:8000/api/generate" \
  --payloads "prompt_injection_payloads.txt"

# Expected: No critical or high vulnerabilities found
```

### Level 5: Compliance Validation

```python
# Compliance checker script
async def validate_compliance():
    # Check encryption at rest
    assert all_pii_fields_encrypted()
    
    # Check audit logging
    assert audit_logs_immutable()
    assert audit_retention_policy_enforced()
    
    # Check access controls
    assert rbac_properly_configured()
    assert least_privilege_enforced()
    
    # Check data retention
    assert retention_policies_applied()
    assert secure_deletion_working()
    
    # Check attorney-client privilege
    assert privileged_communications_protected()
    assert privilege_markers_preserved()
    
    print("✅ All compliance checks passed")

# Run compliance validation
python3 scripts/validate_compliance.py
```

## Final Validation Checklist

- [ ] All PII fields encrypted with AES-256: `pnpm test:encryption`
- [ ] Audit logs created for all operations: `pnpm test:audit`
- [ ] RBAC working correctly: `pnpm test:rbac`
- [ ] No SQL injection vulnerabilities: `sqlmap scan clean`
- [ ] No XSS vulnerabilities: `XSStrike scan clean`
- [ ] No prompt injection vulnerabilities: `python test_prompt_injection.py`
- [ ] Rate limiting working: `pnpm test:rate-limit`
- [ ] Penetration test passed: `OWASP ZAP report clean`
- [ ] Compliance validation passed: `python validate_compliance.py`
- [ ] Performance within limits: `encryption < 200ms`
- [ ] Security monitoring active: `check monitoring dashboard`
- [ ] Incident response plan tested: `tabletop exercise completed`
- [ ] Documentation complete: `security guide published`

---

## Anti-Patterns to Avoid

- ❌ Don't store PII in plain text - always encrypt
- ❌ Don't trust client input - always validate and sanitize
- ❌ Don't skip audit logging - required for compliance
- ❌ Don't use weak encryption - AES-256 minimum
- ❌ Don't ignore security warnings - fix immediately
- ❌ Don't bypass RBAC - enforce at every layer
- ❌ Don't log sensitive data - mask PII in logs
- ❌ Don't reuse encryption keys - implement rotation
- ❌ Don't allow unlimited requests - implement rate limiting
- ❌ Don't forget about insider threats - monitor all access

## Security Incident Response

In case of security incident:
1. **Isolate** affected systems immediately
2. **Notify** security team and legal counsel
3. **Preserve** evidence and audit logs
4. **Analyze** root cause and impact
5. **Remediate** vulnerability
6. **Notify** affected clients within 72 hours
7. **Document** lessons learned
8. **Update** security measures

## Success Metrics

- Zero data breaches
- 100% PII encryption coverage
- < 200ms encryption latency
- 100% audit log completeness
- Zero critical vulnerabilities in pentests
- Full compliance with legal requirements
- 99.9% availability with security enabled