#!/bin/bash
# Smart commit hook for Living Tree

cd "$CLAUDE_PROJECT_DIR"

# Check if there are changes
if ! git diff --quiet || ! git diff --staged --quiet; then
    # Get changed files
    changed_files=$(git diff --name-only; git diff --staged --name-only)
    
    # Determine commit type and scope
    if echo "$changed_files" | grep -q "^apps/web/"; then
        scope="web"
    elif echo "$changed_files" | grep -q "^api/"; then
        scope="api"
    elif echo "$changed_files" | grep -q "^PRPs/"; then
        scope="docs"
    else
        scope="config"
    fi
    
    # Determine type
    if echo "$changed_files" | grep -q "test"; then
        type="test"
    elif echo "$changed_files" | grep -q "fix"; then
        type="fix"
    else
        type="feat"
    fi
    
    # Create commit message
    message="$type($scope): update $(echo "$changed_files" | head -1 | xargs basename)"
    
    # Stage and commit
    git add -A
    git commit -m "$message" 2>/dev/null
    
    echo "{\"committed\": true, \"message\": \"$message\"}"
else
    echo "{\"committed\": false, \"reason\": \"No changes to commit\"}"
fi

exit 0