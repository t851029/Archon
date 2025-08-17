name: "Simple Test Feature - User Settings Toggle"
description: |

## Purpose

A simple test feature that demonstrates the Living Tree development patterns by implementing a basic user settings toggle component with persistent state management.

## Core Principles

1. **Context is King**: Include ALL necessary documentation, examples, and caveats
2. **Validation Loops**: Provide executable tests/lints the AI can run and fix
3. **Information Dense**: Use keywords and patterns from the codebase
4. **Progressive Success**: Start simple, validate, then enhance

---

## Goal

Build a simple user settings toggle feature that allows users to enable/disable notification preferences with persistent state storage in the database.

## Why

- **Business value and user impact**: Provides users with basic preference control, improving user experience
- **Integration with existing features**: Demonstrates integration with Clerk authentication and Supabase database
- **Problems this solves**: Shows how to implement basic CRUD operations with persistent state in the Living Tree architecture

## What

A settings toggle component that allows users to toggle email notification preferences with the state persisted to the database and synchronized across sessions.

### Success Criteria

- [ ] Toggle component renders in the profile page
- [ ] Toggle state persists to Supabase user_preferences table
- [ ] Toggle state loads correctly on page refresh
- [ ] Component follows existing Living Tree design patterns
- [ ] All tests pass and no TypeScript errors

## All Needed Context

### Documentation & References (list all context needed to implement the feature)

```yaml
# MUST READ - Include these in your context window
- url: https://nextjs.org/docs/app/building-your-application/data-fetching/server-actions-and-mutations
  why: Server actions pattern for database mutations

- file: apps/web/app/(app)/profile/page.tsx
  why: Where the toggle will be added, existing patterns to follow

- file: apps/web/components/ui/switch.tsx
  why: Existing toggle/switch component from shadcn/ui

- doc: https://supabase.com/docs/guides/database/tables
  section: Creating tables and RLS policies
  critical: Understanding Row Level Security for user data

- docfile: apps/web/CLAUDE.md
  why: Frontend-specific patterns and conventions
```

### Current Codebase tree (run `tree` in the root of the project) to get an overview of the codebase

```bash
apps/web/
├── app/
│   ├── (app)/
│   │   ├── profile/
│   │   │   └── page.tsx
│   │   └── layout.tsx
│   └── api/
├── components/
│   ├── ui/
│   │   └── switch.tsx
│   └── user-menu.tsx
├── hooks/
│   └── use-authenticated-fetch.ts
├── lib/
│   ├── env.ts
│   └── utils.ts
└── services/
    └── supabase.service.ts
```

### Desired Codebase tree with files to be added and responsibility of file

```bash
apps/web/
├── app/
│   ├── (app)/
│   │   ├── profile/
│   │   │   └── page.tsx                    # Add NotificationToggle component
│   └── api/
│       └── user-preferences/
│           └── route.ts                    # API route for preferences CRUD
├── components/
│   ├── ui/
│   │   └── switch.tsx                      # Existing switch component
│   └── notification-toggle.tsx             # New toggle component
├── hooks/
│   └── use-user-preferences.ts             # Hook for preferences state management
├── lib/
│   └── types.ts                           # Add UserPreferences type
└── services/
    └── user-preferences.service.ts        # Service for preferences API calls
```

### Known Gotchas of our codebase & Library Quirks

```typescript
// CRITICAL: Next.js 15 App Router - Route handlers must export named functions
// Example: export async function GET(request: NextRequest) { }

// CRITICAL: 'use client' directive must be at top of file, affects entire component tree
// Example: Components that use useState, onClick handlers need 'use client'

// CRITICAL: Server Components can't use browser APIs or event handlers
// Example: Profile page is Server Component, toggle needs to be Client Component

// CRITICAL: We use TypeScript strict mode and require proper typing
// Example: All props must have interfaces, no 'any' types allowed

// CRITICAL: Supabase RLS policies use Clerk user IDs (text type, not UUID)
// Example: auth.uid() returns text, not uuid in RLS policies

// CRITICAL: Environment variables need proper validation via lib/env.ts
// Example: Use env.SUPABASE_SERVICE_ROLE_KEY, not process.env directly
```

