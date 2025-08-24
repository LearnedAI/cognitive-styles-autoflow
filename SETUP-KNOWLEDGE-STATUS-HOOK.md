# Setup Knowledge Status SessionStart Hook

## Automatic Setup via Claude Code UI

1. **Open Hooks Configuration**
   ```bash
   /hooks
   ```

2. **Select SessionStart Hook Event**
   - Choose `SessionStart` from the hook events list

3. **Add Matcher**
   - Select `+ Add new matcher…`
   - Enter: `startup`

4. **Add Hook Command** 
   - Select `+ Add new hook…`
   - Enter: `/mnt/c/Users/Learn/Greenfield/session-startup-knowledge-hook.sh`

5. **Set Storage Location**
   - Select `User settings` (applies to all projects)
   - This saves to `~/.claude/settings.json`

6. **Save Configuration**
   - Press Esc to return to REPL
   - Hook is now registered and will trigger on next session startup

## Manual Configuration

Alternatively, add this directly to `~/.claude/settings.json`:

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup", 
        "hooks": [
          {
            "type": "command",
            "command": "/mnt/c/Users/Learn/Greenfield/session-startup-knowledge-hook.sh",
            "timeout": 10
          }
        ]
      }
    ]
  }
}
```

## Verification

Run `/hooks` to verify configuration shows:
- SessionStart event configured
- startup matcher active  
- Command pointing to hook script

## Expected Behavior

On next Claude Code session startup, you'll see:
- Knowledge status table automatically displayed
- System capabilities overview  
- Auto-loaded nugget summary
- Additional context injected into Claude's session

## Nugget Loading Strategy

- **Auto-loaded (11 nuggets)**: Essential Claude Code functionality
- **On-demand (6 nuggets)**: Specialized features loaded when relevant
- **Rare-use (11 nuggets)**: Enterprise features loaded on explicit request

This provides immediate expert-level context while optimizing context window usage.