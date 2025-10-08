#!/bin/bash
# Automatically trigger gemini-large-context for large changesets

# Check if we're in a Git repository
if [ ! -d ".git" ]; then
  exit 0
fi

CHANGED_FILES=$(git diff --name-only 2>/dev/null | wc -l)

if [ "$CHANGED_FILES" -gt 10 ]; then
  echo "🔍 Large changeset detected ($CHANGED_FILES files modified)"
  echo "Triggering gemini-large-context subagent for automated review..."
  echo ""
  echo "gemini-large-context: Review all changes in git diff and check for:"
  echo "  - Breaking changes"
  echo "  - Test coverage gaps"
  echo "  - Documentation updates needed"
  echo "  - Potential bugs or regressions"
fi

exit 0