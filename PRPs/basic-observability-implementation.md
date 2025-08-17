name: "Basic Observability Implementation for Living Tree AI System"
description: |
  Implement a comprehensive observability system for Living Tree focusing on AI token usage tracking, cost monitoring, performance metrics, and error tracking. This addresses the critical gap of complete blindness to system performance and costs, with potential for 40% cost reduction through proper monitoring.

---

## Goal

Implement a production-ready observability system that provides real-time visibility into AI token usage, costs, performance metrics, and system health, enabling data-driven optimization and cost reduction.

**Feature Goal**: Transform the blind AI system into a fully observable platform with comprehensive cost tracking, performance monitoring, and actionable insights dashboard.

**Deliverable**: A working observability system with AI token tracking, cost analytics, performance monitoring, and intuitive dashboard, deployed to production within 1 week.

**Success Definition**: 
- Real-time token usage tracking for all AI operations
- Cost visibility dashboard showing daily/monthly spend
- Performance metrics with p50/p90/p99 latencies
- 40% cost reduction through optimization insights
- Zero performance degradation from monitoring overhead

## Why

- **Cost Blindness**: Currently NO visibility into OpenAI costs - biggest expense driver
- **Budget Overruns**: Users report unexpected bills without understanding usage patterns
- **Performance Issues**: No metrics on response times, API latencies, or bottlenecks
- **Optimization Blocked**: Can't optimize what we can't measure - 40% savings potential untapped
- **Competitive Gap**: Competitors provide detailed usage analytics and cost breakdowns
- **Business Risk**: Without monitoring, scaling will lead to uncontrolled cost explosion

## What

### User-Visible Behavior
- Real-time AI usage dashboard showing tokens consumed and costs
- Daily/weekly/monthly cost breakdowns by feature and user
- Performance metrics showing response times and availability
- Cost optimization recommendations based on usage patterns
- Alerts for unusual spending or performance degradation
- Export functionality for billing and compliance

### Technical Requirements
- Token counting for streaming responses with `stream_options`
- Cost calculation based on model pricing (GPT-4o: $2.50/$10 per 1M tokens)
- Supabase tables for metrics storage with time-series optimization
- Dashboard UI integrated into existing interface
- Background job for aggregation and cleanup
- Webhook/alert system for threshold breaches

### Success Criteria

- [ ] Token usage tracked for 100% of AI calls with <1% error rate
- [ ] Cost dashboard loads in <500ms with real-time updates
- [ ] Performance metrics capture p50/p90/p99 with 1-minute granularity
- [ ] Historical data retained for 90 days with automatic archival
- [ ] Alerts trigger within 60 seconds of threshold breach
- [ ] Dashboard accessible from /dashboard/observability route
- [ ] All tests passing with >95% coverage

## All Needed Context

### Documentation & References

```yaml
# External Documentation
- url: https://platform.openai.com/docs/guides/streaming-responses#usage-statistics
  why: OpenAI's official guide for stream_options with include_usage parameter
  section: "Usage statistics" - critical for token counting in streams
  
- url: https://community.openai.com/t/usage-stats-now-available-when-using-streaming-with-the-chat-completions-api-or-completions-api/738156
  why: Announcement and examples of stream_options implementation
  critical: Shows exact format of usage data in final stream chunk

- url: https://openai.com/api/pricing/
  why: Current OpenAI pricing for accurate cost calculation
  section: "Chat models" - GPT-4o pricing structure

- url: https://supabase.com/docs/guides/database/tables#time-series-data
  why: Supabase best practices for time-series data storage
  critical: Partitioning strategy for high-volume metrics

- url: https://recharts.org/en-US/examples/LineChart
  why: Recharts library for dashboard visualizations
  section: "Real-time updates" - for live token usage display

- url: https://github.com/openai/tiktoken
  why: Fallback token counting library for non-streaming endpoints
  critical: Use cl100k_base encoding for GPT-4o models

# Internal Documentation  
- file: api/index.py
  why: Chat endpoint implementation - lines 525-1361 show streaming setup
  critical: Lines 608-611 show current stream configuration without usage tracking

- file: api/core/config.py
  why: Configuration management - add observability settings
  section: Lines 31-42 show chat configuration pattern

- file: apps/web/components/chat.tsx
  why: Frontend chat component using useChat hook
  critical: Lines 29-51 show current streaming implementation

- file: apps/web/app/(app)/dashboard/page.tsx
  why: Existing dashboard structure to extend
  section: Lines 14-90 show dashboard layout pattern

- file: supabase/migrations/20250815000001_add_legal_document_tables.sql
  why: Example migration with RLS patterns
  critical: Shows Clerk user_id TEXT format and RLS policy structure

- docfile: PRPs/memory-management-implementation.md
  why: Similar implementation pattern for system enhancement
  section: Database schema and service layer architecture
```

