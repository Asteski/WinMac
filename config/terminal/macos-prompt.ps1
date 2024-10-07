
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
    if (Test-Admin -eq $true) { $userName = "`e[91m$($userName)`e[0m" } else { $userName = "`e[93m$($userName)`e[0m" }
    if ($folder -eq $env:USERNAME)
    {
        $userName + '@' + $computerName + ' ~ % '
    }
    else
    {
        $userName + '@' + $computerName + ' /' + $folder + ' % '
    }
}
