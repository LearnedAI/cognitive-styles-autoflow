#!/bin/bash

# Enhanced Signal Interface - Confidence-Aware Style + Mode Control
# Integrates intelligent confidence assessment with existing signal system

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ORIGINAL_SIGNAL_SCRIPT="$SCRIPT_DIR/signal-style.sh"
CONFIDENCE_SCRIPT="$SCRIPT_DIR/intelligent-plan-exit.sh"

if [ -z "$1" ]; then
    cat << EOF
Enhanced Signal Interface - Confidence-Aware Cognitive Automation

USAGE: $0 <command> [options]

CONFIDENCE-ENHANCED COMMANDS:
  smart-build <plan_text>     - Build only if confidence is high
  confident-plan <plan_text>  - Plan with confidence assessment  
  auto-implement <plan_text>  - Implement with confidence evaluation
  explain-build <plan_text>   - Build with detailed confidence explanation

ORIGINAL COORDINATED COMMANDS:
  STRATEGIC COGNITIVE WORKFLOW (Core Triad):
  think       - Think style + Plan Mode (2) - Deep cognitive exploration
  plan        - Plan style + Plan Mode (2) - Strategic architecture  
  build       - Build style + Bypass Mode (3) - Full implementation

  OPERATIONAL SUPPORT WORKFLOW:
  explore     - Explore style + Normal Mode (0) - Broad discovery
  test        - Test style + Accept Mode (1) - Validation and QA
  review      - Review style + Normal Mode (0) - Analysis and optimization

CONFIDENCE REPORTING:
  confidence-status          - Show last confidence assessment
  confidence-test <text>     - Test confidence assessment on text

EXAMPLES:
  # Smart building with confidence checking
  $0 smart-build "Create new configuration file with default settings"
  
  # Traditional style switching
  $0 think                   # Deep cognitive analysis
  $0 build                   # Implementation mode
  
  # Confidence assessment
  $0 confidence-test "Delete all production files"

CONFIDENCE INTEGRATION:
  The enhanced commands evaluate plan confidence before proceeding:
  🟢 High (85+):    Proceed automatically with notification
  🟡 Medium (70-84): Proceed with detailed explanation
  🟠 Low (50-69):   Request manual approval
  🔴 Very Low (<50): Require explicit approval

EOF
    exit 1
fi

COMMAND=$1
PLAN_TEXT="${2:-}"
USER_CONTEXT="${3:-}"

# Enhanced confidence-aware commands
case "$COMMAND" in
    smart-build)
        if [ -z "$PLAN_TEXT" ]; then
            echo "❌ Error: Plan text required for smart-build"
            echo "Usage: $0 smart-build '<plan_text>' [user_context]"
            exit 1
        fi
        
        echo "🧠 SMART BUILD - Confidence-Based Implementation"
        echo "=============================================="
        echo ""
        
        # Evaluate confidence
        if "$CONFIDENCE_SCRIPT" proceed-if-confident "$PLAN_TEXT" "$USER_CONTEXT"; then
            echo ""
            echo "✅ Confidence check passed - Switching to BUILD mode"
            exec "$ORIGINAL_SIGNAL_SCRIPT" build
        else
            echo ""
            echo "⏸️  Smart build blocked due to low confidence"
            echo "   Consider using 'explain-build' to proceed with explanation"
            echo "   Or review and modify the plan to improve confidence"
            exit 1
        fi
        ;;
        
    confident-plan)
        if [ -z "$PLAN_TEXT" ]; then
            echo "❌ Error: Plan text required for confident-plan"
            echo "Usage: $0 confident-plan '<plan_text>' [user_context]"
            exit 1
        fi
        
        echo "📋 CONFIDENT PLAN - Strategic Analysis with Confidence"
        echo "===================================================="
        echo ""
        
        # Show confidence analysis
        "$CONFIDENCE_SCRIPT" evaluate "$PLAN_TEXT" "$USER_CONTEXT"
        
        echo ""
        echo "🎯 Switching to PLAN mode for strategic development..."
        exec "$ORIGINAL_SIGNAL_SCRIPT" plan
        ;;
        
    auto-implement)
        if [ -z "$PLAN_TEXT" ]; then
            echo "❌ Error: Plan text required for auto-implement"
            echo "Usage: $0 auto-implement '<plan_text>' [user_context]"
            exit 1
        fi
        
        echo "🚀 AUTO-IMPLEMENT - Intelligent Workflow Automation" 
        echo "================================================="
        echo ""
        
        # Full workflow: assess confidence, then proceed accordingly
        eval_result=$("$CONFIDENCE_SCRIPT" evaluate "$PLAN_TEXT" "$USER_CONTEXT")
        recommendation=$(echo "$eval_result" | grep "RECOMMENDATION=" | cut -d'=' -f2)
        
        echo "$eval_result"
        echo ""
        
        case "$recommendation" in
            "AUTO_PROCEED")
                echo "🎯 HIGH CONFIDENCE → Proceeding with BUILD mode"
                exec "$ORIGINAL_SIGNAL_SCRIPT" build
                ;;
            "PROCEED_WITH_EXPLANATION")  
                echo "🎯 MEDIUM CONFIDENCE → Proceeding with BUILD mode + explanation"
                "$CONFIDENCE_SCRIPT" explain-and-proceed "$PLAN_TEXT" "$USER_CONTEXT"
                exec "$ORIGINAL_SIGNAL_SCRIPT" build
                ;;
            *)
                echo "🎯 LOW CONFIDENCE → Switching to PLAN mode for manual review"
                echo "   Please review the confidence analysis and approve manually if appropriate"
                exec "$ORIGINAL_SIGNAL_SCRIPT" plan
                ;;
        esac
        ;;
        
    explain-build)
        if [ -z "$PLAN_TEXT" ]; then
            echo "❌ Error: Plan text required for explain-build"
            echo "Usage: $0 explain-build '<plan_text>' [user_context]"
            exit 1
        fi
        
        echo "📝 EXPLAIN-BUILD - Transparent Implementation"
        echo "=========================================="
        echo ""
        
        # Always show explanation and proceed
        "$CONFIDENCE_SCRIPT" explain-and-proceed "$PLAN_TEXT" "$USER_CONTEXT"
        
        echo "🎯 Proceeding to BUILD mode with full transparency..."
        exec "$ORIGINAL_SIGNAL_SCRIPT" build
        ;;
        
    confidence-status)
        echo "📊 CONFIDENCE SYSTEM STATUS"
        echo "=========================="
        echo ""
        "$CONFIDENCE_SCRIPT" confidence-report
        ;;
        
    confidence-test)
        if [ -z "$PLAN_TEXT" ]; then
            echo "❌ Error: Text required for confidence test"
            echo "Usage: $0 confidence-test '<plan_text>' [user_context]"
            exit 1
        fi
        
        echo "🧪 CONFIDENCE TEST"
        echo "=================="
        echo ""
        "$CONFIDENCE_SCRIPT" evaluate "$PLAN_TEXT" "$USER_CONTEXT"
        ;;
        
    # All original commands pass through to original script
    think|plan|build|test|review|explore|normal-mode|accept-mode|plan-mode|bypass-mode|check-mode|reset-mode)
        exec "$ORIGINAL_SIGNAL_SCRIPT" "$COMMAND"
        ;;
        
    *)
        echo "❌ Error: Unknown command '$COMMAND'"
        echo "Run '$0' without arguments to see available commands"
        exit 1
        ;;
esac