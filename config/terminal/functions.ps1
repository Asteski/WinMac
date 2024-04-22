
# Completion settings
Set-PSReadlineKeyHandler -Chord Tab -Function MenuComplete
Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward

# Aliases
set-alias -name vi -value vim
set-alias -name np -value notepad
set-alias -name note -value notepad
set-alias -name of -value open
set-alias -name tree -value PSTree
set-alias -name kill -value killall -Option AllScope
set-alias -name whatis -value man
set-alias -name backup -value wbadmin
set-alias -name rcopy -value robocopy
set-alias -name history -value hist -Option AllScope
set-alias -name version -value psversion
set-alias -name psver -value psversion
set-alias -name htop -value ntop
set-alias -name apt -value winget
set-alias -name brew -value winget
set-alias -name info -value computerinfo

# Functions
function psversion { $PSVersionTable }
function ll { Get-ChildItem -Force }
function la { Get-ChildItem -Force -Attributes !D }
function wl { winget list }
function ws { $appname = $args; winget search "$appname" }
function wr { $appname = $args; winget uninstall "$appname" } 
function wu { $appname = $args; winget upgrade "$appname" } 
function wi { $appname = $args; winget install "$appname" --accept-package-agreements --accept-source-agreements }


function printenv { 
    if ($args.Count -eq 0) { 
        Get-ChildItem Env: 
    }
    else { 
        $args | ForEach-Object { 
            $envVar = Get-ChildItem Env:$_ -ErrorAction SilentlyContinue
            if ($envVar) {
                $envVar
            } else {
                Write-Host "Environment variable '$_' does not exist." -ForegroundColor Red
            }
        }
    }
}

function setenv { 
    param(
        [Parameter(Mandatory = $true, Position=0)] [string] $name,
        [Parameter(Mandatory = $true, Position=1)] [string] $value
    )
    if (-not (Test-Path "Env:\$name")) {
        Write-Host "Environment variable '$name' does not exist." -ForegroundColor Red
    } else {
        [Environment]::SetEnvironmentVariable($name, $value, "User")
    }
}

function rmenv { 
    param(
        [Parameter(Mandatory = $true, Position=0)] [string] $name
    )
    if (-not (Test-Path "Env:\$name")) {
        Write-Host "Environment variable '$name' does not exist." -ForegroundColor Red
    } else {
        Remove-Item Env:\$name
    }
}

function battery { 
    $info = get-wmiobject Win32_Battery |`
    select-object @{N='Battery ID'; E={$_.DeviceID}},`
    @{N='Battery Type'; E={$_.Caption}},  `
    @{N='Battery Status'; E={$_.Status}}, `
    @{N='Charge Remaining'; E={$_.EstimatedChargeRemaining}}, `
    @{N='Time Remaining'; E={$_.EstimatedRunTime}} 
Write-Host @"

Battery Information
"@ -ForegroundColor Yellow
    $info
}

function computerinfo { 
    $info = Get-ComputerInfo |`
    select-object `
    @{N='User Name'; E={$_.CsCaption}}, `
    @{N='PC Manufacturer'; E={$_.CsManufacturer}}, `
    @{N='PC Model'; E={$_.CsModel}}, `
    @{N='OS Name'; E={$_.OsName}}, `
    @{N='OS Version'; E={$_.OsVersion}}, `
    @{N='BIOS Version'; E={$_.BiosCaption}}, `
    @{N='BIOS Release Date'; E={$_.BiosReleaseDate}}, `
    @{N='CPU Manufacturer'; E={$_.CsProcessors.Manufacturer}}, `
    @{N='CPU Name'; E={$_.CsProcessors.Name}}, `
    @{N='CPU Description'; E={$_.CsProcessors.Description}}, `
    @{N='CPU Availability'; E={$_.CsProcessors.Availability}}, `
    @{N='CPU Architecture'; E={$_.CsProcessors.Architecture}}, `
    # @{N='BiosSerialNumber'; E={$_.BiosSerialNumber}}, `
    @{N='Last BootUp Time'; E={$_.OsLastBootUpTime}}
Write-Host @"

Computer Information
"@ -ForegroundColor Yellow
    $info
}

function hist {
    $find = $args;
    Get-Content (Get-PSReadlineOption).HistorySavePath | Where-Object {$_ -like "*$find*"} | Select-Object -Last 20
}

function touch {
    $file = $args[0]
    if($null -eq $file) 
    {
        $file = "touch_" + (Get-Date -Format "yy-MM-ddTHHmmss") + ".txt"
        Write-Output $null > $file
        Write-Host "File created: $file" -ForegroundColor Yellow
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
        Write-Host "Process $procName stopped" -ForegroundColor Green
    }
}

function open {
    $path = $args
    if (!($path)) {
        Invoke-Item .
    }
    elseif (Test-Path "$path") {
        $fullPath = Get-Item -Path "$path" -Force | Select-Object -ExpandProperty FullName
        if ((Test-Path "$fullPath") -and (Get-Item "$fullPath" -Force).PSIsContainer) 
        {
            Invoke-Item "$fullPath"
        }
        else
        {
            $folderPath = Split-Path -Path "$fullPath"
            explorer.exe $folderPath
        }
    }
    elseif (!(Test-Path "$path"))
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
