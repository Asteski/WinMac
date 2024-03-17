## Winget

# get latest download url
# $URL = "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
# $URL = (Invoke-WebRequest -Uri $URL).Content | ConvertFrom-Json |
#         Select-Object -ExpandProperty "assets" |
#         Where-Object "browser_download_url" -Match '.msixbundle' |
#         Select-Object -ExpandProperty "browser_download_url"
# $LicenseFileURL = 'https://github.com/microsoft/winget-cli/releases/download/v1.7.10661/9ea36fa38dd3449c94cc839961888850_License1.xml'

# download
# Invoke-WebRequest -Uri $URL -OutFile "Setup.msix" -UseBasicParsing
# Invoke-WebRequest -Uri $LicenseFileURL -OutFile  'license.xml' 

# install
# #Add-AppxPackage -Path "Setup.msix" -LicensePath .\license.xml
# Add-AppxProvisionedPackage -PackagePath "Setup.msix" -LicensePath 'license.xml' -online 

# delete file
# Remove-Item "Setup.msix"

# apps list

$list = @(
    # "Microsoft.PowerShell", ## PowerShell Core # interactive
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
    # "Git.Git",
    'Microsoft.PowerToys',
    'Voidtools.Everything',
    'lin-ycv.EverythingPowerToys',
    'StartIsBack.StartAllBack',
    'JanDeDobbeleer.OhMyPosh'
)

# install apps

foreach ($app in $list) {
    winget install --id $app --silent --force
}

## PowerToys

$plugins = $env:LOCALAPPDATA + '\Microsoft\PowerToys\PowerToys Run\Plugins'
$winget = 'https://github.com/bostrot/PowerToysRunPluginWinget/releases/download/v1.2.3/winget-powertoys-1.2.3.zip'
$prockill = 'https://github.com/8LWXpg/PowerToysRun-ProcessKiller/releases/download/v1.0.1/ProcessKiller-v1.0.1-x64.zip'

Invoke-WebRequest -uri $winget -Method "GET"  -Outfile 'winget.zip'
Invoke-WebRequest -uri $prockill -Method "GET"  -Outfile 'prockill.zip'

Expand-Archive 'winget.zip' -DestinationPath $pwd\Winget -Force
Expand-Archive 'prockill.zip' -DestinationPath $pwd -Force

Copy-item $pwd\Winget -Destination $plugins -Recurse -Force
Copy-item $pwd\ProcessKiller -Destination $plugins -Recurse -Force

Get-ChildItem * -Include *.zip -Recurse | Remove-Item
Remove-Item -Recurse -Force Winget
Remove-Item -Recurse -Force ProcessKiller

## StartAllBack

# $registryFile = $pwd + '\StartAllBack\StartAllBack.reg'
# Start-Process -FilePath 'regedit.exe' -ArgumentList "/s $RegistryFile" -Wait

$registryPath = "HKCU:\Software\StartIsBack"

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
Set-ItemProperty -Path $registryPath -Name "TaskbarTranslucentEffect" -Value 1
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