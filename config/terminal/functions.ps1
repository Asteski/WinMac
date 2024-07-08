
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
set-alias -name env -value printenv
set-alias -name svc -value Get-Service
set-alias -name fsvc -value Find-Service
set-alias -name setsvc -value Set-Service
set-alias -name rmsvc -value Remove-Service
set-alias -name startsvc -value Start-Service
set-alias -name stopsvc -value Stop-Service
set-alias -name proc -value Get-Process
set-alias -name fproc -value Find-Process
set-alias -name setproc -value Set-Process
set-alias -name rmproc -value Remove-Process
set-alias -name startproc -value Start-Process
set-alias -name stopproc -value Stop-Process
set-alias -name less -value more
set-alias -name random -value Get-RandomString
set-alias -name user -value getuser
set-alias -name pwd -value ppwd
set-alias -name lnk -value run
set-alias -name ls -value lls
set-alias -name l -value lls
set-alias -name stack -value stahky
set-alias -name find -value ffind
set-alias -name fi -value ffind

# Functions
function psversion { $PSVersionTable }
function lls { Get-ChildItem | format-table -autosize }
function ll { Get-ChildItem -Force | format-table -autosize }
function la { Get-ChildItem -Force -Attributes !D | format-table -autosize }
function ld { Get-ChildItem -Directory | format-table -autosize }
function wl { winget list } 
function wi { winget install $args }
function wl { winget list }
function wr { winget uninstall $args } 
function ws { $appname = $args; winget search "$appname" }
function wu { winget upgrade $args } 
function ww { $appname = $args; winget show "$appname" }
function ppwd { $pwd.path }
function ld { Get-ChildItem -Directory }
function c { Set-Location .. }
function ffind { $filter = "*$args*"; if ($filter) {(Get-ChildItem -Recurse -ErrorAction SilentlyContinue | Where-Object { $_.Name -like $filter }).FullName} else {Write-Host "No filename provided." -ForegroundColor Red}}

$stacks = "$env:LOCALAPPDATA\Stahky"
function stahky { 
    $dir = "$args"
    if (-not (Test-Path $stacks)) {
        Write-Host "Stahky not found." -ForegroundColor Red
    } 
    elseif ($args.Count -eq 0) {
        Write-Host "Please provide a directory to stack:" -ForegroundColor Yellow
        Write-Host "stack <full path to directory>"
        Write-Host "stack . for current directory"
        Write-Host
        Write-Host "stack go to peek stacks directory"
    }
    elseif ($args -eq "go") {
        open $stacks
    }
    elseif ($args -eq ".") {
        Stahky.exe $pwd
    }
    else {
        Stahky.exe $dir
    }
}

function run {
    $start = "$($env:APPDATA)\Microsoft\Windows\Start Menu\Programs"
    $name = "$args"
    $lnk = Get-ChildItem -Path $start -Filter "*.lnk" -Recurse | Where-Object { $_.Name -like "*$name*" }
    if ($lnk.Count -gt 1) {
        Write-Host "Multiple shortcuts found. Please provide a more specific name:" -ForegroundColor Red
        Write-Host
        (($lnk | Select-Object -Property Name).Name).Replace(".lnk", "")
    } elseif ($lnk.Count -eq 0) {
        Write-Host "No shortcut found." -ForegroundColor Red
    } else {
        Start-Process -FilePath $lnk.FullName
    }
}

function getuser {
    $userName = $args
    Import-Module microsoft.powershell.localaccounts -UseWindowsPowerShell -WarningAction SilentlyContinue
    if ($userName) {
        Get-LocalUser $userName | Select-Object Name, Enabled, LastLogon, SID, PasswordExpires, PasswordChangeableDate, PasswordLastSet
    } else {
        Get-LocalUser | Select-Object Name, Enabled, LastLogon, PasswordExpires, PasswordChangeableDate, PasswordLastSet | Format-Table
    }
}

function adduser {
    $userName = $args
    Import-Module microsoft.powershell.localaccounts -UseWindowsPowerShell -WarningAction SilentlyContinue
    $new = New-LocalUser "$userName" -NoPassword
    if ($new) {
        Write-Host "User $userName created."
    }
}

function rmuser {
    $userName = $args[0]
    Import-Module microsoft.powershell.localaccounts -UseWindowsPowerShell -WarningAction SilentlyContinue
    Remove-LocalUser "$userName"
}

function passwd {
    [string]$userName = $args[0]
    Import-Module microsoft.powershell.localaccounts -UseWindowsPowerShell -WarningAction SilentlyContinue
    $securePwd1 = Read-Host "Enter Password" -AsSecureString
    $plainPwd1 =[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePwd1))
    $securePwd2 = Read-Host "Enter Password again" -AsSecureString
    $plainPwd2 =[Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePwd2))
    
    if($plainPwd1 -NE $plainPwd2) {
        Write-Host "Passwords do not match." -ForegroundColor Red
    } else {
        Set-LocalUser -Name $userName -Password $securePwd1
        Write-Host "Password changed for $userName." -ForegroundColor Green
    }
}

