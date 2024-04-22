Clear-Host
Write-Host @"
-----------------------------------------------------------------------

Welcome to WinMac Deployment!

Author: Asteski
Version: 0.2.3

This is Work in Progress. You're using this script at your own risk.

-----------------------------------------------------------------------

"@ -ForegroundColor Cyan
Write-Host @"
Currently no update/uninstall functionality is implemented, so please
make sure to run the script on a clean system or make a backup.

PowerShell profile files will be removed and replaced with new ones. 
Please make sure to backup your current profiles if needed.

"@ -ForegroundColor Yellow

Write-Host "-----------------------------------------------------------------------"  -ForegroundColor Cyan
Write-Host
$installConfirmation = Read-Host "Are you sure you want to start the installation process (y/n)"

if ($installConfirmation -ne 'y') {
    Write-Host "Installation process aborted." -ForegroundColor Red
    Start-Sleep 2
    exit
}

## Start Logging

$errorActionPreference="SilentlyContinue"
$date = Get-Date -Format "yy-MM-ddTHHmmss"
mkdir ./temp | Out-Null
Start-Transcript -Path ".\temp\WinMac_install_log_$date.txt" -Append | Out-Null

## User Configuration

Write-Host @"

You can choose now between MacOS-like prompt and WinMac prompt.

MacOS prompt:
userName@computerName ~ % 

WinMac prompt: 
12:35:06 userName @ ~ > 

"@
$promptSet = Read-Host "Do you want to use MacOS-like prompt? (y/n)"
if ($promptSet -eq 'y') {
    Write-Host "Using MacOS-like prompt." -ForegroundColor Yellow
    Start-Sleep 2
}
else
{ 
    Write-Host "Using WinMac prompt." -ForegroundColor Yellow
    Start-Sleep 2
}

Start-Sleep 1
Write-Host
Write-Host @"
Please do not do anything while the script is running, as it may impact
the installation process.
"@ -ForegroundColor Red
Start-Sleep 2
Write-Host
Write-Host "Starting installation process in..." -ForegroundColor Green
for ($a=3; $a -ge 0; $a--) {
    Write-Host -NoNewLine "`b$a" -ForegroundColor Green
    Start-Sleep 1
}

## Winget
Write-Host
Write-Host "Checking for Windows Package Manager (Winget)" -ForegroundColor Yellow
$progressPreference = 'silentlyContinue'
Write-Information "Downloading WinGet and its dependencies..."
$wingetUrl = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
$installPath = "$env:TEMP\winget.msixbundle"
Invoke-WebRequest -Uri $wingetUrl -OutFile $installPath
Write-Information "Installing WinGet..."
Add-AppxPackage -Path $installPath
Remove-Item -Path $installPath -Force
Write-Information "Winget installation completed."

## PowerToys

Write-Host "Installing PowerToys..."  -ForegroundColor Yellow
winget configure .\config\powertoys.dsc.yaml --accept-configuration-agreements | Out-Null
Write-Host "Installing PowerToys completed." -ForegroundColor Green
Start-Sleep 5
Get-Process | Where-Object { $_.ProcessName -eq 'PowerToys' } | Stop-Process -Force | Out-Null

Write-Host "Installing Everything..." -ForegroundColor Yellow
$winget = @(
    "Voidtools.Everything",
    "lin-ycv.EverythingPowerToys"
)
foreach ($app in $winget) {winget install --id $app --source winget --silent | Out-Null}
Write-Host "Installing Everything completed." -ForegroundColor Green

## PowerShell Profile

Write-Host "Configuring PowerShell Profile..." -ForegroundColor Yellow

$profilePath = $PROFILE | Split-Path | Split-Path
$profileFile = $PROFILE | Split-Path -Leaf
if ($promptSet -eq 'y') { $prompt = Get-Content "$pwd\config\terminal\macos-prompt.ps1" -Raw }
else { $promptSet = Get-Content "$pwd\config\terminal\winmac-prompt.ps1" -Raw }
$functions = Get-Content "$pwd\config\terminal\functions.ps1" -Raw

