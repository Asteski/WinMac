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
taskkill /IM nexus.exe /F > $null 2>&1
taskkill /IM explorer.exe /F > $null 2>&1
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
	$cursorMode 			= 'aero'
	$cursorName 			= 'Windows Default (system scheme)'
	$theme 					= $themeStyle -replace 'Light', 'Dark'
	$dockRunningIndicator 	= $dockRunningIndicator -replace 'Light', 'Dark'
	$orbBitmap 				= $orbBitmap -replace 'black', 'white'
	$recycleBinEmptyIcon 	= $recycleBinEmptyIcon -replace 'Light', 'Dark'
	$recycleBinFullIcon 	= $recycleBinFullIcon -replace 'Light', 'Dark'
	Set-ItemProperty -Path $registryPath2 -Name "Windows10Style" -Value 'True'
}
if ($mode -eq 'Light')
{
	$OSMode 				= 1
	$UIDarkMode 			= '3'
	$DockLabelColor1 		= '1644825'
	$DockLabelBackColor1 	= '16119283'
	$cursorMode 			= 'aero_black'
	$cursorName 			= 'Windows Black'
	$theme 					= $themeStyle -replace 'Dark', 'Light'
	$dockRunningIndicator 	= $dockRunningIndicator -replace 'Dark', 'Light'
	$orbBitmap 				= $orbBitmap -replace 'white', 'black'
	$recycleBinEmptyIcon 	= $recycleBinEmptyIcon -replace 'Dark', 'Light'
	$recycleBinFullIcon 	= $recycleBinFullIcon -replace 'Dark', 'Light'
	Set-ItemProperty -Path $registryPath2 -Name "Windows10Style" -Value 'False'
}

if ($mode2 -eq 'NoApp') {
	Set-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize' -Name 'SystemUsesLightTheme' -Type DWord -Value $OSMode
}
else {
	#* IF statement below is used for custom themes like Rectify11 Dark theme
	#* Rectify11 Dark theme allows to force dark theme on Windows legacy apps like Registry Editor, Disk Management, Event Viewer and etc.
	#* Registry modification below allows to make title bars dark in legacy apps
	#* In order for custom themes to work properly, we need to install SecureUXTheme and enable *Fix control panel white header/sidebar* option in UXTheme Hook Windhawk mod
	#? Once above are done:
	#? - clone Rectify11Installer-V4 GitHub repository locally using Git
	#? - copy Rectify11 themes folder content to C:\Windows\Resources\Themes
	#? - rename darkrectified.theme to WinMac_Dark.theme (backup default WinMac_Dark.theme first)
	#? - copy Rectify11 System32 folder content to C:\Windows\System32 folder
	#? - additionally you can copy [Control Panel\Cursors] content from default WinMac_Dark.theme to Rectify11 dark theme file using text editor, to apply default Windows 11 cursors
	#? - uncomment below if and else statements (lines from 73 to 80)
	# if ($mode -eq 'Light') {
	# 	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "ColorPrevalence" -Value 0
	# 	Remove-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "AccentColorInactive"
 	# }
	# else {
	# 	Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "ColorPrevalence" -Value 1
	# 	New-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\DWM" -Name "AccentColorInactive" -PropertyType DWord -Value 0xFF444444
	# }
	Start-Process "$env:WINDIR\Resources\Themes\WinMac_$mode.theme"
}

$RegConnect = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey([Microsoft.Win32.RegistryHive]"CurrentUser","$env:COMPUTERNAME")
$RegCursors = $RegConnect.OpenSubKey("Control Panel\Cursors",$true)
$RegCursors.SetValue("",$cursorName)
$RegCursors.SetValue("AppStarting","$curDestFolder\$($cursorMode)_working.ani")
$RegCursors.SetValue("Arrow","$curDestFolder\$($cursorMode)_arrow.cur")
$RegCursors.SetValue("Crosshair","$curDestFolder\cross_r.cur")
$RegCursors.SetValue("Hand","$curDestFolder\$($cursorMode)_link.cur")
$RegCursors.SetValue("Help","$curDestFolder\$($cursorMode)_helpsel.cur")
$RegCursors.SetValue("IBeam","$curDestFolder\beam_r.cur")
$RegCursors.SetValue("No","$curDestFolder\$($cursorMode)_unavail.cur")
$RegCursors.SetValue("NWPen","$curDestFolder\$($cursorMode)_pen.cur")
$RegCursors.SetValue("SizeAll","$curDestFolder\$($cursorMode)_move.cur")
$RegCursors.SetValue("SizeNESW","$curDestFolder\$($cursorMode)_nesw.cur")
$RegCursors.SetValue("SizeNS","$curDestFolder\$($cursorMode)_ns.cur")
$RegCursors.SetValue("SizeNWSE","$curDestFolder\$($cursorMode)_nwse.cur")
$RegCursors.SetValue("SizeWE","$curDestFolder\$($cursorMode)_ew.cur")
$RegCursors.SetValue("UpArrow","$curDestFolder\$($cursorMode)_up.cur")
$RegCursors.SetValue("Wait","$curDestFolder\$($cursorMode)_busy.ani")
$RegCursors.SetValue("Pin","$curDestFolder\$($cursorMode)_pin.cur")
$RegCursors.SetValue("Person","$curDestFolder\$($cursorMode)_person.cur")
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
$CursorRefresh::SystemParametersInfo(0x057,0,$null,0) > $null 2>&1

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
Set-ItemProperty -Path $registryPath2 -Name "TaskIcon2" -Value "C:\\Users\\Public\\Documents\\WinStep\\Icons\\store_$mode.ico"
Set-ItemProperty -Path $registryPath3 -Name "(default)" -Value $recycleBinEmptyIcon
Set-ItemProperty -Path $registryPath3 -Name "empty" -Value $recycleBinEmptyIcon
Set-ItemProperty -Path $registryPath3 -Name "full" -Value $recycleBinFullIcon
Set-ItemProperty -Path $registryPath4 -Name "Icon" -Value $recycleBinEmptyIcon
Set-ItemProperty -Path $registryPath5 -Name "OrbBitmap" -Value $orbBitmap
Start-Process explorer
try { Start-Process "C:\Program Files (x86)\Winstep\Nexus.exe" } catch {}