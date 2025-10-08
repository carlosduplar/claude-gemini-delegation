# Install Claude Code <-> Gemini CLI delegation subagents
# PowerShell version for Windows

$ErrorActionPreference = "Stop"

Write-Host "🚀 Installing Claude Code ↔ Gemini CLI delegation subagents..." -ForegroundColor Cyan
Write-Host ""

# Check if claude is installed
try {
    $null = Get-Command claude -ErrorAction Stop
} catch {
    Write-Host "❌ Error: Claude Code CLI not found" -ForegroundColor Red
    Write-Host "Please install Claude Code first: https://claude.ai/code"
    exit 1
}

# Check if gemini is installed
try {
    $null = Get-Command gemini -ErrorAction Stop
} catch {
    Write-Host "❌ Error: Gemini CLI not found" -ForegroundColor Yellow
    Write-Host "Installing Gemini CLI..."
    npm install -g @google/gemini-cli
}

# Check if MCP wrapper is available
try {
    $npmList = npm list -g mcp-gemini-cli 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Not installed"
    }
} catch {
    Write-Host "📦 Installing MCP Gemini CLI wrapper..." -ForegroundColor Yellow
    npm install -g mcp-gemini-cli
}

# Create .claude directory if it doesn't exist
$claudeDir = Join-Path $env:USERPROFILE ".claude"
$agentsDir = Join-Path $claudeDir "agents"

if (-not (Test-Path $agentsDir)) {
    New-Item -ItemType Directory -Path $agentsDir -Force | Out-Null
}

# Copy subagent templates
Write-Host "📝 Creating subagent: gemini-large-context" -ForegroundColor Green
if (-not (Test-Path "examples\subagents\gemini-large-context.md")) {
    Write-Host "❌ Error: examples\subagents\gemini-large-context.md not found" -ForegroundColor Red
    Write-Host "Please run this script from the repository root directory"
    exit 1
}
Copy-Item -Path "examples\subagents\gemini-large-context.md" -Destination "$agentsDir\gemini-large-context.md" -Force

Write-Host "📝 Creating subagent: gemini-shell-ops" -ForegroundColor Green
if (-not (Test-Path "examples\subagents\gemini-shell-ops.md")) {
    Write-Host "❌ Error: examples\subagents\gemini-shell-ops.md not found" -ForegroundColor Red
    Write-Host "Please run this script from the repository root directory"
    exit 1
}
Copy-Item -Path "examples\subagents\gemini-shell-ops.md" -Destination "$agentsDir\gemini-shell-ops.md" -Force

# Verify MCP connection
Write-Host ""
Write-Host "🔌 Verifying MCP connection..." -ForegroundColor Cyan

# Add MCP server if not already configured
# Uses -notmatch regex operator to check if "gemini-cli" appears in the MCP list output
# This matches the Bash version which uses grep -q "gemini-cli"
$mcpList = claude mcp list 2>&1 | Out-String
if ($mcpList -notmatch "gemini-cli") {
    Write-Host "Adding Gemini CLI MCP server..."
    claude mcp add-json --scope=user gemini-cli '{
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "mcp-gemini-cli"]
    }'
} else {
    Write-Host "✓ Gemini CLI MCP server already configured" -ForegroundColor Green
}

Write-Host ""
Write-Host "✅ Installation complete!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Next steps:" -ForegroundColor Cyan
Write-Host "  1. Test the installation:"
Write-Host "     .\scripts\powershell\Test-Delegation.ps1"
Write-Host ""
Write-Host "  2. Configure your project:"
Write-Host "     Copy-Item -Recurse examples\project-config\.claude \path\to\your\project\"
Write-Host ""
Write-Host "  3. Start using Claude Code:"
Write-Host "     cd \path\to\your\project"
Write-Host "     claude"
Write-Host "     > Analyze the entire repository"
Write-Host ""
Write-Host "🎉 Autonomous delegation is ready!" -ForegroundColor Green
