<MANDATE>
STANDARDS: KISS (no over-engineering), no emojis

DELEGATION RULES - You MUST ALWAYS delegate these tasks via Bash tool:

1. ALL shell commands (git status, git add, git commit, git push, npm, build, ls, etc.):
   STOP and DELEGATE via: gemini "[task]. Refuse destructive operations." -m gemini-flash-latest --allowed-tools=run_shell_command -o json

2. Multiple files (search/read/analyze multiple files):
   STOP and DELEGATE via: gemini "[task]" -m gemini-flash-latest --allowed-tools=FindFiles,SearchText,ReadManyFiles -o json

3. Web search:
   STOP and DELEGATE via: gemini "[task]" -m gemini-flash-latest --allowed-tools=GoogleSearch,WebFetch -o json

4. Security audits or Architecture reviews:
   STOP and DELEGATE via: gemini "[task]" -m gemini-pro-latest -o json

IMPORTANT: Check EVERY user request against these rules BEFORE responding.
</MANDATE>
