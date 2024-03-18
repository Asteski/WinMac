clear
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
# Write-Information "Downloading WinGet and its dependencies..." -ForegroundColor Black
# $wingetUrl = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
# $installPath = "$env:TEMP\winget.msixbundle"
# Invoke-WebRequest -Uri $wingetUrl -OutFile $installPath
# Write-Information "Installing WinGet..." -ForegroundColor Black
# Add-AppxPackage -Path $installPath
# Remove-Item -Path $installPath
# Write-Information "WinGet installation completed." -ForegroundColor Green

$list = @(
    # "9NRWMJP3717K", ## Python # interactive
    # "BotProductions.IconViewer", # interactive
    # "Brave.Brave",
    # "CPUID.CPU-Z", # interactive
    # "Helm.Helm",
    # "Irfanview.IrfanView",
    # "Logitech.OptionsPlus", # interactive
    # "Microsoft.AzureCLI", # interactive
    # "Microsoft.VisualStudioCode",
    # "Neovim.Neovim",
    # "Python.Launcher",
    # "Kuberentes.Minikube",
    # "7zip.7zip",
    "Microsoft.PowerShell",
    "JanDeDobbeleer.OhMyPosh",
    "Git.Git",
    'Microsoft.PowerToys',
    'Voidtools.Everything',
    'lin-ycv.EverythingPowerToys',
    'StartIsBack.StartAllBack'
)

Write-Host @"
Installing Packages:

"@ -ForegroundColor Yellow

foreach ($app in $list) {winget install --id $app --no-upgrade --silent}

Write-Host "Installing Packages completed." -ForegroundColor Green

## PowerToys

Write-Host "Configuring PowerToys..." -ForegroundColor Yellow

$plugins = $env:LOCALAPPDATA + '\Microsoft\PowerToys\PowerToys Run\Plugins'
$winget = 'https://github.com/bostrot/PowerToysRunPluginWinget/releases/download/v1.2.3/winget-powertoys-1.2.3.zip'
$prockill = 'https://github.com/8LWXpg/PowerToysRun-ProcessKiller/releases/download/v1.0.1/ProcessKiller-v1.0.1-x64.zip'
Get-Process -Name PowerToys* | Stop-Process -Force
Invoke-WebRequest -uri $winget -Method "GET" -Outfile 'winget.zip'
Expand-Archive 'winget.zip' -DestinationPath $pwd\Winget -Force
Copy-item $pwd\Winget -Destination $plugins -Recurse -Force
# Invoke-WebRequest -uri $prockill -Method "GET" -Outfile 'prockill.zip'
# Expand-Archive 'prockill.zip' -DestinationPath $pwd -Force
# Copy-item $pwd\ProcessKiller -Destination $plugins -Recurse -Force
$PowerToysProc = Get-Process -Name PowerToys*
ForEach ($proc in $PowerToysProc) {
    $proc.WaitForExit(10000)
    $proc.Kill()
}
Start-Process -FilePath PowerToys.Runner.exe
Remove-Item -Recurse -Force Winget
# Remove-Item -Recurse -Force ProcessKiller
Get-ChildItem * -Include *.zip -Recurse | Remove-Item -Force

Write-Host "Installing Packages completed." -ForegroundColor Green

## StartAllBack

Write-Host "Configuring StartAllBack..." -ForegroundColor Yellow

$registryPath = "HKCU:\Software\StartIsBack"
$cachePath = "HKCU:\Software\StartIsBack\Cache"

