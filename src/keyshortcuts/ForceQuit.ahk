﻿#SingleInstance Force
#NoTrayIcon
^!Esc::
{
    If Not WinActive("ahk_exe explorer.exe") and Not WinActive("ahk_exe Nexus.exe")
    {
        active_window_id := WinGetID("A")
        active_window_process_name := WinGetProcessName("ahk_id " active_window_id)
        Run("taskkill /F /IM " active_window_process_name, , "Hide")
    }
}