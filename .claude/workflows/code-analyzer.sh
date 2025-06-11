#!/bin/bash

# Code Analysis Engine for Intelligent Conflict Resolution
# Analyzes code quality, complexity, and best practices

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Analysis configuration
COMPLEXITY_WEIGHT=2.0
QUALITY_WEIGHT=3.0
COMPLETENESS_WEIGHT=2.5
DOCUMENTATION_WEIGHT=1.5
ACCESSIBILITY_WEIGHT=1.0

log_analysis() {
    echo -e "${PURPLE}[ANALYSIS]${NC} $1"
}

log_score() {
    echo -e "${BLUE}[SCORE]${NC} $1"
}

# Analyze component quality
analyze_component_quality() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        echo "0.0"
        return 1
    fi
    
    log_analysis "Analyzing component quality: $file"
    
    local complexity_score
    local quality_score
    local completeness_score
    local documentation_score
    local accessibility_score
    local final_score
    
    complexity_score=$(analyze_code_complexity "$file")
    quality_score=$(analyze_code_quality "$file")
    completeness_score=$(analyze_feature_completeness "$file")
    documentation_score=$(analyze_documentation_quality "$file")
    accessibility_score=$(analyze_accessibility_features "$file")
    
    # Calculate weighted final score
    final_score=$(python3 -c "
complexity = $complexity_score
quality = $quality_score  
completeness = $completeness_score
documentation = $documentation_score
accessibility = $accessibility_score

weights_sum = $COMPLEXITY_WEIGHT + $QUALITY_WEIGHT + $COMPLETENESS_WEIGHT + $DOCUMENTATION_WEIGHT + $ACCESSIBILITY_WEIGHT
weighted_sum = (complexity * $COMPLEXITY_WEIGHT + quality * $QUALITY_WEIGHT + completeness * $COMPLETENESS_WEIGHT + documentation * $DOCUMENTATION_WEIGHT + accessibility * $ACCESSIBILITY_WEIGHT)

final = weighted_sum / weights_sum
print(f'{final:.2f}')
" 2>/dev/null || echo "7.0")
    
    log_score "Component: $file"
    log_score "├─ Complexity: $complexity_score"
    log_score "├─ Quality: $quality_score"
    log_score "├─ Completeness: $completeness_score"
    log_score "├─ Documentation: $documentation_score"
    log_score "├─ Accessibility: $accessibility_score"
    log_score "└─ Final Score: $final_score"
    
    echo "$final_score"
}

