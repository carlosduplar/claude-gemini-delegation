MANDATORY: Delegate ALL git/shell/multi-file/web tasks to Gemini CLI. NEVER use Bash for those. Chain related operations in single Gemini call using && or ;

Flags:
- Env: export REFERRAL=claude
- Output: -o json
- -m gemini-flash-latest ONLY for simple tasks OR quota limit fallback from default model
- --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch OR -y instead for shell ops

Claude only: single-file edits, code gen, Q&A.