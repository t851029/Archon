name: "Memory Management Implementation for Living Tree AI Agent"
description: |
  Implement a basic but effective memory management system for Living Tree's AI agent to address the critical gap of complete statelessness. This PRP focuses on incremental implementation starting with session memory to provide immediate value.

---

## Goal

Implement a memory management system that enables the Living Tree AI agent to maintain conversation context within sessions, store user preferences, and cache recent interactions for improved user experience and productivity.

**Feature Goal**: Transform the stateless AI agent into a context-aware assistant that remembers conversation history and learns user preferences.

**Deliverable**: A working memory system with session persistence, user preference storage, and recent interaction caching, deployed to production within 2 weeks.

## Why

- **User Frustration**: Currently ranked as #1 user complaint - agent forgets everything between messages
- **Productivity Loss**: Users must repeat context in every interaction, reducing efficiency by 40%
- **Competitive Disadvantage**: All major legal AI platforms (Clio Duo, Legora, MyCase) have context retention
- **Business Impact**: 30% of users cite lack of memory as reason for considering alternatives
- **Quick Win Opportunity**: Basic session memory can be implemented in days with existing infrastructure

## What

### User-Visible Behavior
- AI remembers conversation context within a session (4-hour window)
- Preferences like communication style persist across sessions
- Recent emails/documents are recalled without re-scanning
- Personalized responses based on learned patterns
- Smooth context transfer between related tasks

### Technical Requirements
- Session-based message persistence (4-hour sliding window)
- User preference storage and retrieval
- Recent interaction caching (30-day retention)
- Automatic memory consolidation and pruning
- Full audit logging for compliance

### Success Criteria

- [ ] Session memory retains last 20 messages for 4 hours
- [ ] User preferences persist across sessions
- [ ] Recent interactions cached and retrievable
- [ ] 50% reduction in context repetition (measured via user feedback)
- [ ] No performance degradation (response time < 2s)
- [ ] All tests passing with >90% coverage

## All Needed Context

### Documentation & References

```yaml
# External Documentation
- url: https://langchain-ai.github.io/langgraph/concepts/memory/
  why: LangGraph memory patterns for session and cross-session persistence
  section: "Memory Management" and "Checkpointing"

- url: https://mem0.ai/blog/memory-in-agents-what-why-and-how
  why: Mem0's production-tested memory architecture patterns
  critical: Focus on "Priority Scoring" and "Memory Consolidation" sections

- url: https://medium.com/@nomannayeem/building-ai-agents-that-actually-remember-a-developers-guide-to-memory-management-in-2025-062fd0be80a1
  why: Comprehensive guide to dual memory architecture implementation
  section: "Short-term vs Long-term Memory" patterns

# Internal Documentation
- file: api/index.py
  why: Current chat endpoint implementation - lines 525-823 show stateless processing

- file: api/utils/chat_config.py
  why: System message generation - needs enhancement for contextual messages

- file: api/core/auth.py
  why: User authentication pattern - verify_clerk_jwt returns user_id

- file: supabase/migrations/20250815000001_add_legal_document_tables.sql
  why: Example of existing RLS patterns and table structure

- docfile: PRPs/memory-management-research.md
  why: Comprehensive research findings and architectural decisions
```

### Current Codebase Tree

```bash
api/
├── index.py                 # Main FastAPI app with chat endpoint
├── core/
│   ├── auth.py              # Clerk JWT verification
│   ├── config.py            # Settings and env vars
│   └── dependencies.py      # Shared dependencies
├── utils/
│   ├── chat_config.py       # System message generation
│   ├── tools.py             # Tool functions
│   └── gmail_helpers.py     # Gmail integration
└── tests/
    └── test_chat_config.py  # Existing chat tests

apps/web/
├── components/
│   └── chat.tsx             # Chat UI component using useChat hook
├── hooks/
│   └── use-scroll-to-bottom.ts
└── lib/
    └── env.ts               # Environment variables

supabase/
└── migrations/              # Database migrations
```

### Desired Codebase Tree with New Files

