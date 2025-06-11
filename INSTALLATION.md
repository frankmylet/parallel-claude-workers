# Installation Guide

## Quick Installation

### Method 1: Copy to Any Project

```bash
# Copy the parallel-claude-workers directory to your project
cp -r /path/to/parallel-claude-workers /your/project/root/
cd /your/project/root

# Make scripts executable
chmod +x parallel-claude-workers/.claude/workflows/*.sh

# Test installation
parallel-claude-workers/.claude/workflows/parallel-manager.sh --help
```

### Method 2: Clone from Repository

```bash
# Clone to your project root
cd /your/project/root
git clone [repository-url] parallel-claude-workers
cd parallel-claude-workers
chmod +x .claude/workflows/*.sh
```

## Setup for Claude Code Integration

### Add Slash Commands

To use `/parallel-work` and `/format-tasks` commands in Claude Code:

```bash
# Create symlinks in your project's .claude/commands/ directory
cd /your/project/root

# Create .claude/commands directory if it doesn't exist
mkdir -p .claude/commands

# Create symlinks to the parallel tools
ln -s ../../parallel-claude-workers/.claude/workflows/parallel-manager.sh .claude/commands/parallel-work
ln -s ../../parallel-claude-workers/.claude/workflows/task-formatter.sh .claude/commands/format-tasks
```

### Verify Installation

```bash
# Test basic functionality
.claude/commands/parallel-work --help
.claude/commands/format-tasks --help

# Test with example tasks
.claude/commands/parallel-work --instructions=parallel-claude-workers/.claude/instructions/example-user-profile.md --workers=2
```

## Project Structure After Installation

```
your-project/
├── your-existing-files...
├── parallel-claude-workers/          # The parallel development system
│   ├── README.md
│   ├── INSTALLATION.md
│   └── .claude/
│       ├── commands/
│       ├── workflows/
│       └── instructions/
├── .claude/                           # Your project's Claude Code config
│   └── commands/
│       ├── parallel-work -> ../../parallel-claude-workers/.claude/workflows/parallel-manager.sh
│       └── format-tasks -> ../../parallel-claude-workers/.claude/workflows/task-formatter.sh
└── worktrees/                        # Created during parallel development
    ├── worker-1/
    ├── worker-2/
    └── ...
```

## Configuration

### Customize for Your Project

1. **Edit task templates**:
   ```bash
   # Customize the task template for your project type
   cp parallel-claude-workers/.claude/instructions/template.md my-project-template.md
   # Edit my-project-template.md with project-specific guidelines
   ```

2. **Create project-specific examples**:
   ```bash
   # Create examples relevant to your project
   cp parallel-claude-workers/.claude/instructions/example-user-profile.md my-project-tasks.md
   # Edit with your actual project tasks
   ```

3. **Adjust default settings**:
   ```bash
   # Edit parallel-manager.sh if needed
   nano parallel-claude-workers/.claude/workflows/parallel-manager.sh
   # Modify WORKER_COUNT, BRANCH_PREFIX, etc.
   ```

## Verification

### Test the Complete Workflow

```bash
# 1. Test task formatting
echo "- Create login component
- Add user dashboard  
- Build admin panel" > test-notes.txt

parallel-claude-workers/.claude/workflows/task-formatter.sh --input=test-notes.txt --workers=3

# 2. Test parallel development
parallel-claude-workers/.claude/workflows/parallel-manager.sh --instructions=parallel-tasks.md --workers=3 --auto-launch

# 3. Test review and cleanup
parallel-claude-workers/.claude/workflows/parallel-manager.sh --review
parallel-claude-workers/.claude/workflows/parallel-manager.sh --cleanup
```

### Expected Results

✅ **Task Formatter**: Converts notes to structured tasks
✅ **Parallel Manager**: Creates worktrees and launches VS Code
✅ **Claude Auto-Start**: Claude begins working in each VS Code window
✅ **Review**: Shows progress and merge readiness
✅ **Cleanup**: Removes worktrees and branches

## Troubleshooting Installation

### Permission Issues

```bash
# Fix script permissions
chmod +x parallel-claude-workers/.claude/workflows/*.sh
```

### Path Issues

```bash
# Use absolute paths if relative paths don't work
/full/path/to/parallel-claude-workers/.claude/workflows/parallel-manager.sh --help
```

### Git Issues

```bash
# Ensure you're in a git repository
git status

# Initialize git if needed
git init
```

### VS Code Issues

```bash
# Ensure VS Code command is available
code --version

# Install VS Code command if missing
# (Instructions vary by OS)
```

## Uninstallation

```bash
# Remove parallel development system
rm -rf parallel-claude-workers/

# Remove symlinks
rm .claude/commands/parallel-work
rm .claude/commands/format-tasks

# Clean up any remaining worktrees
rm -rf worktrees/
```

## Next Steps

After successful installation:

1. **Read the main README.md** for usage instructions
2. **Try the examples** to understand the workflow  
3. **Create your first parallel task file**
4. **Launch your first parallel development session**

Ready to revolutionize your development workflow! 🚀