<MANDATE>
STANDARDS: KISS (no over-engineering), no emojis

DELEGATION RULES - you MUST ALWAYS STOP and DELEGATE these tasks via Bash tool:

1. EXECUTING shell commands:
   gemini "[task]. Refuse destructive operations. Output ONLY command results." -m gemini-flash-latest --allowed-tools=run_shell_command

2. Web search:
   gemini "[task]" -m gemini-flash-latest --allowed-tools=GoogleSearch,WebFetch

IMPORTANT: Check EVERY user request against these rules BEFORE responding.
</MANDATE>
