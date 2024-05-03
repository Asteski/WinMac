$selectedApps = @()

Write-Host "Please select packages you want to install:"
Write-Host "1. PowerToys"
Write-Host "2. Powershell Profile"
Write-Host "3. StartAllBack"
Write-Host "4. Open-Shell"
Write-Host "5. TopNotify"

$selection = Read-Host "Enter the numbers of the packages you want to install (separated by commas):"

$selectedApps = $selection.Split(',')

foreach ($app in $selectedApps) {
    switch ($app.Trim()) {
        "1" {
            # Install PowerToys
            # Add your installation code here
            Write-Host "Installing PowerToys..."
        }
        "2" {
            # Install Everything
            # Add your installation code here
            Write-Host "Installing Powershell Profile..."
        }
        "3" {
            # Install StartAllBack
            # Add your installation code here
            Write-Host "Installing StartAllBack..."
        }
        "4" {
            # Install Open-Shell
            # Add your installation code here
            Write-Host "Installing Open-Shell..."
        }
        "5" {
            # Install TopNotify
            # Add your installation code here
            Write-Host "Installing TopNotify..."
        }
        default {
            Write-Host "Invalid selection: $app"
        }
    }
}