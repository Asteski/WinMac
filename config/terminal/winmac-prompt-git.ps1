
# WinMac prompt

function prompt {
    $userName = $env:USERNAME
    $folder = Split-Path -Leaf $pwd
    $date = "`e[92m$("$(Get-Date -f HH:mm:ss) ")`e[0m`e[93m"
    if (Test-Admin -eq $true) { $userName = "`e[91m$($userName)`e[0m" } else { $userName = "`e[93m$($userName)`e[0m" }
    if ($folder -eq $env:USERNAME)
    {
        "$($date)$($userName) @ ~`e[93m$(' > ')`e[0m"
    }
    else
    {
        "$($date)$($userName) @ $folder`e[93m$(' > ')`e[0m"
    }
    Set-Title
}
