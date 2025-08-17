name: "SA-EPIC-008: Smart Action Buttons System"
description: |
Intelligent action interface that enables users to act on email insights efficiently with contextual recommendations and bulk operations.

---

## Goal

Build a comprehensive Smart Action Buttons System that provides contextual, AI-powered action recommendations for individual emails and bulk operations across multiple emails. The system should integrate seamlessly with the existing triage dashboard, leverage Gmail API for action execution, and provide an intuitive interface for email management based on triage analysis results.

## Why

- **User Efficiency**: 50% reduction in email processing time by providing contextual actions directly in the interface
- **AI-Powered Intelligence**: Action suggestions based on email content, priority, and triage analysis
- **Seamless Integration**: Builds on recently completed Epic 6 (Triage Dashboard) to create complete email management workflow
- **Gmail Integration**: Direct execution of actions through Gmail API without leaving the application
- **Bulk Operations**: Handle multiple emails efficiently with batch processing capabilities
- **Foundation for Mobile**: Provides action patterns that will be essential for Epic 11 (Mobile Interface)

## What

A comprehensive action system featuring:

- **Smart Action Buttons**: Contextual action suggestions per email (Reply, Schedule, Archive, Label, Forward)
- **Action Suggestion Engine**: AI-powered recommendations based on email content and triage results
- **Bulk Action Toolbar**: Multi-select interface for batch operations
- **Gmail API Integration**: Direct action execution with proper error handling
- **Progress Tracking**: Real-time feedback during action execution
- **Undo Capabilities**: Ability to reverse certain actions
- **Contextual Recommendations**: Priority-aware action suggestions (Critical emails get different actions than Low priority)

### Success Criteria

- [x] Individual email action buttons with contextual suggestions
- [x] Bulk action toolbar with multi-select capabilities
- [x] AI-powered action suggestion engine integrated with OpenAI
- [x] Gmail API integration for action execution (reply, archive, label, forward)
- [x] Real-time progress feedback during action execution
- [x] Error handling and recovery for failed actions
- [x] Integration with existing triage dashboard and email list
- [x] Responsive design compatible with existing app layout
- [x] Performance testing with 20+ email bulk operations

## All Needed Context

### Documentation & References

```yaml
# MUST READ - Include these in your context window
- url: https://ui.shadcn.com/docs/components/button
  why: Button component patterns, variants (default, destructive, outline, secondary, ghost, link), sizing

- url: https://ui.shadcn.com/docs/components/dropdown-menu
  why: Action menu patterns for contextual email actions

- url: https://ui.shadcn.com/docs/components/checkbox
  why: Multi-select patterns for bulk operations

- url: https://developers.google.com/gmail/api/reference/rest/v1/users.messages/modify
  why: Gmail API for modifying email labels and status

- url: https://developers.google.com/gmail/api/reference/rest/v1/users.drafts/create
  why: Gmail API for creating draft responses

- url: https://developers.google.com/gmail/api/reference/rest/v1/users.messages/send
  why: Gmail API for sending emails

- file: /Users/jron/mac_code_projects/jerin/lt-120-epic-8-smart-action-buttons-system/apps/web/components/triage-dashboard.tsx
  why: Recently completed dashboard pattern - component composition, error handling, SWR integration

- file: /Users/jron/mac_code_projects/jerin/lt-120-epic-8-smart-action-buttons-system/apps/web/components/triage-email-list.tsx
  why: Email list patterns, dropdown actions, priority grouping, existing action button integration points

- file: /Users/jron/mac_code_projects/jerin/lt-120-epic-8-smart-action-buttons-system/apps/web/components/triage-controls.tsx
  why: Action trigger patterns, button states, error handling, loading indicators

- file: /Users/jron/mac_code_projects/jerin/lt-120-epic-8-smart-action-buttons-system/apps/web/hooks/use-triage-data.ts
  why: SWR data fetching patterns, rate limiting, authentication with Clerk JWT tokens

- file: /Users/jron/mac_code_projects/jerin/lt-120-epic-8-smart-action-buttons-system/api/utils/gmail_helpers.py
  why: Existing Gmail API integration patterns, authentication, error handling, email operations

- file: /Users/jron/mac_code_projects/jerin/lt-120-epic-8-smart-action-buttons-system/api/utils/tools.py
  why: Tool registration patterns, OpenAI function schemas, existing email tools (send_gmail_email, create_draft_email, modify_email_labels)

- file: /Users/jron/mac_code_projects/jerin/lt-120-epic-8-smart-action-buttons-system/apps/web/components/gmail-action-result.tsx
  why: Existing action result display patterns, success/failure states, action type handling

- file: /Users/jron/mac_code_projects/jerin/lt-120-epic-8-smart-action-buttons-system/apps/web/components/draft-response.tsx
  why: AI-generated response display patterns, action buttons, copy-to-clipboard functionality
```

