#!/bin/bash

# Parallel Worktree Manager
# Main script for managing parallel development workflows

set -e

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
WORKTREE_DIR="$PROJECT_ROOT/worktrees"
BRANCH_PREFIX="parallel-task"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Help function
show_help() {
    cat << EOF
Parallel Worktree Manager

Usage: $0 [OPTIONS]

OPTIONS:
    --instructions=FILE    Path to task instructions file (required for init)
    --workers=N           Number of worktrees to create (default: 3)
    --review              Review worktree status and prepare for merge
    --merge               Merge completed worktrees back to main
    --cleanup             Remove all worktrees and cleanup
    --branch-prefix=PREFIX Custom branch prefix (default: parallel-task)
    --auto-launch         Automatically open VS Code and start Claude in each worktree
    --launch-only         Only launch existing worktrees (no creation)
    --help                Show this help message

EXAMPLES:
    # Initialize 3 parallel worktrees with auto-launch
    $0 --instructions=tasks.md --workers=3 --auto-launch
    
    # Initialize without auto-launch (manual setup)
    $0 --instructions=tasks.md --workers=3
    
    # Launch existing worktrees only
    $0 --launch-only
    
    # Review progress
    $0 --review
    
    # Merge completed work
    $0 --merge
    
    # Cleanup
    $0 --cleanup
EOF
}

# Parse arguments
INSTRUCTIONS_FILE=""
WORKER_COUNT=3
MODE="init"
AUTO_LAUNCH=false
LAUNCH_ONLY=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --instructions=*)
            INSTRUCTIONS_FILE="${1#*=}"
            shift
            ;;
        --workers=*)
            WORKER_COUNT="${1#*=}"
            shift
            ;;
        --branch-prefix=*)
            BRANCH_PREFIX="${1#*=}"
            shift
            ;;
        --review)
            MODE="review"
            shift
            ;;
        --merge)
            MODE="merge"
            shift
            ;;
        --cleanup)
            MODE="cleanup"
            shift
            ;;
        --auto-launch)
            AUTO_LAUNCH=true
            shift
            ;;
        --launch-only)
            LAUNCH_ONLY=true
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

# Validate git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Not in a git repository"
        exit 1
    fi
}

# Ensure we're on main branch for initialization
ensure_main_branch() {
    local current_branch=$(git branch --show-current)
    if [[ "$current_branch" != "main" ]]; then
        log_warn "Currently on branch '$current_branch'. Switching to main..."
        git checkout main
        git pull origin main
    fi
}

# Check if worktrees already exist
check_existing_worktrees() {
    if [[ -d "$WORKTREE_DIR" ]] && [[ -n "$(ls -A "$WORKTREE_DIR" 2>/dev/null)" ]]; then
        local existing_workers=($(ls -d "$WORKTREE_DIR"/worker-* 2>/dev/null | wc -l))
        if [[ $existing_workers -gt 0 ]]; then
            return 0  # Worktrees exist
        fi
    fi
    return 1  # No worktrees
}

# Setup existing worktrees with missing .claude configuration
setup_existing_worktrees() {
    log_info "Setting up .claude configuration for existing worktrees..."
    
    for worker_dir in "$WORKTREE_DIR"/worker-*; do
        if [[ -d "$worker_dir" ]]; then
            local worker_id=$(basename "$worker_dir" | sed 's/worker-//')
            
            log_info "Setting up worker $worker_id configuration..."
            
            # Create .claude directory if missing
            mkdir -p "$worker_dir/.claude"
            
            # Copy task instructions if they exist in worktree root
            if [[ -f "$WORKTREE_DIR/task-$worker_id.md" ]]; then
                cp "$WORKTREE_DIR/task-$worker_id.md" "$worker_dir/.claude/current-task.md"
            else
                log_warn "No task file found for worker $worker_id"
            fi
            
            # Clean up old files
            rm -f "$worker_dir/.claude/quick-start.sh"
            
            # Create setup files
            create_claude_setup "$worker_dir" "$worker_id"
            create_startup_prompt "$worker_dir" "$worker_id"
        fi
    done
    
    log_success "All existing worktrees configured!"
}

