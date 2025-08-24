#!/bin/bash
# Refactored Cognitive Automation Statusline for Claude Code
# Based on Chong's cc-statusline optimizations + Cognitive Automation integration
# Version: 2.0.0

# Read JSON input from stdin
input=$(cat)

# Early exit if no input
if [[ -z "$input" ]]; then
    echo "No session data"
    exit 0
fi

# Dependency check with fallback
if ! command -v jq &> /dev/null; then
    echo "⚠️ jq not available - basic statusline mode"
    exit 0
fi

# Color definitions (Chong's approach - lighter palette)
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly GRAY='\033[0;90m'
readonly PEACH='\033[38;5;216m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Unicode symbols
readonly FOLDER_ICON="📁"
readonly BRANCH_ICON="🌿"
readonly AUTOMATION_ACTIVE="🟢"
readonly AUTOMATION_INACTIVE="🔴"
readonly AUTOMATION_WARNING="🟡"
readonly COST_ICON="💰"
readonly CONTEXT_ICON="🧠"
readonly FULL_BLOCK="█"
readonly EMPTY_BLOCK="░"

# OPTIMIZATION 1: Single JSON extraction (simplified for Sonnet 4 only)
extract_session_data() {
    echo "$input" | jq -r '. as $root | {
        output_style: ($root.output_style.name // "default"),
        current_dir: ($root.workspace.current_dir // "'$(pwd)'"),
        transcript_path: ($root.transcript_path // ""),
        session_id: ($root.session_id // "")
    }'
}

# OPTIMIZATION 2: Claude Pro subscription detection
is_claude_pro_user() {
    # For Claude Pro users, we should hide cost regardless of the value
    # since you mentioned having Claude Pro subscription
    # TODO: Add more sophisticated detection if needed
    return 0  # Always return true for now since user has Claude Pro
}

# OPTIMIZATION 3: Context calculation (Sonnet 4 - 200K tokens)
calculate_context_usage() {
    local session_id=$(echo "$session_data" | jq -r '.session_id')
    local max_tokens=200000  # Sonnet 4 context window
    
    # Get actual context usage from transcript
    local transcript_path=$(echo "$session_data" | jq -r '.transcript_path')
    local current_tokens=0
    
    if [[ -f "$transcript_path" ]]; then
        local char_count=$(wc -c < "$transcript_path" 2>/dev/null || echo "0")
        # Improved estimation: 3.5 chars per token
        current_tokens=$((char_count / 4))
    fi
    
    # Calculate percentage
    local percentage=0
    if [[ $max_tokens -gt 0 ]]; then
        percentage=$((current_tokens * 100 / max_tokens))
    fi
    
    echo "$current_tokens:$max_tokens:$percentage"
}

# OPTIMIZATION 4: Efficient progress bar (Chong's style)
create_context_bar() {
    local percentage=$1
    local width=8  # Smaller for better fit
    local filled=$((percentage * width / 100))
    
    local bar=""
    for ((i=0; i<filled; i++)); do
        bar="${bar}${FULL_BLOCK}"
    done
    for ((i=filled; i<width; i++)); do
        bar="${bar}${EMPTY_BLOCK}"
    done
    
    echo "$bar"
}

# OPTIMIZATION 5: Streamlined git info (performance focused)
get_git_status() {
    if git rev-parse --git-dir &>/dev/null; then
        local branch=$(git branch --show-current 2>/dev/null || echo "detached")
        local status=""
        
        # Quick dirty check (faster than git diff)
        if ! git diff --quiet 2>/dev/null; then
            status="*"
        fi
        
        echo "${branch}${status}"
    fi
}

# OPTIMIZATION 6: Enhanced cognitive automation status (with fallback)
get_automation_status() {
    if [[ -x "./cognitive-automation-status.sh" ]]; then
        local result=$(./cognitive-automation-status.sh "compact" 2>/dev/null)
        if [[ -n "$result" ]]; then
            local icon=$(echo "$result" | cut -d: -f1)
            local status=$(echo "$result" | cut -d: -f2)
            echo "${icon} ${status}"
            return
        fi
    fi
    
    # Fallback: simple process check
    if pgrep -f "StyleService" >/dev/null 2>&1; then
        echo "${AUTOMATION_ACTIVE} Active"
    else
        echo "${AUTOMATION_INACTIVE} Off"
    fi
}

# OPTIMIZATION 7: Claude Pro display (no cost tracking needed)
format_subscription_info() {
    echo "Pro"  # Simple Pro indicator for Claude Pro subscription
}

# OPTIMIZATION 8: Main statusline generation (simplified for Sonnet 4 + Claude Pro)
generate_statusline() {
    # Single data extraction
    session_data=$(extract_session_data)
    
    # Extract key values
    local output_style=$(echo "$session_data" | jq -r '.output_style')
    local current_dir=$(echo "$session_data" | jq -r '.current_dir')
    
    # Calculate context
    local context_info=$(calculate_context_usage)
    local current_tokens=$(echo "$context_info" | cut -d: -f1)
    local max_tokens=$(echo "$context_info" | cut -d: -f2)
    local percentage=$(echo "$context_info" | cut -d: -f3)
    
    # Format components
    local dir_name=$(basename "$current_dir" 2>/dev/null || echo "unknown")
    local git_info=$(get_git_status)
    local automation_status=$(get_automation_status)
    local subscription_info=$(format_subscription_info)
    
    # Context visualization
    local progress_bar=$(create_context_bar "$percentage")
    local context_color="$GREEN"
    if [[ $percentage -gt 80 ]]; then
        context_color="$RED"
    elif [[ $percentage -gt 60 ]]; then
        context_color="$PEACH"
    fi
    
    # Format token display
    local current_k=$((current_tokens / 1000))
    local max_k=$((max_tokens / 1000))
    
    # Build statusline components (no model display needed - always Sonnet 4)
    local style_display="[${BOLD}${output_style}${NC}]"
    local project_display="${FOLDER_ICON} ${dir_name}"
    local git_display=""
    if [[ -n "$git_info" ]]; then
        git_display=" │ ${BRANCH_ICON} ${git_info}"
    fi
    local context_display="${CONTEXT_ICON} ${context_color}${progress_bar} ${percentage}%${NC} (${current_k}K/${max_k}K)"
    
    # Generate final statusline (simplified - no model name, Pro subscription)
    echo -e "${style_display} │ ${project_display}${git_display} │ ${context_display} │ ${automation_status} │ ${COST_ICON} ${subscription_info}"
}

# Execute main function
generate_statusline