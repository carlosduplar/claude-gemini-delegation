#!/bin/bash

# Test 0.8: Code Generation (NEGATIVE TEST)
# Validates that Claude Code DOES NOT delegate pure code generation tasks
# This is a negative test - delegation should NOT occur

TEST_ID="0.8"
TEST_NAME="Code Generation (No Delegation Expected)"
TEST_CATEGORY="Claude Delegation Logic - Negative Test"

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

# Test command - Ask Claude to generate code
# This is Claude's core strength and should NOT be delegated
TEST_PROMPT="Write a bash function called 'calculate_sum' that takes two numbers as arguments and returns their sum"
CLAUDE_CMD="claude --verbose -p \"$TEST_PROMPT\""

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

# Assert 2: Claude should NOT delegate code generation (NEGATIVE TEST)
echo -n "Assert 2: Claude did NOT delegate... "
if echo "$OUTPUT" | grep -qi "gemini"; then
  echo -e "${RED}FAIL${NC} (Unexpected delegation - Claude should handle this)"
  PASS=false
  DELEGATED=true
else
  echo -e "${GREEN}PASS${NC}"
  DELEGATED=false
fi

# Assert 3: Output should contain the generated function
echo -n "Assert 3: Output contains generated code... "
if echo "$OUTPUT" | grep -qi "calculate_sum\|function\|\$1\|\$2"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC} (No code generation in response)"
  PASS=false
fi

# Assert 4: Execution time should be quick
echo -n "Assert 4: Execution time quick (<60s)... "
if [ $DURATION -lt 60 ]; then
  echo -e "${GREEN}PASS${NC} (${DURATION}s)"
else
  echo -e "${YELLOW}WARN${NC} (${DURATION}s, expected <60s)"
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
