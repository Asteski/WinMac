#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

#HotIf WinActive("ahk_exe msedge.exe")

; Ctrl+Shift+A => search opened tabs
^+a:: {
    Send("^l")
    Sleep(10)
    Send("@")
    Sleep(10)
    Send("ta")
    Sleep(10)
    Send("{Tab}")
}

; Ctrl+Shift+F => search favorites
^+f:: {
    Send("^l")
    Sleep(10)
    Send("@")
    Sleep(10)
    Send("fa")
    Sleep(10)
    Send("{Tab}")
}

; Ctrl+Shift+G => ask copilot
^+g:: {
    Send("^l")
    Sleep(10)
    Send("@")
    Sleep(10)
    Send("co")
    Sleep(10)
    Send("{Tab}")
}

; Ctrl+Shift+H => search history
^+h:: {
    Send("^l")
    Sleep(10)
    Send("@")
    Sleep(10)
    Send("hi")
    Sleep(10)
    Send("{Tab}")
}

; Ctrl+Shift+S => search current selection or open selected url
^+s:: {
    Send("^c")
    Sleep(10)
    Send("^l") 
    Sleep(10)
    Send("^v") 
    Sleep(10)
    Send("{Enter}")
}

; Ctrl+Shift+C => copy current url
^+c::
{
    Send("^l")
    Sleep(10)
    Send("^c")
    Sleep(10)
    Send("{Esc}")
}

; Ctrl+, => open settings
^,:: {
    Send("!f")
    Sleep(10)
    Send("g")
}

; Ctrl+Shift+D => duplicate tab
^+d::Send("^+k")

; Ctrl+Shift+T => reopen closed tab
^+z::Send("^+t")
#HotIf