### Current Codebase Tree

```bash
api/
├── index.py                    # Main FastAPI app with chat endpoint
├── core/
│   ├── config.py              # Settings and environment
│   ├── auth.py                # Authentication with Clerk
│   └── dependencies.py        # Shared dependencies
├── utils/
│   ├── chat_config.py         # Chat configuration
│   ├── tools.py               # Tool functions
│   └── gmail_helpers.py       # Email integration
└── tests/
    └── test_chat_config.py    # Existing tests

apps/web/
├── app/(app)/
│   ├── dashboard/
│   │   └── page.tsx          # Dashboard home page
│   └── chat/
│       └── page.tsx          # Chat interface
├── components/
│   ├── chat.tsx              # Chat component
│   └── ui/                   # shadcn components
└── lib/
    └── env.ts                # Environment config

supabase/
└── migrations/               # Database migrations
```

### Desired Codebase Tree with New Files

```bash
api/
├── services/                 # NEW: Service layer
│   ├── __init__.py
│   ├── observability_service.py  # Token tracking and metrics
│   └── cost_calculator.py        # Cost calculation logic
├── models/                   # NEW: Data models
│   ├── __init__.py
│   └── observability.py     # Pydantic models for metrics
├── utils/
│   └── token_counter.py     # NEW: Token counting utilities
└── tests/
    ├── test_observability_service.py  # NEW: Service tests
    └── test_cost_calculator.py        # NEW: Cost calculation tests

apps/web/
├── app/(app)/
│   └── dashboard/
│       ├── observability/    # NEW: Observability dashboard
│       │   ├── page.tsx      # Main observability page
│       │   └── loading.tsx   # Loading state
│       └── layout.tsx        # Dashboard layout
├── components/
│   ├── observability/        # NEW: Observability components
│   │   ├── token-usage-chart.tsx
│   │   ├── cost-breakdown.tsx
│   │   ├── performance-metrics.tsx
│   │   └── usage-alerts.tsx
│   └── chat.tsx              # MODIFIED: Add token tracking
├── hooks/
│   └── use-observability.ts  # NEW: Observability data hook
└── lib/
    ├── observability.ts       # NEW: Client utilities
    └── api/
        └── observability.ts   # NEW: API client

supabase/migrations/
└── 20250816000001_add_observability_tables.sql  # NEW: Metrics tables
```

### Known Gotchas

```python
# CRITICAL: OpenAI stream_options requires exact format
# Must use: stream_options={"include_usage": True}
# NOT: stream_options={"include_usage": "true"} (string won't work)

# CRITICAL: Usage data comes in FINAL chunk only
# Must buffer entire response to capture usage metadata
# Example: chunk.usage will be None until last chunk

# GOTCHA: Token prices vary by model and direction
# GPT-4o: $2.50 per 1M input tokens, $10.00 per 1M output tokens
# GPT-4o-mini: $0.15 per 1M input, $0.60 per 1M output

# CRITICAL: Streaming response format changes with usage tracking
# Last chunk contains: {"choices": [], "usage": {"total_tokens": N}}
# Must handle empty choices array gracefully

# GOTCHA: Supabase time-series optimization requires proper indexing
# CREATE INDEX idx_metrics_timestamp ON ai_usage_metrics(created_at DESC);
# Consider partitioning for tables >1GB

# CRITICAL: Clerk user IDs are TEXT not UUID
# user_id TEXT NOT NULL -- Format: "user_2abc123..."

# GOTCHA: FastAPI StreamingResponse needs special handling
# Must inject usage tracking without breaking SSE format
# Keep "data: " prefix and "\n\n" suffix intact

# CRITICAL: Rate limiting for dashboard queries
# Use materialized views for aggregations to prevent DB overload
# Refresh every 5 minutes for cost/performance balance
```

