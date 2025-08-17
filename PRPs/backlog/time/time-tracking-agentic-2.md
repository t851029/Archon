name: "Time Tracking Agentic - Security-First Implementation"
description: |

## Purpose

AI-powered time tracking assistant that securely scans sent emails for billable time mentions using OpenAI function calling patterns. Emphasizes security-by-design, data protection, and compliance with privacy regulations.

## Core Security Principles

1. **Zero Trust Architecture**: Every request authenticated and authorized
2. **Data Minimization**: Process only necessary email content
3. **Encryption Everywhere**: Data encrypted in transit and at rest
4. **Audit Everything**: Comprehensive logging and monitoring
5. **Principle of Least Privilege**: Minimal required permissions only

---

## Goal

Build a secure time tracking AI assistant that integrates with the existing OpenAI function calling architecture to analyze sent emails for billable time mentions while maintaining strict security controls, data protection, and privacy compliance.

## Why

### Business Value

- **Automated Time Capture**: Reduces manual time entry by 80-90%
- **Revenue Recovery**: Captures missed billable time from email communications
- **Compliance Assurance**: Built-in audit trails for billing transparency
- **Client Trust**: Demonstrates security-first approach to sensitive data

### User Impact

- **Effortless Tracking**: Time entries auto-generated from natural email communication
- **Privacy Protected**: Only authorized users access their own time data
- **Transparent Processing**: Clear visibility into what data is analyzed and why

### Integration Benefits

- **Existing Auth**: Leverages proven Clerk JWT validation patterns
- **Tool Architecture**: Seamlessly integrates with current OpenAI function calling system
- **Security Foundation**: Built on established security patterns in the codebase

## What

### User-Visible Behavior

- AI assistant suggests time entries based on sent email analysis
- Users can approve, modify, or reject suggested time entries
- Real-time privacy controls for email scanning scope
- Comprehensive audit trail of all time tracking activities

### Technical Requirements

- **Security-First Design**: All components designed with security controls from inception
- **GDPR Compliance**: Full data subject rights support (access, rectification, erasure, portability)
- **Encrypted Storage**: All time tracking data encrypted at rest
- **Access Controls**: Role-based access with fine-grained permissions
- **Audit Logging**: Comprehensive activity logging for compliance and forensics

### Success Criteria

#### Security Criteria

- [ ] All authentication verified through Clerk JWT validation
- [ ] Input sanitization prevents injection attacks on 100% of parameters
- [ ] Data encryption implemented for all sensitive data at rest and in transit
- [ ] Security audit logging captures 100% of time tracking operations
- [ ] Vulnerability assessment shows zero critical or high-severity issues

#### Functional Criteria

- [ ] AI tools registered in available_tools dictionary and callable via OpenAI chat API
- [ ] Time entries extracted from sent emails with >90% accuracy
- [ ] GDPR compliance demonstrated through data subject rights implementation
- [ ] Performance under 2 seconds for time analysis of typical email batch
- [ ] Integration tests pass for all security controls

#### Privacy Criteria

- [ ] User consent mechanisms for email scanning implemented
- [ ] Data retention policies enforced automatically
- [ ] Right to erasure functional within 30 days of request
- [ ] Data minimization validated - only necessary email content processed

## All Needed Context

### Documentation & References

```yaml
# MUST READ - Include these in your context window
- file: /home/jron/wsl_project/jerin-lt-139-time-reviewer-tool/api/core/auth.py
  why: Secure JWT validation patterns with Clerk SDK

- file: /home/jron/wsl_project/jerin-lt-139-time-reviewer-tool/api/core/dependencies.py
  why: Dependency injection patterns for auth and service clients

- file: /home/jron/wsl_project/jerin-lt-139-time-reviewer-tool/api/utils/tools.py
  why: Existing OpenAI function calling patterns and tool structure

- file: /home/jron/wsl_project/jerin-lt-139-time-reviewer-tool/api/index.py
  why: available_tools registration and OpenAI integration patterns

- file: /home/jron/wsl_project/jerin-lt-139-time-reviewer-tool/api/core/config.py
  why: Security configuration patterns and environment validation

- doc: https://platform.openai.com/docs/guides/safety-best-practices
  section: Function calling security
  critical: Input validation and tool security patterns

- doc: https://gdpr.eu/checklist/
  section: Data processing compliance
  critical: Legal requirements for personal data processing

- doc: https://owasp.org/www-project-top-ten/
  section: Application Security Risks
  critical: Prevention of common vulnerabilities
```