if (-not (Test-Path "$profilePath\PowerShell")) { New-Item -ItemType Directory -Path "$profilePath\PowerShell" | Out-Null } else { Remove-Item -Path "$profilePath\PowerShell\$profileFile" -Force | Out-Null }
if (-not (Test-Path "$profilePath\WindowsPowerShell")) { New-Item -ItemType Directory -Path "$profilePath\WindowsPowerShell" | Out-Null } else { Remove-Item -Path "$profilePath\WindowsPowerShell\$profileFile" -Force | Out-Null }
if (-not (Test-Path "$profilePath\PowerShell\$profileFile")) { New-Item -ItemType File -Path "$profilePath\PowerShell\$profileFile" | Out-Null }
if (-not (Test-Path "$profilePath\WindowsPowerShell\$profileFile")) { New-Item -ItemType File -Path "$profilePath\WindowsPowerShell\$profileFile" | Out-Null }

Write-Host "Checking for NuGet Provider" -ForegroundColor Yellow
$progressPreference = 'silentlyContinue'
if (-not (Get-PackageProvider -ListAvailable | Where-Object {$_.Name -eq 'NuGet'})) {
    Write-Information "Installing NuGet Provider..."
    Install-PackageProvider -Name NuGet -Force
    Write-Information "NuGet Provider installation completed."
}
else {
    Write-Information "NuGet Provider is already installed."
}

$winget = @(
    "Vim.Vim",
    "gsass1.NTop"
)
foreach ($app in $winget) {winget install --id $app --source winget --silent | Out-Null}
$vimParentPath = Join-Path $env:PROGRAMFILES Vim
$latestSubfolder = Get-ChildItem -Path $vimParentPath -Directory | Sort-Object -Property CreationTime -Descending | Select-Object -First 1
$vimChildPath = $latestSubfolder.FullName
[Environment]::SetEnvironmentVariable("Path", $env:Path + ";$vimChildPath", [EnvironmentVariableTarget]::Machine) | Out-Null
Install-Module PSTree -Scope CurrentUser -Force | Out-Null
Add-Content -Path "$profilePath\PowerShell\$profileFile" -Value $prompt
Add-Content -Path "$profilePath\PowerShell\$profileFile" -Value $functions
Add-Content -Path "$profilePath\WindowsPowerShell\$prompt" -Value $functions
Add-Content -Path "$profilePath\WindowsPowerShell\$profileFile" -Value $functions

Write-Host "Configuring PowerShell Profile completed." -ForegroundColor Green

## StartAllBack

Write-Host "Configuring Shell..." -ForegroundColor Yellow

Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class Taskbar {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
}
"@
$taskbarHandle = [Taskbar]::FindWindow("Shell_TrayWnd", "") | Out-Null
$HWND_TOP = [IntPtr]::Zero
$SWP_SHOWWINDOW = 0x0040
[Taskbar]::SetWindowPos($taskbarHandle, $HWND_TOP, 0, 0, 0, 0, $SWP_SHOWWINDOW) | Out-Null

Write-Host "Configuring StartAllBack..." -ForegroundColor Yellow

winget install --id "StartIsBack.StartAllBack" --source winget --silent | Out-Null

$exRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
$sabRegPath = "HKCU:\Software\StartIsBack"
Set-ItemProperty -Path $exRegPath\HideDesktopIcons\NewStartPanel -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Value 1
Set-ItemProperty -Path $exRegPath\Advanced -Name "TaskbarSizeMove" -Value 1
Set-ItemProperty -Path $exRegPath\Advanced -Name "ShowStatusBar" -Value 0
Set-ItemProperty -Path $exRegPath\Advanced -Name "EnableSnapAssistFlyout" -Value 0
Set-ItemProperty -Path $exRegPath\Advanced -Name "EnableSnapBar" -Value 0
Set-ItemProperty -Path $exRegPath\Advanced -Name "TaskbarGlomLevel" -Value 1
Set-ItemProperty -Path $exRegPath\Advanced -Name "TaskbarSmallIcons" -Value 1
Set-ItemProperty -Path $exRegPath\Advanced -Name "TaskbarSi" -Value 0
Set-ItemProperty -Path $exRegPath\Advanced -Name "TaskbarAl" -Value 0
Set-ItemProperty -Path $exRegPath\Advanced -Name "UseCompactMode" -Value 1
Set-ItemProperty -Path $sabRegPath -Name "WinBuild" -Value 22759
Set-ItemProperty -Path $sabRegPath -Name "WinLangID" -Value 2064
Set-ItemProperty -Path $sabRegPath -Name "WinkeyFunction" -Value 1
Set-ItemProperty -Path $sabRegPath -Name "WelcomeShown" -Value 3
Set-ItemProperty -Path $sabRegPath -Name "UpdateCheck" -Value ([byte[]](160, 224, 8, 201, 49, 125, 218, 1))
Set-ItemProperty -Path $sabRegPath -Name "SettingsVersion" -Value 5
Set-ItemProperty -Path $sabRegPath -Name "ModernIconsColorized" -Value 0
Set-ItemProperty -Path $sabRegPath -Name "FrameStyle" -Value 2
Set-ItemProperty -Path $sabRegPath -Name "TaskbarOneSegment" -Value 0
Set-ItemProperty -Path $sabRegPath -Name "TaskbarCenterIcons" -Value 1
Set-ItemProperty -Path $sabRegPath -Name "TaskbarTranslucentEffect" -Value 0
Set-ItemProperty -Path $sabRegPath -Name "TaskbarLargerIcons" -Value 0
Set-ItemProperty -Path $sabRegPath -Name "TaskbarSpacierIcons" -Value (-1)
Set-ItemProperty -Path $sabRegPath -Name "TaskbarControlCenter" -Value 1
Set-ItemProperty -Path $sabRegPath -Name "UpdateInfo" -Value ([byte[]](60, 63, 120, 109, 108, 32, 118, 101, 114, 115, 105, 111, 110, 61, 34, 49, 46, 48, 34, 63, 62, 10, 60, 85, 112, 100, 97, 116, 101, 32, 78, 97, 109, 101, 61, 34, 83, 116, 97, 114, 116, 65, 108, 108, 66, 97, 99, 107, 32, 51, 46, 55, 46, 55, 34, 32, 68, 101, 115, 99, 114, 105, 112, 116, 105, 111, 110, 61, 34, 34, 32, 68, 111, 119, 110, 108, 111, 97, 100, 85, 82, 76, 61, 34, 104, 116, 116, 112, 115, 58, 47, 47, 115, 116, 97, 114, 116, 105, 115, 98, 97, 99, 107, 46, 115, 102, 111, 51, 46, 99, 100, 110, 46, 100, 105, 103, 105, 116, 97, 108, 111, 99, 101, 97, 110, 115, 112, 97, 99, 101, 115, 46, 99, 111, 109, 47, 83, 116, 97, 114, 116, 65, 108, 108, 66, 97, 99, 107, 95, 51, 46, 55, 46, 55, 95, 115, 101, 116, 117, 112, 46, 101, 120, 101, 34, 32, 76, 101, 97, 114, 110, 77, 111, 114, 101, 85, 82, 76, 61, 34, 104, 116, 116, 112, 115, 58, 47, 47, 119, 119, 119, 46, 115, 116, 97, 114, 116, 97, 108, 108, 98, 97, 99, 107, 46, 99, 111, 109, 47, 34, 47, 62, 10))
Set-ItemProperty -Path $sabRegPath -Name "UpdateInfoHash" -Value 805441044
Set-ItemProperty -Path $sabRegPath -Name "SysTrayStyle" -Value 1
Set-ItemProperty -Path $sabRegPath -Name "SysTrayActionCenter" -Value 1
Set-ItemProperty -Path $sabRegPath -Name "SysTraySpacierIcons" -Value 1
Set-ItemProperty -Path $sabRegPath -Name "SysTrayClockFormat" -Value 3
Set-ItemProperty -Path $sabRegPath -Name "SysTrayInputSwitch" -Value 0
Set-ItemProperty -Path $sabRegPath\DarkMagic -Name "(default)" -Value 1
Set-ItemProperty -Path $sabRegPath\DarkMagic -Name "Unround" -Value 0
Set-ItemProperty -Path $sabRegPath\DarkMagic -Name "DarkMode" -Value 1
Stop-Process -Name Explorer -Force

