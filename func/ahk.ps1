$ahkPath = Join-Path $pwd\bin "starthotkey.exe"
if (-not (Test-Path $ahkPath)) {
    Write-Host "starthotkey.exe not found at path: $exePath" -ForegroundColor Red
    exit 1
}
$registryPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Run"
Set-ItemProperty -Path $registryPath -Name "AutoHotKeyScript" -Value $exePath