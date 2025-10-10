# Gemini CLI Guardrail Configuration

## Mode Detection and Conditional Guardrails

This configuration applies security guardrails ONLY when Gemini is invoked by Claude Code in non-interactive mode. Interactive user sessions remain unrestricted.

### Invocation Context Detection

Gemini MUST detect the invocation mode and apply guardrails conditionally:

**Non-Interactive Mode (Apply Guardrails):**
- Environment variable `GEMINI_INVOKED_BY=claude` is set
- Standard input is a pipe (non-TTY)
- Invoked with `-p` flag (headless mode)

**Interactive Mode (No Guardrails):**
- TTY is present
- No special environment variables
- User manually confirms all operations

Detection logic:
```javascript
const isNonInteractive = process.env.GEMINI_INVOKED_BY === 'claude' || !process.stdin.isTTY;
```

## Security Guardrails (Non-Interactive Mode ONLY)

When operating in non-interactive mode, evaluate ALL shell commands against these rules BEFORE execution:

### DENY Commands (Abort Execution)

These commands MUST be blocked in non-interactive mode:

```json
{
  "action": "DENY",
  "patterns": [
    "rm -rf *",
    "rm -rf .",
    "rm -rf /",
    "rm -rf .git",
    "rmdir /s /q",
    "git clean -fd",
    "sudo rm",
    "sudo *",
    "| rm",
    "| del",
    "> /dev/sda",
    "mkfs.*",
    "format.*",
    "dd if=/dev/zero",
    ":(){ :|:& };:",
    "chmod -R 777 /",
    "chown -R"
  ],
  "reason": "Destructive operation prohibited in non-interactive mode"
}
```

Additional deny rules:
- Any command containing `rm -rf` followed by repository root paths
- Commands with pipes to destructive operations (e.g., `find | xargs rm`)
- Direct file writes to codebase using WriteFile tool (use Shell with safe editors instead)
- System-level destructive operations (partition formatting, mass permission changes)

### ALLOW Commands (Execute Without Prompt)

These commands are safe to execute in non-interactive mode:

```json
{
  "action": "ALLOW",
  "categories": {
    "git_safe": [
      "git status",
      "git add",
      "git commit",
      "git push",
      "git pull",
      "git fetch",
      "git log",
      "git diff",
      "git branch",
      "git checkout -b",
      "git merge",
      "git stash",
      "git show"
    ],
    "npm_safe": [
      "npm install",
      "npm run build",
      "npm run test",
      "npm run dev",
      "npm run start",
      "npm audit",
      "npm update",
      "npm list"
    ],
    "filesystem_safe": [
      "mkdir",
      "touch",
      "cp",
      "mv",
      "ls",
      "cat",
      "grep",
      "find",
      "cd",
      "pwd",
      "tree",
      "head",
      "tail"
    ],
    "read_only": [
      "ReadFile",
      "ReadFolder",
      "ReadManyFiles",
      "FindFiles",
      "SearchText",
      "GoogleSearch",
      "WebFetch"
    ]
  }
}
```

Execution criteria:
- Command matches allowed pattern exactly or is a subset (e.g., `git status` is allowed)
- File operations are scoped to project subdirectories (not root or system paths)
- No destructive flags present (e.g., `-f`, `--force` in dangerous contexts)

### PROMPT Commands (Require Confirmation)

These commands require explicit confirmation even in non-interactive mode:

```json
{
  "action": "PROMPT",
  "patterns": [
    "git reset --hard",
    "git revert",
    "git push --force",
    "npm uninstall",
    "rm -r",
    "operations affecting >10 files"
  ],
  "behavior": "Return command to Claude Code for user approval"
}
```

When PROMPT is triggered:
1. Return JSON response with `{"status": "requires_confirmation", "command": "...", "reason": "..."}`
2. Claude Code will ask user for approval
3. If approved, Claude Code will re-invoke Gemini with approval flag

## Command Evaluation Process

For EVERY Shell tool invocation in non-interactive mode, follow this process:

