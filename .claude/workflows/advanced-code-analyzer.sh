#!/bin/bash

# Advanced Code Analyzer - Enhanced Quality Metrics
# Deep semantic analysis, architectural patterns, and best practices detection

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Enhanced analysis weights
ARCHITECTURAL_WEIGHT=3.0
SEMANTIC_WEIGHT=2.5
PERFORMANCE_WEIGHT=2.0
MAINTAINABILITY_WEIGHT=2.5
SECURITY_WEIGHT=1.5
TESTING_WEIGHT=1.5

log_advanced() {
    echo -e "${CYAN}[ADVANCED]${NC} $1"
}

log_semantic() {
    echo -e "${PURPLE}[SEMANTIC]${NC} $1"
}

log_pattern() {
    echo -e "${BLUE}[PATTERN]${NC} $1"
}

# Advanced component quality analysis
analyze_advanced_component_quality() {
    local file="$1"
    
    if [[ ! -f "$file" ]]; then
        echo "0.0"
        return 1
    fi
    
    log_advanced "Advanced analysis: $file"
    
    local architectural_score
    local semantic_score
    local performance_score
    local maintainability_score
    local security_score
    local testing_score
    local final_score
    
    architectural_score=$(analyze_architectural_patterns "$file")
    semantic_score=$(analyze_semantic_quality "$file")
    performance_score=$(analyze_performance_patterns "$file")
    maintainability_score=$(analyze_maintainability_patterns "$file")
    security_score=$(analyze_security_patterns "$file")
    testing_score=$(analyze_testing_readiness "$file")
    
    # Calculate weighted final score
    final_score=$(python3 -c "
arch = $architectural_score
semantic = $semantic_score
perf = $performance_score
maint = $maintainability_score
security = $security_score
testing = $testing_score

weights_sum = $ARCHITECTURAL_WEIGHT + $SEMANTIC_WEIGHT + $PERFORMANCE_WEIGHT + $MAINTAINABILITY_WEIGHT + $SECURITY_WEIGHT + $TESTING_WEIGHT
weighted_sum = (arch * $ARCHITECTURAL_WEIGHT + semantic * $SEMANTIC_WEIGHT + perf * $PERFORMANCE_WEIGHT + maint * $MAINTAINABILITY_WEIGHT + security * $SECURITY_WEIGHT + testing * $TESTING_WEIGHT)

final = weighted_sum / weights_sum
print(f'{final:.2f}')
" 2>/dev/null || echo "7.0")
    
    log_advanced "Enhanced Quality Analysis:"
    log_advanced "├─ Architecture: $architectural_score/10"
    log_advanced "├─ Semantics: $semantic_score/10"
    log_advanced "├─ Performance: $performance_score/10"
    log_advanced "├─ Maintainability: $maintainability_score/10"
    log_advanced "├─ Security: $security_score/10"
    log_advanced "├─ Testing: $testing_score/10"
    log_advanced "└─ Final Score: $final_score/10"
    
    echo "$final_score"
}

# Analyze architectural patterns and design principles
analyze_architectural_patterns() {
    local file="$1"
    local score=5.0
    
    log_pattern "Analyzing architectural patterns in $file"
    
    # Component composition patterns
    local uses_composition=$(grep -c "children\|render.*=>\|Component.*{" "$file" 2>/dev/null || echo "0")
    local uses_hoc=$(grep -c "withComponent\|with[A-Z]\|Higher.*Order" "$file" 2>/dev/null || echo "0")
    local uses_render_props=$(grep -c "render.*=>\|children.*function" "$file" 2>/dev/null || echo "0")
    
    # React patterns
    local uses_hooks=$(grep -c "use[A-Z]\|useState\|useEffect\|useCallback\|useMemo\|useContext" "$file" 2>/dev/null || echo "0")
    local uses_forwardref=$(grep -c "forwardRef\|React\.forwardRef" "$file" 2>/dev/null || echo "0")
    local uses_memo=$(grep -c "React\.memo\|memo(" "$file" 2>/dev/null || echo "0")
    
    # Design patterns
    local uses_factory=$(grep -c "create[A-Z]\|make[A-Z]\|build[A-Z]" "$file" 2>/dev/null || echo "0")
    local uses_observer=$(grep -c "subscribe\|observer\|listen" "$file" 2>/dev/null || echo "0")
    local uses_command=$(grep -c "execute\|command\|action" "$file" 2>/dev/null || echo "0")
    
    # Modern React patterns
    if [[ $uses_hooks -gt 0 ]]; then
        score=$(python3 -c "print($score + 2.0)" 2>/dev/null || echo "$score")
        log_pattern "✓ Uses React Hooks"
    fi
    
    if [[ $uses_forwardref -gt 0 ]]; then
        score=$(python3 -c "print($score + 1.0)" 2>/dev/null || echo "$score")
        log_pattern "✓ Uses forwardRef for proper ref handling"
    fi
    
    if [[ $uses_memo -gt 0 ]]; then
        score=$(python3 -c "print($score + 1.0)" 2>/dev/null || echo "$score")
        log_pattern "✓ Uses React.memo for optimization"
    fi
    
    # Composition over inheritance
    if [[ $uses_composition -gt 0 ]]; then
        score=$(python3 -c "print($score + 1.5)" 2>/dev/null || echo "$score")
        log_pattern "✓ Uses composition patterns"
    fi
    
    # Advanced patterns
    if [[ $uses_render_props -gt 0 ]]; then
        score=$(python3 -c "print($score + 0.5)" 2>/dev/null || echo "$score")
        log_pattern "✓ Uses render props pattern"
    fi
    
    # Ensure score bounds
    score=$(python3 -c "print(max(0, min(10, $score)))" 2>/dev/null || echo "$score")
    echo "$score"
}

# Analyze semantic quality and code understanding
analyze_semantic_quality() {
    local file="$1"
    local score=5.0
    
    log_semantic "Analyzing semantic quality in $file"
    
    # Naming quality
    local meaningful_names=$(grep -o "\b[a-z][a-zA-Z0-9]*[A-Za-z]\b" "$file" | wc -l)
    local short_names=$(grep -o "\b[a-z][a-z0-9]\{1,3\}\b" "$file" | wc -l)
    local total_names=$((meaningful_names + short_names))
    
    if [[ $total_names -gt 0 ]]; then
        local naming_ratio=$(python3 -c "print($meaningful_names / $total_names)" 2>/dev/null || echo "0.5")
        local naming_good=$(python3 -c "print($naming_ratio > 0.7)" 2>/dev/null || echo "False")
        if [[ "$naming_good" == "True" ]]; then
            score=$(python3 -c "print($score + 1.5)" 2>/dev/null || echo "$score")
            log_semantic "✓ Good naming conventions ($naming_ratio ratio)"
        fi
    fi
    
    # Self-documenting code
    local has_clear_functions=$(grep -c "function [a-zA-Z][a-zA-Z0-9]*[A-Za-z]\|const [a-zA-Z][a-zA-Z0-9]*[A-Za-z].*=" "$file" 2>/dev/null || echo "0")
    local has_descriptive_vars=$(grep -c "const [a-zA-Z][a-zA-Z0-9]\{4,\}\|let [a-zA-Z][a-zA-Z0-9]\{4,\}" "$file" 2>/dev/null || echo "0")
    
    if [[ $has_clear_functions -gt 0 ]]; then
        score=$(python3 -c "print($score + 1.0)" 2>/dev/null || echo "$score")
        log_semantic "✓ Clear function definitions"
    fi
    
    if [[ $has_descriptive_vars -gt 2 ]]; then
        score=$(python3 -c "print($score + 1.0)" 2>/dev/null || echo "$score")
        log_semantic "✓ Descriptive variable names"
    fi
    
    # Type annotations and interfaces
    local type_annotations=$(grep -c ":\s*[A-Z][a-zA-Z]*\|:\s*string\|:\s*number\|:\s*boolean" "$file" 2>/dev/null || echo "0")
    local interface_definitions=$(grep -c "interface [A-Z][a-zA-Z]*\|type [A-Z][a-zA-Z]*.*=" "$file" 2>/dev/null || echo "0")
    
    if [[ $type_annotations -gt 3 ]]; then
        score=$(python3 -c "print($score + 1.0)" 2>/dev/null || echo "$score")
        log_semantic "✓ Good type annotations"
    fi
    
    if [[ $interface_definitions -gt 0 ]]; then
        score=$(python3 -c "print($score + 1.5)" 2>/dev/null || echo "$score")
        log_semantic "✓ Proper interface definitions"
    fi
    
    # Intent clarity
    local has_constants=$(grep -c "const [A-Z_][A-Z_0-9]*\s*=" "$file" 2>/dev/null || echo "0")
    local has_enums=$(grep -c "enum [A-Z][a-zA-Z]*\|const.*=.*{.*}.*as const" "$file" 2>/dev/null || echo "0")
    
    if [[ $has_constants -gt 0 ]]; then
        score=$(python3 -c "print($score + 0.5)" 2>/dev/null || echo "$score")
        log_semantic "✓ Uses constants for magic values"
    fi
    
    if [[ $has_enums -gt 0 ]]; then
        score=$(python3 -c "print($score + 0.5)" 2>/dev/null || echo "$score")
        log_semantic "✓ Uses enums for type safety"
    fi
    
    score=$(python3 -c "print(max(0, min(10, $score)))" 2>/dev/null || echo "$score")
    echo "$score"
}

# Analyze performance patterns and optimizations
analyze_performance_patterns() {
    local file="$1"
    local score=5.0
    
    log_pattern "Analyzing performance patterns in $file"
    
    # React performance optimizations
    local uses_usememo=$(grep -c "useMemo\|React\.useMemo" "$file" 2>/dev/null || echo "0")
    local uses_usecallback=$(grep -c "useCallback\|React\.useCallback" "$file" 2>/dev/null || echo "0")
    local uses_memo=$(grep -c "React\.memo\|memo(" "$file" 2>/dev/null || echo "0")
    local uses_lazy=$(grep -c "React\.lazy\|lazy(" "$file" 2>/dev/null || echo "0")
    
    # Performance anti-patterns
    local inline_objects=$(grep -c "=\s*{\|=\s*\[" "$file" 2>/dev/null || echo "0")
    local inline_functions=$(grep -c "onClick={() =>\|onChange={() =>" "$file" 2>/dev/null || echo "0")
    local unnecessary_rerenders=$(grep -c "useEffect.*\[\]" "$file" 2>/dev/null || echo "0")
    
    # Good practices
    if [[ $uses_usememo -gt 0 ]]; then
        score=$(python3 -c "print($score + 1.5)" 2>/dev/null || echo "$score")
        log_pattern "✓ Uses useMemo for expensive calculations"
    fi
    
    if [[ $uses_usecallback -gt 0 ]]; then
        score=$(python3 -c "print($score + 1.5)" 2>/dev/null || echo "$score")
        log_pattern "✓ Uses useCallback for stable references"
    fi
    
    if [[ $uses_memo -gt 0 ]]; then
        score=$(python3 -c "print($score + 1.0)" 2>/dev/null || echo "$score")
        log_pattern "✓ Uses React.memo to prevent re-renders"
    fi
    
    if [[ $uses_lazy -gt 0 ]]; then
        score=$(python3 -c "print($score + 1.0)" 2>/dev/null || echo "$score")
        log_pattern "✓ Uses lazy loading"
    fi
    
    # Penalize anti-patterns
    if [[ $inline_functions -gt 3 ]]; then
        score=$(python3 -c "print($score - 1.0)" 2>/dev/null || echo "$score")
        log_pattern "⚠ Many inline functions (performance risk)"
    fi
    
    if [[ $inline_objects -gt 5 ]]; then
        score=$(python3 -c "print($score - 0.5)" 2>/dev/null || echo "$score")
        log_pattern "⚠ Many inline objects (re-render risk)"
    fi
    
    # Bundle size considerations
    local import_efficiency=$(grep -c "import.*{.*}" "$file" 2>/dev/null || echo "0")
    local total_imports=$(grep -c "^import" "$file" 2>/dev/null || echo "1")
    local selective_import_ratio=$(python3 -c "print($import_efficiency / $total_imports)" 2>/dev/null || echo "0.5")
    local efficient_imports=$(python3 -c "print($selective_import_ratio > 0.7)" 2>/dev/null || echo "False")
    
    if [[ "$efficient_imports" == "True" ]]; then
        score=$(python3 -c "print($score + 0.5)" 2>/dev/null || echo "$score")
        log_pattern "✓ Efficient selective imports"
    fi
    
    score=$(python3 -c "print(max(0, min(10, $score)))" 2>/dev/null || echo "$score")
    echo "$score"
}

# Analyze maintainability patterns
analyze_maintainability_patterns() {
    local file="$1"
    local score=5.0
    
    log_pattern "Analyzing maintainability patterns in $file"
    
    # Code organization
    local function_length=$(grep -n "function\|const.*=.*=>" "$file" | wc -l)
    local total_lines=$(wc -l < "$file")
    local avg_function_length=0
    if [[ $function_length -gt 0 ]]; then
        avg_function_length=$((total_lines / function_length))
    fi
    
    # Function size (smaller is better for maintainability)
    if [[ $avg_function_length -lt 20 ]]; then
        score=$(python3 -c "print($score + 1.5)" 2>/dev/null || echo "$score")
        log_pattern "✓ Small, focused functions"
    elif [[ $avg_function_length -gt 50 ]]; then
        score=$(python3 -c "print($score - 1.0)" 2>/dev/null || echo "$score")
        log_pattern "⚠ Large functions (refactor consideration)"
    fi
    
    # Separation of concerns
    local separates_logic=$(grep -c "use[A-Z][a-zA-Z]*\|custom.*hook" "$file" 2>/dev/null || echo "0")
    local separates_state=$(grep -c "useState\|useReducer\|useContext" "$file" 2>/dev/null || echo "0")
    local separates_effects=$(grep -c "useEffect" "$file" 2>/dev/null || echo "0")
    
    if [[ $separates_logic -gt 0 ]]; then
        score=$(python3 -c "print($score + 1.0)" 2>/dev/null || echo "$score")
        log_pattern "✓ Separates business logic"
    fi
    
    if [[ $separates_state -gt 0 && $separates_effects -gt 0 ]]; then
        score=$(python3 -c "print($score + 1.0)" 2>/dev/null || echo "$score")
        log_pattern "✓ Clear state and effect separation"
    fi
    
    # Error handling
    local has_error_handling=$(grep -c "try.*{.*catch\|throw.*Error\|\.catch(" "$file" 2>/dev/null || echo "0")
    local has_error_boundaries=$(grep -c "ErrorBoundary\|componentDidCatch\|getDerivedStateFromError" "$file" 2>/dev/null || echo "0")
    
    if [[ $has_error_handling -gt 0 ]]; then
        score=$(python3 -c "print($score + 1.0)" 2>/dev/null || echo "$score")
        log_pattern "✓ Proper error handling"
    fi
    
    if [[ $has_error_boundaries -gt 0 ]]; then
        score=$(python3 -c "print($score + 0.5)" 2>/dev/null || echo "$score")
        log_pattern "✓ Error boundary patterns"
    fi
    
    # Documentation and comments
    local has_jsdoc=$(grep -c "/\*\*\|@param\|@returns\|@example" "$file" 2>/dev/null || echo "0")
    local has_inline_docs=$(grep -c "//.*[a-zA-Z]" "$file" 2>/dev/null || echo "0")
    local comment_ratio=$(python3 -c "print(($has_jsdoc + $has_inline_docs) / $total_lines)" 2>/dev/null || echo "0")
    local well_documented=$(python3 -c "print($comment_ratio > 0.1)" 2>/dev/null || echo "False")
    
    if [[ "$well_documented" == "True" ]]; then
        score=$(python3 -c "print($score + 1.0)" 2>/dev/null || echo "$score")
        log_pattern "✓ Well documented code"
    fi
    
    score=$(python3 -c "print(max(0, min(10, $score)))" 2>/dev/null || echo "$score")
    echo "$score"
}

# Analyze security patterns and best practices
analyze_security_patterns() {
    local file="$1"
    local score=5.0
    
    log_pattern "Analyzing security patterns in $file"
    
    # Input validation
    local has_validation=$(grep -c "validate\|sanitize\|escape\|zod\|yup\|joi" "$file" 2>/dev/null || echo "0")
    local has_prop_validation=$(grep -c "PropTypes\|interface.*Props" "$file" 2>/dev/null || echo "0")
    
    if [[ $has_validation -gt 0 ]]; then
        score=$(python3 -c "print($score + 2.0)" 2>/dev/null || echo "$score")
        log_pattern "✓ Input validation present"
    fi
    
    if [[ $has_prop_validation -gt 0 ]]; then
        score=$(python3 -c "print($score + 1.0)" 2>/dev/null || echo "$score")
        log_pattern "✓ Props validation"
    fi
    
    # XSS prevention
    local safe_rendering=$(grep -c "dangerouslySetInnerHTML" "$file" 2>/dev/null || echo "0")
    local secure_refs=$(grep -c "useRef\|createRef" "$file" 2>/dev/null || echo "0")
    
    if [[ $safe_rendering -eq 0 ]]; then
        score=$(python3 -c "print($score + 1.0)" 2>/dev/null || echo "$score")
        log_pattern "✓ No dangerous HTML injection"
    else
        score=$(python3 -c "print($score - 1.0)" 2>/dev/null || echo "$score")
        log_pattern "⚠ Uses dangerouslySetInnerHTML"
    fi
    
    # Secure defaults
    local secure_links=$(grep -c 'target="_blank".*rel="noopener noreferrer"' "$file" 2>/dev/null || echo "0")
    local insecure_links=$(grep -c 'target="_blank"' "$file" 2>/dev/null || echo "0")
    
    if [[ $secure_links -gt 0 && $insecure_links -eq $secure_links ]]; then
        score=$(python3 -c "print($score + 0.5)" 2>/dev/null || echo "$score")
        log_pattern "✓ Secure external links"
    elif [[ $insecure_links -gt $secure_links ]]; then
        score=$(python3 -c "print($score - 0.5)" 2>/dev/null || echo "$score")
        log_pattern "⚠ Insecure external links"
    fi
    
    # Sensitive data handling
    local handles_secrets=$(grep -c "password\|token\|key\|secret" "$file" 2>/dev/null || echo "0")
    local hardcoded_secrets=$(grep -c "password.*=.*['\"][^'\"]*['\"]\|token.*=.*['\"][^'\"]*['\"]" "$file" 2>/dev/null || echo "0")
    
    if [[ $hardcoded_secrets -gt 0 ]]; then
        score=$(python3 -c "print($score - 2.0)" 2>/dev/null || echo "$score")
        log_pattern "❌ Hardcoded secrets detected"
    elif [[ $handles_secrets -gt 0 ]]; then
        score=$(python3 -c "print($score + 0.5)" 2>/dev/null || echo "$score")
        log_pattern "✓ Handles sensitive data"
    fi
    
    score=$(python3 -c "print(max(0, min(10, $score)))" 2>/dev/null || echo "$score")
    echo "$score"
}

# Analyze testing readiness and testability
analyze_testing_readiness() {
    local file="$1"
    local score=5.0
    
    log_pattern "Analyzing testing readiness in $file"
    
    # Testable structure
    local pure_functions=$(grep -c "function [a-zA-Z][a-zA-Z0-9]*.*{.*return\|const [a-zA-Z][a-zA-Z0-9]*.*=.*=>" "$file" 2>/dev/null || echo "0")
    local side_effects=$(grep -c "useEffect\|fetch\|axios\|localStorage\|sessionStorage" "$file" 2>/dev/null || echo "0")
    
    if [[ $pure_functions -gt $side_effects ]]; then
        score=$(python3 -c "print($score + 1.5)" 2>/dev/null || echo "$score")
        log_pattern "✓ More pure functions than side effects"
    fi
    
    # Test identifiers
    local has_test_ids=$(grep -c "data-testid\|testId\|test-id" "$file" 2>/dev/null || echo "0")
    local has_aria_labels=$(grep -c "aria-label\|aria-labelledby" "$file" 2>/dev/null || echo "0")
    
    if [[ $has_test_ids -gt 0 ]]; then
        score=$(python3 -c "print($score + 1.0)" 2>/dev/null || echo "$score")
        log_pattern "✓ Test identifiers present"
    fi
    
    if [[ $has_aria_labels -gt 0 ]]; then
        score=$(python3 -c "print($score + 1.0)" 2>/dev/null || echo "$score")
        log_pattern "✓ ARIA labels for testing"
    fi
    
    # Dependency injection readiness
    local uses_props=$(grep -c "props\.\|{.*}.*=.*props" "$file" 2>/dev/null || echo "0")
    local uses_context=$(grep -c "useContext\|Context\." "$file" 2>/dev/null || echo "0")
    
    if [[ $uses_props -gt 0 ]]; then
        score=$(python3 -c "print($score + 1.0)" 2>/dev/null || echo "$score")
        log_pattern "✓ Dependency injection via props"
    fi
    
    if [[ $uses_context -gt 0 ]]; then
        score=$(python3 -c "print($score + 0.5)" 2>/dev/null || echo "$score")
        log_pattern "✓ Context for dependency injection"
    fi
    
    # Predictable behavior
    local uses_controlled_components=$(grep -c "value=.*onChange=" "$file" 2>/dev/null || echo "0")
    local uses_uncontrolled=$(grep -c "defaultValue\|ref.*current" "$file" 2>/dev/null || echo "0")
    
    if [[ $uses_controlled_components -gt $uses_uncontrolled ]]; then
        score=$(python3 -c "print($score + 1.0)" 2>/dev/null || echo "$score")
        log_pattern "✓ Prefers controlled components"
    fi
    
    score=$(python3 -c "print(max(0, min(10, $score)))" 2>/dev/null || echo "$score")
    echo "$score"
}

# Compare two implementations using advanced metrics
compare_implementations_advanced() {
    local file1="$1"
    local file2="$2"
    local comparison_focus="${3:-overall}"
    
    log_advanced "Advanced comparison: $file1 vs $file2"
    
    local score1
    local score2
    
    case "$comparison_focus" in
        "architecture")
            score1=$(analyze_architectural_patterns "$file1")
            score2=$(analyze_architectural_patterns "$file2")
            ;;
        "performance")
            score1=$(analyze_performance_patterns "$file1")
            score2=$(analyze_performance_patterns "$file2")
            ;;
        "maintainability")
            score1=$(analyze_maintainability_patterns "$file1")
            score2=$(analyze_maintainability_patterns "$file2")
            ;;
        "security")
            score1=$(analyze_security_patterns "$file1")
            score2=$(analyze_security_patterns "$file2")
            ;;
        "overall"|*)
            score1=$(analyze_advanced_component_quality "$file1")
            score2=$(analyze_advanced_component_quality "$file2")
            ;;
    esac
    
    log_advanced "Comparison Results ($comparison_focus focus):"
    log_advanced "├─ Implementation 1: $score1/10"
    log_advanced "└─ Implementation 2: $score2/10"
    
    local better_is_two=$(python3 -c "print($score2 > $score1)" 2>/dev/null || echo "False")
    local score_diff=$(python3 -c "print(abs($score2 - $score1))" 2>/dev/null || echo "0")
    local significant_diff=$(python3 -c "print($score_diff > 1.0)" 2>/dev/null || echo "False")
    
    if [[ "$better_is_two" == "True" ]]; then
        if [[ "$significant_diff" == "True" ]]; then
            echo "2:$score2:$score1:significant"
        else
            echo "2:$score2:$score1:marginal"
        fi
    elif [[ "$score1" == "$score2" ]]; then
        echo "tie:$score1:$score2:equal"
    else
        if [[ "$significant_diff" == "True" ]]; then
            echo "1:$score1:$score2:significant"
        else
            echo "1:$score1:$score2:marginal"
        fi
    fi
}