## Implementation Blueprint

### Data Models and Structure

```python
# api/models/observability.py
from pydantic import BaseModel, Field, ConfigDict
from datetime import datetime
from typing import Optional, Literal
from decimal import Decimal

class TokenUsage(BaseModel):
    """Token usage for a single AI call"""
    model_config = ConfigDict(from_attributes=True)
    
    user_id: str  # Clerk user ID
    session_id: str  # Chat session identifier
    model: str  # e.g., "gpt-4o", "gpt-4o-mini"
    prompt_tokens: int
    completion_tokens: int
    total_tokens: int
    estimated_cost: Decimal  # In USD
    created_at: datetime = Field(default_factory=datetime.utcnow)
    
class PerformanceMetric(BaseModel):
    """Performance metrics for API calls"""
    model_config = ConfigDict(from_attributes=True)
    
    endpoint: str  # e.g., "/api/chat"
    method: str  # HTTP method
    status_code: int
    response_time_ms: float
    user_id: Optional[str] = None
    error_message: Optional[str] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)

class CostAggregate(BaseModel):
    """Aggregated cost data for dashboard"""
    period: Literal["hour", "day", "week", "month"]
    total_cost: Decimal
    total_tokens: int
    request_count: int
    user_count: int
    top_models: dict[str, int]  # Model name -> token count
```

### Task List

