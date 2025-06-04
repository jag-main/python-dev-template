"""Tests for the main module."""

import sys
from io import StringIO
from unittest.mock import patch

from src.main import main


def test_main_prints_hello_message(capsys):
    """Test that main() prints the expected hello message."""
    main()
    captured = capsys.readouterr()
    assert captured.out == "Hello from {{PROJECT_NAME}}!\n"


def test_main_with_mock_print():
    """Test main() using mock to verify print is called with correct message."""
    with patch("builtins.print") as mock_print:
        main()
        mock_print.assert_called_once_with("Hello from {{PROJECT_NAME}}!")


def test_main_returns_none():
    """Test that main() returns None."""
    result = main()
    assert result is None


class TestMainExecution:
    """Test class for main execution scenarios."""

    def test_main_function_exists(self):
        """Test that main function exists and is callable."""
        assert callable(main)

    def test_main_stdout_redirect(self):
        """Test main output with stdout redirection."""
        old_stdout = sys.stdout
        sys.stdout = mystdout = StringIO()

        try:
            main()
            output = mystdout.getvalue()
            assert output == "Hello from {{PROJECT_NAME}}!\n"
        finally:
            sys.stdout = old_stdout
