# Troubleshooting Guide

## Installation Issues

### MCP server not found

**Symptom:**
```bash
claude mcp list
# gemini-cli not shown
```

**Solution:**

**Linux/macOS:**
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

**Windows (PowerShell):**
```powershell
# Remove existing configuration
claude mcp remove gemini-cli

# Reinstall
claude mcp add-json --scope=user gemini-cli '{"type":"stdio","command":"cmd","args":["/c","npx","-y","mcp-gemini-cli"]}'

# Verify
claude mcp list
```

### "spawn gemini ENOENT" error (Windows only)

**Symptom:**
```
Error: spawn gemini ENOENT
```
This occurs when the MCP server cannot find the `gemini` executable in its PATH.

**Root Cause:**
On Windows, the MCP server process doesn't automatically inherit the full system PATH, so it cannot locate the `gemini.cmd` executable installed by npm.

**Solution: Manual PATH configuration**

The `claude mcp add-json` command does not currently support the `env` field for PATH configuration. To manually add PATH configuration:

1. **Locate the npm global bin directory:**
   ```powershell
   npm config get prefix
   # Example output: C:\Users\<username>\AppData\Roaming\npm
   ```

2. **Edit the Claude Code configuration file:**
   ```powershell
   notepad "$env:USERPROFILE\.claude.json"
   ```

3. **Find the `"gemini-cli"` MCP server configuration** and add the `env` field with PATH:
   ```json
   "gemini-cli": {
     "type": "stdio",
     "command": "cmd",
     "args": ["/c", "npx", "-y", "mcp-gemini-cli"],
     "env": {
       "PATH": "C:\\Users\\<username>\\AppData\\Roaming\\npm;C:\\Windows\\system32;..."
     }
   }
   ```
   **Note:** Replace `<username>` with your actual username and include the full system PATH (get it from `$env:PATH` in PowerShell).

4. **Save the file and restart Claude Code.**

**Verification:**
Test that gemini can be spawned by the subagent:
```text
claude
> Use gemini-shell-ops to run: gemini --version
```

If this works, the PATH issue is resolved.

**Alternative Solution 3: Ensure npm is in system PATH**

Add npm global bin directory to your system PATH permanently:
1. Press Win + R, type `sysdm.cpl`, press Enter
2. Go to "Advanced" tab → "Environment Variables"
3. Under "User variables", select "Path" → "Edit"
4. Add: `C:\Users\<username>\AppData\Roaming\npm`
5. Click OK on all dialogs
6. Restart Claude Code

This ensures all processes can find `gemini.cmd`.

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

# If missing, manually copy from repository
cp examples/subagents/gemini-large-context.md ~/.claude/agents/
cp examples/subagents/gemini-shell-ops.md ~/.claude/agents/
```

**Windows (PowerShell):**
```powershell
# Check if files exist
Get-ChildItem "$env:USERPROFILE\.claude\agents\"

# If missing, manually copy from repository
Copy-Item examples\subagents\gemini-large-context.md "$env:USERPROFILE\.claude\agents\"
Copy-Item examples\subagents\gemini-shell-ops.md "$env:USERPROFILE\.claude\agents\"
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

**Solution 1: Verify subagent files exist**

Check that files exist in `~/.claude/agents/`:
```bash
ls -la ~/.claude/agents/
# Should show: gemini-large-context.md, gemini-shell-ops.md
```

If missing, copy from the repository:
```bash
cp examples/subagents/*.md ~/.claude/agents/
```

**Solution 2: Add project routing rules**

Create or edit `.claude/CLAUDE.md` in your project root:
```markdown
## When to Use Gemini CLI

You MUST use `gemini -p` shell command (via Bash tool) when:
- Analyzing entire codebases or large directories
- Comparing multiple large files (>200 lines total)
- User explicitly requests "analyze all files", "scan codebase", "audit project"
```

**Solution 3: Use explicit commands**

Force delegation explicitly:
```
claude
> Use gemini-large-context to analyze the repository
```

### Wrong subagent triggered

**Symptom:**
Wrong subagent is being used for the task.

**Solution:**

Be more explicit in your request or specify the subagent:
```
"Use gemini-large-context to analyze the code"
"Use gemini-shell-ops to run git status"
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

Create a fresh test project manually to isolate the issue:
```bash
cd /tmp
mkdir test-delegation && cd test-delegation
cp -r /path/to/claude-gemini-delegation/examples/project-config/.claude .
```

3. **Report issue:**
- GitHub Issues: https://github.com/carlosduplar/claude-gemini-delegation/issues
- Include: OS, Claude version, Gemini CLI version, error logs