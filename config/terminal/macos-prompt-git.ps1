
# macOS prompt

function Set-Title
{
    $repo = git rev-parse --show-toplevel 2>$null
    if ($LASTEXITCODE -eq 0) {
    $repo = Split-Path -Leaf $repo
            $title = $repo + '@' + (git rev-parse --abbrev-ref HEAD 2>$null)
    } else {
        $title = Split-Path -Leaf (Get-Location)
    }
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
    elseif (Find-GitRoot)
    {
        "$userName@$computerName $folder `e[95mgit:(`e[96m$(git rev-parse --abbrev-ref HEAD 2>$null)`e[95m)`e[0m% "
    }
    else
    {
        "$userName@$computerName $folder % "
    }
    Set-Title
}
