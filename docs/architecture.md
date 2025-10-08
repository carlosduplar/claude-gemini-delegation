# Architecture

## Overview

This system enables Claude Code to autonomously delegate large-context and shell operations to Gemini CLI, preserving Claude Pro token limits while exploiting Gemini's free 1M-token context window.

## Components

### 1. Claude Code (Primary Agent)
- **Role:** Main conversational AI, reasoning, design decisions
- **Token Limit:** ~44K tokens/5 hours + 40-80 Sonnet 4 hours/week
- **Strengths:** Complex reasoning, code generation, architecture decisions
- **Delegates to:** Subagents via internal mechanism

### 2. Model Context Protocol (MCP)
- **Role:** Bridge between Claude Code and external tools
- **Type:** stdio-based protocol
- **Function:** Exposes Gemini CLI as a callable tool to Claude

### 3. MCP Gemini CLI Wrapper
- **Package:** `mcp-gemini-cli`
- **Role:** Translates MCP requests into Gemini CLI commands
- **Installation:** `npm install -g mcp-gemini-cli`

### 4. Subagents
Specialized Claude instances with focused responsibilities:

#### gemini-large-context
- **Triggers:** "entire codebase", "all files", ">10 files"
- **Responsibilities:** Repository analysis, documentation, large logs
- **Mechanism:** Calls Gemini CLI MCP tool with @./ context

#### gemini-shell-ops
- **Triggers:** Git commands, npm commands, shell operations
- **Responsibilities:** Command execution, build monitoring, test analysis
- **Mechanism:** Calls Gemini CLI MCP tool with shell commands

### 5. Gemini CLI
- **Role:** Large-context AI agent with shell access
- **Context Window:** 1M tokens
- **Rate Limit:** 1000 requests/day (free tier)
- **Authentication:** Google OAuth

## Data Flow

### Scenario 1: Full Repository Analysis

```

User: "Analyze entire codebase for security issues"
│
├─> Claude Code (main agent)
│     - Detects: "entire codebase" keyword
│     - Decision: Delegate to gemini-large-context
│     │
│     └─> gemini-large-context (subagent)
│           - Constructs prompt: "Security audit of @./"
│           - Calls: gemini-cli MCP tool
│           │
│           └─> MCP Bridge
│                 │
│                 └─> Gemini CLI
│                       - Loads all files (~800K tokens)
│                       - Analyzes security patterns
│                       - Returns findings
│                       │
│                       ├─> Back to subagent
│                       │     - Synthesizes findings
│                       │     - Prioritizes issues
│                       │     │
│                       │     └─> Back to main agent
│                             - Formats for user
│                             - Suggests next steps
│
└─> User receives prioritized security report

```

### Scenario 2: Test Execution with Analysis

```

User: "Run tests and fix any failures"
│
├─> Claude Code (main agent)
│     - Detects: Command execution + analysis
│     - Decision: Delegate to gemini-shell-ops
│     │
│     └─> gemini-shell-ops (subagent)
│           - Calls: gemini-cli MCP tool
│           - Command: "npm test"
│           │
│           └─> MCP Bridge
│                 │
│                 └─> Gemini CLI
│                       - Executes: npm test
│                       - Captures: 3K lines of output
│                       - Analyzes failures
│                       - Returns root causes
│                       │
│                       ├─> Back to subagent
│                       │     - Summarizes errors
│                       │     - Suggests fixes
│                       │     │
│                       │     └─> Back to main agent
│                             - Proposes code changes
│                             - Asks user to confirm
│
└─> User receives diagnosis + fix suggestions

```

## Decision Logic

### How Claude Decides to Delegate

Claude Code evaluates each user request against subagent descriptions:

1. **Keyword Matching**
   - "entire", "all files", "repository" → gemini-large-context
   - "git", "npm", "build", "test" → gemini-shell-ops

2. **Scope Estimation**
   - >10 files mentioned → gemini-large-context
   - Shell command in request → gemini-shell-ops

3. **Token Prediction**
   - Estimated >20K tokens → gemini-large-context
   - Command output likely >1K lines → gemini-shell-ops

4. **Explicit Instructions**
   - `.claude/CLAUDE.md` routing rules
   - Subagent `description` fields with "MUST BE USED"

### Override Mechanisms

Users can force delegation:
```

claude
> Use gemini-large-context to analyze this file

```

Or prevent delegation:
```

claude
> Without using subagents, explain this code

```

## Token Flow

### Before Delegation (all on Claude Pro)
```

User request: "Audit codebase"
│
├─> Load 500 files (200K tokens) ❌ EXCEEDS LIMIT
├─> Analyze patterns (50K tokens)
└─> Generate report (10K tokens)

Total: 260K tokens → Impossible with 44K limit

```

