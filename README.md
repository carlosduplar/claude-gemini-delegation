# Claude Code → Gemini CLI Autonomous Delegation

Automatically route large-context and shell operations from Claude Code to Gemini CLI using MCP and subagents, preserving Claude Pro token limits while exploiting Gemini's 1M-token free tier.

## Why This Matters

**Problem:** Claude Pro caps at ~44K tokens every 5 hours plus 40-80 weekly Sonnet 4 hours. Power users hit limits during:
- Full-repository analysis
- Large test log debugging
- Multi-file refactoring
- Documentation generation
- Git operations

**Solution:** Claude Code autonomously delegates high-token tasks to Gemini CLI (1M tokens, 1000 daily requests, free) via MCP bridge and subagents.

## Architecture (Router Agent System)
```text
┌─────────────────────────────────────────┐
│ Claude Code (Router Agent)              │
│ - Intelligent prompt analysis           │
│ - 3-tier delegation priority system     │
│ - Token optimization logic              │
└────────┬────────────────────────────────┘
         │ Analyzes user prompt
         ├──────────────────────────────────┬────────────────────┐
         │                                  │                    │
    Priority 1:                       Priority 2:          Priority 3:
    Shell Commands?                   Large Files?         Keywords?
         │                                  │                    │
         ▼                                  ▼                    ▼
┌────────────────────┐         ┌────────────────────┐   Default: Claude
│ gemini-shell-ops   │         │ gemini-large-context│   (Self-execution)
│ Subagent           │         │ Subagent            │
│ - Git ops          │         │ - File analysis     │
│ - npm commands     │         │ - Repo audits       │
│ - Build scripts    │         │ - Large logs        │
└─────────┬──────────┘         └──────────┬─────────┘
          │                               │
          └───────────┬───────────────────┘
                      │ MCP Bridge
               ┌──────▼──────┐
               │ Gemini CLI  │
               │ (MCP Tool)  │
               │ Free 1M ctx │
               └─────────────┘
```
## Prerequisites

- **Node.js** 18+ and npm
- **Claude Code** with active Pro subscription
- **Gemini CLI** installed and authenticated
- **VS Code** (optional, for IDE integration)

## Quick Start (5 minutes)

### Step 1: Install Gemini CLI

```text
npm install -g @google/gemini-cli
gemini # Select OAuth - Personal Google Account
```

### Step 2: Install MCP Gemini CLI wrapper

