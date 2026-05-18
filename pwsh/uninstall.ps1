param (
    [switch]$noGUI
)
$version = "1.4.2"
$ErrorActionPreference = "SilentlyContinue"
$WarningPreference = "SilentlyContinue"
$ProgressPreference = "SilentlyContinue"
$programsDir = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs"
$winMacDirectory = "$env:LOCALAPPDATA\WinMac"
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
if (-not (Test-Path -Path "../temp")) {New-Item -ItemType Directory -Path "../temp" | Out-Null}
$sysType = (Get-WmiObject -Class Win32_ComputerSystem).SystemType
$user = [Security.Principal.WindowsIdentity]::GetCurrent()
$adminTest = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
$checkDir = Get-ChildItem '..'
if (!($checkDir -like "*WinMac*" -and $checkDir -like "*config*" -and $checkDir -like "*bin*" -and $checkDir -like "*pwsh*")) {
    [void][System.Windows.MessageBox]::Show("WinMac components not found. Please make sure to run the script from the correct directory.", "Missing Components", 'OK', 'Error')
    exit
}
if (-not $adminTest) {
    Add-Type -AssemblyName PresentationFramework
    [void][System.Windows.MessageBox]::Show("This script must be run as Administrator.", "Insufficient Privileges", 'OK', 'Error')
    exit
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
function Show-Header {
    Write-Host "-----------------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "                Welcome to WinMac Uninstallation Wizard                " -ForegroundColor Cyan
    Write-Host "                            Version: $version                          " -ForegroundColor Cyan
    Write-Host "                            Author: Asteski                            " -ForegroundColor Cyan
    Write-Host "               GitHub: https://github.com/Asteski/WinMac               " -ForegroundColor Cyan
    Write-Host "-----------------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host "             " -NoNewline
    Write-Host "NO LIABILITY ACCEPTED, PROCEED WITH CAUTION!" -ForegroundColor Black -BackgroundColor Red -NoNewline
    Write-Host "              "
}
$windowsTheme = Get-WindowsTheme
#* GUI
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
    $bottomTextBlock1 = '↓ Important Notes ↓'
    $bottomTextBlock2 = 'PowerShell default profile will be removed and replaced with new one. Please make sure to backup your current profile if needed.'
    $bottomTextBlock3 = 'The author of this script is not responsible for any damage caused by running it. Highly recommend to create a system restore point before proceeding with the installation process to ensure you can revert any changes if necessary.'
    $bottomTextBlock4 = 'For guide on how to use the script, please refer to the Wiki page on WinMac GitHub page.'
[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="WinMac Uninstaller Wizard" Height="500" Width="480" WindowStartupLocation="CenterScreen" Background="$backgroundColor" Icon="$iconFolderPath\wizard.ico">
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
                        <CheckBox x:Name="chkPowerShellProfile" Content="PowerShell Profile" IsChecked="True" Grid.Row="1" Grid.Column="0" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkStartAllBack" Content="StartAllBack" IsChecked="True" Grid.Row="1" Grid.Column="1" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkWinMacMenu" Content="WinMac Menu" IsChecked="True" Grid.Row="2" Grid.Column="0" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkWindhawk" Content="Windhawk" IsChecked="True" Grid.Row="2" Grid.Column="1" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkAutoHotkey" Content="Keyboard Shortcuts" IsChecked="True" Grid.Row="3" Grid.Column="0" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkNexusDock" Content="Nexus Dock" IsChecked="True" Grid.Row="3" Grid.Column="1" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkHotCorners" Content="Hot Corners" IsChecked="True" Grid.Row="4" Grid.Column="0" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkMacType" Content="MacType" IsChecked="True" Grid.Row="4" Grid.Column="1" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
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
    $chkPowerShellProfile = $window.FindName("chkPowerShellProfile")
    $chkStartAllBack = $window.FindName("chkStartAllBack")
    $chkWinMacMenu = $window.FindName("chkWinMacMenu")
    $chkWindhawk = $window.FindName("chkWindhawk")
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
        if ($fullUninstall.IsChecked) { $selection = "1","2","3","4","5","6","7","8","9","10","11" } 
        else {
            if ($chkPowerToys.IsChecked) { $selection += "1," }
            if ($chkEverything.IsChecked) { $selection += "2," }
            if ($chkPowerShellProfile.IsChecked) { $selection += "3," }
            if ($chkStartAllBack.IsChecked) { $selection += "4," }
            if ($chkWinMacMenu.IsChecked) { $selection += "5," }
            if ($chkWindhawk.IsChecked) { $selection += "6," }
            if ($chkAutoHotkey.IsChecked) { $selection += "7," }
            if ($chkNexusDock.IsChecked) { $selection += "8," }
            if ($chkHotCorners.IsChecked) { $selection += "9," }
            if ($chkMacType.IsChecked) { $selection += "10," }
            if ($chkOther.IsChecked) { $selection += "11" }
        }
        $appList = @{
                "1"="PowerToys"
                "2"="Everything"
                "3"="PowerShell Profile"
                "4"="StartAllBack"
                "5"="WinMac Menu"
                "6"="Windhawk"
                "7"="Keyboard Shortcuts"
                "8"="Nexus Dock"
                "9"="Hot Corners"
                "10"="MacType"
                "11"="Other"
        }
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
    Show-Header
Write-Host @"

The author of this script is not responsible for any damage caused by 
running it. Highly recommend to create a system restore point 
before proceeding with the installation process to ensure you can 
revert any changes if necessary.

PowerShell profile files will be removed, please make sure to backup 
your current profile if needed.

PowerToys, Vim, Nexus, Windhawk and MacType packages will show prompt
to uninstall, please confirm the uninstallations manually.

Do not restart your computer after uninstallation of MacType when 
prompted!

For guide on how to use the script, please refer to the Wiki page 
on WinMac GitHub page: https://github.com/Asteski/WinMac/wiki

"@ -ForegroundColor Yellow
    Write-Host "-----------------------------------------------------------------------" -ForegroundColor Cyan
    $fullOrCustom = Read-Host "`nEnter 'F' for full or 'C' for custom uninstallation"
    if ($fullOrCustom -eq 'F' -or $fullOrCustom -eq 'f') {
        $selectedApps = "1","2","3","4","5","6","7","8","9","10","11"
        Write-Host "Choosing full uninstallation." -ForegroundColor Yellow
        Start-Sleep 2

    }
    elseif ($fullOrCustom -eq 'C' -or $fullOrCustom -eq 'c') {
        Write-Host "Choosing custom uninstallation." -ForegroundColor Yellow
        Start-Sleep 2
        $appList = @{
                "1"="PowerToys"
                "2"="Everything"
                "3"="PowerShell Profile"
                "4"="StartAllBack"
                "5"="WinMac Menu"
                "6"="Windhawk"
                "7"="Keyboard Shortcuts"
                "8"="Nexus Dock"
                "9"="Hot Corners"
                "10"="MacType"
                "11"="Other"
        }
    Clear-Host
    Show-Header
Write-Host @"

`e[93m$("Please select options you want to uninstall:")`e[0m

"@
        Write-Host "1. PowerToys"
        Write-Host "2. Everything"
        Write-Host "3. PowerShell Profile"
        Write-Host "4. StartAllBack"
        Write-Host "5. WinMac Menu"
        Write-Host "6. Windhawk"
        Write-Host "7. Keyboard Shortcuts"
        Write-Host "8. Nexus Dock"
        Write-Host "9. Hot Corners"
        Write-Host "10. MacType"
        Write-Host "11. Other Settings"
        Write-Host
        do {
            $selection = Read-Host "Enter the numbers of options you want to uninstall (separated by commas)"
            $selection = $selection.Trim()
            $selection = $selection -replace '\s*,\s*', ','
            $valid = $selection -match '^([1-9]|10|11)(,([1-9]|10|11))*$'
            if (!$valid) {
                Write-Host "`e[91mInvalid input! Please enter numbers between 1 and 11, separated by commas.`e[0m`n"
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
        Start-Sleep 2
    }
    else
    {
        $selectedApps = "1","2","3","4","5","6","7","8","9","10","11"
        Write-Host "Invalid input. Defaulting to full uninstallation." -ForegroundColor Yellow
        Start-Sleep 2
    }
    do {
        Clear-Host
        Show-Header
        $uninstallConfirmation = Read-Host "`nAre you sure you want to start the uninstallation process (Y/n)"
        $valid = $uninstallConfirmation -match '^(y|Y|n|N)$'
    if (!$valid) {
        Write-Host "`e[91mInvalid input! Please enter either (Y)es or (N)o.`e[0m`n"
        Start-Sleep 2
    }
} while (!$valid)

if ($uninstallConfirmation -eq 'n' -or $uninstallConfirmation -eq 'N') {
    Clear-Host
    Show-Header
    Write-Host "`n`e[91mUninstallation process aborted.`e[0m"
    Start-Sleep 2
    Clear-Host
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
#* Nuget check
Clear-Host
Show-Header
Write-Host
Write-Host "Checking Package Provider (Nuget)" -ForegroundColor Yellow
$nugetProvider = Get-PackageProvider -Name NuGet
if ($null -eq $nugetProvider) {
    Write-Host "NuGet is not installed. Installing NuGet..." -ForegroundColor DarkYellow
    Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
    Write-Host "NuGet installation completed." -ForegroundColor Green
} else {
    Write-Host "NuGet is already installed." -ForegroundColor Green
}
#* Winget check
Write-Host "Checking Package Manager (Winget)" -ForegroundColor Yellow
$wingetCliCheck = winget -v
if ($null -eq $wingetCliCheck) {
    $progressPreference = 'silentlyContinue'
    Write-Information "Downloading Winget and its dependencies..."
    Invoke-WebRequest -Uri 'https://aka.ms/getwinget' -OutFile '..\temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
    Invoke-WebRequest -Uri 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx' -OutFile '..\temp\Microsoft.VCLibs.x64.14.00.Desktop.appx'
    Invoke-WebRequest -Uri 'https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx' -OutFile '..\temp\Microsoft.UI.Xaml.2.8.x64.appx'
    Add-AppxPackage '..\bin\Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x64__8wekyb3d8bbwe.appx'
    Add-AppxPackage '..\temp\Microsoft.VCLibs.x64.14.00.Desktop.appx'
    Add-AppxPackage '..\temp\Microsoft.UI.Xaml.2.8.x64.appx'
    Add-AppxPackage '..\temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
}
$wingetClientCheck = Get-InstalledModule -Name Microsoft.WinGet.Client
if ($null -eq $wingetClientCheck) {
    Write-Host "Winget PowerShell Module is not installed. Installing Microsoft.WinGet.Client..." -ForegroundColor DarkYellow
    Install-Module -Name Microsoft.WinGet.Client -Force
    Write-Host "Winget PowerShell Module installation completed." -ForegroundColor Green
} else {
    $wingetFind = Find-Module -Name Microsoft.WinGet.Client
    if ($wingetFind.Version -gt $wingetClientCheck.Version) {
        Write-Host "A newer version of Winget PowerShell Module is available. Updating Microsoft.WinGet.Client..." -ForegroundColor DarkYellow
        Update-Module -Name Microsoft.WinGet.Client -Force
        Write-Host "Winget PowerShell Module update completed." -ForegroundColor Green
    } else {
        Write-Host "Winget PowerShell Module is already installed." -ForegroundColor Green
    }
}
Import-Module -Name Microsoft.WinGet.Client
Write-Host "`n-----------------------------------------------------------------------`n" -ForegroundColor Cyan
$wingetCliCheck = winget -v
if ($null -eq $wingetCliCheck) {
    Write-Host "Winget installation failed. Aborting installation." -ForegroundColor Red
    Start-Sleep 3
    exit 1
}
#! WinMac deployment
if ($selectedApps -like '*8*'){ Get-Process Nexus | Stop-Process -Force }
foreach ($app in $selectedApps) {
    switch ($app.Trim()) {
    #* PowerToys
        "1" {
            Write-Host "Uninstalling PowerToys..."  -ForegroundColor Yellow
            Get-Process | Where-Object { $_.ProcessName -eq 'PowerToys' } | Stop-Process -Force
            Uninstall-WinGetPackage -id Microsoft.PowerToys | Out-Null
            Start-Process "$env:LOCALAPPDATA\Microsoft\PowerToys\PowerToys Run\Plugins\Everything\uninstall.exe" -ArgumentList "/S" -Wait
            Uninstall-WinGetPackage -id QL-Win.QuickLook | Out-Null
            Uninstall-WinGetPackage -id ThioJoe.SvgThumbnailExtension | Out-Null
            Remove-Item $env:LOCALAPPDATA\Microsoft\PowerToys -Recurse -Force
            Remove-Item $env:LOCALAPPDATA\PowerToys -Recurse -Force
            Remove-Item $env:APPDATA\pooi.moe -Recurse -Force
            Remove-Item $programsDir\QuickLook.lnk -Force
            Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "QuickLook" | Out-Null
            Write-Host "Uninstalling PowerToys completed." -ForegroundColor Green
        }
    #* Everything
        "2" {
            Write-Host "Uninstalling Everything..."  -ForegroundColor Yellow
            Uninstall-WinGetPackage -id Voidtools.Everything | Out-Null
            Remove-Item -Path "$programsDir\Everything.lnk" -Force
            Remove-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Services\Everything" -Recurse | Out-Null
            while (Get-WinGetPackage -id Voidtools.Everything) {
                Start-Sleep -Seconds 5
            }
            Remove-Item $env:APPDATA\Everything -Recurse -Force
            Remove-Item $env:LOCALAPPDATA\Everything -Recurse -Force
            Write-Host "Uninstalling Everything completed." -ForegroundColor Green
        }
    #* PowerShell Profile
        "3" {
            Write-Host "Uninstalling PowerShell Profile..." -ForegroundColor Yellow
            $profilePath = $PROFILE | Split-Path | Split-Path
            $profileFile = $PROFILE | Split-Path -Leaf
            Uninstall-WinGetPackage gsass1.NTop | Out-Null
            Uninstall-Module PSTree -Force | Out-Null
            $vimPath = (Get-ChildItem "$env:PROGRAMFILES\Vim" -Directory -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
            Start-Process "$vimPath\uninstall-gui.exe" -ArgumentList "/S" -Wait
            if ((Test-Path "$profilePath\PowerShell\$profileFile")) { Remove-Item -Path "$profilePath\PowerShell\$profileFile" }
            if ((Test-Path "$profilePath\WindowsPowerShell\$profileFile")) { Remove-Item -Path "$profilePath\WindowsPowerShell\$profileFile" }
            Remove-Item -Path "$programsDir\gVim*" -Force
            Remove-Item -Path "$env:PROGRAMFILES\Vim" -Recurse -Force
            Write-Host "Uninstalling PowerShell Profile completed." -ForegroundColor Green
        }
    #* StartAllBack
        "4" {
            Write-Host "Uninstalling StartAllBack..." -ForegroundColor Yellow
            $exRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
            $sabRegPath = "HKCU:\Software\StartIsBack"
            Set-ItemProperty -Path $sabRegPath\DarkMagic -Name "Unround" -Value 0
            Stop-Process -Name explorer -Force
            Start-Sleep 3
            Uninstall-WinGetPackage -id "StartIsBack.StartAllBack" | Out-Null
            Set-ItemProperty -Path $exRegPath\Advanced -Name "ShowNotificationIcon" -Value 1
            Set-ItemProperty -Path $exRegPath\Advanced -Name "UseCompactMode" -Value 0
            Set-ItemProperty -Path $exRegPath\Advanced -Name "ShowStatusBar" -Value 1
            Set-ItemProperty -Path $exRegPath\Advanced -Name "UseCompactMode" -Value 0
            Set-ItemProperty -Path $exRegPath\Advanced -Name "TaskbarAl" -Value 1
            Set-ItemProperty -Path $exRegPath\Advanced -Name "TaskbarGlomLevel" -Value 0
            Set-ItemProperty -Path $exRegPath\Advanced -Name "LaunchTO" -Value 0
            $original = "Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy"
            $disabled = "++Microsoft.Windows.StartMenuExperienceHost_cw5n1h2txyewy"
            $originalPath = Join-Path -Path "C:\Windows\SystemApps" -ChildPath $original
            $disabledPath = Join-Path -Path "C:\Windows\SystemApps" -ChildPath $disabled
            if (Test-Path -LiteralPath $disabledPath) {
                Rename-Item -LiteralPath $disabledPath -NewName $originalPath
            }
            Stop-Process -Name explorer -Force
            Write-Host "Uninstalling StartAllBack completed." -ForegroundColor Green
            Start-Sleep 2
        }
    #* WinMac Menu
        "5" {
            Write-Host "Uninstalling WinMac Menu..." -ForegroundColor Yellow
            $sabRegPath = "HKCU:\Software\StartIsBack"
            Stop-Process -Name WinMacMenu -Force
            Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\winver.exe" -Force
            Uninstall-WinGetPackage -name "Winver UWP" | Out-Null
            Set-ItemProperty -Path $sabRegPath -Name "WinkeyFunction" -Value 0
            $toolbarsValue = [byte[]](
                0x0c,0x00,0x00,0x00,0x08,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
                0xaa,0x4f,0x28,0x68,0x48,0x6a,0xd0,0x11,0x8c,0x78,0x00,0xc0,0x4f,0xd9,0x18,0xb4,
                0x00,0x00,0x00,0x00,0x40,0x0d,0x00,0x00,0x00,0x00,0x00,0x00,0x1e,0x00,0x00,0x00,
                0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x1e,0x00,0x00,0x00,0x00,0x00,0x00,0x00,
                0x01,0x00,0x00,0x00
            )
            $taskbarLinksPath = "HKCU:\Software\StartIsBack\Taskbaz"
            if (Test-Path $taskbarLinksPath) {
                Set-ItemProperty -Path $taskbarLinksPath -Name "Toolbars" -Value $toolbarsValue -Type Binary -Force
            }
            $folderPath = Get-Item (Join-Path $Env:USERPROFILE "Favorites\Links") -Force
            if (($folderPath.Attributes -band [System.IO.FileAttributes]::Hidden) -ne 0) {
                $folderPath.Attributes = $folderPath.Attributes -band (-bnot [System.IO.FileAttributes]::Hidden)
            }
            Stop-Process -Name explorer -Force
            Remove-Item -Path "$winMacDirectory\WinMacMenu.exe" -Force
            Remove-Item -Path "$winMacDirectory\WinMacMenu.dll" -Force
            Remove-Item -Path "$winMacDirectory\config.ini" -Force
            Remove-Item -Path "$env:USERPROFILE\Links\Explorer.lnk" -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "$env:USERPROFILE\Links\Favourites.lnk" -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "$env:LOCALAPPDATA\WinMac\explorer.ini" -Force -ErrorAction SilentlyContinue
            Remove-Item -Path "$env:LOCALAPPDATA\WinMac\favourites.ini" -Force -ErrorAction SilentlyContinue
            Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "WinMac Menu" | Out-Null
            Write-Host "Uninstalling WinMac Menu completed." -ForegroundColor Green
        }
    #* Windhawk
        "6" {
            Write-Host "Uninstalling Windhawk..." -ForegroundColor Yellow
            taskkill /IM explorer.exe /F > $null 2>&1
            Stop-Process -Name windhawk -Force
            Start-Process "$env:PROGRAMFILES\Windhawk\uninstall.exe" -ArgumentList "/S" -Wait
            Remove-Item -Path "$programsDir\Windhawk.lnk"
            Remove-Item -Path "$env:WINDIR\System32\ModernShutDownWindows.exe" -Force
            Remove-Item -Path "$env:LOCALAPPDATA\IconCache.db" -Force
            Remove-Item -Path "$winMacDirectory\resource-redirect" -Recurse -Force
            Get-ChildItem "$env:LocalAppData\Microsoft\Windows\Explorer\" -Filter "thumbcache_*.db" | Remove-Item -Force
            Remove-ItemProperty -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" -Name "Logo" -ErrorAction SilentlyContinue
            Start-Process explorer
            Write-Host "Uninstalling Windhawk completed." -ForegroundColor Green
        }
    #* AutoHotkey Keyboard Shortcuts
        "7" {
            Write-Host "Uninstalling Keyboard Shortcuts..." -ForegroundColor Yellow
            Stop-Process -Name WinMacKeyShortcuts -Force
            $tasks = Get-ScheduledTask -TaskPath "\WinMac\" | Where-Object { $_.TaskName -match 'Keyboard Shortcuts' }
            foreach ($task in $tasks) { Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false }
            Remove-Item "$winMacDirectory\WinMacKeyShortcuts.exe" -Force
            Write-Host "Uninstalling Keyboard Shortcuts completed." -ForegroundColor Green
        }
    #* Nexus Dock
        "8" {
            Write-Host "Uninstalling Nexus Dock..." -ForegroundColor Yellow
            # Uninstall-WinGetPackage -name Nexus | Out-Null
            Start-Process "${env:ProgramFiles(x86)}\Winstep\unins000.exe" -ArgumentList "/VERYSILENT /SP- /SUPPRESSMSGBOXES" -Wait
            Remove-Item -Path "$programsDir\Nexus.lnk" -Force
            Remove-Item -Path "C:\Users\Public\Documents\Winstep" -Recurse -Force
            Write-Host "Uninstalling Nexus Dock completed." -ForegroundColor Green
        }
    #* Hot Corners
        "9" {
            Write-Host "Uninstalling Hot Corners..." -ForegroundColor Yellow
            $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
            Stop-Process -n WinXCornersPlus -Force
            Stop-Process -n WinLaunch -Force
            Stop-Process -n ssn -Force
            Start-Process "${env:ProgramFiles(x86)}\Simnet\Simple Sticky Notes\unins000.exe" -ArgumentList "/VERYSILENT /SP- /SUPPRESSMSGBOXES" -WindowStyle Hidden -Wait
            Remove-ItemProperty -Path $regPath -Name "WinLaunch"
            Remove-ItemProperty -Path $regPath -Name "WinXCornersPlus"
            Remove-ItemProperty -Path $regPath -Name "Simple Sticky Notes"
            Remove-Item -Path "$env:LOCALAPPDATA\WinMac\hotcorners" -Recurse -Force
            Remove-Item -Path "$env:LOCALAPPDATA\WinLaunch" -Recurse -Force
            Remove-Item -Path "$env:LOCALAPPDATA\WinXCornersPlus" -Recurse -Force
            Remove-Item -Path "$env:APPDATA\WinLaunch" -Recurse -Force
            Remove-Item -Path "$env:APPDATA\Simnet" -Recurse -Force
            Remove-Item -Path "$programsDir\WinXCornersPlus.lnk" -Recurse -Force
            Remove-Item -Path "$programsDir\Simple Sticky Notes.lnk" -Recurse -Force
            Write-Host "Uninstalling Hot Corners completed." -ForegroundColor Green
        }
    #* MacType
        "10" {
            if (!($sysType -like "*ARM*")) {
                Write-Host "Uninstalling MacType..." -ForegroundColor Yellow
                Stop-Process -Name MacTray -Force
                Start-Process "$env:PROGRAMFILES\MacType\unins000.exe" -ArgumentList "/VERYSILENT /SP- /NORESTART /SUPPRESSMSGBOXES" -Wait
                Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name FontSmoothing -Value "2"
                Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name FontSmoothingType -Type DWord -Value 2
                RUNDLL32.EXE user32.dll,UpdatePerUserSystemParameters ,1 ,True
                Stop-Process -Name Explorer -Force
                $tasks = Get-ScheduledTask -TaskPath "\WinMac\" | Where-Object { $_.TaskName -match 'MacType' }
                foreach ($task in $tasks) { Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false }
                Write-Host "Uninstalling MacType completed." -ForegroundColor Green
            }
        }
    #* Other
        "11" {
            Write-Host "Uninstalling Other Settings..." -ForegroundColor Yellow
            $regPath = "HKCU:\SOFTWARE\WinMac"
            $exRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
        #? Restore default Windows theme
            if ($windowsTheme -eq "Dark") { 
                Start-Process "C:\Windows\Resources\Themes\Dark.theme"
            } else { 
                Start-Process "C:\Windows\Resources\Themes\Aero.theme"
            }
            Start-Sleep -Seconds 3
            $stopTime = (Get-Date).AddSeconds(5)
            while ((Get-Date) -lt $stopTime) {
                $systemSettings = Get-Process SystemSettings -ErrorAction SilentlyContinue
                if ($systemSettings) {
                    Stop-Process -InputObject $systemSettings -Force
                    break
                }
                Start-Sleep -Milliseconds 100
            }
            Get-Process SystemSettings -ErrorAction SilentlyContinue | Stop-Process -Force
        #? Unpin User folder, Programs and Recycle Bin from Quick Access
            Set-ItemProperty -Path $regPath -Name "QuickAccess" -Value 0
            Set-ItemProperty -Path $exRegPath\HideDesktopIcons\NewStartPanel -Name "{645FF040-5081-101B-9F08-00AA002F954E}" -Value 0
            $homeDir = "C:\Users\$env:USERNAME"
            $homeIniFilePath = "$($homeDir)\desktop.ini"
            Remove-Item -Path $homeIniFilePath -Force | Out-Null
            $programsIniFilePath = "$($programsDir)\desktop.ini"
            Remove-Item -Path $programsIniFilePath -Force  | Out-Null
            Get-ChildItem -Path "C:\Windows\Cursors" -Directory | Where-Object { $_.Name -eq "windows-modern-v2" } | Remove-Item -Recurse -Force
            reg import ..\config\cursors\Remove_Modern_Cursors_Scheme.reg > $null 2>&1
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
        #? Restoring file explorer and context menus settings
            Get-ChildItem ..\config\registry\add\* -e *theme* | ForEach-Object { reg import $_.FullName > $null 2>&1 }
            reg import '..\config\registry\remove\Remove_Theme_Mode_in_Context_Menu.reg' > $null 2>&1
            reg import '..\config\registry\remove\Remove_Hidden_items_from_context_menu.reg' > $null 2>&1
            reg import '..\config\registry\remove\Remove_Navigation_pane_from_context_menu.reg' > $null 2>&1
            Remove-Item -Path "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}" -Recurse | Out-Null
            Remove-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" | Out-Null
            Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings" -Recurse | Out-Null
            Remove-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarSmallIcons" | Out-Null
        #? Removal of Themes related resources
            Remove-Item -Path "$env:WINDIR\Web\Wallpaper\macOS" -Recurse -Force
            Remove-Item -Path "$env:WINDIR\Web\Wallpaper\Server" -Recurse -Force
            Remove-Item -Path "$env:WINDIR\Resources\Icons" -Recurse -Force
            Get-ChildItem "$env:WINDIR\Resources\Themes" -Filter "Rectified" | Remove-Item -Force -Recurse
            Get-ChildItem "$env:WINDIR\Resources\Themes" -Filter "*WinMac*" | Remove-Item -Force -Recurse
            Remove-Item -Path "$env:WINDIR\System32\duires.dll" -Force
            Remove-Item -Path "$env:WINDIR\System32\ImmersiveFontHandler.dll" -Force
            Remove-Item -Path "$env:WINDIR\System32\twinuifonts.dll" -Force
            Remove-Item -Path "$winMacDirectory\ThemeSwitcher.ps1"
        #? Remove Hide Desktop Icons
            Remove-Item -Path "$winMacDirectory\HideDesktopIcons.exe" -Force
            Remove-Item -Path "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Hide Desktop Icons.lnk" -Force
        #? Remove Window Switcher
            Stop-Process -Name window-switcher -Force
            $tasks = Get-ScheduledTask -TaskPath "\WinMac\" | Where-Object { $_.TaskName -match 'Window Switcher' }
            foreach ($task in $tasks) { Unregister-ScheduledTask -TaskName $task.TaskName -Confirm:$false }
            Remove-Item "$winMacDirectory\window-switcher*" -Force
            #? Remove Send To Programs (create shortcut)
            $sendToPath = Join-Path $env:APPDATA 'Microsoft\Windows\SendTo\Programs (create shortcut).lnk'
            Remove-Item -Path $sendToPath -Force
            Remove-Item -Path "$winMacDirectory\ProgramsShortcut.exe" -Force
        #? Restore Home settings page visibility
            Remove-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\Explorer" -Name SettingsPageVisibility -Force | Out-Null
            Write-Host "Uninstalling Other Settings completed." -ForegroundColor Green
        #? Rename Microsoft Edge shortcuts
            $edgePaths = @(
                "$env:LOCALAPPDATA\Microsoft\Windows\Start Menu\Programs",
                "C:\ProgramData\Microsoft\Windows\Start Menu\Programs"
            )
            foreach ($path in $edgePaths) {
                Get-ChildItem -Path $path -Filter "Edge.lnk" -ErrorAction SilentlyContinue | ForEach-Object {
                    Rename-Item -Path $_.FullName -NewName "Microsoft Edge.lnk" -Force -ErrorAction SilentlyContinue
                }
            }
        }
    }
}
if ((Get-ChildItem -Path "$env:LOCALAPPDATA\WinMac" -Recurse | Measure-Object).Count -eq 0) { 
    Remove-Item -Path "$env:LOCALAPPDATA\WinMac" -Force
    Remove-ItemProperty -Path "HKCU:\Environment" -Name "WINMAC" -Force -ErrorAction SilentlyContinue
    Remove-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment" -Name "WINMAC" -Force -ErrorAction SilentlyContinue
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
    if ($userPath -like "*$winMacDirectory*") {
        $userPath = $userPath -replace ";?$([regex]::Escape($winMacDirectory))", ""
        [System.Environment]::SetEnvironmentVariable("Path", $userPath, [System.EnvironmentVariableTarget]::User)
    }
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
    if ($machinePath -like "*$winMacDirectory*") {
        $machinePath = $machinePath -replace ";?$([regex]::Escape($winMacDirectory))", ""
        [System.Environment]::SetEnvironmentVariable("Path", $machinePath, [System.EnvironmentVariableTarget]::Machine)
    }
}
$tasksFolder = Get-ScheduledTask -TaskPath "\WinMac" -ErrorAction SilentlyContinue
if ($null -eq $tasksFolder) { Unregister-ScheduledTask -TaskPath "\WinMac" -Confirm:$false -ErrorAction SilentlyContinue }

Start-Sleep 2
Stop-Process -n explorer
Start-Sleep 3
if (-not (Get-Process -Name explorer)) { Start-Process explorer }
Write-Host "`n------------------------ WinMac Deployment completed ------------------------" -ForegroundColor Cyan
Write-Host @"

Enjoy and support by giving feedback and contributing to the project!

For more information please visit WinMac GitHub page: 
https://github.com/Asteski/WinMac

If you have any questions or suggestions, please contact me on GitHub.

"@ -ForegroundColor Cyan

Write-Host "-----------------------------------------------------------------------------"  -ForegroundColor Cyan
Start-Sleep 2
$restartConfirmation = Read-Host "`nRestart computer now? It's recommended to fully apply all the changes (Y/n)"
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