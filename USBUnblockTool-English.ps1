<#
.SYNOPSIS
    Detects processes blocking USB/External Drive ejection.
    Based on Windows Event Log (Kernel-PnP Event ID 225).

.DESCRIPTION
    Run this script after a failed ejection attempt.
    It scans for the most recent "ejection failed" system logs to identify 
    the process name and PID holding the device.

.NOTES
    Requires Administrator privileges to read system logs.
#>

<#
    Auto-request Administrator privileges.
    Without this, double-clicking runs as a standard user, preventing access to logs and process paths.
#>
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
if (-not $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    # Get the full path of the current script
    $scriptPath = $MyInvocation.MyCommand.Definition
    
    # Restart PowerShell with -Verb RunAs to request Admin rights
    Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`"" -Verb RunAs
    
    # Close the current non-admin window
    Exit
}

# Set console encoding to UTF-8 to ensure characters display correctly
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host "      USB Blocker Detector (Event Logs)   " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan
Write-Host ""

# User Instructions
Write-Host "⚠️  NOTE: This tool relies on the system's ejection failure record." -ForegroundColor Yellow
Write-Host "1. Try to eject the USB device via the system tray first."
Write-Host "2. Wait for the Windows 'Device is currently in use' error."
Write-Host "3. Press any key here to start scanning..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

Write-Host "`nScanning system logs..." -ForegroundColor Green

try {
    # Get the last 5 Kernel-PnP Event ID 225 (Device could not be removed)
    # Event ID 225: The application X stopped the removal or ejection for the device Y.
    $events = Get-WinEvent -FilterHashtable @{
        LogName = 'System'
        ProviderName = 'Microsoft-Windows-Kernel-PnP'
        ID = 225
    } -ErrorAction Stop -MaxEvents 5

    if ($events) {
        $found = $false
        
        foreach ($evt in $events) {
            # Check event time, only look at the last 5 minutes to avoid old data
            if ($evt.TimeCreated -gt (Get-Date).AddMinutes(-5)) {
                $found = $true
                $msg = $evt.Message
                
                # Regex to extract Process ID (PID)
                # Typical msg: The application X with process id 1234 stopped the removal...
                
                Write-Host "------------------------------------------"
                Write-Host "Time Found : $($evt.TimeCreated.ToString('HH:mm:ss'))" -ForegroundColor White
                
                # Try to extract PID
                if ($msg -match "process id (\d+)") {
                    $pidValue = $matches[1]
                    
                    # Try to get current process status
                    try {
                        # Using FileVersionInfo as per your previous code to get the path
                        $proc = Get-Process -Id $pidValue -FileVersionInfo -ErrorAction SilentlyContinue
                        if ($proc) {
                            Write-Host "Blocking App: $($proc.FileName)" -ForegroundColor Red
                            Write-Host "Process PID : $pidValue" -ForegroundColor Yellow
                            # Note: FileVersionInfo objects don't always have MainWindowTitle, 
                            # strictly speaking, but keeping your logic intact:
                            Write-Host "Window Title: $($proc.MainWindowTitle)" 
                            
                            # Ask to kill process
                            Write-Host "`nDo you want to force kill this process? (Not recommended) (Y/N)" -NoNewline
                            $response = Read-Host
                            if ($response -eq 'Y' -or $response -eq 'y') {
                                Stop-Process -Id $pidValue -Force
                                Write-Host "Process terminated! Please try ejecting again." -ForegroundColor Green
                            }
                        } else {
                            Write-Host "Blocking process (PID: $pidValue) seems to have closed itself." -ForegroundColor Gray
                        }
                    } catch {
                        Write-Host "Could not get details for PID $pidValue." -ForegroundColor Red
                    }
                } else {
                    # If regex fails, show original message
                    Write-Host "Log Details: $msg" -ForegroundColor Gray
                }
            }
        }

        if (-not $found) {
            Write-Host "❌ No 'Ejection Failed' records found in the last 5 minutes." -ForegroundColor Red
            Write-Host "Possible cause: You haven't clicked 'Eject' yet, or the system didn't log the event."
        }
    }
}
catch {
    Write-Host "❌ No relevant logs found or permission denied." -ForegroundColor Red
    Write-Host "Please ensure you are running this script as Administrator." -ForegroundColor Yellow
}

Write-Host "`nScan finished. Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")