This project uses [mcp-gemini-cli](https://github.com/DiversioTeam/gemini-cli-mcp) by DiversioTeam to bridge Claude Code with Gemini CLI.

```text
npm install -g mcp-gemini-cli
```

### Step 3: Connect Claude Code to Gemini CLI MCP
**For macOS/Linux:**
```text
claude mcp add-json --scope=user gemini-cli '{
"type": "stdio",
"command": "npx",
"args": ["-y", "mcp-gemini-cli"]
}'
```

**For Windows:**
```text
claude mcp add-json --scope=user gemini-cli "{"type":"stdio","command":"cmd","args":["/c","npx","-y","mcp-gemini-cli"]}"
```
**Note:** Windows requires the `cmd /c` wrapper to execute npx commands properly.

Verify connection:

```text
claude

/mcp
```
Should show gemini-cli listed


### Step 4: Install subagents

From this repository root:

**Linux/macOS (Bash):**
```bash
./scripts/bash/install-subagents.sh
```

**Windows (PowerShell):**
```powershell
.\scripts\powershell\Install-Subagents.ps1
```

This creates two subagents:
- `gemini-large-context` - For repository-wide operations
- `gemini-shell-ops` - For Git, npm, build commands

### Step 5: Configure your project

Copy configuration templates to your project:
```text
cp -r examples/project-config/.claude /path/to/your/project/
```

Edit `/path/to/your/project/.claude/CLAUDE.md` with your project-specific build commands and tech stack details.

### Step 6: Test autonomous delegation
```text
cd /path/to/your/project
claude

Analyze the entire repository for performance bottlenecks
```

Claude should automatically spawn `gemini-large-context` subagent → call Gemini CLI MCP → return analysis.

**Note:** All commands in Quick Start should be run from the repository root directory.

## Advanced Delegation Logic (Router Agent)

This repository implements an **intelligent Router Agent system** that automatically analyzes user prompts to determine optimal routing between Claude Code and Gemini CLI.

### How It Works

Instead of simple keyword matching, the Router Agent uses a **3-tier priority system**:

#### Priority 1: Explicit Shell Command Detection
**Triggers:** Prompt contains actual shell commands
**Action:** Delegate to `gemini-shell-ops` subagent
**Detected commands:**
- Git: `git`, `commit`, `push`, `pull`, `merge`, `branch`, `rebase`
- npm/yarn: `npm`, `yarn`, `pnpm`, `install`, `build`, `test`, `dev`
- Docker: `docker`, `kubectl`, `compose`
- Build tools: `make`, `cmake`, `gradle`, `maven`
- Unix utils: `ls`, `find`, `grep`, `cat`, `wc`, `sed`, `awk`

**Example:**
```bash
User: "git commit -m 'feat: add router agent'"
→ Detected: `git` command
→ Action: Delegate to gemini-shell-ops
```

#### Priority 2: High-Token File Analysis (200+ lines)
**Triggers:** Prompt mentions file paths AND total line count > 200
**Action:** Delegate to `gemini-large-context` subagent
**Detection method:**
1. Parse prompt for file paths (e.g., `src/auth.js`, `./config.json`)
2. Calculate total line count across all mentioned files
3. If total > 200 lines → delegate to Gemini (save Claude tokens)
4. If total ≤ 200 lines → Claude handles it (faster response)

**Example:**
```bash
User: "Analyze auth.js and database.js"
→ Detected files: auth.js (150 lines) + database.js (100 lines)
→ Total: 250 lines > 200 threshold
→ Action: Delegate to gemini-large-context (token optimization)
```

#### Priority 3: Keyword-Based Triggers (Existing)
**Triggers:** Keywords like "entire codebase", "all files", "scan", ">5 files"
**Action:** Delegate to `gemini-large-context` subagent

#### Priority 4: Default to Claude (Self-Execution)
**Triggers:** None of the above conditions met
**Action:** Claude handles directly (no delegation)
**Use cases:** Conceptual questions, small code changes, architecture discussions

**Example:**
```bash
User: "Explain the benefits of delegation"
→ No shell commands detected
→ No file paths mentioned
→ No large-scale keywords
→ Action: Claude responds directly (no delegation needed)
```

### Token Efficiency Benefits

The Router Agent intelligently saves Claude Pro tokens:

| Scenario | Old Behavior | New Behavior | Tokens Saved |
|----------|-------------|--------------|--------------|
| Large file analysis | Load 500+ line files | Delegate to Gemini | ~20K+ tokens |
| Shell commands | Claude executes | Delegate to Gemini | ~5K tokens |
| Small files (<200 lines) | Could delegate | Claude handles | 0 tokens (faster!) |
| Conceptual questions | Could delegate | Claude handles | 0 tokens (faster!) |

### Manual Testing Tool

Use the PowerShell helper to test routing decisions:

```powershell
# Test shell command detection
.\scripts\powershell\Invoke-SmartDelegation.ps1 -Prompt "git status"
# Output: gemini-shell-ops (Priority 1: detected `git`)

# Test file size analysis
.\scripts\powershell\Invoke-SmartDelegation.ps1 -Prompt "Analyze auth.js and db.js"
# Output: gemini-cli (Priority 2: if total > 200) or claude-self (if ≤ 200)

# Test default behavior
.\scripts\powershell\Invoke-SmartDelegation.ps1 -Prompt "Explain MVC pattern"
# Output: claude-self (Priority 4: no triggers matched)
```

### Customizing Thresholds

Edit the file size threshold in `.claude/CLAUDE.md`:

```markdown
#### Priority 2: High-Token File Analysis (200+ lines)
# Change 200 to your preferred threshold (e.g., 300, 500)
```

Or use the PowerShell tool with custom threshold:

```powershell
Invoke-SmartDelegation.ps1 -Prompt "..." -FileThreshold 300
```

## Configuration Files

### Global Configuration (User-Level)

Location: `~/.claude/` (Linux/macOS) or `$env:USERPROFILE\.claude\` (Windows)
```text
~/.claude/
├── agents/
│ ├── gemini-large-context.md # Large-context subagent
│ └── gemini-shell-ops.md # Shell operations subagent
├── settings.json # Global settings
└── CLAUDE.md # Global instructions
```


### Project Configuration

Location: `<project-root>/.claude/` (any platform)
```text
<project-root>/.claude/
├── CLAUDE.md # Project routing rules and tech stack info
├── settings.json # Project permissions and environment settings
├── commands/
│   ├── docs-gen.md # Generate API documentation
│   └── test-all.md # Run full test suite with analysis
└── hooks/
    └── after_edit.sh # Auto-trigger on large changesets (Linux/macOS)
    └── after_edit.ps1 # Auto-trigger on large changesets (Windows)
```

## Usage Examples

### Example 1: Full Repository Analysis
```text
claude

Analyze the entire codebase for security vulnerabilities

```

**What happens:**
1. Claude detects "entire codebase" keyword
2. Spawns `gemini-large-context` subagent
3. Subagent calls Gemini CLI MCP: "Perform security audit of @./"
4. Gemini processes 1M tokens across all files
5. Claude synthesizes findings into prioritized list

### Example 2: Test Suite Analysis
```text
Run all tests and analyze any failures

```

**What happens:**
1. Claude detects command execution + analysis
2. Spawns `gemini-shell-ops` subagent
3. Subagent calls Gemini CLI MCP: "Execute 'npm test' and analyze output"
4. Gemini runs tests, captures 5K lines of output
5. Claude presents root causes and fixes

### Example 3: Multi-File Refactoring
```text
Refactor authentication logic across all modules to use JWT

```

**What happens:**
1. Claude detects "across all modules"
2. Spawns `gemini-large-context` subagent
3. Subagent calls Gemini CLI with @./src/ context
4. Gemini analyzes 50+ files, proposes changes
5. Claude creates focused file-by-file implementation plan

### Example 4: Git History Summary
```text
Create release notes from the last 100 commits

```

**What happens:**
1. Claude detects Git operation
2. Spawns `gemini-shell-ops` subagent
3. Subagent calls Gemini CLI: "Execute 'git log -100' and categorize changes"
4. Gemini groups commits by type
5. Claude formats release notes

## Customization

### Adjust Delegation Thresholds

Edit `~/.claude/agents/gemini-large-context.md` (user-level config):
```text
description: MUST BE USED PROACTIVELY when: analyzing 15+ files, processing logs >2K lines...

```

Change thresholds to match your workflow.

### Add Custom Commands

Edit `<project>/.claude/settings.json` (project-level config) to add custom permissions and environment variables. See `examples/project-config/.claude/settings.json` for a complete example with:
- Auto-approved commands
- Commands requiring confirmation
- Denied operations
- Environment variables

## Token Savings Calculator

Based on typical usage patterns:

| Task | Claude Tokens | Gemini Tokens | Savings |
|------|---------------|---------------|---------|
| Full repo audit (500 files) | 150K | 800K | 100% (would exceed cap) |
| Test log analysis (3K lines) | 12K | 15K | 12K saved |
| Git history (100 commits) | 8K | 10K | 8K saved |
| Multi-file refactor (20 files) | 45K | 200K | 45K saved |

**Monthly savings:** ~500K tokens → extends Claude Pro by 10-15x for repo-wide tasks.

## Troubleshooting

### MCP server not showing up

Verify MCP installation
```text
claude mcp list
```
Reinstall if missing
```text
claude mcp remove gemini-cli
claude mcp add-json --scope=user gemini-cli '{
"type": "stdio",
"command": "npx",
"args": ["-y", "mcp-gemini-cli"]
}'

