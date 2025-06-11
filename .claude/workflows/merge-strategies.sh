#!/bin/bash

# Merge Strategies for Intelligent Conflict Resolution
# Contains specific algorithms for different types of conflicts

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Helper functions for merge strategies
log_strategy() {
    echo -e "${BLUE}[STRATEGY]${NC} $1"
}

log_merge_success() {
    echo -e "${GREEN}[MERGE]${NC} $1"
}

log_merge_warning() {
    echo -e "${YELLOW}[MERGE]${NC} $1"
}

log_merge_error() {
    echo -e "${RED}[MERGE]${NC} $1"
}

# Strategy 1: Merge TypeScript exports (for index.ts files)
merge_typescript_exports() {
    local file="$1"
    
    log_strategy "Merging TypeScript exports in $file"
    
    if [[ ! -f "$file" ]]; then
        log_merge_error "File not found: $file"
        return 1
    fi
    
    # Create temporary file for processing
    local temp_file=$(mktemp)
    local result_file=$(mktemp)
    
    # Extract sections from conflict markers
    local in_head=false
    local in_incoming=false
    local head_content=()
    local incoming_content=()
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^\<\<\<\<\<\<\<[[:space:]] ]]; then
            in_head=true
            continue
        elif [[ "$line" == "=======" ]]; then
            in_head=false
            in_incoming=true
            continue
        elif [[ "$line" =~ ^\>\>\>\>\>\>\>[[:space:]] ]]; then
            in_incoming=false
            continue
        elif [[ "$in_head" == true ]]; then
            head_content+=("$line")
        elif [[ "$in_incoming" == true ]]; then
            incoming_content+=("$line")
        else
            # Non-conflict content - write directly to result
            echo "$line" >> "$result_file"
        fi
    done < "$file"
    
    # Process exports intelligently
    declare -A unique_exports
    declare -A export_lines
    
    # Function to extract export information
    extract_exports() {
        local content=("$@")
        for line in "${content[@]}"; do
            if [[ "$line" =~ ^export[[:space:]]+.*[[:space:]]+from[[:space:]]+ ]]; then
                # Extract the main export name for deduplication
                local export_key
                if [[ "$line" =~ export[[:space:]]+\{[[:space:]]*([^}]+)[[:space:]]*\} ]]; then
                    export_key="${BASH_REMATCH[1]// /}"
                    export_key="${export_key//,*/}" # Take first export for key
                elif [[ "$line" =~ export[[:space:]]+([A-Za-z][A-Za-z0-9_]*) ]]; then
                    export_key="${BASH_REMATCH[1]}"
                else
                    export_key="$line"
                fi
                
                unique_exports["$export_key"]="$line"
                export_lines["$export_key"]="$line"
            elif [[ "$line" =~ ^export[[:space:]]+ ]]; then
                # Handle other export types
                unique_exports["$line"]="$line"
                export_lines["$line"]="$line"
            fi
        done
    }
    
    # Extract exports from both sides
    extract_exports "${head_content[@]}"
    extract_exports "${incoming_content[@]}"
    
    # Write merged exports to result file
    for export_key in $(printf '%s\n' "${!unique_exports[@]}" | sort); do
        echo "${unique_exports[$export_key]}" >> "$result_file"
    done
    
    # Replace original file with merged result
    mv "$result_file" "$file"
    rm -f "$temp_file"
    
    log_merge_success "Merged ${#unique_exports[@]} unique exports in $file"
    return 0
}