Write-Host "Configuring StartAllBack completed." -ForegroundColor Green

## Misc

$shellExePath = Join-Path $env:PROGRAMFILES "Open-Shell\startmenu.exe"
Set-ItemProperty -Path $exRegPath\Advanced -Name "LaunchTO" -Value 1
Set-ItemProperty -Path $exRegPath -Name "ShowFrequent" -Value 0
Set-ItemProperty -Path $exRegPath -Name "ShowRecent" -Value 0
Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "TaskbarNoMultimon" -Value 1
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "TaskbarNoMultimon" -Value 1

# Themes
$curSourceFolder = $pwd.Path + '\config\cursor'
$curDestFolder = "C:\Windows\Cursors"
Copy-Item -Path $curSourceFolder\* -Destination $curDestFolder -Recurse -Force
$RegConnect = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"CurrentUser","$env:COMPUTERNAME")
$RegCursors = $RegConnect.OpenSubKey("Control Panel\Cursors",$true)
$RegCursors.SetValue("","Windows Black")
$RegCursors.SetValue("AppStarting","$curDestFolder\aero_black_working.ani")
$RegCursors.SetValue("Arrow","$curDestFolder\aero_black_arrow.cur")
$RegCursors.SetValue("Crosshair","$curDestFolder\aero_black_cross.cur")
$RegCursors.SetValue("Hand","$curDestFolder\aero_black_link.cur")
$RegCursors.SetValue("Help","$curDestFolder\aero_black_helpsel.cur")
$RegCursors.SetValue("IBeam","$curDestFolder\aero_black_beam.cur")
$RegCursors.SetValue("No","$curDestFolder\aero_black_unavail.cur")
$RegCursors.SetValue("NWPen","$curDestFolder\aero_black_pen.cur")
$RegCursors.SetValue("SizeAll","$curDestFolder\aero_black_move.cur")
$RegCursors.SetValue("SizeNESW","$curDestFolder\aero_black_nesw.cur")
$RegCursors.SetValue("SizeNS","$curDestFolder\aero_black_ns.cur")
$RegCursors.SetValue("SizeNWSE","$curDestFolder\aero_black_nwse.cur")
$RegCursors.SetValue("SizeWE","$curDestFolder\aero_black_ew.cur")
$RegCursors.SetValue("UpArrow","$curDestFolder\aero_black_up.cur")
$RegCursors.SetValue("Wait","$curDestFolder\aero_black_busy.ani")
$RegCursors.SetValue("Pin","$curDestFolder\aero_black_pin.ani")
$RegCursors.SetValue("Person","$curDestFolder\aero_black_person.ani")
$RegCursors.Close()
$RegConnect.Close()
$CSharpSig = @'

[DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]

public static extern bool SystemParametersInfo(

                 uint uiAction,

                 uint uiParam,

                 uint pvParam,

                 uint fWinIni);

'@
$CursorRefresh = Add-Type -MemberDefinition $CSharpSig -Name WinAPICall -Namespace SystemParamInfo –PassThru
$CursorRefresh::SystemParametersInfo(0x0057,0,$null,0) | Out-Null

# Pin Home and Programs to Quick Access

$homeDir = "C:\Users\$env:USERNAME"
$homeIniFilePath = "$($homeDir)\desktop.ini"
$programsDir = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs"
$programsIniFilePath = "$($programsDir)\desktop.ini"
$homeIni = @"
[.ShellClassInfo]
IconResource=C:\Windows\System32\SHELL32.dll,160
"@
$programsIni = @"
[.ShellClassInfo]
IconResource=C:\WINDOWS\System32\imageres.dll,187
"@

if (Test-Path $homeIniFilePath)  {
    Remove-Item $homeIniFilePath -Force
    New-Item -Path $homeIniFilePath -ItemType File -Force | Out-Null
}

