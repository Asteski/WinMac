#SingleInstance Force
#NoTrayIcon
#Enter::
{
    If Not WinActive("ahk_class Shell_TrayWnd") and Not WinActive("ahk_exe Nexus.exe")
    {
        WinMaximize("A")
    }
    return
}