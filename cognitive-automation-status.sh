#!/bin/bash
# Cognitive Automation Status Integration for Claude Code Statusline
# Integrates with existing signal-style.sh and StyleService system
# Version: 1.0.0

# Color definitions
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly PURPLE='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly WHITE='\033[1;37m'
readonly GRAY='\033[0;90m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Status icons
readonly STATUS_ACTIVE="🟢"
readonly STATUS_INACTIVE="🔴"
readonly STATUS_WARNING="🟡"
readonly STATUS_PROCESSING="🔵"
readonly STATUS_ERROR="⚠️"

# Service files and directories
readonly STYLE_SIGNALS_DIR="style-signals"
readonly SERVICE_SCRIPT="manage-style-service.sh"
readonly SIGNAL_SCRIPT="signal-style.sh"
readonly SERVICE_LOG="service.log"

# Check if StyleService (PowerShell) is running on Windows
check_powershell_service() {
    # Check for PowerShell processes running StyleService
    if command -v powershell.exe >/dev/null 2>&1; then
        local ps_count=$(powershell.exe -Command "Get-Process | Where-Object {$_.ProcessName -like '*PowerShell*' -and $_.CommandLine -like '*StyleService*'} | Measure-Object | Select-Object -ExpandProperty Count" 2>/dev/null || echo "0")
        # Ensure we have a valid number
        if [[ "$ps_count" =~ ^[0-9]+$ ]]; then
            echo "$ps_count"
        else
            echo "0"
        fi
    else
        echo "0"
    fi
}

# Check signal processing status
check_signal_processing() {
    local processing_status="idle"
    local queue_count=0
    local processing_count=0
    
    if [[ -d "$STYLE_SIGNALS_DIR" ]]; then
        # Count files in different signal directories
        if [[ -d "$STYLE_SIGNALS_DIR/queue" ]]; then
            queue_count=$(find "$STYLE_SIGNALS_DIR/queue" -name "*.signal" 2>/dev/null | wc -l)
        fi
        
        if [[ -d "$STYLE_SIGNALS_DIR/processing" ]]; then
            processing_count=$(find "$STYLE_SIGNALS_DIR/processing" -name "*.signal" 2>/dev/null | wc -l)
        fi
        
        # Determine processing status
        if [[ $processing_count -gt 0 ]]; then
            processing_status="processing"
        elif [[ $queue_count -gt 0 ]]; then
            processing_status="queued"
        else
            processing_status="idle"
        fi
    fi
    
    echo "$processing_status:$queue_count:$processing_count"
}

# Get last processed signal information
get_last_signal_info() {
    local last_signal=""
    local last_time=""
    
    if [[ -d "$STYLE_SIGNALS_DIR/processed" ]]; then
        local latest_file=$(find "$STYLE_SIGNALS_DIR/processed" -name "*.signal.*" -printf '%T@ %p\n' 2>/dev/null | sort -nr | head -1 | cut -d' ' -f2-)
        
        if [[ -n "$latest_file" ]]; then
            last_signal=$(basename "$latest_file" | cut -d'.' -f1)
            last_time=$(stat -c %y "$latest_file" 2>/dev/null | cut -d' ' -f2 | cut -d'.' -f1)
        fi
    fi
    
    echo "$last_signal:$last_time"
}

# Check service health via management script
check_service_health() {
    local health_status="unknown"
    local service_pid=""
    
    if [[ -f "$SERVICE_SCRIPT" ]]; then
        local status_output=$(bash "$SERVICE_SCRIPT" status 2>/dev/null)
        
        if echo "$status_output" | grep -q "running"; then
            health_status="running"
            service_pid=$(echo "$status_output" | grep -o "PID: [0-9]*" | cut -d' ' -f2)
        elif echo "$status_output" | grep -q "stopped"; then
            health_status="stopped"
        else
            health_status="unknown"
        fi
    fi
    
    echo "$health_status:$service_pid"
}

# Calculate service uptime
calculate_uptime() {
    local pid="$1"
    local uptime=""
    
    if [[ -n "$pid" ]] && kill -0 "$pid" 2>/dev/null; then
        # Get process start time on Linux
        if [[ -f "/proc/$pid/stat" ]]; then
            local start_time=$(awk '{print $22}' "/proc/$pid/stat" 2>/dev/null)
            local boot_time=$(awk '/btime/ {print $2}' /proc/stat 2>/dev/null)
            local current_time=$(date +%s)
            
            if [[ -n "$start_time" && -n "$boot_time" ]]; then
                local process_start=$((boot_time + start_time / $(getconf CLK_TCK)))
                local uptime_seconds=$((current_time - process_start))
                
                if [[ $uptime_seconds -gt 3600 ]]; then
                    uptime="${uptime_seconds}h"
                elif [[ $uptime_seconds -gt 60 ]]; then
                    uptime="${uptime_seconds}m"
                else
                    uptime="${uptime_seconds}s"
                fi
            fi
        fi
    fi
    
    echo "$uptime"
}

# Get confidence score from recent operations
get_confidence_score() {
    local confidence="N/A"
    
    # Look for confidence assessment files
    if [[ -f "confidence-assessment.log" ]]; then
        local latest_confidence=$(tail -1 "confidence-assessment.log" 2>/dev/null | grep -o "[0-9]\+%" | tail -1)
        if [[ -n "$latest_confidence" ]]; then
            confidence="$latest_confidence"
        fi
    fi
    
    echo "$confidence"
}

# Check for recent errors in service log
check_recent_errors() {
    local error_count=0
    local last_error=""
    
    if [[ -f "$SERVICE_LOG" ]]; then
        # Count errors in last 100 lines
        local temp_count=$(tail -100 "$SERVICE_LOG" 2>/dev/null | grep -ci "error\|failed\|exception" | head -1)
        if [[ "$temp_count" =~ ^[0-9]+$ ]]; then
            error_count="$temp_count"
        fi
        
        # Get last error message
        last_error=$(tail -100 "$SERVICE_LOG" 2>/dev/null | grep -i "error\|failed\|exception" | tail -1 | cut -c1-50)
    fi
    
    echo "$error_count:$last_error"
}

# Format automation status for display
format_automation_status() {
    local format="$1"  # compact, detailed, json
    
    # Gather all status information
    local ps_service_count=$(check_powershell_service)
    local signal_info=$(check_signal_processing)
    local service_health_info=$(check_service_health)
    local last_signal_info=$(get_last_signal_info)
    local confidence_score=$(get_confidence_score)
    local error_info=$(check_recent_errors)
    
    # Parse gathered information
    local signal_status=$(echo "$signal_info" | cut -d: -f1)
    local queue_count=$(echo "$signal_info" | cut -d: -f2)
    local processing_count=$(echo "$signal_info" | cut -d: -f3)
    
    local health_status=$(echo "$service_health_info" | cut -d: -f1)
    local service_pid=$(echo "$service_health_info" | cut -d: -f2)
    
    local last_signal=$(echo "$last_signal_info" | cut -d: -f1)
    local last_time=$(echo "$last_signal_info" | cut -d: -f2)
    
    local error_count=$(echo "$error_info" | cut -d: -f1)
    local last_error=$(echo "$error_info" | cut -d: -f2)
    
    # Calculate uptime if service is running
    local uptime=""
    if [[ -n "$service_pid" ]]; then
        uptime=$(calculate_uptime "$service_pid")
    fi
    
    # Determine overall status
    local status_icon="$STATUS_INACTIVE"
    local status_text="Inactive"
    local status_color="$RED"
    
    if [[ "$health_status" == "running" || ( -n "$ps_service_count" && $ps_service_count -gt 0 ) ]]; then
        if [[ -n "$error_count" && $error_count -gt 0 ]]; then
            status_icon="$STATUS_WARNING"
            status_text="Warning"
            status_color="$YELLOW"
        elif [[ "$signal_status" == "processing" ]]; then
            status_icon="$STATUS_PROCESSING"
            status_text="Processing"
            status_color="$BLUE"
        else
            status_icon="$STATUS_ACTIVE"
            status_text="Active"
            status_color="$GREEN"
        fi
    fi
    
    # Format output based on requested format
    case "$format" in
        "json")
            cat <<EOF
{
    "overall_status": "$status_text",
    "service_running": $([ "$health_status" == "running" ] && echo "true" || echo "false"),
    "powershell_processes": $ps_service_count,
    "signal_processing": {
        "status": "$signal_status",
        "queue_count": $queue_count,
        "processing_count": $processing_count
    },
    "last_signal": {
        "type": "$last_signal",
        "time": "$last_time"
    },
    "service_pid": "$service_pid",
    "uptime": "$uptime",
    "confidence_score": "$confidence_score",
    "recent_errors": $error_count,
    "last_error": "$last_error"
}
EOF
            ;;
        "detailed")
            echo -e "Cognitive Automation: ${status_color}${status_icon} ${status_text}${NC}"
            if [[ -n "$uptime" ]]; then
                echo -e "Service Uptime: ${uptime}"
            fi
            if [[ -n "$last_signal" ]]; then
                echo -e "Last Signal: ${last_signal} @ ${last_time}"
            fi
            if [[ $queue_count -gt 0 || $processing_count -gt 0 ]]; then
                echo -e "Queue: ${queue_count} | Processing: ${processing_count}"
            fi
            if [[ "$confidence_score" != "N/A" ]]; then
                echo -e "Confidence: ${confidence_score}"
            fi
            if [[ -n "$error_count" && $error_count -gt 0 ]]; then
                echo -e "${YELLOW}Recent Errors: ${error_count}${NC}"
            fi
            ;;
        *)
            # Compact format for statusline
            echo "${status_icon}:${status_text}:${last_signal}:${confidence_score}:${error_count}"
            ;;
    esac
}

# Main execution
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    format_automation_status "${1:-compact}"
fi