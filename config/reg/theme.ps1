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
$registryPath0 = "HKCU:\Software\WinSTEP2000\NeXuS"
$registryPath1 = "HKCU:\Software\WinSTEP2000\NeXuS\Docks"
$registryPath2 = "HKCU:\Software\WinSTEP2000\Shared"
$registryPath3 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon"
$registryPath4 = "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\empty"
$dockRunningIndicator = (Get-ItemProperty -Path $registryPath1 -Name "DockRunningIndicator1").DockRunningIndicator1  # -ErrorAction SilentlyContinue
$themeStyle = (Get-ItemProperty -Path $registryPath0 -Name "GenThemeName").GenThemeName  # -ErrorAction SilentlyContinue
$orbBitmap = (Get-ItemProperty -Path "HKCU:\Software\StartIsBack" -Name "OrbBitmap").OrbBitmap

if ($mode -eq 'Light') {
	$CursorMode 			= 'aero_black'
	$cursorName 			= 'Windows Black'
	$OSMode 				= 1
	$UIDarkMode 			= '3'
	$DockLabelColor 		= '1644825'
	$DockLabelBackColor 	= '16119283'
	$theme = $themeStyle -replace 'Dark', 'Light'
	$dockRunningIndicator = $dockRunningIndicator -replace 'Dark', 'Light'
	$orbBitmap = $orbBitmap -replace 'white', 'black'
	Set-ItemProperty -Path $registryPath3 -Name "(default)" -Value "%SystemRoot%\System32\imageres.dll,-1017"
	Set-ItemProperty -Path $registryPath3 -Name "empty" -Value "%SystemRoot%\System32\imageres.dll,-1015"
	Set-ItemProperty -Path $registryPath3 -Name "full" -Value "%SystemRoot%\System32\imageres.dll,-1017"
	Set-ItemProperty -Path $registryPath4 -Name "Icon" -Value "%SystemRoot%\System32\imageres.dll,-1015"
}
elseif ($mode -eq 'Dark') {
	$CursorMode 			= 'aero'
	$cursorName 			= 'Windows Default (system scheme)'
	$OSMode 				= 0
	$UIDarkMode 			= '1'
	$DockLabelColor 		= '15658734'
	$DockLabelBackColor 	= '2563870'
	$theme = $themeStyle -replace 'Light', 'Dark'
	$dockRunningIndicator = $dockRunningIndicator -replace 'Light', 'Dark'
	$orbBitmap = $orbBitmap -replace 'black', 'white'
	Set-ItemProperty -Path $registryPath3 -Name "(default)" -Value "%SystemRoot%\System32\imageres.dll,-54"
	Set-ItemProperty -Path $registryPath3 -Name "empty" -Value "%SystemRoot%\System32\imageres.dll,-55"
	Set-ItemProperty -Path $registryPath3 -Name "full" -Value "%SystemRoot%\System32\imageres.dll,-54"
	Set-ItemProperty -Path $registryPath4 -Name "Icon" -Value "%SystemRoot%\System32\imageres.dll,-55"
}

