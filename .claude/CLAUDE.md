<MANDATE>
STANDARDS: KISS, YAGNI, DRY. no emojis

RESPONSE FORMAT: concise, no filler

PROJECT CLAUDE.md: Maximum 500 tokens. Commands, style rules, workflow essentials only

BATCHED EDITS: Group related changes. Minimize separate edit operations

DELEGATION RULES - you MUST ALWAYS STOP and DELEGATE these tasks via Bash tool:

1. Read-only shell commands (npm, build, ls, grep, find, etc.):
   gemini "[task]. Refuse destructive operations. Output ONLY command results and STOP." --allowed-tools=run_shell_command

2. Web search and documentation lookup:
   gemini "[task]. Concise answer. Use available tools." --allowed-tools=GoogleSearch,WebFetch

3. Browser automation, web testing, and performance profiling:
   gemini "[task]. Use available tools. Output ONLY findings and recommendations and STOP."

4. Security audits:
   gemini "[task]. Scan for security vulnerabilities, hardcoded secrets, broken access control, and insecure patterns. Use available tools. Output ONLY issues with severity and remediation and STOP."

5. Code review (quality and patterns):
   gemini "[task]. Review code for quality, readability, logic errors, and best practices. Use available tools. Output ONLY findings and recommendations and STOP."

IMPORTANT: Check EVERY user request against these rules BEFORE responding. If it matches delegation rules 1-4, STOP and delegate immediately.

---

## Delegation Strategy

This project uses hybrid orchestration for token efficiency:

**Orchestrator:** Claude Code (routing decisions, validation, user interaction)
**Heavy Lifting:** 
- Gemini CLI: `gemini "[task]" --allowed-tools=...`
- Copilot CLI: `copilot --model claude-opus-4.5 -p "[task]" -s --allow-all-tools`

### Routing Rules
Reference: `.claude/orchestrators/ORCHESTRATION_RULES.md`
- Rule 1: Token Volume (>25K + suitable type = DELEGATE)
- Rule 2: Interaction Pattern (interactive = KEEP)
- Rule 3: Criticality (security/production = KEEP)
- Rule 4: Task Type (refactor/test/docs = DELEGATE)

### Validation Gates
Reference: `.claude/orchestrators/VALIDATION_GATES.md`
- Gate 1: File Integrity (exists, >100B, readable)
- Gate 2: Structure (format correct, no placeholders)
- Gate 3: Content (length OK, syntax valid, secure)
- Gate 4: Quality (spot-check 3 sections)

### Example: 50K Token Refactor

```
Task: "Refactor src/api.js to async/await (50K tokens)"

Routing Decision:
- Tokens: 50K (>25K threshold)
- Type: refactor (CLI-suitable)
- Interactive: No
- Critical: No
-> DELEGATE to Gemini CLI

Execution:
1. Write context to .claude/tasks/api_refactor_input.md
2. Run: gemini "[refactor task]" --input .claude/tasks/api_refactor_input.md
3. Read result (~8K tokens)
4. Validate using gates (all pass)
5. Return validated result

Token Breakdown:
- Claude read input:    2K
- CLI execution:        0  (outside context)
- Claude read result:   8K
- Validation:           2K
- Total:               12K vs 50K monolithic = 76% savings
```

### Fallback Behavior

If CLI delegation fails:
1. Log failure to `.claude/logs/`
2. Notify: "CLI delegation failed, using backup method"
3. Retry with monolithic Claude (full context)
4. Track in metrics for threshold adjustment

### Metrics
Track in: `.claude/logs/METRICS_WEEK1.md`
</MANDATE>
