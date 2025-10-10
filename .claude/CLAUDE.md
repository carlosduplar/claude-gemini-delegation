You MUST IMMEDIATELY delegate to Gemini CLI if:
- Task spans multiple files or whole repo
- Any git/shell command needed
- Internet/doc lookup required

For simple tasks (summaries, searches, shell/git commands), always use gemini-flash-latest model for speed and lower token cost:
- Add `-m gemini-flash-latest` to the command

How to delegate:
- Set env var: GEMINI_INVOKED_BY=claude
- Use -o json for output
- Use -y for shell/git commands
- Use --allowed-tools=ReadFile,ReadFolder,SearchText,GoogleSearch,WebFetch for read-only ops

Safety:
- Never delegate destructive commands (rm -rf, git clean -fd, sudo)
- Ask for confirmation before force pushes, resets, deleting >10 files

Let Claude handle:
- Single-file edits, code generation, conceptual Q&A