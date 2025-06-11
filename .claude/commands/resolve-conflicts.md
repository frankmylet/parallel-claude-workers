# Resolve Conflicts - Intelligent Conflict Resolution

**Command**: `/resolve-conflicts`

Automatically detect, analyze, and resolve merge conflicts using intelligent strategies.

## Usage

```bash
/resolve-conflicts [OPTIONS] [COMMAND]
```

## Commands

### `analyze`
Analyze current conflicts without resolving them.

```bash
/resolve-conflicts analyze
```

**Output**: Detailed breakdown of conflicts found, their types, complexity, and recommended resolution strategies.

### `resolve`
Automatically resolve conflicts using intelligent strategies.

```bash
/resolve-conflicts resolve [--strategy=auto|interactive|manual] [--confidence=7.0]
```

**Options**:
- `--strategy=auto`: Fully automated resolution
- `--strategy=interactive`: Review each resolution before applying  
- `--strategy=manual`: Provide guidance for manual resolution
- `--confidence=N.N`: Minimum confidence level (0.0-10.0, default: 7.0)

### `interactive`
Step through conflicts one by one with user confirmation.

```bash
/resolve-conflicts interactive [--confidence=8.0]
```

### `status`
Show current conflict status and resolution progress.

```bash
/resolve-conflicts status
```

### `rollback`
Rollback to state before conflict resolution.

```bash
/resolve-conflicts rollback
```

## Examples

### Quick Auto-Resolution
```bash
/resolve-conflicts resolve --strategy=auto --confidence=8.0
```
Automatically resolves all conflicts with confidence ≥ 8.0/10.

### Interactive Review
```bash
/resolve-conflicts interactive
```
Shows each conflict with analysis and asks for confirmation before resolving.

### Analysis Only
```bash
/resolve-conflicts analyze
```
Shows what would be resolved without making changes.

### High-Confidence Auto-Resolution
```bash
/resolve-conflicts resolve --strategy=auto --confidence=9.0
```
Only auto-resolves conflicts with very high confidence.

## Integration with Parallel Manager

The conflict resolver integrates seamlessly with the parallel workflow:

```bash
# Auto-resolve during merge
/parallel-work --merge --auto-resolve

# Interactive resolution during merge  
/parallel-work --merge --interactive
```

## Conflict Types Handled

### 1. **Index/Export Conflicts** (Confidence: 9.0+)
- **Strategy**: Intelligent merge of unique exports
- **Auto-resolve**: ✅ Yes
- **Example**: `index.ts` files with different export lists

### 2. **TypeScript Components** (Confidence: 7.0+)
- **Strategy**: Code quality analysis and best implementation selection
- **Auto-resolve**: ⚠️ With high confidence only
- **Example**: Different implementations of `Button.tsx`

### 3. **Storybook Stories** (Confidence: 8.0+)
- **Strategy**: Merge unique stories and examples
- **Auto-resolve**: ✅ Yes
- **Example**: Different story examples in `Button.stories.tsx`

### 4. **CSS/Styles** (Confidence: 6.0+)
- **Strategy**: Merge unique selectors and rules
- **Auto-resolve**: ⚠️ Review recommended
- **Example**: Different styling approaches

### 5. **JSON Configuration** (Confidence: 8.0+)
- **Strategy**: Intelligent JSON object merging
- **Auto-resolve**: ⚠️ With validation
- **Example**: Package.json or config files

## Resolution Process

### 1. **Detection**
- Scans for merge conflicts in current repository
- Classifies conflict types and complexity
- Estimates resolution confidence

### 2. **Analysis**
- **Code Quality Scoring**: Complexity, best practices, documentation
- **Feature Completeness**: Props, variants, functionality
- **Design System Compliance**: Consistency with project patterns

### 3. **Strategy Selection**
- **Auto-merge**: Safe conflicts (exports, simple additions)
- **Best-choice**: Clear winner based on analysis
- **Hybrid-merge**: Combine best features from both sides
- **Manual-review**: Complex conflicts requiring human judgment

