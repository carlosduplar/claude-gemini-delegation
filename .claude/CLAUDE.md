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

CRITICAL: ALWAYS set environment variable BEFORE invoking Gemini to enable guardrails:

```bash
export GEMINI_INVOKED_BY=claude
```

On Windows (PowerShell):
```powershell
$env:GEMINI_INVOKED_BY="claude"
```

ALWAYS execute with `-o json` flag for structured output:

```bash
# File analysis examples
export GEMINI_INVOKED_BY=claude && gemini "Your prompt here @file.js @directory/" --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json
export GEMINI_INVOKED_BY=claude && gemini "Analyze the package.json and the src directory to identify any unused npm packages. @package.json @src/" -m gemini-flash-latest --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json
export GEMINI_INVOKED_BY=claude && gemini "Analyze entire project @." --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json
export GEMINI_INVOKED_BY=claude && gemini "Scan the codebase for common security vulnerabilities like hardcoded secrets or potential injection points. @." --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json
export GEMINI_INVOKED_BY=claude && gemini "Summarize what this file does @src/main.js" -m gemini-flash-latest --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json

# Git operations - Gemini handles multi-step workflows autonomously (use flash for speed)
# IMPORTANT: Guardrails are active - destructive commands will be denied automatically
export GEMINI_INVOKED_BY=claude && gemini "Check git status, then stage all deleted files and the modified .gitignore file using git add commands. Execute: git status && git add -u && git add .gitignore && git status" -m gemini-flash-latest -y -o json
export GEMINI_INVOKED_BY=claude && gemini "Check git status to see the current state, then push the commit to the remote repository. Execute: git status && git push" -m gemini-flash-latest -y -o json
export GEMINI_INVOKED_BY=claude && gemini "Stage these files, create a commit with message 'Update documentation', then push. Execute the full workflow." -m gemini-flash-latest -y -o json

# Internet Access & Factual Lookups - use flash for straightforward documentation/tutorial queries
export GEMINI_INVOKED_BY=claude && gemini "What are the latest features and breaking changes in Node.js version 22?" -m gemini-flash-latest --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json
export GEMINI_INVOKED_BY=claude && gemini "What is the current best practice for implementing authentication in React applications in 2025?" -m gemini-flash-latest --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json
export GEMINI_INVOKED_BY=claude && gemini "Find documentation and examples for the latest version of the 'zod' validation library" -m gemini-flash-latest --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json
export GEMINI_INVOKED_BY=claude && gemini "What are the performance differences between PostgreSQL and MySQL for high-concurrency workloads?" -m gemini-flash-latest --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json
```

YOU MUST ALWAYS:
- Set `GEMINI_INVOKED_BY=claude` environment variable BEFORE invoking Gemini (enables guardrails)
- Use the prompt as the positional first parameter
- Use `@.` whenever a repository-wide analysis is required
- Use `--allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch` flag to pre-allow usage of read-only tools
- Use `-y` flag when shell commands are needed (git, npm, etc.)
- Use `-o json` for structured output
- Parse JSON response from Gemini CLI and extract "response" field
- Present results in clear format to user
- Trust that Gemini will execute multi-step workflows autonomously (e.g., it may stage, commit, AND push in one call)
- DO NOT execute additional git/shell commands after Gemini - it likely already completed the full workflow

### Guardrail Behavior

When `GEMINI_INVOKED_BY=claude` is set, Gemini applies automated security guardrails:

**ALLOWED (Execute automatically):**
- Git: status, add, commit, push (non-force), pull, fetch, log, diff, branch, merge, stash, show
- NPM: install, run build/test/dev/start, audit, update, list
- Filesystem: mkdir, touch, cp, mv, ls, cat, grep, find, cd, pwd (project scope only)
- Read-only tools: ReadFile, ReadFolder, SearchText, GoogleSearch, WebFetch

**DENIED (Abort with JSON error):**
- rm -rf (mass deletions)
- Repository deletion (rm -rf .git)
- git clean -fd
- sudo operations
- Destructive piped commands
- Direct file writes via WriteFile tool

**REQUIRES CONFIRMATION (Interactive mode only):**
- git reset --hard
- git push --force
- npm uninstall
- Operations affecting >10 files

If a command requires confirmation or is denied, check the output and handle appropriately.

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

## Safety Guidelines

When delegating commands to Gemini, be mindful of safety:

### CATASTROPHIC Commands - NEVER Delegate

These commands cause IRREVERSIBLE damage. DO NOT delegate to Gemini. Instead:
1. Stop and explain the danger to the user
2. Propose a SAFER alternative that accomplishes the user's goal
3. Ask for explicit confirmation of the safer approach

**Patterns to BLOCK:**
- `rm -rf /` - Deletes entire filesystem
- `rm -rf *` - Mass deletion of all files
- `rm -rf .git` - Destroys repository history
- `git clean -fd` - Removes untracked files permanently
- `sudo <anything>` - Elevated privileges (unnecessary for development)
- `curl <url> | bash` - Executes arbitrary remote code
- `rmdir <project-root>` - Deletes entire project
- Piped destructive commands: `find . -name "*.js" | xargs rm`

### HIGH RISK Commands - Require User Confirmation

These commands are POTENTIALLY destructive. DO NOT delegate until the user gives EXPLICIT approval.

**Patterns to CONFIRM:**
- `git reset --hard` - Discards uncommitted changes
- `git push --force` - Overwrites remote history (especially dangerous on main/master)
- `npm uninstall` - Removes dependencies
- `git clean` (any variant) - Removes files
- Operations affecting >10 files at once
- Branch deletions: `git branch -D`

### SAFE Commands - Delegate Normally

These commands are READ-ONLY or have minimal risk. Delegate to Gemini with standard invocation.

**Patterns to ALLOW:**
- **Git read operations:** status, log, diff, show, branch (list), fetch
- **Git safe writes:** add, commit, push (non-force), pull, stash
- **NPM safe operations:** install, run (build/test/dev/start), list, audit, update
- **Filesystem read:** ls, cat, grep, find (without -exec), pwd, cd
- **Filesystem safe writes:** mkdir, touch, cp, mv (project scope only)
- **Read-only tools:** ReadFile, ReadFolder, SearchText, GoogleSearch, WebFetch

## When you MUST NOT Use Gemini

- Conceptual questions
- Single-file edits
- Code generation tasks
