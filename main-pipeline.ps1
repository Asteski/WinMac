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
    # "Microsoft.PowerShell", ## PowerShell Core # interactive
    # "9NRWMJP3717K", ## Python # interactive
    # "BotProductions.IconViewer", # interactive
    # "Brave.Brave",
    # "CPUID.CPU-Z", # interactive
    # "Helm.Helm",
    # "Irfanview.IrfanView",
    # "Logitech.OptionsPlus", # interactive
    # "Microsoft.AzureCLI", # interactive
    # "Microsoft.VisualStudioCode",
    # "Neovim.Neovim",
    # "Python.Launcher",
    # "Kuberentes.Minikube",
    # "7zip.7zip",
    # "Git.Git",
    'Microsoft.PowerToys',
    'Voidtools.Everything',
    'lin-ycv.EverythingPowerToys',
    'StartIsBack.StartAllBack',
    'JanDeDobbeleer.OhMyPosh'
)

# install apps

foreach ($app in $list) {
    winget install --id $app --silent --force
}

## PowerToys

$plugins = $env:LOCALAPPDATA + '\Microsoft\PowerToys\PowerToys Run\Plugins'
$winget = 'https://github.com/bostrot/PowerToysRunPluginWinget/releases/download/v1.2.3/winget-powertoys-1.2.3.zip'
$prockill = 'https://github.com/8LWXpg/PowerToysRun-ProcessKiller/releases/download/v1.0.1/ProcessKiller-v1.0.1-x64.zip'

Invoke-WebRequest -uri $winget -Method "GET"  -Outfile 'winget.zip'
Invoke-WebRequest -uri $prockill -Method "GET"  -Outfile 'prockill.zip'

Expand-Archive 'winget.zip' -DestinationPath $pwd\Winget -Force
Expand-Archive 'prockill.zip' -DestinationPath $pwd -Force

Copy-item $pwd\Winget -Destination $plugins -Recurse -Force
Copy-item $pwd\ProcessKiller -Destination $plugins -Recurse -Force

Get-ChildItem * -Include *.zip -Recurse | Remove-Item
Remove-Item -Recurse -Force Winget
Remove-Item -Recurse -Force ProcessKiller

## StartAllBack

$registryFile = $pwd + '\StartAllBack\StartAllBack.reg'
Start-Process -FilePath 'regedit.exe' -ArgumentList "/s $RegistryFile" -Wait