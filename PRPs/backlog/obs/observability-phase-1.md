# Observability Phase 1 - Full-Stack Telemetry Collection PRP

## Purpose

Implement comprehensive observability infrastructure for the Living Tree Project to enable AI-assisted debugging and reduce MTTR by 30%. This PRP covers Phase 1 (Foundational Visibility) and Phase 2 (End-to-End Tracing) of the Observability Epic, specifically following the technology choices defined in the PRD.

## Core Principles

1. **Context is King**: Include ALL necessary documentation, examples, and caveats
2. **Validation Loops**: Provide executable tests/lints the AI can run and fix
3. **Information Dense**: Use keywords and patterns from the codebase
4. **Progressive Success**: Start simple, validate, then enhance

## Goal

Transform the Living Tree Project from unstructured logging to a comprehensive observability platform with:

- **Structured JSON logging** in FastAPI backend with request correlation IDs using **structlog**
- **Distributed tracing** from Next.js frontend through FastAPI backend using **@vercel/otel** and **opentelemetry-instrument**
- **Unified telemetry collection** in **Grafana Cloud** (Logs in Loki, Traces in Tempo, Metrics from Supabase)
- **AI-assistant ready data** for the "Observe -> Feed -> Prompt -> Fix" workflow

## Why

- **Business value**: 30% reduction in MTTR, maintain feature velocity despite AI-generated code complexity
- **Integration**: Enables AI assistants like Claude Code to debug black-box AI-generated code effectively
- **Problems solved**: Eliminates "vibe coding" debugging issues, provides data-driven investigation tools
- **Epic alignment**: Implements Observability-Driven Development (ODD) to solve the "Vibe Coder's Dilemma"

## What

Transform the current logging from string-based to structured JSON with correlation IDs, implement full-stack distributed tracing, and integrate with Grafana Cloud for unified observability following the Epic's three-phase implementation.

### Phase 1: Foundational Visibility (Target: 1 Week)

- **Structured JSON logging** in FastAPI backend using **structlog**
- **Request correlation IDs** attached to every log generated during a single API request
- **Grafana Cloud setup** connected to Supabase Prometheus metrics endpoint
- **Supabase Log Drains** configured to forward logs to Grafana Loki

### Phase 2: End-to-End Tracing (Target: 2 Weeks)

- **Next.js instrumentation** using **@vercel/otel** for automatic tracing
- **FastAPI instrumentation** using **opentelemetry-instrument** for automatic tracing
- **OpenTelemetry Collector** deployment to receive telemetry and forward to Grafana Cloud (Tempo)
- **Context propagation** between frontend and backend services

### Success Criteria

- [ ] All FastAPI logs are structured JSON with request_id correlation using structlog
- [ ] Supabase metrics visible in Grafana Cloud dashboard via metrics endpoint integration
- [ ] End-to-end traces from Next.js to FastAPI visible in Grafana Cloud Tempo
- [ ] Manual correlation working for Supabase database queries with trace_id logging
- [ ] AI assistants can effectively consume structured telemetry data for debugging

## All Needed Context

### Documentation & References (all context needed to implement the feature)