# Initialize worktrees
init_worktrees() {
    # Handle launch-only mode
    if $LAUNCH_ONLY; then
        if check_existing_worktrees; then
            log_info "Setting up and launching existing worktrees..."
            setup_existing_worktrees
            auto_launch_workers
            return
        else
            log_error "No existing worktrees found. Remove --launch-only flag to create new ones."
            exit 1
        fi
    fi
    
    # Check for existing worktrees when trying to create new ones
    if check_existing_worktrees; then
        log_warn "Existing worktrees detected!"
        log_info "Options:"
        log_info "1. Use --launch-only to launch existing worktrees"
        log_info "2. Use --cleanup first to remove existing worktrees"
        log_info "3. Continue anyway (may cause conflicts)"
        read -p "Continue with creation anyway? [y/N]: " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Aborted. Use --launch-only or --cleanup first."
            exit 0
        fi
    fi
    
    if [[ -z "$INSTRUCTIONS_FILE" ]]; then
        log_error "Instructions file is required for initialization"
        show_help
        exit 1
    fi
    
    if [[ ! -f "$INSTRUCTIONS_FILE" ]]; then
        log_error "Instructions file not found: $INSTRUCTIONS_FILE"
        exit 1
    fi
    
    log_info "Initializing $WORKER_COUNT parallel worktrees..."
    
    # Ensure clean state
    ensure_main_branch
    
    # Create worktree directory if it doesn't exist
    mkdir -p "$WORKTREE_DIR"
    
    # Split tasks
    log_info "Splitting tasks from $INSTRUCTIONS_FILE..."
    "$SCRIPT_DIR/task-splitter.sh" "$INSTRUCTIONS_FILE" "$WORKER_COUNT" "$WORKTREE_DIR"
    
    # Create worktrees
    for i in $(seq 1 $WORKER_COUNT); do
        local branch_name="${BRANCH_PREFIX}-$i"
        local worktree_path="$WORKTREE_DIR/worker-$i"
        
        log_info "Creating worktree $i: $branch_name"
        
        # Create worktree with new branch in one command
        git worktree add -b "$branch_name" "$worktree_path" main
        
        # Copy task instructions
        cp "$WORKTREE_DIR/task-$i.md" "$worktree_path/.claude/current-task.md"
        
        # Create Claude Code setup
        create_claude_setup "$worktree_path" "$i"
        
        # Create startup prompt
        create_startup_prompt "$worktree_path" "$i"
        
        log_success "Worktree $i ready at: $worktree_path"
    done
    
    # Return to main branch
    git checkout main
    
    log_success "All worktrees initialized!"
    
    if $AUTO_LAUNCH; then
        log_info "Auto-launching VS Code and Claude for each worker..."
        auto_launch_workers
    else
        log_info "Next steps:"
        log_info "Option A - Auto Launch (Easiest):"
        log_info "  Re-run with --auto-launch flag to automatically open VS Code and Claude"
        log_info ""
        log_info "Option B - Manual IDE Workflow:"
        log_info "  1. Open each worktree in your IDE: code worktrees/worker-N"
        log_info "  2. Run .claude/start-worker.sh in each terminal"
        log_info ""
        log_info "Option C - Manual Terminal Workflow:"
        log_info "  1. cd worktrees/worker-N && .claude/start-worker.sh"
        log_info ""
        log_info "3. Run '$0 --review' to check progress"
    fi
}

