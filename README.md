# Claude Code + Gemini CLI Delegation

Automatically delegate high-token or tool-heavy tasks from Claude Code to Gemini CLI to preserve Claude token/quota and profit from Gemini's higher limits.

## Why This Matters
- 60-70% reduction in Claude token consumption
- Claude Pro caps at ~19K tokens/5h; Gemini offers 1M tokens/day free tier
- Clearer audit trail, simpler debugging, faster turnaround on large-context tasks

## Delegation Scope
- Delegate tasks that require large context, external tools, or shell/file access.
  - All shell commands (git, npm, build, ls, grep, find, etc.)
  - Web search and documentation lookup
  - Browser automation tasks
  - Security audits
- Claude handles single-file edits, straight code generation, architectural decisions, and small queries.

## Quick Start
1. Install/Update CLIs:
```bash
npm install -g @google/gemini-cli @anthropic-ai/claude-code
```
2. Place delegation rules:
```bash
cp .claude/CLAUDE.md /path/to/project/.claude/   # project
cp .claude/CLAUDE.md ~/.claude/                # user-wide
```
3. Test:
```bash
cd /path/to/project && claude
Ask a large-scope task (e.g., "Analyze the repository for performance issues")
```

## CLAUDE.md Configuration

CLAUDE.md enforces these token-saving patterns:

- **KISS principle**: Prevents over-engineering
- **Batched edits**: Groups related changes (~30% token savings)
- **Concise responses**: "No filler" directive reduces verbose output
- **Auto-delegation**: Routes shell/search/browser/security tasks to Gemini
- **500 token limit**: Keeps project rules minimal and deterministic

## Gemini CLI recommendations
- Prefer [Gemini CLI extensions](https://geminicli.com/extensions/) over MCP for tool access. Extensions run locally and are token-efficient.
- Install recommended extensions/tools:
  - [context7](https://github.com/upstash/context7) (context management)
  - [chrome-devtools](https://github.com/ChromeDevTools/chrome-devtools-mcp) (browser debugging)
  - [securityServer](https://github.com/gemini-cli-extensions/security) from gemini-cli-security (for security checks)

## Additional Claude Optimization
- Uninstall all MCP tools from Claude
- Turn off auto-compact in /config
- Avoid subagents: 5-10K token overhead per invocation
- Use context management: /clear, /compact, and session restarts when Claude drifts from delegation rules.

## Examples

**Delegated to Gemini:**
- "Find all TODOs across the codebase" → Shell tools
- "Test the login form and capture screenshots" → chrome-devtools extension if installed
- "Perform security audit on auth module" → securityServer extension if installed
- "Search React documentation for useEffect" → GoogleSearch + context7 extension if installed

**Handled by Claude:**
- "Write a function to parse JSON" → Direct code generation
- "Refactor this function for readability" → Single-file edit
- "Should I use Redis or PostgreSQL here?" → Architecture decision

## Delegation Testing
- Run: ./tests/regression/run_tests.sh

## Troubleshooting

**Claude not delegating:**
- Verify CLAUDE.md is in `.claude/` directory
- Run `/clear` to reset context

## Support
- Issues: https://github.com/carlosduplar/claude-gemini-delegation/issues
- Discussions: https://github.com/carlosduplar/claude-gemini-delegation/discussions

--- 

**Last Updated:** October 29, 2025