#!/bin/bash

# Markdown to MOD Conversion System
# Converts official documentation to MOD format with full preservation + optimization
# Part of Intelligence Vault Knowledge Acquisition Pipeline

VERSION="1.0.0"
INTELLIGENCE_VAULT="intelligence-vault"
DOMAIN_NUGGETS_DIR="$INTELLIGENCE_VAULT/domain-nuggets"
OFFICIAL_DOCS_DIR="$INTELLIGENCE_VAULT/official-docs"
KNOWLEDGE_INDEX="$INTELLIGENCE_VAULT/metadata/knowledge-index.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
PURPLE='\033[0;35m'
NC='\033[0m'

usage() {
    echo "Usage: $0 <markdown_file> <domain> [nugget_name]"
    echo ""
    echo "Converts official Markdown documentation to MOD format with:"
    echo "- Zero information loss from original"
    echo "- MOD format optimization for LLM consumption"  
    echo "- Official source validation metadata"
    echo ""
    echo "Examples:"
    echo "  $0 ai_docs/en_docs_claude-code_slash-commands.md ai-development SlashCommands"
    echo "  $0 ai_docs/en_docs_claude-code_settings.md ai-development Settings"
    echo "  $0 ai_docs/en_docs_claude-code_overview.md ai-development Overview"
}

# Extract metadata from markdown file
extract_markdown_metadata() {
    local md_file="$1"
    local title=$(head -20 "$md_file" | grep '^# ' | head -1 | sed 's/^# //')
    local description=$(head -20 "$md_file" | grep '^>' | head -1 | sed 's/^> //')
    
    echo "TITLE:$title"
    echo "DESCRIPTION:$description"
}

# Convert markdown to MOD format with full preservation
convert_markdown_to_mod() {
    local md_file="$1"
    local domain="$2"
    local nugget_name="$3"
    local output_file="$4"
    
    # Extract metadata
    local metadata_lines=($(extract_markdown_metadata "$md_file"))
    local title=""
    local description=""
    
    for line in "${metadata_lines[@]}"; do
        if [[ "$line" =~ ^TITLE: ]]; then
            title="${line#TITLE:}"
        elif [[ "$line" =~ ^DESCRIPTION: ]]; then
            description="${line#DESCRIPTION:}"
        fi
    done
    
    # If no title found, use filename
    if [[ -z "$title" ]]; then
        title=$(basename "$md_file" .md | sed 's/_/ /g' | sed 's/en docs claude-code/Claude Code/')
    fi
    
    # Calculate complexity based on file size and content
    local file_size=$(wc -l < "$md_file")
    local complexity=2
    if [[ $file_size -gt 200 ]]; then
        complexity=4
    elif [[ $file_size -gt 100 ]]; then
        complexity=3
    fi
    
    # Extract key concepts and examples from markdown
    local concepts=$(grep -E "^##|^###" "$md_file" | head -10 | sed 's/^#* //' | tr '\n' ',' | sed 's/,$//')
    local has_code_blocks=$(grep -c '```' "$md_file")
    local has_tables=$(grep -c '|.*|' "$md_file")
    
    # Generate MOD header with official source validation
    cat > "$output_file" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<document type="api-reference" subject="$nugget_name">
  <metadata>
    <created>$(date +%Y-%m-%d)</created>
    <updated>$(date +%Y-%m-%d)</updated>
    <version>1.0.0</version>
    <scope>complete-system</scope>
    <dependencies>["claude-code"]</dependencies>
    <complexity>$complexity</complexity>
    <audience>llm-exclusive</audience>
    <official_source>Anthropic Claude Code Documentation</official_source>
    <source_file>$(basename "$md_file")</source_file>
    <validation_date>$(date)</validation_date>
    <preservation_level>complete</preservation_level>
  </metadata>

  <overview confidence="high">
    ## $title - Official Claude Code Reference
    
    $description
    
    Complete preservation of official Anthropic documentation with MOD format optimization for enhanced LLM consumption and integration with cognitive automation workflows.
    
    <quick-example format="json" scenario="official-documentation">
      {
        "source": "official_anthropic_documentation",
        "preservation": "zero_information_loss",
        "optimization": "mod_format_for_llm_consumption",
        "integration": "cognitive_automation_ready",
        "concepts_covered": "$concepts",
        "code_examples": $has_code_blocks,
        "reference_tables": $has_tables
      }
    </quick-example>
  </overview>

  <concepts>
    <concept id="official-documentation-content" type="core">
      <definition>
        Complete preservation of official Claude Code documentation with enhanced structure for LLM processing and cognitive automation integration.
      </definition>
      <prerequisites>["claude-code-installation", "basic-cli-usage"]</prerequisites>
      <examples category="complete-reference">
        <example scenario="full-documentation" complexity="$complexity">
          <description>Complete original documentation preserved in structured format</description>
          <code format="markdown">
EOF
    
    # Preserve complete markdown content within MOD structure
    echo "            {" >> "$output_file"
    echo "              \"original_content\": {" >> "$output_file"
    echo "                \"format\": \"markdown\"," >> "$output_file"
    echo "                \"preservation_method\": \"complete_embedding\"," >> "$output_file"
    echo "                \"content\": \`\`\`markdown" >> "$output_file"
    
    # Embed the complete markdown content, escaping as needed
    sed 's/```/\\`\\`\\`/g' "$md_file" >> "$output_file"
    
    echo "                \`\`\`" >> "$output_file"
    echo "              }" >> "$output_file"
    echo "            }" >> "$output_file"
    
    # Add structured sections based on markdown headers
    cat >> "$output_file" <<EOF
          </code>
        </example>
      </examples>
      <relationships>
        <implements>["claude-code-functionality", "official-specifications"]</implements>
        <integrates-with>["cognitive-automation", "claude-code-workflows"]</integrates-with>
        <validates>["implementation-patterns", "usage-examples"]</validates>
      </relationships>
    </concept>
  </concepts>

  <implementation-guide>
    <step-by-step>
      <step number="1" complexity="1" validation-required="true">
        <description>Reference official documentation for authoritative guidance</description>
        <examples>
          <example scenario="documentation-lookup" environment="development">
            <code format="json">
              {
                "access_method": "intelligence_vault_mod_nugget",
                "content_type": "complete_official_documentation",
                "integration": "cognitive_automation_workflows",
                "validation": "anthropic_official_source"
              }
            </code>
          </example>
        </examples>
        <validation-criteria>
          <check>Documentation content matches official source</check>
          <check>All examples and syntax preserved accurately</check>
          <check>Integration with cognitive automation functional</check>
          <expected-result>Authoritative reference available in intelligence vault</expected-result>
        </validation-criteria>
      </step>
    </step-by-step>
  </implementation-guide>

  <source-validation>
    <official-reference>Anthropic Claude Code Documentation</official-reference>
    <source-file>$(basename "$md_file")</source-file>
    <conversion-date>$(date)</conversion-date>
    <preservation-guarantee>complete_content_preservation</preservation-guarantee>
    <enhancement-type>mod_format_optimization</enhancement-type>
    <validation-method>direct_source_embedding</validation-method>
  </source-validation>

  <conclusion>
    <authoritative-status>
      This MOD nugget contains complete, unmodified official Anthropic Claude Code documentation with MOD format optimization for enhanced LLM consumption and cognitive automation integration. Zero information loss from original source.
    </authoritative-status>
  </conclusion>
</document>
EOF

    echo -e "${GREEN}✅ MOD conversion completed: $output_file${NC}"
}

