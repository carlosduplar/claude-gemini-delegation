## Universal Standards

KISS, no emojis, DRY, fail fast

## Task Delegation (MANDATORY)

Shell operations:
gemini "[task]. Refuse destructive. Output ONLY results." -m gemini-flash-latest --allowed-tools=run_shell_command

Web Search:
gemini "[task]. ONLY bullet points." -m gemini-flash-latest --allowed-tools=GoogleSearch,WebFetch

## Response Format

- Concise - no filler
- Show only changed code sections
