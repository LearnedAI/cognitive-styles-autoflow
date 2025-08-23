#!/bin/bash

# Intelligent Plan Exit System
# Confidence-based enhancement to ExitPlanMode workflow

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIDENCE_SCRIPT="$SCRIPT_DIR/confidence-assessment.sh"
PLAN_LOG="$SCRIPT_DIR/intelligent-plan-exit.log"

log_plan_exit() {
    local level="$1"
    local message="$2"
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S.%3N')
    echo "[$timestamp] [$level] $message" | tee -a "$PLAN_LOG"
}

show_help() {
    cat << EOF
Intelligent Plan Exit System
Confidence-based enhancement to Claude Code's ExitPlanMode workflow

USAGE:
    ./intelligent-plan-exit.sh <command> [options]

COMMANDS:
    evaluate <plan_text> [user_context]     - Evaluate plan confidence and recommend action
    proceed-if-confident <plan_text>        - Auto-proceed only if confidence is high
    explain-and-proceed <plan_text>         - Proceed with detailed explanation
    force-approval <plan_text>              - Override confidence and request approval
    confidence-report                       - Show last confidence assessment
    help                                   - Show this help message

WORKFLOW INTEGRATION:
    This system enhances the standard ExitPlanMode workflow:
    1. Plan developed in Plan Mode
    2. Confidence assessment performed
    3. Action taken based on confidence level:
       - High (85+): Automatic ExitPlanMode with explanation
       - Medium (70-84): ExitPlanMode with detailed confidence report
       - Low (<70): Present confidence analysis and request manual approval

EXAMPLES:
    # Evaluate a plan and get recommendation
    ./intelligent-plan-exit.sh evaluate "Create git worktree for testing"
    
    # Only proceed if confidence is high
    ./intelligent-plan-exit.sh proceed-if-confident "Add new feature to existing file"
    
    # Proceed with explanation regardless of confidence
    ./intelligent-plan-exit.sh explain-and-proceed "Refactor database schema"

CONFIDENCE LEVELS:
    🟢 HIGH (85-100):    Auto-proceed with notification
    🟡 MEDIUM (70-84):   Proceed with detailed explanation  
    🟠 LOW (50-69):      Request user approval with analysis
    🔴 VERY LOW (<50):   Require explicit approval

EOF
}

evaluate_plan_confidence() {
    local plan_text="$1"
    local user_context="${2:-}"
    
    log_plan_exit "INFO" "Starting plan confidence evaluation"
    
    # Run confidence assessment
    local confidence_result
    if ! confidence_result=$("$CONFIDENCE_SCRIPT" assess "$plan_text" "$user_context"); then
        log_plan_exit "ERROR" "Confidence assessment failed"
        echo "❌ Error: Unable to assess plan confidence"
        exit 1
    fi
    
    # Parse results
    local confidence=$(echo "$confidence_result" | grep "CONFIDENCE_SCORE=" | cut -d'=' -f2)
    local recommendation=$(echo "$confidence_result" | grep "RECOMMENDATION=" | cut -d'=' -f2)
    local completeness=$(echo "$confidence_result" | grep "COMPLETENESS=" | cut -d'=' -f2)
    local risk=$(echo "$confidence_result" | grep "RISK=" | cut -d'=' -f2)
    local intent=$(echo "$confidence_result" | grep "INTENT=" | cut -d'=' -f2)
    local readiness=$(echo "$confidence_result" | grep "READINESS=" | cut -d'=' -f2)
    
    log_plan_exit "INFO" "Confidence: $confidence, Recommendation: $recommendation"
    
    # Display confidence analysis
    echo ""
    echo "🧠 PLAN CONFIDENCE ANALYSIS"
    echo "=========================="
    echo "📊 Overall Confidence: $confidence/100"
    echo ""
    echo "📋 Component Scores:"
    echo "   • Plan Completeness: $completeness/100 (30% weight)"
    echo "   • Implementation Risk: $risk/100 (40% weight - lower is better)"  
    echo "   • User Intent Clarity: $intent/100 (20% weight)"
    echo "   • System Readiness: $readiness/100 (10% weight)"
    echo ""
    
    # Color-coded confidence level
    if [[ $confidence -ge 85 ]]; then
        echo "🟢 CONFIDENCE LEVEL: HIGH"
        echo "   Recommendation: Proceed automatically with notification"
    elif [[ $confidence -ge 70 ]]; then
        echo "🟡 CONFIDENCE LEVEL: MEDIUM-HIGH"  
        echo "   Recommendation: Proceed with detailed explanation"
    elif [[ $confidence -ge 50 ]]; then
        echo "🟠 CONFIDENCE LEVEL: MEDIUM"
        echo "   Recommendation: Request user approval with analysis"
    else
        echo "🔴 CONFIDENCE LEVEL: LOW"
        echo "   Recommendation: Require explicit user approval"
    fi
    
    echo ""
    
    # Return recommendation for programmatic use
    echo "RECOMMENDATION=$recommendation"
}

