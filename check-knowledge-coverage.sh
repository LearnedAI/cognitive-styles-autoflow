#!/bin/bash

# Knowledge Gap Detection System
# Part of Modular MOD Intelligence Vault
# Analyzes task descriptions to determine knowledge coverage and gaps

VERSION="1.0.0"
KNOWLEDGE_INDEX="intelligence-vault/metadata/knowledge-index.json"
KEYWORD_MAPPINGS="intelligence-vault/metadata/keyword-mappings.json"
LEARNING_HISTORY="intelligence-vault/metadata/learning-history.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

usage() {
    echo "Usage: $0 '<task_description>'"
    echo "       $0 --analyze-domains"
    echo "       $0 --list-gaps"
    echo ""
    echo "Examples:"
    echo "  $0 'implement OAuth2 authentication with JWT tokens'"
    echo "  $0 'build real-time WebRTC video calling application'"
    echo "  $0 'optimize PostgreSQL query performance'"
}

# Extract keywords from task description
extract_keywords() {
    local task="$1"
    local keywords=()
    
    # Convert to lowercase for matching
    task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')
    
    # Extract keywords using jq from keyword mappings
    if [[ -f "$KEYWORD_MAPPINGS" ]]; then
        while IFS= read -r domain; do
            domain_keywords=$(jq -r ".natural_language_mappings[\"$domain\"] | .[]" "$KEYWORD_MAPPINGS" 2>/dev/null)
            while IFS= read -r keyword; do
                if [[ "$keyword" != "null" && "$task_lower" =~ $keyword ]]; then
                    keywords+=("$domain")
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
                            keywords+=("$domain")
                        fi
                    done <<< "$pattern_domains"
                fi
            fi
        done < <(jq -r '.phrase_patterns | keys[]' "$KEYWORD_MAPPINGS" 2>/dev/null)
    fi
    
    # Remove duplicates and return
    printf '%s\n' "${keywords[@]}" | sort -u
}

