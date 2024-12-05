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
# Stop-Process -Name TopNotify -force
taskkill /IM explorer.exe /F
taskkill /IM nexus.exe /F
$registryPath0 = "HKCU:\Software\WinSTEP2000\NeXuS"
$registryPath1 = "HKCU:\Software\WinSTEP2000\NeXuS\Docks"
$registryPath2 = "HKCU:\Software\WinSTEP2000\Shared"
$dockRunningIndicator = (Get-ItemProperty -Path $registryPath1 -Name "DockRunningIndicator1").DockRunningIndicator1
$themeStyle = (Get-ItemProperty -Path $registryPath0 -Name "GenThemeName").GenThemeName
if ($mode -eq 'Light') {
	$theme = $themeStyle -replace 'Dark', 'Light'
	$dockRunningIndicator = $dockRunningIndicator -replace 'Dark', 'Light'
    $curDestFolder = "C:\Windows\Cursors"
    $RegConnect = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"CurrentUser","$env:COMPUTERNAME")
    $RegCursors = $RegConnect.OpenSubKey("Control Panel\Cursors",$true)
    $RegCursors.SetValue("","Windows Black")
    $RegCursors.SetValue("AppStarting","$curDestFolder\aero_black_working.ani")
    $RegCursors.SetValue("Arrow","$curDestFolder\aero_black_arrow.cur")
    $RegCursors.SetValue("Crosshair","$curDestFolder\aero_black_cross.cur")
    $RegCursors.SetValue("Hand","$curDestFolder\aero_black_link.cur")
    $RegCursors.SetValue("Help","$curDestFolder\aero_black_helpsel.cur")
    $RegCursors.SetValue("IBeam","$curDestFolder\aero_black_beam.cur")
    $RegCursors.SetValue("No","$curDestFolder\aero_black_unavail.cur")
    $RegCursors.SetValue("NWPen","$curDestFolder\aero_black_pen.cur")
    $RegCursors.SetValue("SizeAll","$curDestFolder\aero_black_move.cur")
    $RegCursors.SetValue("SizeNESW","$curDestFolder\aero_black_nesw.cur")
    $RegCursors.SetValue("SizeNS","$curDestFolder\aero_black_ns.cur")
    $RegCursors.SetValue("SizeNWSE","$curDestFolder\aero_black_nwse.cur")
    $RegCursors.SetValue("SizeWE","$curDestFolder\aero_black_ew.cur")
    $RegCursors.SetValue("UpArrow","$curDestFolder\aero_black_up.cur")
    $RegCursors.SetValue("Wait","$curDestFolder\aero_black_busy.ani")
    $RegCursors.SetValue("Pin","$curDestFolder\aero_black_pin.cur")
    $RegCursors.SetValue("Person","$curDestFolder\aero_black_person.cur")
    $RegCursors.Close()
    $RegConnect.Close()
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
}
if ($mode -eq 'Dark') {
	$theme = $themeStyle -replace 'Light', 'Dark'
	$dockRunningIndicator = $dockRunningIndicator -replace 'Light', 'Dark'
    $curDestFolder = "C:\Windows\Cursors"
    $RegConnect = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"CurrentUser","$env:COMPUTERNAME")
    $RegCursors = $RegConnect.OpenSubKey("Control Panel\Cursors",$true)
    $RegCursors.SetValue("","Windows Aero")
    $RegCursors.SetValue("AppStarting","$curDestFolder\aero_working.ani")
    $RegCursors.SetValue("Arrow","$curDestFolder\aero_arrow.cur")
    $RegCursors.SetValue("Crosshair","$curDestFolder\aero_cross.cur")
    $RegCursors.SetValue("Hand","$curDestFolder\aero_link.cur")
    $RegCursors.SetValue("Help","$curDestFolder\aero_helpsel.cur")
    $RegCursors.SetValue("IBeam","$curDestFolder\aero_beam.cur")
    $RegCursors.SetValue("No","$curDestFolder\aero_unavail.cur")
    $RegCursors.SetValue("NWPen","$curDestFolder\aero_pen.cur")
    $RegCursors.SetValue("SizeAll","$curDestFolder\aero_move.cur")
    $RegCursors.SetValue("SizeNESW","$curDestFolder\aero_nesw.cur")
    $RegCursors.SetValue("SizeNS","$curDestFolder\aero_ns.cur")
    $RegCursors.SetValue("SizeNWSE","$curDestFolder\aero_nwse.cur")
    $RegCursors.SetValue("SizeWE","$curDestFolder\aero_ew.cur")
    $RegCursors.SetValue("UpArrow","$curDestFolder\aero_up.cur")
    $RegCursors.SetValue("Wait","$curDestFolder\aero_busy.ani")
    $RegCursors.SetValue("Pin","$curDestFolder\aero_pin.ani")
    $RegCursors.SetValue("Person","$curDestFolder\aero_person.ani")
    $RegCursors.Close()
    $RegConnect.Close()
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
}
Start-Process explorer
Start-Process "C:\Program Files (x86)\Winstep\Nexus.exe"