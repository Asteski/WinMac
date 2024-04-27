Clear-Host
Write-Host "----------------------------- WinMac Dock Deployment -----------------------------" -ForegroundColor Cyan
Write-Host
Write-Host "Configuring Nexus Dock..." -ForegroundColor Yellow
Write-Host
$roundedOrSquared = Read-Host "Enter 'R' for rounded dock or 'S' for squared dock"
if ($roundedOrSquared -eq "R" -or $roundedOrSquared -eq "r") {
    Write-Host "Setting rounded dock..." -ForegroundColor Yellow
} elseif ($roundedOrSquared -eq "S" -or $roundedOrSquared -eq "s") {
    Write-Host "Setting squared dock..." -ForegroundColor Yellow
} else {
    Write-Host "Invalid input. Defaulting to rounded dock." -ForegroundColor Yellow
}

$downloadUrl = "https://www.winstep.net/nexus.zip"
$downloadPath = "dock.zip"
if (-not (Test-Path $downloadPath)) {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath
}

Expand-Archive -Path $downloadPath -DestinationPath $pwd -Force
Start-Process -FilePath ".\NexusSetup.exe" -ArgumentList "/silent"
start-sleep 60
Stop-Process -n Nexus
Remove-Item .\dock.zip -Force
Remove-Item .\ReadMe.txt -Force
Remove-Item .\NexusSetup.exe -Force
$winStep = 'C:\Users\Public\Documents\WinStep'
Remove-Item -Path "$winStep\Themes\*" -Recurse -Force
Copy-Item -Path "config\dock\themes\*" -Destination "$winStep\Themes\" -Recurse -Force
Remove-Item -Path "$winStep\NeXus\Indicators\*" -Force -Recurse
Copy-Item -Path "config\dock\indicators\*" -Destination "$winStep\NeXus\Indicators\" -Recurse -Force
New-Item -ItemType Directory -Path "$winStep\Icons" -Force | Out-Null
Copy-Item config\dock\icons "$winStep" -Recurse -Force | Out-Null

if ($roundedOrSquared -eq "R" -or $roundedOrSquared -eq "r") {
    $regFile = "$pwd\config\dock\winstepR.reg"
} elseif ($roundedOrSquared -eq "S" -or $roundedOrSquared -eq "s") {
    $regFile = "$pwd\config\dock\winstepS.reg"
} else {
    $regFile = "$pwd\config\dock\winstepR.reg"
}

reg import $regFile

Start-Sleep 2
Start-Process 'C:\Program Files (x86)\Winstep\Nexus.exe' | Out-Null
Remove-Item "C:\Users\$env:USERNAME\Desktop\Nexus.lnk" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "C:\Users\$env:USERNAME\OneDrive\Desktop\Nexus.lnk" -Force -ErrorAction SilentlyContinue | Out-Null

Write-Host "Configuring Nexus Dock completed." -ForegroundColor Green

Write-Host
Write-Host "------------------------ WinMac Dock Deployment completed ------------------------" -ForegroundColor Cyan
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