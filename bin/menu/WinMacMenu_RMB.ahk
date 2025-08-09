#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

#HotIf WinMacMenu()
$RButton::Send("{LWin down}{LWin up}")
Return
#HotIf

WinMacMenu() {
    MouseGetPos , , &id, &control
	WGC := WinGetClass(id)
	WGT := WinGetTitle(id)
	If (WGC = "Shell_TrayWnd" And control = "Start1") 
	{
		return True
	}
	Else If (WGC = "Button" And WGT = "Start") 
	{
		return True
	} 
}
