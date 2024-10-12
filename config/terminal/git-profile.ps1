
# Git prompt function
function Find-GitRoot {
    param (
        [string]$StartingDirectory = (Get-Location)
    )
    $currentDirectory = Get-Item -Path $StartingDirectory
    while ($null -ne $currentDirectory) {
        if (Test-Path -Path (Join-Path $currentDirectory.FullName '.git')) {
            return $true
        }
        $currentDirectory = $currentDirectory.Parent
    }
    return $false
}

# Git aliases
function add { git add $args; git status }
function status { git status }
function commit { git commit -m $args }
function push { git push $args }
function pull { git pull $args }
function rebase { git pull --rebase }
function stash { git stash $args }
function branch { git branch $args }
function checkout { git checkout $args }
function merge { git merge $args }
function clone { git clone $args }
function log { git log $args }
function tag { $msg = $args[1]; git tag -a $args[0] -m "$msg" }
function pusha { $msg = $args; git add -u; git status; start-sleep 1; git commit -m "$msg"; git push }
set-alias -name ch -value checkout
set-alias -name st -value status

