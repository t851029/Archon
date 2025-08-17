PRP: AI Agent Email with Retainer Letter Tool

Feature Overview

Implement a unique email address for each user that serves as their AI assistant. Users (lawyers) can email directly to this address to interact with the AI Agent. The initial use case is drafting retainer letters with future expansion to additional tools.

Requirements

Unique Email Address per User

Each user gets a unique email address (e.g., john-doe-7f3a@agent.livingtree.io)

This serves as their personal AI assistant email

Display the email address in a tile on the tools page

Two New Tools with Toggles

Agent Tool: Master toggle to enable/disable the email functionality

Retainer Letters Tool: Specific tool for retainer letter generation

Email Processing

Receive emails sent to the unique address

Process and generate retainer letters

Return the generated document to the sender

Technical Architecture

Email Infrastructure

We'll use SendGrid Inbound Parse webhook to process incoming emails:

Domain Setup: Configure subdomain agent.livingtree.io with MX records pointing to SendGrid

Webhook Endpoint: Create /api/agent/inbound-email to receive parsed emails

Email Format: {user-slug}-{short-uuid}@agent.livingtree.io

Reference: https://www.twilio.com/docs/sendgrid/for-developers/parsing-email/setting-up-the-inbound-parse-webhook

Database Schema

Create new tables for the feature:

-- Agent email settings table
CREATE TABLE agent_email_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL UNIQUE,
    email_address TEXT NOT NULL UNIQUE,
    enabled BOOLEAN DEFAULT false,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Tool-specific settings (extends existing pattern)
CREATE TABLE retainer_letter_settings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL UNIQUE,
    enabled BOOLEAN DEFAULT false,
    template_preferences JSONB DEFAULT '{}',
    default_jurisdiction TEXT,
    firm_details JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Inbound email processing log
