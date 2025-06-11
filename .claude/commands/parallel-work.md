# Parallel Worktree Workflow

A system for managing parallel development tasks using git worktrees and Claude Code agents.

## Usage

```bash
# Create worktrees and assign tasks
/parallel-work --instructions=task-instructions.md --workers=3

# Review and merge completed work
/parallel-work --review --merge

# Cleanup worktrees
/parallel-work --cleanup
```

## Arguments

- `--instructions=<file>` - Path to task instructions file (required)
- `--workers=<number>` - Number of worktrees to create (default: 3)
- `--review` - Review mode: check worktree status and prepare for merge
- `--merge` - Merge completed worktrees back to main
- `--cleanup` - Remove all worktrees and cleanup
- `--branch-prefix=<prefix>` - Custom branch prefix (default: parallel-task)

## Workflow Overview

1. **Initialize**: Creates N worktrees with unique branches
2. **Distribute**: Splits task instructions across workers
3. **Execute**: Run Claude Code in each worktree directory
4. **Review**: Check status, conflicts, and readiness
5. **Merge**: Merge completed work back to main branch
6. **Cleanup**: Remove temporary worktrees

## File Structure

```
.claude/
├── commands/
│   └── parallel-work.md (this file)
├── workflows/
│   ├── parallel-manager.sh
│   ├── task-splitter.sh
│   ├── review-merger.sh
│   └── worktree-utils.sh
└── instructions/
    ├── template.md
    └── example-tasks.md
```

## Task Instructions Format

Task instruction files should follow this structure:

```markdown
# Task Set: Feature Implementation

## Overview
Brief description of the overall goal

## Tasks
### Task 1: Component Creation
- Create UserProfile component
- Add TypeScript interfaces
- Write basic tests

### Task 2: API Integration
- Implement user API endpoints
- Add error handling
- Update documentation

### Task 3: UI Integration
- Connect component to API
- Add loading states
- Style with Tailwind
```

## Example Commands

```bash
# Start 3-way parallel development
/parallel-work --instructions=.claude/instructions/user-profile-tasks.md --workers=3

# Review progress
/parallel-work --review

# Merge when ready
/parallel-work --merge

# Cleanup after merge
/parallel-work --cleanup
```