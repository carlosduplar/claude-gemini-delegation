# Orchestration Decision Rules for Claude Code

Route tasks between Claude Code (orchestrator) and CLI tools (Gemini/Copilot) based on token efficiency.

## Decision Flow

```
User submits task
       |
       v
+------+-------+
| Measure:     |
| - Tokens     |
| - Type       |
| - Interactive|
+--------------+
       |
       v
+------+-------+        +------------------+
| Rule 1:      |  YES   |                  |
| >25K tokens  +------->| DELEGATE to CLI  |
| + right type?|        |                  |
+--------------+        +------------------+
       | NO
       v
+------+-------+        +------------------+
| <8K tokens?  |  YES   |                  |
|              +------->| KEEP in Claude   |
+--------------+        +------------------+
       | NO
       v
+------+-------+        +------------------+
| Rule 2:      |  YES   |                  |
| Interactive? +------->| KEEP in Claude   |
+--------------+        +------------------+
       | NO
       v
+------+-------+        +------------------+
| Rule 3:      |  YES   |                  |
| Critical?    +------->| KEEP in Claude   |
| (security/   |        | (full audit)     |
| production)  |        +------------------+
+--------------+
       | NO
       v
+------+-------+        +------------------+
| Rule 4:      |  YES   |                  |
| CLI-suitable +------->| DELEGATE to CLI  |
| type?        |        |                  |
+--------------+        +------------------+
       | NO
       v
+------------------+
| KEEP in Claude   |
| (default safe)   |
+------------------+
```

---

## Rule Definitions

### Rule 1: Token Volume (Primary)

| Condition | Action |
|-----------|--------|
| `tokens > 25000 AND type in [refactor, test_gen, audit, docs]` | DELEGATE |
| `tokens < 8000` | KEEP (overhead not worth it) |
| Otherwise | Continue to Rule 2 |

**Rationale:** Large context tasks benefit most from CLI delegation. Small tasks incur overhead that exceeds savings.

### Rule 2: Interaction Pattern

| Condition | Action |
|-----------|--------|
| Task requires multiple refinement rounds | KEEP |
| Task is one-shot async | Continue to Rule 3 |

**Rationale:** Interactive tasks suffer from CLI latency. Keep in Claude for responsive UX.

### Rule 3: Code Quality Criticality

| Condition | Action |
|-----------|--------|
| `category in [security_audit, production_refactor, generated_code]` | KEEP |
| Otherwise | Continue to Rule 4 |

**Rationale:** Critical code needs full visibility, audit trail, and Claude's reasoning quality.

### Rule 4: Task Type Suitability

| CLI-Suitable (DELEGATE) | Claude-Suitable (KEEP) |
|-------------------------|------------------------|
| refactor | architecture |
| test_gen | complex_reasoning |
| documentation | novel_problem |
| static_analysis | design decisions |
| bulk formatting | code review requiring context |

---

## Implementation Pattern

When evaluating a task in Claude Code:

```
Based on ORCHESTRATION_RULES.md:
- Input tokens: [estimated count]
- Task type: [classification]
- Interactivity: [yes/no]
- Criticality: [low/medium/high]

Decision: [KEEP | DELEGATE]
Reason: Rule [N] - [brief explanation]

If DELEGATE:
  1. Write context to .claude/tasks/[taskid]_input.md
  2. Run: gemini "[task description]" --input .claude/tasks/[taskid]_input.md
  3. Validate result using VALIDATION_GATES.md
  4. Return validated result

If KEEP:
  Process directly in Claude
```

---

## Failure Modes & Fallback

### When Delegation Fails

1. **File not created**: CLI crashed or timed out
   - Fallback: Retry once, then KEEP in Claude

2. **Empty or malformed output**: CLI produced garbage
   - Fallback: KEEP in Claude with original context

3. **Validation gates fail**: Output doesn't meet quality bar
   - Fallback: Offer user choice (retry CLI, KEEP in Claude, manual fix)

### Fallback Behavior

```
IF delegation fails:
  1. Log failure: .claude/logs/[taskid]_failure.md
  2. Notify user: "CLI delegation failed, using backup method"
  3. Process with monolithic Claude (original task, full context)
  4. Track in metrics for threshold adjustment
```

---

## Token Cost Examples

### Example 1: 50K Token Refactor (DELEGATE)

| Phase | Tokens | Notes |
|-------|--------|-------|
| Read task context | 2K | User's request |
| Write input file | 0 | File system operation |
| CLI execution | 0 | Outside Claude context |
| Read result | 8K | Refactored code |
| Validation | 2K | Run gates |
| **Total** | **12K** | vs 50K monolithic |
| **Savings** | **76%** | |

### Example 2: 5K Token Quick Fix (KEEP)

| Phase | Tokens | Notes |
|-------|--------|-------|
| Read context | 5K | Small task |
| Generate fix | 2K | Output |
| **Total (KEEP)** | **7K** | Direct processing |
| Delegation would add | +4K | Overhead for small task |
| **Decision** | KEEP | Overhead exceeds savings |

---

## Cross-References

- Validation: [VALIDATION_GATES.md](./VALIDATION_GATES.md)
- Metrics: [../logs/METRICS_WEEK1.md](../logs/METRICS_WEEK1.md)
- Strategy: [../CLAUDE.md](../CLAUDE.md#delegation-strategy)
