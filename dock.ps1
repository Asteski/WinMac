$downloadUrl = "https://www.winstep.net/nexus.zip"
$downloadPath = "dock.zip"
if (-not (Test-Path $downloadPath)) {
    Invoke-WebRequest -Uri $downloadUrl -OutFile $downloadPath #| Out-Null
}
Expand-Archive -Path $downloadPath -DestinationPath $pwd -Force #| Out-Null
Start-Process -FilePath ".\NexusSetup.exe" -ArgumentList "/silent" -Verb RunAs
Start-Sleep 60
Stop-Process -n Nexus #| Out-Null
# Remove-Item .\dock.zip -Force #| Out-Null
Remove-Item .\ReadMe.txt -Force #| Out-Null
Remove-Item .\NexusSetup.exe -Force
$winStep = 'C:\Users\Public\Documents\WinStep'
Copy-Item -Path "config\dock\themes\*" -Destination "$winStep\" -Recurse -Force -Container -Exclude (Get-ChildItem -Path "$winStep\" -Directory).Name | Out-Null
Copy-Item -Path "config\dock\indicators\*" -Destination "$winStep\NeXus\" -Recurse -Force -Container -Exclude (Get-ChildItem -Path "$winStep\NeXus\" -File).Name | Out-Null
#TODO explorer tasmgr controlpanel terminal downloads recyclebin settings
New-Item -ItemType Directory -Path "$winStep\Icons" -Force | Out-Null
Copy-Item config\dock\icons "$winStep" -Recurse -Force | Out-Null

$regFile = "$pwd\config\dock\winstep.reg"
reg import $regFile

# $regEntries = @"
# "BitmapsFolder"="C:\\Users\\Public\\Documents\\WinStep\\Themes\\WinMac Light Opaque Squared\\"
# "GlobalBitmapFolder"="C:\\Users\\Public\\Documents\\WinStep\\Themes\\WinMac Light Opaque Squared\\"
# "NeXuSBitmapFolder"="C:\\Users\\Public\\Documents\\WinStep\\Themes\\WinMac Light Opaque Squared\\"
# "NeXuSImage3"="C:\\Users\\Public\\Documents\\WinStep\\Themes\\WinMac Light Opaque Squared\\NxBack.png"
# "ClockVoiceFolder"="C:\\Users\\Public\\Documents\\WinStep\\Themes\\Female Voice\\"
# "ClockSoundFolder"="C:\\Users\\Public\\Documents\\WinStep\\Themes\\WinstepSamples\\"
# "ClockBitmapFolder"="C:\\Users\\Public\\Documents\\WinStep\\Themes\\WinMac Light Opaque Squared\\"
# "TrashBitmapFolder"="C:\\Users\\Public\\Documents\\WinStep\\Themes\\WinMac Light Opaque Squared\\"
# "CPUBitmapFolder"="C:\\Users\\Public\\Documents\\WinStep\\Themes\\WinMac Light Opaque Squared\\"
# "POP3BitmapFolder"="C:\\Users\\Public\\Documents\\WinStep\\Themes\\WinMac Light Opaque Squared\\"
# "METARBitmapFolder"="C:\\Users\\Public\\Documents\\WinStep\\Themes\\WinMac Light Opaque Squared\\"
# "@

# $regEntries | ForEach-Object {
#     $key = $_.Split("=")[0].Trim()
#     $value = $_.Split("=")[1].Trim()
#     Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS" -Name $key -Value $value
# }

# Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "DockBitmapFolder1" -Value "C:\\Users\\Public\\Documents\\WinStep\\Themes\\WinMac Light Opaque Squared\\"
# Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Docks" -Name "DockBack3Image1" -Value "C:\\Users\\Public\\Documents\\WinStep\\Themes\\WinMac Light Opaque Squared\\NxBack.png"

# Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Shared" -Name "IconBrowserPath" -Value "C:\\Users\\Adams\\OneDrive\\Utilities\\icons\\System App Icons\\Windows System\\SEO\\Explorer\\"
# Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Shared" -Name "BackupPath" -Value "C:\\Users\\Adams\\OneDrive\\Utilities\\Nexus Dock\\"
# Set-ItemProperty -Path "HKCU:\Software\WinSTEP2000\NeXuS\Shared" -Name "TaskIcon1" -Value "C:\\Users\\Adams\\OneDrive\\Utilities\\icons\\System App Icons\\Windows System\\SEO\\Explorer\\Settings.ico"

Start-Sleep 2
Start-Process 'C:\Program Files (x86)\Winstep\Nexus.exe' | Out-Null
Remove-Item "C:\Users\$env:UERNAME\Desktop\Nexus.lnk" -Force | Out-Null