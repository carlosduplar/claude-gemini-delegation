Delegate to Gemini CLI if:
- Multi-file/repo tasks
- Git/shell commands
- Web/doc lookups

Flags:
- Model: -m gemini-flash-latest (simple tasks: faster, cheaper)
- Env: GEMINI_INVOKED_BY=claude
- Output: -o json
- Shell/git: -y
- Read-only: --allowed-tools=ReadFile,ReadFolder,SearchText,GoogleSearch,WebFetch

Never: rm -rf, git clean -fd, sudo
Confirm: force push, reset, del >10 files

Claude handles: single-file edits, code gen, conceptual Q&A