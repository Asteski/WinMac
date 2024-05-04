Clear-Host
Write-Host "----------------------------- WinMac Deployment -----------------------------" -ForegroundColor Cyan
Write-Host
Write-Host "Configuring Nexus Dock..." -ForegroundColor Yellow
Write-Host
$roundedOrSquared = Read-Host "Enter 'R' for rounded dock or 'S' for squared dock"
if ($roundedOrSquared -eq "R" -or $roundedOrSquared -eq "r") {
    Write-Host "Using rounded dock." -ForegroundColor Yellow 
} elseif ($roundedOrSquared -eq "S" -or $roundedOrSquared -eq "s") {
    Write-Host "Using squared dock." -ForegroundColor Yellow
} else {
    Write-Host "Invalid input. Defaulting to rounded dock." -ForegroundColor Yellow
}

$lightOrDark = Read-Host "Enter 'L' for light themed dock or 'D' for dark themed dock"
if ($lightOrDark -eq "L" -or $lightOrDark -eq "l") {
    Write-Host "Using light theme." -ForegroundColor Yellow 
} elseif ($lightOrDark -eq "D" -or $lightOrDark -eq "d") {
    Write-Host "Using dark theme." -ForegroundColor Yellow
} else {
    Write-Host "Invalid input. Defaulting to light theme." -ForegroundColor Yellow
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
Remove-Item -Path "$winStep\Themes\*" -Recurse -Force| Out-Null
Copy-Item -Path "config\dock\themes\*" -Destination "$winStep\Themes\" -Recurse -Force | Out-Null
Remove-Item -Path "$winStep\NeXus\Indicators\*" -Force -Recurse | Out-Null
Copy-Item -Path "config\dock\indicators\*" -Destination "$winStep\NeXus\Indicators\" -Recurse -Force | Out-Null
New-Item -ItemType Directory -Path "$winStep\Sounds" -Force | Out-Null
Copy-Item -Path "config\dock\sounds\*" -Destination "$winStep\Sounds\" -Recurse -Force | Out-Null
New-Item -ItemType Directory -Path "$winStep\Icons" -Force | Out-Null
Copy-Item config\dock\icons "$winStep" -Recurse -Force | Out-Null

$regFile = "$pwd\config\dock\winstep.reg"
$tempFolder = "$pwd\temp"
    if (-not (Test-Path $tempFolder)) {
    New-Item -ItemType Directory -Path $tempFolder -Force | Out-Null
}

if ($roundedOrSquared -eq "S" -or $roundedOrSquared -eq "s") {
    $modifiedContent = Get-Content $regFile | ForEach-Object { $_ -replace "Rounded", "Squared" }
    $modifiedFile = "$pwd\temp\winstep.reg"
    $modifiedContent | Out-File -FilePath $modifiedFile -Encoding UTF8 | Out-Null
    $regFile = $modifiedFile
    if ($lightOrDark -eq "D" -or $lightOrDark -eq "d") {
        $modifiedContent = Get-Content $regFile | ForEach-Object { $_ -replace "Light", "Dark" }
        $modifiedFile = "$pwd\temp\winstep.reg"
        $modifiedContent | Out-File -FilePath $modifiedFile -Encoding UTF8 | Out-Null
    }
}
elseif (($roundedOrSquared -ne "S" -or $roundedOrSquared -ne "s") -and ($lightOrDark -eq "D" -or $lightOrDark -eq "d")) {
    $modifiedContent = Get-Content $regFile | ForEach-Object { $_ -replace "Light", "Dark" }
    $modifiedFile = "$pwd\temp\winstep.reg"
    $modifiedContent | Out-File -FilePath $modifiedFile -Encoding UTF8 | Out-Null
    $regFile = $modifiedFile
}


reg import $regFile
Start-Sleep 2
Write-Host "Configuring Nexus Dock completed." -ForegroundColor Green

Write-Host "Clean up..." -ForegroundColor Yellow
Start-Process 'C:\Program Files (x86)\Winstep\Nexus.exe' | Out-Null
Remove-Item "C:\Users\$env:USERNAME\Desktop\Nexus.lnk" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "C:\Users\$env:USERNAME\OneDrive\Desktop\Nexus.lnk" -Force -ErrorAction SilentlyContinue | Out-Null
Remove-Item "$pwd\temp\*" -Recurse -Force -ErrorAction SilentlyContinue | Out-Null
Write-Host "Clean up completed." -ForegroundColor Green

Write-Host
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