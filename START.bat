@echo off
:: Elevation check as before
net session >nul 2>&1
if %errorLevel% NEQ 0 (
    echo Requesting administrator privileges...
    powershell -Command "Start-Process -FilePath '%COMSPEC%' -ArgumentList '/c \"%~f0\"' -Verb RunAs"
    exit /b
)

:: Run the PowerShell script normally (visible window)
set "script=%~dp0Advanced PC Optimizer v2.0.ps1"
PowerShell -NoProfile -ExecutionPolicy Bypass -File "%script%"

:: Pause to see output before window closes
pause
exit /b 0
