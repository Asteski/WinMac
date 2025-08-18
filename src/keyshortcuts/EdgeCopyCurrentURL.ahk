#SingleInstance Force
#NoTrayIcon
#HotIf WinActive("ahk_exe msedge.exe")
^+c:: {
    Send("^l")       ; Ctrl+L
    Sleep(100)       ; short delay
    Send("^c")       ; Ctrl+C
}
#HotIf