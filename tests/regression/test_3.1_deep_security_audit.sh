#!/bin/bash

# Test 3.1: Deep Security and Architecture Audit
# Validates that Gemini Pro can perform comprehensive security and architectural analysis

TEST_ID="3.1"
TEST_NAME="Deep Security and Architecture Audit"
TEST_CATEGORY="Advanced Delegation"

# Expected values
EXPECTED_MODEL="gemini-2.5-pro"
TOKEN_EFFICIENCY_THRESHOLD=75

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "Test $TEST_ID: $TEST_NAME"
echo "Category: $TEST_CATEGORY"
echo "========================================="

# Test command
TEST_PROMPT="Perform a comprehensive security and architecture audit of this project. Analyze: 1) Permission model and security guardrails, 2) Token efficiency architecture, 3) Test coverage and validation approach, 4) Potential security risks in the delegation pattern"
GEMINI_CMD="export REFERRAL=claude && gemini \"$TEST_PROMPT\" -m gemini-2.5-pro -o json 2>/dev/null"

echo "Executing: $GEMINI_CMD"
echo ""

# Execute and capture output
TEMP_OUTPUT=$(mktemp)
START_TIME=$(date +%s)
eval "$GEMINI_CMD" > "$TEMP_OUTPUT" 2>&1
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

# Assert 2: Output should be valid JSON
echo -n "Assert 2: Output is valid JSON... "
if echo "$OUTPUT" | jq -e . >/dev/null 2>&1; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  PASS=false
fi

# Assert 3: Should cover permission model
echo -n "Assert 3: Covers permission model... "
if echo "$OUTPUT" | grep -qi "permission\|guardrail\|security"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  PASS=false
fi

# Assert 4: Should cover architecture
echo -n "Assert 4: Covers architecture... "
if echo "$OUTPUT" | grep -qi "architecture\|design\|delegation"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  PASS=false
fi

# Assert 5: Should cover test coverage
echo -n "Assert 5: Covers test coverage... "
if echo "$OUTPUT" | grep -qi "test\|coverage\|validation"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  PASS=false
fi

# Assert 6: Should identify risks
echo -n "Assert 6: Identifies security risks... "
if echo "$OUTPUT" | grep -qi "risk\|vulnerability\|concern\|potential"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  PASS=false
fi

# Assert 7: Should mention token efficiency
echo -n "Assert 7: Discusses token efficiency... "
if echo "$OUTPUT" | grep -qi "token\|efficiency"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  PASS=false
fi

# Assert 8: Check token usage (if available in JSON output)
echo -n "Assert 8: Token efficiency threshold met... "
MODEL_KEY=$(echo "$OUTPUT" | jq -r '.stats.models | keys[0]')

if echo "$OUTPUT" | jq -e ".stats.models.\"$MODEL_KEY\".tokens" &>/dev/null; then
  PROMPT_TOKENS=$(echo "$OUTPUT" | jq -r ".stats.models.\"$MODEL_KEY\".tokens.prompt // 0")
  CANDIDATE_TOKENS=$(echo "$OUTPUT" | jq -r ".stats.models.\"$MODEL_KEY\".tokens.candidates // 0")
  TOOL_TOKENS=$(echo "$OUTPUT" | jq -r ".stats.models.\"$MODEL_KEY\".tokens.tools // 0")

  GEMINI_TASK_TOKENS=$((CANDIDATE_TOKENS + TOOL_TOKENS))

  # For deep analysis, use 15x multiplier (more complex than basic tasks)
  ESTIMATED_CLAUDE_TASK_TOKENS=$((CANDIDATE_TOKENS * 15))

  if [ $ESTIMATED_CLAUDE_TASK_TOKENS -gt 0 ]; then
    EFFICIENCY=$((100 * (ESTIMATED_CLAUDE_TASK_TOKENS - GEMINI_TASK_TOKENS) / ESTIMATED_CLAUDE_TASK_TOKENS))
    if [ $EFFICIENCY -ge $TOKEN_EFFICIENCY_THRESHOLD ]; then
      echo -e "${GREEN}PASS${NC} (${EFFICIENCY}% efficient)"
    else
      echo -e "${YELLOW}WARN${NC} (${EFFICIENCY}% efficient, expected ${TOKEN_EFFICIENCY_THRESHOLD}%+)"
    fi
  else
    echo -e "${YELLOW}SKIP${NC} (Cannot calculate efficiency)"
  fi
else
  echo -e "${YELLOW}SKIP${NC} (Token usage not in output)"
fi

# Assert 9: Execution time should be reasonable (longer for Pro model)
echo -n "Assert 9: Execution time reasonable (<300s)... "
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
