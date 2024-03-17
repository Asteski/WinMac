function WinMac {    
    $sab = (winget show --id StartIsBack.StartAllBack | Select-String -Pattern "Version").ToString().Split(":")[1].Trim()
    $pt = (winget show --id Microsoft.PowerToys | Select-String -Pattern "Version").ToString().Split(":")[1].Trim()
    $ev = (winget show --id Voidtools.Everything | Select-String -Pattern "Version").ToString().Split(":")[1].Trim()
    $output = @{
        'Version' = '0.0.1'
        'StartAllBackVersion' = $sab
        'PowerToysVersion' = $pt
        'EverythingVersion' = $ev
    }
    return $output
}