name: "Time Tracking Agentic - High Performance AI Tools"
description: |
AI-powered time tracking assistant using OpenAI function calling patterns with
focus on performance optimization, scalability, and efficient resource utilization.

---

## Goal

Build a high-performance time tracking assistant that leverages AI agent tool calling patterns to scan sent emails for billable time mentions. The system must integrate seamlessly with the existing OpenAI function calling architecture while maintaining optimal performance characteristics and scalability for production workloads.

## Why

- **Legal Billing Accuracy**: Automated extraction of billable time from sent emails reduces manual tracking errors by ~80%
- **Productivity Enhancement**: Lawyers can focus on legal work rather than administrative time tracking
- **Revenue Recovery**: Captures billable time that would otherwise be lost due to incomplete manual tracking
- **Scalability**: Designed to handle enterprise workloads with hundreds of concurrent users and thousands of emails per hour
- **Performance**: Sub-second response times for individual email analysis, <30s for batch processing

## What

An AI-powered time tracking system that provides four core tools callable via the existing chat API:

1. **scan_billable_time**: Analyzes sent emails for billable time mentions with high-performance batch processing
2. **analyze_time_entry**: Deep analysis of individual emails for precise time extraction
3. **get_time_tracking_summary**: Aggregated reporting with caching and optimization
4. **configure_time_tracking**: User preferences and settings management

### Success Criteria

- [ ] **Performance**: Single email analysis <2s, batch processing (50 emails) <30s
- [ ] **Scalability**: Handle 10+ concurrent users, 1000+ emails/hour per instance
- [ ] **Accuracy**: >95% precision in time mention detection, >90% recall
- [ ] **Memory Efficiency**: <100MB per 50-email batch, automatic garbage collection
- [ ] **Cache Performance**: >80% cache hit rate for repeated queries
- [ ] **Database Performance**: <100ms query response time, optimized indexing
- [ ] **Concurrent Processing**: 10+ parallel operations without resource exhaustion
- [ ] **API Rate Limiting**: Compliant with OpenAI (3500 RPM) and Gmail (250 quota units/user/second) limits

## All Needed Context

### Documentation & References

```yaml
# MUST READ - Include these in your context window
- file: /home/jron/wsl_project/jerin-lt-139-time-reviewer-tool/api/utils/tools.py
  why: Existing tool patterns, triage_emails implementation for performance reference

- file: /home/jron/wsl_project/jerin-lt-139-time-reviewer-tool/api/index.py
  why: OpenAI function calling registration, available_tools dictionary, stream_text architecture

- file: /home/jron/wsl_project/jerin-lt-139-time-reviewer-tool/api/tests/test_triage_performance.py
  why: Performance testing patterns, concurrent processing examples, benchmarking approaches

- file: /home/jron/wsl_project/jerin-lt-139-time-reviewer-tool/supabase/migrations/20240101000000_email_triage.sql
  why: Database schema patterns, indexing strategies, RLS policy implementation

- file: /home/jron/wsl_project/jerin-lt-139-time-reviewer-tool/api/core/config.py
  why: LRU cache usage, settings management, performance configuration

- doc: https://platform.openai.com/docs/guides/function-calling
  section: Parallel function calling, token management
  critical: Rate limiting and concurrent request handling

- doc: https://docs.python.org/3/library/asyncio.html
  section: asyncio.gather, asyncio.Semaphore, asyncio.Queue
  critical: Concurrency patterns for high-performance async operations
```

### Current Codebase Performance Patterns Analysis

**Existing High-Performance Patterns:**

- **LRU Caching**: `@lru_cache` in config.py for settings management
- **Async/Await**: Throughout tools.py with proper dependency injection
- **Batch Processing**: trige_emails processes 50+ emails efficiently
- **Connection Pooling**: Gmail service dependency injection with connection reuse
- **Rate Limiting**: Existing patterns in triage tools for API compliance
- **Database Optimization**: Indexed queries with RLS policies
- **Memory Management**: Garbage collection in test suites
- **Concurrent Processing**: asyncio.gather patterns in performance tests

**Performance Bottlenecks Identified:**

