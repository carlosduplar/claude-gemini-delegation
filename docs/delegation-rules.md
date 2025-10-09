# Delegation Rules

This document explains when Claude Code delegates tasks to Gemini CLI.

## When to Delegate

Claude automatically delegates to Gemini CLI via subagents when:

### 1. Large Files (>200 lines)
When the total line count of files mentioned in the request exceeds 200 lines.

**Example:**
```
User: "Analyze auth.js and database.js"
- auth.js: 150 lines
- database.js: 100 lines
- Total: 250 lines > 200 threshold
Result: Delegates to gemini-large-context subagent
```

### 2. Repository-Wide Operations
When keywords indicate large-scale analysis:
- "entire codebase"
- "all files"
- "whole repository"
- "scan the project"
- "audit"

**Example:**
```
User: "Analyze the entire codebase for security issues"
Result: Delegates to gemini-large-context subagent
```

### 3. Shell Operations
When the request involves shell commands:
- Git operations: `git commit`, `git push`, `git log`, etc.
- npm commands: `npm install`, `npm test`, `npm build`, etc.
- Build tools: `make`, `docker`, `cargo`, etc.

**Example:**
```
User: "Run npm test and fix any failures"
Result: Delegates to gemini-shell-ops subagent
```

## When NOT to Delegate

Claude handles these directly (no delegation):
- Small files (<200 lines total)
- Single-file edits
- Conceptual questions
- Architecture discussions
- Design decisions
- Code generation (<200 lines)

## Configuration

### Project-Level Configuration
Create `.claude/CLAUDE.md` in your project root to customize delegation rules:

```markdown
## When to Use Gemini CLI

You MUST use `gemini -p` shell command (via Bash tool) when:
- Comparing multiple large files (>200 lines total)
- Analyzing entire codebases or large directories
- Working with files totaling more than 100KB
```

### Adjust Thresholds
Change the line count threshold by editing your project's `.claude/CLAUDE.md`:
```markdown
- Comparing multiple large files (>300 lines total)  # Changed from 200
```

## Subagents

### gemini-large-context
**Handles:** Large file analysis, repository-wide operations
**Triggers:** >200 lines, "entire codebase", "all files"

### gemini-shell-ops
**Handles:** Shell commands, Git operations, npm commands
**Triggers:** Shell command keywords in user request

## Token Savings

By delegating large operations to Gemini CLI (1M free tokens), Claude preserves its Pro token limits:

| Operation | Claude Tokens | Gemini Tokens | Saved |
|-----------|---------------|---------------|-------|
| 500-line file analysis | 20K | 0 (Gemini handles) | 20K |
| Full repo audit | 150K+ | 0 (Gemini handles) | 150K+ |
| Shell commands | 5K | 0 (Gemini handles) | 5K |

## Troubleshooting

### Delegation not working
1. Verify subagent files exist in `~/.claude/agents/`:
   - `gemini-large-context.md`
   - `gemini-shell-ops.md`
2. Check that Gemini CLI MCP is installed: `claude mcp list`
3. Test explicitly: "Use gemini-large-context to analyze this"

### Wrong subagent triggered
Clarify your request or use explicit subagent invocation:
```
"Use gemini-large-context to analyze the repository"
"Use gemini-shell-ops to run git status"
```