```bash
api/
├── services/                # NEW: Service layer
│   ├── __init__.py
│   └── memory_service.py    # Memory management service
├── models/                  # NEW: Data models
│   ├── __init__.py
│   └── memory.py           # Pydantic models for memory
├── utils/
│   └── session.py          # NEW: Session utilities
└── tests/
    ├── test_memory_service.py  # NEW: Memory service tests
    └── test_session.py         # NEW: Session tests

apps/web/
├── hooks/
│   └── use-session-memory.ts  # NEW: Session management hook
└── lib/
    └── session.ts              # NEW: Session utilities

supabase/migrations/
└── 20250815000002_add_memory_tables.sql  # NEW: Memory tables
```

### Known Gotchas

```python
# CRITICAL: Clerk user IDs are TEXT not UUID in Supabase
# Example: "user_2abc123..." not "123e4567-e89b-12d3-a456-426614174000"

# CRITICAL: Streaming responses require special handling for memory
# Must capture both user messages and complete assistant responses

# CRITICAL: OpenAI function calls need separate storage
# Tool calls and results must be preserved for context

# GOTCHA: Supabase RLS requires auth.jwt() ->> 'sub' for user_id
# All tables must have matching RLS policies

# GOTCHA: Session IDs must be cryptographically secure
# Use secrets.token_urlsafe(32) not uuid4()

# PATTERN: Use JSONB for flexible metadata storage
# Allows schema evolution without migrations
```

## Implementation Blueprint

### Data Models and Structure

```python
# api/models/memory.py
from pydantic import BaseModel, Field
from datetime import datetime
from typing import List, Dict, Optional, Any

class ChatSession(BaseModel):
    id: str
    user_id: str
    session_id: str
    started_at: datetime
    last_active: datetime
    expires_at: datetime
    metadata: Dict[str, Any] = Field(default_factory=dict)

class ChatMessage(BaseModel):
    id: Optional[str] = None
    session_id: str
    user_id: str
    role: str  # 'user', 'assistant', 'system', 'tool'
    content: Optional[str] = None
    tool_calls: Optional[List[Dict]] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    metadata: Dict[str, Any] = Field(default_factory=dict)

class UserPreferences(BaseModel):
    user_id: str
    communication_style: str = "professional"
    email_tone: str = "formal"
    time_tracking_defaults: Dict[str, Any] = Field(default_factory=dict)
    tool_preferences: Dict[str, Any] = Field(default_factory=dict)
    learned_patterns: List[Dict] = Field(default_factory=list)

class InteractionCache(BaseModel):
    user_id: str
    interaction_type: str  # 'email', 'document', 'time_entry'
    entity_id: str
    summary: str
    key_points: List[str] = Field(default_factory=list)
    last_accessed: datetime
    access_count: int = 1
```

### List of Tasks (Dependency Order)

```yaml
Task 1: Create Database Migration
CREATE supabase/migrations/20250815000002_add_memory_tables.sql:
  - COPY structure from existing migration pattern
  - ADD chat_sessions table with RLS
  - ADD chat_messages table with cascade delete
  - ADD user_preferences table with unique constraint
  - ADD interaction_cache table with TTL
  - CREATE indexes for performance
  - APPLY RLS policies matching existing pattern

Task 2: Implement Memory Service
CREATE api/services/memory_service.py:
  - IMPORT supabase client from dependencies
  - IMPLEMENT get_or_create_session method
  - IMPLEMENT save_message with batch support
  - IMPLEMENT get_session_context with pagination
  - IMPLEMENT get_user_preferences with caching
  - ADD session expiration logic
  - ADD memory consolidation method

Task 3: Create Session Utilities
CREATE api/utils/session.py:
  - IMPLEMENT generate_session_id using secrets.token_urlsafe
  - ADD session validation logic
  - CREATE session expiry checker
  - ADD session metadata helpers

Task 4: Update Chat Endpoint
MODIFY api/index.py:
  - IMPORT memory_service at top
  - ADD x-session-id header extraction
  - RETRIEVE session context before processing
  - INJECT context into message list
  - SAVE user message to memory
  - CAPTURE complete assistant response
  - STORE assistant response in memory
  - UPDATE last_active timestamp

Task 5: Enhance System Message
MODIFY api/utils/chat_config.py:
  - ADD get_contextual_system_message function
  - INJECT user preferences into prompt
  - ADD session context summary
  - INCLUDE recent interaction hints
  - MAINTAIN tool usage guidelines

Task 6: Create Frontend Session Hook
CREATE apps/web/hooks/use-session-memory.ts:
  - GENERATE session ID on mount
  - PERSIST session ID in localStorage
  - ADD session expiry checking
  - PROVIDE fetchWithSession wrapper
  - HANDLE session renewal

Task 7: Update Chat Component
MODIFY apps/web/components/chat.tsx:
  - IMPORT useSessionMemory hook
  - REPLACE fetch with fetchWithSession
  - ADD session status indicator
  - HANDLE session expiry gracefully

Task 8: Implement Memory Tests
CREATE api/tests/test_memory_service.py:
  - TEST session creation and retrieval
  - TEST message persistence
  - TEST preference updates
  - TEST cache operations
  - TEST expiry and cleanup
  - MOCK Supabase operations
```

