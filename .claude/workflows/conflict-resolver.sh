#!/bin/bash

# Intelligent Conflict Resolver for Parallel Claude Workers
# Automatically detects, analyzes, and resolves merge conflicts

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
CONFIG_FILE="$SCRIPT_DIR/../config/resolver-settings.json"
BACKUP_DIR="$PROJECT_ROOT/.claude/backups/$(date +%Y%m%d_%H%M%S)"
REPORT_FILE="$PROJECT_ROOT/.claude/reports/conflict-resolution-$(date +%Y%m%d_%H%M%S).md"

# Source dependencies
source "$SCRIPT_DIR/merge-strategies.sh"
source "$SCRIPT_DIR/code-analyzer.sh" 2>/dev/null || echo "Note: code-analyzer.sh not yet available"
source "$SCRIPT_DIR/conflict-validator.sh" 2>/dev/null || echo "Note: conflict-validator.sh not yet available"

# Global variables
declare -g CONFLICTS_FOUND=()
declare -g RESOLUTIONS_APPLIED=()
declare -g VALIDATION_RESULTS=()
declare -g BACKUP_CREATED=false

# Helper functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${PURPLE}[STEP]${NC} $1"
}

# Show help
show_help() {
    cat << EOF
Intelligent Conflict Resolver - Automatically resolve merge conflicts

Usage:
    $0 [OPTIONS] [COMMAND]

Commands:
    analyze                 Analyze conflicts without resolving
    resolve                 Resolve conflicts automatically
    interactive            Resolve with user confirmation
    status                 Show current conflict status
    rollback               Rollback to pre-resolution state
    help                   Show this help message

Options:
    --strategy=STRATEGY     Resolution strategy: auto|interactive|manual
    --confidence=LEVEL      Minimum confidence level (0.0-10.0, default: 7.0)
    --backup               Create backup before resolution (default: true)
    --validate             Validate results after resolution (default: true)
    --report               Generate detailed report (default: true)
    --dry-run              Show what would be done without executing

Examples:
    $0 analyze                                    # Analyze current conflicts
    $0 resolve --strategy=auto                    # Auto-resolve with default settings
    $0 interactive --confidence=8.0               # Interactive with high confidence
    $0 resolve --dry-run                          # Preview resolution actions

Integration with Parallel Manager:
    .claude/workflows/parallel-manager.sh --merge --auto-resolve
    .claude/workflows/parallel-manager.sh --merge --interactive

EOF
}

# Create backup of current state
create_backup() {
    if [[ "$BACKUP_CREATED" == "true" ]]; then
        return 0
    fi
    
    log_step "Creating backup..."
    mkdir -p "$BACKUP_DIR"
    
    # Backup git state
    git stash push -m "conflict-resolver-backup-$(date +%s)" --include-untracked 2>/dev/null || true
    echo "$(git stash list | head -1 | cut -d: -f1)" > "$BACKUP_DIR/stash_ref.txt"
    
    # Backup current branch state
    git rev-parse HEAD > "$BACKUP_DIR/head_commit.txt"
    git branch --show-current > "$BACKUP_DIR/current_branch.txt"
    
    # Backup conflicted files
    if git status --porcelain | grep -E "^(AA|UU|DD)" > /dev/null; then
        mkdir -p "$BACKUP_DIR/conflicted_files"
        git status --porcelain | grep -E "^(AA|UU|DD)" | while read -r status file; do
            if [[ -f "$file" ]]; then
                mkdir -p "$BACKUP_DIR/conflicted_files/$(dirname "$file")"
                cp "$file" "$BACKUP_DIR/conflicted_files/$file"
            fi
        done
    fi
    
    BACKUP_CREATED=true
    log_success "Backup created: $BACKUP_DIR"
}

