# TODO - Monday Session

## Priority 1: Fix Test 0.6 Multi-File Search

**Status:** Test failing - boundary case issue

**Problem:**
- Test 0.6 expects delegation for multi-file search operations
- Claude Code is using native Grep tool instead of delegating
- Current prompt: "Search all test files for TEST_ID declarations and analyze the naming patterns used across different test categories. Summarize the categorization scheme."
- Execution: Claude handles directly with Grep (token-efficient for simple searches)

**Options:**

### Option A: Revise Test to Require Complex Analysis
Make the prompt more complex to justify delegation:
```
"Search all test files for TEST_ID declarations, read the full content of each file,
analyze the testing patterns, categorization schemes, and assertion strategies used.
Provide a comprehensive report comparing approaches across all test categories."
```

This would require:
- Reading multiple files completely (not just grep)
- Cross-file pattern analysis
- Synthesis of findings
- Should trigger delegation due to token cost

### Option B: Accept as Boundary Case
Document that simple grep-style searches are acceptable for Claude to handle directly:
- Update test expectations to allow native tool usage
- Add documentation explaining when delegation is/isn't needed
- Keep test as validation that Claude makes intelligent delegation decisions

**Recommendation:** Try Option A first. If still not delegating, document as Option B.

**Files to Modify:**
- `tests/regression/test_0.6_multi_file_search.sh` (line 23 - update TEST_PROMPT)

---

## Priority 2: Implement Guardrail Tests

**Status:** Not yet implemented

**Objective:** Ensure Claude Code properly enforces delegation boundaries and security guardrails.

**Test Cases Needed:**

### Test 4.1: Over-delegation Prevention
**Goal:** Verify Claude doesn't delegate tasks it should handle directly

Test scenarios:
1. Simple variable assignment: "x = 5"
2. Trivial code comment addition
3. Direct question answering from knowledge
4. Single-file code edit

**Expected:** No delegation, Claude handles directly

### Test 4.2: Security Guardrail Enforcement
**Goal:** Verify Claude refuses to delegate prohibited operations

Test scenarios:
1. Request to modify .git directory directly
2. Request to execute arbitrary shell commands without context
3. Request to modify security-sensitive files
4. Request to bypass authentication or permissions

**Expected:** Refusal or appropriate safety checks

### Test 4.3: Model Selection Enforcement
**Goal:** Verify correct model (Flash vs Pro) selected for task types

Test scenarios:
1. Security audit → Should use gemini-2.5-pro
2. Git operations → Should use gemini-flash-latest
3. Simple file search → Should use gemini-flash-latest
4. Architecture review → Should use gemini-2.5-pro

**Expected:** Correct model selection detected in output

### Test 4.4: Delegation Fallback
**Goal:** Verify graceful handling when delegation fails

Test scenarios:
1. Gemini API unavailable
2. Quota exceeded
3. Invalid command syntax
4. Timeout scenarios

**Expected:** Appropriate error handling and fallback behavior

**New Files to Create:**
- `tests/regression/test_4.1_over_delegation_prevention.sh`
- `tests/regression/test_4.2_security_guardrails.sh`
- `tests/regression/test_4.3_model_selection.sh`
- `tests/regression/test_4.4_delegation_fallback.sh`

---

## Priority 3: Documentation Updates

**Status:** In progress

**Tasks:**

### 3.1: Update Delegation Decision Tree
**File:** `.claude/CLAUDE.md`

Add clarity on boundary cases:
```markdown
Multi-file search/scan boundary cases:
- Simple grep-style searches (<5 files, single pattern): Claude may use native Grep
- Complex analysis (pattern analysis, cross-file comparison, synthesis): Delegate to Gemini
- When in doubt: delegate for token efficiency
```

### 3.2: Document Test Results
**File:** `README.md`

Add section referencing test results:
```markdown
## Test Results

Regression test suite validates 94% success rate with 150%+ average token efficiency gains.

See detailed results: [tests/regression/TEST_RESULTS.md](tests/regression/TEST_RESULTS.md)
```

### 3.3: Document Known Issues
**File:** `tests/regression/TEST_RESULTS.md` (already updated)

Status: DONE ✓

---

## Priority 4: Test Suite Maintenance

**Status:** Ongoing

**Tasks:**

### 4.1: Add --verbose Flag to All Category 0 Tests
Currently only test 0.6 has --verbose. Should add to all delegation detection tests:
- test_0.1_git_delegation.sh
- test_0.2_codebase_analysis.sh
- test_0.3_security_audit.sh
- test_0.4_build_operations.sh
- test_0.5_web_search.sh
- test_0.10_mixed_task.sh

### 4.2: Improve Token Metrics Collection
Add token usage extraction from Claude Code output:
- Parse token usage from verbose output
- Log to delegation metrics file
- Add summary statistics to test results

### 4.3: Enhance Test Output
Improve test result formatting:
- Add color-coded summary tables
- Generate HTML report option
- Add comparative analysis (run-over-run)

---

## Success Criteria

Tests passing: 18/18 (100%)
- Fix test 0.6: PASS
- Add 4 guardrail tests: 4/4 PASS
- Total: 22 tests, 100% pass rate

Documentation complete:
- Delegation decision tree updated with boundary cases
- README references test results
- Known issues documented

Regression suite enhanced:
- All delegation tests use --verbose flag
- Token metrics collection implemented
- Improved test output formatting

---

## Timeline Estimate

**Monday Session (2-3 hours):**
- Priority 1 (Test 0.6 fix): 30 mins
- Priority 2 (Guardrail tests): 90 mins
- Priority 3 (Documentation): 30 mins
- Priority 4 (Maintenance): 30 mins

**Session Goals:**
1. Get test 0.6 passing
2. Implement at least 2 guardrail tests (4.1 and 4.2)
3. Update documentation
4. If time permits: add --verbose to other tests

---

## Notes

- Test 0.6 failure is a boundary case, not a critical bug
- Guardrail tests are important for production readiness
- Current 94% success rate exceeds targets, these are refinements
- Token efficiency (150%+ avg) far exceeds 40% goal

**Overall Status:** Project is production-ready, Monday tasks are enhancements and validation.
