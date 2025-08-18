#pragma once
#include <windows.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef enum {
    CI_SEPARATOR = 0,
    CI_URI,
    CI_FILE,
    CI_CMD,
    CI_FOLDER,
    CI_FOLDER_SUBMENU,
    CI_POWER_SLEEP,
    CI_POWER_SHUTDOWN,
    CI_POWER_RESTART,
    CI_POWER_LOCK,
    CI_POWER_LOGOFF,
    CI_RECENT_SUBMENU
} ConfigItemType;

typedef struct ConfigItem {
    WCHAR name[64];
    WCHAR label[128];
    ConfigItemType type;
    WCHAR path[MAX_PATH];     // file/folder path or command target
    WCHAR params[256];        // optional params
    WCHAR iconPath[MAX_PATH]; // optional icon path (.ico), 16x16 preferred
    BOOL submenu;             // for folder: display as submenu
} ConfigItem;

typedef struct Config {
    WCHAR iniPath[MAX_PATH];
    int recentMax;
    // Recent items label mode: FALSE = filename only, TRUE = full path
    BOOL recentShowFullPath; // General: RecentLabel = filename | fullpath
    int folderMaxDepth; // 1..4 depth for nested folder submenus
    // Whether folder submenus should offer single-click open of the folder itself
    BOOL folderSingleClickOpen; // General: FolderSubmenuOpen = single|double
    // Visibility options
    BOOL showHidden;   // show items with FILE_ATTRIBUTE_HIDDEN
    BOOL showDotfiles; // show items whose name starts with '.'
    // Styles
    enum { STYLE_LEGACY=0, STYLE_MODERN=1 } menuStyle;
    WCHAR defaultIconPath[MAX_PATH]; // optional default icon for items without explicit icon
    BOOL legacyIcons; // show icons also in legacy style (owner-draw minimal)
    // Appearance
    BOOL roundedCorners; // General: Corners = rounded | square (modern style selection corners)
    // Placement settings
    enum { HP_LEFT=0, HP_CENTER=1, HP_RIGHT=2 } hPlacement;
    int hOffset; // pixels from left/right when not centered
    enum { VP_TOP=0, VP_CENTER=1, VP_BOTTOM=2 } vPlacement;
    int vOffset; // pixels from top/bottom when not centered
    // Optional: pointer-relative positioning and menu width (modern-only override)
    BOOL pointerRelative; // Position near mouse pointer instead of edges
    int menuWidth; // [General] MenuWidth=226..255 (0 = auto). Applies only to modern style.
    ConfigItem items[64];
    int count;
} Config;

// Resolves config path, creates default file if missing; returns TRUE if path is available
BOOL config_ensure(Config* out);
BOOL config_load(Config* out);
// Overrides the default INI path; call before config_load. Will create defaults if missing.
void config_set_path(Config* out, const WCHAR* path);
// Set a global default path override used by config_ensure/load callers that supply a fresh Config.
void config_set_default_path(const WCHAR* path);

#ifdef __cplusplus
}
#endif