```yaml
# MUST READ - Include these in your context window
- url: https://signoz.io/guides/structlog/
  why: Complete structlog setup guide with FastAPI examples

- url: https://gist.github.com/nymous/f138c7f06062b7c43c060bf03759c29e
  why: Production-ready FastAPI + structlog + Uvicorn configuration

- url: https://nextjs.org/docs/app/guides/open-telemetry
  why: Official Next.js 15 OpenTelemetry instrumentation guide

- url: https://opentelemetry-python-contrib.readthedocs.io/en/latest/instrumentation/fastapi/fastapi.html
  why: Official OpenTelemetry FastAPI instrumentation documentation

- url: https://grafana.com/docs/grafana-cloud/monitor-infrastructure/integrations/integration-reference/integration-supabase/
  why: Official Supabase + Grafana Cloud integration setup

- url: https://github.com/blueswen/fastapi-observability
  why: Complete FastAPI observability example with Tempo, Loki, Prometheus

- file: /Users/jron/mac_code_projects/jerin/lt-133-observability-phase-1/api/core/config.py
  why: Current configuration patterns and logging setup to extend

- file: /Users/jron/mac_code_projects/jerin/lt-133-observability-phase-1/api/utils/tools.py
  why: Current logging patterns throughout the codebase to convert

- file: /Users/jron/mac_code_projects/jerin/lt-133-observability-phase-1/pyproject.toml
  why: Current Python dependencies for adding observability packages

- doc: https://grafana.com/blog/2024/02/20/how-to-instrument-your-python-application-using-opentelemetry/
  section: Complete 2025-updated Python OpenTelemetry guide
  critical: Environment variables and collector configuration for Grafana Cloud

- docfile: /Users/jron/mac_code_projects/jerin/lt-133-observability-phase-1/CLAUDE.md
  why: Project conventions, patterns, and critical environment setup
```

### Current Codebase Tree

```bash
living-tree/
├── api/                         # FastAPI backend
│   ├── core/
│   │   ├── config.py           # Settings management (LOG_LEVEL, ENABLE_REQUEST_LOGGING)
│   │   ├── auth.py             # JWT authentication
│   │   └── dependencies.py     # Dependency injection
│   ├── utils/
│   │   ├── tools.py            # Tool registry and execution
│   │   ├── gmail_helpers.py    # Gmail API integration
│   │   └── prompt.py           # AI prompt templates
│   └── index.py                # Main FastAPI app (health endpoints, CORS middleware)
├── apps/web/                    # Next.js 15 frontend
│   ├── app/                    # App Router routes
│   ├── components/             # React components
│   ├── hooks/                  # Custom hooks (use-triage-data.ts)
│   ├── middleware.ts           # Route protection
│   └── next.config.mjs         # Next.js configuration
├── packages/
│   ├── ui/                     # Shared components
│   └── types/                  # TypeScript definitions
├── docs/environments/          # Environment documentation
└── turbo.json                  # Turborepo configuration
```

### Desired Codebase tree with files to be added and responsibility of file

```bash
living-tree/
├── api/
│   ├── core/
│   │   ├── config.py      # EXTEND: Add structlog and OTEL config
│   │   ├── logging.py     # NEW: Centralized structlog configuration
│   │   └── tracing.py     # NEW: OpenTelemetry setup and configuration
│   ├── utils/
│   │   ├── correlation.py # NEW: Request ID generation and context management
│   │   └── tools.py       # MODIFY: Replace all logger calls with structured logging
│   ├── instrumentation.py # NEW: FastAPI auto-instrumentation setup
│   └── index.py           # MODIFY: Add structlog and OTEL middleware
├── apps/web/
│   ├── instrumentation.ts # NEW: Next.js OpenTelemetry configuration
│   └── next.config.mjs    # MODIFY: Add OTEL configuration
├── grafana/
│   ├── otel-collector.yaml # NEW: OpenTelemetry Collector configuration
│   └── dashboards/        # NEW: Pre-built Grafana dashboards
├── docker-compose.observability.yml # NEW: Local observability stack
└── pyproject.toml         # MODIFY: Add observability dependencies
```

### Known Gotchas of our codebase & Library Quirks

```python
# CRITICAL: Living Tree uses Poetry for Python dependencies (NEVER pip)
# Example: poetry add structlog opentelemetry-instrumentation-fastapi

# CRITICAL: Project uses pnpm for JavaScript dependencies (NEVER npm)
# Example: pnpm add @vercel/otel @opentelemetry/api

# CRITICAL: FastAPI runs on port 8000, Next.js on 3000
# OpenTelemetry Collector typically uses 4317 (gRPC) and 4318 (HTTP)

# CRITICAL: Current logging uses standard Python logging module
logger = logging.getLogger(__name__)
logger.info("Current string-based logging")
# CONVERT TO: structlog with bound context
logger = structlog.get_logger()
logger.info("Structured logging", user_id="123", request_id="abc")

# CRITICAL: Supabase metrics endpoint authentication
# URL: https://<project-ref>.supabase.co/customer/v1/privileged/metrics
# Auth: Basic auth with username "service_role" and password = SUPABASE_SERVICE_ROLE_KEY

# CRITICAL: Clerk user IDs are text type, not UUID in database
# RLS policies use text-based user identification

# CRITICAL: Project uses Vercel deployment with specific CORS origins
# OpenTelemetry must not interfere with existing CORS configuration

# CRITICAL: @vercel/otel works in both Edge and Node.js runtimes (Next.js requirement)
# Manual OpenTelemetry setup does NOT work with Edge runtime
```

