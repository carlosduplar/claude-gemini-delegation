# Claude Code + Gemini CLI Delegation

Automatically delegate cross-file, repository-wide, and shell tasks from Claude Code to Gemini CLI, optimizing token usage across both AI assistants.

**Problem:** Claude Pro caps at ~19K tokens/5h. Power users hit limits during repo-wide analysis, multi-file operations, or shell automation.

**Solution:** Claude autonomously routes high-token tasks to Gemini CLI (1M tokens/day, 1000 req/day, free tier available).

## Prerequisites

- **Node.js**: Version 18 or higher - download it at [nodejs.org](https://nodejs.org/en/download)

## Quick Start

1. **Install/update Gemini CLI to the latest version**
```bash
npm install -g @google/gemini-cli
```

2. **Install/update Claude Code to the latest version**
```bash
npm install -g @anthropic-ai/claude-code
```

3. **Choose your configuration scope:**

**Option A: Project-specific (recommended for teams)**
```bash
# Copy or merge to your project
mkdir -p /path/to/project/.claude
cp .claude/CLAUDE.md /path/to/project/.claude/
```

**Option B: User-wide (applies to all your projects)**
```bash
# Copy or merge to Claude Code user settings
cp .claude/CLAUDE.md ~/.claude/
```

3. **Test delegation:**
```bash
cd /path/to/project && claude
# Ask: "Analyze the entire repository for performance issues"
# Claude detects "entire repository" and delegates to Gemini CLI
```

## Delegation Rules

Claude delegates when:

1. **Cross-File Context:** Understanding or modifying code that spans multiple files
2. **Repository-Wide Analysis:** Keywords like "analyze all files", "entire codebase", "scan repository"
3. **Shell Operations:** Git commands, npm/package manager commands, build scripts
4. **Internet Access:** Requests requiring real-time information, documentation lookups, or web searches

**Examples:**
- `"Audit codebase for security"` → `gemini "Analyze @. for security" --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText -o json`
- `"Run tests and analyze failures"` → `gemini "Run npm test and explain failures" -m gemini-flash-latest -y -o json`
- `"Get git log from last 100 commits"` → `gemini "Show git log -100 --oneline" -m gemini-flash-latest -y -o json`
- `"What are the latest features in Node.js 22?"` → `gemini "Find latest Node.js 22 features" -m gemini-flash-latest --allowed-tools=GoogleSearch,WebFetch -o json`

**Model Selection:**
- **gemini-flash-latest** (faster, higher rate limits): File summaries, git operations, documentation lookups, procedural tasks
- **gemini-2.5-pro** (default, more capable): Complex analysis, security audits, architecture reviews, deep reasoning

**Customize:** Edit `.claude/CLAUDE.md` to adjust delegation rules and tool permissions.

## Architecture

```text
User Request
    |
    v
Claude Code (analyzes task)
    |
    +-- Single-file, conceptual, code generation --> Claude handles directly
    |
    +-- Cross-file, repo-wide, or shell task --> Delegates via Bash
                                                      |
                                                      v
                                                  Gemini CLI
                                                  (executes with -y or --allowed-tools)
                                                      |
                                                      v
                                                  Results (JSON)
                                                      |
                                                      v
                                                  Claude synthesizes
```

**Decision logic:**
1. Cross-file context needed? → Gemini
2. Keywords: "entire", "all files", "scan repository"? → Gemini
3. Shell commands: git/npm/build? → Gemini (with `-y` and `-m gemini-flash-latest`)
4. Internet/documentation lookup needed? → Gemini (with `--allowed-tools=GoogleSearch,WebFetch` and `-m gemini-flash-latest`)
5. Otherwise: Claude handles directly

## Configuration

### Core Delegation Rules

Location: `<project-root>/.claude/CLAUDE.md`

This file tells Claude when to delegate to Gemini CLI. See `.claude/CLAUDE.md` in this repo for the template.

### Guardrail System

GEMINI.md and settings.json provide Gemini CLI security guardrails that apply when Claude Code invokes it:

**ALLOWED (Auto-execute):**
- Git: status, add, commit, push (non-force), pull, fetch, log, diff, branch, merge, stash
- NPM: install, run build/test/dev, audit, update, list
- Filesystem: mkdir, touch, cp, mv, ls, cat, grep (project scope)
- Read-only: ReadFile, ReadFolder, SearchText, GoogleSearch, WebFetch

**DENIED (Auto-block):**
- rm -rf (mass deletions)
- Repository deletion (rm -rf .git)
- git clean -fd, sudo operations
- Destructive piped commands
- Direct file writes via WriteFile tool

**REQUIRES CONFIRMATION:**
- git reset --hard, git push --force
- npm uninstall
- Operations affecting >10 files

## Files in This Repository

```text
.
├── README.md                # This file
├── .claude/
│   └── CLAUDE.md           # Claude Code delegation rules
├── .gemini/
│   ├── GEMINI.md           # Gemini guardrail instructions
│   └── settings.json       # Profile-based guardrail configuration
└── LICENSE                 # MIT License
```

## Key Features

- **Automatic Delegation:** Claude detects when to use Gemini based on configurable rules
- **Conditional Guardrails:** Security restrictions apply only in non-interactive mode, preserving full control for users
- **Secure Tool Usage:** Use `--allowed-tools` for read-only operations or `-y` for shell commands with guardrails
- **Structured Output:** All Gemini responses return JSON for easy parsing
- **Customizable Rules:** Edit `.claude/CLAUDE.md` and `.gemini/GEMINI.md` to adjust delegation and security behavior
- **Model Optimization:** Intelligently routes simple tasks to gemini-flash-latest for speed and rate limit conservation
- **Audit Logging:** Track all non-interactive operations for security review and debugging

## Performance Impact

**Token Savings Example** (from developing this repository):

| Metric | Without Delegation | With Delegation | Savings |
|--------|-------------------|-----------------|---------|
| Claude tokens used | ~156K tokens | ~42K tokens | **73% reduction** |
| Operations performed | 10 git ops, 3 web searches, repo analysis | Delegated to Gemini | Avoided rate limits |
| Gemini tokens used | N/A | ~168K tokens | From separate 1M/day quota |

**Time Efficiency:**
- **Git operations:** gemini-flash-latest executes in 1-3 seconds vs Claude's 5-10 seconds (contextual overhead)
- **Web searches:** Gemini has native GoogleSearch tool, faster than Claude's WebFetch
- **Repository analysis:** Gemini can process entire codebases without Claude's context window constraints

**Real-world benefits:**
- Stay under Claude Pro's 44K tokens/5h limit even with complex workflows
- Leverage Gemini's 1M tokens/day free tier for high-volume operations
- Faster execution for procedural tasks (git, npm, searches)
- Reserve Claude's context for high-value tasks: code generation, architecture decisions, complex reasoning

## Guardrail Architecture

### Design Philosophy

The guardrail system is designed to:
1. **Prevent accidental destruction** when Claude Code automates workflows
2. **Preserve user autonomy** in interactive sessions
3. **Maintain transparency** through audit logging
4. **Allow customization** for different security requirements

### How It Works

```text
Claude Code Request
    |
    v
Set GEMINI_INVOKED_BY=claude
    |
    v
Gemini CLI (detects non-interactive mode)
    |
    v
Load non_interactive_profile from settings.json
    |
    v
Evaluate command against:
    1. DENY list --> Abort with JSON error
    2. ALLOW list --> Execute safely
    3. PROMPT list --> Request user confirmation
    4. Default --> Request confirmation
    |
    v
Log to audit.log (timestamp, command, action, result)
    |
    v
Return JSON response to Claude Code
```

### Example Workflow: Safe Git Push

**User Request:** "Commit and push changes"

**Claude Code Action:**
```bash
export GEMINI_INVOKED_BY=claude && gemini "Stage all changes, commit with message 'Update docs', and push to remote" -m gemini-flash-latest -y -o json
```

**Gemini Evaluation:**
1. Detects `GEMINI_INVOKED_BY=claude` → Load guardrails
2. Parses commands: `git add -A && git commit -m "Update docs" && git push`
3. Checks each command:
   - `git add -A` → ALLOW list → Execute
   - `git commit` → ALLOW list → Execute
   - `git push` → ALLOW list → Execute
4. Logs to audit.log: `{"timestamp": "...", "command": "git push", "action": "allow", "executed": true}`
5. Returns: `{"status": "success", "output": "...", "mode": "non_interactive"}`

### Example Workflow: Blocked Destruction

**User Request:** "Clean up the repository completely"

**Claude Code Action:**
```bash
export GEMINI_INVOKED_BY=claude && gemini "Remove all untracked files and directories: git clean -fd" -y -o json
```

**Gemini Evaluation:**
1. Detects `GEMINI_INVOKED_BY=claude` → Load guardrails
2. Parses command: `git clean -fd`
3. Matches DENY list pattern: `^git\\s+clean\\s+-fd`
4. Returns: `{"status": "denied", "reason": "git clean -fd prohibited - use git status first", "mode": "non_interactive"}`
5. Logs to audit.log: `{"timestamp": "...", "command": "git clean -fd", "action": "deny", "executed": false}`

**Claude Code Response:** "The command 'git clean -fd' was denied by guardrails. This destructive operation is not allowed in automated mode. Please run 'gemini' interactively to perform this action with manual confirmation."

### Customization

Edit `~/.gemini/settings.json` to customize guardrails:

**Add custom allow pattern:**
```json
{
  "profiles": {
    "non_interactive_profile": {
      "command_rules": {
        "allow_list": [
          {
            "category": "custom_scripts",
            "patterns": [
              "^./scripts/deploy\\.sh",
              "^npm run deploy"
            ],
            "description": "Allow custom deployment scripts"
          }
        ]
      }
    }
  }
}
```

**Add custom deny pattern:**
```json
{
  "profiles": {
    "non_interactive_profile": {
      "command_rules": {
        "deny_list": [
          {
            "pattern": "^docker\\s+system\\s+prune\\s+-a",
            "description": "Block docker system prune in automation",
            "message": "Docker system prune requires manual review"
          }
        ]
      }
    }
  }
}
```

### Audit Log Analysis

View recent non-interactive operations:
```bash
# Show last 20 entries
tail -20 ~/.gemini/audit.log | jq '.'

# Find all denied commands
grep '"action":"deny"' ~/.gemini/audit.log | jq '.'

# Show commands from specific date
grep '2025-10-10' ~/.gemini/audit.log | jq '.'

# Count operations by action
jq -s 'group_by(.action) | map({action: .[0].action, count: length})' ~/.gemini/audit.log
```

## Complementary Tools

- [Claude Code Usage Monitor](https://github.com/Maciek-roboblog/Claude-Code-Usage-Monitor) is quite handy for tracking token consumption in near real-time and historical trends.

## Credits

- [Gemini CLI](https://github.com/google-gemini/gemini-cli) by Google
- [Claude Code](https://claude.ai/code) by Anthropic

## License

MIT License - See [LICENSE](LICENSE) file

## Support

- [Issues](https://github.com/carlosduplar/claude-gemini-delegation/issues)
- [Discussions](https://github.com/carlosduplar/claude-gemini-delegation/discussions)

---

**Last Updated:** October 9, 2025
