# PRP: Replace Navigation with shadcn Sidebar-07 Component

## Executive Summary

Replace the current `SimpleSidebar` component with shadcn's `sidebar-07` component to improve UI consistency, accessibility, and maintainability while preserving all existing functionality.

## Background

### Current Implementation Analysis

The existing navigation uses a custom `SimpleSidebar` component located at `/apps/web/components/simple-sidebar.tsx` with:
- Collapsible functionality (expand/collapse to icon-only mode)
- Two navigation sections: "top" and "bottom"
- Integrated user menu in the footer
- Tooltips when collapsed
- Active state tracking
- Tailwind CSS styling with dark/light theme support

### Navigation Structure (from `/apps/web/lib/config/navigation.ts`)
```typescript
- Dashboard (top)
- Chat (top)
- Agent Tools (top)
- Email Triage (top)
- Integrations (top)
- Profile (bottom)
- Settings (bottom)
- Debug (bottom)
```

### Integration Points
- Used in `/apps/web/app/(app)/layout.tsx`
- Depends on:
  - `@/components/user-menu`
  - `@/components/logo`
  - `@/lib/config/navigation`
  - shadcn UI components: Button, Tooltip
  - lucide-react icons

## Research Findings

### shadcn Sidebar-07 Features
Based on research from https://ui.shadcn.com/view/sidebar-07:
- **Core Feature**: "A sidebar that collapses to icons"
- **Composable Architecture**: SidebarProvider, Sidebar, SidebarHeader, SidebarContent, SidebarFooter, SidebarMenu, etc.
- **State Persistence**: Cookie-based state management for collapse/expand
- **Built-in Accessibility**: ARIA attributes, keyboard navigation
- **Theming**: CSS variable-based theming compatible with existing setup

### Key Differences to Address
1. **Component Structure**: shadcn uses a provider-based architecture vs current single component
2. **State Management**: Cookie-based vs React state
3. **User Menu Integration**: Need to adapt current UserMenu component
4. **Logo Placement**: Adapt Logo component to new header structure

## Implementation Blueprint

### Phase 1: Installation and Setup

```bash
# Install the sidebar component and its dependencies
npx shadcn@latest add sidebar

# This will install:
# - components/ui/sidebar.tsx (main component)
# - hooks/use-sidebar.ts (state management)
# - Required dependencies
```

### Phase 2: Create AppSidebar Component

Create `/apps/web/components/app-sidebar.tsx`:

```typescript
"use client"

import { navigationConfig } from "@/lib/config/navigation"
import { Logo } from "@/components/logo"
import { UserMenu } from "@/components/user-menu"
import {
  Sidebar,
  SidebarContent,
  SidebarFooter,
  SidebarGroup,
  SidebarGroupContent,
  SidebarHeader,
  SidebarMenu,
  SidebarMenuItem,
  SidebarMenuButton,
  SidebarSeparator,
  useSidebar,
} from "@/components/ui/sidebar"
import Link from "next/link"
import { usePathname } from "next/navigation"

export function AppSidebar() {
  const pathname = usePathname()
  const { state } = useSidebar()
  const isCollapsed = state === "collapsed"

  // Active state logic
  const isActive = (href: string) => {
    if (href === "/dashboard") {
      return pathname === "/" || pathname === "/dashboard"
    }
    return pathname === href || pathname.startsWith(href + "/")
  }

  // Top navigation items
  const topNavItems = navigationConfig.navLinks.filter(
    (link) => link.navLocation === "top"
  )

  // Bottom navigation items
  const bottomNavItems = navigationConfig.navLinks.filter(
    (link) => link.navLocation === "bottom"
  )

  return (
    <Sidebar collapsible="icon">
      <SidebarHeader>
        <Link href="/dashboard" className="flex items-center">
          <Logo showText={!isCollapsed} size="sm" />
        </Link>
      </SidebarHeader>
      
      <SidebarContent>
        <SidebarGroup>
          <SidebarGroupContent>
            <SidebarMenu>
              {topNavItems.map((item) => (
                <SidebarMenuItem key={item.href}>
                  <SidebarMenuButton 
                    asChild 
                    isActive={isActive(item.href)}
                  >
                    <Link href={item.href}>
                      <item.icon className="h-4 w-4" />
                      <span>{item.label}</span>
                    </Link>
                  </SidebarMenuButton>
                </SidebarMenuItem>
              ))}
            </SidebarMenu>
          </SidebarGroupContent>
        </SidebarGroup>
      </SidebarContent>

      <SidebarFooter>
        <SidebarMenu>
          {bottomNavItems.map((item) => (
            <SidebarMenuItem key={item.href}>
              <SidebarMenuButton 
                asChild 
                isActive={isActive(item.href)}
              >
                <Link href={item.href}>
                  <item.icon className="h-4 w-4" />
                  <span>{item.label}</span>
                </Link>
              </SidebarMenuButton>
            </SidebarMenuItem>
          ))}
        </SidebarMenu>
        <SidebarSeparator />
        <div className="p-2">
          <UserMenu 
            showLabel={!isCollapsed} 
            align={isCollapsed ? "center" : "start"} 
          />
        </div>
      </SidebarFooter>
    </Sidebar>
  )
}
```

