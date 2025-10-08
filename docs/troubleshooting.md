# Troubleshooting Guide

## Installation Issues

### MCP server not found

**Symptom:**
```bash
claude mcp list
# gemini-cli not shown
```

**Solution:**

**Linux/macOS & Windows (same commands):**
```bash
# Remove existing configuration
claude mcp remove gemini-cli

# Reinstall
claude mcp add-json --scope=user gemini-cli '{
"type": "stdio",
"command": "npx",
"args": ["-y", "mcp-gemini-cli"]
}'

# Verify
claude mcp list
```

### Subagents not appearing

**Symptom:**
```bash
claude
> /agents
# No subagents listed
```

**Solution:**

**Linux/macOS:**
```bash
# Check if files exist
ls -la ~/.claude/agents/

# If missing, reinstall
./scripts/bash/install-subagents.sh

# Or manually copy
cp examples/subagents/*.md ~/.claude/agents/
```

**Windows (PowerShell):**
```powershell
# Check if files exist
Get-ChildItem "$env:USERPROFILE\.claude\agents\"

# If missing, reinstall
.\scripts\powershell\Install-Subagents.ps1

# Or manually copy
Copy-Item examples\subagents\*.md "$env:USERPROFILE\.claude\agents\"
```

### Gemini CLI authentication failed

**Symptom:**
```bash
gemini
Error: Not authenticated
```

**Solution:**

**Linux/macOS & Windows (same commands):**
```bash
gemini
# Select: OAuth - Personal Google Account
# Follow browser authentication flow
# Grant required permissions
```

## Delegation Issues

### Subagents not triggering automatically

**Symptom:**
Claude processes requests directly without delegating.

**Diagnosis:**

**Linux/macOS:**
```bash
# Check subagent description strength
cat ~/.claude/agents/gemini-large-context.md | head -5
```

**Windows (PowerShell):**
```powershell
# Check subagent description strength
Get-Content "$env:USERPROFILE\.claude\agents\gemini-large-context.md" | Select-Object -First 5
```

**Solution 1: Strengthen description**

Edit `~/.claude/agents/gemini-large-context.md` (user-level):
```markdown
***
description: MUST BE USED PROACTIVELY and AUTOMATICALLY when analyzing 15+ files, processing logs >2K lines, full-repo operations. CRITICAL - Always delegate before main agent attempts large operations.
***
```

**Solution 2: Add project routing rules**

**Linux/macOS:**
```bash
# Create .claude/CLAUDE.md in project root
cat > .claude/CLAUDE.md << 'RULEEOF'
## Automatic Task Routing

### Route to gemini-large-context subagent
When user requests involve:
- "entire codebase" or "all files"
- Documentation generation
- Large log analysis
- Multi-file refactoring
RULEEOF
```

**Windows (PowerShell):**
```powershell
# Create .claude/CLAUDE.md in project root
@"
## Automatic Task Routing

### Route to gemini-large-context subagent
When user requests involve:
- "entire codebase" or "all files"
- Documentation generation
- Large log analysis
- Multi-file refactoring
"@ | Out-File -FilePath ".claude\CLAUDE.md" -Encoding utf8
```

**Solution 3: Use explicit commands**

**Linux/macOS & Windows (same):**
```bash
claude
> Use gemini-large-context to analyze the repository
```

### Wrong subagent triggered

**Symptom:**
`gemini-shell-ops` triggered for analysis task (or vice versa).

**Solution:**

Add disambiguation in `<project>/.claude/CLAUDE.md` (project-level):
```markdown
## Route to gemini-large-context (NOT shell-ops)
- Code analysis
- Documentation generation
- Pattern detection

## Route to gemini-shell-ops (NOT large-context)
- Git operations
- npm commands
- Shell scripts
```

## Gemini CLI Issues

### Rate limit exceeded

**Symptom:**
```bash
Error: Rate limit exceeded (1000 requests/day)
```

**Solution 1: Check usage**

**Linux/macOS & Windows (same):**
```bash
gemini
> /stats
```

**Solution 2: Optimize delegation**
Reduce unnecessary subagent calls by strengthening exclusion rules.

### Context too large (>1M tokens)

**Symptom:**
```bash
Error: Context length exceeds 1,000,000 tokens
```

**Solution:**

Break down the request:
```bash
# Instead of:
> Analyze the entire monorepo (1.5M tokens)

# Do:
> Analyze ./src directory
> Analyze ./services directory
> Summarize findings
```

### Connection timeout

**Symptom:**
```bash
Error: Request timeout after 30s
```

**Solution 1: Check network**

**Linux/macOS & Windows:**
```bash
ping api.gemini.google.com
```

**Solution 2: Retry with smaller scope**

```bash
# Instead of:
> Process this 10MB log file

# Do:
> Process first 5000 lines of this log file
```

## Configuration Issues

### .claude/CLAUDE.md not being read

**Symptom:**
Routing rules not applied.

**Verification:**

**Linux/macOS:**
```bash
# Check file location
ls -la .claude/CLAUDE.md

# Check permissions
chmod 644 .claude/CLAUDE.md
```

**Windows (PowerShell):**
```powershell
# Check file location
Get-Item .claude\CLAUDE.md

# Check file attributes
Get-ItemProperty .claude\CLAUDE.md
```

**Solution:**

Ensure file is in project root (not `~/.claude/` or `$env:USERPROFILE\.claude\`):
```
your-project/
└── .claude/
    ├── CLAUDE.md           ← Must be here (project-level)
    ├── settings.json       ← Permissions and environment
    └── hooks/
        ├── after_edit.sh   ← Linux/macOS hook
        └── after_edit.ps1  ← Windows hook
```

### Settings not applied

**Symptom:**
Commands requiring approval are being auto-executed (or vice versa).

**Solution:**

Check `<project>/.claude/settings.json` (project-level) exists and has proper structure:

**Linux/macOS:**
```bash
cat .claude/settings.json
```

**Windows (PowerShell):**
```powershell
Get-Content .claude\settings.json
```

Should contain:
```json
{
  "permissions": {
    "allow": [...],
    "ask": [...],
    "deny": [...]
  }
}
```

See `examples/project-config/.claude/settings.json` for complete example.

### Hooks not executing

**Symptom:**
`after_edit.sh` not running after file changes.

**Solution:**

**Linux/macOS:**
```bash
# Make executable
chmod +x .claude/hooks/after_edit.sh

# Test manually
./.claude/hooks/after_edit.sh
```

**Windows:**
Note: Windows hooks typically use `.ps1` or `.bat` files instead of `.sh`

## Getting Help

If issues persist:

1. **Check logs:**

**Linux/macOS:**
```bash
claude --debug > debug.log 2>&1
```

**Windows (PowerShell):**
```powershell
claude --debug > debug.log 2>&1
```

2. **Minimal reproduction:**

**Linux/macOS:**
```bash
# Create fresh test project
./scripts/bash/test-delegation.sh
```

**Windows (PowerShell):**
```powershell
# Create fresh test project
.\scripts\powershell\Test-Delegation.ps1
```

3. **Report issue:**
- GitHub Issues: https://github.com/carlosduplar/claude-gemini-delegation/issues
- Include: OS, Claude version, Gemini CLI version, error logs