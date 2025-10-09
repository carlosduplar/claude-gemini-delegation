# Delegation Configuration

## CRITICAL: When to Delegate to Gemini CLI

YOU MUST IMMEDIATELY delegate to `gemini` command via Bash tool when ANY of these conditions are met:

1.  **Cross-File Context:** Understanding or modifying code that spans multiple files, such as refactoring, tracing data flow, or analyzing the impact of a change.
2.  **Repository-Wide Analysis:** Requests to "analyze all files," understand the "entire codebase," or "scan the repository."
3.  **ALL Git Operations:** ANY git command (status, add, commit, push, pull, log, diff, branch, etc.) MUST be executed through Gemini, not directly.
4.  **ALL Shell Operations:** npm/yarn/pnpm commands, build scripts, test runners, or ANY command-line operations MUST be executed through Gemini.
5.  **Internet Access & Factual Lookups:** The user's request requires access to real-time information, external documentation, or any knowledge from the public internet.

NEVER execute git commands or shell operations directly. ALWAYS use Gemini as the intermediary.

## How to Use Gemini

ALWAYS execute with `-o json` flag for structured output:

```bash
# File analysis examples
gemini "Your prompt here @file.js @directory/" --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json
gemini "Analyze the package.json and the src directory to identify any unused npm packages. @package.json @src/" -m gemini-flash-latest --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json
gemini "Analyze entire project @." --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json
gemini "Scan the codebase for common security vulnerabilities like hardcoded secrets or potential injection points. @." --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json
gemini "Summarize what this file does @src/main.js" -m gemini-flash-latest --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json

# Git operations - Gemini handles multi-step workflows autonomously (use flash for speed)
gemini "Check git status, then stage all deleted files and the modified .gitignore file using git add commands. Execute: git status && git add -u && git add .gitignore && git status" -m gemini-flash-latest -y -o json
gemini "Check git status to see the current state, then push the commit to the remote repository. Execute: git status && git push" -m gemini-flash-latest -y -o json
gemini "Stage these files, create a commit with message 'Update documentation', then push. Execute the full workflow." -m gemini-flash-latest -y -o json

# Internet Access & Factual Lookups - use flash for straightforward documentation/tutorial queries
gemini "What are the latest features and breaking changes in Node.js version 22?" -m gemini-flash-latest --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json
gemini "What is the current best practice for implementing authentication in React applications in 2025?" -m gemini-flash-latest --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json
gemini "Find documentation and examples for the latest version of the 'zod' validation library" -m gemini-flash-latest --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json
gemini "What are the performance differences between PostgreSQL and MySQL for high-concurrency workloads?" --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json
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

### Model Selection Strategy:

Use `-m gemini-flash-latest` for simpler, faster tasks:
- File or project summaries
- Internet searches for documentation, tutorials, or factual information
- Explicit shell command execution (git, npm, build scripts)
- Straightforward procedural analysis (finding unused packages, listing dependencies)

Use default model (gemini-2.5-pro) for complex tasks:
- Deep code analysis requiring nuanced understanding
- Security vulnerability analysis requiring pattern recognition
- Architecture reviews and design decisions
- Complex refactoring that spans multiple files

## When you MUST NOT Use Gemini

- Conceptual questions
- Single-file edits
- Code generation tasks
