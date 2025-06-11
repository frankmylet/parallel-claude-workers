#!/bin/bash

# Parallel Claude Workers - Project Initialization Script
# Safely integrates the parallel development tool into any project

set -e  # Exit on error

PROJECT_ROOT="$(pwd)"
TOOL_DIR="parallel-claude-workers"
CLAUDE_MD="$PROJECT_ROOT/CLAUDE.md"

echo "🚀 Initializing Parallel Claude Workers in project..."
echo "Project root: $PROJECT_ROOT"

# 1. Verify we're in a git repository
if [ ! -d ".git" ]; then
    echo "❌ Error: Not in a git repository. Please run 'git init' first."
    exit 1
fi

# 2. Check if tool already exists
if [ -d "$TOOL_DIR" ]; then
    echo "⚠️  Tool directory already exists. Updating configuration..."
else
    echo "❌ Error: parallel-claude-workers directory not found."
    echo "Please copy the tool to this project first:"
    echo "  cp -r /path/to/parallel-claude-workers ."
    exit 1
fi

# 3. Make scripts executable
echo "🔧 Making scripts executable..."
chmod +x "$TOOL_DIR/.claude/workflows/"*.sh

# 4. Create .claude/commands directory
echo "📁 Setting up Claude Code integration..."
mkdir -p .claude/commands

# 5. Create symlinks for slash commands
echo "🔗 Creating slash command symlinks..."
ln -sf ../../$TOOL_DIR/.claude/workflows/parallel-manager.sh .claude/commands/parallel-work
ln -sf ../../$TOOL_DIR/.claude/workflows/task-formatter.sh .claude/commands/format-tasks
ln -sf ../../$TOOL_DIR/.claude/workflows/conflict-resolver.sh .claude/commands/resolve-conflicts
ln -sf ../../$TOOL_DIR/.claude/workflows/intelligent-task-splitter.sh .claude/commands/split-tasks
ln -sf ../../$TOOL_DIR/.claude/workflows/advanced-code-analyzer.sh .claude/commands/analyze-code

# 6. Update/create CLAUDE.md with tool reference
echo "📝 Updating CLAUDE.md with tool reference..."

CLAUDE_SECTION="## 🚀 Parallel Development Tool

When working with parallel development or the \`parallel-claude-workers\` tool, load additional context from:
- \`parallel-claude-workers/CLAUDE.md\` - Complete tool usage and safety guidelines"

if [ -f "$CLAUDE_MD" ]; then
    # Check if section already exists
    if grep -q "## 🚀 Parallel Development Tool" "$CLAUDE_MD"; then
        echo "✅ CLAUDE.md already contains parallel development section"
    else
        echo "" >> "$CLAUDE_MD"
        echo "$CLAUDE_SECTION" >> "$CLAUDE_MD"
        echo "✅ Added parallel development section to existing CLAUDE.md"
    fi
else
    # Create new CLAUDE.md with basic structure
    cat > "$CLAUDE_MD" << EOF
# Project Instructions for Claude Code

## Quick Context
This project uses the Parallel Claude Workers tool for AI-powered parallel development.

$CLAUDE_SECTION

## When to Load More Context
- **Parallel development**: Read \`parallel-claude-workers/CLAUDE.md\` for complete tool usage
- **Complex searches**: Use Task tool instead of grep/find
EOF
    echo "✅ Created new CLAUDE.md with parallel development section"
fi

# 7. Add gitignore entries for generated files
echo "📄 Updating .gitignore..."
GITIGNORE_SECTION="
# Parallel Claude Workers - Generated Files
worktrees/
parallel-tasks.md
*-tasks.md
task-*.md
!.claude/commands/*-tasks.md"

if [ -f ".gitignore" ]; then
    if ! grep -q "# Parallel Claude Workers" .gitignore; then
        echo "$GITIGNORE_SECTION" >> .gitignore
        echo "✅ Added gitignore entries for parallel development"
    else
        echo "✅ Gitignore already configured for parallel development"
    fi
else
    echo "$GITIGNORE_SECTION" > .gitignore
    echo "✅ Created .gitignore with parallel development entries"
fi

# 8. Verify installation
echo "🔍 Verifying installation..."

# Check slash commands
if [ -L ".claude/commands/parallel-work" ]; then
    echo "✅ Slash commands configured"
else
    echo "❌ Slash commands not properly configured"
    exit 1
fi

# Check tool accessibility
if [ -x "$TOOL_DIR/.claude/workflows/parallel-manager.sh" ]; then
    echo "✅ Tool scripts are executable"
else
    echo "❌ Tool scripts not executable"
    exit 1
fi

# 9. Test basic functionality
echo "🧪 Testing basic functionality..."
if "$TOOL_DIR/.claude/workflows/parallel-manager.sh" --help > /dev/null 2>&1; then
    echo "✅ Tool responds to commands"
else
    echo "❌ Tool not responding properly"
    exit 1
fi

echo ""
echo "🎉 Parallel Claude Workers successfully initialized!"
echo ""
echo "📋 What's been set up:"
echo "  ✅ Executable scripts"
echo "  ✅ Slash commands: /parallel-work, /resolve-conflicts, /format-tasks, /split-tasks, /analyze-code"
echo "  ✅ CLAUDE.md integration"
echo "  ✅ Gitignore configuration"
echo ""
echo "🚀 Quick start:"
echo "  1. Create a task file: echo '- Build login - Add dashboard' > notes.txt"
echo "  2. Format tasks: /format-tasks --input=notes.txt --workers=3"
echo "  3. Launch parallel development: /parallel-work --instructions=parallel-tasks.md --workers=3 --auto-launch"
echo ""
echo "📖 For complete usage guide, Claude will load context from:"
echo "     parallel-claude-workers/CLAUDE.md"
echo ""
echo "⚠️  Remember: Always use proper cleanup commands, never manually delete worktrees!"