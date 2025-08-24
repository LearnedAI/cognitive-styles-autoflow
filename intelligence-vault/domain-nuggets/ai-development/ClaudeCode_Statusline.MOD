<?xml version="1.0" encoding="UTF-8"?>
<document type="api-reference" subject="ClaudeCode_Statusline">
  <metadata>
    <created>2025-08-24</created>
    <updated>2025-08-24</updated>
    <version>1.0.0</version>
    <scope>complete-system</scope>
    <dependencies>["claude-code"]</dependencies>
    <complexity>2</complexity>
    <audience>llm-exclusive</audience>
    <official_source>Anthropic Claude Code Documentation</official_source>
    <source_file>en_docs_claude-code_statusline.md</source_file>
    <validation_date>2025-08-24</validation_date>
    <preservation_level>complete</preservation_level>
  </metadata>

  <overview confidence="high">
    ## Status Line Configuration - Official Claude Code Reference
    
    Create a custom status line for Claude Code to display contextual information
    
    Complete preservation of official Anthropic documentation with MOD format optimization for enhanced LLM consumption and integration with cognitive automation workflows.
    
    <quick-example format="json" scenario="official-documentation">
      {
        "source": "official_anthropic_documentation",
        "preservation": "zero_information_loss",
        "optimization": "mod_format_for_llm_consumption",
        "integration": "cognitive_automation_ready",
        "concepts_covered": "Custom status line creation,JSON input structure,Example scripts,Tips and troubleshooting",
        "code_examples": 6,
        "programming_languages": ["bash", "python", "javascript"],
        "key_features": ["terminal_prompt_customization", "ansi_color_support", "contextual_session_data"]
      }
    </quick-example>
  </overview>

  <concepts>
    <concept id="official-documentation-content" type="core">
      <definition>
        Complete preservation of official Claude Code documentation with enhanced structure for LLM processing and cognitive automation integration.
      </definition>
      <prerequisites>["claude-code-installation", "basic-cli-usage", "json-processing"]</prerequisites>
      <examples category="complete-reference">
        <example scenario="full-documentation" complexity="2">
          <description>Complete original documentation preserved in structured format</description>
          <code format="markdown">
            {
              "original_content": {
                "format": "markdown",
                "preservation_method": "complete_embedding",
                "content": ```markdown
# Status line configuration

> Create a custom status line for Claude Code to display contextual information

Make Claude Code your own with a custom status line that displays at the bottom of the Claude Code interface, similar to how terminal prompts (PS1) work in shells like Oh-my-zsh.

## Create a custom status line

You can either:

* Run `/statusline` to ask Claude Code to help you set up a custom status line. By default, it will try to reproduce your terminal's prompt, but you can provide additional instructions about the behavior you want to Claude Code, such as `/statusline show the model name in orange`

* Directly add a `statusLine` command to your `.claude/settings.json`:

```json
{
  "statusLine": {
    "type": "command",
    "command": "~/.claude/statusline.sh",
    "padding": 0 // Optional: set to 0 to let status line go to edge
  }
}
```

## How it Works

* The status line is updated when the conversation messages update
* Updates run at most every 300ms
* The first line of stdout from your command becomes the status line text
* ANSI color codes are supported for styling your status line
* Claude Code passes contextual information about the current session (model, directories, etc.) as JSON to your script via stdin

## JSON Input Structure

Your status line command receives structured data via stdin in JSON format:

```json
{
  "hook_event_name": "Status",
  "session_id": "abc123...",
  "transcript_path": "/path/to/transcript.json",
  "cwd": "/current/working/directory",
  "model": {
    "id": "claude-opus-4-1",
    "display_name": "Opus"
  },
  "workspace": {
    "current_dir": "/current/working/directory",
    "project_dir": "/original/project/directory"
  },
  "version": "1.0.80",
  "output_style": {
    "name": "default"
  },
  "cost": {
    "total_cost_usd": 0.01234,
    "total_duration_ms": 45000,
    "total_api_duration_ms": 2300,
    "total_lines_added": 156,
    "total_lines_removed": 23
  }
}
```

## Example Scripts

### Simple Status Line

```bash
#!/bin/bash
# Read JSON input from stdin
input=$(cat)

# Extract values using jq
MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')

echo "[$MODEL_DISPLAY] 📁 ${CURRENT_DIR##*/}"
```

### Git-Aware Status Line

```bash
#!/bin/bash
# Read JSON input from stdin
input=$(cat)

# Extract values using jq
MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')

# Show git branch if in a git repo
GIT_BRANCH=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(git branch --show-current 2>/dev/null)
    if [ -n "$BRANCH" ]; then
        GIT_BRANCH=" | 🌿 $BRANCH"
    fi
fi

echo "[$MODEL_DISPLAY] 📁 ${CURRENT_DIR##*/}$GIT_BRANCH"
```

### Python Example

```python
#!/usr/bin/env python3
import json
import sys
import os

# Read JSON from stdin
data = json.load(sys.stdin)

# Extract values
model = data['model']['display_name']
current_dir = os.path.basename(data['workspace']['current_dir'])

# Check for git branch
git_branch = ""
if os.path.exists('.git'):
    try:
        with open('.git/HEAD', 'r') as f:
            ref = f.read().strip()
            if ref.startswith('ref: refs/heads/'):
                git_branch = f" | 🌿 {ref.replace('ref: refs/heads/', '')}"
    except:
        pass

print(f"[{model}] 📁 {current_dir}{git_branch}")
```

### Node.js Example

```javascript
#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Read JSON from stdin
let input = '';
process.stdin.on('data', chunk => input += chunk);
process.stdin.on('end', () => {
    const data = JSON.parse(input);
    
    // Extract values
    const model = data.model.display_name;
    const currentDir = path.basename(data.workspace.current_dir);
    
    // Check for git branch
    let gitBranch = '';
    try {
        const headContent = fs.readFileSync('.git/HEAD', 'utf8').trim();
        if (headContent.startsWith('ref: refs/heads/')) {
            gitBranch = ` | 🌿 ${headContent.replace('ref: refs/heads/', '')}`;
        }
    } catch (e) {
        // Not a git repo or can't read HEAD
    }
    
    console.log(`[${model}] 📁 ${currentDir}${gitBranch}`);
});
```

### Helper Function Approach

For more complex bash scripts, you can create helper functions:

```bash
#!/bin/bash
# Read JSON input once
input=$(cat)

# Helper functions for common extractions
get_model_name() { echo "$input" | jq -r '.model.display_name'; }
get_current_dir() { echo "$input" | jq -r '.workspace.current_dir'; }
get_project_dir() { echo "$input" | jq -r '.workspace.project_dir'; }
get_version() { echo "$input" | jq -r '.version'; }
get_cost() { echo "$input" | jq -r '.cost.total_cost_usd'; }
get_duration() { echo "$input" | jq -r '.cost.total_duration_ms'; }
get_lines_added() { echo "$input" | jq -r '.cost.total_lines_added'; }
get_lines_removed() { echo "$input" | jq -r '.cost.total_lines_removed'; }

# Use the helpers
MODEL=$(get_model_name)
DIR=$(get_current_dir)
echo "[$MODEL] 📁 ${DIR##*/}"
```

## Tips

* Keep your status line concise - it should fit on one line
* Use emojis (if your terminal supports them) and colors to make information scannable
* Use `jq` for JSON parsing in Bash (see examples above)
* Test your script by running it manually with mock JSON input: `echo '{"model":{"display_name":"Test"},"workspace":{"current_dir":"/test"}}' | ./statusline.sh`
* Consider caching expensive operations (like git status) if needed

## Troubleshooting

* If your status line doesn't appear, check that your script is executable (`chmod +x`)
* Ensure your script outputs to stdout (not stderr)
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

    <concept id="statusline-configuration" type="core">
      <definition>
        Status line configuration enables custom display of contextual information at the bottom of the Claude Code interface, similar to terminal prompts in shell environments.
      </definition>
      <prerequisites>["claude-code-installation", "json-processing-tools", "shell-scripting"]</prerequisites>
      <examples category="configuration-patterns">
        <example scenario="basic-configuration" complexity="1">
          <description>Simple status line setup via settings.json</description>
          <code format="json">
            {
              "configuration_method": "settings_json",
              "file_location": ".claude/settings.json",
              "structure": {
                "statusLine": {
                  "type": "command",
                  "command": "~/.claude/statusline.sh",
                  "padding": 0
                }
              },
              "execution_details": {
                "update_frequency": "conversation_message_updates",
                "rate_limit": "300ms_maximum",
                "output_source": "first_line_stdout",
                "styling_support": "ansi_color_codes"
              }
            }
          </code>
        </example>
        <example scenario="interactive-setup" complexity="1">
          <description>Using /statusline slash command for assisted setup</description>
          <code format="json">
            {
              "command": "/statusline",
              "default_behavior": "reproduce_terminal_prompt",
              "customization_examples": [
                "/statusline show the model name in orange",
                "/statusline include git branch and cost information",
                "/statusline display current time and project directory"
              ],
              "assistance_level": "claude_code_guided_setup"
            }
          </code>
        </example>
      </examples>
      <relationships>
        <requires>["claude-code-settings", "executable-script"]</requires>
        <enables>["contextual-awareness", "workflow-visibility"]</enables>
        <integrates-with>["terminal-customization", "development-workflows"]</integrates-with>
      </relationships>
    </concept>

    <concept id="json-input-structure" type="system">
      <definition>
        Comprehensive JSON data structure passed to status line commands containing session context, model information, workspace details, and usage statistics.
      </definition>
      <prerequisites>["json-processing", "stdin-handling"]</prerequisites>
      <examples category="data-structure">
        <example scenario="complete-json-schema" complexity="3">
          <description>Full JSON input structure with all available fields</description>
          <code format="json">
            {
              "json_schema": {
                "hook_event_name": "Status",
                "session_id": "unique_session_identifier",
                "transcript_path": "conversation_log_file_path",
                "cwd": "current_working_directory",
                "model": {
                  "id": "model_internal_id",
                  "display_name": "user_friendly_model_name"
                },
                "workspace": {
                  "current_dir": "active_working_directory",
                  "project_dir": "original_project_root_directory"
                },
                "version": "claude_code_version",
                "output_style": {
                  "name": "active_output_style_name"
                },
                "cost": {
                  "total_cost_usd": "session_cost_in_dollars",
                  "total_duration_ms": "total_session_duration",
                  "total_api_duration_ms": "api_call_duration",
                  "total_lines_added": "code_lines_added",
                  "total_lines_removed": "code_lines_removed"
                }
              },
              "processing_methods": {
                "bash_jq": "echo \"$input\" | jq -r '.field.subfield'",
                "python": "data = json.load(sys.stdin)",
                "nodejs": "const data = JSON.parse(input)"
              }
            }
          </code>
        </example>
      </examples>
      <relationships>
        <provides>["session-context", "usage-metrics", "workspace-information"]</provides>
        <requires>["json-parsing-capability"]</requires>
        <enables>["dynamic-status-display", "contextual-information"]</enables>
      </relationships>
    </concept>
  </concepts>

  <implementation-guide>
    <step-by-step>
      <step number="1" complexity="1" validation-required="true">
        <description>Basic status line implementation</description>
        <examples>
          <example scenario="simple-bash-script" environment="unix-shell">
            <code format="bash">
              {
                "script_creation": "#!/bin/bash\ninput=$(cat)\nMODEL=$(echo \"$input\" | jq -r '.model.display_name')\necho \"[$MODEL] Current Session\"",
                "setup_commands": [
                  "chmod +x ~/.claude/statusline.sh",
                  "echo '{\"statusLine\":{\"type\":\"command\",\"command\":\"~/.claude/statusline.sh\"}}' >> .claude/settings.json"
                ],
                "testing": "echo '{\"model\":{\"display_name\":\"Test\"}}' | ./statusline.sh"
              }
            </code>
          </example>
        </examples>
        <validation-criteria>
          <check>Script is executable and returns status line text</check>
          <check>JSON parsing works correctly with jq</check>
          <check>Status line appears in Claude Code interface</check>
          <expected-result>Functional custom status line displaying basic information</expected-result>
        </validation-criteria>
      </step>

      <step number="2" complexity="2" validation-required="true">
        <description>Enhanced status line with multiple data sources</description>
        <examples>
          <example scenario="git-aware-status" environment="git-repository">
            <code format="bash">
              {
                "enhanced_script": "#!/bin/bash\ninput=$(cat)\nMODEL=$(echo \"$input\" | jq -r '.model.display_name')\nDIR=$(echo \"$input\" | jq -r '.workspace.current_dir')\nBRANCH=$(git branch --show-current 2>/dev/null || echo 'no-git')\necho \"[$MODEL] 📁 ${DIR##*/} 🌿 $BRANCH\"",
                "features_added": ["git_branch_detection", "directory_display", "emoji_indicators"],
                "error_handling": "graceful_fallback_for_non_git_repositories"
              }
            </code>
          </example>
        </examples>
        <validation-criteria>
          <check>Git branch detection works in repositories</check>
          <check>Graceful handling of non-git directories</check>
          <check>Multiple data sources displayed correctly</check>
          <expected-result>Rich status line with contextual workspace information</expected-result>
        </validation-criteria>
      </step>
    </step-by-step>
  </implementation-guide>

  <troubleshooting>
    <problem-category name="status-line-display">
      <diagnostic-workflow>
        <step>Check script execution permissions (chmod +x)</step>
        <step>Verify settings.json configuration syntax</step>
        <step>Test script manually with mock JSON input</step>
        <step>Check script outputs to stdout (not stderr)</step>
      </diagnostic-workflow>

      <common-issues>
        <issue id="status-line-not-appearing" frequency="high" complexity="1">
          <symptoms>
            <symptom>No status line visible in Claude Code interface</symptom>
            <symptom>Script exists but not being executed</symptom>
          </symptoms>
          <diagnostic-commands format="bash">
            [
              {"command": "ls -la ~/.claude/statusline.sh", "expected": "executable permissions -rwxr-xr-x"},
              {"command": "cat .claude/settings.json | jq .statusLine", "expected": "valid statusLine configuration"}
            ]
          </diagnostic-commands>
          <solution-examples>
            <solution scenario="permission-fix">
              <code format="bash">
                {
                  "fix_permissions": "chmod +x ~/.claude/statusline.sh",
                  "test_script": "echo '{\"model\":{\"display_name\":\"Test\"}}' | ~/.claude/statusline.sh",
                  "verify_config": "jq .statusLine .claude/settings.json"
                }
              </code>
            </solution>
          </solution-examples>
        </issue>

        <issue id="json-parsing-errors" frequency="medium" complexity="2">
          <symptoms>
            <symptom>Status line shows error messages or blank output</symptom>
            <symptom>jq command not found or JSON parsing failures</symptom>
          </symptoms>
          <solution-examples>
            <solution scenario="install-jq">
              <code format="bash">
                {
                  "ubuntu_debian": "sudo apt-get install jq",
                  "macos": "brew install jq",
                  "test_jq": "echo '{\"test\":\"value\"}' | jq -r '.test'",
                  "alternative_parsing": "use python -c \"import json,sys; print(json.load(sys.stdin)['field'])\""
                }
              </code>
            </solution>
          </solution-examples>
        </issue>
      </common-issues>
    </problem-category>
  </troubleshooting>

  <source-validation>
    <official-reference>Anthropic Claude Code Documentation</official-reference>
    <source-file>en_docs_claude-code_statusline.md</source-file>
    <conversion-date>2025-08-24</conversion-date>
    <preservation-guarantee>complete_content_preservation</preservation-guarantee>
    <enhancement-type>mod_format_optimization</enhancement-type>
    <validation-method>direct_source_embedding</validation-method>
  </source-validation>

  <conclusion>
    <authoritative-status>
      This MOD nugget contains complete, unmodified official Anthropic Claude Code statusline documentation with MOD format optimization for enhanced LLM consumption and cognitive automation integration. Zero information loss from original source with comprehensive implementation guidance.
    </authoritative-status>
  </conclusion>
</document>