<?xml version="1.0" encoding="UTF-8"?>
<document type="api-reference" subject="ClaudeCode_Setup">
  <metadata>
    <created>2025-08-23</created>
    <updated>2025-08-23</updated>
    <version>1.0.0</version>
    <scope>complete-system</scope>
    <dependencies>["claude-code"]</dependencies>
    <complexity>4</complexity>
    <audience>llm-exclusive</audience>
    <official_source>Anthropic Claude Code Documentation</official_source>
    <source_file>en_docs_claude-code_setup.md</source_file>
    <validation_date>Sat Aug 23 19:21:04 EDT 2025</validation_date>
    <preservation_level>complete</preservation_level>
  </metadata>

  <overview confidence="high">
    ## Claude - Official Claude Code Reference
    
    Advanced
    
    Complete preservation of official Anthropic documentation with MOD format optimization for enhanced LLM consumption and integration with cognitive automation workflows.
    
    <quick-example format="json" scenario="official-documentation">
      {
        "source": "official_anthropic_documentation",
        "preservation": "zero_information_loss",
        "optimization": "mod_format_for_llm_consumption",
        "integration": "cognitive_automation_ready",
        "concepts_covered": "System Requirements,Operating Systems,Hardware Requirements,Software Dependencies,Installation Methods,Standard NPM Installation,Native Binary Installation (Beta),Local Installation (Non-Global),Authentication Configuration,Anthropic Console (Default)",
        "code_examples": 38,
        "reference_tables": 0
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
        <example scenario="full-documentation" complexity="4">
          <description>Complete original documentation preserved in structured format</description>
          <code format="markdown">
            {
              "original_content": {
                "format": "markdown",
                "preservation_method": "complete_embedding",
                "content": ```markdown
# Claude Code setup

> Advanced setup options, enterprise configurations, and deployment-specific instructions for Claude Code.

## System Requirements

### Operating Systems
- **macOS**: 10.15+ (Catalina or later)
- **Linux**: Ubuntu 20.04+, Debian 10+, or compatible distributions
- **Windows**: 10+ (with WSL recommended)

### Hardware Requirements
- **RAM**: 4GB+ recommended for optimal performance
- **Storage**: 1GB+ available space
- **Network**: Stable internet connection required

### Software Dependencies
- **Node.js**: Version 18 or newer
- **Shell**: Bash, Zsh, or Fish recommended
- **Terminal**: Modern terminal emulator with Unicode support

## Installation Methods

### Standard NPM Installation
\`\`\`bash
npm install -g @anthropic-ai/claude-code
\`\`\`

### Native Binary Installation (Beta)
For macOS, Linux, and WSL:
\`\`\`bash
curl -fsSL https://claude.ai/install.sh | bash
\`\`\`

For Windows PowerShell:
\`\`\`powershell
irm https://claude.ai/install.ps1 | iex
\`\`\`

### Local Installation (Non-Global)
If you prefer not to install globally:
\`\`\`bash
# Create local directory
mkdir -p ~/.local/bin
npm install --prefix ~/.local @anthropic-ai/claude-code

# Add to PATH
echo 'export PATH="$HOME/.local/node_modules/.bin:$PATH"' >> ~/.bashrc
source ~/.bashrc
\`\`\`

## Authentication Configuration

### Anthropic Console (Default)
1. Visit [console.anthropic.com](https://console.anthropic.com)
2. Generate API key
3. Run `claude login` and enter key

### Claude App Integration
For Pro/Max plan subscribers:
1. Sign in to Claude app
2. Link account via `claude login --app`

### Enterprise Authentication
#### Amazon Bedrock
\`\`\`bash
# Configure AWS credentials first
aws configure

# Set Claude Code to use Bedrock
claude config set provider bedrock
claude config set region us-east-1
\`\`\`

#### Google Vertex AI
\`\`\`bash
# Authenticate with Google Cloud
gcloud auth login

# Configure Claude Code
claude config set provider vertex
claude config set project your-project-id
\`\`\`

## Windows-Specific Setup

### WSL Configuration
**Recommended**: Use WSL 2 for best performance
\`\`\`bash
# Install WSL 2
wsl --install

# Install Node.js in WSL
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install Claude Code
npm install -g @anthropic-ai/claude-code
\`\`\`

### Native Windows Setup
For Git Bash or PowerShell users:
\`\`\`powershell
# Install via PowerShell
npm install -g @anthropic-ai/claude-code

# Configure terminal integration
claude config set terminal powershell
\`\`\`

## Advanced Configuration

### Disable Auto-Updates
\`\`\`bash
# Via configuration
claude config set auto-update false

# Via environment variable
export CLAUDE_CODE_DISABLE_AUTO_UPDATE=true
\`\`\`

### Custom Installation Directory
\`\`\`bash
# Set custom install path
export CLAUDE_CODE_INSTALL_DIR="$HOME/custom/claude-code"
npm install -g --prefix="$CLAUDE_CODE_INSTALL_DIR" @anthropic-ai/claude-code
\`\`\`

### Corporate Proxy Configuration
\`\`\`bash
# Configure proxy settings
claude config set proxy.host proxy.company.com
claude config set proxy.port 8080
claude config set proxy.auth username:password
\`\`\`

### LLM Gateway Integration
\`\`\`bash
# Point to internal LLM gateway
claude config set gateway.url https://internal-llm-gateway.company.com
claude config set gateway.auth-method bearer
claude config set gateway.token your-internal-token
\`\`\`

## Post-Installation Verification

### Health Check
\`\`\`bash
# Run comprehensive system check
claude doctor
\`\`\`

Expected output indicators:
- ✅ Node.js version compatible
- ✅ Network connectivity
- ✅ Authentication configured
- ✅ Permissions properly set

### Manual Updates
\`\`\`bash
# Check for updates
claude update --check

# Apply updates
claude update
\`\`\`

## Enterprise Deployment

### Development Container Support
Create `.devcontainer/devcontainer.json`:
\`\`\`json
{
  "name": "Claude Code Dev Environment",
  "image": "node:18",
  "postCreateCommand": "npm install -g @anthropic-ai/claude-code",
  "remoteUser": "node",
  "features": {
    "ghcr.io/devcontainers/features/github-cli:1": {}
  }
}
\`\`\`

### Team Installation Script
\`\`\`bash
#!/bin/bash
# team-install-claude-code.sh

# Verify Node.js
if ! command -v node &> /dev/null; then
    echo "Node.js required. Install from https://nodejs.org/"
    exit 1
fi

# Install Claude Code
npm install -g @anthropic-ai/claude-code

# Configure team defaults
claude config set session.timeout 3600
claude config set costs.warning-threshold 10.00

# Verify installation
claude doctor

echo "Claude Code installed and configured for team use"
\`\`\`

## Troubleshooting Common Issues

### Permission Errors
\`\`\`bash
# Fix npm permissions (Linux/macOS)
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.profile
source ~/.profile
\`\`\`

### Network Issues
\`\`\`bash
# Test connectivity
curl -I https://api.anthropic.com/health

# Configure npm registry
npm config set registry https://registry.npmjs.org/
\`\`\`

### WSL Path Issues
\`\`\`bash
# Fix Windows-WSL path integration
echo 'export PATH="$PATH:/mnt/c/Windows/System32"' >> ~/.bashrc
source ~/.bashrc
\`\`\`

## Best Practices

### Security Recommendations
1. **API Keys**: Store in secure credential managers
2. **Permissions**: Use principle of least privilege
3. **Updates**: Enable automatic security updates
4. **Logging**: Configure appropriate log levels

### Performance Optimization
1. **Memory**: Allocate sufficient RAM for large codebases
2. **Storage**: Use SSD for better response times
3. **Network**: Ensure stable, low-latency connection

### Team Collaboration
1. **Shared Configurations**: Use `.claude/settings.json` in repos
2. **Standards**: Establish team coding standards
3. **Training**: Provide Claude Code onboarding for new team members

## Next Steps

After successful setup:
1. Complete the [Quickstart guide](/en/docs/claude-code/quickstart)
2. Configure [IDE integrations](/en/docs/claude-code/ide-integrations)
3. Set up [team settings](/en/docs/claude-code/settings)
4. Review [security guidelines](/en/docs/claude-code/security)                ```
              }
            }
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
    <source-file>en_docs_claude-code_setup.md</source-file>
    <conversion-date>Sat Aug 23 19:21:04 EDT 2025</conversion-date>
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
