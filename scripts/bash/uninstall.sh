#!/bin/bash
set -e

# Parse command line arguments
FULL_UNINSTALL=false
if [ "$1" = "--full" ]; then
    FULL_UNINSTALL=true
fi

echo "🗑️  Uninstalling Claude Code → Gemini CLI delegation..."
echo ""

# Remove subagents
if [ -f "$HOME/.claude/agents/gemini-large-context.md" ]; then
    rm "$HOME/.claude/agents/gemini-large-context.md"
    echo "✓ Removed gemini-large-context subagent"
fi

if [ -f "$HOME/.claude/agents/gemini-shell-ops.md" ]; then
    rm "$HOME/.claude/agents/gemini-shell-ops.md"
    echo "✓ Removed gemini-shell-ops subagent"
fi

# Remove MCP server
if claude mcp list 2>/dev/null | grep -q "gemini-cli"; then
    claude mcp remove gemini-cli
    echo "✓ Removed Gemini CLI MCP server"
fi

# Full uninstall (optional)
if [ "$FULL_UNINSTALL" = true ]; then
    echo ""
    echo "📦 Performing full uninstall..."

    if command -v npm &> /dev/null; then
        if npm list -g @google/gemini-cli &> /dev/null; then
            npm uninstall -g @google/gemini-cli
            echo "✓ Uninstalled Gemini CLI"
        fi

        if npm list -g mcp-gemini-cli &> /dev/null; then
            npm uninstall -g mcp-gemini-cli
            echo "✓ Uninstalled MCP Gemini CLI wrapper"
        fi
    fi
fi

echo ""
echo "✅ Uninstallation complete"

if [ "$FULL_UNINSTALL" = false ]; then
    echo ""
    echo "Note: This did not uninstall npm packages. To remove everything, run:"
    echo "  ./scripts/bash/uninstall.sh --full"
    echo ""
    echo "Or manually run:"
    echo "  npm uninstall -g @google/gemini-cli"
    echo "  npm uninstall -g mcp-gemini-cli"
fi

echo ""