#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

; Alt+Backspace => Delete
!Backspace::Send("{Del}")

; Ctrl+Esc => Win+X
^Esc::Send("#{x}")

; Win+Q => Alt+F4
#q::Send("!{F4}")

; Ctrl+Alt+Esc => Force Quit
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

; Win+Enter => Maximize Window
#Enter::
{
    if WinExist("A")
    {
        if not WinActive("ahk_class Shell_TrayWnd") and not WinActive("ahk_exe Nexus.exe")
        {
            WinMaximize("A")
        }
    }
    return
}

; Win+M => Minimize Window
#m::
{
    if !WinActive("ahk_class Shell_TrayWnd") and !WinActive("ahk_exe Nexus.exe")
    {
        if WinExist("A")
            WinMinimize("A")
    }
}

; Ctrl+Win+F => Fullscreen
^#f::Send("{F11}")

; Ctrl+H => Show/Hide Hidden Files in Explorer
#HotIf WinActive("ahk_class CabinetWClass") or WinActive("ahk_class ExploreWClass")
^h::
{
    ; Toggle registry value
    currentSetting := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Hidden")
    newSetting := (currentSetting = 2) ? 1 : 2
    RegWrite(newSetting, "REG_DWORD", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Hidden")

    ; Send WM_SETTINGCHANGE to notify Explorer of the change
    SendMessage(0x1A, 0, StrPtr("Environment"), 0xFFFF)

    ; Refresh all open Explorer windows (ahk_class CabinetWClass or ExploreWClass)
    idList := WinGetList("ahk_class CabinetWClass")
    for this_id in idList
    {
        PostMessage(0x111, 41504,,, "ahk_id " . this_id)  ; 41504 = Command ID for Refresh (F5)
    }
}

; Ctrl+Shift+L => Copy Current Path
^+l:: {
    Send("^l")
    Sleep(100)
    Send("^c")
    Sleep(10)
    Send("{Esc}")
}
#HotIf