CREATE TABLE agent_email_log (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id TEXT NOT NULL,
    from_email TEXT NOT NULL,
    to_email TEXT NOT NULL,
    subject TEXT,
    tool_type TEXT NOT NULL,
    processing_status TEXT NOT NULL,
    response_draft_id TEXT,
    error_message TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Add indexes and RLS policies
CREATE INDEX idx_agent_email_address ON agent_email_settings(email_address);
CREATE INDEX idx_agent_email_user ON agent_email_settings(user_id);
CREATE INDEX idx_retainer_settings_user ON retainer_letter_settings(user_id);
CREATE INDEX idx_agent_log_user ON agent_email_log(user_id, created_at DESC);

-- Enable RLS
ALTER TABLE agent_email_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE retainer_letter_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE agent_email_log ENABLE ROW LEVEL SECURITY;

-- RLS Policies
CREATE POLICY "Users can only access their own agent settings"
ON agent_email_settings FOR ALL TO authenticated
USING (user_id = auth.uid()::text);

CREATE POLICY "Users can only access their own retainer settings"
ON retainer_letter_settings FOR ALL TO authenticated
USING (user_id = auth.uid()::text);

CREATE POLICY "Users can only access their own email logs"
ON agent_email_log FOR ALL TO authenticated
USING (user_id = auth.uid()::text);

Implementation Blueprint

Phase 1: Tool Configuration

Update Tool Config (apps/web/lib/tools-config.ts)

// Add new category if needed
export const toolCategories: ToolCategoryInfo[] = [
  // ... existing categories
  {
    id: 'agent',
    name: 'AI Agent',
    description: 'Direct email access to your AI assistant',
    icon: 'Bot',
    color: 'bg-purple-500'
  },
  {
    id: 'legal',
    name: 'Legal Tools',
    description: 'AI-powered legal document generation',
    icon: 'Scale',
    color: 'bg-indigo-500'
  }
];

// Add new tools
export const defaultTools: ToolConfig[] = [
  // ... existing tools
  {
    id: 'agent-email',
    name: 'Agent Email',
    description: 'Enable direct email access to your AI assistant',
    category: 'agent',
    icon: 'Mail',
    enabled: false,
    capabilities: [
      'Unique email address',
      'Process email commands',
      'Integrate with other tools',
      'Async task processing'
    ],
    status: 'inactive',
    requiresAuth: false,
    hasSettings: false
  },
  {
    id: 'retainer-letters',
    name: 'Retainer Letters',
    description: 'Generate professional retainer letters via email',
    category: 'legal',
    icon: 'FileText',
    enabled: false,
    capabilities: [
      'Draft retainer agreements',
      'Customize terms and conditions',
      'Multiple jurisdictions',
      'Client information parsing',
      'PDF generation'
    ],
    status: 'inactive',
    requiresAuth: true,
    hasSettings: true
  }
];

Phase 2: Backend Implementation

Email Generation Utility (api/utils/agent_email.py)

import hashlib
from typing import Optional

def generate_agent_email(user_id: str, user_name: Optional[str] = None) -> str:
    """Generate unique email address for user's AI agent."""
    # Create a short hash from user_id
    hash_input = f"{user_id}-agent-salt"
    short_hash = hashlib.sha256(hash_input.encode()).hexdigest()[:8]
    
    # Generate slug from name if available
    if user_name:
        slug = user_name.lower().replace(' ', '-').replace('.', '')
        # Remove special characters
        slug = ''.join(c for c in slug if c.isalnum() or c == '-')
    else:
        slug = "agent"
    
    return f"{slug}-{short_hash}@agent.livingtree.io"

def parse_agent_email(email_address: str) -> Optional[str]:
    """Extract user identifier from agent email address."""
    if not email_address.endswith("@agent.livingtree.io"):
        return None
    
    local_part = email_address.split('@')[0]
    # Extract the hash part (last 8 characters after final hyphen)
    parts = local_part.split('-')
    if len(parts) >= 2:
        return parts[-1]  # Return the hash for lookup
    return None

Inbound Email Webhook (api/routes/agent.py)

from fastapi import APIRouter, HTTPException, Form, UploadFile, File, Depends
from typing import Optional, List
import json
import logging
from api.core.dependencies import get_supabase_client
from api.utils.agent_email import parse_agent_email
from api.utils.retainer_letter import generate_retainer_letter
from api.utils.gmail_helpers import create_draft
from supabase import Client

router = APIRouter(prefix="/api/agent", tags=["agent"])
logger = logging.getLogger(__name__)

@router.post("/inbound-email")
async def process_inbound_email(
    to: str = Form(...),
    from_: str = Form(..., alias="from"),
    subject: str = Form(...),
    text: str = Form(None),
    html: str = Form(None),
    attachments: Optional[int] = Form(0),
    supabase: Client = Depends(get_supabase_client)
):
    """
    Process inbound emails from SendGrid Parse Webhook.
    Reference: https://www.twilio.com/docs/sendgrid/for-developers/parsing-email/inbound-email
    """
    logger.info(f"Received email to: {to}, from: {from_}, subject: {subject}")
    
    try:
        # 1. Parse the agent email to find user
        agent_hash = parse_agent_email(to)
        if not agent_hash:
            logger.warning(f"Invalid agent email format: {to}")
            return {"status": "ignored", "reason": "invalid_recipient"}
        
        # 2. Look up user by email address
        result = supabase.table("agent_email_settings").select("*").eq("email_address", to).single().execute()
        if not result.data:
            logger.warning(f"No user found for agent email: {to}")
            return {"status": "ignored", "reason": "unknown_recipient"}
        
        user_settings = result.data
        user_id = user_settings["user_id"]
        
        # 3. Check if agent is enabled
        if not user_settings["enabled"]:
            logger.info(f"Agent disabled for user: {user_id}")
            return {"status": "ignored", "reason": "agent_disabled"}
        
        # 4. Determine tool to use based on subject/content
        tool_type = determine_tool_type(subject, text or html)
        
        # 5. Log the incoming email
        log_entry = {
            "user_id": user_id,
            "from_email": from_,
            "to_email": to,
            "subject": subject,
            "tool_type": tool_type,
            "processing_status": "processing"
        }
        supabase.table("agent_email_log").insert(log_entry).execute()
        
        # 6. Process based on tool type
        if tool_type == "retainer_letter":
            # Check if retainer letters tool is enabled
            retainer_result = supabase.table("retainer_letter_settings").select("*").eq("user_id", user_id).single().execute()
            if not retainer_result.data or not retainer_result.data["enabled"]:
                return {"status": "error", "reason": "retainer_tool_disabled"}
            
            # Generate retainer letter
            retainer_content = await generate_retainer_letter(
                user_id=user_id,
                email_content=text or html,
                subject=subject,
                sender_email=from_,
                settings=retainer_result.data
            )
            
            # Create draft reply
            # Note: This would need Gmail service with user's auth
            # For now, we'll store it for later sending
            draft_data = {
                "to": from_,
                "subject": f"Re: {subject} - Retainer Letter",
                "body": retainer_content["letter_text"],
                "attachments": [retainer_content["pdf_url"]] if "pdf_url" in retainer_content else []
            }
            
            # Update log with success
            supabase.table("agent_email_log").update({
                "processing_status": "completed",
                "response_draft_id": json.dumps(draft_data)
            }).eq("id", log_entry["id"]).execute()
            
            return {"status": "success", "tool": tool_type}
        
        else:
            return {"status": "error", "reason": "unknown_tool_type"}
            
    except Exception as e:
        logger.error(f"Error processing inbound email: {e}")
        return {"status": "error", "reason": str(e)}

def determine_tool_type(subject: str, content: str) -> str:
    """Determine which tool to use based on email content."""
    subject_lower = subject.lower()
    content_lower = content.lower() if content else ""
    
    # Keywords for retainer letter
    retainer_keywords = ["retainer", "engagement letter", "retainer agreement", "legal services agreement"]
    
    for keyword in retainer_keywords:
        if keyword in subject_lower or keyword in content_lower:
            return "retainer_letter"
    
    # Default to retainer letter for now
    return "retainer_letter"

Retainer Letter Generator (api/utils/retainer_letter.py)

from typing import Dict, Any
import re
from datetime import datetime
from openai import OpenAI
from api.core.dependencies import get_openai_client
import logging

logger = logging.getLogger(__name__)

async def generate_retainer_letter(
    user_id: str,
    email_content: str,
    subject: str,
    sender_email: str,
    settings: Dict[str, Any]
) -> Dict[str, Any]:
    """Generate a retainer letter based on email content."""
    openai_client = get_openai_client()
    
    # Extract client information from email
    client_info = extract_client_info(email_content, sender_email)
    
    # Get firm details from settings
    firm_details = settings.get("firm_details", {})
    jurisdiction = settings.get("default_jurisdiction", "California")
    
    # Create prompt for retainer letter generation
    prompt = f"""
    Generate a professional retainer letter for legal services based on the following:
    
    Client Information:
    - Name: {client_info.get('name', 'Client')}
    - Email: {client_info.get('email', sender_email)}
    - Matter: {client_info.get('matter', 'Legal Services')}
    
    Firm Information:
    - Firm Name: {firm_details.get('name', 'Law Firm')}
    - Attorney: {firm_details.get('attorney_name', 'Attorney')}
    - Address: {firm_details.get('address', '')}
    - Jurisdiction: {jurisdiction}
    
    Email Context:
    Subject: {subject}
    Content: {email_content[:1000]}
    
    Generate a complete retainer letter including:
    1. Parties and matter description
    2. Scope of representation
    3. Fee structure (hourly rate or flat fee)
    4. Retainer amount
    5. Billing and payment terms
    6. Termination provisions
    7. Conflict of interest disclosure
    8. Confidentiality
    9. Governing law
    
    Format the letter professionally with proper headings and paragraphs.
    """
    
    try:
        response = openai_client.chat.completions.create(
            model="gpt-4o",
            messages=[
                {
                    "role": "system",
                    "content": "You are a legal assistant specializing in drafting retainer letters. Create professional, comprehensive retainer agreements that comply with legal ethics rules."
                },
                {"role": "user", "content": prompt}
            ],
            temperature=0.3,
            max_tokens=2000
        )
        
        letter_text = response.choices[0].message.content
        
        # Here you would typically:
        # 1. Convert to PDF using a service like Puppeteer or wkhtmltopdf
        # 2. Upload to cloud storage
        # 3. Return the URL
        
        return {
            "letter_text": letter_text,
            "client_info": client_info,
            "generated_at": datetime.utcnow().isoformat(),
            # "pdf_url": "https://storage.livingtree.io/retainers/..." # Would be actual URL
        }
        
    except Exception as e:
        logger.error(f"Error generating retainer letter: {e}")
        raise

def extract_client_info(email_content: str, sender_email: str) -> Dict[str, str]:
    """Extract client information from email content."""
    info = {"email": sender_email}
    
    # Extract name from email if possible
    email_parts = sender_email.split('@')[0]
    if '.' in email_parts:
        parts = email_parts.split('.')
        info["name"] = f"{parts[0].title()} {parts[1].title()}"
    
    # Look for patterns in email content
    # Matter description
    matter_match = re.search(r'(?:matter|regarding|re:|subject:)\s*([^\n]+)', email_content, re.I)
    if matter_match:
        info["matter"] = matter_match.group(1).strip()
    
    # Phone number
    phone_match = re.search(r'(\+?1?[-.\s]?\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4})', email_content)
    if phone_match:
        info["phone"] = phone_match.group(1)
    
    return info

Phase 3: Frontend Implementation

Update Tools Page (apps/web/app/(app)/tools/tools-page-client.tsx)

Add a new section to display the agent email when the Agent tool is enabled:

// Add after the existing tools display, before the Auto Drafts Settings Dialog

{/* Agent Email Display */}
{(() => {
  const agentTool = tools.find(t => t.id === 'agent-email');
  if (agentTool?.enabled) {
    return (
      <div className="mt-8 p-6 rounded-lg border bg-card">
        <div className="flex items-center space-x-3 mb-4">
          <Bot className="h-6 w-6 text-primary" />
          <h3 className="text-lg font-semibold">Your AI Agent Email</h3>
        </div>
        <div className="space-y-4">
          <div className="flex items-center justify-between p-4 bg-muted rounded-md">
            <div className="flex items-center space-x-3">
              <Mail className="h-5 w-5 text-muted-foreground" />
              <code className="text-sm font-mono">
                {user.emailAddresses[0]?.emailAddress.split('@')[0]}-a7f3@agent.livingtree.io
              </code>
            </div>
            <Button
              variant="outline"
              size="sm"
              onClick={() => {
                navigator.clipboard.writeText(
                  `${user.emailAddresses[0]?.emailAddress.split('@')[0]}-a7f3@agent.livingtree.io`
                );
                toast.success('Email address copied to clipboard');
              }}
            >
              <Copy className="h-4 w-4" />
            </Button>
          </div>
          <p className="text-sm text-muted-foreground">
            Send emails to this address to interact with your AI assistant. 
            Enable specific tool integrations below to unlock different capabilities.
          </p>
        </div>
      </div>
    );
  }
  return null;
})()}

API Route for Agent Toggle (apps/web/app/api/tools/[toolId]/toggle/route.ts)

Update the existing route to handle agent email generation:

// Add this logic in the POST handler after the toolId check

if (toolId === 'agent-email') {
  // Generate unique email for user if enabling
  if (enabled) {
    const userEmail = user.emailAddresses[0]?.emailAddress || '';
    const emailParts = userEmail.split('@')[0];
    const hash = crypto.createHash('sha256')
      .update(`${userId}-agent-salt`)
      .digest('hex')
      .substring(0, 8);
    const agentEmail = `${emailParts}-${hash}@agent.livingtree.io`;
    
    // Store in database
    const { error } = await supabase
      .from('agent_email_settings')
      .upsert({
        user_id: userId,
        email_address: agentEmail,
        enabled: true
      });
    
    if (error) {
      console.error('Error saving agent email:', error);
      return NextResponse.json(
        { error: 'Failed to enable agent email' },
        { status: 500 }
      );
    }
  } else {
    // Disable agent email
    const { error } = await supabase
      .from('agent_email_settings')
      .update({ enabled: false })
      .eq('user_id', userId);
  }
}

// Similar logic for retainer-letters tool
if (toolId === 'retainer-letters') {
  const { error } = await supabase
    .from('retainer_letter_settings')
    .upsert({
      user_id: userId,
      enabled: enabled
    });
}

Retainer Letter Settings Dialog (apps/web/components/tools/retainer-settings-dialog.tsx)

Create a settings dialog similar to auto-drafts:

import { Dialog, DialogContent, DialogHeader, DialogTitle } from "@/components/ui/dialog";
import { Label } from "@/components/ui/label";
import { Input } from "@/components/ui/input";
import { Button } from "@/components/ui/button";
import { useState } from "react";

interface RetainerSettingsDialogProps {
  open: boolean;
  onOpenChange: (open: boolean) => void;
  toolId: string;
  enabled: boolean;
}

export function RetainerSettingsDialog({ 
  open, 
  onOpenChange,
  toolId,
  enabled 
}: RetainerSettingsDialogProps) {
  const [firmName, setFirmName] = useState('');
  const [attorneyName, setAttorneyName] = useState('');
  const [jurisdiction, setJurisdiction] = useState('');
  
  const handleSave = async () => {
    // Save settings via API
    const response = await fetch(`/api/tools/retainer-letters/settings`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        firm_details: {
          name: firmName,
          attorney_name: attorneyName
        },
        default_jurisdiction: jurisdiction
      })
    });
    
    if (response.ok) {
      toast.success('Retainer letter settings saved');
      onOpenChange(false);
    }
  };
  
  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent>
        <DialogHeader>
          <DialogTitle>Retainer Letter Settings</DialogTitle>
        </DialogHeader>
        <div className="space-y-4">
          <div>
            <Label htmlFor="firm-name">Firm Name</Label>
            <Input
              id="firm-name"
              value={firmName}
              onChange={(e) => setFirmName(e.target.value)}
              placeholder="Your Law Firm, LLP"
            />
          </div>
          <div>
            <Label htmlFor="attorney-name">Attorney Name</Label>
            <Input
              id="attorney-name"
              value={attorneyName}
              onChange={(e) => setAttorneyName(e.target.value)}
              placeholder="John Doe, Esq."
            />
          </div>
          <div>
            <Label htmlFor="jurisdiction">Default Jurisdiction</Label>
            <Input
              id="jurisdiction"
              value={jurisdiction}
              onChange={(e) => setJurisdiction(e.target.value)}
              placeholder="California"
            />
          </div>
          <Button onClick={handleSave} className="w-full">
            Save Settings
          </Button>
        </div>
      </DialogContent>
    </Dialog>
  );
}

