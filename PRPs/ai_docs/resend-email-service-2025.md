# Resend Email Service Integration Guide - 2025

## Overview

Resend is a modern email service specifically designed for developers, offering a superior alternative to SendGrid with React-native integration patterns perfect for Next.js applications.

## Why Resend for Living Tree

1. **Developer-First Design**: Built specifically for React/Next.js applications
2. **React Email Templates**: Native support for react-email library
3. **Webhook System**: Real-time email event tracking with reliable delivery
4. **Next.js Integration**: Official documentation and patterns for Next.js 15
5. **Pricing**: Competitive pricing with no hidden fees for premium support

## Integration Architecture

### Next.js Route Handler Pattern

```typescript
// app/api/send/route.ts
import { Resend } from 'resend';
import { EmailTemplate } from '@/components/email-template';

const resend = new Resend(process.env.RESEND_API_KEY);

export async function POST(request: Request) {
  try {
    const { to, subject, ...data } = await request.json();
    
    const { data: result, error } = await resend.emails.send({
      from: 'agent@livingtree.io',
      to: [to],
      subject: subject,
      react: EmailTemplate({ ...data }),
    });

    if (error) {
      return Response.json({ error }, { status: 400 });
    }

    return Response.json(result);
  } catch (error) {
    return Response.json({ error }, { status: 500 });
  }
}
```

### Webhook Processing for Inbound Emails

```typescript
// app/api/webhooks/resend/route.ts
import { NextRequest } from 'next/server';
import { headers } from 'next/headers';

export async function POST(request: NextRequest) {
  const body = await request.text();
  const signature = headers().get('resend-webhook-signature');
  
  // Verify webhook signature
  if (!verifyWebhookSignature(body, signature)) {
    return new Response('Unauthorized', { status: 401 });
  }

  const event = JSON.parse(body);
  
  switch (event.type) {
    case 'email.received':
      await processInboundEmail(event.data);
      break;
    case 'email.delivered':
      await updateEmailStatus(event.data);
      break;
  }

  return new Response('OK');
}
```

## Email Template Patterns

### React Email Components

```tsx
// components/email-template.tsx
import { Html, Head, Body, Container, Text, Button } from '@react-email/components';

interface EmailTemplateProps {
  clientName: string;
  matterType: string;
  firmName: string;
}

export const RetainerLetterTemplate = ({ 
  clientName, 
  matterType, 
  firmName 
}: EmailTemplateProps) => (
  <Html>
    <Head />
    <Body style={{ fontFamily: 'Arial, sans-serif' }}>
      <Container>
        <Text>Dear {clientName},</Text>
        <Text>
          Thank you for your interest in our legal services regarding {matterType}.
          Attached is your retainer letter for review.
        </Text>
        <Button href="https://app.livingtree.io/documents/sign">
          Review & Sign Document
        </Button>
        <Text>Best regards,<br />{firmName}</Text>
      </Container>
    </Body>
  </Html>
);
```

## Environment Configuration

```bash
# .env
RESEND_API_KEY=re_123...
RESEND_WEBHOOK_SECRET=wh_123...
AGENT_EMAIL_DOMAIN=agent.livingtree.io
```

## Inbound Email Processing

### Custom Domain Setup

1. **DNS Configuration**:
   - Add MX record: `agent.livingtree.io` → `mx.resend.com`
   - Add TXT record for domain verification
   - Configure SPF, DKIM, DMARC records

2. **Webhook Configuration**:
   - Endpoint: `https://app.livingtree.io/api/webhooks/resend`
   - Events: `email.received`, `email.delivered`, `email.bounced`

### Email Parsing Pattern

```typescript
interface InboundEmailEvent {
  from: string;
  to: string;
  subject: string;
  text: string;
  html: string;
  attachments?: Array<{
    filename: string;
    content: string;
    contentType: string;
  }>;
}

async function processInboundEmail(emailData: InboundEmailEvent) {
  // Extract user from unique email address
  const userHash = extractUserFromEmail(emailData.to);
  
  // Determine document type from subject/content
  const documentType = classifyEmailRequest(emailData.subject, emailData.text);
  
  // Generate document using AI
  const document = await generateLegalDocument({
    type: documentType,
    clientEmail: emailData.from,
    content: emailData.text,
    userHash: userHash
  });
  
  // Send response with generated document
  await resend.emails.send({
    from: emailData.to, // Reply from same agent address
    to: emailData.from,
    subject: `Re: ${emailData.subject} - Your ${documentType}`,
    react: DocumentResponseTemplate({ document }),
    attachments: [
      {
        filename: `${documentType}.pdf`,
        content: document.pdfBuffer
      }
    ]
  });
}
```

## Security Considerations

1. **Webhook Signature Verification**: Always verify incoming webhook signatures
2. **Rate Limiting**: Implement rate limiting for inbound email processing
3. **Email Validation**: Sanitize and validate all email content
4. **Domain Authentication**: Proper SPF, DKIM, DMARC configuration

## Error Handling

```typescript
try {
  const result = await resend.emails.send(emailData);
  
  if (result.error) {
    console.error('Resend API error:', result.error);
    // Handle specific error types
    switch (result.error.name) {
      case 'validation_error':
        // Handle validation errors
        break;
      case 'rate_limit_exceeded':
        // Implement retry logic
        break;
    }
  }
} catch (error) {
  console.error('Network error:', error);
  // Implement fallback or retry logic
}
```

## Integration with Living Tree Patterns

1. **Follow existing API route patterns** in `apps/web/app/api/`
2. **Use Clerk authentication** for user context
3. **Store email events** in Supabase with RLS policies
4. **Integrate with existing tool system** for document generation
5. **Use SWR patterns** for frontend email status tracking

## Testing

```typescript
// Test webhook endpoint locally
const testWebhook = async () => {
  const response = await fetch('http://localhost:3000/api/webhooks/resend', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'resend-webhook-signature': 'test_signature'
    },
    body: JSON.stringify({
      type: 'email.received',
      data: {
        from: 'client@example.com',
        to: 'john-doe-a7f3@agent.livingtree.io',
        subject: 'Need retainer letter',
        text: 'Please prepare a retainer letter for divorce case'
      }
    })
  });
  
  console.log(await response.json());
};
```

## References

- **Resend Next.js Guide**: https://resend.com/docs/send-with-nextjs
- **React Email Components**: https://react.email/docs/introduction
- **Webhook Documentation**: https://resend.com/docs/webhooks
- **Domain Setup Guide**: https://resend.com/docs/domains