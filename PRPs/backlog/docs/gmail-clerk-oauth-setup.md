# Gmail Integration with Clerk OAuth

## Overview

Living Tree uses Clerk's OAuth integration for Gmail access. This eliminates the need for custom OAuth flows and provides a secure, managed authentication experience.

## How It Works

1. **User Authentication**: Users sign in to Living Tree using Clerk
2. **Google Account Connection**: Users connect their Google account through Clerk's SSO
3. **Token Management**: Clerk securely stores and manages OAuth tokens
4. **API Access**: Backend retrieves tokens from Clerk to access Gmail

## Setup Requirements

### For Users

1. Sign in to Living Tree
2. Navigate to Profile/Account Settings
3. Find "Connected Accounts" or "Social Connections"
4. Click "Connect Google Account"
5. Authorize the requested Gmail permissions
6. Return to the app - Gmail features are now available

### For Developers

#### Backend Configuration

The backend automatically retrieves OAuth tokens from Clerk when needed:

```python
# api/core/dependencies.py
token_response = clerk_client.users.get_o_auth_access_token(
    user_id=user_id,
    provider="oauth_google"
)
```

#### Environment Variables

Ensure these are set in your environment:

- `CLERK_SECRET_KEY` - For backend Clerk API access
- `GMAIL_CLIENT_ID` - (Optional) Only for display purposes
- `GMAIL_CLIENT_SECRET` - (Optional) Only for display purposes

#### Clerk Dashboard Setup

1. **Enable Google OAuth** in Clerk Dashboard:
   - Go to "SSO Connections"
   - Add Google as a provider
   - For development: Use Clerk's shared credentials
   - For production: Add custom Google OAuth credentials

2. **Configure OAuth Scopes**:
   - Ensure these scopes are requested:
     - `https://www.googleapis.com/auth/gmail.readonly`
     - `https://www.googleapis.com/auth/gmail.send`
     - `https://www.googleapis.com/auth/gmail.modify`

3. **Set Redirect URIs** (Production only):
   - Add your domain to Clerk's production instance
   - Google OAuth redirect will be handled by Clerk

## Error Handling

### Common Errors

1. **"Google account not connected"**
   - User hasn't connected Google through Clerk
   - Solution: Direct user to profile settings

2. **"Could not retrieve Google OAuth token"**
   - Token expired or revoked
   - Solution: User needs to reconnect Google account

3. **"Gmail integration not available"**
   - Backend can't access Clerk API
   - Solution: Check CLERK_SECRET_KEY configuration

## Testing

### Local Development

1. Use Clerk's development instance
2. Connect a test Google account
3. Test Gmail features in the chat interface

### Staging

1. Ensure staging Clerk instance is configured
2. Connect Google account through staging.livingtree.io
3. Verify Gmail tools work in chat

### Production

1. Use production Clerk instance with custom OAuth app
2. Ensure proper scopes and permissions
3. Monitor for OAuth errors in logs

## Migration from Custom OAuth

The custom OAuth flow (`/api/auth/google/login`) has been deprecated. Users who previously authorized through the custom flow need to:

1. Disconnect their Google account (if applicable)
2. Reconnect through Clerk's OAuth in their profile settings

## Security Considerations

- OAuth tokens are stored securely by Clerk
- Tokens are only accessible server-side via Clerk's API
- No tokens are stored in Living Tree's database
- Token refresh is handled automatically by Clerk

## Troubleshooting

### Gmail Features Not Working

1. **Check Clerk Connection**:

   ```bash
   # In backend logs, look for:
   "Successfully retrieved Google OAuth token for user {user_id}"
   ```

2. **Verify OAuth Scopes**:
   - Check Clerk Dashboard for configured scopes
   - Ensure Gmail API scopes are included

3. **Test Token Retrieval**:
   ```python
   # Test in Python shell
   from api.core.dependencies import clerk_client
   tokens = clerk_client.users.get_o_auth_access_token(
       user_id="user_xxx",
       provider="oauth_google"
   )
   print(tokens)
   ```

### Environment-Specific Issues

- **Local**: Uses Clerk development keys
- **Staging**: Uses Clerk production instance with staging domain
- **Production**: Uses Clerk production instance with custom OAuth app

## Benefits of Clerk OAuth

1. **No Custom Code**: Eliminates custom OAuth implementation
2. **Automatic Token Refresh**: Clerk handles token lifecycle
3. **Secure Storage**: Tokens stored in Clerk's infrastructure
4. **Easy Revocation**: Users can disconnect in profile settings
5. **Consistent UX**: Same flow for all OAuth providers