- **Sequential Processing**: Current tools process emails one-by-one
- **No Caching Layer**: Repeated analysis of same emails
- **Synchronous Database Writes**: Blocking operations during batch processing
- **Memory Accumulation**: Large email batches held in memory
- **No Connection Pooling**: Each request creates new connections

### Desired Codebase Structure

```bash
api/
├── utils/
│   ├── time_tracking_tools.py        # Core time tracking tool implementations
│   ├── time_tracking_schemas.py      # Pydantic models for time tracking
│   ├── time_tracking_cache.py        # High-performance caching layer
│   ├── time_tracking_processor.py    # Batch processing engine
│   └── time_tracking_optimizer.py    # Performance optimization utilities
├── tests/
│   ├── test_time_tracking_tools.py   # Unit tests
│   ├── test_time_tracking_performance.py # Performance benchmarks
│   └── test_time_tracking_concurrency.py # Concurrency tests
└── supabase/migrations/
    └── [timestamp]_time_tracking_tables.sql # Database schema
```

### Known Gotchas & Library Quirks

```python
# CRITICAL: OpenAI Function Calling requires specific JSON schema format
# Tools must be registered in available_tools dictionary with exact signatures

# CRITICAL: Gmail API rate limiting - 250 quota units/user/second
# Must implement exponential backoff and request batching

# CRITICAL: Supabase RLS policies require user_id in ALL queries
# All time tracking tables must include user_id filtering

# CRITICAL: FastAPI dependency injection with async/await
# All tool functions must use proper Depends() pattern for service injection

# PERFORMANCE: asyncio.gather has memory overhead for large batches
# Limit concurrent operations to 10-15 to prevent memory exhaustion

# PERFORMANCE: Pydantic v2 validation is fast but still adds overhead
# Use .model_dump() for serialization, avoid repeated validation

# MEMORY: Email content can be large (1MB+ for attachments)
# Process emails in streaming fashion, avoid loading all into memory

# DATABASE: Supabase connection pooling is automatic but limited
# Use batch operations for bulk inserts/updates
```

## Implementation Blueprint

### Data Models and Structure

High-performance data models optimized for time tracking operations:

```python
# api/utils/time_tracking_schemas.py
from pydantic import BaseModel, Field, validator
from typing import List, Optional, Dict, Any
from datetime import datetime, timedelta
from enum import Enum

class TimeEntryType(str, Enum):
    CALL = "call"
    MEETING = "meeting"
    RESEARCH = "research"
    DRAFTING = "drafting"
    REVIEW = "review"
    TRAVEL = "travel"
    OTHER = "other"

class BillableTimeEntry(BaseModel):
    """Optimized model for billable time entries"""
    email_id: str = Field(..., description="Gmail message ID")
    user_id: str = Field(..., description="User identifier")

    # Time information
    duration_minutes: float = Field(..., ge=0, le=1440)  # Max 24 hours
    entry_type: TimeEntryType
    date_performed: datetime

    # Context
    client_matter: Optional[str] = Field(None, max_length=200)
    description: str = Field(..., max_length=1000)
    rate_category: Optional[str] = Field(None, max_length=50)

    # Metadata
    confidence_score: float = Field(..., ge=0.0, le=1.0)
    extracted_text: str = Field(..., max_length=500)

    # Performance optimization
    created_at: datetime = Field(default_factory=datetime.utcnow)
    processed_at: Optional[datetime] = None

class ScanBillableTimeParams(BaseModel):
    """Parameters for scanning emails for billable time"""
    date_range_days: int = Field(default=7, ge=1, le=30)
    max_emails: int = Field(default=100, ge=1, le=500)
    query_filter: Optional[str] = Field(None, description="Gmail query filter")
    client_filter: Optional[str] = Field(None, description="Filter by client name")
    use_cache: bool = Field(default=True, description="Enable result caching")

class TimeTrackingSummaryParams(BaseModel):
    """Parameters for time tracking summary"""
    date_range_days: int = Field(default=30, ge=1, le=365)
    client_filter: Optional[str] = None
    entry_type_filter: Optional[List[TimeEntryType]] = None
    min_duration_minutes: Optional[float] = Field(None, ge=0)
    use_cache: bool = Field(default=True)

class BatchProcessingResult(BaseModel):
    """Results from batch processing with performance metrics"""
    total_processed: int
    time_entries_found: int
    processing_time_ms: int
    cache_hits: int
    cache_misses: int
    memory_usage_mb: float
    api_calls_made: int
    entries: List[BillableTimeEntry]
```