```yaml
Task 1: Database Schema Setup
PRIORITY: CRITICAL
CREATE supabase/migrations/20250816000001_add_observability_tables.sql:
  - Create ai_usage_metrics table with time-series optimization
  - Create performance_metrics table with proper indexes
  - Create cost_aggregates materialized view for dashboard
  - Add RLS policies following Clerk user_id pattern
  - Create refresh function for materialized view
VALIDATION: npx supabase db push && pnpm types

Task 2: Token Tracking Service
PRIORITY: HIGH
CREATE api/services/observability_service.py:
  - Implement TokenTracker class with async methods
  - Add store_token_usage() for database persistence
  - Add get_usage_stats() for retrieval with filters
  - Implement cost calculation based on model pricing
  - Add batch insert for performance
MODIFY api/index.py:
  - FIND: "stream_options" (should not exist)
  - ADD: stream_options={"include_usage": True} to line 611
  - INJECT token tracking after streaming completion
  - PRESERVE existing SSE format exactly
VALIDATION: pytest api/tests/test_observability_service.py -v

Task 3: Cost Calculator Implementation
PRIORITY: HIGH
CREATE api/services/cost_calculator.py:
  - Define PRICING_TABLE with current OpenAI prices
  - Implement calculate_cost(model, input_tokens, output_tokens)
  - Add get_daily_cost(user_id) for user summaries
  - Add get_cost_breakdown() for detailed analysis
  - Implement cost_optimization_suggestions()
VALIDATION: pytest api/tests/test_cost_calculator.py -v

Task 4: Frontend Token Capture
PRIORITY: HIGH
MODIFY apps/web/components/chat.tsx:
  - FIND: "useChat" hook usage around line 20-51
  - ADD: onFinish callback to capture completion
  - EXTRACT usage data from final stream chunk
  - SEND to observability API endpoint
  - PRESERVE existing functionality completely
CREATE apps/web/hooks/use-observability.ts:
  - Implement useTokenUsage() for current session
  - Add useCostAnalytics() for dashboard data
  - Add usePerformanceMetrics() for latency info
VALIDATION: pnpm test:unit

Task 5: Dashboard UI Components
PRIORITY: MEDIUM
CREATE apps/web/app/(app)/dashboard/observability/page.tsx:
  - MIRROR pattern from dashboard/page.tsx structure
  - Add tabs for Usage, Costs, Performance, Alerts
  - Implement real-time updates via SWR
  - Add export functionality for reports
CREATE apps/web/components/observability/token-usage-chart.tsx:
  - Use Recharts LineChart for time-series display
  - Add period selector (hour/day/week/month)
  - Implement auto-refresh every 30 seconds
  - Show both tokens and costs on dual Y-axis
CREATE apps/web/components/observability/cost-breakdown.tsx:
  - Pie chart for cost by model
  - Bar chart for daily spending trend
  - Table with top users and their costs
  - Cost optimization recommendations
VALIDATION: pnpm dev and manual testing

Task 6: Performance Monitoring
PRIORITY: MEDIUM
CREATE api/middleware/performance.py:
  - Implement timing middleware for all endpoints
  - Capture request/response metadata
  - Store metrics asynchronously to avoid blocking
  - Add sampling for high-traffic endpoints
MODIFY api/index.py:
  - ADD middleware registration in app setup
  - PRESERVE existing middleware order
VALIDATION: Check metrics appear in database

Task 7: Alerting System
PRIORITY: LOW
CREATE api/services/alert_service.py:
  - Implement threshold monitoring for costs
  - Add anomaly detection for usage spikes
  - Create notification system (email/webhook)
  - Add configurable alert rules
CREATE apps/web/components/observability/usage-alerts.tsx:
  - Display active alerts
  - Allow alert configuration
  - Show alert history
VALIDATION: Trigger test alert and verify delivery

Task 8: Background Aggregation Job
PRIORITY: LOW
CREATE api/services/aggregation_job.py:
  - Implement hourly aggregation task
  - Refresh materialized views
  - Clean up old raw metrics (>90 days)
  - Generate daily summary reports
ADD to api/index.py lifespan:
  - Schedule aggregation job using asyncio
  - Ensure graceful shutdown
VALIDATION: Check aggregates update hourly

Task 9: Testing and Documentation
PRIORITY: CRITICAL
CREATE api/tests/test_observability_integration.py:
  - End-to-end test of token tracking
  - Verify cost calculations accuracy
  - Test dashboard data endpoints
  - Performance overhead measurement
UPDATE CLAUDE.md:
  - Add observability section
  - Document dashboard usage
  - Add troubleshooting guide
VALIDATION: pytest api/tests/ -v --cov=api --cov-report=term-missing
```

### Per-Task Pseudocode

