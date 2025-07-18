param
(
	[Parameter(Mandatory=$true)]
	[string]
	$mode,
	[Parameter(Mandatory=$false)]
	[string]
	$mode2
)
$ErrorActionPreference = 'SilentlyContinue'
$WarningPreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'
taskkill /IM explorer.exe /F > $null 2>&1
taskkill /IM nexus.exe /F > $null 2>&1
$registryPath0 = "HKCU:\Software\WinSTEP2000\NeXuS"
$registryPath1 = "HKCU:\Software\WinSTEP2000\NeXuS\Docks"
$registryPath2 = "HKCU:\Software\WinSTEP2000\Shared"
$registryPath3 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon"
$registryPath4 = "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\empty"
$registryPath5 = "HKCU:\Software\StartIsBack"
$dockRunningIndicator = (Get-ItemProperty -Path $registryPath1 -Name "DockRunningIndicator1").DockRunningIndicator1
$themeStyle = (Get-ItemProperty -Path $registryPath0 -Name "GenThemeName").GenThemeName
$orbBitmap = (Get-ItemProperty -Path $registryPath5 -Name "OrbBitmap").OrbBitmap
$recycleBinEmptyIcon = (Get-ItemProperty -Path $registryPath0 -Name "TrashEmptyIcon").TrashEmptyIcon
$recycleBinFullIcon = (Get-ItemProperty -Path $registryPath0 -Name "TrashFullIcon").TrashFullIcon
if ($mode -eq 'Dark')
{
	$OSMode 				= 0
	$UIDarkMode 			= '1'
	$DockLabelColor1 		= '15658734'
	$DockLabelBackColor1 	= '2563870'
	$theme 					= $themeStyle -replace 'Light', 'Dark'
	$orbBitmap 				= $orbBitmap -replace 'black', 'white'
	$dockRunningIndicator 	= $dockRunningIndicator -replace 'Light', 'Dark'
	$recycleBinEmptyIcon 	= $recycleBinEmptyIcon -replace 'Light', 'Dark'
	$recycleBinFullIcon 	= $recycleBinFullIcon -replace 'Light', 'Dark'
	$contextMenuStyle 		= 'False'
	$cursorTheme 			= 'Windows Default'
	$cursorMappings 		= @{
		Arrow       		= 'C:\WINDOWS\cursors\aero_arrow.cur'
		Help        		= 'C:\WINDOWS\cursors\aero_helpsel.cur'
		Hand        		= 'C:\WINDOWS\cursors\aero_link.cur'
		AppStarting 		= 'C:\WINDOWS\cursors\aero_working.ani'
		Wait        		= 'C:\WINDOWS\cursors\aero_busy.ani'
		NWPen       		= 'C:\WINDOWS\cursors\aero_pen.cur'
		No          		= 'C:\WINDOWS\cursors\aero_unavail.cur'
		SizeNS      		= 'C:\WINDOWS\cursors\aero_ns.cur'
		SizeWE      		= 'C:\WINDOWS\cursors\aero_ew.cur'
		SizeNWSE    		= 'C:\WINDOWS\cursors\aero_nwse.cur'
		SizeNESW    		= 'C:\WINDOWS\cursors\aero_nesw.cur'
		SizeAll     		= 'C:\WINDOWS\cursors\aero_move.cur'
		UpArrow     		= 'C:\WINDOWS\cursors\aero_up.cur'
		Pin         		= 'C:\WINDOWS\cursors\aero_pin.cur'
		Person      		= 'C:\WINDOWS\cursors\aero_person.cur'
	}
}
if ($mode -eq 'Light')
{
	$OSMode 				= 1
	$UIDarkMode 			= '3'
	$DockLabelColor1 		= '1644825'
	$DockLabelBackColor1 	= '16119283'
	$theme 					= $themeStyle -replace 'Dark', 'Light'
	$orbBitmap 				= $orbBitmap -replace 'white', 'black'
	$dockRunningIndicator 	= $dockRunningIndicator -replace 'Dark', 'Light'
	$recycleBinEmptyIcon 	= $recycleBinEmptyIcon -replace 'Dark', 'Light'
	$recycleBinFullIcon 	= $recycleBinFullIcon -replace 'Dark', 'Light'
	$cursorTheme 			= 'Windows Black'
	$cursorMappings 		= @{
		Arrow       		= 'C:\WINDOWS\cursors\aero_black_arrow.cur'
		Help        		= 'C:\WINDOWS\cursors\aero_black_helpsel.cur'
		Hand        		= 'C:\WINDOWS\cursors\aero_black_link.cur'
		AppStarting 		= 'C:\WINDOWS\cursors\aero_black_working.ani'
		Wait        		= 'C:\WINDOWS\cursors\aero_black_busy.ani'
		NWPen       		= 'C:\WINDOWS\cursors\aero_black_pen.cur'
		No          		= 'C:\WINDOWS\cursors\aero_black_unavail.cur'
		SizeNS      		= 'C:\WINDOWS\cursors\aero_black_ns.cur'
		SizeWE      		= 'C:\WINDOWS\cursors\aero_black_ew.cur'
		SizeNWSE    		= 'C:\WINDOWS\cursors\aero_black_nwse.cur'
		SizeNESW    		= 'C:\WINDOWS\cursors\aero_black_nesw.cur'
		SizeAll     		= 'C:\WINDOWS\cursors\aero_black_move.cur'
		UpArrow     		= 'C:\WINDOWS\cursors\aero_black_up.cur'
		Pin         		= 'C:\WINDOWS\cursors\aero_black_pin.cur'
		Person      		= 'C:\WINDOWS\cursors\aero_black_person.cur'
	}
}
if ($mode2 -eq 'NoApp') {
	Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'SystemUsesLightTheme' -Type DWord -Value $OSMode
}
else {
	if ($mode -eq 'Light') {
		Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "ColorPrevalence" -Value 0 												#? comment out this line when using default WinMac theme
		Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "AccentColorInactive" 												#? comment out this line when using default WinMac theme
		Start-Process "$env:WINDIR\Resources\Themes\WinMac_light.theme"
	}
	else {
		Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "ColorPrevalence" -Value 1 												 #? comment out this line when using default WinMac theme
		New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "AccentColorInactive" -PropertyType DWord -Value 0xFF444444 > $null 2>&1 #? comment out this line when using default WinMac theme
		Start-Process "$env:WINDIR\Resources\Themes\darkrectified.theme" 																			 #? comment out this line when using default WinMac theme
		# Start-Process "$env:WINDIR\Resources\Themes\WinMac_dark.theme" 																			 #* uncomment this line to use default WinMac dark theme
	}
}

