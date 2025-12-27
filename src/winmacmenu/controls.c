#include "controls.h"
#include "menu.h"
#include <shellapi.h>
#include <shlwapi.h>

void ExecuteControlAction(ControlActionType action, const WCHAR* command, HWND hWnd) {
    // Debug output
    WCHAR debug[512];
    wsprintfW(debug, L"ExecuteControlAction: action=%d, command='%s', hWnd=%p\n", 
              action, command ? command : L"(null)", hWnd);
    OutputDebugStringW(debug);
    
    switch (action) {
        case CA_NOTHING:
            // Do nothing
            OutputDebugStringW(L"Action: CA_NOTHING\n");
            break;
            
        case CA_WINMAC_MENU:
            // Show WinMac Menu - same as the current behavior
            OutputDebugStringW(L"Action: CA_WINMAC_MENU\n");
            if (hWnd) {
                PostMessageW(hWnd, WM_APP, 0, 0);
            }
            break;
            
        case CA_WINDOWS_MENU:
            OutputDebugStringW(L"Action: CA_WINDOWS_MENU\n");
            ShowWindowsStartMenu();
            break;
            
        case CA_CUSTOM_COMMAND:
            wprintf(L"Action: CA_CUSTOM_COMMAND - executing '%s'\n", command ? command : L"(null)");
            OutputDebugStringW(L"Action: CA_CUSTOM_COMMAND\n");
            if (command && command[0]) {
                ExecuteCustomCommand(command);
            } else {
                wprintf(L"No custom command specified\n");
                OutputDebugStringW(L"No custom command specified\n");
            }
            break;
    }
}

void ShowWindowsStartMenu(void) {
    // Send Win key press to show Windows Start Menu
    // This simulates pressing the Windows key to open the built-in start menu
    keybd_event(VK_LWIN, 0, 0, 0);  // Key down
    keybd_event(VK_LWIN, 0, KEYEVENTF_KEYUP, 0);  // Key up
}

void ExecuteCustomCommand(const WCHAR* command) {
    if (!command || !command[0]) return;
    
    // Parse command and arguments
    WCHAR cmdCopy[2048];
    lstrcpynW(cmdCopy, command, ARRAYSIZE(cmdCopy));
    
    WCHAR* args = NULL;
    WCHAR* space = wcschr(cmdCopy, L' ');
    if (space) {
        *space = 0;
        args = space + 1;
        // Skip leading spaces in arguments
        while (*args == L' ') args++;
        if (*args == 0) args = NULL;
    }
    
    // Try to execute the command
    SHELLEXECUTEINFOW sei = { sizeof(sei) };
    sei.fMask = SEE_MASK_NOASYNC;
    sei.lpFile = cmdCopy;
    sei.lpParameters = args;
    sei.nShow = SW_SHOWNORMAL;
    
    if (!ShellExecuteExW(&sei)) {
        // If direct execution fails, try with cmd.exe
        WCHAR cmdLine[2048];
        wsprintfW(cmdLine, L"cmd.exe /c \"%s\"", command);
        
        STARTUPINFOW si = { sizeof(si) };
        PROCESS_INFORMATION pi = { 0 };
        
        if (CreateProcessW(NULL, cmdLine, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi)) {
            CloseHandle(pi.hProcess);
            CloseHandle(pi.hThread);
        }
    }
}