param
(
	[Parameter(Mandatory=$true)]
	[string]
	$mode,
	[Parameter(Mandatory=$false)]
	[string]
	$mode2
)
Write-Host "Switching to $mode mode..." -ForegroundColor Green
$ErrorActionPreference = 'SilentlyContinue'
$WarningPreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'
Write-Host "Shutting down Windows Explorer..." -ForegroundColor Yellow
taskkill /IM explorer.exe /F > $null 2>&1
if (Test-Path "C:\Program Files (x86)\Winstep\Nexus.exe") {
	Write-Host "Shutting down Nexus Dock..." -ForegroundColor Yellow
	taskkill /IM nexus.exe /F > $null 2>&1
}
$registryPath0 = "HKCU:\Software\WinSTEP2000\NeXuS"
$registryPath1 = "HKCU:\Software\WinSTEP2000\NeXuS\Docks"
$registryPath2 = "HKCU:\Software\WinSTEP2000\Shared"
$registryPath3 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon"
$registryPath4 = "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\empty"
$registryPath5 = "HKCU:\Software\StartIsBack"
$dockRunningIndicator = (Get-ItemProperty -Path $registryPath1 -Name "DockRunningIndicator1").DockRunningIndicator1
$themeStyle = (Get-ItemProperty -Path $registryPath0 -Name "GenThemeName").GenThemeName
$orbBitmap = (Get-ItemProperty -Path $registryPath5 -Name "OrbBitmap").OrbBitmap
$dockTrashEmptyIcon = (Get-ItemProperty -Path $registryPath0 -Name "TrashEmptyIcon").TrashEmptyIcon
$dockTrashFullIcon = (Get-ItemProperty -Path $registryPath0 -Name "TrashFullIcon").TrashFullIcon
if ($mode -eq 'Dark')
{
	$OSMode 				= 0
	$UIDarkMode 			= '1'
	$DockLabelColor1 		= '15658734'
	$DockLabelBackColor1 	= '2563870'
	$cursorName 			= 'Windows Modern v2 - Aero White - (x1)'
	$cursorColor 			= 'white'
	$theme 					= $themeStyle -replace 'Light', 'Dark'
	$orbBitmap 				= $orbBitmap -replace 'black', 'white'
	$dockRunningIndicator 	= $dockRunningIndicator -replace 'Light', 'Dark'
	$dockTrashEmptyIcon 	= $dockTrashEmptyIcon -replace 'Light', 'Dark'
	$dockTrashFullIcon 		= $dockTrashFullIcon -replace 'Light', 'Dark'
	$recycleBinEmptyIcon 	= '%SystemRoot%\System32\imageres.dll,-55'
	$recycleBinFullIcon 	= '%SystemRoot%\System32\imageres.dll,-54'
	$contextMenuStyle 		= 'True'
}
if ($mode -eq 'Light')
{
	$OSMode 				= 1
	$UIDarkMode 			= '3'
	$DockLabelColor1 		= '1644825'
	$DockLabelBackColor1 	= '16119283'
	$cursorName 			= 'Windows Modern v2 - Aero Black - (x1)'
	$cursorColor 			= 'black'
	$theme 					= $themeStyle -replace 'Dark', 'Light'
	$orbBitmap 				= $orbBitmap -replace 'white', 'black'
	$dockRunningIndicator 	= $dockRunningIndicator -replace 'Dark', 'Light'
	$dockTrashEmptyIcon 	= $dockTrashEmptyIcon -replace 'Dark', 'Light'
	$dockTrashFullIcon 		= $dockTrashFullIcon -replace 'Dark', 'Light'
	$recycleBinEmptyIcon 	= '%SystemRoot%\System32\imageres.dll,-1015'
	$recycleBinFullIcon 	= '%SystemRoot%\System32\imageres.dll,-1017'
	$contextMenuStyle 		= 'False'
}
Write-Host "Changing Windows theme..." -ForegroundColor Yellow
if ($mode2 -eq 'NoApp') {
	Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'SystemUsesLightTheme' -Type DWord -Value $OSMode
}
else {
	#! Comment line 68 and uncomment line 69 to apply Rectify11 themes. In order to force dark titlebars with darkrectified theme,
	#! enable 'Show accent colour on title bars and window borders' in Settings > Personalization > Colours, or use application like MicaForEveryone
	Start-Process "$env:WINDIR\Resources\Themes\WinMac_$($mode).theme"
	#Start-Process "$env:WINDIR\Resources\Themes\$($mode)rectified.theme"
}

