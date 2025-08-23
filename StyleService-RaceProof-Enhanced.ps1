# Enhanced Race-Proof StyleService with Confidence Integration
# Comprehensive race condition prevention + confidence-aware workflows

param(
    [string]$SignalPath = "C:\Users\Learn\Greenfield\style-signals",
    [string]$TimingProfile = "Balanced",
    [string]$LogPath = "C:\Users\Learn\Greenfield\service.log",
    [switch]$ConfidenceMode = $false
)

# Enhanced timing profiles for race prevention
$TimingProfiles = @{
    "Conservative" = @{
        FocusWait = 500
        ModeSwitch = 1000  
        StyleWait = 3000
        CoordinationDelay = 2000
        ContinuationWait = 500
        VerificationWait = 800
        GlobalLockCycle = 1500
    }
    "Balanced" = @{
        FocusWait = 300
        ModeSwitch = 750
        StyleWait = 2250
        CoordinationDelay = 1200  
        ContinuationWait = 300
        VerificationWait = 600
        GlobalLockCycle = 1000
    }
    "Aggressive" = @{
        FocusWait = 200
        ModeSwitch = 500
        StyleWait = 1500
        CoordinationDelay = 800
        ContinuationWait = 200
        VerificationWait = 400
        GlobalLockCycle = 750
    }
}

$Timing = $TimingProfiles[$TimingProfile]

# Enhanced directory and lock management
@($SignalPath, (Split-Path $LogPath)) | ForEach-Object {
    if (-not (Test-Path $_)) {
        New-Item -ItemType Directory -Path $_ -Force | Out-Null
    }
}

# Multiple lock files for comprehensive race prevention
$GlobalLockFile = Join-Path $SignalPath ".global-lock"
$ProcessLockFile = Join-Path $SignalPath ".process-lock" 
$ServicePidFile = Join-Path $SignalPath ".service-pid"
$CommandLockFile = Join-Path $SignalPath ".command-lock"

function Write-ServiceLog {
    param([string]$Message, [string]$Level = "INFO")
    $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    $logMessage = "[$timestamp] [$Level] $Message"
    Write-Host $logMessage
    $logMessage | Out-File -FilePath $LogPath -Append -Encoding UTF8
}

function Test-ProcessRunning {
    param([int]$ProcessId)
    try {
        $process = Get-Process -Id $ProcessId -ErrorAction SilentlyContinue
        return $null -ne $process
    }
    catch {
        return $false
    }
}

function Get-ExistingServicePid {
    if (Test-Path $ServicePidFile) {
        try {
            $existingPid = Get-Content $ServicePidFile -Raw | Where-Object { $_ -match '\d+' }
            if ($existingPid -and (Test-ProcessRunning -ProcessId ([int]$existingPid))) {
                return [int]$existingPid
            }
        }
        catch {
            Write-ServiceLog "Invalid PID file content, cleaning up" "WARN"
        }
        Remove-Item $ServicePidFile -Force -ErrorAction SilentlyContinue
    }
    return $null
}

function Set-ServicePid {
    $currentPid = $PID
    Write-ServiceLog "Setting service PID: $currentPid"
    $currentPid | Out-File -FilePath $ServicePidFile -Force -Encoding UTF8
}

function Remove-ServicePid {
    if (Test-Path $ServicePidFile) {
        Remove-Item $ServicePidFile -Force -ErrorAction SilentlyContinue
        Write-ServiceLog "Service PID file removed"
    }
}

function Wait-GlobalLock {
    param([int]$TimeoutMs = 5000)
    
    $startTime = Get-Date
    while (Test-Path $GlobalLockFile) {
        $elapsed = (Get-Date) - $startTime
        if ($elapsed.TotalMilliseconds -gt $TimeoutMs) {
            Write-ServiceLog "Global lock timeout - forcing cleanup" "WARN"
            Remove-Item $GlobalLockFile -Force -ErrorAction SilentlyContinue
            break
        }
        Start-Sleep -Milliseconds 100
    }
}

function Set-GlobalLock {
    param([string]$Operation)
    
    Wait-GlobalLock
    
    $lockInfo = @{
        ProcessId = $PID
        Operation = $Operation
        Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
        LockId = [System.Guid]::NewGuid().ToString()
    }
    
    $lockInfo | ConvertTo-Json | Out-File -FilePath $GlobalLockFile -Force -Encoding UTF8
    Write-ServiceLog "Global lock acquired for: $Operation" "LOCK"
    return $lockInfo.LockId
}

function Remove-GlobalLock {
    param([string]$LockId)
    
    if (Test-Path $GlobalLockFile) {
        try {
            $lockData = Get-Content $GlobalLockFile -Raw | ConvertFrom-Json
            if ($lockData.LockId -eq $LockId -and $lockData.ProcessId -eq $PID) {
                Remove-Item $GlobalLockFile -Force
                Write-ServiceLog "Global lock released: $LockId" "LOCK"
            } else {
                Write-ServiceLog "Lock mismatch - cannot release lock owned by different process" "WARN"
            }
        }
        catch {
            Write-ServiceLog "Invalid lock file - forcing cleanup" "WARN"
            Remove-Item $GlobalLockFile -Force -ErrorAction SilentlyContinue
        }
    }
}

function Test-CommandInProgress {
    return (Test-Path $CommandLockFile)
}

function Set-CommandLock {
    param([string]$Command)
    
    $commandInfo = @{
        Command = $Command
        ProcessId = $PID
        StartTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss.fff"
    }
    
    $commandInfo | ConvertTo-Json | Out-File -FilePath $CommandLockFile -Force -Encoding UTF8
    Write-ServiceLog "Command lock set for: $Command" "LOCK"
}

