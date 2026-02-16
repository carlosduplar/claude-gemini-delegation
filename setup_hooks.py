#!/usr/bin/env python3
"""
Cross-platform setup script for Claude-Gemini delegation hooks

This script:
1. Creates .claude/hooks directory structure
2. Makes hook scripts executable (Unix-like systems)
3. Creates sample wrapper scripts
4. Validates Python installation

Usage:
    python setup-hooks.py [--user]
    
Options:
    --user    Install in user's home directory (~/.claude)
"""

import sys
import os
import stat
from pathlib import Path
import platform


def check_python_version():
    """Ensure Python 3.6+ is installed."""
    if sys.version_info < (3, 6):
        print("❌ Error: Python 3.6 or higher is required")
        print(f"   Current version: {sys.version}")
        sys.exit(1)
    
    print(f"✅ Python {sys.version_info.major}.{sys.version_info.minor} detected")


def create_directory_structure(base_dir: Path):
    """Create necessary directory structure."""
    dirs = [
        base_dir / "hooks",
        base_dir / "metrics",
    ]
    
    for dir_path in dirs:
        dir_path.mkdir(parents=True, exist_ok=True)
        print(f"✅ Created directory: {dir_path}")


def make_executable(file_path: Path):
    """Make a file executable on Unix-like systems."""
    if platform.system() != 'Windows':
        current_permissions = file_path.stat().st_mode
        file_path.chmod(current_permissions | stat.S_IXUSR | stat.S_IXGRP | stat.S_IXOTH)
        print(f"   Made executable: {file_path.name}")


def create_wrapper_scripts(hooks_dir: Path):
    """Create convenient wrapper scripts for different platforms."""
    
    # Unix wrapper (bash)
    unix_wrapper = hooks_dir / "delegate"
    unix_wrapper.write_text("""#!/bin/bash
# Wrapper script for delegation hooks
# Usage: ./delegate <task> [context] [max_lines]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
python3 "$SCRIPT_DIR/pre-delegate.py" "$@"
""")
    make_executable(unix_wrapper)
    
    # Windows wrapper (batch)
    windows_wrapper = hooks_dir / "delegate.bat"
    windows_wrapper.write_text("""@echo off
REM Wrapper script for delegation hooks
REM Usage: delegate.bat <task> [context] [max_lines]

python "%~dp0pre-delegate.py" %*
""")
    
    # PowerShell wrapper
    ps_wrapper = hooks_dir / "delegate.ps1"
    ps_wrapper.write_text("""# Wrapper script for delegation hooks
# Usage: ./delegate.ps1 <task> [context] [max_lines]

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
python "$ScriptDir/pre-delegate.py" $args
""")
    
    print("✅ Created wrapper scripts:")
    print(f"   • delegate (Unix)")
    print(f"   • delegate.bat (Windows)")
    print(f"   • delegate.ps1 (PowerShell)")


def create_sample_claude_md(claude_dir: Path):
    """Create a sample CLAUDE.md if it doesn't exist."""
    claude_md = claude_dir / "CLAUDE.md"
    
    if claude_md.exists():
        print(f"⚠️  CLAUDE.md already exists, skipping")
        return
    
    sample_content = """# Claude Code Configuration

## Delegation with Hooks

Use Python hooks for cross-platform delegation:

```bash
# Using wrapper script (Unix/Mac)
PROMPT=$(./claude/hooks/delegate "npm ls" "Investigating build slowdown")
gemini -p "$PROMPT"

# Using Python directly (all platforms)
PROMPT=$(python .claude/hooks/pre-delegate.py "npm ls" "Investigating build slowdown")
gemini -p "$PROMPT"

# Validate response
python .claude/hooks/post-delegate.py "$RESPONSE" 10 "dependency-analysis"
```

## Windows Users

Use the batch or PowerShell wrappers:

```powershell
# PowerShell
$prompt = & .claude/hooks/delegate.ps1 "npm ls" "Build investigation"
gemini -p $prompt

# Command Prompt
FOR /F "delims=" %i IN ('.claude\\hooks\\delegate.bat "npm ls" "Build investigation"') DO SET PROMPT=%i
gemini -p "%PROMPT%"
```

## Core Principles

- **KISS**: Keep it simple
- **Token efficiency**: Every token counts
- **Hook-driven automation**: Use local scripts, not subagents
"""
    
    claude_md.write_text(sample_content)
    print(f"✅ Created sample CLAUDE.md")


