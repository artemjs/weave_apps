#!/bin/bash
# Auto-push script for weave_apps

cd /tmp/weave_apps

# Check if there are changes
if git diff --quiet && git diff --staged --quiet; then
    echo "No changes to push"
    exit 0
fi

# Get commit message from argument or use default
MSG="${1:-Auto-update apps}"

# Add all changes
git add -A

# Commit with message
git commit -m "$MSG

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"

# Push to GitHub
git push

echo "✅ Pushed successfully!"
