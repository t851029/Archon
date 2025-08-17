name: "Feature-Flagged Retainer Letter Drafter - Incremental Rollout Implementation"
description: |
  Comprehensive PRP for implementing an AI-powered retainer letter drafter with multi-level feature flags enabling progressive rollout, A/B testing, instant disable capabilities, and granular control at database, API, and frontend levels.

---

## Goal

Implement a feature-flag-driven retainer letter generation system that enables progressive rollout with real-time control, comprehensive monitoring, and instant rollback capabilities without code deployments. The system will use multi-level feature flags (database, API, frontend) to provide granular control over feature availability per user, organization segment, or percentage-based cohorts.

**Feature Goal**: Deploy retainer letter functionality behind comprehensive feature flags allowing controlled rollout, A/B testing, usage monitoring, and instant disable without deployments.

**Deliverable**: Production-ready feature flag system integrated with retainer letter generation, supporting percentage rollouts, user targeting, A/B testing, and emergency kill switches.

**Success Definition**:
- Feature flags control access at database, API, and UI levels independently
- Percentage-based rollout from 0% to 100% users
- User segment targeting (beta testers, specific organizations, jurisdictions)
- Real-time toggle without deployments (< 5 second propagation)
- Comprehensive flag state monitoring and analytics
- Zero-downtime rollback capability

## Why

- **Risk Mitigation**: Legal document generation requires careful rollout to ensure compliance
- **Progressive Validation**: Test with beta users before general availability
- **Instant Rollback**: Critical for legal features - disable instantly if issues arise
- **A/B Testing**: Compare AI-generated vs traditional methods for quality metrics
- **Compliance Control**: Enable per-jurisdiction based on regulatory approval
- **Performance Management**: Control load by limiting concurrent users
- **Cost Control**: Monitor and cap AI usage costs during rollout
- **User Feedback**: Gather metrics from early adopters before full launch

## What

### User-Visible Behavior

**For End Users**:
- Feature appears/disappears based on flag state
- Seamless experience when enabled
- Graceful degradation when disabled
- Clear messaging about beta/preview status

**For Administrators**:
- Feature flag dashboard showing current state
- User segment configuration interface
- Rollout percentage controls
- Emergency kill switch button
- Usage analytics and metrics
- A/B test results visualization

### Technical Requirements

**Feature Flag Infrastructure**:
- Multi-level flags (DB, API, UI) for defense in depth
- LaunchDarkly SDK integration (or Unleash for open-source)
- Flag evaluation caching for performance
- Fallback mechanisms for service outages
- Audit logging of all flag changes

**Flag Hierarchy**:
```yaml
retainer-letter-master:           # Master kill switch
  retainer-letter-api:           # API availability
    retainer-letter-generation:  # Document generation
    retainer-letter-templates:   # Template selection
  retainer-letter-ui:            # UI visibility
    retainer-letter-settings:    # Settings dialog
    retainer-letter-preview:     # Preview functionality
  retainer-letter-email:         # Email integration
    retainer-letter-agent:       # Agent email feature
    retainer-letter-drafts:      # Gmail draft creation
```

**Targeting Capabilities**:
- User ID targeting (specific beta testers)
- Organization/team targeting (enterprise clients)
- Percentage rollout (0-100% of users)
- Geographic targeting (jurisdiction-based)
- Plan-based targeting (premium features)
- Time-based targeting (scheduled rollouts)

### Success Criteria

- [ ] LaunchDarkly/Unleash SDK integrated and configured
- [ ] Multi-level feature flags controlling all aspects
- [ ] Percentage rollout working from 0% to 100%
- [ ] User segment targeting functional
- [ ] Real-time toggle propagation < 5 seconds
- [ ] Flag state monitoring dashboard operational
- [ ] Emergency kill switch tested and verified
- [ ] A/B test metrics being collected
- [ ] Audit log capturing all flag changes
- [ ] Performance impact < 10ms per flag evaluation
- [ ] Fallback behavior working when flag service down

## All Needed Context

### Documentation & References

