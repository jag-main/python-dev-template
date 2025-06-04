#!/bin/bash
# Python Dev Template Initializer
# A bash script to create new Python projects from this template with custom configuration.

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
readonly DEFAULT_TARGET_DIR="$(dirname "$SCRIPT_DIR")"

# Files that need template variable replacement
readonly -a TEMPLATE_FILES=(
    "pyproject.toml"
    "Makefile"
    "README.md"
    ".envrc-sample"
    "src/main.py"
    "tests/test_main.py"
)

# Directories to exclude when copying template
readonly -a EXCLUDE_DIRS=(
    "__pycache__"
    ".pytest_cache"
    ".mypy_cache"
    ".ruff_cache"
    "build"
    "dist"
    ".git"
    ".venv"
    "coverage_html_report"
)

# Files to exclude when copying template
readonly -a EXCLUDE_FILES=(
    "init_project.py"
    "init_project.sh"
    "TEMPLATE_README.md"
    ".coverage"
    "*.pyc"
    "*.pyo"
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
    printf "%bPython Dev Template Initializer%b\n\n" "$BOLD" "$NC"
    printf "%bUSAGE:%b\n" "$CYAN" "$NC"
    printf "    %s PROJECT_NAME [OPTIONS]\n\n" "$0"
    printf "%bARGUMENTS:%b\n" "$CYAN" "$NC"
    printf "    PROJECT_NAME    Name of the new project (lowercase, hyphens/underscores allowed)\n\n"
    printf "%bOPTIONS:%b\n" "$CYAN" "$NC"
    printf "    -p, --python VERSION    Python version requirement (e.g., '3.11', '3.12') [default: %s]\n" "$DEFAULT_PYTHON_VERSION"
    printf "    -t, --target DIRECTORY  Target directory where project will be created [default: ../]\n"
    printf "    -a, --author NAME       Author name for the project\n"
    printf "    -h, --help             Show this help message\n\n"
    printf "%bEXAMPLES:%b\n" "$CYAN" "$NC"
    printf "    %s my-awesome-app --python 3.12\n" "$0"
    printf "    %s web-scraper --python 3.11 --author \"John Doe\" --target ~/projects\n" "$0"
    printf "    %s data-processor -p 3.13 -a \"Jane Smith\"\n\n" "$0"
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

    # Replace author if provided and not default
    if [[ "${TEMPLATE_VARS[AUTHOR]}" != "Your Name" ]]; then
        sed -i "s/Your Name/${TEMPLATE_VARS[AUTHOR]}/g" "$temp_file"
    fi

    # Move temp file back
    mv "$temp_file" "$file_path"
}

# Check if item should be excluded
should_exclude() {
    local item="$1"
    local item_name
    item_name=$(basename "$item")

    # Check exclude directories (also check if any parent directory is excluded)
    for exclude_dir in "${EXCLUDE_DIRS[@]}"; do
        if [[ "$item_name" == "$exclude_dir" ]] || [[ "$item" == *"/$exclude_dir/"* ]]; then
            return 0
        fi
    done

    # Check exclude files
    for exclude_file in "${EXCLUDE_FILES[@]}"; do
        if [[ "$item_name" == "$exclude_file" ]]; then
            return 0
        fi
    done

    return 1
}

# Check if file needs template processing
is_template_file() {
    local file_path="$1" # This could be either just the filename or the relative path

    for template_file in "${TEMPLATE_FILES[@]}"; do
        # Check if the file path ends with the template file pattern
        if [[ "$file_path" == "$template_file" ]] || [[ "$file_path" == *"/$template_file" ]]; then
            return 0
        fi
    done

    return 1
}

# Copy files recursively with template processing
copy_template_files() {
    local src_dir="$1"
    local dst_dir="$2"

    log_info "Copying template files to $dst_dir"

    # Create destination directory
    mkdir -p "$dst_dir"

    # Copy files and directories
    while IFS= read -r -d '' item; do
        if should_exclude "$item"; then
            continue
        fi

        local rel_path="${item#$src_dir/}"
        local dst_item="$dst_dir/$rel_path"

        if [[ -d "$item" ]]; then
            mkdir -p "$dst_item"
            echo "  📁 Created directory: $rel_path"
        elif [[ -f "$item" ]]; then
            # Create parent directory if needed
            mkdir -p "$(dirname "$dst_item")"

            # Get file name for processing
            local file_name
            file_name=$(basename "$item")

            # Special handling for .envrc-sample -> .envrc
            if [[ "$file_name" == ".envrc-sample" ]]; then
                dst_item="$dst_dir/.envrc"
            fi

            # Copy file
            cp "$item" "$dst_item"

            # Check if it's a template file that needs processing
            if is_template_file "$rel_path"; then
                replace_template_variables "$dst_item"
                if [[ "$file_name" == ".envrc-sample" ]]; then
                    echo "  ✏️  Processed template: .envrc (from .envrc-sample)"
                else
                    echo "  ✏️  Processed template: $rel_path"
                fi
            else
                echo "  📄 Copied: $rel_path"
            fi
        fi
    done < <(find "$src_dir" -type f -o -type d | grep -v "^$src_dir$" | sort | tr '\n' '\0')
}

# Create a new project from the template
create_project() {
    local project_name="$1"
    local target_dir="$2"
    local python_version="$3"
    local author="$4"

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

    # Create project directory
    local project_dir="$target_dir/$project_name"
    if [[ -d "$project_dir" ]]; then
        log_error "Directory already exists: $project_dir"
        return 1
    fi

    log_info "Creating project '$project_name' in $project_dir"

    # Create template variables
    create_template_variables "$project_name" "$python_version" "$author"

    # Copy and process template files
    copy_template_files "$SCRIPT_DIR" "$project_dir"

    # Copy TEMPLATE_README.md as README.md if it exists
    if [[ -f "$SCRIPT_DIR/TEMPLATE_README.md" ]]; then
        cp "$SCRIPT_DIR/TEMPLATE_README.md" "$project_dir/README.md"
        replace_template_variables "$project_dir/README.md"
        echo "  ✏️  Processed template: README.md (from TEMPLATE_README.md)"
    fi

    log_success "Project '$project_name' created successfully!"
    echo ""
    echo -e "${CYAN}📋 Next steps:${NC}"
    echo "   cd $project_dir"
    echo "   make setup    # Set up development environment"
    echo "   make run      # Run the application"
    echo ""
}

# Parse command line arguments
parse_args() {
    local project_name=""
    local python_version="$DEFAULT_PYTHON_VERSION"
    local target_dir="$DEFAULT_TARGET_DIR"
    local author="Your Name"

    while [[ $# -gt 0 ]]; do
        case $1 in
        -p | --python)
            python_version="$2"
            shift 2
            ;;
        -t | --target)
            target_dir="$2"
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

    # Resolve target directory to absolute path
    target_dir=$(realpath "$target_dir")

    # Create the project
    create_project "$project_name" "$target_dir" "$python_version" "$author"
}

# Main entry point
main() {
    parse_args "$@"
}

# Run main function with all arguments
main "$@"
