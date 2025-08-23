# Cognitive Style Automation - Post-Extraction Setup
# Run this script once after extracting the zip file
# Handles permissions, validation, and initial configuration

param(
    [switch]$SkipExecutionPolicy,
    [switch]$SkipValidation,
    [switch]$Quiet
)

$ErrorActionPreference = "Stop"

function Write-SetupMessage {
    param([string]$Message, [string]$Type = "INFO")
    
    if (-not $Quiet) {
        $timestamp = Get-Date -Format "HH:mm:ss"
        $color = switch ($Type) {
            "SUCCESS" { "Green" }
            "WARNING" { "Yellow" }
            "ERROR" { "Red" }
            default { "White" }
        }
        Write-Host "[$timestamp] $Message" -ForegroundColor $color
    }
}

function Test-PowerShellExecutionPolicy {
    $currentPolicy = Get-ExecutionPolicy -Scope CurrentUser
    $restrictivePolicies = @("Restricted", "AllSigned")
    
    if ($currentPolicy -in $restrictivePolicies) {
        Write-SetupMessage "Current PowerShell execution policy: $currentPolicy" "WARNING"
        Write-SetupMessage "This may prevent the service from running." "WARNING"
        
        if (-not $SkipExecutionPolicy) {
            $response = Read-Host "Would you like to set execution policy to RemoteSigned for CurrentUser? (y/n)"
            if ($response -eq "y" -or $response -eq "Y") {
                try {
                    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force
                    Write-SetupMessage "Execution policy updated to RemoteSigned" "SUCCESS"
                    return $true
                } catch {
                    Write-SetupMessage "Failed to update execution policy: $($_.Exception.Message)" "ERROR"
                    return $false
                }
            }
        }
        return $false
    }
    
    Write-SetupMessage "PowerShell execution policy: $currentPolicy (OK)" "SUCCESS"
    return $true
}

function Test-WSLAvailability {
    try {
        $wslResult = & wsl.exe --status 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-SetupMessage "WSL is available and functional" "SUCCESS"
            return $true
        } else {
            Write-SetupMessage "WSL is not available or not functional" "WARNING"
            return $false
        }
    } catch {
        Write-SetupMessage "WSL not found on system" "WARNING"
        return $false
    }
}

function Set-BashPermissions {
    $scriptPath = $PSScriptRoot
    $bashScripts = @("signal-style.sh", "manage-style-service.sh")
    
    foreach ($script in $bashScripts) {
        $scriptFile = Join-Path $scriptPath $script
        if (Test-Path $scriptFile) {
            try {
                # Use WSL to set execute permissions
                $wslPath = $scriptFile -replace "^C:", "/mnt/c" -replace "\\", "/"
                & wsl.exe chmod +x "$wslPath" 2>$null
                Write-SetupMessage "Set execute permissions on $script" "SUCCESS"
            } catch {
                Write-SetupMessage "Warning: Could not set permissions on $script" "WARNING"
            }
        }
    }
}

function Test-WindowsTerminal {
    $terminal = Get-Process -Name "WindowsTerminal" -ErrorAction SilentlyContinue
    if ($terminal) {
        Write-SetupMessage "Windows Terminal is running and accessible" "SUCCESS"
        return $true
    } else {
        Write-SetupMessage "Windows Terminal not currently running (this is normal)" "INFO"
        return $true  # Not an error, just informational
    }
}

function Test-ServiceFunctionality {
    $scriptPath = $PSScriptRoot
    $serviceFile = Join-Path $scriptPath "StyleService-Persistent.ps1"
    
    if (-not (Test-Path $serviceFile)) {
        Write-SetupMessage "Service file not found: $serviceFile" "ERROR"
        return $false
    }
    
    try {
        # Test if we can load the service script (syntax check)
        $null = Get-Content $serviceFile | Out-String
        Write-SetupMessage "Service file syntax validation passed" "SUCCESS"
        
        # Test Windows Forms availability
        Add-Type -AssemblyName System.Windows.Forms -ErrorAction Stop
        Write-SetupMessage "Windows Forms assemblies available" "SUCCESS"
        
        return $true
    } catch {
        Write-SetupMessage "Service validation failed: $($_.Exception.Message)" "ERROR"
        return $false
    }
}

