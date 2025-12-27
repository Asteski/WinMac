#pragma once
#include <windows.h>
#include <commctrl.h>

#ifdef __cplusplus
extern "C" {
#endif

// Initialize taskbar hooking to intercept start button clicks
BOOL InitTaskbarHook(void);

// Shutdown taskbar hooking
void ShutdownTaskbarHook(void);

// Find taskbar windows and start button
HWND FindTaskbarWindow(void);
HWND FindStartButton(HWND hTaskbar);

#ifdef __cplusplus
}
#endif