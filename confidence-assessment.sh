#!/bin/bash

# Cognitive Automation System - Confidence Assessment Engine
# Intelligent grading loop for plan mode exit decisions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIDENCE_LOG="$SCRIPT_DIR/confidence-assessment.log"
CONFIDENCE_REPORT="$SCRIPT_DIR/confidence-report.json"

# Initialize logging
log_confidence() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
    echo "[$timestamp] [$level] $message" | tee -a "$CONFIDENCE_LOG"
}

# Confidence scoring functions
assess_plan_completeness() {
    local completeness_score=0
    
    # Check if plan has specific steps (basic requirement)
    if [[ "$PLAN_TEXT" =~ "Step"[[:space:]]|"Phase"[[:space:]]|"##"[[:space:]] ]]; then
        completeness_score=$((completeness_score + 25))
    fi
    
    # Check for implementation details
    if [[ "$PLAN_TEXT" =~ "implement"|"create"|"build"|"modify" ]]; then
        completeness_score=$((completeness_score + 20))
    fi
    
    # Check for resource identification
    if [[ "$PLAN_TEXT" =~ "file"|"script"|"command"|"tool" ]]; then
        completeness_score=$((completeness_score + 20))
    fi
    
    # Check for success criteria or expected outcomes
    if [[ "$PLAN_TEXT" =~ "result"|"outcome"|"expected"|"verify"|"test" ]]; then
        completeness_score=$((completeness_score + 20))
    fi
    
    # Check for structure and organization
    if [[ $(echo "$PLAN_TEXT" | wc -l) -gt 10 ]]; then
        completeness_score=$((completeness_score + 15))
    fi
    
    echo $completeness_score
}

assess_implementation_risk() {
    local risk_score=0
    
    # High risk indicators (increase risk score)
    if [[ "$PLAN_TEXT" =~ "delete"|"remove"|"rm "|"DROP"|"truncate" ]]; then
        risk_score=$((risk_score + 40))
    fi
    
    # System modification risks
    if [[ "$PLAN_TEXT" =~ "production"|"live"|"deploy"|"release" ]]; then
        risk_score=$((risk_score + 30))
    fi
    
    # Database/critical system risks
    if [[ "$PLAN_TEXT" =~ "database"|"db"|"migration"|"schema" ]]; then
        risk_score=$((risk_score + 25))
    fi
    
    # Network/security risks
    if [[ "$PLAN_TEXT" =~ "network"|"security"|"auth"|"permission"|"sudo" ]]; then
        risk_score=$((risk_score + 20))
    fi
    
    # File system risks
    if [[ "$PLAN_TEXT" =~ "chmod"|"chown"|"mv "|"/etc/"|"/usr/" ]]; then
        risk_score=$((risk_score + 15))
    fi
    
    # Low risk indicators (decrease risk score)
    if [[ "$PLAN_TEXT" =~ "read-only"|"analyze"|"research"|"documentation" ]]; then
        risk_score=$((risk_score - 20))
    fi
    
    # Isolated environment indicators (lower risk)
    if [[ "$PLAN_TEXT" =~ "worktree"|"experimental"|"test"|"sandbox" ]]; then
        risk_score=$((risk_score - 15))
    fi
    
    # Version control safety (lower risk)
    if [[ "$PLAN_TEXT" =~ "git"|"commit"|"branch"|"backup" ]]; then
        risk_score=$((risk_score - 10))
    fi
    
    # Ensure risk score is within bounds
    if [[ $risk_score -lt 0 ]]; then risk_score=0; fi
    if [[ $risk_score -gt 100 ]]; then risk_score=100; fi
    
    echo $risk_score
}