### Step 1: Parse Command
Extract the actual shell command from the request:
```javascript
const command = extractShellCommand(userPrompt);
```

### Step 2: Check Against DENY List
```javascript
for (const pattern of DENY_PATTERNS) {
  if (command.match(pattern)) {
    return {
      "status": "denied",
      "command": command,
      "reason": "Destructive operation prohibited in non-interactive mode",
      "suggestion": "This command requires interactive mode. Run 'gemini' without -p flag."
    };
  }
}
```

### Step 3: Check Against ALLOW List
```javascript
for (const pattern of ALLOW_PATTERNS) {
  if (command.match(pattern)) {
    // Execute safely
    return executeCommand(command);
  }
}
```

### Step 4: Check Against PROMPT List
```javascript
for (const pattern of PROMPT_PATTERNS) {
  if (command.match(pattern)) {
    return {
      "status": "requires_confirmation",
      "command": command,
      "reason": "Potentially destructive operation",
      "impact": describeImpact(command)
    };
  }
}
```

### Step 5: Default Behavior
If command doesn't match any list, apply conservative default:
```javascript
return {
  "status": "requires_confirmation",
  "command": command,
  "reason": "Unrecognized command pattern"
};
```

## JSON Response Format

All command evaluation results MUST be returned in this format:

### Success (ALLOW)
```json
{
  "status": "success",
  "command": "git status",
  "output": "On branch main\nnothing to commit, working tree clean",
  "mode": "non_interactive"
}
```

### Denied (DENY)
```json
{
  "status": "denied",
  "command": "rm -rf .git",
  "reason": "Destructive operation prohibited in non-interactive mode",
  "suggestion": "This command requires interactive mode with user confirmation",
  "mode": "non_interactive"
}
```

### Requires Confirmation (PROMPT)
```json
{
  "status": "requires_confirmation",
  "command": "git reset --hard HEAD~5",
  "reason": "Potentially destructive: will discard 5 commits",
  "impact": "Permanent loss of uncommitted changes and last 5 commits",
  "mode": "non_interactive"
}
```

## Mode-Specific Behavior Examples

### Example 1: Interactive Mode (No Guardrails)

User invocation:
```bash
gemini
> Run rm -rf node_modules && npm install
```

Behavior:
- Gemini displays warning about rm -rf operation
- User must manually confirm with "yes"
- Full control, no auto-denial
- Guardrails: DISABLED

### Example 2: Non-Interactive Mode (Guardrails Active)

Claude Code invocation:
```bash
export GEMINI_INVOKED_BY=claude
gemini -p "Clean and reinstall dependencies: rm -rf node_modules && npm install" -y -o json
```

Behavior:
- Gemini detects GEMINI_INVOKED_BY=claude
- Evaluates command against DENY list
- Matches "rm -rf" pattern
- Returns JSON denial without executing
- Guardrails: ENABLED

Expected output:
```json
{
  "status": "denied",
  "command": "rm -rf node_modules",
  "reason": "Destructive operation prohibited in non-interactive mode",
  "suggestion": "Use 'npm ci' instead, or run in interactive mode",
  "mode": "non_interactive"
}
```

### Example 3: Safe Git Operation

Claude Code invocation:
```bash
export GEMINI_INVOKED_BY=claude
gemini -p "Check git status and stage all files" -y -o json
```

Behavior:
- Gemini detects non-interactive mode
- Evaluates `git status && git add -A`
- Both commands in ALLOW list
- Executes safely without prompt
- Returns success JSON

Expected output:
```json
{
  "status": "success",
  "command": "git status && git add -A",
  "output": "On branch main\nChanges to be committed:\n  modified: README.md",
  "mode": "non_interactive"
}
```

### Example 4: Prompt for Confirmation

Claude Code invocation:
```bash
export GEMINI_INVOKED_BY=claude
gemini -p "Reset last commit: git reset --hard HEAD~1" -y -o json
```

