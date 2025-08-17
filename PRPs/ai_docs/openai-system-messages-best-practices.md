# OpenAI System Messages and Few-Shot Prompting Best Practices

## System Message Architecture

### Core Structure
System messages define the AI's role, behavior, and constraints. For conversational AI:

```python
system_message = """
You are a helpful AI assistant for [DOMAIN/COMPANY].
Current date: {current_date}
Knowledge cutoff: {knowledge_cutoff}

Role:
- [Define specific role and expertise]
- [Scope of assistance]

Behavior Guidelines:
- Ask clarifying questions when requests are ambiguous
- Provide concise, actionable responses
- When uncertain, acknowledge limitations clearly
- Use available tools rather than guessing

Tone:
- Professional yet friendly
- Clear and direct
- Empathetic when appropriate
"""
```

## Temperature Settings for Conversational AI

Based on research, optimal temperature ranges:

| Use Case | Temperature | Rationale |
|----------|------------|-----------|
| Conversational AI | 0.6-0.7 | Balance between natural flow and consistency |
| Customer Support | 0.3-0.5 | Prioritizes accuracy over creativity |
| Creative Tasks | 0.7-0.9 | Encourages diverse responses |
| Technical/Factual | 0.1-0.3 | Maximum accuracy and consistency |

**Research Finding**: 85% of users experience improved satisfaction with conversational models set at ~0.7 temperature.

## Few-Shot Example Patterns

### Pattern 1: Clarification Requests
```python
few_shot_examples = [
    {
        "user": "Analyze my data",
        "assistant": "I'd be happy to help analyze your data. To provide the most relevant analysis, could you clarify what type of data you're working with? For example, are you looking at sales data, survey responses, or website analytics?"
    },
    {
        "user": "Make it better",
        "assistant": "I'd like to help improve that for you. Could you specify what you'd like me to improve? Are you referring to a document, code, process, or something else?"
    }
]
```

### Pattern 2: Tool Result Summarization
```python
tool_response_examples = [
    {
        "context": "After weather tool call",
        "assistant": "Based on current data, it's 72°F and sunny with light winds. Perfect weather for outdoor activities! Would you like the extended forecast or weather for a different location?"
    },
    {
        "context": "After email search",
        "assistant": "I found 5 unread emails from the past 24 hours. The most urgent appears to be from your client regarding the contract review (marked as high priority). Would you like me to summarize these emails or help you draft responses?"
    }
]
```

## Implementation Guidelines

### 1. Message Ordering
- System message first (defines behavior)
- Few-shot examples second (demonstrates patterns)
- User message last (current request)

### 2. Tool Usage Guidance
```python
tool_guidance = """
When using tools:
1. Use tools for real-time data rather than training knowledge
2. After tool execution, summarize key findings
3. Suggest logical next steps based on results
4. If tool fails, explain clearly and offer alternatives
"""
```

### 3. Error Handling Pattern
```python
error_handling = """
When encountering issues:
- Acknowledge the problem clearly
- Explain what went wrong in simple terms
- Offer alternative approaches
- Ask if the user wants to try something different
"""
```

## Model Selection Notes

### Current Best Options (as of 2025)
- **GPT-4o**: Best for general conversational AI with 128K context
- **GPT-4o-mini**: Cost-effective for simpler conversations
- **GPT-4.1**: Latest with enhanced reasoning (when available)
- **Note**: GPT-5 doesn't exist yet; use GPT-4o as the most advanced conversational model

### For o1/o3 Models
Use `developer` role instead of `system` role:
```python
messages = [
    {"role": "developer", "content": system_instructions},
    {"role": "user", "content": user_query}
]
```

## Key Research Findings

1. **Optimal Few-Shot Count**: 2-5 examples typically sufficient
2. **Order Matters**: Recent examples have more influence (recency bias)
3. **Consistency Critical**: Maintain same format across all examples
4. **Provide an "Out"**: Always give model option to say "I don't know"
5. **Temperature Sweet Spot**: 0.6-0.7 for conversational AI based on user satisfaction data

## References
- [OpenAI Platform Docs - Reasoning](https://platform.openai.com/docs/guides/reasoning-best-practices)
- [Azure OpenAI - System Messages](https://learn.microsoft.com/en-us/azure/ai-foundry/openai/concepts/advanced-prompt-engineering)
- [Temperature Optimization Research](https://moldstud.com/articles/p-the-ultimate-guide-to-prompt-engineering-temperature-parameter-optimization-for-ai-success)