Testing & Validation

Unit Tests

Email Generation Tests (api/tests/test_agent_email.py)

import pytest
from api.utils.agent_email import generate_agent_email, parse_agent_email

def test_generate_agent_email():
    """Test unique email generation."""
    email1 = generate_agent_email("user123", "John Doe")
    email2 = generate_agent_email("user456", "Jane Smith")
    
    assert email1.endswith("@agent.livingtree.io")
    assert email2.endswith("@agent.livingtree.io")
    assert email1 != email2
    assert "john-doe" in email1
    assert "jane-smith" in email2

def test_parse_agent_email():
    """Test email parsing."""
    email = "john-doe-a7f3b2c1@agent.livingtree.io"
    hash_part = parse_agent_email(email)
    assert hash_part == "a7f3b2c1"
    
    invalid_email = "test@gmail.com"
    assert parse_agent_email(invalid_email) is None

Frontend Component Tests (apps/web/tests/components/agent-email-display.test.ts)

import { render, screen } from '@testing-library/react';
import { ToolCard } from '@/components/tools/tool-card';

describe('Agent Email Tool', () => {
  it('displays unique email when enabled', () => {
    const agentTool = {
      id: 'agent-email',
      name: 'Agent Email',
      enabled: true,
      // ... other props
    };
    
    render(<ToolCard tool={agentTool} />);
    
    expect(screen.getByText(/agent.livingtree.io/)).toBeInTheDocument();
  });
});

