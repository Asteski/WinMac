param (
    [switch]$noGUI
)
$version = "1.0.0"
$sysType = (Get-WmiObject -Class Win32_ComputerSystem).SystemType
$date = Get-Date -Format "yy-MM-ddTHHmmss"
$logFile = "WinMac_uninstall_log_$date.txt"
$transcriptFile = "WinMac_uninstall_transcript_$date.txt"
$errorActionPreference="SilentlyContinue"
$WarningPreference="SilentlyContinue"
$programsDir = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs"
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
if (-not (Test-Path -Path "../temp")) {New-Item -ItemType Directory -Path "../temp" | Out-Null}
if (-not (Test-Path -Path "../logs")) {New-Item -ItemType Directory -Path "../logs" | Out-Null}
$user = [Security.Principal.WindowsIdentity]::GetCurrent()
$adminTest = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
$checkDir = Get-ChildItem '..'
if (!($checkDir -like "*WinMac*" -and $checkDir -like "*config*" -and $checkDir -like "*bin*" -and $checkDir -like "*pwsh*")) {
    Write-Host "WinMac components not found. Please make sure to run the script from the correct directory." -ForegroundColor Red
    Start-Sleep 2
    exit
}
function Invoke-Output {
    param ([scriptblock]$Command)
    $output = & $Command 2>&1
    $output | Out-File -FilePath "..\logs\$logFile" -Append
    if ($debug -and $output) {$output}
}
function Get-WindowsTheme {
    try {
        $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        $appsUseLightTheme = Get-ItemProperty -Path $key -Name AppsUseLightTheme
        if ($appsUseLightTheme.AppsUseLightTheme -eq 0) {
            return "Dark"
        } else {
            return "Light" 
        }
    } catch {
        return "Light"
    }
}
$windowsTheme = Get-WindowsTheme
if (!($noGUI)) {
    $backgroundColor = if ($windowsTheme -eq "Dark") { "#1E1E1E" } else { "#eff4f9" }
    $foregroundColor = if ($windowsTheme -eq "Dark") { "#f3f3f3" } else { "#1b1b1b" }
    $accentColor = if ($windowsTheme -eq "Dark") { "#0078D4" } else { "#fcfcfc" }
    $secondaryBackgroundColor = if ($windowsTheme -eq "Dark") { "#2D2D2D" } else { "#fcfcfc" }
    $borderColor = if ($windowsTheme -eq "Dark") { "#2D2D2D" } else { "#e5e5e5" }
    $parentDirectory = Split-Path -Path $PSScriptRoot -Parent
    $iconFolderName = "config"
    $iconFolderPath = Join-Path -Path $parentDirectory -ChildPath $iconFolderName
    $topTextBlock = "Windows and macOS Hybrid Uninstallation Wizard"
    $bottomTextBlock1 = 'Important Notes'
    $bottomTextBlock2 = 'Please disable Windows Defender/3rd party Anti-virus, to prevent issues with uninsalling icons pack.'
    $bottomTextBlock3 = 'PowerShell profile files will be removed, please make sure to backup your current profiles if needed.'
    $bottomTextBlock4 = 'Vim, Nexus, Windhawk and Icons Pack will show prompt to uninstall, please confirm the uninstallations manually.'
[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="WinMac Uninstaller Wizard" Height="660" Width="480" WindowStartupLocation="CenterScreen" Background="$backgroundColor" Icon="$iconFolderPath\wizard.ico">
    <Window.Resources>
        <SolidColorBrush x:Key="BackgroundBrush" Color="$backgroundColor"/>
        <SolidColorBrush x:Key="ForegroundBrush" Color="$foregroundColor"/>
        <SolidColorBrush x:Key="AccentBrush" Color="$accentColor"/>
        <SolidColorBrush x:Key="SecondaryBackgroundBrush" Color="$secondaryBackgroundColor"/>
        <SolidColorBrush x:Key="BorderBrush" Color="$borderColor"/>
        <Thickness x:Key="BorderThickness">0</Thickness>  <!-- Corrected Thickness -->
    </Window.Resources>

    <Grid Background="{StaticResource BackgroundBrush}">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        
        <!-- Title -->
        <StackPanel Grid.Row="0" HorizontalAlignment="Center">
            <TextBlock FontSize="20" FontWeight="Bold" HorizontalAlignment="Center" Margin="0,10,0,10">
                <Run Text="WinMac" Foreground="#0174cf"/>
            </TextBlock>
            
            <!-- Static TextBlock below the title -->
            <TextBlock Text="Version $version" Foreground="{StaticResource ForegroundBrush}" HorizontalAlignment="Center" Margin="0,5,0,5" TextWrapping="Wrap"/>
            <TextBlock Text="$topTextBlock" Foreground="{StaticResource ForegroundBrush}" HorizontalAlignment="Center" Margin="0,5,0,13" TextWrapping="Wrap"/>
        </StackPanel>

        <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto">
            <StackPanel VerticalAlignment="Top">
                <!-- Uninstalltion Type -->
                <GroupBox Header="Select Uninstaller Type" Margin="0,5,0,5" Padding="5,5,5,5" Foreground="{StaticResource ForegroundBrush}" Background="{StaticResource SecondaryBackgroundBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="{StaticResource BorderThickness}">
                    <Grid Margin="5">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*" />
                            <ColumnDefinition Width="*" />
                        </Grid.ColumnDefinitions>
                        <RadioButton x:Name="fullUninstall" Content="Full" IsChecked="True" Grid.Column="0" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <RadioButton x:Name="customUninstall" Content="Custom" Grid.Column="1" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                    </Grid>
                </GroupBox>

                <!-- Component Selection -->
                <GroupBox Header="Choose Components" Margin="0,5,0,5" Padding="5,5,5,5" x:Name="componentSelection" IsEnabled="False" Foreground="{StaticResource ForegroundBrush}" Background="{StaticResource SecondaryBackgroundBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="{StaticResource BorderThickness}">
                    <Grid Margin="5">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*" />
                            <ColumnDefinition Width="*" />
                        </Grid.ColumnDefinitions>
                        <Grid.RowDefinitions>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                            <RowDefinition Height="Auto"/>
                        </Grid.RowDefinitions>

                        <CheckBox x:Name="chkPowerToys" Content="PowerToys" IsChecked="True" Grid.Row="0" Grid.Column="0" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkEverything" Content="Everything" IsChecked="True" Grid.Row="0" Grid.Column="1" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkPowershellProfile" Content="PowerShell Profile" IsChecked="True" Grid.Row="1" Grid.Column="0" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkStartAllBack" Content="StartAllBack" IsChecked="True" Grid.Row="1" Grid.Column="1" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkWinMacMenu" Content="WinMac Menu" IsChecked="True" Grid.Row="2" Grid.Column="0" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkWindhawk" Content="Windhawk" IsChecked="True" Grid.Row="2" Grid.Column="1" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkStahky" Content="Stahky" IsChecked="True" Grid.Row="3" Grid.Column="0" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkAutoHotkey" Content="Keyboard Shortcuts" IsChecked="True" Grid.Row="3" Grid.Column="1" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkNexusDock" Content="Nexus Dock" IsChecked="True" Grid.Row="4" Grid.Column="0" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkHotCorners" Content="Hot Corners" IsChecked="True" Grid.Row="4" Grid.Column="1" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkMacType" Content="MacType" IsChecked="True" Grid.Row="5" Grid.Column="0" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkOther" Content="Other" IsChecked="True" Grid.Row="5" Grid.Column="1" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                    </Grid>
                </GroupBox>

                <!-- 2x2 GroupBox Layout -->
                <Grid>
                    <Grid.RowDefinitions>
                        <RowDefinition Height="*" />
                        <RowDefinition Height="*" />
                        <RowDefinition Height="Auto"/> <!-- For the TextBlock -->
                    </Grid.RowDefinitions>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="*" />
                        <ColumnDefinition Width="*" />
                    </Grid.ColumnDefinitions>
                </Grid>
                    <!-- TextBlock below the last row of GroupBoxes -->
                    <TextBlock FontSize="14" Foreground="{StaticResource ForegroundBrush}" FontWeight="Bold" HorizontalAlignment="Center" Margin="10" Text="$bottomTextBlock1" TextWrapping="Wrap"/>
                    <TextBlock Margin="10" Foreground="{StaticResource ForegroundBrush}" Text="$bottomTextBlock2" TextWrapping="Wrap"/>
                    <TextBlock Margin="10" Foreground="{StaticResource ForegroundBrush}" Text="$bottomTextBlock3" TextWrapping="Wrap"/>
                    <TextBlock Margin="10" Foreground="{StaticResource ForegroundBrush}" Text="$bottomTextBlock4" TextWrapping="Wrap"/>

            </StackPanel>
        </ScrollViewer>

        <!-- Buttons -->
        <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Center">
            <Button x:Name="btnUninstall" Content="Uninstall" Width="100" Height="30" Margin="10" Foreground="{StaticResource ForegroundBrush}" Background="{StaticResource AccentBrush}"/>
            <Button x:Name="btnCancel" Content="Cancel" Width="100" Height="30" Margin="10" Foreground="{StaticResource ForegroundBrush}" Background="{StaticResource SecondaryBackgroundBrush}"/>
        </StackPanel>
    </Grid>
</Window>
"@
    $reader = New-Object System.Xml.XmlNodeReader $xaml
    $window = [Windows.Markup.XamlReader]::Load($reader)
    $fullUninstall = $window.FindName("fullUninstall")
    $customUninstall = $window.FindName("customUninstall")
    $componentSelection = $window.FindName("componentSelection")
    $chkPowerToys = $window.FindName("chkPowerToys")
    $chkEverything = $window.FindName("chkEverything")
    $chkPowershellProfile = $window.FindName("chkPowershellProfile")
    $chkStartAllBack = $window.FindName("chkStartAllBack")
    $chkWinMacMenu = $window.FindName("chkWinMacMenu")
    $chkWindhawk = $window.FindName("chkWindhawk")
    $chkStahky = $window.FindName("chkStahky")
    $chkAutoHotkey = $window.FindName("chkAutoHotkey")
    $chkNexusDock = $window.FindName("chkNexusDock")
    $chkHotCorners = $window.FindName("chkHotCorners")
    $chkMacType = $window.FindName("chkMacType")
    $chkOther = $window.FindName("chkOther")
    $btnUninstall = $window.FindName("btnUninstall")
    $btnCancel = $window.FindName("btnCancel")
    $fullUninstall.Add_Checked({$componentSelection.IsEnabled = $false})
    $customUninstall.Add_Checked({$componentSelection.IsEnabled = $true})
    $result = @{}
    $btnUninstall.Add_Click({
        if ($fullUninstall.IsChecked) { $selection = "1","2","3","4","5","6","7","8","9","10","11","12" } 
        else {
            if ($chkPowerToys.IsChecked) { $selection += "1," }
            if ($chkEverything.IsChecked) { $selection += "2," }
            if ($chkPowershellProfile.IsChecked) { $selection += "3," }
            if ($chkStartAllBack.IsChecked) { $selection += "4," }
            if ($chkWinMacMenu.IsChecked) { $selection += "5," }
            if ($chkWindhawk.IsChecked) { $selection += "6," }
            if ($chkStahky.IsChecked) { $selection += "7," }
            if ($chkAutoHotkey.IsChecked) { $selection += "8," }
            if ($chkNexusDock.IsChecked) { $selection += "9," }
            if ($chkHotCorners.IsChecked) { $selection += "10," }
            if ($chkMacType.IsChecked) { $selection += "11," }
            if ($chkOther.IsChecked) { $selection += "12" }
        }
        $appList = @{"1"="PowerToys"; "2"="Everything"; "3"="Powershell Profile"; "4"="StartAllBack"; "5"="WinMac Menu"; "6"="Windhawk"; "7"="Stahky"; "8"="AutoHotkey"; "9"="Nexus Dock"; "10"="Hot Corners"; "11"="MacType"; "12"="Other"}
        $result["selectedApps"] = $selection.Split(',').TrimEnd(',')
        $selectedAppNames = @()
        foreach ($appNumber in $selection) {
            if ($appList.ContainsKey($appNumber)) {
                $selectedAppNames += $appList[$appNumber]
            }
        }
        $result = [System.Windows.MessageBox]::Show("Do you wish to continue uninstallation?", "WinMac Uninstall", [System.Windows.MessageBoxButton]::OKCancel, [System.Windows.MessageBoxImage]::Information) 
        if ($result -eq 'OK') {
            $isUninstallCompleted = $true
            $window.Close()
        }
    })
    $window.Add_Closed({
        if (-not $isUninstallCompleted) {
            Stop-Process -Id $PID
        }
    })
    $btnCancel.Add_Click({
        $window.Close()
        exit
    })
    $window.ShowDialog() | Out-Null
}
else {
    Clear-Host
Write-Host @"
-----------------------------------------------------------------------

Welcome to WinMac Deployment!

Version: $version
Author: Asteski
GitHub: https://github.com/Asteski/WinMac

This is work in progress. You're using this script at your own risk.

-----------------------------------------------------------------------
"@ -ForegroundColor Cyan
Write-Host @"

This script is responsible for uninstalling all or specific WinMac 
components.

Please disable Windows Defender/3rd party Anti-virus, to prevent issues 
with uninstalling icons pack.

PowerShell profile files will be removed, please make sure to backup 
your current profiles if needed.

Vim and Nexus packages will show prompt to uninstall, please confirm the
uninstallations manually.

The author of this script is not responsible for any damage caused by 
running it.

For guide on how to use the script, please refer to the Wiki page 
on WinMac GitHub page:

https://github.com/Asteski/WinMac/wiki

"@ -ForegroundColor Yellow
    if (-not $adminTest) {Write-Host "Script is not running in elevated session." -ForegroundColor Red} else {Write-Host "Script is running in elevated session." -ForegroundColor Green}
    Write-Host "`n-----------------------------------------------------------------------" -ForegroundColor Cyan
    # WinMac configuration
    $fullOrCustom = Read-Host "`nEnter 'F' for full or 'C' for custom uninstallation"
    if ($fullOrCustom -eq 'F' -or $fullOrCustom -eq 'f') {
        $selectedApps = "1","2","3","4","5","6","7","8","9","10","11","12"
        Write-Host "Choosing full uninstallation." -ForegroundColor Yellow
    }
    elseif ($fullOrCustom -eq 'C' -or $fullOrCustom -eq 'c') {
        Write-Host "Choosing custom uninstallation." -ForegroundColor Yellow
        Start-Sleep 1
        $appList = @{"1"="PowerToys"; "2"="Everything"; "3"="Powershell Profile"; "4"="StartAllBack"; "5"="WinMac Menu"; "6"="Windhawk"; "7"="Stahky"; "8"="Keyboard Shortcuts"; "9"="Nexus Dock"; "10"="Hot Corners"; "11"="MacType"; "12"="Other"}
Write-Host @"

`e[93m$("Please select options you want to uninstall:")`e[0m

"@
        Write-Host "1. PowerToys"
        Write-Host "2. Everything"
        Write-Host "3. Powershell Profile"
        Write-Host "4. StartAllBack"
        Write-Host "5. WinMac Menu"
        Write-Host "6. Windhawk"
        Write-Host "7. Stahky"
        Write-Host "8. Keyboard Shortcuts"
        Write-Host "9. Nexus Dock"
        Write-Host "10. Hot Corners"
        Write-Host "11. MacType"
        Write-Host "12. Other Settings"
        Write-Host
        do {
            $selection = Read-Host "Enter the numbers of options you want to uninstall (separated by commas)"
            $selection = $selection.Trim()
            $selection = $selection -replace '\s*,\s*', ','
            $valid = $selection -match '^([1-9]|10|11|12)(,([1-9]|10|11|12))*$'
            if (!$valid) {
                Write-Host "`e[91mInvalid input! Please enter numbers between 1 and 12, separated by commas.`e[0m`n"
            }
        } while ([string]::IsNullOrWhiteSpace($selection) -or !$valid)
        $selectedApps = @()
        $selectedApps = $selection.Split(',')
        $selectedAppNames = @()
        foreach ($appNumber in $selectedApps) {
            if ($appList.ContainsKey($appNumber)) {
                $selectedAppNames += $appList[$appNumber]
            }
        }
        $selectedApps = @()
        $selectedApps = $selection.Split(',')
        $selectedAppNames = @()
        foreach ($appNumber in $selectedApps) {
            if ($appList.ContainsKey($appNumber)) {
                $selectedAppNames += $appList[$appNumber]
            }
        }
        Write-Host "`e[92m$("Selected options:")`e[0m $($selectedAppNames -join ', ')"
    }
    else
    {
        $selectedApps = "1","2","3","4","5","6","7","8","9","10","11","12"
        Write-Host "Invalid input. Defaulting to full uninstallation." -ForegroundColor Yellow
    }
    Start-Sleep 1
    Write-Host
    $installConfirmation = Read-Host "Are you sure you want to start the uninstallation process (Y/n)"

    if ($installConfirmation -ne 'y' -or $installConfirmation -ne 'Y') {
        Write-Host "Uninstallation process aborted." -ForegroundColor Red
        Start-Sleep 2
        exit
    }
}
if ($result){
    $selectedApps = $result["selectedApps"]
}
for ($a=3; $a -ge 0; $a--) {
    Write-Host "`rStarting uninstallation process in $a" -NoNewLine -ForegroundColor Yellow
    Start-Sleep 1
}
Write-Host "`r" -NoNewline
Write-Host "`n-----------------------------------------------------------------------`n" -ForegroundColor Cyan
Start-Transcript -Path ../logs/$transcriptFile -Append | Out-Null
# Nuget check
Write-Host "Checking Package Provider (Nuget)" -ForegroundColor Yellow
$nugetProvider = Get-PackageProvider -Name NuGet
if ($null -eq $nugetProvider) {
    Write-Host "NuGet is not installed. Installing NuGet..." -ForegroundColor DarkYellow
    Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
    Write-Host "NuGet installation completed." -ForegroundColor Green
} else {
    Write-Host "NuGet is already installed." -ForegroundColor Green
}
# Winget check
Write-Host "Checking Package Manager (Winget)" -ForegroundColor Yellow
$wingetCliCheck = winget -v
if ($null -eq $wingetCliCheck) {
    $progressPreference = 'silentlyContinue'
    Write-Information "Downloading Winget and its dependencies..."
    Invoke-WebRequest -Uri 'https://aka.ms/getwinget' -OutFile '..\temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
    Invoke-WebRequest -Uri 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx' -OutFile '..\temp\Microsoft.VCLibs.x64.14.00.Desktop.appx'
    Invoke-WebRequest -Uri 'https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx' -OutFile '..\temp\Microsoft.UI.Xaml.2.8.x64.appx'
    Add-AppxPackage '..\temp\Microsoft.VCLibs.x64.14.00.Desktop.appx'
    Add-AppxPackage '..\temp\Microsoft.UI.Xaml.2.8.x64.appx'
    Add-AppxPackage '..\temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
}
$wingetClientCheck = Get-InstalledModule -Name Microsoft.WinGet.Client -ErrorAction SilentlyContinue
if ($null -eq $wingetClientCheck) {
    Write-Host "Winget is not installed. Installing Winget..." -ForegroundColor DarkYellow
    Install-Module -Name Microsoft.WinGet.Client -Force
    Write-Host "Winget installation completed." -ForegroundColor Green
} else {
    $wingetFind = Find-Module -Name Microsoft.WinGet.Client
    if ($wingetFind.Version -gt $wingetClientCheck.Version) {
        Write-Host "A newer version of Winget is available. Updating Winget..." -ForegroundColor DarkYellow
        Update-Module -Name Microsoft.WinGet.Client -Force
        Write-Host "Winget update completed." -ForegroundColor Green
    } else {
        Write-Host "Winget is already installed." -ForegroundColor Green
    }
}
Import-Module -Name Microsoft.WinGet.Client -Force
# WinMac deployment
foreach ($app in $selectedApps) {
    switch ($app.Trim()) {
    # PowerToys
        "1" {
            Write-Host "Uninstalling PowerToys..."  -ForegroundColor Yellow
            Get-Process | Where-Object { $_.ProcessName -eq 'PowerToys' } | Stop-Process -Force
            $everythingPT = Get-WingetPackage -name EverythingPT -ErrorAction SilentlyContinue
            Uninstall-WinGetPackage -$everythingPT.name | Out-Null
            Uninstall-WinGetPackage -id Microsoft.PowerToys | Out-Null
            Remove-Item $env:LOCALAPPDATA\Microsoft\PowerToys -Recurse -Force
            Remove-Item $env:LOCALAPPDATA\PowerToys -Recurse -Force
            Write-Host "Uninstalling PowerToys completed." -ForegroundColor Green
        }
    # Everything
        "2" {
            Write-Host "Uninstalling Everything..."  -ForegroundColor Yellow
            Uninstall-WinGetPackage -id Voidtools.Everything | Out-Null
            Remove-Item -Path "$programsDir\Everything.lnk" -Force
            Remove-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Everything" -Recurse | Out-Null
            while (Get-WinGetPackage -id Voidtools.Everything -ErrorAction SilentlyContinue) {
                Start-Sleep -Seconds 5
            }
            Remove-Item $env:APPDATA\Everything -Recurse -Force
            Remove-Item $env:LOCALAPPDATA\Everything -Recurse -Force
            Write-Host "Uninstalling Everything completed." -ForegroundColor Green
        }
    # PowerShell Profile
        "3" {
            Write-Host "Uninstalling PowerShell Profile..." -ForegroundColor Yellow
            $profilePath = $PROFILE | Split-Path | Split-Path
            $profileFile = $PROFILE | Split-Path -Leaf
            $winget = @(
                "Vim.Vim",
                "gsass1.NTop"
            )
            foreach ($app in $winget) { Uninstall-WinGetPackage -id $app | Out-Null}
            Uninstall-Module PSTree -Force | Out-Null
            if ((Test-Path "$profilePath\PowerShell\$profileFile")) { Remove-Item -Path "$profilePath\PowerShell\$profileFile" }
            if ((Test-Path "$profilePath\WindowsPowerShell\$profileFile")) { Remove-Item -Path "$profilePath\WindowsPowerShell\$profileFile" }
            Remove-Item -Path "$programsDir\gVim*" -Force
            Write-Host "Uninstalling PowerShell Profile completed." -ForegroundColor Green
        }
    # StartAllBack
        "4" {
            Write-Host "Uninstalling StartAllBack..." -ForegroundColor Yellow
            $exRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
            $sabRegPath = "HKCU:\Software\StartIsBack"
            taskkill /f /im explorer.exe > $null 2>&1
            Set-ItemProperty -Path $sabRegPath\DarkMagic -Name "Unround" -Value 0
            Start-Sleep 5
            Start-Process -name explorer
            Uninstall-WinGetPackage -id "StartIsBack.StartAllBack" | Out-Null
            Set-ItemProperty -Path $exRegPath\Advanced -Name "UseCompactMode" -Value 0
            Set-ItemProperty -Path $exRegPath\Advanced -Name "TaskbarAl" -Value 1
            Set-ItemProperty -Path $exRegPath\Advanced -Name "TaskbarGlomLevel" -Value 0
            Set-ItemProperty -Path $exRegPath\Advanced -Name "LaunchTO" -Value 0
            Stop-Process -Name explorer -Force
            Write-Host "Uninstalling StartAllBack completed." -ForegroundColor Green
            Start-Sleep 3
        }
    # WinMac Menu
        "5" {
            Write-Host "Uninstalling WinMac Menu..." -ForegroundColor Yellow
            $sabRegPath = "HKCU:\Software\StartIsBack"
            if ($sysType -like "*ARM*"){
                Stop-Process -Name WindowsKey -Force
                Stop-Process -Name StartButton -Force
                $tasks = Get-ScheduledTask -TaskPath "\WinMac\" -ErrorAction SilentlyContinue | Where-Object { $_.TaskName -match 'Start Button|Windows Key' }
                foreach ($task in $tasks) { Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false }
                Get-ChildItem "$env:LOCALAPPDATA\WinMac" | Where-Object { $_.Name -match 'startbutton|windowskey' } | Remove-Item -Recurse -Force
            }
            else {
                Stop-Process -Name startmenu -Force | Out-Null
                winget uninstall --id "Open-Shell.Open-Shell-Menu" --source winget --force | Out-Null    
            }
            Uninstall-WinGetPackage -name "Winver UWP" | Out-Null
            Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Windows" -Filter "WinX" -Recurse -Force | ForEach-Object { Remove-Item $_.FullName -Recurse -Force }
            Expand-Archive -Path "..\config\WinX-default.zip" -Destination "$env:LOCALAPPDATA\Microsoft\Windows\" -Force
            Set-ItemProperty -Path $sabRegPath -Name "WinkeyFunction" -Value 0 -ErrorAction SilentlyContinue
            Remove-Item -Path "$env:LOCALAPPDATA\WinMac\start.exe" -Force
            Stop-Process -n Explorer
            Write-Host "Uninstalling WinMac Menu completed." -ForegroundColor Green
        }
    # Windhawk
        "6" {
            Write-Host "Uninstalling Windhawk..." -ForegroundColor Yellow
            Stop-Process -Name windhawk -Force
            Uninstall-WinGetPackage -name Windhawk | Out-Null
            Remove-Item -Path "$programsDir\Windhawk.lnk"
            Write-Host "Uninstalling Windhawk completed." -ForegroundColor Green
        }
    # Stahky
        "7" {
            Write-Host "Uninstalling Stahky..." -ForegroundColor Yellow
            $exePath = "$env:LOCALAPPDATA\Stahky"
            Remove-Item -Path $exePath -Recurse -Force
            Write-Host "Uninstalling Stahky completed." -ForegroundColor Green
        }
    # AutoHotkey Keyboard Shortcuts
        "8" {
            Write-Host "Uninstalling Keyboard Shortcuts..." -ForegroundColor Yellow
            Stop-Process -Name KeyShortcuts -Force
            $tasks = Get-ScheduledTask -TaskPath "\WinMac\" -ErrorAction SilentlyContinue | Where-Object { $_.TaskName -match 'Keyboard Shortcuts' }
            foreach ($task in $tasks) { Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false }
            Get-ChildItem "$env:LOCALAPPDATA\WinMac" | Where-Object { $_.Name -match 'keyshortcuts' } | Remove-Item -Recurse -Force
            Write-Host "Uninstalling Keyboard Shortcuts completed." -ForegroundColor Green
        }
    # Nexus Dock
        "9" {
            Write-Host "Uninstalling Nexus Dock..." -ForegroundColor Yellow
            Get-Process Nexus | Stop-Process -Force
            Uninstall-WinGetPackage -name Nexus | Out-Null
            Remove-Item -Path "$programsDir\Nexus.lnk" -Force
            Remove-Item -Path "C:\Users\Public\Documents\Winstep" -Recurse -Force
            Write-Host "Uninstalling Nexus Dock completed." -ForegroundColor Green
        }
    # Hot Corners
        "10" {
            Write-Host "Uninstalling Hot Corners..." -ForegroundColor Yellow
            $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
            Stop-Process -n WinXCorners -Force
            Stop-Process -n WinLaunch -Force
            Stop-Process -n ssn -Force
            Uninstall-WinGetPackage -name "Simple Sticky Notes"  | Out-Null
            winget install 9NBLGGH4QGHW --silent | Out-Null
            Remove-ItemProperty -Path $regPath -Name "WinLaunch"
            Remove-ItemProperty -Path $regPath -Name "WinXCorners"
            Remove-ItemProperty -Path $regPath -Name "Simple Sticky Notes"
            Remove-Item -Path "$env:LOCALAPPDATA\WinMac\hotcorners" -Recurse -Force
            Remove-Item -Path "$env:LOCALAPPDATA\WinLaunch" -Recurse -Force
            Remove-Item -Path "$env:LOCALAPPDATA\WinXCorners" -Recurse -Force
            Remove-Item -Path "$env:APPDATA\WinLaunch" -Recurse -Force
            Remove-Item -Path "$env:APPDATA\Simnet" -Recurse -Force
            Remove-Item -Path "$programsDir\WinXCorners.lnk" -Recurse -Force
            Remove-Item -Path "$programsDir\WinLaunch.lnk" -Recurse -Force
            Remove-Item -Path "$programsDir\Simple Sticky Notes.lnk" -Recurse -Force
            Write-Host "Uninstalling Hot Corners completed." -ForegroundColor Green
        }
    # MacType
        "11" {
            Write-Host "Uninstalling MacType..." -ForegroundColor Yellow
            Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "MacType" | Out-Null
            winget uninstall MacType --silent | Out-Null
            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name FontSmoothing -Value "2"
            Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name FontSmoothingType -Type DWord -Value 2
            RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters ,1 ,True
            Stop-Process -Name Explorer -Force -ErrorAction SilentlyContinue
             New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "MacType" -Value "$env:PROGRAMFILES\MacType\MacTray.exe" | Out-Null
            Write-Host "Uninstalling MacType completed." -ForegroundColor Green
        }
    # Other
        "12" {
            Write-Host "Uninstalling Other Settings..." -ForegroundColor Yellow
            $regPath = "HKCU:\SOFTWARE\WinMac"
            $exRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
            Get-ChildItem "C:\Windows\Cursors" -filter aero_black* | ForEach-Object { Remove-Item $_.FullName -Force }
            Set-ItemProperty -Path $regPath -Name "QuickAccess" -Value 0
            Set-ItemProperty -Path $exRegPath\HideDesktopIcons\NewStartPanel -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Value 0
            $homeDir = "C:\Users\$env:USERNAME"
            $homeIniFilePath = "$($homeDir)\desktop.ini"
            Remove-Item -Path $homeIniFilePath -Force | Out-Null
            $programsIniFilePath = "$($programsDir)\desktop.ini"
            Remove-Item -Path $programsIniFilePath -Force  | Out-Null
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
            Get-ChildItem ..\config\reg\add\* -e *theme* | ForEach-Object { reg import $_.FullName > $null 2>&1 }
            reg import '..\config\reg\remove\Remove_Theme_Mode_in_Context_Menu.reg' > $null 2>&1
            reg import '..\config\reg\remove\Remove_Hidden_items_from_context_menu.reg' > $null 2>&1
            Get-ChildItem "$env:LocalAppData\Microsoft\Windows\Explorer\" -Filter "thumbcache_*.db" | Remove-Item -Force -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" -Name "Logo" -ErrorAction SilentlyContinue
            Remove-Item -Path "$env:LOCALAPPDATA\WinMac\theme.ps1"
            Remove-Item -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Hide Desktop Icons.lnk" -Force
            Remove-Item -Path "$env:LOCALAPPDATA\WinMac\HideDesktopIcons.exe" -Force
            Write-Host "Uninstalling Other Settings completed." -ForegroundColor Green
        }
    }
}
# Clean up
if ((Get-ChildItem -Path "$env:LOCALAPPDATA\WinMac" -Recurse | Measure-Object).Count -eq 0) { Remove-Item -Path "$env:LOCALAPPDATA\WinMac" -Force }
$tasksFolder = Get-ScheduledTask -TaskPath "\WinMac\" -ErrorAction SilentlyContinue
if ($null -eq $tasksFolder) { schtasks /DELETE /TN \WinMac /F > $null 2>&1 }
$explorerProcess = Get-Process -Name explorer -ErrorAction SilentlyContinue
if ($null -eq $explorerProcess) {Start-Process -FilePath explorer.exe}
Stop-Transcript | Out-Null
Write-Host "`n------------------------ WinMac Deployment completed ------------------------" -ForegroundColor Cyan
Write-Host @"

Enjoy and support by giving feedback and contributing to the project!

For more information please visit WinMac GitHub page: 
https://github.com/Asteski/WinMac

If you have any questions or suggestions, please contact me on GitHub.

"@ -ForegroundColor Cyan

Write-Host "-----------------------------------------------------------------------------"  -ForegroundColor Cyan
Write-Host
$restartConfirmation = Read-Host "Restart computer now? It's recommended to fully apply all the changes (Y/n)"
if ($restartConfirmation -eq "Y" -or $restartConfirmation -eq "y") {
    for ($a=9; $a -ge 0; $a--) {
        Write-Host "`rRestarting computer in $a" -NoNewLine -ForegroundColor Red
        Start-Sleep 1
    }
    Restart-Computer -Force
} else {
    Write-Host "Computer will not be restarted." -ForegroundColor Green
}
#EOF