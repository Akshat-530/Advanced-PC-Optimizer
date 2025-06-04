# Advanced PC Optimizer v2.0
# Created by: AKSHAT_530
# Link: https://linktr.ee/Akshat_530

# ===== COLOR SCHEME =====
$cleanupColor = "Cyan"
$maintColor = "Green"
$reportColor = "Magenta"
$tweakColor = "Yellow"
$exitColor = "Red"
$supportColor = "DarkCyan"

# ===== VERIFIED FUNCTIONS =====
function Clear-AdvancedCleanup {
    Write-Host "`n==== ADVANCED CLEANUP ==== " -ForegroundColor $cleanupColor
    $confirm = Read-Host "This will delete temporary files, prefetch, and empty the Recycle Bin. Continue? (Y/N)"
    if ($confirm -notmatch "^[Yy]$") {
        Write-Host "Advanced Cleanup canceled." -ForegroundColor Yellow
        Write-Progress -Activity "Advanced Cleanup" -Status "Canceled" -PercentComplete 100 -Completed
        return
    }

    $paths = @(
        "$env:SystemRoot\Temp\*",
        "$env:SystemRoot\Prefetch\*",
        "$env:TEMP\*",
        "$env:LOCALAPPDATA\Temp\*",
        "$env:SystemRoot\SoftwareDistribution\Download\*",
        "$env:SYSTEMDRIVE\$Recycle.Bin\*",
        "$env:LOCALAPPDATA\Microsoft\Windows\INetCache\*",
        "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\*.db",
        "$env:LOCALAPPDATA\CrashveloppementsDumps\*"
    )

    $totalItems = $paths.Count + 1 # +1 for Recycle Bin fallback
    $currentItem = 0

    foreach ($path in $paths) {
        $currentItem++
        Write-Progress -Activity "Advanced Cleanup" -Status "Cleaning $path" -PercentComplete (($currentItem / $totalItems) * 100)
        try {
            if (Test-Path $path) {
                Remove-Item $path -Recurse -Force -ErrorAction Stop
            }
        } catch {
            # Suppress errors
        }
        Start-Sleep -Milliseconds 100
    }

    Write-Progress -Activity "Advanced Cleanup" -Status "Emptying Recycle Bin" -PercentComplete (($currentItem / $totalItems) * 100)
    try {
        Clear-RecycleBin -Force -ErrorAction Stop
    } catch {
        try {
            $shell = New-Object -ComObject Shell.Application
            $recycleBin = $shell.Namespace(0xA)
            $items = $recycleBin.Items()
            if ($items.Count -gt 0) {
                $items | ForEach-Object { Remove-Item $_.Path -Recurse -Force -ErrorAction Stop }
            }
        } catch {
            # Suppress errors
        }
    }

    Write-Progress -Activity "Advanced Cleanup" -Status "Complete" -PercentComplete 100 -Completed
    Write-Host "`nCleanup Complete!" -ForegroundColor Green
}
function Run-DiskCleanupSystem {
    Write-Host "`n==== SYSTEM DISK CLEANUP ==== " -ForegroundColor $cleanupColor
    Write-Progress -Activity "System Disk Cleanup" -Status "Initializing" -PercentComplete 10
    try {
        $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
        if (-not (Test-Path "$regPath\Temporary Files")) {
            Write-Host "  No Disk Cleanup profile found. Please run 'cleanmgr /sageset:1' manually to configure it." -ForegroundColor Yellow
            Write-Progress -Activity "System Disk Cleanup" -Status "Canceled" -PercentComplete 100 -Completed
            return
        }
        Write-Progress -Activity "System Disk Cleanup" -Status "Running cleanmgr" -PercentComplete 50
        Start-Process cleanmgr.exe -ArgumentList "/sagerun:1" -Wait -ErrorAction Stop
        Write-Host "  Disk Cleanup executed with saved settings (sagerun:1)" -ForegroundColor Gray
        Write-Progress -Activity "System Disk Cleanup" -Status "Complete" -PercentComplete 100 -Completed
        Write-Host "`nDisk Cleanup Complete!" -ForegroundColor Green
    } catch {
        Write-Host "  Failed to run Disk Cleanup: $($_.Exception.Message)" -ForegroundColor Red
        Write-Progress -Activity "System Disk Cleanup" -Status "Failed" -PercentComplete 100 -Completed
    }
}