### Current Codebase Tree

```bash
api/
├── core/
│   ├── auth.py              # Secure Clerk JWT validation
│   ├── dependencies.py      # Auth dependency injection
│   └── config.py           # Security configuration
├── utils/
│   ├── tools.py            # OpenAI function calling tools
│   ├── email_schemas.py    # Pydantic validation schemas
│   └── gmail_helpers.py    # Gmail API integration
├── index.py                # Main FastAPI app with available_tools
└── tests/                  # Security and integration tests
```

### Desired Codebase Tree with Security Additions

```bash
api/
├── core/
│   ├── auth.py              # [Enhanced] Additional security validations
│   ├── dependencies.py      # [Enhanced] Time tracking auth dependencies
│   ├── config.py           # [Enhanced] Time tracking security config
│   └── security.py         # [NEW] Security utilities and encryption
├── utils/
│   ├── tools.py            # [Enhanced] New time tracking tools
│   ├── email_schemas.py    # [Enhanced] Time tracking schemas
│   ├── time_tracking.py    # [NEW] Core time tracking logic
│   └── audit_logger.py     # [NEW] Security audit logging
├── models/
│   └── time_entries.py     # [NEW] Time tracking data models
├── tests/
│   ├── test_time_security.py  # [NEW] Security-focused tests
│   └── test_time_compliance.py # [NEW] GDPR compliance tests
└── migrations/
    └── add_time_tracking.sql   # [NEW] Database schema with encryption
```

### Known Security Gotchas & Library Quirks

```python
# CRITICAL: Clerk JWT validation requires exact Request object format
# Example: Must use verify_clerk_jwt() from core.auth, not manual JWT parsing

# CRITICAL: OpenAI function calls can be manipulated by prompt injection
# Example: Always validate tool parameters independently of LLM output

# CRITICAL: Gmail API tokens expire and need refresh handling
# Example: Implement token refresh logic with proper error handling

# CRITICAL: Supabase service role keys must be in exact JWT format
# Example: Must start with 'eyJ' and have exactly 3 parts separated by dots

# CRITICAL: Email content may contain PII requiring special handling
# Example: Implement data classification before processing

# CRITICAL: GDPR requires explicit consent for email scanning
# Example: Must implement consent management before processing any emails

# SECURITY: Rate limiting required for AI tool calls to prevent abuse
# Example: Implement per-user rate limits for time tracking operations

# SECURITY: All user inputs must be sanitized before database operations
# Example: Use Pydantic validators and parameterized queries exclusively
```

## Implementation Blueprint

### Data Models and Security Structure

Create secure, encrypted data models ensuring type safety, data protection, and audit trails.

```python
# Time Tracking Security Models
class TimeEntryModel(BaseModel):
    """Encrypted time entry with audit trail"""
    id: UUID4
    user_id: str  # Clerk user ID
    email_id: str  # Gmail message ID (encrypted)
    description: str  # Encrypted billable description
    hours: Decimal  # Precise time tracking
    date: datetime
    client_name: Optional[str] = None  # Encrypted if present
    project_code: Optional[str] = None
    billing_rate: Optional[Decimal] = None  # Encrypted
    confidence_score: float  # AI extraction confidence
    status: TimeEntryStatus = TimeEntryStatus.PENDING
    created_at: datetime
    updated_at: datetime
    audit_trail: List[AuditEvent]  # All modifications logged

class TimeTrackingConfig(BaseModel):
    """User privacy and scanning preferences"""
    user_id: str
    email_scanning_enabled: bool = False
    consent_date: Optional[datetime] = None
    data_retention_days: int = 90  # GDPR compliance
    allowed_senders: List[str] = []  # Whitelist for scanning
    excluded_keywords: List[str] = []  # Privacy exclusions
    billing_rates: Dict[str, Decimal] = {}  # Encrypted rates
```