def create_readme(hooks_dir: Path):
    """Create README for hooks directory."""
    readme = hooks_dir / "README.md"
    
    content = """# Delegation Hooks

Cross-platform Python hooks for Claude Code -> Gemini delegation.

## Usage

### Pre-delegation (format prompts)

```bash
# Unix/Mac/Linux
python pre-delegate.py "npm ls" "Debugging build" 8

# Windows (same command)
python pre-delegate.py "npm ls" "Debugging build" 8
```

### Post-delegation (validate responses)

```bash
python post-delegate.py "Response text..." 10 "task-name"
```

### Analyze metrics

```bash
python analyze-metrics.py
python analyze-metrics.py --days 14  # Last 14 days
```

## Wrapper Scripts

For convenience, use the wrapper scripts:

**Unix/Mac/Linux:**
```bash
./delegate "npm ls" "Build investigation"
```

**Windows (Command Prompt):**
```cmd
delegate.bat "npm ls" "Build investigation"
```

**Windows (PowerShell):**
```powershell
./delegate.ps1 "npm ls" "Build investigation"
```

## Requirements

- Python 3.6 or higher (no additional dependencies)

## Platform Notes

All scripts use standard library only and work identically across:
- Windows (Command Prompt, PowerShell)
- macOS (Terminal, iTerm2)
- Linux (bash, zsh, fish)
"""
    
    readme.write_text(content)
    print(f"✅ Created README.md in hooks directory")


def create_gitignore(claude_dir: Path):
    """Create .gitignore for metrics."""
    gitignore = claude_dir / ".gitignore"
    
    if gitignore.exists():
        content = gitignore.read_text()
        if "metrics/" not in content:
            gitignore.write_text(content + "\n# Delegation metrics\nmetrics/\n")
            print("✅ Updated .gitignore")
    else:
        gitignore.write_text("# Delegation metrics\nmetrics/\n")
        print("✅ Created .gitignore")


def print_next_steps(claude_dir: Path, is_user_install: bool):
    """Print next steps for the user."""
    print("\n" + "="*60)
    print("🎉 Setup Complete!")
    print("="*60)
    
    print("\n📍 Installation Location:")
    print(f"   {claude_dir.absolute()}")
    
    print("\n🚀 Next Steps:")
    
    if is_user_install:
        print("\n1. This is a user-wide installation")
        print("   Hooks will be available for all your projects")
    else:
        print("\n1. This is a project-specific installation")
        print("   Hooks are only available in this project")
    
    print("\n2. Test the hooks:")
    
    if platform.system() == 'Windows':
        print(f'   cd {claude_dir / "hooks"}')
        print('   python pre-delegate.py "npm ls" "Test" 5')
    else:
        print(f'   cd {claude_dir / "hooks"}')
        print('./delegate "npm ls" "Test" 5')
    
    print("\n3. Update your workflow:")
    print("   Edit your CLAUDE.md to reference the hooks")
    
    print("\n4. Run a test delegation:")
    test_cmd = 'python .claude/hooks/pre-delegate.py "git status" "Test delegation"'
    if platform.system() != 'Windows':
        test_cmd = './.claude/hooks/delegate "git status" "Test delegation"'
    
    print(f'   PROMPT=$({test_cmd})')
    print('   gemini -p "$PROMPT"')
    
    print("\n📚 Documentation:")
    print(f"   {claude_dir / 'hooks' / 'README.md'}")
    
    print("\n💡 Tips:")
    print("   • Hooks work identically on Windows, Mac, and Linux")
    print("   • No dependencies needed beyond Python 3.6+")
    print("   • Metrics are auto-logged in .claude/metrics/")
    print("   • Run analyze-metrics.py weekly to optimize prompts")


def main():
    """Main setup process."""
    print("🔧 Claude-Gemini Delegation Hooks Setup")
    print("=" * 60)
    
    # Check Python version
    check_python_version()
    
    # Determine installation location
    is_user_install = '--user' in sys.argv
    
    if is_user_install:
        base_dir = Path.home() / ".claude"
        print(f"\n📍 Installing to user directory: {base_dir}")
    else:
        base_dir = Path.cwd() / ".claude"
        print(f"\n📍 Installing to project directory: {base_dir}")
    
    print()
    
    # Create directory structure
    create_directory_structure(base_dir)
    
    # Create wrapper scripts
    hooks_dir = base_dir / "hooks"
    create_wrapper_scripts(hooks_dir)
    
    # Create documentation
    create_sample_claude_md(base_dir)
    create_readme(hooks_dir)
    create_gitignore(base_dir)
    
    # Make Python scripts executable on Unix
    if platform.system() != 'Windows':
        for script in ['pre-delegate.py', 'post-delegate.py', 'analyze-metrics.py']:
            script_path = hooks_dir / script
            if script_path.exists():
                make_executable(script_path)
    
    # Print next steps
    print_next_steps(base_dir, is_user_install)


if __name__ == "__main__":
    main()