function nohup {
    param(
        [Parameter(Mandatory = $true, Position=0)] [string] $command,
        [Alias('l')] [switch] $listAll,
        [Alias('r')] [string] $killJob
    )

    if ($listAll) {
        Get-Job | Select-Object -Property Id, Name, State, HasMoreData, Command
    }
    elseif ($killJob) {
        $job = Get-Job -Id $killJob -ErrorAction SilentlyContinue
        if ($job) {
            $job | Stop-Job -Force
            Write-Host "Job with ID $killJob has been killed." -ForegroundColor Green
        }
        else {
            Write-Host "Job with ID $killJob not found." -ForegroundColor Red
        }
    }
    else {
        Start-Job -ScriptBlock { param($command) & $command } -ArgumentList $command
    }
}

function head {
    $file = $args[0]
    $lines = $args[1]
    if ($null -eq $lines) { $lines = 10 }
    more $file | Select-Object -first $lines
}

function tail {
    $file = $args[0]
    $lines = $args[1]
    if ($null -eq $lines) { $lines = 10 }
    more $file | Select-Object -last $lines
}

function unzip {
    [string]$file = $args
    Expand-Archive $file
}

function wget {
    $url = $args
    $outFile = $url.Split("/")[-1]
    Invoke-WebRequest "$url" -OutFile $outFile
}

function Find-Service {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$SearchString
    )

    $services = Get-Service -ErrorAction SilentlyContinue | Where-Object { $_.DisplayName -like "*$SearchString*" }

    if ($services.Count -eq 0) {
        Write-Host "No services found matching '$SearchString'."
    } else {
        Write-Host "Services matching '$SearchString':"
        $services
    }
}
function Find-Process {
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$SearchString
    )

    $processes = Get-Process -ErrorAction SilentlyContinue | Where-Object { $_.ProcessName -like "*$SearchString*" }

    if ($processes.Count -eq 0) {
        Write-Host "No processes found matching '$SearchString'."
    } else {
        Write-Host "Processes matching '$SearchString':"
        $processes
    }
}

function printenv { 
    if ($args.Count -eq 0) { 
        Get-ChildItem Env: 
    }
    else { 
        $args | ForEach-Object { 
            $envVar = Get-ChildItem Env:$_ -ErrorAction SilentlyContinue
            if ($envVar) {
                $envVar.Value -split ';' | Sort-Object 
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
    [Environment]::SetEnvironmentVariable($name, $value, "User")
}

function rmenv { 
    param(
        [Parameter(Mandatory = $true, Position=0)] [string] $name
    )
    if (-not (Test-Path "Env:\$name")) {
        Write-Host "Environment variable '$name' does not exist." -ForegroundColor Red
    } else {
        [Environment]::SetEnvironmentVariable($name, $null, "User")
    }
}

function Get-RandomString
{
    param([Parameter(ValueFromPipeline=$false)][ValidateRange(1,64)][Alias('l','length')][int]$PasswordLength = 10)

    $CharacterSet = @{
            Lowercase   = (97..122) | Get-Random -Count 20 | ForEach-Object {[char]$_}
            Uppercase   = (65..90)  | Get-Random -Count 20 | ForEach-Object {[char]$_}
            Numeric     = (48..57)  | Get-Random -Count 20 | ForEach-Object {[char]$_}
            SpecialChar = (33..47)+(58..64)+(91..96)+(123..126) | Get-Random -Count 10 | ForEach-Object {[char]$_}
    }

    $StringSet = $CharacterSet.Uppercase + $CharacterSet.Lowercase + $CharacterSet.Numeric + $CharacterSet.SpecialChar

    -join(Get-Random -Count $PasswordLength -InputObject $StringSet)
}

function battery { 
    $info = get-wmiobject Win32_Battery |`
    select-object @{N='Battery ID'; E={$_.DeviceID}},`
    @{N='Battery Type'; E={$_.Caption}},  `
    @{N='Battery Status'; E={$_.Status}}, `
    @{N='Charge Remaining'; E={$_.EstimatedChargeRemaining}}, `
    @{N='Time Remaining'; E={$_.EstimatedRunTime}} 
    if ($info.'Time Remaining' -ge 2000) { $info.'Battery Status' = "Charging"; $info.'Time Remaining' = "N/A"}
    if ($info) {
    Write-Host @"

Battery Information
"@ -ForegroundColor Yellow
    $info 
    } else {
        Write-Host "No battery found" -ForegroundColor Red 
        }
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
    @{N='Last BootUp Time'; E={$_.OsLastBootUpTime}}
Write-Host @"

Computer Information
"@ -ForegroundColor Yellow
    $info
}

function hist {
    $find = $args
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
            $files = Get-ChildItem -Exclude *.exe,*.dll,*.sys,*.com,*.msi,*.msp,*.msu,*.cab,*.iso,*.img,*.vhd,*.vhdx,*.zip,*.rar,*.7z
            string-search $args[0]
            }
        elseif (($args.count -eq 2) -and ($args[0] -eq '-r')){
            $files = Get-ChildItem -Recurse -Exclude *.exe,*.dll,*.sys,*.com,*.msi,*.msp,*.msu,*.cab,*.iso,*.img,*.vhd,*.vhdx ,*.zip,*.rar,*.7z
            string-search $args[1]
        }
    }
}

#EOF