### Security-Focused Task List

```yaml
Task 1 - Security Foundation:
CREATE api/core/security.py:
  - IMPLEMENT encryption/decryption utilities using Fernet
  - ADD data classification functions for PII detection
  - CREATE secure parameter validation helpers
  - PATTERN: Follow existing config.py structure for consistency

CREATE api/utils/audit_logger.py:
  - IMPLEMENT comprehensive audit logging for all time tracking operations
  - ADD structured logging with user_id, action, timestamp, IP address
  - PRESERVE existing logging patterns from utils/tools.py
  - CRITICAL: Never log sensitive data (email content, billing rates)

Task 2 - Data Models with Encryption:
CREATE api/models/time_entries.py:
  - IMPLEMENT encrypted TimeEntry model with Pydantic validation
  - ADD audit trail functionality for all data modifications
  - CREATE user consent and configuration models
  - PATTERN: Mirror existing email_schemas.py validation patterns
  - CRITICAL: Encrypt all PII fields before database storage

Task 3 - Secure Authentication Dependencies:
MODIFY api/core/dependencies.py:
  - ADD get_time_tracking_user() dependency with enhanced validation
  - IMPLEMENT user consent verification before any email access
  - CREATE rate limiting dependency for time tracking operations
  - PRESERVE existing JWT validation patterns

Task 4 - AI Tool Security Implementation:
MODIFY api/utils/tools.py:
  - ADD scan_billable_time() tool with input sanitization
  - ADD analyze_time_entry() tool with content filtering
  - ADD get_time_tracking_summary() tool with access controls
  - ADD configure_time_tracking() tool with permission validation
  - PATTERN: Follow existing triage_emails() structure
  - CRITICAL: Validate all AI tool parameters independently

Task 5 - Database Security:
CREATE api/migrations/add_time_tracking_encrypted.sql:
  - CREATE time_entries table with encryption for sensitive fields
  - CREATE time_tracking_config table for user preferences
  - CREATE audit_log table for comprehensive activity tracking
  - ADD indexes for performance while maintaining security
  - PATTERN: Follow existing migration patterns

Task 6 - GDPR Compliance Features:
CREATE api/utils/gdpr_compliance.py:
  - IMPLEMENT data subject rights (access, rectification, erasure, portability)
  - ADD automated data retention enforcement
  - CREATE consent management functions
  - ADD data breach notification mechanisms

Task 7 - Security Testing Suite:
CREATE api/tests/test_time_security.py:
  - TEST authentication bypass attempts
  - TEST SQL injection prevention
  - TEST unauthorized access scenarios
  - TEST encryption/decryption functionality
  - PATTERN: Follow existing test structure

CREATE api/tests/test_gdpr_compliance.py:
  - TEST data subject rights implementation
  - TEST consent management flows
  - TEST data retention policy enforcement
  - TEST breach notification procedures
```

### Per Task Security Pseudocode

