#!/bin/bash

# Test 0.4: Build Operations Delegation
# Validates that Claude Code correctly delegates build/test commands to Gemini

TEST_ID="0.4"
TEST_NAME="Build Operations Delegation"
TEST_CATEGORY="Claude Delegation Logic"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo "========================================="
echo "Test $TEST_ID: $TEST_NAME"
echo "Category: $TEST_CATEGORY"
echo "========================================="

# Test command - Ask Claude to run a build/test command
TEST_PROMPT="Run 'ls -la tests/regression' and show me the output"
CLAUDE_CMD="claude -p \"$TEST_PROMPT\""

echo "Executing: $CLAUDE_CMD"
echo ""

# Execute and capture output
TEMP_OUTPUT=$(mktemp)
START_TIME=$(date +%s)
eval "$CLAUDE_CMD" > "$TEMP_OUTPUT" 2>&1
EXIT_CODE=$?
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Read output
OUTPUT=$(cat "$TEMP_OUTPUT")

# Cleanup
rm "$TEMP_OUTPUT"

# Test assertions
PASS=true

# Assert 1: Exit code should be 0
echo -n "Assert 1: Exit code is 0... "
if [ $EXIT_CODE -eq 0 ]; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC} (Exit code: $EXIT_CODE)"
  PASS=false
fi

# Assert 2: Claude should delegate shell commands to Gemini
echo -n "Assert 2: Claude delegated to Gemini... "
if echo "$OUTPUT" | grep -qi "gemini"; then
  echo -e "${GREEN}PASS${NC}"
  DELEGATED=true
else
  echo -e "${RED}FAIL${NC} (No delegation detected)"
  PASS=false
  DELEGATED=false
fi

# Assert 3: Should use -y flag for shell access
echo -n "Assert 3: Uses shell access flag... "
if echo "$OUTPUT" | grep -q "\-y"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${YELLOW}WARN${NC} (Expected -y flag for shell commands)"
fi

# Assert 4: Output should contain command results
echo -n "Assert 4: Output contains command results... "
if echo "$OUTPUT" | grep -qi "test_.*\.sh\|total\|drwx"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC} (No command output in response)"
  PASS=false
fi

# Assert 5: Execution time should be reasonable
echo -n "Assert 5: Execution time reasonable (<120s)... "
if [ $DURATION -lt 120 ]; then
  echo -e "${GREEN}PASS${NC} (${DURATION}s)"
else
  echo -e "${YELLOW}WARN${NC} (${DURATION}s, expected <120s)"
fi

# Final result
echo ""
echo "========================================="
if [ "$PASS" = true ]; then
  echo -e "Test Result: ${GREEN}PASS${NC}"
  echo "========================================="
  exit 0
else
  echo -e "Test Result: ${RED}FAIL${NC}"
  echo "========================================="
  exit 1
fi