# Analyze code complexity
analyze_code_complexity() {
    local file="$1"
    local score=5.0
    
    if [[ ! -f "$file" ]]; then
        echo "0.0"
        return
    fi
    
    local line_count
    local function_count
    local conditional_count
    local loop_count
    local nesting_level
    
    line_count=$(wc -l < "$file")
    function_count=$(grep -c "function\|const.*=.*=>\|=.*function" "$file" 2>/dev/null || echo "0")
    conditional_count=$(grep -c "if\s*(\|switch\s*(\|case\s\|?.*:" "$file" 2>/dev/null || echo "0")
    loop_count=$(grep -c "for\s*(\|while\s*(\|\.map\s*(\|\.forEach\s*(" "$file" 2>/dev/null || echo "0")
    
    # Calculate max nesting level (simplified)
    nesting_level=$(grep -o "{" "$file" | wc -l)
    local closing_braces
    closing_braces=$(grep -o "}" "$file" | wc -l)
    if [[ $closing_braces -gt 0 ]]; then
        nesting_level=$((nesting_level - closing_braces))
        nesting_level=${nesting_level#-} # absolute value
    fi
    
    # Scoring: Lower complexity = higher score (using python)
    if [[ $line_count -lt 50 ]]; then
        score=$(python3 -c "print($score + 1.0)" 2>/dev/null || echo "$score")
    elif [[ $line_count -gt 200 ]]; then
        score=$(python3 -c "print($score - 1.0)" 2>/dev/null || echo "$score")
    fi
    
    if [[ $function_count -lt 5 ]]; then
        score=$(python3 -c "print($score + 0.5)" 2>/dev/null || echo "$score")
    elif [[ $function_count -gt 10 ]]; then
        score=$(python3 -c "print($score - 0.5)" 2>/dev/null || echo "$score")
    fi
    
    if [[ $conditional_count -lt 5 ]]; then
        score=$(python3 -c "print($score + 0.5)" 2>/dev/null || echo "$score")
    elif [[ $conditional_count -gt 15 ]]; then
        score=$(python3 -c "print($score - 1.0)" 2>/dev/null || echo "$score")
    fi
    
    if [[ $nesting_level -lt 3 ]]; then
        score=$(python3 -c "print($score + 0.5)" 2>/dev/null || echo "$score")
    elif [[ $nesting_level -gt 6 ]]; then
        score=$(python3 -c "print($score - 1.5)" 2>/dev/null || echo "$score")
    fi
    
    # Ensure score is between 0 and 10
    score=$(python3 -c "print(max(0, min(10, $score)))" 2>/dev/null || echo "$score")
    
    echo "$score"
}

# Analyze code quality
analyze_code_quality() {
    local file="$1"
    local score=5.0
    
    if [[ ! -f "$file" ]]; then
        echo "0.0"
        return
    fi
    
    # TypeScript usage
    if grep -q "interface\|type\s.*=\|:\s*\w\+\s*[=;]" "$file"; then
        score=$(echo "$score + 1.5" | bc -l)
    fi
    
    # React best practices
    if grep -q "React\.FC\|React\.Component\|forwardRef\|memo" "$file"; then
        score=$(echo "$score + 1.0" | bc -l)
    fi
    
    # Modern JavaScript features
    if grep -q "const\s\|let\s\|=>\|\.\.\..*[,}]\|async\|await" "$file"; then
        score=$(echo "$score + 0.5" | bc -l)
    fi
    
    # Error handling
    if grep -q "try\s*{\|catch\s*(\|throw\s\|Error(" "$file"; then
        score=$(echo "$score + 0.5" | bc -l)
    fi
    
    # CVA (Class Variance Authority) usage
    if grep -q "cva\s*(\|VariantProps\|variants:" "$file"; then
        score=$(echo "$score + 1.0" | bc -l)
    fi
    
    # Consistent naming
    local camelcase_vars
    local kebab_case_vars
    camelcase_vars=$(grep -o "\b[a-z][a-zA-Z0-9]*\b" "$file" | wc -l)
    kebab_case_vars=$(grep -o "\b[a-z][a-z0-9-]*[a-z0-9]\b" "$file" | wc -l)
    
    if [[ $camelcase_vars -gt $((kebab_case_vars * 2)) ]]; then
        score=$(echo "$score + 0.5" | bc -l)
    fi
    
    # No console.log or debugger statements
    if ! grep -q "console\.\|debugger" "$file"; then
        score=$(echo "$score + 0.5" | bc -l)
    else
        score=$(echo "$score - 0.5" | bc -l)
    fi
    
    # Proper imports
    if grep -q "^import.*from\s" "$file"; then
        score=$(echo "$score + 0.5" | bc -l)
    fi
    
    # Ensure score is between 0 and 10
    score=$(echo "if ($score < 0) 0 else if ($score > 10) 10 else $score" | bc -l)
    
    echo "$score"
}

# Analyze feature completeness
analyze_feature_completeness() {
    local file="$1"
    local score=5.0
    
    if [[ ! -f "$file" ]]; then
        echo "0.0"
        return
    fi
    
    # Props interface defined
    if grep -q "interface.*Props\|type.*Props" "$file"; then
        score=$(echo "$score + 1.5" | bc -l)
    fi
    
    # Multiple variants/states
    if grep -q "variants:\s*{" "$file"; then
        local variant_count
        variant_count=$(grep -c "^\s*[a-zA-Z]\+:" "$file" 2>/dev/null || echo "0")
        if [[ $variant_count -gt 2 ]]; then
            score=$(echo "$score + 1.0" | bc -l)
        else
            score=$(echo "$score + 0.5" | bc -l)
        fi
    fi
    
    # Default props/values
    if grep -q "defaultProps\|defaultValue\|default:" "$file"; then
        score=$(echo "$score + 0.5" | bc -l)
    fi
    
    # Event handlers
    if grep -q "onClick\|onChange\|onSubmit\|onFocus\|onBlur" "$file"; then
        score=$(echo "$score + 0.5" | bc -l)
    fi
    
    # Conditional rendering
    if grep -q "&&\|?\s*:\|if\s*(" "$file"; then
        score=$(echo "$score + 0.5" | bc -l)
    fi
    
    # State management
    if grep -q "useState\|useEffect\|useCallback\|useMemo" "$file"; then
        score=$(echo "$score + 0.5" | bc -l)
    fi
    
    # Forwarded refs
    if grep -q "forwardRef\|useImperativeHandle" "$file"; then
        score=$(echo "$score + 0.5" | bc -l)
    fi
    
    # Loading/disabled states
    if grep -q "loading\|disabled\|pending" "$file"; then
        score=$(echo "$score + 0.5" | bc -l)
    fi
    
    # Ensure score is between 0 and 10
    score=$(echo "if ($score < 0) 0 else if ($score > 10) 10 else $score" | bc -l)
    
    echo "$score"
}

# Analyze documentation quality
analyze_documentation_quality() {
    local file="$1"
    local score=5.0
    
    if [[ ! -f "$file" ]]; then
        echo "0.0"
        return
    fi
    
    local comment_lines
    local jsdoc_comments
    local inline_comments
    local todo_comments
    
    comment_lines=$(grep -c "^\s*/\*\|^\s*//\|^\s*\*" "$file" 2>/dev/null || echo "0")
    jsdoc_comments=$(grep -c "^\s*/\*\*\|@param\|@returns\|@example" "$file" 2>/dev/null || echo "0")
    inline_comments=$(grep -c "//.*[a-zA-Z]" "$file" 2>/dev/null || echo "0")
    todo_comments=$(grep -c "TODO\|FIXME\|XXX\|HACK" "$file" 2>/dev/null || echo "0")
    
    # Calculate comment ratio
    local total_lines
    total_lines=$(wc -l < "$file")
    local comment_ratio
    if [[ $total_lines -gt 0 ]]; then
        comment_ratio=$(echo "scale=2; $comment_lines / $total_lines" | bc -l)
    else
        comment_ratio="0"
    fi
    
    # Good comment ratio (10-25%)
    if (( $(echo "$comment_ratio >= 0.10 && $comment_ratio <= 0.25" | bc -l) )); then
        score=$(echo "$score + 2.0" | bc -l)
    elif (( $(echo "$comment_ratio > 0.05" | bc -l) )); then
        score=$(echo "$score + 1.0" | bc -l)
    fi
    
    # JSDoc style comments
    if [[ $jsdoc_comments -gt 0 ]]; then
        score=$(echo "$score + 1.5" | bc -l)
    fi
    
    # Component description/header comment
    if grep -q "^\s*/\*\*.*[Cc]omponent\|^\s*//.*[Cc]omponent" "$file"; then
        score=$(echo "$score + 1.0" | bc -l)
    fi
    
    # TODO comments (slightly negative - indicates incomplete work)
    if [[ $todo_comments -gt 0 ]]; then
        score=$(echo "$score - 0.3" | bc -l)
    fi
    
    # README or examples referenced
    if grep -q "@example\|@see\|README" "$file"; then
        score=$(echo "$score + 0.5" | bc -l)
    fi
    
    # Ensure score is between 0 and 10
    score=$(echo "if ($score < 0) 0 else if ($score > 10) 10 else $score" | bc -l)
    
    echo "$score"
}

# Analyze accessibility features
analyze_accessibility_features() {
    local file="$1"
    local score=5.0
    
    if [[ ! -f "$file" ]]; then
        echo "0.0"
        return
    fi
    
    # ARIA attributes
    local aria_count
    aria_count=$(grep -c "aria-\|role=" "$file" 2>/dev/null || echo "0")
    if [[ $aria_count -gt 0 ]]; then
        score=$(echo "$score + 2.0" | bc -l)
    fi
    
    # Semantic HTML elements
    if grep -q "<button\|<input\|<label\|<fieldset\|<legend" "$file"; then
        score=$(echo "$score + 1.0" | bc -l)
    fi
    
    # Keyboard navigation
    if grep -q "onKeyDown\|onKeyPress\|onKeyUp\|tabIndex" "$file"; then
        score=$(echo "$score + 1.0" | bc -l)
    fi
    
    # Focus management
    if grep -q "focus\|blur\|autoFocus" "$file"; then
        score=$(echo "$score + 0.5" | bc -l)
    fi
    
    # Alt text for images
    if grep -q "alt=" "$file"; then
        score=$(echo "$score + 0.5" | bc -l)
    fi
    
    # Screen reader support
    if grep -q "aria-label\|aria-describedby\|aria-hidden" "$file"; then
        score=$(echo "$score + 1.0" | bc -l)
    fi
    
    # Color contrast considerations (if CSS-in-JS is used)
    if grep -q "contrast\|color.*#\|bg-.*-\d\d\d" "$file"; then
        score=$(echo "$score + 0.5" | bc -l)
    fi
    
    # Ensure score is between 0 and 10
    score=$(echo "if ($score < 0) 0 else if ($score > 10) 10 else $score" | bc -l)
    
    echo "$score"
}

# Analyze Storybook story quality
analyze_story_quality() {
    local file="$1"
    local score=5.0
    
    if [[ ! -f "$file" ]]; then
        echo "0.0"
        return
    fi
    
    log_analysis "Analyzing Storybook story: $file"
    
    # Count different types of stories
    local story_count
    local template_count
    local args_count
    local parameters_count
    
    story_count=$(grep -c "export const.*=.*{" "$file" 2>/dev/null || echo "0")
    template_count=$(grep -c "Template\|template" "$file" 2>/dev/null || echo "0")
    args_count=$(grep -c "args:" "$file" 2>/dev/null || echo "0")
    parameters_count=$(grep -c "parameters:" "$file" 2>/dev/null || echo "0")
    
    # Multiple story examples
    if [[ $story_count -gt 3 ]]; then
        score=$(echo "$score + 2.0" | bc -l)
    elif [[ $story_count -gt 1 ]]; then
        score=$(echo "$score + 1.0" | bc -l)
    fi
    
    # Uses template pattern
    if [[ $template_count -gt 0 ]]; then
        score=$(echo "$score + 1.0" | bc -l)
    fi
    
    # Good args usage
    if [[ $args_count -gt 0 ]]; then
        score=$(echo "$score + 1.0" | bc -l)
    fi
    
    # Story parameters
    if [[ $parameters_count -gt 0 ]]; then
        score=$(echo "$score + 0.5" | bc -l)
    fi
    
    # Documentation in stories
    if grep -q "title:\|description:\|docs:" "$file"; then
        score=$(echo "$score + 1.0" | bc -l)
    fi
    
    # Controls/knobs
    if grep -q "control:\|controls:" "$file"; then
        score=$(echo "$score + 0.5" | bc -l)
    fi
    
    echo "$score"
}

# Compare two implementations and determine which is better
compare_implementations() {
    local file1="$1"
    local file2="$2"
    local file_type="$3"
    
    log_analysis "Comparing implementations: $file1 vs $file2"
    
    local score1
    local score2
    
    case "$file_type" in
        "component")
            score1=$(analyze_component_quality "$file1")
            score2=$(analyze_component_quality "$file2")
            ;;
        "story")
            score1=$(analyze_story_quality "$file1")
            score2=$(analyze_story_quality "$file2")
            ;;
        *)
            # Generic comparison
            score1=$(analyze_component_quality "$file1")
            score2=$(analyze_component_quality "$file2")
            ;;
    esac
    
    log_score "Implementation 1 score: $score1"
    log_score "Implementation 2 score: $score2"
    
    if (( $(echo "$score1 > $score2" | bc -l) )); then
        echo "1:$score1:$score2"
    elif (( $(echo "$score2 > $score1" | bc -l) )); then
        echo "2:$score2:$score1"
    else
        echo "tie:$score1:$score2"
    fi
}

