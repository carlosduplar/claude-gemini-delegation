# Conditional Guardrails Implementation Notes

## Overview

This implementation provides conditional security guardrails for Gemini CLI that apply ONLY when invoked by Claude Code in non-interactive mode. Interactive user sessions remain unrestricted.

## Files Created/Modified

### 1. `.gemini/GEMINI.md`
**Purpose:** Instructions for Gemini CLI on how to apply guardrails based on invocation context

**Key Sections:**
- Mode detection logic (interactive vs non-interactive)
- DENY/ALLOW/PROMPT command lists with regex patterns
- Command evaluation process (step-by-step algorithm)
- JSON response format for all scenarios
- Mode-specific behavior examples
- Audit logging specification
- Testing procedures

**Important Details:**
- Guardrails activate when `GEMINI_INVOKED_BY=claude` environment variable is set
- Three command categories: DENY (abort), ALLOW (auto-execute), PROMPT (request confirmation)
- All operations logged to `~/.gemini/audit.log` in JSON format

### 2. `.gemini/settings.json`
**Purpose:** Profile-based configuration for Gemini CLI with dual operating modes

**Key Sections:**
- `default_profile`: No restrictions (interactive use)
- `non_interactive_profile`: Full guardrails (Claude Code delegation)
- Profile selection logic based on environment variables
- Detailed allow/deny/prompt lists with regex patterns
- Audit logging configuration
- JSON response schemas

**Important Details:**
- Profile auto-selected based on `GEMINI_INVOKED_BY` environment variable
- Regex patterns for command matching (e.g., `^git\\s+status`)
- File operation threshold (>10 files requires confirmation)
- WriteFile tool explicitly disabled in non-interactive mode

### 3. `.claude/CLAUDE.md` (Updated)
**Purpose:** Instructions for Claude Code on how to invoke Gemini with guardrails

**Key Changes:**
- Added `export GEMINI_INVOKED_BY=claude` before all Gemini invocations
- Updated all example commands to include environment variable
- Added "Guardrail Behavior" section explaining DENY/ALLOW/PROMPT categories
- Added instructions to check JSON response status field

**Important Details:**
- Claude MUST set environment variable BEFORE invoking Gemini
- Claude MUST parse JSON response and handle denied/requires_confirmation status
- Commands use `&&` to chain environment variable with Gemini invocation

### 4. `README.md` (Updated)
**Purpose:** User-facing documentation for the guardrail system

**Key Additions:**
- "Guardrail System" section in Configuration
- Two operating modes comparison (Interactive vs Non-Interactive)
- Security rules reference (ALLOW/DENY/PROMPT lists)
- Installation instructions for copying files to `~/.gemini/`
- Testing procedures with expected outputs
- "Guardrail Architecture" section with workflow examples
- Customization guide for adding custom patterns
- Audit log analysis examples

## Implementation Status

[OK] GEMINI.md created with conditional guardrail instructions
[OK] settings.json created with dual profiles
[OK] CLAUDE.md updated with environment variable instructions
[OK] README.md updated with guardrail documentation

## Testing Checklist

### Test 1: Non-Interactive Denial
```bash
export GEMINI_INVOKED_BY=claude
gemini -p "Delete repository: rm -rf .git" -y -o json
```
**Expected:** JSON response with `"status": "denied"`

### Test 2: Interactive Bypass
```bash
unset GEMINI_INVOKED_BY
gemini
> rm -rf .git
```
**Expected:** User prompt for confirmation (no auto-denial)

### Test 3: Non-Interactive Allow
```bash
export GEMINI_INVOKED_BY=claude
gemini -p "Show git status" -y -o json
```
**Expected:** JSON response with `"status": "success"` and git output

### Test 4: Non-Interactive Prompt
```bash
export GEMINI_INVOKED_BY=claude
gemini -p "Force push: git push --force" -y -o json
```
**Expected:** JSON response with `"status": "requires_confirmation"`