function Clear-ShaderCache {
    Write-Host "`n==== GPU SHADER CACHE ==== " -ForegroundColor $cleanupColor
    Write-Host "  Note: Clearing shader caches may cause temporary performance hiccups in games or GPU-intensive applications." -ForegroundColor Yellow
    Write-Progress -Activity "GPU Shader Cache" -Status "Detecting GPU drivers" -PercentComplete 10
    $gpuDrivers = Get-WmiObject Win32_VideoController | Select-Object -ExpandProperty Name
    $shaderPaths = @()
    if ($gpuDrivers -match "NVIDIA") {
        $shaderPaths += "$env:LOCALAPPDATA\NVIDIA\DXCache", "$env:ProgramData\NVIDIA Corporation\NV_Cache"
    }
    if ($gpuDrivers -match "AMD") {
        $shaderPaths += "$env:LOCALAPPDATA\AMD\DxCache"
    }
    if ($gpuDrivers -match "Intel") {
        $shaderPaths += "$env:LOCALAPPDATA\Intel\ShaderCache"
    }
    $shaderPaths += "$env:LOCALAPPDATA\D3DSCache"
    $totalItems = $shaderPaths.Count
    $currentItem = 0
    foreach ($path in $shaderPaths) {
        $currentItem++
        Write-Progress -Activity "GPU Shader Cache" -Status "Cleaning $path" -PercentComplete (($currentItem / $totalItems) * 100)
        try {
            if (Test-Path $path) {
                Remove-Item "$path\*" -Recurse -Force -ErrorAction SilentlyContinue
                Write-Host "  Cleared: $(Split-Path $path -Leaf)" -ForegroundColor Gray
            }
        } catch {
            # Silently skip files that are in use or inaccessible
        }
        Start-Sleep -Milliseconds 200 # Simulate work for progress visibility
    }
    Write-Progress -Activity "GPU Shader Cache" -Status "Complete" -PercentComplete 100 -Completed
    Write-Host "`nShader Cache Cleared!" -ForegroundColor Green
}

function Clear-DNSCache {
    Write-Host "`n==== DNS CACHE & NETWORK RESET ==== " -ForegroundColor $cleanupColor
    $confirm = Read-Host "This will reset network settings and may disrupt active connections. Continue? (Y/N)"
    if ($confirm -notmatch "^[Yy]$") {
        Write-Host "Network reset canceled." -ForegroundColor Yellow
        Write-Progress -Activity "DNS Cache & Network Reset" -Status "Canceled" -PercentComplete 100 -Completed
        return
    }
    Write-Progress -Activity "DNS Cache & Network Reset" -Status "Flushing DNS" -PercentComplete 33
    try {
        ipconfig /flushdns | Out-Null
        Write-Progress -Activity "DNS Cache & Network Reset" -Status "Resetting Winsock" -PercentComplete 66
        netsh winsock reset | Out-Null
        Write-Progress -Activity "DNS Cache & Network Reset" -Status "Resetting IP" -PercentComplete 90
        netsh int ip reset | Out-Null
        Write-Host "  DNS cache cleared and network stack reset." -ForegroundColor Gray
        Write-Progress -Activity "DNS Cache & Network Reset" -Status "Complete" -PercentComplete 100 -Completed
        Write-Host "`nNetwork reset complete! A restart is required to apply changes." -ForegroundColor Green
    } catch {
        Write-Host "  Failed to reset network stack: $($_.Exception.Message)" -ForegroundColor Red
        Write-Progress -Activity "DNS Cache & Network Reset" -Status "Failed" -PercentComplete 100 -Completed
    }
}

