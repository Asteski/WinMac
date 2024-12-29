param (
    [switch]$noGUI,
    [switch]$debug
)
$version = "0.8.0"
$date = Get-Date -Format "yy-MM-ddTHHmmss"
$logFile = "WinMac_uninstall_log_$date.txt"
$transcriptFile = "WinMac_uninstall_transcript_$date.txt"
$errorActionPreference="SilentlyContinue"
$WarningPreference="SilentlyContinue"
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
    $topTextBlock = "PowerShell uninstaller wizard for Windows and macOS hybrid"
    $bottomTextBlock1 = 'Important Notes:'
    $bottomTextBlock2 = 'PowerShell profile files will be removed, please make sure to backup your current profiles if needed.'
    $bottomTextBlock3 = 'Vim and Nexus packages will show prompt to uninstall, please confirm the uninstallations manually.'
    $bottomTextBlock4 = 'For guide on how to use the script, please refer to the Wiki page on WinMac GitHub page: https://github.com/Asteski/WinMac/wiki'
[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="WinMac Uninstaller Wizard" Height="640" Width="480" WindowStartupLocation="CenterScreen" Background="$backgroundColor" Icon="$iconFolderPath\wizard.ico">
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
                <Run Text="Win" Foreground="#0174cf"/>
                <Run Text="Mac" Foreground="#a6a6a6"/>
            </TextBlock>
            
            <!-- Static TextBlock below the title -->
            <TextBlock Text="$topTextBlock" Foreground="{StaticResource ForegroundBrush}" HorizontalAlignment="Center" Margin="0,5,0,10" TextWrapping="Wrap"/>
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
                        <CheckBox x:Name="chkTopNotify" Content="TopNotify" IsChecked="True" Grid.Row="2" Grid.Column="1" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkStahky" Content="Stahky" IsChecked="True" Grid.Row="3" Grid.Column="0" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkKeyboardShortcuts" Content="Keyboard Shortcuts" IsChecked="True" Grid.Row="3" Grid.Column="1" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkNexusDock" Content="Nexus Dock" IsChecked="True" Grid.Row="4" Grid.Column="0" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkWindhawk" Content="Windhawk" IsChecked="True" Grid.Row="4" Grid.Column="1" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkOther" Content="Other" IsChecked="True" Grid.Row="5" Grid.Column="0" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
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
    $chkTopNotify = $window.FindName("chkTopNotify")
    $chkStahky = $window.FindName("chkStahky")
    $chkKeyboardShortcuts = $window.FindName("chkKeyboardShortcuts")
    $chkNexusDock = $window.FindName("chkNexusDock")
    $chkWindhawk = $window.FindName("chkWindhawk")
    $chkOther = $window.FindName("chkOther")
    $btnUninstall = $window.FindName("btnUninstall")
    $btnCancel = $window.FindName("btnCancel")
    $fullUninstall.Add_Checked({$componentSelection.IsEnabled = $false})
    $customUninstall.Add_Checked({$componentSelection.IsEnabled = $true})
    $result = @{}
    $btnUninstall.Add_Click({
        if ($fullUninstall.IsChecked) { $selection = "1","2","3","4","5","6","7","8","9","10","11" } 
        else {
            if ($chkPowerToys.IsChecked) { $selection += "1," }
            if ($chkEverything.IsChecked) { $selection += "2," }
            if ($chkPowershellProfile.IsChecked) { $selection += "3," }
            if ($chkStartAllBack.IsChecked) { $selection += "4," }
            if ($chkWinMacMenu.IsChecked) { $selection += "5," }
            if ($chkTopNotify.IsChecked) { $selection += "6," }
            if ($chkStahky.IsChecked) { $selection += "7," }
            if ($chkKeyboardShortcuts.IsChecked) { $selection += "8," }
            if ($chkNexusDock.IsChecked) { $selection += "9," }
            if ($chkWindhawk.IsChecked) { $selection += "10," }
            if ($chkOther.IsChecked) { $selection += "11" }
        }
        $appList = @{"1"="PowerToys"; "2"="Everything"; "3"="Powershell Profile"; "4"="StartAllBack"; "5"="WinMac Menu"; "6"="TopNotify"; "7"="Stahky"; "8"="Keyboard Shortcuts"; "9"="Nexus Dock"; "10"="Windhawk"; "11"="Other Settings"}
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
        $selectedApps = "1","2","3","4","5","6","7","8","9","10","11"
        Write-Host "Choosing full uninstallation." -ForegroundColor Yellow
    }
    elseif ($fullOrCustom -eq 'C' -or $fullOrCustom -eq 'c') {
        Write-Host "Choosing custom uninstallation." -ForegroundColor Yellow
        Start-Sleep 1
        $appList = @{"1"="PowerToys"; "2"="Everything"; "3"="Powershell Profile"; "4"="StartAllBack"; "5"="WinMac Menu"; "6"="TopNotify"; "7"="Stahky"; "8"="Keyboard Shortcuts"; "9"="Nexus Dock"; "10"="Windhawk"; "11"="Other"}
Write-Host @"

`e[93m$("Please select options you want to uninstall:")`e[0m

"@
        Write-Host "1. PowerToys"
        Write-Host "2. Everything"
        Write-Host "3. Powershell Profile"
        Write-Host "4. StartAllBack"
        Write-Host "5. WinMac Menu"
        Write-Host "6. TopNotify"
        Write-Host "7. Stahky"
        Write-Host "8. Keyboard Shortcuts"
        Write-Host "9. Nexus Dock"
        Write-Host "10. Windhawk"
        Write-Host "11. Other Settings"
        Write-Host
        do {
            $selection = Read-Host "Enter the numbers of options you want to uninstall (separated by commas)"
            $selection = $selection.Trim()
            $selection = $selection -replace '\s*,\s*', ','
            $valid = $selection -match '^([1-9]|10|11)(,([1-9]|10|11))*$'
            if (!$valid) {
                Write-Host "`e[91mInvalid input! Please enter numbers between 1 and 10, separated by commas.`e[0m`n"
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
        $selectedApps = "1","2","3","4","5","6","7","8","9","10","11"
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
Write-Host "Starting uninstallation process in..." -ForegroundColor Green
for ($a=3; $a -ge 0; $a--) {
    Write-Host -NoNewLine "`b$a" -ForegroundColor Green
    Start-Sleep 1
}
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
            Invoke-Output { Uninstall-WinGetPackage -id Microsoft.PowerToys }
            Write-Host "Uninstalling PowerToys completed." -ForegroundColor Green
        }
    # Everything
        "2" {
            Write-Host "Uninstalling Everything..."  -ForegroundColor Yellow
            Invoke-Output { Uninstall-WinGetPackage -id Voidtools.Everything }
            $programsDir = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs"
            Remove-Item -Path "$programsDir\Everything.lnk" -Force
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
            foreach ($app in $winget) {Invoke-Output { Uninstall-WinGetPackage -id $app }}
            Uninstall-Module PSTree -Force
            if ((Test-Path "$profilePath\PowerShell\$profileFile")) { Remove-Item -Path "$profilePath\PowerShell\$profileFile" }
            if ((Test-Path "$profilePath\WindowsPowerShell\$profileFile")) { Remove-Item -Path "$profilePath\WindowsPowerShell\$profileFile" }
            $programsDir = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs"
            Remove-Item -Path "$programsDir\gVim*" -Force
            Write-Host "Uninstalling PowerShell Profile completed." -ForegroundColor Green
        }
    # StartAllBack
        "4" {
            Write-Host "Uninstalling StartAllBack..." -ForegroundColor Yellow
            Invoke-Output { Uninstall-WinGetPackage -id "StartIsBack.StartAllBack" }
            $exRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
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
            Stop-Process -Name WindowsKey -Force
            Stop-Process -Name StartButton -Force
            Invoke-Output { Uninstall-WinGetPackage -name "Winver UWP" }
            $tasks = Get-ScheduledTask -TaskPath "\WinMac\" -ErrorAction SilentlyContinue | Where-Object { $_.TaskName -match 'Start Button|Windows Key' }
            foreach ($task in $tasks) { Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false }
            $tasksFolder = Get-ScheduledTask -TaskPath "\WinMac\" -ErrorAction SilentlyContinue
            if ($null -eq $tasksFolder) { schtasks /DELETE /TN \WinMac /F > $null 2>&1 }
            Get-ChildItem "$env:LOCALAPPDATA\WinMac" | Where-Object { $_.Name -match 'startbutton|windowskey' } | Remove-Item -Recurse -Force
            Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Windows" -Filter "WinX" -Recurse -Force | ForEach-Object { Remove-Item $_.FullName -Recurse -Force }
            Expand-Archive -Path "..\config\WinX-default.zip" -Destination "$env:LOCALAPPDATA\Microsoft\Windows\" -Force
            $sabRegPath = "HKCU:\Software\StartIsBack"
            Set-ItemProperty -Path $sabRegPath -Name "WinkeyFunction" -Value 0 -ErrorAction SilentlyContinue
            Stop-Process -n Explorer
            Write-Host "Uninstalling WinMac Menu completed." -ForegroundColor Green
        }
    # TopNotify
        "6" {
            Write-Host "Uninstalling TopNotify..." -ForegroundColor Yellow
            Invoke-Output { Uninstall-WinGetPackage -name TopNotify }
            Write-Host "Uninstalling TopNotify completed." -ForegroundColor Green
        }
    # Stahky
        "7" {
            Write-Host "Uninstalling Stahky..." -ForegroundColor Yellow
            $exePath = "$env:LOCALAPPDATA\Stahky"
            Remove-Item -Path $exePath -Recurse -Force
            Write-Host "Uninstalling Stahky completed." -ForegroundColor Green
        }
    # Keyboard Shortcuts
        "8" {
            Write-Host "Uninstalling Keyboard Shortcuts..." -ForegroundColor Yellow
            Stop-Process -Name KeyShortcuts -Force
            $tasks = Get-ScheduledTask -TaskPath "\WinMac\" -ErrorAction SilentlyContinue | Where-Object { $_.TaskName -match 'Keyboard Shortcuts' }
            foreach ($task in $tasks) { Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false }
            $tasksFolder = Get-ScheduledTask -TaskPath "\WinMac\" -ErrorAction SilentlyContinue
            if ($null -eq $tasksFolder) { schtasks /DELETE /TN \WinMac /F > $null 2>&1 }
            Get-ChildItem "$env:LOCALAPPDATA\WinMac" | Where-Object { $_.Name -match 'keyshortcuts' } | Remove-Item -Recurse -Force
            Write-Host "Uninstalling Keyboard Shortcuts completed." -ForegroundColor Green
        }
    # Nexus Dock
        "9" {
            Write-Host "Uninstalling Nexus Dock..." -ForegroundColor Yellow
            Get-Process Nexus | Stop-Process -Force
            Invoke-Output { Uninstall-WinGetPackage -name Nexus }
            $programsDir = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs"
            Remove-Item -Path "$programsDir\Nexus.lnk" -Force
            Write-Host "Uninstalling Nexus Dock completed." -ForegroundColor Green
        }
    # Windhawk
        "10" {
            Write-Host "Uninstalling Windhawk..." -ForegroundColor Yellow
            Stop-Process -name windhawk -force
            Invoke-Output {Uninstall-WinGetPackage -name Windhawk}
            Write-Host "Uninstalling Windhawk completed." -ForegroundColor Green
        }
    # Other
        "11" {
            Write-Host "Uninstalling Other Settings..." -ForegroundColor Yellow
            $regPath = "HKCU:\SOFTWARE\WinMac"
            $exRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
            Set-ItemProperty -Path $regPath -Name "QuickAccess" -Value 0
            Set-ItemProperty -Path $exRegPath\HideDesktopIcons\NewStartPanel -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Value 0
            $homeDir = "C:\Users\$env:USERNAME"
            $homeIniFilePath = "$($homeDir)\desktop.ini"
            Invoke-Output { Remove-Item -Path $homeIniFilePath -Force }
            $programsDir = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs"
            $programsIniFilePath = "$($programsDir)\desktop.ini"
            Invoke-Output { Remove-Item -Path $programsIniFilePath -Force }
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
            Invoke-Output { $CursorRefresh::SystemParametersInfo(0x0057,0,$null,0) }
            $homeDir = "C:\Users\$env:USERNAME"
            $homePin = new-object -com shell.application
            Invoke-Output { $homePin.Namespace($homeDir).Self.InvokeVerb("pintohome") }
            $programsDir = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs"
            $programsPin = new-object -com shell.application
            Invoke-Output { $programsPin.Namespace($programsDir).Self.InvokeVerb("pintohome") }
            $RBPath = 'HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\pintohome\command\'
            $name = "DelegateExecute"
            $value = "{b455f46e-e4af-4035-b0a4-cf18d2f6f28e}"
            Invoke-Output { New-Item -Path $RBPath -Force }
            Invoke-Output { New-ItemProperty -Path $RBPath -Name $name -Value $value -PropertyType String -Force }
            $oShell = New-Object -ComObject Shell.Application
            $recycleBin = $oShell.Namespace("shell:::{645FF040-5081-101B-9F08-00AA002F954E}")
            Invoke-Output { $recycleBin.Self.InvokeVerb("PinToHome") }
            Invoke-Output { Remove-Item -Path "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}" -Recurse }
            Invoke-Output { Remove-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" }
            Invoke-Output { Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" -Recurse }
            Invoke-Output { Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarSmallIcons" }
            Get-ChildItem ..\config\contextmenu\add\* -e *theme* | ForEach-Object { reg import $_.FullName > $null 2>&1 }
            Get-ChildItem '..\config\contextmenu\remove\Remove_Theme_Mode_in_Context_Menu.reg' | ForEach-Object { reg import $_.FullName > $null 2>&1 }
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{f874310e-b6b7-47dc-bc84-b9e6b38f5903}" -Force | Out-Null
            New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Desktop\NameSpace\{e88865ea-0e1c-4e20-9aa6-edcd0212c87c}" -Force | Out-Null
            Set-ItemProperty -Path $regPath -Name "IconPack" -Value 0 | Out-Null
            Invoke-Output { Uninstall-WinGetPackage -name 'IconPack Installer' }
            Start-Sleep -Seconds 60
            Stop-Process -Name explorer -Force
            Write-Host "Uninstalling Other Settings completed." -ForegroundColor Green
        }
    }
}
# Clean up
if ((Get-ChildItem -Path "$env:LOCALAPPDATA\WinMac" -Recurse | Measure-Object).Count -eq 0) { Remove-Item -Path "$env:LOCALAPPDATA\WinMac" -Force }
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