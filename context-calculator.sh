#!/bin/bash
# Enhanced Context Window Calculator for Claude Code
# Provides accurate token estimation and visualization
# Version: 1.0.0

# Constants
readonly MAX_TOKENS=200000
readonly COMPACT_THRESHOLD=160000  # 80% of max tokens
readonly TOKENS_PER_CHAR=0.25      # Refined estimation: ~4 chars per token
readonly EMERGENCY_THRESHOLD=180000 # 90% threshold for emergency alerts

# Color definitions
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly ORANGE='\033[0;33m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly GRAY='\033[0;90m'
readonly BOLD='\033[1m'
readonly BLINK='\033[5m'
readonly NC='\033[0m'

# Unicode progress bar characters
readonly FULL_BLOCK="█"
readonly SEVEN_EIGHTHS="▉"
readonly THREE_QUARTERS="▊"
readonly FIVE_EIGHTHS="▋"
readonly HALF_BLOCK="▌"
readonly THREE_EIGHTHS="▍"
readonly ONE_QUARTER="▎"
readonly ONE_EIGHTH="▏"
readonly EMPTY_BLOCK="░"

# Calculate token count from transcript file
calculate_tokens() {
    local transcript_path="$1"
    
    if [[ ! -f "$transcript_path" ]]; then
        echo "0"
        return
    fi
    
    # Get file size in characters
    local file_size=$(wc -c < "$transcript_path" 2>/dev/null || echo "0")
    
    # Enhanced token estimation considering JSON overhead
    # JSON structure adds approximately 30% overhead
    local content_chars=$((file_size * 70 / 100))
    local estimated_tokens=$(awk "BEGIN {print int($content_chars * $TOKENS_PER_CHAR)}")
    
    echo "$estimated_tokens"
}

# Calculate percentage with high precision
calculate_percentage() {
    local current_tokens="$1"
    local max_tokens="$2"
    
    if [[ $max_tokens -eq 0 ]]; then
        echo "0"
        return
    fi
    
    local percentage=$(awk "BEGIN {printf \"%.0f\", $current_tokens * 100 / $max_tokens}")
    echo "$percentage" | cut -d. -f1  # Return integer percentage
}

# Create detailed progress bar with fractional precision
create_detailed_progress_bar() {
    local percentage=$1
    local width=${2:-10}
    
    # Calculate filled blocks with fractional precision
    local filled_float=$(awk "BEGIN {printf \"%.2f\", $percentage * $width / 100}")
    local filled_int=$(echo "$filled_float" | cut -d. -f1)
    local fractional=$(echo "$filled_float" | cut -d. -f2 | head -c1)
    
    # Ensure filled_int is valid
    if [[ -z "$filled_int" || "$filled_int" == "" ]]; then
        filled_int=0
    fi
    
    local bar=""
    
    # Add full blocks
    for ((i=0; i<filled_int && i<width; i++)); do
        bar="${bar}${FULL_BLOCK}"
    done
    
    # Add fractional block if needed
    if [[ $filled_int -lt $width ]]; then
        case $fractional in
            [1-2]) bar="${bar}${ONE_EIGHTH}" ;;
            [3-4]) bar="${bar}${ONE_QUARTER}" ;;
            [5-6]) bar="${bar}${THREE_EIGHTHS}" ;;
            [7]) bar="${bar}${HALF_BLOCK}" ;;
            [8]) bar="${bar}${FIVE_EIGHTHS}" ;;
            [9]) bar="${bar}${THREE_QUARTERS}" ;;
            *) if [[ $filled_int -lt $width ]]; then bar="${bar}${EMPTY_BLOCK}"; fi ;;
        esac
        filled_int=$((filled_int + 1))
    fi
    
    # Add empty blocks
    for ((i=filled_int; i<width; i++)); do
        bar="${bar}${EMPTY_BLOCK}"
    done
    
    echo "$bar"
}

# Get context status with color and warnings
get_context_status() {
    local current_tokens=$1
    local percentage=$2
    local color=""
    local status=""
    local warning=""
    
    if [[ $current_tokens -ge $EMERGENCY_THRESHOLD ]]; then
        color="$RED$BLINK"
        status="CRITICAL"
        warning="⚠️ EMERGENCY: Context almost full!"
    elif [[ $current_tokens -ge $COMPACT_THRESHOLD ]]; then
        color="$ORANGE"
        status="WARNING"
        warning="⚠️ Auto-compact will trigger soon"
    elif [[ $percentage -ge 60 ]]; then
        color="$YELLOW"
        status="CAUTION"
        warning=""
    elif [[ $percentage -ge 30 ]]; then
        color="$CYAN"
        status="GOOD"
        warning=""
    else
        color="$GREEN"
        status="EXCELLENT"
        warning=""
    fi
    
    echo "$color:$status:$warning"
}