# Rollback to previous state
rollback() {
    log_step "Rolling back to pre-resolution state..."
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        log_error "No backup found to rollback to"
        return 1
    fi
    
    # Restore files
    if [[ -d "$BACKUP_DIR/conflicted_files" ]]; then
        find "$BACKUP_DIR/conflicted_files" -type f | while read -r backup_file; do
            original_file="${backup_file#$BACKUP_DIR/conflicted_files/}"
            mkdir -p "$(dirname "$original_file")"
            cp "$backup_file" "$original_file"
        done
    fi
    
    # Restore git state
    if [[ -f "$BACKUP_DIR/stash_ref.txt" ]]; then
        stash_ref=$(cat "$BACKUP_DIR/stash_ref.txt")
        git stash pop "$stash_ref" 2>/dev/null || true
    fi
    
    log_success "Rollback completed"
}

# Detect merge conflicts
detect_conflicts() {
    log_step "Detecting merge conflicts..."
    
    CONFLICTS_FOUND=()
    
    # Check for active merge
    if [[ ! -f "$PROJECT_ROOT/.git/MERGE_HEAD" ]]; then
        log_warning "No active merge detected. Use 'git merge' first."
        return 1
    fi
    
    # Parse git status for conflicts
    while IFS= read -r line; do
        if [[ $line =~ ^(UU|AA|DD|AU|UA|DU|UD)[[:space:]]+(.+)$ ]]; then
            status="${BASH_REMATCH[1]}"
            file="${BASH_REMATCH[2]}"
            conflict_type=$(classify_conflict_type "$status" "$file")
            
            CONFLICTS_FOUND+=("$status:$file:$conflict_type")
            log_info "Found conflict: $file ($conflict_type)"
        fi
    done < <(git status --porcelain)
    
    log_success "Found ${#CONFLICTS_FOUND[@]} conflicts"
    return 0
}

# Classify conflict type for strategy selection
classify_conflict_type() {
    local status="$1"
    local file="$2"
    
    case "$file" in
        */index.ts|*/index.tsx)
            echo "INDEX_EXPORTS"
            ;;
        *.tsx|*.ts)
            if [[ "$file" =~ \.stories\. ]]; then
                echo "STORYBOOK_STORY"
            else
                echo "TYPESCRIPT_COMPONENT"
            fi
            ;;
        *.css|*.scss|*.sass)
            echo "STYLESHEET"
            ;;
        *.json)
            echo "JSON_CONFIG"
            ;;
        *.md)
            echo "DOCUMENTATION"
            ;;
        *)
            echo "GENERIC_FILE"
            ;;
    esac
}

# Analyze conflict complexity and suggest resolution strategy
analyze_conflict() {
    local conflict_info="$1"
    IFS=':' read -r status file conflict_type <<< "$conflict_info"
    
    log_info "Analyzing: $file"
    
    # Basic analysis
    local complexity="LOW"
    local confidence="9.0"
    local suggested_strategy="auto_merge"
    
    case "$conflict_type" in
        "INDEX_EXPORTS")
            # Index files are usually safe to auto-merge
            complexity="LOW"
            confidence="9.5"
            suggested_strategy="merge_exports"
            ;;
        "TYPESCRIPT_COMPONENT")
            # Components need careful analysis
            complexity="MEDIUM"
            confidence="7.0"
            suggested_strategy="best_implementation"
            
            # Check if code-analyzer is available for deeper analysis
            if command -v analyze_component_quality >/dev/null 2>&1; then
                local quality_score
                quality_score=$(analyze_component_quality "$file" 2>/dev/null || echo "6.0")
                confidence="$quality_score"
            fi
            ;;
        "STORYBOOK_STORY")
            # Stories can usually be merged
            complexity="MEDIUM"
            confidence="8.0"
            suggested_strategy="merge_stories"
            ;;
        *)
            complexity="HIGH"
            confidence="5.0"
            suggested_strategy="manual_review"
            ;;
    esac
    
    echo "$complexity:$confidence:$suggested_strategy"
}

