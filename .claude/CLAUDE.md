# Delegation Configuration

## When to Delegate to Gemini CLI

ALWAYS use `gemini` command via Bash tool when:

1.  **Cross-File Context:** Understanding or modifying code that spans multiple files, such as refactoring, tracing data flow, or analyzing the impact of a change.
2.  **Repository-Wide Analysis:** Requests to "analyze all files," understand the "entire codebase," or "scan the repository."
3.  **Local Environment Interaction:** Executing shell commands, including `git` operations, `npm` or other package manager commands, and running build scripts.

## How to Use Gemini

ALWAYS execute with `-o json` flag for structured output:

```bash
gemini "Your prompt here @file.js @directory/" --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json
gemini "Analyze the package.json and the src directory to identify any unused npm packages. @package.json @src/" --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json
gemini "Analyze entire project @." --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json
gemini "Scan the codebase for common security vulnerabilities like hardcoded secrets or potential injection points. @." --allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch -o json
```

YOU MUST ALWAYS:
- Use the prompt as the positional first parameter
- Use `@.` whenever a repository-wide analysis is required
- Use `--allowed-tools=ReadFile,ReadFolder,ReadManyFiles,FindFiles,SearchText,Shell,GoogleSearch,WebFetch` flag to pre-allow usage of read-only tools. 
- Use `-o json` for structured output
- Parse JSON response from Gemini CLI and extract "response" field
- Present results in clear format to user

## When you MUST NOT Use Gemini

- Conceptual questions
- Single-file edits
- Code generation tasks