analyze_user_intent() {
    local intent_score=50  # Neutral baseline
    
    # Strong implementation intent indicators
    if [[ "$USER_CONTEXT" =~ "implement"|"build"|"create"|"make"|"do it"|"proceed" ]]; then
        intent_score=$((intent_score + 25))
    fi
    
    # Time/urgency indicators
    if [[ "$USER_CONTEXT" =~ "quickly"|"fast"|"now"|"immediately"|"urgent" ]]; then
        intent_score=$((intent_score + 20))
    fi
    
    # Approval language
    if [[ "$USER_CONTEXT" =~ "yes"|"go ahead"|"sounds good"|"looks good"|"approve" ]]; then
        intent_score=$((intent_score + 20))
    fi
    
    # Automation request indicators
    if [[ "$USER_CONTEXT" =~ "automat"|"autonomous"|"self"|"continue" ]]; then
        intent_score=$((intent_score + 15))
    fi
    
    # Hesitation indicators (decrease score)
    if [[ "$USER_CONTEXT" =~ "maybe"|"perhaps"|"might"|"consider"|"think about" ]]; then
        intent_score=$((intent_score - 15))
    fi
    
    # Caution indicators
    if [[ "$USER_CONTEXT" =~ "careful"|"cautious"|"check"|"review"|"wait" ]]; then
        intent_score=$((intent_score - 20))
    fi
    
    # Ensure intent score is within bounds
    if [[ $intent_score -lt 0 ]]; then intent_score=0; fi
    if [[ $intent_score -gt 100 ]]; then intent_score=100; fi
    
    echo $intent_score
}

verify_system_readiness() {
    local readiness_score=0
    
    # Check git repository status
    if git status &>/dev/null; then
        readiness_score=$((readiness_score + 20))
        
        # Check for clean working directory
        if [[ -z $(git status --porcelain) ]]; then
            readiness_score=$((readiness_score + 15))
        fi
    fi
    
    # Check for required tools and files
    local required_files=("StyleService-Persistent.ps1" "signal-style.sh" "manage-style-service.sh")
    local files_found=0
    for file in "${required_files[@]}"; do
        if [[ -f "$file" ]]; then
            files_found=$((files_found + 1))
        fi
    done
    readiness_score=$((readiness_score + (files_found * 15)))
    
    # Check signal directory structure
    if [[ -d "style-signals" ]]; then
        readiness_score=$((readiness_score + 10))
    fi
    
    # Check for worktree isolation if mentioned in plan
    if [[ "$PLAN_TEXT" =~ "worktree" ]] && command -v git &>/dev/null; then
        if git worktree list &>/dev/null; then
            readiness_score=$((readiness_score + 10))
        fi
    fi
    
    # Check disk space (basic requirement)
    local available_space=$(df . | tail -1 | awk '{print $4}')
    if [[ $available_space -gt 1000000 ]]; then  # 1GB+ available
        readiness_score=$((readiness_score + 10))
    fi
    
    # Ensure readiness score is within bounds
    if [[ $readiness_score -gt 100 ]]; then readiness_score=100; fi
    
    echo $readiness_score
}

calculate_confidence() {
    local completeness=$1
    local risk=$2
    local intent=$3
    local readiness=$4
    
    # Weighted confidence calculation
    # Completeness: 30%, Risk (inverted): 40%, Intent: 20%, Readiness: 10%
    local confidence=$(( (completeness * 30 + (100 - risk) * 40 + intent * 20 + readiness * 10) / 100 ))
    
    echo $confidence
}

generate_confidence_report() {
    local completeness=$1
    local risk=$2
    local intent=$3
    local readiness=$4
    local confidence=$5
    local recommendation="$6"
    
    cat > "$CONFIDENCE_REPORT" <<EOF
{
    "timestamp": "$(date -Iseconds)",
    "scores": {
        "completeness": $completeness,
        "risk": $risk,
        "intent": $intent,
        "readiness": $readiness,
        "confidence": $confidence
    },
    "weights": {
        "completeness": 30,
        "risk": 40,
        "intent": 20,
        "readiness": 10
    },
    "thresholds": {
        "high_confidence": 85,
        "medium_confidence": 70,
        "low_confidence": 50
    },
    "recommendation": "$recommendation",
    "explanation": {
        "completeness": "Plan structure and detail assessment",
        "risk": "Implementation safety and reversibility evaluation",
        "intent": "User expectation and approval signals analysis",
        "readiness": "System state and resource availability check"
    }
}
EOF
}