# Strategy 2: Choose best implementation (for component files)
choose_best_implementation() {
    local file="$1"
    
    log_strategy "Choosing best implementation for $file"
    
    if [[ ! -f "$file" ]]; then
        log_merge_error "File not found: $file"
        return 1
    fi
    
    # Extract HEAD and incoming versions
    local temp_head=$(mktemp)
    local temp_incoming=$(mktemp)
    local result_file=$(mktemp)
    
    local in_head=false
    local in_incoming=false
    local current_section="none"
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^\<\<\<\<\<\<\<[[:space:]] ]]; then
            in_head=true
            current_section="head"
            continue
        elif [[ "$line" == "=======" ]]; then
            in_head=false
            in_incoming=true
            current_section="incoming"
            continue
        elif [[ "$line" =~ ^\>\>\>\>\>\>\>[[:space:]] ]]; then
            in_incoming=false
            current_section="none"
            continue
        elif [[ "$in_head" == true ]]; then
            echo "$line" >> "$temp_head"
        elif [[ "$in_incoming" == true ]]; then
            echo "$line" >> "$temp_incoming"
        else
            echo "$line" >> "$result_file"
        fi
    done < "$file"
    
    # Score implementations
    local head_score
    local incoming_score
    
    head_score=$(score_implementation "$temp_head")
    incoming_score=$(score_implementation "$temp_incoming")
    
    log_strategy "HEAD score: $head_score, Incoming score: $incoming_score"
    
    # Choose better implementation (using python for comparison)
    local better_is_incoming
    better_is_incoming=$(python3 -c "print($incoming_score > $head_score)" 2>/dev/null || echo "False")
    
    if [[ "$better_is_incoming" == "True" ]]; then
        log_merge_success "Choosing incoming implementation (score: $incoming_score)"
        cat "$temp_incoming" >> "$result_file"
    else
        log_merge_success "Choosing HEAD implementation (score: $head_score)"
        cat "$temp_head" >> "$result_file"
    fi
    
    # Replace original file
    mv "$result_file" "$file"
    rm -f "$temp_head" "$temp_incoming"
    
    return 0
}

# Score implementation quality (basic version)
score_implementation() {
    local file="$1"
    local score=5.0
    
    if [[ ! -f "$file" ]]; then
        echo "0.0"
        return
    fi
    
    local line_count=$(wc -l < "$file")
    local comment_count=$(grep -c "^\s*//" "$file" || echo "0")
    local prop_count=$(grep -c "interface.*Props\|type.*Props" "$file" || echo "0")
    local variant_count=$(grep -c "variants:" "$file" || echo "0")
    local accessibility_count=$(grep -c "aria-\|role=" "$file" || echo "0")
    
    # Scoring algorithm (using python for arithmetic)
    # Base score: 5.0
    # +1.0 for good documentation (comments)
    # +1.0 for TypeScript props interface
    # +1.0 for CVA variants
    # +0.5 for accessibility features
    # +0.5 for reasonable length (not too short or too long)
    
    if [[ $comment_count -gt 3 ]]; then
        score=$(python3 -c "print($score + 1.0)" 2>/dev/null || echo "$score")
    fi
    
    if [[ $prop_count -gt 0 ]]; then
        score=$(python3 -c "print($score + 1.0)" 2>/dev/null || echo "$score")
    fi
    
    if [[ $variant_count -gt 0 ]]; then
        score=$(python3 -c "print($score + 1.0)" 2>/dev/null || echo "$score")
    fi
    
    if [[ $accessibility_count -gt 0 ]]; then
        score=$(python3 -c "print($score + 0.5)" 2>/dev/null || echo "$score")
    fi
    
    if [[ $line_count -gt 50 && $line_count -lt 300 ]]; then
        score=$(python3 -c "print($score + 0.5)" 2>/dev/null || echo "$score")
    fi
    
    echo "$score"
}

