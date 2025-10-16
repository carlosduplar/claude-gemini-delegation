# Claude Code + Gemini CLI Delegation

Automatically delegate high-token tasks from Claude Code to Gemini CLI, optimizing token usage across both AI assistants.

**Problem:** Claude Pro caps at ~19K tokens/5h. Power users hit limits during repo-wide analysis, multi-file operations, or shell automation.

**Solution:** Claude Code autonomously routes these tasks to Gemini CLI (1M tokens/day free tier).

## Key Features

- Automatic delegation based on task analysis
- 10 to 60% Claude Code token reduction, depending on workflow complexity
- Security guardrails prevent accidental destruction in automation
- Structured JSON responses for easy parsing
- Model optimization in Gemini (Flash for speed, Pro for depth) avoiding rate limits as well
- Fully customizable rules and tool permissions

## Why CLI over MCP?

This project uses direct Gemini CLI invocations rather than wrapping them in an MCP server:

- **Lower latency**: No protocol serialization overhead between Claude and the CLI
- **Native to Claude Code**: Leverages built-in shell tool; MCP is designed for non-CLI clients
- **Token efficiency**: CLI output can be filtered; bypasses repetitive security checks
- **Simpler debugging**: Commands visible in logs, no server process management

## Prerequisites

- **Node.js**: Version 18 or higher - [nodejs.org](https://nodejs.org/en/download)

## Quick Start

1. **Install/update both CLIs**
```bash
npm install -g @google/gemini-cli @anthropic-ai/claude-code
```

2. **Copy configuration files**

**Project-specific** (recommended for teams):
```bash
cp -r .claude .gemini /path/to/your/project/
```

**User-wide** (applies to all projects):
```bash
cp .claude/CLAUDE.md ~/.claude/
cp -r .gemini ~/
```

3. **Test delegation**
```bash
cd /path/to/your/project && claude
# Ask: "Analyze the entire repository for performance issues"
# Claude will delegate to Gemini CLI automatically
```

## How It Works

Claude delegates when tasks involve:

1. **Multi-file operations** - Understanding or modifying code across multiple files
2. **Repository-wide analysis** - Audits, scans, architecture reviews
3. **Shell operations** - Git, npm, builds, any command execution
4. **Internet access** - Documentation lookups, web searches

**Command Format:**
```bash
export REFERRAL=claude && gemini "task" -m gemini-flash-latest -o json --allowed-tools=...
```

**Examples:**
- "Audit codebase for security" → Uses `read_many_files,search_file_content,glob`
- "Run tests and explain failures" → Uses `run_shell_command`
- "What are the latest Node.js features?" → Uses `google_web_search,web_fetch`

**Model Selection:**
- `gemini-flash-latest` - Fast, higher rate limits (git, npm, file summaries, searches)
- `gemini-2.5-pro` - Deep analysis (security audits, architecture reviews, complex reasoning)

**Flow:**
```
User Request → Claude analyzes → Single-file/code gen? → Claude handles
                               → Multi-file/shell/web? → Gemini executes → Claude synthesizes
```

## Configuration

Three files control behavior:

**`.claude/CLAUDE.md`** - Delegation rules for Claude Code
- Defines when to delegate (multi-file, git, shell, web, audits)
- Specifies tool permissions per task type
- Model selection logic (Flash vs Pro)

**`.gemini/GEMINI.md`** - Brief security reminder for Gemini
- Enforces JSON output in non-interactive mode
- High-level allow/deny/confirm rules

**`.gemini/settings.json`** - Detailed guardrail configuration
- Auto-executes safe commands (git status, npm install, read-only tools)
- Auto-blocks destructive commands (rm -rf, git clean -fd, sudo)
- Prompts for confirmation on risky operations (git reset --hard, npm uninstall)

## Security Guardrails

When Claude invokes Gemini (via `REFERRAL=claude`), guardrails automatically apply:

| Action | Commands | Behavior |
|--------|----------|----------|
| **ALLOW** | git status/add/commit/push (non-force), npm install/test/build, read-only operations (ls, cat, grep, ReadFile, SearchText) | Auto-execute |
| **DENY** | rm -rf, del /s, PowerShell Remove-Item -Recurse, git clean -fd, sudo, chmod -R 777, destructive pipes, .env/.ssh/credentials access | Auto-block with JSON error |
| **CONFIRM** | git reset --hard, git push --force, npm uninstall, operations affecting >10 files | Prompt user |

Guardrails only apply in non-interactive mode - users retain full control when running `gemini` directly.

**Customize:** Edit `.gemini/settings.json` to add custom allow/deny patterns for your workflow.

**Windows Note:** The documented Gemini shell tools (Shell, run_shell_command) does NOT work on Windows. For shell operations on Windows, use the `-y` flag instead of `--allowed-tools` to enable unrestricted shell access:
```bash
export REFERRAL=claude && gemini "task" -m gemini-flash-latest -y -o json
```

## Maintaining Instruction Adherence

Claude Code may (and will) occasionally deviate from CLAUDE.md instructions, especially in long conversations with large context. Best practices:

1. **Clear context regularly** - Use `/clear` command to reset conversation state
2. **Compress context** - Use `/condense` to summarize and reduce token usage
3. **Start fresh** - If Claude ignores rules repeatedly, clear context and restart

## License

MIT License - See [LICENSE](LICENSE) file

## Support

- [Issues](https://github.com/carlosduplar/claude-gemini-delegation/issues)
- [Discussions](https://github.com/carlosduplar/claude-gemini-delegation/discussions)

---

**Last Updated:** October 16, 2025
