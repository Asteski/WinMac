$url = "https://github.com/joedf/stahky/releases/download/v0.1.0.8/stahky_U64_v0.1.0.8.zip"
$outputPath = "$pwd\stahky_U64_v0.1.0.8.zip"
$exePath = "$env:PROGRAMFILES\Stahky"
# $shortcutPath = "$exePath\config\shortcuts\control.stahky.lnk"

New-Item -ItemType Directory -Path $env:PROGRAMFILES\Stahky -Force | Out-Null
New-Item -ItemType Directory -Path $env:PROGRAMFILES\Stahky\config -Force | Out-Null
Invoke-WebRequest -Uri $url -OutFile $outputPath
if (Test-Path -Path "$exePath\stahky.exe") {
    Write-Host "Stahky already exists."
} else {
    Expand-Archive -Path $outputPath -DestinationPath $exePath
}
Copy-Item -Path $pwd\config\taskbar\stacks\* -Destination $exePath\config -Recurse -Force
Copy-Item -Path $exePath\config\themes\stahky-dark.ini -Destination $exePath\stahky.init

$shortcutPath = "$exePath\config\shortcuts\Control.stahky.lnk"
$shell = New-Object -ComObject WScript.Shell
$taskbarPath = [System.IO.Path]::Combine($env:APPDATA, "Microsoft\Internet Explorer\Quick Launch\User Pinned\TaskBar")
$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $exePath
$shortcut.Save()
$shortcutFile = [System.IO.Path]::Combine($taskbarPath, "control.stahky.lnk")
Copy-Item -Path $shortcutPath -Destination $shortcutFile -Force