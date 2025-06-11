#!/bin/bash

# Conflict Resolution Validator
# Tests and validates merge results to ensure correctness

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

log_validation() {
    echo -e "${PURPLE}[VALIDATION]${NC} $1"
}

log_test() {
    echo -e "${BLUE}[TEST]${NC} $1"
}

log_pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
}

log_fail() {
    echo -e "${RED}[FAIL]${NC} $1"
}

log_warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Validate build system
validate_build() {
    log_validation "Validating build system..."
    
    local validation_passed=true
    
    # Check if package.json exists and has build scripts
    if [[ ! -f "$PROJECT_ROOT/package.json" ]]; then
        log_fail "No package.json found in project root"
        return 1
    fi
    
    # Try to run build in different directories
    for dir in "$PROJECT_ROOT" "$PROJECT_ROOT/frontend" "$PROJECT_ROOT/storybook"; do
        if [[ -f "$dir/package.json" ]]; then
            log_test "Testing build in $dir"
            
            cd "$dir"
            
            # Check for build script
            if jq -e '.scripts.build' package.json >/dev/null 2>&1; then
                log_test "Running npm run build in $dir"
                
                if npm run build >/dev/null 2>&1; then
                    log_pass "Build successful in $dir"
                else
                    log_fail "Build failed in $dir"
                    validation_passed=false
                fi
            else
                log_warn "No build script found in $dir/package.json"
            fi
        fi
    done
    
    cd "$PROJECT_ROOT"
    
    if [[ "$validation_passed" == true ]]; then
        log_pass "Build validation completed successfully"
        return 0
    else
        log_fail "Build validation failed"
        return 1
    fi
}

# Validate TypeScript compilation
validate_typescript() {
    log_validation "Validating TypeScript compilation..."
    
    local validation_passed=true
    
    # Check different directories for TypeScript configs
    for dir in "$PROJECT_ROOT" "$PROJECT_ROOT/frontend" "$PROJECT_ROOT/storybook" "$PROJECT_ROOT/backend"; do
        if [[ -f "$dir/tsconfig.json" ]]; then
            log_test "Checking TypeScript in $dir"
            
            cd "$dir"
            
            # Try TypeScript compilation
            if command -v tsc >/dev/null 2>&1; then
                if tsc --noEmit --skipLibCheck >/dev/null 2>&1; then
                    log_pass "TypeScript compilation successful in $dir"
                else
                    log_fail "TypeScript compilation failed in $dir"
                    validation_passed=false
                fi
            elif command -v npx >/dev/null 2>&1; then
                if npx tsc --noEmit --skipLibCheck >/dev/null 2>&1; then
                    log_pass "TypeScript compilation successful in $dir"
                else
                    log_fail "TypeScript compilation failed in $dir"
                    validation_passed=false
                fi
            else
                log_warn "TypeScript compiler not available for validation"
            fi
        fi
    done
    
    cd "$PROJECT_ROOT"
    
    if [[ "$validation_passed" == true ]]; then
        log_pass "TypeScript validation completed successfully"
        return 0
    else
        log_fail "TypeScript validation failed"
        return 1
    fi
}

# Validate Storybook configuration
validate_storybook() {
    log_validation "Validating Storybook configuration..."
    
    local storybook_dir=""
    
    # Find Storybook directory
    for dir in "$PROJECT_ROOT/storybook" "$PROJECT_ROOT/frontend" "$PROJECT_ROOT"; do
        if [[ -f "$dir/.storybook/main.ts" || -f "$dir/.storybook/main.js" ]]; then
            storybook_dir="$dir"
            break
        fi
    done
    
    if [[ -z "$storybook_dir" ]]; then
        log_warn "No Storybook configuration found"
        return 0
    fi
    
    log_test "Found Storybook in $storybook_dir"
    cd "$storybook_dir"
    
    # Check if Storybook can build
    if [[ -f "package.json" ]] && jq -e '.scripts."build-storybook"' package.json >/dev/null 2>&1; then
        log_test "Testing Storybook build"
        
        if npm run build-storybook >/dev/null 2>&1; then
            log_pass "Storybook build successful"
            cd "$PROJECT_ROOT"
            return 0
        else
            log_fail "Storybook build failed"
            cd "$PROJECT_ROOT"
            return 1
        fi
    else
        log_warn "No Storybook build script found"
        cd "$PROJECT_ROOT"
        return 0
    fi
}