```python
# Task 4 - AI Tool Security Implementation
async def scan_billable_time(
    params: ScanBillableTimeParams,
    service: Resource = Depends(get_gmail_service),
    openai_client: OpenAI = Depends(get_openai_client),
    user_id: str = Depends(get_time_tracking_user),  # Enhanced auth
    supabase_client: Client = Depends(get_supabase_client),
    audit_logger: AuditLogger = Depends(get_audit_logger),
) -> SecureTimeTrackingResult:
    """
    Securely scan sent emails for billable time with comprehensive security controls.
    """
    # SECURITY: Audit log the request with minimal necessary data
    await audit_logger.log_time_tracking_request(
        user_id=user_id,
        action="scan_billable_time",
        params_hash=hash_params(params),  # Hash, don't log raw params
        ip_address=get_client_ip(request)
    )

    # SECURITY: Validate user consent before processing
    consent = await verify_user_consent(user_id, supabase_client)
    if not consent.email_scanning_enabled:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Email scanning not enabled. Please enable in settings."
        )

    # SECURITY: Rate limiting to prevent abuse
    await enforce_rate_limit(user_id, "time_tracking", max_requests=10)

    # SECURITY: Input validation and sanitization
    validated_params = validate_and_sanitize_params(params)

    # SECURITY: Scope limiting - only sent emails, only consented timeframe
    email_filter = build_secure_email_filter(
        user_consent=consent,
        base_query="in:sent",
        max_age_days=consent.data_retention_days
    )

    try:
        # PATTERN: Use existing Gmail patterns with additional security
        sent_emails = await get_filtered_emails(
            service=service,
            query=email_filter,
            max_results=min(validated_params.max_emails, 50)  # Hard limit
        )

        # SECURITY: Content filtering before AI processing
        filtered_emails = []
        for email in sent_emails:
            # Remove PII not relevant to time tracking
            filtered_content = filter_email_content(
                email,
                allowed_patterns=["hours", "time", "meeting", "call", "work"],
                excluded_patterns=consent.excluded_keywords
            )

            # Data classification - skip if contains sensitive data
            if classify_data_sensitivity(filtered_content) > SensitivityLevel.MEDIUM:
                continue

            filtered_emails.append(filtered_content)

        # SECURITY: AI processing with sanitized, minimal data
        time_entries = []
        for email in filtered_emails:
            # CRITICAL: Validate AI response independently
            ai_response = await openai_client.chat.completions.create(
                model="gpt-4",
                messages=[
                    {"role": "system", "content": TIME_EXTRACTION_SYSTEM_PROMPT},
                    {"role": "user", "content": email.filtered_content}
                ],
                tools=[time_extraction_tool_schema],
                max_tokens=500  # Limit response size
            )

            # SECURITY: Validate and sanitize AI output
            extracted_time = validate_ai_time_extraction(ai_response)
            if extracted_time:
                # Encrypt sensitive fields before storage
                encrypted_entry = encrypt_time_entry(extracted_time, user_id)
                time_entries.append(encrypted_entry)

        # SECURITY: Store with audit trail
        stored_entries = await store_time_entries_secure(
            time_entries, user_id, supabase_client
        )

        # SECURITY: Success audit log
        await audit_logger.log_time_tracking_success(
            user_id=user_id,
            action="scan_billable_time",
            entries_count=len(stored_entries),
            emails_processed=len(filtered_emails)
        )

        return SecureTimeTrackingResult(
            entries=stored_entries,
            processed_count=len(filtered_emails),
            extracted_count=len(time_entries)
        )

    except Exception as e:
        # SECURITY: Error audit log without sensitive details
        await audit_logger.log_time_tracking_error(
            user_id=user_id,
            action="scan_billable_time",
            error_type=type(e).__name__,
            # Don't log full error message - may contain sensitive data
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An error occurred during time tracking analysis"
        )
```

### Integration Points

```yaml
SECURITY_CONFIG:
  - add to: api/core/config.py
  - pattern: "TIME_TRACKING_ENCRYPTION_KEY = os.getenv('TIME_TRACKING_ENCRYPTION_KEY')"
  - validation: Key rotation policy and secure key storage

DATABASE_SECURITY:
  - migration: "Add encrypted time_entries table with audit triggers"
  - encryption: "Encrypt PII fields: description, client_name, billing_rate"
  - indexes: "CREATE INDEX CONCURRENTLY idx_time_entries_user_date ON time_entries(user_id, date)"

API_SECURITY:
  - add to: api/index.py
  - pattern: "available_tools['scan_billable_time'] = scan_billable_time"
  - middleware: Rate limiting and request validation middleware

COMPLIANCE:
  - gdpr: "Implement data subject rights endpoints"
  - audit: "Comprehensive activity logging for all operations"
  - retention: "Automated data cleanup after retention period"
```

## Security Validation Loop

### Level 1: Security Syntax & Configuration