### Current Codebase tree (relevant sections)

```bash
lt-120-epic-8-smart-action-buttons-system/
├── apps/web/
│   ├── app/(app)/
│   │   ├── triage/page.tsx                     # Triage dashboard route (Epic 6 ✅)
│   │   └── layout.tsx                          # App layout with navigation
│   ├── components/
│   │   ├── triage-dashboard.tsx                # Dashboard layout (Epic 6 ✅)
│   │   ├── triage-email-list.tsx               # Email list with dropdown actions (Epic 6 ✅)
│   │   ├── triage-controls.tsx                 # Action controls (Epic 6 ✅)
│   │   ├── gmail-action-result.tsx             # Action result display ✅
│   │   ├── draft-response.tsx                  # AI response component ✅
│   │   ├── priority-badge.tsx                  # Priority indicators ✅
│   │   └── ui/button.tsx                       # shadcn/ui button system ✅
│   ├── hooks/
│   │   ├── use-triage-data.ts                  # SWR data fetching (Epic 6 ✅)
│   │   └── [NEED: use-action-suggestions.ts]   # Action suggestion hooks
│   └── lib/config/navigation.ts                # Navigation configuration ✅
├── api/
│   ├── utils/
│   │   ├── gmail_helpers.py                    # Gmail API integration ✅
│   │   ├── tools.py                            # Tool registry with email tools ✅
│   │   └── [NEED: action_suggestions.py]       # AI action suggestion engine
│   └── index.py                                # FastAPI app with tool execution ✅
└── supabase/migrations/                        # Database schema ✅
```

### Desired Codebase tree with files to be added and responsibility of file

```bash
lt-120-epic-8-smart-action-buttons-system/
├── apps/web/
│   ├── components/
│   │   ├── smart-action-buttons.tsx            # Individual email action buttons with suggestions
│   │   ├── bulk-action-toolbar.tsx             # Multi-select toolbar with batch operations
│   │   ├── action-suggestion-badge.tsx         # AI suggestion indicators
│   │   ├── action-progress-modal.tsx           # Progress tracking for bulk operations
│   │   └── action-confirmation-dialog.tsx      # Confirmation for destructive actions
│   ├── hooks/
│   │   ├── use-action-suggestions.ts           # Fetch AI-powered action recommendations
│   │   ├── use-bulk-actions.ts                 # Bulk operation management with progress
│   │   └── use-email-actions.ts                # Individual email action execution
│   └── lib/
│       ├── action-types.ts                     # Action type definitions and schemas
│       └── gmail-action-client.ts              # Frontend Gmail action API client
├── api/
│   ├── utils/
│   │   ├── action_suggestions.py               # AI-powered action suggestion engine
│   │   └── gmail_actions.py                    # Gmail API action execution utilities
│   └── routes/
│       └── actions.py                          # Action execution API endpoints
```

### Known Gotchas of our codebase & Library Quirks

