$url = "https://github.com/joedf/stahky/releases/download/v0.1.0.8/stahky_U64_v0.1.0.8.zip"
$outputPath = "$pwd\stahky_U64_v0.1.0.8.zip"
$exePath = "$env:PROGRAMFILES\Stahky"

New-Item -ItemType Directory -Path $env:PROGRAMFILES\Stahky -Force | Out-Null
New-Item -ItemType Directory -Path $env:PROGRAMFILES\Stahky\config -Force | Out-Null
Invoke-WebRequest -Uri $url -OutFile $outputPath
Expand-Archive -Path $outputPath -DestinationPath $exePath
Copy-Item -Path $pwd\config\taskbar\stacks\* -Destination $exePath\config -Recurse -Force
Copy-Item -Path $exePath\config\themes\stahky-dark.ini -Destination $exePath\stahky.ini