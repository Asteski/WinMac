
# macOS prompt

function Set-Title 
{
    $title = Split-Path -Leaf (Get-Location)
    if (Test-Admin -eq $true) { $title = 'Admin: ' + $title }
    $host.UI.RawUI.WindowTitle = $title
}

function prompt {
    $userName = $env:USERNAME
    $folder = Split-Path -Leaf $pwd
    $computerName = hostname
    if (Test-Admin -eq $true) { $userName = "`e[91m$($userName)`e[0m" } else { $userName = "`e[93m$($userName)`e[0m" }
    if ($env:USERPROFILE -eq $pwd)
    {
        "$userName@$computerName ~ % "
    }
    else
    {
        "$userName@$computerName $folder % "
    }
    Set-Title
}
