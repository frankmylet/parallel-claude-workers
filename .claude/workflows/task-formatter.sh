#!/bin/bash

# Task Formatter
# Converts unformatted task descriptions into structured parallel development tasks

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TEMPLATE_FILE="$SCRIPT_DIR/../instructions/template.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[FORMAT]${NC} $1"; }
log_success() { echo -e "${GREEN}[FORMAT]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[FORMAT]${NC} $1"; }
log_error() { echo -e "${RED}[FORMAT]${NC} $1"; }

# Help function
show_help() {
    cat << EOF
Task Formatter - Convert unformatted notes to structured parallel tasks

Usage: $0 [OPTIONS]

OPTIONS:
    --input=FILE          Input file with unformatted task descriptions
    --output=FILE         Output formatted task file (default: parallel-tasks.md)
    --workers=N           Number of workers to optimize for (default: 3)
    --interactive         Enter tasks interactively
    --help                Show this help message

EXAMPLES:
    # Format from file
    $0 --input=notes.txt --workers=4

    # Interactive mode
    $0 --interactive --workers=3

    # Custom output
    $0 --input=raw.md --output=formatted.md --workers=2
EOF
}

# Parse arguments
INPUT_FILE=""
OUTPUT_FILE="parallel-tasks.md"
WORKER_COUNT=3
INTERACTIVE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --input=*)
            INPUT_FILE="${1#*=}"
            shift
            ;;
        --output=*)
            OUTPUT_FILE="${1#*=}"
            shift
            ;;
        --workers=*)
            WORKER_COUNT="${1#*=}"
            shift
            ;;
        --interactive)
            INTERACTIVE=true
            shift
            ;;
        --help)
            show_help
            exit 0
            ;;
        *)
            log_error "Unknown argument: $1"
            show_help
            exit 1
            ;;
    esac
done

# Interactive mode
interactive_input() {
    log_info "Interactive task entry mode"
    log_info "Enter your unformatted task descriptions below."
    log_info "When finished, press Ctrl+D on an empty line."
    echo ""
    echo "Example input:"
    echo "- Create login component"
    echo "- Add user registration" 
    echo "- Build dashboard"
    echo ""
    echo "Enter your tasks:"
    
    local temp_file=$(mktemp)
    cat > "$temp_file"
    echo "$temp_file"
}

# Format tasks using Claude
format_tasks() {
    local input_content="$1"
    local worker_count="$2"
    
    log_info "Formatting tasks for $worker_count parallel workers..."
    
    # Create the formatting prompt
    local format_prompt="I need you to convert unformatted task descriptions into a structured parallel development task file.

INPUT:
$input_content

REQUIREMENTS:
- Format as markdown with proper structure
- Create exactly $worker_count main tasks (or groups of related subtasks)
- Each task should be independent and suitable for parallel development
- Include an overview section explaining the overall goal
- Make tasks roughly equal in complexity
- Use the following template structure:

# Task Set: [Descriptive Title]

## Overview
[Brief description of overall goal and context]

## Tasks

### Task 1: [Task Name]
- Specific deliverable 1
- Specific deliverable 2
- Specific deliverable 3

### Task 2: [Task Name]
- Specific deliverable 1
- Specific deliverable 2

[Continue for $worker_count tasks total]

Please convert the input into this structured format, ensuring tasks are well-balanced and independent."

    # Use Claude to format the tasks
    log_info "Using Claude to structure and format tasks..."
    claude "$format_prompt"
}

# Main execution
main() {
    local input_content=""
    
    if $INTERACTIVE; then
        local temp_file=$(interactive_input)
        input_content=$(cat "$temp_file")
        rm "$temp_file"
    else
        if [[ -z "$INPUT_FILE" ]]; then
            log_error "Input file required. Use --input=FILE or --interactive"
            show_help
            exit 1
        fi
        
        if [[ ! -f "$INPUT_FILE" ]]; then
            log_error "Input file not found: $INPUT_FILE"
            exit 1
        fi
        
        input_content=$(cat "$INPUT_FILE")
    fi
    
    if [[ -z "$input_content" ]]; then
        log_error "No input content provided"
        exit 1
    fi
    
    log_info "Input content:"
    echo "----------------------------------------"
    echo "$input_content"
    echo "----------------------------------------"
    echo ""
    
    # Format the tasks
    log_info "Formatting tasks into structured file: $OUTPUT_FILE"
    
    # Create temporary file for Claude output
    local temp_output=$(mktemp)
    
    # Format tasks and capture output
    format_tasks "$input_content" "$WORKER_COUNT" > "$temp_output"
    
    # Move formatted content to output file
    mv "$temp_output" "$OUTPUT_FILE"
    
    log_success "Tasks formatted successfully!"
    log_info "Output file: $OUTPUT_FILE"
    log_info "Optimized for: $WORKER_COUNT parallel workers"
    echo ""
    log_info "Next steps:"
    log_info "1. Review the formatted tasks in $OUTPUT_FILE"
    log_info "2. Launch parallel development:"
    log_info "   .claude/workflows/parallel-manager.sh --instructions=$OUTPUT_FILE --workers=$WORKER_COUNT --auto-launch"
}

# Run main function
main "$@"