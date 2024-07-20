#If HoveringStart()
$LButton::Send #{x}
Return
#If

HoveringStart() {
    ; CoordMode, Mouse, Screen
    MouseGetPos, , , win, contr
	WinGetClass, class , % "ahk_id " win
	if (class = "Button")
    	return true
}