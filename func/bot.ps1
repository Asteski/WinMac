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

# Get the screen height
# $screenHeight = [System.Windows.Forms.Screen]::PrimaryScreen.Bounds.Height

# Move the taskbar to the bottom of the screen
[Taskbar]::SetWindowPos($taskbarHandle, $HWND_TOP, 0, - 40, 0, 0, $SWP_SHOWWINDOW)