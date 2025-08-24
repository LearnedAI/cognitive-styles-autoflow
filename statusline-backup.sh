#!/bin/bash
# Ultimate Cognitive Automation Statusline for Claude Code
# Combines the best ideas from community and cognitive automation integration
# Version: 1.0.0

# Read JSON input from stdin
input=$(cat)

# Color definitions for visual indicators
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;90m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Unicode symbols for visual elements
FOLDER_ICON="📁"
BRANCH_ICON="🌿"
AUTOMATION_ACTIVE="🟢"
AUTOMATION_INACTIVE="🔴"
AUTOMATION_WARNING="🟡"
COST_ICON="💰"
EFFICIENCY_ICON="⚡"
CONTEXT_FULL="█"
CONTEXT_EMPTY="░"
ALERT_ICON="⚠️"
FIRE_ICON="🔥"

# Extract core data from JSON input using jq
get_model_name() {
    echo "$input" | jq -r '.model.display_name // "Unknown"'
}

get_model_id() {
    echo "$input" | jq -r '.model.id // "unknown"'
}

get_output_style() {
    echo "$input" | jq -r '.output_style.name // "default"'
}

get_current_dir() {
    echo "$input" | jq -r '.workspace.current_dir // "'$(pwd)'"'
}

get_project_dir() {
    echo "$input" | jq -r '.workspace.project_dir // "'$(pwd)'"'
}

get_session_cost() {
    echo "$input" | jq -r '.cost.total_cost_usd // 0'
}

get_session_duration() {
    echo "$input" | jq -r '.cost.total_duration_ms // 0'
}

get_api_duration() {
    echo "$input" | jq -r '.cost.total_api_duration_ms // 0'
}

get_lines_added() {
    echo "$input" | jq -r '.cost.total_lines_added // 0'
}

get_lines_removed() {
    echo "$input" | jq -r '.cost.total_lines_removed // 0'
}

get_transcript_path() {
    echo "$input" | jq -r '.transcript_path // ""'
}

# Enhanced context window calculation using dedicated script
calculate_context_usage() {
    local transcript_path="$1"
    local session_duration="$2"
    
    # Use enhanced context calculator if available
    if [[ -x "./context-calculator.sh" ]]; then
        local result=$(./context-calculator.sh "$transcript_path" "$session_duration" "compact")
        # Parse the enhanced result: color:percentage:current:max:status:warning
        local percentage=$(echo "$result" | cut -d: -f2)
        local current_formatted=$(echo "$result" | cut -d: -f3)
        local max_formatted=$(echo "$result" | cut -d: -f4)
        echo "$current_formatted:$max_formatted:$percentage:$result"
    else
        # Fallback to basic calculation
        local max_tokens=200000
        if [[ -f "$transcript_path" ]]; then
            local file_size=$(wc -c < "$transcript_path" 2>/dev/null || echo "0")
            local estimated_tokens=$((file_size / 4))
            local percentage=$((estimated_tokens * 100 / max_tokens))
            if [[ $percentage -gt 100 ]]; then
                percentage=100
                estimated_tokens=$max_tokens
            fi
            echo "$estimated_tokens:$max_tokens:$percentage:basic"
        else
            echo "0:$max_tokens:0:basic"
        fi
    fi
}

# Create visual progress bar for context usage
create_progress_bar() {
    local percentage=$1
    local width=10
    local filled=$((percentage * width / 100))
    local empty=$((width - filled))
    
    local bar=""
    for ((i=0; i<filled; i++)); do
        bar="${bar}${CONTEXT_FULL}"
    done
    for ((i=0; i<empty; i++)); do
        bar="${bar}${CONTEXT_EMPTY}"
    done
    
    echo "$bar"
}

# Get git branch information
get_git_info() {
    if git rev-parse --git-dir > /dev/null 2>&1; then
        local branch=$(git branch --show-current 2>/dev/null || echo "detached")
        local status=""
        
        # Check for uncommitted changes
        if ! git diff --quiet 2>/dev/null; then
            status="${status}*"
        fi
        
        # Check for staged changes
        if ! git diff --cached --quiet 2>/dev/null; then
            status="${status}+"
        fi
        
        echo "${branch}${status}"
    else
        echo ""
    fi
}