### Phase 3: Update Layout Component

Update `/apps/web/app/(app)/layout.tsx`:

```typescript
import { SidebarProvider, SidebarTrigger } from "@/components/ui/sidebar"
import { AppSidebar } from "@/components/app-sidebar"

export default function AppLayout({ children }: { children: React.ReactNode }) {
  return (
    <SidebarProvider>
      <div className="flex h-screen relative">
        <AppSidebar />
        <div className="flex-1 flex flex-col">
          {/* Header */}
          <header className="flex h-16 items-center justify-between border-b border-border px-6">
            <div className="flex items-center gap-4">
              <SidebarTrigger />
              <h1 className="text-lg font-semibold">Living Tree</h1>
            </div>
          </header>

          {/* Page Content */}
          <main className="flex-1 overflow-auto p-6">
            {children}
          </main>
        </div>
      </div>
    </SidebarProvider>
  )
}
```

### Phase 4: Cleanup

1. Remove `/apps/web/components/simple-sidebar.tsx`
2. Remove unused imports from layout
3. Update any tests that reference SimpleSidebar

## Task Breakdown

1. **Install shadcn sidebar component** (10 mins)
   - Run installation command
   - Verify component files created

2. **Create AppSidebar component** (30 mins)
   - Implement component with navigation structure
   - Integrate Logo and UserMenu components
   - Implement active state logic

3. **Update app layout** (20 mins)
   - Replace SimpleSidebar with new implementation
   - Add SidebarProvider wrapper
   - Add SidebarTrigger to header

4. **Test functionality** (20 mins)
   - Verify all navigation links work
   - Test collapse/expand functionality
   - Check active states
   - Test responsive behavior
   - Verify theme switching works

5. **Cleanup old code** (10 mins)
   - Remove SimpleSidebar component
   - Clean up imports
   - Update any related tests

## Validation Gates

```bash
# 1. Type checking
cd apps/web && pnpm check-types

# 2. Linting
pnpm lint

# 3. Build verification
pnpm build:web

# 4. Manual testing checklist
# - [ ] All navigation links route correctly
# - [ ] Sidebar collapses to icons
# - [ ] Active states display properly
# - [ ] Mobile responsive behavior works
# - [ ] Keyboard navigation functions
# - [ ] Theme switching works
# - [ ] User menu displays correctly
# - [ ] No console errors
```

## Error Handling Strategy

1. **Component Import Errors**: Ensure all shadcn dependencies are installed
2. **State Management Issues**: Verify SidebarProvider wraps the entire layout
3. **Styling Conflicts**: Check for CSS variable conflicts in globals.css
4. **Icon Display Issues**: Ensure lucide-react icons are properly imported

## Gotchas and Considerations

1. **Cookie-based State**: The shadcn sidebar uses cookies for persistence. Ensure this doesn't conflict with any existing state management.

2. **UserMenu Integration**: The UserMenu component expects `showLabel` and `align` props - ensure these are passed correctly based on sidebar state.

3. **Logo Component**: The Logo component accepts `showText` and `size` props - adapt based on collapsed state.

4. **Route Matching**: The current implementation has special logic for the dashboard route (`/` or `/dashboard`). This must be preserved.

5. **Theme Compatibility**: The shadcn sidebar uses CSS variables that should be compatible with the existing theme setup, but verify dark/light mode transitions work smoothly.

## Documentation References

- shadcn Sidebar Documentation: https://ui.shadcn.com/docs/components/sidebar
- sidebar-07 Demo: https://ui.shadcn.com/view/sidebar-07
- Current SimpleSidebar: `/apps/web/components/simple-sidebar.tsx`
- Navigation Config: `/apps/web/lib/config/navigation.ts`

## Success Criteria

✅ All existing navigation functionality preserved
✅ Improved accessibility with ARIA attributes
✅ Smooth collapse/expand animations
✅ State persistence across page reloads
✅ No regression in responsive behavior
✅ Clean removal of old code
✅ All validation gates pass

## Confidence Score: 9/10

This PRP provides comprehensive context for a one-pass implementation. The only uncertainty is around potential edge cases in the UserMenu integration, but the existing patterns are well-documented.