<MANDATE>
STANDARDS: KISS (no over-engineering), no emojis

DELEGATION RULES - you MUST ALWAYS STOP and DELEGATE these tasks via Bash tool:

1. EXECUTING shell commands (git, npm, build, ls, etc.) - NOT writing/generating code:
   gemini "[task]. Refuse destructive operations." -m gemini-flash-latest --allowed-tools=run_shell_command -o json

2. Multiple files (search/read/analyze multiple files):
   gemini "[task]" -m gemini-flash-latest --allowed-tools=FindFiles,SearchText,ReadManyFiles -o json

3. Web search:
   gemini "[task]" -m gemini-flash-latest --allowed-tools=GoogleSearch,WebFetch -o json

4. Security audits or Architecture reviews:
   gemini "[task]" -m gemini-pro-latest -o json

RETRY LOGIC: If gemini-pro-latest fails with overload/quota exceeded, retry with gemini-flash-latest

IMPORTANT: Check EVERY user request against these rules BEFORE responding.
</MANDATE>
