# Gemini Delegation Test Plan

## Objectives

1. Validate that Gemini wrapper correctly handles delegated tasks
2. Verify token efficiency improvements through delegation
3. Identify additional token-heavy operations safe for Gemini delegation
4. Ensure Claude Code maintains senior architect role for code edits/generation
5. Improve delegation patterns based on test results

## Test Categories

### 1. Basic Delegation Tests

#### Test 1.1: Git Operations
**Prompt to Claude:**
```
Show me the git status and recent commits
```

**Expected Behavior:**
- Claude recognizes this as GEMINI_TASK
- Delegates to Gemini Flash with appropriate timeout (120000ms)
- Returns formatted git information
- Does not consume significant Claude tokens

**Success Criteria:**
- Correct delegation occurs
- Results are accurate and well-formatted
- Token usage is minimal for Claude

#### Test 1.2: Multi-File Reading
**Prompt to Claude:**
```
Read all markdown files in the project and summarize their purpose
```

**Expected Behavior:**
- Claude delegates to Gemini Flash with ReadManyFiles
- Gemini reads multiple files efficiently
- Summary is coherent and accurate

**Success Criteria:**
- All markdown files are found and read
- Summary covers all files
- Token efficiency compared to Claude reading individually

#### Test 1.3: Web Research
**Prompt to Claude:**
```
Search for best practices for AI agent delegation patterns
```

**Expected Behavior:**
- Claude delegates to Gemini Flash with WebFetch/GoogleSearch
- Gemini performs web search
- Returns relevant, current information

**Success Criteria:**
- Search results are relevant
- Information is up-to-date
- Claude maintains architectural perspective in response

### 2. Complex Delegation Tests

#### Test 2.1: Codebase Architecture Analysis
**Prompt to Claude:**
```
Analyze the entire codebase architecture and identify all token-heavy operations
that could be safely delegated to Gemini Flash or Gemini Pro, while ensuring
Claude Code maintains its role as senior architect for code edits, code generation,
and provided data analysis. For each identified operation, specify:
1. Operation type
2. Why it's token-heavy
3. Which Gemini model (Flash vs Pro)
4. Recommended --allowed-tools or -y flag
5. Why it's safe to delegate
6. What Claude should do with the results
```

**Expected Behavior:**
- Claude delegates to Gemini 2.5-Pro (deep analysis)
- Gemini analyzes full codebase structure
- Identifies delegation opportunities
- Respects role boundaries

**Success Criteria:**
- Comprehensive analysis of token-heavy operations
- Clear distinction between Claude and Gemini responsibilities
- Actionable recommendations for improving delegation
- No suggestions that violate Claude's senior architect role

#### Test 2.2: Build System Analysis
**Prompt to Claude:**
```
Run the build process and analyze any errors or warnings
```

**Expected Behavior:**
- Claude delegates to Gemini Flash with -y flag (shell access)
- Gemini executes build commands
- Returns build output and analysis

**Success Criteria:**
- Build executes correctly
- Errors/warnings are identified
- Analysis is actionable

#### Test 2.3: Security Audit
**Prompt to Claude:**
```
Perform a security audit of the codebase focusing on command injection
risks in the Gemini wrapper
```

**Expected Behavior:**
- Claude delegates to Gemini 2.5-Pro (deep analysis)
- Gemini performs thorough security review
- Identifies potential vulnerabilities

**Success Criteria:**
- Security issues are identified
- Recommendations are specific and actionable
- Audit covers command injection vectors

### 3. Boundary Tests

#### Test 3.1: Code Generation (Claude Territory)
**Prompt to Claude:**
```
Add error handling to the gemini-wrapper.js for network timeouts
```

**Expected Behavior:**
- Claude handles directly (CLAUDE_TASK)
- No delegation to Gemini
- Code is generated and edited by Claude

**Success Criteria:**
- Claude performs the work
- No inappropriate delegation
- Code quality is high

#### Test 3.2: Code Edit (Claude Territory)
**Prompt to Claude:**
```
Refactor the command building logic in gemini-wrapper.js to be more maintainable
```

**Expected Behavior:**
- Claude handles directly (CLAUDE_TASK)
- Claude reads file, analyzes, and edits
- No delegation occurs

**Success Criteria:**
- Claude performs analysis and edits
- Refactoring improves code quality
- No delegation boundary violations

#### Test 3.3: Ambiguous Task Resolution
**Prompt to Claude:**
```
Review the gemini-wrapper.js code and check if there are any issues
```

**Expected Behavior:**
- Claude recognizes "code audit" aspect
- Delegates to Gemini Pro for review
- Claude synthesizes results from architect perspective

**Success Criteria:**
- Appropriate delegation occurs
- Claude adds architectural perspective
- Results are actionable

