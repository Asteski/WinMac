#include "taskbar_hook.h"
#include "controls.h"
#include "config.h"
#include <stdio.h>

// External reference to global config
extern Config g_cfg;

// Taskbar and start button handles
static HWND g_hTaskbar = NULL;
static HWND g_hStartButton = NULL;
static HHOOK g_hMsgHook = NULL;

// Low-level mouse hook procedure to intercept start button clicks globally
static LRESULT CALLBACK LowLevelMouseProc(int nCode, WPARAM wParam, LPARAM lParam) {
    if (nCode >= 0) {
        MSLLHOOKSTRUCT* pMouse = (MSLLHOOKSTRUCT*)lParam;
        
        // Check for mouse clicks
        BOOL bLeftClick = (wParam == WM_LBUTTONDOWN);
        BOOL bMiddleClick = (wParam == WM_MBUTTONDOWN);
        BOOL bRightClick = (wParam == WM_RBUTTONDOWN);
        
        if ((bLeftClick || bMiddleClick || bRightClick) && g_hStartButton) {
            // Check if click is over start button
            RECT startButtonRect;
            if (GetWindowRect(g_hStartButton, &startButtonRect) && PtInRect(&startButtonRect, pMouse->pt)) {
                
                WCHAR debug[256];
                wsprintfW(debug, L"Start button clicked at (%d,%d): Left=%d, Middle=%d, Right=%d\n", 
                         pMouse->pt.x, pMouse->pt.y, bLeftClick, bMiddleClick, bRightClick);
                OutputDebugStringW(debug);
                
                ControlActionType action = CA_NOTHING;
                const WCHAR* command = NULL;
                
                if (bLeftClick) {
                    BOOL shiftPressed = (GetKeyState(VK_SHIFT) & 0x8000) != 0;
                    if (shiftPressed) {
                        // TODO: Handle Shift+Left click when implemented
                        action = g_cfg.leftClickAction;
                        command = g_cfg.leftClickCommand;
                    } else {
                        action = g_cfg.leftClickAction;
                        command = g_cfg.leftClickCommand;
                    }
                } else if (bMiddleClick) {
                    // TODO: Handle middle click when implemented
                    action = g_cfg.leftClickAction; // For now, use left click action
                    command = g_cfg.leftClickCommand;
                } else if (bRightClick) {
                    // TODO: Handle right click when implemented  
                    action = g_cfg.leftClickAction; // For now, use left click action
                    command = g_cfg.leftClickCommand;
                }
                
                if (action != CA_NOTHING) {
                    // Execute the configured action
                    ExecuteControlAction(action, command, g_hTaskbar);
                    
                    // Suppress the click if we're not showing Windows menu
                    if (action != CA_WINDOWS_MENU) {
                        return 1; // Suppress the mouse event
                    }
                }
            }
        }
    }
    
    return CallNextHookEx(g_hMsgHook, nCode, wParam, lParam);
}

HWND FindTaskbarWindow(void) {
    return FindWindow(L"Shell_TrayWnd", NULL);
}

HWND FindStartButton(HWND hTaskbar) {
    if (!hTaskbar) return NULL;
    
    // Try different methods to find the start button depending on Windows version
    HWND hStartButton = NULL;
    
    // Method 1: Direct child search for "Start" button
    hStartButton = FindWindowEx(hTaskbar, NULL, L"Start", NULL);
    if (hStartButton) return hStartButton;
    
    // Method 2: Look for the start button in the tray area
    HWND hTray = FindWindowEx(hTaskbar, NULL, L"TrayNotifyWnd", NULL);
    if (!hTray) {
        // Try ReBarWindow32 for newer Windows versions
        HWND hRebar = FindWindowEx(hTaskbar, NULL, L"ReBarWindow32", NULL);
        if (hRebar) {
            // Look for MSTaskSwWClass 
            HWND hTaskSwitch = FindWindowEx(hRebar, NULL, L"MSTaskSwWClass", NULL);
            if (hTaskSwitch) {
                // Start button might be a sibling or child
                hStartButton = FindWindowEx(hRebar, NULL, L"Start", NULL);
                if (hStartButton) return hStartButton;
            }
        }
    }
    
    // Method 3: For Windows 10/11, try a simple fallback - use the taskbar itself as target
    // This is a simplified approach - in a real implementation you'd want a proper callback
    if (!hStartButton) {
        // As a fallback, we'll target the taskbar area near the start button
        hStartButton = hTaskbar;
    }
    
    return hStartButton;
}

BOOL InitTaskbarHook(void) {
    OutputDebugStringW(L"InitTaskbarHook: Starting taskbar hook initialization\n");
    
    // Find taskbar window
    g_hTaskbar = FindTaskbarWindow();
    if (!g_hTaskbar) {
        OutputDebugStringW(L"InitTaskbarHook: Could not find taskbar window\n");
        return FALSE;
    }
    
    WCHAR debug[256];
    wsprintfW(debug, L"InitTaskbarHook: Found taskbar window: %p\n", g_hTaskbar);
    OutputDebugStringW(debug);
    
    // Find start button
    g_hStartButton = FindStartButton(g_hTaskbar);
    if (!g_hStartButton) {
        OutputDebugStringW(L"InitTaskbarHook: Could not find start button\n");
        return FALSE;
    }
    
    wsprintfW(debug, L"InitTaskbarHook: Found start button: %p\n", g_hStartButton);
    OutputDebugStringW(debug);
    
    // Install low-level mouse hook to intercept mouse messages globally
    g_hMsgHook = SetWindowsHookEx(WH_MOUSE_LL, LowLevelMouseProc, GetModuleHandle(NULL), 0);
    if (!g_hMsgHook) {
        OutputDebugStringW(L"InitTaskbarHook: Failed to install mouse hook\n");
        return FALSE;
    }
    
    OutputDebugStringW(L"InitTaskbarHook: Mouse hook installed successfully\n");
    return TRUE;
}

void ShutdownTaskbarHook(void) {
    if (g_hMsgHook) {
        UnhookWindowsHookEx(g_hMsgHook);
        g_hMsgHook = NULL;
        OutputDebugStringW(L"ShutdownTaskbarHook: Mouse hook removed\n");
    }
    
    g_hTaskbar = NULL;
    g_hStartButton = NULL;
}