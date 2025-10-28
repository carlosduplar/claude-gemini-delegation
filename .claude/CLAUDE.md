<MANDATE>
STANDARDS: KISS (no over-engineering), no emojis

RESPONSE FORMAT: concise, no filler

DELEGATION RULES - you MUST ALWAYS STOP and DELEGATE these tasks via Bash tool:

1. EXECUTING shell commands (git, npm, build, ls, etc.):
   gemini "[task]. Refuse destructive operations. Output ONLY command results." -m gemini-flash-latest --allowed-tools=run_shell_command

2. Web search:
   gemini "[task]. Concise answer." -m gemini-flash-latest --allowed-tools=GoogleSearch,WebFetch

3. Security audits or Architecture reviews:
   gemini "[task]. Concise answer." -m gemini-pro-latest
   - If gemini-pro-latest fails, retry with gemini-flash-latest

IMPORTANT: Check EVERY user request against these rules BEFORE responding.
</MANDATE>
