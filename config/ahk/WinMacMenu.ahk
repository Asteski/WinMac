#NoTrayIcon
#HotIf StartOrb() || StartCorner()
$LButton::MouseClick("right")
Return
#HotIf

StartOrb() {
    ; CoordMode, Mouse, Screen
    MouseGetPos(, , &win, &contr)
	class := WinGetClass("ahk_id " win)
	if (class = "Button")
    	return true
}

StartCorner() {
    MouseGetPos(&xpos, &ypos)
	if (xpos <= 1) and (ypos <= 1)
    	return true
}

