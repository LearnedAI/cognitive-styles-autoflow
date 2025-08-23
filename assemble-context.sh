#!/bin/bash

# Intelligent Context Assembly System
# Part of Modular MOD Intelligence Vault
# Optimally selects and combines MOD nuggets for task-specific contexts

VERSION="1.0.0"
KNOWLEDGE_INDEX="intelligence-vault/metadata/knowledge-index.json"
KEYWORD_MAPPINGS="intelligence-vault/metadata/keyword-mappings.json"
DEFAULT_MAX_TOKENS=8000
DOMAIN_NUGGETS_DIR="intelligence-vault/domain-nuggets"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

usage() {
    echo "Usage: $0 '<task_description>' [options]"
    echo ""
    echo "Options:"
    echo "  --max-tokens NUM     Maximum tokens to use (default: $DEFAULT_MAX_TOKENS)"
    echo "  --focus MODE         Focus mode: implementation|troubleshooting|learning"
    echo "  --expert-mode        Assume expert coverage available"
    echo "  --partial-mode       Handle partial coverage scenarios"
    echo "  --output FILE        Output assembled context to file"
    echo "  --dry-run            Show selection without assembling"
    echo ""
    echo "Examples:"
    echo "  $0 'build authentication system' --max-tokens 8000"
    echo "  $0 'debug performance issues' --focus troubleshooting"
    echo "  $0 'learn React hooks' --focus learning --max-tokens 4000"
}

# Extract domains from task (reuse logic from check-knowledge-coverage.sh)
extract_domains() {
    local task="$1"
    local domains=()
    
    task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')
    
    if [[ -f "$KEYWORD_MAPPINGS" ]]; then
        while IFS= read -r domain; do
            domain_keywords=$(jq -r ".natural_language_mappings[\"$domain\"] | .[]" "$KEYWORD_MAPPINGS" 2>/dev/null)
            while IFS= read -r keyword; do
                if [[ "$keyword" != "null" && "$task_lower" =~ $keyword ]]; then
                    domains+=("$domain")
                    break
                fi
            done <<< "$domain_keywords"
        done < <(jq -r '.natural_language_mappings | keys[]' "$KEYWORD_MAPPINGS" 2>/dev/null)
        
        # Check phrase patterns
        while IFS= read -r pattern; do
            if [[ "$pattern" != "null" ]]; then
                if echo "$task_lower" | grep -qP "$pattern"; then
                    pattern_domains=$(jq -r ".phrase_patterns[\"$pattern\"] | .[]?" "$KEYWORD_MAPPINGS" 2>/dev/null)
                    while IFS= read -r domain; do
                        if [[ "$domain" != "null" && "$domain" != "" ]]; then
                            domains+=("$domain")
                        fi
                    done <<< "$pattern_domains"
                fi
            fi
        done < <(jq -r '.phrase_patterns | keys[]' "$KEYWORD_MAPPINGS" 2>/dev/null)
    fi
    
    printf '%s\n' "${domains[@]}" | sort -u
}

# Calculate relevance score for a nugget based on task and focus
calculate_relevance() {
    local domain="$1"
    local nugget="$2"
    local task="$3"
    local focus="$4"
    local base_score=50
    
    # Domain-specific relevance
    case "$domain" in
        "authentication") 
            if [[ "$task" =~ (login|auth|oauth|jwt|token) ]]; then
                base_score=95
            fi ;;
        "react")
            if [[ "$task" =~ (component|hook|react|jsx|frontend) ]]; then
                base_score=90
            fi ;;
        "databases")
            if [[ "$task" =~ (database|sql|query|schema) ]]; then
                base_score=88
            fi ;;
        "security")
            if [[ "$task" =~ (secure|vulnerability|encrypt|https) ]]; then
                base_score=92
            fi ;;
        "performance")
            if [[ "$task" =~ (optimize|performance|speed|memory) ]]; then
                base_score=94
            fi ;;
    esac
    
    # Focus-specific adjustments
    case "$focus" in
        "implementation")
            if [[ "$nugget" =~ (Implementation|Examples|Patterns) ]]; then
                base_score=$((base_score + 10))
            fi ;;
        "troubleshooting")
            if [[ "$nugget" =~ (Troubleshooting|Debug|Errors) ]]; then
                base_score=$((base_score + 15))
            fi ;;
        "learning")
            if [[ "$nugget" =~ (Basics|Introduction|Guide) ]]; then
                base_score=$((base_score + 12))
            fi ;;
    esac
    
    # Ensure score is within bounds
    if [[ $base_score -gt 100 ]]; then
        base_score=100
    elif [[ $base_score -lt 0 ]]; then
        base_score=0
    fi
    
    echo $base_score
}