### After Delegation (split between Claude Pro and Gemini free)
```

User request: "Audit codebase"
│
├─> Claude Pro (5K tokens)
│   └─> Decision: Delegate to subagent
│
├─> gemini-large-context subagent (2K tokens)
│   └─> Construct delegation prompt
│
└─> Gemini CLI (800K tokens, FREE)
├─> Load all files
├─> Pattern analysis
└─> Return findings
│
├─> subagent synthesis (3K tokens)
└─> Claude formats output (2K tokens)

Total Claude Pro: 12K tokens ✅ Within limit
Total Gemini: 800K tokens ✅ Free tier

```

## Configuration Hierarchy

Priority (highest to lowest):

1. **Explicit user instruction**
```

> Use gemini-large-context for this

```

2. **Project-level .claude/CLAUDE.md**
```


## Route to gemini-large-context

- Any mention of "entire project"

```

3. **Subagent description field**
```

description: MUST BE USED when analyzing 15+ files

```

4. **Global ~/.claude/CLAUDE.md**
```


## Default routing rules

```

5. **Claude's internal heuristics**
- Default decision logic based on request characteristics

## Performance Characteristics

### Latency

| Operation | No Delegation | With Delegation | Notes |
|-----------|---------------|-----------------|-------|
| Single file edit | 2-3s | 2-3s | No delegation needed |
| 10-file analysis | 8-10s | 12-15s | +4s for subagent spawn |
| Full repo audit | Impossible | 25-35s | Only possible with delegation |
| Test execution | 5s + manual | 8-12s | Automated analysis |

### Token Efficiency

| Task | Claude Tokens Saved | Gemini Tokens Used |
|------|---------------------|-------------------|
| Full repo audit | 150K | 800K |
| Multi-file refactor | 45K | 200K |
| Test log analysis | 12K | 15K |
| Git history review | 8K | 10K |

**Monthly savings:** ~500K Claude tokens → 10-15x extension of Pro plan

## Security Considerations

### Auto-Approve vs Manual Confirmation

**Auto-approved operations:**
- File reading (read_file)
- Directory listing (list_directory)
- Git status/log/diff
- npm test (non-destructive)

**Requires confirmation:**
- File writing (write_file)
- Git push/reset
- npm publish
- Any rm/sudo commands

## Subagent Invocation Methods

Claude Code can invoke subagents in three ways:

### 1. Automatic Invocation (Proactive)

Claude automatically detects tasks that match subagent descriptions and spawns them without user intervention.

**Triggers:**
- **Keyword matching:** "entire codebase", "all files", "run tests", "git commit"
- **Scope estimation:** Request involves >10 files, >20K tokens estimated
- **Description field:** Subagent has "MUST BE USED PROACTIVELY" in description

**Example:**
```
User: "Analyze the entire repository for security issues"
Claude: [Detects "entire repository" → spawns gemini-large-context automatically]
```

**Configuration:**
Edit `~/.claude/agents/<subagent-name>.md`:
```markdown
***
description: MUST BE USED PROACTIVELY when analyzing 15+ files, processing logs >2K lines...
***
```

### 2. Manual Invocation (Explicit)

User explicitly requests a specific subagent.

**Example:**
```
User: "Use gemini-large-context to analyze this file"
Claude: [Spawns gemini-large-context as requested]
```

**Syntax:**
```
> Use <subagent-name> to <task description>
```

### 3. Project-Configured Routing

Project-level `.claude/CLAUDE.md` defines routing rules.

**Example configuration:**
```markdown
## Route to gemini-large-context subagent
When user requests involve:
- "entire codebase" or "full repository"
- Documentation generation
- Multi-file refactoring (>10 files)

## Route to gemini-shell-ops subagent
When user requests involve:
- Git operations (commit, push, log)
- npm commands (test, build, install)
- Shell automation
```

**Priority order:**
1. Explicit user instruction (highest)
2. Project-level routing rules (`<project>/.claude/CLAUDE.md`)
3. Subagent description field (`~/.claude/agents/<name>.md`)
4. Global routing rules (`~/.claude/CLAUDE.md`)
5. Claude's internal heuristics (lowest)

### Preventing Delegation

Users can explicitly prevent delegation:
```
User: "Without using subagents, explain this code"
Claude: [Processes request directly, no delegation]
```

## Limitations

1. **Subagent spawn overhead:** 3-5 seconds per delegation
2. **Gemini rate limits:** 1000 requests/day (free tier)
3. **Context compression:** Gemini may truncate >1M token operations
4. **Network dependency:** Requires internet for Gemini API
5. **No local model support:** Cannot run Gemini CLI offline

## Future Enhancements

1. **Intelligent caching:** Cache Gemini results for similar queries
2. **Parallel delegation:** Multiple subagents simultaneously
3. **Cost tracking:** Monitor token usage across both services
4. **Custom subagents:** Database, API testing, deployment specialists
5. **Local model fallback:** Use Ollama when Gemini unavailable