function Clear-BrowserData {
    Write-Host "`n==== CLEAR BROWSER CACHE ==== " -ForegroundColor $cleanupColor
    Write-Host "  Warning: Close all browsers before proceeding to avoid file access issues." -ForegroundColor Yellow
    $browsers = @("Chrome", "Edge", "Firefox")
    $totalItems = $browsers.Count
    $currentItem = 0
    foreach ($browser in $browsers) {
        $currentItem++
        Write-Progress -Activity "Clear Browser Cache" -Status "Cleaning $browser cache" -PercentComplete (($currentItem / $totalItems) * 100)
        switch ($browser) {
            "Chrome" {
                $chromeBasePath = "$env:LOCALAPPDATA\Google\Chrome\User Data"
                if (Test-Path $chromeBasePath) {
                    Get-ChildItem -Path $chromeBasePath -Directory | ForEach-Object {
                        $cachePath = "$($_.FullName)\Cache"
                        if (Test-Path $cachePath) {
                            try {
                                Remove-Item "$cachePath\*" -Recurse -Force -ErrorAction SilentlyContinue
                                Write-Host "  Chrome cache cleared for profile: $($_.Name)" -ForegroundColor Gray
                            } catch {
                                # Silently skip files that are in use or inaccessible
                            }
                        }
                    }
                }
            }
            "Edge" {
                $edgeBasePath = "$env:LOCALAPPDATA\Microsoft\Edge\User Data"
                if (Test-Path $edgeBasePath) {
                    Get-ChildItem -Path $edgeBasePath -Directory | ForEach-Object {
                        $cachePath = "$($_.FullName)\Cache"
                        if (Test-Path $cachePath) {
                            try {
                                Remove-Item "$cachePath\*" -Recurse -Force -ErrorAction SilentlyContinue
                                Write-Host "  Edge cache cleared for profile: $($_.Name)" -ForegroundColor Gray
                            } catch {
                                # Silently skip files that are in use or inaccessible
                            }
                        }
                    }
                }
            }
            "Firefox" {
                $firefoxBasePath = "$env:APPDATA\Mozilla\Firefox\Profiles"
                if (Test-Path $firefoxBasePath) {
                    Get-ChildItem -Path $firefoxBasePath -Directory | ForEach-Object {
                        $cachePath = "$($_.FullName)\cache"
                        if (Test-Path $cachePath) {
                            try {
                                Remove-Item "$cachePath\*" -Recurse -Force -ErrorAction SilentlyContinue
                                Write-Host "  Firefox cache cleared for profile: $($_.Name)" -ForegroundColor Gray
                            } catch {
                                # Silently skip files that are in use or inaccessible
                            }
                        }
                    }
                }
            }
        }
        Start-Sleep -Milliseconds 200 # Simulate work for progress visibility
    }
    Write-Progress -Activity "Clear Browser Cache" -Status "Complete" -PercentComplete 100 -Completed
    Write-Host "`nBrowser cache cleared!" -ForegroundColor Green
}

function Update-AppsAndSoftware {
    Write-Host "`n==== UPDATE ALL APPS & SOFTWARE ==== " -ForegroundColor $maintColor
    Write-Host "  Updating Windows OS and all installed applications..." -ForegroundColor Gray
    Write-Progress -Activity "Update Apps & Software" -Status "Checking for Windows Updates" -PercentComplete 10

    # Handle PSWindowsUpdate module
    try {
        if (Get-Module -Name PSWindowsUpdate -ListAvailable) {
            # Check if module is in use
            if (Get-Module -Name PSWindowsUpdate) {
                Write-Host "  Warning: PSWindowsUpdate module is currently in use. Attempting to unload..." -ForegroundColor Yellow
                try {
                    Remove-Module -Name PSWindowsUpdate -Force -ErrorAction Stop
                } catch {
                    Write-Host "  Failed to unload PSWindowsUpdate module. Please close other PowerShell sessions and try again." -ForegroundColor Red
                    Write-Progress -Activity "Update Appsdoesn't & Software" -Status "Failed (Windows Update)" -PercentComplete 100 -Completed
                    return
                }
            }
            Write-Progress -Activity "Update Apps & Software" -Status "Installing PSWindowsUpdate module" -PercentComplete 20
            Install-Module -Name PSWindowsUpdate -Force -Scope CurrentUser -ErrorAction Stop
            Import-Module -Name PSWindowsUpdate -ErrorAction Stop
            Write-Progress -Activity "Update Apps & Software" -Status "Installing Windows Updates" -PercentComplete 40
            Get-WindowsUpdate -Install -AcceptAll -AutoReboot -ErrorAction Stop
            Write-Host "  Windows OS updates installed." -ForegroundColor Gray
        } else {
            Write-Host "  PSWindowsUpdate module not found. Skipping Windows Update." -ForegroundColor Yellow
        }
    } catch {
        Write-Host "  Failed to install Windows updates: $($_.Exception.Message)" -ForegroundColor Red
    }

    # Handle winget updates
    try {
        Write-Progress -Activity "Update Apps & Software" -Status "Checking for application updates" -PercentComplete 60
        Write-Host "  Checking for available application updates..." -ForegroundColor Gray
        winget upgrade
        Write-Progress -Activity "Update Apps & Software" -Status "Updating applications" -PercentComplete 80
        winget upgrade --all --accept-source-agreements --accept-package-agreements
        Write-Host "  All applications updated." -ForegroundColor Gray
    } catch {
        Write-Host "  Failed to update applications: $($_.Exception.Message)" -ForegroundColor Red
    }

    Write-Progress -Activity "Update Apps & Software" -Status "Complete" -PercentComplete 100 -Completed
    Write-Host "`nUpdate process completed!" -ForegroundColor Green
}