## Implementation Blueprint

### Data models and structure

Create observability configuration models to ensure type safety and consistency.

```python
# New Pydantic models for observability configuration
class ObservabilitySettings(BaseSettings):
    # Structured logging
    LOG_FORMAT: str = Field(default="json", description="Log format: json or console")
    LOG_LEVEL: str = Field(default="INFO", description="Logging level")

    # OpenTelemetry
    OTEL_SERVICE_NAME: str = Field(default="living-tree-api", description="Service name for traces")
    OTEL_EXPORTER_OTLP_ENDPOINT: Optional[str] = Field(default=None, description="OTLP endpoint")
    OTEL_EXPORTER_OTLP_HEADERS: Optional[str] = Field(default=None, description="OTLP headers")

    # Grafana Cloud
    GRAFANA_CLOUD_API_KEY: Optional[str] = Field(default=None, description="Grafana Cloud API key")
    GRAFANA_CLOUD_INSTANCE_ID: Optional[str] = Field(default=None, description="Grafana Cloud instance")

    # Correlation
    ENABLE_CORRELATION_ID: bool = Field(default=True, description="Enable request correlation IDs")

class CorrelationContext(BaseModel):
    request_id: str = Field(..., description="Unique request identifier")
    user_id: Optional[str] = Field(default=None, description="Authenticated user ID")
    trace_id: Optional[str] = Field(default=None, description="OpenTelemetry trace ID")
    span_id: Optional[str] = Field(default=None, description="OpenTelemetry span ID")
```

### Manual Prerequisites (Complete BEFORE starting implementation)

```yaml
MANUAL Task 0.1 - Setup Grafana Cloud Account:
**REQUIRED**: Manual account creation and configuration
**WHO**: Developer (YOU must do this manually)
**WHEN**: Before Task 6 (Setup Grafana Cloud Integration)
**STEPS**:
  - VISIT https://grafana.com/auth/sign-up/
  - CREATE free Grafana Cloud account
  - NAVIGATE to "Connections" > "Add new connection" > "OpenTelemetry"
  - COPY OTLP endpoint URL (e.g., https://otlp-gateway-prod-us-central-0.grafana.net/otlp)
  - GENERATE API key for authentication
  - CREATE base64 encoded credentials: echo -n "instance_id:api_key" | base64
  - SAVE credentials for Task 6 environment configuration

MANUAL Task 0.2 - Gather Supabase Credentials:
**REQUIRED**: Existing Supabase project access
**WHO**: Developer (YOU must collect these manually)
**WHEN**: Before Task 6 (Setup Grafana Cloud Integration)
**STEPS**:
  - OPEN Supabase dashboard at https://supabase.com/dashboard
  - NAVIGATE to your Living Tree project
  - COPY project reference ID from URL (e.g., fwdfewruzeaplmcezyne)
  - VERIFY you have SUPABASE_SERVICE_ROLE_KEY from Settings > API
  - CONFIRM metrics endpoint URL: https://<project-ref>.supabase.co/customer/v1/privileged/metrics
  - TEST endpoint access with: curl -H "Authorization: Basic <base64-service-role>" <metrics-url>
```

### list of tasks to be completed to fullfill the PRP in the order they should be completed

