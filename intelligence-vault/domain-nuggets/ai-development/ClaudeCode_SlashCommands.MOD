<?xml version="1.0" encoding="UTF-8"?>
<document type="api-reference" subject="ClaudeCode_SlashCommands">
  <metadata>
    <created>2025-08-23</created>
    <updated>2025-08-25</updated>
    <version>1.1.0</version>
    <scope>complete-system</scope>
    <dependencies>["claude-code"]</dependencies>
    <complexity>4</complexity>
    <audience>llm-exclusive</audience>
    <official_source>Anthropic Claude Code Documentation</official_source>
    <source_file>en_docs_claude-code_slash-commands.md</source_file>
    <validation_date>Sat Aug 23 19:06:16 EDT 2025</validation_date>
    <preservation_level>complete</preservation_level>
  </metadata>

  <overview confidence="high">
    ## Slash - Official Claude Code Reference
    
    Control
    
    Complete preservation of official Anthropic documentation with MOD format optimization for enhanced LLM consumption and integration with cognitive automation workflows.
    
    <quick-example format="json" scenario="official-documentation">
      {
        "source": "official_anthropic_documentation",
        "preservation": "zero_information_loss",
        "optimization": "mod_format_for_llm_consumption",
        "integration": "cognitive_automation_ready",
        "concepts_covered": "Built-in slash commands,Custom slash commands,Syntax,Parameters,Command types,Project commands,Personal commands,Features,Namespacing,Arguments",
        "code_examples": 16,
        "reference_tables": 26
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
# Slash commands

> Control Claude's behavior during an interactive session with slash commands.

## Built-in slash commands

| Command                   | Purpose                                                                        |
| :------------------------ | :----------------------------------------------------------------------------- |
| `/add-dir`                | Add additional working directories                                             |
| `/bug`                    | Report bugs (sends conversation to Anthropic)                                  |
| `/clear`                  | Clear conversation history                                                     |
| `/compact [instructions]` | Compact conversation with optional focus instructions                          |
| `/config`                 | View/modify configuration                                                      |
| `/context`                | Display detailed context usage                                                 |
| `/cost`                   | Show token usage statistics                                                    |
| `/doctor`                 | Checks the health of your Claude Code installation                             |
| `/help`                   | Get usage help                                                                 |
| `/init`                   | Initialize project with CLAUDE.md guide                                        |
| `/login`                  | Switch Anthropic accounts                                                      |
| `/logout`                 | Sign out from your Anthropic account                                           |
| `/mcp`                    | Manage MCP server connections and OAuth authentication                         |
| `/memory`                 | Edit CLAUDE.md memory files                                                    |
| `/model`                  | Select or change the AI model                                                  |
| `/permissions`            | View or update [permissions](/en/docs/claude-code/iam#configuring-permissions) |
| `/pr_comments`            | View pull request comments                                                     |
| `/review`                 | Request code review                                                            |
| `/status`                 | View account and system statuses                                               |
| `/terminal-setup`         | Install Shift+Enter key binding for newlines (iTerm2 and VSCode only)          |
| `/vim`                    | Enter vim mode for alternating insert and command modes                        |

## Custom slash commands

Custom slash commands allow you to define frequently-used prompts as Markdown files that Claude Code can execute. Commands are organized by scope (project-specific or personal) and support namespacing through directory structures.

### Syntax

\`\`\`
/<command-name> [arguments]
\`\`\`

#### Parameters

| Parameter        | Description                                                       |
| :--------------- | :---------------------------------------------------------------- |
| `<command-name>` | Name derived from the Markdown filename (without `.md` extension) |
| `[arguments]`    | Optional arguments passed to the command                          |

### Command types

#### Project commands

Commands stored in your repository and shared with your team. When listed in `/help`, these commands show "(project)" after their description.

**Location**: `.claude/commands/`

In the following example, we create the `/optimize` command:

\`\`\`bash
# Create a project command
mkdir -p .claude/commands
echo "Analyze this code for performance issues and suggest optimizations:" > .claude/commands/optimize.md
\`\`\`

#### Personal commands

Commands available across all your projects. When listed in `/help`, these commands show "(user)" after their description.

**Location**: `~/.claude/commands/`

In the following example, we create the `/security-review` command:

\`\`\`bash
# Create a personal command
mkdir -p ~/.claude/commands
echo "Review this code for security vulnerabilities:" > ~/.claude/commands/security-review.md
\`\`\`

### Features

#### Namespacing

Organize commands in subdirectories. The subdirectories determine the command's
full name. The description will show whether the command comes from the project
directory (`.claude/commands`) or the user-level directory (`~/.claude/commands`).

Conflicts between user and project level commands are not supported. Otherwise,
multiple commands with the same base file name can coexist.

For example, a file at `.claude/commands/frontend/component.md` creates the command `/frontend:component` with description showing "(project)".
Meanwhile, a file at `~/.claude/commands/component.md` creates the command `/component` with description showing "(user)".

#### Arguments

Pass dynamic values to commands using the `$ARGUMENTS` placeholder.

For example:

\`\`\`bash
# Command definition
echo 'Fix issue #$ARGUMENTS following our coding standards' > .claude/commands/fix-issue.md

# Usage
> /fix-issue 123
\`\`\`

#### Bash command execution

Execute bash commands before the slash command runs using the `!` prefix. The output is included in the command context.

For example:

\`\`\`markdown
---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*)
description: Create a git commit
---

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged changes): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your task

Based on the above changes, create a single git commit.
\`\`\`

#### File references

Include file contents in commands using the `@` prefix to [reference files](/en/docs/claude-code/common-workflows#reference-files-and-directories).

For example:

\`\`\`markdown
# Reference a specific file
Review the implementation in @src/utils/helpers.js

# Reference multiple files
Compare @src/old-version.js with @src/new-version.js
\`\`\`

#### Thinking mode

Slash commands can trigger extended thinking by including [extended thinking keywords](/en/docs/claude-code/common-workflows#use-extended-thinking).

### File format

Command files support:

* **Markdown format** (`.md` extension)
* **YAML frontmatter** for metadata:
  * `allowed-tools`: List of tools the command can use
  * `description`: Brief description of the command
* **Dynamic content** with bash commands (`!`) and file references (`@`)
* **Prompt instructions** as the main content

## MCP slash commands

MCP servers can expose prompts as slash commands that become available in Claude Code. These commands are dynamically discovered from connected MCP servers.

### Command format

MCP commands follow the pattern:

\`\`\`
/mcp__<server-name>__<prompt-name> [arguments]
\`\`\`

### Features

#### Dynamic discovery

MCP commands are automatically available when:

* An MCP server is connected and active
* The server exposes prompts through the MCP protocol
* The prompts are successfully retrieved during connection

#### Arguments

MCP prompts can accept arguments defined by the server:

\`\`\`
# Without arguments
> /mcp__github__list_prs

# With arguments
> /mcp__github__pr_review 456
> /mcp__jira__create_issue "Bug title" high
\`\`\`

#### Naming conventions

* Server and prompt names are normalized
* Spaces and special characters become underscores
* Names are lowercased for consistency

### Managing MCP connections

Use the `/mcp` command to:

* View all configured MCP servers
* Check connection status
* Authenticate with OAuth-enabled servers
* Clear authentication tokens
* View available tools and prompts from each server

## See also

* [Interactive mode](/en/docs/claude-code/interactive-mode) - Shortcuts, input modes, and interactive features
* [CLI reference](/en/docs/claude-code/cli-reference) - Command-line flags and options
* [Settings](/en/docs/claude-code/settings) - Configuration options
* [Memory management](/en/docs/claude-code/memory) - Managing Claude's memory across sessions
                ```
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
    <source-file>en_docs_claude-code_slash-commands.md</source-file>
    <conversion-date>Sat Aug 23 19:06:16 EDT 2025</conversion-date>
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
