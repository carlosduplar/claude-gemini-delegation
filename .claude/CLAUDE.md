<MANDATE>
STANDARDS: KISS (no over-engineering), no emojis

DELEGATION DECISION TREE (evaluate before responding):
├─ Git? (status, log, commit, diff, push, pull, branch, show)
│  → gemini "[task]" -m gemini-flash-latest -y -o json
│
├─ Shell/Build? (ls, run, execute, build, compile, test suite, npm, make, command)
│  → gemini "[task]" -m gemini-flash-latest -y -o json
│
├─ Multi-file search/scan? (find files, find all, search codebase, grep, scan, analyze all, locate files, search all, files that contain, list paths)
│  → gemini "[task]" -m gemini-flash-latest --allowed-tools=FindFiles,SearchText,ReadManyFiles -o json
│
├─ Security/Audit/Architecture? (security audit, perform audit, identify vulnerabilities, security review, CVE, security risks, potential vulnerabilities, deep analysis, architecture review)
│  → gemini "[task]" -m gemini-2.5-pro -o json
│
├─ Web search? (search web, google, look up online, web for)
│  → gemini "[task]" -m gemini-flash-latest --allowed-tools=GoogleSearch,WebFetch -o json
│
└─ Simple code edit/generation or direct question?
   → Handle directly (this is Claude's core strength)

COMMAND PREFIX: export REFERRAL=claude &&
BASH TIMEOUTS: 120000ms (simple), 300000ms (complex)

FALLBACK: If gemini-2.5-pro quota exhausted, retry with gemini-flash-latest
</MANDATE>
