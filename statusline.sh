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

# OPTIMIZATION 1: Minimal JSON extraction for core info only
extract_session_data() {
    echo "$input" | jq -r '. as $root | {
        output_style: ($root.output_style.name // "default"),
        current_dir: ($root.workspace.current_dir // "'$(pwd)'"),
        transcript_path: ($root.transcript_path // ""),
        version: ($root.version // "1.0.80")
    }'
}

# Style emoji mapping for visual enhancement
get_style_emoji() {
    local style="$1"
    case "$style" in
        "explore") echo "🔍" ;;
        "think") echo "🤔" ;;
        "plan") echo "📋" ;;
        "build") echo "🔨" ;;
        "test") echo "🧪" ;;
        "review") echo "👀" ;;
        "documentation") echo "📚" ;;
        "default") echo "⚡" ;;
        *) echo "🎯" ;;
    esac
}

# Accurate context estimation (based on real-world validation)
calculate_context_usage() {
    local max_tokens=200000  # Sonnet 4 context window
    local current_tokens=0
    local percentage=0
    
    # Get transcript file for estimation
    local transcript_path=$(echo "$session_data" | jq -r '.transcript_path')
    
    if [[ -f "$transcript_path" ]]; then
        local file_size=$(wc -c < "$transcript_path" 2>/dev/null || echo "0")
        
        # Fine-tuned estimation based on multiple real-world validations:
        # - Validation 1: 104% → auto-compact appeared  
        # - Validation 2: 73% statusline = 88% actual (underestimated by 15%)
        # - Validation 3: 94% statusline = 89% actual (overestimated by 5%)
        # - Sweet spot: 4.0 chars per token with 22% JSON overhead
        local content_chars=$((file_size * 78 / 100))
        current_tokens=$((content_chars / 4))  # 4.0 chars per token
        
        # Calculate realistic percentage
        percentage=$((current_tokens * 100 / max_tokens))
        
        # Sanity check - don't exceed 100%
        if [[ $percentage -gt 100 ]]; then
            percentage=100
            current_tokens=$max_tokens
        fi
    else
        # No transcript available - minimal usage
        current_tokens=5000
        percentage=2
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

# Claude Code version display with robot emoji
get_claude_version() {
    local version=$(echo "$session_data" | jq -r '.version')
    echo "🤖 v${version}"
}

# Simplified automation status (red/green)
get_automation_status() {
    if [[ -x "./cognitive-automation-status.sh" ]]; then
        local result=$(./cognitive-automation-status.sh "compact" 2>/dev/null)
        if [[ -n "$result" ]]; then
            local icon=$(echo "$result" | cut -d: -f1)
            echo "${icon}"
            return
        fi
    fi
    
    # Fallback: simple process check with red/green
    if pgrep -f "StyleService" >/dev/null 2>&1; then
        echo "${AUTOMATION_ACTIVE}"
    else
        echo "${AUTOMATION_INACTIVE}"
    fi
}

# Main statusline generation (simplified and focused)
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
    
    # Get components
    local dir_name=$(basename "$current_dir" 2>/dev/null || echo "unknown")
    local style_emoji=$(get_style_emoji "$output_style")
    local automation_status=$(get_automation_status)
    local claude_version=$(get_claude_version)
    
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
    
    # Build clean, focused statusline
    local style_display="${style_emoji} [${BOLD}${output_style}${NC}]"
    local project_display="${FOLDER_ICON} ${dir_name}"
    local context_display="${CONTEXT_ICON} ${context_color}${progress_bar} ${percentage}%${NC} (${current_k}K/${max_k}K)"
    
    # Generate final statusline: Style │ Project │ Context │ Automation │ Version
    echo -e "${style_display} │ ${project_display} │ ${context_display} │ ${automation_status} │ ${claude_version}"
}

# Execute main function
generate_statusline