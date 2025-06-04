<!-- markdownlint-disable MD041 -->
<p align="center">
  <a href="" rel="noopener">
    <img width=200px height=200px src="https://i.imgur.com/6wj0hh6.jpg" alt="Project logo">
  </a>
</p>

<div align="center">

[![Status](https://img.shields.io/badge/status-active-success.svg)](https://github.com/jagd-main/python-dev-template)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENCE)

</div>

---

<p align="center">
  🐍 A modern Python project template with comprehensive development tools and best practices built-in.<br>
</p>

## 📝 Table of Contents

- [Quick Start](#quick_start)
- [Features](#features)
- [Usage](#usage)
- [Development Workflow](#workflow)
- [Project Structure](#structure)
- [Authors](#authors)

## 🚀 Quick Start <a name = "quick_start"></a>

Create a new Python project:

### 📋 **Prerequisites**

Before using this template, install the required tools:

1. **UV Package Manager** (Required):

   ```bash
   # On macOS/Linux:
   curl -LsSf https://astral.sh/uv/install.sh | sh

   # On Windows:
   powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

   # Or via package managers:
   # macOS: brew install uv
   # Ubuntu/Debian: sudo apt install uv
   ```

2. **direnv** (Optional but recommended for automatic environment setup):

   ```bash
   # On macOS:
   brew install direnv

   # On Ubuntu/Debian:
   sudo apt install direnv

   # On other systems: https://direnv.net/docs/installation.html
   ```

   After installation, add direnv to your shell:

   ```bash
   # For bash: echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
   # For zsh: echo 'eval "$(direnv hook zsh)"' >> ~/.zshrc
   ```

### 🎯 **Setup Script**

The `setup` script automatically detects the correct mode based on your context:

- GitHub Template Usage (Auto-detected)

    ```bash
    # 1. Click "Use this template" on GitHub to create your repository
    # 2. Clone and set up:
    git clone https://github.com/YOUR-USERNAME/YOUR-PROJECT-NAME.git
    cd YOUR-PROJECT-NAME
    chmod +x setup  # Make setup script executable
    ./setup my-project-name --python 3.12 --author "Your Name"
    ```

- Clone & Generate Usage (Auto-detected)

    ```bash
    # 1. Clone the template repository and create new project:
    git clone https://github.com/jagd-main/python-dev-template.git
    cd python-dev-template
    chmod +x setup  # Make setup script executable
    ./setup my-awesome-project --python 3.12 --author "Your Name"
    cd ../my-awesome-project
    ```

### 🛠️ **Manual Mode Selection**

Force a specific mode if auto-detection isn't working:

```bash
# Ensure setup script is executable first
chmod +x setup

# Force in-place setup (GitHub template mode)
./setup my-project --mode in_place --python 3.12 --author "Your Name"

# Force generate mode (create new directory)
./setup new-project --mode generate --target ~/projects --python 3.11
```

### 3. Start developing

```bash
make setup    # Set up development environment
make run      # Run your application
```

## ✨ Features <a name = "features"></a>

- **🚀 Modern Python**: Supports Python 3.9+ with latest tooling
- **📦 Dependency Management**: UV for fast, reliable dependency resolution
- **🔍 Code Quality**: Ruff (linting + formatting), isort, MyPy type checking
- **🧪 Testing**: Pytest with coverage reporting
- **🪝 Pre-commit Hooks**: Automated code quality checks
- **📊 Documentation**: Markdown linting and structured project docs
- **🛠️ Development Automation**: Comprehensive Makefile for common tasks
- **🎯 CI-Ready**: Validation pipeline for continuous integration

## 🛠️ Usage <a name = "usage"></a>

### Unified Setup Script

The `setup` script intelligently detects the appropriate mode and handles both scenarios:

```bash
./setup [PROJECT_NAME] [OPTIONS]

Arguments:
  PROJECT_NAME              Name for your project (optional - see auto-detection below)

Options:
  -p, --python VERSION      Python version requirement (e.g., '3.11', '3.12') [default: 3.12]
  -t, --target DIRECTORY    Target directory (only for generate mode)
  -a, --author NAME         Author name for the project [default: Your Name]
  -m, --mode MODE           Force specific mode: 'in_place' or 'generate' [default: auto-detect]
  -h, --help               Show detailed help message

Auto-Detection Logic:
  🔍 GitHub Template Mode    Detected when in a template-derived repository
  🔍 Clone & Generate Mode   Detected when in the original template repository
  🔍 Manual Override         Use --mode to force specific behavior

Prerequisites:
  Make sure the setup script is executable: chmod +x setup
  Install required tools:
    - UV package manager: https://docs.astral.sh/uv/getting-started/installation/
    - direnv (optional but recommended): https://direnv.net/docs/installation.html

Examples:
  ./setup web-scraper --python 3.11 --author "John Doe"
  ./setup data-processor --mode generate --target ~/projects
  ./setup my-app --mode in_place --python 3.12
```

## 🔄 Development Workflow <a name = "workflow"></a>

Once you've created your project, use these commands for daily development:

### Initial Setup (one time)

```bash
make setup          # Complete development environment setup
```

### Daily Development

```bash
make format          # Format code with ruff and isort
make lint            # Lint code and fix auto-fixable issues
make test            # Run tests with coverage
make quick-check     # Quick validation (format + lint + fast test)
```

### Quality Assurance

```bash
make type-check      # Run MyPy type checking
make validate        # Full validation pipeline (lint + type + test)
make pre-commit      # Run pre-commit hooks on all files
```

## 📁 Project Structure <a name = "structure"></a>

Generated projects follow this structure:

```text
your-new-project/
├── 📄 pyproject.toml          # Project configuration & dependencies
├── 📄 Makefile                # Development automation
├── 📄 markdownlint.json       # Markdown linting rules
├── 📄 README.md               # Project documentation
├── 📁 src/                    # Source code
│   ├── 📄 __init__.py
│   └── 📄 main.py            # Main application entry point
├── 📁 tests/                  # Test files
│   ├── 📄 __init__.py
│   └── 📄 test_main.py       # Example tests
└── 📁 data/                   # Data files (optional)
```

## ✍️ Authors <a name = "authors"></a>

- [@javier](https://github.com/jag-main) - Template creator and maintainer

---

<div align="center">

## Happy Coding! 🐍✨

Built with ❤️ for the Python community

</div>