```yaml
# Feature Flag Service Documentation
- url: https://docs.launchdarkly.com/sdk/server-side/python
  why: LaunchDarkly Python SDK for FastAPI integration
  section: "Getting started" - SDK initialization patterns
  critical: Singleton pattern and connection management

- url: https://docs.launchdarkly.com/sdk/client-side/react/react-web
  why: React SDK for frontend feature flags
  section: "React Web SDK" - Hook-based flag evaluation
  critical: withLDProvider HOC and useFlags hook patterns

- url: https://docs.getunleash.io/reference/sdks/python
  why: Open-source alternative - Unleash Python SDK
  section: "Python SDK" - Self-hosted option for compliance
  critical: Strategy configuration and custom contexts

- url: https://www.getunleash.io/blog/progressive-rollout-strategies
  why: Best practices for progressive feature rollouts
  section: "Gradual rollout" - Percentage-based strategies
  critical: Stickiness and user consistency

# Internal Context
- file: api/core/config.py
  why: Configuration management for feature flag settings
  critical: Lines 14-86 show environment-based configuration pattern

- file: api/index.py
  why: Main API entry point for flag integration
  critical: Lines 167-185 tool registration, lines 525-1361 streaming

- file: api/utils/tools.py
  why: Tool system that will be flag-controlled
  critical: Lines 1819-2000 legal patterns, 1217-1300 auto-draft patterns

- file: apps/web/app/api/tools/[toolId]/toggle/route.ts
  why: Existing toggle patterns to extend with flags
  critical: Lines 36-204 show tool enable/disable patterns

- file: apps/web/lib/tools-config.ts
  why: Frontend tool configuration for flag integration
  critical: Tool interface and category patterns

- file: PRPs/backlog/retainer/ai-powered-retainer-letter-drafter.md
  why: Complete retainer letter feature specification
  critical: All implementation details and patterns

- file: PRPs/basic-observability-implementation.md
  why: Monitoring patterns for flag state tracking
  critical: Lines 223-515 metrics and dashboard patterns

- docfile: PRPs/ai_docs/legal-document-automation-patterns-2025.md
  why: Legal compliance requirements for feature flags
  critical: Jurisdiction-based controls and audit requirements
```

### Current Codebase Tree

```bash
api/
├── core/
│   ├── config.py              # Environment configuration
│   ├── dependencies.py        # Shared dependencies
│   └── auth.py               # Authentication
├── utils/
│   ├── tools.py              # Tool implementations
│   ├── gmail_helpers.py      # Email functionality
│   └── email_schemas.py      # Validation models
├── services/                 # Service layer (from observability)
│   └── observability_service.py
└── index.py                  # Main FastAPI app

apps/web/
├── app/api/tools/[toolId]/
│   └── toggle/route.ts       # Tool toggle API
├── lib/
│   ├── tools-config.ts       # Tool configuration
│   └── env.ts               # Environment vars
├── components/
│   └── tools/               # Tool UI components
└── hooks/                   # React hooks

supabase/
└── migrations/              # Database migrations
```

### Desired Codebase Tree with Feature Flag Additions

```bash
api/
├── core/
│   ├── feature_flags.py      # NEW: Feature flag service
│   └── flag_config.py        # NEW: Flag definitions
├── services/
│   ├── flag_service.py       # NEW: Flag evaluation service
│   ├── flag_analytics.py     # NEW: Flag usage analytics
│   └── retainer_service.py   # NEW: Retainer generation
├── middleware/
│   └── feature_flag_middleware.py  # NEW: Flag context
├── models/
│   └── feature_flags.py      # NEW: Flag data models
└── utils/
    └── flag_decorators.py     # NEW: Python decorators

apps/web/
├── providers/
│   └── feature-flag-provider.tsx  # NEW: React context
├── hooks/
│   ├── use-feature-flag.ts   # NEW: Flag evaluation hook
│   └── use-flag-analytics.ts # NEW: Analytics hook
├── components/
│   ├── feature-flag-gate.tsx # NEW: Conditional rendering
│   └── flag-admin/           # NEW: Admin dashboard
│       ├── flag-dashboard.tsx
│       ├── flag-controls.tsx
│       └── flag-metrics.tsx
├── lib/
│   ├── feature-flags.ts      # NEW: Flag client
│   └── flag-config.ts        # NEW: Flag definitions
└── app/api/
    ├── flags/                # NEW: Flag API routes
    │   ├── evaluate/route.ts
    │   └── admin/route.ts
    └── webhooks/
        └── launchdarkly/route.ts  # NEW: Flag webhooks

supabase/migrations/
├── 20250817000001_add_feature_flag_tables.sql  # NEW
└── 20250817000002_add_flag_audit_tables.sql    # NEW
```

### Known Gotchas