# Analyze entire project structure
analyze_project_structure() {
    local project_root="$1"
    
    log_analysis "Analyzing project structure..."
    
    # Component organization
    local component_dirs
    component_dirs=$(find "$project_root" -type d -name components -o -name Components 2>/dev/null | wc -l)
    
    # Story organization
    local story_files
    story_files=$(find "$project_root" -name "*.stories.*" 2>/dev/null | wc -l)
    
    # TypeScript usage
    local ts_files
    local js_files
    ts_files=$(find "$project_root" -name "*.ts" -o -name "*.tsx" 2>/dev/null | wc -l)
    js_files=$(find "$project_root" -name "*.js" -o -name "*.jsx" 2>/dev/null | wc -l)
    
    log_score "Project Structure Analysis:"
    log_score "├─ Component directories: $component_dirs"
    log_score "├─ Story files: $story_files"
    log_score "├─ TypeScript files: $ts_files"
    log_score "└─ JavaScript files: $js_files"
    
    # Calculate structure score
    local structure_score=5.0
    
    if [[ $component_dirs -gt 0 ]]; then
        structure_score=$(echo "$structure_score + 1.0" | bc -l)
    fi
    
    if [[ $story_files -gt 5 ]]; then
        structure_score=$(echo "$structure_score + 1.0" | bc -l)
    fi
    
    if [[ $ts_files -gt $((js_files * 2)) ]]; then
        structure_score=$(echo "$structure_score + 2.0" | bc -l)
    fi
    
    echo "$structure_score"
}

