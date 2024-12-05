param
(
	[Parameter(Mandatory=$true)]
	[string]
	$mode,
	[Parameter(Mandatory=$false)]
	[string]
	$mode2
)
if ($mode -eq 'Dark')
{
	$UIDarkMode = '1'
	$DockLabelColor1 = '15658734'
	$DockLabelBackColor1 = '2563870'
}
if ($mode -eq 'Light')
{
	$UIDarkMode = '3'
	$DockLabelColor1 = '1644825'
	$DockLabelBackColor1 = '16119283'
}
taskkill /IM explorer.exe /F > $null 2>&1
taskkill /IM nexus.exe /F > $null 2>&1
$registryPath0 = "HKCU:\Software\WinSTEP2000\NeXuS"
$registryPath1 = "HKCU:\Software\WinSTEP2000\NeXuS\Docks"
$registryPath2 = "HKCU:\Software\WinSTEP2000\Shared"
try {
	$dockRunningIndicator = (Get-ItemProperty -Path $registryPath1 -Name "DockRunningIndicator1").DockRunningIndicator1
	$themeStyle = (Get-ItemProperty -Path $registryPath0 -Name "GenThemeName").GenThemeName
}
catch {
	echo 
}
if ($mode -eq 'Light') {
	$theme = $themeStyle -replace 'Dark', 'Light'
	$dockRunningIndicator = $dockRunningIndicator -replace 'Dark', 'Light'
	try {
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
		Set-ItemProperty -Path $registryPath0 -Name "TrashEmptyIcon" -Value "C:\Users\Public\Documents\Winstep\Icons\recycle_bin_empty.ico"
		Set-ItemProperty -Path $registryPath0 -Name "TrashFullIcon" -Value "C:\Users\Public\Documents\Winstep\Icons\recycle_bin_full.ico"
		Set-ItemProperty -Path "HKCU:\Software\StartIsBack" -Name "OrbBitmap" -Value "black-rounded.svg"
		Set-ItemProperty -Path $registryPath1 -Name "DockBitmapFolder1" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\"
		Set-ItemProperty -Path $registryPath1 -Name "DockBack3Image1" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\NxBack.png"
		Set-ItemProperty -Path $registryPath1 -Name "DockLabelColor1" -Value $DockLabelColor1
		Set-ItemProperty -Path $registryPath1 -Name "DockLabelBackColor1" -Value $DockLabelBackColor1
		Set-ItemProperty -Path $registryPath2 -Name "UIDarkMode" -Value $UIDarkMode
		Set-ItemProperty -Path $registryPath1 -Name "DockRunningIndicator1" -Value $dockRunningIndicator
		Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Type DWord -Value 1
		if ($mode2 -eq 'App') {
			Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Type DWord -Value 1
		}
	} catch {}
}
if ($mode -eq 'Dark') {
	$theme = $themeStyle -replace 'Light', 'Dark'
	$dockRunningIndicator = $dockRunningIndicator -replace 'Light', 'Dark'
	try {
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
		Set-ItemProperty -Path $registryPath0 -Name "TrashEmptyIcon" -Value "C:\Users\Public\Documents\Winstep\Icons\recycle_bin_empty_dark.ico"
		Set-ItemProperty -Path $registryPath0 -Name "TrashFullIcon" -Value "C:\Users\Public\Documents\Winstep\Icons\recycle_bin_full_dark.ico"
		Set-ItemProperty -Path "HKCU:\Software\StartIsBack" -Name "OrbBitmap" -Value "white-rounded.svg"
		Set-ItemProperty -Path $registryPath1 -Name "DockBitmapFolder1" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\"
		Set-ItemProperty -Path $registryPath1 -Name "DockBack3Image1" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\NxBack.png"
		Set-ItemProperty -Path $registryPath1 -Name "DockLabelColor1" -Value $DockLabelColor1
		Set-ItemProperty -Path $registryPath1 -Name "DockLabelBackColor1" -Value $DockLabelBackColor1
		Set-ItemProperty -Path $registryPath2 -Name "UIDarkMode" -Value $UIDarkMode
		Set-ItemProperty -Path $registryPath1 -Name "DockRunningIndicator1" -Value $dockRunningIndicator
		Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Type DWord -Value 0
		if ($mode2 -eq 'App') {
			Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Type DWord -Value 0
		}
	} catch {}
}
try {
	Start-Process explorer
	Start-Process "C:\Program Filesaa (x86)\Winstep\Nexus.exe"
} catch {}