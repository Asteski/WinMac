param
(
	[Parameter(Mandatory=$true)]
	[string]
	$mode,
	[Parameter(Mandatory=$false)]
	[string]
	$mode2
)
taskkill /IM explorer.exe /F > $null 2>&1
taskkill /IM nexus.exe /F > $null 2>&1
# $ErrorActionPreference = 'SilentlyContinue'
$registryPath0 = 'HKCU:\Software\WinSTEP2000\NeXuS'
$registryPath1 = 'HKCU:\Software\WinSTEP2000\NeXuS\Docks'
$registryPath2 = 'HKCU:\Software\WinSTEP2000\Shared'
$registryPath3 = 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon'
$registryPath4 = 'HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\empty'
$registryPath5 = 'HKCU:\Software\StartIsBack'
$themeStyle = (Get-ItemProperty -Path $registryPath0 -Name 'GenThemeName').GenThemeName
$orbBitmap = (Get-ItemProperty -Path 'HKCU:\Software\StartIsBack' -Name 'OrbBitmap').OrbBitmap
$dockRunningIndicator = (Get-ItemProperty -Path $registryPath1 -Name 'DockRunningIndicator1').DockRunningIndicator1

if ($mode -eq 'Light') {
	$OSMode 				= 1
	$UIDarkMode 			= '3'
	$DockLabelColor1 		= '1644825'
	$DockLabelBackColor1 	= '16119283'
	$theme 					= $themeStyle -replace 'Dark', 'Light'
	$orbBitmap 				= $orbBitmap -replace 'white', 'black'
	$dockRunningIndicator 	= $dockRunningIndicator -replace 'Dark', 'Light'
	$recycleBinEmptyIcon 	= '%SystemRoot%\System32\imageres.dll,-1015'
	$recycleBinFullIcon 	= '%SystemRoot%\System32\imageres.dll,-1017'
}
elseif ($mode -eq 'Dark') {
	$OSMode 				= 0
	$UIDarkMode 			= '1'
	$DockLabelColor1 		= '15658734'
	$DockLabelBackColor1 	= '2563870'
	$theme 					= $themeStyle -replace 'Light', 'Dark'
	$dockRunningIndicator 	= $dockRunningIndicator -replace 'Light', 'Dark'
	$orbBitmap 				= $orbBitmap -replace 'black', 'white'
	$recycleBinEmptyIcon 	= '%SystemRoot%\System32\imageres.dll,-55'
	$recycleBinFullIcon 	= '%SystemRoot%\System32\imageres.dll,-54'
}

if ($mode2 -eq 'NoApp') {
	Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'SystemUsesLightTheme' -Type DWord -Value $OSMode
}
else {
	Start-Process "$env:WINDIR\Resources\Themes\WinMac_$mode.theme"
	while ($true) {
		if (Get-Process -Name 'SystemSettings') {
			Stop-Process -Name 'SystemSettings' -Force
			break
		}
		Start-Sleep -Milliseconds 100
	}
}
Set-ItemProperty -Path $registryPath0 -Name "GenThemeName" -Value $theme
Set-ItemProperty -Path $registryPath0 -Name "BitmapsFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\"
Set-ItemProperty -Path $registryPath0 -Name "GlobalBitmafpFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\"
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
Set-ItemProperty -Path $registryPath0 -Name "TrashEmptyIcon" -Value "C:\Users\Public\Documents\Winstep\Icons\recycle_bin_empty_$mode.ico"
Set-ItemProperty -Path $registryPath0 -Name "TrashFullIcon" -Value "C:\Users\Public\Documents\Winstep\Icons\recycle_bin_full_$mode.ico"
Set-ItemProperty -Path $registryPath0 -Name "NeXuSImage27" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\NxSep.png"
Set-ItemProperty -Path $registryPath0 -Name "DockBack27Image1" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\NxSep.png"
Set-ItemProperty -Path $registryPath1 -Name "DockBitmapFolder1" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\"
Set-ItemProperty -Path $registryPath1 -Name "DockBack3Image1" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\NxBack.png"
Set-ItemProperty -Path $registryPath1 -Name "DockBack27Image1" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\NxSep.png"
Set-ItemProperty -Path $registryPath1 -Name "DockLabelColor1" -Value $DockLabelColor1
Set-ItemProperty -Path $registryPath1 -Name "DockLabelBackColor1" -Value $DockLabelBackColor1
Set-ItemProperty -Path $registryPath1 -Name "DockBack27Image1" -Value $dockRunningIndicator
Set-ItemProperty -Path $registryPath1 -Name "DockRunningIndicator1" -Value $dockRunningIndicator
Set-ItemProperty -Path $registryPath2 -Name "UIDarkMode" -Value $UIDarkMode
Set-ItemProperty -Path $registryPath2 -Name "TaskIcon2" -Value "C:\\Users\\Public\\Documents\\WinStep\\Icons\\store_$mode.ico"
Set-ItemProperty -Path $registryPath3 -Name '(default)' -Value $recycleBinFullIcon
Set-ItemProperty -Path $registryPath3 -Name 'empty' -Value $recycleBinEmptyIcon
Set-ItemProperty -Path $registryPath3 -Name 'full' -Value $recycleBinFullIcon
Set-ItemProperty -Path $registryPath4 -Name 'Icon' -Value $recycleBinEmptyIcon
Set-ItemProperty -Path $registryPath5 -Name 'OrbBitmap' -Value $orbBitmap

Start-Process explorer
try { Start-Process 'C:\Program Files (x86)\Winstep\Nexus.exe' } catch {}
start-sleep 5