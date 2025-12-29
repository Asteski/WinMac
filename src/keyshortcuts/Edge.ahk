#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

#HotIf WinActive("ahk_exe msedge.exe")
; Ctrl+Shift+C to copy URL
^+c::
{
    Send("^l")
    Sleep(100)
    Send("^c")
    Sleep(200)
    Send("{Esc}")
}
; Ctrl+Shift+A to search tabs
^+a:: {
    Send("^l")
    Sleep(10)
    Send("@")
    Sleep(10)
    Send("ta")
    Sleep(10)
    Send("{Tab}")
}
; Ctrl+Shift+F to search favorites
^+f:: {
    Send("^l")
    Sleep(10)
    Send("@")
    Sleep(10)
    Send("fa")
    Sleep(10)
    Send("{Tab}")
}
; Ctrl+Shift+G to ask Copilot
^+g:: {
    Send("^l")
    Sleep(10)
    Send("@")
    Sleep(10)
    Send("co")
    Sleep(10)
    Send("{Tab}")
}
; Ctrl+Shift+H to search history
^+h:: {
    Send("^l")
    Sleep(10)
    Send("@")
    Sleep(10)
    Send("hi")
    Sleep(10)
    Send("{Tab}")
}
; Ctrl+Shift+D to duplicate tab
^+d:: {
    Send("^+k")
}
; Ctrl+G to open Copilot sidebar
^g:: {
    Send("^+.")
}
; Ctrl + , to open settings
^,:: {
    Send("!f")
    Sleep(10)
    Send("g")
}
; Ctrl+Shift+Z to reopen closed tab
^+z::{
    Send("^+t")
}
#HotIf