Add-Content $homeIniFilePath -Value $homeIni
(Get-Item $homeIniFilePath -Force).Attributes = 'Hidden, System, Archive'
(Get-Item $homeDir -Force).Attributes = 'ReadOnly, Directory'

$homePin = new-object -com shell.application
$homePin.Namespace($homeDir).Self.InvokeVerb("pintohome") | Out-Null

if (Test-Path $programsIniFilePath)  {
    Remove-Item $programsIniFilePath -Force
    New-Item -Path $programsIniFilePath -ItemType File -Force | Out-Null
}

Add-Content $programsIniFilePath -Value $programsIni
(Get-Item $programsIniFilePath -Force).Attributes = 'Hidden, System, Archive'
(Get-Item $programsDir -Force).Attributes = 'ReadOnly, Directory'

$programsPin = new-object -com shell.application
$programsPin.Namespace($programsDir).Self.InvokeVerb("pintohome") | Out-Null

# Pin Recycle Bin to Quick Access

$RBPath = 'HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\pintohome\command\'
$name = "DelegateExecute"
$value = "{b455f46e-e4af-4035-b0a4-cf18d2f6f28e}"
New-Item -Path $RBPath -Force | Out-Null
New-ItemProperty -Path $RBPath -Name $name -Value $value -PropertyType String -Force | Out-Null
$oShell = New-Object -ComObject Shell.Application
$trash = $oShell.Namespace("shell:::{645FF040-5081-101B-9F08-00AA002F954E}")
$trash.Self.InvokeVerb("PinToHome") | Out-Null
Remove-Item -Path "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}" -Recurse | Out-Null

# Remove Shortcut Arrows

Copy-Item -Path "$pwd\config\blank.ico" -Destination "C:\Windows" -Force
New-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" | Out-Null
Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" -Name "29" -Value "C:\Windows\blank.ico" -Type String

## Open-Shell

Write-Host "Configuring Open-Shell..." -ForegroundColor Yellow

winget install --id "Open-Shell.Open-Shell-Menu" --source winget --custom 'ADDLOCAL=StartMenu' --silent | Out-Null
Start-Sleep 5
Stop-Process -Name startmenu -Force | Out-Null
taskkill /IM explorer.exe /F | Out-Null
New-Item -Path "Registry::HKEY_CURRENT_USER\Software\OpenShell" -Force | Out-Null
New-Item -Path "Registry::HKEY_CURRENT_USER\Software\OpenShell\OpenShell" -Force | Out-Null
New-Item -Path "Registry::HKEY_CURRENT_USER\Software\OpenShell\StartMenu" -Force | Out-Null
New-Item -Path "Registry::HKEY_CURRENT_USER\Software\OpenShell\ClassicExplorer" -Force | Out-Null
New-Item -Path "Registry::HKEY_CURRENT_USER\Software\OpenShell\OpenShell\Settings" -Force | Out-Null
New-Item -Path "Registry::HKEY_CURRENT_USER\Software\OpenShell\StartMenu\Settings" -Force | Out-Null
New-Item -Path "Registry::HKEY_CURRENT_USER\Software\OpenShell\ClassicExplorer\Settings" -Force | Out-Null
Set-ItemProperty -Path "HKCU:\Software\OpenShell\ClassicExplorer" -Name "ShowedToolbar" -Value 0
Set-ItemProperty -Path "HKCU:\Software\OpenShell\ClassicExplorer" -Name "NewLine" -Value 0
Set-ItemProperty -Path "HKCU:\Software\OpenShell\ClassicExplorer" -Name "CSettingsDlg" -Value ([byte[]](0,0,0,0,103,0,0,0,0,0,0,0,0,0,0,0,170,15,0,0,1,0,185,115,0,0,0,0))
Set-ItemProperty -Path "HKCU:\Software\OpenShell\ClassicExplorer\Settings" -Name "Version" -Value 10741631
Set-ItemProperty -Path "HKCU:\Software\OpenShell\ClassicExplorer\Settings" -Name "ShowStatusBar" -Value 0
Set-ItemProperty -Path "HKCU:\Software\OpenShell\ClassicExplorer\Settings" -Name "TreeStyle" -Value "Vista"
Set-ItemProperty -Path "HKCU:\Software\OpenShell\ClassicExplorer\Settings" -Name "HScrollbar" -Value "Default"
Set-ItemProperty -Path "HKCU:\Software\OpenShell\ClassicExplorer\Settings" -Name "NoFadeButtons" -Value 1
Set-ItemProperty -Path "HKCU:\Software\OpenShell\ClassicExplorer\Settings" -Name "HideSearch" -Value 0
Set-ItemProperty -Path "HKCU:\Software\OpenShell\ClassicExplorer\Settings" -Name "UseBigButtons" -Value 0
Set-ItemProperty -Path "HKCU:\Software\OpenShell\ClassicExplorer\Settings" -Name "AltEnter" -Value 0
Set-ItemProperty -Path "HKCU:\Software\OpenShell\ClassicExplorer\Settings" -Name "DisableBreadcrumbs" -Value 0
Set-ItemProperty -Path "HKCU:\Software\OpenShell\OpenShell" -Name "LastUpdateTime" -Value 0x161cde38
Set-ItemProperty -Path "HKCU:\Software\OpenShell\OpenShell\Settings" -Name "Nightly" -Value 0x00000001
Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu" -Name "ShowedStyle2" -Value 0x00000000
Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu" -Name "CSettingsDlg" -Value ([byte[]](0xaf, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xe4, 0x02, 0x00, 0x00, 0xb4, 0x00, 0x00, 0x00, 0xd7, 0x0b, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00))
Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "Version" -Value 0x040400bf
Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "DisablePinExt" -Value 1
Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "EnableContextMenu" -Value 0
Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "MouseClick" -Value "Command"
Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "ShiftClick" -Value "Command"
Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "WinKey" -Value "Command"
Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "MouseClickCommand" -Value "$pwd\bin\start.exe"
Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "ShiftClickCommand" -Value "Nothing"
Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "WinKeyCommand" -Value "$pwd\bin\start.exe"
Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "ShiftWin" -Value "Nothing"
Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "ShiftRight" -Value 1
Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "SearchBox" -Value "Hide"
Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "SkinW7" -Value "Immersive"
Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "SkinVariationW7" -Value ""
Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "SkinOptionsW7" -Value ([byte[]](0x4c, 0x00, 0x49, 0x00, 0x47, 0x00, 0x48, 0x00, 0x54, 0x00, 0x3d, 0x00, 0x30, 0x00, 0x00, 0x00, 0x44, 0x00, 0x41, 0x00, 0x52, 0x00, 0x4b, 0x00, 0x3d, 0x00, 0x30, 0x00, 0x00, 0x00, 0x41, 0x00, 0x55, 0x00, 0x54, 0x00, 0x4f, 0x00, 0x3d, 0x00, 0x31, 0x00, 0x00, 0x00, 0x55, 0x00, 0x53, 0x00, 0x45, 0x00, 0x52, 0x00, 0x5f, 0x00, 0x49, 0x00, 0x4d, 0x00, 0x41, 0x00, 0x47, 0x00, 0x45, 0x00, 0x3d, 0x00, 0x30, 0x00, 0x00, 0x00, 0x55, 0x00, 0x53, 0x00, 0x45, 0x00, 0x52, 0x00, 0x5f, 0x00, 0x4e, 0x00, 0x41, 0x00, 0x4d, 0x00, 0x45, 0x00, 0x3d, 0x00, 0x30, 0x00, 0x00, 0x00, 0x43, 0x00, 0x45, 0x00, 0x4e, 0x00, 0x54, 0x00, 0x45, 0x00, 0x52, 0x00, 0x5f, 0x00, 0x4e, 0x00, 0x41, 0x00, 0x4d, 0x00, 0x45, 0x00, 0x3d, 0x00, 0x30, 0x00, 0x00, 0x00, 0x53, 0x00, 0x4d, 0x00, 0x41, 0x00, 0x4c, 0x00, 0x4c, 0x00, 0x5f, 0x00, 0x49, 0x00, 0x43, 0x00, 0x4f, 0x00, 0x4e, 0x00, 0x53, 0x00, 0x3d, 0x00, 0x30, 0x00, 0x00, 0x00, 0x4f, 0x00, 0x50, 0x00, 0x41, 0x00, 0x51, 0x00, 0x55, 0x00, 0x45, 0x00, 0x3d, 0x00, 0x30, 0x00, 0x00, 0x00, 0x44, 0x00, 0x49, 0x00, 0x53, 0x00, 0x41, 0x00, 0x42, 0x00, 0x4c, 0x00, 0x45, 0x00, 0x5f, 0x00, 0x4d, 0x00, 0x41, 0x00, 0x53, 0x00, 0x4b, 0x00, 0x3d, 0x00, 0x30, 0x00, 0x00, 0x00, 0x42, 0x00, 0x4c, 0x00, 0x41, 0x00, 0x43, 0x00, 0x4b, 0x00, 0x5f, 0x00, 0x54, 0x00, 0x45, 0x00, 0x58, 0x00, 0x54, 0x00, 0x3d, 0x00, 0x30, 0x00, 0x00, 0x00, 0x42, 0x00, 0x4c, 0x00, 0x41, 0x00, 0x43, 0x00, 0x4b, 0x00, 0x5f, 0x00, 0x46, 0x00, 0x52, 0x00, 0x41, 0x00, 0x4d, 0x00, 0x45, 0x00, 0x53, 0x00, 0x3d, 0x00, 0x30, 0x00, 0x00, 0x00, 0x54, 0x00, 0x52, 0x00, 0x41, 0x00, 0x4e, 0x00, 0x53, 0x00, 0x50, 0x00, 0x41, 0x00, 0x52, 0x00, 0x45, 0x00, 0x4e, 0x00, 0x54, 0x00, 0x5f, 0x00, 0x4c, 0x00, 0x45, 0x00, 0x53, 0x00, 0x53, 0x00, 0x3d, 0x00, 0x30, 0x00, 0x00, 0x00, 0x54, 0x00, 0x52, 0x00, 0x41, 0x00, 0x4e, 0x00, 0x53, 0x00, 0x50, 0x00, 0x41, 0x00, 0x52, 0x00, 0x45, 0x00, 0x4e, 0x00, 0x54, 0x00, 0x5f, 0x00, 0x4d, 0x00, 0x4f, 0x00, 0x52, 0x00, 0x45, 0x00, 0x3d, 0x00, 0x31, 0x00, 0x00, 0x00))
Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\WinX" -Recurse -Force
Copy-Item -Path "$pwd\config\winx\" -Destination "$env:LOCALAPPDATA\Microsoft\Windows\" -Recurse -Force
Start-Process Explorer
Start-Process $shellExePath

