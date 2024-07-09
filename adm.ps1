#winget install --id Armin2208.WindowsAutoNightMode --silent
$fileContent = Get-Content -Path ".\config\adm\scripts.yaml"
$newContent = $fileContent -replace "<STRING_TO_REPLACE>", "C:\Users\$ENV:USERNAME\AppData\Roaming\AutoDarkMode"
New-Item -ItemType File -Path ".\temp\scripts.yaml" -Force
$newContent | Set-Content -Path ".\temp\scripts.yaml"
#Get-Process "AutoDarkMode" -ErrorAction SilentlyContinue | Stop-Process -Force
Copy-Item ".\temp\scripts.yaml" "C:\Users\$ENV:USERNAME\AppData\Roaming\AutoDarkMode\scripts.yaml"  -Force
Copy-Item ".\config\adm\color-mode.ps1" "C:\Users\$ENV:USERNAME\AppData\Roaming\AutoDarkMode\color-mode.ps1" -Force