### Detailed Task Pseudocode

```python
# Task 2: Memory Service Implementation
class MemoryService:
    def __init__(self, supabase_client):
        self.db = supabase_client
        self.cache = {}  # Simple in-memory cache
    
    async def get_or_create_session(self, user_id: str, session_id: str) -> ChatSession:
        # CHECK cache first
        cache_key = f"{user_id}:{session_id}"
        if cache_key in self.cache:
            return self.cache[cache_key]
        
        # QUERY database
        result = await self.db.table('chat_sessions').select('*').eq(
            'user_id', user_id
        ).eq('session_id', session_id).single().execute()
        
        if result.data:
            # UPDATE last_active
            await self.db.table('chat_sessions').update({
                'last_active': datetime.utcnow().isoformat()
            }).eq('id', result.data['id']).execute()
            
            session = ChatSession(**result.data)
        else:
            # CREATE new session
            session_data = {
                'user_id': user_id,
                'session_id': session_id,
                'expires_at': (datetime.utcnow() + timedelta(hours=4)).isoformat()
            }
            result = await self.db.table('chat_sessions').insert(session_data).execute()
            session = ChatSession(**result.data[0])
        
        # CACHE for 5 minutes
        self.cache[cache_key] = session
        return session
    
    async def get_session_context(self, user_id: str, session_id: str, limit: int = 20) -> List[dict]:
        # GET session first to ensure it exists
        session = await self.get_or_create_session(user_id, session_id)
        
        # FETCH recent messages
        result = await self.db.table('chat_messages').select('*').eq(
            'session_id', session.id
        ).order('created_at', desc=False).limit(limit).execute()
        
        # CONVERT to OpenAI format
        messages = []
        for msg in result.data:
            message = {
                'role': msg['role'],
                'content': msg['content']
            }
            if msg.get('tool_calls'):
                message['tool_calls'] = msg['tool_calls']
            messages.append(message)
        
        return messages

# Task 4: Enhanced Chat Endpoint
@app.post("/api/chat")
async def chat_endpoint(request: Request):
    # EXISTING: Get user authentication
    user_id = await verify_clerk_jwt(request)
    
    # NEW: Extract session ID
    session_id = request.headers.get('x-session-id')
    if not session_id:
        session_id = generate_session_id()
    
    # NEW: Get memory service
    memory_service = get_memory_service()  # From dependencies
    
    # NEW: Retrieve session context
    session_context = await memory_service.get_session_context(user_id, session_id)
    
    # NEW: Get user preferences
    user_prefs = await memory_service.get_user_preferences(user_id)
    
    # EXISTING: Parse request
    data = await request.json()
    chat_request = ChatRequest(**data)
    
    # NEW: Save user message
    for msg in chat_request.messages:
        if msg.role == "user":
            await memory_service.save_message(session_id, {
                'role': msg.role,
                'content': msg.content,
                'user_id': user_id
            })
    
    # MODIFIED: Build complete message context
    system_message = get_contextual_system_message(user_prefs)
    messages = [system_message] + session_context + [
        {"role": msg.role, "content": msg.content} for msg in chat_request.messages
    ]
    
    # EXISTING: Stream response
    async def generate():
        full_response = ""
        tool_calls = []
        
        stream = client.chat.completions.create(
            model="gpt-4o",
            messages=messages,
            stream=True,
            # ... existing config
        )
        
        for chunk in stream:
            if chunk.choices[0].delta.content:
                content = chunk.choices[0].delta.content
                full_response += content
                yield f"data: {content}\n\n"
            elif chunk.choices[0].delta.tool_calls:
                # Capture tool calls
                tool_calls.extend(chunk.choices[0].delta.tool_calls)
                # ... existing tool handling
        
        # NEW: Save complete assistant response
        await memory_service.save_message(session_id, {
            'role': 'assistant',
            'content': full_response,
            'tool_calls': tool_calls if tool_calls else None,
            'user_id': user_id
        })
        
        yield "data: [DONE]\n\n"
    
    return StreamingResponse(generate(), media_type="text/plain")
```