if (Test-Path "C:\Program Files (x86)\Winstep\Nexus.exe") {
	Write-Host "Changing Nexus Dock theme..." -ForegroundColor Yellow

	$registry1Properties = Get-ItemProperty -Path $registryPath1
	$storeIcon = 'C:\Users\Public\Documents\WinStep\Icons\store'
	$storeIcon = $registry1Properties.PSObject.Properties |
		Where-Object { $_.Value -like "$storeIcon*" } |
		Select-Object -ExpandProperty Name

	Set-ItemProperty -Path $registryPath0 -Name "GenThemeName" -Value $theme
	Set-ItemProperty -Path $registryPath0 -Name "BitmapsFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\"
	Set-ItemProperty -Path $registryPath0 -Name "GlobalBitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\"
	Set-ItemProperty -Path $registryPath0 -Name "NeXuSBitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\"
	Set-ItemProperty -Path $registryPath0 -Name "NeXuSThemeName" -Value $theme
	Set-ItemProperty -Path $registryPath0 -Name "NeXuSImage3" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\NxBack.png"
	Set-ItemProperty -Path $registryPath0 -Name "ClockBitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\"
	Set-ItemProperty -Path $registryPath0 -Name "TrashBitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\"
	Set-ItemProperty -Path $registryPath0 -Name "CPUBitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\"
	Set-ItemProperty -Path $registryPath0 -Name "POP3BitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\"
	Set-ItemProperty -Path $registryPath0 -Name "METARBitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\"
	Set-ItemProperty -Path $registryPath0 -Name "NetBitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\"
	Set-ItemProperty -Path $registryPath0 -Name "RAMBitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\"
	Set-ItemProperty -Path $registryPath0 -Name "WANDABitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\"
	Set-ItemProperty -Path $registryPath0 -Name "TrashEmptyIcon" -Value $dockTrashEmptyIcon
	Set-ItemProperty -Path $registryPath0 -Name "TrashFullIcon" -Value $dockTrashFullIcon
	Set-ItemProperty -Path $registryPath1 -Name "DockBitmapFolder1" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\"
	Set-ItemProperty -Path $registryPath1 -Name "DockBack3Image1" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\NxBack.png"
	Set-ItemProperty -Path $registryPath1 -Name "DockLabelColor1" -Value $DockLabelColor1
	Set-ItemProperty -Path $registryPath1 -Name "DockLabelBackColor1" -Value $DockLabelBackColor1
	Set-ItemProperty -Path $registryPath1 -Name "DockRunningIndicator1" -Value $dockRunningIndicator
	if ($storeIcon) { Set-ItemProperty -Path $registryPath1 -Name $storeIcon -Value "C:\Users\Public\Documents\WinStep\Icons\store_$mode.ico" }
	Set-ItemProperty -Path $registryPath2 -Name "TaskIcon2" -Value "C:\Users\Public\Documents\WinStep\Icons\store_$mode.ico"
	Set-ItemProperty -Path $registryPath2 -Name "UIDarkMode" -Value $UIDarkMode
	Set-ItemProperty -Path $registryPath2 -Name "Windows10Style" -Value $contextMenuStyle
}

Write-Host "Changing Recycle Bin icons and Start Orb color..." -ForegroundColor Yellow

Set-ItemProperty -Path $registryPath3 -Name "(default)" -Value $recycleBinEmptyIcon
Set-ItemProperty -Path $registryPath3 -Name "empty" -Value $recycleBinEmptyIcon
Set-ItemProperty -Path $registryPath3 -Name "full" -Value $recycleBinFullIcon
Set-ItemProperty -Path $registryPath4 -Name "Icon" -Value $recycleBinEmptyIcon
Set-ItemProperty -Path $registryPath5 -Name "OrbBitmap" -Value $orbBitmap

Start-Sleep 2
Write-Host "Changing Cursor color..." -ForegroundColor Yellow

$RegConnect = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"CurrentUser","$env:COMPUTERNAME")
$RegCursors = $RegConnect.OpenSubKey("Control Panel\Cursors",$true)
$RegCursors.SetValue("",$cursorName)
$RegCursors.SetValue("AppStarting","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\working-in-background_$cursorColor.ani")
$RegCursors.SetValue("Arrow","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\normal-select_$cursorColor.cur")
$RegCursors.SetValue("Crosshair","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\precision-select_default.cur")
$RegCursors.SetValue("Hand","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\link-select_$cursorColor.cur")
$RegCursors.SetValue("Help","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\help-select_$cursorColor.cur")
$RegCursors.SetValue("IBeam","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\text-select_$cursorColor.cur")
$RegCursors.SetValue("No","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\unavailable_$cursorColor.cur")
$RegCursors.SetValue("NWPen","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\handwriting_$cursorColor.cur")
$RegCursors.SetValue("SizeAll","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\move_$cursorColor.cur")
$RegCursors.SetValue("SizeNESW","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\diagonal-resize-2_$cursorColor.cur")
$RegCursors.SetValue("SizeNS","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\vertical-resize_$cursorColor.cur")
$RegCursors.SetValue("SizeNWSE","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\diagonal-resize-1_$cursorColor.cur")
$RegCursors.SetValue("SizeWE","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\horizontal-resize_$cursorColor.cur")
$RegCursors.SetValue("UpArrow","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\alternate-select_$cursorColor.cur")
$RegCursors.SetValue("Wait","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\busy.ani")
$RegCursors.SetValue("Pin","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\link-select_$cursorColor.cur")
$RegCursors.SetValue("Person","%SYSTEMROOT%\Cursors\windows-modern-v2\x1\link-select_$cursorColor.cur")
$RegCursors.Close()
$RegConnect.Close()
Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;
public class User32 {
    [DllImport("user32.dll")]
    public static extern IntPtr SystemParametersInfo(int uAction, int uParam, IntPtr lpvParam, int fuWinIni);
}
"@
[User32]::SystemParametersInfo(0x0057, 0, [IntPtr]::Zero, 0x0001) > $null 2>&1
Write-Host "Starting Explorer..." -ForegroundColor Yellow
Start-Process explorer
if (Test-Path "C:\Program Files (x86)\Winstep\Nexus.exe") {
	Write-Host "Changing Nexus Dock theme..." -ForegroundColor Yellow
	try { Start-Process "C:\Program Files (x86)\Winstep\Nexus.exe" } catch {}
}
Write-Host "Theme switch completed!" -ForegroundColor Green
Start-Sleep 2
#EOF