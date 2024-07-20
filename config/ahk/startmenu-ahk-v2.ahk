#HotIf HoveringStart()
$LButton::Send("#{x}")
Return
#HotIf

HoveringStart() {
    ; CoordMode, Mouse, Screen
    MouseGetPos(, , &win, &contr)
	class := WinGetClass("ahk_id " win)
	if (class = "Button")
    	return true
}