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

## Architecture
```text
┌─────────────────────────────────────────┐
│ Claude Code                              │
│ - Analyzes task requirements            │
│ - Delegates large-scale operations      │
└────────┬────────────────────────────────┘
         │
         │ Delegates when:
         │ - Files >200 lines total
         │ - Entire codebase analysis
         │ - Shell operations needed
         │
         ▼
┌──────────────────────────────────────────┐
│ Gemini CLI (via MCP)                     │
│ - 1M token context window (free)         │
│ - Large file analysis                    │
│ - Repository-wide operations             │
│ - Shell command execution                │
└──────────────────────────────────────────┘
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

**For Windows (PowerShell):**
```powershell
claude mcp add-json --scope=user gemini-cli '{"type":"stdio","command":"cmd","args":["/c","npx","-y","mcp-gemini-cli"]}'
```
**Note:** Windows requires the `cmd /c` wrapper to execute npx commands properly. If you encounter `spawn gemini ENOENT` errors, see [Troubleshooting: spawn gemini ENOENT](docs/troubleshooting.md#spawn-gemini-enoent-error-windows-only).

Verify connection:

```text
claude

/mcp
```
Should show gemini-cli listed


### Step 4: Install subagents

Create the subagents directory:

**Linux/macOS:**
```bash
mkdir -p ~/.claude/agents
```

**Windows (PowerShell):**
```powershell
New-Item -ItemType Directory -Path "$env:USERPROFILE\.claude\agents" -Force
```

Copy subagent templates:

**Linux/macOS:**
```bash
cp examples/subagents/gemini-large-context.md ~/.claude/agents/
cp examples/subagents/gemini-shell-ops.md ~/.claude/agents/
```

**Windows (PowerShell):**
```powershell
Copy-Item examples\subagents\gemini-large-context.md $env:USERPROFILE\.claude\agents\
Copy-Item examples\subagents\gemini-shell-ops.md $env:USERPROFILE\.claude\agents\
```

This creates two subagents:
- `gemini-large-context` - For large file analysis and repository-wide operations
- `gemini-shell-ops` - For shell commands (Git, npm, build tools)

### Step 5: Configure your project

Copy configuration templates to your project:

**Linux/macOS:**
```bash
cp -r examples/project-config/.claude /path/to/your/project/
```

**Windows (PowerShell):**
```powershell
Copy-Item -Recurse examples\project-config\.claude \path\to\your\project\
```

Edit `/path/to/your/project/.claude/CLAUDE.md` with your project-specific build commands and tech stack details.

### Step 6: Test autonomous delegation
```text
cd /path/to/your/project
claude

Analyze the entire repository for performance bottlenecks
```

Claude should detect "entire repository" keyword → delegate to Gemini CLI via subagent → return analysis.

**Note:** All commands in Quick Start should be run from the repository root directory.

## When Claude Delegates to Gemini

Claude automatically uses Gemini CLI when:

1. **Large Files** - Total file size exceeds 200 lines
2. **Entire Codebase** - Keywords like "analyze all files", "entire codebase", "scan repository"
3. **Shell Operations** - Git commands, npm commands, build scripts

**Example:**
```bash
User: "Analyze auth.js and database.js"
→ auth.js (150 lines) + database.js (100 lines) = 250 lines
→ 250 > 200 threshold → Delegates to Gemini CLI
```

### Token Savings

| Task | Without Gemini | With Gemini | Tokens Saved |
|------|----------------|-------------|--------------|
| Large file analysis (500+ lines) | Would exceed Claude limit | Uses Gemini free tier | 20K+ tokens |
| Full repo audit (500 files) | Impossible | Uses Gemini free tier | 150K+ tokens |
| Shell commands | Uses Claude tokens | Uses Gemini free tier | 5K tokens |

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

Claude detects "entire codebase" → delegates to Gemini CLI → returns security findings

### Example 2: Test Suite Analysis
```text
Run all tests and analyze any failures
```

Claude detects test command → delegates to Gemini CLI → analyzes output and suggests fixes

### Example 3: Multi-File Refactoring
```text
Refactor authentication logic across all modules to use JWT
```

Claude detects "across all modules" → delegates large-scale analysis to Gemini CLI → creates implementation plan

### Example 4: Git History Summary
```text
Create release notes from the last 100 commits
```

Claude detects Git operation → delegates to Gemini CLI → formats release notes

## Customization

### Adjust Delegation Thresholds

Edit `.claude/CLAUDE.md` in your project to change the 200-line threshold:
```markdown
## When to Use Gemini CLI

You MUST use `gemini -p` shell command (via Bash tool) when:
- Comparing multiple large files (>300 lines total)  # Changed from 200
```

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

**Linux/macOS:**
```text
claude mcp remove gemini-cli
claude mcp add-json --scope=user gemini-cli '{
"type": "stdio",
"command": "npx",
"args": ["-y", "mcp-gemini-cli"]
}'
```

**Windows (PowerShell):**
```powershell
claude mcp remove gemini-cli
claude mcp add-json --scope=user gemini-cli '{"type":"stdio","command":"cmd","args":["/c","npx","-y","mcp-gemini-cli"]}'
```

If you encounter `spawn gemini ENOENT` errors after reinstalling, see [Troubleshooting: spawn gemini ENOENT](docs/troubleshooting.md#spawn-gemini-enoent-error-windows-only).

### Subagents not triggering automatically

Verify the subagent files exist in `~/.claude/agents/`:
- `gemini-large-context.md`
- `gemini-shell-ops.md`

If missing, copy them from `examples/subagents/` directory.

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
└── LICENSE # MIT License
```

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