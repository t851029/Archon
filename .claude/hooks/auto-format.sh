#!/bin/bash
# Auto-format hook for Living Tree - formats only changed files

# Get the hook input from stdin
hook_input=$(cat)

# Extract file path from JSON using bash (fallback if jq not available)
if command -v jq >/dev/null 2>&1; then
    file_path=$(echo "$hook_input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
else
    # Bash fallback - extract file_path value with grep and cut
    file_path=$(echo "$hook_input" | grep -o '"file_path": *"[^"]*"' | cut -d'"' -f4)
fi

# Check if we have a valid file path
if [ -z "$file_path" ] || [ "$file_path" = "null" ]; then
    echo '{"status": "no_file_path", "success": false}'
    exit 0
fi

# Change to project directory
cd "$CLAUDE_PROJECT_DIR" || exit 1

# Format based on file extension
case "$file_path" in
    *.ts|*.tsx|*.js|*.jsx|*.md)
        # Try prettier directly first, then via pnpm
        if command -v prettier >/dev/null 2>&1 && prettier --write "$file_path" 2>/dev/null; then
            echo "{\"status\": \"formatted\", \"file\": \"$file_path\", \"tool\": \"prettier\"}"
        elif command -v pnpm >/dev/null 2>&1 && pnpm prettier --write "$file_path" 2>/dev/null; then
            echo "{\"status\": \"formatted\", \"file\": \"$file_path\", \"tool\": \"pnpm prettier\"}"
        else
            echo "{\"status\": \"format_failed\", \"file\": \"$file_path\", \"reason\": \"prettier not available\"}"
        fi
        ;;
    *.py)
        # Format Python files if Docker is available
        if command -v docker-compose >/dev/null 2>&1; then
            if docker-compose exec -T api poetry run black "$file_path" 2>/dev/null; then
                echo "{\"status\": \"formatted\", \"file\": \"$file_path\", \"tool\": \"black\"}"
            else
                echo "{\"status\": \"format_failed\", \"file\": \"$file_path\", \"reason\": \"black/docker not available\"}"
            fi
        else
            echo "{\"status\": \"skipped\", \"file\": \"$file_path\", \"reason\": \"docker not available\"}"
        fi
        ;;
    *)
        echo "{\"status\": \"skipped\", \"file\": \"$file_path\", \"reason\": \"unsupported_file_type\"}"
        ;;
esac

exit 0