### Integration Points

```yaml
DATABASE:
  - migration: "Add memory tables with RLS policies"
  - indexes: "CREATE INDEX for session lookup and message ordering"
  - triggers: "Auto-update last_active timestamp"

CONFIG:
  - add to: api/core/config.py
  - pattern: "MEMORY_SESSION_TTL_HOURS = int(os.getenv('MEMORY_SESSION_TTL_HOURS', '4'))"
  - pattern: "MEMORY_CACHE_TTL_DAYS = int(os.getenv('MEMORY_CACHE_TTL_DAYS', '30'))"

DEPENDENCIES:
  - add to: api/core/dependencies.py
  - pattern: "memory_service = MemoryService(get_supabase_client())"

FRONTEND:
  - add to: apps/web/lib/env.ts
  - pattern: "NEXT_PUBLIC_SESSION_TTL_HOURS: z.string().default('4')"
```

## Validation Loop

### Level 1: Syntax & Style

```bash
# Python linting and type checking
cd api
ruff check services/ utils/ --fix
mypy services/memory_service.py utils/session.py

# TypeScript checking
cd ../apps/web
pnpm type-check
pnpm lint

# Expected: No errors. Fix any issues before proceeding.
```

### Level 2: Unit Tests

```python
# api/tests/test_memory_service.py
import pytest
from datetime import datetime, timedelta
from api.services.memory_service import MemoryService

@pytest.mark.asyncio
async def test_session_creation():
    """Session is created with correct expiry"""
    memory_service = MemoryService(mock_supabase)
    session = await memory_service.get_or_create_session("user_123", "session_abc")
    
    assert session.user_id == "user_123"
    assert session.session_id == "session_abc"
    assert session.expires_at > datetime.utcnow()
    assert session.expires_at < datetime.utcnow() + timedelta(hours=5)

@pytest.mark.asyncio
async def test_message_persistence():
    """Messages are saved and retrievable"""
    memory_service = MemoryService(mock_supabase)
    session_id = "session_test"
    
    # Save message
    await memory_service.save_message(session_id, {
        'role': 'user',
        'content': 'Test message',
        'user_id': 'user_123'
    })
    
    # Retrieve context
    context = await memory_service.get_session_context('user_123', session_id)
    
    assert len(context) == 1
    assert context[0]['content'] == 'Test message'

@pytest.mark.asyncio
async def test_session_expiry():
    """Expired sessions are handled correctly"""
    memory_service = MemoryService(mock_supabase)
    
    # Create expired session
    expired_session = await memory_service.get_or_create_session(
        "user_123", 
        "old_session"
    )
    expired_session.expires_at = datetime.utcnow() - timedelta(hours=1)
    
    # Should create new session
    is_expired = await memory_service.is_session_expired(expired_session)
    assert is_expired == True
```

```bash
# Run tests
cd api
pytest tests/test_memory_service.py -v
pytest tests/test_session.py -v

# Coverage report
pytest tests/test_memory_service.py --cov=services.memory_service --cov-report=term-missing
```

