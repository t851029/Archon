#!/usr/bin/env python3
"""Validate PRP quality for Living Tree."""

import json
import sys
import re
from pathlib import Path

def validate_prp(prp_path: str) -> dict:
    """Validate PRP meets Living Tree standards."""
    
    if not Path(prp_path).exists():
        return {"valid": False, "error": "PRP file not found"}
    
    with open(prp_path, 'r') as f:
        content = f.read()
    
    # Check required sections
    required_sections = ['## Goal', '## Why', '## What', '## All Needed Context', 
                        '## Implementation Blueprint', '## Validation Loop']
    
    missing = [s for s in required_sections if s not in content]
    if missing:
        return {"valid": False, "missing_sections": missing}
    
    # Check for Living Tree specifics
    has_pnpm = 'pnpm' in content
    has_docker = 'docker-compose' in content or 'Docker' in content
    has_validation = 'pnpm lint' in content or 'pytest' in content
    
    score = 5  # Base score
    if has_pnpm: score += 2
    if has_docker: score += 2
    if has_validation: score += 1
    
    return {
        "valid": score >= 8,
        "score": score,
        "has_pnpm": has_pnpm,
        "has_docker": has_docker,
        "has_validation": has_validation
    }

if __name__ == "__main__":
    # Read hook input
    hook_input = json.loads(sys.stdin.read())
    
    # Extract PRP path from prompt
    prompt = hook_input.get("prompt", "")
    prp_match = re.search(r'PRPs/([^\.]+\.md)', prompt)
    
    if prp_match:
        prp_path = prp_match.group(0)
        result = validate_prp(prp_path)
        print(json.dumps(result))
    else:
        print(json.dumps({"valid": True, "note": "No PRP path found"}))
    
    sys.exit(0)