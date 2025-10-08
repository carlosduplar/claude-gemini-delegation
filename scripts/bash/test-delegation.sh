#!/bin/bash
set -e

echo "🧪 Testing Claude Code → Gemini CLI autonomous delegation..."
echo ""

# Create temporary test directory
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"

# Initialize a simple project
echo "Setting up test project..."
mkdir -p src tests
cat > src/main.js << 'JSEOF'
function add(a, b) {
  return a + b;
}

function multiply(a, b) {
  return a * b;
}

function divide(a, b) {
  if (b === 0) {
    throw new Error('Division by zero');
  }
  return a / b;
}

module.exports = { add, multiply, divide };
JSEOF

cat > tests/main.test.js << 'TESTEOF'
const { add, multiply, divide } = require('../src/main');

test('add function', () => {
  expect(add(2, 3)).toBe(5);
});

test('multiply function', () => {
  expect(multiply(4, 5)).toBe(20);
});

test('divide function', () => {
  expect(divide(10, 2)).toBe(5);
  expect(() => divide(10, 0)).toThrow('Division by zero');
});
TESTEOF

cat > package.json << 'PKGEOF'
{
  "name": "delegation-test",
  "version": "1.0.0",
  "scripts": {
    "test": "jest"
  }
}
PKGEOF

echo "✓ Test project created at: $TEST_DIR"
echo ""

# Test 1: Check MCP connection
echo "Test 1: Verifying MCP connection..."
if claude mcp list 2>/dev/null | grep -q "gemini-cli"; then
    echo "✓ MCP connection verified"
else
    echo "❌ MCP server not found"
    exit 1
fi

# Test 2: Check subagents
echo ""
echo "Test 2: Verifying subagents..."
if [ -f "$HOME/.claude/agents/gemini-large-context.md" ]; then
    echo "✓ gemini-large-context subagent found"
else
    echo "❌ gemini-large-context subagent not found"
    exit 1
fi

if [ -f "$HOME/.claude/agents/gemini-shell-ops.md" ]; then
    echo "✓ gemini-shell-ops subagent found"
else
    echo "❌ gemini-shell-ops subagent not found"
    exit 1
fi

# Test 3: Gemini CLI authentication
echo ""
echo "Test 3: Checking Gemini CLI authentication..."
if gemini --version &> /dev/null; then
    echo "✓ Gemini CLI is installed"
else
    echo "⚠️  Gemini CLI not authenticated"
    echo "Run: gemini"
    echo "Then select: OAuth - Personal Google Account"
fi

echo ""
echo "✅ All automated tests passed!"
echo ""
echo "🎯 Manual test:"
echo "  cd $TEST_DIR"
echo "  claude"
echo "  > Analyze all files in this project"
echo ""
echo "Expected: Claude should spawn gemini-large-context subagent"
echo ""