Write-Host "Configuring Open-Shell completed." -ForegroundColor Green

# Start-Process Explorer
# Add-Type -TypeDefinition @"
#     using System;
#     using System.Runtime.InteropServices;

#     public class Keyboard {
#         [DllImport("user32.dll", SetLastError = true)]
#         public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

#         [DllImport("user32.dll")]
#         public static extern bool SetForegroundWindow(IntPtr hWnd);

#         [DllImport("user32.dll", SetLastError = true)]
#         public static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, int dwExtraInfo);
#     }
# "@
# Start-Process Explorer
# Start-Sleep 5
# $explorerHandle = [Keyboard]::FindWindow("CabinetWClass", $null)
# [Keyboard]::SetForegroundWindow($explorerHandle) | Out-Null
# $KEYEVENTF_KEYUP = 0x2
# $VK_MENU = 0x12 # Alt key
# $VK_V = 0x56 # V key
# $VK_RETURN = 0x0D # Enter key
# [Keyboard]::keybd_event($VK_MENU, 0, 0, 0) # Alt key press
# [Keyboard]::keybd_event($VK_V, 0, 0, 0) # V key press
# [Keyboard]::keybd_event($VK_V, 0, $KEYEVENTF_KEYUP, 0) # V key release
# [Keyboard]::keybd_event($VK_MENU, 0, $KEYEVENTF_KEYUP, 0) # Alt key release
# Start-Sleep -Seconds 2
# [Keyboard]::keybd_event($VK_RETURN, 0, 0, 0) # Enter key press
# [Keyboard]::keybd_event($VK_RETURN, 0, $KEYEVENTF_KEYUP, 0) # Enter key release
# Start-Sleep -Seconds 2
# [Keyboard]::keybd_event($VK_RETURN, 0, 0, 0) # Enter key press
# [Keyboard]::keybd_event($VK_RETURN, 0, $KEYEVENTF_KEYUP, 0) # Enter key release
# Start-Sleep -Seconds 2
# Stop-Process -Name Explorer
# Start-Sleep -Seconds 2

