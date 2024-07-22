#NoTrayIcon
#HotIf HoveringStart() || CornerStart()
$LButton::MouseClick("right")
Return
#HotIf

HoveringStart() {
    ; CoordMode, Mouse, Screen
    MouseGetPos(, , &win, &contr)
	class := WinGetClass("ahk_id " win)
	if (class = "Button")
    	return true
}

CornerStart() {
    MouseGetPos(&xpos, &ypos)
	if (xpos <= 1) and (ypos <= 1)
    	return true
}