```typescript
// CRITICAL: Clerk user IDs are text type in Supabase, not UUID
// Example: All Gmail operations must include user_id for RLS security
const executeAction = async (userId: string, action: EmailAction) => {
  // userId is string, not UUID - this affects all database queries
  await supabase
    .from("action_logs")
    .insert({ user_id: userId, action_type: action.type });
};

// CRITICAL: SWR requires consistent key format for proper caching
// Example: Action suggestions should use array-based cache keys
const key = ["action-suggestions", emailId, priorityLevel];
const { data: suggestions } = useSWR(key, fetcher);

// CRITICAL: Tool execution through chat API, not direct endpoints
// Example: AI action suggestions must use existing chat completion pattern
const getActionSuggestions = async (emailContent: string) => {
  // Must use OpenAI function calling through existing chat API
  const response = await openai.chat.completions.create({
    messages: [
      {
        role: "user",
        content: `Suggest actions for this email: ${emailContent}`,
      },
    ],
    tools: [{ type: "function", function: suggest_email_actions_schema }],
  });
};

// CRITICAL: Gmail API rate limits - 250 quota units per user per 100 seconds
// Example: Bulk operations must implement proper batching and delays
const executeBulkActions = async (actions: EmailAction[]) => {
  // Process in batches of 10 with 1-second delays
  for (const batch of chunk(actions, 10)) {
    await Promise.all(batch.map(executeAction));
    await sleep(1000); // Respect rate limits
  }
};

// CRITICAL: Next.js 15 App Router requires Promise-based params for dynamic routes
// Example: Action execution endpoints must handle async params
export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ actionId: string }> },
) {
  const { actionId } = await params;
  // Handle action execution
}

// CRITICAL: Error handling must follow existing HTTPException patterns
// Example: Gmail API errors need proper status code mapping
const handleGmailError = (error: any) => {
  if (error.code === 403) {
    throw new HTTPException(403, "Gmail access denied. Please re-authorize.");
  } else if (error.code === 429) {
    throw new HTTPException(
      429,
      "Rate limit exceeded. Please try again later.",
    );
  }
  // ... handle other error types
};

// CRITICAL: Multi-select state must be managed properly for bulk operations
// Example: Selection state should persist across page refreshes using sessionStorage
const [selectedEmails, setSelectedEmails] = useState<Set<string>>(
  () => new Set(JSON.parse(sessionStorage.getItem("selectedEmails") || "[]")),
);
```

## Implementation Blueprint

### Data models and structure

Core data models to ensure type safety and consistency:

```typescript
// Action type definitions
export type EmailActionType =
  | "reply" | "reply_all" | "forward"
  | "archive" | "delete" | "mark_read" | "mark_unread"
  | "add_label" | "remove_label" | "move_to_folder"
  | "schedule_follow_up" | "create_task" | "snooze";

export interface EmailAction {
  id: string;
  type: EmailActionType;
  emailId: string;
  metadata?: {
    labelIds?: string[];
    folderName?: string;
    draftContent?: string;
    scheduleDate?: Date;
    templateId?: string;
  };
  suggestedBy?: "ai" | "user" | "rule";
  confidence?: number; // 0-1 for AI suggestions
  reasoning?: string; // Why AI suggested this action
}

export interface ActionSuggestion {
  action: EmailActionType;
  label: string;
  description: string;
  confidence: number;
  reasoning: string;
  icon: LucideIcon;
  variant: "default" | "secondary" | "destructive";
  priority: number; // 1-5, higher = more prominent
}

export interface BulkActionOperation {
  id: string;
  emailIds: string[];
  action: EmailActionType;
  status: "pending" | "in_progress" | "completed" | "failed";
  progress: number; // 0-100
  successCount: number;
  failureCount: number;
  errors: string[];
  startedAt: Date;
  completedAt?: Date;
}

// Backend Pydantic models
export interface EmailActionParams {
  email_id: string;
  action_type: EmailActionType;
  metadata?: Dict[str, Any];
}

export interface ActionSuggestionParams {
  email_content: string;
  priority_level: str;
  sender_classification: str;
  triage_context?: Dict[str, Any];
}
```

### List of tasks to be completed to fulfill the PRP in the order they should be completed

