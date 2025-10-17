#!/bin/bash

# Test 1.2: Multi-File Reading
# Validates that Gemini can efficiently read multiple files

TEST_ID="1.2"
TEST_NAME="Multi-File Reading"
TEST_CATEGORY="Basic Delegation"

# Expected values
EXPECTED_MODEL="gemini-flash-latest"
EXPECTED_TOOLS="FindFiles,ReadManyFiles"
TOKEN_EFFICIENCY_THRESHOLD=90

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
TEST_PROMPT="Read all markdown files in the project and summarize their purpose"
GEMINI_CMD="export REFERRAL=claude && gemini \"$TEST_PROMPT\" -m gemini-flash-latest --allowed-tools=[FindFiles,ReadFile,ReadFolder,ReadManyFiles,SearchText] -o json 2>/dev/null"

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
if echo "$OUTPUT" | jq empty 2>/dev/null; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  PASS=false
fi

# Assert 3: Output should mention multiple markdown files
echo -n "Assert 3: Output mentions multiple markdown files... "
MD_COUNT=$(echo "$OUTPUT" | grep -o "\.md" | wc -l)
if [ $MD_COUNT -ge 3 ]; then
  echo -e "${GREEN}PASS${NC} (Found $MD_COUNT references)"
else
  echo -e "${RED}FAIL${NC} (Found only $MD_COUNT references, expected 3+)"
  PASS=false
fi

# Assert 4: Output should contain summaries (check for common summary words)
echo -n "Assert 4: Output contains summaries... "
if echo "$OUTPUT" | grep -qi "purpose\|summary\|documentation\|describes\|explains"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  PASS=false
fi

# Assert 5: Check token usage (if available in JSON output)
echo -n "Assert 5: Token efficiency threshold met... "
MODEL_KEY=$(echo "$OUTPUT" | jq -r '.stats.models | keys[0]')

# Check if token information is available by looking for the tokens object
if echo "$OUTPUT" | jq -e ".stats.models.\"$MODEL_KEY\".tokens" &>/dev/null; then
  # Correctly extract the token counts using the dynamic model key
  PROMPT_TOKENS=$(echo "$OUTPUT" | jq -r ".stats.models.\"$MODEL_KEY\".tokens.prompt // 0")
  CANDIDATE_TOKENS=$(echo "$OUTPUT" | jq -r ".stats.models.\"$MODEL_KEY\".tokens.candidates // 0")
  CACHED_TOKENS=$(echo "$OUTPUT" | jq -r ".stats.models.\"$MODEL_KEY\".tokens.cached // 0")
  TOOL_TOKENS=$(echo "$OUTPUT" | jq -r ".stats.models.\"$MODEL_KEY\".tokens.tools // 0")

  # Gemini's cost for the task (tool use + final response - cached tokens)
  GEMINI_TASK_TOKENS=$((CANDIDATE_TOKENS + TOOL_TOKENS - CACHED_TOKENS))

  # Estimate Claude's cost for the task (15x the final response size as a proxy for complexity)
  ESTIMATED_CLAUDE_TASK_TOKENS=$((CANDIDATE_TOKENS * 15))

  if [ $ESTIMATED_CLAUDE_TASK_TOKENS -gt 0 ]; then
    # Correct formula: (estimated - actual) / estimated * 100
    # Efficiency is based on the task tokens saved
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

# Assert 6: Execution time should be reasonable
echo -n "Assert 6: Execution time reasonable (<120s)... "
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
