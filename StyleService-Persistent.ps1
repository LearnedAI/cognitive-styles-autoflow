# Claude Code Persistent Service - No Job Dependencies
# Direct process execution with comprehensive logging
# Solves coordination bug by ensuring service persistence

param(
    [string]$SignalPath = "C:\Users\Learn\Greenfield\style-signals",
    [string]$TimingProfile = "Balanced", # Conservative, Balanced, Aggressive
    [string]$LogPath = "C:\Users\Learn\Greenfield\service.log"
)

# Create signals and log directories
@($SignalPath, (Split-Path $LogPath)) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
    }
}

function Write-ServiceLog {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage
    $logMessage | Out-File -FilePath $LogPath -Append
}

Write-ServiceLog "=== Claude Persistent Service Starting ===" "SYSTEM"
Write-ServiceLog "Signal Path: $SignalPath"
Write-ServiceLog "Timing Profile: $TimingProfile"
Write-ServiceLog "Log Path: $LogPath"
Write-ServiceLog "Features: Persistent execution + Coordination logging + No job dependencies"

# Add Windows Forms for SendKeys
Add-Type -AssemblyName System.Windows.Forms

# Add Win32 API for window focus
Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class Win32 {
        [DllImport("user32.dll")]
        public static extern bool SetForegroundWindow(IntPtr hWnd);
        
        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
        
        [DllImport("user32.dll")]
        public static extern IntPtr GetForegroundWindow();
    }
"@

# Service state variables
$processedCount = 0
$startupTime = Get-Date
$lastHealthCheck = Get-Date

# Lock file definitions with health tracking
$globalLock = "$SignalPath\.global-lock"
$coordinationLock = "$SignalPath\.coordination-lock"
$servicePid = "$SignalPath\.service-pid"

# RACE CONDITION PREVENTION: Check for existing service instance
if (Test-Path $servicePid) {
    $existingPid = Get-Content $servicePid -Raw -ErrorAction SilentlyContinue
    if ($existingPid) {
        $existingProcess = Get-Process -Id $existingPid -ErrorAction SilentlyContinue
        if ($existingProcess -and $existingProcess.ProcessName -eq "powershell") {
            Write-ServiceLog "ERROR: Service already running with PID $existingPid" "ERROR"
            Write-ServiceLog "Terminating to prevent duplicate service instances" "ERROR"
            exit 1
        } else {
            Write-ServiceLog "Stale PID file found, removing..." "WARN"
            Remove-Item $servicePid -Force -ErrorAction SilentlyContinue
        }
    }
}

# Write service PID for monitoring
$PID | Out-File -FilePath $servicePid -NoNewline
Write-ServiceLog "Service PID: $PID registered"

# OPTIMIZED TIMING: 1.5x original values (50% increase) for race prevention
$timingProfiles = @{
    "Conservative" = @{
        "focus_wait" = 450       # 1.5x original (300ms)
        "mode_switch" = 900      # 1.5x original (600ms)
        "style_wait" = 2250      # 1.5x original (1500ms) - key timing
        "coordination_delay" = 1200  # 1.5x original (800ms) - key timing
        "continuation_wait" = 450    # 1.5x original (300ms)
        "verification_wait" = 750    # 1.5x original (500ms)
    }
    "Balanced" = @{
        "focus_wait" = 300       # 1.5x original (200ms)
        "mode_switch" = 750      # 1.5x original (500ms)
        "style_wait" = 2250      # 1.5x original (1500ms) - key timing
        "coordination_delay" = 1200  # 1.5x original (800ms) - key timing
        "continuation_wait" = 300    # 1.5x original (200ms)
        "verification_wait" = 600    # 1.5x original (400ms)
    }
    "Aggressive" = @{
        "focus_wait" = 225       # 1.5x original (150ms)
        "mode_switch" = 600      # 1.5x original (400ms)
        "style_wait" = 1800      # 1.5x original (1200ms) - key timing
        "coordination_delay" = 900   # 1.5x original (600ms) - key timing
        "continuation_wait" = 225    # 1.5x original (150ms)
        "verification_wait" = 450    # 1.5x original (300ms)
    }
}

$currentTiming = $timingProfiles[$TimingProfile]

# Mode state management
$modeStateFile = "$SignalPath\.mode-state"

function Initialize-ModeState {
    if (-not (Test-Path $modeStateFile)) {
        Write-ServiceLog "Initializing mode state file (Mode 0 - Normal)"
        "0" | Out-File -FilePath $modeStateFile -NoNewline
    }
}

