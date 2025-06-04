<!-- markdownlint-disable MD041 -->
<p align="center">
  <a href="" rel="noopener">
    <img width=200px height=200px src="https://i.imgur.com/6wj0hh6.jpg" alt="Project logo">
  </a>
</p>

<div align="center">

[![Status](https://img.shields.io/badge/status-active-success.svg)](https://github.com/jagd-main/python-dev-template)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)

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

Create a new Python project in 3 simple steps:

### Method 1: Use as GitHub Template (Recommended)

```bash
# Click "Use this template" on GitHub, then:
git clone https://github.com/YOUR-USERNAME/YOUR-PROJECT-NAME.git
cd YOUR-PROJECT-NAME
./init_project.sh YOUR-PROJECT-NAME --python 3.12 --author "Your Name"
```

### Method 2: Clone and Generate

```bash
git clone https://github.com/jagd-main/python-dev-template.git
cd python-dev-template
./init_project.sh my-awesome-project --python 3.12 --author "Your Name"
```

### 3. Set up and start developing

```bash
cd ../my-awesome-project  # or just cd . if using Method 1
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

### Template Initialization

```bash
./init_project.sh PROJECT_NAME [OPTIONS]

Options:
  -p, --python VERSION    Python version requirement (e.g., '3.11', '3.12') [default: 3.12]
  -t, --target DIRECTORY  Target directory where project will be created [default: ../]
  -a, --author NAME       Author name for the project
  -h, --help             Show help message

Examples:
  ./init_project.sh web-scraper --python 3.11
  ./init_project.sh data-processor --python 3.12 --author "Jane Doe" --target ~/projects
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

**Happy Coding! 🐍✨**

*Built with ❤️ for the Python community*

</div>
