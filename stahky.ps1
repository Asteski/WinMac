$url = "https://github.com/joedf/stahky/releases/download/v0.1.0.8/stahky_U64_v0.1.0.8.zip"
$outputPath = "$pwd\stahky_U64_v0.1.0.8.zip"
$exePath = "$env:programfiles\Stahky"

Invoke-WebRequest -Uri $url -OutFile $outputPath
Expand-Archive -Path $outputPath -DestinationPath $exePath

$shell = New-Object -ComObject WScript.Shell
$shortcutPath = "$pwd\stahky.lnk"
$targetPath = "$pwd\stahky.exe /stahky $pwd\config\taskbar\stacks\shortcuts\Favorites.stahky.lnk"

$shortcut = $shell.CreateShortcut($shortcutPath)
$shortcut.TargetPath = $targetPath
$shortcut.Save()


$Target = "$pwd\config\taskbar\stacks\shortcuts\Favorites.stahky.lnk"
$KeyPath1  = "HKCU:\SOFTWARE\Classes"
$KeyPath2  = "*"
$KeyPath3  = "shell"
$KeyPath4  = "{:}"
$ValueName = "ExplorerCommandHandler"
$ValueData =
    (Get-ItemProperty `
        ("HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\" + `
            "CommandStore\shell\Windows.taskbarpin")
    ).ExplorerCommandHandler

$Key2 = (Get-Item $KeyPath1).OpenSubKey($KeyPath2, $true)
$Key3 = $Key2.CreateSubKey($KeyPath3, $true)
$Key4 = $Key3.CreateSubKey($KeyPath4, $true)
$Key4.SetValue($ValueName, $ValueData)

$Shell = New-Object -ComObject "Shell.Application"
$Folder = $Shell.Namespace((Get-Item $Target).DirectoryName)
$Item = $Folder.ParseName((Get-Item $Target).Name)
$Item.InvokeVerb("{:}")

$Key3.DeleteSubKey($KeyPath4)
if ($Key3.SubKeyCount -eq 0 -and $Key3.ValueCount -eq 0) {
    $Key2.DeleteSubKey($KeyPath3)
}