function Get-CurrentMode {
    if (Test-Path $modeStateFile) {
        $mode = Get-Content $modeStateFile -Raw
        $modeNum = [int]$mode.Trim()
        if ($modeNum -ge 0 -and $modeNum -le 3) {
            return $modeNum
        }
    }
    
    Write-ServiceLog "Invalid mode state, resetting to Mode 0" "WARN"
    "0" | Out-File -FilePath $modeStateFile -NoNewline
    return 0
}

function Set-CurrentMode {
    param([int]$Mode)
    
    if ($Mode -lt 0 -or $Mode -gt 3) {
        Write-ServiceLog "Invalid mode: $Mode. Must be 0, 1, 2, or 3" "ERROR"
        return
    }
    
    "$Mode" | Out-File -FilePath $modeStateFile -NoNewline
    
    $modeNames = @("Normal", "Accept Edits", "Plan Mode", "Bypass Permissions")
    Write-ServiceLog "Mode state updated to $Mode ($($modeNames[$Mode]))"
}

function Get-CoordinatedMode {
    param([string]$Style)
    
    $styleModePairs = @{
        "think" = 2      # Think style → Plan Mode (deep cognitive work)
        "plan" = 2       # Plan style → Plan Mode (strategic architecture)
        "build" = 3      # Build style → Bypass Permissions Mode (full implementation)
        "explore" = 0    # Explore style → Normal Mode (broad discovery)
        "test" = 1       # Test style → Accept Edits Mode (validation)
        "review" = 0     # Review style → Normal Mode (analysis)
    }
    
    if ($styleModePairs.ContainsKey($Style.ToLower())) {
        $mode = $styleModePairs[$Style.ToLower()]
        $modeNames = @("Normal", "Accept Edits", "Plan Mode", "Bypass Permissions")
        Write-ServiceLog "COORDINATION: Style '$Style' requires Mode $mode ($($modeNames[$mode]))"
        return $mode
    }
    
    Write-ServiceLog "No coordination for style '$Style', keeping current mode" "WARN"
    return -1
}

function Focus-WindowsTerminal {
    Write-ServiceLog "Focusing Windows Terminal..." "DEBUG"
    
    $windowsTerminal = Get-Process | Where-Object { 
        $_.ProcessName -eq "WindowsTerminal" -and $_.MainWindowTitle -ne ""
    } | Select-Object -First 1

    if (-not $windowsTerminal) {
        Write-ServiceLog "Windows Terminal not found" "ERROR"
        return $false
    }

    Write-ServiceLog "Found Windows Terminal: PID $($windowsTerminal.Id), Title: $($windowsTerminal.MainWindowTitle)" "DEBUG"
    
    $windowHandle = $windowsTerminal.MainWindowHandle
    [Win32]::ShowWindow($windowHandle, 9) # SW_RESTORE
    [Win32]::SetForegroundWindow($windowHandle)
    
    Start-Sleep -Milliseconds $currentTiming.focus_wait
    Write-ServiceLog "Windows Terminal focused successfully" "DEBUG"
    return $true
}

function Switch-ToMode {
    param([int]$TargetMode)
    
    $currentMode = Get-CurrentMode
    $modeNames = @("Normal", "Accept Edits", "Plan Mode", "Bypass Permissions")
    
    Write-ServiceLog "MODE SWITCHING: From $currentMode ($($modeNames[$currentMode])) to $TargetMode ($($modeNames[$TargetMode]))"
    
    # Calculate steps needed (circular: 0→1→2→3→0)
    $stepsNeeded = ($TargetMode - $currentMode + 4) % 4
    
    if ($stepsNeeded -eq 0) {
        Write-ServiceLog "Already in target mode $TargetMode" "DEBUG"
        return $true
    }
    
    Write-ServiceLog "COORDINATION: Need $stepsNeeded Shift+Tab steps to reach Mode $TargetMode"
    
    if (-not (Focus-WindowsTerminal)) {
        return $false
    }
    
    # Send Shift+Tab for each step needed
    for ($i = 0; $i -lt $stepsNeeded; $i++) {
        Write-ServiceLog "SENDING: Shift+Tab (step $($i+1) of $stepsNeeded)"
        [System.Windows.Forms.SendKeys]::SendWait("+{TAB}")
        
        # Update mode counter after each step
        $currentMode = ($currentMode + 1) % 4
        Set-CurrentMode -Mode $currentMode
        
        # Wait between mode switches
        if ($i -lt ($stepsNeeded - 1)) {
            Start-Sleep -Milliseconds $currentTiming.mode_switch
        }
    }
    
    Write-ServiceLog "MODE SWITCHING COMPLETED: Now in Mode $TargetMode ($($modeNames[$TargetMode]))" "SUCCESS"
    return $true
}