Set-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name '(default)' -Value $cursorTheme
foreach ($cursorName in $cursorMappings.Keys) {
	$cursorPath = $cursorMappings[$cursorName]
	Set-ItemProperty -Path "HKCU:\Control Panel\Cursors" -Name $cursorName -Value $cursorPath
}
Add-Type @"
using System;
using System.Runtime.InteropServices;
public class NativeMethods {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SystemParametersInfo(int uAction, int uParam, string lpvParam, int fuWinIni);
}
"@
[NativeMethods]::SystemParametersInfo(0x57, 0, $null, 0x03) > $null 2>&1

$registry1Properties = Get-ItemProperty -Path $registryPath1
$storeIcon = 'C:\Users\Public\Documents\Winstep\Icons\store'
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
Set-ItemProperty -Path $registryPath0 -Name "TrashEmptyIcon" -Value $recycleBinEmptyIcon
Set-ItemProperty -Path $registryPath0 -Name "TrashFullIcon" -Value $recycleBinFullIcon
Set-ItemProperty -Path $registryPath1 -Name "DockBitmapFolder1" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\"
Set-ItemProperty -Path $registryPath1 -Name "DockBack3Image1" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\NxBack.png"
Set-ItemProperty -Path $registryPath1 -Name "DockLabelColor1" -Value $DockLabelColor1
Set-ItemProperty -Path $registryPath1 -Name "DockLabelBackColor1" -Value $DockLabelBackColor1
Set-ItemProperty -Path $registryPath1 -Name "DockRunningIndicator1" -Value $dockRunningIndicator
if ($storeIcon)   { Set-ItemProperty -Path $registryPath1 -Name $storeIcon -Value "C:\Users\Public\Documents\Winstep\Icons\store_$mode.ico" }
Set-ItemProperty -Path $registryPath2 -Name "UIDarkMode" -Value $UIDarkMode
Set-ItemProperty -Path $registryPath2 -Name "Windows10Style" -Value $contextMenuStyle
Set-ItemProperty -Path $registryPath3 -Name "(default)" -Value $recycleBinEmptyIcon
Set-ItemProperty -Path $registryPath3 -Name "empty" -Value $recycleBinEmptyIcon
Set-ItemProperty -Path $registryPath3 -Name "full" -Value $recycleBinFullIcon
Set-ItemProperty -Path $registryPath4 -Name "Icon" -Value $recycleBinEmptyIcon
Set-ItemProperty -Path $registryPath5 -Name "OrbBitmap" -Value $orbBitmap
Start-Process explorer
try { Start-Process "C:\Program Files (x86)\Winstep\Nexus.exe" } catch {}