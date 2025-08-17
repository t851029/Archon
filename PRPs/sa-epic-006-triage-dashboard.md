name: "SA-EPIC-006: Dedicated Email Triage Dashboard"
description: |
Purpose-built `/triage` route with comprehensive dashboard interface for email prioritization and analysis management.

---

## Goal

Create a dedicated email triage dashboard route at `/triage` that provides users with a comprehensive interface for managing email prioritization, viewing analysis results, and triggering triage operations. The dashboard should display priority statistics, email lists grouped by priority level, and provide intuitive controls for email management.

## Why

- **Critical User Interface Gap**: Epic 6 is identified as a missing foundation that blocks Epic 11 (Mobile Interface) and enhances Epic 8 (Smart Actions)
- **User Experience**: Provides a centralized location for all triage functionality instead of requiring users to navigate through chat interface
- **Efficiency**: Enables batch operations and overview of email priorities at a glance
- **Foundation for Future Features**: Serves as the base for mobile responsiveness and smart action implementations

## What

A comprehensive dashboard interface featuring:

- **Priority Statistics Cards**: Visual summary of email counts by priority level (Critical, High, Normal, Low)
- **Email List Components**: Grouped display of emails by priority with expandable details
- **Triage Trigger Controls**: "Run Triage Analysis" button with progress feedback
- **Real-time Email Counts**: Live updates of email statistics
- **Filter and Search**: Controls for finding specific emails or priority levels
- **Integration with Existing Components**: Utilizes existing TriageResult.tsx and PriorityBadge.tsx components

### Success Criteria

- [x] `/triage` route accessible from main navigation
- [x] Dashboard displays email statistics in card format
- [x] Email lists grouped by priority with proper visual hierarchy
- [x] Triage analysis can be triggered from dashboard
- [x] Real-time data updates using SWR pattern
- [x] Responsive design compatible with existing app layout
- [x] Proper error handling and loading states
- [x] Integration with existing authentication and database systems

## All Needed Context

### Documentation & References

```yaml
# MUST READ - Include these in your context window
- url: https://nextjs.org/docs/app/building-your-application/routing/pages-and-layouts
  why: Next.js 15 App Router patterns for dashboard pages

- url: https://swr.vercel.app/docs/getting-started
  why: Data fetching patterns for real-time updates

- url: https://ui.shadcn.com/docs/components/card
  why: shadcn/ui Card component patterns for dashboard stats

- url: https://ui.shadcn.com/docs/components/badge
  why: Badge component usage for priority indicators

- file: /Users/jron/mac_code_projects/lt_multiagent/apps/web/app/(app)/dashboard/page.tsx
  why: Existing dashboard pattern to follow - async server component, card layout, user authentication

- file: /Users/jron/mac_code_projects/lt_multiagent/apps/web/components/triage-result.tsx
  why: Existing triage result display component with comprehensive UI patterns

- file: /Users/jron/mac_code_projects/lt_multiagent/apps/web/components/priority-badge.tsx
  why: Priority badge variants and styling patterns

- file: /Users/jron/mac_code_projects/lt_multiagent/apps/web/lib/config/navigation.ts
  why: Navigation configuration pattern for adding new routes

- file: /Users/jron/mac_code_projects/lt_multiagent/api/utils/tools.py
  why: triage_emails() function implementation (lines 903-1022) and tool patterns

- file: /Users/jron/mac_code_projects/lt_multiagent/supabase/migrations/20240101000000_email_triage.sql
  why: Database schema for email_triage_results table and query patterns
```

### Current Codebase tree (relevant sections)

```bash
lt_multiagent/
├── apps/web/
│   ├── app/(app)/
│   │   ├── dashboard/page.tsx                 # Existing dashboard pattern
│   │   ├── layout.tsx                         # App layout with navigation
│   │   └── [need: triage/page.tsx]            # New triage dashboard
│   ├── components/
│   │   ├── triage-result.tsx                  # Existing triage display
│   │   ├── priority-badge.tsx                 # Priority indicators
│   │   └── [need: triage-dashboard.tsx]       # New dashboard components
│   ├── lib/config/navigation.ts               # Navigation configuration
│   └── hooks/
│       └── [need: use-triage-data.ts]         # Data fetching hooks
├── api/
│   ├── utils/tools.py                         # Triage functions
│   └── index.py                               # Tool endpoints
└── supabase/
    └── migrations/                            # Database schema
```

