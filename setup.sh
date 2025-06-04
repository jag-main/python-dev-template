#!/bin/bash
# Python Dev Template Setup Script
# A unified setup script that works for both GitHub template usage and direct cloning.

set -euo pipefail # Exit on error, undefined vars, pipe failures

# Color codes for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly BOLD='\033[1m'
readonly NC='\033[0m' # No Color

# Script configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DEFAULT_PYTHON_VERSION="3.12"

# Files that need template variable replacement
readonly -a TEMPLATE_FILES=(
    "pyproject.toml"
    "Makefile"
    "README.md"
    ".envrc-sample"
    "src/main.py"
    "tests/test_main.py"
)

# Files to exclude when this is in template mode (not needed in final project)
readonly -a TEMPLATE_SETUP_FILES=(
    "init_project.sh"
    "setup.sh"
    "TEMPLATE_README.md"
    "setup.py"
    "init_project.py"
)

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}" >&2
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}" >&2
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}" >&2
}

log_error() {
    echo -e "${RED}❌ $1${NC}" >&2
}

# Show usage information
show_help() {
    printf "%bPython Dev Template Setup%b\n\n" "$BOLD" "$NC"
    printf "%bUSAGE:%b\n" "$CYAN" "$NC"
    printf "    %s PROJECT_NAME [OPTIONS]\n\n" "$0"
    printf "%bARGUMENTS:%b\n" "$CYAN" "$NC"
    printf "    PROJECT_NAME    Name for your project (lowercase, hyphens/underscores allowed)\n\n"
    printf "%bOPTIONS:%b\n" "$CYAN" "$NC"
    printf "    -p, --python VERSION    Python version requirement (e.g., '3.11', '3.12') [default: %s]\n" "$DEFAULT_PYTHON_VERSION"
    printf "    -a, --author NAME       Author name for the project [default: Your Name]\n"
    printf "    -h, --help             Show this help message\n\n"
    printf "%bEXAMPLES:%b\n" "$CYAN" "$NC"
    printf "    %s my-awesome-app --python 3.12\n" "$0"
    printf "    %s web-scraper --python 3.11 --author \"John Doe\"\n" "$0"
    printf "    %s data-processor -p 3.13 -a \"Jane Smith\"\n\n" "$0"
    printf "%bWORKS WITH:%b\n" "$CYAN" "$NC"
    printf "    • GitHub template repositories (after using \"Use this template\")\n"
    printf "    • Direct git clones\n"
    printf "    • Downloaded ZIP files\n\n"
}

# Validate project name follows Python package naming conventions
validate_project_name() {
    local name="$1"

    if [[ -z "$name" ]]; then
        return 1
    fi

    # Check if it matches Python package naming pattern
    if [[ ! "$name" =~ ^[a-z][a-z0-9_-]*[a-z0-9]$|^[a-z]$ ]]; then
        return 1
    fi

    return 0
}

# Validate Python version format
validate_python_version() {
    local version="$1"

    # Check if it matches version pattern (3.9 and above)
    if [[ ! "$version" =~ ^3\.(9|1[0-9]|[2-9][0-9])$ ]]; then
        return 1
    fi

    return 0
}

# Create template variables mapping
create_template_variables() {
    local project_name="$1"
    local python_version="$2"
    local author="${3:-Your Name}"

    # Create different name formats
    local package_name="${project_name,,}" # lowercase
    package_name="${package_name//-/_}"    # replace hyphens with underscores

    # Create class name (PascalCase)
    local class_name=""
    IFS='_-' read -ra PARTS <<<"$project_name"
    for part in "${PARTS[@]}"; do
        class_name+="$(tr '[:lower:]' '[:upper:]' <<<"${part:0:1}")${part:1}"
    done

    # Create associative array for template variables
    declare -gA TEMPLATE_VARS=(
        ["PROJECT_NAME"]="$project_name"
        ["PACKAGE_NAME"]="$package_name"
        ["CLASS_NAME"]="$class_name"
        ["PYTHON_VERSION"]="$python_version"
        ["PYTHON_VERSION_NODOT"]="${python_version//./}"
        ["AUTHOR"]="$author"
    )
}

# Replace template variables in file content
replace_template_variables() {
    local file_path="$1"
    local temp_file
    temp_file=$(mktemp)

    # Copy file to temp location
    cp "$file_path" "$temp_file"

    # Replace template placeholders with actual values
    for var_name in "${!TEMPLATE_VARS[@]}"; do
        local placeholder="{{${var_name}}}"
        local value="${TEMPLATE_VARS[$var_name]}"
        # Use | as delimiter to avoid conflicts with forward slashes in paths
        sed -i "s|${placeholder}|${value}|g" "$temp_file"
    done

    # Move temp file back
    mv "$temp_file" "$file_path"
}

