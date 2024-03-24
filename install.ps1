#################################################################################
#                                                                               #
#                                                                               #
#                    WinMac deployment script - WinMac.ps1                      #
#                                                                               #
#                           Author: Adam Kamienski                              #
#                               GitHub: Asteski                                 #
#                               Version: 0.0.6                                  #
#                                                                               #
#                                                                               #
#################################################################################

# TODO:
# !! Force Taskbar to go on top automatically
# !! Modify Start menu/Win key actions
# ! Update $profile
# ! Add winget and prockill pliugins to PowerToys
# * Create WinMac Control Panel UWP app:
#   * Add setting to modify middle-mouse button behaviour on taskbar
#   * Taskbar Position
#   * Taskbar Alignment
#   * Taskbar Combine
#   * Taskbar Size
#   * Taskbar Transparency
#   * Explorer Mode
#   * Tools section PowerToys, StartAllBack, Everything, WinX, AutoDarkMode

# Clear-Host
Write-Host @"

------------------------ WinMac Deployment ------------------------ 

Welcome to WinMac Deployment!

Author: Adam Kamienski
GitHub: Asteski
Version: 0.0.6

This is Work in Progress.

"@ -ForegroundColor Cyan

## WinGet

Write-Host "Checking for Windows Package Manager (WinGet)" -ForegroundColor Yellow
$progressPreference = 'silentlyContinue'
Write-Information "Downloading WinGet and its dependencies..."
$wingetUrl = "https://github.com/microsoft/winget-cli/releases/latest/download/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
$installPath = "$env:TEMP\winget.msixbundle"
Invoke-WebRequest -Uri $wingetUrl -OutFile $installPath
Write-Information "Installing WinGet..."
Add-AppxPackage -Path $installPath
Remove-Item -Path $installPath
Write-Information "WinGet installation completed."

# $winget = @(
#     # "RamenSoftware.7+TaskbarTweaker",
#     # "Open-Shell.Open-Shell-Menu",
#     "Armin2208.WindowsAutoNightMode",
#     "JanDeDobbeleer.OhMyPosh",
#     "Microsoft.PowerToys",
#     "Voidtools.Everything",
#     "lin-ycv.EverythingPowerToys"
# )

# Write-Host @"
# Installing Packages:

# "@ -ForegroundColor Yellow

# foreach ($app in $winget) {winget install --id $app --no-upgrade --silent}

# Write-Host "Installing Packages completed." -ForegroundColor Green

## PowerToys

# Write-Host @"
# Configuring PowerToys...

# "@ -ForegroundColor Yellow

# $plugins = $env:LOCALAPPDATA + '\Microsoft\PowerToys\'
# $winget = 'https://github.com/bostrot/PowerToysRunPluginWinget/releases/download/v1.2.3/winget-powertoys-1.2.3.zip'
# $prockill = 'https://github.com/8LWXpg/PowerToysRun-ProcessKiller/releases/download/v1.0.1/ProcessKiller-v1.0.1-x64.zip'

# Get-Process -Name PowerToys* | Stop-Process -Force
# Invoke-WebRequest -uri $winget -Method "GET" -Outfile 'winget.zip'
# Invoke-WebRequest -uri $prockill -Method "GET" -Outfile 'prockill.zip'
# Expand-Archive 'winget.zip' -DestinationPath $pwd\Winget -Force
# Expand-Archive 'prockill.zip' -DestinationPath $pwd -Force
# Copy-item $pwd\Winget -Destination $plugins -Recurse -Force
# Copy-item $pwd\ProcessKiller -Destination $plugins -Recurse -Force

# $PowerToysProc = Get-Process -Name PowerToys*
# ForEach ($proc in $PowerToysProc) {
#     $proc.WaitForExit(10000)
#     $proc.Kill()
# }

# $powerToysPath = $env:LOCALAPPDATA + '\PowerToys\PowerToys.exe'
# Add-Content -Path "C:\Program Files\Everything\Everything.ini" -Value "show_tray_icon=0"
# Start-Process -FilePath $powerToysPath
# Remove-Item -Recurse -Force Winget
# Remove-Item -Recurse -Force ProcessKiller
# Get-ChildItem * -Include *.zip -Recurse | Remove-Item -Force
# Write-Host "Configuring PowerToys completed." -ForegroundColor Green

