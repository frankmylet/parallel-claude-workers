# Installation Guide

*Quick setup for the AI-powered parallel development system*

## 🚀 One-Command Installation

### Step 1: Get the Tool

**Option A: Clone directly**
```bash
cd /your/project/root
git clone https://github.com/frankmylet/parallel-claude-workers.git
```

**Option B: Copy from existing installation**
```bash
cp -r /path/to/parallel-claude-workers /your/project/root/
```

**Option C: Download ZIP**
```bash
cd /your/project/root
# Download and extract ZIP as 'parallel-claude-workers/'
```

### Step 2: Initialize

```bash
cd /your/project/root
./parallel-claude-workers/init-project.sh
```

**Done!** The init script automatically:
- ✅ Sets up all slash commands
- ✅ Configures CLAUDE.md integration  
- ✅ Updates .gitignore
- ✅ Verifies installation
- ✅ Tests functionality

## ✅ Verification

After installation, test the setup:

```bash
# Test slash commands work
/parallel-work --help
/resolve-conflicts --help

# Quick workflow test
echo "- Build login\n- Add dashboard" > test.txt
/format-tasks --input=test.txt --workers=2
```

## 🔧 Troubleshooting

**Permission errors:**
```bash
chmod +x parallel-claude-workers/.claude/workflows/*.sh
```

**Git not initialized:**
```bash
git init
```

**VS Code command missing:**
```bash
code --version  # Should return version number
```

## 🗑️ Uninstallation

```bash
# Remove tool and all symlinks
rm -rf parallel-claude-workers/ .claude/commands/parallel-* .claude/commands/resolve-* .claude/commands/format-* .claude/commands/split-* .claude/commands/analyze-*

# Clean up generated files
rm -rf worktrees/ parallel-tasks.md *-tasks.md
```

## ➡️ Next Steps

**Read the [README.md](README.md)** for complete usage instructions, advanced features, and AI conflict resolution capabilities.

---

*For detailed usage, examples, and advanced configuration, see the main README.md*