### Core Performance Architecture

```python
# api/utils/time_tracking_cache.py
from functools import lru_cache, wraps
from typing import Dict, Any, Optional, Tuple
import asyncio
import hashlib
import json
from datetime import datetime, timedelta

class HighPerformanceCache:
    """Memory-efficient caching for time tracking operations"""

    def __init__(self, max_size: int = 1000, ttl_seconds: int = 3600):
        self._cache: Dict[str, Tuple[Any, datetime]] = {}
        self._max_size = max_size
        self._ttl = timedelta(seconds=ttl_seconds)
        self._hits = 0
        self._misses = 0

    def _generate_key(self, *args, **kwargs) -> str:
        """Generate cache key from function arguments"""
        key_data = {"args": args, "kwargs": kwargs}
        key_str = json.dumps(key_data, sort_keys=True, default=str)
        return hashlib.md5(key_str.encode()).hexdigest()

    def _is_expired(self, timestamp: datetime) -> bool:
        """Check if cache entry is expired"""
        return datetime.utcnow() - timestamp > self._ttl

    def _evict_expired(self):
        """Remove expired entries"""
        now = datetime.utcnow()
        expired_keys = [
            key for key, (_, timestamp) in self._cache.items()
            if now - timestamp > self._ttl
        ]
        for key in expired_keys:
            del self._cache[key]

    def get(self, key: str) -> Optional[Any]:
        """Get cached value"""
        if key in self._cache:
            value, timestamp = self._cache[key]
            if not self._is_expired(timestamp):
                self._hits += 1
                return value
            else:
                del self._cache[key]

        self._misses += 1
        return None

    def set(self, key: str, value: Any):
        """Set cached value with LRU eviction"""
        # Evict expired entries first
        self._evict_expired()

        # If at max size, remove oldest entry
        if len(self._cache) >= self._max_size:
            oldest_key = min(self._cache.keys(),
                           key=lambda k: self._cache[k][1])
            del self._cache[oldest_key]

        self._cache[key] = (value, datetime.utcnow())

    @property
    def hit_rate(self) -> float:
        """Calculate cache hit rate"""
        total = self._hits + self._misses
        return self._hits / total if total > 0 else 0.0

# Global cache instance
time_tracking_cache = HighPerformanceCache()

def cached_async(ttl_seconds: int = 3600):
    """Decorator for caching async function results"""
    def decorator(func):
        @wraps(func)
        async def wrapper(*args, **kwargs):
            cache_key = time_tracking_cache._generate_key(*args, **kwargs)

            # Try cache first
            cached_result = time_tracking_cache.get(cache_key)
            if cached_result is not None:
                return cached_result

            # Execute function
            result = await func(*args, **kwargs)

            # Cache result
            time_tracking_cache.set(cache_key, result)
            return result

        return wrapper
    return decorator
```

### List of Tasks (Performance-Optimized Implementation Order)