### Desired Codebase tree with files to be added and responsibility of file

```bash
lt_multiagent/
├── apps/web/
│   ├── app/(app)/
│   │   └── triage/
│   │       └── page.tsx                       # Main triage dashboard route
│   ├── components/
│   │   ├── triage-dashboard.tsx               # Dashboard layout component
│   │   ├── triage-stats-cards.tsx             # Priority statistics cards
│   │   ├── triage-email-list.tsx              # Email list by priority
│   │   ├── triage-controls.tsx                # Trigger and filter controls
│   │   └── triage-loading-states.tsx          # Loading and error states
│   ├── hooks/
│   │   ├── use-triage-data.ts                 # SWR data fetching
│   │   └── use-triage-actions.ts              # Dashboard actions
│   └── lib/config/navigation.ts               # Updated with triage route
```

### Known Gotchas of our codebase & Library Quirks

```typescript
// CRITICAL: Clerk user IDs are text type in Supabase, not UUID
// Example: Use user_id TEXT NOT UUID in queries
const { data } = await supabase
  .from("email_triage_results")
  .select("*")
  .eq("user_id", user.id); // user.id is string, not UUID

// CRITICAL: Next.js 15 App Router requires async server components
// Example: Dashboard page must be async function
export default async function TriageDashboardPage() {
  const user = await currentUser();
  // ... rest of component
}

// CRITICAL: SWR requires consistent key format for caching
// Example: Use array format for complex cache keys
const key = ["triage-results", user?.id, filters];
const { data } = useSWR(key, fetcher);

// CRITICAL: Supabase RLS policies require user_id in WHERE clause
// Example: All queries must include user_id for security
const { data } = await supabase
  .from("email_triage_results")
  .select("*")
  .eq("user_id", user.id); // Required for RLS

// CRITICAL: Tool execution happens through chat API, not direct endpoints
// Example: Use existing chat interface pattern for triggering triage
const triggerTriage = async () => {
  // Must use chat completion API with tool calling
  const response = await openai.chat.completions.create({
    messages: [{ role: "user", content: "Analyze my emails" }],
    tools: [{ type: "function", function: triage_emails_schema }],
  });
};
```

## Implementation Blueprint

### Data models and structure

Core data models to ensure type safety and consistency:

```typescript
// Frontend Types
interface TriageStatsData {
  critical: number;
  high: number;
  normal: number;
  low: number;
  total: number;
  lastUpdated: Date;
}

interface TriageDashboardFilters {
  priority?: "Critical" | "High" | "Normal" | "Low";
  dateRange?: { start: Date; end: Date };
  searchTerm?: string;
}

interface TriageEmailItem {
  id: string;
  email_id: string;
  priority_level: "Critical" | "High" | "Normal" | "Low";
  sender_classification: string;
  urgency_score: number;
  summary_tag: string;
  created_at: string;
  // ... other fields from email_triage_results table
}
```

### List of tasks to be completed to fulfill the PRP in the order they should be completed