# Resolve a single conflict
resolve_conflict() {
    local conflict_info="$1"
    local strategy="$2"
    local confidence_threshold="${3:-7.0}"
    
    IFS=':' read -r status file conflict_type <<< "$conflict_info"
    
    # Get analysis
    local analysis
    analysis=$(analyze_conflict "$conflict_info")
    IFS=':' read -r complexity confidence suggested_strategy <<< "$analysis"
    
    # Use suggested strategy if none provided
    if [[ -z "$strategy" || "$strategy" == "auto" ]]; then
        strategy="$suggested_strategy"
    fi
    
    log_step "Resolving: $file (strategy: $strategy)"
    
    # Check confidence threshold (skip bc for now)
    local conf_check
    conf_check=$(python3 -c "print($confidence < $confidence_threshold)" 2>/dev/null || echo "False")
    if [[ "$conf_check" == "True" ]]; then
        log_warning "Confidence ($confidence) below threshold ($confidence_threshold) for $file"
        log_warning "Escalating to manual review"
        return 1
    fi
    
    # Apply resolution strategy
    local resolution_result="success"
    case "$strategy" in
        "auto_merge"|"merge_exports"|"merge_typescript_exports")
            if merge_typescript_exports "$file"; then
                resolution_result="merged_exports"
            else
                return 1
            fi
            ;;
        "best_implementation")
            if choose_best_implementation "$file"; then
                resolution_result="chose_best"
            else
                return 1
            fi
            ;;
        "merge_stories"|"merge_storybook_stories")
            if merge_storybook_stories "$file"; then
                resolution_result="merged_stories"
            else
                return 1
            fi
            ;;
        "manual_review")
            log_warning "Manual review required for $file"
            return 1
            ;;
        *)
            log_error "Unknown strategy: $strategy"
            return 1
            ;;
    esac
    
    # Record resolution
    RESOLUTIONS_APPLIED+=("$file:$strategy:$confidence:$resolution_result")
    log_success "Resolved: $file"
    return 0
}

# Main resolution workflow
resolve_conflicts() {
    local mode="${1:-auto}"
    local confidence_threshold="${2:-7.0}"
    local dry_run="${3:-false}"
    
    log_step "Starting conflict resolution (mode: $mode, confidence: $confidence_threshold)"
    
    # Detect conflicts
    if ! detect_conflicts; then
        return 1
    fi
    
    if [[ "${#CONFLICTS_FOUND[@]}" -eq 0 ]]; then
        log_success "No conflicts found!"
        return 0
    fi
    
    # Create backup unless dry run
    if [[ "$dry_run" != "true" ]]; then
        create_backup
    fi
    
    # Resolve each conflict
    local total_conflicts=${#CONFLICTS_FOUND[@]}
    local resolved_count=0
    local failed_count=0
    
    for conflict_info in "${CONFLICTS_FOUND[@]}"; do
        IFS=':' read -r status file conflict_type <<< "$conflict_info"
        
        # Get suggested strategy
        local analysis
        analysis=$(analyze_conflict "$conflict_info")
        IFS=':' read -r complexity confidence suggested_strategy <<< "$analysis"
        
        # Interactive mode: ask user
        if [[ "$mode" == "interactive" ]]; then
            echo
            log_info "Conflict: $file"
            log_info "Type: $conflict_type"
            log_info "Complexity: $complexity"
            log_info "Confidence: $confidence"
            log_info "Suggested: $suggested_strategy"
            
            read -p "Resolve automatically? [Y/n/s(kip)]: " -n 1 -r
            echo
            case $REPLY in
                [Nn]* ) 
                    log_info "Skipping $file"
                    continue
                    ;;
                [Ss]* )
                    log_info "Marking for manual review: $file"
                    failed_count=$((failed_count + 1))
                    continue
                    ;;
                * )
                    # Continue with auto-resolution
                    ;;
            esac
        fi
        
        # Attempt resolution
        if [[ "$dry_run" == "true" ]]; then
            log_info "[DRY RUN] Would resolve $file with strategy: $suggested_strategy"
            resolved_count=$((resolved_count + 1))
        else
            if resolve_conflict "$conflict_info" "$suggested_strategy" "$confidence_threshold"; then
                resolved_count=$((resolved_count + 1))
            else
                failed_count=$((failed_count + 1))
            fi
        fi
    done
    
    # Summary
    echo
    log_success "Resolution Summary:"
    log_info "Total conflicts: $total_conflicts"
    log_success "Resolved: $resolved_count"
    if [[ $failed_count -gt 0 ]]; then
        log_warning "Manual review needed: $failed_count"
    fi
    
    return 0
}