```yaml
Task 1: Database Schema and Optimization
CREATE supabase/migrations/[timestamp]_time_tracking_tables.sql:
  - CREATE time_tracking_entries table with optimized indexes
  - CREATE time_tracking_settings table for user preferences
  - CREATE performance indexes on user_id, date_performed, email_id
  - CREATE partial indexes for common query patterns
  - ENABLE Row Level Security with optimized policies

Task 2: Core Performance Infrastructure
CREATE api/utils/time_tracking_cache.py:
  - IMPLEMENT HighPerformanceCache class with LRU eviction
  - ADD cache decorators for async functions
  - INCLUDE memory monitoring and metrics
  - IMPLEMENT cache warming strategies

CREATE api/utils/time_tracking_processor.py:
  - IMPLEMENT BatchProcessor with asyncio.Semaphore for concurrency control
  - ADD memory-efficient email streaming
  - IMPLEMENT exponential backoff for rate limiting
  - CREATE connection pooling for database operations

Task 3: Pydantic Models and Validation
CREATE api/utils/time_tracking_schemas.py:
  - MIRROR pattern from: api/utils/email_schemas.py
  - IMPLEMENT optimized BillableTimeEntry model
  - ADD validation for time ranges and business rules
  - CREATE batch processing parameter models

Task 4: Core Tool Implementation
CREATE api/utils/time_tracking_tools.py:
  - IMPLEMENT scan_billable_time with batch processing
  - IMPLEMENT analyze_time_entry for single email analysis
  - IMPLEMENT get_time_tracking_summary with aggregation
  - IMPLEMENT configure_time_tracking for settings
  - MIRROR dependency injection pattern from existing tools

Task 5: OpenAI Integration and Registration
MODIFY api/index.py:
  - FIND pattern: "available_tools = {"
  - ADD time tracking tools to available_tools dictionary
  - INJECT OpenAI function schemas in stream_text function
  - PRESERVE existing error handling patterns

Task 6: Performance Testing Suite
CREATE api/tests/test_time_tracking_performance.py:
  - MIRROR pattern from: api/tests/test_triage_performance.py
  - IMPLEMENT load testing for concurrent operations
  - ADD memory usage profiling
  - CREATE benchmark tests for scalability validation

Task 7: Integration and Optimization
MODIFY api/utils/time_tracking_tools.py:
  - ADD performance monitoring and logging
  - IMPLEMENT circuit breaker pattern for external API calls
  - ADD graceful degradation for high load scenarios
  - OPTIMIZE database queries with batching
```

### Task-Specific Performance Pseudocode

```python
# Task 1: Database Schema Optimization
# Optimized indexes for common query patterns
CREATE INDEX CONCURRENTLY idx_time_entries_user_date
ON time_tracking_entries (user_id, date_performed DESC);

CREATE INDEX CONCURRENTLY idx_time_entries_email_lookup
ON time_tracking_entries (user_id, email_id);

# Partial index for recent entries (performance optimization)
CREATE INDEX CONCURRENTLY idx_time_entries_recent
ON time_tracking_entries (user_id, created_at)
WHERE created_at > NOW() - INTERVAL '30 days';

# Task 4: Core Tool Implementation with Performance Focus
@cached_async(ttl_seconds=1800)  # 30-minute cache
async def scan_billable_time(
    params: ScanBillableTimeParams,
    service: Resource = Depends(get_gmail_service),
    openai_client: OpenAI = Depends(get_openai_client),
    user_id: str = Depends(get_current_user_id),
    supabase_client: Client = Depends(get_supabase_client),
) -> BatchProcessingResult:
    """High-performance email scanning for billable time"""

    start_time = time.time()
    semaphore = asyncio.Semaphore(10)  # Limit concurrent operations

    # PERFORMANCE: Stream emails instead of loading all
    async def process_email_batch(email_ids: List[str]) -> List[BillableTimeEntry]:
        async with semaphore:
            # PATTERN: Batch Gmail API calls for efficiency
            emails = await asyncio.gather(
                *[get_email_with_retry(service, email_id) for email_id in email_ids],
                return_exceptions=True
            )

            # PERFORMANCE: Filter out exceptions and process valid emails
            valid_emails = [e for e in emails if not isinstance(e, Exception)]

            # PATTERN: Batch OpenAI calls with rate limiting
            await rate_limiter.acquire(len(valid_emails))

            # PERFORMANCE: Process in parallel with memory bounds
            tasks = []
            for email in valid_emails:
                task = analyze_email_for_time(email, openai_client, user_id)
                tasks.append(task)

                # CRITICAL: Prevent memory exhaustion
                if len(tasks) >= 20:
                    batch_results = await asyncio.gather(*tasks, return_exceptions=True)
                    tasks = []
                    yield [r for r in batch_results if isinstance(r, BillableTimeEntry)]

            # Process remaining
            if tasks:
                batch_results = await asyncio.gather(*tasks, return_exceptions=True)
                yield [r for r in batch_results if isinstance(r, BillableTimeEntry)]

    # PERFORMANCE: Bulk database operations
    async def bulk_store_entries(entries: List[BillableTimeEntry]):
        # Convert to dict format for bulk insert
        entry_dicts = [entry.model_dump() for entry in entries]

        # PATTERN: Use bulk upsert for performance
        result = await supabase_client.table("time_tracking_entries")\
            .upsert(entry_dicts, on_conflict="user_id,email_id")\
            .execute()

        return len(result.data) if result.data else 0

# Task 6: Performance Testing Implementation
@pytest.mark.performance
async def test_concurrent_time_scanning():
    """Test concurrent scanning performance"""

    # Setup concurrent users
    concurrent_users = 5
    emails_per_user = 20

    async def scan_for_user(user_id: str) -> BatchProcessingResult:
        params = ScanBillableTimeParams(max_emails=emails_per_user)
        return await scan_billable_time(params, mock_service, mock_client, user_id, mock_db)

    # PERFORMANCE: Measure concurrent execution
    start_time = time.time()
    results = await asyncio.gather(
        *[scan_for_user(f"user_{i}") for i in range(concurrent_users)]
    )
    total_time = time.time() - start_time

    # VALIDATION: Performance assertions
    assert total_time < 45.0  # Should complete within 45 seconds
    assert all(r.total_processed == emails_per_user for r in results)

    # VALIDATION: Resource usage
    total_emails = sum(r.total_processed for r in results)
    throughput = total_emails / total_time
    assert throughput > 2.0  # At least 2 emails/second with concurrency
```

