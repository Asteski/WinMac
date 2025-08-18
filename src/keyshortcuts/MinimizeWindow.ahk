#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon
#m::
{
    if !WinActive("ahk_class Shell_TrayWnd") && !WinActive("ahk_exe Nexus.exe")
    {
        if WinExist("A")
            WinMinimize("A")
        ; else do nothing
    }
}