function Send-SlashCommand {
    param(
        [string]$Command,
        [string]$LogContext = "SLASH COMMAND"
    )
    
    Write-ServiceLog "$LogContext`: Sending $Command"
    
    if (-not (Focus-WindowsTerminal)) {
        return $false
    }
    
    # ENHANCED CLIPBOARD SAFETY: Multiple clears and longer waits
    [System.Windows.Forms.Clipboard]::Clear()
    Start-Sleep -Milliseconds 100
    [System.Windows.Forms.Clipboard]::Clear()
    Start-Sleep -Milliseconds 50
    
    try {
        [System.Windows.Forms.Clipboard]::SetText($Command)
        Write-ServiceLog "Clipboard set to: $Command"
        
        Start-Sleep -Milliseconds 100
        
        [System.Windows.Forms.SendKeys]::SendWait("^v")
        Write-ServiceLog "Command pasted via Ctrl+V"
        
        Start-Sleep -Milliseconds 100
        [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
        Write-ServiceLog "Enter key sent - command executed"
        
        # IMPORTANT: Clear clipboard after use to prevent contamination
        Start-Sleep -Milliseconds 100
        [System.Windows.Forms.Clipboard]::Clear()
        
        Write-ServiceLog "$LogContext SENT: $Command" "SUCCESS"
        return $true
    }
    catch {
        Write-ServiceLog "Failed to send slash command '$Command': $($_.Exception.Message)" "ERROR"
        return $false
    }
    finally {
        # Ensure clipboard is cleared even on error
        try {
            [System.Windows.Forms.Clipboard]::Clear()
        }
        catch {
            Write-ServiceLog "Warning: Could not clear clipboard" "WARN"
        }
    }
}

function Send-StyleCommand {
    param([string]$Style)
    
    $command = "/output-style $Style"
    return Send-SlashCommand -Command $command -LogContext "STYLE COMMAND"
}

function Send-ContinuationCommand {
    Write-ServiceLog "CONTINUATION: Sending 'continue with next step'"
    
    Start-Sleep -Milliseconds $currentTiming.coordination_delay
    
    if (-not (Focus-WindowsTerminal)) {
        return $false
    }
    
    $continueCommand = "continue with next step"
    
    # ENHANCED CLIPBOARD SAFETY: Multiple clears and longer waits
    [System.Windows.Forms.Clipboard]::Clear()
    Start-Sleep -Milliseconds 100
    [System.Windows.Forms.Clipboard]::Clear()
    Start-Sleep -Milliseconds 50
    
    [System.Windows.Forms.Clipboard]::SetText($continueCommand)
    Start-Sleep -Milliseconds 100
    
    [System.Windows.Forms.SendKeys]::SendWait("^v")
    Start-Sleep -Milliseconds 100
    [System.Windows.Forms.SendKeys]::SendWait("{ENTER}")
    
    # IMPORTANT: Clear clipboard after use to prevent contamination
    Start-Sleep -Milliseconds 100
    [System.Windows.Forms.Clipboard]::Clear()
    
    Write-ServiceLog "CONTINUATION SENT: $continueCommand" "SUCCESS"
    return $true
}

function Execute-CoordinatedWorkflow {
    param([string]$Style)
    
    $startTime = Get-Date
    Write-ServiceLog "=== COORDINATED WORKFLOW START: $Style ===" "SYSTEM"
    
    try {
        # Acquire coordination lock
        if (Test-Path $coordinationLock) {
            Write-ServiceLog "Coordination already in progress, waiting..." "WARN"
            return $false
        }
        
        "WORKFLOW-$Style-$(Get-Date -Format 'HHmmss')" | Out-File $coordinationLock
        Write-ServiceLog "Coordination lock acquired for $Style"
        
        # Step 1: Determine coordinated mode
        $targetMode = Get-CoordinatedMode -Style $Style
        
        if ($targetMode -ne -1) {
            Write-ServiceLog "STEP 1: Mode coordination required - switching to Mode $targetMode"
            if (-not (Switch-ToMode -TargetMode $targetMode)) {
                Write-ServiceLog "Mode switching failed" "ERROR"
                return $false
            }
            
            # Verification wait
            Start-Sleep -Milliseconds $currentTiming.verification_wait
        } else {
            Write-ServiceLog "STEP 1: No mode coordination needed"
        }
        
        # Step 2: Send style command
        Write-ServiceLog "STEP 2: Sending style command"
        if (-not (Send-StyleCommand -Style $Style)) {
            Write-ServiceLog "Style command failed" "ERROR"
            return $false
        }
        
        # Wait for style processing
        Start-Sleep -Milliseconds $currentTiming.style_wait
        
        # Step 3: Send continuation
        Write-ServiceLog "STEP 3: Sending continuation command"
        if (-not (Send-ContinuationCommand)) {
            Write-ServiceLog "Continuation command failed" "ERROR"
            return $false
        }
        
        $endTime = Get-Date
        $totalTime = ($endTime - $startTime).TotalMilliseconds
        $script:processedCount++
        
        Write-ServiceLog "=== COORDINATED WORKFLOW COMPLETED: $Style in ${totalTime}ms (#$script:processedCount) ===" "SUCCESS"
        return $true
    }
    finally {
        Remove-Item $coordinationLock -Force -ErrorAction SilentlyContinue
        Write-ServiceLog "Coordination lock released"
    }
}

function Get-CommandType {
    param([string]$SignalName)
    
    # Define command mappings
    $cognitiveStyles = @("think", "plan", "build", "explore", "test", "review", "mapper")
    $builtinSlashCommands = @("context", "help", "prime", "compact")
    $modeCommands = @("normal-mode", "accept-mode", "plan-mode", "bypass-mode", "check-mode", "reset-mode")
    
    if ($SignalName -in $cognitiveStyles) {
        return @{
            Type = "cognitive-style"
            Command = "/output-style $SignalName"
            Handler = "Execute-CoordinatedWorkflow"
        }
    }
    elseif ($SignalName -in $builtinSlashCommands) {
        return @{
            Type = "builtin-slash-command"
            Command = "/$SignalName"
            Handler = "Execute-SlashCommand"
        }
    }
    elseif ($SignalName -in $modeCommands) {
        return @{
            Type = "mode-command"
            Command = $SignalName
            Handler = "Execute-ModeCommand"
        }
    }
    elseif ($SignalName.StartsWith("/")) {
        # Direct slash command
        return @{
            Type = "direct-slash-command"
            Command = $SignalName
            Handler = "Execute-SlashCommand"
        }
    }
    else {
        return @{
            Type = "unknown"
            Command = $SignalName
            Handler = $null
        }
    }
}

function Execute-UniversalCommand {
    param([string]$SignalName)
    
    Write-ServiceLog "SIMPLE COMMAND PROCESSING: '$SignalName'"
    
    # Simple hardcoded replacements - much easier!
    if ($SignalName -eq "context") {
        Write-ServiceLog "EXECUTING: /context command"
        return Send-SlashCommand -Command "/context" -LogContext "CONTEXT COMMAND"
    }
    elseif ($SignalName -eq "help") {
        Write-ServiceLog "EXECUTING: /help command" 
        return Send-SlashCommand -Command "/help" -LogContext "HELP COMMAND"
    }
    elseif ($SignalName -eq "prime") {
        Write-ServiceLog "EXECUTING: /prime command"
        return Send-SlashCommand -Command "/prime" -LogContext "PRIME COMMAND"
    }
    elseif ($SignalName -eq "compact") {
        Write-ServiceLog "EXECUTING: /compact command"
        return Send-SlashCommand -Command "/compact" -LogContext "COMPACT COMMAND"
    }
    elseif ($SignalName -in @("think", "plan", "build", "explore", "test", "review", "mapper")) {
        Write-ServiceLog "EXECUTING: Coordinated workflow for '$SignalName'"
        return Execute-CoordinatedWorkflow -Style $SignalName
    }
    else {
        Write-ServiceLog "UNKNOWN COMMAND: '$SignalName'" "WARN"
        return $false
    }
}

function Parse-SignalContent {
    param(
        [string]$Content,
        [string]$SignalName
    )
    
    $Content = $Content.Trim()
    Write-ServiceLog "PARSING: '$Content' from signal '$SignalName'"
    
    # Parse based on signal content format
    if ($Content -like "Style change request:*") {
        # Extract: "Style change request: build" → "build"
        $command = $Content -replace "Style change request:\s*", ""
        Write-ServiceLog "PARSED as cognitive style: '$command'"
        return $command.Trim()
    }
    elseif ($Content -like "Builtin slash command:*") {
        # Extract: "Builtin slash command: context" → "context" 
        $command = $Content -replace "Builtin slash command:\s*", ""
        Write-ServiceLog "PARSED as builtin slash command: '$command'"
        return $command.Trim()
    }
    elseif ($Content -like "Direct slash command:*") {
        # Extract: "Direct slash command: /help" → "/help"
        $command = $Content -replace "Direct slash command:\s*", ""
        Write-ServiceLog "PARSED as direct slash command: '$command'"
        return $command.Trim()
    }
    elseif ($Content -like "Mode change request:*") {
        # Extract: "Mode change request: normal-mode" → "normal-mode"
        $command = $Content -replace "Mode change request:\s*", ""
        Write-ServiceLog "PARSED as mode command: '$command'"
        return $command.Trim()
    }
    else {
        # Fallback to signal filename
        Write-ServiceLog "PARSED as fallback (unknown format): '$SignalName'" "WARN"
        return $SignalName
    }
}

function Execute-ContextCommand {
    return Send-SlashCommand -Command "/context" -LogContext "CONTEXT COMMAND"
}

function Process-Signals {
    # RACE CONDITION PREVENTION: Use global lock for entire signal processing
    if (Test-Path $globalLock) {
        Write-ServiceLog "Global signal processing in progress, skipping cycle" "DEBUG"
        return
    }
    
    try {
        # Acquire global lock BEFORE scanning for signals
        "SIGNAL-PROCESSING-$(Get-Date -Format 'HHmmss.fff')" | Out-File $globalLock
        Write-ServiceLog "Global signal lock acquired"
        
        # Scan for signals after acquiring lock
        $signalFiles = Get-ChildItem -Path $SignalPath -Filter "*.signal" -ErrorAction SilentlyContinue
        
        if ($signalFiles.Count -eq 0) {
            return
        }
        
        Write-ServiceLog "Found $($signalFiles.Count) signal file(s) to process"
        
        foreach ($file in $signalFiles) {
            $signalName = $file.BaseName
            Write-ServiceLog "Processing signal: '$signalName'"
            
            try {
                # ATOMIC OPERATION: Move signal to processing directory to prevent re-processing
                $processedDir = "$SignalPath\processed"
                if (-not (Test-Path $processedDir)) {
                    New-Item -ItemType Directory -Path $processedDir -Force | Out-Null
                }
                
                $processedFile = "$processedDir\$($file.Name).$(Get-Date -Format 'HHmmss')"
                Move-Item $file.FullName $processedFile -Force
                Write-ServiceLog "Signal moved to: $processedFile"
                
                # Use simple command processing based on signal filename
                Execute-UniversalCommand -SignalName $signalName
            }
            catch {
                Write-ServiceLog "Failed to process signal '$signalName': $($_.Exception.Message)" "ERROR"
            }
        }
    }
    finally {
        # Release global lock
        Remove-Item $globalLock -Force -ErrorAction SilentlyContinue
        Write-ServiceLog "Global signal lock released"
    }
}

function Show-ServiceHealth {
    $uptime = (Get-Date) - $startupTime
    $currentMode = Get-CurrentMode
    $modeNames = @("Normal", "Accept Edits", "Plan Mode", "Bypass Permissions")
    $queueSize = (Get-ChildItem -Path $SignalPath -Filter "*.signal" -ErrorAction SilentlyContinue).Count
    
    $healthMessage = "HEALTH: Uptime $($uptime.ToString('hh\:mm\:ss')), Processed: $processedCount, Mode: $currentMode ($($modeNames[$currentMode])), Queue: $queueSize"
    Write-ServiceLog $healthMessage "HEALTH"
}

# Initialize service
Initialize-ModeState
Write-ServiceLog "=== PERSISTENT SERVICE INITIALIZED ===" "SYSTEM"
Write-ServiceLog "Timing: Focus=$($currentTiming.focus_wait)ms, Mode=$($currentTiming.mode_switch)ms, Style=$($currentTiming.style_wait)ms"
Show-ServiceHealth

Write-ServiceLog "Entering main service loop..."

# Main service loop - no job dependencies
try {
    while ($true) {
        try {
            # Process signals
            Process-Signals
            
            # Periodic health check (every 5 minutes)
            if (((Get-Date) - $lastHealthCheck).TotalMinutes -ge 5) {
                Show-ServiceHealth
                $lastHealthCheck = Get-Date
            }
            
            # RACE CONDITION PREVENTION: Monitor for signals every 1000ms (prevents overlapping executions)
            Start-Sleep -Milliseconds 1000
            
        } catch {
            Write-ServiceLog "Service loop error: $($_.Exception.Message)" "ERROR"
            Start-Sleep -Seconds 1
        }
    }
}
finally {
    Write-ServiceLog "=== SERVICE SHUTDOWN ===" "SYSTEM"
    Remove-Item $servicePid -Force -ErrorAction SilentlyContinue
}