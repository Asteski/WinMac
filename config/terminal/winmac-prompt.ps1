
# WinMac prompt
function Test-Admin
{
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

function prompt {
    $userName = $env:USERNAME
    $folder = Split-Path -Leaf $pwd
    $date = Get-Date -f HH:mm:ss
    if (Test-Admin -eq $true) { $userName = "$([char]27)[91m$($userName)$([char]27)[0m" } else { $userName = "$([char]27)[93m$($userName)$([char]27)[0m" }
    if ($folder -eq $env:USERNAME)
    {
        "$([char]27)[92m$($date)$([char]27)[0m" + ' ' + $userName + ' @ ~' + "$([char]27)[93m$(' > ')$([char]27)[0m"
    }
    else
    {
        "$([char]27)[92m$($date)$([char]27)[0m" + ' ' + $userName + ' @ ' + $folder + "$([char]27)[93m$(' > ')$([char]27)[0m"
    }
}