function Generate-BatteryReport {
    param (
        [string]$OutputPath = "$env:USERPROFILE\Desktop\BatteryReport.html"
    )
    Write-Host "`n==== BATTERY HEALTH REPORT ==== " -ForegroundColor $reportColor
    Write-Progress -Activity "Battery Health Report" -Status "Checking for battery" -PercentComplete 10
    $battery = Get-WmiObject Win32_Battery
    if (-not $battery) {
        Write-Host "  No battery detected on this system. Battery report not applicable." -ForegroundColor Yellow
        Write-Progress -Activity "Battery Health Report" -Status "Canceled" -PercentComplete 100 -Completed
        return
    }
    Write-Progress -Activity "Battery Health Report" -Status "Generating report" -PercentComplete 50
    try {
        powercfg /batteryreport /output $OutputPath | Out-Null
        Write-Host "  Battery report saved to $OutputPath" -ForegroundColor Gray
        Write-Progress -Activity "Battery Health Report" -Status "Opening report" -PercentComplete 80
        Start-Process $OutputPath -ErrorAction Stop
        Write-Host "  Battery report opened in default browser" -ForegroundColor Gray
        Write-Progress -Activity "Battery Health Report" -Status "Complete" -PercentComplete 100 -Completed
    } catch {
        Write-Host "  Failed to generate or open battery report: $($_.Exception.Message)" -ForegroundColor Red
        Write-Progress -Activity "Battery Health Report" -Status "Failed" -PercentComplete 100 -Completed
    }
}

function Show-SystemInformation {
    Write-Host "`n==== SYSTEM INFORMATION ==== " -ForegroundColor $reportColor
    Write-Progress -Activity "System Information" -Status "Opening msinfo32" -PercentComplete 50
    try {
        Start-Process msinfo32.exe -ErrorAction Stop
        Write-Host "  System Information application opened" -ForegroundColor Gray
        Write-Progress -Activity "System Information" -Status "Complete" -PercentComplete 100 -Completed
    } catch {
        Write-Host "  Failed to open System Information: $($_.Exception.Message)" -ForegroundColor Red
        Write-Progress -Activity "System Information" -Status "Failed" -PercentComplete 100 -Completed
    }
}

