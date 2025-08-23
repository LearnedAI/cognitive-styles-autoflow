#!/bin/bash

# Enhanced Confidence Assessment with Knowledge Completeness
# Integrates Intelligence Vault for comprehensive plan evaluation
# 5-dimensional confidence scoring with official documentation validation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIDENCE_LOG="$SCRIPT_DIR/enhanced-confidence-assessment.log"
CONFIDENCE_REPORT="$SCRIPT_DIR/enhanced-confidence-report.json"
INTELLIGENCE_VAULT="$SCRIPT_DIR/intelligence-vault"
KNOWLEDGE_INDEX="$INTELLIGENCE_VAULT/metadata/knowledge-index.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

# Initialize enhanced logging
log_confidence() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
    echo "[$timestamp] [$level] $message" | tee -a "$CONFIDENCE_LOG"
}

# NEW: Knowledge Completeness Assessment
assess_knowledge_completeness() {
    local plan_text="$1"
    local knowledge_score=0
    
    log_confidence "INFO" "Assessing knowledge completeness for plan domains"
    
    # Extract domains from plan text using existing intelligence vault logic
    local domains=()
    if [[ -f "$SCRIPT_DIR/check-knowledge-coverage.sh" ]]; then
        # Use our existing domain extraction logic
        domains=($(echo "$plan_text" | tr '[:upper:]' '[:lower:]' | \
            grep -oE 'auth|oauth|jwt|token|react|component|hook|database|sql|query|git|worktree|branch|performance|optimize|docker|container|security|encrypt|typescript|nodejs|api'))
        
        # Remove duplicates
        domains=($(printf '%s\n' "${domains[@]}" | sort -u))
    fi
    
    if [[ ${#domains[@]} -eq 0 ]]; then
        log_confidence "WARN" "No specific technical domains identified in plan"
        knowledge_score=30  # Baseline for general tasks
        echo "$knowledge_score"
        return
    fi
    
    local total_coverage=0
    local domain_count=0
    
    echo -e "${PURPLE}🧠 KNOWLEDGE COMPLETENESS ANALYSIS${NC}" >&2
    
    for domain in "${domains[@]}"; do
        domain_count=$((domain_count + 1))
        local coverage_score=0
        
        # Map extracted keywords to our domain structure
        case "$domain" in
            "auth"|"oauth"|"jwt"|"token")
                domain_name="authentication"
                ;;
            "react"|"component"|"hook")
                domain_name="react"
                ;;
            "database"|"sql"|"query")
                domain_name="databases"
                ;;
            "git"|"worktree"|"branch")
                domain_name="git"
                ;;
            "performance"|"optimize")
                domain_name="performance"
                ;;
            "docker"|"container")
                domain_name="docker"
                ;;
            "security"|"encrypt")
                domain_name="security"
                ;;
            "typescript")
                domain_name="typescript"
                ;;
            "nodejs"|"api")
                domain_name="nodejs"
                ;;
            *)
                domain_name="$domain"
                ;;
        esac
        
        # Check knowledge vault for domain coverage
        if [[ -f "$KNOWLEDGE_INDEX" ]]; then
            local nugget_count=$(jq -r ".domains[\"$domain_name\"].nuggets | length" "$KNOWLEDGE_INDEX" 2>/dev/null || echo "0")
            local coverage_areas=$(jq -r ".domains[\"$domain_name\"].coverage_areas | length" "$KNOWLEDGE_INDEX" 2>/dev/null || echo "0")
            
            # Calculate domain-specific knowledge score
            if [[ "$nugget_count" == "null" ]]; then nugget_count=0; fi
            if [[ "$coverage_areas" == "null" ]]; then coverage_areas=0; fi
            
            if [[ $nugget_count -eq 0 ]]; then
                coverage_score=0
                echo -e "  ${RED}❌ $domain_name: NO KNOWLEDGE BASE${NC}" >&2
                log_confidence "CRITICAL" "Zero knowledge coverage for domain: $domain_name"
            elif [[ $nugget_count -ge 3 && $coverage_areas -ge 5 ]]; then
                coverage_score=100
                echo -e "  ${GREEN}✅ $domain_name: EXPERT KNOWLEDGE${NC} ($nugget_count nuggets, $coverage_areas areas)" >&2
            elif [[ $nugget_count -ge 2 && $coverage_areas -ge 3 ]]; then
                coverage_score=75
                echo -e "  ${YELLOW}⚠ $domain_name: GOOD KNOWLEDGE${NC} ($nugget_count nuggets, $coverage_areas areas)" >&2
            elif [[ $nugget_count -ge 1 ]]; then
                coverage_score=50
                echo -e "  ${YELLOW}⚠ $domain_name: BASIC KNOWLEDGE${NC} ($nugget_count nuggets, $coverage_areas areas)" >&2
            else
                coverage_score=25
                echo -e "  ${RED}❌ $domain_name: MINIMAL KNOWLEDGE${NC}" >&2
            fi
            
            total_coverage=$((total_coverage + coverage_score))
        else
            log_confidence "ERROR" "Knowledge index not found at $KNOWLEDGE_INDEX"
            coverage_score=0
            total_coverage=$((total_coverage + coverage_score))
        fi
    done
    
    # Calculate average knowledge completeness
    if [[ $domain_count -gt 0 ]]; then
        knowledge_score=$((total_coverage / domain_count))
    else
        knowledge_score=50  # Neutral baseline
    fi
    
    echo -e "  ${BLUE}📊 Overall Knowledge Coverage: ${knowledge_score}%${NC}" >&2
    
    # Apply knowledge quality multipliers
    # Check for official documentation backing
    if [[ -d "$INTELLIGENCE_VAULT/official-docs" ]]; then
        local doc_coverage=$(find "$INTELLIGENCE_VAULT/official-docs" -name "*.md" -o -name "*.MOD" | wc -l)
        if [[ $doc_coverage -gt 5 ]]; then
            knowledge_score=$((knowledge_score + 10))  # Bonus for official docs
            echo -e "  ${GREEN}📚 Official Documentation Bonus: +10%${NC}" >&2
        fi
    fi
    
    # Penalty for unvalidated knowledge
    if [[ $knowledge_score -lt 75 ]]; then
        echo -e "  ${RED}⚠ Knowledge gaps may lead to implementation risks${NC}" >&2
        log_confidence "WARN" "Knowledge completeness below expert threshold: $knowledge_score%"
    fi
    
    echo "$knowledge_score"
}