# Create Claude Code setup for worktree
create_claude_setup() {
    local worktree_path="$1"
    local worker_id="$2"
    
    mkdir -p "$worktree_path/.claude"
    
    cat > "$worktree_path/.claude/worker-context.md" << EOF
# Worker $worker_id Context

This is worker $worker_id of a parallel development session.

## Your Task
See \`.claude/current-task.md\` for your specific assignment.

## Important Notes
- Work only on your assigned task
- Test your changes before marking complete
- Create descriptive commits
- Avoid conflicts with other workers

## When Complete
1. Run verification scripts
2. Create a final commit
3. Return to main session for review

## Commands
\`\`\`bash
# Test your changes
npm run test
npm run build

# Create final commit
git add .
git commit -m "feat: Complete worker $worker_id task"
\`\`\`
EOF
}

# Create startup prompt for auto-launching workers
create_startup_prompt() {
    local worktree_path="$1"
    local worker_id="$2"
    
    # Create the readable startup prompt file
    cat > "$worktree_path/.claude/startup-prompt.txt" << EOF
I am Worker $worker_id in a parallel development session. Please start working on my assigned tasks.

My specific assignment is in .claude/current-task.md - please read this file and begin implementing the tasks assigned to me.

Key guidelines:
- Focus only on my assigned tasks
- Test changes before committing  
- Create descriptive commits
- Follow existing code patterns

Please begin by reading .claude/current-task.md and then start implementing my assigned tasks.
EOF

    # Create the enhanced command-line startup script
    cat > "$worktree_path/.claude/start-worker.sh" << EOF
#!/bin/bash
echo "🚀 Starting Worker $worker_id..."
echo "📋 Reading task assignment..."
echo "⚡ Launching Claude with full context..."
claude "I am Worker $worker_id in a parallel development session. Please start working on my assigned tasks. My specific assignment is in .claude/current-task.md - read this file and begin implementing the tasks assigned to me. Focus only on my assigned tasks, test changes before committing, create descriptive commits, and follow existing code patterns."
EOF
    chmod +x "$worktree_path/.claude/start-worker.sh"
}

# Create VS Code task for auto-starting Claude
create_vscode_task() {
    local worktree_path="$1"
    local worker_id="$2"
    
    mkdir -p "$worktree_path/.vscode"
    
    cat > "$worktree_path/.vscode/tasks.json" << EOF
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "Start Claude Worker $worker_id",
            "type": "shell",
            "command": "bash",
            "args": [".claude/auto-start.sh"],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "always",
                "focus": true,
                "panel": "new"
            },
            "problemMatcher": [],
            "runOptions": {
                "runOn": "folderOpen"
            }
        }
    ]
}
EOF
}

# Create VS Code settings for auto-terminal  
create_vscode_auto_terminal() {
    local worktree_path="$1"
    local worker_id="$2"
    
    mkdir -p "$worktree_path/.vscode"
    
    cat > "$worktree_path/.vscode/settings.json" << EOF
{
    "terminal.integrated.defaultProfile.linux": "bash"
}
EOF
}

# Auto-launch VS Code and Claude for all workers
auto_launch_workers() {
    log_info "Opening VS Code and auto-starting Claude for each worktree..."
    
    for worker_dir in "$WORKTREE_DIR"/worker-*; do
        if [[ -d "$worker_dir" ]]; then
            local worker_id=$(basename "$worker_dir" | sed 's/worker-//')
            
            log_info "Opening VS Code for worker $worker_id..."
            
            # Open VS Code for this worktree
            code "$worker_dir" &
            
            # Create VS Code configuration files
            create_vscode_task "$worker_dir" "$worker_id"
            create_vscode_auto_terminal "$worker_dir" "$worker_id"
            
            log_info "Auto-starting Claude for worker $worker_id..."
            
            # Create the Claude startup command with the full prompt
            local claude_prompt="I am Worker $worker_id in a parallel development session. Please start working on my assigned tasks. My specific assignment is in .claude/current-task.md - read this file and begin implementing the tasks assigned to me. Focus only on my assigned tasks, test changes before committing, create descriptive commits, and follow existing code patterns."
            
            # Create an auto-start script that VS Code can easily trigger
            cat > "$worker_dir/.claude/auto-start.sh" << EOF
#!/bin/bash
echo "🎯 Auto-starting Claude Worker $worker_id..."
echo "📂 Working directory: \$(pwd)"
echo "📋 Task file: .claude/current-task.md"
echo "⚡ Starting Claude with full context..."
echo ""
echo "🚀 Starting Worker $worker_id..."
echo "📋 Reading task assignment..."
echo "⚡ Launching Claude with full context..."
claude "$claude_prompt"
EOF
            chmod +x "$worker_dir/.claude/auto-start.sh"
            
            log_info "VS Code workspace configured for worker $worker_id"
            
            # Note: start-worker.sh is already created by create_startup_prompt function
            
            # Small delay between workers to avoid overwhelming the system
            sleep 2
        fi
    done
    
    log_success "All workers launched!"
    log_info "✅ VS Code windows opened for each worktree"
    log_info "✅ VS Code tasks configured to auto-start Claude on folder open"
    log_info "✅ Each worker will automatically read task assignments and begin work"
    log_info ""
    log_info "🎯 VS Code should auto-run 'Start Claude Worker N' task"
    log_info "📱 If Claude didn't auto-start, run: Ctrl+Shift+P → 'Tasks: Run Task' → 'Start Claude Worker N'"
    log_info "🚀 Or manually run: .claude/start-worker.sh in each terminal"
}

# Review worktrees
review_worktrees() {
    log_info "Reviewing parallel worktrees..."
    
    if [[ ! -d "$WORKTREE_DIR" ]]; then
        log_error "No worktrees found. Run with --instructions first."
        exit 1
    fi
    
    local all_ready=true
    
    for worker_dir in "$WORKTREE_DIR"/worker-*; do
        if [[ -d "$worker_dir" ]]; then
            local worker_id=$(basename "$worker_dir" | sed 's/worker-//')
            log_info "Checking worker $worker_id..."
            
            cd "$worker_dir"
            
            # Check git status
            if git diff --quiet && git diff --cached --quiet; then
                log_success "Worker $worker_id: Clean (no uncommitted changes)"
            else
                log_warn "Worker $worker_id: Has uncommitted changes"
                all_ready=false
            fi
            
            # Check if ahead of main
            local commits_ahead=$(git rev-list --count main..HEAD)
            if [[ $commits_ahead -gt 0 ]]; then
                log_info "Worker $worker_id: $commits_ahead commits ahead of main"
            else
                log_warn "Worker $worker_id: No commits made"
                all_ready=false
            fi
            
            cd "$PROJECT_ROOT"
        fi
    done
    
    if $all_ready; then
        log_success "All workers appear ready for merge!"
        log_info "Run '$0 --merge' to merge all changes"
    else
        log_warn "Some workers are not ready for merge"
        log_info "Complete work in worktrees before merging"
    fi
}

# Merge worktrees
merge_worktrees() {
    log_info "Merging parallel worktrees..."
    
    ensure_main_branch
    
    local merge_conflicts=false
    
    for worker_dir in "$WORKTREE_DIR"/worker-*; do
        if [[ -d "$worker_dir" ]]; then
            local worker_id=$(basename "$worker_dir" | sed 's/worker-//')
            local branch_name="${BRANCH_PREFIX}-$worker_id"
            
            log_info "Merging worker $worker_id (branch: $branch_name)..."
            
            # Attempt merge
            if git merge "$branch_name" --no-ff -m "feat: Merge parallel worker $worker_id"; then
                log_success "Worker $worker_id merged successfully"
            else
                log_error "Merge conflict in worker $worker_id"
                merge_conflicts=true
                # Abort the merge to continue with others
                git merge --abort
            fi
        fi
    done
    
    if $merge_conflicts; then
        log_error "Some merges had conflicts. Resolve manually:"
        log_info "1. git merge ${BRANCH_PREFIX}-<worker-id>"
        log_info "2. Resolve conflicts"
        log_info "3. git commit"
        log_info "4. Repeat for each conflicted worker"
    else
        log_success "All workers merged successfully!"
        log_info "Run '$0 --cleanup' to remove worktrees"
    fi
}

# Cleanup worktrees
cleanup_worktrees() {
    log_info "Cleaning up parallel worktrees..."
    
    if [[ ! -d "$WORKTREE_DIR" ]]; then
        log_warn "No worktrees directory found"
        return
    fi
    
    # Remove worktrees
    for worker_dir in "$WORKTREE_DIR"/worker-*; do
        if [[ -d "$worker_dir" ]]; then
            local worker_id=$(basename "$worker_dir" | sed 's/worker-//')
            local branch_name="${BRANCH_PREFIX}-$worker_id"
            
            log_info "Removing worktree $worker_id..."
            git worktree remove "$worker_dir" --force || true
            git branch -D "$branch_name" || true
        fi
    done
    
    # Remove worktree directory
    rm -rf "$WORKTREE_DIR"
    
    log_success "Cleanup complete!"
}

# Main execution
main() {
    check_git_repo
    
    case $MODE in
        "init")
            init_worktrees
            ;;
        "review")
            review_worktrees
            ;;
        "merge")
            merge_worktrees
            ;;
        "cleanup")
            cleanup_worktrees
            ;;
        *)
            log_error "Unknown mode: $MODE"
            show_help
            exit 1
            ;;
    esac
}

# Source utilities
source "$SCRIPT_DIR/worktree-utils.sh"

# Run main function
main "$@"