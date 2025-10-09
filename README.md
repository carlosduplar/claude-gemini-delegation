# Claude Code + Gemini CLI Delegation

Automatically delegate cross-file, repository-wide, and shell tasks from Claude Code to Gemini CLI, optimizing token usage across both AI assistants.

**Problem:** Claude Pro caps at ~44K tokens/5h. Power users hit limits during repo-wide analysis, multi-file operations, or shell automation.

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

Location: `<project-root>/.claude/CLAUDE.md`

This file tells Claude when to delegate to Gemini CLI. See `.claude/CLAUDE.md` in this repo for the template.

## Files in This Repository

```text
.
├── README.md           # This file
├── .claude/
│   └── CLAUDE.md       # Delegation rules template
└── LICENSE             # MIT License
```

## Key Features

- **Automatic Delegation:** Claude detects when to use Gemini based on configurable rules
- **Secure Tool Usage:** Use `--allowed-tools` for read-only operations or `-y` for shell commands
- **Structured Output:** All Gemini responses return JSON for easy parsing
- **Customizable Rules:** Edit `.claude/CLAUDE.md` to adjust delegation behavior
- **Model Optimization:** Intelligently routes simple tasks to gemini-flash-latest for speed and rate limit conservation

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
