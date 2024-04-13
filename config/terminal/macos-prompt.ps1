
# MacOS prompt
function prompt {
    $userName = $env:USERNAME
    $computerName = hostname
    $folder = Split-Path -Leaf $pwd
    if ($folder -eq $env:USERNAME)
    {
        $userName + '@' + $computerName + ' ~ % '
    }
    else
    {
        $userName + '@' + $computerName + ' /' + $folder + ' % '
    }
}
