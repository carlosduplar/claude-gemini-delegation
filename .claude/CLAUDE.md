MANDATORY: Delegate ALL git/shell/multi-file/web tasks to Gemini CLI. NEVER use Bash for those. Chain related operations in single Gemini call using && or ;

Flags:
- Model: -m gemini-2.5-pro (default) OR -m gemini-flash-latest (simple tasks/quota fallback)
- Env: export REFERRAL=claude
- Output: -o json
- Shell: -y OR read-only: --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch

Claude only: single-file edits, code gen, Q&A.