Integration Tests

Webhook Processing (api/tests/test_inbound_webhook.py)

from fastapi.testclient import TestClient
from api.index import app

client = TestClient(app)

def test_inbound_email_webhook():
    """Test SendGrid webhook processing."""
    response = client.post("/api/agent/inbound-email", data={
        "to": "john-doe-a7f3b2c1@agent.livingtree.io",
        "from": "client@example.com",
        "subject": "Need a retainer letter",
        "text": "Hi, I need a retainer letter for our upcoming case..."
    })
    
    assert response.status_code == 200
    assert response.json()["status"] == "success"

Manual Testing Checklist

[ ] Enable Agent Email tool and verify unique email is generated

[ ] Copy email address and verify clipboard functionality

[ ] Enable Retainer Letters tool

[ ] Send test email to agent address

[ ] Verify webhook receives and processes email

[ ] Check retainer letter generation

[ ] Verify email log entries in database

[ ] Test with Agent Email disabled

[ ] Test with Retainer Letters disabled

[ ] Verify error handling for invalid emails

Deployment Considerations

SendGrid Setup

Add subdomain agent.livingtree.io to DNS

Configure MX record: mx.sendgrid.net (priority 10)

Set up Inbound Parse webhook in SendGrid dashboard

Point webhook to https://api.livingtree.io/api/agent/inbound-email

