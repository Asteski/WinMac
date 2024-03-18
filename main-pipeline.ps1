Clear-Host
Write-Host @"
------------------------ WinMac Deployment ------------------------

Welcome to WinMac Deployment!

Author: Adam Kamienski
GitHub: Asteski
Version: 0.0.2

This is Work in Progress.

"@ -ForegroundColor Cyan

# Write-Host "Checking for Windows Package Manager (WinGet)" -ForegroundColor Yellow
# $progressPreference = 'silentlyContinue'
# Write-Information "Downloading WinGet and its dependencies..."
# $wingetUrl = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
# $installPath = "$env:TEMP\winget.msixbundle"
# Invoke-WebRequest -Uri $wingetUrl -OutFile $installPath
# Write-Information "Installing WinGet..."
# Add-AppxPackage -Path $installPath
# Remove-Item -Path $installPath
# Write-Information "WinGet installation completed."

# $winget = @(
#     "9NRWMJP3717K", ## Python # interactive
#     "BotProductions.IconViewer", # interactive
#     "Brave.Brave",
#     "CPUID.CPU-Z", # interactive
#     "Helm.Helm",
#     "Irfanview.IrfanView",
#     "Logitech.OptionsPlus", # interactive
#     "Microsoft.AzureCLI", # interactive
#     "Microsoft.VisualStudioCode",
#     "Neovim.Neovim",
#     "Python.Launcher",
#     "Kuberentes.Minikube",
#     "7zip.7zip",
#     "Git.Git",
#     "Microsoft.PowerShell",
#     "JanDeDobbeleer.OhMyPosh"
# )

# Write-Host @"
# Installing Packages:

# "@ -ForegroundColor Yellow

# foreach ($app in $winget) {winget install --id $app --no-upgrade --silent}

# Write-Host "Installing Packages completed." -ForegroundColor Green

## PowerToys

Write-Host @"
Installing PowerToys...

"@ -ForegroundColor Yellow

$powerToys = @(
    'Microsoft.PowerToys',
    'Voidtools.Everything',
    'lin-ycv.EverythingPowerToys'
)

foreach ($app in $powerToys) {winget install --id $app --no-upgrade --silent}

$plugins = $env:LOCALAPPDATA + '\Microsoft\PowerToys\'
$winget = 'https://github.com/bostrot/PowerToysRunPluginWinget/releases/download/v1.2.3/winget-powertoys-1.2.3.zip'
$prockill = 'https://github.com/8LWXpg/PowerToysRun-ProcessKiller/releases/download/v1.0.1/ProcessKiller-v1.0.1-x64.zip'
Get-Process -Name PowerToys* | Stop-Process -Force
Invoke-WebRequest -uri $winget -Method "GET" -Outfile 'winget.zip'
Invoke-WebRequest -uri $prockill -Method "GET" -Outfile 'prockill.zip'
Expand-Archive 'winget.zip' -DestinationPath $pwd\Winget -Force
Expand-Archive 'prockill.zip' -DestinationPath $pwd -Force
Copy-item $pwd\Winget -Destination $plugins -Recurse -Force
Copy-item $pwd\ProcessKiller -Destination $plugins -Recurse -Force
$PowerToysProc = Get-Process -Name PowerToys*
ForEach ($proc in $PowerToysProc) {
    $proc.WaitForExit(10000)
    $proc.Kill()
}
$powerToysPath = $env:LOCALAPPDATA + '\PowerToys\PowerToys.exe'

Add-Content -Path "C:\Program Files\Everything\Everything.ini" -Value "show_tray_icon=0"
# Start-Process -FilePath "C:\Program Files\Everything\Everything.exe"
Start-Process -FilePath $powerToysPath
Remove-Item -Recurse -Force Winget
Remove-Item -Recurse -Force ProcessKiller
Get-ChildItem * -Include *.zip -Recurse | Remove-Item -Force
Write-Host "Configuring PowerToys completed." -ForegroundColor Green

## StartAllBack

Write-Host "Configuring StartAllBack..." -ForegroundColor Yellow

taskkill /f /im explorer.exe

$explorerPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\"
$sabPath = "HKCU:\Software\StartIsBack"

Set-ItemProperty -Path $explorerPath\Advanced -Name TaskbarGlomLevel -Value 1
Set-ItemProperty -Path $explorerPath\Advanced -Name "TaskbarSmallIcons" -Value 1
Set-ItemProperty -Path $explorerPath\Advanced -Name "TaskbarSi" -Value 0
Set-ItemProperty -Path $explorerPath\Advanced -Name "TaskbarAl" -Value 0
Set-ItemProperty -Path $explorerPath\Advanced -Name "UseCompactMode" -Value 1
Set-ItemProperty -Path $explorerPath\StuckRects3 -Name "Settings" -Value ([byte[]](0x30,0x00,0x00,0x00,0xfe,0xff,0xff,0xff,0x7a,0xf4,0x00,0x00,0x01,0x00,0x00,0x00,0x3c,0x00,0x00,0x00,0x3c,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xfc,0x03,0x00,0x00,0x80,0x07,0x00,0x00,0x38,0x04,0x00,0x00,0x78,0x00,0x00,0x00,0x01,0x00,0x00,0x00))

