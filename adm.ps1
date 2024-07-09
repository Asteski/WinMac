#winget install --id Armin2208.WindowsAutoNightMode --silent
$fileContent = Get-Content -Path ".\config\adm\scripts.yaml"
$newContent = $fileContent -replace "<STRING_TO_REPLACE>", "C:\Users\$ENV:USERNAME\AppData\Roaming\AutoDarkMode"
$newContent | Set-Content -Path ".\temp\scripts.yaml"
#Get-Process "AutoDarkMode" -ErrorAction SilentlyContinue | Stop-Process -Force
Copy-Item ".\temp\scripts.yaml" "C:\Users\$ENV:USERNAME\AppData\Roaming\AutoDarkMode"  -Force
Copy-Item ".\config\adm\color-scheme.ps1" "C:\Users\$ENV:USERNAME\AppData\Roaming\AutoDarkMode" -Force
