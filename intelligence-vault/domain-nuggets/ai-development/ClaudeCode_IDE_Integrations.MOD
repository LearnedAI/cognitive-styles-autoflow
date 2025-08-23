<?xml version="1.0" encoding="UTF-8"?>
<document type="api-reference" subject="ClaudeCode_IDE_Integrations">
  <metadata>
    <created>2025-08-23</created>
    <updated>2025-08-23</updated>
    <version>1.0.0</version>
    <scope>complete-system</scope>
    <dependencies>["claude-code"]</dependencies>
    <complexity>4</complexity>
    <audience>llm-exclusive</audience>
    <official_source>Anthropic Claude Code Documentation</official_source>
    <source_file>en_docs_claude-code_ide-integrations.md</source_file>
    <validation_date>Sat Aug 23 19:21:16 EDT 2025</validation_date>
    <preservation_level>complete</preservation_level>
  </metadata>

  <overview confidence="high">
    ## Claude - Official Claude Code Reference
    
    Comprehensive
    
    Complete preservation of official Anthropic documentation with MOD format optimization for enhanced LLM consumption and integration with cognitive automation workflows.
    
    <quick-example format="json" scenario="official-documentation">
      {
        "source": "official_anthropic_documentation",
        "preservation": "zero_information_loss",
        "optimization": "mod_format_for_llm_consumption",
        "integration": "cognitive_automation_ready",
        "concepts_covered": "Supported IDEs and Editors,Visual Studio Code (and Forks),JetBrains IDEs,Other Editors,Installation and Setup,VS Code Integration,Automatic Setup,Manual Configuration,JetBrains IDE Integration,Plugin Installation",
        "code_examples": 54,
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
# Claude Code IDE integrations

> Comprehensive guide to integrating Claude Code with popular IDEs and editors for seamless development workflows.

## Supported IDEs and Editors

### Visual Studio Code (and Forks)
**Full Support**: Complete integration with VS Code and compatible forks.

Supported editors:
- **Visual Studio Code** - Microsoft's official editor
- **Cursor** - AI-powered fork of VS Code
- **Windsurf** - Enhanced VS Code variant
- **VSCodium** - Open-source VS Code build
- **Code - OSS** - Open-source Visual Studio Code

### JetBrains IDEs
**Plugin Support**: Official plugin available for all JetBrains products.

Supported IDEs:
- **IntelliJ IDEA** (Community & Ultimate)
- **PyCharm** (Community & Professional)
- **WebStorm**
- **PhpStorm**
- **GoLand**
- **RubyMine**
- **CLion**
- **Rider**
- **Android Studio**
- **DataGrip**

### Other Editors
**Terminal Integration**: Works with any editor via terminal integration.

Compatible editors:
- **Vim/Neovim** - Via terminal mode
- **Emacs** - Via shell integration
- **Sublime Text** - Via build systems
- **Atom** - Via terminal packages

## Installation and Setup

### VS Code Integration

#### Automatic Setup
\`\`\`bash
# Navigate to your project in VS Code
cd your-project
code .

# Start Claude Code in integrated terminal
claude
\`\`\`

Claude Code automatically detects VS Code and enables:
- Context sharing from active editor
- File reference shortcuts
- Diff viewing in editor
- Diagnostic error sharing

#### Manual Configuration
\`\`\`bash
# Configure VS Code as preferred editor
claude config set editor.default vscode
claude config set editor.vscode.path /path/to/code

# Enable advanced features
claude config set integration.vscode.diagnostics true
claude config set integration.vscode.selections true
\`\`\`

### JetBrains IDE Integration

#### Plugin Installation
**Method 1**: Marketplace Installation
1. Open IDE Settings (Cmd+, / Ctrl+,)
2. Navigate to Plugins
3. Search for "Claude Code"
4. Install and restart IDE

**Method 2**: Manual Installation
\`\`\`bash
# Download plugin file
curl -O https://plugins.jetbrains.com/plugin/download?id=claude-code

# Install via IDE
# Settings → Plugins → Install Plugin from Disk
\`\`\`

#### Plugin Configuration
\`\`\`bash
# Set custom Claude command path
claude config set integration.jetbrains.command /custom/path/claude

# Configure multiline prompt handling
claude config set integration.jetbrains.multiline true

# Enable automatic updates
claude config set integration.jetbrains.auto-update true
\`\`\`

#### Plugin Features
- **Quick Launch**: Cmd+Esc (Mac) / Ctrl+Esc (Windows/Linux)
- **Context Sharing**: Automatically shares current file/selection
- **Diff Viewer**: View changes directly in IDE
- **Error Integration**: Shares diagnostic errors with Claude
- **File References**: Quick file insertion with shortcuts

## Key Integration Features

### Keyboard Shortcuts
**Universal Shortcuts**: Work across all supported IDEs.

Default shortcuts:
- **Launch Claude**: Cmd+Esc (Mac) / Ctrl+Esc (Windows/Linux)
- **Send Selection**: Cmd+Shift+Enter (Mac) / Ctrl+Shift+Enter (Windows/Linux)
- **Quick File Reference**: Cmd+R (Mac) / Ctrl+R (Windows/Linux)

Customization:
\`\`\`bash
# Customize keyboard shortcuts
claude config set shortcuts.launch "cmd+opt+c"
claude config set shortcuts.selection "cmd+shift+s"
claude config set shortcuts.reference "cmd+r"
\`\`\`

### Automatic Context Sharing
**Smart Context**: Automatically shares relevant context with Claude.

Shared context includes:
- **Active File**: Currently focused file content
- **Selection**: Currently selected text
- **Tab Context**: Open files in current editor group
- **Project Structure**: Relevant project files and directories
- **Git Status**: Current branch, staged changes, recent commits

Configuration:
\`\`\`bash
# Configure context sharing depth
claude config set context.max-files 10
claude config set context.include-git true
claude config set context.include-diagnostics true

# Privacy controls
claude config set context.exclude-patterns "*.env,*.key,secrets/*"
\`\`\`

### Diff Viewing
**In-Editor Diffs**: View Claude's suggested changes directly in your IDE.

Features:
- **Side-by-side** comparison
- **Unified diff** view
- **Interactive** accept/reject changes
- **Partial application** of suggested edits

Usage:
\`\`\`bash
# Enable diff viewing
claude config set diff.viewer ide
claude config set diff.format side-by-side

# Apply changes interactively
# Use Cmd+Shift+A (Mac) / Ctrl+Shift+A (Windows/Linux) in diff view
\`\`\`

### File Reference Shortcuts
**Quick References**: Easily reference files in your codebase.

Shortcut syntax:
- `@filename` - Reference specific file
- `@folder/` - Reference entire folder
- `@*.ext` - Reference files by extension
- `@grep:pattern` - Reference files containing pattern

Examples:
\`\`\`bash
# Reference specific files
"Look at @src/components/Button.tsx and @styles/button.css"

# Reference multiple files
"Review @src/api/*.ts files for consistency"

# Reference with search
"Check @grep:TODO for remaining tasks"
\`\`\`

### Diagnostic Integration
**Error Sharing**: Automatically shares IDE diagnostics with Claude.

Supported diagnostics:
- **Syntax Errors**: Parser and compiler errors
- **Linting Issues**: ESLint, Pylint, etc.
- **Type Errors**: TypeScript, Flow, mypy, etc.
- **Runtime Errors**: Debugging information
- **Performance Warnings**: Profiler insights

Configuration:
\`\`\`bash
# Enable diagnostic sharing
claude config set diagnostics.enabled true
claude config set diagnostics.auto-share true
claude config set diagnostics.severity-threshold warning
\`\`\`

## Advanced Integration Options

### Custom Commands
**IDE-Specific Commands**: Create custom commands for your workflow.

VS Code example (`settings.json`):
\`\`\`json
{
  "terminal.integrated.profiles.osx": {
    "Claude": {
      "path": "/usr/local/bin/claude",
      "args": ["--mode", "interactive", "--context", "vscode"]
    }
  }
}
\`\`\`

JetBrains example (External Tools):
\`\`\`xml
<tool name="Claude Code Review" 
      description="Review current file with Claude"
      showInMainMenu="true"
      showInEditor="true">
  <exec>
    <option name="COMMAND" value="/usr/local/bin/claude" />
    <option name="PARAMETERS" value="review $FilePath$" />
    <option name="WORKING_DIRECTORY" value="$ProjectFileDir$" />
  </exec>
</tool>
\`\`\`

### Remote Development
**Remote Integration**: Use Claude Code with remote development setups.

#### VS Code Remote Development
\`\`\`json
// .vscode/settings.json
{
  "remote.SSH.defaultExtensions": ["anthropic.claude-code"],
  "remote.containers.defaultExtensions": ["anthropic.claude-code"]
}
\`\`\`

#### GitHub Codespaces
\`\`\`json
// .devcontainer/devcontainer.json
{
  "name": "Claude Code Dev Environment",
  "image": "node:18",
  "postCreateCommand": "npm install -g @anthropic-ai/claude-code",
  "customizations": {
    "vscode": {
      "extensions": ["anthropic.claude-code"]
    }
  }
}
\`\`\`

#### JetBrains Gateway
\`\`\`bash
# Configure remote Claude Code access
claude config set remote.enabled true
claude config set remote.host your-remote-host
claude config set remote.auth ssh-key
\`\`\`

### Workspace Integration
**Multi-Project Support**: Manage multiple projects and workspaces.

Configuration:
\`\`\`bash
# Set workspace-specific settings
claude workspace set myproject api.model claude-3-sonnet
claude workspace set myproject context.max-tokens 100000

# Switch between workspaces
claude workspace switch myproject
claude workspace list
\`\`\`

## Performance Optimization

### Response Time Optimization
**Faster Integration**: Optimize for quicker IDE responses.

Configuration:
\`\`\`bash
# Enable caching
claude config set cache.enabled true
claude config set cache.ttl 300

# Optimize context processing
claude config set context.processing async
claude config set context.debounce 500ms
\`\`\`

### Memory Management
**Resource Optimization**: Manage memory usage in large projects.

Configuration:
\`\`\`bash
# Set memory limits
claude config set memory.max-heap 512MB
claude config set memory.gc-threshold 80

# Configure file limits
claude config set files.max-size 1MB
claude config set files.max-count 100
\`\`\`

### Network Optimization
**Connection Management**: Optimize network usage.

Configuration:
\`\`\`bash
# Connection pooling
claude config set network.pool-size 5
claude config set network.keep-alive true

# Request batching
claude config set network.batch-requests true
claude config set network.batch-size 10
\`\`\`

## Troubleshooting Common Issues

### VS Code Integration Issues

#### Extension Not Loading
\`\`\`bash
# Check VS Code extension status
code --list-extensions | grep claude

# Reinstall extension
code --uninstall-extension anthropic.claude-code
code --install-extension anthropic.claude-code
\`\`\`

#### Context Not Sharing
\`\`\`bash
# Verify integration settings
claude config get integration.vscode

# Reset VS Code integration
claude config reset integration.vscode
claude restart
\`\`\`

### JetBrains Plugin Issues

#### Plugin Not Responding
\`\`\`bash
# Check plugin status
claude config get integration.jetbrains.status

# Restart plugin
claude config set integration.jetbrains.restart true
\`\`\`

#### Keyboard Shortcuts Not Working
\`\`\`bash
# Check shortcut conflicts
claude config get shortcuts
claude config set shortcuts.launch "alt+c"
\`\`\`

### General Integration Issues

#### Performance Problems
\`\`\`bash
# Check performance metrics
claude doctor --performance

# Optimize settings
claude config set performance.mode fast
claude config set context.lazy-loading true
\`\`\`

#### Authentication Issues
\`\`\`bash
# Verify authentication
claude auth status

# Re-authenticate
claude login --force
\`\`\`

## Best Practices

### Workflow Integration
1. **Start Small**: Begin with basic context sharing
2. **Customize Gradually**: Add shortcuts and customizations over time
3. **Regular Updates**: Keep IDE plugins and Claude Code updated
4. **Team Standards**: Establish consistent integration patterns

### Security Considerations
1. **Context Filtering**: Use exclude patterns for sensitive files
2. **Diagnostic Privacy**: Review what diagnostics are shared
3. **Network Security**: Ensure secure connections in corporate environments
4. **Access Controls**: Implement appropriate user access controls

### Performance Tips
1. **Selective Context**: Don't share entire large codebases at once
2. **Cache Configuration**: Enable intelligent caching for better performance
3. **Resource Limits**: Set appropriate memory and file limits
4. **Background Processing**: Use async processing where possible

## Advanced Use Cases

### Code Review Workflows
\`\`\`bash
# Set up automated code review
claude config set review.auto-trigger true
claude config set review.trigger-on commit
claude config set review.include-tests true
\`\`\`

### Documentation Generation
\`\`\`bash
# Configure documentation assistance
claude config set docs.auto-generate true
claude config set docs.format markdown
claude config set docs.include-examples true
\`\`\`

### Testing Integration
\`\`\`bash
# Enable test-aware context
claude config set testing.framework jest
claude config set testing.include-coverage true
claude config set testing.auto-suggest-tests true
\`\`\`                ```
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
    <source-file>en_docs_claude-code_ide-integrations.md</source-file>
    <conversion-date>Sat Aug 23 19:21:16 EDT 2025</conversion-date>
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
