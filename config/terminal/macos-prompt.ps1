
# MacOS prompt
function Test-Admin
{
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

function prompt {
    $userName = $env:USERNAME
    $computerName = hostname
    $folder = Split-Path -Leaf $pwd
    if (Test-Admin -eq $true) { $userName = "$([char]27)[91m$($userName)$([char]27)[0m" } else { $userName = "$([char]27)[93m$($userName)$([char]27)[0m" }
    if ($folder -eq $env:USERNAME)
    {
        $userName + '@' + $computerName + ' ~ % '
    }
    else
    {
        $userName + '@' + $computerName + ' /' + $folder + ' % '
    }
}