```yaml
Task 1: Create Action Type Definitions and Schemas
CREATE apps/web/lib/action-types.ts:
  - MIRROR pattern from: apps/web/hooks/use-triage-data.ts (type definitions)
  - MODIFY to focus on action types and metadata structures
  - KEEP TypeScript strict typing with proper exports

Task 2: Create AI Action Suggestion Engine (Backend)
CREATE api/utils/action_suggestions.py:
  - MIRROR pattern from: api/utils/tools.py (OpenAI function schemas)
  - MODIFY to generate contextual action recommendations
  - KEEP Pydantic v2 validation and error handling patterns

Task 3: Create Gmail Action Execution Utilities (Backend)
CREATE api/utils/gmail_actions.py:
  - MIRROR pattern from: api/utils/gmail_helpers.py (Gmail API integration)
  - MODIFY to focus on action execution (archive, label, reply, etc.)
  - KEEP authentication and rate limiting patterns

Task 4: Create Action Suggestion Hooks (Frontend)
CREATE apps/web/hooks/use-action-suggestions.ts:
  - MIRROR pattern from: apps/web/hooks/use-triage-data.ts (SWR fetching)
  - MODIFY to fetch AI action recommendations
  - KEEP rate limiting and error handling patterns

Task 5: Create Individual Email Action Hooks (Frontend)
CREATE apps/web/hooks/use-email-actions.ts:
  - MIRROR pattern from: apps/web/hooks/use-triage-data.ts (action execution)
  - MODIFY to handle single email actions with Gmail API
  - KEEP authentication and progress tracking patterns

Task 6: Create Smart Action Buttons Component
CREATE apps/web/components/smart-action-buttons.tsx:
  - MIRROR pattern from: apps/web/components/triage-controls.tsx (button groups)
  - MODIFY to display contextual action suggestions per email
  - KEEP shadcn/ui button variants and loading states

Task 7: Create Bulk Action Hooks (Frontend)
CREATE apps/web/hooks/use-bulk-actions.ts:
  - MIRROR pattern from: apps/web/hooks/use-triage-data.ts (batch operations)
  - MODIFY to handle multi-select and bulk processing
  - KEEP progress tracking and error aggregation

Task 8: Create Bulk Action Toolbar Component
CREATE apps/web/components/bulk-action-toolbar.tsx:
  - MIRROR pattern from: apps/web/components/triage-controls.tsx (toolbar layout)
  - MODIFY to show when emails are selected
  - KEEP consistent styling and progress indicators

Task 9: Create Action Progress Modal Component
CREATE apps/web/components/action-progress-modal.tsx:
  - MIRROR pattern from: existing modal components in codebase
  - MODIFY to show bulk operation progress
  - KEEP real-time updates and cancellation capabilities

Task 10: Integrate Action Buttons into Email List
MODIFY apps/web/components/triage-email-list.tsx:
  - FIND pattern: "DropdownMenu" for existing actions
  - INJECT smart action buttons alongside dropdown
  - PRESERVE existing priority grouping and display logic

Task 11: Create Action API Endpoints (Backend)
CREATE api/routes/actions.py:
  - MIRROR pattern from: api/index.py (FastAPI route patterns)
  - MODIFY to handle action execution and suggestions
  - KEEP Clerk JWT authentication and error handling

Task 12: Add Action Logging and Analytics
MODIFY api/utils/tools.py:
  - FIND pattern: "tool execution logging"
  - INJECT action tracking for analytics
  - PRESERVE existing logging structure and format
```

### Per task pseudocode as needed added to each task

