
Set-PSReadlineKeyHandler -Chord Tab -Function TabCompleteNext
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

set-alias -name np -value notepad
set-alias -name note -value notepad
# set-alias -name qn -value quicknote
# set-alias -name qnote -value quicknote
set-alias -name te -value PSTree
set-alias -name open -value of
set-alias -name tree -value PSTree
set-alias -name kill -value killall
set-alias -name whatis -value man
set-alias -name backup -value wbadmin
set-alias -name rcopy -value robocopy

function ll { Get-ChildItem -Force }
function la { Get-ChildItem -Force -Attributes !D }

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

function touch {
    $file = $args[0]
    if($null -eq $file) 
    {
        $file = "touch_" + (Get-Date -Format "yyyy-MM-ddTHHmmss") + ".txt"
        Write-Output $null > $file
        Write-Host "File created: $file" -ForegroundColor Green
    }
    elseif(Test-Path $file)
    {
        Write-Host "File already exists" -ForegroundColor Red
    }
    else
    {
        Write-Output $null > $file
        Write-Host "File created: $file" -ForegroundColor Green
    }
}

function ditto {
    $source = $args[0]
    $destination = $args[1]
    if($null -eq $source -or $null -eq $destination) 
    {
        Write-Host "Source does not exist or destination already exists"  -ForegroundColor Red
    }
    elseif((Test-Path $source) -and -not (Test-Path $destination))
    {
        Copy-Item -Path $source -Destination $destination -Recurse
    }
    else 
    {
        Write-Host "Source does not exist or destination already exists" -ForegroundColor Red
    }
}

function top {
    $process = Get-Process | Sort-Object -Property CPU -Descending | Select-Object -First 10
    $process | Format-Table -AutoSize
}

function killall {
    $procName = $args[0]
    $process = Get-Process | Where-Object { $_.ProcessName -eq $procName }
    if ($null -eq $procName -or $null -eq $process) 
    {
        Write-Host "Process is not running or not found" -ForegroundColor Red
    } 
    else 
    {
        $process | Stop-Process -Force
        WRite-Host "Process $procName stopped" -ForegroundColor Green
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
        Invoke-Item .
    }
    else
    {
        Write-Host "File or directory does not exist" -ForegroundColor Red
    }
}

function ansi-reverse {
    param(
        [Parameter(Mandatory = $true, Position=0)] [string] $txt,   # raw text string
        [Parameter(Mandatory = $true, Position=1)] [string] $pat    # Pattern string
    )
    
    $ESC = "$([char] 27)"   # ANSI ESC (0x1b)
    $RES = "`e[0m"          # ANSI Reset ()
    $RON = "`e[7m"          # Reverse
    $ROF = "`e[27m"         # ReverseOff
    $RED = "`e[91m"         # BrightRed
    $GRY = "`e[90m"         # BrightBlack / "DarkGray"

    # Replace text pattern with ANSI Reversed version (and using capture group for case preserve)
    # https://stackoverflow.com/a/40683667/1147688
    $txt = "$txt" -replace "($pat)", "$RED`$1$GRY"      # Using: BrightRed

    Return "$txt"
}

function print-color {
    param( 
        [Parameter(Mandatory = $true, Position=0)] [string] $i,     # Filename
        [Parameter(Mandatory = $true, Position=1)] [string] $j,     # Linenumber
        [Parameter(Mandatory = $true, Position=2)] [string] $k,     # Line
        [Parameter(Mandatory = $true, Position=3)] [string] $p      # Pattern
    )
    
    $fn = " {0}  " -f $i
    $nn = ": {0,-5}: " -f $j
    $ln = (ansi-reverse "$k" "$p")
    
    Write-Host -f DarkYellow "$fn" -non
    Write-Host -f Yellow "$nn" -non
    Write-Host -f DarkGray "$ln"
}

function string-search {
    param(
        [Parameter(Mandatory = $true, Position=0)] [string] $pattern
    )
    foreach ($file in $files) {
        $A = Select-String -Path $file.FullName -AllMatches -Pattern $pattern
        $A | Select-Object Path, LineNumber, Pattern, Line | ForEach-Object {
            # $i = $_.Filename
            $i = $_.Path.Substring(($pwd.Path).Length + 1)
            $j = $_.LineNumber
            $k = $_.Line
            $p = $_.Pattern
            print-color "$i" "$j" "$k" "$p"
        }
    }
}

function grep {
    if($args.count -eq 0) { 
        Write-Host -f Red "Error: " -Non; Write-Host "Please provide a RegEx argument to grep." 
        Write-Host -f DarkYellow "Usage: grep <RegEx>"  
    } 
    else 
    {
        if ($args.count -eq 1) {
            $files = Get-ChildItem
            string-search $args[0]
            }
        elseif (($args.count -eq 2) -and ($args[0] -eq '-r')){
            $files = Get-ChildItem -Recurse
            string-search $args[1]
        }
    }
}