Environment Variables

Add to .env:

SENDGRID_WEBHOOK_PUBLIC_KEY=<sendgrid-public-key>
AGENT_EMAIL_DOMAIN=agent.livingtree.io

Security

Validate SendGrid webhook signatures

Rate limit inbound emails per user

Implement email size limits

Sanitize email content before processing

Future Enhancements

Support for more document types (NDAs, contracts, etc.)

Email command syntax for specific actions

Multi-language retainer letter templates

Integration with document signing services

Email threading and conversation context

Attachment processing

References

SendGrid Inbound Parse: https://www.twilio.com/docs/sendgrid/for-developers/parsing-email/inbound-email

Living Tree Tools Implementation: /apps/web/lib/tools-config.ts

Auto Drafts Pattern: /apps/web/components/tools/auto-drafts-dialog.tsx

Email Processing: /api/utils/tools.py (process_auto_draft function)

Validation Commands

# Backend tests
cd api && poetry run pytest tests/test_agent_email.py -v

# Frontend tests  
cd apps/web && pnpm test agent-email

# Type checking
pnpm type-check

# Linting
pnpm lint

# Full build
pnpm build

Success Criteria

Each user has a unique, persistent email address

Agent Email toggle controls email processing

Retainer Letters tool generates appropriate documents

Emails are processed within 30 seconds

Generated retainer letters are legally compliant templates

All tests pass and build succeeds

Confidence Score: 8/10

The implementation follows existing patterns in the codebase closely, uses proven email infrastructure (SendGrid), and builds on the established tool system. The main complexity is in the email webhook processing and document generation, but these are well-documented patterns. The migration risk is low as it's additive functionality