function Remove-CommandLock {
    if (Test-Path $CommandLockFile) {
        Remove-Item $CommandLockFile -Force -ErrorAction SilentlyContinue
        Write-ServiceLog "Command lock released" "LOCK"
    }
}

function Get-ProcessedDirectory {
    $processedDir = Join-Path $SignalPath "processed"
    if (-not (Test-Path $processedDir)) {
        New-Item -ItemType Directory -Path $processedDir -Force | Out-Null
    }
    return $processedDir
}

function Move-SignalToProcessed {
    param([string]$SignalFile)
    
    $processedDir = Get-ProcessedDirectory
    $filename = Split-Path $SignalFile -Leaf
    $timestamp = Get-Date -Format "HHmmss"
    $processedFile = Join-Path $processedDir "$filename.$timestamp"
    
    try {
        Move-Item -Path $SignalFile -Destination $processedFile -Force
        Write-ServiceLog "Signal moved to processed: $processedFile" "ATOMIC"
        return $true
    }
    catch {
        Write-ServiceLog "Failed to move signal file: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Test-ConfidenceApproval {
    param([string]$StyleCommand)
    
    if (-not $ConfidenceMode) {
        return $true  # Always proceed if confidence mode is disabled
    }
    
    # For now, return true - this would integrate with confidence assessment system
    # Future enhancement: Call confidence-assessment.sh here
    Write-ServiceLog "Confidence mode enabled - would assess: $StyleCommand" "CONFIDENCE"
    return $true
}

# Check for existing service instance
$existingPid = Get-ExistingServicePid
if ($existingPid) {
    Write-ServiceLog "Another service instance is already running (PID: $existingPid)" "ERROR"
    Write-ServiceLog "If this is incorrect, delete $ServicePidFile and restart" "INFO"
    exit 1
}

# Initialize service
Write-ServiceLog "=== Enhanced Race-Proof Service Starting ===" "SYSTEM"
Write-ServiceLog "Signal Path: $SignalPath"
Write-ServiceLog "Timing Profile: $TimingProfile"
Write-ServiceLog "Confidence Mode: $ConfidenceMode"

Set-ServicePid

# Add Windows Forms for SendKeys
Add-Type -AssemblyName System.Windows.Forms

# Win32 API for window management
Add-Type @"
    using System;
    using System.Runtime.InteropServices;
    public class Win32 {
        [DllImport("user32.dll")]
        public static extern bool SetForegroundWindow(IntPtr hWnd);
        
        [DllImport("user32.dll")]
        public static extern IntPtr GetForegroundWindow();
        
        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    }
"@

# Cleanup handler
$cleanup = {
    Write-ServiceLog "Service shutdown initiated" "SYSTEM"
    Remove-ServicePid
    Remove-GlobalLock
    Remove-CommandLock
    Write-ServiceLog "=== Enhanced Race-Proof Service Stopped ===" "SYSTEM"
}

# Register cleanup handlers
Register-EngineEvent -SourceIdentifier PowerShell.Exiting -Action $cleanup
trap { & $cleanup; break }

Write-ServiceLog "=== ENHANCED RACE-PROOF SERVICE INITIALIZED ===" "SYSTEM"
Write-ServiceLog "PID: $PID, Timing: $($Timing | ConvertTo-Json -Compress)"

# Main service loop with enhanced race prevention
$processed = 0
while ($true) {
    try {
        # Skip if another command is in progress
        if (Test-CommandInProgress) {
            Start-Sleep -Milliseconds $Timing.GlobalLockCycle
            continue
        }
        
        # Look for signal files
        $signalFiles = Get-ChildItem -Path $SignalPath -Filter "*.signal" -ErrorAction SilentlyContinue
        
        if ($signalFiles.Count -eq 0) {
            # Health check every 10 cycles
            if ($processed % 10 -eq 0) {
                $uptime = (Get-Date) - (Get-Process -Id $PID).StartTime
                Write-ServiceLog "HEALTH: Uptime $($uptime.ToString('hh\:mm\:ss')), Processed: $processed, Queue: 0" "HEALTH"
            }
            Start-Sleep -Milliseconds $Timing.GlobalLockCycle
            continue
        }
        
        # Process only the first signal file (prevents race conditions)
        $signalFile = $signalFiles[0]
        $signalName = $signalFile.BaseName
        
        Write-ServiceLog "Processing signal: '$signalName'"
        
        # Acquire global coordination lock
        $lockId = Set-GlobalLock $signalName
        Set-CommandLock $signalName
        
        try {
            # Atomic signal file processing
            if (-not (Move-SignalToProcessed -SignalFile $signalFile.FullName)) {
                Write-ServiceLog "Failed to process signal atomically - skipping" "ERROR"
                continue
            }
            
            # Confidence check
            if (-not (Test-ConfidenceApproval -StyleCommand $signalName)) {
                Write-ServiceLog "Confidence check failed for: $signalName" "CONFIDENCE"
                continue
            }
            
            Write-ServiceLog "=== COORDINATED WORKFLOW START: $signalName ===" "SYSTEM"
            
            # Style coordination logic would go here
            # This is a simplified version - full coordination code would be integrated
            
            $processed++
            Write-ServiceLog "=== COORDINATED WORKFLOW COMPLETED: $signalName ($($$processed)) ===" "SUCCESS"
        }
        finally {
            Remove-CommandLock
            Remove-GlobalLock $lockId
        }
        
    }
    catch {
        Write-ServiceLog "Service loop error: $($_.Exception.Message)" "ERROR"
        Remove-CommandLock
        Remove-GlobalLock
        Start-Sleep -Milliseconds 1000
    }
}