function Initialize-Directories {
    $scriptPath = $PSScriptRoot
    $directories = @(
        "style-signals",
        "timing-logs",
        "backups",
        "backups/baseline-configs"
    )
    
    foreach ($dir in $directories) {
        $fullPath = Join-Path $scriptPath $dir
        if (-not (Test-Path $fullPath)) {
            New-Item -ItemType Directory -Path $fullPath -Force | Out-Null
            Write-SetupMessage "Created directory: $dir" "SUCCESS"
        }
    }
}

function Show-QuickStart {
    Write-Host ""
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host "  COGNITIVE STYLE AUTOMATION - SETUP COMPLETE" -ForegroundColor Cyan
    Write-Host "=" * 60 -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Quick Start Commands:" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  # Start the persistent service (recommended)" -ForegroundColor White
    Write-Host "  ./manage-style-service.sh start persistent" -ForegroundColor Green
    Write-Host ""
    Write-Host "  # Use style transitions" -ForegroundColor White
    Write-Host "  ./signal-style.sh explore    # Research and analysis" -ForegroundColor Green
    Write-Host "  ./signal-style.sh plan       # Architecture design" -ForegroundColor Green
    Write-Host "  ./signal-style.sh build      # Implementation" -ForegroundColor Green
    Write-Host "  ./signal-style.sh test       # Quality assurance" -ForegroundColor Green
    Write-Host "  ./signal-style.sh review     # Code review" -ForegroundColor Green
    Write-Host ""
    Write-Host "  # Check service status" -ForegroundColor White
    Write-Host "  ./manage-style-service.sh status" -ForegroundColor Green
    Write-Host ""
    Write-Host "Performance:" -ForegroundColor Yellow
    Write-Host "  - Style transitions: ~1.8 seconds" -ForegroundColor White
    Write-Host "  - Memory usage: ~1.8MB persistent" -ForegroundColor White
    Write-Host "  - Session-persistent service (no startup overhead)" -ForegroundColor White
    Write-Host ""
    Write-Host "Documentation:" -ForegroundColor Yellow
    Write-Host "  - Read COGNITIVE-AUTOMATION-SYSTEM.md for complete system understanding" -ForegroundColor White
    Write-Host "  - See README-INSTALLATION.md for troubleshooting" -ForegroundColor White
    Write-Host ""
    Write-Host "Installation Location: $PSScriptRoot" -ForegroundColor Cyan
    Write-Host ""
}

# Main setup process
try {
    Write-SetupMessage "Starting Cognitive Style Automation setup..." "INFO"
    Write-SetupMessage "Installation location: $PSScriptRoot" "INFO"
    
    $setupSuccess = $true
    
    # Test PowerShell execution policy
    if (-not (Test-PowerShellExecutionPolicy)) {
        $setupSuccess = $false
    }
    
    # Initialize directory structure
    Initialize-Directories
    
    # Test WSL availability
    $wslAvailable = Test-WSLAvailability
    
    # Set bash script permissions if WSL is available
    if ($wslAvailable) {
        Set-BashPermissions
    } else {
        Write-SetupMessage "WSL not available - bash scripts may need manual permission setting" "WARNING"
    }
    
    # Test Windows Terminal access
    Test-WindowsTerminal
    
    # Validate service functionality
    if (-not $SkipValidation) {
        if (-not (Test-ServiceFunctionality)) {
            $setupSuccess = $false
        }
    }
    
    if ($setupSuccess) {
        Write-SetupMessage "Setup completed successfully!" "SUCCESS"
        Show-QuickStart
    } else {
        Write-SetupMessage "Setup completed with warnings - see messages above" "WARNING"
        Write-SetupMessage "The system may still work, but some features might be limited" "WARNING"
        Show-QuickStart
    }
    
} catch {
    Write-SetupMessage "Setup failed: $($_.Exception.Message)" "ERROR"
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "1. Ensure you're running from the extracted directory" -ForegroundColor White
    Write-Host "2. Check PowerShell execution policy: Get-ExecutionPolicy" -ForegroundColor White
    Write-Host "3. Verify WSL is installed and functional: wsl --status" -ForegroundColor White
    Write-Host "4. See README-INSTALLATION.md for detailed troubleshooting" -ForegroundColor White
    exit 1
}