# Generate detailed analysis report
generate_analysis_report() {
    local file="$1"
    local output_file="$2"
    
    log_analysis "Generating detailed analysis report..."
    
    local component_score
    local complexity_score
    local quality_score
    local completeness_score
    local documentation_score
    local accessibility_score
    
    component_score=$(analyze_component_quality "$file")
    complexity_score=$(analyze_code_complexity "$file")
    quality_score=$(analyze_code_quality "$file")
    completeness_score=$(analyze_feature_completeness "$file")
    documentation_score=$(analyze_documentation_quality "$file")
    accessibility_score=$(analyze_accessibility_features "$file")
    
    cat > "$output_file" << EOF
# Code Analysis Report

**File**: $file
**Date**: $(date)
**Analyzer Version**: 1.0.0

## Overall Score: $component_score/10

## Detailed Breakdown

### Code Complexity: $complexity_score/10
- Lower complexity generally indicates better maintainability
- Considers line count, function count, nesting levels, and conditionals

### Code Quality: $quality_score/10
- TypeScript usage, modern JavaScript features
- React best practices, error handling
- Consistent naming conventions

### Feature Completeness: $completeness_score/10
- Props interfaces, variants, event handlers
- State management, conditional rendering
- Loading states and error handling

### Documentation: $documentation_score/10
- Comment coverage and quality
- JSDoc documentation
- Component descriptions

### Accessibility: $accessibility_score/10
- ARIA attributes and semantic HTML
- Keyboard navigation support
- Screen reader compatibility

## Recommendations

EOF

    # Add specific recommendations based on scores
    if (( $(echo "$complexity_score < 6.0" | bc -l) )); then
        echo "- Consider refactoring to reduce complexity" >> "$output_file"
    fi
    
    if (( $(echo "$documentation_score < 6.0" | bc -l) )); then
        echo "- Add more documentation and comments" >> "$output_file"
    fi
    
    if (( $(echo "$accessibility_score < 6.0" | bc -l) )); then
        echo "- Improve accessibility features" >> "$output_file"
    fi
    
    if (( $(echo "$component_score > 8.0" | bc -l) )); then
        echo "- Excellent implementation! Consider using as reference" >> "$output_file"
    fi
    
    log_success "Analysis report generated: $output_file"
}

# Export functions for use in conflict-resolver.sh
export -f analyze_component_quality
export -f analyze_story_quality
export -f compare_implementations
export -f analyze_project_structure
export -f generate_analysis_report
export -f analyze_code_complexity
export -f analyze_code_quality
export -f analyze_feature_completeness
export -f analyze_documentation_quality
export -f analyze_accessibility_features