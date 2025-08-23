#!/bin/bash

# Quick Worktree Creation - Common Presets for Cognitive Automation System

set -e

show_help() {
    cat << EOF
Quick Worktree Creation - Common Presets

USAGE:
    ./quick-worktree.sh <preset>

PRESETS:
    experimental    - Create experimental worktree for testing new features
    performance     - Create performance optimization worktree  
    research        - Create research worktree for new cognitive styles
    feature <name>  - Create feature development worktree
    bugfix <name>   - Create bugfix worktree
    custom <name> <branch> - Create custom worktree

EXAMPLES:
    ./quick-worktree.sh experimental
    ./quick-worktree.sh performance  
    ./quick-worktree.sh research
    ./quick-worktree.sh feature new-coordination
    ./quick-worktree.sh bugfix race-condition-fix
    ./quick-worktree.sh custom prototype experiment/prototype-v2

This script uses manage-worktrees.sh with predefined naming conventions.
EOF
}

case "${1:-help}" in
    experimental)
        echo "Creating experimental worktree..."
        ./manage-worktrees.sh create experimental feature/experimental-$(date +%Y%m%d)
        ;;
    performance)
        echo "Creating performance optimization worktree..."
        ./manage-worktrees.sh create performance performance/optimization-$(date +%Y%m%d)
        ;;
    research)
        echo "Creating research worktree..."
        ./manage-worktrees.sh create research experiment/research-$(date +%Y%m%d)
        ;;
    feature)
        if [ -z "$2" ]; then
            echo "Error: Feature name required"
            echo "Usage: $0 feature <name>"
            exit 1
        fi
        echo "Creating feature worktree: $2"
        ./manage-worktrees.sh create "feature-$2" "feature/$2"
        ;;
    bugfix)
        if [ -z "$2" ]; then
            echo "Error: Bugfix name required"  
            echo "Usage: $0 bugfix <name>"
            exit 1
        fi
        echo "Creating bugfix worktree: $2"
        ./manage-worktrees.sh create "bugfix-$2" "bugfix/$2"
        ;;
    custom)
        if [ -z "$2" ] || [ -z "$3" ]; then
            echo "Error: Both name and branch required"
            echo "Usage: $0 custom <name> <branch>"
            exit 1
        fi
        echo "Creating custom worktree: $2"
        ./manage-worktrees.sh create "$2" "$3"
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Error: Unknown preset '$1'"
        echo "Run './quick-worktree.sh help' for available presets"
        exit 1
        ;;
esac