```python
# CRITICAL: LaunchDarkly SDK Singleton Pattern
# The SDK client MUST be a singleton - multiple instances cause issues
# Initialize once in app lifespan, not per request
ldclient.set_config(Config(sdk_key))
client = ldclient.get()  # Singleton access

# CRITICAL: Feature Flag Evaluation Context
# Always include user context for consistent targeting
context = Context.builder("user_123").set("email", "user@example.com").build()
flag_value = client.variation("retainer-letter-master", context, False)

# GOTCHA: Flag Evaluation Caching
# LaunchDarkly caches for 5 seconds by default
# For real-time updates, use streaming connections
config = Config(
    sdk_key=LAUNCHDARKLY_SDK_KEY,
    stream=True,  # Enable streaming for real-time
    cache_time=0  # Disable caching for immediate updates
)

# CRITICAL: Fallback Values
# ALWAYS provide fallback when flag service unavailable
try:
    enabled = client.variation("flag-key", context, False)  # False = fallback
except Exception as e:
    logger.error(f"Flag evaluation failed: {e}")
    enabled = False  # Safe default

# GOTCHA: React SDK Initialization
// Must wrap app with provider at root level
import { withLDProvider } from 'launchdarkly-react-client-sdk';
const App = withLDProvider({
  clientSideID: 'your-client-side-id',
  options: {
    streaming: true,  // Real-time updates
    sendEvents: true  // Analytics
  }
})(YourApp);

# CRITICAL: Database Flag Checks
-- Add flag column to control at DB level
ALTER TABLE retainer_letter_settings 
ADD COLUMN feature_flags JSONB DEFAULT '{"enabled": false}';

-- Check flags in RLS policies
CREATE POLICY "Feature flag check" ON retainer_letter_settings
USING (
  (feature_flags->>'enabled')::boolean = true 
  AND user_id = auth.jwt() ->> 'sub'
);

# GOTCHA: A/B Test Variant Consistency
# Use "stickiness" to ensure users stay in same variant
{
  "key": "retainer-ai-model",
  "variations": ["gpt-4o", "gpt-4o-mini"],
  "targets": [],
  "rules": [{
    "variation": 0,
    "rollout": {
      "variations": [
        {"variation": 0, "weight": 50000},  # 50% to GPT-4o
        {"variation": 1, "weight": 50000}   # 50% to GPT-4o-mini
      ],
      "bucketBy": "key"  # Sticky by user key
    }
  }]
}

# CRITICAL: Emergency Kill Switch Pattern
# Implement multiple levels of kill switches
async def check_feature_enabled(user_id: str, feature: str) -> bool:
    # Level 1: Master kill switch
    if not await flag_service.is_enabled("master-kill-switch", user_id):
        return False
    
    # Level 2: Feature-specific kill switch
    if not await flag_service.is_enabled(f"{feature}-kill-switch", user_id):
        return False
    
    # Level 3: User-specific flag
    return await flag_service.is_enabled(feature, user_id)

# GOTCHA: Flag State Monitoring
# Log all flag evaluations for debugging
@dataclass
class FlagEvaluation:
    flag_key: str
    user_id: str
    value: Any
    reason: str  # Why this value was returned
    timestamp: datetime
    
# Store in time-series table for analysis
```

## Implementation Blueprint

### Data Models and Structure

```python
# api/models/feature_flags.py
from pydantic import BaseModel, Field
from typing import Optional, Literal, Dict, Any, List
from datetime import datetime
from enum import Enum

class FlagType(str, Enum):
    BOOLEAN = "boolean"
    STRING = "string"
    NUMBER = "number"
    JSON = "json"

class FlagTarget(BaseModel):
    """User or segment targeting rules"""
    user_ids: List[str] = []
    organizations: List[str] = []
    segments: List[str] = []
    percentage: Optional[float] = None  # 0-100
    attributes: Dict[str, Any] = {}  # Custom targeting

class FeatureFlag(BaseModel):
    """Feature flag configuration"""
    key: str
    name: str
    description: str
    flag_type: FlagType = FlagType.BOOLEAN
    default_value: Any
    enabled: bool = False
    targets: FlagTarget
    variants: Optional[Dict[str, Any]] = None  # For A/B tests
    prerequisites: List[str] = []  # Dependent flags
    schedule: Optional[Dict[str, datetime]] = None  # Time-based
    
class FlagEvaluation(BaseModel):
    """Result of flag evaluation"""
    flag_key: str
    user_id: str
    value: Any
    variation_index: Optional[int] = None
    reason: str
    timestamp: datetime = Field(default_factory=datetime.utcnow)
    
class FlagAuditLog(BaseModel):
    """Audit log for flag changes"""
    flag_key: str
    action: Literal["created", "updated", "deleted", "evaluated"]
    user_id: str  # Who made the change
    old_value: Optional[Any] = None
    new_value: Optional[Any] = None
    reason: Optional[str] = None
    timestamp: datetime = Field(default_factory=datetime.utcnow)
```

### Task List (Priority-Ordered Implementation)

