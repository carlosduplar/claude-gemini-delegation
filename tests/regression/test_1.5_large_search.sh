#!/bin/bash

# Test 1.5: Large-scale Search Operations
# Validates that Gemini can handle large-scale search and aggregation tasks efficiently

TEST_ID="1.5"
TEST_NAME="Large-scale Search Operations"
TEST_CATEGORY="Basic Delegation"

# Expected values
EXPECTED_MODEL="gemini-flash-latest"
TOKEN_EFFICIENCY_THRESHOLD=85

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "Test $TEST_ID: $TEST_NAME"
echo "Category: $TEST_CATEGORY"
echo "========================================="

# Test 1: Project-wide search with aggregation
echo ""
echo "Sub-test 1: Project-wide search with breakdown"
echo "-------------------------------------"
TEST_PROMPT_1="Search for all occurrences of the word 'test' in all files in the project and provide a detailed breakdown by file extension"
GEMINI_CMD_1="export REFERRAL=claude && gemini \"$TEST_PROMPT_1\" -m gemini-flash-latest --allowed-tools=SearchText,FindFiles -o json 2>/dev/null"

TEMP_OUTPUT_1=$(mktemp)
START_TIME_1=$(date +%s)
eval "$GEMINI_CMD_1" > "$TEMP_OUTPUT_1" 2>&1
EXIT_CODE_1=$?
END_TIME_1=$(date +%s)
DURATION_1=$((END_TIME_1 - START_TIME_1))
OUTPUT_1=$(cat "$TEMP_OUTPUT_1")
rm "$TEMP_OUTPUT_1"

PASS=true

# Assert 1.1: Exit code should be 0
echo -n "Assert 1.1: Exit code is 0... "
if [ $EXIT_CODE_1 -eq 0 ]; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC} (Exit code: $EXIT_CODE_1)"
  PASS=false
fi

# Assert 1.2: Output should be valid JSON
echo -n "Assert 1.2: Output is valid JSON... "
if echo "$OUTPUT_1" | jq -e . >/dev/null 2>&1; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  PASS=false
fi

# Assert 1.3: Should provide numerical results
echo -n "Assert 1.3: Provides quantitative results... "
if echo "$OUTPUT_1" | grep -Eq "[0-9]+ (occurrences|files|lines)"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  PASS=false
fi

# Assert 1.4: Should break down by file extension
echo -n "Assert 1.4: Breakdown by file extension... "
if echo "$OUTPUT_1" | grep -qi "\.sh\|\.md\|\.json\|extension"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  PASS=false
fi

# Assert 1.5: Execution time should be reasonable
echo -n "Assert 1.5: Execution time reasonable (<120s)... "
if [ $DURATION_1 -lt 120 ]; then
  echo -e "${GREEN}PASS${NC} (${DURATION_1}s)"
else
  echo -e "${YELLOW}WARN${NC} (${DURATION_1}s, expected <120s)"
fi

# Test 2: Testing strategy analysis
echo ""
echo "Sub-test 2: Multi-file testing strategy analysis"
echo "-------------------------------------"
TEST_PROMPT_2="Read all files in the tests directory recursively and analyze the testing strategy, including test organization, validation patterns, and coverage approach"
GEMINI_CMD_2="export REFERRAL=claude && gemini \"$TEST_PROMPT_2\" -m gemini-flash-latest --allowed-tools=ReadManyFiles,FindFiles -o json 2>/dev/null"

TEMP_OUTPUT_2=$(mktemp)
START_TIME_2=$(date +%s)
eval "$GEMINI_CMD_2" > "$TEMP_OUTPUT_2" 2>&1
EXIT_CODE_2=$?
END_TIME_2=$(date +%s)
DURATION_2=$((END_TIME_2 - START_TIME_2))
OUTPUT_2=$(cat "$TEMP_OUTPUT_2")
rm "$TEMP_OUTPUT_2"

# Assert 2.1: Exit code should be 0
echo -n "Assert 2.1: Exit code is 0... "
if [ $EXIT_CODE_2 -eq 0 ]; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC} (Exit code: $EXIT_CODE_2)"
  PASS=false
fi

# Assert 2.2: Output should be valid JSON
echo -n "Assert 2.2: Output is valid JSON... "
if echo "$OUTPUT_2" | jq -e . >/dev/null 2>&1; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  PASS=false
fi

# Assert 2.3: Should discuss test organization
echo -n "Assert 2.3: Discusses test organization... "
if echo "$OUTPUT_2" | grep -qi "organization\|structure\|directory"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  PASS=false
fi

# Assert 2.4: Should discuss validation patterns
echo -n "Assert 2.4: Discusses validation patterns... "
if echo "$OUTPUT_2" | grep -qi "validation\|assert\|pattern"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  PASS=false
fi

# Assert 2.5: Should discuss coverage
echo -n "Assert 2.5: Discusses coverage approach... "
if echo "$OUTPUT_2" | grep -qi "coverage\|test.*case\|scenario"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  PASS=false
fi

# Assert 2.6: Execution time should be reasonable
echo -n "Assert 2.6: Execution time reasonable (<120s)... "
if [ $DURATION_2 -lt 120 ]; then
  echo -e "${GREEN}PASS${NC} (${DURATION_2}s)"
else
  echo -e "${YELLOW}WARN${NC} (${DURATION_2}s, expected <120s)"
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
