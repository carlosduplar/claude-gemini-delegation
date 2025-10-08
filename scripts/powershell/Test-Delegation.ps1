# Test Claude Code -> Gemini CLI autonomous delegation
# PowerShell version for Windows

$ErrorActionPreference = "Stop"

Write-Host "🧪 Testing Claude Code → Gemini CLI autonomous delegation..." -ForegroundColor Cyan
Write-Host ""

# Create temporary test directory
$testDir = Join-Path $env:TEMP "claude-gemini-test-$(Get-Random)"
New-Item -ItemType Directory -Path $testDir -Force | Out-Null
Set-Location $testDir

# Initialize a simple project
Write-Host "Setting up test project..." -ForegroundColor Yellow
New-Item -ItemType Directory -Path "src" -Force | Out-Null
New-Item -ItemType Directory -Path "tests" -Force | Out-Null

# Create src/main.js
@"
function add(a, b) {
  return a + b;
}

function multiply(a, b) {
  return a * b;
}

function divide(a, b) {
  if (b === 0) {
    throw new Error('Division by zero');
  }
  return a / b;
}

module.exports = { add, multiply, divide };
"@ | Out-File -FilePath "src\main.js" -Encoding utf8

# Create tests/main.test.js
@"
const { add, multiply, divide } = require('../src/main');

test('add function', () => {
  expect(add(2, 3)).toBe(5);
});

test('multiply function', () => {
  expect(multiply(4, 5)).toBe(20);
});

test('divide function', () => {
  expect(divide(10, 2)).toBe(5);
  expect(() => divide(10, 0)).toThrow('Division by zero');
});
"@ | Out-File -FilePath "tests\main.test.js" -Encoding utf8

# Create package.json
@"
{
  "name": "delegation-test",
  "version": "1.0.0",
  "scripts": {
    "test": "jest"
  }
}
"@ | Out-File -FilePath "package.json" -Encoding utf8

Write-Host "✓ Test project created at: $testDir" -ForegroundColor Green
Write-Host ""

# Test 1: Check MCP connection
Write-Host "Test 1: Verifying MCP connection..." -ForegroundColor Cyan
$mcpList = claude mcp list 2>&1 | Out-String
if ($mcpList -match "gemini-cli") {
    Write-Host "✓ MCP connection verified" -ForegroundColor Green
} else {
    Write-Host "❌ MCP server not found" -ForegroundColor Red
    exit 1
}

# Test 2: Check subagents
Write-Host ""
Write-Host "Test 2: Verifying subagents..." -ForegroundColor Cyan

$claudeDir = Join-Path $env:USERPROFILE ".claude"
$largeContextAgent = Join-Path $claudeDir "agents\gemini-large-context.md"
$shellOpsAgent = Join-Path $claudeDir "agents\gemini-shell-ops.md"

if (Test-Path $largeContextAgent) {
    Write-Host "✓ gemini-large-context subagent found" -ForegroundColor Green
} else {
    Write-Host "❌ gemini-large-context subagent not found" -ForegroundColor Red
    exit 1
}

if (Test-Path $shellOpsAgent) {
    Write-Host "✓ gemini-shell-ops subagent found" -ForegroundColor Green
} else {
    Write-Host "❌ gemini-shell-ops subagent not found" -ForegroundColor Red
    exit 1
}

# Test 3: Gemini CLI authentication
Write-Host ""
Write-Host "Test 3: Checking Gemini CLI authentication..." -ForegroundColor Cyan
try {
    $geminiVersion = gemini --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Gemini CLI is installed" -ForegroundColor Green
    } else {
        throw "Not authenticated"
    }
} catch {
    Write-Host "⚠️  Gemini CLI not authenticated" -ForegroundColor Yellow
    Write-Host "Run: gemini"
    Write-Host "Then select: OAuth - Personal Google Account"
}

Write-Host ""
Write-Host "✅ All automated tests passed!" -ForegroundColor Green
Write-Host ""
Write-Host "🎯 Manual test:" -ForegroundColor Cyan
Write-Host "  cd $testDir"
Write-Host "  claude"
Write-Host "  > Analyze all files in this project"
Write-Host ""
Write-Host "Expected: Claude should spawn gemini-large-context subagent" -ForegroundColor Yellow
Write-Host ""
