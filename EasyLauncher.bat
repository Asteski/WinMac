@echo off
cd /d "%~dp0\pwsh"

:: Debugging: Check what argument is passed
echo Argument passed: %1

:: Check if no argument is passed
if "%1"=="" (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "installGUI.ps1"
    goto :eof
)

:: Check if -uninstall is passed
if /i "%1"=="-uninstall" (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "uninstallGUI.ps1"
    goto :eof
)

:: Check if -nogui is passed
if /i "%1"=="-nogui" (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "installGUI.ps1" -ArgumentList '-nogui'
    goto :eof
)

:: Check if -uninstallnogui is passed
if /i "%1"=="-uninstallnogui" (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "uninstall.ps1" -ArgumentList '-nogui'
    goto :eof
)

:: Handle invalid argument case
echo [31mInvalid argument.[0m
