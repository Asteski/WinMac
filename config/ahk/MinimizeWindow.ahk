#NoTrayIcon
^m::
{
    If Not WinActive("ahk_class Shell_TrayWnd")
    {
        WinMinimize("A")
    }
}