# Parallel Claude Workers - Internal Documentation

This directory contains the core parallel development system.

## Directory Structure

```
.claude/
├── commands/           # Claude Code slash command documentation
│   ├── parallel-work.md
│   └── format-tasks.md
├── workflows/          # Executable scripts
│   ├── parallel-manager.sh    # Main workflow engine
│   ├── task-formatter.sh      # Task formatting tool
│   └── worktree-utils.sh      # Helper functions
└── instructions/       # Task templates and examples
    ├── template.md
    ├── example-user-profile.md
    └── example-ecommerce-features.md
```

## Core Components

### parallel-manager.sh
- **Purpose**: Main workflow orchestrator
- **Functions**: Create worktrees, launch VS Code, manage Claude instances
- **Modes**: `--auto-launch`, `--launch-only`, `--review`, `--merge`, `--cleanup`

### task-formatter.sh  
- **Purpose**: Convert unformatted notes to structured tasks
- **Input**: Raw text files or interactive input
- **Output**: Properly formatted task files for parallel development

### worktree-utils.sh
- **Purpose**: Helper functions for git worktree management
- **Functions**: Status checking, conflict detection, validation

## Integration Points

### Claude Code
- Slash commands in `/commands/` directory
- Auto-launching Claude with formatted prompts
- VS Code task integration

### Git Worktrees
- Isolated development environments
- Branch management and merging
- Conflict resolution guidance

### VS Code
- Automatic workspace configuration
- Task-based Claude launching
- Terminal integration

## Customization

### Adding New Features
1. Add functions to appropriate script
2. Update help documentation
3. Test with various scenarios

### Project-Specific Adaptation
1. Modify templates in `instructions/`
2. Adjust default settings in scripts
3. Create project-specific examples

This system provides the foundation for scalable parallel development workflows.