#!/bin/bash

# Style Service Management Script with Failure Detection and Recovery
# Provides centralized control, monitoring, and failure recovery

SCRIPT_DIR="/mnt/c/Users/Learn/Greenfield"
SIGNAL_DIR="$SCRIPT_DIR/style-signals"
LOG_DIR="$SCRIPT_DIR/timing-logs"
PID_FILE="$SCRIPT_DIR/.style-service.pid"
CONFIG_FILE="$SCRIPT_DIR/.style-service.config"

# Available service configurations
declare -A SERVICES=(
    ["current"]="StyleService.ps1"
    ["round1"]="StyleService-Round1.ps1"
    ["round2"]="StyleService-Round2.ps1"
    ["round3"]="StyleService-Round3.ps1"
    ["round3plus"]="StyleService-Round3Plus.ps1"
    ["persistent"]="StyleService-Persistent.ps1"
)

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

function log_message() {
    local level=$1
    local message=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo -e "[$timestamp] [$level] $message"
    echo "[$timestamp] [$level] $message" >> "$LOG_DIR/service-management.log"
}

function show_usage() {
    echo "Style Service Management Tool"
    echo "Usage: $0 <command> [options]"
    echo
    echo "Commands:"
    echo "  start <config>     Start service with configuration (current|round1|round2|round3|round3plus|persistent)"
    echo "  stop              Stop running service"
    echo "  restart <config>  Restart service with new configuration"
    echo "  status            Show service status and performance metrics"
    echo "  test <config>     Test specific configuration with reliability validation"
    echo "  monitor           Start real-time monitoring"
    echo "  cleanup           Clean up lock files and signals"
    echo "  benchmark         Run comprehensive benchmark across all configurations"
    echo
    echo "Examples:"
    echo "  $0 start round1              # Start Round 1 optimized timing"
    echo "  $0 test round2               # Test Round 2 configuration"
    echo "  $0 benchmark                 # Compare all configurations"
}