# Validate resolution results
validate_resolution() {
    log_step "Validating resolution results..."
    
    # Check if we still have conflicts
    if git status --porcelain | grep -E "^(AA|UU|DD)" > /dev/null; then
        log_error "Conflicts still remain after resolution"
        return 1
    fi
    
    # Run basic validation if validator is available
    if command -v validate_build >/dev/null 2>&1; then
        if ! validate_build; then
            log_error "Build validation failed"
            return 1
        fi
    fi
    
    log_success "Validation passed"
    return 0
}

# Generate resolution report
generate_report() {
    local report_file="$1"
    
    log_step "Generating resolution report..."
    
    mkdir -p "$(dirname "$report_file")"
    
    cat > "$report_file" << EOF
# Conflict Resolution Report

**Date**: $(date)
**Project**: $(basename "$PROJECT_ROOT")
**Resolver Version**: 1.0.0

## Summary

- **Total Conflicts Found**: ${#CONFLICTS_FOUND[@]}
- **Successfully Resolved**: ${#RESOLUTIONS_APPLIED[@]}
- **Manual Review Required**: $((${#CONFLICTS_FOUND[@]} - ${#RESOLUTIONS_APPLIED[@]}))

## Conflicts Found

EOF

    for conflict_info in "${CONFLICTS_FOUND[@]}"; do
        IFS=':' read -r status file conflict_type <<< "$conflict_info"
        echo "- **$file** ($conflict_type) - Status: $status" >> "$report_file"
    done
    
    cat >> "$report_file" << EOF

## Resolutions Applied

EOF

    for resolution in "${RESOLUTIONS_APPLIED[@]}"; do
        IFS=':' read -r file strategy confidence result <<< "$resolution"
        echo "- **$file** - Strategy: $strategy, Confidence: $confidence" >> "$report_file"
    done
    
    cat >> "$report_file" << EOF

## Recommendations

EOF

    if [[ ${#RESOLUTIONS_APPLIED[@]} -lt ${#CONFLICTS_FOUND[@]} ]]; then
        cat >> "$report_file" << EOF
Some conflicts require manual resolution. Consider:

1. Reviewing the conflicted files manually
2. Improving task separation in future parallel development
3. Adding project-specific resolution rules
EOF
    else
        echo "All conflicts were resolved successfully! 🎉" >> "$report_file"
    fi
    
    log_success "Report generated: $report_file"
}

# Main function
main() {
    local command="${1:-help}"
    local strategy="auto"
    local confidence="7.0"
    local backup="true"
    local validate="true"
    local report="true"
    local dry_run="false"
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --strategy=*)
                strategy="${1#*=}"
                shift
                ;;
            --confidence=*)
                confidence="${1#*=}"
                shift
                ;;
            --no-backup)
                backup="false"
                shift
                ;;
            --no-validate)
                validate="false"
                shift
                ;;
            --no-report)
                report="false"
                shift
                ;;
            --dry-run)
                dry_run="true"
                shift
                ;;
            analyze|resolve|interactive|status|rollback|help)
                command="$1"
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
    
    # Execute command
    case "$command" in
        "analyze")
            detect_conflicts
            for conflict_info in "${CONFLICTS_FOUND[@]}"; do
                echo "Analysis: $(analyze_conflict "$conflict_info")"
            done
            ;;
        "resolve")
            resolve_conflicts "$strategy" "$confidence" "$dry_run"
            if [[ "$validate" == "true" && "$dry_run" != "true" ]]; then
                validate_resolution
            fi
            if [[ "$report" == "true" ]]; then
                generate_report "$REPORT_FILE"
            fi
            ;;
        "interactive")
            resolve_conflicts "interactive" "$confidence" "$dry_run"
            if [[ "$validate" == "true" && "$dry_run" != "true" ]]; then
                validate_resolution
            fi
            if [[ "$report" == "true" ]]; then
                generate_report "$REPORT_FILE"
            fi
            ;;
        "status")
            detect_conflicts
            ;;
        "rollback")
            rollback
            ;;
        "help")
            show_help
            ;;
        *)
            log_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

# Run main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi