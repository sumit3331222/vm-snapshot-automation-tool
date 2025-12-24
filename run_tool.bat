@echo off
REM Run the PowerShell tool with ExecutionPolicy bypass for this process
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "& '%~dp0vm_snapshot_manager.ps1'"
pause
