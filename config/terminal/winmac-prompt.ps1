
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
    if (Test-Admin -eq $true) { $userName = "`e[91m$($userName)`e[0m" } else { $userName = "`e[93m$($userName)`e[0m" }
    if ($folder -eq $env:USERNAME)
    {
        "`e[92m$($date)`e[0m" + ' ' + $userName + ' @ ~' + "`e[93m$(' > ')`e[0m"
    }
    else
    {
        "`e[92m$($date)`e[0m" + ' ' + $userName + ' @ ' + $folder + "`e[93m$(' > ')`e[0m"
    }
}
