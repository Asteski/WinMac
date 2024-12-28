using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;

class MinimizeWindowsApp
{
    [DllImport("user32.dll")]
    private static extern IntPtr GetForegroundWindow();
    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
    [DllImport("user32.dll", SetLastError = true)]
    private static extern bool IsWindowVisible(IntPtr hWnd);
    [DllImport("user32.dll")]
    private static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);
    [DllImport("user32.dll", CharSet = CharSet.Auto)]
    private static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount);
    [DllImport("user32.dll", SetLastError = true)]
    private static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    private const int SW_MINIMIZE = 6;

    static void Main(string[] args) => MinimizeAllWindowsExceptFocused();

    static void MinimizeAllWindowsExceptFocused()
    {
        IntPtr focusedWindow = GetForegroundWindow();
        EnumWindows((hWnd, lParam) =>
        {
            if (!IsWindowVisible(hWnd) || hWnd == focusedWindow || IsTaskbarOrSystemTray(hWnd) || IsNexusRelatedWindow(hWnd) || IsTerminalWindow(hWnd) || IsExplorerWindow(hWnd))
                return true;
            ShowWindow(hWnd, SW_MINIMIZE);
            return true;
        }, IntPtr.Zero);
    }

    static bool IsTerminalWindow(IntPtr hWnd)
    {
        const string terminalClassName = "ConsoleWindowClass";
        StringBuilder className = new StringBuilder(256);
        GetClassName(hWnd, className, className.Capacity);
        return className.ToString().Equals(terminalClassName, StringComparison.OrdinalIgnoreCase);
    }

    static bool IsTaskbarOrSystemTray(IntPtr hWnd)
    {
        const string taskbarClassName = "Shell_TrayWnd";
        const string systemTrayClassName = "NotifyIconOverflowWindow";
        StringBuilder className = new StringBuilder(256);
        GetClassName(hWnd, className, className.Capacity);
        return className.ToString().Equals(taskbarClassName, StringComparison.OrdinalIgnoreCase) || className.ToString().Equals(systemTrayClassName, StringComparison.OrdinalIgnoreCase);
    }

    static bool IsNexusRelatedWindow(IntPtr hWnd)
    {
        const string nexusProcessName = "nexus";
        uint processId;
        GetWindowThreadProcessId(hWnd, out processId);
        try
        {
            var process = Process.GetProcessById((int)processId);
            return process.ProcessName.Equals(nexusProcessName, StringComparison.OrdinalIgnoreCase);
        }
        catch { return false; }
    }

    static bool IsExplorerWindow(IntPtr hWnd)
    {
        const string explorerClassName = "CabinetWClass";
        StringBuilder className = new StringBuilder(256);
        GetClassName(hWnd, className, className.Capacity);
        return className.ToString().Equals(explorerClassName, StringComparison.OrdinalIgnoreCase);
    }
}