```yaml
Task 1: Database Schema for Feature Flags
PRIORITY: CRITICAL
CREATE supabase/migrations/20250817000001_add_feature_flag_tables.sql:
  - Create feature_flags table for flag configuration
  - Create flag_evaluations table for usage tracking
  - Create flag_audit_log table for compliance
  - Create user_segments table for targeting
  - Add feature_flags JSONB column to existing tables
  - Implement RLS policies with flag checks
  - Create indexes for performance
VALIDATION: npx supabase db push && pnpm types

Task 2: Core Feature Flag Service
PRIORITY: CRITICAL
CREATE api/core/feature_flags.py:
  - Initialize LaunchDarkly client as singleton
  - Implement fallback to database flags
  - Add flag evaluation with context
  - Create caching layer for performance
  - Add circuit breaker for resilience
IMPLEMENT patterns:
  - Singleton client initialization
  - Graceful degradation on service failure
  - Context building from user data
  - Variant consistency via bucketing
VALIDATION: pytest api/tests/test_feature_flags.py -v

Task 3: Flag Configuration and Definitions
PRIORITY: HIGH
CREATE api/core/flag_config.py:
  - Define flag hierarchy structure
  - Set default values and fallbacks
  - Configure targeting rules
  - Define A/B test variants
  - Set up prerequisite dependencies
DEFINE flags:
  - retainer-letter-master (kill switch)
  - retainer-letter-api-enabled
  - retainer-letter-ui-visible
  - retainer-letter-generation-model (A/B test)
  - retainer-letter-beta-users
VALIDATION: Verify flag structure in LaunchDarkly dashboard

Task 4: API Integration with Decorators
PRIORITY: HIGH
CREATE api/utils/flag_decorators.py:
  - @feature_flag decorator for endpoints
  - @flag_variant decorator for A/B tests
  - @flag_metric decorator for analytics
  - Context extraction from requests
  - Graceful degradation handling
MODIFY api/utils/tools.py:
  - WRAP generate_retainer_letter with @feature_flag
  - ADD variant selection for model choice
  - INJECT flag checks at critical points
  - PRESERVE existing functionality
VALIDATION: Test endpoints with flags on/off

Task 5: Frontend Provider and Context
PRIORITY: HIGH
CREATE apps/web/providers/feature-flag-provider.tsx:
  - Initialize LaunchDarkly React SDK
  - Provide flag context to app
  - Handle loading and error states
  - Set up user context from Clerk
  - Enable real-time streaming
MODIFY apps/web/app/layout.tsx:
  - WRAP app with FeatureFlagProvider
  - PASS user context from auth
  - CONFIGURE client-side ID
VALIDATION: Check flag availability in React DevTools

Task 6: React Hooks for Flag Evaluation
PRIORITY: HIGH
CREATE apps/web/hooks/use-feature-flag.ts:
  - useFeatureFlag() for boolean flags
  - useFeatureVariant() for A/B tests
  - useFlagLoading() for loading state
  - useFlagMetrics() for analytics
  - Memoization for performance
CREATE apps/web/components/feature-flag-gate.tsx:
  - Conditional rendering component
  - Loading state handling
  - Fallback UI for disabled features
  - Debug mode for development
VALIDATION: pnpm test flag components

Task 7: Retainer Letter Feature Integration
PRIORITY: HIGH
MODIFY apps/web/lib/tools-config.ts:
  - ADD flag checks to tool availability
  - CONDITIONALLY show retainer tools
  - PRESERVE existing tool logic
MODIFY apps/web/app/api/tools/[toolId]/toggle/route.ts:
  - CHECK feature flags before enabling
  - RETURN appropriate error if flagged off
  - LOG flag evaluation for analytics
MODIFY api/index.py:
  - ADD flag check to tool registration
  - CONDITIONALLY include in available_tools
  - TRACK usage metrics
VALIDATION: Feature appears/disappears based on flags

Task 8: Flag Administration Dashboard
PRIORITY: MEDIUM
CREATE apps/web/app/(app)/admin/flags/page.tsx:
  - Display all feature flags and states
  - Show current rollout percentages
  - Display user segments and targeting
  - Real-time flag state updates
  - Emergency kill switch controls
CREATE apps/web/components/flag-admin/flag-controls.tsx:
  - Toggle switches for flags
  - Percentage sliders for rollout
  - User segment management
  - A/B test configuration
  - Audit log viewer
VALIDATION: Admin can control flags in real-time

Task 9: Flag Analytics and Monitoring
PRIORITY: MEDIUM
CREATE api/services/flag_analytics.py:
  - Track flag evaluations
  - Calculate exposure metrics
  - Monitor performance impact
  - Generate usage reports
  - A/B test statistical analysis
CREATE apps/web/components/flag-admin/flag-metrics.tsx:
  - Usage charts and graphs
  - A/B test conversion metrics
  - Performance impact visualization
  - User segment analytics
  - Export functionality
INTEGRATE with observability:
  - Add flag dimensions to metrics
  - Track feature usage by flag state
  - Monitor flag evaluation latency
VALIDATION: Metrics appear in dashboard

Task 10: Emergency Kill Switch Implementation
PRIORITY: HIGH
CREATE api/middleware/feature_flag_middleware.py:
  - Global flag check middleware
  - Circuit breaker implementation
  - Rate limiting by flag state
  - Emergency response handling
CREATE apps/web/app/api/flags/emergency/route.ts:
  - Instant kill switch endpoint
  - Broadcast to all services
  - Cache invalidation
  - Audit logging
ADD to admin dashboard:
  - Big red emergency button
  - Confirmation dialog
  - Instant propagation
  - Rollback capability
VALIDATION: Kill switch disables feature < 5 seconds

Task 11: A/B Testing Framework
PRIORITY: MEDIUM
CREATE api/services/ab_test_service.py:
  - Variant assignment logic
  - Conversion tracking
  - Statistical significance calculation
  - Test result aggregation
  - Automated winner selection
MODIFY retainer generation:
  - Support multiple AI models
  - Track generation quality metrics
  - Compare costs per variant
  - Monitor user satisfaction
VALIDATION: Users consistently get same variant

Task 12: Progressive Rollout Automation
PRIORITY: LOW
CREATE api/services/rollout_service.py:
  - Scheduled rollout increases
  - Automatic rollback on errors
  - Health check integration
  - Rollout pause/resume
  - Notification system
CONFIGURE rollout strategy:
  - Start at 1% for 24 hours
  - Increase to 5% if metrics good
  - Then 10%, 25%, 50%, 100%
  - Auto-rollback if errors > threshold
VALIDATION: Rollout progresses automatically

Task 13: Compliance and Audit Logging
PRIORITY: HIGH
CREATE api/services/flag_audit_service.py:
  - Log all flag changes
  - Track who changed what when
  - Compliance report generation
  - Data retention policies
  - Export for legal review
IMPLEMENT requirements:
  - GDPR compliance for EU users
  - Jurisdiction-based controls
  - Audit trail for 7 years
  - Encrypted storage
VALIDATION: Audit log captures all changes

Task 14: Testing and Documentation
PRIORITY: CRITICAL
CREATE api/tests/test_feature_flag_integration.py:
  - End-to-end flag testing
  - Rollout simulation
  - Kill switch testing
  - A/B test validation
  - Performance benchmarks
CREATE docs/feature-flags.md:
  - Flag naming conventions
  - Rollout procedures
  - Emergency protocols
  - A/B test guidelines
  - Troubleshooting guide
VALIDATION: All tests pass, docs complete
```

