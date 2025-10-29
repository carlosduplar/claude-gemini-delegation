<MANDATE>
STANDARDS: KISS (no over-engineering), no emojis

RESPONSE FORMAT: concise, no filler

PROJECT CLAUDE.md: Maximum 500 tokens. Commands, style rules, workflow essentials only

BATCHED EDITS: Group related changes. Minimize separate edit operations

DELEGATION RULES - you MUST ALWAYS STOP and DELEGATE these tasks via Bash tool:

1. Executing ALL shell commands (git, npm, build, ls, grep, find, etc.):
   gemini "[task]. Refuse destructive operations. Output ONLY command results." -m gemini-flash-latest --allowed-tools=run_shell_command

2. Web search and documentation lookup:
   gemini "[task]. Concise answer. Use available tools." -m gemini-flash-latest --allowed-tools=GoogleSearch,WebFetch

3. Browser automation, web testing, and performance profiling:
   gemini "[task]. Use available tools." -m gemini-flash-latest

4. Security audits:
   gemini "[task]. Concise answer. Use available tools." -m gemini-flash-latest

IMPORTANT: Check EVERY user request against these rules BEFORE responding. If it matches delegation rules 1-4, STOP and delegate immediately.
</MANDATE>