# Strategy 3: Merge Storybook stories
merge_storybook_stories() {
    local file="$1"
    
    log_strategy "Merging Storybook stories in $file"
    
    if [[ ! -f "$file" ]]; then
        log_merge_error "File not found: $file"
        return 1
    fi
    
    # For Storybook files, we generally want to merge unique stories
    # This is a simplified version - could be enhanced with AST parsing
    
    local temp_head=$(mktemp)
    local temp_incoming=$(mktemp)
    local result_file=$(mktemp)
    
    local in_head=false
    local in_incoming=false
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^\<\<\<\<\<\<\<[[:space:]] ]]; then
            in_head=true
            continue
        elif [[ "$line" == "=======" ]]; then
            in_head=false
            in_incoming=true
            continue
        elif [[ "$line" =~ ^\>\>\>\>\>\>\>[[:space:]] ]]; then
            in_incoming=false
            continue
        elif [[ "$in_head" == true ]]; then
            echo "$line" >> "$temp_head"
        elif [[ "$in_incoming" == true ]]; then
            echo "$line" >> "$temp_incoming"
        else
            echo "$line" >> "$result_file"
        fi
    done < "$file"
    
    # For now, choose the implementation with more stories
    local head_story_count
    local incoming_story_count
    
    head_story_count=$(grep -c "export const.*Story\|export const.*=.*{" "$temp_head" || echo "0")
    incoming_story_count=$(grep -c "export const.*Story\|export const.*=.*{" "$temp_incoming" || echo "0")
    
    if [[ $incoming_story_count -gt $head_story_count ]]; then
        log_merge_success "Choosing incoming stories ($incoming_story_count vs $head_story_count stories)"
        cat "$temp_incoming" >> "$result_file"
    else
        log_merge_success "Choosing HEAD stories ($head_story_count vs $incoming_story_count stories)"
        cat "$temp_head" >> "$result_file"
    fi
    
    mv "$result_file" "$file"
    rm -f "$temp_head" "$temp_incoming"
    
    return 0
}

# Strategy 4: Smart merge for CSS/styles
merge_css_styles() {
    local file="$1"
    
    log_strategy "Merging CSS styles in $file"
    
    # For CSS files, we want to combine unique selectors
    # This is a basic implementation
    
    local temp_file=$(mktemp)
    local result_file=$(mktemp)
    
    # Remove conflict markers and combine content
    grep -v -E "^(<{7}|={7}|>{7})" "$file" > "$temp_file"
    
    # Sort and deduplicate CSS rules (basic approach)
    sort "$temp_file" | uniq > "$result_file"
    
    mv "$result_file" "$file"
    rm -f "$temp_file"
    
    log_merge_success "Merged CSS styles in $file"
    return 0
}

# Strategy 5: Merge JSON configurations
merge_json_config() {
    local file="$1"
    
    log_strategy "Merging JSON configuration in $file"
    
    # For JSON files, we need to be more careful
    # This is a placeholder for more sophisticated JSON merging
    
    # Try to parse and merge JSON objects
    # For now, choose the larger/more complete version
    
    local temp_head=$(mktemp)
    local temp_incoming=$(mktemp)
    
    local in_head=false
    local in_incoming=false
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^\<\<\<\<\<\<\<[[:space:]] ]]; then
            in_head=true
            continue
        elif [[ "$line" == "=======" ]]; then
            in_head=false
            in_incoming=true
            continue
        elif [[ "$line" =~ ^\>\>\>\>\>\>\>[[:space:]] ]]; then
            in_incoming=false
            continue
        elif [[ "$in_head" == true ]]; then
            echo "$line" >> "$temp_head"
        elif [[ "$in_incoming" == true ]]; then
            echo "$line" >> "$temp_incoming"
        fi
    done < "$file"
    
    # Basic size comparison for now
    local head_size
    local incoming_size
    
    head_size=$(wc -c < "$temp_head")
    incoming_size=$(wc -c < "$temp_incoming")
    
    if [[ $incoming_size -gt $head_size ]]; then
        log_merge_success "Choosing incoming JSON (larger configuration)"
        cp "$temp_incoming" "$file"
    else
        log_merge_success "Choosing HEAD JSON"
        cp "$temp_head" "$file"
    fi
    
    rm -f "$temp_head" "$temp_incoming"
    return 0
}

# Strategy 6: Hybrid merge (combine best parts)
hybrid_merge() {
    local file="$1"
    local merge_type="$2"
    
    log_strategy "Performing hybrid merge for $file (type: $merge_type)"
    
    case "$merge_type" in
        "component_props")
            # Merge props interfaces and keep best implementation
            hybrid_merge_component_props "$file"
            ;;
        "story_examples")
            # Merge unique story examples
            hybrid_merge_story_examples "$file"
            ;;
        "css_variants")
            # Merge CSS variants and classes
            hybrid_merge_css_variants "$file"
            ;;
        *)
            log_merge_warning "Unknown hybrid merge type: $merge_type"
            choose_best_implementation "$file"
            ;;
    esac
}