Behavior:
- Gemini detects non-interactive mode
- Evaluates `git reset --hard HEAD~1`
- Matches PROMPT list
- Returns JSON requesting confirmation
- Does NOT execute

Expected output:
```json
{
  "status": "requires_confirmation",
  "command": "git reset --hard HEAD~1",
  "reason": "Potentially destructive: will discard last commit",
  "impact": "Permanent loss of commit and uncommitted changes",
  "mode": "non_interactive"
}
```

Claude Code will then ask the user:
```
Gemini requires confirmation for: git reset --hard HEAD~1
Reason: Potentially destructive - will discard last commit
Proceed? (y/n)
```

## Audit Logging

In non-interactive mode, log all command evaluations:

```json
{
  "timestamp": "2025-10-10T14:30:00Z",
  "mode": "non_interactive",
  "invoked_by": "claude",
  "command": "git push",
  "action": "allow",
  "executed": true,
  "exit_code": 0
}
```

Log file location: `~/.gemini/audit.log`

Log entries for DENY actions:
```json
{
  "timestamp": "2025-10-10T14:32:15Z",
  "mode": "non_interactive",
  "invoked_by": "claude",
  "command": "rm -rf .git",
  "action": "deny",
  "executed": false,
  "reason": "Destructive operation prohibited"
}
```

## File Write Operations

IMPORTANT: In non-interactive mode, direct file writes to the codebase using WriteFile tool are RESTRICTED.

### Denied Approach
```json
{
  "tool": "WriteFile",
  "path": "src/index.js",
  "content": "...",
  "status": "denied",
  "reason": "Direct file writes prohibited in non-interactive mode"
}
```

### Allowed Approach
Use Shell tool with safe editors or redirection:
```bash
# Safe: Using cat with heredoc (non-destructive, reviewable)
cat > src/temp_file.js << 'EOF'
console.log('safe content');
EOF
```

Rationale: Shell commands are auditable and can be reviewed in git history. Direct WriteFile bypasses command evaluation.

## Configuration Override

Users can override these settings by editing `~/.gemini/settings.json`:

```json
{
  "profiles": {
    "default_profile": {
      "guardrails_enabled": false
    },
    "non_interactive_profile": {
      "guardrails_enabled": true,
      "allow_list": [...],
      "deny_list": [...],
      "prompt_list": [...]
    }
  },
  "active_profile": "auto"
}
```

Profile selection logic:
- `auto`: Detect mode and select profile
- `default_profile`: Always use default (interactive)
- `non_interactive_profile`: Always use non-interactive

## Testing Guardrails

### Test 1: Verify Non-Interactive Denial
```bash
export GEMINI_INVOKED_BY=claude
gemini -p "Delete repository: rm -rf .git" -y -o json
```

Expected: JSON with `"status": "denied"`

### Test 2: Verify Interactive Bypass
```bash
unset GEMINI_INVOKED_BY
gemini
> rm -rf .git
```

Expected: User prompt for confirmation (no auto-denial)

### Test 3: Verify ALLOW List
```bash
export GEMINI_INVOKED_BY=claude
gemini -p "Show git status" -y -o json
```

Expected: JSON with `"status": "success"` and git status output

### Test 4: Verify PROMPT List
```bash
export GEMINI_INVOKED_BY=claude
gemini -p "Force push: git push --force" -y -o json
```

Expected: JSON with `"status": "requires_confirmation"`

### Test 5: Verify Audit Logging
```bash
export GEMINI_INVOKED_BY=claude
gemini -p "Run git status" -y -o json
cat ~/.gemini/audit.log | grep "git status"
```

Expected: Audit log entry with timestamp and action

## Summary

This configuration creates a dual-mode security system:

1. **Interactive Mode**: Full user control, manual confirmation for all operations
2. **Non-Interactive Mode**: Automated guardrails prevent destructive operations when Claude Code delegates tasks

Key principles:
- Security by default in automation
- Transparency through audit logging
- User autonomy in interactive sessions
- Clear, actionable JSON responses for programmatic consumers
