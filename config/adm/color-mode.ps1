function Set-ColorMode {
	$ErrorActionPreference = 'Continue'
	param
	(
		[Parameter(Mandatory=$true)]
		[string]
		$colorScheme
	)


	if ($colorScheme -eq 'Dark' -or $colorScheme -eq 'd')
	{
		$orbColor = 'white'
		$themeColor = 'Dark'
		$UIDarkMode = '1'
		$DockLabelColor1 = '15658734'
		$DockLabelBackColor1 = '2563870'
	}
	elseif ($colorScheme -eq 'Light' -or $colorScheme -eq 'l')
	{
		$orbColor = 'black'
		$themeColor = 'Light'
		$UIDarkMode = '3'
		$DockLabelColor1 = '1644825'
		$DockLabelBackColor1 = '16119283'
	}
	else {
		Write-Host "Invalid color scheme. Please enter 'Dark' or 'Light'."
		return
	}
	
	Set-ItemProperty -Path "HKCU:\Software\StartIsBack" -Name "OrbBitmap" -Value "C:\Users\$ENV:USERNAME\AppData\Local\StartAllBack\Orbs\$orbColor.svg"
	Stop-Process -n TopNotify -force
	Stop-Process -n Explorer -force
	Stop-Process -n Nexus -force
	$registryPath0 = "HKCU:\Software\WinSTEP2000\NeXuS"
	Set-ItemProperty -Path $registryPath0 -Name "GenThemeName" -Value "WinMac $themeColor Rounded"
	Set-ItemProperty -Path $registryPath0 -Name "BitmapsFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\WinMac $themeColor Rounded\"
	Set-ItemProperty -Path $registryPath0 -Name "GlobalBitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\WinMac $themeColor Rounded\"
	Set-ItemProperty -Path $registryPath0 -Name "NeXuSBitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\WinMac $themeColor Rounded\"
	Set-ItemProperty -Path $registryPath0 -Name "NeXuSThemeName" -Value "WinMac $themeColor Rounded"
	Set-ItemProperty -Path $registryPath0 -Name "NeXuSImage3" -Value "C:\Users\Public\Documents\WinStep\Themes\WinMac $themeColor Rounded\NxBack.png"
	Set-ItemProperty -Path $registryPath0 -Name "ClockBitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\WinMac $themeColor Rounded\"
	Set-ItemProperty -Path $registryPath0 -Name "TrashBitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\WinMac $themeColor Rounded\"
	Set-ItemProperty -Path $registryPath0 -Name "CPUBitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\WinMac $themeColor Rounded\"
	Set-ItemProperty -Path $registryPath0 -Name "POP3BitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\WinMac $themeColor Rounded\"
	Set-ItemProperty -Path $registryPath0 -Name "METARBitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\WinMac $themeColor Rounded\"
	Set-ItemProperty -Path $registryPath0 -Name "NetBitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\WinMac $themeColor Rounded\"
	Set-ItemProperty -Path $registryPath0 -Name "RAMBitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\WinMac $themeColor Rounded\"
	Set-ItemProperty -Path $registryPath0 -Name "WANDABitmapFolder" -Value "C:\Users\Public\Documents\WinStep\Themes\WinMac $themeColor Rounded\"

	$registryPath1 = "HKCU:\Software\WinSTEP2000\NeXuS\Docks"
	$indicator = (Get-ItemProperty -Path $registryPath1 -Name "DockRunningIndicator1").DockRunningIndicator1

	if ($indicator -like "*Dark*") {
		$indicatorValue = $indicator.Replace("Dark","Light")
	}
	else {
		$indicatorValue = $indicator.Replace("Light","Dark")
	}
	Set-ItemProperty -Path $registryPath1 -Name "DockRunningIndicator1" -Value $indicatorValue
	Set-ItemProperty -Path $registryPath1 -Name "DockBitmapFolder1" -Value "C:\Users\Public\Documents\WinStep\Themes\WinMac $themeColor Rounded\"
	Set-ItemProperty -Path $registryPath1 -Name "DockBack3Image1" -Value "C:\Users\Public\Documents\WinStep\Themes\WinMac $themeColor Rounded\NxBack.png"
	Set-ItemProperty -Path $registryPath1 -Name "DockLabelColor1" -Value $DockLabelColor1
	Set-ItemProperty -Path $registryPath1 -Name "DockLabelBackColor1" -Value $DockLabelBackColor1

	$registryPath2 = "HKCU:\Software\WinSTEP2000\Shared"
	Set-ItemProperty -Path $registryPath2 -Name "UIDarkMode" -Value $UIDarkMode

	Start-Process Explorer
	Start-Process "C:\Program Files\WindowsApps\55968SamsidGameStudios.TopNotify_2.3.7.0_x64__r9j5xrxak4zje\TopNotify.exe"
	Start-Process "C:\Program Files (x86)\Winstep\Nexus.exe"
}