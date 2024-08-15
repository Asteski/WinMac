using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Threading;
using System.Windows.Forms;

class Program
{
    private static IntPtr _hookID = IntPtr.Zero;
    private static bool _isWinKeyDown = false;
    private static bool _otherKeyPressed = false;
    private static Mutex? _mutex = null;

    static void Main()
    {
        const string mutexName = "Global\\MyUniqueWinXMenuMutex";

        _mutex = new Mutex(true, mutexName, out bool createdNew);

        if (!createdNew)
        {
            // Exit immediately if another instance is running
            Environment.Exit(0);
            return;
        }

        _hookID = SetHook(HookCallback);
        Application.Run();
        UnhookWindowsHookEx(_hookID);

        _mutex.ReleaseMutex();
    }

    private static IntPtr SetHook(LowLevelKeyboardProc proc)
    {
        using (Process curProcess = Process.GetCurrentProcess())
        using (ProcessModule? curModule = curProcess.MainModule)
        {
            if (curModule != null && curModule.ModuleName != null)
            {
                return SetWindowsHookEx(WH_KEYBOARD_LL, proc, GetModuleHandle(curModule.ModuleName), 0);
            }
            else
            {
                throw new InvalidOperationException("Failed to get the current process module or module name.");
            }
        }
    }

    private delegate IntPtr LowLevelKeyboardProc(int nCode, IntPtr wParam, IntPtr lParam);

    private static IntPtr HookCallback(int nCode, IntPtr wParam, IntPtr lParam)
    {
        if (nCode >= 0)
        {
            int vkCode = Marshal.ReadInt32(lParam);

            if (wParam == (IntPtr)WM_KEYDOWN)
            {
                if (vkCode == VK_LWIN || vkCode == VK_RWIN)
                {
                    _isWinKeyDown = true;
                    _otherKeyPressed = false;
                }
                else if (_isWinKeyDown)
                {
                    _otherKeyPressed = true;
                }
            }
            else if (wParam == (IntPtr)WM_KEYUP)
            {
                if ((vkCode == VK_LWIN || vkCode == VK_RWIN) && !_otherKeyPressed)
                {
                    ShowWinXMenu();
                }
                _isWinKeyDown = false;
            }
        }

        return CallNextHookEx(_hookID, nCode, wParam, lParam);
    }

    private static void ShowWinXMenu()
    {
        keybd_event(VK_LWIN, 0, 0, 0);
        keybd_event((byte)Keys.X, 0, 0, 0);
        keybd_event((byte)Keys.X, 0, KEYEVENTF_KEYUP, 0);
        keybd_event(VK_LWIN, 0, KEYEVENTF_KEYUP, 0);
    }

    private const int WH_KEYBOARD_LL = 13;
    private const int WM_KEYDOWN = 0x0100;
    private const int WM_KEYUP = 0x0101;
    private const int VK_LWIN = 0x5B;
    private const int VK_RWIN = 0x5C;
    private const uint KEYEVENTF_KEYUP = 0x0002;

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr SetWindowsHookEx(int idHook, LowLevelKeyboardProc lpfn, IntPtr hMod, uint dwThreadId);

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    [return: MarshalAs(UnmanagedType.Bool)]
    private static extern bool UnhookWindowsHookEx(IntPtr hhk);

    [DllImport("user32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr CallNextHookEx(IntPtr hhk, int nCode, IntPtr wParam, IntPtr lParam);

    [DllImport("kernel32.dll", CharSet = CharSet.Auto, SetLastError = true)]
    private static extern IntPtr GetModuleHandle(string lpModuleName);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern void keybd_event(byte bVk, byte bScan, uint dwFlags, uint dwExtraInfo);
}
