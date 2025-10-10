Apply these rules ONLY when Gemini is invoked by Claude Code in non-interactive mode.

Allow:
- git status/add/commit/push/pull/fetch/log/diff/branch/merge/stash (no force)
- npm install/run/audit/update/list
- mkdir, touch, cp, mv, ls, cat, grep (project only)
- ReadFile, ReadFolder, SearchText, GoogleSearch, WebFetch

Deny:
- rm -rf, git clean -fd, sudo, repo deletion, destructive pipes, direct WriteFile

Require confirmation:
- git reset --hard, git push --force, npm uninstall, >10 files affected

Always return output as JSON.