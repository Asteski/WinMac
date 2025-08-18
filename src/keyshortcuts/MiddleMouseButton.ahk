#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon
#HotIf WinX()
$MButton::Send("#{x}")
Return
#HotIf

WinX()
{
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