$RegConnect = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"CurrentUser","$env:COMPUTERNAME")
$RegCursors = $RegConnect.OpenSubKey("Control Panel\Cursors",$true)
$RegCursors.SetValue("",$cursorName)
$RegCursors.SetValue("AppStarting","C:\Windows\Cursors\$($CursorMode)_working.ani")
$RegCursors.SetValue("Arrow","C:\Windows\Cursors\$($CursorMode)_arrow.cur")
$RegCursors.SetValue("Crosshair","C:\Windows\Cursors\cross_r.cur")
$RegCursors.SetValue("Hand","C:\Windows\Cursors\$($CursorMode)_link.cur")
$RegCursors.SetValue("Help","C:\Windows\Cursors\$($CursorMode)_helpsel.cur")
$RegCursors.SetValue("IBeam","C:\Windows\Cursors\beam_r.cur")
$RegCursors.SetValue("No","C:\Windows\Cursors\$($CursorMode)_unavail.cur")
$RegCursors.SetValue("NWPen","C:\Windows\Cursors\$($CursorMode)_pen.cur")
$RegCursors.SetValue("SizeAll","C:\Windows\Cursors\$($CursorMode)_move.cur")
$RegCursors.SetValue("SizeNESW","C:\Windows\Cursors\$($CursorMode)_nesw.cur")
$RegCursors.SetValue("SizeNS","C:\Windows\Cursors\$($CursorMode)_ns.cur")
$RegCursors.SetValue("SizeNWSE","C:\Windows\Cursors\$($CursorMode)_nwse.cur")
$RegCursors.SetValue("SizeWE","C:\Windows\Cursors\$($CursorMode)_ew.cur")
$RegCursors.SetValue("UpArrow","C:\Windows\Cursors\$($CursorMode)_up.cur")
$RegCursors.SetValue("Wait","C:\Windows\Cursors\$($CursorMode)_busy.ani")
$RegCursors.SetValue("Pin","C:\Windows\Cursors\$($CursorMode)_pin.cur")
$RegCursors.SetValue("Person","C:\Windows\Cursors\$($CursorMode)_person.cur")
$RegCursors.Close()
$RegConnect.Close()
$CSharpSig = @'
[DllImport("user32.dll", EntryPoint = "SystemParametersInfo")]
public static extern bool SystemParametersInfo(
uint uiAction,
uint uiParam,
uint pvParam,
uint fWinIni);
'@
$CursorRefresh = Add-Type -MemberDefinition $CSharpSig -Name WinAPICall -Namespace SystemParamInfo –PassThru
$CursorRefresh::SystemParametersInfo(0x0057,0,$null,0) > $null 2>&1

Set-ItemProperty -Path "HKCU:\Software\StartIsBack" -Name "OrbBitmap" -Value $orbBitmap # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath0 -Name "GenThemeName" -Value $theme # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath0 -Name "BitmapsFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\" # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath0 -Name "GlobalBitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\" # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath0 -Name "NeXuSBitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\" # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath0 -Name "NeXuSThemeName" -Value $theme # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath0 -Name "NeXuSImage3" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\NxBack.png" # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath0 -Name "ClockBitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\" # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath0 -Name "TrashBitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\" # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath0 -Name "CPUBitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\" # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath0 -Name "POP3BitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\" # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath0 -Name "METARBitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\" # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath0 -Name "NetBitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\" # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath0 -Name "RAMBitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\" # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath0 -Name "WANDABitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\" # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath0 -Name "TrashEmptyIcon" -Value "C:\Users\Public\Documents\Winstep\Icons\recycle_bin_empty_$mode.ico" # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath0 -Name "TrashFullIcon" -Value "C:\Users\Public\Documents\Winstep\Icons\recycle_bin_full_$mode.ico" # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath0 -Name "NeXuSImage27" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\NxSep.png" # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath0 -Name "DockBack27Image1" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\NxSep.png" # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath1 -Name "DockBack27Image1" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\NxSep.png" # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath1 -Name "DockBitmapFolder1" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\" # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath1 -Name "DockBack3Image1" -Value "C:\Users\Public\Documents\WinStep\Themes\$theme\NxBack.png" # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath1 -Name "DockLabelColor1" -Value $DockLabelColor # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath1 -Name "DockLabelBackColor1" -Value $DockLabelBackColor # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath1 -Name "DockRunningIndicator1" -Value $dockRunningIndicator # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath2 -Name "UIDarkMode" -Value $UIDarkMode # -ErrorAction SilentlyContinue
Set-ItemProperty -Path $registryPath2 -Name "TaskIcon2" -Value "C:\\Users\\Public\\Documents\\WinStep\\Icons\\store_$mode.ico" # -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "SystemUsesLightTheme" -Type DWord -Value $OSMode # -ErrorAction SilentlyContinue
if ($mode2 -eq 'App') {	Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize" -Name "AppsUseLightTheme" -Type DWord -Value $OSMode } # -ErrorAction SilentlyContinue

Start-Process explorer
try { Start-Process "C:\Program Files (x86)\Winstep\Nexus.exe" } catch {}

start-sleep 5