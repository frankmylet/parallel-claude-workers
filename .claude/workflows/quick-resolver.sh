#!/bin/bash

# Quick Conflict Resolver - Simplified version for immediate use
# Resolves your current conflicts without complex scoring

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Simple merge for index.ts exports
merge_index_exports() {
    local file="$1"
    echo "Merging exports in $file..."
    
    # Extract unique exports from conflict
    local temp_file=$(mktemp)
    local merged_file=$(mktemp)
    
    # Get non-conflict content
    grep -v -E "^(<{7}|={7}|>{7})" "$file" > "$merged_file"
    
    # Extract exports from conflict sections
    local in_conflict=false
    while IFS= read -r line; do
        if [[ "$line" =~ ^\<\<\<\<\<\<\< ]] || [[ "$line" =~ ^\>\>\>\>\>\>\> ]] || [[ "$line" == "=======" ]]; then
            continue
        fi
        if [[ "$line" =~ ^export.*from ]]; then
            echo "$line" >> "$temp_file"
        fi
    done < "$file"
    
    # Add unique exports
    sort "$temp_file" | uniq >> "$merged_file"
    
    mv "$merged_file" "$file"
    rm -f "$temp_file"
    
    git add "$file"
    log_success "Merged exports in $file"
}

# Choose better implementation based on file size and content
choose_better_implementation() {
    local file="$1"
    echo "Choosing better implementation for $file..."
    
    local temp_head=$(mktemp)
    local temp_incoming=$(mktemp)
    local result_file=$(mktemp)
    
    local in_head=false
    local in_incoming=false
    
    while IFS= read -r line; do
        if [[ "$line" =~ ^\<\<\<\<\<\<\< ]]; then
            in_head=true
            continue
        elif [[ "$line" == "=======" ]]; then
            in_head=false
            in_incoming=true
            continue
        elif [[ "$line" =~ ^\>\>\>\>\>\>\> ]]; then
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
    
    # Simple scoring: longer file with more features wins
    local head_lines=$(wc -l < "$temp_head")
    local incoming_lines=$(wc -l < "$temp_incoming")
    local head_features=$(grep -c "interface\|type\|variants\|aria-" "$temp_head" 2>/dev/null || echo "0")
    local incoming_features=$(grep -c "interface\|type\|variants\|aria-" "$temp_incoming" 2>/dev/null || echo "0")
    
    if [[ $incoming_features -gt $head_features ]] || [[ $incoming_features -eq $head_features && $incoming_lines -gt $head_lines ]]; then
        log_success "Choosing incoming implementation (more features/content)"
        cat "$temp_incoming" >> "$result_file"
    else
        log_success "Choosing HEAD implementation"
        cat "$temp_head" >> "$result_file"
    fi
    
    mv "$result_file" "$file"
    rm -f "$temp_head" "$temp_incoming"
    
    git add "$file"
}

# Main resolution function
resolve_current_conflicts() {
    log_info "Quick conflict resolution starting..."
    
    # Check for conflicts
    if ! git status --porcelain | grep -E "^(AA|UU|DD)" > /dev/null; then
        log_error "No merge conflicts found"
        return 1
    fi
    
    # Process each conflicted file
    git status --porcelain | grep -E "^(AA|UU|DD)" | while read -r status file; do
        log_info "Resolving: $file"
        
        case "$file" in
            */index.ts)
                merge_index_exports "$file"
                ;;
            *.tsx|*.ts)
                if [[ "$file" =~ \.stories\. ]]; then
                    choose_better_implementation "$file"
                else
                    choose_better_implementation "$file"
                fi
                ;;
            *)
                choose_better_implementation "$file"
                ;;
        esac
    done
    
    # Check if we resolved everything
    if git status --porcelain | grep -E "^(AA|UU|DD)" > /dev/null; then
        log_error "Some conflicts still remain"
        return 1
    else
        log_success "All conflicts resolved!"
        log_info "You can now commit the changes"
        return 0
    fi
}

# Run the resolver
resolve_current_conflicts