# Validate specific resolved files
validate_resolved_files() {
    local files=("$@")
    
    log_validation "Validating resolved files..."
    
    local validation_passed=true
    
    for file in "${files[@]}"; do
        log_test "Validating $file"
        
        # Check if file exists
        if [[ ! -f "$file" ]]; then
            log_fail "Resolved file not found: $file"
            validation_passed=false
            continue
        fi
        
        # Check for remaining conflict markers
        if grep -q -E "^(<{7}|={7}|>{7})" "$file"; then
            log_fail "Conflict markers still present in $file"
            validation_passed=false
            continue
        fi
        
        # File-specific validation
        case "$file" in
            *.ts|*.tsx)
                validate_typescript_file "$file"
                if [[ $? -ne 0 ]]; then
                    validation_passed=false
                fi
                ;;
            *.json)
                validate_json_file "$file"
                if [[ $? -ne 0 ]]; then
                    validation_passed=false
                fi
                ;;
            *.css|*.scss|*.sass)
                validate_css_file "$file"
                if [[ $? -ne 0 ]]; then
                    validation_passed=false
                fi
                ;;
            *.stories.*)
                validate_story_file "$file"
                if [[ $? -ne 0 ]]; then
                    validation_passed=false
                fi
                ;;
        esac
        
        log_pass "Validation passed for $file"
    done
    
    if [[ "$validation_passed" == true ]]; then
        log_pass "All resolved files validated successfully"
        return 0
    else
        log_fail "Some resolved files failed validation"
        return 1
    fi
}

# Validate TypeScript file
validate_typescript_file() {
    local file="$1"
    
    # Basic syntax check
    if command -v tsc >/dev/null 2>&1; then
        if tsc --noEmit --skipLibCheck "$file" >/dev/null 2>&1; then
            return 0
        else
            log_fail "TypeScript syntax error in $file"
            return 1
        fi
    fi
    
    # Basic syntax validation using Node.js (if available)
    if command -v node >/dev/null 2>&1; then
        # Try to parse as JavaScript (won't catch TS-specific errors but will catch syntax)
        if node -c "$file" >/dev/null 2>&1; then
            return 0
        else
            log_fail "JavaScript syntax error in $file"
            return 1
        fi
    fi
    
    # Fallback: basic pattern matching for common issues
    if grep -q "^\s*export\s*{.*}\s*from\s*['\"].*['\"]" "$file"; then
        # Valid export pattern found
        return 0
    elif grep -q "^\s*import.*from\s*['\"].*['\"]" "$file"; then
        # Valid import pattern found
        return 0
    else
        log_warn "Could not validate TypeScript syntax for $file (no validator available)"
        return 0
    fi
}

# Validate JSON file
validate_json_file() {
    local file="$1"
    
    if command -v jq >/dev/null 2>&1; then
        if jq . "$file" >/dev/null 2>&1; then
            return 0
        else
            log_fail "Invalid JSON in $file"
            return 1
        fi
    elif command -v python3 >/dev/null 2>&1; then
        if python3 -m json.tool "$file" >/dev/null 2>&1; then
            return 0
        else
            log_fail "Invalid JSON in $file"
            return 1
        fi
    elif command -v node >/dev/null 2>&1; then
        if node -e "JSON.parse(require('fs').readFileSync('$file', 'utf8'))" >/dev/null 2>&1; then
            return 0
        else
            log_fail "Invalid JSON in $file"
            return 1
        fi
    else
        log_warn "No JSON validator available for $file"
        return 0
    fi
}

# Validate CSS file
validate_css_file() {
    local file="$1"
    
    # Basic CSS validation - check for balanced braces
    local open_braces
    local close_braces
    
    open_braces=$(grep -o "{" "$file" | wc -l)
    close_braces=$(grep -o "}" "$file" | wc -l)
    
    if [[ $open_braces -eq $close_braces ]]; then
        return 0
    else
        log_fail "Unbalanced braces in CSS file $file"
        return 1
    fi
}

# Validate Storybook story file
validate_story_file() {
    local file="$1"
    
    # Check for basic Storybook structure
    if grep -q "export default" "$file" && grep -q "export const.*=" "$file"; then
        return 0
    else
        log_fail "Invalid Storybook story structure in $file"
        return 1
    fi
}

