#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon
; Ctrl+Esc => Alt+Shift+Esc
^Esc:: {
    Send("!+{Esc}")
}