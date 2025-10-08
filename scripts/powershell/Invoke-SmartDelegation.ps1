<#
.SYNOPSIS
    Advanced Router Agent for intelligent Claude-Gemini delegation decisions.

.DESCRIPTION
    Analyzes user prompts to determine optimal delegation strategy:
    - Priority 1: Explicit shell command detection
    - Priority 2: High-token file analysis (200+ lines)
    - Priority 3: Default to Claude (self-execution)

.PARAMETER Prompt
    The user's prompt to analyze for delegation routing.

.PARAMETER FileThreshold
    Line count threshold for file-based delegation (default: 200 lines).

.OUTPUTS
    PSCustomObject with recommendation: gemini-cli, gemini-shell-ops, or claude-self

.EXAMPLE
    Invoke-SmartDelegation -Prompt "git commit -m 'feat: add feature'"
    Returns: gemini-shell-ops (detected explicit shell command)

.EXAMPLE
    Invoke-SmartDelegation -Prompt "Analyze auth.js and database.js"
    Returns: gemini-cli (if total lines > 200) or claude-self (if <= 200)

.NOTES
    Part of the Advanced Delegation Logic framework.
    Version: 1.0.0
#>

param(
    [Parameter(Mandatory = $true)]
    [string]$Prompt,

    [Parameter(Mandatory = $false)]
    [int]$FileThreshold = 200
)

# Shell commands that trigger gemini-shell-ops delegation
$ShellCommands = @(
    'git', 'npm', 'yarn', 'pnpm', 'docker', 'kubectl',
    'pip', 'cargo', 'go run', 'make', 'cmake',
    'ls', 'find', 'grep', 'cat', 'wc', 'sed', 'awk',
    'ssh', 'curl', 'wget', 'terraform', 'ansible'
)

# Result object
$Result = [PSCustomObject]@{
    Delegation = 'claude-self'  # Default
    Reason = ''
    MatchedCommand = $null
    FilesParsed = @()
    TotalLines = 0
}

# ============================================
# PRIORITY 1: EXPLICIT SHELL COMMAND DETECTION
# ============================================

foreach ($cmd in $ShellCommands) {
    # Match command at word boundaries (avoid false positives)
    if ($Prompt -match "\b$cmd\b") {
        $Result.Delegation = 'gemini-shell-ops'
        $Result.Reason = "Detected explicit shell command: '$cmd'"
        $Result.MatchedCommand = $cmd
        return $Result
    }
}

# ============================================
# PRIORITY 2: HIGH-TOKEN FILE ANALYSIS
# ============================================

# Extract potential file paths from prompt
# Matches: path/to/file.ext, ./file.js, ../folder/file.ts, C:\path\file.py
$FilePathPattern = '(?:[A-Za-z]:\\)?(?:\.{1,2}[/\\])?(?:[\w\-\.]+[/\\])*[\w\-\.]+\.\w+'
$MatchedFiles = [regex]::Matches($Prompt, $FilePathPattern) | ForEach-Object { $_.Value }

if ($MatchedFiles.Count -gt 0) {
    $TotalLineCount = 0

    foreach ($filePath in $MatchedFiles) {
        # Normalize path (handle both absolute and relative)
        $FullPath = $filePath

        # If relative path, prepend current directory
        if (-not [System.IO.Path]::IsPathRooted($filePath)) {
            $FullPath = Join-Path (Get-Location) $filePath
        }

        # Check if file exists and count lines
        if (Test-Path $FullPath -PathType Leaf) {
            try {
                $LineCount = (Get-Content $FullPath -ErrorAction Stop).Count
                $TotalLineCount += $LineCount

                $Result.FilesParsed += [PSCustomObject]@{
                    Path = $filePath
                    Lines = $LineCount
                }
            }
            catch {
                # Skip files that can't be read (binary, permissions, etc.)
                Write-Verbose "Could not read file: $FullPath"
            }
        }
    }

    # Apply threshold check
    if ($TotalLineCount -gt $FileThreshold) {
        $Result.Delegation = 'gemini-cli'
        $Result.Reason = "Total file size ($TotalLineCount lines) exceeds threshold ($FileThreshold lines)"
        $Result.TotalLines = $TotalLineCount
        return $Result
    }
    else {
        $Result.TotalLines = $TotalLineCount
        $Result.Reason = "Total file size ($TotalLineCount lines) within Claude's capacity (<= $FileThreshold lines)"
    }
}
else {
    $Result.Reason = "No shell commands or file paths detected; Claude handles conceptual tasks"
}

# ============================================
# PRIORITY 3: DEFAULT TO CLAUDE (SELF-EXECUTION)
# ============================================

return $Result