### 4. Token Efficiency Tests

#### Test 4.1: Large File Set Reading
**Prompt to Claude:**
```
Find all JavaScript files and check for console.log statements
```

**Expected Behavior:**
- Delegates to Gemini Flash with FindFiles + SearchText
- Efficient multi-file search
- Minimal Claude token usage

**Success Criteria:**
- All JS files are searched
- Console.log statements are found
- Token usage is significantly lower than Claude doing it

#### Test 4.2: Iterative Shell Commands
**Prompt to Claude:**
```
Check node version, npm version, and list all installed packages
```

**Expected Behavior:**
- Delegates to Gemini Flash with -y flag
- Multiple commands executed efficiently
- Results returned in one response

**Success Criteria:**
- All commands execute
- Results are formatted clearly
- Single delegation call handles multiple commands

### 5. Error Handling Tests

#### Test 5.1: Command Failure
**Prompt to Claude:**
```
Run a non-existent git command
```

**Expected Behavior:**
- Gemini executes and returns error
- Claude interprets error gracefully
- User gets helpful error message

**Success Criteria:**
- Error is caught and reported
- No crash or hang
- Error message is actionable

#### Test 5.2: Timeout Handling
**Prompt to Claude:**
```
Run a command that takes longer than the timeout
```

**Expected Behavior:**
- Timeout occurs
- Error is reported to user
- System remains stable

**Success Criteria:**
- Timeout is enforced
- Graceful error handling
- No resource leaks

#### Test 5.3: Invalid Tool Combination
**Prompt to Claude:**
```
Use Gemini with both --allowed-tools and -y flag
```

**Expected Behavior:**
- Claude detects invalid combination
- Corrects to proper syntax
- Task proceeds correctly

**Success Criteria:**
- Invalid combination is avoided
- Proper syntax is used
- Task completes successfully

## Special Test: Codebase Analysis for Delegation Improvements

**Primary Test Prompt to Claude:**
```
Delegate to Gemini Pro: Analyze the entire claude-gemini-delegation codebase
including all documentation, code, and configuration files. Identify:

1. All token-heavy operations that could be delegated to Gemini Flash
2. All complex operations that should use Gemini Pro
3. Operations that must remain with Claude Code (code edits, generation, analysis)
4. Gaps in the current delegation model
5. Additional MCP tools or patterns that would improve delegation
6. Potential improvements to the wrapper implementation
7. Documentation improvements needed

For each finding, provide:
- Specific file/location references
- Token impact estimate (high/medium/low)
- Risk assessment for delegation
- Implementation recommendation
- Expected benefit

The goal is to create a comprehensive delegation strategy that maximizes
token efficiency while maintaining Claude Code's role as senior architect.
```

**Expected Deliverable:**
- Comprehensive analysis document
- Categorized delegation opportunities
- Implementation roadmap
- Risk/benefit analysis for each recommendation

## Success Metrics

1. **Delegation Accuracy:** 95%+ correct task routing
2. **Token Efficiency:** 40%+ reduction in Claude token usage for delegated tasks
3. **Response Quality:** No degradation in response quality
4. **Error Rate:** <5% errors in delegation process
5. **Coverage:** Identification of 10+ new delegation opportunities

## Test Execution Plan

1. **Phase 1:** Run basic delegation tests (1.1-1.3)
2. **Phase 2:** Execute special codebase analysis test
3. **Phase 3:** Run complex delegation tests (2.1-2.3)
4. **Phase 4:** Validate boundaries (3.1-3.3)
5. **Phase 5:** Measure token efficiency (4.1-4.2)
6. **Phase 6:** Test error handling (5.1-5.3)
7. **Phase 7:** Analyze results and implement improvements
8. **Phase 8:** Regression test after improvements

## Results Documentation Template

For each test, document:
```markdown
### Test [ID]: [Name]

**Execution Date:** [Date]
**Tester:** [Name]

**Actual Behavior:**
[Description]

**Pass/Fail:** [Status]

**Token Usage:**
- Claude tokens: [number]
- Gemini tokens: [number]
- Efficiency gain: [percentage]

**Issues Found:**
[List any issues]

**Recommendations:**
[Improvements suggested]
```

## Post-Test Actions

1. **Aggregate findings** from all tests
2. **Prioritize improvements** based on impact/effort
3. **Update delegation rules** in CLAUDE.md if needed
4. **Enhance wrapper** based on technical findings
5. **Improve documentation** with new patterns discovered
6. **Create regression test suite** for future validation
7. **Update README** with validated use cases

## Notes

- All tests should respect the MANDATE in CLAUDE.md
- Focus on practical, real-world usage scenarios
- Measure both technical metrics and user experience
- Document edge cases and limitations discovered
- Use findings to refine the delegation model iteratively
