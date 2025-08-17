#!/bin/bash

# Test DevOps Hook System
echo "🧪 Testing DevOps hook triggers..."

echo "1. Simulating JWT error..."
echo "JWSError (JSONDecodeError 'Not valid base64url'): Invalid JWT token detected"

echo "2. Simulating port conflict..."  
echo "Error: Port 3000 already in use (EADDRINUSE)"

echo "3. Simulating CORS error..."
echo "CORS error: Disallowed CORS origin 'https://preview-url.vercel.app'"

echo "4. Simulating environment error..."
echo "Environment variable SUPABASE_SERVICE_ROLE_KEY not found"

echo "5. Simulating Docker error..."
echo "Docker container api not running"

echo
echo "✅ Test complete! These errors should trigger the DevOps helper agent automatically when they occur in real tool execution."