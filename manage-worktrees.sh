#!/bin/bash

# Cognitive Automation System - Worktree Management
# Automated creation and management of isolated worktrees for parallel development

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MAIN_DIR="/mnt/c/Users/Learn/Greenfield"
PARENT_DIR="/mnt/c/Users/Learn"

show_help() {
    cat << EOF
Cognitive Automation System - Worktree Management

USAGE:
    ./manage-worktrees.sh <command> [arguments]

COMMANDS:
    create <name> <branch>     - Create new isolated worktree
    list                       - List all worktrees
    remove <name>              - Remove worktree safely
    status                     - Show worktree status and health
    cleanup                    - Clean up orphaned worktrees
    help                       - Show this help message

EXAMPLES:
    # Create experimental worktree
    ./manage-worktrees.sh create experimental feature/worktree-integration
    
    # Create performance optimization worktree
    ./manage-worktrees.sh create performance performance/service-optimization
    
    # Create research worktree
    ./manage-worktrees.sh create research experiment/new-cognitive-styles
    
    # List all worktrees
    ./manage-worktrees.sh list
    
    # Remove worktree when done
    ./manage-worktrees.sh remove experimental

WORKTREE NAMING CONVENTION:
    cognitive-styles-<name>    - Worktree directory name
    <branch>                   - Git branch name (can be new or existing)

ISOLATION FEATURES:
    - Independent signal directories: style-signals-<name>
    - Isolated service logs: service-<name>.log
    - Modified StyleService paths for complete independence
    - Separate signal processing to prevent main system interference

EOF
}

create_worktree() {
    local name="$1"
    local branch="$2"
    
    if [ -z "$name" ] || [ -z "$branch" ]; then
        echo "Error: Both name and branch are required"
        echo "Usage: $0 create <name> <branch>"
        exit 1
    fi
    
    local worktree_dir="$PARENT_DIR/cognitive-styles-$name"
    local signal_dir_name="style-signals-$name"
    
    echo "Creating worktree: cognitive-styles-$name"
    echo "Branch: $branch"
    echo "Directory: $worktree_dir"
    
    # Create the worktree
    cd "$MAIN_DIR"
    if git show-ref --verify --quiet "refs/heads/$branch"; then
        echo "Using existing branch: $branch"
        git worktree add "$worktree_dir" "$branch"
    else
        echo "Creating new branch: $branch"
        git worktree add "$worktree_dir" -b "$branch"
    fi
    
    echo "Setting up isolation for worktree: $name"
    
    # Modify StyleService for isolation
    local service_file="$worktree_dir/StyleService-Persistent.ps1"
    if [ -f "$service_file" ]; then
        echo "Configuring isolated StyleService..."
        
        # Update signal path
        sed -i "s|C:\\\\Users\\\\Learn\\\\Greenfield\\\\style-signals|C:\\\\Users\\\\Learn\\\\cognitive-styles-$name\\\\$signal_dir_name|g" "$service_file"
        
        # Update log path  
        sed -i "s|C:\\\\Users\\\\Learn\\\\Greenfield\\\\service\\.log|C:\\\\Users\\\\Learn\\\\cognitive-styles-$name\\\\service-$name.log|g" "$service_file"
        
        echo "✓ StyleService configured for isolation"
    else
        echo "Warning: StyleService-Persistent.ps1 not found in worktree"
    fi
    
    # Modify signal-style.sh for isolation
    local signal_script="$worktree_dir/signal-style.sh"
    if [ -f "$signal_script" ]; then
        echo "Configuring isolated signal interface..."
        
        # Update signal directory path
        sed -i "s|/mnt/c/Users/Learn/Greenfield/style-signals|/mnt/c/Users/Learn/cognitive-styles-$name/$signal_dir_name|g" "$signal_script"
        
        echo "✓ Signal interface configured for isolation"
    else
        echo "Warning: signal-style.sh not found in worktree"
    fi
    
    # Create isolated signal directory structure
    echo "Creating isolated signal directories..."
    local signal_dir="$worktree_dir/$signal_dir_name"
    mkdir -p "$signal_dir"/{processed,processing,queue}
    
    # Create .gitkeep files
    echo "# Worktree: $name - Signal directory" > "$signal_dir/.gitkeep"
    echo "# Worktree: $name - Processed signals" > "$signal_dir/processed/.gitkeep"
    echo "# Worktree: $name - Processing signals" > "$signal_dir/processing/.gitkeep"
    echo "# Worktree: $name - Signal queue" > "$signal_dir/queue/.gitkeep"
    
    echo "✓ Isolated signal directories created"
    
    echo ""
    echo "🎉 Worktree 'cognitive-styles-$name' created successfully!"
    echo ""
    echo "Next steps:"
    echo "1. cd $worktree_dir"
    echo "2. ./signal-style.sh <command>  # Test isolated signaling"
    echo "3. Start isolated service if needed"
    echo ""
    echo "The worktree is completely isolated from main production system."
}