# Check if file needs template processing
is_template_file() {
    local file_path="$1"

    for template_file in "${TEMPLATE_FILES[@]}"; do
        # Check if the file path ends with the template file pattern
        if [[ "$file_path" == "$template_file" ]] || [[ "$file_path" == *"/$template_file" ]]; then
            return 0
        fi
    done

    return 1
}

# Check if file is a template setup file that should be removed
is_template_setup_file() {
    local file_name="$1"

    for setup_file in "${TEMPLATE_SETUP_FILES[@]}"; do
        if [[ "$file_name" == "$setup_file" ]]; then
            return 0
        fi
    done

    return 1
}

# Process template files in current directory
process_template_files() {
    log_info "Processing template files..."

    # Process template files (exclude cache directories)
    while IFS= read -r -d '' file; do
        local rel_path="${file#$SCRIPT_DIR/}"
        
        # Skip cache directories and their contents
        if [[ "$rel_path" == *".pytest_cache"* ]] || [[ "$rel_path" == *".mypy_cache"* ]] || [[ "$rel_path" == *".ruff_cache"* ]] || [[ "$rel_path" == *"__pycache__"* ]]; then
            continue
        fi
        
        if is_template_file "$rel_path"; then
            replace_template_variables "$file"
            echo "  ✏️  Processed: $rel_path"
        fi
    done < <(find "$SCRIPT_DIR" -type f -print0)

    # Handle .envrc-sample -> .envrc conversion
    if [[ -f "$SCRIPT_DIR/.envrc-sample" ]]; then
        mv "$SCRIPT_DIR/.envrc-sample" "$SCRIPT_DIR/.envrc"
        echo "  ✏️  Converted: .envrc-sample → .envrc"
    fi

    # Replace TEMPLATE_README.md with README.md if it exists
    if [[ -f "$SCRIPT_DIR/TEMPLATE_README.md" ]]; then
        mv "$SCRIPT_DIR/TEMPLATE_README.md" "$SCRIPT_DIR/README.md"
        replace_template_variables "$SCRIPT_DIR/README.md"
        echo "  ✏️  Replaced: README.md (from TEMPLATE_README.md)"
    fi
}

# Clean up template setup files
cleanup_template_files() {
    log_info "Cleaning up template setup files..."

    for setup_file in "${TEMPLATE_SETUP_FILES[@]}"; do
        local file_path="$SCRIPT_DIR/$setup_file"
        if [[ -f "$file_path" ]]; then
            rm "$file_path"
            echo "  🗑️  Removed: $setup_file"
        fi
    done
}

# Initialize git repository if not already initialized
init_git_repo() {
    if [[ ! -d "$SCRIPT_DIR/.git" ]]; then
        log_info "Initializing git repository..."
        cd "$SCRIPT_DIR"
        git init
        git add .
        git commit -m "Initial commit: Set up ${TEMPLATE_VARS[PROJECT_NAME]} project from template"
        echo "  📦 Git repository initialized"
    else
        log_info "Git repository already exists, skipping initialization"
    fi
}

# Setup the project
setup_project() {
    local project_name="$1"
    local python_version="$2"
    local author="$3"

    # Validate inputs
    if ! validate_project_name "$project_name"; then
        log_error "Invalid project name: $project_name"
        echo "   Project names should be lowercase, use hyphens or underscores, and start with a letter" >&2
        return 1
    fi

    if ! validate_python_version "$python_version"; then
        log_error "Invalid Python version: $python_version"
        echo "   Use format like '3.11', '3.12', etc. (3.9 or higher)" >&2
        return 1
    fi

    log_info "Setting up project '$project_name' with Python $python_version"

    # Create template variables
    create_template_variables "$project_name" "$python_version" "$author"

    # Process template files
    process_template_files

    # Clean up template files
    cleanup_template_files

    # Initialize git repository
    init_git_repo

    log_success "Project '$project_name' setup completed!"
    echo ""
    echo -e "${CYAN}📋 Next steps:${NC}"
    echo "   make setup    # Set up development environment"
    echo "   make run      # Run the application"
    echo ""
    echo -e "${YELLOW}💡 Tip:${NC} Your project is ready for development!"
}

# Parse command line arguments
parse_args() {
    local project_name=""
    local python_version="$DEFAULT_PYTHON_VERSION"
    local author="Your Name"

    while [[ $# -gt 0 ]]; do
        case $1 in
        -p | --python)
            python_version="$2"
            shift 2
            ;;
        -a | --author)
            author="$2"
            shift 2
            ;;
        -h | --help)
            show_help
            exit 0
            ;;
        -*)
            log_error "Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            if [[ -z "$project_name" ]]; then
                project_name="$1"
            else
                log_error "Too many arguments"
                show_help
                exit 1
            fi
            shift
            ;;
        esac
    done

    # Check if project name was provided
    if [[ -z "$project_name" ]]; then
        log_error "Project name is required"
        show_help
        exit 1
    fi

    # Setup the project
    setup_project "$project_name" "$python_version" "$author"
}

# Main entry point
main() {
    parse_args "$@"
}

# Run main function with all arguments
main "$@"