## Implementation Blueprint

### Data models and structure

Create the core data models, we ensure type safety and consistency.

```typescript
// User preferences type
interface UserPreferences {
  id: string;
  user_id: string; // Clerk user ID (text)
  email_notifications: boolean;
  created_at: string;
  updated_at: string;
}

// API response types
interface PreferencesResponse {
  success: boolean;
  data: UserPreferences;
  error?: string;
}

// Component prop types
interface NotificationToggleProps {
  userId: string;
  initialValue?: boolean;
}
```

### List of tasks to be completed to fulfill the PRP in the order they should be completed

```yaml
Task 1:
CREATE database migration:
  - CREATE TABLE user_preferences with proper schema
  - ADD RLS policy for user isolation using Clerk user IDs
  - ADD indexes for performance
  - TEST migration locally with npx supabase db push

Task 2:
CREATE lib/types.ts additions:
  - DEFINE UserPreferences interface
  - DEFINE API response types
  - EXPORT all preference-related types

Task 3:
CREATE services/user-preferences.service.ts:
  - IMPLEMENT getUserPreferences function
  - IMPLEMENT updateUserPreferences function
  - USE existing Supabase client patterns from services/supabase.service.ts
  - INCLUDE proper error handling

Task 4:
CREATE hooks/use-user-preferences.ts:
  - USE SWR for caching and synchronization
  - IMPLEMENT optimistic updates
  - FOLLOW patterns from existing hooks like use-triage-data.ts
  - INCLUDE loading and error states

Task 5:
CREATE components/notification-toggle.tsx:
  - USE 'use client' directive
  - IMPLEMENT toggle with shadcn/ui Switch component
  - USE use-user-preferences hook
  - INCLUDE loading and error states
  - FOLLOW existing component patterns

Task 6:
CREATE app/api/user-preferences/route.ts:
  - IMPLEMENT GET handler for fetching preferences
  - IMPLEMENT POST handler for updating preferences
  - USE Clerk authentication validation
  - FOLLOW Next.js 15 API route patterns

Task 7:
MODIFY app/(app)/profile/page.tsx:
  - IMPORT NotificationToggle component
  - ADD toggle to existing profile layout
  - PASS user ID from Clerk authentication
  - MAINTAIN existing Server Component structure
```

### Per task pseudocode as needed added to each task

```typescript
// Task 5 - NotificationToggle Component
'use client'

import { Switch } from '@/components/ui/switch'
import { useUserPreferences } from '@/hooks/use-user-preferences'

export default function NotificationToggle({ userId }: { userId: string }) {
    // PATTERN: Use SWR-based hook for state management
    const { preferences, updatePreferences, isLoading, error } = useUserPreferences(userId)

    // GOTCHA: Handle loading state to prevent flash of incorrect state
    if (isLoading) return <div>Loading...</div>

    // PATTERN: Optimistic updates for better UX
    const handleToggle = async (checked: boolean) => {
        // Optimistically update UI
        await updatePreferences({ email_notifications: checked })
    }

    return (
        <div className="flex items-center space-x-2">
            <Switch 
                checked={preferences?.email_notifications ?? false}
                onCheckedChange={handleToggle}
                disabled={isLoading}
            />
            <label>Email Notifications</label>
            {error && <span className="text-red-500">Error updating preference</span>}
        </div>
    )
}
```

### Integration Points

```yaml
DATABASE:
  - migration: "Add table 'user_preferences' with RLS policies"
  - client: "@/services/supabase.service.ts"
  - pattern: "createClient() for client components, service role for API routes"

AUTHENTICATION:
  - integration: "Clerk user ID for RLS policies"
  - pattern: "auth().userId in Server Components, useUser() in Client Components"

CONFIG:
  - environment: "Use existing Supabase environment variables"
  - pattern: "Import from @/lib/env for type safety"

ROUTES:
  - api route: "app/api/user-preferences/route.ts"
  - component: "app/(app)/profile/page.tsx"
```

