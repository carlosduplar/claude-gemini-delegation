# Uninstall Claude Code <-> Gemini CLI delegation
# PowerShell version for Windows

param(
    [switch]$Full
)

Write-Host "🗑️  Uninstalling Claude Code → Gemini CLI delegation..." -ForegroundColor Cyan
Write-Host ""

$claudeDir = Join-Path $env:USERPROFILE ".claude"
$largeContextAgent = Join-Path $claudeDir "agents\gemini-large-context.md"
$shellOpsAgent = Join-Path $claudeDir "agents\gemini-shell-ops.md"

# Remove subagents
if (Test-Path $largeContextAgent) {
    Remove-Item $largeContextAgent -Force
    Write-Host "✓ Removed gemini-large-context subagent" -ForegroundColor Green
}

if (Test-Path $shellOpsAgent) {
    Remove-Item $shellOpsAgent -Force
    Write-Host "✓ Removed gemini-shell-ops subagent" -ForegroundColor Green
}

# Remove MCP server
$mcpList = claude mcp list 2>&1 | Out-String
if ($mcpList -match "gemini-cli") {
    claude mcp remove gemini-cli
    Write-Host "✓ Removed Gemini CLI MCP server" -ForegroundColor Green
}

# Full uninstall (optional)
if ($Full) {
    Write-Host ""
    Write-Host "📦 Performing full uninstall..." -ForegroundColor Cyan

    try {
        $geminiInstalled = npm list -g @google/gemini-cli 2>$null
        if ($LASTEXITCODE -eq 0) {
            npm uninstall -g @google/gemini-cli
            Write-Host "✓ Uninstalled Gemini CLI" -ForegroundColor Green
        }
    } catch {
        # Package not installed, skip
    }

    try {
        $mcpInstalled = npm list -g mcp-gemini-cli 2>$null
        if ($LASTEXITCODE -eq 0) {
            npm uninstall -g mcp-gemini-cli
            Write-Host "✓ Uninstalled MCP Gemini CLI wrapper" -ForegroundColor Green
        }
    } catch {
        # Package not installed, skip
    }
}

Write-Host ""
Write-Host "✅ Uninstallation complete" -ForegroundColor Green

if (-not $Full) {
    Write-Host ""
    Write-Host "Note: This did not uninstall npm packages. To remove everything, run:" -ForegroundColor Yellow
    Write-Host "  .\scripts\powershell\Uninstall.ps1 -Full"
    Write-Host ""
    Write-Host "Or manually run:"
    Write-Host "  npm uninstall -g @google/gemini-cli"
    Write-Host "  npm uninstall -g mcp-gemini-cli"
}

Write-Host ""