```bash
# SECURITY: Validate encryption key configuration
python -c "from api.core.config import settings; assert settings.TIME_TRACKING_ENCRYPTION_KEY"

# SECURITY: Check for hardcoded secrets
ruff check api/ --select S --fix  # Security-specific linting
semgrep --config=p/owasp-top-ten api/  # OWASP security scanning

# SECURITY: Type checking for security-critical functions
mypy api/core/security.py api/utils/time_tracking.py

# Expected: No security warnings or hardcoded credentials
```

### Level 2: Security Unit Tests

```python
# CREATE api/tests/test_time_security.py with comprehensive security tests:

def test_authentication_required():
    """All time tracking endpoints require valid JWT"""
    response = client.post("/api/time-tracking/scan", headers={})
    assert response.status_code == 401

def test_input_sanitization():
    """SQL injection attempts are blocked"""
    malicious_input = "'; DROP TABLE time_entries; --"
    result = sanitize_time_params(malicious_input)
    assert "DROP" not in result
    assert ";" not in result

def test_encryption_decryption():
    """Sensitive data is encrypted/decrypted correctly"""
    original = "Client ABC - 2.5 hours consultation"
    encrypted = encrypt_field(original, test_key)
    assert encrypted != original
    assert decrypt_field(encrypted, test_key) == original

def test_user_isolation():
    """Users can only access their own time entries"""
    with pytest.raises(HTTPException) as exc_info:
        get_time_entries(user_id="user1", requesting_user="user2")
    assert exc_info.value.status_code == 403

def test_rate_limiting():
    """Rate limiting prevents abuse"""
    for i in range(11):  # Exceed limit of 10
        if i < 10:
            response = client.post("/api/time-tracking/scan", headers=auth_headers)
            assert response.status_code in [200, 201]
        else:
            response = client.post("/api/time-tracking/scan", headers=auth_headers)
            assert response.status_code == 429

def test_gdpr_data_erasure():
    """User data can be completely erased"""
    # Create test data
    create_time_entries(user_id="test_user")

    # Erase data
    erase_user_data("test_user")

    # Verify erasure
    entries = get_time_entries("test_user")
    assert len(entries) == 0

def test_audit_logging():
    """All operations are properly audited"""
    initial_count = count_audit_logs("test_user")

    scan_billable_time(test_params, user_id="test_user")

    final_count = count_audit_logs("test_user")
    assert final_count > initial_count
```

```bash
# Run security tests specifically:
pytest api/tests/test_time_security.py -v
pytest api/tests/test_gdpr_compliance.py -v

# Expected: All security tests pass, no data leakage
```

### Level 3: Integration Security Testing

```bash
# Start service with security configurations
uvicorn api.index:app --reload --port 8000

# Test authenticated time tracking
curl -X POST http://localhost:8000/api/time-tracking/scan \
  -H "Authorization: Bearer $VALID_JWT" \
  -H "Content-Type: application/json" \
  -d '{"max_emails": 10, "since_hours": 24}'

# Expected: {"status": "success", "entries": [...], "processed_count": N}

# Test unauthorized access (should fail)
curl -X POST http://localhost:8000/api/time-tracking/scan \
  -H "Content-Type: application/json" \
  -d '{"max_emails": 10}'

# Expected: {"detail": "Not authenticated", "status_code": 401}

# Test rate limiting
for i in {1..12}; do
  curl -X POST http://localhost:8000/api/time-tracking/scan \
    -H "Authorization: Bearer $VALID_JWT" \
    -H "Content-Type: application/json" \
    -d '{"max_emails": 1}' &
done
wait

# Expected: First 10 succeed, remaining 2 return 429 Too Many Requests
```

### Level 4: Security Penetration Testing

```bash
# OWASP ZAP automated security scan
docker run -t owasp/zap2docker-stable zap.sh -daemon -port 8080 -host 0.0.0.0 \
  -config api.addrs.addr.name=0.0.0.0 -config api.addrs.addr.regex=true

# Burp Suite API security testing
burp_enterprise_edition --project-file=time_tracking_security.burp \
  --start-url=http://localhost:8000/api/time-tracking/

# Custom security validation
python security_validation_script.py --target=http://localhost:8000 \
  --test-injection --test-auth --test-encryption

# Expected: No critical or high severity vulnerabilities found
```

