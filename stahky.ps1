$url = "https://github.com/joedf/stahky/releases/download/v0.1.0.8/stahky_U64_v0.1.0.8.zip"
$outputPath = "$($pwd)\stahky_U64_v0.1.0.8.zip"
$exePath = ($env:AppData | Split-Path) + "\local\Stahky\"

Invoke-WebRequest -Uri $url -OutFile $outputPath
Expand-Archive -Path $outputPath -DestinationPath $exePath

$shell = New-Object -ComObject Shell.Application
$shortcutPath1 = "$($pwd)\config\taskbar\stacks\shortcuts\Control.stahky.lnk"
$shortcutPath2 = "$($pwd)\config\taskbar\stacks\shortcuts\Favorites.stahky.lnk"

$taskbarPath = [System.IO.Path]::Combine($env:APPDATA, "Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar")
$taskbarFolder = $shell.Namespace($taskbarPath)

$shortcut1 = $shell.CreateShortcut($shortcutPath1)
$shortcut2 = $shell.CreateShortcut($shortcutPath2)

$taskbarFolder.CopyHere($shortcut1.FullName)
$taskbarFolder.CopyHere($shortcut2.FullName)