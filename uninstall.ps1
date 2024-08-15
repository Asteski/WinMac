Clear-Host
Write-Host @"
-----------------------------------------------------------------------

Welcome to WinMac Deployment!

Author: Asteski
Version: 0.5.2

This is Work in Progress. You're using this script at your own risk.

-----------------------------------------------------------------------
"@ -ForegroundColor Cyan
Write-Host @"

This script is responsible for uninstalling all or specific WinMac 
components.

PowerShell profile files will be removed, please make sure to backup 
your current profiles if needed.

Vim and Nexus packages will show prompt to uninstall, please confirm the
uninstallations manually.

AutoHotkey option must be run in elevated mode to uninstall.

"@ -ForegroundColor Yellow

Write-Host "-----------------------------------------------------------------------" -ForegroundColor Cyan

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
Start-Transcript -Path ".\temp\WinMac_uninstall_log_$date.txt" -Append | Out-Null

## User Configuration

$fullOrCustom = Read-Host "`nEnter 'F' for full or 'C' for custom uninstallation"
if ($fullOrCustom -eq 'F' -or $fullOrCustom -eq 'f') {
    $selectedApps = "1","2","3","4","5","6","7","8","9","10"
    Write-Host "Choosing full uninstallation." -ForegroundColor Yellow
}
elseif ($fullOrCustom -eq 'C' -or $fullOrCustom -eq 'c') {
    Write-Host "Choosing custom uninstallation." -ForegroundColor Yellow
    Start-Sleep 1
    $appList = @{"1"="PowerToys"; "2"="Everything"; "3"="Powershell Profile"; "4"="StartAllBack"; "5"="WinMac Menu"; "6"="TopNotify"; "7"="Nexus Dock"; "8"="Stahky"; "9"="AutoHotkey"; "10"="Other"}
Write-Host @"

$([char]27)[93m$("Please select options you want to uninstall:")$([char]27)[0m

"@
    Write-Host "1. PowerToys"
    Write-Host "2. Everything"
    Write-Host "3. Powershell Profile"
    Write-Host "4. StartAllBack"
    Write-Host "5. WinMac Menu"
    Write-Host "6. TopNotify"
    Write-Host "7. Nexus Dock"
    Write-Host "8. Stahky"
    Write-Host "9. AutoHotkey"
    Write-Host "10. Other"
    $selection = Read-Host "Enter the numbers of options you want to uninstall (separated by commas)"
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
    $selectedApps = "1","2","3","4","5","6","7","8","9","10"
    Write-Host "Invalid input. Defaulting to full uninstallation." -ForegroundColor Yellow
}
Start-Sleep 1
Write-Host
$installConfirmation = Read-Host "Are you sure you want to start the uninstallation process (y/n)"

if ($installConfirmation -ne 'y') {
    Write-Host "Uninstallation process aborted." -ForegroundColor Red
    Start-Sleep 2
    exit
}
Write-Host "Starting uninstallation process in..." -ForegroundColor Red
for ($a=3; $a -ge 0; $a--) {
    Write-Host -NoNewLine "`b$a" -ForegroundColor Red
    Start-Sleep 1
}

Write-Host
Write-Host "-----------------------------------------------------------------------" -ForegroundColor Cyan
Write-Host

## Winget
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
}
else 
{
    Write-Host "$([char]27)[92m$("Winget is already installed.")$([char]27)[0m Version: $($wingetCheck)"
}

## Defintions
$exRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
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

foreach ($app in $selectedApps) {
    switch ($app.Trim()) {
        "1" {
            # PowerToys
            Write-Host "Uninstalling PowerToys..."  -ForegroundColor Yellow
            Get-Process | Where-Object { $_.ProcessName -eq 'PowerToys' } | Stop-Process -Force | Out-Null
            Start-Sleep 2
            winget uninstall --id Microsoft.PowerToys --silent --force | Out-Null
            Write-Host "Uninstalling PowerToys completed." -ForegroundColor Green
        }
        "2" {
            # Everything
            Write-Host "Uninstalling Everything..."  -ForegroundColor Yellow
            winget uninstall --id Voidtools.Everything --source winget --force | Out-Null
            $programsDir = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs"
            Remove-Item -Path "$programsDir\Everything.lnk" -Force | Out-Null
            Write-Host "Uninstalling Everything completed." -ForegroundColor Green
        }
        "3" {
            # PowerShell Profile
            Write-Host "Uninstalling PowerShell Profile..." -ForegroundColor Yellow
            $profilePath = $PROFILE | Split-Path | Split-Path
            $profileFile = $PROFILE | Split-Path -Leaf
            $winget = @(
                "Vim.Vim",
                "gsass1.NTop"
            )
            foreach ($app in $winget) {winget uninstall --id $app --source winget --silent --force | Out-Null}
            Uninstall-Module PSTree -Force
            if ((Test-Path "$profilePath\PowerShell\$profileFile")) { Remove-Item -Path "$profilePath\PowerShell\$profileFile" | Out-Null }
            if ((Test-Path "$profilePath\WindowsPowerShell\$profileFile")) { Remove-Item -Path "$profilePath\WindowsPowerShell\$profileFile" | Out-Null }
            $programsDir = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs"
            Remove-Item -Path "$programsDir\gVim*" -Force | Out-Null
            Write-Host "Uninstalling PowerShell Profile completed." -ForegroundColor Green
        }
        "4" {
            # StartAllBack
            Write-Host "Uninstalling StartAllBack..." -ForegroundColor Yellow
            winget uninstall --id "StartIsBack.StartAllBack" --source winget --silent --force | Out-Null
            Set-ItemProperty -Path $exRegPath\Advanced -Name "UseCompactMode" -Value 0
            Set-ItemProperty -Path $exRegPath\Advanced -Name "TaskbarAl" -Value 1
            Set-ItemProperty -Path $exRegPath\Advanced -Name "TaskbarGlomLevel" -Value 0
            Stop-Process -Name explorer -Force | Out-Null
            Write-Host "Uninstalling StartAllBack completed." -ForegroundColor Green
            Start-Sleep 3
        }
        "5" {
            # WinMac Menu
            Write-Host "Uninstalling WinMac Menu..." -ForegroundColor Yellow
            Stop-Process -Name WinKey -Force | Out-Null
            $tasks = Get-ScheduledTask -TaskPath "\WinMac\" -ErrorAction SilentlyContinue | Where-Object { $_.TaskName -match 'startbutton|winkey' }
            foreach ($task in $tasks) { Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false }
            $tasksFolder = Get-ScheduledTask -TaskPath "\WinMac\" -ErrorAction SilentlyContinue
            if ($tasksFolder -eq $null) { Remove-Item -Path "$env:SYSTEMROOT\System32\Tasks\WinMac" -Force -Recurse -ErrorAction SilentlyContinue }
            Remove-Item -Path "$env:PROGRAMFILES\WinMac" -Recurse -Force
            Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\winx" -Recurse -Force | Out-Null
            Expand-Archive -Path "$pwd\config\WinX-default.zip" -Destination "$env:LOCALAPPDATA\Microsoft\Windows\" -Force
            Stop-Process -n Explorer
            Write-Host "Uninstalling WinMac Menu completed." -ForegroundColor Green
        }
        "6" {
            # TopNotify
            Write-Host "Uninstalling TopNotify..." -ForegroundColor Yellow
            winget uninstall --name TopNotify --silent | Out-Null
            Write-Host "Uninstalling TopNotify completed." -ForegroundColor Green
        }
        "7" {
            # Nexus Dock
            Write-Host "Uninstalling Nexus Dock..." -ForegroundColor Yellow
            Get-Process Nexus | Stop-Process -Force | Out-Null
            winget uninstall --name Nexus --silent --force | Out-Null
            $programsDir = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs"
            Remove-Item -Path "$programsDir\Nexus.lnk" -Force | Out-Null
            Write-Host "Uninstalling Nexus Dock completed." -ForegroundColor Green
        }
        "8" {
            # Stahky
            Write-Host "Uninstalling Stahky..." -ForegroundColor Yellow
            $exePath = "$env:LOCALAPPDATA\Stahky"
            Remove-Item -Path $exePath -Recurse -Force | Out-Null
            Write-Host "Uninstalling Stahky completed." -ForegroundColor Green
        }
        "9" {
            # AutoHotkey
            Write-Host "Uninstalling AutoHotkey..." -ForegroundColor Yellow
            Stop-Process -Name "AutoHotkey*" -Force | Out-Null
            winget uninstall --id autohotkey.autohotkey --source winget --force | Out-Null
            $tasks = Get-ScheduledTask -TaskPath "\WinMac\" -ErrorAction SilentlyContinue | Where-Object { $_.TaskName -notmatch 'startbutton|winkey' }
            foreach ($task in $tasks) { Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false -ErrorAction SilentlyContinue }
            $tasksFolder = Get-ScheduledTask -TaskPath "\WinMac\" -ErrorAction SilentlyContinue
            if ($tasksFolder -eq $null) { Remove-Item -Path "$env:SYSTEMROOT\System32\Tasks\WinMac" -Force -Recurse -ErrorAction SilentlyContinue }}
            Write-Host "Uninstalling AutoHotkey completed." -ForegroundColor Green
        }
        "10" {
            # Other
            Write-Host "Uninstalling Other configurations..." -ForegroundColor Yellow
            Set-ItemProperty -Path $exRegPath\HideDesktopIcons\NewStartPanel -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Value 0

            $homeDir = "C:\Users\$env:USERNAME"
            $homeIniFilePath = "$($homeDir)\desktop.ini"
            Remove-Item -Path $homeIniFilePath -Force | Out-Null
            $programsDir = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs"
            $programsIniFilePath = "$($programsDir)\desktop.ini"
            Remove-Item -Path $programsIniFilePath -Force | Out-Null

            $curDestFolder = "C:\Windows\Cursors"
            $RegConnect = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"CurrentUser","$env:COMPUTERNAME")
            $RegCursors = $RegConnect.OpenSubKey("Control Panel\Cursors",$true)
            $RegCursors.SetValue("","Windows Aero")
            $RegCursors.SetValue("AppStarting","$curDestFolder\aero_working.ani")
            $RegCursors.SetValue("Arrow","$curDestFolder\aero_arrow.cur")
            $RegCursors.SetValue("Crosshair","$curDestFolder\aero_cross.cur")
            $RegCursors.SetValue("Hand","$curDestFolder\aero_link.cur")
            $RegCursors.SetValue("Help","$curDestFolder\aero_helpsel.cur")
            $RegCursors.SetValue("IBeam","$curDestFolder\aero_beam.cur")
            $RegCursors.SetValue("No","$curDestFolder\aero_unavail.cur")
            $RegCursors.SetValue("NWPen","$curDestFolder\aero_pen.cur")
            $RegCursors.SetValue("SizeAll","$curDestFolder\aero_move.cur")
            $RegCursors.SetValue("SizeNESW","$curDestFolder\aero_nesw.cur")
            $RegCursors.SetValue("SizeNS","$curDestFolder\aero_ns.cur")
            $RegCursors.SetValue("SizeNWSE","$curDestFolder\aero_nwse.cur")
            $RegCursors.SetValue("SizeWE","$curDestFolder\aero_ew.cur")
            $RegCursors.SetValue("UpArrow","$curDestFolder\aero_up.cur")
            $RegCursors.SetValue("Wait","$curDestFolder\aero_busy.ani")
            $RegCursors.SetValue("Pin","$curDestFolder\aero_pin.ani")
            $RegCursors.SetValue("Person","$curDestFolder\aero_person.ani")
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

            $homeDir = "C:\Users\$env:USERNAME"
            $homePin = new-object -com shell.application
            $homePin.Namespace($homeDir).Self.InvokeVerb("pintohome") | Out-Null
            $programsDir = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs"
            $programsPin = new-object -com shell.application
            $programsPin.Namespace($programsDir).Self.InvokeVerb("pintohome") | Out-Null

            $RBPath = 'HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\pintohome\command\'
            $name = "DelegateExecute"
            $value = "{b455f46e-e4af-4035-b0a4-cf18d2f6f28e}"
            New-Item -Path $RBPath -Force | Out-Null
            New-ItemProperty -Path $RBPath -Name $name -Value $value -PropertyType String -Force | Out-Null
            $oShell = New-Object -ComObject Shell.Application
            $recycleBin = $oShell.Namespace("shell:::{645FF040-5081-101B-9F08-00AA002F954E}")
            $recycleBin.Self.InvokeVerb("PinToHome") | Out-Null
            Remove-Item -Path "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}" -Recurse | Out-Null
            Remove-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" | Out-Null
            Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" -Recurse | Out-Null
            Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarSmallIcons" | Out-Null
            Stop-Process -Name explorer -Force | Out-Null
        }
    }
}

# Clean up
Write-Host "Clean up..." -ForegroundColor Yellow
$explorerProcess = Get-Process -Name explorer -ErrorAction SilentlyContinue
if ($null -eq $explorerProcess) {
    Start-Process -FilePath explorer.exe
}
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

#EOF