## Validation Loop

### Level 1: Syntax & Style

```bash
# Run these FIRST - fix any errors before proceeding
pnpm lint                    # ESLint checks
pnpm check-types            # TypeScript type checking
pnpm format                 # Prettier formatting

# Expected: No errors. If errors, READ the error and fix.
```

### Level 2: Unit Tests each new feature/file/function use existing test patterns

```typescript
// CREATE tests/components/notification-toggle.test.tsx:
import { render, screen, fireEvent, waitFor } from '@testing-library/react'
import { NotificationToggle } from '@/components/notification-toggle'

// Mock the hook
jest.mock('@/hooks/use-user-preferences', () => ({
  useUserPreferences: jest.fn()
}))

describe('NotificationToggle', () => {
  test('renders with correct initial state', () => {
    const mockHook = {
      preferences: { email_notifications: true },
      updatePreferences: jest.fn(),
      isLoading: false,
      error: null
    }
    
    require('@/hooks/use-user-preferences').useUserPreferences.mockReturnValue(mockHook)
    
    render(<NotificationToggle userId="test-user" />)
    expect(screen.getByRole('switch')).toBeChecked()
  })

  test('calls updatePreferences when toggled', async () => {
    const mockUpdate = jest.fn()
    const mockHook = {
      preferences: { email_notifications: false },
      updatePreferences: mockUpdate,
      isLoading: false,
      error: null
    }
    
    require('@/hooks/use-user-preferences').useUserPreferences.mockReturnValue(mockHook)
    
    render(<NotificationToggle userId="test-user" />)
    fireEvent.click(screen.getByRole('switch'))
    
    await waitFor(() => {
      expect(mockUpdate).toHaveBeenCalledWith({ email_notifications: true })
    })
  })
})
```

```bash
# Run and iterate until passing:
pnpm test notification-toggle.test.tsx
# If failing: Read error, understand root cause, fix code, re-run
```

### Level 3: Integration Test

```bash
# Start the dev server
pnpm dev

# Test the page loads with toggle
curl http://localhost:3000/profile
# Expected: HTML response containing the notification toggle

# Test the API endpoint
curl -X GET http://localhost:3000/api/user-preferences \
  -H "Authorization: Bearer <clerk-jwt-token>"
# Expected: {"success": true, "data": {...}}

# Test updating preferences
curl -X POST http://localhost:3000/api/user-preferences \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer <clerk-jwt-token>" \
  -d '{"email_notifications": true}'
# Expected: {"success": true, "data": {...}}
```

### Level 4: Deployment & Creative Validation

```bash
# Production build check
pnpm build
# Expected: Successful build with no errors

# Test production build
pnpm start

# Database migration check
npx supabase db push
# Expected: Migration applies successfully

# Creative validation methods:
# - Test toggle persistence across browser sessions
# - Test with different user accounts for isolation
# - Test error scenarios (network failures, invalid data)
# - Verify RLS policies prevent cross-user access
```

## Final validation Checklist

- [ ] All tests pass: `pnpm test`
- [ ] No linting errors: `pnpm lint`
- [ ] No type errors: `pnpm check-types`
- [ ] Database migration successful: `npx supabase db push`
- [ ] API endpoints respond correctly
- [ ] Toggle state persists across page refreshes
- [ ] RLS policies prevent unauthorized access
- [ ] Component follows existing design patterns

---

## Anti-Patterns to Avoid

- ❌ Don't create new authentication patterns - use existing Clerk integration
- ❌ Don't skip RLS policies - all user data must be protected
- ❌ Don't use 'use client' unnecessarily - keep Server Components when possible
- ❌ Don't hardcode API URLs - use environment variables
- ❌ Don't ignore loading and error states - provide good UX
- ❌ Don't create new database patterns - follow existing Supabase service patterns