# Format tokens in human-readable form
format_token_count() {
    local tokens=$1
    
    if [[ $tokens -ge 1000 ]]; then
        local k_tokens=$(awk "BEGIN {printf \"%.1f\", $tokens / 1000}")
        echo "${k_tokens}K"
    else
        echo "${tokens}"
    fi
}

# Calculate time until context limit (based on current session rate)
estimate_time_to_limit() {
    local current_tokens=$1
    local session_duration_ms=$2
    
    if [[ $session_duration_ms -eq 0 || $current_tokens -eq 0 ]]; then
        echo "∞"
        return
    fi
    
    local remaining_tokens=$((COMPACT_THRESHOLD - current_tokens))
    if [[ $remaining_tokens -le 0 ]]; then
        echo "0m"
        return
    fi
    
    local tokens_per_ms=$(awk "BEGIN {printf \"%.6f\", $current_tokens / $session_duration_ms}")
    local time_to_limit_ms=$(awk "BEGIN {printf \"%.0f\", $remaining_tokens / $tokens_per_ms}")
    local time_to_limit_min=$((time_to_limit_ms / 60000))
    
    if [[ $time_to_limit_min -lt 60 ]]; then
        echo "${time_to_limit_min}m"
    else
        local hours=$((time_to_limit_min / 60))
        local mins=$((time_to_limit_min % 60))
        echo "${hours}h${mins}m"
    fi
}

# Main context analysis function
analyze_context() {
    local transcript_path="$1"
    local session_duration_ms="${2:-0}"
    local output_format="${3:-compact}"  # compact, detailed, or json
    
    # Calculate current usage
    local current_tokens=$(calculate_tokens "$transcript_path")
    local percentage=$(calculate_percentage "$current_tokens" "$MAX_TOKENS")
    local remaining_tokens=$((MAX_TOKENS - current_tokens))
    
    # Get status information
    local status_info=$(get_context_status "$current_tokens" "$percentage")
    local color=$(echo "$status_info" | cut -d: -f1)
    local status=$(echo "$status_info" | cut -d: -f2)
    local warning=$(echo "$status_info" | cut -d: -f3)
    
    # Format token counts
    local current_formatted=$(format_token_count "$current_tokens")
    local max_formatted=$(format_token_count "$MAX_TOKENS")
    local remaining_formatted=$(format_token_count "$remaining_tokens")
    
    # Calculate time estimates
    local time_to_limit=$(estimate_time_to_limit "$current_tokens" "$session_duration_ms")
    
    case $output_format in
        "json")
            cat <<EOF
{
    "current_tokens": $current_tokens,
    "max_tokens": $MAX_TOKENS,
    "percentage": $percentage,
    "remaining_tokens": $remaining_tokens,
    "status": "$status",
    "warning": "$warning",
    "time_to_limit": "$time_to_limit",
    "compact_threshold": $COMPACT_THRESHOLD,
    "emergency_threshold": $EMERGENCY_THRESHOLD
}
EOF
            ;;
        "detailed")
            local progress_bar=$(create_detailed_progress_bar "$percentage" 20)
            echo -e "Context Usage: ${color}${progress_bar}${NC} ${percentage}% (${current_formatted}/${max_formatted})"
            echo -e "Status: ${color}${status}${NC} | Remaining: ${remaining_formatted} | ETA to compact: ${time_to_limit}"
            if [[ -n "$warning" ]]; then
                echo -e "${color}${warning}${NC}"
            fi
            ;;
        *)
            # Compact format (default)
            local progress_bar=$(create_detailed_progress_bar "$percentage" 10)
            echo "${color}${progress_bar}${NC}:${percentage}:${current_formatted}:${max_formatted}:${status}:${warning}"
            ;;
    esac
}

# Test function for development
test_context_calculator() {
    echo "Testing Context Calculator..."
    echo
    
    # Test different percentage levels
    local test_percentages=(15 45 65 75 85 95)
    
    for pct in "${test_percentages[@]}"; do
        echo "Testing $pct% usage:"
        local test_tokens=$((MAX_TOKENS * pct / 100))
        local mock_transcript="/tmp/mock_transcript_${pct}.json"
        
        # Create mock file
        head -c $((test_tokens * 4)) /dev/zero > "$mock_transcript" 2>/dev/null
        
        # Analyze
        analyze_context "$mock_transcript" 600000 "detailed"
        echo
        
        # Cleanup
        rm -f "$mock_transcript"
    done
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    case "${1:-}" in
        "test")
            test_context_calculator
            ;;
        *)
            analyze_context "$@"
            ;;
    esac
fi