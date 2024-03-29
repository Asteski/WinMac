
function prompt { 
    $userName = 'Adams'
    $folder = Split-Path -Leaf $pwd
    if ($folder -eq $env:USERNAME) 
    {
        'PS: ' + $userName + ' @ ~ > ' 
    }
    else
    {
        'PS: ' + $userName + ' @ ' + $folder + ' > '
    }
}

function touch {
    $file = $args[0]
    if($null -eq $file) 
    {
        $file = "touch_" + (Get-Date -Format "yyyy-MM-ddTHHmmss") + ".txt"
        Write-Output $null > $file
    }
    elseif(Test-Path $file)
    {
        throw "file already exists"
    }
    else
    {
        Write-Output $null > $file
    }
}

function ditto {
    $source = $args[0]
    $destination = $args[1]
    if($null -eq $source -or $null -eq $destination) 
    {
        throw "Source and destination are required"
    }
    elseif((Test-Path $source) -and -not (Test-Path $destination)) 
    {
        Copy-Item -Path $source -Destination $destination -Recurse
    }
    else 
    {
        throw "Source does not exist or destination already exists"
    }
}

function top {
    $process = Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 10
    $process | Format-Table -AutoSize
}

function whatis {
    $command = $args[0]
    if($null -eq $command) 
    {
        throw "Command is required"
    }
    else
    {
        help $command
    }
}

function killall {
    $procName = $args[0]
    $process = Get-Process | Where-Object { $_.ProcessName -eq $procName }
    if ($null -eq $procName -or $null -eq $process) 
    {
        throw "Process is not running or not found"
    } 
    else 
    {
        $process | Stop-Process -Force
    }
}

function of {
    param (
        [Parameter(Mandatory=$false, Position=0)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    if (Test-Path $Path) {
        $fullPath = Get-Item -Path $Path | Select-Object -ExpandProperty FullName
        if ((Test-Path $fullPath) -and (Get-Item $fullPath).PSIsContainer) 
        {
            explorer.exe $fullPath
        }
        else 
        {
            $folderPath = Split-Path -Path $fullPath
            explorer.exe $folderPath
        }
    }
    elseif (-not (Test-Path $Path)) {
        ii .
    }
    else
    {
        throw "File or directory does not exist"
    }
}

function ll {
    Get-ChildItem -Force
}

function la {
    Get-ChildItem -Force -Attributes !D
}

function tree {
    Get-ChildItem -Recurse -Force
}

set-alias -name np -value notepad
set-alias -name open -value of