# Helper: Merge component props
hybrid_merge_component_props() {
    local file="$1"
    
    # This would require AST parsing for proper implementation
    # For now, fall back to best implementation choice
    choose_best_implementation "$file"
}

# Helper: Merge story examples
hybrid_merge_story_examples() {
    local file="$1"
    
    # Extract unique story exports and combine them
    # This is a simplified version
    merge_storybook_stories "$file"
}

# Helper: Merge CSS variants
hybrid_merge_css_variants() {
    local file="$1"
    
    # Combine unique CSS classes and variants
    merge_css_styles "$file"
}

# Strategy selection based on file analysis
select_merge_strategy() {
    local file="$1"
    local conflict_type="$2"
    local analysis="$3"
    
    IFS=':' read -r complexity confidence suggested_strategy <<< "$analysis"
    
    case "$conflict_type" in
        "INDEX_EXPORTS")
            echo "merge_typescript_exports"
            ;;
        "TYPESCRIPT_COMPONENT")
            if (( $(echo "$confidence > 8.0" | bc -l) )); then
                echo "choose_best_implementation"
            else
                echo "hybrid_merge"
            fi
            ;;
        "STORYBOOK_STORY")
            echo "merge_storybook_stories"
            ;;
        "STYLESHEET")
            echo "merge_css_styles"
            ;;
        "JSON_CONFIG")
            echo "merge_json_config"
            ;;
        *)
            echo "choose_best_implementation"
            ;;
    esac
}

# Apply merge strategy to file
apply_merge_strategy() {
    local file="$1"
    local strategy="$2"
    local conflict_type="$3"
    
    log_strategy "Applying $strategy to $file"
    
    case "$strategy" in
        "merge_typescript_exports")
            merge_typescript_exports "$file"
            ;;
        "choose_best_implementation")
            choose_best_implementation "$file"
            ;;
        "merge_storybook_stories")
            merge_storybook_stories "$file"
            ;;
        "merge_css_styles")
            merge_css_styles "$file"
            ;;
        "merge_json_config")
            merge_json_config "$file"
            ;;
        "hybrid_merge")
            hybrid_merge "$file" "$conflict_type"
            ;;
        *)
            log_merge_error "Unknown merge strategy: $strategy"
            return 1
            ;;
    esac
    
    # Mark file as resolved
    git add "$file"
    
    return 0
}

# Validate merge result
validate_merge_result() {
    local file="$1"
    
    # Check if file still has conflict markers
    if grep -q -E "^(<{7}|={7}|>{7})" "$file"; then
        log_merge_error "Conflict markers still present in $file"
        return 1
    fi
    
    # Basic syntax validation for different file types
    case "$file" in
        *.ts|*.tsx)
            # TypeScript syntax check (if tsc is available)
            if command -v tsc >/dev/null 2>&1; then
                tsc --noEmit --skipLibCheck "$file" 2>/dev/null || {
                    log_merge_warning "TypeScript syntax issues in $file"
                    return 1
                }
            fi
            ;;
        *.json)
            # JSON validation
            if command -v jq >/dev/null 2>&1; then
                jq . "$file" >/dev/null 2>&1 || {
                    log_merge_error "Invalid JSON in $file"
                    return 1
                }
            fi
            ;;
    esac
    
    log_merge_success "Merge validation passed for $file"
    return 0
}

# Export functions for use in conflict-resolver.sh
export -f merge_typescript_exports
export -f choose_best_implementation
export -f merge_storybook_stories
export -f merge_css_styles
export -f merge_json_config
export -f hybrid_merge
export -f apply_merge_strategy
export -f validate_merge_result
export -f select_merge_strategy
export -f score_implementation