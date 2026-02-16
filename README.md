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

Delegate token-heavy operations to Gemini CLI (generous free tier) while Claude handles high-value reasoning.

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

# 2. Run interactive installer (recommended)
python setup.py

# The installer will:
# - Detect installed AI CLIs (Gemini, Aider, etc.)
# - Let you select which to enable
# - Install delegation hooks
# - Configure Claude Code settings
# - Copy CLAUDE.md to your project
```

**Or manual installation:**

```bash
# Copy CLAUDE.md only (minimal setup)
cp .claude/CLAUDE.md /path/to/your/project/.claude/

# Or for global rules (applies to all projects):
cp .claude/CLAUDE.md ~/.claude/
```

**Restart Claude Code after installation.**

---

## What Gets Installed

### Interactive Installer (`setup.py`)

The installer configures:

1. **CLAUDE.md** - Delegation rules (~300 tokens)
2. **Claude Code settings** - Optimized model and token behavior
3. **Delegation hooks** (optional) - Automated prompt formatting

**Settings configured in `.claude/settings.json`:**

```json
{
  "ANTHROPIC_MODEL": "opusplan"
}
```

See [Settings Explained](#settings-explained) for details on each setting.

### Optional: Delegation Hooks

If you want automated prompt formatting:

```bash
python setup_hooks.py

# Installs cross-platform hooks to .claude/hooks/:
# - pre-delegate.py (prompt formatter)
# - post-delegate.py (response validator)
# - analyze-metrics.py (usage analyzer)
```

**Note:** Hooks are optional. CLAUDE.md alone provides 50-70% token savings.

---

## Settings Explained

### ANTHROPIC_MODEL: "opusplan"

**What it does:** Special mode that uses opus during plan mode, then switches to sonnet for execution.

**Benefits:**
- ✅ Avoids having to switch manually between Opus and Sonnet
- ✅ Gives the best of both models (Opus for planning, Sonnet for coding)
- ✅ Maximizes token consumption on a balanced configuration yielding best results

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

## Configuration Options

### Option 1: Automated Setup (Recommended)

```bash
python setup.py

# Interactive installer:
# - Detects installed CLIs
# - Configures settings.json
# - Installs CLAUDE.md
# - Optional: delegation hooks
```

### Option 2: Manual Setup (Minimal)

```bash
# Just copy CLAUDE.md
cp .claude/CLAUDE.md ~/.claude/

# Manually add to .claude/settings.json:
{
  "ANTHROPIC_MODEL": "opusplan"
}

# Restart Claude Code
```

### Option 3: Hooks Only

```bash
# Install delegation hooks for automation
python setup_hooks.py

# Hooks provide:
# - Automatic prompt formatting
# - Response validation
# - Usage metrics tracking
```

---

## Platform Support

### Cross-Platform Compatibility

| Platform | Support | Notes |
|----------|---------|-------|
| **Linux** | ✅ Full | Native bash support |
| **macOS** | ✅ Full | Native bash support |
| **Windows** | ✅ Full | PowerShell & Git Bash supported |

### Python Version Requirement

- **Minimum:** Python 3.6
- **Recommended:** Python 3.8+
- **No additional packages required** (stdlib only)

---

## Advanced Usage

### Updating Token Budget

Keep Claude aware of token pressure by updating CLAUDE.md:

```markdown
# In your .claude/CLAUDE.md
**Budget: 19K tokens per 5hr | Remaining: 14,200**
**Status: ⚠️ WARNING (below 15K)**
```

Update this periodically during your session. When status is WARNING, delegation becomes more aggressive.

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

### Weekly Metrics (If Hooks Installed)

Track your delegation effectiveness:

```bash
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

### Settings Not Applied

**Problem:** settings.json changes don't take effect.

**Solution:**
```bash
# 1. Verify settings.json exists
cat .claude/settings.json

# 2. Completely restart Claude Code
# (not just /clear - full application restart)

# 3. Re-run setup if needed
python setup.py
```

---

## Expected Results

### Token Savings by Usage Pattern

| Usage Pattern | Delegation Rate | Token Savings |
|---------------|-----------------|---------------|
| **Passive** (rely on auto-delegation) | 30-40% | 10-20% |
| **Active** (explicit requests) | 60-70% | 40-55% |
| **Power User** (maintain budget + hooks) | 80-90% | 60-75% |

---

## Project Structure
claude-gemini-delegation/
├── .claude/
│   ├── CLAUDE.md              # Core delegation rules
│   └── settings.json.example  # Settings template
├── hooks/                      # Optional delegation hooks
│   ├── pre-delegate.py
│   ├── post-delegate.py
│   └── analyze-metrics.py
├── examples/                   # Example configurations
│   ├── minimal-CLAUDE.md
│   └── security-focused-CLAUDE.md
├── tests/regression/
│   └── run_tests.sh
├── setup.py                    # Interactive installer
├── setup_hooks.py              # Hooks installer
├── LICENSE
└── README.md

**Last Updated**: February 16, 2026