# Enhanced confidence calculation with 5 dimensions
calculate_enhanced_confidence() {
    local plan_text="$1"
    local user_context="${2:-}"
    
    log_confidence "INFO" "Starting enhanced 5-dimensional confidence assessment"
    
    # Original 4 dimensions (preserved from existing system)
    local completeness_score=$(assess_plan_completeness "$plan_text")
    local risk_score=$(assess_implementation_risk "$plan_text") 
    local intent_score=$(analyze_user_intent "$user_context")
    local readiness_score=$(verify_system_readiness)
    
    # NEW: 5th dimension - Knowledge Completeness
    local knowledge_score=$(assess_knowledge_completeness "$plan_text")
    
    # Enhanced weighted calculation including knowledge
    local weighted_scores=(
        "$((completeness_score * 25))"      # 25% weight
        "$((risk_score * 30))"              # 30% weight (inverted)
        "$((intent_score * 15))"            # 15% weight
        "$((readiness_score * 10))"         # 10% weight
        "$((knowledge_score * 20))"         # 20% weight (NEW)
    )
    
    local total_weighted=$((${weighted_scores[0]} + ${weighted_scores[1]} + ${weighted_scores[2]} + ${weighted_scores[3]} + ${weighted_scores[4]}))
    local confidence_score=$((total_weighted / 100))
    
    # Knowledge-based recommendation logic
    local recommendation="PROCEED_WITH_EXPLANATION"
    if [[ $confidence_score -ge 85 && $knowledge_score -ge 75 ]]; then
        recommendation="AUTO_PROCEED"
    elif [[ $confidence_score -ge 70 && $knowledge_score -ge 50 ]]; then
        recommendation="PROCEED_WITH_EXPLANATION"
    elif [[ $knowledge_score -lt 25 ]]; then
        recommendation="RESEARCH_REQUIRED"
    else
        recommendation="MANUAL_APPROVAL_REQUIRED"
    fi
    
    # Generate enhanced confidence report
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%S.%3NZ")
    
    cat > "$CONFIDENCE_REPORT" <<EOF
{
    "timestamp": "$timestamp",
    "version": "enhanced-5d",
    "scores": {
        "completeness": $completeness_score,
        "risk": $risk_score,
        "intent": $intent_score,
        "readiness": $readiness_score,
        "knowledge": $knowledge_score,
        "confidence": $confidence_score
    },
    "weights": {
        "completeness": 25,
        "risk": 30,
        "intent": 15,
        "readiness": 10,
        "knowledge": 20
    },
    "thresholds": {
        "high_confidence": 85,
        "medium_confidence": 70,
        "low_confidence": 50,
        "expert_knowledge": 75,
        "minimal_knowledge": 25
    },
    "recommendation": "$recommendation",
    "explanation": {
        "completeness": "Plan structure and detail assessment",
        "risk": "Implementation safety and reversibility evaluation",
        "intent": "User expectation and approval signals analysis",
        "readiness": "System state and resource availability check",
        "knowledge": "Domain expertise and documentation completeness"
    },
    "knowledge_analysis": {
        "domains_identified": $(echo "$plan_text" | tr '[:upper:]' '[:lower:]' | grep -oE 'auth|oauth|jwt|token|react|component|hook|database|sql|query|git|worktree|branch|performance|optimize|docker|container|security|encrypt|typescript|nodejs|api' | sort -u | jq -R . | jq -s .),
        "vault_status": "$(test -f "$KNOWLEDGE_INDEX" && echo "available" || echo "missing")",
        "recommendation_detail": "$(get_knowledge_recommendation "$knowledge_score" "$confidence_score")"
    }
}
EOF

    echo "$confidence_score"
}