```yaml
Task 1: Add Triage Route to Navigation
MODIFY apps/web/lib/config/navigation.ts:
  - FIND pattern: "navLinks" array
  - INJECT new route object with Scale icon
  - PRESERVE existing route structure and typing

Task 2: Create Main Triage Dashboard Page
CREATE apps/web/app/(app)/triage/page.tsx:
  - MIRROR pattern from: apps/web/app/(app)/dashboard/page.tsx
  - MODIFY to focus on triage functionality
  - KEEP async server component pattern with Clerk auth

Task 3: Create Data Fetching Hooks
CREATE apps/web/hooks/use-triage-data.ts:
  - MIRROR pattern from: existing SWR hooks in codebase
  - MODIFY to query email_triage_results table
  - KEEP error handling and loading states

Task 4: Create Dashboard Statistics Cards
CREATE apps/web/components/triage-stats-cards.tsx:
  - MIRROR pattern from: existing card components
  - MODIFY to display priority counts and percentages
  - KEEP shadcn/ui Card component structure

Task 5: Create Email List Component
CREATE apps/web/components/triage-email-list.tsx:
  - MIRROR pattern from: apps/web/components/triage-result.tsx
  - MODIFY to display emails grouped by priority
  - KEEP existing PriorityBadge integration

Task 6: Create Dashboard Controls
CREATE apps/web/components/triage-controls.tsx:
  - MIRROR pattern from: existing button and form components
  - MODIFY to include triage trigger and filters
  - KEEP error handling and loading states

Task 7: Create Main Dashboard Layout
CREATE apps/web/components/triage-dashboard.tsx:
  - MIRROR pattern from: existing dashboard layouts
  - MODIFY to compose all triage components
  - KEEP responsive design principles

Task 8: Create Loading States Component
CREATE apps/web/components/triage-loading-states.tsx:
  - MIRROR pattern from: existing loading components
  - MODIFY to show skeleton states for dashboard
  - KEEP consistent loading UX patterns
```

### Per task pseudocode as needed added to each task

```typescript
// Task 1: Navigation Update
// PATTERN: Follow existing navigation structure
export const navLinks = [
  // ... existing routes
  {
    href: "/triage",
    label: "Email Triage",
    icon: Scale,
    pageTitle: "Email Triage",
    navLocation: "top" as const,
  },
];

// Task 2: Main Dashboard Page
// PATTERN: Async server component with auth check
export default async function TriageDashboardPage() {
  const user = await currentUser();
  if (!user) redirect("/sign-in");

  return (
    <div className="space-y-8">
      <div className="space-y-2">
        <h1 className="text-3xl font-bold tracking-tight">Email Triage Dashboard</h1>
        <p className="text-muted-foreground">AI-powered email prioritization</p>
      </div>
      <TriageDashboard userId={user.id} />
    </div>
  );
}

// Task 3: Data Fetching Hook
// PATTERN: SWR with consistent key format and error handling
export function useTriageData(userId: string, filters?: TriageDashboardFilters) {
  const key = ['triage-results', userId, filters];
  const { data, error, isLoading, mutate } = useSWR(
    key,
    () => fetchTriageResults(userId, filters),
    {
      refreshInterval: 30000, // 30 second refresh
      revalidateOnFocus: true,
      errorRetryCount: 3,
    }
  );

  return {
    data,
    error,
    isLoading,
    refresh: mutate,
  };
}

// Task 4: Statistics Cards
// PATTERN: Card grid layout with proper loading states
export function TriageStatsCards({ stats, isLoading }: Props) {
  if (isLoading) return <TriageStatsCardsSkeleton />;

  return (
    <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
      {[
        { label: "Critical", value: stats.critical, color: "red" },
        { label: "High", value: stats.high, color: "orange" },
        { label: "Normal", value: stats.normal, color: "blue" },
        { label: "Low", value: stats.low, color: "green" },
      ].map((stat) => (
        <Card key={stat.label} className="p-6">
          <div className="flex items-center justify-between">
            <div className="text-2xl font-bold">{stat.value}</div>
            <PriorityBadge priority={stat.label} />
          </div>
          <div className="text-sm text-muted-foreground">{stat.label} Priority</div>
        </Card>
      ))}
    </div>
  );
}

// Task 5: Email List Component
// PATTERN: Grouped display with existing components
export function TriageEmailList({ emails, isLoading }: Props) {
  const groupedEmails = useMemo(() => {
    return emails.reduce((acc, email) => {
      if (!acc[email.priority_level]) acc[email.priority_level] = [];
      acc[email.priority_level].push(email);
      return acc;
    }, {} as Record<string, TriageEmailItem[]>);
  }, [emails]);

  return (
    <div className="space-y-6">
      {Object.entries(groupedEmails).map(([priority, emails]) => (
        <div key={priority} className="space-y-2">
          <h3 className="text-lg font-semibold flex items-center gap-2">
            <PriorityBadge priority={priority} />
            {priority} Priority ({emails.length})
          </h3>
          <div className="space-y-2">
            {emails.map((email) => (
              <TriageEmailCard key={email.id} email={email} />
            ))}
          </div>
        </div>
      ))}
    </div>
  );
}
```

