
function Find-GitRoot {
    param (
        [string]$StartingDirectory = (Get-Location)
    )
    $currentDirectory = Get-Item -Path $StartingDirectory
    while ($null -ne $currentDirectory) {
        if (Test-Path -Path (Join-Path $currentDirectory.FullName '.git')) {
            return $true
        }
        $currentDirectory = $currentDirectory.Parent
    }
    return $false
}