winget install --id "StartIsBack.StartAllBack" --silent --no-upgrade

Set-ItemProperty -Path $sabPath -Name "ModernIconsColorized" -Value 0
Set-ItemProperty -Path $sabPath -Name "SettingsVersion" -Value 5
Set-ItemProperty -Path $sabPath -Name "WelcomeShown" -Value 3
Set-ItemProperty -Path $sabPath -Name "UpdateCheck" -Value ([byte[]](0x44, 0xCE, 0xBE, 0x05, 0x25, 0x77, 0xDA, 0x01))
Set-ItemProperty -Path $sabPath -Name "FrameStyle" -Value 1
Set-ItemProperty -Path $sabPath -Name "AlterStyle" -Value "Plain8.msstyles"
Set-ItemProperty -Path $sabPath -Name "SysTrayStyle" -Value 1
Set-ItemProperty -Path $sabPath -Name "BottomDetails" -Value 0
Set-ItemProperty -Path $sabPath -Name "RestyleIcons" -Value 1
Set-ItemProperty -Path $sabPath -Name "NavBarGlass" -Value 1
Set-ItemProperty -Path $sabPath -Name "OldSearch" -Value 1
Set-ItemProperty -Path $sabPath -Name "NoXAMLMenus" -Value 1
Set-ItemProperty -Path $sabPath -Name "RestyleControls" -Value 0
Set-ItemProperty -Path $sabPath -Name "WinkeyFunction" -Value 0
Set-ItemProperty -Path $sabPath -Name "TaskbarJumpList" -Value 1
Set-ItemProperty -Path $sabPath -Name "TaskbarOneSegment" -Value 0
Set-ItemProperty -Path $sabPath -Name "TaskbarCenterIcons" -Value 1
Set-ItemProperty -Path $sabPath -Name "TaskbarTranslucentEffect" -Value 1
Set-ItemProperty -Path $sabPath -Name "SysTrayActionCenter" -Value 0
Set-ItemProperty -Path $sabPath -Name "TaskbarLargerIcons" -Value 0
Set-ItemProperty -Path $sabPath -Name "UndeadControlPanel" -Value 1
Set-ItemProperty -Path $sabPath -Name "LegacyTaskbar" -Value 1
Set-ItemProperty -Path $sabPath -Name "TaskbarSpacierIcons" -Value 1
Set-ItemProperty -Path $sabPath -Name "SysTrayNetwork" -Value 1
Set-ItemProperty -Path $sabPath -Name "SysTrayClockFormat" -Value 3
Set-ItemProperty -Path $sabPath -Name "TaskbarControlCenter" -Value 1
Set-ItemProperty -Path $sabPath -Name "SysTrayVolume" -Value 1
Set-ItemProperty -Path $sabPath -Name "SysTrayPower" -Value 1
Set-ItemProperty -Path $sabPath -Name "Start_LargeAllAppsIcons" -Value 0
Set-ItemProperty -Path $sabPath -Name "AllProgramsFlyout" -Value 1
Set-ItemProperty -Path $sabPath -Name "StartMetroAppsFolder" -Value 1
Set-ItemProperty -Path $sabPath -Name "Start_SortOverride" -Value 0
Set-ItemProperty -Path $sabPath -Name "Start_NotifyNewApps" -Value 1
Set-ItemProperty -Path $sabPath -Name "Start_AutoCascade" -Value 0
Set-ItemProperty -Path $sabPath -Name "Start_AskCortana" -Value 0
Set-ItemProperty -Path $sabPath -Name "HideUserFrame" -Value 1
Set-ItemProperty -Path $sabPath -Name "Start_RightPaneIcons" -Value 0
Set-ItemProperty -Path $sabPath -Name "Start_ShowUser" -Value 1
Set-ItemProperty -Path $sabPath -Name "Start_ShowMyDocs" -Value 1
Set-ItemProperty -Path $sabPath -Name "Start_ShowMyPics" -Value 1
Set-ItemProperty -Path $sabPath -Name "Start_ShowMyMusic" -Value 0
Set-ItemProperty -Path $sabPath -Name "Start_ShowVideos" -Value 1
Set-ItemProperty -Path $sabPath -Name "Start_ShowDownloads" -Value 1
Set-ItemProperty -Path $sabPath -Name "Start_ShowSkyDrive" -Value 1
Set-ItemProperty -Path $sabPath -Name "StartMenuFavorites" -Value 2
Set-ItemProperty -Path $sabPath -Name "Start_ShowRecentDocs" -Value 2
Set-ItemProperty -Path $sabPath -Name "Start_ShowNetPlaces" -Value 0
Set-ItemProperty -Path $sabPath -Name "Start_ShowNetConn" -Value 0
Set-ItemProperty -Path $sabPath -Name "Start_ShowMyComputer" -Value 1
Set-ItemProperty -Path $sabPath -Name "Start_ShowControlPanel" -Value 0
Set-ItemProperty -Path $sabPath -Name "Start_ShowPCSettings" -Value 0
Set-ItemProperty -Path $sabPath -Name "Start_AdminToolsRoot" -Value 0
Set-ItemProperty -Path $sabPath -Name "Start_ShowPrinters" -Value 0
Set-ItemProperty -Path $sabPath -Name "Start_ShowSetProgramAccessAndDefaults" -Value 0
Set-ItemProperty -Path $sabPath -Name "Start_ShowTerminal" -Value 0
Set-ItemProperty -Path $sabPath -Name "Start_ShowCommandPrompt" -Value 0
Set-ItemProperty -Path $sabPath -Name "Start_ShowRun" -Value 0
Set-ItemProperty -Path $sabPath -Name "Start_MinMFU" -Value 14
Set-ItemProperty -Path $sabPath -Name "SysTrayCopilotIcon" -Value 1
Set-ItemProperty -Path $sabPath -Name "MultiColumnFlyout" -Value 0
Set-ItemProperty -Path $sabPath -Name "Start_LargeMFUIcons" -Value 0
Set-ItemProperty -Path $sabPath -Name "SysTrayLocation" -Value 0
Set-ItemProperty -Path $sabPath -Name "SysTraySpacierIcons" -Value 1

