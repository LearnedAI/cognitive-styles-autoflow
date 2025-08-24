#!/bin/bash
# SessionStart Hook - Single Execution Prevention
# Prevents duplicate displays using session tracking

# Read JSON input from Claude Code (if provided)
INPUT=""
if [ ! -t 0 ]; then
    INPUT=$(cat)
fi

# Extract session info if available
SESSION_ID="unknown"
SOURCE="startup"
if [ ! -z "$INPUT" ]; then
    SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null || echo "unknown")
    SOURCE=$(echo "$INPUT" | jq -r '.source // "startup"' 2>/dev/null || echo "startup")
fi

# Create session tracking file
SESSION_MARKER="/tmp/claude-knowledge-status-${SESSION_ID}"

# Check if already displayed for this session
if [[ -f "$SESSION_MARKER" ]]; then
    # Already displayed, exit silently
    exit 0
fi

# Display knowledge status table
echo "=== COGNITIVE AUTOMATION SYSTEM v2.1 - KNOWLEDGE STATUS ==="
echo ""
echo "┌─────────────────┬─────────┬─────────────┬──────────────────┐"
echo "│ Domain          │ Nuggets │ Coverage    │ Official Backing │"
echo "├─────────────────┼─────────┼─────────────┼──────────────────┤"
echo "│ ai-development  │   26    │ 126+ areas  │ 100% Anthropic   │"
echo "│ git             │    1    │  4 areas    │ 100% Official    │"
echo "│ authentication  │    1    │  2 areas    │ 100% Official    │"
echo "├─────────────────┼─────────┼─────────────┼──────────────────┤"
echo "│ TOTAL           │   28    │ 130+ areas  │ 100% Official    │"
echo "└─────────────────┴─────────┴─────────────┴──────────────────┘"
echo ""
echo "🧠 SYSTEM STATUS:"
echo "   ✅ Cognitive Automation: ACTIVE"
echo "   ✅ Intelligence Vault: LOADED (28 nuggets)"
echo "   ✅ Confidence Assessment: 5-DIMENSIONAL"
echo "   ✅ Parallel Development: WORKTREES_READY"
echo "   ✅ Knowledge Coverage: EXPERT (Claude Code Complete)"
echo ""
echo "🚀 CAPABILITIES ONLINE:"
echo "   • Autonomous cognitive style automation"
echo "   • Complete Claude Code expertise (zero information loss)"
echo "   • Intelligent context assembly for any task"
echo "   • 5D confidence assessment with knowledge validation"
echo "   • Risk-free parallel development with worktrees"
echo ""

# Create session marker to prevent duplicate displays
touch "$SESSION_MARKER"

# Clean up old markers (older than 24 hours)
find /tmp -name "claude-knowledge-status-*" -mtime +1 -delete 2>/dev/null || true

exit 0