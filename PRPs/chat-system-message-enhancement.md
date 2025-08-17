# PRP: Enhanced Chat System with System Messages and Optimized Parameters

## Goal

Enhance the Living Tree chat system by adding a comprehensive system message that defines role, tone, clarification behavior, and tool usage guidance. Tune model parameters to optimal temperature (0.6-0.7) and add few-shot examples for improved conversation flow.

### Feature Goal
Transform the existing chat implementation to have guided AI behavior through system messages and few-shot prompting, resulting in more consistent, helpful, and context-aware responses.

### Deliverable
- System message configuration with role, tone, and behavior guidelines
- Temperature tuning to 0.6-0.7 for optimal conversation flow
- Few-shot examples for clarification requests and tool result summarization
- Model configuration for GPT-4o (GPT-5 doesn't exist yet)

### Success Definition
Chat system provides more consistent responses, asks clarifying questions when appropriate, and effectively summarizes tool results with suggested next steps.

## Why

- **Consistency**: Currently no system message guides AI behavior, leading to inconsistent responses
- **User Experience**: Users need clearer clarification requests and better tool result summaries
- **Production Readiness**: System messages and temperature tuning are industry best practices
- **Tool Integration**: Better guidance on when to use tools vs respond directly

## What

Add system message configuration to the chat endpoint that:
- Defines the AI assistant's role as a productivity helper for Living Tree
- Sets professional yet friendly tone
- Instructs when to ask clarifying questions
- Guides tool usage and result summarization
- Implements temperature of 0.6-0.7
- Includes 2-3 few-shot examples for common patterns

### Success Criteria

- [ ] System message properly integrated into OpenAI chat completion
- [ ] Temperature set to 0.6-0.7 range
- [ ] Few-shot examples working for clarification scenarios
- [ ] Tool results include summaries and next step suggestions
- [ ] Chat responses more consistent and helpful
- [ ] All existing tools continue to work correctly

## All Needed Context

### Documentation & References

```yaml
# MUST READ - Include these in your context window
- url: https://platform.openai.com/docs/guides/reasoning-best-practices
  why: Official OpenAI guidance on system messages and prompting

- file: /Users/kylemarks/Documents/GitHub/living-tree/api/index.py
  why: Current chat implementation - lines 94-109 (convert_to_openai_messages), lines 648-1416 (stream_text function)

- file: /Users/kylemarks/Documents/GitHub/living-tree/api/utils/tools.py
  why: All 16 tool definitions to understand tool calling patterns

- docfile: /Users/kylemarks/Documents/GitHub/living-tree/PRPs/ai_docs/openai-system-messages-best-practices.md
  why: Comprehensive research on system messages, temperature, and few-shot examples

- doc: https://cookbook.openai.com/articles/openai-harmony
  section: Basic system message format
  critical: Use current date and knowledge cutoff in system message

- file: /Users/kylemarks/Documents/GitHub/living-tree/api/core/config.py
  why: Settings configuration pattern for new environment variables
```

### Current Codebase Structure

```bash
api/
├── index.py                  # Main FastAPI app with /api/chat endpoint
├── core/
│   ├── config.py            # Environment configuration
│   ├── auth.py              # JWT validation
│   └── dependencies.py      # Dependency injection
└── utils/
    ├── tools.py             # 16 tool definitions
    └── prompt.py            # Existing prompt templates (for tools)
```

### Desired Codebase Structure

```bash
api/
├── index.py                  # MODIFIED: Add system message to stream_text
├── core/
│   ├── config.py            # MODIFIED: Add temperature config
│   ├── auth.py              # No changes
│   └── dependencies.py      # No changes  
├── utils/
│   ├── tools.py             # No changes
│   ├── prompt.py            # No changes
│   └── chat_config.py       # NEW: System message and few-shot examples
```

### Known Gotchas

```python
# CRITICAL: Current implementation has NO system message (line 656-659)
# Currently: messages parameter passed directly to OpenAI without system prompt

# CRITICAL: Temperature not configurable, using OpenAI default (1.0)
# Need to add temperature parameter to chat completion call

# CRITICAL: Model hardcoded as "gpt-4o" (line 656)
# GPT-5 doesn't exist - keep using gpt-4o as most advanced

# GOTCHA: convert_to_openai_messages supports system role but never used
# Function already handles "system" role properly (line 102-103)

# PATTERN: Settings loaded from environment via pydantic_settings
# Use same pattern for temperature configuration
```

## Implementation Blueprint

### Task 1: Create Chat Configuration Module

CREATE api/utils/chat_config.py:
```python
from datetime import datetime
from typing import List, Dict, Any

def get_system_message() -> str:
    """Generate system message with current date"""
    current_date = datetime.now().strftime("%Y-%m-%d")
    
    return f"""You are a helpful AI assistant for Living Tree, an AI-powered productivity platform specializing in email management and professional workflows.

Current date: {current_date}
Knowledge cutoff: 2024-04

Your role:
- Assist users with email triage, drafting, and time tracking
- Help organize and prioritize professional communications
- Provide intelligent suggestions for productivity improvements

Behavior guidelines:
- When a request is unclear or could have multiple interpretations, ask ONE specific clarifying question
- Provide concise, actionable responses focused on productivity
- When you don't have enough information, clearly explain what you need
- Use available tools for real-time data rather than relying on training knowledge

Tool usage:
- After using tools, provide a brief summary of key findings
- Suggest logical next steps based on tool results
- If a tool fails, explain what happened and offer alternatives

Tone:
- Professional yet friendly
- Clear and direct communication
- Empathetic when discussing workload or time management"""

def get_few_shot_examples() -> List[Dict[str, str]]:
    """Return few-shot examples for common scenarios"""
    return [
        # Clarification example
        {
            "role": "user",
            "content": "Check my emails"
        },
        {
            "role": "assistant", 
            "content": "I'd be happy to help you check your emails. To provide the most relevant information, could you clarify what you're looking for? For example:\n- Recent unread emails from the last 24 hours?\n- Emails from a specific sender?\n- High-priority emails that need attention?"
        },
        # Tool result summary example
        {
            "role": "user",
            "content": "Show me my important emails from today"
        },
        {
            "role": "assistant",
            "content": "[After running triage_emails tool]\n\nI've analyzed your emails from today and found 3 high-priority items:\n\n1. **Contract Review** from Jane Smith - Requires response by EOD\n2. **Meeting Reschedule** from Team Lead - Tomorrow's meeting moved to 2 PM\n3. **Client Invoice** from Accounting - Approval needed for Q4 billing\n\nWould you like me to help draft responses to any of these, or would you prefer to see more details about a specific email?"
        }
    ]
```

### Task 2: Update Configuration for Temperature

MODIFY api/core/config.py:
```python
# FIND pattern: class Settings(BaseSettings)
# ADD these fields to Settings class:

CHAT_TEMPERATURE: float = 0.7  # Optimal for conversational AI
CHAT_MODEL: str = "gpt-4o"     # Most advanced available model
INCLUDE_SYSTEM_MESSAGE: bool = True
INCLUDE_FEW_SHOT: bool = True
```

### Task 3: Enhance Message Conversion Function

MODIFY api/index.py:
```python
# FIND pattern: def convert_to_openai_messages
# REPLACE entire function with enhanced version:

from api.utils.chat_config import get_system_message, get_few_shot_examples

def convert_to_openai_messages(
    messages: List[ClientMessage],
    include_system: bool = True,
    include_few_shot: bool = True
) -> List[ChatCompletionMessageParam]:
    openai_messages: List[ChatCompletionMessageParam] = []
    
    # Add system message if enabled
    if include_system and settings.INCLUDE_SYSTEM_MESSAGE:
        system_msg: ChatCompletionSystemMessageParam = {
            "role": "system",
            "content": get_system_message()
        }
        openai_messages.append(system_msg)
    
    # Add few-shot examples if enabled and no prior conversation
    if include_few_shot and settings.INCLUDE_FEW_SHOT and len(messages) == 1:
        for example in get_few_shot_examples():
            if example["role"] == "user":
                example_msg: ChatCompletionUserMessageParam = {
                    "role": "user",
                    "content": example["content"]
                }
            else:
                example_msg: ChatCompletionAssistantMessageParam = {
                    "role": "assistant",
                    "content": example["content"]
                }
            openai_messages.append(example_msg)
    
    # Add user messages
    for message in messages:
        # ... (keep existing message conversion logic)
```

### Task 4: Update Stream Text Function with Temperature

MODIFY api/index.py:
```python
# FIND pattern: async def stream_text (around line 648)
# FIND the OpenAI completion call (around line 656-659)
# REPLACE with:

completion = await openai_client.chat.completions.create(
    model=settings.CHAT_MODEL,  # Now configurable
    messages=messages,
    temperature=settings.CHAT_TEMPERATURE,  # Now set to 0.7
    stream=True,
    tools=tool_schemas if tool_schemas else None
)
```

### Task 5: Enhance Tool Result Formatting

MODIFY api/index.py:
```python
# FIND pattern: where tool results are yielded (around line 1365-1380)
# AFTER yielding tool result, ADD summary generation:

if tool_name in ["triage_emails", "list_emails", "get_email_details"]:
    # Generate helpful summary after email tools
    summary_prompt = f"Based on the {tool_name} results, provide a brief summary and suggest next steps."
    # This would be added to the assistant's next response
    
if tool_name == "get_current_weather":
    # Add contextual suggestions for weather
    # e.g., "Perfect weather for that outdoor meeting you mentioned"
```

### Integration Points

```yaml
ENVIRONMENT:
  - add to: .env
  - variables:
    - CHAT_TEMPERATURE=0.7
    - CHAT_MODEL=gpt-4o
    - INCLUDE_SYSTEM_MESSAGE=true
    - INCLUDE_FEW_SHOT=true

CONFIG:
  - modified: api/core/config.py
  - pattern: Add new fields to Settings class

MODULES:
  - new: api/utils/chat_config.py
  - imports: Add to api/index.py imports section

TESTING:
  - update: api/tests/test_chat.py (if exists)
  - verify: System message included in requests
  - verify: Temperature parameter applied
```

## Validation Loop

### Level 1: Syntax & Style

```bash
# Check Python syntax and formatting
cd api/
poetry run black api/utils/chat_config.py api/index.py
poetry run flake8 api/utils/chat_config.py api/index.py
poetry run mypy api/utils/chat_config.py api/index.py

# Expected: No errors
```

### Level 2: Unit Tests

```python
# CREATE api/tests/test_chat_config.py:

import pytest
from api.utils.chat_config import get_system_message, get_few_shot_examples
from api.index import convert_to_openai_messages

def test_system_message_includes_date():
    """System message includes current date"""
    message = get_system_message()
    assert "Current date:" in message
    assert "Living Tree" in message
    
def test_few_shot_examples_format():
    """Few-shot examples have correct structure"""
    examples = get_few_shot_examples()
    assert len(examples) >= 4  # At least 2 exchanges
    assert all("role" in ex and "content" in ex for ex in examples)
    
def test_message_conversion_with_system():
    """System message properly prepended"""
    user_messages = [ClientMessage(role="user", content="Hello")]
    result = convert_to_openai_messages(user_messages, include_system=True)
    assert result[0]["role"] == "system"
    assert "Living Tree" in result[0]["content"]

def test_temperature_configuration():
    """Temperature properly configured"""
    from api.core.config import settings
    assert 0.6 <= settings.CHAT_TEMPERATURE <= 0.7
```

```bash
# Run tests
poetry run pytest api/tests/test_chat_config.py -v
```

### Level 3: Integration Test

```bash
# Start the backend
pnpm dev:api

# Test chat with system message
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "messages": [
      {"role": "user", "content": "What can you help me with?"}
    ]
  }'

# Expected: Response mentions Living Tree capabilities and email management

# Test clarification behavior
curl -X POST http://localhost:8000/api/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -d '{
    "messages": [
      {"role": "user", "content": "Check my stuff"}
    ]
  }'

# Expected: Response asks for clarification about what "stuff" means
```

### Level 4: Frontend Integration Test

```bash
# Start full stack
pnpm dev

# Navigate to http://localhost:3000/chat
# Test scenarios:
# 1. Ask vague question -> Should get clarification request
# 2. Use weather tool -> Should get summary with suggestions
# 3. Use email tool -> Should get organized summary with next steps
```

## Final Validation Checklist

### Configuration Validation
- [ ] System message includes current date and Living Tree context
- [ ] Temperature set to 0.7 in configuration
- [ ] Model configured as "gpt-4o" (not gpt-5)
- [ ] Environment variables properly loaded

### Behavior Validation
- [ ] Chat asks clarifying questions for ambiguous requests
- [ ] Tool results include helpful summaries
- [ ] Tone is professional yet friendly
- [ ] System respects its defined role and limitations

### Backward Compatibility
- [ ] All 16 existing tools continue to work
- [ ] Frontend chat component works without modifications
- [ ] Streaming responses maintain correct format
- [ ] Authentication flow unchanged

### Performance Validation
- [ ] Response time similar to previous implementation
- [ ] Streaming works smoothly
- [ ] No memory leaks or excessive API calls

### Commands to Run

```bash
# Type checking
poetry run mypy api/

# Linting
poetry run black api/
poetry run flake8 api/

# Testing
poetry run pytest api/tests/ -v

# Full validation
pnpm lint
pnpm check-types
pnpm test
```

## Success Metrics

**Confidence Score**: 9/10 for one-pass implementation success

The implementation is straightforward with clear patterns to follow. The only uncertainty is around the exact OpenAI response format changes with system messages, but the existing streaming infrastructure should handle it well.

**Key Success Indicators**:
- More consistent chat responses
- Improved clarification requests
- Better tool result summaries
- Maintained backward compatibility
- All tests passing