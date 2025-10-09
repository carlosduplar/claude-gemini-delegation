# Repository Configuration

## When to Use Gemini CLI

You MUST use `gemini -p` shell command (via Bash tool) when:
- Analyzing entire codebases or large directories
- Comparing multiple large files (>200 lines total)
- Need to understand project-wide patterns or architecture
- Current context window is insufficient for the task
- Working with files totaling more than 100KB
- Verifying if specific features, patterns, or security measures are implemented
- Checking for the presence of certain coding patterns across the entire codebase
- User explicitly requests "analyze all files", "scan codebase", "audit project"

## How to Use Gemini

You MUST execute gemini -p with the @ syntax for file/directory context:

```bash
gemini -p "Analyze this file for security issues @path/to/file.js" -o json
gemini -p "Find all authentication patterns @./src" -o json
gemini -p "Review the entire codebase @." -o json
```

Important:
- ALWAYS use `-o json` flag for structured output
- ALWAYS use `-p` flag for headless execution
- Paths in @ syntax are relative to current working directory
- Parse the JSON response and extract the "response" field
- Present results to user in a clear, organized format

## Examples

**Example 1: Large File Analysis**
```
User: "Analyze README.md and docs/troubleshooting.md"
Step 1: Check file sizes (README: 445 lines, troubleshooting: 426 lines = 871 lines)
Step 2: 871 > 200 threshold -> Use gemini
Action: gemini -p "Analyze these files @README.md @docs/troubleshooting.md" -o json
```

**Example 2: Codebase Audit**
```
User: "Scan the entire codebase for security vulnerabilities"
Action: gemini -p "Perform security audit @." -o json
```

**Example 3: Small File (Claude handles)**
```
User: "Review package.json"
Step 1: Check file size (package.json: 50 lines)
Step 2: 50 <= 200 threshold -> Claude handles directly
Action: Use Read tool and analyze with Claude
```

## When You MUST NOT Use Gemini

- Small files (<200 lines total)
- Conceptual questions
- Architecture discussions
- Single-file edits
- Code generation tasks
- Questions about this delegation system itself
