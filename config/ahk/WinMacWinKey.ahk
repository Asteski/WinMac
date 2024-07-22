LWin up::
If (A_PriorKey = "LWin") ; LWin was pressed alone
    Send, #{x}
return

; In this case its necessary to define a custom combination by using "&" or "<#" 
; to avoid that LWin loses its original function as a modifier key:

<#d:: Send #d  ; <# means LWin