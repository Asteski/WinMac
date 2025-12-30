#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

; Alt+Backspace to Delete
!Backspace::
{
    Send("{Del}")
}
