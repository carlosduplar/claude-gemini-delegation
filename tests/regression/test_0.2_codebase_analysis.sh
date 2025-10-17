#!/bin/bash

# Test 0.2: Codebase Analysis Delegation
# Validates that Claude Code correctly delegates multi-file codebase analysis to Gemini

TEST_ID="0.2"
TEST_NAME="Codebase Analysis Delegation"
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

# Test command - Ask Claude to analyze multiple files
TEST_PROMPT="Analyze all shell scripts in tests/regression/ and summarize their purpose"
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

# Assert 2: Claude should delegate to Gemini for multi-file analysis
echo -n "Assert 2: Claude delegated to Gemini... "
if echo "$OUTPUT" | grep -qi "gemini"; then
  echo -e "${GREEN}PASS${NC}"
  DELEGATED=true
else
  echo -e "${RED}FAIL${NC} (No delegation detected)"
  PASS=false
  DELEGATED=false
fi

# Assert 3: Output should contain delegation command with appropriate tools
echo -n "Assert 3: Delegation uses file reading tools... "
if echo "$OUTPUT" | grep -q "ReadFile\|ReadManyFiles\|FindFiles"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${YELLOW}WARN${NC} (Expected file reading tools not found)"
fi

# Assert 4: Output should contain analysis of test scripts
echo -n "Assert 4: Output contains test analysis... "
if echo "$OUTPUT" | grep -qi "test.*\.sh\|regression\|validation\|assertion"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC} (No test analysis in response)"
  PASS=false
fi

# Assert 5: Execution time should be reasonable
echo -n "Assert 5: Execution time reasonable (<180s)... "
if [ $DURATION -lt 180 ]; then
  echo -e "${GREEN}PASS${NC} (${DURATION}s)"
else
  echo -e "${YELLOW}WARN${NC} (${DURATION}s, expected <180s)"
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
