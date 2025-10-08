# Delegation Rules

This document explains how Claude Code decides when to delegate tasks to Gemini CLI subagents.

## Trigger Mechanisms

### 1. Keyword-Based Triggers

Claude scans user requests for specific keywords that indicate large-context operations:

#### gemini-large-context triggers
- **Scope keywords:** "entire", "all", "whole", "full", "complete"
- **Modifiers:** "codebase", "repository", "project", "files"
- **Operations:** "analyze", "audit", "review", "scan", "search"

Examples:
- "Analyze the **entire codebase**" ✓
- "Review **all files** for bugs" ✓
- "Audit the **whole project**" ✓
- "Search **complete repository**" ✓

#### gemini-shell-ops triggers
- **Git commands:** "git", "commit", "push", "pull", "merge", "branch"
- **npm commands:** "npm", "install", "build", "test", "dev", "start"
- **Shell operations:** "run", "execute", "deploy", "script"

Examples:
- "**Commit** these changes" ✓
- "Run the **test** suite" ✓
- "Execute **npm build**" ✓
- "**Deploy** to production" ✓

### 2. Scope-Based Triggers

Claude estimates the number of files or lines involved:

| Scope | Files | Lines | Action |
|-------|-------|-------|--------|
| Small | 1-3 | <500 | Keep in main agent |
| Medium | 4-9 | 500-2K | Keep in main agent |
| Large | 10-20 | 2K-10K | Delegate to gemini-large-context |
| Very Large | 21+ | 10K+ | **Must** delegate to gemini-large-context |

Examples:
- "Refactor authentication.js" → 1 file → **No delegation**
- "Update all API routes" → ~15 files → **Delegate**
- "Fix linting errors" → 50+ files → **Delegate**

### 3. Operation-Type Triggers

Certain operation types automatically trigger delegation:

| Operation | Delegate To | Reason |
|-----------|-------------|--------|
| Documentation generation | gemini-large-context | Requires full codebase scan |
| Dead code detection | gemini-large-context | Must analyze all references |
| Dependency tree analysis | gemini-large-context | Cross-file relationships |
| Build monitoring | gemini-shell-ops | Real-time command execution |
| Test execution | gemini-shell-ops | Command + output analysis |
| Git operations | gemini-shell-ops | Shell command required |

### 4. Explicit Delegation

Users can force or prevent delegation:

**Force delegation:**
```

> Use gemini-large-context to analyze this
> Delegate to gemini-shell-ops for testing

```

**Prevent delegation:**
```

> Without subagents, review this code
> Don't delegate, just explain

```

## Configuration Files

### Project-Level: .claude/CLAUDE.md

Highest priority for project-specific rules:

```


## Route to gemini-large-context

- Any request mentioning "security audit"
- Documentation updates spanning multiple modules
- Performance analysis across services


## Route to gemini-shell-ops

- All deployment operations
- Database migration execution
- Docker container management


## Never delegate

- Single-function optimization
- Architecture discussions

```

### User-Level: ~/.claude/CLAUDE.md

Global fallback rules:

```


## Default Delegation Rules

### Always delegate to gemini-large-context

- Repository-wide operations
- Analysis of >15 files
- Log files >2K lines


### Always delegate to gemini-shell-ops

- Git operations
- npm/yarn commands
- CI/CD scripts

```

## Decision Tree

```

User Request
│
├─ Contains Git/npm command?
│  └─ YES → gemini-shell-ops ✓
│
├─ Mentions "entire"/"all"/"whole"?
│  └─ YES → gemini-large-context ✓
│
├─ Involves >10 files?
│  └─ YES → gemini-large-context ✓
│
├─ Output expected >2K lines?
│  └─ YES → gemini-shell-ops ✓
│
├─ .claude/CLAUDE.md has routing rule?
│  └─ YES → Follow rule ✓
│
└─ Default: Keep in main agent

```

## Fine-Tuning Thresholds

### Increase delegation (save more tokens)

Make triggers more aggressive:

```


# In subagent description

description: MUST BE USED when analyzing 8+ files (was 15)

```

### Decrease delegation (faster responses)

Make triggers more conservative:

```


# In subagent description

description: Use when analyzing 25+ files (was 15)

```

## Common Patterns

### Pattern 1: Incremental Analysis

Instead of:
```

> Analyze all 500 files

```

Claude breaks it down:
```

1. Use gemini-large-context for initial scan
2. Return top 10 files needing attention
3. Main agent provides detailed fixes for those 10
```

### Pattern 2: Cascading Delegation

```

User: Fix failing tests
│
├─> gemini-shell-ops: Run npm test
│   └─> Returns: 5 test files failing
│       │
│       └─> gemini-large-context: Analyze those 5 files
│           └─> Returns: Root cause in shared utility
│               │
│               └─> Main Claude agent: Fix utility function

```

## Troubleshooting

### Delegation not triggering

1. Check subagent description has strong keywords:
```

description: MUST BE USED PROACTIVELY when...

```

2. Add explicit routing rule in `.claude/CLAUDE.md`:
```


## Route to gemini-large-context

- Any request with "analyze"

```

3. Use explicit command:
```

> Use gemini-large-context to analyze this

```

### Delegation triggering too often

1. Increase thresholds in subagent description:
```

description: Use when analyzing 25+ files (was 15)

```

2. Add exclusions in `.claude/CLAUDE.md`:
```


## Never delegate

- Single-file reviews
- Simple refactoring
- Architecture discussions
- Design decisions
```