# Get knowledge-based recommendation details
get_knowledge_recommendation() {
    local knowledge_score="$1"
    local confidence_score="$2"
    
    if [[ $knowledge_score -lt 25 ]]; then
        echo "Critical knowledge gaps detected. Recommend research-think workflow to build domain expertise before implementation."
    elif [[ $knowledge_score -lt 50 ]]; then
        echo "Partial knowledge available. Consider loading existing MOD nuggets and flagging specific gaps."
    elif [[ $knowledge_score -lt 75 ]]; then
        echo "Good knowledge base available. Proceed with existing nuggets and targeted research for gaps."
    else
        echo "Expert-level knowledge available. Proceed with confidence using assembled context from intelligence vault."
    fi
}

# Placeholder functions for compatibility (would source from original confidence-assessment.sh)
assess_plan_completeness() {
    local plan_text="$1"
    # Simplified implementation - in production, source from original script
    local score=70
    if [[ "$plan_text" =~ "Step"|"Phase"|"##" ]]; then score=$((score + 20)); fi
    if [[ "$plan_text" =~ "implement"|"create"|"build" ]]; then score=$((score + 10)); fi
    echo "$score"
}

assess_implementation_risk() {
    local plan_text="$1"
    # Simplified implementation - lower risk score is better (inverted)
    local risk=20  # Low risk baseline
    if [[ "$plan_text" =~ "delete"|"remove"|"destroy" ]]; then risk=$((risk + 30)); fi
    echo "$risk"
}

analyze_user_intent() {
    local user_context="$1"
    local intent=60  # Baseline
    if [[ "$user_context" =~ "implement"|"build"|"proceed" ]]; then intent=$((intent + 20)); fi
    if [[ "$user_context" =~ "maybe"|"perhaps"|"careful" ]]; then intent=$((intent - 15)); fi
    echo "$intent"
}

verify_system_readiness() {
    local readiness=80  # Generally ready baseline
    if ! git status &>/dev/null; then readiness=$((readiness - 20)); fi
    echo "$readiness"
}

# Main execution
main() {
    local plan_text="$1"
    local user_context="$2"
    
    if [[ -z "$plan_text" ]]; then
        echo "Usage: $0 '<plan_text>' [user_context]"
        echo "Enhanced confidence assessment with knowledge completeness evaluation"
        exit 1
    fi
    
    echo -e "${BLUE}🎯 ENHANCED CONFIDENCE ASSESSMENT v2.0${NC}"
    echo -e "${CYAN}Plan Analysis with Intelligence Vault Integration${NC}"
    echo ""
    
    local confidence=$(calculate_enhanced_confidence "$plan_text" "$user_context")
    
    echo ""
    echo -e "${BLUE}📊 CONFIDENCE ASSESSMENT COMPLETE${NC}"
    echo "Overall Confidence: $confidence%"
    
    # Display recommendation
    local recommendation=$(jq -r '.recommendation' "$CONFIDENCE_REPORT" 2>/dev/null || echo "UNKNOWN")
    case "$recommendation" in
        "AUTO_PROCEED")
            echo -e "${GREEN}✅ RECOMMENDATION: AUTO-PROCEED${NC}"
            echo "High confidence with expert knowledge backing. Safe to implement."
            ;;
        "PROCEED_WITH_EXPLANATION") 
            echo -e "${YELLOW}⚠ RECOMMENDATION: PROCEED WITH EXPLANATION${NC}"
            echo "Good confidence with adequate knowledge. Explain approach before implementing."
            ;;
        "RESEARCH_REQUIRED")
            echo -e "${RED}🔬 RECOMMENDATION: RESEARCH REQUIRED${NC}"
            echo "Critical knowledge gaps detected. Use research-think workflow first."
            ;;
        "MANUAL_APPROVAL_REQUIRED")
            echo -e "${RED}⏸ RECOMMENDATION: MANUAL APPROVAL REQUIRED${NC}"
            echo "Low confidence or insufficient knowledge. Require explicit user approval."
            ;;
    esac
    
    echo ""
    echo "Report saved to: $CONFIDENCE_REPORT"
}

main "$@"