#!/bin/bash

# Enhanced Signal Interface - Style + Mode Control
# Usage: ./signal-style.sh <command>
# 
# Style Commands: explore, plan, build, test, review, think
# Mode Commands: normal-mode, accept-mode, plan-mode, bypass-mode
# Utility Commands: check-mode, reset-mode

if [ -z "$1" ]; then
    echo "Usage: $0 <command>"
    echo ""
    echo "Coordinated Style+Mode Commands (Automatic Pairing):"
    echo ""
    echo "  STRATEGIC COGNITIVE WORKFLOW (Core Triad):"
    echo "  think       - Think style + Plan Mode (2) - Deep cognitive exploration, no distractions"
    echo "  plan        - Plan style + Plan Mode (2) - Strategic architecture, pure planning"
    echo "  build       - Build style + Bypass Mode (3) - Full implementation with permissions"
    echo ""
    echo "  OPERATIONAL SUPPORT WORKFLOW:"
    echo "  explore     - Explore style + Normal Mode (0) - Broad discovery and exploration"
    echo "  test        - Test style + Accept Mode (1) - Validation and quality assurance"
    echo "  review      - Review style + Normal Mode (0) - Analysis and optimization"
    echo ""
    echo "Manual Mode Commands (Interface mode only):"
    echo "  normal-mode   - Switch to normal mode (Mode 0) only"
    echo "  accept-mode   - Switch to accept edits mode (Mode 1) only"
    echo "  plan-mode     - Switch to plan mode (Mode 2) only - no file editing"
    echo "  bypass-mode   - Switch to bypass permissions mode (Mode 3) only"
    echo ""
    echo "Utility Commands:"
    echo "  check-mode    - Show current interface mode"
    echo "  reset-mode    - Reset to normal mode (emergency)"
    echo ""
    echo "Complete Autonomous Workflow Examples:"
    echo "  ./signal-style.sh think        # → /output-style think + Plan Mode (2)"
    echo "  ./signal-style.sh plan         # → /output-style plan + Plan Mode (2)"
    echo "  ./signal-style.sh build        # → /output-style build + Bypass Mode (3)"
    echo "  ./signal-style.sh explore      # → /output-style explore + Normal Mode (0)"
    echo "  ./signal-style.sh test         # → /output-style test + Accept Mode (1)"
    echo "  ./signal-style.sh review       # → /output-style review + Normal Mode (0)"
    echo ""
    echo "Mode Details:"
    echo "  Mode 0 (Normal): Full editing, shows '? for shortcuts'"
    echo "  Mode 1 (Accept): Auto-accept edits, green '>>accept edits on'"
    echo "  Mode 2 (Plan): No file editing, blue '||plan mode'"
    echo "  Mode 3 (Bypass): Elevated access, red '>>bypass permissions on'"
    exit 1
fi

COMMAND=$1
SIGNAL_DIR="/mnt/c/Users/Learn/Greenfield/style-signals"
SIGNAL_FILE="$SIGNAL_DIR/$COMMAND.signal"

# Create signals directory if it doesn't exist
mkdir -p "$SIGNAL_DIR"

# Validate command type and create appropriate signal
STYLE_COMMANDS=("explore" "think" "plan" "build" "test" "review")
MODE_COMMANDS=("normal-mode" "accept-mode" "plan-mode" "bypass-mode" "check-mode" "reset-mode")

# Check if command is valid
VALID_COMMAND=false
for cmd in "${STYLE_COMMANDS[@]}"; do
    if [ "$COMMAND" = "$cmd" ]; then
        VALID_COMMAND=true
        break
    fi
done

if [ "$VALID_COMMAND" = false ]; then
    for cmd in "${MODE_COMMANDS[@]}"; do
        if [ "$COMMAND" = "$cmd" ]; then
            VALID_COMMAND=true
            break
        fi
    done
fi

if [ "$VALID_COMMAND" = false ]; then
    echo "Error: Unknown command '$COMMAND'"
    echo "Run './signal-style.sh' without arguments to see available commands"
    exit 1
fi

# Create signal file for the background service
if [[ " ${STYLE_COMMANDS[@]} " =~ " ${COMMAND} " ]]; then
    echo "Style change request: $COMMAND" > "$SIGNAL_FILE"
else
    echo "Mode change request: $COMMAND" > "$SIGNAL_FILE"
fi