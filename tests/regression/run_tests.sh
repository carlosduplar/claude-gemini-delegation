#!/bin/bash

# Regression Test Runner
# Executes all delegation tests and provides summary report

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Test tracking
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Header
echo ""
echo -e "${CYAN}=========================================${NC}"
echo -e "${CYAN}  Gemini Delegation Regression Tests${NC}"
echo -e "${CYAN}=========================================${NC}"
echo ""
echo "Test Session Date: $(date +%Y-%m-%d)"
echo "Test Session Time: $(date +%H:%M:%S)"
echo ""

# Check for required dependencies
echo "Checking dependencies..."
echo -n "- gemini CLI: "
if command -v gemini &> /dev/null; then
  echo -e "${GREEN}OK${NC}"
else
  echo -e "${RED}MISSING${NC}"
  echo "Please install gemini CLI: npm install -g @google/gemini-cli"
  exit 1
fi

echo -n "- jq (JSON processor): "
if command -v jq &> /dev/null; then
  echo -e "${GREEN}OK${NC}"
else
  echo -e "${YELLOW}MISSING${NC} (Optional, but recommended for token metrics)"
fi

echo -n "- git: "
if command -v git &> /dev/null; then
  echo -e "${GREEN}OK${NC}"
else
  echo -e "${RED}MISSING${NC}"
  exit 1
fi

echo ""

# Find all test scripts
TEST_SCRIPTS=()
while IFS= read -r -d $'\0' test_file; do
  TEST_SCRIPTS+=("$test_file")
done < <(find "$SCRIPT_DIR" -name "test_*.sh" -type f -print0 | sort -z)

if [ ${#TEST_SCRIPTS[@]} -eq 0 ]; then
  echo -e "${RED}No test scripts found in $SCRIPT_DIR${NC}"
  exit 1
fi

echo "Found ${#TEST_SCRIPTS[@]} test(s) to execute"
echo ""

# Execute each test
TEST_RESULTS=()
for test_script in "${TEST_SCRIPTS[@]}"; do
  test_name=$(basename "$test_script" .sh)
  TOTAL_TESTS=$((TOTAL_TESTS + 1))

  echo -e "${BLUE}Running: $test_name${NC}"
  echo ""

  # Make script executable
  chmod +x "$test_script"

  # Execute test
  if bash "$test_script"; then
    PASSED_TESTS=$((PASSED_TESTS + 1))
    TEST_RESULTS+=("$test_name:PASS")
  else
    FAILED_TESTS=$((FAILED_TESTS + 1))
    TEST_RESULTS+=("$test_name:FAIL")
  fi

  echo ""
done

# Summary report
echo ""
echo -e "${CYAN}=========================================${NC}"
echo -e "${CYAN}  Test Summary${NC}"
echo -e "${CYAN}=========================================${NC}"
echo ""

for result in "${TEST_RESULTS[@]}"; do
  test_name="${result%%:*}"
  test_status="${result##*:}"

  if [ "$test_status" = "PASS" ]; then
    echo -e "  $test_name: ${GREEN}PASS${NC}"
  else
    echo -e "  $test_name: ${RED}FAIL${NC}"
  fi
done

echo ""
echo "Total Tests:  $TOTAL_TESTS"
echo -e "Passed:       ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed:       ${RED}$FAILED_TESTS${NC}"

if [ $FAILED_TESTS -eq 0 ]; then
  SUCCESS_RATE=100
else
  SUCCESS_RATE=$((PASSED_TESTS * 100 / TOTAL_TESTS))
fi

echo "Success Rate: ${SUCCESS_RATE}%"
echo ""

# Final result
if [ $FAILED_TESTS -eq 0 ]; then
  echo -e "${GREEN}All tests passed!${NC}"
  echo -e "${CYAN}=========================================${NC}"
  exit 0
else
  echo -e "${RED}Some tests failed. Please review output above.${NC}"
  echo -e "${CYAN}=========================================${NC}"
  exit 1
fi
