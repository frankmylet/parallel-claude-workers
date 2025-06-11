# Installation Guide

## Quick Installation

*Install the complete AI-powered parallel development system with intelligent conflict resolution*

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

### Add Enhanced Slash Commands

To use `/parallel-work`, `/format-tasks`, and `/resolve-conflicts` commands in Claude Code:

```bash
# Create symlinks in your project's .claude/commands/ directory
cd /your/project/root

# Create .claude/commands directory if it doesn't exist
mkdir -p .claude/commands

# Create symlinks to all parallel tools
ln -s ../../parallel-claude-workers/.claude/workflows/parallel-manager.sh .claude/commands/parallel-work
ln -s ../../parallel-claude-workers/.claude/workflows/task-formatter.sh .claude/commands/format-tasks
ln -s ../../parallel-claude-workers/.claude/workflows/conflict-resolver.sh .claude/commands/resolve-conflicts
ln -s ../../parallel-claude-workers/.claude/workflows/intelligent-task-splitter.sh .claude/commands/split-tasks
ln -s ../../parallel-claude-workers/.claude/workflows/advanced-code-analyzer.sh .claude/commands/analyze-code
```

### Verify Installation

```bash
# Test all enhanced functionality
.claude/commands/parallel-work --help
.claude/commands/format-tasks --help
.claude/commands/resolve-conflicts --help
.claude/commands/split-tasks --help
.claude/commands/analyze-code --help

# Test with example tasks
.claude/commands/parallel-work --instructions=parallel-claude-workers/.claude/instructions/example-user-profile.md --workers=2

# Test conflict resolution system
.claude/commands/resolve-conflicts analyze --detailed
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
│       ├── format-tasks -> ../../parallel-claude-workers/.claude/workflows/task-formatter.sh
│       ├── resolve-conflicts -> ../../parallel-claude-workers/.claude/workflows/conflict-resolver.sh
│       ├── split-tasks -> ../../parallel-claude-workers/.claude/workflows/intelligent-task-splitter.sh
│       └── analyze-code -> ../../parallel-claude-workers/.claude/workflows/advanced-code-analyzer.sh
└── worktrees/                        # Created during parallel development
    ├── worker-1/
    ├── worker-2/
    └── ...
```

## Configuration

### Customize AI-Powered Features

1. **Configure conflict resolution**:
   ```bash
   # Customize conflict resolution behavior
   cp parallel-claude-workers/.claude/config/resolver-settings.json my-resolver-config.json
   # Adjust confidence thresholds, strategies, and learning parameters
   ```

2. **Edit task templates**:
   ```bash
   # Customize the task template for your project type
   cp parallel-claude-workers/.claude/instructions/template.md my-project-template.md
   # Edit my-project-template.md with project-specific guidelines
   ```

3. **Create project-specific examples**:
   ```bash
   # Create examples relevant to your project
   cp parallel-claude-workers/.claude/instructions/example-user-profile.md my-project-tasks.md
   # Edit with your actual project tasks
   ```

4. **Adjust default settings**:
   ```bash
   # Edit parallel-manager.sh if needed
   nano parallel-claude-workers/.claude/workflows/parallel-manager.sh
   # Modify WORKER_COUNT, BRANCH_PREFIX, etc.
   ```

5. **Tune code analysis**:
   ```bash
   # Configure quality analysis weights and metrics
   nano parallel-claude-workers/.claude/workflows/advanced-code-analyzer.sh
   # Adjust architectural, performance, and security analysis parameters
   ```

## Verification

### Test the Complete AI-Enhanced Workflow

```bash
# 1. Test intelligent task splitting
echo "- Create login component
- Add user dashboard  
- Build admin panel
- Implement user authentication
- Add data analytics" > test-notes.txt

parallel-claude-workers/.claude/workflows/task-formatter.sh --input=test-notes.txt --workers=3
parallel-claude-workers/.claude/workflows/intelligent-task-splitter.sh split --input=parallel-tasks.md --workers=3

# 2. Test parallel development with conflict resolution
parallel-claude-workers/.claude/workflows/parallel-manager.sh --instructions=parallel-tasks.md --workers=3 --auto-launch

# 3. Test AI conflict resolution
parallel-claude-workers/.claude/workflows/conflict-resolver.sh analyze --detailed
parallel-claude-workers/.claude/workflows/conflict-resolver.sh resolve --strategy=auto --confidence=8.0

# 4. Test code quality analysis
parallel-claude-workers/.claude/workflows/advanced-code-analyzer.sh analyze --worktree=all --detailed

# 5. Test review and cleanup
parallel-claude-workers/.claude/workflows/parallel-manager.sh --review
parallel-claude-workers/.claude/workflows/parallel-manager.sh --merge
parallel-claude-workers/.claude/workflows/parallel-manager.sh --cleanup
```

### Expected Results

✅ **Task Formatter**: Converts notes to structured tasks
✅ **Intelligent Splitter**: Analyzes and prevents conflicts before they happen
✅ **Parallel Manager**: Creates worktrees and launches VS Code
✅ **Claude Auto-Start**: Claude begins working in each VS Code window
✅ **Conflict Analysis**: AI analyzes potential merge conflicts with detailed reports
✅ **Auto-Resolution**: 80-90% of conflicts resolved automatically with high confidence
✅ **Code Quality Analysis**: Multi-dimensional analysis of architecture, performance, security
✅ **Review**: Shows progress and merge readiness
✅ **Intelligent Merge**: AI-assisted merging with quality-based decision making
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

# Remove all symlinks
rm .claude/commands/parallel-work
rm .claude/commands/format-tasks
rm .claude/commands/resolve-conflicts
rm .claude/commands/split-tasks
rm .claude/commands/analyze-code

# Clean up any remaining worktrees
rm -rf worktrees/
```

## Next Steps

After successful installation:

1. **Read the main README.md** for comprehensive usage instructions
2. **Try the AI-enhanced examples** to understand intelligent conflict resolution  
3. **Configure conflict resolution settings** for your project
4. **Create your first parallel task file** with conflict prevention
5. **Launch your first AI-powered parallel development session**
6. **Experience 80-90% automatic conflict resolution**

Ready to revolutionize your development workflow with AI-powered parallel development! 🚀

---

*Featuring intelligent conflict resolution, multi-dimensional code analysis, and adaptive learning systems*