Set-ItemProperty -Path $registryPath -Name "WinBuild" -Value 0x5867
Set-ItemProperty -Path $registryPath -Name "WinLangID" -Value 0x0409
Set-ItemProperty -Path $registryPath -Name "ModernIconsColorized" -Value 0
Set-ItemProperty -Path $registryPath -Name "SettingsVersion" -Value 5
Set-ItemProperty -Path $registryPath -Name "WelcomeShown" -Value 3
Set-ItemProperty -Path $registryPath -Name "UpdateCheck" -Value ([byte[]](0x44, 0xCE, 0xBE, 0x05, 0x25, 0x77, 0xDA, 0x01))
Set-ItemProperty -Path $registryPath -Name "FrameStyle" -Value 2
Set-ItemProperty -Path $registryPath -Name "OrbBitmap" -Value ""
Set-ItemProperty -Path $registryPath -Name "AlterStyle" -Value ""
Set-ItemProperty -Path $registryPath -Name "TaskbarStyle" -Value ""
Set-ItemProperty -Path $registryPath -Name "SysTrayStyle" -Value 1
Set-ItemProperty -Path $registryPath -Name "BottomDetails" -Value 0
Set-ItemProperty -Path $registryPath -Name "RestyleIcons" -Value 1
Set-ItemProperty -Path $registryPath -Name "NavBarGlass" -Value 1
Set-ItemProperty -Path $registryPath -Name "OldSearch" -Value 1
Set-ItemProperty -Path $registryPath -Name "NoXAMLMenus" -Value 1
Set-ItemProperty -Path $registryPath -Name "RestyleControls" -Value 0
Set-ItemProperty -Path $registryPath -Name "WinkeyFunction" -Value 0
Set-ItemProperty -Path $registryPath -Name "TaskbarJumpList" -Value 1
Set-ItemProperty -Path $registryPath -Name "TaskbarOneSegment" -Value 0
Set-ItemProperty -Path $registryPath -Name "TaskbarCenterIcons" -Value 1
Set-ItemProperty -Path $registryPath -Name "TaskbarTranslucentEffect" -Value 0
Set-ItemProperty -Path $registryPath -Name "SysTrayActionCenter" -Value 0
Set-ItemProperty -Path $registryPath -Name "TaskbarLargerIcons" -Value 0
Set-ItemProperty -Path $registryPath -Name "UndeadControlPanel" -Value 1
Set-ItemProperty -Path $registryPath -Name "LegacyTaskbar" -Value 1
Set-ItemProperty -Path $registryPath -Name "TaskbarSpacierIcons" -Value -1
Set-ItemProperty -Path $registryPath -Name "SysTrayNetwork" -Value 1
Set-ItemProperty -Path $registryPath -Name "SysTrayClockFormat" -Value 3
Set-ItemProperty -Path $registryPath -Name "TaskbarControlCenter" -Value 1
Set-ItemProperty -Path $registryPath -Name "SysTrayVolume" -Value 1
Set-ItemProperty -Path $registryPath -Name "SysTrayPower" -Value 1
Set-ItemProperty -Path $registryPath -Name "CustomColors" -Value @{
    "ColorA" = "FFFFFFFF"
    "ColorB" = "FFFFFFFF"
    "ColorC" = "FFFFFFFF"
    "ColorD" = "FFFFFFFF"
    "ColorE" = "FFFFFFFF"
    "ColorF" = "FFFFFFFF"
    "ColorG" = "FFFFFFFF"
    "ColorH" = "FFFFFFFF"
    "ColorI" = "FFFFFFFF"
    "ColorJ" = "FFFFFFFF"
    "ColorK" = "FFFFFFFF"
    "ColorL" = "FFFFFFFF"
    "ColorM" = "FFFFFFFF"
    "ColorN" = "FFFFFFFF"
    "ColorO" = "FFFFFFFF"
    "ColorP" = "FFFFFFFF"
}
Set-ItemProperty -Path $registryPath -Name "Start_LargeAllAppsIcons" -Value 0
Set-ItemProperty -Path $registryPath -Name "AllProgramsFlyout" -Value 1
Set-ItemProperty -Path $registryPath -Name "StartMetroAppsFolder" -Value 1
Set-ItemProperty -Path $registryPath -Name "Start_SortOverride" -Value 0
Set-ItemProperty -Path $registryPath -Name "Start_NotifyNewApps" -Value 1
Set-ItemProperty -Path $registryPath -Name "Start_AutoCascade" -Value 0
Set-ItemProperty -Path $registryPath -Name "Start_AskCortana" -Value 0
Set-ItemProperty -Path $registryPath -Name "HideUserFrame" -Value 1
Set-ItemProperty -Path $registryPath -Name "Start_RightPaneIcons" -Value 0
Set-ItemProperty -Path $registryPath -Name "Start_ShowUser" -Value 1
Set-ItemProperty -Path $registryPath -Name "Start_ShowMyDocs" -Value 1
Set-ItemProperty -Path $registryPath -Name "Start_ShowMyPics" -Value 1
Set-ItemProperty -Path $registryPath -Name "Start_ShowMyMusic" -Value 0
Set-ItemProperty -Path $registryPath -Name "Start_ShowVideos" -Value 1
Set-ItemProperty -Path $registryPath -Name "Start_ShowDownloads" -Value 1
Set-ItemProperty -Path $registryPath -Name "Start_ShowSkyDrive" -Value 1
Set-ItemProperty -Path $registryPath -Name "StartMenuFavorites" -Value 0
Set-ItemProperty -Path $registryPath -Name "Start_ShowRecentDocs" -Value 0
Set-ItemProperty -Path $registryPath -Name "Start_ShowNetPlaces" -Value 0
Set-ItemProperty -Path $registryPath -Name "Start_ShowNetConn" -Value 0
Set-ItemProperty -Path $registryPath -Name "Start_ShowMyComputer" -Value 1
Set-ItemProperty -Path $registryPath -Name "Start_ShowControlPanel" -Value 0
Set-ItemProperty -Path $registryPath -Name "Start_ShowPCSettings" -Value 0
Set-ItemProperty -Path $registryPath -Name "Start_AdminToolsRoot" -Value 0
Set-ItemProperty -Path $registryPath -Name "Start_ShowPrinters" -Value 0
Set-ItemProperty -Path $registryPath -Name "Start_ShowSetProgramAccessAndDefaults" -Value 0
Set-ItemProperty -Path $registryPath -Name "Start_ShowTerminal" -Value 0
Set-ItemProperty -Path $registryPath -Name "Start_ShowCommandPrompt" -Value 0
Set-ItemProperty -Path $registryPath -Name "Start_ShowRun" -Value 0
Set-ItemProperty -Path $registryPath -Name "Start_MinMFU" -Value 14
Set-ItemProperty -Path $registryPath -Name "SysTrayCopilotIcon" -Value 1
Set-ItemProperty -Path $registryPath -Name "MultiColumnFlyout" -Value 0
Set-ItemProperty -Path $registryPath -Name "Start_LargeMFUIcons" -Value 0

