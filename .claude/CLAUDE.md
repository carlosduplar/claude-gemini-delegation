# Repository Configuration

## ADVANCED ROUTER AGENT DELEGATION RULES

This repository implements **Advanced Delegation Logic** using an intelligent "Router Agent" system that analyzes user prompts to decide optimal routing.

### Delegation Priority Order

#### Priority 1: Explicit Shell Command Detection
**ALWAYS delegate to gemini-shell-ops subagent when prompt contains:**
- Git commands: `git`, `commit`, `push`, `pull`, `merge`, `branch`, `rebase`, `log`, `diff`
- npm/yarn: `npm`, `yarn`, `pnpm`, `install`, `build`, `test`, `dev`, `start`
- Docker: `docker`, `kubectl`, `compose`
- Python: `pip`, `python`, `virtualenv`
- Rust: `cargo`, `rustc`
- Go: `go run`, `go build`, `go test`
- Build tools: `make`, `cmake`, `gradle`, `maven`
- Unix utils: `ls`, `find`, `grep`, `cat`, `wc`, `sed`, `awk`
- DevOps: `ssh`, `curl`, `wget`, `terraform`, `ansible`

**Rationale:** Direct shell command execution requires process monitoring and error handling that Gemini CLI excels at.

#### Priority 2: High-Token File Analysis (200+ lines)
**ALWAYS delegate to gemini-large-context subagent when:**
- User mentions specific file paths in their prompt
- Total combined line count of all mentioned files > **200 lines**
- This prevents Claude from consuming excessive tokens on large files

**Detection method:**
1. Parse prompt for file paths (e.g., `src/auth.js`, `./config.json`, `C:\path\file.py`)
2. Calculate total line count across all mentioned files using `wc -l` or PowerShell `(Get-Content).Count`
3. If total > 200 lines → delegate to Gemini CLI
4. If total ≤ 200 lines → Claude handles it

**Rationale:** Token efficiency. Large files should be processed by Gemini's 1M-token context instead of consuming Claude's limited token budget.

#### Priority 3: Keyword-Based Triggers (Existing)
**ALWAYS delegate to gemini-large-context subagent when user says:**
- "analyze all files"
- "analyze the entire"
- "review all files"
- "scan the codebase"
- "audit the project"
- Any request involving more than 5 files

#### Priority 4: Default to Claude (Self-Execution)
**If none of the above rules match:**
- Claude handles the request directly
- Use for: conceptual questions, small code changes, architecture discussions, single-file edits

**Rationale:** Not everything needs delegation. Claude excels at reasoning, design decisions, and small-scale code generation.

## How to Delegate

When you detect one of the above triggers, YOU MUST:

1. Immediately invoke the appropriate subagent
2. Do NOT use your own Read() or Search() tools
3. Pass the full request to the subagent
4. Wait for subagent response
5. Synthesize results for user

**Examples:**

**Example 1: Shell Command (Priority 1)**
```
User: "git commit -m 'feat: add advanced routing'"
Action: Invoke gemini-shell-ops subagent
Reason: Detected explicit `git` command
```

**Example 2: Large Files (Priority 2)**
```
User: "Analyze auth.js and database.js"
Step 1: Check file sizes: auth.js (150 lines) + database.js (100 lines) = 250 lines
Step 2: 250 > 200 threshold → Invoke gemini-large-context subagent
Reason: High-token file analysis
```

**Example 3: Small Files (Default to Claude)**
```
User: "Review config.json"
Step 1: Check file size: config.json (50 lines)
Step 2: 50 ≤ 200 threshold → Claude handles directly
Reason: Within token budget, no delegation needed
```

**Example 4: Conceptual Question (Default to Claude)**
```
User: "Explain the benefits of delegation"
Action: Claude responds directly
Reason: No shell commands, no file paths → conceptual task
```

## Router Agent Helper Tool

Use the PowerShell helper tool for manual delegation decisions:

```powershell
.\scripts\powershell\Invoke-SmartDelegation.ps1 -Prompt "git status"
# Returns: gemini-shell-ops (detected explicit shell command)

.\scripts\powershell\Invoke-SmartDelegation.ps1 -Prompt "Analyze auth.js and db.js"
# Returns: gemini-cli (if total > 200 lines) or claude-self (if ≤ 200)
```