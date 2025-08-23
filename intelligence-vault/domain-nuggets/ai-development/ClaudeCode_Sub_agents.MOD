<?xml version="1.0" encoding="UTF-8"?>
<document type="api-reference" subject="ClaudeCode_Sub_agents">
  <metadata>
    <created>2025-08-23</created>
    <updated>2025-08-23</updated>
    <version>1.0.0</version>
    <scope>complete-system</scope>
    <dependencies>["claude-code"]</dependencies>
    <complexity>4</complexity>
    <audience>llm-exclusive</audience>
    <official_source>Anthropic Claude Code Documentation</official_source>
    <source_file>en_docs_claude-code_sub-agents.md</source_file>
    <validation_date>Sat Aug 23 19:10:09 EDT 2025</validation_date>
    <preservation_level>complete</preservation_level>
  </metadata>

  <overview confidence="high">
    ## Subagents - Official Claude Code Reference
    
    Create
    
    Complete preservation of official Anthropic documentation with MOD format optimization for enhanced LLM consumption and integration with cognitive automation workflows.
    
    <quick-example format="json" scenario="official-documentation">
      {
        "source": "official_anthropic_documentation",
        "preservation": "zero_information_loss",
        "optimization": "mod_format_for_llm_consumption",
        "integration": "cognitive_automation_ready",
        "concepts_covered": "What are subagents?,Key benefits,Quick start,Creating subagents,Using the interactive interface,Manual creation,Subagent configuration,Required fields,Optional fields,System prompt guidelines",
        "code_examples": 10,
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
# Subagents

> Create and use specialized AI subagents in Claude Code for task-specific workflows and improved context management.

Custom subagents in Claude Code are specialized AI assistants that can be invoked to handle specific types of tasks. They enable more efficient problem-solving by providing task-specific configurations with customized system prompts, tools and a separate context window.

## What are subagents?

Subagents are pre-configured AI personalities that Claude Code can delegate tasks to. Each subagent:

* Has a specific purpose and expertise area
* Uses its own context window separate from the main conversation
* Can be configured with specific tools it's allowed to use
* Includes a custom system prompt that guides its behavior

When Claude Code encounters a task that matches a subagent's expertise, it can delegate that task to the specialized subagent, which works independently and returns results.

## Key benefits

<CardGroup cols={2}>
  <Card title="Context preservation" icon="layer-group">
    Each subagent operates in its own context, preventing pollution of the main conversation and keeping it focused on high-level objectives.
  </Card>

  <Card title="Specialized expertise" icon="brain">
    Subagents can be fine-tuned with detailed instructions for specific domains, leading to higher success rates on designated tasks.
  </Card>

  <Card title="Reusability" icon="rotate">
    Once created, subagents can be used across different projects and shared with your team for consistent workflows.
  </Card>

  <Card title="Flexible permissions" icon="shield-check">
    Each subagent can have different tool access levels, allowing you to limit powerful tools to specific subagent types.
  </Card>
</CardGroup>

## Quick start

To create your first subagent:

<Steps>
  <Step title="Open the subagents interface">
    Run the following command:

    \`\`\`
    /agents
    \`\`\`
  </Step>

  <Step title="Select 'Create New Agent'">
    Choose whether to create a project-level or user-level subagent
  </Step>

  <Step title="Define the subagent">
    Configure the subagent's name, system prompt, and allowed tools
  </Step>

  <Step title="Test the subagent">
    Use the preview feature to test your subagent before saving
  </Step>
</Steps>

## Creating subagents

### Using the interactive interface

The `/agents` command opens an interactive interface where you can:

* Browse existing subagents
* Create new subagents with guided setup
* Edit existing subagent configurations
* Test subagents before deploying

### Manual creation

Subagents are stored as markdown files in your project's `.claude/agents/` directory (for project-level agents) or `~/.claude/agents/` directory (for user-level agents).

Each subagent file follows this structure:

\`\`\`markdown
---
name: agent-name
description: Brief description of the agent's purpose
tools: comma-separated list of allowed tools
---

# System prompt content

Detailed instructions for the subagent go here...
\`\`\`

## Subagent configuration

### Required fields

**name**: A unique identifier for the subagent (used for invocation)
**description**: A brief explanation of what the subagent does

### Optional fields

**tools**: Comma-separated list of tools the subagent can use
**model**: Specific model to use (defaults to your current model)

### System prompt guidelines

The system prompt should:

* Clearly define the subagent's role and expertise
* Provide specific instructions for the types of tasks it handles
* Include any relevant context or constraints
* Use clear, actionable language

## Example subagents

### Code reviewer

\`\`\`markdown
---
name: code-reviewer
description: Specialized code review assistant
tools: Read, Grep, Glob
---

You are an expert code reviewer with deep knowledge of software engineering best practices. Your role is to:

1. Analyze code for bugs, security vulnerabilities, and performance issues
2. Suggest improvements for readability and maintainability
3. Ensure code follows established patterns and conventions
4. Provide constructive feedback with specific recommendations

Focus on actionable insights rather than general observations.
\`\`\`

### Debugger

\`\`\`markdown
---
name: debugger
description: Expert debugging assistant
tools: Read, Bash, Grep
---

You are a debugging specialist who helps identify and resolve software issues. Your responsibilities include:

1. Analyzing error messages and stack traces
2. Identifying root causes of bugs
3. Suggesting specific fixes with code examples
4. Recommending debugging strategies and tools

Always provide step-by-step debugging approaches and explain your reasoning.
\`\`\`

## Using subagents

### Automatic delegation

Claude Code automatically routes appropriate tasks to subagents based on:

* Task context and keywords
* Available subagent capabilities
* Tool requirements

### Manual invocation

You can explicitly request a specific subagent by mentioning its name:

\`\`\`
@code-reviewer Please review this function for potential issues
\`\`\`

### Best practices

1. **Single purpose**: Create focused subagents for specific domains
2. **Clear boundaries**: Define what each subagent should and shouldn't do
3. **Tool limitations**: Only grant necessary tool access
4. **Team sharing**: Store project-level subagents in version control
5. **Regular updates**: Keep subagent prompts current with your workflows

## Management

### Listing subagents

Use `/agents` to see all available subagents and their status.

### Editing subagents

Subagents can be modified through:

* The interactive `/agents` interface
* Direct editing of the markdown files
* Programmatic updates via API

### Sharing subagents

Project-level subagents (stored in `.claude/agents/`) are automatically shared with team members when committed to version control.

## Troubleshooting

### Common issues

**Subagent not found**: Check that the file exists in the correct directory and has the proper YAML frontmatter.

**Tool access denied**: Verify that the subagent's tools list includes the required tools.

**Poor performance**: Review and refine the system prompt for clarity and specificity.

### Debugging tips

* Use the preview feature to test subagents before deployment
* Check the Claude Code logs for subagent invocation details
* Start with simple subagents and add complexity gradually                ```
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
    <source-file>en_docs_claude-code_sub-agents.md</source-file>
    <conversion-date>Sat Aug 23 19:10:09 EDT 2025</conversion-date>
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
