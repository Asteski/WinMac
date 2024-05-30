$url = "https://github.com/joedf/stahky/releases/download/v0.1.0.8/stahky_U64_v0.1.0.8.zip"
$outputPath = "$($pwd)\stahky_U64_v0.1.0.8.zip"
$exePath = ($env:AppData | Split-Path) + "\local\Stahky\"

Invoke-WebRequest -Uri $url -OutFile $outputPath
Expand-Archive -Path $outputPath -DestinationPath $exePath

$shell = New-Object -ComObject Shell.Application
$shortcutPath1 = "$($pwd)\config\taskbar\stacks\shortcuts\Control.stahky.lnk"
$shortcutPath2 = "$($pwd)\config\taskbar\stacks\shortcuts\Favorites.stahky.lnk"
$taskbar = $shell.Namespace('C:\Users\Adams\AppData\Roaming\Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar')
Copy-Item "$($pwd)\config\taskbar\stacks\themes\stahky-light.ini" "$exePath\stahky.ini" --Force
$shortcut1 = $taskbar.ParseName($shortcutPath1)
$shortcut2 = $taskbar.ParseName($shortcutPath2)
$verb = $shortcut1.Verbs() | Where-Object { $_.Name -eq 'Pin to Taskbar' }
$verb.DoIt()
$verb = $shortcut2.Verbs() | Where-Object { $_.Name -eq 'Pin to Taskbar' }
$verb.DoIt()