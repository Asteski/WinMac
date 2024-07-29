#NoTrayIcon
^!Esc::
{
    If Not WinActive("ahk_exe explorer.exe")
    {
        WinGet, active_window_id, ID, A
        WinGet, active_window_process_name, ProcessName, ahk_id %active_window_id%
        Run, taskkill /F /IM %active_window_process_name%,, Hide
    }
}