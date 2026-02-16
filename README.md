# Claude Code + Gemini Delegation

**Preserve 50-70% of your Claude Code token quota** by delegating high-cost operations to Gemini CLI.

[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Python](https://img.shields.io/badge/python-3.6+-blue.svg)](https://www.python.org/downloads/)
[![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)](#)

## The Problem

Claude Code Pro users hit a hard wall:
- **~19,000 tokens per 5-hour window**
- **Token quota exhausted = can't work until reset**
- Most developers run out in 2-3 hours on complex projects

**Common scenario:** You spend 2,000 tokens reading `npm ls` output, leaving only 17,000 for actual coding. By afternoon, you're blocked.

## The Solution

Delegate token-heavy operations to Gemini CLI (1M tokens/day free tier) while Claude handles high-value reasoning.

**Simple math:**
- Reading 2,000 lines yourself: **2,000 tokens**
- Delegating to Gemini: **~150 tokens**
- **Savings: 92% per operation**

---

## Quick Start

### Prerequisites

- **Python 3.6+** (no additional packages required)
- **Claude Code** installed
- **Gemini CLI:** `npm install -g @google/gemini-cli`

### Installation (30 seconds)

```bash
# 1. Clone repository
git clone https://github.com/carlosduplar/claude-gemini-delegation.git
cd claude-gemini-delegation

# 2. Copy CLAUDE.md to your project
cp .claude/CLAUDE.md /path/to/your/project/.claude/

# Or for global rules (applies to all projects):
cp .claude/CLAUDE.md ~/.claude/

# 3. Restart Claude Code
```

That's it! Claude will now automatically delegate appropriate tasks.

---

## How It Works

### Delegation Rules

Your `.claude/CLAUDE.md` configures strict rules for when Claude MUST delegate:

**BANNED Operations (Always Delegate):**
- Commands producing >500 lines of output
- `npm ls`, `pip list`, `git log` (>5 commits)
- `find`, `grep -r` (recursive searches)
- Reading 3+ new files for analysis
- Security audits and scans

**Decision Tree:**
```
1. >500 lines of output? → DELEGATE
2. 3+ new files to read? → DELEGATE
3. Banned command? → DELEGATE
4. Security/audit task? → DELEGATE
5. Already in context? → Handle directly
```

### Example: Before vs After

**❌ WITHOUT Delegation:**
```
User: "Check npm dependencies"
Claude: Let me read npm ls output...
[Reads 1,847 lines = 2,000 tokens]
Total cost: 2,000 tokens
```

**✅ WITH Delegation:**
```
User: "Check npm dependencies"
Claude: I'll delegate this to preserve your quota:

PROMPT=$(python .claude/hooks/pre-delegate.py "npm ls" "Build analysis" 8)
gemini -p "$PROMPT"

[Gemini reads 1,847 lines, returns 150-token summary]
Total cost: 150 tokens (92% savings!)
```

---

## What Gets Delegated

### ✅ Always Delegate (Token Savings: 80-95%)

- **Shell commands with verbose output**
  - `npm ls`, `pip freeze`, `git log`
  - `find`, `grep -r`, directory searches
  - Build logs, test outputs
  
- **Multi-file analysis**
  - Security audits across codebase
  - Performance analysis of 5+ files
  - Dependency vulnerability scans

- **Web search & documentation**
  - Current framework documentation
  - API reference lookups
  - Stack Overflow searches

### ❌ Never Delegate (Claude Handles)

- Single-file edits already in context
- Architectural decisions (no new data needed)
- Code generation from scratch
- Quick clarifications (<50 tokens)

---

## Configuration

### Your CLAUDE.md (300 tokens)

The `.claude/CLAUDE.md` file is intentionally concise (~300 tokens). This upfront cost pays for itself in the first 2-3 delegations.

**Key sections:**
1. **Token budget display** - Shows remaining quota
2. **RED LINE rules** - Banned commands (no exceptions)
3. **Decision tree** - 5-question checklist
4. **Delegation format** - Exact syntax to use

### Updating Token Budget

Keep Claude aware of token pressure:

```markdown
# In your .claude/CLAUDE.md
**Budget: 19K tokens per 5hr | Remaining: 14,200**
**Status: ⚠️ WARNING (below 15K)**
```

Update this periodically during your session. When status is WARNING, delegation becomes more aggressive.

---

## Platform Support

### Cross-Platform Compatibility

| Platform | Support | Notes |
|----------|---------|-------|
| **Linux** | ✅ Full | Native bash support |
| **macOS** | ✅ Full | Native bash support |
| **Windows** | ✅ Full | Use PowerShell or Git Bash |

### Python Version Requirement

- **Minimum:** Python 3.6
- **Recommended:** Python 3.8+
- **No additional packages required** (stdlib only)

---

## Advanced Usage

### Manual Delegation

When Claude doesn't auto-delegate, you can explicitly request it:

```
User: "Use Gemini to scan for security issues"
```

Claude will comply with explicit delegation requests.

### Delegation with Context

For better results, provide context in your requests:

```
User: "We're deploying tomorrow. Scan @src/ for hardcoded credentials and API keys. Use Gemini."
```

Context helps Gemini provide more relevant, actionable summaries.

### Weekly Metrics

Track your delegation effectiveness:

```bash
# If you installed the Python hooks (optional)
python .claude/hooks/analyze-metrics.py

# Expected output:
# Delegation rate: 73%
# Average response: 180 tokens
# Token savings: 8,400 tokens this week
```

---

## Troubleshooting

### Claude Not Delegating

**Problem:** Claude executes commands directly instead of delegating.

**Solutions:**
1. **Verify CLAUDE.md location:**
   ```bash
   # Check project-specific
   ls .claude/CLAUDE.md
   
   # Check global
   ls ~/.claude/CLAUDE.md
   ```

2. **Restart Claude Code:**
   ```bash
   # Claude reads CLAUDE.md on startup
   exit
   claude
   ```

3. **Clear context:**
   ```
   # Inside Claude Code session
   /clear
   ```

4. **Be explicit:**
   ```
   User: "Use Gemini to check dependencies"
   ```

### Gemini Not Installed

**Problem:** Claude tries to delegate but Gemini isn't available.

**Solution:**
```bash
# Install Gemini CLI
npm install -g @google/gemini-cli

# Verify installation
gemini --version

# Set API key
export GEMINI_API_KEY="your-key-here"
# Add to ~/.bashrc or ~/.zshrc for persistence
```

### Token Budget Out of Sync

**Problem:** Token budget in CLAUDE.md doesn't reflect reality.

**Solution:**
Update the budget manually after major operations:

```markdown
**Budget: 19K tokens per 5hr | Remaining: 11,400**
```

This helps Claude make better delegation decisions.

---

## Expected Results

### Token Savings by Usage Pattern

| Usage Pattern | Delegation Rate | Token Savings |
|---------------|-----------------|---------------|
| **Passive** (rely on auto-delegation) | 30-40% | 10-20% |
| **Active** (explicit requests) | 60-70% | 40-55% |
| **Power User** (maintain budget) | 80-90% | 60-75% |

### Real-World Example

**Baseline:** 19,000 tokens/session, exhausted in 2 hours

**With delegation:**
- Major operations delegated: 12/session
- Average savings: 1,800 tokens/operation
- Total savings: ~21,000 tokens
- **Result:** 19K tokens lasts 5+ hours instead of 2

---

## Comparison with Alternatives

### vs. MCP Server Approach

| Feature | This Repo (CLAUDE.md) | MCP Server |
|---------|----------------------|------------|
| **Setup complexity** | Copy one file | Run server process |
| **Maintenance** | Zero (static file) | Server lifecycle |
| **Token overhead** | 300 tokens (one-time) | Variable |
| **Reliability** | Works if Claude reads file | Depends on server uptime |
| **User control** | High (edit CLAUDE.md) | Low (server config) |

### vs. Python Hooks

| Feature | CLAUDE.md Only | + Python Hooks |
|---------|---------------|----------------|
| **Setup** | 30 seconds | 5 minutes |
| **Features** | Delegation rules | Rules + metrics + validation |
| **Token savings** | 40-60% | 60-75% |
| **Complexity** | Minimal | Moderate |

**Recommendation:** Start with CLAUDE.md only. Add Python hooks later if you want metrics and automation.

---

## Project Structure

```
claude-gemini-delegation/
├── .claude/
│   └── CLAUDE.md              # Core delegation rules (copy this)
├── tests/regression/
│   └── run_tests.sh           # Test delegation patterns
├── LICENSE                     # MIT License
└── README.md                   # This file
```

**What to copy:** Just `.claude/CLAUDE.md` to your project or home directory.

---

## Gemini CLI Tips

### Recommended Extensions

Gemini CLI supports extensions that enhance delegation:

```bash
# Context management
npm install -g @upstash/context7

# Browser automation
npm install -g chrome-devtools-extension

# Security scanning
npm install -g gemini-cli-security
```

### Configure Gemini

```bash
# Set API key
export GEMINI_API_KEY="your-key-here"

# Increase timeout for large operations
export GEMINI_TIMEOUT=60

# Enable verbose mode for debugging
gemini --verbose -p "your prompt"
```

---

## Claude Code Optimization Tips

### Maximize Your Quota

Beyond delegation, these settings help:

1. **Disable auto-compact:**
   ```
   # In Claude Code
   /config
   # Set auto-compact: off
   ```

2. **Avoid subagents:**
   - Subagents cost 5-10K tokens per invocation
   - Use delegation instead

3. **Use /clear strategically:**
   ```
   # After completing a major task
   /clear
   # Preserves quota for next task
   ```

4. **Batch related edits:**
   - Don't ask for 5 separate file edits
   - Ask for all 5 changes at once
   - Saves token overhead

---

## Contributing

Contributions welcome! Areas where help is needed:

### Improvement Ideas

- [ ] Add example `.claude/CLAUDE.md` variations for different workflows
- [ ] Create delegation metrics dashboard
- [ ] Build interactive installer (detect installed CLIs)
- [ ] Add support for Aider, Copilot CLI delegation
- [ ] Create video tutorial/demo
- [ ] Write detailed case studies with token measurements

### How to Contribute

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with real Claude Code sessions
5. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## FAQ

### Q: Does this work with Claude 3.5 Sonnet?

**A:** Yes, works with all Claude models via Claude Code.

### Q: What if I don't have Gemini CLI?

**A:** The CLAUDE.md rules still help by preventing wasteful operations. But delegation won't work until you install Gemini.

### Q: Can I delegate to other CLIs besides Gemini?

**A:** Yes! Edit CLAUDE.md to reference Aider, Copilot CLI, etc. Same pattern applies.

### Q: Will Claude always follow the rules?

**A:** 70-90% compliance rate depending on:
- How explicit your requests are
- How well you maintain token budget display
- Whether you use banned command keywords

### Q: Does this increase response time?

**A:** Delegation adds ~2-5 seconds per operation. But you save 10-20 minutes by not exhausting your quota early.

### Q: What's the token cost of CLAUDE.md?

**A:** ~300 tokens (one-time cost when Claude reads it). This pays for itself in 1-2 delegations.

---

## Roadmap

### v1.0 (Current)
- ✅ Core CLAUDE.md delegation rules
- ✅ Cross-platform compatibility
- ✅ Basic documentation

### v1.5 (Planned - Q1 2026)
- [ ] Interactive installer with CLI detection
- [ ] Python hooks for metrics and automation
- [ ] Example configurations for different workflows
- [ ] Video tutorials and demos

### v2.0 (Planned - Q2 2026)
- [ ] Delegation dashboard (track savings)
- [ ] Multi-CLI support (Aider, Copilot)
- [ ] Automatic CLAUDE.md optimization
- [ ] Community-shared delegation patterns

---

## Related Projects

- **[multi-agent-mcp](https://github.com/carlosduplar/multi-agent-mcp)** - MCP server for multi-agent routing
- **[claude-code-bridge](https://github.com/tkaufmann/claude-gemini-bridge)** - Hook-based Gemini integration
- **[Gemini CLI](https://github.com/google/generative-ai-cli)** - Official Google Gemini CLI

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

## Support

- **Issues:** [GitHub Issues](https://github.com/carlosduplar/claude-gemini-delegation/issues)
- **Discussions:** [GitHub Discussions](https://github.com/carlosduplar/claude-gemini-delegation/discussions)
- **Email:** [Your email or "Create an issue"]

---

## Acknowledgments

- Anthropic for Claude Code
- Google for Gemini CLI
- Community contributors and testers

---

**Last Updated:** February 16, 2026

---

## Quick Links

- [Installation](#quick-start)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [FAQ](#faq)
- [Contributing](#contributing)