# Main confidence assessment function
assess_plan_confidence() {
    local plan_text="$1"
    local user_context="${2:-}"
    
    # Set global variables for scoring functions
    PLAN_TEXT="$plan_text"
    USER_CONTEXT="$user_context"
    
    log_confidence "INFO" "Starting confidence assessment"
    log_confidence "INFO" "Plan length: $(echo "$plan_text" | wc -l) lines"
    log_confidence "INFO" "User context: $user_context"
    
    # Calculate individual scores
    local completeness=$(assess_plan_completeness)
    local risk=$(assess_implementation_risk)
    local intent=$(analyze_user_intent)
    local readiness=$(verify_system_readiness)
    
    # Calculate overall confidence
    local confidence=$(calculate_confidence $completeness $risk $intent $readiness)
    
    log_confidence "INFO" "Scores - Completeness: $completeness, Risk: $risk, Intent: $intent, Readiness: $readiness"
    log_confidence "INFO" "Overall confidence: $confidence"
    
    # Determine recommendation
    local recommendation
    if [[ $confidence -ge 85 ]]; then
        recommendation="AUTO_PROCEED"
    elif [[ $confidence -ge 70 ]]; then
        recommendation="PROCEED_WITH_EXPLANATION"
    elif [[ $confidence -ge 50 ]]; then
        recommendation="REQUEST_APPROVAL"
    else
        recommendation="REQUIRE_EXPLICIT_APPROVAL"
    fi
    
    log_confidence "INFO" "Recommendation: $recommendation"
    
    # Generate detailed report
    generate_confidence_report $completeness $risk $intent $readiness $confidence "$recommendation"
    
    # Output results
    echo "CONFIDENCE_SCORE=$confidence"
    echo "RECOMMENDATION=$recommendation"
    echo "COMPLETENESS=$completeness"
    echo "RISK=$risk"
    echo "INTENT=$intent"
    echo "READINESS=$readiness"
}

# Command line interface
show_help() {
    cat << EOF
Confidence Assessment Engine

USAGE:
    ./confidence-assessment.sh [command] [options]

COMMANDS:
    assess <plan_text> [user_context]  - Assess confidence for a plan
    report                             - Show detailed confidence report
    test                               - Run confidence assessment tests
    help                               - Show this help message

EXAMPLES:
    # Assess a simple plan
    ./confidence-assessment.sh assess "Create new file with content"
    
    # Assess with user context
    ./confidence-assessment.sh assess "Delete production database" "user said be careful"
    
    # View detailed report
    ./confidence-assessment.sh report

CONFIDENCE LEVELS:
    85-100: AUTO_PROCEED           (High confidence - automatic implementation)
    70-84:  PROCEED_WITH_EXPLANATION  (Medium-high - proceed with transparency)
    50-69:  REQUEST_APPROVAL       (Medium - ask user for confirmation)
    0-49:   REQUIRE_EXPLICIT_APPROVAL (Low - require detailed user approval)

EOF
}

# Main command handling
case "${1:-help}" in
    assess)
        if [[ -z "$2" ]]; then
            echo "Error: Plan text is required"
            echo "Usage: $0 assess '<plan_text>' [user_context]"
            exit 1
        fi
        assess_plan_confidence "$2" "$3"
        ;;
    report)
        if [[ -f "$CONFIDENCE_REPORT" ]]; then
            cat "$CONFIDENCE_REPORT" | jq '.'
        else
            echo "No confidence report found. Run assessment first."
            exit 1
        fi
        ;;
    test)
        echo "Running confidence assessment tests..."
        
        # Test high confidence scenario
        echo "=== HIGH CONFIDENCE TEST ==="
        assess_plan_confidence "Create worktree for experimental feature development. Step 1: Use git worktree add. Step 2: Set up isolated directories. Expected result: New isolated development environment." "user said proceed quickly"
        
        echo ""
        echo "=== LOW CONFIDENCE TEST ==="
        assess_plan_confidence "Delete all production files and restart server." "user mentioned being careful"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Error: Unknown command '$1'"
        echo "Run './confidence-assessment.sh help' for usage information"
        exit 1
        ;;
esac