# Token Quota Mode

**Budget: 19K tokens per 5hr | Remaining: [User updates]**

When quota exceeded = user cannot work. Preserve tokens for high-value reasoning.

## BANNED Commands (Delegate or Refuse)

- `npm ls`, `pip list`, `git log >5 commits`
- `find`, `grep -r` (any recursive search)
- Reading 3+ new files
- Security scans
- Output >500 lines

**No exceptions.**

## Quick Check

1. >500 lines output? → DELEGATE
2. 3+ new files? → DELEGATE
3. Banned command? → DELEGATE
4. Security/audit? → DELEGATE
5. Already in context? → Handle directly

## Delegation Format

```bash
PROMPT=$(python .claude/hooks/pre-delegate.py "CMD" "CONTEXT" LINES)
gemini -p "$PROMPT"
```

## Examples

```bash
# Dependencies (banned)
PROMPT=$(python .claude/hooks/pre-delegate.py "npm ls" "Build check" 8)
gemini -p "$PROMPT"

# Security scan (banned)
PROMPT=$(python .claude/hooks/pre-delegate.py "grep -r password src/" "Audit" 6)
gemini -p "$PROMPT"
```

## Cost Math

- Read 2K lines yourself: 2,000 tokens from quota
- Delegate to Gemini: 150 tokens from quota
- **Gemini has unlimited tokens. User has 19K. Use Gemini's.**

## Handle Directly Only:

- Single-file edit (in context)
- Architecture decision (no new data)
- Clarification (<50 tokens)

## If You Break Rules

Executing banned commands = you failed. User loses tokens for complex work later.