# Check coverage for identified domains
check_coverage() {
    local domains=("$@")
    local coverage_report=()
    local total_coverage=0
    local domain_count=${#domains[@]}
    
    if [[ $domain_count -eq 0 ]]; then
        echo -e "${YELLOW}⚠ No specific domains identified in task description${NC}"
        echo "Recommendation: Perform manual analysis or refine task description"
        return 1
    fi
    
    echo -e "${BLUE}📊 KNOWLEDGE COVERAGE ANALYSIS${NC}"
    echo "Identified domains: ${domains[*]}"
    echo ""
    
    for domain in "${domains[@]}"; do
        if [[ -f "$KNOWLEDGE_INDEX" ]]; then
            nugget_count=$(jq -r ".domains[\"$domain\"].nuggets | length" "$KNOWLEDGE_INDEX" 2>/dev/null)
            if [[ "$nugget_count" == "null" ]]; then
                nugget_count=0
            fi
            
            coverage_areas=$(jq -r ".domains[\"$domain\"].coverage_areas | length" "$KNOWLEDGE_INDEX" 2>/dev/null)
            if [[ "$coverage_areas" == "null" ]]; then
                coverage_areas=0
            fi
            
            # Calculate domain coverage score
            if [[ $nugget_count -eq 0 ]]; then
                coverage_score=0
            elif [[ $nugget_count -ge 3 && $coverage_areas -ge 5 ]]; then
                coverage_score=100
            elif [[ $nugget_count -ge 2 && $coverage_areas -ge 3 ]]; then
                coverage_score=75
            elif [[ $nugget_count -ge 1 && $coverage_areas -ge 1 ]]; then
                coverage_score=50
            else
                coverage_score=25
            fi
            
            total_coverage=$((total_coverage + coverage_score))
            
            # Display coverage status
            if [[ $coverage_score -eq 0 ]]; then
                echo -e "  ${RED}❌ $domain: NO COVERAGE${NC} (0 nuggets, 0 areas)"
                coverage_report+=("$domain:CRITICAL_GAP")
            elif [[ $coverage_score -ge 75 ]]; then
                echo -e "  ${GREEN}✅ $domain: EXPERT COVERAGE${NC} ($nugget_count nuggets, $coverage_areas areas)"
                coverage_report+=("$domain:EXPERT")
            elif [[ $coverage_score -ge 50 ]]; then
                echo -e "  ${YELLOW}⚠ $domain: PARTIAL COVERAGE${NC} ($nugget_count nuggets, $coverage_areas areas)"
                coverage_report+=("$domain:PARTIAL")
            else
                echo -e "  ${RED}❌ $domain: MINIMAL COVERAGE${NC} ($nugget_count nuggets, $coverage_areas areas)"
                coverage_report+=("$domain:MINIMAL")
            fi
        else
            echo -e "  ${RED}❌ $domain: KNOWLEDGE INDEX NOT FOUND${NC}"
            coverage_report+=("$domain:SYSTEM_ERROR")
        fi
    done
    
    # Calculate overall coverage
    if [[ $domain_count -gt 0 ]]; then
        overall_coverage=$((total_coverage / domain_count))
    else
        overall_coverage=0
    fi
    
    echo ""
    echo -e "${BLUE}📈 OVERALL ASSESSMENT${NC}"
    echo "Coverage Score: $overall_coverage%"
    
    # Provide recommendation
    if [[ $overall_coverage -ge 85 ]]; then
        echo -e "${GREEN}✅ EXPERT COVERAGE AVAILABLE${NC}"
        echo "Recommendation: LOAD_EXISTING_NUGGETS - Proceed with confidence"
        echo "Action: ./assemble-context.sh '$*' --expert-mode"
    elif [[ $overall_coverage -ge 50 ]]; then
        echo -e "${YELLOW}⚠ PARTIAL COVERAGE DETECTED${NC}"
        echo "Recommendation: LOAD_AVAILABLE_NUGGETS + FLAG_GAPS"
        echo "Action: ./assemble-context.sh '$*' --partial-mode"
        echo "Consider: Research specific gaps before implementation"
    else
        echo -e "${RED}❌ CRITICAL KNOWLEDGE GAPS DETECTED${NC}"
        echo "Recommendation: TRIGGER_KNOWLEDGE_ACQUISITION_PIPELINE"
        echo "Action: ./signal-style.sh think  # Research and create missing nuggets"
        echo "Next: Generate MOD nuggets for missing domains"
    fi
    
    return 0
}

# List all current knowledge gaps
list_gaps() {
    echo -e "${BLUE}🔍 CURRENT KNOWLEDGE GAPS${NC}"
    
    if [[ -f "$KNOWLEDGE_INDEX" ]]; then
        echo "Domains with no coverage:"
        jq -r '.domains | to_entries[] | select(.value.nuggets | length == 0) | .key' "$KNOWLEDGE_INDEX" | while read -r domain; do
            echo -e "  ${RED}❌ $domain${NC}"
        done
        
        echo ""
        echo "Domains with minimal coverage:"
        jq -r '.domains | to_entries[] | select((.value.nuggets | length) > 0 and (.value.nuggets | length) < 2) | .key' "$KNOWLEDGE_INDEX" | while read -r domain; do
            nugget_count=$(jq -r ".domains[\"$domain\"].nuggets | length" "$KNOWLEDGE_INDEX")
            echo -e "  ${YELLOW}⚠ $domain${NC} ($nugget_count nuggets)"
        done
    else
        echo -e "${RED}Knowledge index not found: $KNOWLEDGE_INDEX${NC}"
    fi
}

# Main execution logic
main() {
    if [[ $# -eq 0 ]]; then
        usage
        exit 1
    fi
    
    case "$1" in
        --analyze-domains)
            echo -e "${BLUE}📊 DOMAIN ANALYSIS${NC}"
            if [[ -f "$KNOWLEDGE_INDEX" ]]; then
                jq -r '.domains | to_entries[] | "\(.key): \(.value.nuggets | length) nuggets, \(.value.coverage_areas | length) areas"' "$KNOWLEDGE_INDEX"
            else
                echo -e "${RED}Knowledge index not found${NC}"
            fi
            ;;
        --list-gaps)
            list_gaps
            ;;
        --help|-h)
            usage
            ;;
        *)
            # Analyze specific task
            task_description="$*"
            echo -e "${BLUE}🔍 ANALYZING TASK: '$task_description'${NC}"
            echo ""
            
            # Extract keywords/domains
            domains=($(extract_keywords "$task_description"))
            
            # Check coverage
            check_coverage "${domains[@]}"
            ;;
    esac
}

main "$@"