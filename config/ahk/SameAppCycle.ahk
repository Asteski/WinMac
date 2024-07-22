; Cycle between windows of the same app like in macOS - Alt+backtick.
; Original Source: https://gist.github.com/kamui/12c581c09288ac486faeb1095622c873
; Based on: https://gist.github.com/rbika/014fb3570beaef195db0bd53fa681037

; Limitations
; • It does not work in Explorer app
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
