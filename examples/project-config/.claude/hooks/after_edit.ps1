# Automatically trigger gemini-large-context for large changesets
# PowerShell version for Windows

# Check if we're in a Git repository
if (-not (Test-Path ".git")) {
    exit 0
}

# Count changed files using git
try {
    $changedFiles = (git diff --name-only 2>$null | Measure-Object).Count
} catch {
    # If git command fails, exit gracefully
    exit 0
}

if ($changedFiles -gt 10) {
    Write-Host "🔍 Large changeset detected ($changedFiles files modified)" -ForegroundColor Yellow
    Write-Host "Triggering gemini-large-context subagent for automated review..."
    Write-Host ""
    Write-Host "gemini-large-context: Review all changes in git diff and check for:"
    Write-Host "  - Breaking changes"
    Write-Host "  - Test coverage gaps"
    Write-Host "  - Documentation updates needed"
    Write-Host "  - Potential bugs or regressions"
}

exit 0
