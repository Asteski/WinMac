param (
    [switch]$noGUI
)
$version = "1.4.0"
$ErrorActionPreference = "SilentlyContinue"
$WarningPreference = "SilentlyContinue"
$ProgressPreference = "SilentlyContinue"
$programsDir = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
$winMacDirectory = "$env:LOCALAPPDATA\WinMac"
[System.Environment]::SetEnvironmentVariable("WINMAC", "$env:LOCALAPPDATA\WinMac", [System.EnvironmentVariableTarget]::User)
[System.Environment]::SetEnvironmentVariable("WINMAC", "$env:LOCALAPPDATA\WinMac", [System.EnvironmentVariableTarget]::Machine)
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework
$user = [Security.Principal.WindowsIdentity]::GetCurrent()
$adminTest = (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
$sysType = (Get-WmiObject -Class Win32_ComputerSystem).SystemType
$osVersion = (Get-WmiObject -Class Win32_OperatingSystem).Caption
$checkDir = Get-ChildItem '..'
if (-not (Test-Path -Path "../temp")) {New-Item -ItemType Directory -Path "../temp" | Out-Null }
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
    Write-Host "                 Welcome to WinMac Installation Wizard                 " -ForegroundColor Cyan
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
    $isCheckedLight = if ($windowsTheme -eq "Light") { "True" } else { "False" }
    $isCheckedDark = if ($windowsTheme -eq "Dark") { "True" } else { "False" }
    $parentDirectory = Split-Path -Path $PSScriptRoot -Parent
    $iconFolderName = "config"
    $iconFolderPath = Join-Path -Path $parentDirectory -ChildPath $iconFolderName
    $topTextBlock = "Windows and macOS Hybrid Installation Wizard"
    $bottomTextBlock1 = '↓ Important Notes ↓'
    $bottomTextBlock2 = 'PowerShell default profile will be removed and replaced with new one. Please make sure to backup your current profile if needed.'
    $bottomTextBlock3 = 'The author of this script is not responsible for any damage caused by running it. Highly recommend to create a system restore point before proceeding with the installation process to ensure you can revert any changes if necessary.'
    $bottomTextBlock4 = 'For guide on how to use the script, please refer to the Wiki page on WinMac GitHub page.'
[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="WinMac Deployment Wizard" 
    Height="622" Width="540" 
    WindowStartupLocation="CenterScreen" 
    Background="$backgroundColor" 
    Icon="$iconFolderPath\wizard.ico">
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

        <ScrollViewer Grid.Row="1" VerticalScrollBarVisibility="Disabled" PanningMode="VerticalOnly" CanContentScroll="True" Focusable="True">
            <StackPanel VerticalAlignment="Top">
                <!-- Main Grid for Components and Options -->
                <Grid>
                    <Grid.ColumnDefinitions>
                        <ColumnDefinition Width="160"/> <!-- Column for Installation Type and Components -->
                        <ColumnDefinition Width="*"/> <!-- Column for Options -->
                    </Grid.ColumnDefinitions>

                    <StackPanel Grid.Column="0">
                        <!-- Installation Type -->
                        <GroupBox Header="Installation Type" Margin="0,5,0,5" Padding="5,5,5,5" Foreground="{StaticResource ForegroundBrush}" Background="{StaticResource SecondaryBackgroundBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="{StaticResource BorderThickness}" Width="205">
                            <Grid Margin="5">
                                <Grid.ColumnDefinitions>
                                    <ColumnDefinition Width="*" />
                                    <ColumnDefinition Width="110" />
                                </Grid.ColumnDefinitions>
                                <RadioButton x:Name="fullInstall" Content="Full" IsChecked="True" Grid.Column="0" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                                <RadioButton x:Name="customInstall" Content="Custom" Grid.Column="1" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                            </Grid>
                        </GroupBox>

                        <!-- Component Selection -->
                        <GroupBox Header="Components" Margin="0,5,0,5" Padding="5,5,5,5" x:Name="componentSelection" IsEnabled="False" Foreground="{StaticResource ForegroundBrush}" Background="{StaticResource SecondaryBackgroundBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="{StaticResource BorderThickness}">
                            <StackPanel Margin="5">
                                <CheckBox x:Name="chkPowerToys" Content="PowerToys" IsChecked="True" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                                <CheckBox x:Name="chkEverything" Content="Everything" IsChecked="True" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                                <CheckBox x:Name="chkPowerShellProfile" Content="PowerShell Profile" IsChecked="True" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                                <CheckBox x:Name="chkStartAllBack" Content="StartAllBack" IsChecked="True" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                                <CheckBox x:Name="chkWinMacMenu" Content="WinMac Menu" IsChecked="True" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                                <CheckBox x:Name="chkWindhawk" Content="Windhawk" IsChecked="True" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                                <CheckBox x:Name="chkStahky" Content="Stahky" IsChecked="True" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                                <CheckBox x:Name="chkAutoHotKey" Content="Keyboard Shortcuts" IsChecked="True" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                                <CheckBox x:Name="chkNexusDock" Content="Nexus Dock" IsChecked="True" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                                <CheckBox x:Name="chkHotCorners" Content="Hot Corners" IsChecked="True" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                                <CheckBox x:Name="chkMacType" Content="MacType" IsChecked="True" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                                <CheckBox x:Name="chkOther" Content="Other" IsChecked="True" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                            </StackPanel>
                        </GroupBox>
                    </StackPanel>

                    <!-- Grid for Additional Settings Options -->
                    <Grid Grid.Column="1">
                        <Grid.RowDefinitions>
                            <RowDefinition Height="*" />
                            <RowDefinition Height="*" />
                            <RowDefinition Height="*" />
                        </Grid.RowDefinitions>
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*" />
                            <ColumnDefinition Width="*" />
                            <ColumnDefinition Width="*" />
                        </Grid.ColumnDefinitions>

                        <GroupBox Grid.Row="0" Grid.Column="0" Header="Explorer style" Margin="5" Padding="0,0,0,0" Foreground="{StaticResource ForegroundBrush}" Background="{StaticResource SecondaryBackgroundBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="{StaticResource BorderThickness}">
                            <StackPanel>
                                <RadioButton x:Name="explorerModern" Content="Modern" IsChecked="True" Margin="0,22,0,13" Foreground="{StaticResource ForegroundBrush}"/>
                                <RadioButton x:Name="explorerClassic" Content="Classic" Margin="0,0,0,13" Foreground="{StaticResource ForegroundBrush}"/>
                            </StackPanel>
                        </GroupBox>

                        <!-- Additional Settings: Prompt Style -->
                        <GroupBox Grid.Row="0" Grid.Column="1" Header="Prompt style" Margin="5" Padding="0,0,0,0" Foreground="{StaticResource ForegroundBrush}" Background="{StaticResource SecondaryBackgroundBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="{StaticResource BorderThickness}">
                            <StackPanel>
                                <RadioButton x:Name="promptStyleWinMac" Content="WinMac" IsChecked="True" Margin="0,22,0,13" Foreground="{StaticResource ForegroundBrush}"/>
                                <RadioButton x:Name="promptStylemacOS" Content="macOS" Margin="0,0,0,13" Foreground="{StaticResource ForegroundBrush}"/>
                            </StackPanel>
                        </GroupBox>
                        
                        <GroupBox Grid.Row="0" Grid.Column="2" Header="Start Menu style" Margin="5" Padding="0,0,0,0" Foreground="{StaticResource ForegroundBrush}" Background="{StaticResource SecondaryBackgroundBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="{StaticResource BorderThickness}">
                            <StackPanel>
                                <RadioButton x:Name="startMenuWinMac" Content="WinMac" IsChecked="True" Margin="0,22,0,13" Foreground="{StaticResource ForegroundBrush}"/>
                                <RadioButton x:Name="startMenuClassic" Content="Classic" Margin="0,0,0,13" Foreground="{StaticResource ForegroundBrush}"/>
                            </StackPanel>
                        </GroupBox>

                        <GroupBox Grid.Row="1" Grid.Column="0" Header="Shell corners" Margin="5" Padding="0,0,0,0" Foreground="{StaticResource ForegroundBrush}" Background="{StaticResource SecondaryBackgroundBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="{StaticResource BorderThickness}">
                            <StackPanel>
                                <RadioButton x:Name="shellCornerRounded" Content="Rounded" IsChecked="True" Margin="0,22,0,13" Foreground="{StaticResource ForegroundBrush}"/>
                                <RadioButton x:Name="shellCornerSquared" Content="Squared" Margin="0,0,0,13" Foreground="{StaticResource ForegroundBrush}"/>
                            </StackPanel>
                        </GroupBox>

                        <GroupBox Grid.Row="1" Grid.Column="1" Header="Theme style" Margin="5" Padding="0,0,0,0" Foreground="{StaticResource ForegroundBrush}" Background="{StaticResource SecondaryBackgroundBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="{StaticResource BorderThickness}">
                            <StackPanel>
                                <RadioButton x:Name="themeLight" Content="Light" IsChecked="$isCheckedLight" Margin="0,22,0,13" Foreground="{StaticResource ForegroundBrush}"/>
                                <RadioButton x:Name="themeDark" Content="Dark" IsChecked="$isCheckedDark" Margin="0,0,0,13" Foreground="{StaticResource ForegroundBrush}"/>
                            </StackPanel>
                        </GroupBox>

                        <GroupBox Grid.Row="1" Grid.Column="2" Header="Folder color" Margin="5" Padding="0,0,0,0" Foreground="{StaticResource ForegroundBrush}" Background="{StaticResource SecondaryBackgroundBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="{StaticResource BorderThickness}">
                            <StackPanel>
                                <RadioButton x:Name="folderColorBlue" Content="Blue" IsChecked="True" Margin="0,22,0,13" Foreground="{StaticResource ForegroundBrush}"/>
                                <RadioButton x:Name="folderColorYellow" Content="Yellow" Margin="0,0,0,13" Foreground="{StaticResource ForegroundBrush}"/>
                            </StackPanel>
                        </GroupBox>

                        <GroupBox Grid.Row="2" Grid.Column="0" Header="Dock style" Margin="5" Padding="0,0,0,0" Foreground="{StaticResource ForegroundBrush}" Background="{StaticResource SecondaryBackgroundBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="{StaticResource BorderThickness}">
                            <StackPanel>
                                <RadioButton x:Name="dockStyleDefault" Content="Default" IsChecked="True" Margin="0,22,0,13" Foreground="{StaticResource ForegroundBrush}"/>
                                <RadioButton x:Name="dockStyleDynamic" Content="Dynamic" Margin="0,0,0,13" Foreground="{StaticResource ForegroundBrush}"/>
                            </StackPanel>
                        </GroupBox>

                        <GroupBox Grid.Row="2" Grid.Column="1" Header="Git profile" Margin="5" Padding="0,0,0,0" Foreground="{StaticResource ForegroundBrush}" Background="{StaticResource SecondaryBackgroundBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="{StaticResource BorderThickness}">
                            <StackPanel>
                                <RadioButton x:Name="chkGitProfile" Content="Enabled" IsChecked="True" Margin="0,22,0,13" Foreground="{StaticResource ForegroundBrush}"/> 
                                <RadioButton x:Name="chkGitProfileDisabled" Content="Disabled" Margin="0,0,0,13" Foreground="{StaticResource ForegroundBrush}"/>
                            </StackPanel>
                        </GroupBox>
                    </Grid>
                </Grid>
                <!-- TextBlock below the last row of GroupBoxes -->
                <TextBlock FontSize="14" FontWeight="Bold" Foreground="{StaticResource ForegroundBrush}" HorizontalAlignment="Center" Margin="10" Text="$bottomTextBlock1" TextWrapping="Wrap"/>
                <TextBlock Margin="10" Foreground="{StaticResource ForegroundBrush}" Text="$bottomTextBlock2" TextWrapping="Wrap"/>
                <TextBlock Margin="10" Foreground="{StaticResource ForegroundBrush}" Text="$bottomTextBlock3" TextWrapping="Wrap"/>
                <TextBlock Margin="10" Foreground="{StaticResource ForegroundBrush}" Text="$bottomTextBlock4" TextWrapping="Wrap"/>
            </StackPanel>
        </ScrollViewer>

        <!-- Buttons -->
        <StackPanel Grid.Row="2" Orientation="Horizontal" HorizontalAlignment="Right">
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
    $chkPowerShellProfile = $window.FindName("chkPowerShellProfile")
    $chkStartAllBack = $window.FindName("chkStartAllBack")
    $chkWinMacMenu = $window.FindName("chkWinMacMenu")
    $chkWindhawk = $window.FindName("chkWindhawk")
    $chkStahky = $window.FindName("chkStahky")
    $chkAutoHotKey = $window.FindName("chkAutoHotKey")
    $chkNexusDock = $window.FindName("chkNexusDock")
    $chkGitProfile = $window.FindName("chkGitProfile")
    $chkHotCorners = $window.FindName("chkHotCorners")
    $chkMacType = $window.FindName("chkMacType")
    $chkOther = $window.FindName("chkOther")
    $startMenu = $window.FindName("startMenuWinMac")
    $promptStyle = $window.FindName("promptStyleWinMac")
    $shellCorner = $window.FindName("shellCornerRounded")
    $theme = $window.FindName("themeLight")
    $blueOrYellow = $window.FindName("folderColorYellow")
    $dockDynamic = $window.FindName("dockStyleDynamic")
    $exStyle = $window.FindName("explorerModern")
    $btnInstall = $window.FindName("btnInstall")
    $btnCancel = $window.FindName("btnCancel")
    $fullInstall.Add_Checked({$componentSelection.IsEnabled = $false})
    $customInstall.Add_Checked({$componentSelection.IsEnabled = $true})
    $result = @{}
    $btnInstall.Add_Click({
        if ($fullInstall.IsChecked) { $selection = "1","2","3","4","5","6","7","8","9","10","11","12"} 
        else {
            if ($chkPowerToys.IsChecked) { $selection += "1," }
            if ($chkEverything.IsChecked) { $selection += "2," }
            if ($chkPowerShellProfile.IsChecked) { $selection += "3," }
            if ($chkStartAllBack.IsChecked) { $selection += "4," }
            if ($chkWinMacMenu.IsChecked) { $selection += "5," }
            if ($chkWindhawk.IsChecked) { $selection += "6," }
            if ($chkStahky.IsChecked) { $selection += "7," }
            if ($chkAutoHotKey.IsChecked) { $selection += "8," }
            if ($chkNexusDock.IsChecked) { $selection += "9," }
            if ($chkHotCorners.IsChecked) { $selection += "10," }
            if ($chkMacType.IsChecked) { $selection += "11," }
            if ($chkOther.IsChecked) { $selection += "12" }
        }
        $appList = @{"1"="PowerToys"; "2"="Everything"; "3"="PowerShell Profile"; "4"="StartAllBack"; "5"="WinMac Menu"; "6"="Windhawk"; "7"="Stahky"; "8"="Keyboard Shortcuts"; "9"="Nexus Dock"; "10"="Hot Corners"; "11"="MacType"; "12"="Other"}
        $result["selectedApps"] = $selection.Split(',').TrimEnd(',')
        $selectedAppNames = @()
        foreach ($appNumber in $selection) {
            if ($appList.ContainsKey($appNumber)) {
                $selectedAppNames += $appList[$appNumber]
            }
        }
        $result["menuSet"] = if ($startMenu.IsChecked) { "X" } else { "C" }
        $result["promptSetVar"] = if ($promptStyle.IsChecked) { "W"} else { "M" }
        $result["roundedOrSquared"] = if ($shellCorner.IsChecked) { "R" } else { "S" }
        $result["lightOrDark"] = if ($theme.IsChecked) { "L"; $result["stackTheme"] = 'light'; $result["orbTheme"] = 'black' } else { "D"; $result["stackTheme"] = 'dark'; $result["orbTheme"] = 'white' }
        $result["blueOrYellow"] = if ($blueOrYellow.IsChecked) { "Y" } else { "B" }
        $result["dockDynamic"] = if ($dockDynamic.IsChecked) { "X" } else { "D" }
        $result["gitProfile"] = if ($chkGitProfile.IsChecked) { $true } else { $false }
        $result["exStyle"] = if ($exStyle.IsChecked) { "X" } else { "C" }
        $result = [System.Windows.MessageBox]::Show("Do you wish to continue installation?", "WinMac Deployment", [System.Windows.MessageBoxButton]::OKCancel, [System.Windows.MessageBoxImage]::Information) 
        if ($result -eq 'OK') {
            $isInstallCompleted = $true
            $window.Close()
        }
    })
    $window.Add_Closed({
        if (-not $isInstallCompleted) {
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

PowerShell profile files will be removed and replaced with new ones.
Please make sure to backup your current profile if needed.

For guide on how to use the script, please refer to the Wiki page 
on WinMac GitHub page: https://github.com/Asteski/WinMac/wiki

"@ -ForegroundColor Yellow
    Write-Host "-----------------------------------------------------------------------" -ForegroundColor Cyan
    Write-Host
    $fullOrCustom = Read-Host "Enter 'F' for full or 'C' for custom installation"
    if ($fullOrCustom -eq 'F' -or $fullOrCustom -eq 'f') {
        Write-Host "Choosing full installation." -ForegroundColor Green
        Start-Sleep 2
        $selectedApps = "1","2","3","4","5","6","7","8","9","10","11","12"
    } 
    elseif ($fullOrCustom -eq 'C' -or $fullOrCustom -eq 'c') {
        Write-Host "Choosing custom installation." -ForegroundColor Green
        Start-Sleep 2
        $appList = @{"1"="PowerToys"; "2"="Everything"; "3"="PowerShell Profile"; "4"="StartAllBack"; "5"="WinMac Menu"; "6"="Windhawk"; "7"="Stahky"; "8"="Keyboard Shortcuts"; "9"="Nexus Dock"; "10"="Hot Corners"; "11"="MacType"; "12"="Other"}
    Clear-Host
    Show-Header
Write-Host @"

`e[93m$("Please select options you want to install:")`e[0m

"@
Write-Host @"
1. PowerToys
2. Everything
3. PowerShell Profile
4. StartAllBack
5. WinMac Menu
6. Windhawk
7. Stahky
8. Keyboard Shortcuts
9. Nexus Dock
10. Hot Corners
11. MacType
12. Other Settings
"@
    Write-Host
    do {
        $selection = Read-Host "Enter the numbers of options you want to install (separated by commas)"
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
    Write-Host "`e[92m$("Selected options:")`e[0m $($selectedAppNames -join ', ')"
    Start-Sleep 2
}
else
{
    Write-Host "Invalid input. Defaulting to full installation." -ForegroundColor Yellow
    Start-Sleep 1
    $selectedApps = "1","2","3","4","5","6","7","8","9","10","11","12"
}

if ($selectedApps -like '*4*' -and $selectedApps -like '*5*') {
    Clear-Host
    Show-Header
Write-Host @"

`e[93m$("You can choose between WinMac start menu or Classic start menu.")`e[0m

WinMac start menu replaces default menu with WinMac Menu application.

Classic start menu replaces default menu with enhanced Windows 7 start menu.

"@

    $menuSet = Read-Host "Enter 'X' for WinMac start menu or 'C' for Classic start menu"
    if ($menuSet -eq 'x' -or $menuSet -eq 'X') {
        Write-Host "Using WinMac start menu." -ForegroundColor Green
        Start-Sleep 1
    }
    elseif ($menuSet -eq 'c' -or $menuSet -eq 'C')
    { 
        Write-Host "Using Classic start menu." -ForegroundColor Green
        Start-Sleep 1
    }
    else
    {
        Write-Host "Invalid input. Defaulting to WinMac start menu." -ForegroundColor Yellow
        Start-Sleep 1
        $menuSet = 'X'
    }
}
elseif ($selectedApps -like '*4*' -and $selectedApps -notlike '*5*'){
    $menuSet = 'C'
}
elseif ($selectedApps -notlike '*4*' -and $selectedApps -like '*5*'){
    $menuSet = 'X'
}

if ($selectedApps -like '*3*') {
    Clear-Host
    Show-Header
Write-Host @"

`e[93m$("You can choose between WinMac prompt or macOS-like prompt.")`e[0m

WinMac prompt: 
11:35:06 userName @ ~ > 

macOS prompt:
userName@computerName ~ % 

"@
    $promptSet = Read-Host "Enter 'W' for WinMac prompt or 'M' for macOS prompt"
    if ($promptSet -eq 'W' -or $promptSet -eq 'w') {
        Write-Host "Using WinMac prompt." -ForegroundColor Green
        Start-Sleep 1
        
    }
    elseif ($promptSet -eq 'M' -or $promptSet -eq 'm')
    { 
        Write-Host "Using macOS prompt." -ForegroundColor Green
        Start-Sleep 1
    }
    else
    {
        Write-Host "Invalid input. Defaulting to WinMac prompt." -ForegroundColor Yellow
        Start-Sleep 1
        $promptSet = 'W'
    }
    $gitProfile = Read-Host "`nInstall Git profile (Y/n)"
    if ($gitProfile -eq 'y' -or $gitProfile -eq 'Y') {
        Write-Host "Enabling Git profile." -ForegroundColor Green
        Start-Sleep 1
        $gitProfile = $true
    }
    elseif ($gitProfile -eq 'n' -or $gitProfile -eq 'N') {
        Write-Host "Disabling Git profile." -ForegroundColor Yellow
        Start-Sleep 1
        $gitProfile = $false
    }
    else {
        Write-Host "Invalid input. Defaulting to enable Git profile." -ForegroundColor Yellow
        Start-Sleep 1
        $gitProfile = $true
    }
}
if ($selectedApps -like '*4*' -or $selectedApps -like '*9*') {
    Clear-Host
    Show-Header
    $roundedOrSquared = Read-Host "`nEnter 'R' for rounded or 'S' for squared shell corners"
    if ($roundedOrSquared -eq 'R' -or $roundedOrSquared -eq 'r') {
        Write-Host "Using rounded corners." -ForegroundColor Green
        Start-Sleep 1
    }
    elseif ($roundedOrSquared -eq 'S' -or $roundedOrSquared -eq 's') {
        Write-Host "Using squared corners." -ForegroundColor Green
        Start-Sleep 1
    }
    else
    {
        Write-Host "Invalid input. Defaulting to rounded corners." -ForegroundColor Yellow
        Start-Sleep 1
        $roundedOrSquared = 'R'
    }
}
if ($selectedApps -like '*4*' -or $selectedApps -like '*7*' -or $selectedApps -like '*9*' -or $selectedApps -like '*12*') {
    if ($windowsTheme -eq "Dark") {
        $stackTheme = 'dark'
        $orbTheme = 'white'
        $lightOrDark = "D"
    } else {
        $stackTheme = 'light'
        $orbTheme = 'black'
        $lightOrDark = "L"
    }
}
if ($selectedApps -like '*4*') {
    Clear-Host
    Show-Header
    $exStyle = Read-Host "`nEnter 'X' for modern or 'C' for classic file explorer style"
    if ($exStyle -eq 'X' -or $exStyle -eq 'x') {
        Write-Host "Using modern File Explorer." -ForegroundColor Green
        Start-Sleep 1
        $exStyle = 'x'
    }
    elseif ($exStyle -eq 'C' -or $exStyle -eq 'c') {
        Write-Host "Using classic File Explorer." -ForegroundColor Green
        Start-Sleep 1
    }
    else
    {
        Write-Host "Invalid input. Using default File Explorer." -ForegroundColor Yellow
        Start-Sleep 1
        $exStyle = 'x'
    }
}
if ($selectedApps -like '*9*' -or $selectedApps -like '*6*'-or $selectedApps -like '1') {
    Clear-Host
    Show-Header
    $blueOrYellow = Read-Host "`nEnter 'B' for blue or 'Y' for yellow folders"
    if ($blueOrYellow -eq 'B' -or $blueOrYellow -eq 'b') {
        Write-Host "Using blue folders." -ForegroundColor Green
        Start-Sleep 1
        $blueOrYellow = 'B'
    }
    elseif ($blueOrYellow -eq 'Y' -or $blueOrYellow -eq 'y') {
        Write-Host "Using yellow folders." -ForegroundColor Green
        Start-Sleep 1
    }
    else
    {
        Write-Host "Invalid input. Defaulting to blue folders." -ForegroundColor Yellow
        Start-Sleep 1
        $blueOrYellow = 'B'
    }
}
if ($selectedApps -like '*9*') {
    Clear-Host
    Show-Header
    $dockDynamic = Read-Host "`nEnter 'D' for default or 'X' for dynamic dock"
    if ($dockDynamic -eq 'D' -or $dockDynamic -eq 'd') {
        Write-Host "Using default Dock." -ForegroundColor Green
        Start-Sleep 1
        $dockDynamic = 'D'
    }
    elseif ($dockDynamic -eq 'X' -or $dockDynamic -eq 'x') {
        Write-Host "Using dynamic Dock." -ForegroundColor Green
        Start-Sleep 1
    }
    else
    {
        Write-Host "Invalid input. Using default Dock." -ForegroundColor Yellow
        Start-Sleep 1
        $dockDynamic = 'D'
    }
}
    Clear-Host
    Show-Header
$installConfirmation = Read-Host "`nAre you sure you want to start the installation process (Y/n)"
if ($installConfirmation -ne 'y' -or $installConfirmation -ne 'Y') {
    Show-Header
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
    $dockDynamic = $result["dockDynamic"]
    $blueOrYellow = $result["blueOrYellow"]
    $exStyle = $result["exStyle"]
    $orbTheme = $result["orbTheme"]
    $gitProfile = $result["gitProfile"]
}
for ($a=3; $a -ge 0; $a--) {
    Write-Host "`rStarting installation process in $a" -NoNewLine -ForegroundColor Yellow
    Start-Sleep 1
}
    Clear-Host
    Show-Header
    Write-Host
#* Nuget check
Write-Host "Checking Package Provider (Nuget)" -ForegroundColor Yellow
$nugetProvider = Get-PackageProvider -Name NuGet
if ($null -eq $nugetProvider) {
    Write-Host "NuGet is not installed. Installing NuGet..." -ForegroundColor DarkYellow
    Install-PackageProvider -Name NuGet -Force -Scope CurrentUser
    Write-Host "NuGet installation completed." -ForegroundColor Green
} else {
    Write-Host "NuGet is already installed." -ForegroundColor DarkGreen
}
#* Winget check
Write-Host "Checking Package Manager (Winget)" -ForegroundColor Yellow
$wingetCliCheck = winget -v
if ($null -eq $wingetCliCheck) {
    Invoke-WebRequest -Uri 'https://aka.ms/getwinget' -OutFile '..\temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
    Invoke-WebRequest -Uri 'https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx' -OutFile '..\temp\Microsoft.VCLibs.x64.14.00.Desktop.appx'
    Invoke-WebRequest -Uri 'https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.8.6/Microsoft.UI.Xaml.2.8.x64.appx' -OutFile '..\temp\Microsoft.UI.Xaml.2.8.x64.appx'
    Add-AppxPackage '..\bin\appx\Microsoft.VCLibs.140.00.UWPDesktop_14.0.33728.0_x64__8wekyb3d8bbwe.appx'
    Add-AppxPackage '..\temp\Microsoft.VCLibs.x64.14.00.Desktop.appx'
    Add-AppxPackage '..\temp\Microsoft.UI.Xaml.2.8.x64.appx'
    Add-AppxPackage '..\temp\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle'
}
$wingetClientCheck = Get-InstalledModule -Name Microsoft.WinGet.Client
if ($null -eq $wingetClientCheck) {
    Write-Host "Winget PowerShell Module is not installed. Installing Microsoft.WinGet.Client..." -ForegroundColor DarkYellow
    Install-Module -Name Microsoft.WinGet.Client -Force
} else {
    $wingetFind = Find-Module -Name Microsoft.WinGet.Client
    if ($wingetFind.Version -gt $wingetClientCheck.Version) {
        Write-Host "A newer version of Winget PowerShell Module is available. Updating  Microsoft.WinGet.Client..." -ForegroundColor DarkYellow
        Update-Module -Name Microsoft.WinGet.Client -Force
    }
}
Import-Module -Name Microsoft.WinGet.Client -Force
$wingetClientCheck = Get-InstalledModule -Name Microsoft.WinGet.Client
if ($null -eq $wingetCliCheck) {
    Write-Host "Winget PowerShell Module installation failed. Aborting installation." -ForegroundColor Red
    exit 1
}
else {
    Write-Host "Winget PowerShell Module installation completed." -ForegroundColor Green
}

Write-Host "`n-----------------------------------------------------------------------`n" -ForegroundColor Cyan
#! WinMac deployment
foreach ($app in $selectedApps) {
    switch ($app.Trim()) {
    #* PowerToys
        "1" {
            Write-Host "Installing PowerToys..." -ForegroundColor Yellow
            winget configure --enable | Out-Null
            pwsh -NoProfile -Command "winget configure ..\config\powertoys\powertoys.dsc.yaml --accept-configuration-agreements" | Out-Null
            Copy-Item -Path "..\config\powertoys\ptr\ptr.exe" -Destination "$env:LOCALAPPDATA\PowerToys" -Recurse -Force
            Copy-Item -Path "..\config\powertoys\Assets\PowerLauncher" -Destination "$env:LOCALAPPDATA\PowerToys\Assets" -Recurse -Force
            Copy-Item -Path "..\config\powertoys\Plugins" -Destination "$env:LOCALAPPDATA\Microsoft\PowerToys\PowerToys Run" -Recurse -Force
            if ($blueOrYellow -eq 'B' -or $blueOrYellow -eq 'b') {
                Copy-Item -Path "..\config\powertoys\RunPlugins" -Destination "$env:LOCALAPPDATA\PowerToys" -Recurse -Force
                Copy-Item -Path "..\config\powertoys\Assets\Peek" -Destination "$env:LOCALAPPDATA\PowerToys\WinUI3Apps\Assets" -Recurse -Force
                Copy-Item -Path "..\config\powertoys\RunPlugins\Everything" "$env:LOCALAPPDATA\Microsoft\PowerToys\PowerToys Run\Plugins" -Recurse -Force
            } else {
                Get-ChildItem -Path "..\config\powertoys\RunPlugins" -Recurse | Where-Object { $_.Name -ne "folder.png" } | ForEach-Object {
                    $destinationPath = Join-Path -Path "$env:LOCALAPPDATA\PowerToys\RunPlugins" -ChildPath $_.FullName.Substring((Get-Item "..\config\powertoys\RunPlugins").FullName.Length + 1)
                    if ($_.PSIsContainer) {
                        New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
                    } else {
                        Copy-Item -Path $_.FullName -Destination $destinationPath -Force
                    }
                }
                Get-ChildItem -Path "..\config\powertoys\RunPlugins\Everything" -Recurse | Where-Object { $_.Name -ne "folder.png" } | ForEach-Object {
                    $destinationPath = Join-Path -Path "$env:LOCALAPPDATA\Microsoft\PowerToys\PowerToys Run\Plugins" -ChildPath $_.FullName.Substring((Get-Item "..\config\powertoys\RunPlugins").FullName.Length + 1)
                    if ($_.PSIsContainer) {
                        New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
                    } else {
                        Copy-Item -Path $_.FullName -Destination $destinationPath -Force
                    }
                }
            }
            $envPath = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::User)
            if (-not ($envPath -like "*$env:LOCALAPPDATA\PowerToys*")) {
                $envPath += ";$env:LOCALAPPDATA\PowerToys"
                [System.Environment]::SetEnvironmentVariable("Path", $envPath, [System.EnvironmentVariableTarget]::User)
            }
            Stop-Process -Name PowerToys*
            Stop-Process -Name PowerToys.LightSwitchService
            Stop-Process -Name Microsoft.CmdPal.UI
            Start-Sleep -Seconds 3
            Install-WingetPackage -id ThioJoe.SvgThumbnailExtension | Out-Null
            Install-WingetPackage -id 'QL-Win.QuickLook' | Out-Null
            Move-Item -Path "$Env:USERPROFILE\Desktop\QuickLook.lnk" -Destination "$Env:APPDATA\Microsoft\Windows\Start Menu\Programs\Start-up" -Force
            Start-Process -FilePath "QuickLook.exe" -ArgumentList "/silent" -WorkingDirectory "$Env:LOCALAPPDATA\Programs\QuickLook" -WindowStyle Hidden
            (Get-Content -Path "$env:LOCALAPPDATA\Microsoft\PowerToys\settings.json") -replace '"CmdPal":true', '"CmdPal":false' -replace '"show_tray_icon":true', '"show_tray_icon":false' -replace '"LightSwitch": true', '"LightSwitch": false' | Set-Content -Path "$env:LOCALAPPDATA\Microsoft\PowerToys\settings.json" -Force
            Start-Process "$env:LOCALAPPDATA\PowerToys\PowerToys.exe" -ArgumentList "--start-minimized" -WorkingDirectory "$env:LOCALAPPDATA\PowerToys" -WindowStyle Hidden
            Write-Host "PowerToys installation completed." -ForegroundColor Green
        }
    #* Everything
        "2" {
            Write-Host "Installing Everything..." -ForegroundColor Yellow
            Install-WinGetPackage -Id "voidtools.Everything" | Out-Null
            Move-Item -Path "C:\Users\Public\Desktop\Everything.lnk" -Destination $programsDir -Force
            Move-Item -Path "C:\Users\$env:USERNAME\Desktop\Everything.lnk" -Destination $programsDir -Force
            if (-not (Test-Path -Path "$env:APPDATA\Everything")) {
                New-Item -ItemType Directory -Path "$env:APPDATA\Everything" -Force | Out-Null
                Copy-Item -Path "..\config\everything\Everything.ini" -Destination "$env:APPDATA\Everything" -Force
            }
            else {
                (Get-Content -Path "$env:APPDATA\Everything\Everything.ini") -replace "index_folder_size=0", "index_folder_size=1" -replace 'show_tray_icon=1' , 'show_tray_icon=0' | Set-Content -Path "$env:APPDATA\Everything\Everything.ini"
            }
            Start-Process -FilePath Everything.exe -WorkingDirectory "$env:PROGRAMFILES\Everything" -WindowStyle Hidden
            Write-Host "Everything installation completed." -ForegroundColor Green
        }
    #* PowerShell Profile
        "3" {
            Write-Host "Configuring PowerShell Profile..." -ForegroundColor Yellow
            $profilePath = $PROFILE | Split-Path | Split-Path
            $profileFile = $PROFILE | Split-Path -Leaf
            if ($gitProfile -eq $true) { 
                $git = Get-Content "..\config\terminal\git-profile.ps1" -Raw
                if ($promptSet -eq 'W' -or $promptSet -eq 'w') { $prompt = Get-Content "..\config\terminal\winmac-prompt-git.ps1" -Raw }
                elseif ($promptSet -eq 'M' -or $promptSet -eq 'm') { $prompt = Get-Content "..\config\terminal\macOS-prompt-git.ps1" -Raw }
            }
            else {
                if ($promptSet -eq 'W' -or $promptSet -eq 'w') { $prompt = Get-Content "..\config\terminal\winmac-prompt.ps1" -Raw }
                elseif ($promptSet -eq 'M' -or $promptSet -eq 'm') { $prompt = Get-Content "..\config\terminal\macOS-prompt.ps1" -Raw }
            }
            $functions = Get-Content "..\config\terminal\functions.ps1" -Raw
            if (-not (Test-Path "$profilePath\PowerShell")) { New-Item -ItemType Directory -Path "$profilePath\PowerShell" | Out-Null }
            else { Remove-Item -Path "$profilePath\PowerShell\$profileFile" -Force } 
            if (-not (Test-Path "$profilePath\WindowsPowerShell")) { New-Item -ItemType Directory -Path "$profilePath\WindowsPowerShell" | Out-Null }
            else { Remove-Item -Path "$profilePath\WindowsPowerShell\$profileFile" -Force } 
            if (-not (Test-Path "$profilePath\PowerShell\$profileFile")) { New-Item -ItemType File -Path "$profilePath\PowerShell\$profileFile" | Out-Null }
            if (-not (Test-Path "$profilePath\WindowsPowerShell\$profileFile")) { New-Item -ItemType File -Path "$profilePath\WindowsPowerShell\$profileFile" | Out-Null }
            $vim = Get-WinGetPackage -Id Vim.Vim
            if ($null -eq $vim) {
                $vimVersion = (Find-WingetPackage Vim.Vim | Where-Object {$_.Id -notlike "*nightly*"}).Version
                $vimVersion = ($vimVersion -split '\.')[0..1] -join '.'
                $vimRegPath = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Vim $vimVersion"
                if (-not (Test-Path $vimRegPath)) {New-Item -Path $vimRegPath -Force  | Out-Null }
                Set-ItemProperty -Path $vimRegPath -Name "select_startmenu" -Value 0
                Set-ItemProperty -Path $vimRegPath -Name "select_editwith" -Value 0
                Install-WinGetPackage -Id "Vim.Vim" | Out-Null
            } else {
                Write-Host "Vim is already installed." -ForegroundColor DarkGreen
            }
            $winget = @(
                "gsass1.NTop"
                )
            if ($gitProfile -eq $true) { $winget += "Git.Git" }
            foreach ($app in $winget) {
                $package = Get-WinGetPackage -Id $app
                if ($null -eq $package) {
                    Install-WinGetPackage -id $app -source winget | Out-Null
                } else {
                    Write-Host "$($app.split(".")[1]) is already installed." -ForegroundColor DarkGreen
                }
            }
            $pstreeModule = Get-InstalledModule -Name PSTree
            if ($null -eq $pstreeModule) {
                Install-Module PSTree -Force | Out-Null
            } else {
                Write-Host "PSTree is already installed." -ForegroundColor DarkGreen
            }
            $zModule = Get-InstalledModule -Name z
            if ($null -eq $zModule) {
                Install-Module z -Force | Out-Null
            } else {
                Write-Host "z is already installed." -ForegroundColor DarkGreen
            }
            $vimParentPath = Join-Path $env:PROGRAMFILES Vim
            $latestSubfolder = Get-ChildItem -Path $vimParentPath -Directory | Sort-Object -Property CreationTime -Descending | Select-Object -First 1
            $vimChildPath = $latestSubfolder.FullName
            [Environment]::SetEnvironmentVariable("Path", $env:Path + ";$vimChildPath", [EnvironmentVariableTarget]::Machine)
            Add-Content -Path "$profilePath\PowerShell\$profileFile" -Value $prompt
            if ($gitProfile -eq $true) { Add-Content -Path "$profilePath\PowerShell\$profileFile" -Value $git }
            Add-Content -Path "$profilePath\PowerShell\$profileFile" -Value $functions
            Add-Content -Path "$profilePath\WindowsPowerShell\$profileFile" -Value $prompt
            if ($gitProfile -eq $true) { Add-Content -Path "$profilePath\WindowsPowerShell\$profileFile" -Value $git }
            Add-Content -Path "$profilePath\WindowsPowerShell\$profileFile" -Value $functions
            Remove-Item -Path "C:\Users\Public\Desktop\gVim*" -Force
            Remove-Item -Path "C:\Users\$env:USERNAME\Desktop\gVim*" -Force
            Remove-Item -Path "C:\Users\$env:USERNAME\OneDrive\Desktop\gVim*" -Force
            Write-Host "PowerShell Profile configuration completed." -ForegroundColor Green
        }
    #* StartAllBack
        "4" {
            if (!($osVersion -like '*Windows 11*')) {
                Write-Host "StartAllBack is supported only on Windows 11. Skipping installation." -ForegroundColor Red
            } else {
                Write-Host "Installing StartAllBack..." -ForegroundColor Yellow
                Install-WinGetPackage -Id "StartIsBack.StartAllBack" | Out-Null
                $exRegPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer"
                $sabOrbs = $env:LOCALAPPDATA + "\StartAllBack\Orbs"
                $sabRegPath = "HKCU:\Software\StartIsBack"
                $taskbarOnTopPath = "$exRegPath\StuckRectsLegacy"
                $taskbarOnTopName = "Settings"
                $taskbarOnTopValue = @(0x30,0x00,0x00,0x00,0xfe,0xff,0xff,0xff,0x02,0x00,0x00,0x00,0x01,0x00,0x00,0x00,0x5a,0x00,0x00,0x00,0x32,0x00,0x00,0x00,0x26,0x07,0x00,0x00,0x00,0x00,0x00,0x00,0x80,0x07,0x00,0x00,0x38,0x04,0x00,0x00,0x78,0x00,0x00,0x00,0x01,0x00,0x00,0x00)
                New-Item -Path $taskbarOnTopPath -Force | Out-Null
                New-ItemProperty -Path $taskbarOnTopPath -Name $taskbarOnTopName -Value $taskbarOnTopValue -PropertyType Binary | Out-Null
                Copy-Item "..\config\taskbar\orbs\*" $sabOrbs -Force
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
                Set-ItemProperty -Path $sabRegPath -Name "TaskbarTranslucentEffect" -Value 0
                Set-ItemProperty -Path $sabRegPath -Name "RestyleControls" -Value 1
                Set-ItemProperty -Path $sabRegPath -Name "RestyleIcons" -Value 1
                Set-ItemProperty -Path $sabRegPath -Name "WelcomeShown" -Value 3
                Set-ItemProperty -Path $sabRegPath -Name "SettingsVersion" -Value 5
                Set-ItemProperty -Path $sabRegPath -Name "ModernIconsColorized" -Value 0
                Set-ItemProperty -Path $sabRegPath -Name "TaskbarOneSegment" -Value 0
                Set-ItemProperty -Path $sabRegPath -Name "TaskbarGrouping" -Value 0
                Set-ItemProperty -Path $sabRegPath -Name "TaskbarCenterIcons" -Value 1
                Set-ItemProperty -Path $sabRegPath -Name "TaskbarLargerIcons" -Value 0
                Set-ItemProperty -Path $sabRegPath -Name "TaskbarSpacierIcons" -Value (-1)
                Set-ItemProperty -Path $sabRegPath -Name "TaskbarControlCenter" -Value 0
                Set-ItemProperty -Path $sabRegPath -Name "SysTrayStyle" -Value 0
                Set-ItemProperty -Path $sabRegPath -Name "SysTrayActionCenter" -Value 0
                Set-ItemProperty -Path $sabRegPath -Name "SysTraySpacierIcons" -Value 1
                Set-ItemProperty -Path $sabRegPath -Name "DriveGrouping" -Value 1
                Set-ItemProperty -Path $sabRegPath -Name "SysTrayClockFormat" -Value 3
                Set-ItemProperty -Path $sabRegPath -Name "SysTrayInputSwitch" -Value 0
                Set-ItemProperty -Path $sabRegPath -Name "NavBarGlass" -Value 1
                if ($exStyle -eq 'C' -or $exStyle -eq 'c') { Set-ItemProperty -Path $sabRegPath -Name "FrameStyle" -Value 2 } else { Set-ItemProperty -Path $sabRegPath -Name "FrameStyle" -Value 0 }
                if ($menuSet -eq 'X' -or $menuSet -eq 'x') {
                    Set-ItemProperty -Path $sabRegPath -Name "WinkeyFunction" -Value 1
                }
                else {
                    Set-ItemProperty -Path $sabRegPath -Name "WinkeyFunction" -Value 0
                    Uninstall-WinGetPackage -name "Winver UWP" | Out-Null
                    Get-ChildItem "$env:LOCALAPPDATA\Microsoft\Windows" -Filter "WinX" -Recurse -Force | ForEach-Object { Remove-Item $_.FullName -Recurse -Force }
                    Expand-Archive -Path "..\config\WinX-default.zip" -Destination "$env:LOCALAPPDATA\Microsoft\Windows\" -Force
                }
                Set-ItemProperty -Path $sabRegPath -Name "DarkMagic" -Value 1
                Set-ItemProperty -Path $sabRegPath\DarkMagic -Name "(default)" -Value 1
                Set-ItemProperty -Path $sabRegPath\DarkMagic -Name "DarkMode" -Value 1
                if ($roundedOrSquared -eq 'R' -or $roundedOrSquared -eq 'r') {
                    $orbBitmapValue = "$orbTheme-rounded.svg"
                    $unroundValue = 0
                }
                else { 
                    $orbBitmapValue = "$orbTheme-squared.svg"
                    $unroundValue = 1
                }
                Set-ItemProperty -Path $sabRegPath\DarkMagic -Name "Unround" -Value $unroundValue
                Set-ItemProperty -Path $sabRegPath -Name "OrbBitmap" -Value $orbBitmapValue
                Set-ItemProperty -Path $exRegPath\Advanced -Name "LaunchTO" -Value 1
                Set-ItemProperty -Path $exRegPath -Name "ShowFrequent" -Value 0
                Stop-Process -Name explorer -Force
                Start-Sleep 5
                if (-not (Get-Process -Name explorer)) { Start-Process explorer }
                Write-Host "StartAllBack installation completed." -ForegroundColor Green
            }
        }
    #* WinMac Menu
        "5" {
            if ($osVersion -like '*Windows 11*') {
                if ($menuSet -eq 'X'-or $menuSet -eq 'x') {
                    Write-Host "Installing WinMac Menu..." -ForegroundColor Yellow
                    $dotNetRuntime = Get-WinGetPackage -Id 'Microsoft.DotNet.DesktopRuntime.8'
                    if ($null -eq $dotNetRuntime) {
                        Write-Host "Installing .NET Desktop Runtime 8..." -ForegroundColor DarkYellow
                        Install-WinGetPackage -id 'Microsoft.DotNet.DesktopRuntime.8' | Out-Null
                    }
                    $uiXaml = Get-WinGetPackage -Id 'Microsoft.UI.Xaml.2.7'
                    if ($null -eq $uiXaml) {
                        Write-Host "Installing Microsoft.UI.Xaml 2.7..." -ForegroundColor DarkYellow
                        Install-WinGetPackage -id 'Microsoft.UI.Xaml.2.7' | Out-Null
                    }
                    $runtime = Get-AppxPackage -Name 'Microsoft.NET.Native.Runtime.2.2'
                    if ($null -eq $runtime) {
                        Write-Host "Installing Microsoft.NET.Native.Runtime.2.2..." -ForegroundColor DarkYellow
                        Add-AppxPackage -Path '..\bin\appx\Microsoft.NET.Native.Runtime.2.2_2.2.28604.0_x64__8wekyb3d8bbwe.appx' | Out-Null
                    }
                    $framework = Get-AppxPackage -Name 'Microsoft.NET.Native.Framework.2.2'
                    if ($null -eq $framework) {
                        Write-Host "Installing Microsoft.NET.Native.Framework.2.2..." -ForegroundColor DarkYellow
                        Add-AppxPackage -Path '..\bin\appx\Microsoft.NET.Native.Framework.2.2_2.2.29512.0_x64__8wekyb3d8bbwe.appx' | Out-Null
                    }
                    $winverUWP = Get-AppxPackage -Name 2505FireCubeStudios.WinverUWP
                    if ($null -eq $winverUWP) {
                        Write-Host "Installing WinverUWP 2.1.4..." -ForegroundColor DarkYellow
                        winget install 'FireCubeStudios.WinverUWP' --accept-source-agreements --accept-package-agreements --skip-dependencies | Out-Null
                    } else {
                        Write-Host "WinverUWP is already installed." -ForegroundColor DarkGreen
                    }
                    New-Item -ItemType Directory -Path "$winMacDirectory\" | Out-Null
                    Write-Host "Installing Open-Shell..." -ForegroundColor DarkYellow
                    $shellExePath = Join-Path $env:PROGRAMFILES "Open-Shell\StartMenu.exe"
                    Start-Process -FilePath "..\bin\osh\osh.exe" -ArgumentList "/QUIET", "ADDLOCAL=StartMenu" -Wait -NoNewWindow | Out-Null
                    Stop-Process -Name StartMenu -Force | Out-Null
                    New-Item -Path "Registry::HKEY_CURRENT_USER\Software\OpenShell" -Force | Out-Null
                    New-Item -Path "Registry::HKEY_CURRENT_USER\Software\OpenShell\OpenShell" -Force | Out-Null
                    New-Item -Path "Registry::HKEY_CURRENT_USER\Software\OpenShell\StartMenu" -Force | Out-Null
                    New-Item -Path "Registry::HKEY_CURRENT_USER\Software\OpenShell\OpenShell\Settings" -Force | Out-Null
                    New-Item -Path "Registry::HKEY_CURRENT_USER\Software\OpenShell\StartMenu\Settings" -Force | Out-Null
                    Set-ItemProperty -Path "HKCU:\Software\OpenShell\OpenShell\Settings" -Name "Nightly" -Value 0x00000001
                    Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "Version" -Value 0x040400bf
                    Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "DisablePinExt" -Value 1
                    Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "EnableContextMenu" -Value 0
                    Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "MouseClick" -Value "Command"
                    Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "ShiftClick" -Value "Command"
                    Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "MiddleClick" -Value "Command"
                    Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "WinKey" -Value "Command"
                    Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "MouseClickCommand" -Value "$winMacDirectory\WinMacMenu.exe"
                    Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "ShiftClickCommand" -Value "ModernShutDownWindows"
                    Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "WinKeyCommand" -Value "$winMacDirectory\WinMacMenu.exe"
                    Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "MiddleClickCommand" -Value "taskmgr.exe"
                    Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "ShiftWin" -Value "Nothing"
                    Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "ShiftRight" -Value 1
                    Set-ItemProperty -Path "HKCU:\Software\OpenShell\StartMenu\Settings" -Name "SearchBox" -Value "Hide"
                    if ($sysType -like "*ARM*") { 
                        $wmmExePath = "..\bin\menu\arm\WinMacMenu.exe"
                    } 
                    else {
                        $wmmExePath = "..\bin\menu\x64\WinMacMenu.exe"
                    }
                    Copy-Item -Path $wmmExePath -Destination $winMacDirectory -Force
                    Copy-Item -Path "..\config\menu\config.ini" -Destination $winMacDirectory -Force
                    Copy-Item -Path "..\bin\menu\WinMac_Menu_RMB_Trigger.exe" -Destination $winMacDirectory -Force
                    $folderName = "WinMac"
                    $taskFolder = "\" + $folderName
                    $description = "WinMac Menu right mouse button trigger. Currently used as a workaround for the WinMac Menu being able to be opened with the right mouse button using Open-Shell, as it doesn't currently support that."
                    $taskService = New-Object -ComObject "Schedule.Service"
                    $taskService.Connect()
                    $rootFolder = $taskService.GetFolder("\")
                    try { $existingFolder = $rootFolder.GetFolder($folderName) } catch { $existingFolder = $null }
                    if ($null -eq $existingFolder) { $rootFolder.CreateFolder($folderName) | Out-Null }
                    $trigger = New-ScheduledTaskTrigger -AtLogon
                    $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -MultipleInstances IgnoreNew
                    $action = New-ScheduledTaskAction -Execute WinMac_Menu_RMB_Trigger.exe -WorkingDirectory $winMacDirectory
                    $principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
                    Register-ScheduledTask -TaskName "WinMac Menu RMB Trigger" -Action $action -Trigger $trigger -Principal $principal -TaskPath $taskFolder -Settings $settings -Description $description | Out-Null
                    Start-Process -FilePath "$winMacDirectory\WinMac_Menu_RMB_Trigger.exe" -WorkingDirectory $winMacDirectory | Out-Null
                    $WinverUWP = ((Get-AppxPackage -Name 2505FireCubeStudios.WinverUWP).InstallLocation) + "\WinverUWP.exe"
                    New-Item -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\winver.exe" -Force | Out-Null
                    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\winver.exe" -Name "Debugger" -Value $WinverUWP -Type String
                    Stop-Process -Name Explorer
                    Start-Process $shellExePath
                    $scriptBlock1 = "Start-Process -FilePath $env:LOCALAPPDATA\WinMac\WinMacMenu.exe -WorkingDirectory $env:LOCALAPPDATA\WinMac"
                    $tempScript = Join-Path $env:TEMP "nonadmin_$([guid]::NewGuid().ToString()).ps1"
                    Set-Content -Path $tempScript -Value $scriptBlock1 -Encoding UTF8
$batchContent = @"
@echo off
pushd "$currentDir"
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "`"$tempScript`""
"@
            $tempBatch = Join-Path $env:TEMP "run_nonadmin_$([guid]::NewGuid().ToString()).cmd"
            Set-Content -Path $tempBatch -Value $batchContent -Encoding ASCII
            $tempVbs = Join-Path $env:TEMP "run_silent_$([guid]::NewGuid().ToString()).vbs"
$vbsContent = @"
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run chr(34) & "$tempBatch" & chr(34), 0
"@
                    Set-Content -Path $tempVbs -Value $vbsContent -Encoding ASCII
                    Start-Process -FilePath "explorer.exe" -ArgumentList "`"$tempVbs`""
                    Start-Sleep 5
                    if (-not (Get-Process -Name explorer)) { Start-Process explorer }
                    Write-Host "WinMac Menu installation completed." -ForegroundColor Green
                } else {
                    Write-Host "Skipping WinMac Menu installation." -ForegroundColor DarkYellow
                }
            } elseif ($osVersion -notlike '*Windows 11*') {
                Write-Host "WinMac Menu is supported only on Windows 11. Skipping installation." -ForegroundColor Red
            }
        }
    #* Windhawk
        "6" {
            Write-Host "Installing Windhawk..." -ForegroundColor Yellow
            $windhawkInstalled = Get-WinGetPackage -Id "RamenSoftware.Windhawk"
            if ($null -eq $windhawkInstalled) {
                winget install --id "RamenSoftware.Windhawk" --source winget --silent | Out-Null
            }
            $windhawkProcess = Get-Process -Name Windhawk
            if ($windhawkProcess) {
                Stop-Process -Name Windhawk -Force
                Start-Sleep 2
            }
            $windhawkRoot = "$Env:ProgramData\Windhawk"
            if ($sysType -like "*ARM*") {
                $windhawkBackup = 'windhawk-backup-arm.zip'
            } else {
                $windhawkBackup = 'windhawk-backup-x64.zip'
            }
            $backupFile = Get-ChildItem -Path (Join-Path $PWD '..\config') -Filter $windhawkBackup -Recurse | Select-Object -First 1
            $timeStamp = (Get-Date -Format 'yyyyMMddHHmmss')
            $extractFolder = Join-Path $env:TEMP ("WindhawkRestore_$timeStamp")
            Copy-Item -Path '..\bin\ModernShutDownWindows.exe' -Destination "$env:WINDIR\System32\" -Recurse -Force
            New-Item -ItemType Directory -Path $extractFolder -Force | Out-Null
            Expand-Archive -Path $backupFile.FullName -DestinationPath $extractFolder -Force
            $modsSourceBackup = Join-Path $extractFolder "ModsSource"
            $modsBackup = Join-Path $extractFolder "Engine\Mods"
            $regBackup = Join-Path $extractFolder "Windhawk.reg"
            New-Item -ItemType Directory -Path "$winMacDirectory\resource-redirect\" -Force | Out-Null
            Copy-Item -Path $modsSourceBackup -Destination $windhawkRoot -Recurse -Force
            Expand-Archive -Path '..\bin\windhawk-mods-windows.zip' -DestinationPath "$windhawkRoot\Mods" -Force
            if ($blueOrYellow -eq "Y" -or $blueOrYellow -eq "y") {
                Expand-Archive -Path '..\config\windhawk\resource-redirect\WinMac-yellow-folders.zip' -DestinationPath "..\temp" -Force
            } else {
                Expand-Archive -Path '..\config\windhawk\resource-redirect\WinMac-blue-folders.zip' -DestinationPath "..\temp" -Force
            }
            Copy-Item -Path '..\temp\resource-redirect\*' -Destination "$winMacDirectory\resource-redirect\" -Recurse -Force
            $engineFolder = Join-Path $windhawkRoot "Engine"
            New-Item -ItemType Directory -Path $engineFolder -Force | Out-Null
            Copy-Item -Path $modsBackup -Destination $engineFolder -Recurse -Force
            $regContent = Get-Content $regBackup
            $regContent = $regContent -replace "%LOCALAPPDATA%", $Env:LOCALAPPDATA.replace('\','\\')
            if ($blueOrYellow -eq "Y" -or $blueOrYellow -eq "y") {
                $regContent = $regContent -replace "WinMac-blue-folders", "WinMac-yellow-folders"
            }
            $regContent | Set-Content $regBackup
            reg import $regBackup > $null 2>&1
            Remove-Item "$env:LocalAppData\Microsoft\Windows\Explorer\thumbcache_*.db" -Force -Recurse
            Set-ItemProperty -Path "HKCU:\Software\Classes\Local Settings\Software\Microsoft\Windows\Shell\Bags\AllFolders\Shell" -Name Logo -Value "imageres.dll,-3" -Type String
            $secureUxThemeInstalled = Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -like "SecureUxTheme*" }
            if (-not $secureUxThemeInstalled) { 
                if ($sysType -like "*ARM*") { 
                    Start-Process -FilePath '..\bin\secureuxtheme\SecureUxTheme_ARM64.msi' -ArgumentList '/quiet /norestart' -Wait 
                }
                else {
                    Start-Process -FilePath '..\bin\secureuxtheme\SecureUxTheme_x64.msi' -ArgumentList '/quiet /norestart' -Wait
                }
            }
            Stop-Process -Name explorer -Force
            Move-Item -Path "C:\Users\Public\Desktop\Windhawk.lnk" -Destination $programsDir -Force
            Start-Process "$Env:ProgramFiles\Windhawk\Windhawk.exe"
            Write-Host "Windhawk installation completed." -ForegroundColor Green
            }
    #* WinMac Menu Bar
        "7" {
            Write-Host "Installing WinMac Menu Bar..." -ForegroundColor Yellow
            $folderPath = Join-Path $Env:USERPROFILE 'Favorites\Links'
            if (-not (Test-Path $folderPath)) {
                New-Item -ItemType Directory -Path $folderPath -Force | Out-Null
            }
            Copy-Item -Path "..\config\taskbar\menubar\*.lnk" -Destination "$Env:USERPROFILE\Favorites\Links" -Force
            Copy-Item -Path "..\config\taskbar\menubar\*.ini" -Destination $winMacDirectory -Force
            Copy-Item -Path "..\config\blank.ico" -Destination "C:\Windows" -Force
            $folder = Get-Item $folderPath
            if (($folder.Attributes -band [System.IO.FileAttributes]::Hidden) -eq 0) {
                $folder.Attributes = $folder.Attributes -bor [System.IO.FileAttributes]::Hidden
            }
            $toolbarsValue = [byte[]](0x0c,0x00,0x00,0x00,0x08,0x00,0x00,0x00,0x02,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x21,0xbf,0x5c,0x0e,0x5f,
                0xd1,0xd0,0x11,0x83,0x01,0x00,0xaa,0x00,0x5b,0x43,0x83,0x22,0x00,0x1c,0x00,0x08,0x10,0x00,0x00,0xff,0xff,0xff,0xff,0x01,0x00,
                0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x4c,0x00,0x00,0x00,0x01,0x14,0x02,0x00,0x00,0x00,0x00,
                0x00,0xc0,0x00,0x00,0x00,0x00,0x00,0x00,0x46,0x81,0x01,0x00,0x00,0x12,0x00,0x00,0x00,0x7f,0x15,0x40,0x63,0xcb,0x69,0xdc,0x01,
                0xd3,0x5c,0xed,0x7d,0xcb,0x69,0xdc,0x01,0xfe,0xfb,0xe4,0x7d,0xcb,0x69,0xdc,0x01,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,
                0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0xac,0x00,0x3a,0x00,0x1f,0x49,0x47,0x1a,0x03,0x59,
                0x72,0x3f,0xa7,0x44,0x89,0xc5,0x55,0x95,0xfe,0x6b,0x30,0xee,0x26,0x00,0x01,0x00,0x26,0x00,0xef,0xbe,0x31,0x00,0x00,0x00,0xea,
                0xec,0x14,0xd9,0xf2,0x5d,0xdc,0x01,0xa3,0xa4,0x2c,0xa1,0xbc,0x69,0xdc,0x01,0xa3,0xa4,0x2c,0xa1,0xbc,0x69,0xdc,0x01,0x14,0x00,
                0x20,0x00,0x00,0x00,0x1a,0x00,0xee,0xbb,0xfe,0x23,0x00,0x00,0x10,0x00,0x61,0xf7,0x77,0x17,0xad,0x68,0x8a,0x4d,0x87,0xbd,0x30,
                0xb7,0x59,0xfa,0x33,0xdd,0x00,0x00,0x50,0x00,0x31,0x00,0x00,0x00,0x00,0x00,0x8a,0x5b,0x96,0x5e,0x12,0x00,0x4c,0x69,0x6e,0x6b,
                0x73,0x00,0x3c,0x00,0x09,0x00,0x04,0x00,0xef,0xbe,0x8a,0x5b,0x7d,0x5e,0x8a,0x5b,0x96,0x5e,0x2e,0x00,0x00,0x00,0xb3,0x6b,0x06,
                0x00,0x00,0x00,0x44,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x02,0x12,0xda,0x00,0x4c,0x00,
                0x69,0x00,0x6e,0x00,0x6b,0x00,0x73,0x00,0x00,0x00,0x14,0x00,0x00,0x00,0x10,0x00,0x00,0x00,0x05,0x00,0x00,0xa0,0x06,0x00,0x00,
                0x00,0x5a,0x00,0x00,0x00,0x1c,0x00,0x00,0x00,0x0b,0x00,0x00,0xa0,0x61,0xf7,0x77,0x17,0xad,0x68,0x8a,0x4d,0x87,0xbd,0x30,0xb7,
                0x59,0xfa,0x33,0xdd,0x5a,0x00,0x00,0x00,0x60,0x00,0x00,0x00,0x03,0x00,0x00,0xa0,0x58,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x61,
                0x64,0x61,0x6d,0x73,0x2d,0x79,0x6f,0x67,0x61,0x00,0x00,0x00,0x00,0x00,0x00,0xd0,0x2c,0x5e,0x48,0x0c,0xc4,0x82,0x41,0xa5,0xde,
                0x51,0x25,0x8a,0x54,0x80,0x22,0x9e,0x95,0x6d,0x41,0x45,0xd5,0xf0,0x11,0x9e,0xa6,0x68,0xc6,0xac,0xb9,0xaf,0xb3,0xd0,0x2c,0x5e,
                0x48,0x0c,0xc4,0x82,0x41,0xa5,0xde,0x51,0x25,0x8a,0x54,0x80,0x22,0x9e,0x95,0x6d,0x41,0x45,0xd5,0xf0,0x11,0x9e,0xa6,0x68,0xc6,
                0xac,0xb9,0xaf,0xb3,0xce,0x00,0x00,0x00,0x09,0x00,0x00,0xa0,0x89,0x00,0x00,0x00,0x31,0x53,0x50,0x53,0xe2,0x8a,0x58,0x46,0xbc,
                0x4c,0x38,0x43,0xbb,0xfc,0x13,0x93,0x26,0x98,0x6d,0xce,0x6d,0x00,0x00,0x00,0x04,0x00,0x00,0x00,0x00,0x1f,0x00,0x00,0x00,0x2d,
                0x00,0x00,0x00,0x53,0x00,0x2d,0x00,0x31,0x00,0x2d,0x00,0x35,0x00,0x2d,0x00,0x32,0x00,0x31,0x00,0x2d,0x00,0x33,0x00,0x31,0x00,
                0x32,0x00,0x36,0x00,0x37,0x00,0x31,0x00,0x32,0x00,0x33,0x00,0x39,0x00,0x2d,0x00,0x33,0x00,0x32,0x00,0x33,0x00,0x39,0x00,0x39,
                0x00,0x36,0x00,0x38,0x00,0x39,0x00,0x31,0x00,0x36,0x00,0x2d,0x00,0x35,0x00,0x30,0x00,0x30,0x00,0x38,0x00,0x38,0x00,0x34,0x00,
                0x38,0x00,0x38,0x00,0x38,0x00,0x2d,0x00,0x31,0x00,0x30,0x00,0x30,0x00,0x31,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x39,
                0x00,0x00,0x00,0x31,0x53,0x50,0x53,0xb1,0x16,0x6d,0x44,0xad,0x8d,0x70,0x48,0xa7,0x48,0x40,0x2e,0xa4,0x3d,0x78,0x8c,0x1d,0x00,
                0x00,0x00,0x68,0x00,0x00,0x00,0x00,0x48,0x00,0x00,0x00,0x78,0xd2,0x33,0x3a,0xd6,0x42,0xac,0x41,0x99,0xb3,0x43,0xa7,0xd7,0x12,
                0x67,0x21,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x12,0x01,0x00,0x00,0x40,0x07,0x00,0x00,0x00,0x00,0x00,
                0x00,0x26,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x2d,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x01,0x00,0x00,0x00,
                0x01,0x00,0x00,0x00,0xaa,0x4f,0x28,0x68,0x48,0x6a,0xd0,0x11,0x8c,0x78,0x00,0xc0,0x4f,0xd9,0x18,0xb4,0xa6,0x07,0x00,0x00,0x40,
                0x0d,0x00,0x00,0x00,0x00,0x00,0x00,0x2d,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x2d,0x00,0x00,0x00,0x00,0x00,
                0x00,0x00,0x01,0x00,0x00,0x00)
            $taskbarLinksPath = "HKCU:\Software\StartIsBack\Taskbaz"
            if (-not (Test-Path $taskbarLinksPath)) {
                New-Item -Path $taskbarLinksPath -Force | Out-Null
            }
            Set-ItemProperty -Path $taskbarLinksPath -Name "Toolbars" -Value $toolbarsValue -Type Binary -Force
            Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "TaskbarSizeMove" -Value 0 -Type DWord -Force | Out-Null
            Stop-Process -Name explorer -Force
            Start-Sleep 2
            Write-Host "WinMac Menu Bar installation completed." -ForegroundColor Green
        }
    #* AutoHotkey Keyboard Shortcuts
        "8" {
            Write-Host "Installing Keyboard Shortcuts..." -ForegroundColor Yellow
            New-Item -ItemType Directory -Path "$winMacDirectory\" | Out-Null
            if (Get-Process keyshortcuts) { Stop-Process -Name keyshortcuts }
            Copy-Item '..\bin\ahk\WinMacKeyShortcuts.exe' "$winMacDirectory" 
            Copy-Item '..\bin\windowswitcher\window-switcher*' "$winMacDirectory"
            $folderName = "WinMac"
            $taskFolder = "\" + $folderName
            $description = "WinMac Keyboard Shortcuts - custom keyboard shortcut described in Commands cheat sheet wiki page."
            $taskService = New-Object -ComObject "Schedule.Service"
            $taskService.Connect()
            $rootFolder = $taskService.GetFolder("\") 
            try { $existingFolder = $rootFolder.GetFolder($folderName) } catch { $existingFolder = $null }
            if ($null -eq $existingFolder) { $rootFolder.CreateFolder($folderName) | Out-Null }
            $trigger = New-ScheduledTaskTrigger -AtLogon
            $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -MultipleInstances IgnoreNew
            $action = New-ScheduledTaskAction -Execute WinMacKeyShortcuts.exe -WorkingDirectory $winMacDirectory
            $principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
            Register-ScheduledTask -TaskName "Keyboard Shortcuts" -Action $action -Trigger $trigger -Principal $principal -TaskPath $taskFolder -Settings $settings -Description $description | Out-Null
            Start-Process -FilePath "$winMacDirectory\WinMacKeyShortcuts.exe" -WorkingDirectory $winMacDirectory
            if (Get-Process window-switcher) { Stop-Process -Name window-switcher }
            $description = "Window Switcher - Cycle between windows of the same app like in macOS - Alt+backtick."
            $taskService = New-Object -ComObject "Schedule.Service"
            $taskService.Connect()
            $rootFolder = $taskService.GetFolder("\") 
            try { $existingFolder = $rootFolder.GetFolder($folderName) } catch { $existingFolder = $null }
            if ($null -eq $existingFolder) { $rootFolder.CreateFolder($folderName) | Out-Null }
            $trigger = New-ScheduledTaskTrigger -AtLogon
            $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -MultipleInstances IgnoreNew
            $action = New-ScheduledTaskAction -Execute window-switcher.exe -WorkingDirectory $winMacDirectory
            $principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
            Register-ScheduledTask -TaskName "Window Switcher" -Action $action -Trigger $trigger -Principal $principal -TaskPath $taskFolder -Settings $settings -Description $description | Out-Null
            Start-Process -FilePath "$winMacDirectory\window-switcher.exe" -WorkingDirectory $winMacDirectory
            Write-Host "Keyboard Shortcuts installation completed." -ForegroundColor Green
        }
    #* Nexus Dock
        "9" {
            Write-Host "Installing Nexus Dock..." -ForegroundColor Yellow
            if (Get-Process -n Nexus) { Stop-Process -n Nexus }
            $currentDir = (Get-Location).Path
            $scriptBlock1 = "winget install WinStep.Nexus --silent"
            $tempScript = Join-Path $env:TEMP "nonadmin_$([guid]::NewGuid().ToString()).ps1"
            Set-Content -Path $tempScript -Value $scriptBlock1 -Encoding UTF8
$batchContent = @"
@echo off
pushd "$currentDir"
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "`"$tempScript`""
"@
            $tempBatch = Join-Path $env:TEMP "run_nonadmin_$([guid]::NewGuid().ToString()).cmd"
            Set-Content -Path $tempBatch -Value $batchContent -Encoding ASCII
            $tempVbs = Join-Path $env:TEMP "run_silent_$([guid]::NewGuid().ToString()).vbs"
$vbsContent = @"
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run chr(34) & "$tempBatch" & chr(34), 0
"@
            Set-Content -Path $tempVbs -Value $vbsContent -Encoding ASCII
            Start-Process -FilePath "explorer.exe" -ArgumentList "`"$tempVbs`""
            $sw = [Diagnostics.Stopwatch]::StartNew()
            while (-not (Get-Process -Name "Nexus" -ErrorAction SilentlyContinue)) {
                if ($sw.Elapsed.TotalSeconds -ge 60) {
                    break
                }
                Start-Sleep -Seconds 1
            }
            $sw.Stop()
            Stop-Process -Name "Nexus" -Force
            $wingetTerminalCheck = Get-WinGetPackage -Id "Microsoft.WindowsTerminal"
            if ($null -eq $wingetTerminalCheck) {
                winget install Microsoft.WindowsTerminal | Out-Null
            }
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
                    $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace "store_light", "store_dark" }
                    $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace "recycle_bin_empty_light", "recycle_bin_empty_dark" }
                    $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace "recycle_bin_full_light", "recycle_bin_full_dark" }
                    $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace '"Windows10Style"="False"', '"Windows10Style"="True"' }
                    $modifiedFile = "..\temp\winstep.reg"
                    $modifiedContent | Out-File -FilePath $modifiedFile -Encoding UTF8
                }
            }
            elseif (($roundedOrSquared -ne "S" -or $roundedOrSquared -ne "s") -and ($lightOrDark -eq "D" -or $lightOrDark -eq "d")) {
                $modifiedContent = Get-Content $regFile | ForEach-Object { $_ -replace "Light", "Dark" }
                $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace '"UIDarkMode"="3"', '"UIDarkMode"="1"' }
                $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace "1644825", "15658734" }
                $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace "16119283", "2563870" }
                $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace "store_light", "store_dark" }
                $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace "recycle_bin_empty_light", "recycle_bin_empty_dark" }
                $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace "recycle_bin_full_light", "recycle_bin_full_dark" }
                $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace '"Windows10Style"="False"', '"Windows10Style"="True"' }
                $modifiedFile = "..\temp\winstep.reg"
                $modifiedContent | Out-File -FilePath $modifiedFile -Encoding UTF8 
                $regFile = $modifiedFile
            }
            reg import $regFile > $null 2>&1
            if ($selectedApps -like '*10*' -or (Test-Path "$env:LOCALAPPDATA\WinLaunch")) {
                Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "1Label9" -Value "Launchpad"
                Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "1Path9" -Value "$env:LOCALAPPDATA\WinLaunch\WinLaunch.exe"
                Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "1IconPath9" -Value "C:\ProgramData\Winstep\Icons\launchpad.ico"
                Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "1Type9" -Value "1"
                Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "1Label10" -Value "Capture Desktop"
                Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "1Path10" -Value "*78"
                Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "1Type10" -Value "2"
                Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "1IconPath10" -Value "C:\ProgramData\Winstep\Icons\camera.ico"
                Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "DockNoItems1" -Value "10"
            } else {
                Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "1Label9" -Value "Capture Desktop"
                Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "1Path9" -Value "*78"
                Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "1Type9" -Value "2"
                Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "1IconPath9" -Value "C:\ProgramData\Winstep\Icons\camera.ico"
                Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "DockNoItems1" -Value "9"
            }
                Remove-ItemProperty -Path "Registry::HKEY_CURRENT_USER\Software\WinSTEP2000\NeXuS\Docks" -Name "DockLabelColorHotTrack1" 
                Remove-ItemProperty -Path "Registry::HKEY_CURRENT_USER\Software\WinSTEP2000\NeXuS\Docks" -Name "1Type6"
                Remove-ItemProperty -Path "Registry::HKEY_CURRENT_USER\Software\WinSTEP2000\NeXuS\Docks" -Name "1Type7"
                Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "1Path6" -Value $downloadsPath
                Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "1Path7" -Value "$env:APPDATA\Microsoft\Windows\Recent\"
            if ($dockDynamic -eq "X" -or $dockDynamic -eq "x") {
                Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "DockAutoHideMaximized1" -Value "True"
                Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "DockRespectReserved1" -Value "False"
                Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "DockReserveScreen1" -Value "False"
            }
            if ($blueOrYellow -eq "Y" -or $blueOrYellow -eq "y") {Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "1IconPath0" -Value "C:\ProgramData\Winstep\Icons\explorer_default.ico"}
            $winStep = 'C:\ProgramData\WinStep'
            Remove-Item -Path "$winStep\Themes\*" -Recurse -Force
            Copy-Item -Path "..\config\dock\themes\*" -Destination "$winStep\Themes\" -Recurse -Force
            Remove-Item -Path "$winStep\NeXus\Indicators\*" -Force -Recurse 
            Copy-Item -Path "..\config\dock\indicators\*" -Destination "$winStep\NeXus\Indicators\" -Recurse -Force
            New-Item -ItemType Directory -Path "$winStep\Sounds" -Force | Out-Null
            Copy-Item -Path "..\config\dock\sounds\*" -Destination "$winStep\Sounds\" -Recurse -Force
            New-Item -ItemType Directory -Path "$winStep\Icons" -Force | Out-Null
            Copy-Item "..\config\icons" "$winStep" -Recurse -Force
            $scriptBlock2 = "Start-Process 'C:\Program Files (x86)\Winstep\Nexus.exe'"
            $tempScript = Join-Path $env:TEMP "nonadmin_$([guid]::NewGuid().ToString()).ps1"
            Set-Content -Path $tempScript -Value $scriptBlock2 -Encoding UTF8
$batchContent = @"
@echo off
pushd "$currentDir"
pwsh.exe -NoProfile -ExecutionPolicy Bypass -File "`"$tempScript`""
"@
            $tempBatch = Join-Path $env:TEMP "run_nonadmin_$([guid]::NewGuid().ToString()).cmd"
            Set-Content -Path $tempBatch -Value $batchContent -Encoding ASCII
            $tempVbs = Join-Path $env:TEMP "run_silent_$([guid]::NewGuid().ToString()).vbs"
$vbsContent = @"
Set WshShell = CreateObject("WScript.Shell")
WshShell.Run chr(34) & "$tempBatch" & chr(34), 0
"@
            Set-Content -Path $tempVbs -Value $vbsContent -Encoding ASCII
            Start-Process -FilePath "explorer.exe" -ArgumentList "`"$tempVbs`""
            $sw = [Diagnostics.Stopwatch]::StartNew()
            while (-not (Get-Process -Name "Nexus" -ErrorAction SilentlyContinue)) {
                if ($sw.Elapsed.TotalSeconds -ge 60) { break }
                Start-Sleep -Seconds 1
            }
            $sw.Stop()
            Move-Item -Path "C:\Users\$env:USERNAME\Desktop\Nexus.lnk" -Destination $programsDir -Force 
            Move-Item -Path "C:\Users\$env:USERNAME\OneDrive\Desktop\Nexus.lnk" -Destination $programsDir -Force
            Write-Host "Nexus Dock installation completed." -ForegroundColor Green
            }
    #* Hot Corners
        "10"{
            Write-Host "Installing Hot Corners..." -ForegroundColor Yellow
            $outputPath = '..\temp\WinXCorners.zip'
            $winXCornersUrl = "https://github.com/vhanla/winxcorners/releases/download/1.4.0/WinXCorners1.4.0.zip"
            $winXCornersConfigPath = '..\config\hotcorners\settings.ini'
            $destinationPath = "$env:LOCALAPPDATA\WinXCorners"
            $winLaunchUrl = "https://github.com/jensroth-git/WinLaunch/releases/download/v.0.7.3.0/WinLaunch.0.7.3.0.zip"
            $winLaunchConfigPath = '..\config\hotcorners\Settings.xml'
            $winLaunchOutputPath = '..\temp\WinLaunch.zip'
            $winLaunchDestinationPath = "$env:LOCALAPPDATA\WinLaunch"
            $dotNetRuntime = Get-WinGetPackage -Id 'Microsoft.DotNet.DesktopRuntime.8'
            if ($null -eq $dotNetRuntime) {
                Install-WinGetPackage -id 'Microsoft.DotNet.DesktopRuntime.8' | Out-Null
            }
            $uiXaml = Get-WinGetPackage -Id 'Microsoft.UI.Xaml.2.7'
            if ($null -eq $uiXaml) {
                Install-WinGetPackage -id 'Microsoft.UI.Xaml.2.7' | Out-Null
            }
            Write-Host "Installing WinXCorners..." -ForegroundColor DarkYellow
            Invoke-WebRequest -Uri $winXCornersUrl -OutFile $outputPath
            if (-not (Test-Path -Path $destinationPath)) {
                New-Item -ItemType Directory -Path $destinationPath -Force | Out-Null
            }
            Expand-Archive -Path $outputPath -DestinationPath $destinationPath -Force
            Copy-Item -Path $winXCornersConfigPath -Destination $destinationPath -Force
            Write-Host "Installing Simple Sticky Notes..." -ForegroundColor DarkYellow
            Install-WinGetPackage -id 'SimnetLtd.SimpleStickyNotes' | Out-Null
            Write-Host "Installing WinLaunch..." -ForegroundColor DarkYellow
            Invoke-WebRequest -Uri $winLaunchUrl -OutFile $winLaunchOutputPath
            Expand-Archive -Path $winLaunchOutputPath -DestinationPath $winLaunchDestinationPath -Force
            Copy-Item -Path ..\config\HotCorners\winlaunch.ico -Destination $winLaunchDestinationPath -Force
            Remove-Item $winLaunchOutputPath -Force
            Start-Process "$winLaunchDestinationPath\WinLaunch.exe"
            Start-Process "C:\Program Files (x86)\Simnet\Simple Sticky Notes\ssn.exe"
            Move-Item -Path "$env:USERPROFILE\Desktop\Simple Sticky Notes.lnk" -Destination "$env:APPDATA\Microsoft\Windows\Start Menu\Programs" -Force
            $process = Get-Process -Name WinLaunch
            if ($process) { Stop-Process -Name WinLaunch -Force }
            New-Item -ItemType Directory -Path "$winLaunchDestinationPath\Data" -Force | Out-Null
            Copy-Item -Path $winLaunchConfigPath -Destination "$winLaunchDestinationPath\Data\Settings.xml" -Force
            $configFilePath = Join-Path -Path $destinationPath -ChildPath "settings.ini"
            (Get-Content -Path $configFilePath) -replace "WINLAUNCH", "$($env:LOCALAPPDATA)\WinLaunch\WinLaunch.exe" | Set-Content -Path $configFilePath
            (Get-Content -Path $configFilePath) -replace "MINIMIZEALL", "$($env:LOCALAPPDATA)\WinMac\hotcorners\MinimizeAllWindowsExceptFocused.exe" | Set-Content -Path $configFilePath
            Remove-Item $outputPath -Force
            Start-Process "$destinationPath\WinXCorners.exe"
            $shortcut1Path = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\WinXCorners.lnk"
            $target1Path = "$destinationPath\WinXCorners.exe"
            $shell = New-Object -ComObject WScript.Shell
            $shortcut = $shell.CreateShortcut($shortcut1Path)
            $shortcut.TargetPath = $target1Path
            $shortcut.Save()
            $shortcut2Path = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\WinLaunch.lnk"
            $target2Path = "$winLaunchDestinationPath\WinLaunch.exe"
            $icon2Path = "$winLaunchDestinationPath\winlaunch.ico"
            $shell = New-Object -ComObject WScript.Shell
            $shortcut = $shell.CreateShortcut($shortcut2Path)
            $shortcut.TargetPath = $target2Path
            $shortcut.IconLocation = $icon2Path
            $shortcut.Save()
            if (-not (Test-Path -Path "$winMacDirectory\hotcorners")) { New-Item -ItemType Directory -Path "$winMacDirectory\hotcorners" -Force | Out-Null }
            if ($sysType -like "*ARM*") {Copy-Item -Path ..\bin\hotcorners\arm64\* -Destination "$winMacDirectory\hotcorners\" -Recurse -Force}
            else {Copy-Item -Path ..\bin\hotcorners\x64\* -Destination "$winMacDirectory\hotcorners\" -Recurse -Force}
            New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "WinXCorners" -Value "$destinationPath\WinXCorners.exe" | Out-Null
            Write-Host "Hot Corners installation completed." -ForegroundColor Green
            }
    #* MacType
        "11" {
            if ($sysType -like "*ARM*") {
                Write-Host "MacType is not supported on ARM devices. Skipping installation." -ForegroundColor Red
            }
            else {
                Write-Host "Installing MacType..." -ForegroundColor Yellow
                $macTypeInstalled = Get-WinGetPackage -Id "MacType.MacType"
                if ($null -eq $macTypeInstalled) { winget install --id "MacType.MacType" --source winget --silent | Out-Null }
                Stop-Process -n mt64agnt, MacTray, MacType -Force
                New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run" -Name "MacType" -Value "$env:PROGRAMFILES\MacType\MacTray.exe" | Out-Null
                Copy-Item -Path "..\config\mactype\*" -Destination "$env:PROGRAMFILES\MacType" -Recurse -Force
                Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name FontSmoothing -Value "0"
                Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name FontSmoothingType -Type DWord -Value 0
                Start-Sleep -Seconds 2
                Stop-Process -n Explorer
                Start-Sleep -Seconds 4
                Start-Process -FilePath "$env:PROGRAMFILES\MacType\MacTray.exe"
                Write-Host "MacType installation completed." -ForegroundColor Green
            }
            }
    #* Other
        "12" {
            Write-Host "Configuring Other Settings..." -ForegroundColor Yellow
        #? Black Cursor
            $curSourceFolder = (Get-Item -Path "..\config\cursors").FullName
            $curDestFolder = "C:\Windows\Cursors"
            Copy-Item -Path "$curSourceFolder\windows-modern-v2" -Destination $curDestFolder -Recurse -Force
            reg import ..\config\cursors\Add_Modern_Cursors_Scheme.reg > $null 2>&1
            if ($lightOrDark -eq "L" -or $lightOrDark -eq "l") {
                $cursorName = 'Windows Modern v2 - Aero Black - (x1)'
                $cursorColor = 'black'
            } else {
                $cursorName = 'Windows Modern v2 - Aero White - (x1)'
                $cursorColor = 'white'
            }
            $RegConnect = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"CurrentUser","$env:COMPUTERNAME")
            $RegCursors = $RegConnect.OpenSubKey("Control Panel\Cursors",$true)
            $RegCursors.SetValue("",$cursorName)
            $RegCursors.SetValue("AppStarting","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\working-in-background_$cursorColor.ani")
            $RegCursors.SetValue("Arrow","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\normal-select_$cursorColor.cur")
            $RegCursors.SetValue("Crosshair","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\precision-select_default.cur")
            $RegCursors.SetValue("Hand","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\link-select_$cursorColor.cur")
            $RegCursors.SetValue("Help","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\help-select_$cursorColor.cur")
            $RegCursors.SetValue("IBeam","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\text-select_$cursorColor.cur")
            $RegCursors.SetValue("No","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\unavailable_$cursorColor.cur")
            $RegCursors.SetValue("NWPen","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\handwriting_$cursorColor.cur")
            $RegCursors.SetValue("SizeAll","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\move_$cursorColor.cur")
            $RegCursors.SetValue("SizeNESW","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\diagonal-resize-2_$cursorColor.cur")
            $RegCursors.SetValue("SizeNS","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\vertical-resize_$cursorColor.cur")
            $RegCursors.SetValue("SizeNWSE","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\diagonal-resize-1_$cursorColor.cur")
            $RegCursors.SetValue("SizeWE","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\horizontal-resize_$cursorColor.cur")
            $RegCursors.SetValue("UpArrow","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\alternate-select_$cursorColor.cur")
            $RegCursors.SetValue("Wait","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\busy.ani")
            $RegCursors.SetValue("Pin","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\link-select_$cursorColor.cur")
            $RegCursors.SetValue("Person","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\link-select_$cursorColor.cur")
            $RegCursors.Close()
            $RegConnect.Close()
            Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class User32 {
    [DllImport("user32.dll")]
    public static extern IntPtr SystemParametersInfo(int uAction, int uParam, IntPtr lpvParam, int fuWinIni);
}
"@
            [User32]::SystemParametersInfo(0x0057, 0, [IntPtr]::Zero, 0x0001) > $null 2>&1
        #? Pin User folder, Programs and Recycle Bin to Quick Access
            $registryPath3 = "HKCU:\SOFTWARE\WinMac"
            if (-not (Test-Path -Path $registryPath3)) {New-Item -Path $registryPath3 -Force | Out-Null }
            if ((Get-ItemProperty -Path $registryPath3 -Name "QuickAccess").QuickAccess -ne 1) {
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
                Add-Content $homeIniFilePath -Value $homeIni | Out-Null
                (Get-Item $homeIniFilePath -Force).Attributes = 'Hidden, System, Archive'
                (Get-Item $homeDir -Force).Attributes = 'ReadOnly, Directory'
                $homePin = new-object -com shell.application
                if (-not ($homePin.Namespace($homeDir).Self.Verbs() | Where-Object {$_.Name -eq "pintohome"})) {
                    $homePin.Namespace($homeDir).Self.InvokeVerb("pintohome")
                } 
$programsIni = @"
[.ShellClassInfo]
IconResource=C:\WINDOWS\System32\imageres.dll,-87
"@
                $programsIniFilePath = "$($programsDir)\desktop.ini"
                if (Test-Path $programsIniFilePath)  {
                    Remove-Item $programsIniFilePath -Force
                    New-Item -Path $programsIniFilePath -ItemType File -Force | Out-Null
                }
                Add-Content $programsIniFilePath -Value $programsIni  | Out-Null
                (Get-Item $programsIniFilePath -Force).Attributes = 'Hidden, System, Archive'
                (Get-Item $programsDir -Force).Attributes = 'ReadOnly, Directory'
                $programsPin = new-object -com shell.application
                if (-not ($programsPin.Namespace($programsDir).Self.Verbs() | Where-Object {$_.Name -eq "pintohome"})) {
                    $programsPin.Namespace($programsDir).Self.InvokeVerb("pintohome")
                }
                $RBPath = 'HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\pintohome\command\'
                $name = "DelegateExecute"
                $value = "{b455f46e-e4af-4035-b0a4-cf18d2f6f28e}"
                New-Item -Path $RBPath -Force  | Out-Null
                New-ItemProperty -Path $RBPath -Name $name -Value $value -PropertyType String -Force | Out-Null
                $oShell = New-Object -ComObject Shell.Application
                $recycleBin = $oShell.Namespace("shell:::{645FF040-5081-101B-9F08-00AA002F954E}")
                if (-not ($recycleBin.Self.Verbs() | Where-Object {$_.Name -eq "pintohome"})) {
                    $recycleBin.Self.InvokeVerb("PinToHome")
                }
                Remove-Item -Path "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}" -Recurse
                Set-ItemProperty -Path $registryPath3 -Name "QuickAccess" -Value 1 | Out-Null
            }
        #? Remove shortcut arrows
            Copy-Item -Path "..\config\blank.ico" -Destination "C:\Windows" -Force
            New-Item -Path "Registry::HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" -Force | Out-Null
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Shell Icons" -Name "29" -Value "C:\Windows\blank.ico" -Type String | Out-Null
        #? Configuring file explorer and context menus
            Get-ChildItem ..\config\reg\remove\* -e *theme* | ForEach-Object { reg import $_.FullName > $null 2>&1 }
            $sourceFilePath = "..\config\reg\add\Add_Theme_Mode_in_Context_Menu.reg"
            $tempFilePath = "..\temp\Add_Theme_Mode_in_Context_Menu.reg"
            $ps1FilePath = "..\config\reg\ThemeSwitcher.ps1"
            if (-not (Test-Path -Path $winMacDirectory)) {New-Item -ItemType Directory -Path $winMacDirectory -Force | Out-Null }
            Copy-Item -Path $ps1FilePath -Destination $winMacDirectory -Force
            Copy-Item -Path $sourceFilePath -Destination '..\temp\' -Force
            $appData = $env:LOCALAPPDATA -replace '\\', '\\'
            (Get-Content -Path $tempFilePath) -replace '%LOCALAPPDATA%', $appData | Set-Content -Path $tempFilePath
            reg import '..\config\reg\add\Add_Hidden_items_to_context_menu.reg' > $null 2>&1
            reg import '..\config\reg\add\Add_Navigation_pane_to_context_menu.reg' > $null 2>&1
            reg import '..\temp\Add_Theme_Mode_in_Context_Menu.reg' > $null 2>&1
            Copy-Item -Path "..\config\themes\*" -Destination "$env:WINDIR\Resources\Themes" -Recurse -Force
            New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced" -Name "ShowIconOverlay" -Value 0 -PropertyType DWord -Force | Out-Null
        #? End Task
            Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" -Name "{470C0EBD-5D73-4d58-9CED-E91E22E23282}" -Value "" 
            $taskbarDevSettings = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced\TaskbarDeveloperSettings"
            if (-not (Test-Path $taskbarDevSettings)) { New-Item -Path $taskbarDevSettings -Force | Out-Null }
            New-ItemProperty -Path $taskbarDevSettings -Name "TaskbarEndTask" -Value 1 -PropertyType DWORD -Force | Out-Null
        #? Hide Desktop icons
            Copy-Item -Path "..\bin\HideDesktopIcons.exe" -Destination $winMacDirectory -Force
            $shortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Hide Desktop Icons.lnk"
            $targetPath = "$winMacDirectory\HideDesktopIcons.exe"
            $shell = New-Object -ComObject WScript.Shell
            $shortcut = $shell.CreateShortcut($shortcutPath)
            $shortcut.TargetPath = $targetPath
            $shortcut.IconLocation = $targetPath
            $shortcut.Save()
            $file = Get-Item $shortcutPath
            $file.Attributes = $file.Attributes -bor [System.IO.FileAttributes]::Hidden
        #? Recycle Bin Icons
            $registryPath1 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon"
            $registryPath2 = "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\empty"
            if (-not (Test-Path -Path $registryPath2)) {New-Item -Path $registryPath2 -Force | Out-Null }
            if ($lightOrDark -eq "L" -or $lightOrDark -eq "l") {
                Set-ItemProperty -Path $registryPath1 -Name "(default)" -Value "%SystemRoot%\System32\imageres.dll,-1015"
                Set-ItemProperty -Path $registryPath1 -Name "empty" -Value "%SystemRoot%\System32\imageres.dll,-1015"
                Set-ItemProperty -Path $registryPath1 -Name "full" -Value "%SystemRoot%\System32\imageres.dll,-1017"
                Set-ItemProperty -Path $registryPath2 -Name "Icon" -Value "%SystemRoot%\System32\imageres.dll,-1015"
            } elseif ($lightOrDark -eq "D" -or $lightOrDark -eq "d") {
                Set-ItemProperty -Path $registryPath1 -Name "(default)" -Value "%SystemRoot%\System32\imageres.dll,-55"
                Set-ItemProperty -Path $registryPath1 -Name "empty" -Value "%SystemRoot%\System32\imageres.dll,-55"
                Set-ItemProperty -Path $registryPath1 -Name "full" -Value "%SystemRoot%\System32\imageres.dll,-54"
                Set-ItemProperty -Path $registryPath2 -Name "Icon" -Value "%SystemRoot%\System32\imageres.dll,-55"
            }
        #? Send To Programs (create shortcut)
            Expand-Archive -Path '..\bin\ProgramsShortcut.zip' -DestinationPath $winMacDirectory -Force
            $sendToPath = Join-Path $env:APPDATA 'Microsoft\Windows\SendTo\Programs (create shortcut).lnk'
            $targetPath = Join-Path $winMacDirectory 'ProgramsShortcut.exe'
            $shell = New-Object -ComObject WScript.Shell
            $shortcut = $shell.CreateShortcut($sendToPath)
            $shortcut.TargetPath = $targetPath
            $shortcut.IconLocation = $targetPath
            $shortcut.Save()   
        }
    }
}
Stop-Process -n explorer
Start-Sleep 2
Remove-Item "..\temp" -Recurse -Force
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