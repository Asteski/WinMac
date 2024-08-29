Clear-Host
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

Installation process is seperated into two parts: main install and dock.
Main script must be run with admin privileges, while dock script 
must be run in non-elevated pwsh session.

PowerShell profile files will be removed and replaced with new ones. stat
Please make sure to backup your current profiles if needed.

"@ -ForegroundColor Yellow

Write-Host "Script must be run in elevated session!" -ForegroundColor Red
Write-Host "`n-----------------------------------------------------------------------" -ForegroundColor Cyan

## Check if script is run from the correct directory
$checkDir = Get-ChildItem
if (!($checkDir -like "*WinMac*" -and $checkDir -like "*config*" -and $checkDir -like "*bin*")) {
    Write-Host "`nWinMac components not found. Please make sure to run the script from the correct directory." -ForegroundColor Red
    Start-Sleep 2
    exit
}

## Start Logging
$errorActionPreference="SilentlyContinue"
$date = Get-Date -Format "yy-MM-ddTHHmmss"
mkdir ./temp | Out-Null
Start-Transcript -Path ".\temp\WinMac_install_log_$date.txt" -Append | Out-Null

## WinMac Configuration
Write-Host
$fullOrCustom = Read-Host "Enter 'F' for full or 'C' for custom installation"
if ($fullOrCustom -eq 'F' -or $fullOrCustom -eq 'f') {
    Write-Host "Choosing full installation." -ForegroundColor Green
    $selectedApps = "1","2","3","4","5","6","7","8","9","10"
} 
elseif ($fullOrCustom -eq 'C' -or $fullOrCustom -eq 'c') {
    Write-Host "Choosing custom installation." -ForegroundColor Green
    Start-Sleep 1
    $appList = @{"1"="PowerToys"; "2"="Everything"; "3"="Powershell Profile"; "4"="StartAllBack"; "5"="WinMac Menu"; "6"="TopNotify"; "7"="Stahky"; "8"="WinMac Keybindings"; "9"="WinLauncher"; "10"="Other"}

Write-Host @"

$([char]27)[93m$("Please select options you want to install:")$([char]27)[0m

"@
    Write-Host "1. PowerToys"
    Write-Host "2. Everything"
    Write-Host "3. Powershell Profile"
    Write-Host "4. StartAllBack"
    Write-Host "5. WinMac Menu"
    Write-Host "6. TopNotify"
    Write-Host "7. Stahky"
    Write-Host "8. WinMac Keybindings"
    Write-Host "9. WinLauncher"
    Write-Host @"
10. Other:
    - black cursor
    - pin Home and Programs folders to Quick access
    - remove shortcut arrows
    - remove recycle bin desktop icon
    - add End Task option to taskbar
"@
    Write-Host
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
    $selectedApps = "1","2","3","4","5","6","7","8","9","10"
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

## Winget
Write-Host "Checking for Windows Package Manager (Winget)" -ForegroundColor Yellow
$wingetCheck = winget -v
if ($null -eq $wingetCheck) {
    $progressPreference = 'silentlyContinue'
    Write-Information "Downloading WinGet and its dependencies..."
    Invoke-WebRequest -Uri https://aka.ms/getwinget -OutFile Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
    Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
    Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx -OutFile Microsoft.UI.Xaml.2.8.x64.appx
    Add-AppxPackage Microsoft.VCLibs.x64.14.00.Desktop.appx
    Add-AppxPackage Microsoft.UI.Xaml.2.8.x64.appx
    Add-AppxPackage Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
} else {
    Write-Host "$([char]27)[92m$("Winget is already installed.")$([char]27)[0m Version: $($wingetCheck)"
}

foreach ($app in $selectedApps) {
    switch ($app.Trim()) {
        "1" {
            # PowerToys
            Write-Host "Installing PowerToys..."  -ForegroundColor Yellow
            winget configure .\config\powertoys.dsc.yaml --accept-configuration-agreements | Out-Null
            Write-Host "PowerToys installation completed." -ForegroundColor Green
        }
        "2" {
            # Everything
            Write-Host "Installing Everything..."  -ForegroundColor Yellow
            winget install --id "Voidtools.Everything" --source winget --silent | Out-Null
            $programsDir = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs"
            Move-Item -Path "C:\Users\Public\Desktop\Everything.lnk" -Destination $programsDir -Force -ErrorAction SilentlyContinue | Out-Null
            Move-Item -Path "C:\Users\$env:USERNAME\Desktop\Everything.lnk" -Destination $programsDir -Force -ErrorAction SilentlyContinue | Out-Null
            Start-Process -FilePath Everything.exe -WorkingDirectory $env:PROGRAMFILES\Everything -WindowStyle Hidden
            Write-Host "Everything installation completed." -ForegroundColor Green
            }
        "3" {
            # PowerShell Profile
            Write-Host "Configuring PowerShell Profile..." -ForegroundColor Yellow
            $profilePath = $PROFILE | Split-Path | Split-Path
            $profileFile = $PROFILE | Split-Path -Leaf
            if ($promptSet -eq 'W' -or $promptSet -eq 'w') { $prompt = Get-Content "$pwd\config\terminal\winmac-prompt.ps1" -Raw }
            elseif ($promptSet -eq 'M' -or $promptSet -eq 'm') { $prompt = Get-Content "$pwd\config\terminal\macos-prompt.ps1" -Raw }
            $functions = Get-Content "$pwd\config\terminal\functions.ps1" -Raw

            if (-not (Test-Path "$profilePath\PowerShell")) { New-Item -ItemType Directory -Path "$profilePath\PowerShell" | Out-Null } else { Remove-Item -Path "$profilePath\PowerShell\$profileFile" -Force | Out-Null }
            if (-not (Test-Path "$profilePath\WindowsPowerShell")) { New-Item -ItemType Directory -Path "$profilePath\WindowsPowerShell" | Out-Null } else { Remove-Item -Path "$profilePath\WindowsPowerShell\$profileFile" -Force | Out-Null }
            if (-not (Test-Path "$profilePath\PowerShell\$profileFile")) { New-Item -ItemType File -Path "$profilePath\PowerShell\$profileFile" | Out-Null }
            if (-not (Test-Path "$profilePath\WindowsPowerShell\$profileFile")) { New-Item -ItemType File -Path "$profilePath\WindowsPowerShell\$profileFile" | Out-Null }

            $progressPreference = 'silentlyContinue'
            if (-not (Get-PackageProvider -ListAvailable | Where-Object {$_.Name -eq 'NuGet'})) {
                Write-Information "Installing NuGet Provider..."
                Install-PackageProvider -Name NuGet -Force
                Write-Information "NuGet Provider installation completed."
            }
            else {
                Write-Information "NuGet Provider is already installed."
            }
            Install-Module -Name Microsoft.WinGet.Client -Force -ErrorAction SilentlyContinue | Out-Null
            $winget = @(
                "Vim.Vim",
                "gsass1.NTop"
            )
            foreach ($app in $winget) {winget install --id $app --source winget --silent | Out-Null }
            $vimParentPath = Join-Path $env:PROGRAMFILES Vim
            $latestSubfolder = Get-ChildItem -Path $vimParentPath -Directory | Sort-Object -Property CreationTime -Descending | Select-Object -First 1
            $vimChildPath = $latestSubfolder.FullName
            [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$vimChildPath", [EnvironmentVariableTarget]::Machine) | Out-Null
            Install-Module PSTree -Force | Out-Null
            $programsDir = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs"
            Add-Content -Path "$profilePath\PowerShell\$profileFile" -Value $prompt
            Add-Content -Path "$profilePath\PowerShell\$profileFile" -Value $functions
            Add-Content -Path "$profilePath\WindowsPowerShell\$profileFile" -Value $functions
            Add-Content -Path "$profilePath\WindowsPowerShell\$profileFile" -Value $functions
            Move-Item -Path "C:\Users\Public\Desktop\gVim*" -Destination $programsDir -Force -ErrorAction SilentlyContinue | Out-Null
            Move-Item -Path "C:\Users\$env:USERNAME\Desktop\gVim*" -Destination $programsDir -Force -ErrorAction SilentlyContinue | Out-Null
            Move-Item -Path "C:\Users\$env:USERNAME\OneDrive\Desktop\gVim*" -Destination $programsDir -Force -ErrorAction SilentlyContinue | Out-Null
            Write-Host "PowerShell Profile configuration completed." -ForegroundColor Green
        }
        "4" {
            # StartAllBack
            Write-Host "Installing StartAllBack..." -ForegroundColor Yellow
            winget install --id "StartIsBack.StartAllBack" --source winget --silent | Out-Null
            $exRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
            $sabOrbs = $env:localAPPDATA + "\StartAllBack\Orbs"
            $sabRegPath = "HKCU:\Software\StartIsBack"
            $taskbarOnTopPath = "$exRegPath\StuckRectsLegacy"
            $taskbarOnTopName = "Settings"
            $taskbarOnTopValue = @(0x30,0x00,0x00,0x00,0xfe,0xff,0xff,0xff,0x02,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x5a,0x00,0x00,0x00,0x32,0x00,0x00,0x00,0x26,0x07,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x07,0x00,0x00,0x38,0x04,0x00,0x00,0x78,0x00,0x00,0x00,0x01,0x00,0x00,0x00)
            New-Item -Path $taskbarOnTopPath -Force | Out-Null
            New-ItemProperty -Path $taskbarOnTopPath -Name $taskbarOnTopName -Value $taskbarOnTopValue -PropertyType Binary | Out-Null
            Copy-Item $pwd\config\taskbar\orbs\* $sabOrbs -Force | Out-Null
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
            Stop-Process -Name explorer -Force | Out-Null
            Start-Sleep 2
            Write-Host "StartAllBack installation completed." -ForegroundColor Green
        }
        "5" {
            # WinMac Menu
            if ($menuSet -eq 'X'-or $menuSet -eq 'x') {
                Write-Host "Installing WinMac Menu..." -ForegroundColor Yellow
                winget install --id Microsoft.DotNet.DesktopRuntime.6 --silent | Out-Null
                New-Item -ItemType Directory -Path "$env:LOCALAPPDATA\WinMac\" | Out-Null
                Get-Item -Path .\bin\* | Where-Object { $_.Name -ne "keybindings.exe" } | Copy-Item -Destination "$env:LOCALAPPDATA\WinMac\" -Recurse -Force | Out-Null
                $exeKeyPath = "$env:LOCALAPPDATA\WinMac\windowskey.exe"
                $exeStartPath = "$env:LOCALAPPDATA\WinMac\startbutton.exe"
                $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
                $regKeyName = "WinMac Menu Windows Key"
                $regStartName = "WinMac Menu Start Button"
                Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\WinX" -Recurse -Force
                Copy-Item -Path "$pwd\config\winx\" -Destination "$env:LOCALAPPDATA\Microsoft\Windows\" -Recurse -Force
                Set-ItemProperty -Path $regPath -Name $regKeyName -Value $exeKeyPath
                Set-ItemProperty -Path $regPath -Name $regStartName -Value $exeStartPath
                Start-Process "$env:LOCALAPPDATA\WinMac\windowskey.exe"
                Start-Process "$env:LOCALAPPDATA\WinMac\startbutton.exe"
                Write-Host "WinMac Menu installation completed." -ForegroundColor Green
            }
            else {
                Write-Host "Skipping WinMac Menu installation." -ForegroundColor Magenta
            }
        }
        "6" {
            # TopNotify
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
        "7" {
            # Stahky
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
        "8" {
            # WinMac Keybindings
            Write-Host "Installing WinMac Keybindings..." -ForegroundColor Yellow
            $fileName = 'keybindings.exe'
            $fileDirectory = "$env:LOCALAPPDATA\WinMac"
            $user = [Security.Principal.WindowsIdentity]::GetCurrent();
            $adminTest = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
            New-Item -ItemType Directory -Path "$env:LOCALAPPDATA\WinMac\" | Out-Null
            Copy-Item .\bin\$fileName "$env:LOCALAPPDATA\WinMac\" | Out-Null
            if (-not $adminTest) {
                $exeBindPath = "$env:LOCALAPPDATA\WinMac\keybindings.exe"
                $regBindName = "WinMac Menu Key Bindings"
                $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
                Set-ItemProperty -Path $regPath -Name $regBindName -Value $exeBindPath
            } else {
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
            }
            Start-Process "$env:LOCALAPPDATA\WinMac\keybindings.exe"
            Write-Host "WinMac Keybindings installation completed." -ForegroundColor Green
        }
        "9" {
            # WinLauncher
            Write-Host "Installing WinLauncher..." -ForegroundColor Yellow
            
            Write-Host "WinMac Keybindings installation completed." -ForegroundColor Green
        }
        "10" {
            # Other
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
            New-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" | Out-Null
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" -Name "29" -Value "C:\Windows\blank.ico" -Type String

            ## Misc
            Write-Host "Configuring other settings..." -ForegroundColor Yellow
            Set-ItemProperty -Path "$exRegPath\Advanced" -Name "LaunchTO" -Value 1
            Set-ItemProperty -Path $exRegPath -Name "ShowFrequent" -Value 0
            Set-ItemProperty -Path $exRegPath -Name "ShowRecent" -Value 0
            Set-ItemProperty -Path "HKCU:\Software\Policies\Microsoft\Windows\Explorer" -Name "TaskbarNoMultimon" -Value 1
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\Explorer" -Name "TaskbarNoMultimon" -Value 1
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" -Name "{470C0EBD-5D73-4d58-9CED-E91E22E23282}" -Value ""
            $taskbarDevSettings = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings"
            if (-not (Test-Path $taskbarDevSettings)) { New-Item -Path $taskbarDevSettings -Force | Out-Null }
            New-ItemProperty -Path $taskbarDevSettings -Name "TaskbarEndTask" -Value 1 -PropertyType DWORD -Force | Out-Null
            Stop-Process -n explorer
        }
    }
}

Write-Host
Stop-Transcript

Write-Host "`n------------------------ WinMac Deployment completed ------------------------" -ForegroundColor Cyan
Write-Host @"

Enjoy and support by giving feedback and contributing to the project!

For more information please visit my GitHub page: github.com/Asteski/WinMac

If you have any questions or suggestions, please contact me on GitHub.

"@ -ForegroundColor Green

Write-Host "-----------------------------------------------------------------------------"  -ForegroundColor Cyan
Write-Host @"

To install Winstep Nexus Dock, please run the dock.ps1 script in a PowerShell session without administrative privileges.

"@ -ForegroundColor Yellow
Start-Sleep 2
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

#EOF