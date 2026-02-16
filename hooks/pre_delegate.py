#!/usr/bin/env python3
"""
Pre-delegation hook for Claude Code -> Gemini delegation
Automatically formats and optimizes delegation prompts
Zero token cost - runs locally before Claude sees anything

Usage:
    python pre-delegate.py <task> [context] [max_lines]
    
Example:
    python pre-delegate.py "npm ls" "Debugging slow build" 8
"""

import sys
import re
from typing import Literal

TaskType = Literal["shell", "search", "analyze", "docs", "generic"]


def detect_task_type(task: str) -> TaskType:
    """Detect task type from task description."""
    task_lower = task.lower()
    
    # Shell commands
    if re.search(r'^(git|npm|pip|ls|grep|find|cat|echo|curl|wget)\s', task_lower):
        return "shell"
    
    # Search operations
    if re.search(r'(search|find.*file|grep.*code|locate)', task_lower):
        return "search"
    
    # Analysis tasks
    if re.search(r'(analyze|review|audit|check|inspect|investigate)', task_lower):
        return "analyze"
    
    # Documentation lookup
    if re.search(r'(doc|documentation|api|how.*use|example)', task_lower):
        return "docs"
    
    return "generic"


def estimate_compression(task: str) -> int:
    """Estimate optimal compression level based on expected output."""
    task_lower = task.lower()
    
    # Highly verbose commands need aggressive compression
    if re.search(r'(npm ls|git log|find\s|pip freeze)', task_lower):
        return 5  # Maximum 5 lines
    
    # Search/audit operations
    if re.search(r'(grep|search|audit|scan)', task_lower):
        return 8
    
    # Default
    return 10


def build_shell_prompt(task: str, context: str, max_lines: int) -> str:
    """Build optimized prompt for shell command distillation."""
    return f"""CONTEXT: {context}
TASK: Execute this command and distill the output: {task}
OUTPUT: Extract only:
- Key findings (max 3 bullet points)
- Actionable next steps (1-2 items)
- Any errors/warnings
Total response: <{max_lines} lines"""


def build_search_prompt(task: str, context: str, max_lines: int) -> str:
    """Build optimized prompt for code search."""
    return f"""CONTEXT: {context}
TASK: {task}
OUTPUT: Return ONLY:
- File paths where found (no code snippets)
- Count of occurrences
- 1-line assessment
Maximum {max_lines} lines"""


def build_analyze_prompt(task: str, context: str, max_lines: int) -> str:
    """Build optimized prompt for analysis tasks."""
    return f"""CONTEXT: {context}
TASK: {task}
OUTPUT FORMAT:
- Main finding (1 sentence)
- Supporting evidence (2-3 lines)
- Recommended action
Maximum {max_lines} lines total"""


def build_docs_prompt(task: str, context: str, max_lines: int) -> str:
    """Build optimized prompt for documentation lookup."""
    return f"""CONTEXT: {context}
TASK: {task}
OUTPUT:
- Code example (3-5 lines max)
- Key parameter explanation (1 sentence)
- Official docs link
Total: <{max_lines} lines"""


def build_generic_prompt(task: str, context: str, max_lines: int) -> str:
    """Build generic optimized prompt."""
    return f"""CONTEXT: {context}
TASK: {task}
OUTPUT: Be concise and actionable. Maximum {max_lines} lines."""


def build_prompt(task_type: TaskType, task: str, context: str, max_lines: int) -> str:
    """Build the appropriate prompt based on task type."""
    builders = {
        "shell": build_shell_prompt,
        "search": build_search_prompt,
        "analyze": build_analyze_prompt,
        "docs": build_docs_prompt,
        "generic": build_generic_prompt,
    }
    
    builder = builders.get(task_type, build_generic_prompt)
    return builder(task, context, max_lines)


def main():
    """Main execution."""
    if len(sys.argv) < 2 or sys.argv[1] in ('-h', '--help'):
        print(__doc__)
        sys.exit(1)
    
    task = sys.argv[1]
    context = sys.argv[2] if len(sys.argv) > 2 else "General task"
    max_lines = int(sys.argv[3]) if len(sys.argv) > 3 else None
    
    # Detect task type and optimal compression
    task_type = detect_task_type(task)
    optimal_lines = estimate_compression(task)
    max_lines = max_lines or optimal_lines
    
    # Build and output prompt
    prompt = build_prompt(task_type, task, context, max_lines)
    print(prompt)


if __name__ == "__main__":
    main()
