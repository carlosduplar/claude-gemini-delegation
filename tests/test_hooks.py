"""
Unit tests for delegation hooks
Run with: pytest tests/
"""

import sys
from pathlib import Path

# Add hooks to path
sys.path.insert(0, str(Path(__file__).parent.parent / "hooks"))

from pre_delegate import detect_task_type, estimate_compression, build_prompt
from post_delegate import count_lines, estimate_tokens, validate_response


class TestPreDelegate:
    """Test pre-delegation hook."""
    
    def test_detect_shell_task(self):
        assert detect_task_type("npm ls") == "shell"
        assert detect_task_type("git log --oneline") == "shell"
        assert detect_task_type("pip freeze") == "shell"
    
    def test_detect_search_task(self):
        assert detect_task_type("search for TODO in code") == "search"
        assert detect_task_type("grep -r 'password' src/") == "search"
    
    def test_detect_analyze_task(self):
        assert detect_task_type("analyze the codebase") == "analyze"
        assert detect_task_type("review security vulnerabilities") == "analyze"
    
    def test_estimate_compression(self):
        assert estimate_compression("npm ls") == 5  # Highly verbose
        assert estimate_compression("grep something") == 8
        assert estimate_compression("analyze code") == 10
    
    def test_build_prompt(self):
        prompt = build_prompt("shell", "npm ls", "Build analysis", 5)
        assert "CONTEXT: Build analysis" in prompt
        assert "npm ls" in prompt
        assert "<5 lines" in prompt


class TestPostDelegate:
    """Test post-delegation hook."""
    
    def test_count_lines(self):
        text = "line 1\nline 2\nline 3"
        assert count_lines(text) == 3
        
        text_with_empty = "line 1\n\nline 2\n"
        assert count_lines(text_with_empty) == 2  # Empty lines ignored
    
    def test_estimate_tokens(self):
        text = "a" * 400  # 400 characters
        assert estimate_tokens(text) == 100  # ~4 chars per token
    
    def test_validate_response_success(self):
        response = "Line 1\nLine 2\nLine 3\nLine 4\nLine 5"
        is_valid, warnings = validate_response(response, 10)
        assert is_valid is True
        assert len(warnings) == 0
    
    def test_validate_response_too_long(self):
        response = "\n".join([f"Line {i}" for i in range(20)])
        is_valid, warnings = validate_response(response, 10)
        assert is_valid is False
        assert any("too long" in w.lower() for w in warnings)
    
    def test_validate_response_too_brief(self):
        response = "Short"
        is_valid, warnings = validate_response(response, 10)
        assert is_valid is False
        assert any("brief" in w.lower() for w in warnings)


if __name__ == "__main__":
    import pytest
    pytest.main([__file__, "-v"])
