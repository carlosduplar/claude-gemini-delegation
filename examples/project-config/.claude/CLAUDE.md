# Project Configuration

## Automatic Task Routing

### Route to gemini-large-context subagent
When user requests involve:
- "entire codebase" or "full repository" or "all files"
- "analyze the project" or "audit the code"
- Documentation generation for multiple modules
- Large log file analysis (>1K lines)
- Multi-file refactoring (>10 files)
- Performance profiling across codebase
- Dead code detection

### Route to gemini-shell-ops subagent
When user requests involve:
- Git operations (commit, branch, merge, rebase, log, diff)
- npm commands (install, build, test, run dev, run <script>)
- Shell automation
- Build output analysis
- Test failure debugging
- Deployment scripts
- Docker operations

### Keep in main Claude agent
When user requests involve:
- Single-file code generation (<200 lines)
- Architecture decisions and design discussions
- Focused debugging (<5 files)
- Code review of specific pull request
- Algorithm implementation requiring reasoning
- API design and interface definition

## Project-Specific Context

### Build Commands
- **Development server:** `npm run dev` (port 3000)
- **Production build:** `npm run build`
- **Tests:** `npm test` (unit) and `npm run test:e2e` (integration)
- **Lint:** `npm run lint`
- **Format:** `npm run format`

### Tech Stack
- **Frontend:** React 18 + TypeScript
- **Backend:** Node.js + Express
- **Database:** PostgreSQL with Prisma ORM
- **Testing:** Jest + React Testing Library
- **CI/CD:** GitHub Actions

### Important Directories
- `/src/components` - React components
- `/src/api` - Backend API routes
- `/src/lib` - Shared utilities
- `/tests` - Test files
- `/docs` - Project documentation

### Coding Standards
- Use TypeScript strict mode
- Follow Airbnb style guide
- Prefer functional components with hooks
- Write tests for all business logic
- Document complex functions with JSDoc

### Common Tasks
When user says "run tests", execute `npm test` via gemini-shell-ops
When user says "start dev server", execute `npm run dev` via gemini-shell-ops
When user says "check code quality", run lint and format via gemini-shell-ops
When user says "review the codebase", delegate to gemini-large-context

## Delegation Best Practices

1. **Always explain to user what subagent is being invoked and why**
   Example: "I'm delegating this to gemini-large-context because it requires analyzing 50+ files"

2. **Summarize subagent results before presenting to user**
   Don't dump raw Gemini output - synthesize key points

3. **Provide actionable next steps after delegation**
   User should know exactly what to do after receiving results

4. **Use subagents proactively**
   If you detect a task will benefit from delegation, invoke subagent without waiting for user to ask