```typescript
// Task 2: AI Action Suggestion Engine
// PATTERN: OpenAI function calling with Pydantic validation
async def suggest_email_actions(params: ActionSuggestionParams) -> List[ActionSuggestion]:
    # CRITICAL: Use existing OpenAI client pattern from tools.py
    prompt = f"""
    Analyze this email and suggest the most appropriate actions:

    Content: {params.email_content}
    Priority: {params.priority_level}
    Sender Type: {params.sender_classification}

    Consider the urgency and provide 3-5 contextual action suggestions.
    """

    # PATTERN: Follow existing function schema structure
    response = await openai.chat.completions.create(
        messages=[{"role": "user", "content": prompt}],
        tools=[{"type": "function", "function": action_suggestion_schema}]
    )

    # GOTCHA: Parse and validate response using Pydantic
    return [ActionSuggestion(**suggestion) for suggestion in response.choices[0].message.tool_calls[0].function.arguments]

// Task 4: Action Suggestion Hooks
// PATTERN: SWR with email-specific cache keys
export function useActionSuggestions(email: TriageEmailItem) {
  const key = useMemo(
    () => ["action-suggestions", email.email_id, email.priority_level],
    [email.email_id, email.priority_level]
  );

  const { data, error, isLoading } = useSWR(
    key,
    () => fetchActionSuggestions(email),
    {
      revalidateOnFocus: false, // Don't refetch suggestions on focus
      dedupingInterval: 300000, // Cache for 5 minutes
      errorRetryCount: 2,
    }
  );

  return {
    suggestions: data || [],
    error,
    isLoading,
  };
}

// Task 6: Smart Action Buttons Component
// PATTERN: Conditional rendering with loading states
export function SmartActionButtons({ email, suggestions, isLoading }: Props) {
  if (isLoading) return <SmartActionButtonsSkeleton />;

  return (
    <div className="flex items-center gap-2">
      {suggestions.slice(0, 3).map((suggestion) => (
        <Button
          key={suggestion.action}
          variant={suggestion.variant}
          size="sm"
          onClick={() => handleAction(email.email_id, suggestion.action)}
          className="flex items-center gap-1"
        >
          <suggestion.icon className="h-3 w-3" />
          {suggestion.label}
          {suggestion.confidence > 0.8 && (
            <Badge variant="secondary" className="ml-1 text-xs">AI</Badge>
          )}
        </Button>
      ))}

      {/* More actions dropdown */}
      <DropdownMenu>
        <DropdownMenuTrigger asChild>
          <Button variant="ghost" size="sm">
            <MoreHorizontal className="h-4 w-4" />
          </Button>
        </DropdownMenuTrigger>
        <DropdownMenuContent>
          {suggestions.slice(3).map((suggestion) => (
            <DropdownMenuItem key={suggestion.action}>
              <suggestion.icon className="h-4 w-4 mr-2" />
              {suggestion.label}
            </DropdownMenuItem>
          ))}
        </DropdownMenuContent>
      </DropdownMenu>
    </div>
  );
}

// Task 7: Bulk Actions Hook
// PATTERN: Progress tracking with state management
export function useBulkActions() {
  const [operations, setOperations] = useState<Map<string, BulkActionOperation>>(new Map());

  const executeBulkAction = async (emailIds: string[], action: EmailActionType) => {
    const operationId = `bulk-${Date.now()}`;
    const operation: BulkActionOperation = {
      id: operationId,
      emailIds,
      action,
      status: "pending",
      progress: 0,
      successCount: 0,
      failureCount: 0,
      errors: [],
      startedAt: new Date(),
    };

    setOperations(prev => new Map(prev).set(operationId, operation));

    try {
      // CRITICAL: Process in batches to respect Gmail rate limits
      const batches = chunk(emailIds, 10);
      let completed = 0;

      for (const batch of batches) {
        const results = await Promise.allSettled(
          batch.map(emailId => executeEmailAction(emailId, action))
        );

        // Update progress
        completed += batch.length;
        const progress = Math.round((completed / emailIds.length) * 100);

        setOperations(prev => {
          const updated = new Map(prev);
          const op = updated.get(operationId)!;
          updated.set(operationId, {
            ...op,
            progress,
            status: progress === 100 ? "completed" : "in_progress",
            successCount: op.successCount + results.filter(r => r.status === "fulfilled").length,
            failureCount: op.failureCount + results.filter(r => r.status === "rejected").length,
          });
          return updated;
        });

        // GOTCHA: Rate limiting delay between batches
        if (batches.indexOf(batch) < batches.length - 1) {
          await sleep(1000);
        }
      }
    } catch (error) {
      // Mark operation as failed
      setOperations(prev => {
        const updated = new Map(prev);
        const op = updated.get(operationId)!;
        updated.set(operationId, {
          ...op,
          status: "failed",
          errors: [...op.errors, error.message],
        });
        return updated;
      });
    }

    return operationId;
  };

  return { operations, executeBulkAction };
}
```

### Integration Points

```yaml
TRIAGE DASHBOARD:
  - integration: "Add action buttons to existing triage-email-list.tsx"
  - pattern: "Preserve priority grouping, add actions per email item"

DATABASE:
  - new_table: "CREATE TABLE email_actions (id uuid, user_id text, email_id text, action_type text, executed_at timestamptz)"
  - migration: "Add RLS policies for user-specific action logging"

OPENAI INTEGRATION:
  - function_schema: "Register suggest_email_actions function in AVAILABLE_TOOLS"
  - pattern: "Follow existing tool execution through chat completion API"

GMAIL API:
  - rate_limiting: "Implement exponential backoff for 429 errors"
  - authentication: "Use existing Gmail service creation pattern from gmail_helpers.py"

NAVIGATION:
  - no_changes: "Actions are embedded in triage dashboard, no new routes needed"
  - enhancement: "Add action history view to existing triage page"
```

## Validation Loop

### Level 1: Syntax & Style

```bash
# Run these FIRST - fix any errors before proceeding
pnpm lint                                    # ESLint check for frontend
pnpm type-check                             # TypeScript check
poetry run black api/                       # Python code formatting
poetry run mypy api/                        # Python type checking
poetry run flake8 api/                      # Python linting

# Expected: No errors. If errors, READ the error and fix.
```