## StartAllBack

Write-Host "Configuring StartAllBack..." -ForegroundColor Yellow

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

$taskbarHandle = [Taskbar]::FindWindow("Shell_TrayWnd", "")
$HWND_TOP = [IntPtr]::Zero
$SWP_SHOWWINDOW = 0x0040
[Taskbar]::SetWindowPos($taskbarHandle, $HWND_TOP, 0, 0, 0, 0, $SWP_SHOWWINDOW)

$explorerPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\"
$sabRegPath = "HKCU:\Software\StartIsBack"
Set-ItemProperty -Path $explorerPath\Advanced -Name "TaskbarGlomLevel" -Value 1
Set-ItemProperty -Path $explorerPath\Advanced -Name "TaskbarSmallIcons" -Value 1
Set-ItemProperty -Path $explorerPath\Advanced -Name "TaskbarSi" -Value 0
Set-ItemProperty -Path $explorerPath\Advanced -Name "TaskbarAl" -Value 0
Set-ItemProperty -Path $explorerPath\Advanced -Name "UseCompactMode" -Value 1
# Set-ItemProperty -Path $explorerPath\StuckRects3 -Name "Settings" -Value ([byte[]](0x30,0x00,0x00,0x00,0xfe,0xff,0xff,0xff,0x7a,0xf4,0x00,0x00,0x01,0x00,0x00,0x00,0x3c,0x00,0x00,0x00,0x3c,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xfc,0x03,0x00,0x00,0x80,0x07,0x00,0x00,0x38,0x04,0x00,0x00,0x78,0x00,0x00,0x00,0x01,0x00,0x00,0x00))# reg import $pwd\tb-top.reg
winget install --id "StartIsBack.StartAllBack" --silent --no-upgrade
Set-ItemProperty -Path $sabRegPath -Name "WinBuild" -Value 22759
Set-ItemProperty -Path $sabRegPath -Name "WinLangID" -Value 2064
Set-ItemProperty -Path $sabRegPath -Name "ModernIconsColorized" -Value 0
Set-ItemProperty -Path $sabRegPath -Name "SettingsVersion" -Value 5
Set-ItemProperty -Path $sabRegPath -Name "WelcomeShown" -Value 3
Set-ItemProperty -Path $sabRegPath -Name "UpdateCheck" -Value ([byte[]](160, 224, 8, 201, 49, 125, 218, 1))
Set-ItemProperty -Path $sabRegPath -Name "FrameStyle" -Value 2
Set-ItemProperty -Path $sabRegPath -Name "WinkeyFunction" -Value 1
Set-ItemProperty -Path $sabRegPath -Name "TaskbarOneSegment" -Value 0
Set-ItemProperty -Path $sabRegPath -Name "TaskbarCenterIcons" -Value 1
Set-ItemProperty -Path $sabRegPath -Name "TaskbarTranslucentEffect" -Value 0
Set-ItemProperty -Path $sabRegPath -Name "TaskbarLargerIcons" -Value 0
Set-ItemProperty -Path $sabRegPath -Name "TaskbarSpacierIcons" -Value (-1)
Set-ItemProperty -Path $sabRegPath -Name "UpdateInfo" -Value ([byte[]](60, 63, 120, 109, 108, 32, 118, 101, 114, 115, 105, 111, 110, 61, 34, 49, 46, 48, 34, 63, 62, 10, 60, 85, 112, 100, 97, 116, 101, 32, 78, 97, 109, 101, 61, 34, 83, 116, 97, 114, 116, 65, 108, 108, 66, 97, 99, 107, 32, 51, 46, 55, 46, 55, 34, 32, 68, 101, 115, 99, 114, 105, 112, 116, 105, 111, 110, 61, 34, 34, 32, 68, 111, 119, 110, 108, 111, 97, 100, 85, 82, 76, 61, 34, 104, 116, 116, 112, 115, 58, 47, 47, 115, 116, 97, 114, 116, 105, 115, 98, 97, 99, 107, 46, 115, 102, 111, 51, 46, 99, 100, 110, 46, 100, 105, 103, 105, 116, 97, 108, 111, 99, 101, 97, 110, 115, 112, 97, 99, 101, 115, 46, 99, 111, 109, 47, 83, 116, 97, 114, 116, 65, 108, 108, 66, 97, 99, 107, 95, 51, 46, 55, 46, 55, 95, 115, 101, 116, 117, 112, 46, 101, 120, 101, 34, 32, 76, 101, 97, 114, 110, 77, 111, 114, 101, 85, 82, 76, 61, 34, 104, 116, 116, 112, 115, 58, 47, 47, 119, 119, 119, 46, 115, 116, 97, 114, 116, 97, 108, 108, 98, 97, 99, 107, 46, 99, 111, 109, 47, 34, 47, 62, 10))
Set-ItemProperty -Path $sabRegPath -Name "UpdateInfoHash" -Value 805441044
Set-ItemProperty -Path $sabRegPath -Name "SysTrayActionCenter" -Value 0
Set-ItemProperty -Path $sabRegPath -Name "TaskbarControlCenter" -Value 1
Set-ItemProperty -Path $sabRegPath -Name "SysTrayStyle" -Value 1
Set-ItemProperty -Path $sabRegPath\Cache -Name "OrbWidth.120" -Value 39
Set-ItemProperty -Path $sabRegPath\Cache -Name "OrbHeight.120" -Value 38
Set-ItemProperty -Path $sabRegPath\Cache -Name "IdealHeight.9" -Value 81930
Set-ItemProperty -Path $sabRegPath\Cache -Name "IdealWidth.9" -Value "Control Panel"
Set-ItemProperty -Path $sabRegPath\Cache -Name "IdealHeight.6" -Value 10
# Set-ItemProperty -Path $sabRegPath\Cache\Volatile -Name "WidgetsPayload" -Value "{\"type\":\"AdaptiveCard\",\"version\":\"1.3\",\"id\":\"Weather_Preview_Small\",\"speak\":\"Widgets 42°F Cloudy\",\"body\":[{\"type\":\"ColumnSet\",\"columns\":[{\"id\":\"SmallTicker1\",\"type\":\"Column\",\"width\":\"auto\",\"items\":[{\"id\":\"BadgeAnchorSmallTicker\",\"type\":\"Image\",\"size\":\"medium\",\"url\":\"https://assets.msn.com/weathermapdata/1/static/weather/Icons/KRYFGAA=/Condition/AAehyQC.png\",\"horizontalAlignment\":\"center\",\"lottieAnimation\":\"Cloudy\",\"rotationAnimation\":\"Cloudy\",\"svgUrl\":\"https://assets.msn.com/weathermapdata/1/static/weather/Icons/KRYFGAA=/Condition/AAehyQC.svg\",\"svgSize\":\"72\",\"isAnimated\":false,\"animationCount\":0,\"frameIntervalInMs\":0,\"animationDurationInMs\":0,\"animationSvgSize\":0}],\"verticalContentAlignment\":\"center\"},{\"id\":\"LargeTicker1\",\"type\":\"Column\",\"width\":\"auto\",\"items\":[{\"id\":\"BadgeAnchorLargeTicker\",\"type\":\"Image\",\"size\":\"medium\",\"url\":\"https://assets.msn.com/weathermapdata/1/static/weather/Icons/KRYFGAA=/Condition/AAehyQC.png\",\"horizontalAlignment\":\"center\",\"lottieAnimation\":\"Cloudy\",\"rotationAnimation\":\"Cloudy\",\"svgUrl\":\"https://assets.msn.com/weathermapdata/1/static/weather/Icons/KRYFGAA=/Condition/AAehyQC.svg\",\"svgSize\":\"72\",\"isAnimated\":false,\"animationCount\":0,\"frameIntervalInMs\":0,\"animationDurationInMs\":0,\"animationSvgSize\":0}],\"verticalContentAlignment\":\"center\",\"spacing\":\"none\"},{\"id\":\"LargeTicker2\",\"type\":\"Column\",\"width\":\"stretch\",\"items\":[{\"type\":\"TextBlock\",\"text\":\"42°F\",\"spacing\":\"none\"},{\"type\":\"TextBlock\",\"isSubtle\":true,\"text\":\"Cloudy\",\"spacing\":\"none\"}]}]}],\"playHoverAnimation\":true,\"playClickAnimation\":true,\"playRotationIconAnimation\":true,\"playRotationTransition\":true,\"widgetsOverlay\":{\"type\":\"AdaptiveCard\",\"version\":\"1.3\",\"id\":\"WP_Small_Normal_png\",\"speak\":\"Widgets 42°F Cloudy\",\"body\":[{\"type\":\"ColumnSet\",\"columns\":[{\"type\":\"Column\",\"items\":[{\"type\":\"TextBlock\",\"id\":\"WidgetsOverlayText\",\"size\":\"small\",\"text\":\"42°\",\"horizontalAlignment\":\"center\"}]}]}]},\"widgetsBadgeId\":\"alert_549_SN_Y\",\"widgetsBadge\":{\"type\":\"AdaptiveCard\",\"version\":\"1.3\",\"id\":\"Notification_Overlay_RedDotWithOneInside\",\"body\":[{\"type\":\"ColumnSet\",\"columns\":[{\"id\":\"WidgetsBadgeBackground\",\"type\":\"Column\",\"items\":[{\"type\":\"TextBlock\",\"id\":\"WidgetsBadgeText\",\"size\":\"small\",\"text\":\"1\",\"horizontalAlignment\":\"center\"}],\"style\":\"attention\"}]}]},\"previewSource\":\"BgTaskRotation\",\"debugId\":\"66002957-fcfd-4efb-a20e-010f69665252|2024-03-24T13:23:36.5639783Z|fabric_winfeed|WEU|WinFeed_200\",\"relatedCardId\":-1,\"contentType\":\"Weather_NormalWeather_SevereWeather_wxswysn_TkBs-0\",\"widgetsTelemetryId\":\"{1e967e74-5df9-47fe-ae4c-a8d163acfca3}\"}"
Set-ItemProperty -Path $sabRegPath\DarkMagic -Name "(default)" -Value "1"
Set-ItemProperty -Path $sabRegPath\Recolor -Name "(default)" -Value "0"
# ...