# Set-ItemProperty -Path $sabPath -Name "ModernIconsColorized" -Value 0
# Set-ItemProperty -Path $sabPath -Name "SettingsVersion" -Value 5
# Set-ItemProperty -Path $sabPath -Name "WelcomeShown" -Value 3
# Set-ItemProperty -Path $sabPath -Name "UpdateCheck" -Value ([byte[]](0x44, 0xCE, 0xBE, 0x05, 0x25, 0x77, 0xDA, 0x01))
# Set-ItemProperty -Path $sabPath -Name "FrameStyle" -Value 2
# Set-ItemProperty -Path $sabPath -Name "OrbBitmap" -Value ""
# Set-ItemProperty -Path $sabPath -Name "AlterStyle" -Value ""
# Set-ItemProperty -Path $sabPath -Name "TaskbarStyle" -Value ""
# Set-ItemProperty -Path $sabPath -Name "SysTrayStyle" -Value 1
# Set-ItemProperty -Path $sabPath -Name "BottomDetails" -Value 0
# Set-ItemProperty -Path $sabPath -Name "RestyleIcons" -Value 1
# Set-ItemProperty -Path $sabPath -Name "NavBarGlass" -Value 1
# Set-ItemProperty -Path $sabPath -Name "OldSearch" -Value 1
# Set-ItemProperty -Path $sabPath -Name "NoXAMLMenus" -Value 1
# Set-ItemProperty -Path $sabPath -Name "RestyleControls" -Value 0
# Set-ItemProperty -Path $sabPath -Name "WinkeyFunction" -Value 0
# Set-ItemProperty -Path $sabPath -Name "TaskbarJumpList" -Value 1
# Set-ItemProperty -Path $sabPath -Name "TaskbarOneSegment" -Value 0
# Set-ItemProperty -Path $sabPath -Name "TaskbarCenterIcons" -Value 1
# Set-ItemProperty -Path $sabPath -Name "TaskbarTranslucentEffect" -Value 0
# Set-ItemProperty -Path $sabPath -Name "SysTrayActionCenter" -Value 0
# Set-ItemProperty -Path $sabPath -Name "TaskbarLargerIcons" -Value 0
# Set-ItemProperty -Path $sabPath -Name "UndeadControlPanel" -Value 1
# Set-ItemProperty -Path $sabPath -Name "LegacyTaskbar" -Value 1
# Set-ItemProperty -Path $sabPath -Name "TaskbarSpacierIcons" -Value 1
# Set-ItemProperty -Path $sabPath -Name "SysTrayNetwork" -Value 1
# Set-ItemProperty -Path $sabPath -Name "SysTrayClockFormat" -Value 3
# Set-ItemProperty -Path $sabPath -Name "TaskbarControlCenter" -Value 1
# Set-ItemProperty -Path $sabPath -Name "SysTrayVolume" -Value 1
# Set-ItemProperty -Path $sabPath -Name "SysTrayPower" -Value 1
# Set-ItemProperty -Path $sabPath -Name "Start_LargeAllAppsIcons" -Value 0
# Set-ItemProperty -Path $sabPath -Name "AllProgramsFlyout" -Value 1
# Set-ItemProperty -Path $sabPath -Name "StartMetroAppsFolder" -Value 1
# Set-ItemProperty -Path $sabPath -Name "Start_SortOverride" -Value 0
# Set-ItemProperty -Path $sabPath -Name "Start_NotifyNewApps" -Value 1
# Set-ItemProperty -Path $sabPath -Name "Start_AutoCascade" -Value 0
# Set-ItemProperty -Path $sabPath -Name "Start_AskCortana" -Value 0
# Set-ItemProperty -Path $sabPath -Name "HideUserFrame" -Value 1
# Set-ItemProperty -Path $sabPath -Name "Start_RightPaneIcons" -Value 0
# Set-ItemProperty -Path $sabPath -Name "Start_ShowUser" -Value 1
# Set-ItemProperty -Path $sabPath -Name "Start_ShowMyDocs" -Value 1
# Set-ItemProperty -Path $sabPath -Name "Start_ShowMyPics" -Value 1
# Set-ItemProperty -Path $sabPath -Name "Start_ShowMyMusic" -Value 0
# Set-ItemProperty -Path $sabPath -Name "Start_ShowVideos" -Value 1
# Set-ItemProperty -Path $sabPath -Name "Start_ShowDownloads" -Value 1
# Set-ItemProperty -Path $sabPath -Name "Start_ShowSkyDrive" -Value 1
# Set-ItemProperty -Path $sabPath -Name "StartMenuFavorites" -Value 0
# Set-ItemProperty -Path $sabPath -Name "Start_ShowRecentDocs" -Value 0
# Set-ItemProperty -Path $sabPath -Name "Start_ShowNetPlaces" -Value 0
# Set-ItemProperty -Path $sabPath -Name "Start_ShowNetConn" -Value 0
# Set-ItemProperty -Path $sabPath -Name "Start_ShowMyComputer" -Value 1
# Set-ItemProperty -Path $sabPath -Name "Start_ShowControlPanel" -Value 0
# Set-ItemProperty -Path $sabPath -Name "Start_ShowPCSettings" -Value 0
# Set-ItemProperty -Path $sabPath -Name "Start_AdminToolsRoot" -Value 0
# Set-ItemProperty -Path $sabPath -Name "Start_ShowPrinters" -Value 0
# Set-ItemProperty -Path $sabPath -Name "Start_ShowSetProgramAccessAndDefaults" -Value 0
# Set-ItemProperty -Path $sabPath -Name "Start_ShowTerminal" -Value 0
# Set-ItemProperty -Path $sabPath -Name "Start_ShowCommandPrompt" -Value 0
# Set-ItemProperty -Path $sabPath -Name "Start_ShowRun" -Value 0
# Set-ItemProperty -Path $sabPath -Name "Start_MinMFU" -Value 14
# Set-ItemProperty -Path $sabPath -Name "SysTrayCopilotIcon" -Value 1
# Set-ItemProperty -Path $sabPath -Name "MultiColumnFlyout" -Value 0
# Set-ItemProperty -Path $sabPath -Name "Start_LargeMFUIcons" -Value 0

