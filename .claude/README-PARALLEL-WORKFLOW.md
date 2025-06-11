# Parallel Development Workflow

A comprehensive system for managing parallel development tasks using git worktrees and Claude Code agents.

## ✅ Fully Working Quick Start

1. **Create task instructions file**
2. **Auto-launch parallel workers** 
3. **Claude automatically starts in all VS Code instances**
4. **Review and merge**

### ⚡ One-Command Automation

```bash
# Create and auto-launch everything
.claude/workflows/parallel-manager.sh --instructions=tasks.md --workers=4 --auto-launch

# Or launch existing worktrees
.claude/workflows/parallel-manager.sh --launch-only
```

**Result**: 4 VS Code windows open, each with Claude automatically working on assigned tasks! 🚀

## Complete Workflow Example

### Step 1: Create Task Instructions

Create a task file using the template:

```bash
# Copy template and customize
cp .claude/instructions/template.md .claude/instructions/my-feature.md
```

Edit the file with your specific tasks:

```markdown
# Task Set: User Profile Enhancement

## Overview
Implement comprehensive user profile features...

## Tasks
### Task 1: Profile Component
- Create UserProfile.tsx
- Add avatar upload
- Implement edit functionality

### Task 2: Profile API
- Add profile endpoints
- Implement data validation
- Add profile image storage

### Task 3: Integration
- Connect frontend to API
- Add error handling
- Write comprehensive tests
```

### Step 2: Auto-Launch Parallel Development

```bash
# Create and auto-launch 3 parallel worktrees
.claude/workflows/parallel-manager.sh --instructions=.claude/instructions/my-feature.md --workers=3 --auto-launch
```

This creates:
- `worktrees/worker-1/` - Gets Task 1
- `worktrees/worker-2/` - Gets Task 2  
- `worktrees/worker-3/` - Gets Task 3

### Step 3: Auto-Launch (Recommended)

**Fully Automated Setup:**
```bash
# Create and auto-launch 3 parallel worktrees
.claude/workflows/parallel-manager.sh --instructions=.claude/instructions/my-feature.md --workers=3 --auto-launch

# Or launch existing worktrees
.claude/workflows/parallel-manager.sh --launch-only
```

This will automatically:
- ✅ Open VS Code for each worktree
- ✅ Configure VS Code tasks for easy Claude startup
- ✅ Create quick-start scripts
- ✅ Set up terminal integration

**Manual Setup (Alternative):**
```bash
# Open each worktree in your IDE
code worktrees/worker-1
code worktrees/worker-2  
code worktrees/worker-3
```

### Step 4: Start Claude Workers

**In each VS Code window, you have 3 easy options:**

**🚀 Option 1: VS Code Task (Easiest)**
- Look for VS Code notification: "Start Claude Worker N" 
- Click the task to run automatically
- Or: `Ctrl+Shift+P` → "Tasks: Run Task" → "Start Claude Worker N"

**⚡ Option 2: Quick Start Script**
```bash
# In each VS Code integrated terminal:
.claude/quick-start.sh
```

**📋 Option 3: Manual Start**
```bash
# In each VS Code integrated terminal:
.claude/start-worker.sh
```

**What happens when Claude starts:**
Each worker automatically receives this prompt:
```
I am Worker N in a parallel development session. Please start working on my assigned tasks.

My specific assignment is in .claude/current-task.md - read this file and begin implementing the tasks assigned to me.

Key guidelines:
- Focus only on my assigned tasks
- Test changes before committing  
- Create descriptive commits
- Follow existing code patterns

Please begin by reading .claude/current-task.md and then start implementing my assigned tasks.
```

### Step 5: Review Progress

```bash
# Check status of all workers
.claude/workflows/parallel-manager.sh --review
```

Output shows:
- Worker completion status
- Uncommitted changes
- Commits made
- Ready for merge status

### Step 6: Merge Results

```bash
# Merge all completed work
.claude/workflows/parallel-manager.sh --merge
```

Handles:
- Sequential merging of branches
- Conflict detection
- Merge conflict guidance

### Step 7: Cleanup

```bash
# Remove worktrees and branches
.claude/workflows/parallel-manager.sh --cleanup
```

## Advanced Usage

### All Command Options

```bash
# Full auto-launch with custom settings
.claude/workflows/parallel-manager.sh \
  --instructions=tasks.md \
  --workers=3 \
  --auto-launch \
  --branch-prefix=feature-auth

# Launch existing worktrees only
.claude/workflows/parallel-manager.sh --launch-only

# Create without auto-launch (manual setup)
.claude/workflows/parallel-manager.sh --instructions=tasks.md --workers=3
```

