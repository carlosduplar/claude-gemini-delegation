# Delegation Configuration

## CRITICAL: When to Delegate to Gemini CLI

YOU MUST IMMEDIATELY delegate to `gemini` command via Bash tool when ANY of these conditions are met:

1.  **Cross-File Context:** Understanding or modifying code that spans multiple files, such as refactoring, tracing data flow, or analyzing the impact of a change.
2.  **Repository-Wide Analysis:** Requests to "analyze all files," understand the "entire codebase," or "scan the repository."
3.  **ALL Git Operations:** ANY git command (status, add, commit, push, pull, log, diff, branch, etc.) MUST be executed through Gemini, not directly.
4.  **ALL Shell Operations:** npm/yarn/pnpm commands, build scripts, test runners, or ANY command-line operations MUST be executed through Gemini.

NEVER execute git commands or shell operations directly. ALWAYS use Gemini as the intermediary.

## How to Use Gemini

ALWAYS execute with `-o json` flag for structured output:

```bash
# File analysis examples
gemini "Your prompt here @file.js @directory/" --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json
gemini "Analyze the package.json and the src directory to identify any unused npm packages. @package.json @src/" --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json
gemini "Analyze entire project @." --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json
gemini "Scan the codebase for common security vulnerabilities like hardcoded secrets or potential injection points. @." --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json

# Git operations - Gemini handles multi-step workflows autonomously
gemini "Check git status, then stage all deleted files and the modified .gitignore file using git add commands. Execute: git status && git add -u && git add .gitignore && git status" -y -o json
gemini "Check git status to see the current state, then push the commit to the remote repository. Execute: git status && git push" -y -o json
gemini "Stage these files, create a commit with message 'Update documentation', then push. Execute the full workflow." -y -o json
```

YOU MUST ALWAYS:
- Use the prompt as the positional first parameter
- Use `@.` whenever a repository-wide analysis is required
- Use `--allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch` flag to pre-allow usage of read-only tools
- Use `-y` flag when shell commands are needed (git, npm, etc.)
- Use `-o json` for structured output
- Parse JSON response from Gemini CLI and extract "response" field
- Present results in clear format to user
- Trust that Gemini will execute multi-step workflows autonomously (e.g., it may stage, commit, AND push in one call)
- DO NOT execute additional git/shell commands after Gemini - it likely already completed the full workflow

## When you MUST NOT Use Gemini

- Conceptual questions
- Single-file edits
- Code generation tasks