function Toggle-ShortcutArrow {
    Write-Host "`n==== TOGGLE SHORTCUT ARROWS ==== " -ForegroundColor $tweakColor
    Write-Host "  Note: This will restart Windows Explorer, closing all open folders." -ForegroundColor Yellow
    $confirm = Read-Host "Continue? (Y/N)"
    if ($confirm -notmatch "^[Yy]$") {
        Write-Host "Shortcut arrow toggle canceled." -ForegroundColor Yellow
        Write-Progress -Activity "Toggle Shortcut Arrows" -Status "Canceled" -PercentComplete 100 -Completed
        return
    }
    Write-Progress -Activity "Toggle Shortcut Arrows" -Status "Modifying registry" -PercentComplete 50
    $regPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons"
    $blankIconPath = "$env:SystemRoot\System32\imageres.dll,152"
    if (!(Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    $arrow = Get-ItemProperty -Path $regPath -Name "29" -ErrorAction SilentlyContinue
    if ($arrow) {
        Remove-ItemProperty -Path $regPath -Name "29"
        Write-Host "  Shortcut arrows restored." -ForegroundColor Gray
    } else {
        Set-ItemProperty -Path $regPath -Name "29" -Value $blankIconPath
        Write-Host "  Shortcut arrows removed." -ForegroundColor Gray
    }
    Write-Progress -Activity "Toggle Shortcut Arrows" -Status "Restarting Explorer" -PercentComplete 80
    try {
        Stop-Process -Name explorer -Force -ErrorAction Stop
        Start-Process explorer
    } catch {
        Write-Host "  Failed to restart Explorer: $($_.Exception.Message)" -ForegroundColor Red
        Write-Progress -Activity "Toggle Shortcut Arrows" -Status "Failed" -PercentComplete 100 -Completed
        return
    }
    Write-Progress -Activity "Toggle Shortcut Arrows" -Status "Complete" -PercentComplete 100 -Completed
}

function Toggle-Telemetry {
    Write-Host "`n==== TOGGLE TELEMETRY ==== " -ForegroundColor $tweakColor
    Write-Host "  Warning: Disabling telemetry may affect Windows Insider Program and diagnostic features." -ForegroundColor Yellow
    Write-Progress -Activity "Toggle Telemetry" -Status "Checking telemetry status" -PercentComplete 20
    $svc = Get-Service -Name DiagTrack -ErrorAction SilentlyContinue
    $regPath = "HKLM:\SOFTWARE\Policies\Microsoft\Windows\DataCollection"
    if (!(Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }
    if ($svc.Status -eq "Running") {
        Write-Progress -Activity "Toggle Telemetry" -Status "Disabling telemetry" -PercentComplete 60
        try {
            Stop-Service -Name DiagTrack -Force -ErrorAction Stop
            Set-Service -Name DiagTrack -StartupType Disabled -ErrorAction Stop
            Set-ItemProperty -Path $regPath -Name "AllowTelemetry" -Value 0 -ErrorAction Stop
            Write-Host "  Telemetry disabled." -ForegroundColor Gray
        } catch {
            Write-Host "  Failed to disable telemetry: $($_.Exception.Message)" -ForegroundColor Red
            Write-Progress -Activity "Toggle Telemetry" -Status "Failed" -PercentComplete 100 -Completed
            return
        }
    } else {
        Write-Progress -Activity "Toggle Telemetry" -Status "Enabling telemetry" -PercentComplete 60
        try {
            Set-Service -Name DiagTrack -StartupType Automatic -ErrorAction Stop
            Start-Service -Name DiagTrack -ErrorAction Stop
            Remove-ItemProperty -Path $regPath -Name "AllowTelemetry" -ErrorAction SilentlyContinue
            Write-Host "  Telemetry enabled." -ForegroundColor Gray
        } catch {
            Write-Host "  Failed to enable telemetry: $($_.Exception.Message)" -ForegroundColor Red
            Write-Progress -Activity "Toggle Telemetry" -Status "Failed" -PercentComplete 100 -Completed
            return
        }
    }
    Write-Progress -Activity "Toggle Telemetry" -Status "Complete" -PercentComplete 100 -Completed
}

function Toggle-WindowsUpdate {
    Write-Host "`n==== TOGGLE WINDOWS UPDATE ==== " -ForegroundColor $tweakColor
    Write-Host "  Warning: Disabling Windows Update may prevent security updates, posing a security risk." -ForegroundColor Yellow
    Write-Progress -Activity "Toggle Windows Update" -Status "Checking Windows Update status" -PercentComplete 20
    $svc = Get-Service -Name wuauserv -ErrorAction SilentlyContinue
    if ($svc.Status -eq "Running") {
        Write-Progress -Activity "Toggle Windows Update" -Status "Disabling Windows Update" -PercentComplete 60
        try {
            Stop-Service -Name wuauserv -Force -ErrorAction Stop
            Set-Service -Name wuauserv -StartupType Disabled -ErrorAction Stop
            Write-Host "  Windows Update disabled." -ForegroundColor Gray
        } catch {
            Write-Host "  Failed to disable Windows Update: $($_.Exception.Message)" -ForegroundColor Red
            Write-Progress -Activity "Toggle Windows Update" -Status "Failed" -PercentComplete 100 -Completed
            return
        }
    } else {
        Write-Progress -Activity "Toggle Windows Update" -Status "Enabling Windows Update" -PercentComplete 60
        try {
            Set-Service -Name wuauserv -StartupType Automatic -ErrorAction Stop
            Start-Service -Name wuauserv -ErrorAction Stop
            Write-Host "  Windows Update enabled." -ForegroundColor Gray
        } catch {
            Write-Host "  Failed to enable Windows Update: $($_.Exception.Message)" -ForegroundColor Red
            Write-Progress -Activity "Toggle Windows Update" -Status "Failed" -PercentComplete 100 -Completed
            return
        }
    }
    Write-Progress -Activity "Toggle Windows Update" -Status "Complete" -PercentComplete 100 -Completed
}

function Show-Support {
    Write-Progress -Activity "Support Developer" -Status "Opening support link" -PercentComplete 50
    Start-Process "https://linktr.ee/Akshat_530"
    Write-Progress -Activity "Support Developer" -Status "Complete" -PercentComplete 100 -Completed
}
function Show-GithubPage {
    Write-Progress -Activity "Redirecting to Github" -Status "Opening support link" -PercentComplete 50
    Start-Process "https://github.com/Akshat2006/Advanced-PC-Optimizer"
    Write-Progress -Activity "Redirecting to Github" -Status "Complete" -PercentComplete 100 -Completed
}

function Toggle-ContextMenuStyle {
    $regPath = "HKCU:\Software\Classes\CLSID\{86ca1aa0-34aa-4e8b-a509-50c905bae2a2}"
    $subKey = "InprocServer32"

    if (Test-Path "$regPath\$subKey") {
        # Revert to Windows 11 context menu
        Remove-Item -Path "$regPath" -Recurse -Force
        Write-Host " Reverted to Windows 11 context menu." -ForegroundColor Green
    } else {
        # Switch to Windows 10-style context menu
        New-Item -Path "$regPath\$subKey" -Force | Out-Null
        Set-ItemProperty -Path "$regPath\$subKey" -Name "(default)" -Value "" | Out-Null
        Write-Host " Switched to Windows 10-style context menu." -ForegroundColor Cyan
    }

    # Restart Explorer to apply changes
    Stop-Process -Name explorer -Force
    Start-Sleep -Seconds 1
    Start-Process explorer
    Write-Host " Explorer restarted to apply changes." -ForegroundColor Gray
}

function Toggle-EndTaskOnTaskbar {
    $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings"
    $regName = "TaskbarEndTask"

    # Ensure the registry path exists
    if (-not (Test-Path $regPath)) {
        New-Item -Path $regPath -Force | Out-Null
    }

    # Retrieve current value
    $currentValue = Get-ItemProperty -Path $regPath -Name $regName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty $regName -ErrorAction SilentlyContinue

    if ($null -eq $currentValue -or $currentValue -eq 0) {
        Set-ItemProperty -Path $regPath -Name $regName -Value 1 -Force
        Write-Host " 'End Task' on taskbar has been ENABLED." -ForegroundColor Green
    } else {
        Set-ItemProperty -Path $regPath -Name $regName -Value 0 -Force
        Write-Host " 'End Task' on taskbar has been DISABLED." -ForegroundColor Yellow
    }

    # Restart Explorer to apply the change
    Stop-Process -Name explorer -Force
    Start-Sleep -Seconds 1
    Start-Process explorer
    Write-Host " Explorer restarted to apply changes." -ForegroundColor Gray
}
function Toggle-SafeMode {
    Write-Progress -Activity "Toggle Safe Mode" -Status "Checking boot configuration" -PercentComplete 20
    try {
        $bcdOutput = bcdedit /enum "{current}" 2>&1
        if ($LASTEXITCODE -ne 0) {
            Write-Host "Failed to retrieve boot configuration data:" -ForegroundColor Red
            Write-Host $bcdOutput -ForegroundColor Red
            Write-Progress -Activity "Toggle Safe Mode" -Status "Failed: Unable to access BCD" -PercentComplete 100 -Completed
            return
        }

        if ($bcdOutput | Select-String -Pattern "\bsafeboot\s+minimal") {
            Write-Host "Safe Mode is currently enabled. Reverting to Normal Boot Mode..." -ForegroundColor Cyan
            Write-Progress -Activity "Toggle Safe Mode" -Status "Disabling Safe Mode" -PercentComplete 60
            $result = bcdedit /deletevalue "{current}" safeboot 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Boot configuration set to Normal Mode." -ForegroundColor Green
            } else {
                Write-Host "Failed to revert to Normal Mode:" -ForegroundColor Red
                Write-Host $result -ForegroundColor Red
                Write-Progress -Activity "Toggle Safe Mode" -Status "Failed: Unable to disable Safe Mode" -PercentComplete 100 -Completed
                return
            }
        } else {
            Write-Host "Safe Mode is currently disabled. Enabling Safe Mode (minimal)..." -ForegroundColor Yellow
            Write-Progress -Activity "Toggle Safe Mode" -Status "Enabling Safe Mode" -PercentComplete 60
            $result = bcdedit /set "{current}" safeboot minimal 2>&1
            if ($LASTEXITCODE -eq 0) {
                Write-Host "Boot configuration set to Safe Mode (minimal)." -ForegroundColor Green
            } else {
                Write-Host "Failed to enable Safe Mode:" -ForegroundColor Red
                Write-Host $result -ForegroundColor Red
                Write-Progress -Activity "Toggle Safe Mode" -Status "Failed: Unable to enable Safe Mode" -PercentComplete 100 -Completed
                return
            }
        }

        Write-Progress -Activity "Toggle Safe Mode" -Status "Complete" -PercentComplete 80
        $response = Read-Host "Do you want to restart now? (Y/N)"
        if ($response -match '^[Yy]$') {
            Write-Host "Restarting system..." -ForegroundColor Green
            Write-Progress -Activity "Toggle Safe Mode" -Status "Restarting" -PercentComplete 90
            try {
                Restart-Computer -Force -ErrorAction Stop
            } catch {
                Write-Host "Failed to restart system: $($_.Exception.Message)" -ForegroundColor Red
                Write-Host "Please restart your computer manually to apply the changes." -ForegroundColor Gray
                Write-Progress -Activity "Toggle Safe Mode" -Status "Failed: Restart unsuccessful" -PercentComplete 100 -Completed
            }
        } else {
            Write-Host "Restart cancelled. Changes will apply on next reboot." -ForegroundColor Gray
            Write-Progress -Activity "Toggle Safe Mode" -Status "Complete: Restart cancelled" -PercentComplete 100 -Completed
        }
    } catch {
        Write-Host "An unexpected error occurred: $($_.Exception.Message)" -ForegroundColor Red
        Write-Progress -Activity "Toggle Safe Mode" -Status "Failed: Unexpected error" -PercentComplete 100 -Completed
    }
}

function Show-Menu {
    Clear-Host
    Write-Host "======================================" -ForegroundColor DarkGray
    Write-Host "          Advanced PC Optimizer v2.0" -ForegroundColor Cyan
    Write-Host "             by AKSHAT_530" -ForegroundColor DarkCyan
    Write-Host "======================================" -ForegroundColor DarkGray
    Write-Host "`nCLEANUP TOOLS" -ForegroundColor $cleanupColor
    Write-Host " [1] Advanced Cleanup (Temp, WU, Logs, Recycle Bin)"
    Write-Host " [2] System Disk Cleanup (Cleanmgr Sagerun)"
    Write-Host " [3] Clear GPU Shader Cache (NVIDIA, AMD, Intel, DirectX)"
    Write-Host " [4] Clear DNS Cache & Reset Network"
    Write-Host " [5] Clear Browser Cache"
    Write-Host "`nSYSTEM MAINTENANCE" -ForegroundColor $maintColor
    Write-Host " [6] Run DISM (Health Check)"
    Write-Host " [7] Run System File Checker (SFC)"
    Write-Host " [8] Update all APPS & Software"
    Write-Host "`nSYSTEM REPORTS" -ForegroundColor $reportColor
    Write-Host " [9] Generate Battery Health Report"
    Write-Host " [10] Show System Information"
    Write-Host "`nTWEAKS & TOOLS" -ForegroundColor $tweakColor
    Write-Host " [11] Toggle Shortcut Arrows of folders ( BETA )"
    Write-Host " [12] Toggle Windows Telemetry (On or Off)"
    Write-Host " [13] Toggle Windows Updates (On or Off)"
    Write-Host " [14] Toggle Right Click Menu UI Switch between win 10 and 11 UI"
    Write-Host " [15] Toggle EndTask Option in Taskbar"
    Write-Host " [16] Toggle Safe or Normal Boot Mode"
    Write-Host "`nMore" -ForegroundColor $exitColor
    Write-Host " [0] Exit"
    Write-Host " [17] Support Developer" -ForegroundColor $supportColor
    Write-Host " [18] Visite Github Page" -ForegroundColor $supportColor
}

# ===== MAIN LOOP =====
do {
    Show-Menu
    $choice = Read-Host "`nEnter your choice (0-16)"
    switch ($choice) {
        "1" { Clear-AdvancedCleanup }
        "2" { Run-DiskCleanupSystem }
        "3" { Clear-ShaderCache }
        "4" { Clear-DNSCache }
        "5" { Clear-BrowserData }
        "6" {
            Write-Host "`n==== DISM HEALTH CHECK ==== " -ForegroundColor $maintColor
            Write-Progress -Activity "DISM Health Check" -Status "Running DISM" -PercentComplete 50
            try {
                $output = Start-Process powershell -ArgumentList "-Command DISM /Online /Cleanup-Image /RestoreHealth" -NoNewWindow -Wait -RedirectStandardOutput "$env:TEMP\dism.log" -PassThru
                Get-Content "$env:TEMP\dism.log" | Write-Host -ForegroundColor Gray
                Write-Host "`nDISM Completed!" -ForegroundColor Green
                Write-Progress -Activity "DISM Health Check" -Status "Complete" -PercentComplete 100 -Completed
            } catch {
                Write-Host "  Failed to run DISM: $($_.Exception.Message)" -ForegroundColor Red
                Write-Progress -Activity "DISM Health Check" -Status "Failed" -PercentComplete 100 -Completed
            }
        }
        "7" {
            Write-Host "`n==== SYSTEM FILE CHECKER ==== " -ForegroundColor $maintColor
            Write-Progress -Activity "System File Checker" -Status "Running SFC" -PercentComplete 50
            try {
                $output = Start-Process powershell -ArgumentList "-Command sfc /scannow" -NoNewWindow -Wait -RedirectStandardOutput "$env:TEMP\sfc.log" -PassThru
                Get-Content "$env:TEMP\sfc.log" | Write-Host -ForegroundColor Gray
                Write-Host "`nSFC Completed!" -ForegroundColor Green
                Write-Progress -Activity "System File Checker" -Status "Complete" -PercentComplete 100 -Completed
            } catch {
                Write-Host "  Failed to run SFC: $($_.Exception.Message)" -ForegroundColor Red
                Write-Progress -Activity "System File Checker" -Status "Failed" -PercentComplete 100 -Completed
            }
        }
        "8" { Update-AppsAndSoftware }
        "9" { Generate-BatteryReport }
        "10" { Show-SystemInformation }
        "11" { Toggle-ShortcutArrow }
        "12" { Toggle-Telemetry }
        "13" { Toggle-WindowsUpdate }
        "14" { Toggle-ContextMenuStyle }
        "15" { Toggle-EndTaskOnTaskbar }
        "16" { Toggle-SafeMode }
        "17" { Show-Support }
        "18" { Show-GithubPage }
        "0" {
            Write-Host "`nThank you for using Advanced PC Cleaner!" -ForegroundColor Cyan
            Write-Host "Exiting..." -ForegroundColor Gray
            exit
        }
        default {
            Write-Host "`nInvalid option! Please try again." -ForegroundColor Red
        }
    }
    if ($choice -ne "0") {
        Write-Host "`nPress any key to return to menu..." -ForegroundColor DarkGray
        $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    }
} while ($true)