```yaml
Task 1 - Add Observability Dependencies:
MODIFY pyproject.toml:
  - ADD structlog = "^25.1.0"
  - ADD opentelemetry-api = "^1.28.0"
  - ADD opentelemetry-sdk = "^1.28.0"
  - ADD opentelemetry-instrumentation-fastapi = "^0.56b0"
  - ADD opentelemetry-exporter-otlp = "^1.28.0"
  - ADD opentelemetry-distro = "^0.56b0"

MODIFY apps/web/package.json:
  - ADD @vercel/otel = "^1.13.0"
  - ADD @opentelemetry/api = "^1.10.0"

Task 2 - Create Core Observability Infrastructure:
CREATE api/core/logging.py:
  - IMPLEMENT centralized structlog configuration
  - CONFIGURE JSON formatter for production
  - CONFIGURE console formatter for development
  - SETUP correlation ID injection

CREATE api/core/tracing.py:
  - IMPLEMENT OpenTelemetry tracer provider setup
  - CONFIGURE OTLP exporter for Grafana Cloud
  - SETUP FastAPI auto-instrumentation
  - HANDLE environment-based configuration

CREATE api/utils/correlation.py:
  - IMPLEMENT request ID generation (uuid4)
  - CREATE correlation context management
  - SETUP context vars for async correlation

Task 3 - Integrate Structured Logging in FastAPI:
MODIFY api/core/config.py:
  - EXTEND Settings class with ObservabilitySettings
  - ADD structured logging configuration
  - PRESERVE existing logging configuration

MODIFY api/index.py:
  - REPLACE standard logging setup with structlog
  - ADD correlation ID middleware
  - ADD OpenTelemetry instrumentation
  - PRESERVE existing request logging behavior

Task 4 - Convert Existing Logging Calls:
MODIFY api/utils/tools.py:
  - FIND all logger.info/warning/error calls (70+ instances)
  - REPLACE with structured equivalents
  - ADD contextual information (user_id, email_id, function_name)
  - PRESERVE all existing log information

MODIFY api/core/dependencies.py:
  - CONVERT all logging calls to structured format
  - ADD context for Supabase client operations
  - MAINTAIN existing error handling

Task 5 - Implement Next.js Frontend Tracing:
CREATE apps/web/instrumentation.ts:
  - IMPLEMENT @vercel/otel configuration
  - CONFIGURE service name and resource attributes
  - SETUP OTLP exporter for Grafana Cloud
  - ENABLE automatic instrumentation

MODIFY apps/web/next.config.mjs:
  - ADD experimental.instrumentationHook = true (if needed for Next.js 15)
  - CONFIGURE OpenTelemetry environment variables
  - PRESERVE existing configuration

Task 6 - Setup Grafana Cloud Integration:
**PREREQUISITE**: Complete MANUAL Task 0.1 and 0.2 BEFORE starting this task
CREATE grafana/otel-collector.yaml:
  - USE credentials from MANUAL Task 0.1 (Grafana Cloud setup)
  - CONFIGURE OTLP receivers for traces and logs
  - SETUP exporters for Grafana Cloud Tempo and Loki
  - ADD Supabase metrics scraping configuration using credentials from MANUAL Task 0.2
  - ENABLE CORS for frontend integration

CREATE docker-compose.observability.yml:
  - ADD OpenTelemetry Collector service
  - CONFIGURE networking with existing services
  - SETUP environment variable passing (OTLP endpoint, Supabase credentials)
  - ENABLE development observability stack

Task 7 - Implement Manual Database Correlation:
MODIFY api/utils/tools.py (in database calling functions):
  - ADD trace_id logging before Supabase calls
  - INJECT correlation context in database queries
  - LOG database operation outcomes with trace correlation
  - MAINTAIN existing functionality

CREATE api/core/database_tracing.py:
  - IMPLEMENT Supabase client wrapper with tracing
  - ADD automatic span creation for database operations
  - SETUP query correlation with request traces
  - HANDLE connection pooling and error cases

Task 8 - Create Environment Configuration:
MODIFY api/.env.example:
  - ADD observability environment variables
  - DOCUMENT Grafana Cloud configuration
  - PROVIDE development vs production examples

MODIFY apps/web/.env.example:
  - ADD Next.js OpenTelemetry configuration
  - DOCUMENT frontend instrumentation variables

Task 9 - Add Validation and Testing:
CREATE api/tests/test_observability.py:
  - TEST structured logging output format
  - VERIFY correlation ID propagation
  - VALIDATE OpenTelemetry span creation
  - CHECK Grafana Cloud connectivity

CREATE scripts/validate_observability.py:
  - VERIFY structured log format compliance
  - CHECK OpenTelemetry configuration
  - VALIDATE correlation ID generation
  - TEST end-to-end trace propagation

Task 10 - Documentation and Dashboards:
CREATE grafana/dashboards/living-tree-overview.json:
  - IMPORT Supabase pre-built dashboard
  - ADD custom FastAPI metrics panels
  - CONFIGURE log correlation views
  - SETUP alerting thresholds

CREATE docs/observability-setup.md:
  - DOCUMENT Grafana Cloud setup process
  - PROVIDE troubleshooting guide
  - EXPLAIN correlation workflow
  - INCLUDE AI debugging examples
```