### Integration Points

```yaml
DATABASE:
  - migration: "CREATE time_tracking_entries table with performance indexes"
  - indexes: "Composite indexes on (user_id, date_performed), (user_id, email_id)"
  - policies: "RLS policies for user isolation with query optimization"

CACHING:
  - layer: "In-memory LRU cache with TTL expiration"
  - redis: "Optional Redis integration for distributed caching"
  - warming: "Pre-populate cache with frequently accessed data"

API_LIMITS:
  - openai: "Rate limiting with exponential backoff (3500 RPM)"
  - gmail: "Quota management (250 units/user/second)"
  - concurrent: "Semaphore-based concurrency control (10 max)"

MONITORING:
  - metrics: "Performance counters for cache hit rate, response times"
  - logging: "Structured logging for performance debugging"
  - alerts: "Threshold alerts for degraded performance"
```

## Validation Loop

### Level 1: Syntax & Performance Analysis

```bash
# Performance-focused validation
ruff check api/utils/time_tracking*.py --fix
mypy api/utils/time_tracking*.py --strict
bandit api/utils/time_tracking*.py  # Security analysis

# Memory profiling
python -m memory_profiler api/utils/time_tracking_tools.py

# Expected: No errors, memory usage <50MB baseline
```

### Level 2: Performance Unit Tests

```python
# Performance-specific test cases
def test_cache_performance():
    """Cache hit rate >80% for repeated queries"""
    cache = HighPerformanceCache()

    # Warm cache
    for i in range(100):
        cache.set(f"key_{i}", f"value_{i}")

    # Test hit rate
    hits = sum(1 for i in range(100) if cache.get(f"key_{i}") is not None)
    assert hits >= 80  # >80% hit rate

@pytest.mark.asyncio
async def test_concurrent_processing_limits():
    """Verify semaphore limits concurrent operations"""
    semaphore = asyncio.Semaphore(10)
    active_count = 0
    max_active = 0

    async def mock_operation():
        nonlocal active_count, max_active
        async with semaphore:
            active_count += 1
            max_active = max(max_active, active_count)
            await asyncio.sleep(0.1)
            active_count -= 1

    # Launch 50 concurrent operations
    await asyncio.gather(*[mock_operation() for _ in range(50)])

    assert max_active <= 10  # Never exceed semaphore limit

def test_memory_efficiency():
    """Verify memory usage stays within bounds"""
    import psutil
    import os

    process = psutil.Process(os.getpid())
    initial_memory = process.memory_info().rss

    # Process large batch
    entries = [create_mock_time_entry() for _ in range(1000)]

    final_memory = process.memory_info().rss
    memory_increase = (final_memory - initial_memory) / 1024 / 1024  # MB

    assert memory_increase < 100  # Less than 100MB increase
```

### Level 3: Load Testing & Benchmarks

