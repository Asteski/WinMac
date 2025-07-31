#Requires AutoHotkey v2.0
#SingleInstance Force
#NoTrayIcon

#HotIf WinActive("ahk_class CabinetWClass") or WinActive("ahk_class ExploreWClass")
^h::
{
    ; Toggle registry value
    currentSetting := RegRead("HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Hidden")
    newSetting := (currentSetting = 2) ? 1 : 2
    RegWrite(newSetting, "REG_DWORD", "HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced", "Hidden")

    ; Send WM_SETTINGCHANGE to notify Explorer of the change
    SendMessage(0x1A, 0, StrPtr("Environment"), 0xFFFF)

    ; Refresh all open Explorer windows (ahk_class CabinetWClass or ExploreWClass)
    idList := WinGetList("ahk_class CabinetWClass")
    for this_id in idList
    {
        PostMessage(0x111, 41504,,, "ahk_id " . this_id)  ; 41504 = Command ID for Refresh (F5)
    }
}
#HotIf
