#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

; Win+Ctrl+Q to Win+Ctrl+F4
^#q::{
    Send("^#{F4}")
}