### Working with Different Worker Counts

```bash
# 2 workers (tasks split between 2 workers)
.claude/workflows/parallel-manager.sh --instructions=tasks.md --workers=2 --auto-launch

# 5 workers (some workers may get fewer tasks)  
.claude/workflows/parallel-manager.sh --instructions=tasks.md --workers=5 --auto-launch
```

### VS Code Integration Features

Each worktree gets:
- **VS Code Tasks**: Easy one-click Claude startup
- **Quick Start Scripts**: `.claude/quick-start.sh` for instant launch
- **Terminal Integration**: Ready-to-run commands
- **Workspace Settings**: Optimized for parallel development

### Review Mode Features

```bash
.claude/workflows/parallel-manager.sh --review
```

Shows:
- ✅ Worker 1: Clean, 3 commits ahead
- ⚠️ Worker 2: Has uncommitted changes
- ❌ Worker 3: No commits made

### Merge Conflict Resolution

If conflicts occur during merge:

1. **Automatic conflict detection**
2. **Conflict resolution guide created**
3. **Manual resolution steps provided**

```bash
# Check conflicts
git status

# Resolve manually
# Edit conflicted files
# Remove <<<<<<< ======= >>>>>>> markers

# Complete merge
git add .
git commit -m "resolve: Merge conflicts from parallel work"
```

## File Structure

```
.claude/
├── commands/
│   └── parallel-work.md              # Command documentation
├── workflows/
│   ├── parallel-manager.sh           # Main workflow script
│   ├── task-splitter.sh             # Task distribution logic
│   └── worktree-utils.sh            # Utility functions
└── instructions/
    ├── template.md                   # Task instruction template
    ├── example-user-profile.md       # Example: User features
    └── example-inventory-features.md # Example: Inventory features

worktrees/                            # Created during workflow
├── worker-1/                        # Worktree for worker 1
│   ├── .claude/
│   │   ├── current-task.md          # Worker 1's assignment
│   │   └── worker-context.md        # Worker-specific guidance
│   └── [project files...]
├── worker-2/                        # Worktree for worker 2
└── worker-3/                        # Worktree for worker 3
```

## Best Practices

### 1. Task Design
- Make tasks independent when possible
- Balance complexity across workers
- Include clear deliverables and acceptance criteria
- Specify testing requirements

### 2. During Development
- Stay focused on assigned tasks
- Communicate through git commits
- Test thoroughly before marking complete
- Follow project coding standards

### 3. Merge Strategy
- Review all workers before merging
- Resolve conflicts carefully
- Test merged result
- Keep main branch stable

### 4. Conflict Prevention
- Avoid editing the same files when possible
- Use different directories/modules per worker
- Coordinate on shared resources
- Communicate through task instructions

## Troubleshooting

### Common Issues

**"Worktree already exists"**
```bash
.claude/workflows/parallel-manager.sh --cleanup
# Then retry initialization
```

**"Merge conflicts"**
```bash
# Check conflict guide in worker directory
cat worktrees/worker-N/.claude/conflict-resolution.md
```

**"Tests failing after merge"**
```bash
# Run tests in main branch after merge
npm test
npm run build
```

**"Worker has no tasks"**
- This happens when you have more workers than tasks
- Workers without tasks get a "no tasks assigned" message
- Consider reducing worker count or adding more tasks

### Recovery Commands

```bash
# Reset if something goes wrong
git checkout main
.claude/workflows/parallel-manager.sh --cleanup

# Remove specific worktree manually
git worktree remove worktrees/worker-1 --force
git branch -D parallel-task-1

# Check worktree status
git worktree list
```

## Integration with Claude Code

### Slash Command Integration

Add to your Claude Code slash commands:

```bash
# In your .claude/commands/ directory
ln -s ../workflows/parallel-manager.sh parallel-work

# Then use in Claude Code:
/parallel-work --instructions=my-tasks.md --workers=3
```

### Worker Context

Each worker gets specialized context:
- Task assignment in `.claude/current-task.md`
- Worker guidance in `.claude/worker-context.md`
- Conflict resolution help when needed

### Verification Integration

Workers can use existing verification scripts:
```bash
# Each worker can run
npm run test
npm run build
npm run lint
```

## Examples

See the `.claude/instructions/` directory for complete examples:
- `example-user-profile.md` - User management features
- `example-inventory-features.md` - Inventory system enhancements

These demonstrate proper task breakdown and parallel development planning.