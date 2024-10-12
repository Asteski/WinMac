
# macOS prompt

function prompt {
    $userName = $env:USERNAME
    $folder = Split-Path -Leaf $pwd
    $computerName = hostname
    if (Test-Admin -eq $true) { $userName = "`e[91m$($userName)`e[0m" } else { $userName = "`e[93m$($userName)`e[0m" }
    if ($folder -eq $env:USERNAME)
    {
        "$userName@$computerName ~ % "
    }
    elseif (Find-GitRoot)
    {
        "$userName@$computerName $folder `e[95m$('git::[')`e[96m$(git rev-parse --abbrev-ref HEAD 2>$null)`e[95m$(']')`e[0m% "
    }
    else
    {
        "$userName@$computerName $folder % "
    }
    Set-Title
}