```

### Subagents not triggering automatically

Check subagent descriptions have strong keywords:
- "MUST BE USED"
- "PROACTIVELY"
- "AUTOMATICALLY"

Edit `~/.claude/agents/<agent-name>.md` (user-level) and strengthen the `description` field.

## Files in This Repository

```text
.
├── README.md # This file
├── docs/
│ ├── architecture.md # Detailed architecture
│ ├── delegation-rules.md # How Claude decides when to delegate
│ └── troubleshooting.md # Extended troubleshooting guide
├── examples/
│ ├── project-config/
│ │ └── .claude/
│ │ ├── CLAUDE.md # Example project config
│ │ ├── settings.json # Example permissions and env
│ │ ├── commands/
│ │ │ ├── docs-gen.md # Custom slash command
│ │ │ └── test-all.md # Custom slash command
│ │ └── hooks/
│ │     └── after_edit.sh # Example hook
│ ├── subagents/
│ │ ├── gemini-large-context.md # Large-context subagent template
│ │ └── gemini-shell-ops.md # Shell operations subagent template
│ └── vscode/
│ └── tasks.json # VS Code task examples
├── scripts/
│ ├── bash/ # Linux/macOS scripts (kebab-case naming)
│ │ ├── install-subagents.sh # One-command subagent installation
│ │ ├── test-delegation.sh # Test autonomous delegation
│ │ └── uninstall.sh # Clean removal
│ └── powershell/ # Windows scripts (PascalCase naming)
│   ├── Install-Subagents.ps1 # One-command subagent installation
│   ├── Test-Delegation.ps1 # Test autonomous delegation
│   └── Uninstall.ps1 # Clean removal
└── LICENSE # MIT License
```

**Note:** Script naming conventions follow platform standards:
- Bash scripts use kebab-case (Unix/Linux convention)
- PowerShell scripts use PascalCase with approved verbs (Microsoft convention)

## Contributing

Contributions welcome! Areas for improvement:
- Additional subagent templates (database, API testing, deployment)
- Language-specific examples (Python, Go, Rust)
- CI/CD integration patterns
- Token usage analytics scripts

## Credits

- [Gemini CLI](https://github.com/google-gemini/gemini-cli) by Google
- [MCP Gemini CLI Server](https://github.com/DiversioTeam/gemini-cli-mcp) by DiversioTeam
- [Claude Code](https://claude.ai/code) by Anthropic
- [Model Context Protocol (MCP)](https://modelcontextprotocol.io/)

## License

MIT License - See LICENSE file

## Support

- **Issues:** [GitHub Issues](https://github.com/carlosduplar/claude-gemini-delegation/issues)
- **Discussions:** [GitHub Discussions](https://github.com/carlosduplar/claude-gemini-delegation/discussions)

---

**Last Updated:** October 8, 2025