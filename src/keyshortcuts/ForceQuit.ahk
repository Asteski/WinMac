#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

; Robust Force Quit: Ctrl+Alt+Esc to force quit the active application, with special handling for File Explorer and Nexus Dock
^!Esc::
{
    If Not WinActive("ahk_exe explorer.exe") and Not WinActive("ahk_exe Nexus.exe")
    {
        active_window_id := WinGetID("A")
        active_window_process_name := WinGetProcessName("ahk_id " active_window_id)
        Run("taskkill /F /IM " active_window_process_name, , "Hide")
    }
    Else If WinActive("ahk_exe explorer.exe") and WinActive("ahk_class CabinetWClass")
    {
        active_window_id := WinGetID("A")
        active_window_process_name := WinGetProcessName("ahk_id " active_window_id)
        Run("taskkill /F /IM " active_window_process_name, , "Hide")
    }
}

; Win+Q to Alt+F4
#q::{
    Send("!{F4}")
}