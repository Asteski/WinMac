#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon
#Enter::
{
    if WinExist("A") ; Check if any window is active
    {
        if not WinActive("ahk_class Shell_TrayWnd") and not WinActive("ahk_exe Nexus.exe")
        {
            try {
                WinMaximize("A")
            }
            catch {
            }
        }
        else {
            return
        }
    }
}

