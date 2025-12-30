#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon
#m::
{
    if WinExist("A") ; Check if any window is active
    {
        if !WinActive("ahk_class Shell_TrayWnd") && !WinActive("ahk_exe Nexus.exe")
        {
            try {
                WinMinimize("A")
            }
            catch {
            }
        }
        else {
            return
        }
    }
}