```bash
# Performance benchmarking
pytest api/tests/test_time_tracking_performance.py::test_load_testing -v

# Concurrent user simulation
pytest api/tests/test_time_tracking_concurrency.py -v --tb=short

# Memory profiling during load
python -m pytest api/tests/test_time_tracking_performance.py::test_memory_usage \
  --memprof --memprof-top-n 10

# Database performance analysis
psql -h localhost -d supabase_test -c "EXPLAIN ANALYZE SELECT * FROM time_tracking_entries WHERE user_id = 'test' ORDER BY date_performed DESC LIMIT 50;"

# Expected Results:
# - Single email analysis: <2s
# - Batch processing (50 emails): <30s
# - Concurrent users (10): No degradation
# - Memory usage: <100MB per batch
# - Database queries: <100ms response time
```

### Level 4: Production Performance Validation

```bash
# Load testing with realistic data
artillery run performance/time-tracking-load-test.yml

# Memory leak detection
valgrind --tool=memcheck --leak-check=full python -m api.utils.time_tracking_tools

# Database performance monitoring
pgbench -h localhost -U postgres -d supabase_test -f performance/time_tracking_queries.sql -T 60

# API rate limit compliance testing
python scripts/test_rate_limits.py --service openai --limit 3500 --duration 60
python scripts/test_rate_limits.py --service gmail --limit 250 --duration 1

# Expected Metrics:
# - 95th percentile response time: <5s
# - Error rate: <1%
# - Cache hit rate: >80%
# - Memory growth: <10MB/hour
# - CPU usage: <50% under load
```

## Performance Optimization Checklist

- [ ] **Caching**: LRU cache with TTL, >80% hit rate
- [ ] **Concurrency**: asyncio.Semaphore limiting to 10 operations
- [ ] **Memory**: Streaming processing, <100MB per batch
- [ ] **Database**: Optimized indexes, <100ms query time
- [ ] **Rate Limiting**: Exponential backoff, API compliance
- [ ] **Batch Processing**: 50-email batches, bulk operations
- [ ] **Connection Pooling**: Reuse Gmail/DB connections
- [ ] **Garbage Collection**: Explicit cleanup of large objects
- [ ] **Monitoring**: Performance metrics and alerting
- [ ] **Load Testing**: Validated under production load

## Performance Validation Gates

```yaml
Performance Requirements:
  single_email_analysis: "<2s response time"
  batch_processing_50: "<30s total time"
  concurrent_users_10: "No >20% degradation"
  memory_usage_batch: "<100MB per 50 emails"
  cache_hit_rate: ">80% for repeated queries"
  database_queries: "<100ms average response"
  api_compliance: "Within OpenAI (3500 RPM) and Gmail (250/user/s) limits"
  throughput: ">5 emails/second aggregate"
  error_rate: "<1% under normal load"
  memory_leaks: "<10MB growth per hour"

Load Testing Scenarios:
  concurrent_users: "10 users, 50 emails each"
  sustained_load: "1000 emails/hour for 4 hours"
  burst_traffic: "500 emails in 5 minutes"
  memory_stress: "Process 1000 emails without restart"
```

---

## Anti-Patterns to Avoid

- ❌ Don't process emails synchronously - use asyncio.gather for batches
- ❌ Don't load all emails into memory - use streaming processing
- ❌ Don't ignore rate limits - implement exponential backoff
- ❌ Don't skip caching - implement multi-layer caching strategy
- ❌ Don't use blocking database operations - use async Supabase client
- ❌ Don't create unlimited concurrent operations - use Semaphore
- ❌ Don't ignore memory management - explicit cleanup and monitoring
- ❌ Don't skip performance testing - validate under realistic load
- ❌ Don't hardcode performance limits - make them configurable
- ❌ Don't ignore error handling in concurrent operations - use return_exceptions=True

## Expected Performance Improvements

**Baseline (Sequential Processing)**:

- Single email: 3-5s
- 50 emails: 150-250s (sequential)
- Memory usage: 200MB+ (all emails in memory)
- No caching: Every request hits APIs

**Optimized (Concurrent + Cached)**:

- Single email: <2s (cache hit <0.1s)
- 50 emails: <30s (10x improvement)
- Memory usage: <100MB (streaming)
- Cache hit rate: >80%
- Throughput: 5-10x improvement with concurrency

**Scalability Impact**:

- Support 10+ concurrent users (vs 2-3 baseline)
- Handle 1000+ emails/hour (vs 200-300 baseline)
- Reduce API costs by 80% through caching
- Improve user experience with sub-second responses