### Per task pseudocode as needed added to each task

```python
# Task 2 - api/core/logging.py
import structlog
from typing import Any, Dict

def setup_logging(log_level: str = "INFO", log_format: str = "json") -> None:
    """Configure structlog for the application"""

    # PATTERN: Environment-based configuration (see existing config.py)
    processors = [
        structlog.stdlib.filter_by_level,           # Filter by log level
        structlog.stdlib.add_logger_name,           # Add logger name
        structlog.stdlib.add_log_level,             # Add log level
        structlog.stdlib.PositionalArgumentsFormatter(),  # Handle positional args
        structlog.processors.StackInfoRenderer(),    # Add stack info if requested
        structlog.processors.format_exc_info,       # Format exceptions
        structlog.processors.UnicodeDecoder(),      # Decode unicode
        structlog.contextvars.merge_contextvars,   # CRITICAL: Merge correlation context
    ]

    if log_format == "json":
        # PRODUCTION: JSON formatter for machine parsing
        processors.append(structlog.processors.JSONRenderer())
    else:
        # DEVELOPMENT: Console formatter for human reading
        processors.append(structlog.dev.ConsoleRenderer())

    structlog.configure(
        processors=processors,
        wrapper_class=structlog.stdlib.BoundLogger,
        logger_factory=structlog.stdlib.LoggerFactory(),
        cache_logger_on_first_use=True,
    )

# Task 3 - api/index.py middleware addition
import uuid
from fastapi import Request
import structlog

@app.middleware("http")
async def correlation_middleware(request: Request, call_next):
    """Add correlation ID to all requests"""

    # PATTERN: Generate unique correlation ID (mimic existing request handling)
    correlation_id = str(uuid.uuid4())

    # CRITICAL: Use structlog contextvars for async correlation
    structlog.contextvars.clear_contextvars()
    structlog.contextvars.bind_contextvars(
        request_id=correlation_id,
        method=request.method,
        url=str(request.url),
        user_agent=request.headers.get("user-agent"),
    )

    # PATTERN: Execute request and measure timing
    start_time = time.time()
    response = await call_next(request)
    process_time = time.time() - start_time

    # PATTERN: Structured logging with context (replace existing string logs)
    logger = structlog.get_logger()
    logger.info(
        "Request completed",
        status_code=response.status_code,
        process_time=process_time,
    )

    return response

# Task 4 - Converting existing logs in tools.py
# BEFORE (current pattern):
logger.info(f"Tool: Attempting list_emails with params: {params}")

# AFTER (structured pattern):
logger.info(
    "Tool execution started",
    tool_name="list_emails",
    params=params.dict() if hasattr(params, 'dict') else str(params),
    user_id=getattr(params, 'user_id', None),
)

# Task 5 - apps/web/instrumentation.ts
import { registerOTel } from '@vercel/otel'

export function register() {
  // CRITICAL: @vercel/otel handles Edge + Node.js runtimes automatically
  registerOTel({
    serviceName: 'living-tree-web',
    serviceVersion: '1.0.0',
    // PATTERN: Environment-based exporter configuration
    traceExporter: process.env.OTEL_EXPORTER_OTLP_ENDPOINT ? {
      endpoint: process.env.OTEL_EXPORTER_OTLP_ENDPOINT,
      headers: process.env.OTEL_EXPORTER_OTLP_HEADERS ?
        JSON.parse(process.env.OTEL_EXPORTER_OTLP_HEADERS) : undefined,
    } : undefined,
  })
}

# Task 7 - Manual database correlation in tools.py
async def triage_emails(params, user_id: str, supabase_client):
    """Triage emails with trace correlation"""

    logger = structlog.get_logger()

    # CRITICAL: Log trace ID before database call for manual correlation
    from opentelemetry import trace
    current_span = trace.get_current_span()
    trace_id = current_span.get_span_context().trace_id if current_span else None

    logger.info(
        "Database operation starting",
        operation="store_triage_result",
        trace_id=f"{trace_id:032x}" if trace_id else None,
        user_id=user_id,
    )

    # PATTERN: Wrap database call with additional context
    try:
        result = await supabase_client.table("email_triage_results").insert(data)
        logger.info(
            "Database operation completed",
            operation="store_triage_result",
            success=True,
            rows_affected=len(result.data) if result.data else 0,
        )
    except Exception as e:
        logger.error(
            "Database operation failed",
            operation="store_triage_result",
            error=str(e),
            error_type=type(e).__name__,
        )
        raise
```

