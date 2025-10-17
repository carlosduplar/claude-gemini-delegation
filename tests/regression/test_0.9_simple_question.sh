#!/bin/bash

# Test 0.9: Simple Question (NEGATIVE TEST)
# Validates that Claude Code DOES NOT delegate simple knowledge questions
# This is a negative test - delegation should NOT occur

TEST_ID="0.9"
TEST_NAME="Simple Question (No Delegation Expected)"
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

# Test command - Ask Claude a simple knowledge question
# This should be answered from Claude's knowledge base, not delegated
TEST_PROMPT="What does DRY principle stand for in software engineering?"
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

# Assert 2: Claude should NOT delegate simple questions (NEGATIVE TEST)
echo -n "Assert 2: Claude did NOT delegate... "
if echo "$OUTPUT" | grep -qi "gemini"; then
  echo -e "${RED}FAIL${NC} (Unexpected delegation - Claude should handle this)"
  PASS=false
  DELEGATED=true
else
  echo -e "${GREEN}PASS${NC}"
  DELEGATED=false
fi

# Assert 3: Output should contain the answer about DRY
echo -n "Assert 3: Output contains DRY explanation... "
if echo "$OUTPUT" | grep -qi "don't repeat yourself\|repeat.*yourself\|duplication"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC} (No DRY explanation in response)"
  PASS=false
fi

# Assert 4: Execution time should be very quick
echo -n "Assert 4: Execution time quick (<30s)... "
if [ $DURATION -lt 30 ]; then
  echo -e "${GREEN}PASS${NC} (${DURATION}s)"
else
  echo -e "${YELLOW}WARN${NC} (${DURATION}s, expected <30s)"
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
