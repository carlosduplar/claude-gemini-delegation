# Claude Code + Gemini CLI Delegation

Automatically delegate high-token tasks from Claude Code to Gemini CLI, optimizing token usage across both AI assistants.

**Problem:** Claude Pro caps at ~19K tokens/5h. Power users hit limits during repo-wide analysis, multi-file operations, or shell automation.

**Solution:** Claude Code autonomously routes these tasks to Gemini CLI (1M tokens/day free tier).

## Quick Start

1. **Install/Update CLIs**
```bash
npm install -g @google/gemini-cli @anthropic-ai/claude-code
```

2. **Install delegation rules**

Copy `.claude/CLAUDE.md` to your project or home directory:

```bash
# Project-specific (recommended for teams)
cp .claude/CLAUDE.md /path/to/your/project/.claude/

# User-wide (applies to all projects)
cp .claude/CLAUDE.md ~/.claude/
```

3. **Test it**
```bash
cd /path/to/your/project && claude
# Ask: "Analyze the entire repository for performance issues"
# Claude will delegate to Gemini CLI automatically
```

## How It Works

Claude delegates based on 4 simple rules:

1. **Git/Shell/Build commands** → Gemini Flash with shell access
2. **Multi-file operations** → Gemini Flash with file reading tools
3. **Web search** → Gemini Flash with search tools
4. **Security/Architecture audits** → Gemini Pro for deep analysis

Everything else (code edits, generation, simple questions) Claude handles directly.

**Command Format:**
```bash
gemini "task" -m gemini-flash-latest -o json [flags]
```

**Model Selection:**
- `gemini-flash-latest` - Fast, higher rate limits (15 req/min, 1500/day)
- `gemini-pro-latest` - Deep analysis (2 req/min, 50/day)

**Quota Management:**
- Use Flash by default for routine operations
- Reserve Pro for security audits and architecture reviews
- When Pro quota exhausted, use Flash with step-by-step prompts (Chain-of-Thought)

## Configuration

`.claude/CLAUDE.md` contains 4 delegation rules. Each rule specifies:
- When to delegate (task type)
- Which Gemini model to use
- Which tools/flags to enable

The file is loaded into Claude's context on every request, so keep it minimal.

## Platform Notes

**Windows:** Shell tools require `-y` flag for unrestricted access
```bash
gemini "task" -m gemini-flash-latest -y -o json
```

**macOS/Linux:** Can use granular `--allowed-tools` or `-y` flag
```bash
gemini "task" -m gemini-flash-latest --allowed-tools=ReadFile,SearchText -o json
```

## Security

The delegation command includes "Refuse destructive operations" in the prompt:
```bash
gemini "[task]. Refuse destructive operations." -m gemini-flash-latest -y -o json
```

This tells Gemini to reject commands like `rm -rf`, `git clean -fd`, etc.

## Testing

Run regression tests to validate delegation accuracy:

```bash
./tests/regression/run_tests.sh
```

**Latest Results:** 100% pass rate (7/7 tests)

See detailed results: [tests/regression/TEST_RESULTS.md](tests/regression/TEST_RESULTS.md)

## Why CLI over MCP?

- **Lower latency:** No protocol serialization overhead
- **Native to Claude Code:** Leverages built-in shell tool
- **Simpler debugging:** Commands visible in logs, no server process
- **Token efficient:** CLI output can be filtered

## Maintaining Instruction Adherence

Claude may occasionally deviate from CLAUDE.md instructions in long conversations. Best practices:

1. **Clear context regularly** - Use `/clear` command to reset
2. **Compress context** - Use `/condense` to summarize
3. **Start fresh** - If Claude ignores rules, clear and restart

## Examples

**Multi-file analysis:**
```
You: "Find all TODOs across the codebase and categorize by priority"
Claude: [Delegates to Gemini Flash with FindFiles,SearchText tools]
```

**Security audit:**
```
You: "Perform a security audit on authentication module"
Claude: [Delegates to Gemini Pro for deep analysis]
```

**Code generation:**
```
You: "Write a function to parse JSON"
Claude: [Handles directly, no delegation]
```

**Git operations:**
```
You: "Show me recent commits and current branch status"
Claude: [Delegates to Gemini Flash with shell access]
```

## License

MIT License - See [LICENSE](LICENSE) file

## Support

- [Issues](https://github.com/carlosduplar/claude-gemini-delegation/issues)
- [Discussions](https://github.com/carlosduplar/claude-gemini-delegation/discussions)

---

**Last Updated:** October 20, 2025