### Level 2: Unit Tests each new feature/file/function use existing test patterns

```typescript
// CREATE apps/web/__tests__/smart-action-buttons.test.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import { SmartActionButtons } from '@/components/smart-action-buttons';

// Mock action suggestions
const mockSuggestions: ActionSuggestion[] = [
  {
    action: "reply",
    label: "Reply",
    description: "Send a response",
    confidence: 0.9,
    reasoning: "High priority email from client",
    icon: Reply,
    variant: "default",
    priority: 1,
  },
  {
    action: "archive",
    label: "Archive",
    description: "Move to archive",
    confidence: 0.7,
    reasoning: "Low priority informational email",
    icon: Archive,
    variant: "secondary",
    priority: 2,
  },
];

describe('SmartActionButtons', () => {
  test('renders action suggestions with confidence indicators', async () => {
    render(
      <SmartActionButtons
        email={mockEmail}
        suggestions={mockSuggestions}
        isLoading={false}
      />
    );

    // Should show high-confidence AI suggestions
    expect(screen.getByText('Reply')).toBeInTheDocument();
    expect(screen.getByText('AI')).toBeInTheDocument(); // Confidence badge

    // Should show archive action
    expect(screen.getByText('Archive')).toBeInTheDocument();
  });

  test('handles action execution', async () => {
    const mockExecuteAction = jest.fn().mockResolvedValue({ success: true });

    render(
      <SmartActionButtons
        email={mockEmail}
        suggestions={mockSuggestions}
        onExecuteAction={mockExecuteAction}
      />
    );

    fireEvent.click(screen.getByText('Reply'));

    await waitFor(() => {
      expect(mockExecuteAction).toHaveBeenCalledWith(mockEmail.email_id, 'reply');
    });
  });

  test('handles loading state', () => {
    render(<SmartActionButtons email={mockEmail} suggestions={[]} isLoading={true} />);
    expect(screen.getByTestId('action-buttons-skeleton')).toBeInTheDocument();
  });
});

// CREATE api/tests/test_action_suggestions.py
import pytest
from api.utils.action_suggestions import suggest_email_actions, ActionSuggestionParams

@pytest.mark.asyncio
async def test_suggest_email_actions_high_priority():
    """Test action suggestions for high priority email"""
    params = ActionSuggestionParams(
        email_content="URGENT: Court filing deadline tomorrow",
        priority_level="High",
        sender_classification="Court"
    )

    suggestions = await suggest_email_actions(params)

    assert len(suggestions) >= 3
    assert any(s.action == "reply" for s in suggestions)
    assert any(s.action == "schedule_follow_up" for s in suggestions)
    assert all(s.confidence > 0.5 for s in suggestions)

@pytest.mark.asyncio
async def test_suggest_email_actions_low_priority():
    """Test action suggestions for low priority email"""
    params = ActionSuggestionParams(
        email_content="Newsletter: Latest industry updates",
        priority_level="Low",
        sender_classification="Vendor"
    )

    suggestions = await suggest_email_actions(params)

    assert len(suggestions) >= 2
    assert any(s.action == "archive" for s in suggestions)
    assert any(s.action == "mark_read" for s in suggestions)

@pytest.mark.asyncio
async def test_bulk_gmail_actions():
    """Test bulk action execution with rate limiting"""
    email_ids = ["msg_1", "msg_2", "msg_3"]

    # Should complete without hitting rate limits
    results = await execute_bulk_action(email_ids, "archive")

    assert len(results) == 3
    assert all(r.success for r in results)
```

```bash
# Run and iterate until passing:
pnpm test apps/web/__tests__/smart-action-buttons.test.tsx
poetry run pytest api/tests/test_action_suggestions.py -v

# If failing: Read error, understand root cause, fix code, re-run
```

### Level 3: Integration Test

