#pragma once
#include <windows.h>
#include "config.h"

#ifdef __cplusplus
extern "C" {
#endif

// Shows the settings dialog (modal). Returns TRUE if any values were changed and saved.
BOOL ShowSettingsDialog(HWND owner, Config* cfg);

#ifdef __cplusplus
}
#endif
