# Parallel Claude Workers

**Automate parallel development with Claude Code and git worktrees**

Turn any complex development task into parallel work streams where multiple Claude instances work simultaneously on different parts of your project.

## ✨ Features

- **🚀 One-command setup** - Create multiple git worktrees and launch Claude in each
- **⚡ Full automation** - VS Code opens, Claude starts, work begins immediately
- **📋 Smart task splitting** - Automatically distributes work among workers
- **🔄 Built-in review** - Check progress, merge conflicts, cleanup
- **📝 Task formatting** - Convert rough notes into structured parallel tasks

## 🎯 Quick Start

### 1. Install

Copy this directory to your project root:
```bash
cp -r parallel-claude-workers /path/to/your/project/
cd /path/to/your/project
```

### 2. Create Tasks

**Option A: Use existing examples**
```bash
# Use provided examples
.claude/workflows/parallel-manager.sh --instructions=.claude/instructions/example-user-profile.md --workers=3 --auto-launch
```

**Option B: Format your rough notes**
```bash
# Convert unformatted notes to structured tasks
.claude/workflows/task-formatter.sh --input=my-notes.txt --workers=4
.claude/workflows/parallel-manager.sh --instructions=parallel-tasks.md --workers=4 --auto-launch
```

**Option C: Create custom tasks**
```bash
# Copy template and customize
cp .claude/instructions/template.md my-feature-tasks.md
# Edit my-feature-tasks.md with your specific tasks
.claude/workflows/parallel-manager.sh --instructions=my-feature-tasks.md --workers=3 --auto-launch
```

### 3. Watch the Magic

**Result**: Multiple VS Code windows open, each with Claude automatically working on different parts of your project! 🎉

## 📖 Complete Workflow

### Task Formatting (Optional)

If you have rough notes or unstructured requirements:

```bash
# Interactive mode
.claude/workflows/task-formatter.sh --interactive --workers=4

# From notes file  
.claude/workflows/task-formatter.sh --input=my-rough-notes.txt --workers=3
```

**Input example:**
```
- Need user authentication
- Profile management  
- Dashboard with stats
- Admin panel features
- Tests for everything
```

**Output**: Structured tasks ready for parallel development!

### Parallel Development

```bash
# Create and auto-launch everything
.claude/workflows/parallel-manager.sh --instructions=tasks.md --workers=4 --auto-launch
```

**What happens:**
1. **4 git worktrees** created with unique branches
2. **4 VS Code windows** open automatically  
3. **4 Claude instances** start and begin working
4. **Each worker** gets specific task assignments

### Review and Merge

```bash
# Check progress
.claude/workflows/parallel-manager.sh --review

# Merge when ready
.claude/workflows/parallel-manager.sh --merge

# Clean up
.claude/workflows/parallel-manager.sh --cleanup
```

## 🛠️ Commands Reference

### Parallel Manager

```bash
# Full workflow commands
.claude/workflows/parallel-manager.sh --instructions=FILE --workers=N [--auto-launch]
.claude/workflows/parallel-manager.sh --launch-only
.claude/workflows/parallel-manager.sh --review
.claude/workflows/parallel-manager.sh --merge
.claude/workflows/parallel-manager.sh --cleanup
```

### Task Formatter

```bash
# Format unstructured notes
.claude/workflows/task-formatter.sh --input=FILE [--workers=N] [--output=FILE]
.claude/workflows/task-formatter.sh --interactive --workers=N
```

### Claude Code Integration

```bash
# Use as slash commands (symlink to .claude/commands/)
/parallel-work --instructions=tasks.md --workers=4 --auto-launch
/format-tasks --input=notes.txt --workers=3
```

## 📁 File Structure

```
parallel-claude-workers/
├── README.md                    # This file
├── INSTALLATION.md             # Setup instructions
└── .claude/
    ├── commands/
    │   ├── parallel-work.md     # Parallel development command
    │   └── format-tasks.md      # Task formatting command
    ├── workflows/
    │   ├── parallel-manager.sh  # Main workflow engine
    │   ├── task-formatter.sh    # Task formatting tool
    │   └── worktree-utils.sh    # Utility functions
    └── instructions/
        ├── template.md          # Task instruction template
        ├── example-user-profile.md
        └── example-ecommerce-features.md
```

## 🔧 Configuration

### Customize for Your Project

Edit these files to match your project:

**`.claude/instructions/template.md`** - Modify the task template structure
**`.claude/workflows/parallel-manager.sh`** - Adjust default settings
**Examples** - Create project-specific task examples

### VS Code Integration

Each worktree gets:
- **Auto-launching tasks** - Claude starts when VS Code opens
- **Terminal integration** - Ready-to-run commands
- **Workspace settings** - Optimized for parallel development

## 📝 Task Writing Tips

### Good Parallel Tasks

✅ **Independent** - Can be completed without waiting for others
✅ **Balanced** - Roughly equal complexity and time
✅ **Specific** - Clear deliverables and acceptance criteria
✅ **Testable** - Include testing requirements

### Task Examples

```markdown
### Task 1: User Authentication Component
- Create LoginForm.tsx with email/password validation
- Add error handling and loading states  
- Implement secure authentication flow
- Write unit tests with 90%+ coverage

### Task 2: User Registration API  
- Build registration endpoints in userController.ts
- Add email verification workflow
- Implement validation and error responses
- Create integration tests for all endpoints
```

## 🚀 Advanced Usage

### Large Projects

```bash
# Split into 6 parallel workers
.claude/workflows/parallel-manager.sh --instructions=big-feature.md --workers=6 --auto-launch
```

### Multiple Feature Sets

```bash
# Work on different features in parallel
.claude/workflows/parallel-manager.sh --instructions=auth-tasks.md --workers=3 --branch-prefix=feature-auth --auto-launch
.claude/workflows/parallel-manager.sh --instructions=ui-tasks.md --workers=2 --branch-prefix=feature-ui --auto-launch
```

### Custom Workflows

```bash
# Format -> Launch -> Review cycle
.claude/workflows/task-formatter.sh --input=requirements.txt --workers=4
.claude/workflows/parallel-manager.sh --instructions=parallel-tasks.md --workers=4 --auto-launch
# ... work happens ...
.claude/workflows/parallel-manager.sh --review
.claude/workflows/parallel-manager.sh --merge
```

## 🛟 Troubleshooting

### Common Issues

**"No worktrees found"**
- Run with `--instructions` flag first to create worktrees

**"VS Code didn't auto-start Claude"**  
- Manual: `Ctrl+Shift+P` → "Tasks: Run Task" → "Start Claude Worker N"
- Or run: `.claude/start-worker.sh` in VS Code terminal

**"Merge conflicts"**
- Check `.claude/conflict-resolution.md` in affected worktree
- Resolve manually then continue merge

**"Extension wants to relaunch terminal"**
- Click "Allow" - this is normal VS Code extension behavior

### Getting Help

1. Check the troubleshooting section in main README
2. Review example task files for proper format
3. Test with smaller worker count first (2-3 workers)

## 🎉 Success Stories

After setup, you should see:
- **Multiple VS Code windows** each working on different features
- **Parallel development** happening simultaneously  
- **Faster iteration** on complex projects
- **Better organization** of large tasks

**Ready to revolutionize your development workflow!** 🚀