param (
    [switch]$noGUI,
    [switch]$debug
)
$version = "0.6.0"
$date = Get-Date -Format "yy-MM-ddTHHmmss"
$logFile = "WinMac_install_log_$date.txt"
$transcriptFile = "WinMac_install_transcript_$date.txt"
$errorActionPreference="SilentlyContinue"
$WarningPreference="SilentlyContinue"
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms
if (-not (Test-Path -Path "../temp")) {New-Item -ItemType Directory -Path "../temp" | Out-Null}
if (-not (Test-Path -Path "../logs")) {New-Item -ItemType Directory -Path "../logs" | Out-Null}
Start-Transcript -Path ../logs/$transcriptFile -Append | Out-Null
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
    $topTextBlock = "PowerShell Deployment Tool for Windows and macOS hybrid"
$bottomTextBlock = @"
PowerShell profile files will be removed and replaced with new ones.
Please make sure to backup your current profiles if needed.

The author of this script is not responsible for any damage caused by
running it. It is highly recommended to create a system restore point
before proceeding with the installation process to ensure you can
revert any changes if necessary.

For a guide on how to use the script, please refer to the Wiki page
on WinMac GitHub page:

https://github.com/Asteski/WinMac/wiki
"@
[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="WinMac Deployment" Height="700" Width="480" WindowStartupLocation="CenterScreen" Background="$backgroundColor" Icon="$iconFolderPath\gui.ico">
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
            <TextBlock FontSize="20" FontWeight="Bold" Text="WinMac" Foreground="{StaticResource ForegroundBrush}" HorizontalAlignment="Center" Margin="0,10,0,10"/>
            
            <!-- Static TextBlock below the title -->
            <TextBlock Text="$topTextBlock" Foreground="{StaticResource ForegroundBrush}" HorizontalAlignment="Center" Margin="0,5,0,10" TextWrapping="Wrap"/>
        </StackPanel>

        <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Auto">
            <StackPanel VerticalAlignment="Top">
                <!-- Installation Type -->
                <GroupBox Header="Select Installation Type" Margin="0,5,0,5" Padding="5,5,5,5" Foreground="{StaticResource ForegroundBrush}" Background="{StaticResource SecondaryBackgroundBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="{StaticResource BorderThickness}">
                    <Grid Margin="5">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*" />
                            <ColumnDefinition Width="*" />
                        </Grid.ColumnDefinitions>
                        <RadioButton x:Name="fullInstall" Content="Full Installation" IsChecked="True" Grid.Column="0" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <RadioButton x:Name="customInstall" Content="Custom Installation" Grid.Column="1" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
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
                        <CheckBox x:Name="chkOther" Content="Other" IsChecked="True" Grid.Row="4" Grid.Column="1" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
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

                    <!-- Additional Settings: Start Menu -->
                    <GroupBox Grid.Row="0" Grid.Column="0" Header="Start Menu Options" Margin="5" Padding="5,5,5,5" Foreground="{StaticResource ForegroundBrush}" Background="{StaticResource SecondaryBackgroundBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="{StaticResource BorderThickness}">
                        <StackPanel>
                            <RadioButton x:Name="startMenuWinMac" Content="WinMac Start Menu" IsChecked="True" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                            <RadioButton x:Name="startMenuClassic" Content="Classic Start Menu" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        </StackPanel>
                    </GroupBox>

                    <!-- Additional Settings: Prompt Style -->
                    <GroupBox Grid.Row="0" Grid.Column="1" Header="Prompt Style Options" Margin="5" Padding="5,5,5,5" Foreground="{StaticResource ForegroundBrush}" Background="{StaticResource SecondaryBackgroundBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="{StaticResource BorderThickness}">
                        <StackPanel>
                            <RadioButton x:Name="promptStyleWinMac" Content="WinMac Prompt" IsChecked="True" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                            <RadioButton x:Name="promptStylemacOS" Content="macOS Prompt" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        </StackPanel>
                    </GroupBox>

                    <!-- Additional Settings: Shell Corner Style -->
                    <GroupBox Grid.Row="1" Grid.Column="0" Header="Shell Corner Style" Margin="5" Padding="5,5,5,5" Foreground="{StaticResource ForegroundBrush}" Background="{StaticResource SecondaryBackgroundBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="{StaticResource BorderThickness}">
                        <StackPanel>
                            <RadioButton x:Name="shellCornerRounded" Content="Rounded" IsChecked="True" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                            <RadioButton x:Name="shellCornerSquared" Content="Squared" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        </StackPanel>
                    </GroupBox>

                    <!-- Additional Settings: Theme Style -->
                    <GroupBox Grid.Row="1" Grid.Column="1" Header="Theme Style" Margin="5" Padding="5,5,5,5" Foreground="{StaticResource ForegroundBrush}" Background="{StaticResource SecondaryBackgroundBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="{StaticResource BorderThickness}">
                        <StackPanel>
                            <RadioButton x:Name="themeLight" Content="Light" IsChecked="True" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                            <RadioButton x:Name="themeDark" Content="Dark" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        </StackPanel>
                    </GroupBox>

                    <!-- TextBlock below the last row of GroupBoxes -->
                    <TextBlock Grid.Row="2" Grid.ColumnSpan="2" Margin="5" Foreground="{StaticResource ForegroundBrush}" Text="$bottomTextBlock" TextWrapping="Wrap"/>
                </Grid>

            </StackPanel>
        </ScrollViewer>

        <!-- Buttons -->
        <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Center">
            <Button x:Name="btnInstall" Content="Install" Width="100" Height="30" Margin="10" Foreground="{StaticResource ForegroundBrush}" Background="{StaticResource AccentBrush}"/>
            <Button x:Name="btnCancel" Content="Cancel" Width="100" Height="30" Margin="10" Foreground="{StaticResource ForegroundBrush}" Background="{StaticResource SecondaryBackgroundBrush}"/>
        </StackPanel>
    </Grid>
</Window>
"@
    $reader = New-Object System.Xml.XmlNodeReader $xaml
    $window = [Windows.Markup.XamlReader]::Load($reader)
    $fullInstall = $window.FindName("fullInstall")
    $customInstall = $window.FindName("customInstall")
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
    $chkOther = $window.FindName("chkOther")
    $startMenu = $window.FindName("startMenuWinMac")
    $promptStyle = $window.FindName("promptStyleWinMac")
    $shellCorner = $window.FindName("shellCornerRounded")
    $theme = $window.FindName("themeLight")
    $btnInstall = $window.FindName("btnInstall")
    $btnCancel = $window.FindName("btnCancel")
    $fullInstall.Add_Checked({$componentSelection.IsEnabled = $false})
    $customInstall.Add_Checked({$componentSelection.IsEnabled = $true})
    $result = @{}
    $btnInstall.Add_Click({
        if ($fullInstall.IsChecked) { $selection = "1","2","3","4","5","6","7","8","9","10" } 
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
            if ($chkOther.IsChecked) { $selection += "10" }
        }
        $appList = @{"1"="PowerToys"; "2"="Everything"; "3"="Powershell Profile"; "4"="StartAllBack"; "5"="WinMac Menu"; "6"="TopNotify"; "7"="Stahky"; "8"="Keyboard Shortcuts"; "9"="Nexus Dock"; "10"="Other Settings"}
        $result["selectedApps"] = $selection.Split(',').TrimEnd(',')
        $selectedAppNames = @()
        foreach ($appNumber in $selection) {
            if ($appList.ContainsKey($appNumber)) {
                # $selectedAppNames += $appList[$appNumber] + "`n"
                $selectedAppNames += $appList[$appNumber]
            }
        }
        $result["menuSet"] = if ($startMenu.IsChecked) { "X" } else { "C" }
        $result["promptSetVar"] = if ($promptStyle.IsChecked) { "W"} else { "M" }
        $result["roundedOrSquared"] = if ($shellCorner.IsChecked) { "R" } else { "S" }
        $result["lightOrDark"] = if ($theme.IsChecked) { "L"; $result["stackTheme"] = 'light'; $result["orbTheme"] = 'black.svg' } else { "D"; $result["stackTheme"] = 'dark'; $result["orbTheme"] = 'white.svg' }
        $result = [System.Windows.MessageBox]::Show("Do you wish to continue installation?", "WinMac Deployment", [System.Windows.MessageBoxButton]::OKCancel, [System.Windows.MessageBoxImage]::Information) 
        if ($result -eq 'OK') {
            $window.Close()
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

This script is responsible for installing all or specific WinMac 
components.

PowerShell profile files will be removed and replaced with new ones.
Please make sure to backup your current profiles if needed.

The author of this script is not responsible for any damage caused by 
running it. It is highly recommended to create a system restore point 
before proceeding with the installation process to ensure you can 
revert any changes if necessary.

For guide on how to use the script, please refer to the Wiki page 
on WinMac GitHub page:

https://github.com/Asteski/WinMac/wiki

"@ -ForegroundColor Yellow
    if (-not $adminTest) {Write-Host "Script is not running in elevated session." -ForegroundColor Red} else {Write-Host "Script is running in elevated session." -ForegroundColor Green}
    Write-Host "`n-----------------------------------------------------------------------" -ForegroundColor Cyan
    # WinMac configuration
    Write-Host
    $fullOrCustom = Read-Host "Enter 'F' for full or 'C' for custom installation"
    if ($fullOrCustom -eq 'F' -or $fullOrCustom -eq 'f') {
        Write-Host "Choosing full installation." -ForegroundColor Green
        $selectedApps = "1","2","3","4","5","6","7","8","9","10"
    } 
    elseif ($fullOrCustom -eq 'C' -or $fullOrCustom -eq 'c') {
        Write-Host "Choosing custom installation." -ForegroundColor Green
        Start-Sleep 1
        $appList = @{"1"="PowerToys"; "2"="Everything"; "3"="Powershell Profile"; "4"="StartAllBack"; "5"="WinMac Menu"; "6"="TopNotify"; "7"="Stahky"; "8"="Keyboard Shortcuts"; "9"="Nexus Dock"; "10"="Other"}
Write-Host @"

`e[93m$("Please select options you want to install:")`e[0m

"@
Write-Host @"
1. PowerToys
2. Everything
3. Powershell Profile
4. StartAllBack
5. WinMac Menu
6. TopNotify
7. Stahky
8. Keyboard Shortcuts
9. Nexus Dock
10. Other Settings:
  • Black Cursor
  • Pin Home, Programs and Recycle Bin to Quick Access
  • Remove Shortcut Arrows
  • Remove Recycle Bin from Desktop
  • Add End Task to context menu
"@
    Write-Host
    do {
        $selection = Read-Host "Enter the numbers of options you want to install (separated by commas)"
        $selection = $selection.Trim()
        $selection = $selection -replace '\s*,\s*', ','
        $valid = $selection -match '^([1-9]|10)(,([1-9]|10))*$'
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
    Write-Host "`e[92m$("Selected options:")`e[0m $($selectedAppNames -join ', ')"
}
else
{
    Write-Host "Invalid input. Defaulting to full installation." -ForegroundColor Yellow
    $selectedApps = "1","2","3","4","5","6","7","8","9","10"
}

if ($selectedApps -like '*4*' -or $selectedApps -like '*5*') {
Write-Host @"

`e[93m$("You can choose between WinMac start menu or Classic start menu.")`e[0m

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

`e[93m$("You can choose between WinMac prompt or MacOS-like prompt.")`e[0m

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

if ($selectedApps -like '*4*' -or $selectedApps -like '*9*') {
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

if ($selectedApps -like '*4*' -or $selectedApps -like '*7*' -or $selectedApps -like '*9*') {
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
        $lightOrDark = "L"
    }
}

Start-Sleep 1
$installConfirmation = Read-Host "`nAre you sure you want to start the installation process (y/n)"

if ($installConfirmation -ne 'y') {
    Write-Host "Installation process aborted." -ForegroundColor Red
    Start-Sleep 2
    exit
}
}
if ($result){
    $selectedApps = $result["selectedApps"]
    $menuSet = $result["menuSet"]
    $promptSet = $result["promptSetVar"]
    $roundedOrSquared = $result["roundedOrSquared"]
    $lightOrDark = $result["lightOrDark"]
    $stackTheme = $result["stackTheme"]
    $orbTheme = $result["orbTheme"]
}
Write-Host "Starting installation process in..." -ForegroundColor Green
for ($a=3; $a -ge 0; $a--) {
    Write-Host -NoNewLine "`b$a" -ForegroundColor Green
    Start-Sleep 1
}
Write-Host "`n-----------------------------------------------------------------------`n" -ForegroundColor Cyan
# Nuget check
Write-Host "Checking for Package Provider (Nuget)" -ForegroundColor Yellow
$nugetProvider = Get-PackageProvider -Name NuGet
if ($null -eq $nugetProvider) {
    Write-Host "NuGet is not installed. Installing NuGet..." -ForegroundColor Yellow
    Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
    Write-Host "NuGet installation completed." -ForegroundColor Green
} else {
    Write-Host "NuGet is already installed." -ForegroundColor Green
}
# Winget check
Write-Host "Checking for Package Manager (Winget)" -ForegroundColor Yellow
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
    Write-Host "Winget is not installed. Installing Winget..." -ForegroundColor Yellow
    Install-Module -Name Microsoft.WinGet.Client -Force
    Write-Host "Winget installation completed." -ForegroundColor Green
} else {
    $wingetFind = Find-Module -Name Microsoft.WinGet.Client
    if ($wingetFind.Version -gt $wingetClientCheck.Version) {
        Write-Host "A newer version of Winget is available. Updating Winget..." -ForegroundColor Yellow
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
            Write-Host "Installing PowerToys..." -ForegroundColor Yellow
            winget configure ..\config\powertoys.dsc.yaml --accept-configuration-agreements | Out-Null
            Write-Host "PowerToys installation completed." -ForegroundColor Green
        }
    # Everything
        "2" {
            Write-Host "Installing Everything..." -ForegroundColor Yellow
            Invoke-Output {Install-WinGetPackage -Id "Voidtools.Everything"}
            $programsDir = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs"
            Invoke-Output { Move-Item -Path "C:\Users\Public\Desktop\Everything.lnk" -Destination $programsDir -Force  }
            Invoke-Output { Move-Item -Path "C:\Users\$env:USERNAME\Desktop\Everything.lnk" -Destination $programsDir -Force }
            Invoke-Output { Start-Process -FilePath Everything.exe -WorkingDirectory $env:PROGRAMFILES\Everything -WindowStyle Hidden }
            Write-Host "Everything installation completed." -ForegroundColor Green
        }
    # PowerShell Profile
        "3" {
            Write-Host "Configuring PowerShell Profile..." -ForegroundColor Yellow
            $profilePath = $PROFILE | Split-Path | Split-Path
            $profileFile = $PROFILE | Split-Path -Leaf
            if ($promptSet -eq 'W' -or $promptSet -eq 'w') { $prompt = Get-Content "..\config\terminal\winmac-prompt.ps1" -Raw }
            elseif ($promptSet -eq 'M' -or $promptSet -eq 'm') { $prompt = Get-Content "..\config\terminal\macos-prompt.ps1" -Raw }
            $functions = Get-Content "..\config\terminal\functions.ps1" -Raw
            Invoke-Output { 
                if (-not (Test-Path "$profilePath\PowerShell")) { New-Item -ItemType Directory -Path "$profilePath\PowerShell" } 
                else { Remove-Item -Path "$profilePath\PowerShell\$profileFile" -Force } 
                }
            Invoke-Output { 
                if (-not (Test-Path "$profilePath\WindowsPowerShell")) { New-Item -ItemType Directory -Path "$profilePath\WindowsPowerShell" } 
                else { Remove-Item -Path "$profilePath\WindowsPowerShell\$profileFile" -Force } 
                }
            Invoke-Output { 
                if (-not (Test-Path "$profilePath\PowerShell\$profileFile")) { New-Item -ItemType File -Path "$profilePath\PowerShell\$profileFile" } 
                }
            Invoke-Output { 
                if (-not (Test-Path "$profilePath\WindowsPowerShell\$profileFile")) { New-Item -ItemType File -Path "$profilePath\WindowsPowerShell\$profileFile" } 
                }
            $winget = @(
                "Vim.Vim",
                "gsass1.NTop"
                )
            foreach ($app in $winget) {Invoke-Output { Install-WinGetPackage -id $app -source winget }}
            $vimParentPath = Join-Path $env:PROGRAMFILES Vim
            $latestSubfolder = Get-ChildItem -Path $vimParentPath -Directory | Sort-Object -Property CreationTime -Descending | Select-Object -First 1
            $vimChildPath = $latestSubfolder.FullName
            Invoke-Output { [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$vimChildPath", [EnvironmentVariableTarget]::Machine) }
            Invoke-Output { Install-Module PSTree -Force }
            $programsDir = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs"
            Invoke-Output { Add-Content -Path "$profilePath\PowerShell\$profileFile" -Value $prompt }
            Invoke-Output { Add-Content -Path "$profilePath\PowerShell\$profileFile" -Value $functions }
            Invoke-Output { Add-Content -Path "$profilePath\WindowsPowerShell\$profileFile" -Value $functions }
            Invoke-Output { Move-Item -Path "C:\Users\Public\Desktop\gVim*" -Destination $programsDir -Force }
            Invoke-Output { Move-Item -Path "C:\Users\$env:USERNAME\Desktop\gVim*" -Destination $programsDir -Force }
            Invoke-Output { Move-Item -Path "C:\Users\$env:USERNAME\OneDrive\Desktop\gVim*" -Destination $programsDir -Force }
            Write-Host "PowerShell Profile configuration completed." -ForegroundColor Green
        }
    # StartAllBack
        "4" {
            Write-Host "Installing StartAllBack..." -ForegroundColor Yellow 
            Invoke-Output {Install-WinGetPackage -Id "StartIsBack.StartAllBack"}
            $exRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
            $sabOrbs = $env:localAPPDATA + "\StartAllBack\Orbs"
            $sabRegPath = "HKCU:\Software\StartIsBack"
            $taskbarOnTopPath = "$exRegPath\StuckRectsLegacy"
            $taskbarOnTopName = "Settings"
            $taskbarOnTopValue = @(0x30,0x00,0x00,0x00,0xfe,0xff,0xff,0xff,0x02,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x5a,0x00,0x00,0x00,0x32,0x00,0x00,0x00,0x26,0x07,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x07,0x00,0x00,0x38,0x04,0x00,0x00,0x78,0x00,0x00,0x00,0x01,0x00,0x00,0x00)
            Invoke-Output {New-Item -Path $taskbarOnTopPath -Force}
            Invoke-Output {New-ItemProperty -Path $taskbarOnTopPath -Name $taskbarOnTopName -Value $taskbarOnTopValue -PropertyType Binary}
            Invoke-Output {Copy-Item "..\config\taskbar\orbs\*" $sabOrbs -Force}
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
            Set-ItemProperty -Path $sabRegPath -Name "TaskbarGrouping" -Value 0
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
            Set-ItemProperty -Path "$exRegPath\Advanced" -Name "LaunchTO" -Value 1
            Set-ItemProperty -Path $exRegPath -Name "ShowFrequent" -Value 0
            Set-ItemProperty -Path $exRegPath -Name "ShowRecent" -Value 0
            Invoke-Output {Stop-Process -Name explorer -Force}
            Start-Sleep 2
            Write-Host "StartAllBack installation completed." -ForegroundColor Green
        }
    # WinMac Menu
        "5" {
            if ($adminTest) {
                if ($menuSet -eq 'X'-or $menuSet -eq 'x') {
                    Write-Host "Installing WinMac Menu..." -ForegroundColor Yellow
                    Invoke-Output {Install-WinGetPackage -id 'Microsoft.DotNet.DesktopRuntime.8'}
                    Invoke-WebRequest -Uri 'https://github.com/dongle-the-gadget/WinverUWP/releases/download/v2.1.0.0/2505FireCubeStudios.WinverUWP_2.1.4.0_neutral_._k45w5yt88e21j.AppxBundle' -OutFile '..\temp\2505FireCubeStudios.WinverUWP_2.1.4.0_neutral_._k45w5yt88e21j.AppxBundle'
                    Add-AppxPackage -Path '..\temp\2505FireCubeStudios.WinverUWP_2.1.4.0_neutral_._k45w5yt88e21j.AppxBundle'
                    Invoke-Output {New-Item -ItemType Directory -Path "$env:LOCALAPPDATA\WinMac\"}
                    $sysType = (Get-WmiObject -Class Win32_ComputerSystem).SystemType
                    $exeKeyPath = "$env:LOCALAPPDATA\WinMac\WindowsKey.exe"
                    $exeStartPath = "$env:LOCALAPPDATA\WinMac\StartButton.exe"
                    $folderName = "WinMac"
                    $taskService = New-Object -ComObject "Schedule.Service"
                    $taskService.Connect() 
                    $rootFolder = $taskService.GetFolder("\")
                    try { $existingFolder = $rootFolder.GetFolder($folderName) } catch { $existingFolder = $null }                
                    if ($null -eq $existingFolder) { Invoke-Output {$rootFolder.CreateFolder($folderName)} }
                    $taskFolder = "\" + $folderName
                    $principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
                    $trigger = New-ScheduledTaskTrigger -AtLogon
                    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -MultipleInstances IgnoreNew
                    $actionWinKey = New-ScheduledTaskAction -Execute 'WindowsKey.exe' -WorkingDirectory "$env:LOCALAPPDATA\WinMac\"
                    $actionStartButton = New-ScheduledTaskAction -Execute "StartButton.exe" -WorkingDirectory "$env:LOCALAPPDATA\WinMac\"
                    $processes = @("windowskey", "startbutton")
                    foreach ($process in $processes) {
                        $runningProcess = Get-Process -Name $process
                        if ($runningProcess) {Stop-Process -Name $process -Force}
                    }
                    if ($sysType -like "*ARM*") {Copy-Item -Path ..\bin\menu\arm64\* -Destination "$env:LOCALAPPDATA\WinMac\" -Recurse -Force }
                    else {Copy-Item -Path ..\bin\menu\x64\* -Destination "$env:LOCALAPPDATA\WinMac\" -Recurse -Force }
                    Copy-Item -Path ..\bin\menu\startbutton.exe -Destination "$env:LOCALAPPDATA\WinMac\" -Recurse -Force 
                    Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Windows" -Filter "WinX" -Recurse -Force | ForEach-Object { Remove-Item $_.FullName -Recurse -Force }
                    $parentDirectory = Split-Path -Path $PSScriptRoot -Parent
                    $winxFolderName = "config\winx\Group2"
                    $winxFolderPath = Join-Path -Path $parentDirectory -ChildPath $winxFolderName
                    $WinverUWP = (Get-AppxPackage -Name 2505FireCubeStudios.WinverUWP).InstallLocation
                    $shortcutPath = "$winxFolderPath\8 - System.lnk"
                    $newTargetPath = "$WinverUWP\WinverUWP.exe"
                    $WScriptShell = New-Object -ComObject WScript.Shell
                    $shortcut = $WScriptShell.CreateShortcut($shortcutPath)
                    $shortcut.TargetPath = $newTargetPath
                    $shortcut.Save()
                    Copy-Item -Path "..\config\winx\" -Destination "$env:LOCALAPPDATA\Microsoft\Windows\" -Recurse -Force 
                    Invoke-Output {Register-ScheduledTask -TaskName "StartButton" -Action $actionStartButton -Trigger $trigger -Principal $principal -Settings $settings -TaskPath $taskFolder}
                    Invoke-Output {Register-ScheduledTask -TaskName "WindowsKey" -Action $actionWinKey -Trigger $trigger -Principal $principal -Settings $settings -TaskPath $taskFolder}
                    Start-Process $exeKeyPath
                    Start-Process $exeStartPath
                    Write-Host "WinMac Menu installation completed." -ForegroundColor Green
                } else {
                    Write-Host "Skipping WinMac Menu installation." -ForegroundColor Magenta
                }
            } else {                
                Write-Host "WinMac Menu requires elevated session. Please run the script as an administrator. Skipping installation." -ForegroundColor Red
            }
        }
    # TopNotify
        "6" {
            Write-Host "Installing TopNotify..." -ForegroundColor Yellow
            Invoke-Output {Install-WinGetPackage -name TopNotify}
            $app = Get-AppxPackage *TopNotify*
            Start-Process -FilePath TopNotify.exe -WorkingDirectory $app.InstallLocation
            $pkgName = $app.PackageFamilyName
            $startupTask = ($app | Get-AppxPackageManifest).Package.Applications.Application.Extensions.Extension | Where-Object -Property Category -Eq -Value windows.startupTask
            $taskId = $startupTask.StartupTask.TaskId
            Start-Process Taskmgr -WindowStyle Hidden
            while (!(Get-ItemProperty -Path "HKCU:Software\Classes\Local Settings\Software\Microsoft\Windows\CurrentVersion\AppModel\SystemAppData\$pkgName\$taskId" -Name State )) {Start-Sleep -Seconds 1}
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
            $outputPath = "..\stahky_U64.zip"
            $exePath = "$env:LOCALAPPDATA\Stahky"
            Invoke-Output {New-Item -ItemType Directory -Path $exePath -Force}
            Invoke-Output {New-Item -ItemType Directory -Path $exePath\config -Force}
            Invoke-WebRequest -Uri $url -OutFile $outputPath
            if (Test-Path -Path "$exePath\stahky.exe") {
                Invoke-Output {Write-Output "Stahky already exists."}
            } else {
                Expand-Archive -Path $outputPath -DestinationPath $exePath
            }
            Copy-Item -Path ..\config\taskbar\stacks\* -Destination $exePath\config -Recurse -Force
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
                Write-Host "Installing Keyboard Shortcuts..." -ForegroundColor Yellow
                $fileName = 'keyshortcuts.exe'
                $fileDirectory = "$env:LOCALAPPDATA\WinMac"
                New-Item -ItemType Directory -Path "$env:LOCALAPPDATA\WinMac\" 
                if (Get-Process keyshortcuts) { Stop-Process -Name keyshortcuts }
                Copy-Item ..\bin\$fileName "$env:LOCALAPPDATA\WinMac\" 
                $folderName = "WinMac"
                $taskService = New-Object -ComObject "Schedule.Service"
                $taskService.Connect() 
                $rootFolder = $taskService.GetFolder("\")
                try { $existingFolder = $rootFolder.GetFolder($folderName) } catch { $existingFolder = $null }              
                if ($null -eq $existingFolder) { $rootFolder.CreateFolder($folderName) }
                $taskFolder = "\" + $folderName
                $trigger = New-ScheduledTaskTrigger -AtLogon
                $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -MultipleInstances IgnoreNew
                $taskName = ($fileName).replace('.exe','')
                $action = New-ScheduledTaskAction -Execute $fileName -WorkingDirectory $fileDirectory
                $principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
                Invoke-Output {Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -TaskPath $taskFolder -Settings $settings}
                Start-Process -FilePath "$env:LOCALAPPDATA\WinMac\keyshortcuts.exe" -WorkingDirectory $env:LOCALAPPDATA\WinMac
                Write-Host "Keyboard Shortcuts installation completed." -ForegroundColor Green
            } else {
                Write-Host "Keyboard Shortcuts requires elevated session. Please run the script as an administrator. Skipping installation." -ForegroundColor Red
            }
        }
    # Nexus Dock
        "9" {
            if ($adminTest) {
                Write-Host "Winstep Nexus requires non-elevated session. Please run the script in a default user session. Skipping installation." -ForegroundColor Red
            }
            else {
                Write-Host "Installing Nexus Dock..." -ForegroundColor Yellow
                $downloadUrl = "https://www.winstep.net/nexus.zip"
                $downloadPath = "..\temp\Nexus.zip"
                if (-not (Test-Path $downloadPath)) {
                    Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath
                }
                Expand-Archive -Path $downloadPath -DestinationPath ..\temp -Force
                if (Get-Process -n Nexus) { Stop-Process -n Nexus }
                Start-Process -FilePath "..\temp\NexusSetup.exe" -ArgumentList "/silent"
                Start-Sleep 10
                $process1 = Get-Process -Name "NexusSetup"
                while ($process1) {
                    Start-Sleep 5
                    $process1 = Get-Process -Name "NexusSetup"
                }
                Start-Sleep 10
                $process2 = Get-Process -Name "Nexus"
                if (!($process2)) {
                    Start-Sleep 5
                    $process2 = Get-Process -Name "Nexus"
                } else { Start-Sleep 10 }
                Get-Process -n Nexus | Stop-Process
                $winStep = 'C:\Users\Public\Documents\WinStep'
                Remove-Item -Path "$winStep\Themes\*" -Recurse -Force 
                Copy-Item -Path "..\config\dock\themes\*" -Destination "$winStep\Themes\" -Recurse -Force 
                Remove-Item -Path "$winStep\NeXus\Indicators\*" -Force -Recurse 
                Copy-Item -Path "..\config\dock\indicators\*" -Destination "$winStep\NeXus\Indicators\" -Recurse -Force 
                Invoke-Output {New-Item -ItemType Directory -Path "$winStep\Sounds" -Force}
                Copy-Item -Path "..\config\dock\sounds\*" -Destination "$winStep\Sounds\" -Recurse -Force
                Invoke-Output {New-Item -ItemType Directory -Path "$winStep\Icons" -Force}
                Copy-Item "..\config\dock\icons" "$winStep" -Recurse -Force 
                $regFile = "..\config\dock\winstep.reg"
                $downloadsPath = "$env:USERPROFILE\Downloads"
                if ($roundedOrSquared -eq "S" -or $roundedOrSquared -eq "s") {
                    $modifiedContent = Get-Content $regFile | ForEach-Object { $_ -replace "Rounded", "Squared" }
                    $modifiedFile = "..\temp\winstep.reg"
                    $modifiedContent | Out-File -FilePath $modifiedFile -Encoding UTF8 
                    $regFile = $modifiedFile
                    if ($lightOrDark -eq "D" -or $lightOrDark -eq "d") {
                        $modifiedContent = Get-Content $regFile | ForEach-Object { $_ -replace "Light", "Dark" }
                        $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace '"UIDarkMode"="3"', '"UIDarkMode"="1"' }
                        $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace "1644825", "15658734" }
                        $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace "16119283", "2563870" }
                        $modifiedFile = "..\temp\winstep.reg"
                        $modifiedContent | Out-File -FilePath $modifiedFile -Encoding UTF8 
                    }
                }
                elseif (($roundedOrSquared -ne "S" -or $roundedOrSquared -ne "s") -and ($lightOrDark -eq "D" -or $lightOrDark -eq "d")) {
                    $modifiedContent = Get-Content $regFile | ForEach-Object { $_ -replace "Light", "Dark" }
                    $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace '"UIDarkMode"="3"', '"UIDarkMode"="1"' }
                    $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace "1644825", "15658734" }
                    $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace "16119283", "2563870" }
                    $modifiedFile = "..\temp\winstep.reg"
                    $modifiedContent | Out-File -FilePath $modifiedFile -Encoding UTF8 
                    $regFile = $modifiedFile
                }
                reg import $regFile > $null 2>&1
                Remove-ItemProperty -Path "Registry::HKEY_CURRENT_USER\Software\WinSTEP2000\NeXuS\Docks" -Name "DockLabelColorHotTrack1" 
                Remove-ItemProperty -Path "Registry::HKEY_CURRENT_USER\Software\WinSTEP2000\NeXuS\Docks" -Name "1Type6" 
                Remove-ItemProperty -Path "Registry::HKEY_CURRENT_USER\Software\WinSTEP2000\NeXuS\Docks" -Name "1Type7" 
                Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "1Path6" -Value $downloadsPath
                Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "1Path7" -Value "$env:APPDATA\Microsoft\Windows\Recent\"
                Start-Process 'C:\Program Files (x86)\Winstep\Nexus.exe' 
                while (!(Get-Process "nexus")) { Start-Sleep 1 }
                $programsDir = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs"
                Move-Item -Path "C:\Users\$env:USERNAME\Desktop\Nexus.lnk" -Destination $programsDir -Force 
                Move-Item -Path "C:\Users\$env:USERNAME\OneDrive\Desktop\Nexus.lnk" -Destination $programsDir -Force 
                Write-Host "Nexus Dock installation completed." -ForegroundColor Green
            }
        }
    # Other
        "10" {
        ## Black Cursor
            Write-Host "Configuring Other Settings..." -ForegroundColor Yellow
            Write-Host "Black cursor..." -ForegroundColor Yellow
            $exRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
            $curSourceFolder = (Get-Item -Path "..\config\cursor").FullName
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
            Invoke-Output {$CursorRefresh::SystemParametersInfo(0x0057,0,$null,0)}
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
                Invoke-Output {New-Item -Path $homeIniFilePath -ItemType File -Force}
            }
            Add-Content $homeIniFilePath -Value $homeIni
            (Get-Item $homeIniFilePath -Force).Attributes = 'Hidden, System, Archive'
            (Get-Item $homeDir -Force).Attributes = 'ReadOnly, Directory'
            $homePin = new-object -com shell.application
            if (-not ($homePin.Namespace($homeDir).Self.Verbs() | Where-Object {$_.Name -eq "pintohome"})) {
                $homePin.Namespace($homeDir).Self.InvokeVerb("pintohome") 
            }
$programsIni = @"
[.ShellClassInfo]
IconResource=C:\WINDOWS\System32\imageres.dll,187
"@
            $programsDir = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs"
            $programsIniFilePath = "$($programsDir)\desktop.ini"
            if (Test-Path $programsIniFilePath)  {
                Remove-Item $programsIniFilePath -Force
                Invoke-Output {New-Item -Path $programsIniFilePath -ItemType File -Force}
            }
            Add-Content $programsIniFilePath -Value $programsIni
            (Get-Item $programsIniFilePath -Force).Attributes = 'Hidden, System, Archive'
            (Get-Item $programsDir -Force).Attributes = 'ReadOnly, Directory'
            $programsPin = new-object -com shell.application
            if (-not ($programsPin.Namespace($programsDir).Self.Verbs() | Where-Object {$_.Name -eq "pintohome"})) {
                $programsPin.Namespace($programsDir).Self.InvokeVerb("pintohome") 
            }
            $RBPath = 'HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\pintohome\command\'
            $name = "DelegateExecute"
            $value = "{b455f46e-e4af-4035-b0a4-cf18d2f6f28e}"
            Invoke-Output {New-Item -Path $RBPath -Force}
            Invoke-Output {New-ItemProperty -Path $RBPath -Name $name -Value $value -PropertyType String -Force}
            $oShell = New-Object -ComObject Shell.Application
            $recycleBin = $oShell.Namespace("shell:::{645FF040-5081-101B-9F08-00AA002F954E}")
            if (-not ($recycleBin.Self.Verbs() | Where-Object {$_.Name -eq "pintohome"})) {
                $recycleBin.Self.InvokeVerb("PinToHome") 
            }
            Remove-Item -Path "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}" -Recurse 
        ## Remove Shortcut Arrows
            Write-Host "Removing shortcut arrows..." -ForegroundColor Yellow
            Copy-Item -Path "..\config\blank.ico" -Destination "C:\Windows" -Force
            Invoke-Output {New-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" -Force}
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" -Name "29" -Value "C:\Windows\blank.ico" -Type String
        ## Misc
            Write-Host "Adding End Task to context menu..." -ForegroundColor Yellow
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" -Name "{470C0EBD-5D73-4d58-9CED-E91E22E23282}" -Value ""
            $taskbarDevSettings = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings"
            if (-not (Test-Path $taskbarDevSettings)) { Invoke-Output {New-Item -Path $taskbarDevSettings -Force} }
            Invoke-Output {New-ItemProperty -Path $taskbarDevSettings -Name "TaskbarEndTask" -Value 1 -PropertyType DWORD -Force}
            Stop-Process -n explorer
            Write-Host "Configuring Other Settings completed." -ForegroundColor Green
        }
    }
}
Remove-Item "..\temp\*" -Recurse -Force
Stop-Transcript | Out-Null
Write-Host "`n------------------------ WinMac Deployment completed ------------------------" -ForegroundColor Cyan
Write-Host @"

Enjoy and support by giving feedback and contributing to the project!

For more information please visit WinMac GitHub page: 
https://github.com/Asteski/WinMac

If you have any questions or suggestions, please contact me on GitHub.

"@ -ForegroundColor Cyan

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