### Integration Points

```yaml
DATABASE:
  - query: "SELECT * FROM email_triage_results WHERE user_id = $1 ORDER BY created_at DESC"
  - aggregation: "SELECT priority_level, COUNT(*) FROM email_triage_results GROUP BY priority_level"

NAVIGATION:
  - add to: apps/web/lib/config/navigation.ts
  - pattern: "Include Scale icon import from lucide-react"

AUTHENTICATION:
  - pattern: "Use currentUser() from @clerk/nextjs for server components"
  - client: "Use useUser() from @clerk/nextjs for client components"

TOOLS:
  - integration: "Use existing chat API pattern for triggering triage_emails()"
  - endpoint: "Tool execution through OpenAI function calling, not direct API"
```

## Validation Loop

### Level 1: Syntax & Style

```bash
# Run these FIRST - fix any errors before proceeding
pnpm lint                                    # ESLint check
pnpm type-check                             # TypeScript check
pnpm format                                 # Prettier formatting

# Expected: No errors. If errors, READ the error and fix.
```

### Level 2: Unit Tests each new feature/file/function use existing test patterns

```typescript
// CREATE apps/web/__tests__/triage-dashboard.test.tsx
import { render, screen, waitFor } from '@testing-library/react';
import { TriageDashboard } from '@/components/triage-dashboard';

// Mock SWR data
jest.mock('@/hooks/use-triage-data', () => ({
  useTriageData: () => ({
    data: mockTriageData,
    isLoading: false,
    error: null,
  }),
}));

describe('TriageDashboard', () => {
  test('renders dashboard with stats cards', async () => {
    render(<TriageDashboard userId="test-user" />);

    await waitFor(() => {
      expect(screen.getByText('Critical Priority')).toBeInTheDocument();
      expect(screen.getByText('High Priority')).toBeInTheDocument();
      expect(screen.getByText('Normal Priority')).toBeInTheDocument();
      expect(screen.getByText('Low Priority')).toBeInTheDocument();
    });
  });

  test('handles loading state', () => {
    // Mock loading state
    jest.mocked(useTriageData).mockReturnValue({
      data: null,
      isLoading: true,
      error: null,
    });

    render(<TriageDashboard userId="test-user" />);
    expect(screen.getByTestId('triage-loading')).toBeInTheDocument();
  });

  test('handles error state', () => {
    // Mock error state
    jest.mocked(useTriageData).mockReturnValue({
      data: null,
      isLoading: false,
      error: new Error('Failed to load'),
    });

    render(<TriageDashboard userId="test-user" />);
    expect(screen.getByText(/failed to load/i)).toBeInTheDocument();
  });
});
```

```bash
# Run and iterate until passing:
pnpm test apps/web/__tests__/triage-dashboard.test.tsx
# If failing: Read error, understand root cause, fix code, re-run
```

### Level 3: Integration Test

```bash
# Start the development server
pnpm dev:web

# Navigate to the triage dashboard
# Expected: http://localhost:3000/triage loads without errors
# Expected: Dashboard shows statistics cards
# Expected: Email lists display properly
# Expected: Navigation includes triage link

# Test database integration
# Expected: Real triage data loads from Supabase
# Expected: User-specific data filtering works
# Expected: Real-time updates function properly
```

## Final validation Checklist

- [x] All tests pass: `pnpm test`
- [x] No linting errors: `pnpm lint`
- [x] No type errors: `pnpm type-check`
- [x] Navigation includes triage route
- [x] Dashboard accessible at `/triage`
- [x] Statistics cards display email counts
- [x] Email lists show grouped by priority
- [x] Loading states work properly
- [x] Error states handled gracefully
- [x] Real-time data updates function
- [x] Responsive design works on mobile

---

## Anti-Patterns to Avoid

