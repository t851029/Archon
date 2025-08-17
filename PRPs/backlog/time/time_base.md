Time Tracking Assistant - Product Requirements Document

Overview

An automated email scanning feature that identifies potentially billable time mentioned in sent emails and delivers a daily summary to help users capture unbilled hours.

Problem Statement

Professionals who bill by time often mention work activities in emails but forget to log these hours in their time tracking systems, resulting in lost revenue. Research shows that professional services firms lose 15-25% of billable hours to poor time tracking systems.

Solution

Daily automated email analysis that extracts time-related mentions and activities, delivering a structured summary for easy cross-referencing with existing time tracking systems. This feature will leverage our existing Agent infrastructure to access and analyze sent emails.

Key Features

1. Email Scanning

Scope: Scan all emails sent within a 24-hour window

Time Window: Configurable start time (e.g., 6 PM today to 6 PM yesterday)

Agent Integration: Uses existing Agent to pull sent emails from user's inbox

2. Time Detection Logic

Identify and extract:

Activity indicators:

"Drafted agreement"

"Reviewed contract"

"Prepared presentation"

"Attended meeting"

"Analyzed data"

Context: Include email recipient and subject for reference

Agent Prompt: Detection logic built into Agent prompt for processing

3. Daily Summary Email

Delivery: Automated email sent back to user shortly after scan completion

Format: Structured table containing:

Time/Duration detected

Activity description

Email context (recipient, subject)

Timestamp

Confidence level (high/medium/low)

4. User Configuration

Toggle: On/off switch for feature

Schedule: Set daily scan time

Detection sensitivity: Adjustable threshold for time detection

5. Tools Page Integration

New Tile: Add "Time Tracking" tile to existing tools page

Status Display: Show enabled/disabled state and next scan time

Quick Toggle: Enable/disable directly from tools page

User Flow

User enables Time Tracking tool in tools page

User configures scan time (e.g., 6 PM daily)

System automatically scans emails at scheduled time

System processes and extracts time-related data

User receives summary email within 15 minutes

User reviews summary and cross-references with time tracking system

User manually enters any missing time entries that were found

Success Metrics

Adoption Rate: % of users who enable the time tracking tool

Daily Emails Sent: Number of summary emails successfully delivered

Entries Found: Count of potential billable entries identified per user

MVP Scope

Basic activity keyword detection

Simple table format email summary

Daily schedule only

Fixed time estimates for common activities

Future Scope

Configurable Billing Rates: Allow users to customize time estimates for different activities (e.g., "draft email" = 0.2 hours, "reviewed contract" = 0.3 hours)

Custom Activity Dictionary: Users can add their own activity keywords and associated time values

Future Enhancements: Integration with popular time tracking tools

Codebase Context & Implementation Guide

Existing Patterns to Follow

1. Auto-Drafts Tool Pattern (Primary Reference)

The auto-drafts feature provides an excellent template for this implementation:

Frontend Configuration (apps/web/lib/tools-config.ts):

{
id: 'auto-drafts',
name: 'Auto Drafts',
description: 'Automatically generate contextual email responses for incoming messages',
category: 'email',
icon: 'Sparkles',
enabled: false,
capabilities: [...],
status: 'inactive',
requiresAuth: true,
authStatus: 'disconnected',
usageCount: 0,
hasSettings: true
}

Backend Monitor Pattern (api/utils/auto_draft_monitor.py):

Uses asyncio for background processing

Periodically checks for new emails

Processes emails based on user settings

Stores results in database

2. Email Fetching Pattern (api/utils/tools.py)

async def list_emails(
params: ListEmailsParams,
service: Resource = Depends(get_gmail_service)
) -> ListEmailsOutput: # Query Gmail API with specific parameters
request_params = {
"userId": "me",
"maxResults": params.max_results,
"q": params.query # e.g., "is:sent newer_than:1d"
}

3. Email Sending Pattern (api/utils/gmail_helpers.py)

def send_email(
service: Resource,
to: str,
subject: str,
body_text: str,
body_html: Optional[str] = None
) -> Optional[Dict[str, Any]]: # Creates and sends email via Gmail API

Implementation Blueprint

Phase 1: Database Schema

Create migration file: supabase/migrations/YYYYMMDDHHMMSS_add_time_tracking.sql

