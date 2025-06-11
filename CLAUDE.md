# Parallel Claude Workers - Project Context

## Tool Safety Rules
- **NEVER delete this directory** - it's project-specific installation
- **Use cleanup commands** instead of manual worktree deletion
- **Tool operates on current project** git repository, not external repos
- **Each project gets its own copy** of this tool

## Core Commands

### Parallel Development
```bash
# Full workflow with AI conflict resolution
.claude/workflows/parallel-manager.sh --instructions=FILE --workers=N --auto-launch

# Intelligent task splitting (prevents conflicts)
.claude/workflows/intelligent-task-splitter.sh split --input=FILE --workers=N

# Format unstructured notes into tasks
.claude/workflows/task-formatter.sh --input=FILE --workers=N
```

### AI Conflict Resolution (80-90% Success Rate)
```bash
# Auto-resolve conflicts with confidence scoring
.claude/workflows/conflict-resolver.sh resolve --strategy=auto --confidence=8.0

# Analyze conflicts before resolution
.claude/workflows/conflict-resolver.sh analyze --detailed

# Quick resolution for common conflicts
.claude/workflows/quick-resolver.sh resolve --worktree=NAME
```

### Code Quality Analysis
```bash
# Advanced multi-dimensional analysis
.claude/workflows/advanced-code-analyzer.sh analyze --worktree=NAME --detailed

# Basic quality metrics
.claude/workflows/code-analyzer.sh analyze --file=PATH --metrics=all
```

### Proper Cleanup (CRITICAL)
```bash
# ALWAYS use this instead of manual deletion
.claude/workflows/parallel-manager.sh --cleanup

# Manual git cleanup if needed (safer than rm -rf)
git worktree list              # Check existing worktrees
git worktree prune             # Remove broken references
git branch -D worker-*         # Delete worker branches
```

## Slash Commands Available
```bash
/parallel-work --instructions=tasks.md --workers=4 --auto-launch
/resolve-conflicts resolve --strategy=auto --confidence=8.0
/format-tasks --input=notes.txt --workers=3
/split-tasks --input=requirements.md --workers=4
/analyze-code --worktree=NAME --detailed
```

## Safety Patterns

### ✅ DO
- Use `--cleanup` flag for proper cleanup
- Review conflict analysis before auto-resolution
- Backup important work before major merges
- Run `.claude/workflows/conflict-validator.sh` after resolutions
- Use confidence thresholds (8.0+ for auto-resolve)

### ❌ DON'T
- Never manually delete worktrees/ directory without git cleanup
- Don't delete the entire parallel-claude-workers/ directory
- Don't ignore conflict analysis warnings
- Don't auto-resolve with confidence below 6.0 without review

## Intelligent Features

### Conflict Resolution Capabilities
- **TypeScript exports**: Auto-merges index files (Confidence: 9.0+)
- **React components**: Quality-based selection (Confidence: 7.5+)
- **API endpoints**: Intelligent routing decisions (Confidence: 8.0+)
- **CSS/Styles**: Smart rule merging (Confidence: 6.5+)
- **JSON configs**: Object merging (Confidence: 8.5+)

### Learning System
- **Adapts to preferences**: Learns from user choices
- **Project patterns**: Remembers coding conventions
- **Quality priorities**: Adjusts scoring based on feedback
- **Confidence tuning**: Improves with continued use

## Installation Status in This Project
- Installed: ✅
- Slash commands configured: ✅
- Git worktree support: ✅
- AI conflict resolution: ✅
- Code analysis engine: ✅

## Quick Workflow Example
```bash
# 1. Format rough notes
/format-tasks --input=requirements.txt --workers=4

# 2. Split tasks intelligently  
/split-tasks --input=parallel-tasks.md --workers=4

# 3. Launch parallel development
/parallel-work --instructions=parallel-tasks.md --workers=4 --auto-launch

# 4. Auto-resolve conflicts as they occur
/resolve-conflicts resolve --strategy=auto --confidence=8.0

# 5. Validate and merge
.claude/workflows/conflict-validator.sh validate --worktree=all
.claude/workflows/parallel-manager.sh --merge

# 6. Clean up properly
.claude/workflows/parallel-manager.sh --cleanup
```

## Troubleshooting

### Common Issues
- **"No worktrees found"**: Run with `--instructions` flag first
- **"Conflict resolution failed"**: Lower confidence or use manual resolution
- **"VS Code didn't auto-start"**: Use manual task runner or terminal commands

### Emergency Recovery
```bash
# If tool seems broken, reset git state
git worktree prune
git branch -D worker-*
rm -rf worktrees/
# Then restart with fresh parallel session
```

---

*AI-powered parallel development with 80-90% automatic conflict resolution*