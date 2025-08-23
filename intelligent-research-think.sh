#!/bin/bash

# Intelligent Research-Think Integration
# Integrates Intelligence Vault with Cognitive Style Automation
# Enhanced research workflow with knowledge gap detection

VERSION="1.0.0"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

usage() {
    echo "Usage: $0 '<research_task>' [options]"
    echo ""
    echo "Options:"
    echo "  --force-research     Force research even if knowledge exists"
    echo "  --max-tokens NUM     Maximum tokens for context assembly (default: 8000)"
    echo "  --output FILE        Save assembled context to file"
    echo ""
    echo "Examples:"
    echo "  $0 'implement OAuth2 authentication system'"
    echo "  $0 'optimize database query performance' --max-tokens 6000"
    echo "  $0 'build WebRTC video calling app' --force-research"
}

main() {
    local task=""
    local force_research=false
    local max_tokens=8000
    local output_file=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --force-research)
                force_research=true
                shift
                ;;
            --max-tokens)
                max_tokens="$2"
                shift 2
                ;;
            --output)
                output_file="$2"
                shift 2
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
    
    echo -e "${BLUE}🧠 INTELLIGENT RESEARCH-THINK WORKFLOW v$VERSION${NC}"
    echo "Task: $task"
    echo ""
    
    # Step 1: Check knowledge coverage
    echo -e "${CYAN}🔍 STEP 1: KNOWLEDGE GAP ANALYSIS${NC}"
    ./check-knowledge-coverage.sh "$task"
    coverage_result=$?
    echo ""
    
    # Step 2: Decision based on coverage
    if [[ $coverage_result -eq 0 && "$force_research" == false ]]; then
        # We have some knowledge, try to assemble context
        echo -e "${CYAN}🧠 STEP 2: ASSEMBLING EXISTING KNOWLEDGE${NC}"
        if [[ "$output_file" != "" ]]; then
            ./assemble-context.sh "$task" --max-tokens "$max_tokens" --output "$output_file"
        else
            ./assemble-context.sh "$task" --max-tokens "$max_tokens"
        fi
        assembly_result=$?
        
        if [[ $assembly_result -eq 0 ]]; then
            echo -e "${GREEN}✅ CONTEXT ASSEMBLED - PROCEED WITH EXISTING KNOWLEDGE${NC}"
            echo "Recommendation: Use assembled context for implementation"
            exit 0
        fi
    fi
    
    # Step 3: Trigger research workflow
    echo -e "${CYAN}🔬 STEP 3: TRIGGERING RESEARCH WORKFLOW${NC}"
    echo "Knowledge gaps detected - switching to research-think mode..."
    echo ""
    
    # Switch to think style for research
    echo -e "${YELLOW}→ Switching to THINK cognitive style for deep research${NC}"
    ./signal-style.sh think
    
    echo ""
    echo -e "${BLUE}📚 RESEARCH RECOMMENDATIONS${NC}"
    echo "1. Perform deep research on the identified knowledge gaps"
    echo "2. Create MOD nuggets for newly learned domains"
    echo "3. Update the intelligence vault with new knowledge"
    echo "4. Re-run this script to leverage assembled knowledge"
    echo ""
    echo -e "${CYAN}💡 NEXT STEPS AFTER RESEARCH:${NC}"
    echo "- Run: ./intelligent-research-think.sh '$task' --force-research"
    echo "- Or manually update knowledge vault and re-run"
}

main "$@"