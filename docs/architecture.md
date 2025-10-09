# Architecture

## Overview

This system enables Claude Code to delegate large-context operations and shell commands to Gemini CLI, preserving Claude Pro token limits while leveraging Gemini's free 1M-token context window.

## Components

### 1. Claude Code
- **Role:** Main AI assistant for reasoning, code generation, and design decisions
- **Token Limit:** ~44K tokens/5 hours + 40-80 Sonnet 4 hours/week
- **Strengths:** Complex reasoning, architecture decisions, small-scale code generation
- **Delegates:** Large file analysis, repository-wide operations, shell commands

### 2. Gemini CLI (via MCP)
- **Role:** Large-context AI with shell access
- **Context Window:** 1M tokens
- **Rate Limit:** 1000 requests/day (free tier)
- **Handles:** Repository analysis, large files, shell commands

### 3. Model Context Protocol (MCP)
- **Role:** Bridge between Claude Code and Gemini CLI
- **Type:** stdio-based protocol
- **Package:** `mcp-gemini-cli`

### 4. Subagents
Specialized Claude instances with focused responsibilities:

#### gemini-large-context
- **Purpose:** Large file analysis and repository-wide operations
- **Triggers:** Files >200 lines total, "entire codebase", "all files"
- **Uses:** Gemini CLI MCP tool with file/directory context (`@./` syntax)

#### gemini-shell-ops
- **Purpose:** Shell command execution and monitoring
- **Triggers:** Git commands, npm commands, build tools
- **Uses:** Gemini CLI MCP tool with shell commands

## Data Flow

### Scenario 1: Large File Analysis

```
User: "Analyze auth.js (150 lines) and database.js (100 lines)"
│
├─> Claude Code
│     - Calculates: 150 + 100 = 250 lines
│     - Decision: 250 > 200 threshold
│     - Action: Delegate to gemini-large-context subagent
│     │
│     └─> gemini-large-context subagent
│           - Calls gemini-cli MCP tool
│           - Prompt: "Analyze @auth.js @database.js for security issues"
│           │
│           └─> Gemini CLI (via MCP)
│                 - Loads files (~15K tokens)
│                 - Analyzes patterns
│                 - Returns findings
│                 │
│                 └─> Back to Claude Code
│                       - Synthesizes findings
│                       - Presents to user
```

### Scenario 2: Shell Command Execution

```
User: "Run npm test and fix failures"
│
├─> Claude Code
│     - Detects: "npm test" shell command
│     - Action: Delegate to gemini-shell-ops subagent
│     │
│     └─> gemini-shell-ops subagent
│           - Calls gemini-cli MCP tool
│           - Executes: "npm test"
│           │
│           └─> Gemini CLI (via MCP)
│                 - Runs command
│                 - Captures output
│                 - Analyzes failures
│                 - Returns diagnosis
│                 │
│                 └─> Back to Claude Code
│                       - Suggests fixes
│                       - Implements changes
```

## Delegation Decision Logic

Claude evaluates each request:

1. **Check file sizes:** If total lines > 200 → Delegate to gemini-large-context
2. **Check keywords:** If "entire", "all files", "repository" → Delegate to gemini-large-context
3. **Check commands:** If Git/npm/shell command → Delegate to gemini-shell-ops
4. **Otherwise:** Claude handles directly

## Token Flow Comparison

### Without Delegation
```
User: "Audit codebase"
│
└─> Claude Pro attempts to load 500 files
    - Would require 200K+ tokens
    - EXCEEDS 44K limit
    - IMPOSSIBLE
```

### With Delegation
```
User: "Audit codebase"
│
├─> Claude Pro (5K tokens)
│   └─> Delegates to subagent
│
├─> Subagent (2K tokens)
│   └─> Calls Gemini CLI
│
└─> Gemini CLI (800K tokens, FREE)
    └─> Returns findings (3K tokens to Claude)

Total Claude tokens: 10K [SUCCESS]
Total Gemini tokens: 800K [FREE TIER]
```

## Configuration Hierarchy

Priority order (highest to lowest):

1. **Explicit user command:** "Use gemini-large-context to..."
2. **Project `.claude/CLAUDE.md`:** Project-specific delegation rules
3. **Subagent descriptions:** Defined in `~/.claude/agents/*.md`
4. **Claude's heuristics:** Built-in decision logic

## Token Savings

| Task | Without Delegation | With Delegation | Savings |
|------|-------------------|-----------------|---------|
| 500+ line file | Impossible (exceeds limit) | Uses Gemini free tier | 20K+ |
| Full repo audit | Impossible (exceeds limit) | Uses Gemini free tier | 150K+ |
| Shell commands | Uses Claude tokens | Uses Gemini free tier | 5K |
| Small files (<200 lines) | Uses Claude tokens | Uses Claude tokens | 0 (faster) |

**Monthly impact:** Extends Claude Pro effective token budget by 10-15x for large operations

## Security

### Auto-Approved Operations
- File reading
- Directory listing
- `git status`, `git log`, `git diff`
- `npm test` (non-destructive)

### Requires User Confirmation
- File writing
- `git push`, `git reset`
- `npm publish`
- `rm` commands
- `sudo` commands

## Limitations

1. **Subagent spawn overhead:** 3-5 seconds per delegation
2. **Gemini rate limits:** 1000 requests/day (free tier)
3. **Context limits:** Operations >1M tokens may be truncated
4. **Network dependency:** Requires internet connection
5. **No offline mode:** Cannot use Gemini CLI without network

## Future Enhancements

- Result caching for repeated queries
- Parallel delegation to multiple subagents
- Token usage analytics
- Custom domain-specific subagents (database, API testing, deployment)
- Local model fallback (Ollama) when Gemini unavailable