# Generate detailed quality report
generate_advanced_quality_report() {
    local file="$1"
    local output_file="$2"
    local comparison_file="${3:-}"
    
    log_advanced "Generating advanced quality report..."
    
    local arch_score=$(analyze_architectural_patterns "$file")
    local semantic_score=$(analyze_semantic_quality "$file")
    local perf_score=$(analyze_performance_patterns "$file")
    local maint_score=$(analyze_maintainability_patterns "$file")
    local security_score=$(analyze_security_patterns "$file")
    local testing_score=$(analyze_testing_readiness "$file")
    local overall_score=$(analyze_advanced_component_quality "$file")
    
    mkdir -p "$(dirname "$output_file")"
    
    cat > "$output_file" << EOF
# Advanced Code Quality Report

**File**: $file
**Date**: $(date)
**Analyzer Version**: 2.0.0 (Advanced)

## Overall Quality Score: $overall_score/10

## Detailed Analysis

### 🏗️ Architecture Patterns: $arch_score/10
$(analyze_architectural_patterns "$file" 2>&1 | grep "✓\|⚠\|❌" || echo "- Standard architectural patterns")

### 🧠 Semantic Quality: $semantic_score/10
$(analyze_semantic_quality "$file" 2>&1 | grep "✓\|⚠\|❌" || echo "- Standard semantic quality")

### ⚡ Performance: $perf_score/10
$(analyze_performance_patterns "$file" 2>&1 | grep "✓\|⚠\|❌" || echo "- Standard performance patterns")

### 🔧 Maintainability: $maint_score/10
$(analyze_maintainability_patterns "$file" 2>&1 | grep "✓\|⚠\|❌" || echo "- Standard maintainability")

### 🔒 Security: $security_score/10
$(analyze_security_patterns "$file" 2>&1 | grep "✓\|⚠\|❌" || echo "- Standard security practices")

### 🧪 Testing Readiness: $testing_score/10
$(analyze_testing_readiness "$file" 2>&1 | grep "✓\|⚠\|❌" || echo "- Standard testing readiness")

## Quality Radar

\`\`\`
Architecture    [$arch_score    ] ████████████████████
Semantics       [$semantic_score    ] ████████████████████  
Performance     [$perf_score    ] ████████████████████
Maintainability [$maint_score    ] ████████████████████
Security        [$security_score    ] ████████████████████
Testing         [$testing_score    ] ████████████████████
\`\`\`

## Recommendations

EOF

    # Add specific recommendations based on scores
    if (( $(python3 -c "print($arch_score < 7.0)" 2>/dev/null || echo "False") == "True" )); then
        echo "### 🏗️ Architecture Improvements" >> "$output_file"
        echo "- Consider using more React hooks and modern patterns" >> "$output_file"
        echo "- Implement composition over inheritance" >> "$output_file"
        echo "- Use forwardRef for proper ref handling" >> "$output_file"
        echo "" >> "$output_file"
    fi
    
    if (( $(python3 -c "print($perf_score < 7.0)" 2>/dev/null || echo "False") == "True" )); then
        echo "### ⚡ Performance Optimizations" >> "$output_file"
        echo "- Add useMemo for expensive calculations" >> "$output_file"
        echo "- Use useCallback for stable function references" >> "$output_file"
        echo "- Consider React.memo to prevent unnecessary re-renders" >> "$output_file"
        echo "- Avoid inline objects and functions in render" >> "$output_file"
        echo "" >> "$output_file"
    fi
    
    if (( $(python3 -c "print($security_score < 7.0)" 2>/dev/null || echo "False") == "True" )); then
        echo "### 🔒 Security Enhancements" >> "$output_file"
        echo "- Add input validation and sanitization" >> "$output_file"
        echo "- Use proper CORS and CSP headers" >> "$output_file"
        echo "- Avoid dangerouslySetInnerHTML when possible" >> "$output_file"
        echo "- Add rel='noopener noreferrer' to external links" >> "$output_file"
        echo "" >> "$output_file"
    fi
    
    if [[ -n "$comparison_file" ]]; then
        echo "## Comparison Analysis" >> "$output_file"
        echo "" >> "$output_file"
        local comparison_result
        comparison_result=$(compare_implementations_advanced "$file" "$comparison_file" "overall")
        echo "**Comparison Result**: $comparison_result" >> "$output_file"
        echo "" >> "$output_file"
    fi
    
    echo "---" >> "$output_file"
    echo "*Generated by Advanced Code Analyzer v2.0.0*" >> "$output_file"
    
    log_advanced "Advanced quality report generated: $output_file"
}

# Export functions for use in conflict resolver
export -f analyze_advanced_component_quality
export -f analyze_architectural_patterns
export -f analyze_semantic_quality
export -f analyze_performance_patterns
export -f analyze_maintainability_patterns
export -f analyze_security_patterns
export -f analyze_testing_readiness
export -f compare_implementations_advanced
export -f generate_advanced_quality_report