### Integration Points

```yaml
DEPENDENCIES:
  - poetry add: "structlog opentelemetry-instrumentation-fastapi opentelemetry-exporter-otlp"
  - pnpm add: "@vercel/otel @opentelemetry/api"

ENVIRONMENT_VARIABLES:
  - add to: api/.env
  - pattern: "OTEL_EXPORTER_OTLP_ENDPOINT=https://otlp-gateway-prod-us-central-0.grafana.net/otlp"
  - pattern: "OTEL_EXPORTER_OTLP_HEADERS={'Authorization': 'Basic <base64-encoded-credentials>'}"

MIDDLEWARE:
  - add to: api/index.py
  - pattern: "app.add_middleware(correlation_middleware)"
  - pattern: "FastAPIInstrumentor.instrument_app(app)"

CONFIGURATION:
  - modify: turbo.json passThroughEnv section
  - add: "OTEL_EXPORTER_OTLP_ENDPOINT", "OTEL_EXPORTER_OTLP_HEADERS"
```

## Validation Loop

### Level 1: Syntax & Style

```bash
# Run these FIRST - fix any errors before proceeding
cd api && poetry run black api/ --check          # Code formatting
cd api && poetry run mypy api/                   # Type checking
cd api && poetry run flake8 api/                 # Linting

cd apps/web && pnpm lint                         # Next.js linting
cd apps/web && pnpm check-types                  # TypeScript checking

# Expected: No errors. If errors, READ the error and fix.
```

### Level 2: Unit Tests each new feature/file/function use existing test patterns

