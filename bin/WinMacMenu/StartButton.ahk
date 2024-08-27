#SingleInstance Force
#NoTrayIcon
#HotIf WinX()
$LButton::Send("#{x}")
Return
#HotIf

WinX() {
    Try {
        MouseGetPos , , &id, &control
        WGC := WinGetClass(id)
        WGT := WinGetTitle(id)
        
        If (WGC = "Shell_TrayWnd" And control = "Start1") {
            return True
        } Else If (WGC = "Button" And WGT = "Start") {
            return True
        }
    } Catch {
        ; In case of an error, restart the script silently
        Reload
    }
    return False
}