## Final Security Validation Checklist

### Authentication & Authorization

- [ ] All endpoints require valid Clerk JWT: `pytest api/tests/test_auth_required.py`
- [ ] User isolation enforced: `pytest api/tests/test_user_isolation.py`
- [ ] Rate limiting functional: `pytest api/tests/test_rate_limiting.py`
- [ ] Permission checks implemented: `curl -X GET /api/time-tracking/admin` (should fail)

### Data Protection

- [ ] Encryption at rest verified: `pytest api/tests/test_encryption.py`
- [ ] Input sanitization working: `pytest api/tests/test_input_validation.py`
- [ ] PII detection functional: `pytest api/tests/test_pii_detection.py`
- [ ] Data classification accurate: `python validate_data_classification.py`

### Security Controls

- [ ] No secrets in code: `git secrets --scan`
- [ ] OWASP Top 10 coverage: `semgrep --config=p/owasp-top-ten api/`
- [ ] Vulnerability scan clean: `safety check --json`
- [ ] Security headers present: `curl -I http://localhost:8000/api/health`

### Compliance & Audit

- [ ] GDPR rights implemented: `pytest api/tests/test_gdpr_compliance.py`
- [ ] Audit logging comprehensive: `python validate_audit_coverage.py`
- [ ] Data retention enforced: `pytest api/tests/test_data_retention.py`
- [ ] Breach notification ready: `python test_breach_notification.py`

### Performance & Reliability

- [ ] Response time under 2s: `python load_test_time_tracking.py`
- [ ] Handles malformed input: `python fuzz_test_inputs.py`
- [ ] Error handling secure: `python test_error_information_disclosure.py`
- [ ] Monitoring dashboards: `curl http://localhost:8000/api/time-tracking/metrics`

---

## Security Anti-Patterns to Avoid

### Data Security

- ❌ Don't store email content unencrypted
- ❌ Don't log sensitive data (billing rates, client names)
- ❌ Don't trust AI-generated content without validation
- ❌ Don't process emails without explicit user consent

### Authentication & Access

- ❌ Don't skip JWT validation for "internal" functions
- ❌ Don't use hardcoded API keys or encryption keys
- ❌ Don't allow cross-user data access even in error cases
- ❌ Don't implement custom JWT parsing when Clerk SDK exists

### AI Tool Security

- ❌ Don't trust LLM output for security decisions
- ❌ Don't expose internal system prompts to users
- ❌ Don't allow unlimited AI tool calls without rate limiting
- ❌ Don't process PII through AI without data classification

### Compliance & Privacy

- ❌ Don't assume GDPR compliance - implement and test all rights
- ❌ Don't retain data beyond configured retention periods
- ❌ Don't process personal data without lawful basis
- ❌ Don't ignore data breach notification requirements

---

## Post-Implementation Security Review

### Security Architecture Validation

1. **Threat Model Review**: Validate threat model against STRIDE methodology
2. **Security Controls Audit**: Verify all security controls are implemented and effective
3. **Penetration Testing**: Third-party security assessment of time tracking features
4. **Code Security Review**: Manual review of security-critical code paths

### Compliance Verification

1. **GDPR Assessment**: Legal review of GDPR compliance implementation
2. **Data Flow Analysis**: Map and validate all personal data processing flows
3. **Retention Policy Audit**: Verify automated data cleanup mechanisms
4. **Incident Response Testing**: Test breach notification and response procedures

### Ongoing Security Monitoring

1. **Security Metrics Dashboard**: Real-time monitoring of security events
2. **Anomaly Detection**: Alert on unusual time tracking patterns or access attempts
3. **Regular Vulnerability Scans**: Automated security scanning of dependencies
4. **Security Training**: Team education on time tracking security requirements
