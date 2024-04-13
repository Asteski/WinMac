
# WinMac prompt
function prompt {
    $userName = $env:USERNAME
    $folder = Split-Path -Leaf $pwd
    $date = Get-Date -f HH:mm:ss
    if ($folder -eq $env:USERNAME)
    {
        "$([char]27)[92m$($date)$([char]27)[0m" + ' ' + $userName + ' @ ~' + "$([char]27)[93m$(' > ')$([char]27)[0m"
    }
    else
    {
        "$([char]27)[92m$($date)$([char]27)[0m" + ' ' + $userName + ' @ ' + $folder + "$([char]27)[93m$(' > ')$([char]27)[0m"
    }
}
