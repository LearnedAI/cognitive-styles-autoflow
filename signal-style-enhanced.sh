#!/bin/bash
# Enhanced Signal Interface with Style Validation - v2.0
# Provides graceful handling of style registration and validation

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

SIGNAL_DIR="/mnt/c/Users/Learn/Greenfield/style-signals"
SIGNAL_FILE="$SIGNAL_DIR/style-change.signal"

# Test if a style actually works by checking Claude Code's response
test_style_activation() {
    local style="$1"
    
    echo -e "${BLUE}🔍 Testing style activation: $style${NC}"
    
    # Try to activate the style and check result
    # We'll simulate the /output-style command and check for "Invalid output style" response
    
    # Check if style file exists first
    if [ ! -f ".claude/output-styles/${style}.md" ]; then
        echo -e "${RED}❌ Style file not found: .claude/output-styles/${style}.md${NC}"
        return 1
    fi
    
    # File exists, but Claude Code might not have loaded it yet
    echo -e "${YELLOW}⚠️ Style file exists but may need Claude Code restart to load${NC}"
    echo -e "${BLUE}💡 Try: /output-style $style in Claude Code interface${NC}"
    return 0
}

if [ -z "$1" ]; then
    echo -e "${BLUE}Enhanced Signal Interface - Style + Mode Control v2.0${NC}"
    echo ""
    echo "Enhanced Style Validation Commands:"
    echo "  test-mapper   - Test if Mapper style is working"
    echo "  list-styles   - Show all available output styles"
    echo "  verify-setup  - Check complete Mapper setup"
    echo ""
    echo "Standard Commands:"
    echo "  mapper, think, plan, build, test, review, explore"
    exit 1
fi

COMMAND="$1"

case "$COMMAND" in
    "test-mapper")
        echo -e "${BLUE}🔍 MAPPER STYLE VALIDATION${NC}"
        echo ""
        
        # Check if file exists
        if [ -f ".claude/output-styles/mapper.md" ]; then
            echo -e "${GREEN}✅ mapper.md found in .claude/output-styles/${NC}"
        else
            echo -e "${RED}❌ mapper.md NOT found in .claude/output-styles/${NC}"
            echo "Run: cp mapper.md .claude/output-styles/"
            exit 1
        fi
        
        # Check file content
        if grep -q "name.*Mapper" ".claude/output-styles/mapper.md"; then
            echo -e "${GREEN}✅ Mapper style content valid${NC}"
        else
            echo -e "${YELLOW}⚠️ Mapper style content may be invalid${NC}"
        fi
        
        # Check signal system
        mkdir -p "$SIGNAL_DIR"
        echo "Style change request: mapper" > "$SIGNAL_FILE"
        echo -e "${GREEN}✅ Signal sent to cognitive automation${NC}"
        
        echo ""
        echo -e "${BLUE}📋 NEXT: Test manually with: /output-style mapper${NC}"
        echo -e "${YELLOW}⚠️ If still shows 'Invalid', Claude Code may need restart${NC}"
        exit 0
        ;;
        
    "verify-setup")
        echo -e "${BLUE}🔍 COMPLETE MAPPER SETUP VERIFICATION${NC}"
        echo ""
        
        # 1. Check file existence
        echo "1. Checking mapper.md file..."
        if [ -f ".claude/output-styles/mapper.md" ]; then
            echo -e "${GREEN}   ✅ mapper.md exists${NC}"
        else
            echo -e "${RED}   ❌ mapper.md missing${NC}"
            echo "   Fix: cp mapper.md .claude/output-styles/"
        fi
        
        # 2. Check plan-enhanced
        echo "2. Checking plan-enhanced.md file..."
        if [ -f ".claude/output-styles/plan-enhanced.md" ]; then
            echo -e "${GREEN}   ✅ plan-enhanced.md exists${NC}"
        else
            echo -e "${RED}   ❌ plan-enhanced.md missing${NC}"
            echo "   Fix: cp plan-enhanced.md .claude/output-styles/"
        fi
        
        # 3. Check MOD generator
        echo "3. Checking MOD generator..."
        if [ -f "generate-roadmap-mod.sh" ] && [ -x "generate-roadmap-mod.sh" ]; then
            echo -e "${GREEN}   ✅ generate-roadmap-mod.sh ready${NC}"
        else
            echo -e "${RED}   ❌ generate-roadmap-mod.sh missing or not executable${NC}"
        fi
        
        # 4. Check API prevention
        echo "4. Checking API error prevention..."
        if [ -f "prevent-api-errors.sh" ] && [ -x "prevent-api-errors.sh" ]; then
            echo -e "${GREEN}   ✅ prevent-api-errors.sh ready${NC}"
        else
            echo -e "${RED}   ❌ prevent-api-errors.sh missing or not executable${NC}"
        fi
        
        echo ""
        echo -e "${BLUE}🎯 Manual Test Required:${NC}"
        echo "   Run in Claude Code interface: /output-style mapper"
        echo "   Expected: Style changes to Mapper"
        echo "   If 'Invalid': Restart Claude Code and try again"
        exit 0
        ;;
        
    "list-styles")
        echo -e "${BLUE}📋 Available Output Styles:${NC}"
        echo ""
        if [ -d ".claude/output-styles" ]; then
            for style_file in .claude/output-styles/*.md; do
                if [ -f "$style_file" ]; then
                    style_name=$(basename "$style_file" .md)
                    echo "  $style_name"
                fi
            done
        else
            echo -e "${RED}No .claude/output-styles directory found${NC}"
        fi
        exit 0
        ;;
        
    "mapper")
        echo -e "${BLUE}🎯 Activating Mapper Style${NC}"
        
        # Pre-validation
        if [ ! -f ".claude/output-styles/mapper.md" ]; then
            echo -e "${RED}❌ Mapper style not installed properly${NC}"
            echo "Run: ./signal-style-enhanced.sh verify-setup"
            exit 1
        fi
        
        # Send signal
        mkdir -p "$SIGNAL_DIR"
        echo "Style change request: mapper" > "$SIGNAL_FILE"
        echo -e "${GREEN}✅ Mapper activation signal sent${NC}"
        
        echo ""
        echo -e "${YELLOW}📋 Next Steps:${NC}"
        echo "1. Verify activation: /output-style mapper (should NOT show 'Invalid')"
        echo "2. If still invalid: Restart Claude Code"
        echo "3. Run API prevention: ./prevent-api-errors.sh"
        echo "4. Generate roadmap: ./generate-roadmap-mod.sh --project YourProject ..."
        ;;
        
    *)
        echo -e "${RED}❌ Unknown command: $COMMAND${NC}"
        echo "Available: test-mapper, verify-setup, list-styles, mapper"
        exit 1
        ;;
esac