Set-ItemProperty -Path $cachePath -Name "OrbWidth.120" -Value 0x00000027
Set-ItemProperty -Path $cachePath -Name "OrbHeight.120" -Value 0x00000026
Set-ItemProperty -Path $cachePath -Name "IdealHeight.6" -Value 0x00000000
Set-ItemProperty -Path $cachePath -Name "IdealHeight.9" -Value 0x00010007
Set-ItemProperty -Path $cachePath -Name "IdealWidth.9" -Value "OneDrive"
Set-ItemProperty -Path $cachePath -Name "OrbWidth.96" -Value 0x00000020
Set-ItemProperty -Path $cachePath -Name "OrbHeight.96" -Value 0x0000001e
Set-ItemProperty -Path $cachePath -Name "IdealHeight.7" -Value 0x00000000
Set-ItemProperty -Path $cachePath -Name "OrbWidth.144" -Value 0x00000030
Set-ItemProperty -Path $cachePath -Name "OrbHeight.144" -Value 0x0000002e

Stop-Process -Name "explorer" -Force
Write-Host "Configuring StartAllBack completed." -ForegroundColor Green
Sleep 5
Write-Host @"

Adding WinMac function to PowerShell profile. Function will be appended to PowerShell profile file.

Call it in PowerShell to get the version of WinMac using 'winmac' command.

"@ -ForegroundColor Yellow

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

"@ -ForegroundColor Cyan
Write-Host @"
This is Work in Progress. Use it on your own responsibility.

"@ -ForegroundColor Magenta
# EOF