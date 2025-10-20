#!/bin/bash

# Test 0.3: Security Audit Delegation
# Validates that Claude Code correctly delegates security audits to Gemini (using Pro model)

TEST_ID="0.3"
TEST_NAME="Security Audit Delegation"
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

# Test command - Ask Claude to perform security audit
TEST_PROMPT="Perform a security audit on the shell scripts in tests/regression/ and identify any potential vulnerabilities"
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

# Assert 2: Claude should delegate to Gemini for security audit
echo -n "Assert 2: Claude delegated to Gemini... "
if echo "$OUTPUT" | grep -qiE "(gemini.*-m|gemini.*pro|bash.*gemini|delegating.*gemini)"; then
  echo -e "${GREEN}PASS${NC}"
  DELEGATED=true
else
  echo -e "${RED}FAIL${NC} (No delegation detected)"
  PASS=false
  DELEGATED=false
fi

# Assert 3: Should use Pro model for security audit (deep analysis)
echo -n "Assert 3: Uses Pro model for security audit... "
if echo "$OUTPUT" | grep -qi "pro"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${YELLOW}WARN${NC} (Expected a Pro model, but none was detected in the output)"
fi

# Assert 4: Execution time should be reasonable (security audits take longer)
echo -n "Assert 4: Execution time reasonable (<300s)... "
if [ $DURATION -lt 300 ]; then
  echo -e "${GREEN}PASS${NC} (${DURATION}s)"
else
  echo -e "${YELLOW}WARN${NC} (${DURATION}s, expected <300s)"
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