proceed_if_confident() {
    local plan_text="$1"
    local user_context="${2:-}"
    
    log_plan_exit "INFO" "Conditional proceed requested"
    
    # Evaluate confidence
    local eval_result=$(evaluate_plan_confidence "$plan_text" "$user_context")
    local recommendation=$(echo "$eval_result" | grep "RECOMMENDATION=" | cut -d'=' -f2)
    
    case "$recommendation" in
        "AUTO_PROCEED")
            echo "✅ HIGH CONFIDENCE - Proceeding automatically"
            echo ""
            echo "🚀 Plan approved for immediate implementation based on:"
            echo "   • Complete and well-structured plan"
            echo "   • Low implementation risk"
            echo "   • Clear user intent to proceed"
            echo "   • System ready for implementation"
            echo ""
            echo "Implementation will begin now..."
            return 0
            ;;
        "PROCEED_WITH_EXPLANATION")
            echo "⚡ MEDIUM-HIGH CONFIDENCE - Proceeding with explanation"
            echo ""
            echo "Plan has been approved for implementation."
            echo "Confidence analysis indicates this is a reasonable plan to execute."
            echo ""
            return 0
            ;;
        *)
            echo "⏸️  INSUFFICIENT CONFIDENCE - Manual approval required"
            echo ""
            echo "The confidence assessment indicates this plan needs manual review."
            echo "Please review the analysis above and provide explicit approval if you want to proceed."
            echo ""
            echo "Options:"
            echo "  1. Review and approve manually if the plan looks correct"
            echo "  2. Modify the plan to address confidence concerns"
            echo "  3. Use './intelligent-plan-exit.sh force-approval' to override"
            echo ""
            return 1
            ;;
    esac
}

explain_and_proceed() {
    local plan_text="$1" 
    local user_context="${2:-}"
    
    log_plan_exit "INFO" "Explain and proceed requested"
    
    # Always show confidence analysis
    evaluate_plan_confidence "$plan_text" "$user_context"
    
    echo ""
    echo "📝 PROCEEDING WITH IMPLEMENTATION"
    echo "================================"
    echo "Based on the confidence analysis above, implementation will proceed."
    echo "The system will now execute the planned changes."
    echo ""
    
    return 0
}

force_approval() {
    local plan_text="$1"
    local user_context="${2:-}"
    
    log_plan_exit "INFO" "Force approval requested"
    
    echo "🔧 CONFIDENCE OVERRIDE ACTIVATED"
    echo "==============================="
    echo ""
    
    # Still show confidence analysis for transparency
    evaluate_plan_confidence "$plan_text" "$user_context"
    
    echo ""
    echo "⚠️  MANUAL OVERRIDE: Proceeding regardless of confidence level"
    echo "   User has explicitly requested implementation"
    echo "   Standard confidence thresholds bypassed"
    echo "   Implementation will proceed with full user responsibility"
    echo ""
    
    return 0
}

show_confidence_report() {
    if [[ -f "$SCRIPT_DIR/confidence-report.json" ]]; then
        echo "📊 LATEST CONFIDENCE ASSESSMENT REPORT"
        echo "====================================="
        cat "$SCRIPT_DIR/confidence-report.json" | jq -r '
            "Timestamp: " + .timestamp,
            "Overall Confidence: " + (.scores.confidence | tostring) + "/100",
            "",
            "Component Scores:",
            "  • Completeness: " + (.scores.completeness | tostring) + "/100 (weight: " + (.weights.completeness | tostring) + "%)",
            "  • Risk Level: " + (.scores.risk | tostring) + "/100 (weight: " + (.weights.risk | tostring) + "%)",  
            "  • User Intent: " + (.scores.intent | tostring) + "/100 (weight: " + (.weights.intent | tostring) + "%)",
            "  • System Readiness: " + (.scores.readiness | tostring) + "/100 (weight: " + (.weights.readiness | tostring) + "%)",
            "",
            "Recommendation: " + .recommendation,
            "",
            "Thresholds:",
            "  • High Confidence: " + (.thresholds.high_confidence | tostring) + "+",
            "  • Medium Confidence: " + (.thresholds.medium_confidence | tostring) + "+",
            "  • Low Confidence: " + (.thresholds.low_confidence | tostring) + "+"
        '
    else
        echo "❌ No confidence report found"
        echo "Run a confidence evaluation first using one of the assessment commands"
    fi
}

# Main command handling
case "${1:-help}" in
    evaluate)
        if [[ -z "$2" ]]; then
            echo "❌ Error: Plan text is required"
            echo "Usage: $0 evaluate '<plan_text>' [user_context]"
            exit 1
        fi
        evaluate_plan_confidence "$2" "$3"
        ;;
    proceed-if-confident)
        if [[ -z "$2" ]]; then
            echo "❌ Error: Plan text is required"
            echo "Usage: $0 proceed-if-confident '<plan_text>' [user_context]"
            exit 1
        fi
        proceed_if_confident "$2" "$3"
        ;;
    explain-and-proceed)
        if [[ -z "$2" ]]; then
            echo "❌ Error: Plan text is required"
            echo "Usage: $0 explain-and-proceed '<plan_text>' [user_context]"
            exit 1
        fi
        explain_and_proceed "$2" "$3"
        ;;
    force-approval)
        if [[ -z "$2" ]]; then
            echo "❌ Error: Plan text is required" 
            echo "Usage: $0 force-approval '<plan_text>' [user_context]"
            exit 1
        fi
        force_approval "$2" "$3"
        ;;
    confidence-report)
        show_confidence_report
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "❌ Error: Unknown command '$1'"
        echo "Run './intelligent-plan-exit.sh help' for usage information"
        exit 1
        ;;
esac