start explorer.exe

Write-Host "Configuring StartAllBack completed." -ForegroundColor Green

## FIXME: Define ps subfolder in the project and use it to copy the function to the profile
#
# $funcPath = "$pwd\Utilities\func.ps1"
# $funcContent = Get-Content -Path $funcPath -Raw
# $filePath = Split-Path -Path $profile -Parent
# $profilePath = Split-Path -Path $filePath -Parent
# $fileName = Split-Path -Path $profile -Leaf
# if (-not (Test-Path -Path $profile)){
#     New-Item -Path $profilePath -Name 'WindowsPowershell' -ItemType Directory
#     New-Item -Path $filePath -Name $fileName -ItemType File
# }
# Add-Content -Path $profile -Value `n$funcContent

Write-Host @"
------------------------ WinMac Deployment completed ------------------------

Enjoy and support work in progress by giving feedback and contributing to the project!

WinMac function have been added to PowerShell profile. 
Use 'winmac' command to get the version of WinMac.

"@ -ForegroundColor Cyan
Sleep 2
Write-Host "This is Work in Progress. Use on your own responsibility." -ForegroundColor Magenta
Sleep 2
Write-Host "Windows will restart in 5 seconds..." -ForegroundColor Red
Sleep 5
Restart-Computer -Force
# EOF