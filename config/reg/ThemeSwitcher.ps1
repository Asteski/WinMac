$ErrorActionPreference = 'SilentlyContinue'
$WarningPreference = 'SilentlyContinue'
$ProgressPreference = 'SilentlyContinue'
$param = $args[0]
taskkill /IM nexus.exe /F > $null 2>&1
$registryPath0 = "HKCU:\Software\WinSTEP2000\NeXuS"
$registryPath1 = "HKCU:\Software\WinSTEP2000\NeXuS\Docks"
$registryPath2 = "HKCU:\Software\WinSTEP2000\Shared"
$registryPath3 = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\DefaultIcon"
$registryPath4 = "HKCU:\Software\Classes\CLSID\{645FF040-5081-101B-9F08-00AA002F954E}\shell\empty"
$registryPath5 = "HKCU:\Software\StartIsBack"
$dockIndicator = (Get-ItemProperty -Path $registryPath1 -Name "DockRunningIndicator1").DockRunningIndicator1
$themeStyle = (Get-ItemProperty -Path $registryPath0 -Name "GenThemeName").GenThemeName
$orbBitmap = (Get-ItemProperty -Path $registryPath5 -Name "OrbBitmap").OrbBitmap
$recycleBinEmptyIcon = (Get-ItemProperty -Path $registryPath3 -Name "empty").empty
$recycleBinFullIcon = (Get-ItemProperty -Path $registryPath3 -Name "full").full

switch ($param) {
	"-light" {
		$UIDarkMode 			= '3'
		$mode 					= 'Light'
		$contextMenuStyle 		= 'False'
		$DockLabelColor1 		= '1644825'
		$DockLabelBackColor1 	= '16119283'
		$theme 					= $themeStyle -replace 'Dark', 'Light'
		$orbBitmap 				= $orbBitmap -replace 'white', 'black'
		$dockIndicator 			= $dockIndicator -replace 'Dark', 'Light'
		$recycleBinEmptyIcon 	= $recycleBinEmptyIcon -replace 'Light', 'Dark'
		$recycleBinFullIcon 	= $recycleBinFullIcon -replace 'Light', 'Dark'
	}
	"-dark" {
		$UIDarkMode 			= '1'
		$mode 					= 'Dark'
		$contextMenuStyle 		= 'True'
		$DockLabelColor1 		= '15658734'
		$DockLabelBackColor1 	= '2563870'
		$theme 					= $themeStyle -replace 'Light', 'Dark'
		$orbBitmap 				= $orbBitmap -replace 'black', 'white'
		$dockIndicator 			= $dockIndicator -replace 'Light', 'Dark'
		$recycleBinEmptyIcon 	= $recycleBinEmptyIcon -replace 'Dark', 'Light'
		$recycleBinFullIcon 	= $recycleBinFullIcon -replace 'Dark', 'Light'
	}
}

# Change Theme in Nexus
$themePath = "C:\Users\Public\Documents\WinStep\Themes\$theme\"
$registry1Properties = Get-ItemProperty -Path $registryPath1
$storeIcon = '$ENV:WINDIR\Resources\Icons\store'
$storeIcon = $registry1Properties.PSObject.Properties |
Where-Object { $_.Value -like "$storeIcon*" } |
	Select-Object -ExpandProperty Name
if ($storeIcon) { Set-ItemProperty -Path $registryPath1 -Name $storeIcon -Value "$ENV:WINDIR\Resources\Icons\store_$mode.ico" }
Set-ItemProperty -Path $registryPath0 -Name "GenThemeName" -Value $theme
Set-ItemProperty -Path $registryPath0 -Name "NeXuSThemeName" -Value $theme
Set-ItemProperty -Path $registryPath0 -Name "TrashEmptyIcon" -Value $recycleBinEmptyIcon
Set-ItemProperty -Path $registryPath0 -Name "TrashFullIcon" -Value $recycleBinFullIcon
Set-ItemProperty -Path $registryPath0 -Name "BitmapsFolder" -Value $themePath
Set-ItemProperty -Path $registryPath0 -Name "GlobalBitmapFolder" -Value $themePath
Set-ItemProperty -Path $registryPath0 -Name "NeXuSBitmapFolder" -Value $themePath
Set-ItemProperty -Path $registryPath0 -Name "NeXuSImage3" -Value "$themePath\NxBack.png"
Set-ItemProperty -Path $registryPath0 -Name "ClockBitmapFolder" -Value $themePath
Set-ItemProperty -Path $registryPath0 -Name "TrashBitmapFolder" -Value $themePath
Set-ItemProperty -Path $registryPath0 -Name "CPUBitmapFolder" -Value $themePath
Set-ItemProperty -Path $registryPath0 -Name "POP3BitmapFolder" -Value $themePath
Set-ItemProperty -Path $registryPath0 -Name "METARBitmapFolder" -Value $themePath
Set-ItemProperty -Path $registryPath0 -Name "NetBitmapFolder" -Value $themePath
Set-ItemProperty -Path $registryPath0 -Name "RAMBitmapFolder" -Value $themePath
Set-ItemProperty -Path $registryPath0 -Name "WANDABitmapFolder" -Value $themePath
Set-ItemProperty -Path $registryPath1 -Name "DockBitmapFolder1" -Value $themePath
Set-ItemProperty -Path $registryPath1 -Name "DockBack3Image1" -Value "$themePath\NxBack.png"
Set-ItemProperty -Path $registryPath1 -Name "DockLabelColor1" -Value $DockLabelColor1
Set-ItemProperty -Path $registryPath1 -Name "DockLabelBackColor1" -Value $DockLabelBackColor1
Set-ItemProperty -Path $registryPath1 -Name "DockRunningIndicator1" -Value $dockIndicator
Set-ItemProperty -Path $registryPath2 -Name "UIDarkMode" -Value $UIDarkMode
Set-ItemProperty -Path $registryPath2 -Name "Windows10Style" -Value $contextMenuStyle

# Change Recycle Bin icon
if (-not (Test-Path -LiteralPath $registryPath4)) {
	New-Item -Path $registryPath4 -Force
	New-Item -Path $registryPath4 -Name "Icon" -Force
}
New-ItemProperty -Path $registryPath4 -Name "Icon" -Value $recycleBinEmptyIcon -PropertyType String -Force

# Change StartAllBack orb
Set-ItemProperty -Path $registryPath5 -Name "OrbBitmap" -Value $orbBitmap

# Restart Nexus & Explorer
$exe = "C:\Program Files (x86)\Winstep\Nexus.exe"
Start-Process -FilePath $exe -WorkingDirectory (Split-Path $exe)
Start-Process explorer