### Test 5: Audit Logging
```bash
export GEMINI_INVOKED_BY=claude
gemini -p "Run git status" -y -o json
cat ~/.gemini/audit.log | tail -1 | jq '.'
```
**Expected:** JSON log entry with timestamp, command, action, executed status

## Next Steps for Gemini CLI Integration

This implementation provides the **specification** for how Gemini CLI should implement guardrails. The actual implementation requires changes to the Gemini CLI codebase:

### Required Gemini CLI Changes:

1. **Environment Variable Detection**
   - Check `process.env.GEMINI_INVOKED_BY === 'claude'`
   - Check `!process.stdin.isTTY` for piped input
   - Select profile based on detection logic

2. **Command Evaluation Engine**
   - Parse shell commands from user prompts
   - Match against regex patterns in allow/deny/prompt lists
   - Return structured JSON responses for non-interactive mode

3. **Audit Logging**
   - Create `~/.gemini/audit.log` if not exists
   - Log all non-interactive operations in JSON format
   - Implement log rotation (10MB max, 5 files)

4. **Profile System**
   - Load settings from `~/.gemini/settings.json`
   - Support profile override via config or CLI flag
   - Apply rules only when non_interactive_profile active

5. **Response Formatting**
   - Return JSON with status field (success/denied/requires_confirmation)
   - Include reason and suggestion for denied commands
   - Include impact description for prompt commands

### Alternative: Wrapper Script Approach

If modifying Gemini CLI directly is not feasible, a wrapper script could implement guardrails:

```bash
#!/bin/bash
# gemini-guarded wrapper script

# Detect non-interactive mode
if [[ "$GEMINI_INVOKED_BY" == "claude" ]] || [[ ! -t 0 ]]; then
    # Apply guardrails by evaluating command before passing to Gemini
    # This requires parsing the prompt to extract shell commands
    # Then checking against allow/deny/prompt lists
    # Finally invoking real Gemini CLI if allowed

    # Pseudocode:
    # command=$(extract_shell_command "$@")
    # action=$(evaluate_command "$command")
    # if [[ "$action" == "deny" ]]; then
    #     echo '{"status":"denied",...}' | jq
    #     exit 1
    # elif [[ "$action" == "allow" ]]; then
    #     gemini "$@"  # Call real Gemini CLI
    # elif [[ "$action" == "prompt" ]]; then
    #     echo '{"status":"requires_confirmation",...}' | jq
    #     exit 2
    # fi
else
    # Interactive mode - pass through to real Gemini CLI
    gemini "$@"
fi
```

## Security Considerations

1. **Environment Variable Trust**
   - `GEMINI_INVOKED_BY=claude` can be set by any process
   - This is acceptable because:
     - Setting it intentionally means user wants guardrails
     - Not setting it preserves full control
     - Worst case: User gets more restrictions than expected (safe failure)

2. **Regex Pattern Security**
   - All deny patterns should be tested for bypass attempts
   - Consider edge cases: extra spaces, tabs, case sensitivity
   - Example bypass attempt: `rm   -rf  .git` (extra spaces)
   - Solution: Use `\\s+` instead of literal spaces in patterns

3. **Audit Log Privacy**
   - Logs may contain sensitive command arguments
   - Location: `~/.gemini/audit.log` (user-only readable)
   - Implement log rotation to prevent unlimited growth
   - Consider adding option to disable logging for privacy-sensitive environments

4. **Customization Risks**
   - Users editing settings.json could disable guardrails
   - This is acceptable because:
     - User has full control over their system
     - Editing config requires intentional action
     - Default config is secure

## Usage Examples for Claude Code

### Example 1: Safe Git Workflow
```bash
export GEMINI_INVOKED_BY=claude && gemini "Check status, stage changes, commit with message 'Update docs', and push" -m gemini-flash-latest -y -o json
```

**Gemini Response:**
```json
{
  "status": "success",
  "mode": "non_interactive",
  "output": "On branch main...\\nEverything up-to-date",
  "commands_executed": ["git status", "git add -A", "git commit -m 'Update docs'", "git push"]
}
```

