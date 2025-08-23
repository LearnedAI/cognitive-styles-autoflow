<?xml version="1.0" encoding="UTF-8"?>
<document type="api-reference" subject="ClaudeCode_Iam">
  <metadata>
    <created>2025-08-23</created>
    <updated>2025-08-23</updated>
    <version>1.0.0</version>
    <scope>complete-system</scope>
    <dependencies>["claude-code"]</dependencies>
    <complexity>3</complexity>
    <audience>llm-exclusive</audience>
    <official_source>Anthropic Claude Code Documentation</official_source>
    <source_file>en_docs_claude-code_iam.md</source_file>
    <validation_date>Sat Aug 23 19:10:01 EDT 2025</validation_date>
    <preservation_level>complete</preservation_level>
  </metadata>

  <overview confidence="high">
    ## Identity - Official Claude Code Reference
    
    Learn
    
    Complete preservation of official Anthropic documentation with MOD format optimization for enhanced LLM consumption and integration with cognitive automation workflows.
    
    <quick-example format="json" scenario="official-documentation">
      {
        "source": "official_anthropic_documentation",
        "preservation": "zero_information_loss",
        "optimization": "mod_format_for_llm_consumption",
        "integration": "cognitive_automation_ready",
        "concepts_covered": "Authentication methods,Anthropic API authentication,Cloud provider authentication,Access control and permissions,Permission system,Configuring permissions,Permission modes,Working directories,Tool-specific permission rules,Enterprise managed policy settings",
        "code_examples": 0,
        "reference_tables": 11
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
        <example scenario="full-documentation" complexity="3">
          <description>Complete original documentation preserved in structured format</description>
          <code format="markdown">
            {
              "original_content": {
                "format": "markdown",
                "preservation_method": "complete_embedding",
                "content": ```markdown
# Identity and Access Management

> Learn how to configure user authentication, authorization, and access controls for Claude Code in your organization.

## Authentication methods

Setting up Claude Code requires access to Anthropic models. For teams, you can set up Claude Code access in one of three ways:

* Anthropic API via the Anthropic Console
* Amazon Bedrock
* Google Vertex AI

### Anthropic API authentication

**To set up Claude Code access for your team via Anthropic API:**

1. Use your existing Anthropic Console account or create a new Anthropic Console account
2. You can add users through either method below:
   * Bulk invite users from within the Console (Console -> Settings -> Members -> Invite)
   * [Set up SSO](https://support.anthropic.com/en/articles/10280258-setting-up-single-sign-on-on-the-api-console)
3. When inviting users, they need one of the following roles:
   * "Claude Code" role means users can only create Claude Code API keys
   * "Developer" role means users can create any kind of API key
4. Each invited user needs to complete these steps:
   * Accept the Console invite
   * [Check system requirements](/en/docs/claude-code/setup#system-requirements)
   * [Install Claude Code](/en/docs/claude-code/setup#installation)
   * Login with Console account credentials

### Cloud provider authentication

**To set up Claude Code access for your team via Bedrock or Vertex:**

1. Follow the [Bedrock docs](/en/docs/claude-code/amazon-bedrock) or [Vertex docs](/en/docs/claude-code/google-vertex-ai)
2. Distribute the environment variables and instructions for generating cloud credentials to your users. Read more about how to [manage configuration here](/en/docs/claude-code/settings).
3. Users can [install Claude Code](/en/docs/claude-code/setup#installation)

## Access control and permissions

We support fine-grained permissions so that you're able to specify exactly what the agent is allowed to do (e.g. run tests, run linter) and what it is not allowed to do (e.g. update cloud infrastructure). These permission settings can be checked into version control and distributed to all developers in your organization, as well as customized by individual developers.

### Permission system

Claude Code uses a tiered permission system to balance power and safety:

| Tool Type         | Example              | Approval Required | "Yes, don't ask again" Behavior               |
| :---------------- | :------------------- | :---------------- | :-------------------------------------------- |
| Read-only         | File reads, LS, Grep | No                | N/A                                           |
| Bash Commands     | Shell execution      | Yes               | Permanently per project directory and command |
| File Modification | Edit/write files     | Yes               | Until session end                             |

### Configuring permissions

You can view & manage Claude Code's tool permissions with `/permissions`. This UI lists all permission rules and the settings.json file they are sourced from.

* **Allow** rules will allow Claude Code to use the specified tool without further manual approval.
* **Deny** rules will prevent Claude Code from using the specified tool. Deny rules take precedence over allow rules.
* **Additional directories** extend Claude's file access to directories beyond the initial working directory.
* **Default mode** controls Claude's permission behavior when encountering new requests.

Permission rules use the format: `Tool(optional-specifier)`

A rule that is just the tool name matches any use of that tool. For example, adding `Bash` to the list of allow rules would allow Claude Code to use the Bash tool without requiring user approval.

#### Permission modes

Claude Code supports several permission modes that can be set as the `defaultMode` in [settings files](/en/docs/claude-code/settings#settings-files):

| Mode                | Description                                                                  |
| :------------------ | :--------------------------------------------------------------------------- |
| `default`           | Standard behavior - prompts for permission on first use of each tool         |
| `acceptEdits`       | Automatically accepts file edit permissions for the session                  |
| `plan`              | Plan mode - Claude can analyze but not modify files or execute commands      |
| `bypassPermissions` | Skips all permission prompts (requires safe environment - see warning below) |

#### Working directories

By default, Claude has access to files in the directory where it was launched. You can extend this access:

* **During startup**: Use `--add-dir <path>` CLI argument
* **During session**: Use `/add-dir` slash command
* **Persistent configuration**: Add to `additionalDirectories` in [settings files](/en/docs/claude-code/settings#settings-files)

Files in additional directories follow the same permission rules as the original working directory - they become readable without prompts, and file editing permissions follow the current permission mode.

#### Tool-specific permission rules

Some tools use the optional specifier for more fine-grained permission controls. For example, an allow rule with `Bash(git diff:*)` would allow Bash commands that start with `git diff`. The following tools support permission rules with specifiers:

**Bash**

* `Bash(npm run build)` Matches the exact Bash command `npm run build`
* `Bash(npm run test:*)` Matches Bash commands starting with `npm run test`.

<Tip>
  Claude Code is aware of shell operators (like `&&`) so a prefix match rule like `Bash(safe-cmd:*)` won't give it permission to run the command `safe-cmd && other-cmd`
</Tip>

**Read & Edit**

`Edit` rules apply to all built-in tools that edit files. Claude will make a best-effort attempt to apply `Read` rules to all built-in tools that read files like Grep, Glob, and LS.

Read & Edit rules both follow the [gitignore](https://git-scm.com/docs/gitignore) specification. Patterns are resolved relative to the directory containing `.claude/settings.json`. To reference an absolute path, use `//`. For a path relative to your home directory, use `~/`.

* `Edit(docs/**)` Matches edits to files in the `docs` directory of your project
* `Read(~/.zshrc)` Matches reads to your `~/.zshrc` file
* `Edit(//tmp/scratch.txt)` Matches edits to `/tmp/scratch.txt`

**WebFetch**

* `WebFetch(domain:example.com)` Matches fetch requests to example.com

**MCP**

* `mcp__puppeteer` Matches any tool provided by the `puppeteer` server (name configured in Claude Code)
* `mcp__puppeteer__puppeteer_navigate` Matches the `puppeteer_navigate` tool provided by the `puppeteer` server

### Enterprise managed policy settings

For enterprise deployments of Claude Code, we support enterprise managed policy settings that take precedence over user and project settings. This allows system administrators to enforce security policies that users cannot override.

System administrators can deploy policies to:

* **macOS**: `/Library/Application Support/ClaudeCode/managed-settings.json`
* **Linux and Windows (via WSL)**: `/etc/claude-code/managed-settings.json`

These policy files follow the same format as regular [settings files](/en/docs/claude-code/settings#settings-files) but cannot be overridden by user or project settings. This ensures consistent security policies across your organization.

### Settings precedence

When multiple settings sources exist, they are applied in the following order (highest to lowest precedence):

1. Enterprise policies
2. Command line arguments
3. Local project settings (`.claude/settings.local.json`)
4. Shared project settings (`.claude/settings.json`)
5. User settings (`~/.claude/settings.json`)

This hierarchy ensures that organizational policies are always enforced while still allowing flexibility at the project and user levels where appropriate.

### Additional permission control with hooks

[Claude Code hooks](/en/docs/claude-code/hooks) provide a way to register custom shell commands to perform permission evaluation at runtime. When Claude Code makes a tool call, PreToolUse hooks run before the permission system runs, and the hook output can determine whether to approve or deny the tool call in place of the permission system.

## Credential management

Claude Code supports authentication via Claude.ai credentials, Anthropic API credentials, Bedrock Auth, and Vertex Auth. On macOS, the API keys, OAuth tokens, and other credentials are stored on encrypted macOS Keychain. Alternately, the setting [apiKeyHelper](/en/docs/claude-code/settings#available-settings) can be set to a shell script which returns an API key. By default, this helper is called after 5 minutes or on HTTP 401 response; specifying environment variable `CLAUDE_CODE_API_KEY_HELPER_TTL_MS` defines a custom refresh interval.
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
    <source-file>en_docs_claude-code_iam.md</source-file>
    <conversion-date>Sat Aug 23 19:10:01 EDT 2025</conversion-date>
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
