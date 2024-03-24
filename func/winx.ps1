$exePath = Join-Path $pwd\bin "starthotkey.exe"
if (-not (Test-Path $exePath)) {
    Write-Host "starthotkey.exe not found at path: $exePath" -ForegroundColor Red
    exit 1
}
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
Set-ItemProperty -Path $registryPath -Name "starthotkey" -Value $exePath
Write-Host "Configuration completed." -ForegroundColor Green