```python
# CREATE api/tests/test_observability.py with these test cases:
import structlog
import json
from unittest.mock import patch

def test_structured_logging_format():
    """Verify structured logs produce valid JSON"""
    logger = structlog.get_logger()

    # Test that structured logs produce parseable JSON
    with patch('structlog.processors.JSONRenderer') as mock_renderer:
        logger.info("Test message", user_id="123", request_id="abc")

        # Verify JSON structure
        call_args = mock_renderer.return_value.call_args
        assert "user_id" in str(call_args)
        assert "request_id" in str(call_args)

def test_correlation_id_generation():
    """Verify correlation IDs are unique and valid UUID4"""
    from api.utils.correlation import generate_correlation_id

    id1 = generate_correlation_id()
    id2 = generate_correlation_id()

    assert id1 != id2
    assert len(id1) == 36  # UUID4 format
    assert id1.count('-') == 4

def test_opentelemetry_instrumentation():
    """Verify OpenTelemetry spans are created"""
    from opentelemetry import trace
    from api.core.tracing import setup_tracing

    setup_tracing()
    tracer = trace.get_tracer(__name__)

    with tracer.start_as_current_span("test-span") as span:
        assert span.is_recording()
        assert span.get_span_context().trace_id > 0

def test_grafana_cloud_connectivity():
    """Test OTLP exporter configuration"""
    import os
    from api.core.tracing import create_otlp_exporter

    # Mock environment variables
    with patch.dict(os.environ, {
        'OTEL_EXPORTER_OTLP_ENDPOINT': 'https://test-endpoint.com',
        'OTEL_EXPORTER_OTLP_HEADERS': '{"Authorization": "Basic test"}'
    }):
        exporter = create_otlp_exporter()
        assert exporter is not None
        assert 'test-endpoint.com' in exporter._endpoint
```

```bash
# Run and iterate until passing:
cd api && poetry run pytest tests/test_observability.py -v
# If failing: Read error, understand root cause, fix code, re-run
```

### Level 3: Integration Test

```bash
# Start the observability stack
cd api && poetry run uvicorn api.index:app --reload --port 8000
cd apps/web && pnpm dev

# Test structured logging output
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer test-token" \
  -d '{"messages": [{"role": "user", "content": "test"}]}'

# Expected: Structured JSON logs in console with correlation IDs
# Check: grep '"request_id"' api/backend.log

# Test OpenTelemetry traces
curl -X GET http://localhost:3000/api/health

# Expected: Traces visible in Grafana Cloud Tempo (if configured)
# Check: Grafana Cloud dashboard for incoming traces

# Test Supabase metrics
curl -H "Authorization: Basic <base64-service-role>" \
  https://<project-ref>.supabase.co/customer/v1/privileged/metrics

# Expected: Prometheus metrics returned
# Check: Grafana Cloud Metrics dashboard for Supabase data
```

## Final validation Checklist

- [ ] All tests pass: `cd api && poetry run pytest tests/ -v`
- [ ] No linting errors: `cd api && poetry run flake8 api/`
- [ ] No type errors: `cd api && poetry run mypy api/`
- [ ] Frontend builds: `cd apps/web && pnpm build`
- [ ] Structured logs visible: Check JSON format in development console
- [ ] Correlation IDs working: Verify same request_id across multiple log entries
- [ ] OpenTelemetry traces: Verify spans created for HTTP requests
- [ ] Grafana Cloud integration: Verify metrics/traces/logs flowing to Grafana
- [ ] Manual database correlation: Verify trace_id logged before Supabase calls
- [ ] AI debugging ready: Export structured log samples for AI assistant testing

---

## Anti-Patterns to Avoid

- ❌ Don't mix structured and unstructured logging - convert ALL logging calls
- ❌ Don't ignore correlation context - use structlog.contextvars consistently
- ❌ Don't hardcode Grafana Cloud credentials - use environment variables
- ❌ Don't break existing logging behavior - preserve all current log information
- ❌ Don't skip OpenTelemetry context propagation - ensure trace continuity
- ❌ Don't use manual OpenTelemetry setup in Next.js - use @vercel/otel for Edge compatibility
- ❌ Don't ignore performance impact - use batch processors for high-throughput scenarios

## Quality Score: 9/10

**Confidence Level for One-Pass Implementation:** 9/10

**Reasoning:**

- ✅ Comprehensive context including official documentation and working examples
- ✅ Detailed task breakdown with specific file modifications
- ✅ Complete validation pipeline with executable commands
- ✅ Real codebase patterns referenced and preserved
- ✅ Known gotchas documented from project experience
- ✅ Progressive implementation with validation gates
- ✅ AI-assistant ready structured data as end goal

**Risk Mitigation:**

- All major patterns have working 2025 examples from documentation
- Existing codebase logging patterns well-understood and documented
- Validation loops catch integration issues early
- Progressive implementation allows for course correction
