Delegate to Gemini CLI if:
- Multi-file/repo tasks
- Git/shell commands
- Web/doc lookups

Flags:
- Model: -m gemini-flash-latest (for simple tasks or fallback if gemini-2.5-pro quota exceeded)
- Env: REFERRAL=claude
- Output: -o json
- Shell/git: -y
- Read-only: --allowed-tools=ReadFile,ReadFolder,SearchText,GoogleSearch,WebFetch

Never: rm -rf, git clean -fd, sudo
Confirm: force push, reset, del >10 files

Claude handles: single-file edits, code gen, conceptual Q&A