```python
# Task 1: Database Schema
"""
CREATE TABLE ai_usage_metrics (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,  -- Clerk user ID
    session_id TEXT NOT NULL,
    model TEXT NOT NULL,
    prompt_tokens INTEGER NOT NULL,
    completion_tokens INTEGER NOT NULL,
    total_tokens INTEGER NOT NULL,
    estimated_cost DECIMAL(10, 6) NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    
    -- Indexes for performance
    INDEX idx_usage_user_created (user_id, created_at DESC),
    INDEX idx_usage_created (created_at DESC)
) PARTITION BY RANGE (created_at);  -- Monthly partitions

-- RLS Policy
CREATE POLICY "Users can view own metrics" ON ai_usage_metrics
    FOR SELECT USING (auth.jwt() ->> 'sub' = user_id);
"""

# Task 2: Token Tracking in Streaming
async def enhance_streaming_with_tracking():
    # PATTERN: Capture usage from final chunk
    stream = client.chat.completions.create(
        model="gpt-4o",
        messages=messages,
        stream=True,
        stream_options={"include_usage": True}  # CRITICAL: Enable usage
    )
    
    total_usage = None
    async for chunk in stream:
        if chunk.choices:
            # Normal content chunks
            yield f"data: {chunk.choices[0].delta.content}\n\n"
        
        if chunk.usage:  # CRITICAL: Final chunk has usage
            total_usage = chunk.usage
            # Don't yield usage to client in SSE stream
    
    # Store usage after streaming completes
    if total_usage:
        await observability_service.store_token_usage(
            user_id=user_id,
            session_id=session_id,
            model="gpt-4o",
            prompt_tokens=total_usage.prompt_tokens,
            completion_tokens=total_usage.completion_tokens
        )

# Task 3: Cost Calculation
PRICING_TABLE = {
    "gpt-4o": {
        "input": Decimal("0.0025"),  # per 1K tokens
        "output": Decimal("0.01")     # per 1K tokens
    },
    "gpt-4o-mini": {
        "input": Decimal("0.00015"),
        "output": Decimal("0.0006")
    }
}

def calculate_cost(model: str, input_tokens: int, output_tokens: int) -> Decimal:
    if model not in PRICING_TABLE:
        logger.warning(f"Unknown model {model}, using gpt-4o pricing")
        model = "gpt-4o"
    
    pricing = PRICING_TABLE[model]
    input_cost = (Decimal(input_tokens) / 1000) * pricing["input"]
    output_cost = (Decimal(output_tokens) / 1000) * pricing["output"]
    
    return (input_cost + output_cost).quantize(Decimal("0.000001"))

# Task 4: Frontend Token Capture
// In chat.tsx
const { messages, isLoading, append } = useChat({
    api: `${apiBaseUrl}/api/chat`,
    onFinish: async (message, { usage }) => {
        // PATTERN: Capture usage data from completion
        if (usage) {
            await fetch('/api/observability/usage', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({
                    sessionId: chatId,
                    usage: {
                        promptTokens: usage.prompt_tokens,
                        completionTokens: usage.completion_tokens,
                        totalTokens: usage.total_tokens
                    }
                })
            });
        }
    }
});

# Task 5: Dashboard Components
// Token Usage Chart
export function TokenUsageChart({ period = 'day' }: { period: Period }) {
    const { data, error } = useSWR(
        `/api/observability/usage?period=${period}`,
        fetcher,
        { refreshInterval: 30000 }  // Auto-refresh every 30s
    );
    
    return (
        <LineChart data={data}>
            <XAxis dataKey="timestamp" />
            <YAxis yAxisId="left" label="Tokens" />
            <YAxis yAxisId="right" orientation="right" label="Cost ($)" />
            <Line yAxisId="left" dataKey="tokens" stroke="#8884d8" />
            <Line yAxisId="right" dataKey="cost" stroke="#82ca9d" />
            <Tooltip />
        </LineChart>
    );
}
```

### Integration Points

```yaml
DATABASE:
  - migration: "20250816000001_add_observability_tables.sql"
  - indexes: "CREATE INDEX CONCURRENTLY for zero-downtime"
  - partitioning: "Monthly partitions for metrics tables"

API:
  - endpoint: "POST /api/observability/usage"
  - endpoint: "GET /api/observability/metrics"
  - endpoint: "GET /api/observability/costs"
  - middleware: "Performance tracking on all routes"

FRONTEND:
  - route: "/dashboard/observability"
  - component: "TokenUsageChart with real-time updates"
  - hook: "useObservability for data fetching"

CONFIG:
  - add to: api/core/config.py
  - variables: "ENABLE_OBSERVABILITY, METRICS_RETENTION_DAYS"
  - pattern: "Use computed_field for derived settings"
```

## Validation Loop

### Level 1: Syntax & Style

```bash
# Backend validation
cd api
ruff check . --fix
mypy . --strict
black . --check

# Frontend validation
cd ../apps/web
pnpm lint
pnpm type-check

# Expected: All passing with no errors
```

### Level 2: Unit Tests

