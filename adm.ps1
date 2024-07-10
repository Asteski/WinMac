echo 0
winget install --id Armin2208.WindowsAutoNightMode --silent
echo 1
Start-Process -FilePath "C:\Users\$ENV:USERNAME\AppData\Local\Programs\AutoDarkMode\adm-app\autodarkmodeapp.exe" -Verb RunAs
echo 2
while (!(Get-Process -Name "autodarkmodesvc" -ErrorAction SilentlyContinue)) {
    Write-Host "Process is not running."
    Start-Sleep 1
}
Start-Sleep 10
echo 3
Stop-Process -Name "AutoDarkMode*" -Force
echo 4
$fileContent = Get-Content -Path ".\config\adm\scripts.yaml"
$newContent = $fileContent -replace "<STRING_TO_REPLACE>", "C:\Users\$ENV:USERNAME\AppData\Roaming\AutoDarkMode"
New-Item -ItemType File -Path ".\temp\scripts.yaml" -Force
$newContent | Set-Content -Path ".\temp\scripts.yaml"
Copy-Item ".\temp\scripts.yaml" "C:\Users\$ENV:USERNAME\AppData\Roaming\AutoDarkMode\scripts.yaml" -Force
Copy-Item ".\config\adm\color-mode.ps1" "C:\Users\$ENV:USERNAME\AppData\Roaming\AutoDarkMode\color-mode.ps1" -Force
echo 5
Start-Process -FilePath "C:\Users\$ENV:USERNAME\AppData\Local\Programs\AutoDarkMode\adm-app\autodarkmodeapp.exe" -Verb RunAs
echo 6