### Per-Task Pseudocode

```python
# Task 2: Core Feature Flag Service
# api/core/feature_flags.py
import ldclient
from ldclient import Context, Config
from typing import Any, Optional
import asyncio
from functools import lru_cache

class FeatureFlagService:
    _instance = None
    _client = None
    
    def __new__(cls):
        # Singleton pattern
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def __init__(self):
        if self._client is None:
            # Initialize once
            config = Config(
                sdk_key=settings.LAUNCHDARKLY_SDK_KEY,
                stream=True,  # Real-time updates
                cache_time=0,  # No caching for immediate updates
                offline=settings.ENVIRONMENT == "test"  # Offline in tests
            )
            ldclient.set_config(config)
            self._client = ldclient.get()
            
            # Wait for initialization
            if not self._client.is_initialized():
                self._client.wait_for_initialization(5)
    
    async def evaluate(
        self,
        flag_key: str,
        user_id: str,
        default: Any = False,
        attributes: dict = None
    ) -> Any:
        """Evaluate feature flag with fallback"""
        try:
            # Build context with user attributes
            context_builder = Context.builder(user_id)
            
            if attributes:
                for key, value in attributes.items():
                    context_builder.set(key, value)
            
            context = context_builder.build()
            
            # Evaluate with timeout
            value = await asyncio.wait_for(
                asyncio.to_thread(
                    self._client.variation,
                    flag_key,
                    context,
                    default
                ),
                timeout=1.0  # 1 second timeout
            )
            
            # Log evaluation for analytics
            await self._log_evaluation(flag_key, user_id, value)
            
            return value
            
        except asyncio.TimeoutError:
            logger.warning(f"Flag evaluation timeout: {flag_key}")
            return default
        except Exception as e:
            logger.error(f"Flag evaluation error: {e}")
            # Fallback to database or cache
            return await self._fallback_evaluation(flag_key, user_id, default)
    
    async def _fallback_evaluation(
        self,
        flag_key: str,
        user_id: str,
        default: Any
    ) -> Any:
        """Fallback to database when LaunchDarkly unavailable"""
        # Check database for flag state
        result = await supabase.from_("feature_flags") \
            .select("value, targets") \
            .eq("key", flag_key) \
            .single() \
            .execute()
        
        if result.data:
            # Check if user matches targeting
            if self._matches_target(user_id, result.data.targets):
                return result.data.value
        
        return default

# Task 4: API Decorators
# api/utils/flag_decorators.py
from functools import wraps
from typing import Callable
import inspect

def feature_flag(flag_key: str, default: bool = False):
    """Decorator to control endpoint access via feature flags"""
    def decorator(func: Callable) -> Callable:
        @wraps(func)
        async def async_wrapper(*args, **kwargs):
            # Extract user_id from function arguments
            sig = inspect.signature(func)
            bound = sig.bind(*args, **kwargs)
            bound.apply_defaults()
            
            user_id = bound.arguments.get('user_id')
            if not user_id:
                # Try to get from request context
                request = bound.arguments.get('request')
                if request:
                    user_id = getattr(request.state, 'user_id', None)
            
            if not user_id:
                logger.warning(f"No user_id for flag evaluation: {flag_key}")
                if not default:
                    raise HTTPException(
                        status_code=403,
                        detail="Feature not available"
                    )
            
            # Evaluate flag
            flag_service = FeatureFlagService()
            enabled = await flag_service.evaluate(
                flag_key,
                user_id,
                default
            )
            
            if not enabled:
                raise HTTPException(
                    status_code=403,
                    detail=f"Feature '{flag_key}' is not enabled for this user"
                )
            
            # Call original function
            return await func(*args, **kwargs)
        
        # Handle sync functions
        @wraps(func)
        def sync_wrapper(*args, **kwargs):
            # Similar logic for sync functions
            pass
        
        if inspect.iscoroutinefunction(func):
            return async_wrapper
        else:
            return sync_wrapper
    
    return decorator

# Task 5: React Provider
// apps/web/providers/feature-flag-provider.tsx
import { withLDProvider, useLDClient } from 'launchdarkly-react-client-sdk';
import { useAuth } from '@clerk/nextjs';
import { createContext, useContext, useEffect } from 'react';

const FeatureFlagContext = createContext({});

function FeatureFlagProviderInner({ children }) {
  const { userId, user } = useAuth();
  const ldClient = useLDClient();
  
  useEffect(() => {
    if (ldClient && userId) {
      // Update user context when auth changes
      ldClient.identify({
        key: userId,
        email: user?.primaryEmailAddress?.emailAddress,
        custom: {
          organization: user?.organizationId,
          plan: user?.publicMetadata?.plan || 'free',
          jurisdiction: user?.publicMetadata?.jurisdiction
        }
      });
    }
  }, [ldClient, userId, user]);
  
  return (
    <FeatureFlagContext.Provider value={{ ldClient }}>
      {children}
    </FeatureFlagContext.Provider>
  );
}

// Wrap with LaunchDarkly provider
export const FeatureFlagProvider = withLDProvider({
  clientSideID: process.env.NEXT_PUBLIC_LAUNCHDARKLY_CLIENT_ID,
  options: {
    streaming: true,
    sendEvents: true,
    allAttributesPrivate: false,
    privateAttributes: ['email']
  }
})(FeatureFlagProviderInner);

# Task 6: React Hooks
// apps/web/hooks/use-feature-flag.ts
import { useFlags, useLDClient } from 'launchdarkly-react-client-sdk';
import { useCallback, useMemo } from 'react';

export function useFeatureFlag(flagKey: string, defaultValue = false) {
  const flags = useFlags();
  const client = useLDClient();
  
  const value = useMemo(() => {
    return flags[flagKey] ?? defaultValue;
  }, [flags, flagKey, defaultValue]);
  
  const track = useCallback((event: string, data?: any) => {
    client?.track(event, data);
  }, [client]);
  
  return { enabled: value, track };
}

export function useFeatureVariant(flagKey: string, defaultVariant: string) {
  const flags = useFlags();
  
  const variant = useMemo(() => {
    return flags[flagKey] ?? defaultVariant;
  }, [flags, flagKey, defaultVariant]);
  
  return variant;
}

# Task 10: Emergency Kill Switch
// apps/web/app/api/flags/emergency/route.ts
export async function POST(request: NextRequest) {
  const { userId } = await auth();
  
  // Check admin permissions
  if (!isAdmin(userId)) {
    return NextResponse.json({ error: "Unauthorized" }, { status: 403 });
  }
  
  const { flagKey, enabled, reason } = await request.json();
  
  try {
    // Update LaunchDarkly
    const response = await fetch(
      `https://app.launchdarkly.com/api/v2/flags/${PROJECT}/${flagKey}`,
      {
        method: 'PATCH',
        headers: {
          'Authorization': `Bearer ${LAUNCHDARKLY_API_TOKEN}`,
          'Content-Type': 'application/json'
        },
        body: JSON.stringify([{
          op: 'replace',
          path: '/environments/production/on',
          value: enabled
        }])
      }
    );
    
    // Log audit trail
    await supabase.from('flag_audit_log').insert({
      flag_key: flagKey,
      action: enabled ? 'enabled' : 'disabled',
      user_id: userId,
      reason,
      old_value: !enabled,
      new_value: enabled
    });
    
    // Broadcast to all services via Redis/WebSocket
    await broadcastFlagChange(flagKey, enabled);
    
    // Clear all caches
    await clearFlagCaches(flagKey);
    
    return NextResponse.json({
      success: true,
      message: `Kill switch ${enabled ? 'activated' : 'deactivated'}`,
      propagation_time: '<5 seconds'
    });
    
  } catch (error) {
    logger.error('Emergency kill switch failed', error);
    return NextResponse.json(
      { error: 'Failed to toggle kill switch' },
      { status: 500 }
    );
  }
}
```

### Integration Points

```yaml
DATABASE:
  - migration: "20250817000001_add_feature_flag_tables.sql"
  - tables: "feature_flags, flag_evaluations, flag_audit_log"
  - columns: "Add feature_flags JSONB to existing tables"
  - policies: "RLS checks include flag state"

