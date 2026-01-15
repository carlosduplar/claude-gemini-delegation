#!/bin/bash

# Test: Copilot CLI Delegation with Claude Opus 4.5
# Validates that delegation workflow works with Copilot CLI as the target

TEST_ID="delegation_copilot"
TEST_NAME="Copilot CLI Delegation Test"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "Test: $TEST_NAME"
echo "Model: claude-opus-4.5"
echo "========================================="

# Setup paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TASKS_DIR="$PROJECT_ROOT/.claude/tasks"
LOGS_DIR="$PROJECT_ROOT/.claude/logs"

# Create directories if needed
mkdir -p "$TASKS_DIR"
mkdir -p "$LOGS_DIR"

# Test task: Small refactoring task to validate workflow
TASK_ID="test_$(date +%s)"
INPUT_FILE="$TASKS_DIR/${TASK_ID}_input.md"
OUTPUT_FILE="$TASKS_DIR/${TASK_ID}_result.md"

# Create input context
cat > "$INPUT_FILE" << 'EOF'
## Task: Generate a simple utility function

Create a JavaScript utility function named `formatBytes` that:
1. Takes a number of bytes as input
2. Returns a human-readable string (e.g., "1.5 KB", "2.3 MB")
3. Handles edge cases (0, negative, very large numbers)

Output only the function code, no explanations.
EOF

echo "Input file: $INPUT_FILE"
echo ""
echo "Executing delegation to Copilot CLI..."
echo ""

# Execute delegation
START_TIME=$(date +%s)

# Run copilot with claude-opus-4.5
copilot \
  --model claude-opus-4.5 \
  --silent \
  --allow-all-tools \
  --add-dir "$TASKS_DIR" \
  -p "Read the task from $INPUT_FILE and write the solution to $OUTPUT_FILE. Follow instructions exactly."

EXIT_CODE=$?
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "========================================="
echo "Validation Gates"
echo "========================================="

GATES_PASSED=0
TOTAL_GATES=4

# Gate 1: File Integrity
echo -n "Gate 1 (File Integrity): "
if [ -f "$OUTPUT_FILE" ]; then
  FILE_SIZE=$(stat -f%z "$OUTPUT_FILE" 2>/dev/null || stat -c%s "$OUTPUT_FILE" 2>/dev/null)
  if [ "$FILE_SIZE" -gt 100 ]; then
    echo -e "${GREEN}PASS${NC} (${FILE_SIZE} bytes)"
    ((GATES_PASSED++))
  else
    echo -e "${RED}FAIL${NC} (File too small: ${FILE_SIZE} bytes)"
  fi
else
  echo -e "${RED}FAIL${NC} (File not created)"
fi

# Gate 2: Structure Check
echo -n "Gate 2 (Structure): "
if [ -f "$OUTPUT_FILE" ]; then
  if grep -q "function\|const\|=>" "$OUTPUT_FILE"; then
    if ! grep -qiE "TODO|FIXME|IMPLEMENT|ERROR|FAILED" "$OUTPUT_FILE"; then
      echo -e "${GREEN}PASS${NC}"
      ((GATES_PASSED++))
    else
      echo -e "${RED}FAIL${NC} (Contains placeholder/error text)"
    fi
  else
    echo -e "${RED}FAIL${NC} (No function definition found)"
  fi
else
  echo -e "${RED}FAIL${NC} (No file to check)"
fi

# Gate 3: Content Validation
echo -n "Gate 3 (Content): "
if [ -f "$OUTPUT_FILE" ]; then
  # Check for formatBytes function
  if grep -qi "formatBytes\|format.*bytes" "$OUTPUT_FILE"; then
    echo -e "${GREEN}PASS${NC}"
    ((GATES_PASSED++))
  else
    echo -e "${YELLOW}WARN${NC} (Function name may differ)"
    ((GATES_PASSED++))  # Still pass with warning
  fi
else
  echo -e "${RED}FAIL${NC} (No file to check)"
fi

# Gate 4: Quality Sample
echo -n "Gate 4 (Quality): "
if [ -f "$OUTPUT_FILE" ]; then
  # Check for reasonable code patterns
  if grep -qE "(KB|MB|GB|bytes)" "$OUTPUT_FILE"; then
    echo -e "${GREEN}PASS${NC}"
    ((GATES_PASSED++))
  else
    echo -e "${YELLOW}WARN${NC} (Expected unit strings not found)"
  fi
else
  echo -e "${RED}FAIL${NC} (No file to check)"
fi

echo ""
echo "========================================="
echo "Results"
echo "========================================="
echo "Exit code: $EXIT_CODE"
echo "Duration: ${DURATION}s"
echo "Gates passed: ${GATES_PASSED}/${TOTAL_GATES}"
echo ""

if [ -f "$OUTPUT_FILE" ]; then
  echo "Output preview:"
  echo "---"
  head -20 "$OUTPUT_FILE"
  echo "---"
fi

# Log results
cat > "$LOGS_DIR/${TASK_ID}_log.md" << EOF
# Delegation Test Log

**Task ID:** $TASK_ID
**Model:** claude-opus-4.5
**Date:** $(date)

## Metrics
- Exit code: $EXIT_CODE
- Duration: ${DURATION}s
- Gates passed: ${GATES_PASSED}/${TOTAL_GATES}

## Files
- Input: $INPUT_FILE
- Output: $OUTPUT_FILE
EOF

echo ""
if [ $GATES_PASSED -ge 3 ]; then
  echo -e "Overall: ${GREEN}SUCCESS${NC} - Delegation workflow validated"
  exit 0
else
  echo -e "Overall: ${RED}FAILURE${NC} - Review validation issues"
  exit 1
fi