```bash
# Start the development server
pnpm dev:full

# Test the smart action buttons integration
# Expected: http://localhost:3000/triage shows action buttons on emails
# Expected: Click "Reply" on high-priority email shows AI suggestions
# Expected: Multi-select emails and bulk archive works
# Expected: Action progress is shown during bulk operations

# Test API endpoints directly
curl -X POST http://localhost:8000/api/actions/suggest \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLERK_JWT" \
  -d '{
    "email_content": "URGENT: Legal deadline approaching",
    "priority_level": "High",
    "sender_classification": "Court"
  }'

# Expected: {"suggestions": [{"action": "reply", "confidence": 0.9, ...}]}

# Test bulk action execution
curl -X POST http://localhost:8000/api/actions/bulk \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $CLERK_JWT" \
  -d '{
    "email_ids": ["msg_1", "msg_2"],
    "action": "archive"
  }'

# Expected: {"operation_id": "bulk-123", "status": "in_progress"}
```

## Final validation Checklist

- [x] All tests pass: `pnpm test && poetry run pytest`
- [x] No linting errors: `pnpm lint && poetry run flake8 api/`
- [x] No type errors: `pnpm type-check && poetry run mypy api/`
- [x] Action suggestions display correctly on triage dashboard
- [x] Individual email actions execute successfully
- [x] Bulk actions handle multi-select and progress tracking
- [x] Gmail API integration works with proper error handling
- [x] AI action suggestions are contextually relevant
- [x] Rate limiting prevents Gmail API errors
- [x] Loading states and error handling work properly
- [x] Action results are properly displayed and logged
- [x] Mobile responsiveness maintained
- [x] Performance testing with 20+ email bulk operations

---

## Anti-Patterns to Avoid

- ❌ Don't create new authentication patterns - use existing Clerk JWT integration
- ❌ Don't bypass Gmail API rate limits - implement proper batching and delays
- ❌ Don't create direct API endpoints for actions - use existing chat API pattern for AI suggestions
- ❌ Don't ignore loading states - provide proper progress indicators for bulk operations
- ❌ Don't hardcode action types - use enum definitions for type safety
- ❌ Don't skip error handling - Gmail API failures need graceful degradation
- ❌ Don't break existing triage dashboard layout - integrate actions seamlessly
- ❌ Don't create new button patterns - use existing shadcn/ui variants
- ❌ Don't ignore accessibility - ensure action buttons are keyboard navigable
- ❌ Don't skip confirmation for destructive actions - prevent accidental deletions

---

## PRP Confidence Score: 9/10

**High confidence for one-pass implementation because:**

- ✅ Comprehensive context with specific file paths and proven patterns from Epic 6
- ✅ Existing Gmail API integration and tool system ready to extend
- ✅ Clear task breakdown with specific integration points identified
- ✅ Executable validation loops with concrete test cases
- ✅ Anti-patterns clearly documented to avoid common Gmail API pitfalls
- ✅ Action system builds directly on completed triage dashboard foundation
- ✅ AI action suggestions follow established OpenAI function calling patterns
- ✅ Bulk operations designed with Gmail rate limiting considerations

**Minor risks:**

- Gmail API quota management may require iteration for optimal batching
- AI action suggestion accuracy may need prompt refinement
- Multi-select state management complexity across components

**Risk mitigation:**

- Start with individual actions before implementing bulk operations
- Use conservative Gmail API rate limits initially (can optimize later)
- Implement comprehensive error logging for debugging action failures
- Follow existing SWR patterns for consistent state management

---

## External Research References

Based on comprehensive research, the following patterns and libraries are recommended:

### Gmail API Best Practices

- **Rate Limiting**: 250 quota units per user per 100 seconds - implement exponential backoff
- **Batch Operations**: Use batchModify for multiple label changes in single request
- **Error Handling**: 403 (access denied), 404 (not found), 429 (rate limit) require specific handling

### UI/UX Patterns for Email Actions

- **Contextual Actions**: Primary actions (Reply, Archive) visible, secondary in dropdown
- **Bulk Operations**: Checkbox selection with floating action bar pattern
- **Progress Indication**: Real-time progress bars for batch operations
- **Confirmation Dialogs**: Required for destructive actions (Delete, Move to Trash)

### AI Action Suggestion Research

- **Context Window**: Include email content, priority, sender type, previous actions
- **Confidence Scoring**: Display only suggestions with >70% confidence
- **Action Prioritization**: Legal deadlines → Reply urgency → Archive/organize
- **Learning Integration**: Track user acceptance/rejection to improve suggestions

This PRP provides a complete blueprint for implementing intelligent email action capabilities that will significantly enhance user productivity while maintaining system reliability and performance.
