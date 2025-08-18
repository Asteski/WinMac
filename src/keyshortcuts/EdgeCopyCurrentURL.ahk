#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon
#HotIf WinActive("ahk_exe msedge.exe")
^+c:: {
    Send("^l")       ; Ctrl+L
    Sleep(100)       ; short delay
    Send("^c")       ; Ctrl+C
    Sleep(200)       ; short delay
    Send("{Esc}")    ; Esc to exit the address bar
}
#HotIf