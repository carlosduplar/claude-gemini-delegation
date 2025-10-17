#!/bin/bash

# Test 2.2: Complex Multi-file Analysis
# Validates that Gemini can perform complex analysis across multiple files and provide structured insights

TEST_ID="2.2"
TEST_NAME="Complex Multi-file Analysis"
TEST_CATEGORY="Complex Delegation"

# Expected values
EXPECTED_MODEL="gemini-flash-latest"
TOKEN_EFFICIENCY_THRESHOLD=80

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo "========================================="
echo "Test $TEST_ID: $TEST_NAME"
echo "Category: $TEST_CATEGORY"
echo "========================================="

# Test 1: Test suite analysis
echo ""
echo "Sub-test 1: Test suite comprehensive analysis"
echo "-------------------------------------"
TEST_PROMPT_1="Analyze all shell scripts in the tests/regression directory and create a detailed comparison table showing: test ID, primary tool used, expected token efficiency gain percentage, and validation approach"
GEMINI_CMD_1="export REFERRAL=claude && gemini \"$TEST_PROMPT_1\" -m gemini-flash-latest --allowed-tools=FindFiles,ReadManyFiles,SearchText -o json 2>/dev/null"

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

# Assert 1.3: Should mention multiple test IDs
echo -n "Assert 1.3: References multiple tests (3+)... "
TEST_COUNT=$(echo "$OUTPUT_1" | grep -o "1\.[0-9]\|2\.[0-9]" | wc -l)
if [ "$TEST_COUNT" -ge 3 ]; then
  echo -e "${GREEN}PASS${NC} (Found $TEST_COUNT test references)"
else
  echo -e "${RED}FAIL${NC} (Only found $TEST_COUNT test references)"
  PASS=false
fi

# Assert 1.4: Should mention tools
echo -n "Assert 1.4: References tool usage... "
if echo "$OUTPUT_1" | grep -qi "tool\|read_many_files\|run_shell_command\|search"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  PASS=false
fi

# Assert 1.5: Should mention token efficiency
echo -n "Assert 1.5: Discusses token efficiency... "
if echo "$OUTPUT_1" | grep -qi "efficiency\|token\|%"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  PASS=false
fi

# Assert 1.6: Execution time should be reasonable
echo -n "Assert 1.6: Execution time reasonable (<120s)... "
if [ $DURATION_1 -lt 120 ]; then
  echo -e "${GREEN}PASS${NC} (${DURATION_1}s)"
else
  echo -e "${YELLOW}WARN${NC} (${DURATION_1}s, expected <120s)"
fi

# Test 2: JSON structure analysis
echo ""
echo "Sub-test 2: Structured data analysis"
echo "-------------------------------------"
TEST_PROMPT_2="Find all JSON files in the project and analyze their structure. Group them by purpose and list the key fields in each"
GEMINI_CMD_2="export REFERRAL=claude && gemini \"$TEST_PROMPT_2\" -m gemini-flash-latest --allowed-tools=FindFiles,ReadManyFiles -o json 2>/dev/null"

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

# Assert 2.3: Should identify JSON files
echo -n "Assert 2.3: Identifies JSON files... "
if echo "$OUTPUT_2" | grep -qi "\.json\|settings"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  PASS=false
fi

# Assert 2.4: Should discuss structure/fields
echo -n "Assert 2.4: Analyzes structure and fields... "
if echo "$OUTPUT_2" | grep -qi "field\|structure\|key\|purpose"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  PASS=false
fi

# Assert 2.5: Execution time should be reasonable
echo -n "Assert 2.5: Execution time reasonable (<120s)... "
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
