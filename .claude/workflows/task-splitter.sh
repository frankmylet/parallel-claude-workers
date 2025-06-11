#!/bin/bash

# Task Splitter
# Splits task instructions into individual worker tasks

set -e

INSTRUCTIONS_FILE="$1"
WORKER_COUNT="$2"
OUTPUT_DIR="$3"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[TASK-SPLITTER]${NC} $1"; }
log_success() { echo -e "${GREEN}[TASK-SPLITTER]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[TASK-SPLITTER]${NC} $1"; }
log_error() { echo -e "${RED}[TASK-SPLITTER]${NC} $1"; }

# Validate inputs
if [[ -z "$INSTRUCTIONS_FILE" ]] || [[ -z "$WORKER_COUNT" ]] || [[ -z "$OUTPUT_DIR" ]]; then
    log_error "Usage: $0 <instructions_file> <worker_count> <output_dir>"
    exit 1
fi

if [[ ! -f "$INSTRUCTIONS_FILE" ]]; then
    log_error "Instructions file not found: $INSTRUCTIONS_FILE"
    exit 1
fi

log_info "Splitting tasks from $INSTRUCTIONS_FILE into $WORKER_COUNT workers"

# Read the instructions file
INSTRUCTIONS_CONTENT=$(cat "$INSTRUCTIONS_FILE")

# Extract overview and general instructions
OVERVIEW=$(echo "$INSTRUCTIONS_CONTENT" | sed -n '/^## Overview/,/^## Tasks/p' | head -n -1)

# Extract individual tasks
TASKS=$(echo "$INSTRUCTIONS_CONTENT" | sed -n '/^### Task /,$p')

# Split tasks into array
IFS=$'\n' read -d '' -r -a TASK_SECTIONS <<< "$(echo "$TASKS" | awk '/^### Task /{if(x)print x; x=""; } {x=(!x)?$0:x"\n"$0;} END{print x;}')" || true

TASK_COUNT=${#TASK_SECTIONS[@]}

log_info "Found $TASK_COUNT tasks to distribute among $WORKER_COUNT workers"

# Distribute tasks among workers
for worker_id in $(seq 1 $WORKER_COUNT); do
    worker_file="$OUTPUT_DIR/task-$worker_id.md"
    
    log_info "Creating task file for worker $worker_id: $worker_file"
    
    # Create worker-specific task file
    cat > "$worker_file" << EOF
# Worker $worker_id Task Assignment

$OVERVIEW

## Your Assigned Tasks

EOF
    
    # Calculate which tasks this worker should handle
    tasks_per_worker=$((TASK_COUNT / WORKER_COUNT))
    remainder=$((TASK_COUNT % WORKER_COUNT))
    
    start_task=$(( (worker_id - 1) * tasks_per_worker + 1 ))
    
    # Distribute remainder tasks to first workers
    if [[ $worker_id -le $remainder ]]; then
        start_task=$((start_task + worker_id - 1))
        end_task=$((start_task + tasks_per_worker))
    else
        start_task=$((start_task + remainder))
        end_task=$((start_task + tasks_per_worker - 1))
    fi
    
    # Handle edge case where we have fewer tasks than workers
    if [[ $start_task -gt $TASK_COUNT ]]; then
        echo "### No tasks assigned" >> "$worker_file"
        echo "All tasks have been distributed to other workers." >> "$worker_file"
        log_warn "Worker $worker_id has no tasks (fewer tasks than workers)"
        continue
    fi
    
    # Add assigned tasks
    for task_idx in $(seq $start_task $end_task); do
        if [[ $task_idx -le $TASK_COUNT ]]; then
            echo "${TASK_SECTIONS[$((task_idx - 1))]}" >> "$worker_file"
            echo "" >> "$worker_file"
        fi
    done
    
    # Add worker-specific instructions
    cat >> "$worker_file" << EOF

## Worker Instructions

You are Worker $worker_id in a parallel development session.

### Important Guidelines
- Focus only on your assigned tasks above
- Work independently and avoid conflicts with other workers
- Test your changes thoroughly before committing
- Use descriptive commit messages
- Follow the project's coding standards

### Verification Steps
Before marking your work complete:

1. **Test your changes**:
   \`\`\`bash
   npm run test
   npm run lint
   npm run build
   \`\`\`

2. **Create a descriptive commit**:
   \`\`\`bash
   git add .
   git commit -m "feat: Complete worker $worker_id assigned tasks
   
   - [List your completed tasks here]
   - [Include any important notes]"
   \`\`\`

3. **Verify no conflicts**:
   - Check that your changes don't conflict with other workers
   - Review your modifications carefully

### Need Help?
- Check the main project documentation
- Refer to existing code patterns
- Follow the same style as surrounding code

### When Complete
Your work will be reviewed and merged with other workers' contributions.
Focus on quality and thorough testing.
EOF
    
    log_success "Created task file for worker $worker_id"
done

log_success "Task splitting complete! Created $WORKER_COUNT worker task files."