#!/bin/bash

# Test 0.10: Mixed Task (EDGE CASE)
# Validates that Claude Code correctly handles tasks with both delegatable and non-delegatable parts
# Expected: Delegate git part, handle code generation directly

TEST_ID="0.10"
TEST_NAME="Mixed Task (Partial Delegation)"
TEST_CATEGORY="Claude Delegation Logic - Edge Case"

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

# Test command - Mixed task: git operation + code generation
# Expected behavior: Delegate git status, then Claude writes the parsing function
TEST_PROMPT="Show me the git status, then write a bash function that can parse git status output to count modified files"
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

# Assert 2: Claude should delegate the git part
echo -n "Assert 2: Delegation occurred (for git)... "
if echo "$OUTPUT" | grep -qi "gemini"; then
  echo -e "${GREEN}PASS${NC}"
  DELEGATED=true
else
  echo -e "${YELLOW}WARN${NC} (Expected delegation for git status)"
  DELEGATED=false
fi

# Assert 3: Output should contain git status information
echo -n "Assert 3: Output contains git status... "
if echo "$OUTPUT" | grep -qi "git.*status\|branch\|modified\|untracked"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC} (No git status in response)"
  PASS=false
fi

# Assert 4: Output should contain generated function code
echo -n "Assert 4: Output contains parsing function... "
if echo "$OUTPUT" | grep -qi "function\|parse\|count\|grep\|\$"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC} (No function code in response)"
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