# Estimate tokens for a MOD file
estimate_tokens() {
    local file="$1"
    if [[ -f "$file" ]]; then
        # Rough estimation: ~4 characters per token
        local chars=$(wc -c < "$file")
        echo $((chars / 4))
    else
        echo 0
    fi
}

# Select optimal nuggets within token limits
select_nuggets() {
    local task="$1"
    local focus="$2"
    local max_tokens="$3"
    shift 3
    local domains=("$@")
    
    local selected_nuggets=()
    local total_tokens=0
    local nugget_scores=()
    
    echo -e "${CYAN}🧠 INTELLIGENT NUGGET SELECTION${NC}" >&2
    echo "Task: $task" >&2
    echo "Focus: $focus" >&2
    echo "Token limit: $max_tokens" >&2
    echo "Target domains: ${domains[*]}" >&2
    echo "" >&2
    
    # Collect all available nuggets with scores
    for domain in "${domains[@]}"; do
        domain_dir="$DOMAIN_NUGGETS_DIR/$domain"
        if [[ -d "$domain_dir" ]]; then
            # Use nullglob to handle empty directories properly
            shopt -s nullglob
            nugget_files=("$domain_dir"/*.MOD)
            shopt -u nullglob
            
            for nugget_file in "${nugget_files[@]}"; do
                if [[ -f "$nugget_file" ]]; then
                    nugget_name=$(basename "$nugget_file" .MOD)
                    relevance=$(calculate_relevance "$domain" "$nugget_name" "$task" "$focus")
                    tokens=$(estimate_tokens "$nugget_file")
                    
                    # Store nugget info: domain:nugget:relevance:tokens:file
                    nugget_scores+=("$domain:$nugget_name:$relevance:$tokens:$nugget_file")
                fi
            done
        fi
    done
    
    if [[ ${#nugget_scores[@]} -eq 0 ]]; then
        echo -e "${RED}❌ No MOD nuggets found for target domains${NC}" >&2
        echo "Recommendation: Create MOD nuggets using research-think workflow" >&2
        return 1
    fi
    
    # Sort by relevance (descending)
    IFS=$'\n' nugget_scores=($(sort -t: -k3 -nr <<< "${nugget_scores[*]}"))
    
    # Greedy selection within token limits
    echo -e "${BLUE}📊 NUGGET SELECTION PROCESS${NC}" >&2
    for nugget_info in "${nugget_scores[@]}"; do
        IFS=':' read -ra parts <<< "$nugget_info"
        domain="${parts[0]}"
        nugget="${parts[1]}"
        relevance="${parts[2]}"
        tokens="${parts[3]}"
        file="${parts[4]}"
        
        if [[ $((total_tokens + tokens)) -le $max_tokens ]]; then
            selected_nuggets+=("$file")
            total_tokens=$((total_tokens + tokens))
            echo -e "  ${GREEN}✅ $domain/$nugget${NC} (relevance: $relevance%, tokens: $tokens)" >&2
        else
            echo -e "  ${YELLOW}⚠ $domain/$nugget${NC} (relevance: $relevance%, tokens: $tokens) - SKIPPED (would exceed limit)" >&2
        fi
    done
    
    echo "" >&2
    echo -e "${BLUE}📈 SELECTION SUMMARY${NC}" >&2
    echo "Selected nuggets: ${#selected_nuggets[@]}" >&2
    echo "Total tokens: $total_tokens / $max_tokens" >&2
    echo "Efficiency: $(( (total_tokens * 100) / max_tokens ))%" >&2
    
    # Return selected files (to stdout, which will be captured)
    for nugget in "${selected_nuggets[@]}"; do
        echo "$nugget"
    done
}

# Assemble context from selected nuggets
assemble_context() {
    local output_file="$1"
    local task="$2"
    shift 2
    local nugget_files=("$@")
    
    if [[ ${#nugget_files[@]} -eq 0 ]]; then
        echo -e "${RED}❌ No nuggets to assemble${NC}"
        return 1
    fi
    
    echo -e "${CYAN}🔧 ASSEMBLING CONTEXT${NC}"
    
    # Create context header
    local context_content="# INTELLIGENT CONTEXT ASSEMBLY
# Generated: $(date)
# Task: $task
# Nuggets: ${#nugget_files[@]}

## EXPERT CONTEXT LOADED
The following MOD nuggets have been assembled to provide expert-level domain knowledge for your task:

"
    
    # Add each nugget with clear separation
    local nugget_count=1
    for nugget_file in "${nugget_files[@]}"; do
        if [[ -f "$nugget_file" ]]; then
            nugget_name=$(basename "$nugget_file" .MOD)
            domain=$(basename "$(dirname "$nugget_file")")
            
            context_content+="---

## NUGGET $nugget_count: $domain/$nugget_name

"
            context_content+=$(cat "$nugget_file")
            context_content+="

"
            nugget_count=$((nugget_count + 1))
        fi
    done
    
    context_content+="
---

## CONTEXT ASSEMBLY COMPLETE

You now have expert-level knowledge in the relevant domains for this task. 
Proceed with implementation using the patterns, examples, and guidance provided above.
"
    
    # Output context
    if [[ "$output_file" != "" ]]; then
        echo "$context_content" > "$output_file"
        echo -e "${GREEN}✅ Context assembled to: $output_file${NC}"
    else
        echo "$context_content"
    fi
}

# Main execution logic
main() {
    local task=""
    local max_tokens=$DEFAULT_MAX_TOKENS
    local focus="implementation"
    local mode=""
    local output_file=""
    local dry_run=false
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --max-tokens)
                max_tokens="$2"
                shift 2
                ;;
            --focus)
                focus="$2"
                shift 2
                ;;
            --expert-mode)
                mode="expert"
                shift
                ;;
            --partial-mode)
                mode="partial"
                shift
                ;;
            --output)
                output_file="$2"
                shift 2
                ;;
            --dry-run)
                dry_run=true
                shift
                ;;
            --help|-h)
                usage
                exit 0
                ;;
            *)
                if [[ "$task" == "" ]]; then
                    task="$1"
                fi
                shift
                ;;
        esac
    done
    
    if [[ "$task" == "" ]]; then
        usage
        exit 1
    fi
    
    echo -e "${BLUE}🎯 CONTEXT ASSEMBLY SYSTEM v$VERSION${NC}"
    echo "Task: $task"
    echo ""
    
    # Extract domains
    domains=($(extract_domains "$task"))
    
    if [[ ${#domains[@]} -eq 0 ]]; then
        echo -e "${YELLOW}⚠ No specific domains identified${NC}"
        echo "Recommendation: Refine task description or perform manual nugget selection"
        exit 1
    fi
    
    # Select nuggets
    selected_nuggets=($(select_nuggets "$task" "$focus" "$max_tokens" "${domains[@]}"))
    
    if [[ ${#selected_nuggets[@]} -eq 0 ]]; then
        echo -e "${RED}❌ No suitable nuggets found${NC}"
        echo "Recommendation: Create MOD nuggets for identified domains first"
        exit 1
    fi
    
    if [[ "$dry_run" == true ]]; then
        echo -e "${CYAN}🔍 DRY RUN COMPLETE${NC}"
        echo "Would assemble ${#selected_nuggets[@]} nuggets"
        exit 0
    fi
    
    # Assemble context
    assemble_context "$output_file" "$task" "${selected_nuggets[@]}"
}

main "$@"