#Requires AutoHotkey v2.0


#HotIf WinActive("ahk_exe explorer.exe" && "ahk_class CabinetWClass")
; Ctrl + , to Open File Explorer Options
^,:: {
    Send("^l")
    Sleep(10)
    SendText("shell:::{6DFD7C5C-2451-11d3-A299-00C04F8EF6AF}")
    Sleep(10)
    Send("{Enter}")
}
; Ctrl + Shift + L to Copy File Explorer Path
^+l:: {
    Send("^l")
    Sleep(100)
    Send("^c")   
    Sleep(10)
    Send("{Esc}")
}
#HotIf