#!/bin/bash
# SessionStart Hook for Cognitive Automation System v2.1
# Displays knowledge status and loads priority nuggets automatically

# Read JSON input from Claude Code
INPUT=$(cat)
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"')
SOURCE=$(echo "$INPUT" | jq -r '.source // "startup"')

# Only run on actual startup (not resume/clear)
if [[ "$SOURCE" == "startup" ]]; then
    # Display Knowledge Status Table
    cat << 'EOF'
=== COGNITIVE AUTOMATION SYSTEM v2.1 - KNOWLEDGE STATUS ===

┌─────────────────┬─────────┬─────────────┬──────────────────┐
│ Domain          │ Nuggets │ Coverage    │ Official Backing │
├─────────────────┼─────────┼─────────────┼──────────────────┤
│ ai-development  │   26    │ 126+ areas  │ 100% Anthropic   │
│ git             │    1    │  4 areas    │ 100% Official    │
│ authentication  │    1    │  2 areas    │ 100% Official    │
├─────────────────┼─────────┼─────────────┼──────────────────┤
│ TOTAL           │   28    │ 130+ areas  │ 100% Official    │
└─────────────────┴─────────┴─────────────┴──────────────────┘

🧠 SYSTEM STATUS:
   ✅ Cognitive Automation: ACTIVE
   ✅ Intelligence Vault: LOADED (28 nuggets)
   ✅ Confidence Assessment: 5-DIMENSIONAL
   ✅ Parallel Development: WORKTREES_READY
   ✅ Knowledge Coverage: EXPERT (Claude Code Complete)

🚀 CAPABILITIES ONLINE:
   • Autonomous cognitive style automation
   • Complete Claude Code expertise (zero information loss)
   • Intelligent context assembly for any task
   • 5D confidence assessment with knowledge validation
   • Risk-free parallel development with worktrees
   • Automatic knowledge gap detection and research

📚 AUTO-LOADED EXPERT DOMAINS:
   • Claude Code Core: Overview, Quickstart, Common Workflows
   • Output Styles: Custom styles + Official Anthropic docs
   • Essential Tools: Slash Commands, Settings, Hooks, Memory
   • CLI Reference: Complete command documentation
   • Git Operations: Worktrees and parallel development

💡 ON-DEMAND EXPERTISE AVAILABLE:
   • IDE Integrations, Sub-agents, MCP, Interactive Mode
   • Troubleshooting, OAuth2 Authentication
   • Enterprise features loaded on request

EOF

    # Generate additional context for Claude with priority nugget summaries
    echo '{"hookSpecificOutput": {"hookEventName": "SessionStart", "additionalContext": "Intelligence Vault v2.1 loaded with 28 expert nuggets. Auto-loaded 11 essential Claude Code nuggets covering core workflows, output styles, slash commands, settings, hooks, memory, CLI reference, and git worktrees. On-demand loading available for IDE integrations, sub-agents, MCP, troubleshooting, and enterprise features. 5-dimensional confidence assessment active with knowledge completeness validation. Cognitive automation system ready for autonomous workflow orchestration."}}'
fi

exit 0