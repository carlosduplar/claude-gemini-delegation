# Post-Delegation Validation Gates

Validate CLI-generated output before returning to user. All gates must be checked in order.

---

## Gate 1: File Integrity

**Purpose:** Verify CLI produced readable output.

| Check | Pass Criteria | Fail Action |
|-------|---------------|-------------|
| File exists | Result file at expected path | Retry CLI once |
| File size | > 100 bytes | Retry CLI once |
| File readable | No permission errors | Log and fallback |

```
IF gate1_failed:
  Log: "File integrity check failed"
  Evidence: [path, error message]
  Action: Retry delegation once, then fallback to Claude
```

---

## Gate 2: Structure Check

**Purpose:** Verify output format matches expected type.

| Output Type | Required Structure |
|-------------|-------------------|
| Code | Has function definitions, imports, or class definitions |
| Documentation | Has headings (# or ##), paragraphs |
| Tests | Has test cases (describe/it, test_, @Test) |
| Refactor | Maintains original function signatures |

**Reject if contains:**
- Placeholder text: `TODO`, `FIXME`, `IMPLEMENT`, `...`
- Error messages: `ERROR`, `FAILED`, `UNABLE`, `Exception`
- Incomplete markers: `/* ... */`, `// TODO`

```
IF gate2_failed:
  Log: "Structure validation failed"
  Evidence: [detected issues, sample lines]
  Action: Ask Claude to reformat, or fallback
```

---

## Gate 3: Content Validation

**Purpose:** Verify output quality and safety.

| Check | Pass Criteria |
|-------|---------------|
| Length ratio | Output is 20-200% of input length |
| Syntax valid | Passes language linter (if applicable) |
| Signatures preserved | Original function names/params intact (for refactors) |
| Security scan | No SQL injection, XSS, hardcoded secrets |

**Syntax validation (optional):**
```bash
# For JavaScript/TypeScript
npx eslint --no-eslintrc --parser-options=ecmaVersion:2022 result.js

# For Python
python -m py_compile result.py

# For JSON
python -c "import json; json.load(open('result.json'))"
```

```
IF gate3_failed:
  Log: "Content validation failed"
  Evidence: [linter output, specific violations]
  Action: Manual review required, notify user
```

---

## Gate 4: Quality Sampling

**Purpose:** Spot-check for subtle issues.

**Process:**
1. Select 3 random sections from output
2. Verify each section for:
   - Logical correctness (no obvious bugs)
   - Style consistency (matches project conventions)
   - Comment accuracy (comments describe actual code)

| Sample Check | Red Flags |
|--------------|-----------|
| Logic | Infinite loops, null pointer risks, missing error handling |
| Style | Inconsistent naming, wrong indentation, mixed conventions |
| Comments | Outdated comments, copy-paste artifacts, wrong descriptions |

```
IF gate4_failed:
  Log: "Quality sample failed"
  Evidence: [sampled sections, specific concerns]
  Action: Discuss with user before proceeding
```

---

## Escalation Logic

| Gates Passed | Action |
|--------------|--------|
| 4/4 | Return result with confidence |
| 3/4 | Return result with note: "Minor validation issue detected" |
| 2/4 | Return with warning, offer fallback option |
| 0-1/4 | Do NOT return. Offer fallback only |

### Escalation Template

```
Validation Results for [task_id]:

Gate 1 (File Integrity): [PASS/FAIL]
Gate 2 (Structure): [PASS/FAIL]
Gate 3 (Content): [PASS/FAIL]
Gate 4 (Quality): [PASS/FAIL]

Overall: [X]/4 gates passed

[If < 4 passed:]
Issues detected:
- [Gate N]: [specific issue]
- Evidence: [sample output]

Options:
1. Retry with CLI (different parameters)
2. Process with Claude (monolithic, slower)
3. Accept with manual review
4. Abort task

Which would you prefer?
```

---

## Evidence Collection

For each failed gate, log to `.claude/logs/[taskid]_validation.md`:

```markdown
# Validation Log: [task_id]
Date: [timestamp]
Task: [brief description]

## Failed Gates

### Gate [N]: [gate_name]
- Check: [which check failed]
- Expected: [what was expected]
- Actual: [what was found]
- Evidence: 
  ```
  [relevant output sample, max 20 lines]
  ```

## Action Taken
[retry/fallback/manual/abort]

## Resolution
[final outcome]
```

---

## Quick Reference

```
Gate 1: File exists? Size > 100B? Readable?
        FAIL -> Retry once, then fallback

Gate 2: Format correct? No placeholders? No errors?
        FAIL -> Ask Claude to reformat

Gate 3: Length OK? Syntax valid? Secure?
        FAIL -> Manual review required

Gate 4: Logic sound? Style matches? Comments accurate?
        FAIL -> Discuss with user
```

---

## Cross-References

- Routing: [ORCHESTRATION_RULES.md](./ORCHESTRATION_RULES.md)
- Metrics: [../logs/METRICS_WEEK1.md](../logs/METRICS_WEEK1.md)
- Strategy: [../CLAUDE.md](../CLAUDE.md#delegation-strategy)
