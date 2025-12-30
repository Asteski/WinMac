# param
# (
# 	[Parameter(Mandatory=$true)]
# 	[string]
# 	$mode
# )
Write-Host "Switching to $mode mode..." -ForegroundColor Green
$ErrorActionPreference = 'SilentlyContinue'
$WarningPreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'
taskkill /IM explorer.exe /F > $null 2>&1
if (Test-Path "C:\Program Files (x86)\Winstep\Nexus.exe") {
	taskkill /IM nexus.exe /F > $null 2>&1
}
$registryPath0 = "HKCU:\Software\WinSTEP2000\NeXuS"
$registryPath1 = "HKCU:\Software\WinSTEP2000\NeXuS\Docks"
$registryPath2 = "HKCU:\Software\WinSTEP2000\Shared"
$registryPath3 = "HKCU:\Software\StartIsBack"
$registryPath4 = "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\empty"
$dockIndicator = (Get-ItemProperty -Path $registryPath1 -Name "DockRunningIndicator1").DockRunningIndicator1
$themeStyle = (Get-ItemProperty -Path $registryPath0 -Name "NeXuSThemeName").NeXuSThemeName
$orbBitmap = (Get-ItemProperty -Path $registryPath3 -Name "OrbBitmap").OrbBitmap
$dockTrashEmptyIcon = (Get-ItemProperty -Path $registryPath0 -Name "TrashEmptyIcon").TrashEmptyIcon
$dockTrashFullIcon = (Get-ItemProperty -Path $registryPath0 -Name "TrashFullIcon").TrashFullIcon
switch ($args[0])
{
	'-dark' {
		$mode 					= 'Dark'
		$UIDarkMode 			= '1'
		$DockLabelColor1 		= '15658734'
		$DockLabelBackColor1 	= '2563870'
		$theme 					= $themeStyle -replace 'Light', 'Dark'
		$orbBitmap 				= $orbBitmap -replace 'black', 'white'
		$dockIndicator 			= $dockIndicator -replace 'Light', 'Dark'
		$dockTrashEmptyIcon 	= $dockTrashEmptyIcon -replace 'Light', 'Dark'
		$dockTrashFullIcon 		= $dockTrashFullIcon -replace 'Light', 'Dark'
		$contextMenuStyle 		= 'True'
	}
	'-light' {
		$mode 					= 'Light' 
		$UIDarkMode 			= '3'
		$DockLabelColor1 		= '1644825'
		$DockLabelBackColor1 	= '16119283'
		$theme 					= $themeStyle -replace 'Dark', 'Light'
		$orbBitmap 				= $orbBitmap -replace 'white', 'black'
		$dockIndicator 			= $dockIndicator -replace 'Dark', 'Light'
		$dockTrashEmptyIcon 	= $dockTrashEmptyIcon -replace 'Dark', 'Light'
		$dockTrashFullIcon 		= $dockTrashFullIcon -replace 'Dark', 'Light'
		$contextMenuStyle 		= 'False'
	}
}
if (Test-Path "C:\Program Files (x86)\Winstep\Nexus.exe") {
	$registry1Properties = Get-ItemProperty -Path $registryPath1
	$storeIcon = 'C:\ProgramData\WinStep\Icons\store'
	$storeIcon = $registry1Properties.PSObject.Properties |
		Where-Object { $_.Value -like "$storeIcon*" } |
		Select-Object -ExpandProperty Name

	Set-ItemProperty -Path $registryPath0 -Name "BitmapsFolder" -Value "C:\ProgramData\WinStep\Themes\$theme\"
	Set-ItemProperty -Path $registryPath0 -Name "GlobalBitmapFolder" -Value "C:\ProgramData\WinStep\Themes\$theme\"
	Set-ItemProperty -Path $registryPath0 -Name "NeXuSBitmapFolder" -Value "C:\ProgramData\WinStep\Themes\$theme\"
	Set-ItemProperty -Path $registryPath0 -Name "NeXuSThemeName" -Value $theme
	Set-ItemProperty -Path $registryPath0 -Name "NeXuSImage3" -Value "C:\ProgramData\WinStep\Themes\$theme\NxBack.png"
	Set-ItemProperty -Path $registryPath0 -Name "ClockBitmapFolder" -Value "C:\ProgramData\WinStep\Themes\$theme\"
	Set-ItemProperty -Path $registryPath0 -Name "TrashBitmapFolder" -Value "C:\ProgramData\WinStep\Themes\$theme\"
	Set-ItemProperty -Path $registryPath0 -Name "CPUBitmapFolder" -Value "C:\ProgramData\WinStep\Themes\$theme\"
	Set-ItemProperty -Path $registryPath0 -Name "POP3BitmapFolder" -Value "C:\ProgramData\WinStep\Themes\$theme\"
	Set-ItemProperty -Path $registryPath0 -Name "METARBitmapFolder" -Value "C:\ProgramData\WinStep\Themes\$theme\"
	Set-ItemProperty -Path $registryPath0 -Name "NetBitmapFolder" -Value "C:\ProgramData\WinStep\Themes\$theme\"
	Set-ItemProperty -Path $registryPath0 -Name "RAMBitmapFolder" -Value "C:\ProgramData\WinStep\Themes\$theme\"
	Set-ItemProperty -Path $registryPath0 -Name "WANDABitmapFolder" -Value "C:\ProgramData\WinStep\Themes\$theme\"
	Set-ItemProperty -Path $registryPath1 -Name "DockRunningIndicator1" -Value $dockIndicator
	Set-ItemProperty -Path $registryPath0 -Name "TrashEmptyIcon" -Value $dockTrashEmptyIcon
	Set-ItemProperty -Path $registryPath0 -Name "TrashFullIcon" -Value $dockTrashFullIcon
	Set-ItemProperty -Path $registryPath1 -Name "DockBitmapFolder1" -Value "C:\ProgramData\WinStep\Themes\$theme\"
	Set-ItemProperty -Path $registryPath1 -Name "DockBack3Image1" -Value "C:\ProgramData\WinStep\Themes\$theme\NxBack.png"
	Set-ItemProperty -Path $registryPath1 -Name "DockLabelColor1" -Value $DockLabelColor1
	Set-ItemProperty -Path $registryPath1 -Name "DockLabelBackColor1" -Value $DockLabelBackColor1
	Set-ItemProperty -Path $registryPath1 -Name "DockRunningIndicator1" -Value $dockIndicator
	if ($storeIcon) { Set-ItemProperty -Path $registryPath1 -Name $storeIcon -Value "C:\ProgramData\WinStep\Icons\store_$mode.ico" }
	Set-ItemProperty -Path $registryPath2 -Name "TaskIcon2" -Value "C:\ProgramData\WinStep\Icons\store_$mode.ico"
	Set-ItemProperty -Path $registryPath2 -Name "UIDarkMode" -Value $UIDarkMode
	Set-ItemProperty -Path $registryPath2 -Name "Windows10Style" -Value $contextMenuStyle
}

Set-ItemProperty -Path $registryPath3 -Name "OrbBitmap" -Value $orbBitmap
Set-ItemProperty -Path $registryPath4 -Name "Icon" -Value $dockTrashEmptyIcon
Start-Sleep 2
Start-Process explorer
if (Test-Path "C:\Program Files (x86)\Winstep\Nexus.exe") {
	try { Start-Process "C:\Program Files (x86)\Winstep\Nexus.exe" } catch {}
}
Start-Sleep 2
#EOF