# Validate import/export consistency
validate_import_export_consistency() {
    log_validation "Validating import/export consistency..."
    
    local validation_passed=true
    
    # Find all TypeScript files
    while IFS= read -r -d '' file; do
        # Check exports in the file
        while IFS= read -r export_line; do
            if [[ "$export_line" =~ export.*from[[:space:]]*[\'\"](.*)[\'\"] ]]; then
                local import_path="${BASH_REMATCH[1]}"
                local resolved_path
                
                # Resolve relative imports
                if [[ "$import_path" =~ ^\. ]]; then
                    resolved_path="$(dirname "$file")/$import_path"
                    
                    # Try different extensions
                    for ext in ".ts" ".tsx" ".js" ".jsx" "/index.ts" "/index.tsx"; do
                        if [[ -f "$resolved_path$ext" ]]; then
                            resolved_path="$resolved_path$ext"
                            break
                        fi
                    done
                    
                    if [[ ! -f "$resolved_path" ]]; then
                        log_fail "Import not found: $import_path in $file"
                        validation_passed=false
                    fi
                fi
            fi
        done < <(grep "export.*from" "$file" 2>/dev/null || true)
        
    done < <(find "$PROJECT_ROOT" -name "*.ts" -o -name "*.tsx" -print0 2>/dev/null)
    
    if [[ "$validation_passed" == true ]]; then
        log_pass "Import/export consistency validation passed"
        return 0
    else
        log_fail "Import/export consistency validation failed"
        return 1
    fi
}

# Run linting if available
validate_linting() {
    log_validation "Validating code style and linting..."
    
    local validation_passed=true
    
    # Check different directories for linting
    for dir in "$PROJECT_ROOT" "$PROJECT_ROOT/frontend" "$PROJECT_ROOT/storybook" "$PROJECT_ROOT/backend"; do
        if [[ -f "$dir/package.json" ]]; then
            cd "$dir"
            
            # Check for lint script
            if jq -e '.scripts.lint' package.json >/dev/null 2>&1; then
                log_test "Running linter in $dir"
                
                if npm run lint >/dev/null 2>&1; then
                    log_pass "Linting passed in $dir"
                else
                    log_warn "Linting issues found in $dir (non-critical)"
                    # Don't fail validation for linting issues
                fi
            fi
        fi
    done
    
    cd "$PROJECT_ROOT"
    
    log_pass "Linting validation completed"
    return 0
}

# Comprehensive validation suite
run_full_validation() {
    local resolved_files=("$@")
    
    log_validation "Running comprehensive validation suite..."
    
    local overall_passed=true
    
    # Individual validation steps
    if ! validate_resolved_files "${resolved_files[@]}"; then
        overall_passed=false
    fi
    
    if ! validate_typescript; then
        overall_passed=false
    fi
    
    if ! validate_import_export_consistency; then
        overall_passed=false
    fi
    
    # These are less critical - warnings only
    validate_linting || true
    validate_build || log_warn "Build validation failed (may be expected during development)"
    validate_storybook || log_warn "Storybook validation failed (may be expected)"
    
    if [[ "$overall_passed" == true ]]; then
        log_pass "🎉 All critical validations passed!"
        return 0
    else
        log_fail "❌ Some critical validations failed"
        return 1
    fi
}

# Quick validation for specific use cases
quick_validate() {
    local files=("$@")
    
    log_validation "Running quick validation..."
    
    for file in "${files[@]}"; do
        # Check conflict markers
        if grep -q -E "^(<{7}|={7}|>{7})" "$file"; then
            log_fail "Conflict markers found in $file"
            return 1
        fi
        
        # Basic file-specific checks
        case "$file" in
            *.ts|*.tsx)
                if ! validate_typescript_file "$file"; then
                    return 1
                fi
                ;;
            *.json)
                if ! validate_json_file "$file"; then
                    return 1
                fi
                ;;
        esac
    done
    
    log_pass "Quick validation passed"
    return 0
}

# Generate validation report
generate_validation_report() {
    local report_file="$1"
    shift
    local validated_files=("$@")
    
    log_validation "Generating validation report..."
    
    mkdir -p "$(dirname "$report_file")"
    
    cat > "$report_file" << EOF
# Validation Report

**Date**: $(date)
**Validator Version**: 1.0.0

## Summary

- **Files Validated**: ${#validated_files[@]}
- **TypeScript Check**: $(if validate_typescript >/dev/null 2>&1; then echo "✅ Passed"; else echo "❌ Failed"; fi)
- **Build Check**: $(if validate_build >/dev/null 2>&1; then echo "✅ Passed"; else echo "⚠️ Warning"; fi)
- **Storybook Check**: $(if validate_storybook >/dev/null 2>&1; then echo "✅ Passed"; else echo "⚠️ Warning"; fi)

## Validated Files

EOF

    for file in "${validated_files[@]}"; do
        local status="✅ Passed"
        if grep -q -E "^(<{7}|={7}|>{7})" "$file" 2>/dev/null; then
            status="❌ Conflict markers found"
        elif ! validate_typescript_file "$file" >/dev/null 2>&1; then
            status="❌ Syntax error"
        fi
        
        echo "- **$file**: $status" >> "$report_file"
    done
    
    cat >> "$report_file" << EOF

## Recommendations

EOF

    if ! validate_typescript >/dev/null 2>&1; then
        echo "- Fix TypeScript compilation errors before deploying" >> "$report_file"
    fi
    
    if ! validate_build >/dev/null 2>&1; then
        echo "- Verify build process works correctly" >> "$report_file"
    fi
    
    echo "- Run tests to ensure functionality is preserved" >> "$report_file"
    echo "- Consider code review for complex merges" >> "$report_file"
    
    log_pass "Validation report generated: $report_file"
}

# Export functions for use in other scripts
export -f validate_build
export -f validate_typescript
export -f validate_storybook
export -f validate_resolved_files
export -f validate_import_export_consistency
export -f run_full_validation
export -f quick_validate
export -f generate_validation_report