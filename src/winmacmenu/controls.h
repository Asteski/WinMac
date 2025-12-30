#pragma once
#include <windows.h>
#include "config.h"

#ifdef __cplusplus
extern "C" {
#endif

// Execute a control action based on the configured type
void ExecuteControlAction(ControlActionType action, const WCHAR* customCommand, HWND hWnd);

// Show the Windows Start Menu (Win+X menu equivalent)
void ShowWindowsStartMenu(void);

// Execute a custom command (similar to Windows Run behavior)
void ExecuteCustomCommand(const WCHAR* command);

#ifdef __cplusplus
}
#endif