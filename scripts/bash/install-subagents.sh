#!/bin/bash
set -e

echo "🚀 Installing Claude Code ↔ Gemini CLI delegation subagents..."
echo ""

# Check if claude is installed
if ! command -v claude &> /dev/null; then
    echo "❌ Error: Claude Code CLI not found"
    echo "Please install Claude Code first: https://claude.ai/code"
    exit 1
fi

# Check if gemini is installed
if ! command -v gemini &> /dev/null; then
    echo "❌ Error: Gemini CLI not found"
    echo "Installing Gemini CLI..."
    npm install -g @google/gemini-cli
fi

# Check if MCP wrapper is available
if ! npm list -g mcp-gemini-cli &> /dev/null; then
    echo "📦 Installing MCP Gemini CLI wrapper..."
    npm install -g mcp-gemini-cli
fi

# Create .claude directory if it doesn't exist
CLAUDE_DIR="$HOME/.claude"
AGENTS_DIR="$CLAUDE_DIR/agents"

mkdir -p "$AGENTS_DIR"

# Copy subagent templates
echo "📝 Creating subagent: gemini-large-context"
if [ ! -f "examples/subagents/gemini-large-context.md" ]; then
    echo "❌ Error: examples/subagents/gemini-large-context.md not found"
    echo "Please run this script from the repository root directory"
    exit 1
fi
cp examples/subagents/gemini-large-context.md "$AGENTS_DIR/gemini-large-context.md"

echo "📝 Creating subagent: gemini-shell-ops"
if [ ! -f "examples/subagents/gemini-shell-ops.md" ]; then
    echo "❌ Error: examples/subagents/gemini-shell-ops.md not found"
    echo "Please run this script from the repository root directory"
    exit 1
fi
cp examples/subagents/gemini-shell-ops.md "$AGENTS_DIR/gemini-shell-ops.md"

# Verify MCP connection
echo ""
echo "🔌 Verifying MCP connection..."

# Add MCP server if not already configured
# Uses grep -q to check if "gemini-cli" appears in the MCP list output
if ! claude mcp list 2>/dev/null | grep -q "gemini-cli"; then
    echo "Adding Gemini CLI MCP server..."
    claude mcp add-json --scope=user gemini-cli '{
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "mcp-gemini-cli"]
    }'
else
    echo "✓ Gemini CLI MCP server already configured"
fi

echo ""
echo "✅ Installation complete!"
echo ""
echo "📋 Next steps:"
echo "  1. Test the installation:"
echo "     ./scripts/bash/test-delegation.sh"
echo ""
echo "  2. Configure your project:"
echo "     cp -r examples/project-config/.claude /path/to/your/project/"
echo ""
echo "  3. Start using Claude Code:"
echo "     cd /path/to/your/project"
echo "     claude"
echo "     > Analyze the entire repository"
echo ""
echo "🎉 Autonomous delegation is ready!"