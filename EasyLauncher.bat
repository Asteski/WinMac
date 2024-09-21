@echo off
if "%1"=="" (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "scripts/install.ps1"
) else if "%1"=="uninstall" (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "scripts/uninstall.ps1"
) else if "%1"=="gui" (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "scripts/installGUI.ps1"
) else if "%1"=="uninstallgui" (
    pwsh -NoProfile -ExecutionPolicy Bypass -File "scripts/uninstallGUI.ps1"
) else (
    echo [31mInvalid argument.[0m
)