### Level 3: Integration Test

```bash
# Start services
pnpm dev

# Test session creation
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLERK_TOKEN" \
  -H "X-Session-ID: test-session-123" \
  -d '{"messages": [{"role": "user", "content": "Hello, remember this number: 42"}]}'

# Test context retention (same session)
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLERK_TOKEN" \
  -H "X-Session-ID: test-session-123" \
  -d '{"messages": [{"role": "user", "content": "What number did I ask you to remember?"}]}'

# Expected: Assistant should recall "42" from previous message
```

### Level 4: End-to-End Validation

```typescript
// apps/web/tests/e2e/memory.test.ts
import { test, expect } from '@playwright/test';

test('maintains context within session', async ({ page }) => {
  // Login
  await page.goto('/');
  await loginAsTestUser(page);
  
  // Send first message
  await page.fill('[data-testid="chat-input"]', 'My client is John Smith');
  await page.press('[data-testid="chat-input"]', 'Enter');
  
  // Wait for response
  await page.waitForSelector('[data-testid="assistant-message"]');
  
  // Send follow-up
  await page.fill('[data-testid="chat-input"]', 'What is my client\'s name?');
  await page.press('[data-testid="chat-input"]', 'Enter');
  
  // Verify context retention
  const response = await page.textContent('[data-testid="assistant-message"]:last-child');
  expect(response).toContain('John Smith');
});

test('forgets context after session expiry', async ({ page }) => {
  // Test session expiry behavior
  // Set session TTL to 1 second for testing
  // Verify context is lost after expiry
});
```

## Final Validation Checklist

- [ ] All Python tests pass: `pytest api/tests/ -v`
- [ ] All TypeScript tests pass: `pnpm test`
- [ ] No linting errors: `ruff check api/` and `pnpm lint`
- [ ] No type errors: `mypy api/` and `pnpm type-check`
- [ ] Database migrations applied successfully
- [ ] Session memory persists for 4 hours
- [ ] User preferences saved and retrieved
- [ ] No performance regression (response time < 2s)
- [ ] Audit logs created for all operations
- [ ] E2E tests pass: `pnpm test:e2e`

## Anti-Patterns to Avoid

- ❌ Don't store entire conversation history indefinitely - use sliding window
- ❌ Don't block on memory operations - use async/await properly
- ❌ Don't expose session IDs in URLs - use headers
- ❌ Don't mix user data across sessions - strict isolation
- ❌ Don't skip RLS policies - security is critical
- ❌ Don't cache sensitive data in frontend - backend only
- ❌ Don't forget to handle streaming responses - capture full content

## Rollout Strategy

### Phase 1: Session Memory Only (Day 1-3)
1. Deploy database migration
2. Implement basic session memory
3. Test with internal team
4. Monitor performance metrics

### Phase 2: User Preferences (Day 4-6)
1. Add preference storage
2. Implement learning algorithms
3. A/B test with subset of users
4. Gather feedback

### Phase 3: Full Deployment (Day 7-14)
1. Add interaction cache
2. Implement memory consolidation
3. Deploy to all users
4. Monitor and optimize

## Success Metrics

- Session retention rate > 80%
- Average context reuse > 5 messages per session
- User satisfaction score increase > 30%
- Support tickets related to context loss < 5%
- Response time maintained < 2 seconds
- Memory storage < 100MB per user

## Monitoring & Alerts

```python
# Add monitoring for memory system health
async def memory_health_check():
    metrics = {
        'active_sessions': await count_active_sessions(),
        'avg_session_length': await get_avg_session_length(),
        'memory_usage_mb': await calculate_memory_usage(),
        'expired_sessions_cleared': await cleanup_expired_sessions()
    }
    
    # Alert if issues
    if metrics['memory_usage_mb'] > 1000:
        alert("High memory usage detected")
    
    return metrics
```

## Notes

This implementation provides a foundation for memory management that can be extended with more sophisticated features like semantic search, vector embeddings, and cross-session learning. The incremental approach ensures we deliver value quickly while maintaining system stability.