API:
  - middleware: "FeatureFlagMiddleware for context"
  - decorators: "@feature_flag on all retainer endpoints"
  - service: "FeatureFlagService singleton"
  - endpoints: "POST /api/flags/evaluate, /api/flags/admin"

FRONTEND:
  - provider: "FeatureFlagProvider at app root"
  - hooks: "useFeatureFlag, useFeatureVariant"
  - components: "FeatureFlagGate for conditional rendering"
  - admin: "/admin/flags dashboard"

EXTERNAL:
  - launchdarkly: "SDK initialization and configuration"
  - webhooks: "Real-time flag updates"
  - analytics: "Event tracking and metrics"

MONITORING:
  - metrics: "Flag evaluation latency and errors"
  - dashboards: "Flag state and usage visualization"
  - alerts: "Threshold breaches and anomalies"
  - logs: "Complete audit trail"
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

# Expected: All passing
```

### Level 2: Unit Tests

```python
# test_feature_flags.py
async def test_flag_evaluation():
    """Test basic flag evaluation"""
    service = FeatureFlagService()
    
    # Test with flag enabled
    result = await service.evaluate(
        "test-flag",
        "user_123",
        default=False,
        attributes={"plan": "premium"}
    )
    assert isinstance(result, bool)

async def test_flag_fallback():
    """Test fallback when service unavailable"""
    service = FeatureFlagService()
    
    # Simulate LaunchDarkly outage
    with mock.patch.object(service._client, 'variation', side_effect=Exception):
        result = await service.evaluate("test-flag", "user_123", False)
        assert result == False  # Should use default

