#!/usr/bin/env make
# {{PROJECT_NAME}} - Professional Development Makefile
# ==============================================
# This makefile provides a comprehensive development workflow for the {{PROJECT_NAME}} project.
# All targets follow dependency patterns and proper error handling.

# Project Configuration
# ---------------------
PROJECT_NAME := {{PROJECT_NAME}}
PYTHON_VERSION := {{PYTHON_VERSION}}
VENV := .venv
BIN := $(VENV)/bin
SRC_DIR := src
TEST_DIR := tests
COVERAGE_DIR := coverage_html_report

# Environment Variables
# --------------------
export PYTHONPATH := $(shell pwd)
export UV_COMPILE_BYTECODE := 1

# Terminal Colors
# ---------------
CYAN := \033[0;36m
GREEN := \033[0;32m
RED := \033[0;31m
BLUE := \033[0;34m
YELLOW := \033[1;33m
BOLD := \033[1m
END := \033[0m

# Default target
# --------------
.DEFAULT_GOAL := help

# Utility Functions
# -----------------
define log_info
echo "$(BLUE)ℹ️  $(1)$(END)"
endef

define log_success
echo "$(GREEN)✅ $(1)$(END)"
endef

define log_warning
echo "$(YELLOW)⚠️  $(1)$(END)"
endef

define log_error
echo "$(RED)❌ $(1)$(END)"
endef

################################################################################
# HELP & STATUS
################################################################################

.PHONY: help
help: ## 📚 Show this help message
	@echo "$(BOLD)$(PROJECT_NAME) Development Makefile$(END)"
	@echo "$(CYAN)================================$(END)"
	@echo ""
	@echo "$(BOLD)Usage:$(END) make <target>"
	@echo ""
	@echo "$(BOLD)📋 Recommended Workflow:$(END)"
	@echo ""
	@echo "$(YELLOW)# Initial setup (one time)$(END)"
	@echo "  $(CYAN)make setup$(END)          # Complete development environment setup"
	@echo ""
	@echo "$(YELLOW)# Daily development$(END)"
	@echo "  $(CYAN)make format$(END)          # Format code with ruff and isort"
	@echo "  $(CYAN)make lint$(END)            # Lint code and fix auto-fixable issues"
	@echo "  $(CYAN)make test$(END)            # Run tests with coverage"
	@echo "  $(CYAN)make pre-commit$(END)      # Check everything with pre-commit hooks"
	@echo ""
	@echo "$(YELLOW)# Quality assurance$(END)"
	@echo "  $(CYAN)make type-check$(END)      # Run MyPy type checking"
	@echo "  $(CYAN)make validate$(END)        # Full validation pipeline (lint + type + test)"
	@echo "  $(CYAN)make quick-check$(END)     # Quick development check (format + lint + test-fast)"
	@echo ""
	@echo "$(YELLOW)# Maintenance$(END)"
	@echo "  $(CYAN)make pre-commit-update$(END) # Update pre-commit hook versions"
	@echo "  $(CYAN)make clean$(END)           # Clean environment and cache files"
	@echo "  $(CYAN)make deps-update$(END)     # Update all dependencies"
	@echo ""
	@echo "$(BOLD)📖 All Available Targets:$(END)"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		sort | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  $(CYAN)%-20s$(END) %s\n", $$1, $$2}'
	@echo ""

.PHONY: status
status: ## 🔍 Show development environment status
	@echo "$(BOLD)Development Environment Status$(END)"
	@echo "$(CYAN)==============================$(END)"
	@echo "Project: $(PROJECT_NAME)"
	@echo "Python Version: $(shell uv run python --version 2>/dev/null || echo 'Not available')"
	@echo "UV Version: $(shell uv --version 2>/dev/null || echo 'Not installed')"
	@echo "Virtual Environment: $(shell test -d $(VENV) && echo '$(GREEN)Created$(END)' || echo '$(RED)Not created$(END)')"
	@echo "Pre-commit Hooks: $(shell test -f .git/hooks/pre-commit && echo '$(GREEN)Installed$(END)' || echo '$(RED)Not installed$(END)')"
	@echo "MyPy Version: $(shell uv run mypy --version 2>/dev/null || echo '$(RED)Not available$(END)')"
	@echo "Source Files: $(shell find $(SRC_DIR) -name '*.py' | wc -l) Python files"
	@echo "Test Files: $(shell find $(TEST_DIR) -name '*.py' | wc -l) Python files"

################################################################################
# ENVIRONMENT SETUP
################################################################################

.PHONY: check-uv
check-uv: ## 🔧 Verify UV package manager is available
	@$(call log_info,Checking UV package manager...)
	@command -v uv >/dev/null 2>&1 || { \
		$(call log_error,UV is not installed); \
		echo "$(RED)Please install UV from: https://docs.astral.sh/uv/getting-started/installation/$(END)"; \
		exit 1; \
	}
	@$(call log_success,UV package manager is available)

.PHONY: sync
sync: check-uv ## 📦 Sync dependencies and create virtual environment
	@$(call log_info,Syncing dependencies with UV...)
	@uv sync --all-packages --all-groups || { \
		$(call log_error,Failed to sync packages); \
		exit 1; \
	}
	@$(call log_success,Dependencies synced successfully)

.PHONY: install-hooks
install-hooks: sync ## 🪝 Install pre-commit hooks
	@$(call log_info,Installing pre-commit hooks...)
	@uv run pre-commit install || { \
		$(call log_error,Failed to install pre-commit hooks); \
		exit 1; \
	}
	@$(call log_success,Pre-commit hooks installed)

.PHONY: setup
setup: sync install-hooks ## 🚀 Complete development environment setup
	@$(call log_success,Development environment setup complete!)
	@echo "$(BLUE)💡 Use 'uv run <command>' to run commands in the environment$(END)"
	@echo "$(BLUE)💡 Example: uv run python $(SRC_DIR)/main.py$(END)"

.PHONY: clean
clean: ## 🧹 Clean workspace (remove virtual env, cache, and temp files)
	@$(call log_info,Cleaning development environment...)
	@rm -rf $(VENV)
	@find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	@find . -type f -name "*.pyc" -delete 2>/dev/null || true
	@find . -type f -name "*.pyo" -delete 2>/dev/null || true
	@rm -rf build/ dist/ *.egg-info .pytest_cache/ .ruff_cache/ .mypy_cache/
	@rm -f .coverage
	@rm -rf $(COVERAGE_DIR)/ mypy-report/
	@$(call log_success,Workspace cleaned)

################################################################################
# CODE QUALITY
################################################################################

.PHONY: format
format: sync ## 🎨 Format code with ruff and isort
	@$(call log_info,Formatting code...)
	@uv run ruff format $(SRC_DIR)/ $(TEST_DIR)/
	@uv run isort $(SRC_DIR)/ $(TEST_DIR)/
	@$(call log_success,Code formatting completed)

.PHONY: lint
lint: sync ## 🔍 Lint code and fix auto-fixable issues
	@$(call log_info,Linting code...)
	@uv run ruff check $(SRC_DIR)/ $(TEST_DIR)/ --fix
	@$(call log_success,Code linting completed)

.PHONY: lint-check
lint-check: sync ## 📋 Check code without making changes
	@$(call log_info,Checking code quality...)
	@uv run ruff check $(SRC_DIR)/ $(TEST_DIR)/
	@uv run ruff format $(SRC_DIR)/ $(TEST_DIR)/ --check
	@$(call log_success,Code quality check passed)

.PHONY: type-check
type-check: sync ## 🔬 Run type checking with MyPy
	@$(call log_info,Running type checks with MyPy...)
	@uv run mypy $(SRC_DIR)/ $(TEST_DIR)/ || { \
		$(call log_error,Type checking failed); \
		exit 1; \
	}
	@$(call log_success,Type checking completed)

.PHONY: type-check-report
type-check-report: sync ## 📊 Run type checking with detailed HTML report
	@$(call log_info,Generating HTML type checking report...)
	@uv run mypy $(SRC_DIR)/ $(TEST_DIR)/ --html-report mypy-report || { \
		$(call log_error,Type checking failed); \
		exit 1; \
	}
	@$(call log_success,Type checking HTML report generated: mypy-report/index.html)

.PHONY: type-check-strict
type-check-strict: sync ## 🔬 Run strict type checking (no warnings allowed)
	@$(call log_info,Running strict type checking...)
	@uv run mypy $(SRC_DIR)/ $(TEST_DIR)/ \
		--strict \
		--warn-unreachable \
		--disallow-any-expr || { \
		$(call log_error,Strict type checking failed); \
		exit 1; \
	}
	@$(call log_success,Strict type checking passed)

################################################################################
# TESTING
################################################################################

.PHONY: test
test: sync ## 🧪 Run all tests with coverage
	@$(call log_info,Running test suite...)
	@uv run pytest \
		--verbose \
		--tb=short \
		--maxfail=1 \
		--cov=$(SRC_DIR) \
		--cov-report=html:$(COVERAGE_DIR) \
		--cov-report=term-missing \
		$(TEST_DIR)/
	@$(call log_success,Tests completed)
	@echo "$(BLUE)📊 Coverage report: $(COVERAGE_DIR)/index.html$(END)"

.PHONY: test-fast
test-fast: sync ## ⚡ Run tests without coverage (faster)
	@$(call log_info,Running fast test suite...)
	@uv run pytest --verbose --tb=short --maxfail=1 $(TEST_DIR)/
	@$(call log_success,Fast tests completed)

.PHONY: test-watch
test-watch: sync ## 👀 Run tests in watch mode
	@$(call log_info,Starting test watcher...)
	@uv run pytest-watch --verbose $(TEST_DIR)/

################################################################################
# PRE-COMMIT MANAGEMENT
################################################################################

.PHONY: pre-commit
pre-commit: install-hooks ## 🔄 Run pre-commit on all files
	@$(call log_info,Running pre-commit hooks on all files...)
	@uv run pre-commit run --all-files
	@$(call log_success,Pre-commit checks completed)

.PHONY: pre-commit-update
pre-commit-update: install-hooks ## 🔄 Update pre-commit hook versions
	@$(call log_info,Updating pre-commit hooks...)
	@uv run pre-commit autoupdate
	@$(call log_success,Pre-commit hooks updated)

.PHONY: pre-commit-clean
pre-commit-clean: ## 🧹 Clean pre-commit cache
	@$(call log_info,Cleaning pre-commit cache...)
	@uv run pre-commit clean
	@$(call log_success,Pre-commit cache cleaned)

################################################################################
# CI/CD & VALIDATION
################################################################################

.PHONY: validate
validate: lint-check type-check test ## ✅ Full validation pipeline (lint + type + test)
	@$(call log_success,All validation checks passed!)

.PHONY: ci
ci: setup validate ## 🤖 Complete CI pipeline (setup + validate)
	@$(call log_success,CI pipeline completed successfully!)

.PHONY: quick-check
quick-check: format lint test-fast ## ⚡ Quick development check (format + lint + fast test)
	@$(call log_success,Quick development check completed!)

################################################################################
# PROJECT UTILITIES
################################################################################

.PHONY: run
run: sync ## 🏃 Run the main application
	@$(call log_info,Running $(PROJECT_NAME)...)
	@uv run python $(SRC_DIR)/main.py

.PHONY: shell
shell: sync ## 🐚 Start interactive Python shell with project context
	@$(call log_info,Starting Python shell...)
	@uv run python

.PHONY: deps-update
deps-update: check-uv ## 🔄 Update all dependencies to latest versions
	@$(call log_info,Updating dependencies...)
	@uv lock --upgrade
	@uv sync --all-packages --all-groups
	@$(call log_success,Dependencies updated)