# Set-ItemProperty -Path $sabPath\DarkMagic -Name "Unround" -Value 0
# Set-ItemProperty -Path $sabPath\DarkMagic -Name "DarkMode" -Value 1
Stop-Process -Name Explorer -Force
Write-Host "Configuring StartAllBack completed." -ForegroundColor Yellow
Write-Host "Configuring Shell..." -ForegroundColor Yellow
 # winget install --id "Open-Shell.Open-Shell-Menu" --silent --no-upgrade
# New-Item -ItemType Directory -Force -Path "$env:LOCALAPPDATA\OpenShell"
# Copy-Item -Path "$pwd\config\OpenShell\DataCache.db" -Destination "$env:LOCALAPPDATA\OpenShell\DataCache.db"
$winexePath = Join-Path $pwd\bin "winx.exe"
$process = Start-Process -FilePath $winexePath -WindowStyle Minimized -PassThru
Start-Sleep -Seconds 5
$process.CloseMainWindow()
$process.WaitForExit()
taskill /IM explorer.exe /F
Start-Sleep -Seconds 3
Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\WinX" -Recurse -Force
Copy-Item -Path "$pwd\config\WinX\" -Destination "$env:LOCALAPPDATA\Microsoft\Windows\" -Recurse -Force
$ahkPath = Join-Path $pwd "ahk.exe"
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
Set-ItemProperty -Path $registryPath -Name "AutoHotKeyScript" -Value $ahkPath
Write-Host "Configuring Shell completed." -ForegroundColor Green

## ! FIXME: Define ps subfolder in the project and use it to copy the function to the profile
# function WinMac {    
#     $sab = (winget show --id StartIsBack.StartAllBack | Select-String -Pattern "Version").ToString().Split(":")[1].Trim()
#     $pt = (winget show --id Microsoft.PowerToys | Select-String -Pattern "Version").ToString().Split(":")[1].Trim()
#     $ev = (winget show --id Voidtools.Everything | Select-String -Pattern "Version").ToString().Split(":")[1].Trim()
#     $output = @{
#         'Version' = $version
#         'StartAllBackVersion' = $sab
#         'PowerToysVersion' = $pt
#         'EverythingVersion' = $ev
#     }
#     return $output
# }
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

Start-Sleep 2
Write-Host "This is Work in Progress. Use at your own risk!" -ForegroundColor Magenta

# ! Restart Computer
# Start-Sleep 2
# Write-Host "Windows will restart in 5 seconds..." -ForegroundColor Red
# Start-Sleep 5
# Restart-Computer -Force
# EOF