async def test_emergency_kill_switch():
    """Test emergency kill switch activation"""
    # Activate kill switch
    response = await client.post(
        "/api/flags/emergency",
        json={"flagKey": "retainer-letter-master", "enabled": False}
    )
    assert response.status_code == 200
    
    # Verify feature is disabled
    enabled = await service.evaluate("retainer-letter-master", "user_123")
    assert enabled == False

# Run tests
pytest api/tests/test_feature_flags.py -v
```

### Level 3: Integration Tests

```bash
# Start services
pnpm dev

# Test flag evaluation API
curl -X POST http://localhost:3000/api/flags/evaluate \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "flagKey": "retainer-letter-master",
    "context": {"userId": "user_123", "plan": "premium"}
  }'

# Expected: {"value": true, "variation": 0}

# Test progressive rollout
for i in {1..100}; do
  curl -X POST http://localhost:3000/api/flags/evaluate \
    -H "Content-Type: application/json" \
    -d "{\"flagKey\": \"retainer-letter-ui\", \"context\": {\"userId\": \"user_$i\"}}"
done | grep true | wc -l

# Should return ~10 for 10% rollout

# Test A/B variant assignment
curl -X POST http://localhost:3000/api/flags/evaluate \
  -H "Content-Type: application/json" \
  -d '{
    "flagKey": "retainer-generation-model",
    "context": {"userId": "user_123"}
  }'

# User should consistently get same variant
```

### Level 4: Real-Time Toggle Testing

```bash
# Test real-time propagation
# Terminal 1: Watch flag state
while true; do
  curl -s http://localhost:3000/api/flags/evaluate \
    -H "Content-Type: application/json" \
    -d '{"flagKey": "retainer-letter-master", "context": {"userId": "test"}}' \
    | jq -r '.value'
  sleep 1
done

# Terminal 2: Toggle flag in LaunchDarkly dashboard
# Or via API:
curl -X PATCH https://app.launchdarkly.com/api/v2/flags/default/retainer-letter-master \
  -H "Authorization: Bearer $LD_API_TOKEN" \
  -H "Content-Type: application/json" \
  -d '[{"op": "replace", "path": "/environments/development/on", "value": false}]'

# Terminal 1 should show change within 5 seconds
```

### Level 5: Load and Performance Testing

```yaml
# artillery-flags.yml
config:
  target: "http://localhost:3000"
  phases:
    - duration: 60
      arrivalRate: 100
