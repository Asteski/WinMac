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
    "Microsoft.PowerShell", ## PowerShell Core # interactive
    "9NRWMJP3717K", ## Python # interactive
    "BotProductions.IconViewer", # interactive
    "Brave.Brave",
    "CPUID.CPU-Z", # interactive
    "Git.Git",
    "Helm.Helm",
    "Irfanview.IrfanView",
    "JanDeDobbeleer.OhMyPosh",
    "Logitech.OptionsPlus", # interactive
    "Microsoft.AzureCLI", # interactive
    "Microsoft.VisualStudioCode",
    "Microsoft.Winget.Source_8wekyb3d8bbwe",
    "Neovim.Neovim",
    "Microsoft.PowerToys",
    "Python.Launcher",
    "StartIsBack.StartAllBack",
    "UKuberentes.Minikube",
    "Voidtools.Everything",
    "7zip.7zip"
)

# install apps

foreach ($app in $list) {
    winget install --id $app --force
}

## PowerToys

# %LOCALAPPDATA%\Microsoft\PowerToys

## StartAllBack

# ...

## Context Menu

# Remove the Edit in Notepad from context menu
# Remove-Item -Path "Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Shell Extensions\Blocked" -Name "{CA6CC9F1-867A-481E-951E-A28C5E4F01EA}" -Confirm:$false -Force


