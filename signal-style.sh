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
    echo "  STRATEGIC COGNITIVE WORKFLOW (Enhanced Quartet):"
    echo "  mapper      - Mapper style + Plan Mode (2) - Advanced roadmap construction with MOD docs"
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
    echo "  context       - Display detailed context usage (/context)"
    echo "  help          - Show Claude Code help (/help)"
    echo "  prime         - Load project context (/prime)"
    echo "  compact       - Compact conversation (/compact)"
    echo ""
    echo "Direct Slash Commands (NEW!):"
    echo "  /context      - Send /context directly"
    echo "  /help         - Send /help directly" 
    echo "  /prime        - Send /prime directly"
    echo "  /any-command  - Send any slash command directly"
    echo ""
    echo "Complete Autonomous Workflow Examples:"
    echo "  ./signal-style.sh think        # → /output-style think + Plan Mode (2)"
    echo "  ./signal-style.sh plan         # → /output-style plan + Plan Mode (2)"
    echo "  ./signal-style.sh build        # → /output-style build + Bypass Mode (3)"
    echo "  ./signal-style.sh explore      # → /output-style explore + Normal Mode (0)"
    echo "  ./signal-style.sh test         # → /output-style test + Accept Mode (1)"
    echo "  ./signal-style.sh review       # → /output-style review + Normal Mode (0)"
    echo "  ./signal-style.sh context      # → /context"
    echo "  ./signal-style.sh /context     # → /context (direct slash command)"
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
STYLE_COMMANDS=("explore" "think" "plan" "build" "test" "review" "mapper")
MODE_COMMANDS=("normal-mode" "accept-mode" "plan-mode" "bypass-mode" "check-mode" "reset-mode")
BUILTIN_SLASH_COMMANDS=("context" "help" "prime" "compact")

# Check if command is valid
VALID_COMMAND=false
COMMAND_TYPE=""

# Check for direct slash commands (starts with /)
if [[ "$COMMAND" == /* ]]; then
    VALID_COMMAND=true
    COMMAND_TYPE="direct-slash"
    echo "Direct slash command: $COMMAND" > "$SIGNAL_FILE"
else
    # Check style commands
    for cmd in "${STYLE_COMMANDS[@]}"; do
        if [ "$COMMAND" = "$cmd" ]; then
            VALID_COMMAND=true
            COMMAND_TYPE="style"
            echo "Style change request: $COMMAND" > "$SIGNAL_FILE"
            break
        fi
    done
    
    # Check builtin slash commands (named without /)
    if [ "$VALID_COMMAND" = false ]; then
        for cmd in "${BUILTIN_SLASH_COMMANDS[@]}"; do
            if [ "$COMMAND" = "$cmd" ]; then
                VALID_COMMAND=true
                COMMAND_TYPE="builtin-slash"
                echo "Builtin slash command: $COMMAND" > "$SIGNAL_FILE"
                break
            fi
        done
    fi
    
    # Check mode commands
    if [ "$VALID_COMMAND" = false ]; then
        for cmd in "${MODE_COMMANDS[@]}"; do
            if [ "$COMMAND" = "$cmd" ]; then
                VALID_COMMAND=true
                COMMAND_TYPE="mode"
                echo "Mode change request: $COMMAND" > "$SIGNAL_FILE"
                break
            fi
        done
    fi
fi

if [ "$VALID_COMMAND" = false ]; then
    echo "Error: Unknown command '$COMMAND'"
    echo "Run './signal-style.sh' without arguments to see available commands"
    exit 1
fi

# Provide feedback about what will be executed
case "$COMMAND_TYPE" in
    "style")
        echo "✅ Signal created: $COMMAND → /output-style $COMMAND + coordinated mode"
        ;;
    "builtin-slash")
        echo "✅ Signal created: $COMMAND → /$COMMAND"
        ;;
    "direct-slash")
        echo "✅ Signal created: $COMMAND → $COMMAND"
        ;;
    "mode")
        echo "✅ Signal created: $COMMAND → mode change"
        ;;
esac

echo "📁 Signal file: $(basename "$SIGNAL_FILE")"
echo "🎯 Background service will process this command automatically"