# Enhanced cognitive automation service status
get_automation_status() {
    # Use enhanced cognitive automation status if available
    if [[ -x "./cognitive-automation-status.sh" ]]; then
        local result=$(./cognitive-automation-status.sh "compact")
        # Parse: icon:status:last_signal:confidence:errors
        local icon=$(echo "$result" | cut -d: -f1)
        local status=$(echo "$result" | cut -d: -f2)
        local last_signal=$(echo "$result" | cut -d: -f3)
        local confidence=$(echo "$result" | cut -d: -f4)
        local errors=$(echo "$result" | cut -d: -f5)
        
        # Create enhanced display
        local display="${icon} ${status}"
        if [[ -n "$last_signal" && "$last_signal" != "" ]]; then
            display="${display}(${last_signal})"
        fi
        if [[ "$confidence" != "N/A" ]]; then
            display="${display}[${confidence}]"
        fi
        
        echo "$display"
    else
        # Fallback to basic status
        local status_icon="$AUTOMATION_INACTIVE"
        local status_text="Off"
        
        if pgrep -f "StyleService" > /dev/null 2>&1; then
            status_icon="$AUTOMATION_ACTIVE"
            status_text="Active"
        elif [[ -f "manage-style-service.sh" ]]; then
            local service_status=$(./manage-style-service.sh status 2>/dev/null | grep -o "running\|stopped" || echo "unknown")
            if [[ "$service_status" == "running" ]]; then
                status_icon="$AUTOMATION_ACTIVE"
                status_text="Active"
            elif [[ "$service_status" == "stopped" ]]; then
                status_icon="$AUTOMATION_INACTIVE"
                status_text="Stopped"
            else
                status_icon="$AUTOMATION_WARNING"
                status_text="Unknown"
            fi
        fi
        
        echo "${status_icon} ${status_text}"
    fi
}

# Calculate session efficiency (API time vs total time)
calculate_efficiency() {
    local total_duration=$1
    local api_duration=$2
    
    if [[ $total_duration -gt 0 && $api_duration -gt 0 ]]; then
        local efficiency=$((api_duration * 100 / total_duration))
        echo "${efficiency}%"
    else
        echo "N/A"
    fi
}

# Format cost with appropriate color coding
format_cost() {
    local cost=$1
    local cost_float=$(echo "$cost" | awk '{printf "%.3f", $1}')
    
    # Color coding based on cost thresholds using awk for better compatibility
    if awk "BEGIN {exit !($cost > 0.10)}"; then
        echo -e "${RED}\$${cost_float}${NC}"
    elif awk "BEGIN {exit !($cost > 0.05)}"; then
        echo -e "${YELLOW}\$${cost_float}${NC}"
    else
        echo -e "${GREEN}\$${cost_float}${NC}"
    fi
}

# Get terminal width for adaptive display
get_terminal_width() {
    tput cols 2>/dev/null || echo "80"
}

# Main statusline generation
generate_statusline() {
    local model_name=$(get_model_name)
    local output_style=$(get_output_style)
    local current_dir=$(get_current_dir)
    local session_cost=$(get_session_cost)
    local session_duration=$(get_session_duration)
    local api_duration=$(get_api_duration)
    local transcript_path=$(get_transcript_path)
    local terminal_width=$(get_terminal_width)
    
    # Calculate context usage
    local context_info=$(calculate_context_usage "$transcript_path")
    local current_tokens=$(echo "$context_info" | cut -d: -f1)
    local max_tokens=$(echo "$context_info" | cut -d: -f2)
    local percentage=$(echo "$context_info" | cut -d: -f3)
    
    # Create progress bar
    local progress_bar=$(create_progress_bar "$percentage")
    
    # Get git information
    local git_info=$(get_git_info)
    
    # Get automation status
    local automation_status=$(get_automation_status)
    
    # Calculate efficiency
    local efficiency=$(calculate_efficiency "$session_duration" "$api_duration")
    
    # Format cost
    local formatted_cost=$(format_cost "$session_cost")
    
    # Get directory name only (not full path)
    local dir_name=$(basename "$current_dir")
    
    # Color code context usage
    local context_color=""
    if [[ $percentage -gt 80 ]]; then
        context_color="$RED"
    elif [[ $percentage -gt 60 ]]; then
        context_color="$YELLOW" 
    else
        context_color="$GREEN"
    fi
    
    # Format git branch with icon if available
    local git_display=""
    if [[ -n "$git_info" ]]; then
        git_display=" │ ${BRANCH_ICON} ${git_info}"
    fi
    
    # Adaptive display based on terminal width
    if [[ $terminal_width -gt 120 ]]; then
        # Detailed mode for wide terminals
        echo -e "[${BOLD}${output_style}${NC}] ${model_name} │ ${FOLDER_ICON} ${dir_name}${git_display} │ Context: ${context_color}${progress_bar} ${percentage}%${NC} (${current_tokens}K/${max_tokens}K) │ ${automation_status} │ ${COST_ICON} ${formatted_cost} │ ${EFFICIENCY_ICON} ${efficiency}"
    elif [[ $terminal_width -gt 100 ]]; then
        # Medium mode
        echo -e "[${BOLD}${output_style}${NC}] ${model_name} │ ${FOLDER_ICON} ${dir_name}${git_display} │ ${context_color}${progress_bar} ${percentage}%${NC} │ ${automation_status} │ ${formatted_cost} │ ${efficiency}"
    else
        # Compact mode for narrow terminals
        echo -e "[${BOLD}${output_style}${NC}] ${model_name} │ ${FOLDER_ICON} ${dir_name}${git_display} │ ${context_color}${progress_bar} ${percentage}%${NC} │ ${automation_status} │ ${formatted_cost}"
    fi
}

# Execute main function
generate_statusline