-- Time tracking settings table
CREATE TABLE time_tracking_settings (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
user_id TEXT NOT NULL UNIQUE,
enabled BOOLEAN DEFAULT false,
scan_time TIME DEFAULT '18:00:00', -- 6 PM default
time_window_hours INTEGER DEFAULT 24,
min_confidence_score REAL DEFAULT 0.5,
send_summary_email BOOLEAN DEFAULT true,
created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Time tracking results table
CREATE TABLE time_tracking_results (
id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
user_id TEXT NOT NULL,
email_id TEXT NOT NULL,
activity_type TEXT NOT NULL,
activity_description TEXT NOT NULL,
duration_minutes INTEGER,
confidence_score REAL,
email_recipient TEXT,
email_subject TEXT,
email_date TIMESTAMP WITH TIME ZONE,
scan_date DATE DEFAULT CURRENT_DATE,
created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
UNIQUE(user_id, email_id, activity_description)
);

-- Enable RLS
ALTER TABLE time_tracking_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE time_tracking_results ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can manage their own time tracking settings"
ON time_tracking_settings FOR ALL
USING (user_id = current_setting('request.jwt.claims', true)::json->>'sub');

CREATE POLICY "Users can view their own time tracking results"
ON time_tracking_results FOR ALL
USING (user_id = current_setting('request.jwt.claims', true)::json->>'sub');

Phase 2: Frontend Tool Integration

Add to apps/web/lib/tools-config.ts:

{
id: 'time-tracking',
name: 'Time Tracking Assistant',
description: 'Automatically detect billable hours from your sent emails',
category: 'productivity',
icon: 'Clock',
enabled: false,
capabilities: [
'Scan sent emails for time entries',
'Detect common billing activities',
'Daily summary emails',
'Configurable scan schedule',
'Adjustable confidence thresholds'
],
status: 'inactive',
requiresAuth: true,
authStatus: 'disconnected',
usageCount: 0,
hasSettings: true
}

Create Settings Dialog: apps/web/components/tools/time-tracking-dialog.tsx
(Follow pattern from auto-drafts-dialog.tsx)

Phase 3: Backend Implementation

Create Time Tracking Monitor: api/utils/time_tracking_monitor.py

import asyncio
import re
from datetime import datetime, timedelta, time
from typing import List, Dict, Pattern, Tuple
import logging

# Activity detection patterns based on research

ACTIVITY_PATTERNS: List[Tuple[Pattern, str, int]] = [
# Pattern, Activity Type, Default Minutes
(re.compile(r'\b(review(?:ed)?|analyz(?:e|ed))\s+(?:\w+\s+)*(contract|agreement)', re.I),
'Contract Review', 30),
(re.compile(r'\b(draft(?:ed)?|prepar(?:e|ed))\s+(?:\w+\s+)*(contract|agreement)', re.I),
'Contract Drafting', 60),
(re.compile(r'\b(draft(?:ed)?|prepar(?:e|ed))\s+(?:\w+\s+)*(letter|correspondence|email)', re.I),
'Correspondence', 15),
(re.compile(r'\battend(?:ed)?\s+(?:\w+\s+)*(meeting|call|conference)', re.I),
'Meeting/Call', 60),
(re.compile(r'\b(research(?:ed)?|investigat(?:e|ed))\s+(?:\w+\s+)*(issue|matter|case)', re.I),
'Research', 45),
(re.compile(r'\b(prepar(?:e|ed)|draft(?:ed)?)\s+(?:\w+\s+)*(presentation|report)', re.I),
'Report/Presentation', 90),
]

class TimeTrackingMonitor:
"""Monitors sent emails and extracts time tracking entries."""

    def __init__(self):
        self.is_running = False
        self.processing_interval = 3600  # 1 hour
        self.last_run_times: Dict[str, datetime] = {}

    async def start_monitoring(self):
        """Start the monitoring loop."""
        self.is_running = True
        logger.info("🕐 Starting time tracking monitoring")

        while self.is_running:
            try:
                await self._check_scheduled_scans()
                await asyncio.sleep(60)  # Check every minute
            except Exception as e:
                logger.error(f"Monitor error: {str(e)}", exc_info=True)
                await asyncio.sleep(300)  # 5 min on error

    async def _check_scheduled_scans(self):
        """Check if any users need their scheduled scan."""
        current_time = datetime.now().time()

        # Get all enabled users with their scan times
        supabase = get_supabase_client()
        result = supabase.table("time_tracking_settings")\
            .select("*")\
            .eq("enabled", True)\
            .execute()

        for settings in result.data:
            user_id = settings["user_id"]
            scan_time = time.fromisoformat(settings["scan_time"])

            # Check if it's time to scan and we haven't already today
            if self._should_scan(user_id, scan_time, current_time):
                asyncio.create_task(self._scan_user_emails(user_id, settings))

    def _extract_time_entries(self, email_body: str) -> List[Dict]:
        """Extract time tracking entries from email body."""
        entries = []

        for pattern, activity_type, default_minutes in ACTIVITY_PATTERNS:
            matches = pattern.findall(email_body)
            for match in matches:
                # Calculate confidence based on match quality
                confidence = 0.8 if len(match) > 1 else 0.6

                entries.append({
                    'activity_type': activity_type,
                    'activity_description': ' '.join(match) if isinstance(match, tuple) else match,
                    'duration_minutes': default_minutes,
                    'confidence_score': confidence
                })

        return entries

    async def _generate_summary_email(self, user_id: str, entries: List[Dict]) -> str:
        """Generate HTML summary email."""
        # Group entries by confidence level
        high_confidence = [e for e in entries if e['confidence_score'] >= 0.7]
        medium_confidence = [e for e in entries if 0.5 <= e['confidence_score'] < 0.7]

        html = """
        <html>
        <body style="font-family: Arial, sans-serif; max-width: 800px; margin: 0 auto;">
            <h2>📊 Daily Time Tracking Summary</h2>
            <p>Here are the potential billable activities detected in your sent emails today:</p>

            <h3>High Confidence Entries</h3>
            <table style="width: 100%; border-collapse: collapse;">
                <tr style="background-color: #f0f0f0;">
                    <th style="padding: 10px; text-align: left;">Activity</th>
                    <th style="padding: 10px;">Duration</th>
                    <th style="padding: 10px;">Email Context</th>
                </tr>
        """

        total_minutes = 0
        for entry in high_confidence:
            total_minutes += entry['duration_minutes']
            html += f"""
                <tr>
                    <td style="padding: 10px; border-bottom: 1px solid #ddd;">
                        <strong>{entry['activity_type']}</strong><br>
                        {entry['activity_description']}
                    </td>
                    <td style="padding: 10px; text-align: center; border-bottom: 1px solid #ddd;">
                        {entry['duration_minutes']} min
                    </td>
                    <td style="padding: 10px; border-bottom: 1px solid #ddd;">
                        To: {entry.get('email_recipient', 'N/A')}<br>
                        Re: {entry.get('email_subject', 'N/A')[:50]}...
                    </td>
                </tr>
            """

        html += f"""
            </table>
            <p><strong>Total Potential Billable Time: {total_minutes / 60:.1f} hours</strong></p>

            <p style="color: #666; font-size: 0.9em; margin-top: 30px;">
                This summary was automatically generated based on your sent emails.
                Please review and add any missing entries to your time tracking system.
            </p>
        </body>
        </html>
        """

        return html

Create API Endpoints: api/routes/time_tracking.py

from fastapi import APIRouter, Depends, HTTPException
from api.core.auth import verify_clerk_jwt
from api.core.dependencies import get_supabase_client

router = APIRouter(prefix="/api/time-tracking", tags=["time-tracking"])

@router.get("/settings")
async def get_settings(user_id: str = Depends(verify_clerk_jwt)):
"""Get user's time tracking settings."""
supabase = get_supabase_client()
result = supabase.table("time_tracking_settings")\
 .select("\*")\
 .eq("user_id", user_id)\
 .single()\
 .execute()

    if not result.data:
        # Return defaults if no settings exist
        return {
            "enabled": False,
            "scan_time": "18:00:00",
            "time_window_hours": 24,
            "min_confidence_score": 0.5,
            "send_summary_email": True
        }

    return result.data

@router.post("/settings")
async def update_settings(
settings: TimeTrackingSettings,
user_id: str = Depends(verify_clerk_jwt)
):
"""Update user's time tracking settings."""
supabase = get_supabase_client()

    # Upsert settings
    result = supabase.table("time_tracking_settings")\
        .upsert({
            "user_id": user_id,
            **settings.dict(),
            "updated_at": datetime.utcnow().isoformat()
        })\
        .execute()

    return {"success": True, "settings": result.data[0]}

@router.post("/analyze")
async def manual_analyze(user_id: str = Depends(verify_clerk_jwt)):
"""Manually trigger email analysis.""" # Implementation for manual trigger
pass

Email Parsing Regex Patterns

Based on research, here are the comprehensive regex patterns for detecting billable activities:

# Legal/Professional Activity Patterns

ACTIVITY_PATTERNS = [ # Document Review
(r'\b(review(?:ed)?|analyz(?:e|ed)|examin(?:e|ed))\s+(?:\w+\s+){0,3}(contract|agreement|document|proposal|brief|motion)',
'Document Review', 30),

    # Drafting Activities
    (r'\b(draft(?:ed)?|prepar(?:e|ed)|wro(?:te|tten)|creat(?:e|ed))\s+(?:\w+\s+){0,3}(contract|agreement|letter|memo|brief|motion|proposal)',
     'Document Drafting', 60),

    # Communication
    (r'\b(call(?:ed)?|spoke|discuss(?:ed)?|meet(?:ing)?|confer(?:ence|red)?)\s+(?:with\s+)?(?:\w+\s+){0,3}(client|counsel|team|regarding)',
     'Client Communication', 30),

    # Research
    (r'\b(research(?:ed)?|investigat(?:e|ed)|analyz(?:e|ed))\s+(?:\w+\s+){0,3}(case|law|statute|regulation|precedent|issue)',
     'Legal Research', 45),

    # Time Duration Extraction
    (r'\b(\d+(?:\.\d+)?)\s*(hours?|hrs?|minutes?|mins?)\b', None, None),

]

Integration with Existing Systems

Gmail API Integration: Uses existing get_gmail_service dependency

Authentication: Leverages Clerk JWT validation

Database: Follows Supabase RLS patterns with text user IDs

Monitoring: Extends AsyncIO pattern from auto-draft monitor

Frontend: Integrates with existing tools page architecture

Error Handling Strategy

try: # Gmail API call
emails = await fetch_sent_emails(service, query)
except HttpError as e:
if e.resp.status == 401:
logger.error(f"Gmail auth failed for user {user_id}") # Mark user as needing reauth
elif e.resp.status == 429:
logger.warning("Gmail rate limit reached") # Implement exponential backoff
else:
logger.error(f"Gmail API error: {e}")
except Exception as e:
logger.error(f"Unexpected error: {e}", exc_info=True) # Store error state for user visibility

Implementation Tasks (In Order)

Database Setup

Create migration file with time tracking tables

Apply migration locally: npx supabase db push

Regenerate types: pnpm types

Frontend Tool Configuration

Add time-tracking tool to tools-config.ts

Update ToolCategory type if adding 'productivity' category

Create time-tracking-dialog.tsx component

Backend Monitor Implementation

Create time_tracking_monitor.py

Add activity detection regex patterns

Implement email scanning logic

Create summary email generation

API Endpoints

Create api/routes/time_tracking.py

Add to main FastAPI app in index.py

Implement settings CRUD operations

Add manual analysis trigger endpoint

Email Parsing & Processing

Implement regex pattern matching

Add confidence scoring logic

Create time entry extraction

Handle edge cases and variations

Integration & Testing

Wire up frontend toggle to backend

Test scheduled scanning

Verify email summary generation

Add unit tests for parsing logic

Documentation

Update API documentation

Add user guide for time tracking

Document activity patterns

Validation Gates

Frontend Validation

# Type checking and linting

cd apps/web
pnpm type-check
pnpm lint

# Build verification

pnpm build

Backend Validation

# Type checking

cd api
poetry run mypy api/

# Unit tests for time tracking

poetry run pytest tests/test_time_tracking.py -v

# Docker build test

docker build -f api/Dockerfile -t test-backend .

Integration Testing

# Full stack test

pnpm dev:full

# Manual test checklist:

# 1. Enable time tracking in tools page

# 2. Configure scan time to 5 minutes from now

# 3. Send test email with "Reviewed contract for client X"

# 4. Wait for scheduled scan

# 5. Verify summary email received

# 6. Check database for stored entries

Database Validation

# Verify migrations

npx supabase migration list

# Check generated types include new tables

grep -E "time_tracking_settings|time_tracking_results" apps/web/types/supabase.ts

External Resources & Documentation

Email Parsing Best Practices: https://www.nylas.com/products/email-api/what-is-email-parsing/

Regex Pattern Testing: https://regex101.com/

AsyncIO Background Tasks: https://docs.python.org/3/library/asyncio-task.html

Gmail API Query Reference: https://developers.google.com/gmail/api/guides/filtering

Common Pitfalls to Avoid

Gmail API Rate Limits: Implement exponential backoff

Time Zone Issues: Store all times in UTC, convert for display

Duplicate Detection: Use unique constraint on (user_id, email_id, activity)

Memory Growth: Clear processed email cache periodically

regex Performance: Pre-compile patterns, limit backtracking

Success Criteria

Tool appears in tools page with working toggle

Settings dialog saves configuration to database

Monitor runs at scheduled time and processes emails

Time entries are correctly extracted from email content

Summary email is sent with formatted results

All tests pass and code meets quality standards

Confidence Score: 8.5/10

The implementation path is clear with strong existing patterns to follow. The auto-drafts feature provides an excellent template, and the Gmail API integration is already proven. The main complexity lies in the regex patterns for activity detection, but the research provides good starting patterns that can be refined based on user feedback.
