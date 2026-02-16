# Claude Code + CLI Delegation

Automatically delegate high-token tasks from Claude Code to external CLIs (Gemini, Copilot) to preserve Claude token quota.

## Why This Matters
- 40-60% reduction in Claude token consumption
- Claude Pro caps at ~500K tokens/day; delegation offloads heavy lifting
- Works with multiple CLI backends (Gemini, GitHub Copilot with Claude Opus 4.5)

## Project Structure

```
.claude/
├── CLAUDE.md                    # Core delegation rules
├── orchestrators/
│   ├── ORCHESTRATION_RULES.md   # Routing decision tree
│   └── VALIDATION_GATES.md      # Output validation gates
├── tasks/                       # Execution inputs/outputs
└── logs/                        # Audit trails + metrics
```

## Quick Start

1. **Install CLIs:**
```bash
# Gemini CLI
npm install -g @google/gemini-cli

# GitHub Copilot CLI (for Claude Opus 4.5)
# Install from: https://github.com/github/copilot-cli
```

2. **Copy delegation rules:**
```bash
cp -r .claude /path/to/project/
```

3. **Test delegation:**
```bash
# With Gemini
gemini "List all TODO comments in this repo" --allowed-tools=run_shell_command

# With Copilot (Claude Opus 4.5)
copilot --model claude-opus-4.5 -p "Refactor this function" -s --allow-all-tools
```

## Routing Rules

Tasks are routed based on 4 rules (see `.claude/orchestrators/ORCHESTRATION_RULES.md`):

| Rule | Condition | Action |
|------|-----------|--------|
| Token Volume | >25K tokens + suitable type | DELEGATE |
| Interaction | Requires back-and-forth | KEEP in Claude |
| Criticality | Security/production code | KEEP in Claude |
| Task Type | Refactor/test/docs | DELEGATE |

## Validation Gates

Delegated output is validated through 4 gates (see `.claude/orchestrators/VALIDATION_GATES.md`):

1. **File Integrity** - Output exists, >100 bytes, readable
2. **Structure** - Correct format, no placeholders
3. **Content** - Valid syntax, reasonable length
4. **Quality** - Spot-check 3 sections for logic/style

## CLI Backends

### Gemini CLI
```bash
gemini "[task]" --allowed-tools=run_shell_command,GoogleSearch
```

### Copilot CLI (Claude Opus 4.5)
```bash
copilot --model claude-opus-4.5 -p "[task]" -s --allow-all-tools --add-dir /path
```

Available models: `claude-opus-4.5`, `claude-sonnet-4.5`, `gpt-5`, `gemini-3-pro-preview`

2. **Avoid subagents:**
   - Subagents cost 5-10K tokens per invocation
   - Use delegation instead

**Delegated:**
- "Refactor src/api.js to async/await (50K tokens)" → CLI
- "Generate unit tests for auth module" → CLI
- "Find all security vulnerabilities" → CLI

**Kept in Claude:**
- "Write a utility function" → Small, fast
- "Review this architecture decision" → Needs reasoning
- "Fix this specific bug" → Interactive refinement

## Testing

```bash
# Run delegation test with Copilot CLI
bash tests/test_copilot_delegation.sh

# Run regression tests
bash tests/regression/run_tests.sh
```

## Token Savings Example

```
Task: 50K token refactor

Without delegation: 50K tokens (all in Claude)
With delegation:    12K tokens (read input + read result + validate)

Savings: 76%
```

## Contributing

Contributions welcome! Areas where help is needed:

### Improvement Ideas

- [ ] Add example `.claude/CLAUDE.md` variations for different workflows
- [ ] Create delegation metrics dashboard
- [ ] Build interactive installer (detect installed CLIs)
- [ ] Add support for Aider, Copilot CLI delegation
- [ ] Create video tutorial/demo
- [ ] Write detailed case studies with token measurements

### How to Contribute

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with real Claude Code sessions
5. Submit a pull request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

---

## FAQ

### Q: Does this work with Claude 3.5 Sonnet?

**A:** Yes, works with all Claude models via Claude Code.

### Q: What if I don't have Gemini CLI?

**A:** The CLAUDE.md rules still help by preventing wasteful operations. But delegation won't work until you install Gemini.

### Q: Can I delegate to other CLIs besides Gemini?

**A:** Yes! Edit CLAUDE.md to reference Aider, Copilot CLI, etc. Same pattern applies.

### Q: Will Claude always follow the rules?

**A:** 70-90% compliance rate depending on:
- How explicit your requests are
- How well you maintain token budget display
- Whether you use banned command keywords

### Q: Does this increase response time?

**A:** Delegation adds ~2-5 seconds per operation. But you save 10-20 minutes by not exhausting your quota early.

**Delegation not working:**
- Verify `.claude/CLAUDE.md` exists
- Run `/clear` in Claude to reset context

**Copilot permission denied:**
- Add `--add-dir /path/to/files` to allow file access
- Or use `--allow-all-paths` for full access

## Support

---

**Last Updated:** January 15, 2026
