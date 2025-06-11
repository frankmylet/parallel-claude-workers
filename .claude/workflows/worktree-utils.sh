#!/bin/bash

# Worktree Utilities
# Helper functions for worktree management

# Get worktree status
get_worktree_status() {
    local worktree_path="$1"
    
    if [[ ! -d "$worktree_path" ]]; then
        echo "not_found"
        return
    fi
    
    cd "$worktree_path"
    
    # Check for uncommitted changes
    if ! git diff --quiet || ! git diff --cached --quiet; then
        echo "dirty"
        return
    fi
    
    # Check if ahead of main
    local commits_ahead=$(git rev-list --count main..HEAD)
    if [[ $commits_ahead -gt 0 ]]; then
        echo "ready"
        return
    fi
    
    echo "no_progress"
}

# Check for potential merge conflicts
check_merge_conflicts() {
    local branch1="$1"
    local branch2="$2"
    
    # Create temporary merge to check for conflicts
    git checkout "$branch1"
    if git merge --no-commit --no-ff "$branch2" >/dev/null 2>&1; then
        git merge --abort >/dev/null 2>&1
        return 0  # No conflicts
    else
        return 1  # Conflicts detected
    fi
}

# Get changed files in worktree
get_changed_files() {
    local worktree_path="$1"
    
    cd "$worktree_path"
    git diff --name-only main..HEAD
}

# Validate worktree before merge
validate_worktree() {
    local worktree_path="$1"
    local issues=()
    
    cd "$worktree_path"
    
    # Check for uncommitted changes
    if ! git diff --quiet || ! git diff --cached --quiet; then
        issues+=("has_uncommitted_changes")
    fi
    
    # Check if has commits
    local commits_ahead=$(git rev-list --count main..HEAD)
    if [[ $commits_ahead -eq 0 ]]; then
        issues+=("no_commits")
    fi
    
    # Check if tests pass (if test command exists)
    if command -v npm >/dev/null 2>&1 && [[ -f package.json ]]; then
        if grep -q '"test"' package.json; then
            if ! npm test >/dev/null 2>&1; then
                issues+=("tests_failing")
            fi
        fi
    fi
    
    # Check if build passes
    if command -v npm >/dev/null 2>&1 && [[ -f package.json ]]; then
        if grep -q '"build"' package.json; then
            if ! npm run build >/dev/null 2>&1; then
                issues+=("build_failing")
            fi
        fi
    fi
    
    # Return issues
    if [[ ${#issues[@]} -eq 0 ]]; then
        echo "valid"
    else
        echo "${issues[*]}"
    fi
}

# Create conflict resolution guide
create_conflict_guide() {
    local worktree_path="$1"
    local conflicted_files="$2"
    
    cat > "$worktree_path/.claude/conflict-resolution.md" << EOF
# Merge Conflict Resolution Guide

## Conflicted Files
$conflicted_files

## Resolution Steps

1. **Review conflicts manually**:
   \`\`\`bash
   git status
   git diff
   \`\`\`

2. **Edit conflicted files**:
   - Look for conflict markers: <<<<<<<, =======, >>>>>>>
   - Choose the correct version or merge both
   - Remove conflict markers

3. **Test your resolution**:
   \`\`\`bash
   npm run test
   npm run build
   \`\`\`

4. **Complete the merge**:
   \`\`\`bash
   git add .
   git commit -m "resolve: Merge conflicts from parallel work"
   \`\`\`

## Common Conflict Patterns

- **Import statements**: Usually safe to keep both
- **Function definitions**: Check for duplicates
- **Configuration files**: Merge carefully
- **Package.json**: Merge dependencies

## Need Help?
- Use \`git log --oneline --graph\` to see branch history
- Use \`git show <commit>\` to see what changed
- Consider backing up your work before major changes
EOF
}

# Generate merge summary
generate_merge_summary() {
    local output_file="$1"
    
    cat > "$output_file" << EOF
# Parallel Work Merge Summary

Generated: $(date)

## Branch Status
EOF
    
    for worker_dir in "$WORKTREE_DIR"/worker-*; do
        if [[ -d "$worker_dir" ]]; then
            local worker_id=$(basename "$worker_dir" | sed 's/worker-//')
            local branch_name="${BRANCH_PREFIX}-$worker_id"
            
            cd "$worker_dir"
            
            echo "### Worker $worker_id (Branch: $branch_name)" >> "$output_file"
            echo "" >> "$output_file"
            
            # Get commit summary
            local commits=$(git log --oneline main..HEAD)
            if [[ -n "$commits" ]]; then
                echo "**Commits:**" >> "$output_file"
                echo '```' >> "$output_file"
                echo "$commits" >> "$output_file"
                echo '```' >> "$output_file"
            else
                echo "No commits made." >> "$output_file"
            fi
            
            # Get changed files
            local changed_files=$(git diff --name-only main..HEAD)
            if [[ -n "$changed_files" ]]; then
                echo "" >> "$output_file"
                echo "**Changed Files:**" >> "$output_file"
                echo "$changed_files" | sed 's/^/- /' >> "$output_file"
            fi
            
            echo "" >> "$output_file"
        fi
    done
    
    echo "## Next Steps" >> "$output_file"
    echo "1. Review the changes above" >> "$output_file"
    echo "2. Run tests to ensure no conflicts" >> "$output_file"
    echo "3. Merge branches when ready" >> "$output_file"
}