scenarios:
  - name: "Flag Evaluation Load Test"
    flow:
      - post:
          url: "/api/flags/evaluate"
          json:
            flagKey: "retainer-letter-master"
            context:
              userId: "user_{{ $randomNumber(1, 1000) }}"

# Run load test
artillery run artillery-flags.yml

# Success criteria:
# - p95 latency < 10ms for flag evaluation
# - 0% error rate
# - Consistent evaluation results
```

### Level 6: Production Validation

```bash
# Progressive rollout validation
# Day 1: Enable for 1% of users
curl -X PATCH $LAUNCHDARKLY_API/flags/production/retainer-letter-master \
  -d '[{"op": "replace", "path": "/environments/production/rules/0/rollout/variations/0/weight", "value": 1000}]'

# Monitor metrics for 24 hours
# - Error rates remain stable
# - No performance degradation
# - Positive user feedback

# Day 2: Increase to 5%
# Day 3: 10%
# Day 5: 25%
# Day 7: 50%
# Day 10: 100%

# Emergency rollback test
curl -X POST https://app.livingtree.io/api/flags/emergency \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d '{"flagKey": "retainer-letter-master", "enabled": false, "reason": "High error rate detected"}'

# Feature should be disabled within 5 seconds globally
```

## Final Validation Checklist

- [ ] LaunchDarkly SDK integrated in backend and frontend
- [ ] Multi-level feature flags controlling all aspects
- [ ] Percentage rollout working (1%, 5%, 10%, 25%, 50%, 100%)
- [ ] User segment targeting functional (beta users, organizations)
- [ ] Real-time toggle propagation < 5 seconds
- [ ] Emergency kill switch tested and working
- [ ] A/B test variants consistently assigned
- [ ] Flag evaluation latency < 10ms
- [ ] Fallback behavior when LaunchDarkly unavailable
- [ ] Audit log capturing all flag changes
- [ ] Admin dashboard showing flag states and metrics
- [ ] Progressive rollout automation configured
- [ ] Compliance controls for jurisdictions
- [ ] Documentation complete with runbooks
- [ ] Load testing shows no performance impact

## Anti-Patterns to Avoid

- ❌ Don't create multiple LaunchDarkly client instances
- ❌ Don't evaluate flags without user context
- ❌ Don't hardcode flag values anywhere
- ❌ Don't skip fallback values for resilience
- ❌ Don't cache flag values on client side
- ❌ Don't ignore flag evaluation metrics
- ❌ Don't bypass kill switches in code
- ❌ Don't use flags for configuration (use env vars)
- ❌ Don't create too many flag dependencies
- ❌ Don't forget to clean up old flags
- ❌ Don't skip audit logging for compliance
- ❌ Don't rollout to 100% immediately

## Success Metrics

**Week 1 Goals**:
- Feature flags controlling retainer letter access
- 1% rollout to beta users successful
- Kill switch tested in production
- Zero incidents from flag system

**Week 2 Goals**:
- 10% rollout with positive feedback
- A/B test showing quality metrics
- Admin dashboard operational
- < 5 second propagation achieved

**Month 1 Goals**:
- 100% rollout completed successfully
- 30% cost reduction via model A/B testing
- Zero security incidents
- Full compliance audit trail
- Feature adopted by 50% of users

## Risk Mitigation Strategies

**Technical Risks**:
- LaunchDarkly outage → Database fallback implemented
- Performance degradation → Circuit breaker patterns
- Cache inconsistency → Real-time streaming updates
- Flag sprawl → Regular flag cleanup process

**Business Risks**:
- Legal compliance issues → Jurisdiction-based controls
- Cost overruns → Usage-based throttling
- User confusion → Clear beta/preview labeling
- Data privacy → Private attribute configuration

**Operational Risks**:
- Accidental full rollout → Required approval flow
- Configuration drift → Infrastructure as code
- Missing metrics → Comprehensive monitoring
- Slow rollback → Emergency kill switches

## Flag Lifecycle Management

**Flag Stages**:
1. **Development**: Local testing only
2. **Staging**: Internal team testing
3. **Beta**: Limited external users
4. **Preview**: Broader testing with feedback
5. **GA Rollout**: Progressive percentage increase
6. **Generally Available**: 100% with flag still active
7. **Cleanup**: Remove flag from code
8. **Archived**: Historical record only

**Cleanup Process**:
- Flags at 100% for 30 days → Schedule removal
- Unused flags for 60 days → Archive
- Failed experiments → Immediate cleanup
- Technical debt review → Quarterly

**Confidence Score**: 9.5/10

This comprehensive PRP provides a production-ready feature flag implementation that enables safe, controlled rollout of the retainer letter functionality. The multi-level flag architecture, combined with progressive rollout capabilities and emergency controls, ensures maximum flexibility while minimizing risk. The integration with existing patterns and thorough monitoring guarantees a smooth deployment with instant rollback capabilities if needed.