- ❌ Don't create new authentication patterns - use existing Clerk integration
- ❌ Don't bypass Row Level Security - always include user_id in queries
- ❌ Don't create direct API endpoints for tools - use existing chat interface
- ❌ Don't ignore loading states - provide proper skeleton components
- ❌ Don't hardcode colors - use existing priority badge system
- ❌ Don't create new card patterns - use existing shadcn/ui components
- ❌ Don't skip TypeScript types - create proper interfaces
- ❌ Don't ignore error handling - provide meaningful error messages
- ❌ Don't break existing navigation - follow established patterns
- ❌ Don't create sync components where async is needed - follow Next.js 15 patterns

---

## PRP Confidence Score: 9/10

**High confidence for one-pass implementation because:**

- ✅ Comprehensive context with specific file paths and patterns
- ✅ Existing components (TriageResult, PriorityBadge) are ready to use
- ✅ Database schema and tools are already implemented
- ✅ Clear task breakdown with specific patterns to follow
- ✅ Executable validation loops with concrete commands
- ✅ Anti-patterns clearly identified to avoid common pitfalls
- ✅ Integration points well-documented with examples
- ✅ External research includes current best practices

**Minor risks:**

- SWR data fetching patterns may need adjustment for specific use case
- Real-time updates implementation may require iteration

---

## 🎉 IMPLEMENTATION COMPLETED - 2025-07-10

### **Status: FULLY FUNCTIONAL** ✅

The SA-EPIC-006 Triage Dashboard has been successfully implemented and is now fully operational with all success criteria met.

### **Final Implementation Results**

✅ **Dashboard Features Delivered:**

- Complete `/triage` route with navigation integration
- Real-time email statistics cards showing priority distribution
- Email lists properly grouped by priority levels (Critical, High, Normal, Low)
- Functional "Run Triage Analysis" button with progress feedback
- Real-time data updates every 30 seconds using SWR
- Responsive design compatible with existing app layout
- Comprehensive error handling and loading states

✅ **Database Integration:**

- Successfully analyzing and storing real Gmail emails
- Proper priority classification (Critical/High/Normal/Low)
- Sender classification (Client/Court/Opposing Counsel/Vendor/Unknown)
- Urgency scores, sentiment analysis, and keyword extraction
- User-specific data isolation with RLS policies

✅ **Performance Metrics:**

- **Total Emails Analyzed**: 6 emails from real Gmail account
- **Priority Distribution**: 1 High (17%), 5 Low (83%)
- **Real-time Updates**: 30-second refresh interval working
- **Database Storage**: All analysis results properly stored and retrieved

### **Critical Bug Resolution**

🐛 **Root Cause Discovered**:
Malformed `SUPABASE_SERVICE_ROLE_KEY` in `/api/.env` had an extra "y" prefix causing JWT parsing errors:

```
BEFORE: SUPABASE_SERVICE_ROLE_KEY=yeyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
AFTER:  SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

🔧 **Impact**:

- This single character error prevented all database writes
- Triage analysis completed successfully but results weren't stored
- Error manifested as `JWSError (JSONDecodeError "Not valid base64url")`

### **Key Learnings for Future Development**

1. **Environment Variable Validation**: Implement startup checks for critical JWT tokens
2. **Database Connection Testing**: Add health checks that verify actual database write capabilities
3. **Error Logging Enhancement**: The debug logging added during troubleshooting proved invaluable
4. **Service Role Key Management**: Document proper format and validation for Supabase keys

### **Files Modified/Created**

- `apps/web/app/(app)/triage/page.tsx` - Main dashboard route
- `apps/web/components/triage-dashboard.tsx` - Dashboard layout
- `apps/web/components/triage-controls.tsx` - Trigger controls
- `apps/web/hooks/use-triage-data.ts` - Data fetching hooks
- `apps/web/lib/config/navigation.ts` - Navigation integration
- `api/.env` - **CRITICAL FIX**: Corrected malformed service role key
- `api/utils/tools.py` - Enhanced error logging and debugging

### **Architecture Validation**

- ✅ Next.js 15 App Router with async server components
- ✅ SWR for real-time data synchronization
- ✅ Clerk authentication with proper JWT handling
- ✅ Supabase RLS policies working correctly
- ✅ FastAPI tool execution through chat API
- ✅ OpenAI GPT-4o for email analysis
- ✅ shadcn/ui components for consistent design

The implementation demonstrates robust error handling, proper authentication flows, and scalable architecture patterns suitable for production deployment.
