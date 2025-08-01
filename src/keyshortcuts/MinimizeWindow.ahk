#SingleInstance Force
#NoTrayIcon
#m::
{
    If Not WinActive("ahk_class Shell_TrayWnd") and Not WinActive("ahk_exe Nexus.exe")
    {
        WinMinimize("A")
    }
}