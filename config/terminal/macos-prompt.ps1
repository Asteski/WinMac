
# MacOS prompt

function prompt {
    $userName = $env:USERNAME
    $folder = Split-Path -Leaf $pwd
    $computerName = hostname
    if (Test-Admin -eq $true) { $userName = "`e[91m$($userName)`e[0m" } else { $userName = "`e[93m$($userName)`e[0m" }
    if ($folder -eq $env:USERNAME)
    {
        "$userName@$computerName ~ % "
    }
    else
    {
        "$userName@$computerName $folder % "
    }
    Set-Title
}