list_worktrees() {
    echo "Git Worktrees:"
    git worktree list
    
    echo ""
    echo "Cognitive Automation Worktrees:"
    for dir in "$PARENT_DIR"/cognitive-styles-*; do
        if [ -d "$dir" ]; then
            local name=$(basename "$dir" | sed 's/cognitive-styles-//')
            local branch=$(cd "$dir" && git branch --show-current 2>/dev/null || echo "unknown")
            local signal_dir="$dir/style-signals-$name"
            local has_signals="No"
            if [ -d "$signal_dir" ]; then
                local signal_count=$(find "$signal_dir" -name "*.signal" 2>/dev/null | wc -l)
                has_signals="Yes ($signal_count signals)"
            fi
            
            echo "  $name: $branch (signals: $has_signals)"
        fi
    done
}

remove_worktree() {
    local name="$1"
    
    if [ -z "$name" ]; then
        echo "Error: Worktree name is required"
        echo "Usage: $0 remove <name>"
        exit 1
    fi
    
    local worktree_dir="$PARENT_DIR/cognitive-styles-$name"
    
    if [ ! -d "$worktree_dir" ]; then
        echo "Error: Worktree 'cognitive-styles-$name' does not exist"
        exit 1
    fi
    
    echo "Removing worktree: cognitive-styles-$name"
    
    cd "$MAIN_DIR"
    git worktree remove "$worktree_dir" --force
    
    echo "✓ Worktree 'cognitive-styles-$name' removed successfully"
}

show_status() {
    echo "=== Worktree Health Status ==="
    list_worktrees
    
    echo ""
    echo "=== Signal Directory Status ==="
    for dir in "$PARENT_DIR"/cognitive-styles-*; do
        if [ -d "$dir" ]; then
            local name=$(basename "$dir" | sed 's/cognitive-styles-//')
            local signal_dir="$dir/style-signals-$name"
            
            if [ -d "$signal_dir" ]; then
                echo "Worktree: $name"
                echo "  Signal directory: $signal_dir"
                echo "  Active signals: $(find "$signal_dir" -maxdepth 1 -name "*.signal" 2>/dev/null | wc -l)"
                echo "  Processed: $(find "$signal_dir/processed" -name "*.signal.*" 2>/dev/null | wc -l)"
                echo ""
            fi
        fi
    done
}

cleanup_worktrees() {
    echo "Cleaning up orphaned worktrees..."
    git worktree prune -v
    echo "✓ Cleanup complete"
}

# Main command handling
case "${1:-help}" in
    create)
        create_worktree "$2" "$3"
        ;;
    list)
        list_worktrees
        ;;
    remove)
        remove_worktree "$2"
        ;;
    status)
        show_status
        ;;
    cleanup)
        cleanup_worktrees
        ;;
    help|--help|-h)
        show_help
        ;;
    *)
        echo "Error: Unknown command '$1'"
        echo "Run './manage-worktrees.sh help' for usage information"
        exit 1
        ;;
esac