Clear-Host
Write-Host @"
-----------------------------------------------------------------------

Welcome to WinMac Deployment!

Author: Asteski
Version: 0.4.2

This is Work in Progress. You're using this script at your own risk.

-----------------------------------------------------------------------
"@ -ForegroundColor Cyan
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
Write-Host "Waiting for Nexus process to stop..." -ForegroundColor Yellow
$processName = "NexusSetup"
$timeout = 60 # Timeout in seconds
$stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
while ((Get-Process -Name $processName -ErrorAction SilentlyContinue) -and ($stopwatch.Elapsed.TotalSeconds -lt $timeout)) {
    Start-Sleep -Seconds 1
}
$stopwatch.Stop()
if ($stopwatch.Elapsed.TotalSeconds -ge $timeout) {
    Write-Host "Timeout reached. Nexus process did not stop." -ForegroundColor Red
} else {
    Write-Host "Nexus process stopped." -ForegroundColor Green
}

#EOF