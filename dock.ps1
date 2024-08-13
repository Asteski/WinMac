Clear-Host
Write-Host @"
-----------------------------------------------------------------------

Welcome to WinMac Deployment!

Author: Asteski
Version: 0.5.2

This is Work in Progress. You're using this script at your own risk.

-----------------------------------------------------------------------
"@ -ForegroundColor Cyan

## Check if script is run from the correct directory

$checkDir = Get-ChildItem
if (!($checkDir -like "*WinMac*" -and $checkDir -like "*config*" -and $checkDir -like "*bin*")) {
    Write-Host "`nWinMac components not found. Please make sure to run the script from the correct directory." -ForegroundColor Red
    Start-Sleep 2
    exit
}

## Dock Configuration

Write-Host "`nConfiguring Nexus Dock...`n" -ForegroundColor Yellow
$roundedOrSquared = Read-Host "Enter 'R' for rounded dock or 'S' for squared dock"
if ($roundedOrSquared -eq "R" -or $roundedOrSquared -eq "r") {
    Write-Host "Using rounded dock.`n" -ForegroundColor Green 
} elseif ($roundedOrSquared -eq "S" -or $roundedOrSquared -eq "s") {
    Write-Host "Using squared dock.`n" -ForegroundColor Green
} else {
    Write-Host "Invalid input. Defaulting to rounded dock.`n" -ForegroundColor Yellow
}

$lightOrDark = Read-Host "Enter 'L' for light themed dock or 'D' for dark themed dock"
if ($lightOrDark -eq "L" -or $lightOrDark -eq "l") {
    Write-Host "Using light theme.`n" -ForegroundColor Green
} elseif ($lightOrDark -eq "D" -or $lightOrDark -eq "d") {
    Write-Host "Using dark theme.`n" -ForegroundColor Green
} else {
    Write-Host "Invalid input. Defaulting to light theme.`n" -ForegroundColor Yellow
}
## Dock Installation
Start-Sleep 1
Write-Host "`Installing Nexus Dock...`n" -ForegroundColor Yellow
$downloadUrl = "https://www.winstep.net/nexus.zip"
$downloadPath = "dock.zip"
if (-not (Test-Path $downloadPath)) {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath
}
Expand-Archive -Path $downloadPath -DestinationPath $pwd -Force
Start-Process -FilePath ".\NexusSetup.exe" -ArgumentList "/silent"
Start-Sleep 10
$process1 = Get-Process -Name "NexusSetup" -ErrorAction SilentlyContinue
while ($process1) {
    Start-Sleep 5
    $process1 = Get-Process -Name "NexusSetup" -ErrorAction SilentlyContinue
}
Start-Sleep 10
$process2 = Get-Process -Name "Nexus" -ErrorAction SilentlyContinue
if (!($process2)) {
    Start-Sleep 5
    $process2 = Get-Process -Name "Nexus" -ErrorAction SilentlyContinue
} else { Start-Sleep 10 }
Get-Process -n Nexus | Stop-Process
$winStep = 'C:\Users\Public\Documents\WinStep'
Remove-Item -Path "$winStep\Themes\*" -Recurse -Force # | Out-Null
Copy-Item -Path "config\dock\themes\*" -Destination "$winStep\Themes\" -Recurse -Force # | Out-Null
Remove-Item -Path "$winStep\NeXus\Indicators\*" -Force -Recurse # | Out-Null
Copy-Item -Path "config\dock\indicators\*" -Destination "$winStep\NeXus\Indicators\" -Recurse -Force # | Out-Null
New-Item -ItemType Directory -Path "$winStep\Sounds" -Force # | Out-Null
Copy-Item -Path "config\dock\sounds\*" -Destination "$winStep\Sounds\" -Recurse -Force # | Out-Null
New-Item -ItemType Directory -Path "$winStep\Icons" -Force # | Out-Null
Copy-Item config\dock\icons "$winStep" -Recurse -Force # | Out-Null
$downloadsPath = "$env:USERPROFILE\Downloads"
if (-not (Test-Path $downloadsPath)) {
    New-Item -ItemType Directory -Path $downloadsPath # | Out-Null
}
$regFile = "$pwd\config\dock\winstep.reg"
$tempFolder = "$pwd\temp"
$tempPath = Test-Path $tempFolder
    if (-not ($tempPath)) {
    New-Item -ItemType Directory -Path $tempFolder -Force # | Out-Null
}
if ($roundedOrSquared -eq "S" -or $roundedOrSquared -eq "s") {
    $modifiedContent = Get-Content $regFile | ForEach-Object { $_ -replace "Rounded", "Squared" }
    $modifiedFile = "$pwd\temp\winstep.reg"
    $modifiedContent | Out-File -FilePath $modifiedFile -Encoding UTF8 # | Out-Null
    $regFile = $modifiedFile
    if ($lightOrDark -eq "D" -or $lightOrDark -eq "d") {
        $modifiedContent = Get-Content $regFile | ForEach-Object { $_ -replace "Light", "Dark" }
        $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace '"UIDarkMode"="3"', '"UIDarkMode"="1"' }
        $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace "1644825", "15658734" }
        $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace "16119283", "2563870" }
        $modifiedFile = "$pwd\temp\winstep.reg"
        $modifiedContent | Out-File -FilePath $modifiedFile -Encoding UTF8 # | Out-Null
    }
}
elseif (($roundedOrSquared -ne "S" -or $roundedOrSquared -ne "s") -and ($lightOrDark -eq "D" -or $lightOrDark -eq "d")) {
    $modifiedContent = Get-Content $regFile | ForEach-Object { $_ -replace "Light", "Dark" }
    $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace '"UIDarkMode"="3"', '"UIDarkMode"="1"' }
    $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace "1644825", "15658734" }
    $modifiedContent = $modifiedContent | ForEach-Object { $_ -replace "16119283", "2563870" }
    $modifiedFile = "$pwd\temp\winstep.reg"
    $modifiedContent | Out-File -FilePath $modifiedFile -Encoding UTF8 # | Out-Null
    $regFile = $modifiedFile
}
$modifiedContent = Get-Content $regFile | ForEach-Object { $_ -replace "<<DOWNLOADS_PATH>>", $downloadsPath }
reg import $regFile > $null 2>&1
Remove-ItemProperty -Path "Registry::HKEY_CURRENT_USER\Software\WinSTEP2000\NeXuS\Docks" -Name "DockLabelColorHotTrack1" -ErrorAction SilentlyContinue # | Out-Null
Start-Process 'C:\Program Files (x86)\Winstep\Nexus.exe' # | Out-Null
while (!(Get-Process nexus -ErrorAction SilentlyContinue)) { Start-Sleep 1 }
Write-Host "Nexus Dock installation completed.`n" -ForegroundColor Green

Write-Host "Clean up..." -ForegroundColor Yellow
$programsDir = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs"
Move-Item -Path "C:\Users\$env:USERNAME\Desktop\Nexus.lnk" -Destination $programsDir -Force -ErrorAction SilentlyContinue # | Out-Null
Move-Item -Path "C:\Users\$env:USERNAME\OneDrive\Desktop\Nexus.lnk" -Destination $programsDir -Force -ErrorAction SilentlyContinue # | Out-Null
Remove-Item "$pwd\temp\*" -Recurse -Force -ErrorAction SilentlyContinue # | Out-Null
Remove-Item .\dock.zip -Force # | Out-Null
Remove-Item .\ReadMe.txt -Force # | Out-Null
Remove-Item .\NexusSetup.exe -Force # | Out-Null
Write-Host "Clean up completed.`n" -ForegroundColor Green

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