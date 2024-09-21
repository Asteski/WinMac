Clear-Host
$user = [Security.Principal.WindowsIdentity]::GetCurrent();
$adminTest = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
Write-Host @"
-----------------------------------------------------------------------

Welcome to WinMac Deployment!

Author: Asteski
Version: 0.6.0

This is work in progress. You're using this script at your own risk.

-----------------------------------------------------------------------
"@ -ForegroundColor Cyan
Write-Host @"

This script is responsible for installing all or specific WinMac 
components.

PowerShell profile files will be removed and replaced with new ones.
Please make sure to backup your current profiles if needed.

The author of this script is not responsible for any damage caused by 
running it. It is highly recommended to create a system restore point 
before proceeding with the installation process to ensure you can 
revert any changes if necessary.

For guide on how to use the script, please refer to the Wiki page 
on WinMac GitHub page.

"@ -ForegroundColor Yellow
if (-not $adminTest) {
    Write-Host "Script is not running in elevated session." -ForegroundColor Red
}
else {
    Write-Host "Script is running in elevated session." -ForegroundColor Green
}
Write-Host "`n-----------------------------------------------------------------------" -ForegroundColor Cyan
# $errorActionPreference="SilentlyContinue"
# Show Output function
$ShowOutput = $false
$date = Get-Date -Format "yy-MM-ddTHHmmss"
$logFile = "WinMac_install_log_$date.txt"
# Create temp and logs directories if they don't exist
if (-not (Test-Path -Path "./temp")) {New-Item -ItemType Directory -Path "./temp" | Out-Null}
if (-not (Test-Path -Path "./logs")) {New-Item -ItemType Directory -Path "./logs" | Out-Null}
function Invoke-WithOutput {
    param ([scriptblock]$Command)
    $output = & $Command 2>&1
    $output | Out-File -FilePath ".\logs\$logFile" -Append
    if ($ShowOutput -and $output) {$output}
}
# Directory check
$checkDir = Get-ChildItem
if (!($checkDir -like "*WinMac*" -and $checkDir -like "*config*" -and $checkDir -like "*bin*")) {
    Write-Host "`nWinMac components not found. Please make sure to run the script from the correct directory." -ForegroundColor Red
    Start-Sleep 2
    exit
}
# WinMac configuration
Write-Host
$fullOrCustom = Read-Host "Enter 'F' for full or 'C' for custom installation"
if ($fullOrCustom -eq 'F' -or $fullOrCustom -eq 'f') {
    Write-Host "Choosing full installation." -ForegroundColor Green
    $selectedApps = "1","2","3","4","5","6","7","8","9","10","11"
} 
elseif ($fullOrCustom -eq 'C' -or $fullOrCustom -eq 'c') {
    Write-Host "Choosing custom installation." -ForegroundColor Green
    Start-Sleep 1
    $appList = @{"1"="PowerToys"; "2"="Everything"; "3"="Powershell Profile"; "4"="StartAllBack"; "5"="WinMac Menu"; "6"="TopNotify"; "7"="Stahky"; "8"="Keyboard Shortcuts"; "9"="Launchpad"; "10"="Nexus Dock"; "11"="Other Settings"}
Write-Host @"

$([char]27)[93m$("Please select options you want to install:")$([char]27)[0m

"@
Write-Host @'
Main Components:
 1. PowerToys
 2. Everything
 3. Powershell Profile
 4. StartAllBack
 5. WinMac Menu
 6. TopNotify
 7. Stahky
 8. Keyboard Shortcuts
 9. Launchpad
10. Dock
11. Other Settings:
  • Black Cursor
  • Pin Home, Programs and Recycle Bin to Quick Access
  • Remove Shortcut Arrows
  • Remove Recycle Bin from Desktop
  • Add End Task to context menu
'@
    $selection = Read-Host "Enter the numbers of options you want to install (separated by commas)"
    $selectedApps = @()
    $selectedApps = $selection.Split(',')
    $selectedAppNames = @()
    foreach ($appNumber in $selectedApps) {
        if ($appList.ContainsKey($appNumber)) {
            $selectedAppNames += $appList[$appNumber]
        }
    }
    Write-Host "$([char]27)[92m$("Selected options:")$([char]27)[0m $($selectedAppNames -join ', ')"
}
else
{
    Write-Host "Invalid input. Defaulting to full installation." -ForegroundColor Yellow
    $selectedApps = "1","2","3","4","5","6","7","8","9","10","11"
}

if ($selectedApps -like '*4*' -or $selectedApps -like '*5*') {
Write-Host @"

$([char]27)[93m$("You can choose between WinMac start menu or Classic start menu.")$([char]27)[0m

WinMac start menu replaces default menu with customized WinX menu.

Classic start menu replaces default menu with enhanced Windows 7 start menu.

"@

    $menuSet = Read-Host "Enter 'X' for WinMac start menu or 'C' for Classic start menu"
    if ($menuSet -eq 'x' -or $menuSet -eq 'X') {
        Write-Host "Using WinMac start menu." -ForegroundColor Green
    }
    elseif ($menuSet -eq 'c'-or $menuSet -eq 'C')
    { 
        Write-Host "Using Classic start menu." -ForegroundColor Green
    }
    else
    {
        Write-Host "Invalid input. Defaulting to WinMac start menu." -ForegroundColor Yellow
        $menuSet = 'X'
    }
}

if ($selectedApps -like '*3*') {
Write-Host @"

$([char]27)[93m$("You can choose between WinMac prompt or MacOS-like prompt.")$([char]27)[0m

WinMac prompt: 
12:35:06 userName @ ~ > 

MacOS prompt:
userName@computerName ~ % 

"@
    $promptSet = Read-Host "Enter 'W' for WinMac prompt or 'M' for MacOS prompt"
    if ($promptSet -eq 'W' -or $promptSet -eq 'w') {
        Write-Host "Using WinMac prompt." -ForegroundColor Green
    }
    elseif ($promptSet -eq 'M' -or $promptSet -eq 'm')
    { 
        Write-Host "Using MacOS prompt." -ForegroundColor Green
    }
    else
    {
        Write-Host "Invalid input. Defaulting to WinMac prompt." -ForegroundColor Yellow
        $promptSet = 'W'
    }
}

if ($selectedApps -like '*4*') {
    $roundedOrSquared = Read-Host "`nEnter 'R' for rounded or 'S' for squared shell corners"
    if ($roundedOrSquared -eq 'R' -or $roundedOrSquared -eq 'r') {
        Write-Host "Using rounded corners." -ForegroundColor Green
    }
    elseif ($roundedOrSquared -eq 'S' -or $roundedOrSquared -eq 's') {
        Write-Host "Using squared corners." -ForegroundColor Green
    }
    else
    {
        Write-Host "Invalid input. Defaulting to rounded corners." -ForegroundColor Yellow
        $roundedOrSquared = 'R'
    }
}

if ($selectedApps -like '*4*' -or $selectedApps -like '*7*') {
    $lightOrDark = Read-Host "`nEnter 'L' for light or 'D' for dark themed Windows"
    if ($lightOrDark -eq "L" -or $lightOrDark -eq "l") {
        Write-Host "Using light theme." -ForegroundColor Green
        $stackTheme = 'light'
        $orbTheme = 'black.svg'
    } elseif ($lightOrDark -eq "D" -or $lightOrDark -eq "d") {
        Write-Host "Using dark theme." -ForegroundColor Green
        $stackTheme = 'dark'
        $orbTheme = 'white.svg'
    } else {
        Write-Host "Invalid input. Defaulting to light theme." -ForegroundColor Yellow
        $stackTheme = 'light'
        $orbTheme = 'black.svg'
    }
}

Start-Sleep 1
$installConfirmation = Read-Host "`nAre you sure you want to start the installation process (y/n)"

if ($installConfirmation -ne 'y') {
    Write-Host "Installation process aborted." -ForegroundColor Red
    Start-Sleep 2
    exit
}
Write-Host @"

Please do not do anything while the script is running, as it may impact the installation process.
"@ -ForegroundColor Red
Start-Sleep 2
Write-Host "`nStarting installation process in..." -ForegroundColor Green
for ($a=3; $a -ge 0; $a--) {
    Write-Host -NoNewLine "`b$a" -ForegroundColor Green
    Start-Sleep 1
}

Write-Host "`n-----------------------------------------------------------------------`n" -ForegroundColor Cyan
# Nuget
Write-Host "Checking for Package Provider (Nuget)" -ForegroundColor Yellow
$nugetProvider = Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue
if ($null -eq $nugetProvider) {
    Write-Host "NuGet is not installed. Installing NuGet..." -ForegroundColor Yellow
    Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
    Write-Host "NuGet installation completed." -ForegroundColor Green
} else {
    Write-Host "NuGet is already installed." -ForegroundColor Green
}
# Winget
Write-Host "Checking for Package Manager (Winget)" -ForegroundColor Yellow
$wingetCliCheck = winget -v
if ($null -eq $wingetCliCheck) {
    $progressPreference = 'silentlyContinue'
    Write-Information "Downloading Winget and its dependencies..."
    Invoke-WebRequest -Uri 'https://aka.ms/getwinget' -OutFile '.\temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
    Invoke-WebRequest -Uri 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx' -OutFile '.\temp\Microsoft.VCLibs.x64.14.00.Desktop.appx'
    Invoke-WebRequest -Uri 'https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx' -OutFile '.\temp\Microsoft.UI.Xaml.2.8.x64.appx'
    Add-AppxPackage '.\temp\Microsoft.VCLibs.x64.14.00.Desktop.appx'
    Add-AppxPackage '.\temp\Microsoft.UI.Xaml.2.8.x64.appx'
    Add-AppxPackage '.\temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
}
Import-Module -Name Microsoft.WinGet.Client -Force -ErrorAction SilentlyContinue | Out-Null
$wingetCheck = Get-WinGetVersion -ErrorAction SilentlyContinue | Out-Null
if ($null -eq $wingetClientCheck) {
    Write-Host "Installing Winget..." -ForegroundColor Yellow
    Install-Module -Name Microsoft.WinGet.Client -Force
    Write-Host "Winget installation completed." -ForegroundColor Green
} else {
    $wingetFind = Find-Module Microsoft.WinGet.Client
    if ($wingetCheck -ne $wingetFind.Version) {
        Write-Host "Never version is available. Updating Winget..." -ForegroundColor Yellow
        Update-Module -Name Microsoft.WinGet.Client -Force
        Write-Host "Winget update completed." -ForegroundColor Green
    } else {
        Write-Host "$([char]27)[92m$("Winget is already installed.")$([char]27)[0m Version: $($wingetCheck)"
    }
}
Import-Module -Name Microsoft.WinGet.Client -Force -ErrorAction SilentlyContinue

# WinMac deployment
foreach ($app in $selectedApps) {
    switch ($app.Trim()) {
    # PowerToys
        "1" {
            Write-Host "Installing PowerToys..." -ForegroundColor Yellow
            Invoke-WithOutput {winget configure .\config\powertoys.dsc.yaml --accept-configuration-agreements}
            Write-Host "PowerToys installation completed." -ForegroundColor Green
        }
        # Everything
        "2" {
            Write-Host "Installing Everything..." -ForegroundColor Yellow
            Invoke-WithOutput {Install-WinGetPackage -Id "Voidtools.Everything"}
            $programsDir = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs"
            Invoke-WithOutput { Move-Item -Path "C:\Users\Public\Desktop\Everything.lnk" -Destination $programsDir -Force -ErrorAction SilentlyContinue }
            Invoke-WithOutput { Move-Item -Path "C:\Users\$env:USERNAME\Desktop\Everything.lnk" -Destination $programsDir -Force -ErrorAction SilentlyContinue }
            Invoke-WithOutput { Start-Process -FilePath Everything.exe -WorkingDirectory $env:PROGRAMFILES\Everything -WindowStyle Hidden }
            Write-Host "Everything installation completed." -ForegroundColor Green
        }
        # PowerShell Profile
        "3" {
            Write-Host "Configuring PowerShell Profile..." -ForegroundColor Yellow
            $profilePath = $PROFILE | Split-Path | Split-Path
            $profileFile = $PROFILE | Split-Path -Leaf
            if ($promptSet -eq 'W' -or $promptSet -eq 'w') { $prompt = Get-Content "$pwd\config\terminal\winmac-prompt.ps1" -Raw }
            elseif ($promptSet -eq 'M' -or $promptSet -eq 'm') { $prompt = Get-Content "$pwd\config\terminal\macos-prompt.ps1" -Raw }
            $functions = Get-Content "$pwd\config\terminal\functions.ps1" -Raw
            Invoke-WithOutput { 
                if (-not (Test-Path "$profilePath\PowerShell")) { New-Item -ItemType Directory -Path "$profilePath\PowerShell" } 
                else { Remove-Item -Path "$profilePath\PowerShell\$profileFile" -Force } 
                }
            Invoke-WithOutput { 
                if (-not (Test-Path "$profilePath\WindowsPowerShell")) { New-Item -ItemType Directory -Path "$profilePath\WindowsPowerShell" } 
                else { Remove-Item -Path "$profilePath\WindowsPowerShell\$profileFile" -Force } 
                }
            Invoke-WithOutput { 
                if (-not (Test-Path "$profilePath\PowerShell\$profileFile")) { New-Item -ItemType File -Path "$profilePath\PowerShell\$profileFile" } 
                }
            Invoke-WithOutput { 
                if (-not (Test-Path "$profilePath\WindowsPowerShell\$profileFile")) { New-Item -ItemType File -Path "$profilePath\WindowsPowerShell\$profileFile" } 
                }
            $winget = @(
                "Vim.Vim",
                "gsass1.NTop"
                )
            foreach ($app in $winget) {Invoke-WithOutput { winget install --id $app --source winget --silent }}
            $vimParentPath = Join-Path $env:PROGRAMFILES Vim
            $latestSubfolder = Invoke-WithOutput { Get-ChildItem -Path $vimParentPath -Directory | Sort-Object -Property CreationTime -Descending | Select-Object -First 1 }
            $vimChildPath = $latestSubfolder.FullName
            Invoke-WithOutput { [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$vimChildPath", [EnvironmentVariableTarget]::Machine) }
            Invoke-WithOutput { Install-Module PSTree -Force }
            $programsDir = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs"
            Invoke-WithOutput { Add-Content -Path "$profilePath\PowerShell\$profileFile" -Value $prompt }
            Invoke-WithOutput { Add-Content -Path "$profilePath\PowerShell\$profileFile" -Value $functions }
            Invoke-WithOutput { Add-Content -Path "$profilePath\WindowsPowerShell\$profileFile" -Value $functions }
            Invoke-WithOutput { Move-Item -Path "C:\Users\Public\Desktop\gVim*" -Destination $programsDir -Force -ErrorAction SilentlyContinue }
            Invoke-WithOutput { Move-Item -Path "C:\Users\$env:USERNAME\Desktop\gVim*" -Destination $programsDir -Force -ErrorAction SilentlyContinue }
            Invoke-WithOutput { Move-Item -Path "C:\Users\$env:USERNAME\OneDrive\Desktop\gVim*" -Destination $programsDir -Force -ErrorAction SilentlyContinue }
            Write-Host "PowerShell Profile configuration completed." -ForegroundColor Green
        }
        # StartAllBack
        "4" {
            Write-Host "Installing StartAllBack..." -ForegroundColor Yellow 
            Invoke-WithOutput {Install-WinGetPackage -Id "StartIsBack.StartAllBack"}
            $exRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
            $sabOrbs = $env:localAPPDATA + "\StartAllBack\Orbs"
            $sabRegPath = "HKCU:\Software\StartIsBack"
            $taskbarOnTopPath = "$exRegPath\StuckRectsLegacy"
            $taskbarOnTopName = "Settings"
            $taskbarOnTopValue = @(0x30,0x00,0x00,0x00,0xfe,0xff,0xff,0xff,0x02,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x5a,0x00,0x00,0x00,0x32,0x00,0x00,0x00,0x26,0x07,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x07,0x00,0x00,0x38,0x04,0x00,0x00,0x78,0x00,0x00,0x00,0x01,0x00,0x00,0x00)
            Invoke-WithOutput {New-Item -Path $taskbarOnTopPath -Force}
            Invoke-WithOutput {New-ItemProperty -Path $taskbarOnTopPath -Name $taskbarOnTopName -Value $taskbarOnTopValue -PropertyType Binary}
            Invoke-WithOutput {Copy-Item $pwd\config\taskbar\orbs\* $sabOrbs -Force}
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
            Set-ItemProperty -Path $sabRegPath -Name "RestyleControls" -Value 1
            Set-ItemProperty -Path $sabRegPath -Name "WelcomeShown" -Value 3
            Set-ItemProperty -Path $sabRegPath -Name "SettingsVersion" -Value 5
            Set-ItemProperty -Path $sabRegPath -Name "ModernIconsColorized" -Value 0
            Set-ItemProperty -Path $sabRegPath -Name "FrameStyle" -Value 2
            Set-ItemProperty -Path $sabRegPath -Name "TaskbarOneSegment" -Value 0
            Set-ItemProperty -Path $sabRegPath -Name "TaskbarCenterIcons" -Value 1
            Set-ItemProperty -Path $sabRegPath -Name "TaskbarTranslucentEffect" -Value 0
            Set-ItemProperty -Path $sabRegPath -Name "TaskbarLargerIcons" -Value 0
            Set-ItemProperty -Path $sabRegPath -Name "TaskbarSpacierIcons" -Value (-1)
            Set-ItemProperty -Path $sabRegPath -Name "TaskbarControlCenter" -Value 1
            Set-ItemProperty -Path $sabRegPath -Name "SysTrayStyle" -Value 1
            Set-ItemProperty -Path $sabRegPath -Name "SysTrayActionCenter" -Value 1
            Set-ItemProperty -Path $sabRegPath -Name "SysTraySpacierIcons" -Value 1
            Set-ItemProperty -Path $sabRegPath -Name "SysTrayClockFormat" -Value 3
            Set-ItemProperty -Path $sabRegPath -Name "SysTrayInputSwitch" -Value 0
            Set-ItemProperty -Path $sabRegPath -Name "OrbBitmap" -Value "$($orbTheme)"
            if ($menuSet -eq 'X'-or $menuSet -eq 'x'){ Set-ItemProperty -Path $sabRegPath -Name "WinkeyFunction" -Value 1 }
            else { Set-ItemProperty -Path $sabRegPath -Name "WinkeyFunction" -Value 0 }
            Set-ItemProperty -Path $sabRegPath\DarkMagic -Name "(default)" -Value 1
            Set-ItemProperty -Path $sabRegPath\DarkMagic -Name "DarkMode" -Value 1
            if ($roundedOrSquared -eq 'R' -or $roundedOrSquared -eq 'r') { Set-ItemProperty -Path $sabRegPath\DarkMagic -Name "Unround" -Value 0 }
            else { Set-ItemProperty -Path $sabRegPath\DarkMagic -Name "Unround" -Value 1 }
            Invoke-WithOutput {Stop-Process -Name explorer -Force}
            Start-Sleep 2
            Write-Host "StartAllBack installation completed." -ForegroundColor Green
        }
        # WinMac Menu
        "5" {
            if ($adminTest) {
                Write-Host "WinMac Menu requires administrative privileges. Please run the script as an administrator. Skipping installation." -ForegroundColor Red
            } else {
            if ($menuSet -eq 'X'-or $menuSet -eq 'x') {
                Write-Host "Installing WinMac Menu..." -ForegroundColor Yellow
                winget install --id Microsoft.DotNet.DesktopRuntime.6 --silent | Out-Null
                Invoke-WebRequest -Uri 'https://github.com/dongle-the-gadget/WinverUWP/releases/download/v2.1.0.0/2505FireCubeStudios.WinverUWP_2.1.4.0_neutral_._k45w5yt88e21j.AppxBundle' -OutFile '2505FireCubeStudios.WinverUWP_2.1.4.0_neutral_._k45w5yt88e21j.AppxBundle'
                Add-AppxPackage -Path '2505FireCubeStudios.WinverUWP_2.1.4.0_neutral_._k45w5yt88e21j.AppxBundle'
                New-Item -ItemType Directory -Path "$env:LOCALAPPDATA\WinMac\" -ErrorAction SilentlyContinue
                $sysType = (Get-WmiObject -Class Win32_ComputerSystem).SystemType
                $exeKeyPath = "$env:LOCALAPPDATA\WinMac\windowskey.exe"
                $exeStartPath = "$env:LOCALAPPDATA\WinMac\startbutton.exe"
                $folderName = "WinMac"
                $taskService = New-Object -ComObject "Schedule.Service"
                $taskService.Connect() | Out-Null
                $rootFolder = $taskService.GetFolder("\")
                try { $existingFolder = $rootFolder.GetFolder($folderName) } catch { $existingFolder = $null }                
                if ($null -eq $existingFolder) { $rootFolder.CreateFolder($folderName) | Out-Null }
                $taskFolder = "\" + $folderName
                $principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
                $trigger = New-ScheduledTaskTrigger -AtLogon
                $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -MultipleInstances IgnoreNew
                $actionWinKey = New-ScheduledTaskAction -Execute 'WindowsKey.exe' -WorkingDirectory "$env:PROGRAMFILES\WinMac\"
                $actionStartButton = New-ScheduledTaskAction -Execute "StartButton.ahk" -WorkingDirectory "$env:PROGRAMFILES\WinMac\"
                $processes = @("windowskey", "startbutton")
                foreach ($process in $processes) {
                    $runningProcess = Get-Process -Name $process -ErrorAction SilentlyContinue
                    if ($runningProcess) {Stop-Process -Name $process -Force}
                }
                if ($sysType -like "*ARM*") {Copy-Item -Path .\bin\menu\arm64\* -Destination "$env:LOCALAPPDATA\WinMac\" -Recurse -Force | Out-Null}
                else {Copy-Item -Path .\bin\menu\x64\* -Destination "$env:LOCALAPPDATA\WinMac\" -Recurse -Force | Out-Null}
                Copy-Item -Path .\bin\menu\startbutton.exe -Destination "$env:LOCALAPPDATA\WinMac\" -Recurse -Force | Out-Null
                Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\WinX" -Recurse -Force
                Copy-Item -Path "$pwd\config\winx\" -Destination "$env:LOCALAPPDATA\Microsoft\Windows\" -Recurse -Force | Out-Null
                Register-ScheduledTask -TaskName "StartButton" -Action $actionStartButton -Trigger $trigger -Principal $principal -Settings $settings -TaskPath $taskFolder -ErrorAction SilentlyContinue | Out-Null
                Register-ScheduledTask -TaskName "WindowsKey" -Action $actionWinKey -Trigger $trigger -Principal $principal -Settings $settings -TaskPath $taskFolder -ErrorAction SilentlyContinue | Out-Null
                Start-Process $exeKeyPath
                Start-Process $exeStartPath
                Write-Host "WinMac Menu installation completed." -ForegroundColor Green
            }
            else {Write-Host "Skipping WinMac Menu installation." -ForegroundColor Magenta}
            }
        }
        # TopNotify
        "6" {
            Write-Host "Installing TopNotify..." -ForegroundColor Yellow
            winget install --name TopNotify --silent --accept-package-agreements --accept-source-agreements | Out-Null
            $app = Get-AppxPackage *TopNotify*
            Start-Process -FilePath TopNotify.exe -WorkingDirectory $app.InstallLocation
            $pkgName = $app.PackageFamilyName
            $startupTask = ($app | Get-AppxPackageManifest).Package.Applications.Application.Extensions.Extension | Where-Object -Property Category -Eq -Value windows.startupTask
            $taskId = $startupTask.StartupTask.TaskId
            Start-Process Taskmgr -WindowStyle Hidden
            while (!(Get-ItemProperty -Path "HKCU:Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\$pkgName\$taskId" -Name State -ErrorAction SilentlyContinue)) {Start-Sleep -Seconds 1}
            Stop-Process -Name Taskmgr
            $regKey = "HKCU:Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\$pkgName\$taskId"
            Set-ItemProperty -Path $regKey -Name UserEnabledStartupOnce -Value 1
            Set-ItemProperty -Path $regKey -Name State -Value 2
            Write-Host "TopNotify installation completed." -ForegroundColor Green
        }
        # Stahky
        "7" {
            Write-Host "Installing Stahky..." -ForegroundColor Yellow
            $url = "https://github.com/joedf/stahky/releases/download/v0.1.0.8/stahky_U64_v0.1.0.8.zip"
            $outputPath = "$pwd\stahky_U64.zip"
            $exePath = "$env:LOCALAPPDATA\Stahky"
            New-Item -ItemType Directory -Path $exePath -Force | Out-Null
            New-Item -ItemType Directory -Path $exePath\config -Force | Out-Null
            Invoke-WebRequest -Uri $url -OutFile $outputPath
            if (Test-Path -Path "$exePath\stahky.exe") {
                Write-Output "Stahky already exists."
            } else {
                Expand-Archive -Path $outputPath -DestinationPath $exePath
            }
            Copy-Item -Path $pwd\config\taskbar\stacks\* -Destination $exePath\config -Recurse -Force
            Copy-Item -Path $exePath\config\themes\stahky-$stackTheme.ini -Destination $exePath\stahky.ini
            $pathVarUser = [Environment]::GetEnvironmentVariable("Path", "User")
            $pathVarMachine = [Environment]::GetEnvironmentVariable("Path", "Machine")
            if (-not ($pathVarUser -like "*$exePath*")) {
                $pathVarUser += ";$exePath"
                [Environment]::SetEnvironmentVariable("Path", $pathVarUser, "User")
            }
            if (-not ($pathVarMachine -like "* $exePath*")) {
                $pathVarMachine += "; $exePath"
                [Environment]::SetEnvironmentVariable("Path", $pathVarMachine, "Machine")
            }
            $pathVar = [Environment]::GetEnvironmentVariable("Path", "Machine") + ";$exePath"
            [Environment]::SetEnvironmentVariable("Path", $pathVar, "Machine")
            $pathVar = [Environment]::GetEnvironmentVariable("Path", "User") + ";$exePath"
            [Environment]::SetEnvironmentVariable("Path", $pathVar, "User")
            $shortcutPath1 = "$env:LOCALAPPDATA\Stahky\config\shortcuts\Management.lnk"
            $shortcutPath2 = "$env:LOCALAPPDATA\Stahky\config\shortcuts\Favorites.lnk"
            $newTargetPath = "$env:LOCALAPPDATA\Stahky\Stahky.exe"
            $newArguments1 = '/stahky ' + "$env:LOCALAPPDATA\Stahky\config\management"
            $newArguments2 = '/stahky ' + "$env:LOCALAPPDATA\Stahky\config\favorites"
            $newWorkDir1 = "$env:LOCALAPPDATA\Stahky\config\management"
            $newWorkDir2 = "$env:LOCALAPPDATA\Stahky\config\favorites"
            $shell1 = New-Object -ComObject WScript.Shell
            $shortcut1 = $shell1.CreateShortcut($shortcutPath1) 
            $shortcut1.Arguments = $newArguments1
            $shortcut1.TargetPath = $newTargetPath
            $shortcut1.WorkingDirectory = $newWorkDir1
            $shortcut1.Save()
            $shell2 = New-Object -ComObject WScript.Shell
            $shortcut2 = $shell2.CreateShortcut($shortcutPath2) 
            $shortcut2.Arguments = $newArguments2
            $shortcut2.TargetPath = $newTargetPath
            $shortcut2.WorkingDirectory = $newWorkDir2
            $shortcut2.Save()
            Remove-Item $outputPath -Force
            Write-Host "Stahky installation completed." -ForegroundColor Green
        }
        # Keyboard Shortcuts
        "8" {
            if ($adminTest) {
                Write-Host "Keyboard Shortcuts requires administrative privileges. Please run the script as an administrator. Skipping installation." -ForegroundColor Red
            } else {
                Write-Host "Installing Keyboard Shortcuts..." -ForegroundColor Yellow
                $fileName = 'keybindings.exe'
                $fileDirectory = "$env:LOCALAPPDATA\WinMac"
                New-Item -ItemType Directory -Path "$env:LOCALAPPDATA\WinMac\" | Out-Null
                Copy-Item .\bin\$fileName "$env:LOCALAPPDATA\WinMac\" | Out-Null
                $folderName = "WinMac"
                $taskService = New-Object -ComObject "Schedule.Service"
                $taskService.Connect() | Out-Null
                $rootFolder = $taskService.GetFolder("\")
                try { $existingFolder = $rootFolder.GetFolder($folderName) } catch { $existingFolder = $null }              
                if ($null -eq $existingFolder) { $rootFolder.CreateFolder($folderName) | Out-Null }
                $taskFolder = "\" + $folderName
                $trigger = New-ScheduledTaskTrigger -AtLogon
                $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -MultipleInstances IgnoreNew
                $taskName = ($fileName).replace('.exe','')
                $action = New-ScheduledTaskAction -Execute $fileName -WorkingDirectory $fileDirectory
                $principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
                Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -TaskPath $taskFolder -Settings $settings -ErrorAction SilentlyContinue | Out-Null
                Start-Process "$env:LOCALAPPDATA\WinMac\keybindings.exe"
                Write-Host "Keyboard Shortcuts installation completed." -ForegroundColor Green
            }
        }
        # WinLauncher
        "9" {
            Write-Host "Installing WinLauncher..." -ForegroundColor Yellow
            $zipFilePath = ".\bin\Launchpad.zip"
            $extractPath = "$ENV:LOCALAPPDATA\WinMac\Launchpad"
            Expand-Archive -Path $zipFilePath -DestinationPath $extractPath -Force
            Start-Process "$ENV:LOCALAPPDATA\WinMac\Launchpad\WinLaunch.exe"
            Write-Host "WinLauncher installation completed." -ForegroundColor Green
        }
        # Nexus Dock
        "10" {
            if ($adminTest) {
                Write-Host "Installing Nexus Dock..." -ForegroundColor Yellow
                $downloadUrl = "https://www.winstep.net/nexus.zip"
                $downloadPath = "dock.zip"
                if (-not (Test-Path $downloadPath)) {
                    Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath
                }
                Expand-Archive -Path $downloadPath -DestinationPath $pwd -Force
                Start-Process -FilePath ".\NexusSetup.exe" -ArgumentList "/silent"
                Start-Sleep 10
                $process1 = Get-Process -Name "NexusSetup" -ErrorAction SilentlyContinue
                while ($process1) {
                    Start-Sleep 5
                    $process1 = Get-Process -Name "NexusSetup" -ErrorAction SilentlyContinue
                }
                Start-Sleep 10
                $process2 = Get-Process -Name "Nexus" -ErrorAction SilentlyContinue
                if (!($process2)) {
                    Start-Sleep 5
                    $process2 = Get-Process -Name "Nexus" -ErrorAction SilentlyContinue
                } else { Start-Sleep 10 }
                Get-Process -n Nexus | Stop-Process
                $winStep = 'C:\Users\Public\Documents\WinStep'
                Remove-Item -Path "$winStep\Themes\*" -Recurse -Force | Out-Null
                Copy-Item -Path "config\dock\themes\*" -Destination "$winStep\Themes\" -Recurse -Force | Out-Null
                Remove-Item -Path "$winStep\NeXus\Indicators\*" -Force -Recurse | Out-Null
                Copy-Item -Path "config\dock\indicators\*" -Destination "$winStep\NeXus\Indicators\" -Recurse -Force | Out-Null
                New-Item -ItemType Directory -Path "$winStep\Sounds" -Force | Out-Null
                Copy-Item -Path "config\dock\sounds\*" -Destination "$winStep\Sounds\" -Recurse -Force | Out-Null
                New-Item -ItemType Directory -Path "$winStep\Icons" -Force | Out-Null
                Copy-Item config\dock\icons "$winStep" -Recurse -Force | Out-Null
                $regFile = "$pwd\config\dock\winstep.reg"
                $tempFolder = "$pwd\temp"
                $downloadsPath = "$env:USERPROFILE\Downloads"
                if (-not (Test-Path $tempFolder)) {
                    New-Item -ItemType Directory -Path $tempFolder -Force | Out-Null
                }
                if ($roundedOrSquared -eq "S" -or $roundedOrSquared -eq "s") {
                    $modifiedContent = Get-Content $regFile | ForEach-Object { $_ -replace "Rounded", "Squared" }
                    $modifiedFile = "$pwd\temp\winstep.reg"
                    $modifiedContent | Out-File -FilePath $modifiedFile -Encoding UTF8 | Out-Null
                    $regFile = $modifiedFile
                    if ($lightOrDark -eq "D" -or $lightOrDark -eq "d") {
                        $modifiedContent = Get-Content $regFile | ForEach-Object { $_ -replace "Light", "Dark" }
                        $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace '"UIDarkMode"="3"', '"UIDarkMode"="1"' }
                        $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace "1644825", "15658734" }
                        $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace "16119283", "2563870" }
                        $modifiedFile = "$pwd\temp\winstep.reg"
                        $modifiedContent | Out-File -FilePath $modifiedFile -Encoding UTF8 | Out-Null
                    }
                }
                elseif (($roundedOrSquared -ne "S" -or $roundedOrSquared -ne "s") -and ($lightOrDark -eq "D" -or $lightOrDark -eq "d")) {
                    $modifiedContent = Get-Content $regFile | ForEach-Object { $_ -replace "Light", "Dark" }
                    $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace '"UIDarkMode"="3"', '"UIDarkMode"="1"' }
                    $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace "1644825", "15658734" }
                    $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace "16119283", "2563870" }
                    $modifiedFile = "$pwd\temp\winstep.reg"
                    $modifiedContent | Out-File -FilePath $modifiedFile -Encoding UTF8 | Out-Null
                    $regFile = $modifiedFile
                }
                reg import $regFile > $null 2>&1
                Remove-ItemProperty -Path "Registry::HKEY_CURRENT_USER\Software\WinSTEP2000\NeXuS\Docks" -Name "DockLabelColorHotTrack1" -ErrorAction SilentlyContinue | Out-Null
                Remove-ItemProperty -Path "Registry::HKEY_CURRENT_USER\Software\WinSTEP2000\NeXuS\Docks" -Name "1Type6" -ErrorAction SilentlyContinue | Out-Null
                Remove-ItemProperty -Path "Registry::HKEY_CURRENT_USER\Software\WinSTEP2000\NeXuS\Docks" -Name "1Type7" -ErrorAction SilentlyContinue | Out-Null
                Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "1Path6" -Value $downloadsPath
                Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "1Path7" -Value "$env:APPDATA\Microsoft\Windows\Recent\"
                Start-Process 'C:\Program Files (x86)\Winstep\Nexus.exe' | Out-Null
                while (!(Get-Process nexus -ErrorAction SilentlyContinue)) { Start-Sleep 1 }
                $programsDir = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs"
                Move-Item -Path "C:\Users\$env:USERNAME\Desktop\Nexus.lnk" -Destination $programsDir -Force -ErrorAction SilentlyContinue | Out-Null
                Move-Item -Path "C:\Users\$env:USERNAME\OneDrive\Desktop\Nexus.lnk" -Destination $programsDir -Force -ErrorAction SilentlyContinue | Out-Null
                Remove-Item "$pwd\temp\*" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
                Remove-Item .\dock.zip -Force | Out-Null
                Remove-Item .\ReadMe.txt -Force | Out-Null
                Remove-Item .\NexusSetup.exe -Force | Out-Null
                Write-Host "Nexus Dock installation completed." -ForegroundColor Green

            }
            else {
                Write-Host "Winstep Nexus requires non-administrative privileges. Please run the script as a standard user session. Skipping installation." -ForegroundColor Red
            }
        }
        # Other
        "11" {
            ## Black Cursor
            Write-Host "Configuring black cursor..." -ForegroundColor Yellow
            $exRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
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
            $RegCursors.SetValue("Pin","$curDestFolder\aero_black_pin.cur")
            $RegCursors.SetValue("Person","$curDestFolder\aero_black_person.cur")
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
            ## Pin Home, Programs and Recycle Bin to Quick Access
            write-host "Pinning Home, Programs and Recycle Bin to Quick Access..." -ForegroundColor Yellow
$homeIni = @"
[.ShellClassInfo]
IconResource=C:\Windows\System32\SHELL32.dll,160
"@
            $homeDir = "C:\Users\$env:USERNAME"
            $homeIniFilePath = "$($homeDir)\desktop.ini"
            if (Test-Path $homeIniFilePath)  {
                Remove-Item $homeIniFilePath -Force
                New-Item -Path $homeIniFilePath -ItemType File -Force | Out-Null
            }
            Add-Content $homeIniFilePath -Value $homeIni
            (Get-Item $homeIniFilePath -Force).Attributes = 'Hidden, System, Archive'
            (Get-Item $homeDir -Force).Attributes = 'ReadOnly, Directory'
            $homePin = new-object -com shell.application
            if (-not ($homePin.Namespace($homeDir).Self.Verbs() | Where-Object {$_.Name -eq "pintohome"})) {
                $homePin.Namespace($homeDir).Self.InvokeVerb("pintohome") | Out-Null
            }
$programsIni = @"
[.ShellClassInfo]
IconResource=C:\WINDOWS\System32\imageres.dll,187
"@
            $programsDir = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs"
            $programsIniFilePath = "$($programsDir)\desktop.ini"
            if (Test-Path $programsIniFilePath)  {
                Remove-Item $programsIniFilePath -Force
                New-Item -Path $programsIniFilePath -ItemType File -Force | Out-Null
            }
            Add-Content $programsIniFilePath -Value $programsIni
            (Get-Item $programsIniFilePath -Force).Attributes = 'Hidden, System, Archive'
            (Get-Item $programsDir -Force).Attributes = 'ReadOnly, Directory'
            $programsPin = new-object -com shell.application
            if (-not ($programsPin.Namespace($programsDir).Self.Verbs() | Where-Object {$_.Name -eq "pintohome"})) {
                $programsPin.Namespace($programsDir).Self.InvokeVerb("pintohome") | Out-Null
            }
            $RBPath = 'HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\pintohome\command\'
            $name = "DelegateExecute"
            $value = "{b455f46e-e4af-4035-b0a4-cf18d2f6f28e}"
            New-Item -Path $RBPath -Force | Out-Null
            New-ItemProperty -Path $RBPath -Name $name -Value $value -PropertyType String -Force | Out-Null
            $oShell = New-Object -ComObject Shell.Application
            $recycleBin = $oShell.Namespace("shell:::{645FF040-5081-101B-9F08-00AA002F954E}")
            if (-not ($recycleBin.Self.Verbs() | Where-Object {$_.Name -eq "pintohome"})) {
                $recycleBin.Self.InvokeVerb("PinToHome") | Out-Null
            }
            Remove-Item -Path "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}" -Recurse | Out-Null
            ## Remove Shortcut Arrows
            Write-Host "Removing shortcut arrows..." -ForegroundColor Yellow
            Copy-Item -Path "$pwd\config\blank.ico" -Destination "C:\Windows" -Force
            New-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" -ErrorAction SilentlyContinue
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" -Name "29" -Value "C:\Windows\blank.ico" -Type String
            ## Misc
            Write-Host "Configuring other settings..." -ForegroundColor Yellow
            Set-ItemProperty -Path "$exRegPath\Advanced" -Name "LaunchTO" -Value 1
            Set-ItemProperty -Path $exRegPath -Name "ShowFrequent" -Value 0
            Set-ItemProperty -Path $exRegPath -Name "ShowRecent" -Value 0
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" -Name "{470C0EBD-5D73-4d58-9CED-E91E22E23282}" -Value "" -ErrorAction SilentlyContinue
            $taskbarDevSettings = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings"
            if (-not (Test-Path $taskbarDevSettings)) { New-Item -Path $taskbarDevSettings -Force | Out-Null }
            New-ItemProperty -Path $taskbarDevSettings -Name "TaskbarEndTask" -Value 1 -PropertyType DWORD -Force -ErrorAction SilentlyContinue | Out-Null
            Stop-Process -n explorer
        }
    }
}
Write-Host
Write-Host "`n------------------------ WinMac Deployment completed ------------------------" -ForegroundColor Cyan
Write-Host @"

Enjoy and support by giving feedback and contributing to the project!

For more information please visit my GitHub page: github.com/Asteski/WinMac

If you have any questions or suggestions, please contact me on GitHub.

"@ -ForegroundColor Green

Write-Host "-----------------------------------------------------------------------------"  -ForegroundColor Cyan
Start-Sleep 2
$restartConfirmation = Read-Host "`nRestart computer now? It's recommended to fully apply all the changes. (y/n)"
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

#EOF