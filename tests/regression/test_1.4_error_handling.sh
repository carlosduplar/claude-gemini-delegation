#!/bin/bash

# Test 1.4: Error Handling and Recovery
# Validates that Gemini gracefully handles error conditions (non-existent files, invalid commands, etc.)

TEST_ID="1.4"
TEST_NAME="Error Handling and Recovery"
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

# Test 1: Non-existent file
echo ""
echo "Sub-test 1: Non-existent file search"
echo "-------------------------------------"
TEST_PROMPT_1="Find a file that doesn't exist: nonexistent_file_12345.xyz"
GEMINI_CMD_1="export REFERRAL=claude && gemini \"$TEST_PROMPT_1\" -m gemini-flash-latest --allowed-tools=FindFiles -o json 2>/dev/null"

TEMP_OUTPUT_1=$(mktemp)
eval "$GEMINI_CMD_1" > "$TEMP_OUTPUT_1" 2>&1
EXIT_CODE_1=$?
OUTPUT_1=$(cat "$TEMP_OUTPUT_1")
rm "$TEMP_OUTPUT_1"

PASS=true

# Assert 1.1: Should handle gracefully with exit code 0
echo -n "Assert 1.1: Graceful handling (exit code 0)... "
if [ $EXIT_CODE_1 -eq 0 ]; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC} (Exit code: $EXIT_CODE_1)"
  PASS=false
fi

# Assert 1.2: Should return valid JSON
echo -n "Assert 1.2: Valid JSON response... "
if echo "$OUTPUT_1" | jq -e . >/dev/null 2>&1; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  PASS=false
fi

# Assert 1.3: Should indicate file not found (accepts semantic equivalents)
echo -n "Assert 1.3: Indicates file not found... "
if echo "$OUTPUT_1" | grep -qi "not find\|non-existent\|does not exist\|no.*file\|unable to.*locate\|could not.*find\|cannot.*find\|no such\|didn't.*find\|did not.*find"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  PASS=false
fi

# Test 2: Empty search results
echo ""
echo "Sub-test 2: Pattern with no matches"
echo "-------------------------------------"
# Use a random UUID-like pattern that won't exist in the codebase or test files
NONEXISTENT_PATTERN="QZXWVUTSRQP9876543210"
TEST_PROMPT_2="Search for the text pattern: \"$NONEXISTENT_PATTERN\"ABCDEFGH"
GEMINI_CMD_2="export REFERRAL=claude && gemini \"$TEST_PROMPT_2\" -m gemini-flash-latest --allowed-tools=SearchText -o json 2>/dev/null"

TEMP_OUTPUT_2=$(mktemp)
eval "$GEMINI_CMD_2" > "$TEMP_OUTPUT_2" 2>&1
EXIT_CODE_2=$?
OUTPUT_2=$(cat "$TEMP_OUTPUT_2")
rm "$TEMP_OUTPUT_2"

# Assert 2.1: Should handle gracefully
echo -n "Assert 2.1: Graceful handling (exit code 0)... "
if [ $EXIT_CODE_2 -eq 0 ]; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC} (Exit code: $EXIT_CODE_2)"
  PASS=false
fi

# Assert 2.2: Should return valid JSON
echo -n "Assert 2.2: Valid JSON response... "
if echo "$OUTPUT_2" | jq -e . >/dev/null 2>&1; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  PASS=false
fi

# Assert 2.3: Should indicate no results (accepts semantic equivalents)
echo -n "Assert 2.3: Indicates no matches found... "
if echo "$OUTPUT_2" | grep -qi "no match\|yielded no\|not found\|no result\|zero.*match\|zero.*result\|didn't find\|did not find\|unable to.*find\|could not.*find\|cannot.*find\|no occurrence\|no instance"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  PASS=false
fi

# Test 3: Invalid shell command
echo ""
echo "Sub-test 3: Invalid shell command"
echo "-------------------------------------"
TEST_PROMPT_3="Execute an invalid shell command: this_is_not_a_real_command_xyz"
GEMINI_CMD_3="export REFERRAL=claude && gemini \"$TEST_PROMPT_3\" -m gemini-flash-latest -y -o json 2>/dev/null"

TEMP_OUTPUT_3=$(mktemp)
eval "$GEMINI_CMD_3" > "$TEMP_OUTPUT_3" 2>&1
EXIT_CODE_3=$?
OUTPUT_3=$(cat "$TEMP_OUTPUT_3")
rm "$TEMP_OUTPUT_3"

# Assert 3.1: Should handle gracefully (command will fail but CLI should succeed)
echo -n "Assert 3.1: CLI handles gracefully... "
if [ $EXIT_CODE_3 -eq 0 ]; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC} (Exit code: $EXIT_CODE_3)"
  PASS=false
fi

# Assert 3.2: Should return valid JSON
echo -n "Assert 3.2: Valid JSON response... "
if echo "$OUTPUT_3" | jq -e . >/dev/null 2>&1; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  PASS=false
fi

# Assert 3.3: Should report the command error
echo -n "Assert 3.3: Reports command error... "
if echo "$OUTPUT_3" | grep -qi "error\|fail\|not recognized\|command not found\|exit code"; then
  echo -e "${GREEN}PASS${NC}"
else
  echo -e "${RED}FAIL${NC}"
  PASS=false
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