### 4. **Validation**
- **Syntax checking**: TypeScript compilation, JSON parsing
- **Build testing**: Ensures project still builds
- **Import consistency**: Validates all imports resolve correctly

### 5. **Reporting**
- **Decision log**: What was resolved and why
- **Confidence scores**: How certain the resolver was
- **Manual items**: What still needs human review

## Configuration

Customize resolution behavior via `.claude/config/resolver-settings.json`:

```json
{
  "thresholds": {
    "confidence_threshold": 7.0,
    "auto_resolve_threshold": 8.5
  },
  "strategies": {
    "TYPESCRIPT_COMPONENT": {
      "default_strategy": "choose_best_implementation",
      "auto_resolve": false
    }
  }
}
```

## Safety Features

### **Automatic Backups**
- Creates backup before any changes
- Includes git state and file snapshots
- Rollback capability if issues detected

### **Validation Testing**  
- TypeScript compilation check
- Build system validation
- Import/export consistency verification

### **Manual Override**
- Skip auto-resolution for specific conflicts
- Review and approve suggested resolutions
- Escalate complex cases to human review

## Learning System

The resolver learns from your decisions:

- **Tracks approvals/rejections** of suggested resolutions
- **Adjusts confidence scoring** based on your preferences  
- **Remembers project patterns** and coding style choices
- **Improves over time** with continued usage

## Output Examples

### Analysis Output
```
[ANALYSIS] Found 3 conflicts in current merge
├─ storybook/src/design-system/foundation/Select.tsx (TYPESCRIPT_COMPONENT)
│  ├─ Complexity: 6.5/10 (HEAD) vs 7.8/10 (incoming)
│  ├─ Quality: 8.2/10 (HEAD) vs 8.7/10 (incoming)  
│  ├─ Recommended: choose_best_implementation (incoming)
│  └─ Confidence: 8.4/10
├─ storybook/src/design-system/foundation/index.ts (INDEX_EXPORTS)
│  ├─ Strategy: merge_typescript_exports
│  └─ Confidence: 9.8/10 (auto-resolvable)
└─ storybook/stories/design-system-foundation/Select.stories.tsx (STORYBOOK_STORY)
   ├─ Strategy: merge_storybook_stories  
   └─ Confidence: 8.1/10 (auto-resolvable)
```

### Resolution Output
```
[STEP] Starting conflict resolution (mode: auto, confidence: 7.0)
[SUCCESS] Resolved: index.ts (merge_typescript_exports, confidence: 9.8)
[SUCCESS] Resolved: Select.stories.tsx (merge_storybook_stories, confidence: 8.1)  
[SUCCESS] Resolved: Select.tsx (choose_best_implementation, confidence: 8.4)

[SUCCESS] Resolution Summary:
├─ Total conflicts: 3
├─ Successfully resolved: 3  
├─ Manual review needed: 0
└─ Validation: ✅ All checks passed
```

## Troubleshooting

### "No conflicts found"
- Ensure you're in an active merge state
- Run `git merge <branch>` first to create conflicts

### "Resolution failed validation"  
- Check TypeScript compilation errors
- Verify all imports resolve correctly
- Use `rollback` command to restore previous state

### "Low confidence warning"
- Review the specific conflict manually
- Use `interactive` mode to see detailed analysis
- Consider improving task separation in future parallel work

## Best Practices

### **For Better Auto-Resolution**
1. **Separate concerns** in parallel tasks
2. **Use different files** when possible  
3. **Follow consistent patterns** across implementations
4. **Add good documentation** to help quality analysis

### **For Complex Projects**
1. **Start with interactive mode** to learn the system
2. **Customize thresholds** in configuration file
3. **Review resolution reports** to understand decisions
4. **Provide feedback** to improve learning

---

**Next**: Learn about [task formatting](/format-tasks) and [parallel workflow](/parallel-work) integration.