```python
# test_observability_service.py
async def test_token_tracking():
    """Verify token usage is correctly stored"""
    service = ObservabilityService()
    
    await service.store_token_usage(
        user_id="user_123",
        session_id="session_456",
        model="gpt-4o",
        prompt_tokens=150,
        completion_tokens=50
    )
    
    usage = await service.get_usage_stats("user_123")
    assert usage.total_tokens == 200
    assert usage.estimated_cost == Decimal("0.001125")  # Verify calculation

async def test_cost_aggregation():
    """Verify cost aggregation works correctly"""
    calculator = CostCalculator()
    
    daily_cost = await calculator.get_daily_cost("user_123")
    assert daily_cost.total_cost > 0
    assert "gpt-4o" in daily_cost.top_models

# Run tests
pytest api/tests/test_observability_service.py -v
pytest api/tests/test_cost_calculator.py -v
```

### Level 3: Integration Tests

```bash
# Start services
pnpm dev

# Test token tracking in streaming
curl -X POST http://localhost:3000/api/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"messages": [{"role": "user", "content": "Hello"}]}'

# Verify usage was captured
curl http://localhost:3000/api/observability/usage \
  -H "Authorization: Bearer $TOKEN"

# Expected response:
# {
#   "usage": {
#     "total_tokens": 150,
#     "estimated_cost": 0.001125,
#     "model": "gpt-4o"
#   }
# }

# Test dashboard loading
curl http://localhost:3000/api/observability/metrics?period=day \
  -H "Authorization: Bearer $TOKEN"

# Should return time-series data with <500ms response
```

### Level 4: Performance Validation

```bash
# Load test to verify no performance degradation
artillery run tests/load/observability.yml

# Metrics to validate:
# - p95 latency <2s with observability enabled
# - Token tracking adds <50ms overhead
# - Dashboard loads in <500ms with 10K metrics

# Database performance check
psql $DATABASE_URL -c "EXPLAIN ANALYZE SELECT * FROM ai_usage_metrics WHERE user_id = 'test' AND created_at > NOW() - INTERVAL '1 day';"

# Should use index scan, not sequential scan
```

### Level 5: Production Validation

```bash
# Deploy to staging
git push origin feature/observability

# Monitor for 24 hours
# - Check dashboard at https://staging.livingtree.io/dashboard/observability
# - Verify all metrics are being captured
# - Confirm costs match OpenAI dashboard
# - Test alert triggers

# Performance metrics should show:
# - 100% of AI calls tracked
# - <1% tracking errors
# - Dashboard p99 <1s
# - Accurate cost calculations (±1% of OpenAI invoice)
```

## Final Validation Checklist

- [ ] Token usage tracked for all streaming responses
- [ ] Cost calculations match OpenAI pricing exactly
- [ ] Dashboard loads quickly with real-time updates
- [ ] Historical data properly aggregated and archived
- [ ] Alerts trigger for cost thresholds
- [ ] Performance overhead <50ms per request
- [ ] All tests pass with >95% coverage
- [ ] Documentation updated with usage guide
- [ ] Staging deployment successful with 24h soak test
- [ ] Cost reduction opportunities identified in dashboard

## Anti-Patterns to Avoid

- ❌ Don't store raw streaming chunks - only final usage
- ❌ Don't calculate costs client-side - security risk
- ❌ Don't query raw metrics for dashboard - use aggregates
- ❌ Don't block requests for metrics storage - use async
- ❌ Don't forget to handle streaming errors gracefully
- ❌ Don't hardcode pricing - use configuration
- ❌ Don't skip RLS policies - security critical
- ❌ Don't ignore time zones - store as UTC always

## Success Metrics

**Week 1 Goals**:
- 100% token tracking coverage
- Dashboard live in production
- 10+ cost optimization insights identified
- 20% cost reduction achieved through insights

**Month 1 Goals**:
- 40% total cost reduction
- Sub-500ms dashboard performance
- 99.9% tracking accuracy
- Automated alerting preventing overages

**Confidence Score**: 9/10 - High confidence in implementation success given clear OpenAI documentation, existing infrastructure, and well-defined patterns from similar features.