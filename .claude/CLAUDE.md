# Repository Configuration

## CRITICAL DELEGATION RULES

### ALWAYS delegate to gemini-large-context subagent when user says:
- "analyze all files"
- "analyze the entire"
- "review all files"
- "scan the codebase"
- "audit the project"
- Any request involving more than 5 files

### ALWAYS delegate to gemini-shell-ops subagent when user says:
- "run tests"
- "execute npm"
- "git commit"
- "build the project"
- Any bash/shell command

## How to Delegate

When you detect one of the above phrases, YOU MUST:

1. Immediately invoke the appropriate subagent
2. Do NOT use your own Read() or Search() tools
3. Pass the full request to the subagent
4. Wait for subagent response
5. Synthesize results for user

Example:
User: "analyze all files in this project"
Action: Invoke gemini-large-context subagent with prompt "Analyze all files in @./"
Do NOT: Use Read() or Search() yourself