### Example 2: Denied Destructive Operation
```bash
export GEMINI_INVOKED_BY=claude && gemini "Clean repository: rm -rf node_modules .git" -y -o json
```

**Gemini Response:**
```json
{
  "status": "denied",
  "mode": "non_interactive",
  "command": "rm -rf .git",
  "reason": "Repository deletion prohibited in non-interactive mode",
  "suggestion": "Use interactive mode (run 'gemini' without -p) for destructive operations"
}
```

### Example 3: Confirmation Required
```bash
export GEMINI_INVOKED_BY=claude && gemini "Reset to previous commit: git reset --hard HEAD~1" -y -o json
```

**Gemini Response:**
```json
{
  "status": "requires_confirmation",
  "mode": "non_interactive",
  "command": "git reset --hard HEAD~1",
  "reason": "Potentially destructive: will discard last commit",
  "impact": "Permanent loss of commit and uncommitted changes"
}
```

**Claude Code Should:**
1. Parse JSON response
2. Check status field
3. If "requires_confirmation", ask user: "Gemini requires confirmation for: git reset --hard HEAD~1. Proceed? (y/n)"
4. If user confirms, re-invoke with approval flag (if implemented)

## Maintenance

### Adding New Allow Patterns
Edit `~/.gemini/settings.json`:
```json
{
  "profiles": {
    "non_interactive_profile": {
      "command_rules": {
        "allow_list": [
          {
            "category": "docker_safe",
            "patterns": [
              "^docker ps",
              "^docker images",
              "^docker logs"
            ],
            "description": "Safe Docker read-only commands"
          }
        ]
      }
    }
  }
}
```

### Adding New Deny Patterns
```json
{
  "profiles": {
    "non_interactive_profile": {
      "command_rules": {
        "deny_list": [
          {
            "pattern": "^npm\\s+publish",
            "description": "Block npm publish in automation",
            "message": "Package publishing requires manual review"
          }
        ]
      }
    }
  }
}
```

## Troubleshooting

### Guardrails Not Activating
- Check if `GEMINI_INVOKED_BY=claude` is set: `echo $GEMINI_INVOKED_BY`
- Verify settings.json exists: `ls -la ~/.gemini/settings.json`
- Check profile selection logic in settings.json
- Review Gemini CLI logs for mode detection

### Commands Incorrectly Denied
- Check regex pattern in deny_list
- Test pattern with command: `echo "git status" | grep -E "^git\\s+status"`
- Move pattern from deny_list to allow_list or prompt_list
- Consider adding to allow_list with more specific pattern

### Audit Log Not Creating
- Check directory permissions: `ls -la ~/.gemini/`
- Create directory manually: `mkdir -p ~/.gemini && touch ~/.gemini/audit.log`
- Verify Gemini CLI has write permissions
- Check audit.enabled setting in settings.json

## Version History

- **v1.0.0** (2025-10-10): Initial implementation
  - Created GEMINI.md with conditional guardrail instructions
  - Created settings.json with dual profiles
  - Updated CLAUDE.md with environment variable usage
  - Updated README.md with comprehensive documentation

## Future Enhancements

1. **Advanced Pattern Matching**
   - Support for command chain analysis (detect `git status && rm -rf .git`)
   - Context-aware rules (allow `rm -rf node_modules` but deny `rm -rf .git`)

2. **Machine Learning Integration**
   - Learn from user confirmations to adjust allow/deny lists
   - Anomaly detection for unusual command patterns

3. **Team Collaboration**
   - Shared settings.json via git repository
   - Organization-level guardrail policies
   - Role-based allow/deny rules

4. **Enhanced Logging**
   - Structured logging with severity levels
   - Integration with monitoring systems (Datadog, Splunk)
   - Real-time alerts for denied commands

5. **GUI Configuration Tool**
   - Visual editor for settings.json
   - Pattern testing interface
   - Audit log viewer with filtering

## License

MIT License - See LICENSE file in repository root
