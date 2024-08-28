Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Windows.Forms

function Get-WindowsTheme {
    try {
        $key = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes\Personalize"
        $appsUseLightTheme = Get-ItemProperty -Path $key -Name AppsUseLightTheme -ErrorAction SilentlyContinue

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

# Define colors based on theme
$backgroundColor = if ($windowsTheme -eq "Dark") { "#1E1E1E" } else { "#FFFFFF" }
$foregroundColor = if ($windowsTheme -eq "Dark") { "#FFFFFF" } else { "#000000" }
$accentColor = if ($windowsTheme -eq "Dark") { "#0078D4" } else { "#0078D4" }
$secondaryBackgroundColor = if ($windowsTheme -eq "Dark") { "#2D2D2D" } else { "#F0F0F0" }
$borderColor = "#FFFFFF"  # Greyish border color
$borderThickness = "1"  # Thinner border

[xml]$xaml = @"
<Window
    xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
    xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
    Title="WinMac Deployment" Height="700" Width="400" WindowStartupLocation="CenterScreen" Background="$backgroundColor">
    <Window.Resources>
        <SolidColorBrush x:Key="BackgroundBrush" Color="$backgroundColor"/>
        <SolidColorBrush x:Key="ForegroundBrush" Color="$foregroundColor"/>
        <SolidColorBrush x:Key="AccentBrush" Color="$accentColor"/>
        <SolidColorBrush x:Key="SecondaryBackgroundBrush" Color="$secondaryBackgroundColor"/>
        <SolidColorBrush x:Key="BorderBrush" Color="$borderColor"/>
        <Thickness x:Key="BorderThickness">1</Thickness>  <!-- Corrected Thickness -->
    </Window.Resources>

    <Grid Background="{StaticResource BackgroundBrush}">
        <Grid.RowDefinitions>
            <RowDefinition Height="Auto"/>
            <RowDefinition Height="*"/>
            <RowDefinition Height="Auto"/>
        </Grid.RowDefinitions>
        
        <TextBlock Grid.Row="0" FontSize="20" FontWeight="Bold" Text="WinMac Deployment" Foreground="{StaticResource ForegroundBrush}" HorizontalAlignment="Center" Margin="0,10,0,10"/>

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

                        <CheckBox x:Name="chkPowerToys" Content="PowerToys" Grid.Row="0" Grid.Column="0" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkEverything" Content="Everything" Grid.Row="0" Grid.Column="1" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkPowershellProfile" Content="PowerShell Profile" Grid.Row="1" Grid.Column="0" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkStartAllBack" Content="StartAllBack" Grid.Row="1" Grid.Column="1" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkWinMacMenu" Content="WinMac Menu" Grid.Row="2" Grid.Column="0" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkTopNotify" Content="TopNotify" Grid.Row="2" Grid.Column="1" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkStahky" Content="Stahky" Grid.Row="3" Grid.Column="0" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkAutoHotkey" Content="AutoHotkey" Grid.Row="3" Grid.Column="1" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <CheckBox x:Name="chkOther" Content="Other" Grid.Row="4" Grid.Column="0" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                    </Grid>
                </GroupBox>

                <!-- Additional Settings: Start Menu -->
                <GroupBox Header="Start Menu Options" Margin="0,5,0,5" Padding="5,5,5,5" Foreground="{StaticResource ForegroundBrush}" Background="{StaticResource SecondaryBackgroundBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="{StaticResource BorderThickness}">
                    <Grid Margin="5">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*" />
                            <ColumnDefinition Width="*" />
                        </Grid.ColumnDefinitions>
                        <RadioButton x:Name="startMenuWinMac" Content="WinMac Start Menu" IsChecked="True" Grid.Row="0" Grid.Column="0" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <RadioButton x:Name="startMenuClassic" Content="Classic Start Menu" Grid.Row="0" Grid.Column="1" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                    </Grid>
                </GroupBox>

                <!-- Additional Settings: Prompt Style -->
                <GroupBox Header="Prompt Style Options" Margin="0,5,0,5" Padding="5,5,5,5" Foreground="{StaticResource ForegroundBrush}" Background="{StaticResource SecondaryBackgroundBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="{StaticResource BorderThickness}">
                    <Grid Margin="5">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*" />
                            <ColumnDefinition Width="*" />
                        </Grid.ColumnDefinitions>
                        <RadioButton x:Name="promptStyleWinMac" Content="WinMac Prompt" IsChecked="True" Grid.Row="0" Grid.Column="0" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <RadioButton x:Name="promptStyleMacOS" Content="MacOS Prompt" Grid.Row="0" Grid.Column="1" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                    </Grid>
                </GroupBox>

                <!-- Additional Settings: Shell Corner Style -->
                <GroupBox Header="Shell Corner Style" Margin="0,5,0,5" Padding="5,5,5,5" Foreground="{StaticResource ForegroundBrush}" Background="{StaticResource SecondaryBackgroundBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="{StaticResource BorderThickness}">
                    <Grid Margin="5">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*" />
                            <ColumnDefinition Width="*" />
                        </Grid.ColumnDefinitions>
                        <RadioButton x:Name="shellCornerRounded" Content="Rounded" IsChecked="True" Grid.Row="0" Grid.Column="0" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <RadioButton x:Name="shellCornerSquared" Content="Squared" Grid.Row="0" Grid.Column="1" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                    </Grid>
                </GroupBox>

                <!-- Additional Settings: Theme Style -->
                <GroupBox Header="Theme Style" Margin="0,5,0,5" Padding="5,5,5,5" Foreground="{StaticResource ForegroundBrush}" Background="{StaticResource SecondaryBackgroundBrush}" BorderBrush="{StaticResource BorderBrush}" BorderThickness="{StaticResource BorderThickness}">
                    <Grid Margin="5">
                        <Grid.ColumnDefinitions>
                            <ColumnDefinition Width="*" />
                            <ColumnDefinition Width="*" />
                        </Grid.ColumnDefinitions>
                        <RadioButton x:Name="themeLight" Content="Light" IsChecked="True" Grid.Row="0" Grid.Column="0" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                        <RadioButton x:Name="themeDark" Content="Dark" Grid.Row="0" Grid.Column="1" Margin="0,3,0,3" Foreground="{StaticResource ForegroundBrush}"/>
                    </Grid>
                </GroupBox>

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

# References to UI elements
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
$chkAutoHotkey = $window.FindName("chkAutoHotkey")
$chkOther = $window.FindName("chkOther")

$startMenuWinMac = $window.FindName("startMenuWinMac")
$startMenuClassic = $window.FindName("startMenuClassic")

$promptStyleWinMac = $window.FindName("promptStyleWinMac")
$promptStyleMacOS = $window.FindName("promptStyleMacOS")

$shellCornerRounded = $window.FindName("shellCornerRounded")
$shellCornerSquared = $window.FindName("shellCornerSquared")

$themeLight = $window.FindName("themeLight")
$themeDark = $window.FindName("themeDark")

$btnInstall = $window.FindName("btnInstall")
$btnCancel = $window.FindName("btnCancel")

# Enable/Disable component selection based on install type
$fullInstall.Add_Checked({
    $componentSelection.IsEnabled = $false
})
$customInstall.Add_Checked({
    $componentSelection.IsEnabled = $true
})

# Event handler for the Install button
$btnInstall.Add_Click({
    $installType = if ($fullInstall.IsChecked) { "F" } else { "C" }
    $selectedApps = @()
    
    if ($chkPowerToys.IsChecked) { $selectedApps += "1," }
    if ($chkEverything.IsChecked) { $selectedApps += "2," }
    if ($chkPowershellProfile.IsChecked) { $selectedApps += "3," }
    if ($chkStartAllBack.IsChecked) { $selectedApps += "4," }
    if ($chkWinMacMenu.IsChecked) { $selectedApps += "5," }
    if ($chkTopNotify.IsChecked) { $selectedApps += "6," }
    if ($chkStahky.IsChecked) { $selectedApps += "7," }
    if ($chkAutoHotkey.IsChecked) { $selectedApps += "8," }
    if ($chkOther.IsChecked) { $selectedApps += "9," }
    
    $startMenu = if ($startMenuWinMac.IsChecked) { "X" } else { "C" }
    $promptSet = if ($promptStyleWinMac.IsChecked) { "W" } else { "M" }
    $shellCorners = if ($shellCornerRounded.IsChecked) { "R" } else { "S" }
    $themeStyle = if ($themeLight.IsChecked) { "L" } else { "D" }

    [System.Windows.MessageBox]::Show("Installation Type: $installType`nSelected Components: $($selectedApps -join ', ')`nStart Menu: $startMenu`nPrompt Style: $promptStyle`nShell Corners: $shellCorners`nTheme Style: $themeStyle", "Installation Summary", [System.Windows.MessageBoxButton]::OK, [System.Windows.MessageBoxImage]::Information)

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
            if (-not (Test-Path "$profilePath\PowerShell\$profileFiele")) { New-Item -ItemType File -Path "$profilePath\PowerShell\$profileFile" | Out-Null }
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
            Add-Content -Path "$profilePath\WindowsPowerShell\$prompt" -Value $functions
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
                winget install --id autohotkey.autohotkey --source winget --silent | Out-Null
                winget install --id Microsoft.DotNet.AspNetCore.6 --silent | Out-Null
                Invoke-WebRequest -Uri 'https://download.visualstudio.microsoft.com/download/pr/222a065f-5671-4aed-aba9-46a94f2705e2/2bbcbd8e1c304ed1f7cef2be5afdaf43/windowsdesktop-runtime-6.0.32-win-x64.exe' -OutFile 'windowsdesktop-runtime-6.0.32-win-x64.exe'
                Start-Process -FilePath '.\windowsdesktop-runtime-6.0.32-win-x64.exe' -ArgumentList '/install /quiet /norestart' -Wait
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
                New-Item -ItemType Directory -Path "$env:PROGRAMFILES\WinMac\" | Out-Null
                New-Item -ItemType Directory -Path "$env:PROGRAMFILES\WinMac\menu" | Out-Null
                # Copy-Item .\bin\ "$env:PROGRAMFILES\WinMac\" | Out-Null
                Copy-Item .\bin\menu "$env:PROGRAMFILES\WinMac\menu" | Out-Null
                $actionWinKey = New-ScheduledTaskAction -Execute 'WindowsKey.exe' -WorkingDirectory "$env:PROGRAMFILES\WinMac\menu"
                $actionStartButton = New-ScheduledTaskAction -Execute "StartButton.ahk" -WorkingDirectory "$env:PROGRAMFILES\WinMac\menu"
                Register-ScheduledTask -TaskName "StartButton" -Action $actionStartButton -Trigger $trigger -Principal $principal -Settings $settings -TaskPath $taskFolder -ErrorAction SilentlyContinue | Out-Null
                Register-ScheduledTask -TaskName "WindowsKey" -Action $actionWinKey -Trigger $trigger -Principal $principal -Settings $settings -TaskPath $taskFolder -ErrorAction SilentlyContinue | Out-Null
                Remove-Item "$env:LOCALAPPDATA\Microsoft\Windows\WinX" -Recurse -Force
                Remove-Item .\windowsdesktop-runtime-6.0.32-win-x64.exe -Force
                Copy-Item -Path "$pwd\config\winx\" -Destination "$env:LOCALAPPDATA\Microsoft\Windows\" -Recurse -Force
                Start-Process "$env:PROGRAMFILES\WinMac\menu\WindowsKey.exe"
                Start-Process "$env:PROGRAMFILES\WinMac\menu\StartButton.ahk"
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
            # AutoHotkey
            Write-Host "Installing AutoHotkey..." -ForegroundColor Yellow  
            winget install --id autohotkey.autohotkey --source winget --silent | Out-Null
            $sourceDirectory = "$pwd\config\ahk"
            $destinationDirectory = "$env:PROGRAMFILES\AutoHotkey\Scripts"
            $fileName = "Keybindings.ahk"
            $folderName = "WinMac"
            $taskService = New-Object -ComObject "Schedule.Service"
            $taskService.Connect() | Out-Null
            $rootFolder = $taskService.GetFolder("\")
            $taskFolder = "\" + $folderName
            $trigger = New-ScheduledTaskTrigger -AtLogon
            $settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable -MultipleInstances IgnoreNew
            try { $existingFolder = $rootFolder.GetFolder($folderName) } catch { $existingFolder = $null }                
            if ($null -eq $existingFolder) { $rootFolder.CreateFolder($folderName) | Out-Null }
            Copy-Item -Path $sourceDirectory\* -Destination $destinationDirectory -Recurse -Force
            $taskName = ($fileName).replace('.ahk','')
            $action = New-ScheduledTaskAction -Execute $fileName -WorkingDirectory $destinationDirectory    
            $principal = New-ScheduledTaskPrincipal -GroupId "BUILTIN\Administrators" -RunLevel Highest
            Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Principal $principal -TaskPath $taskFolder -Settings $settings -ErrorAction SilentlyContinue | Out-Null
            Start-Process -FilePath $destinationDirectory\$($fileName)
            Write-Host "AutoHotkey installation completed." -ForegroundColor Green
        }
        "9" {
            # WinLauncher
            Write-Host "Installing WinLauncher..." -ForegroundColor Yellow
            Start-Process -FilePath "msiexec" -ArgumentList "/i $($pwd)\bin\WinLauncher\WinLauncher.msi /quiet" -Wait
            Write-Host "AutoHotkey installation completed." -ForegroundColor Green
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









    $window.Close()
})

# Event handler for the Cancel button
$btnCancel.Add_Click({
    $window.Close()
})

$window.ShowDialog() | Out-Null