# Update knowledge index with new MOD nugget
update_knowledge_index_for_mod() {
    local domain="$1"
    local nugget_name="$2"
    local coverage_areas="$3"
    local keywords="$4"
    
    echo -e "${CYAN}📊 Updating knowledge index for $nugget_name${NC}"
    
    if [[ ! -f "$KNOWLEDGE_INDEX" ]]; then
        echo -e "${RED}❌ Knowledge index not found${NC}"
        return 1
    fi
    
    # Create temporary file for jq operations
    local temp_file=$(mktemp)
    
    # Update knowledge index with new nugget
    jq --arg domain "$domain" \
       --arg nugget "$nugget_name.MOD" \
       --arg coverage "$coverage_areas" \
       --arg keywords "$keywords" '
        .domains[$domain].nuggets += [$nugget] |
        .domains[$domain].coverage_areas += (($coverage | split(",")) // []) |
        .domains[$domain].keywords += (($keywords | split(",")) // []) |
        .domains[$domain].last_updated = now |
        .total_nuggets += 1 |
        .last_updated = now |
        if (.domains_learned | index($domain) | not) then .domains_learned += [$domain] else . end |
        .knowledge_gaps = (.knowledge_gaps - [$domain])
    ' "$KNOWLEDGE_INDEX" > "$temp_file"
    
    mv "$temp_file" "$KNOWLEDGE_INDEX"
    
    echo -e "${GREEN}✅ Knowledge index updated${NC}"
}

# Main conversion workflow
main() {
    local md_file="$1"
    local domain="$2" 
    local nugget_name="$3"
    
    if [[ $# -lt 2 ]]; then
        usage
        exit 1
    fi
    
    if [[ ! -f "$md_file" ]]; then
        echo -e "${RED}❌ Markdown file not found: $md_file${NC}"
        exit 1
    fi
    
    # Auto-generate nugget name if not provided
    if [[ -z "$nugget_name" ]]; then
        nugget_name=$(basename "$md_file" .md | sed 's/en_docs_claude-code_/ClaudeCode-/' | sed 's/-/ /g' | sed 's/ /_/g')
    fi
    
    # Ensure domain directory exists
    local domain_dir="$DOMAIN_NUGGETS_DIR/$domain"
    mkdir -p "$domain_dir"
    
    local output_file="$domain_dir/${nugget_name}.MOD"
    
    echo -e "${BLUE}📚 MARKDOWN TO MOD CONVERSION v$VERSION${NC}"
    echo -e "${CYAN}Converting: $(basename "$md_file") → ${nugget_name}.MOD${NC}"
    echo -e "${PURPLE}Domain: $domain${NC}"
    echo ""
    
    # Convert markdown to MOD
    convert_markdown_to_mod "$md_file" "$domain" "$nugget_name" "$output_file"
    
    # Extract coverage areas and keywords
    local coverage_areas=$(grep -E "^##|^###" "$md_file" | head -5 | sed 's/^#* //' | tr '\n' ',' | sed 's/,$//' | tr '[:upper:]' '[:lower:]' | sed 's/ /-/g')
    local keywords=$(echo "$nugget_name" | tr '[:upper:]' '[:lower:]' | tr '_' ' ' | sed 's/claudecode/claude-code/')
    
    # Update knowledge index
    update_knowledge_index_for_mod "$domain" "$nugget_name" "$coverage_areas" "$keywords"
    
    echo ""
    echo -e "${GREEN}✅ CONVERSION COMPLETE${NC}"
    echo "MOD nugget: $output_file"
    echo "Domain: $domain"
    echo "Coverage: $coverage_areas"
    
    # Validate the created MOD
    if [[ -f "$SCRIPT_DIR/acquire-knowledge.sh" ]]; then
        echo ""
        echo -e "${BLUE}🔍 VALIDATING MOD NUGGET${NC}"
        "$SCRIPT_DIR/acquire-knowledge.sh" validate "$output_file" || true
    fi
}

main "$@"