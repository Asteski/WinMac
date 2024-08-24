; Single Instance to prevent multiple instances of the script from running
#SingleInstance Force

; No tray icon for a cleaner experience
#NoTrayIcon

; Hotkey: Ctrl + Esc - Sends Win + X
^Esc::Send("#{x}")

; Hotkey: Ctrl + Alt + Esc - Closes the active window unless it's Explorer or Nexus
^!Esc::
{
    ; Check if the active window is not Explorer or Nexus
    If Not WinActive("ahk_exe explorer.exe") and Not WinActive("ahk_exe Nexus.exe")
    {
        ; Get the active window ID and process name
        active_window_id := WinGetID("A")
        active_window_process_name := WinGetProcessName("ahk_id " active_window_id)
        ; Force close the active window's process
        Run("taskkill /F /IM " active_window_process_name, , "Hide")
    }
}

; Hotkey: Middle Mouse Button - Sends Win + X only when WinX() condition is true
#HotIf WinX()
$MButton::Send("#{x}")
#HotIf

; Function: Determines if the mouse is over the Start button or Taskbar
WinX() {
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

; Hotkey: Ctrl + Alt + M - Minimizes all windows unless the active window is Nexus
^!m::
{
    If Not WinActive("ahk_class Shell_TrayWnd") and Not WinActive("ahk_exe Nexus.exe")
    {
        WinMinimizeAll
    }
}

; Hotkey: Alt + M - Minimizes the active window unless it's Nexus
!m::
{
    If Not WinActive("ahk_class Shell_TrayWnd") and Not WinActive("ahk_exe Nexus.exe")
    {
        WinMinimize("A")
    }
}

; Cycle between windows of the same app like in macOS - Alt+backtick.
; Original Source: https://gist.github.com/kamui/12c581c09288ac486faeb1095622c873
; Based on: https://gist.github.com/rbika/014fb3570beaef195db0bd53fa681037

#SingleInstance Force
#NoTrayIcon
SendMode("Input")
SetWorkingDir(A_ScriptDir)

SortNumArray(arr) {
  str := ""
  for k, v in arr
    str .= v "`n"
  str := Sort(RTrim(str, "`n"), "N")
  return StrSplit(str, "`n")
}

getArrayValueIndex(arr, val) {
  Loop arr.Length {
    if (arr[A_Index] == val)
      return A_Index
  }
}

activateNextWindow(activeWindowsIdList) {
  currentWinId := WinGetID("A")
  currentIndex := getArrayValueIndex(activeWindowsIdList, currentWinId)

  if (currentIndex == activeWindowsIdList.Length) {
    nextIndex := 1
  }
  else {
    nextIndex := currentIndex + 1
  }

  try {
    WinActivate("ahk_id " activeWindowsIdList[nextIndex])
  } catch Error {
    clonedList := activeWindowsIdList.Clone()
    clonedList.RemoveAt(nextIndex)
    activateNextWindow(clonedList)
  }
}

activatePreviousWindow(activeWindowsIdList) {
  currentWinId := WinGetID("A")
  currentIndex := getArrayValueIndex(activeWindowsIdList, currentWinId)

  if (currentIndex == 1) {
    previousIndex := activeWindowsIdList.Length
  }
  else {
    previousIndex := currentIndex - 1
  }

  try {
    WinActivate("ahk_id " activeWindowsIdList[previousIndex])
  } catch Error {
    clonedList := activeWindowsIdList.Clone()
    clonedList.RemoveAt(previousIndex)
    activatePreviousWindow(clonedList)
  }
}

getSortedActiveWindowsIdList() {
  activeProcess := WinGetProcessName("A") ; Retrieves the name of the process that owns the active window
  activeWindowsIdList := WinGetList("ahk_exe " activeProcess,,,)
  sortedActiveWindowsIdList := SortNumArray(activeWindowsIdList)

  return sortedActiveWindowsIdList
}

!`:: {
  global
  activeWindowsIdList := getSortedActiveWindowsIdList()
  if (activeWindowsIdList.Length == 1) {
    return
  }
  activateNextWindow(activeWindowsIdList)
  return
}

+!`:: {
  global
  activeWindowsIdList := getSortedActiveWindowsIdList()
  if (activeWindowsIdList.Length == 1) {
    return
  }
  activatePreviousWindow(activeWindowsIdList)
  return
}
