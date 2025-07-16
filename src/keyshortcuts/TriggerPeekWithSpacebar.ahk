#SingleInstance Force
#NoTrayIcon
GetFocusedControlClassNN()
{
    GuiWindowHwnd := WinExist("A")
    if !GuiWindowHwnd
        return "NoWindowFound"
    FocusedControl := ControlGetFocus("ahk_id " GuiWindowHwnd)
    if !FocusedControl
        return "NoFocusedControl"
    return ControlGetClassNN(FocusedControl)
}

#HotIf WinActive("ahk_exe explorer.exe")
space::
{
    classnn:=GetFocusedControlClassNN()
    if (RegExMatch(classnn,"DirectUIHWND3"))
    {
        Send("{space}")
    }
    else if (!RegExMatch(classnn,"Microsoft.UI.Content.DesktopChildSiteBridge.*") and !RegExMatch(classnn,"Edit.*") )
    {
        Send("!+{space}")
    }
    else
    {
        Send("{space}")
    }
    return
}
#HotIf

#HotIf WinActive("ahk_exe PowerToys.Peek.UI.exe")
space::^w
#HotIf
