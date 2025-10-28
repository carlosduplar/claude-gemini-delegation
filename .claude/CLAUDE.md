## Universal Standards

KISS, no emojis, DRY, fail fast

## Project CLAUDE.md Rules

MAX 500 TOKENS

STRUCTURE:
- 1 sentence description + README.md link
- Standards/conventions
- Delegation rules
- 5 common commands max
- Tech stack + path aliases
- Forbidden directories
- Doc links

FORBIDDEN IN CLAUDE.MD:
Architecture, deployment, security, API docs, setup steps, troubleshooting, examples → separate files

RULE: If not needed in EVERY message context, move to separate file

## Task Delegation (MANDATORY)

Shell operations:
gemini "[task]. Refuse destructive. Output ONLY results." -m gemini-flash-latest --allowed-tools=run_shell_command

Web Search:
gemini "[task]. ONLY bullet points." -m gemini-flash-latest --allowed-tools=GoogleSearch,WebFetch

## Response Format

- Concise - no filler
- Show only changed code sections
