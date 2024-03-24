Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

public class Taskbar {
    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr FindWindow(string lpClassName, string lpWindowName);

    [DllImport("user32.dll", SetLastError = true)]
    public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);
}
"@

$taskbarHandle = [Taskbar]::FindWindow("Shell_TrayWnd", "")

# Constants for SetWindowPos
$HWND_TOP = [IntPtr]::Zero
$SWP_SHOWWINDOW = 0x0040

# Move the taskbar to the top of the screen
[Taskbar]::SetWindowPos($taskbarHandle, $HWND_TOP, 0, 0, 0, 0, $SWP_SHOWWINDOW)