Start-Sleep 5
Add-Type -AssemblyName System.Windows.Forms
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class MouseInput
{
    [DllImport("user32.dll", CharSet = CharSet.Auto, CallingConvention = CallingConvention.StdCall)]
    public static extern void mouse_event(uint dwFlags, uint dx, uint dy, uint cButtons, uint dwExtraInfo);

    public const uint MOUSEEVENTF_LEFTDOWN = 0x02;
    public const uint MOUSEEVENTF_LEFTUP = 0x04;

    public static void HoldLeftMouseButton()
    {
        mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
    }

    public static void ReleaseLeftMouseButton()
    {
        mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
    }
}
"@

$screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
$w = $screen.width/4
[Windows.Forms.Cursor]::Position = "$($w),$($screen.Height)"
Start-Sleep -Seconds 2
[MouseInput]::HoldLeftMouseButton()
Start-Sleep -Seconds 2
[Windows.Forms.Cursor]::Position = "$($w),1"
Start-Sleep -Seconds 2
[MouseInput]::ReleaseLeftMouseButton()
Start-Sleep -Seconds 2
$screen = [System.Windows.Forms.SystemInformation]::VirtualScreen
$centerX = $screen.Width / 2
$centerY = $screen.Height / 2
[Windows.Forms.Cursor]::Position = "$centerX,$centerY"
Start-Sleep -Milliseconds 100
[MouseInput]::HoldLeftMouseButton()
Start-Sleep -Milliseconds 100
[MouseInput]::ReleaseLeftMouseButton()
Start-Sleep -Seconds 2

Write-Host "Configuring Shell completed." -ForegroundColor Green

Write-Host "Clean up..." -ForegroundColor Yellow
Remove-Item -Path "C:\Users\Public\Desktop\Everything.lnk" -Force | Out-Null
Remove-Item -Path "C:\Users\Public\Desktop\gVim*" -Force | Out-Null
Remove-Item -Path "C:\Users\$env:USERNAME\Desktop\Everything.lnk" -Force | Out-Null
Remove-Item -Path "C:\Users\$env:USERNAME\Desktop\gVim*" -Force | Out-Null
Write-Host "Clean up completed." -ForegroundColor Green
Write-Host
Stop-Transcript

Write-Host
Write-Host "------------------------ WinMac Deployment completed ------------------------" -ForegroundColor Cyan
Write-Host @"

Enjoy and support by giving feedback and contributing to the project!

For more information please visit my GitHub page: github.com/Asteski/WinMac

If you have any questions or suggestions, please contact me on GitHub.

"@ -ForegroundColor Green

Write-Host "-----------------------------------------------------------------------------"  -ForegroundColor Cyan
Write-Host
$restartConfirmation = Read-Host "Restart computer now? It's recommended to fully apply all the changes. (y/n)"
if ($restartConfirmation -eq "Y" -or $restartConfirmation -eq "y") {
    Write-Host "Restarting computer in" -ForegroundColor Red
    for ($a=9; $a -ge 0; $a--) {
        Write-Host -NoNewLine "`b$a" -ForegroundColor Red
        Start-Sleep 1
    }
    Restart-Computer -Force
} else {
    Write-Host "Computer will not be restarted." -ForegroundColor Green
}