function cleanup_environment() {
    log_message "INFO" "Cleaning up environment"
    
    # Kill all PowerShell processes
    powershell.exe -Command "Get-Process powershell -ErrorAction SilentlyContinue | Stop-Process -Force" 2>/dev/null
    
    # Clean up files
    rm -f "$SIGNAL_DIR/.lock"
    rm -f "$SIGNAL_DIR"/*.signal
    rm -f "$PID_FILE"
    
    log_message "INFO" "Environment cleaned"
}

function start_service() {
    local config=$1
    
    if [ -z "$config" ]; then
        echo -e "${RED}Error: Configuration required${NC}"
        echo "Available: ${!SERVICES[@]}"
        return 1
    fi
    
    if [ ! -n "${SERVICES[$config]}" ]; then
        echo -e "${RED}Error: Unknown configuration '$config'${NC}"
        echo "Available: ${!SERVICES[@]}"
        return 1
    fi
    
    local service_file="${SERVICES[$config]}"
    
    if [ -f "$PID_FILE" ]; then
        echo -e "${YELLOW}Service already running. Use 'stop' first or 'restart'${NC}"
        return 1
    fi
    
    # Ensure directories exist
    mkdir -p "$SIGNAL_DIR" "$LOG_DIR"
    
    log_message "INFO" "Starting service: $service_file"
    
    # Cleanup first
    cleanup_environment
    sleep 1
    
    # Convert to Windows path for PowerShell
    local windows_path=$(echo "$SCRIPT_DIR/$service_file" | sed 's|/mnt/c|C:|' | sed 's|/|\\|g')
    
    # Start service in background with proper detachment
    nohup powershell.exe -WindowStyle Hidden -File "$windows_path" >/dev/null 2>&1 &
    local service_pid=$!
    
    # Store PID and config
    echo $service_pid > "$PID_FILE"
    echo $config > "$CONFIG_FILE"
    
    # Brief wait for initialization without blocking
    sleep 1
    
    # Quick verification (non-blocking)
    if ps -p $service_pid > /dev/null 2>&1; then
        log_message "SUCCESS" "Service started successfully (PID: $service_pid, Config: $config)"
        echo -e "${GREEN}Service started: $config configuration${NC}"
        return 0
    else
        log_message "ERROR" "Service failed to start"
        rm -f "$PID_FILE" "$CONFIG_FILE"
        echo -e "${RED}Failed to start service${NC}"
        return 1
    fi
}

function stop_service() {
    if [ ! -f "$PID_FILE" ]; then
        echo -e "${YELLOW}No service running${NC}"
        return 0
    fi
    
    local service_pid=$(cat "$PID_FILE")
    local config=$(cat "$CONFIG_FILE" 2>/dev/null || echo "unknown")
    
    log_message "INFO" "Stopping service (PID: $service_pid, Config: $config)"
    
    # Kill the specific process
    kill $service_pid 2>/dev/null
    
    # Full cleanup
    cleanup_environment
    
    echo -e "${GREEN}Service stopped${NC}"
    log_message "SUCCESS" "Service stopped successfully"
}

function get_service_status() {
    if [ ! -f "$PID_FILE" ]; then
        echo -e "${RED}Service: STOPPED${NC}"
        return 1
    fi
    
    local service_pid=$(cat "$PID_FILE")
    local config=$(cat "$CONFIG_FILE" 2>/dev/null || echo "unknown")
    
    if ps -p $service_pid > /dev/null 2>&1; then
        echo -e "${GREEN}Service: RUNNING${NC}"
        echo "  PID: $service_pid"
        echo "  Configuration: $config"
        echo "  Signal Directory: $SIGNAL_DIR"
        
        # Show recent activity
        if [ -f "$LOG_DIR/service-management.log" ]; then
            echo "  Recent Activity:"
            tail -3 "$LOG_DIR/service-management.log" | sed 's/^/    /'
        fi
        
        return 0
    else
        echo -e "${RED}Service: FAILED${NC} (PID $service_pid not found)"
        cleanup_environment
        return 1
    fi
}

function test_configuration() {
    local config=$1
    
    if [ -z "$config" ]; then
        echo -e "${RED}Error: Configuration required for testing${NC}"
        return 1
    fi
    
    echo -e "${BLUE}Testing $config configuration...${NC}"
    
    # Stop current service if running
    if [ -f "$PID_FILE" ]; then
        stop_service
        sleep 2
    fi
    
    # Start test service
    if start_service "$config"; then
        sleep 3
        
        # Run quick test
        echo "Running reliability test..."
        local test_styles=("explore" "build" "review")
        local success_count=0
        
        for style in "${test_styles[@]}"; do
            echo "Testing $style transition..."
            
            # Signal style change
            echo "Test: $style" > "$SIGNAL_DIR/$style.signal"
            
            # Wait for processing (max 10 seconds)
            local timeout=100 # 10 seconds in 0.1s intervals
            local elapsed=0
            
            while [ -f "$SIGNAL_DIR/$style.signal" ] && [ $elapsed -lt $timeout ]; do
                sleep 0.1
                elapsed=$((elapsed + 1))
            done
            
            if [ ! -f "$SIGNAL_DIR/$style.signal" ]; then
                echo -e "  ${GREEN}✓ $style: SUCCESS${NC}"
                success_count=$((success_count + 1))
            else
                echo -e "  ${RED}✗ $style: TIMEOUT${NC}"
                rm -f "$SIGNAL_DIR/$style.signal"
            fi
        done
        
        echo
        echo "Test Results: $success_count/${#test_styles[@]} successful"
        
        if [ $success_count -eq ${#test_styles[@]} ]; then
            echo -e "${GREEN}Configuration $config: RELIABLE${NC}"
        else
            echo -e "${YELLOW}Configuration $config: NEEDS ATTENTION${NC}"
        fi
        
        # Stop test service
        stop_service
        
    else
        echo -e "${RED}Failed to start $config for testing${NC}"
        return 1
    fi
}

function monitor_service() {
    echo -e "${BLUE}Starting real-time monitoring... (Ctrl+C to stop)${NC}"
    echo "Monitoring signal directory and service logs"
    echo
    
    # Monitor signal directory and logs
    while true; do
        # Check service status
        if [ -f "$PID_FILE" ]; then
            local service_pid=$(cat "$PID_FILE")
            if ! ps -p $service_pid > /dev/null 2>&1; then
                echo -e "${RED}[$(date '+%H:%M:%S')] SERVICE CRASHED - PID $service_pid not found${NC}"
                cleanup_environment
                break
            fi
        fi
        
        # Check for signal files
        local signals=$(ls "$SIGNAL_DIR"/*.signal 2>/dev/null | wc -l)
        if [ $signals -gt 0 ]; then
            echo -e "${YELLOW}[$(date '+%H:%M:%S')] Processing $signals signal(s)...${NC}"
        fi
        
        # Check for lock file
        if [ -f "$SIGNAL_DIR/.lock" ]; then
            echo -e "${BLUE}[$(date '+%H:%M:%S')] Service busy (lock active)${NC}"
        fi
        
        sleep 1
    done
}

function run_benchmark() {
    echo -e "${BLUE}Running comprehensive benchmark across all configurations...${NC}"
    
    # Stop any running service
    if [ -f "$PID_FILE" ]; then
        stop_service
        sleep 2
    fi
    
    # Run the full timing test
    "$SCRIPT_DIR/test-timing-rounds.sh"
    
    echo -e "${GREEN}Benchmark completed. Check $LOG_DIR for detailed results.${NC}"
}

# Main command processing
case "$1" in
    "start")
        start_service "$2"
        ;;
    "stop")
        stop_service
        ;;
    "restart")
        stop_service
        sleep 2
        start_service "$2"
        ;;
    "status")
        get_service_status
        ;;
    "test")
        test_configuration "$2"
        ;;
    "monitor")
        monitor_service
        ;;
    "cleanup")
        cleanup_environment
        ;;
    "benchmark")
        run_benchmark
        ;;
    *)
        show_usage
        exit 1
        ;;
esac