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
    CI_POWER_HIBERNATE,
    CI_RECENT_SUBMENU,
    CI_POWER_MENU,
    CI_TASKKILL,
    CI_THISPC,
    CI_HOME
} ConfigItemType;

typedef enum {
    CA_NOTHING = 0,     // Do nothing
    CA_WINMAC_MENU,     // Show WinMac Menu
    CA_WINDOWS_MENU,    // Show Windows Start Menu
    CA_CUSTOM_COMMAND   // Run custom command
} ControlActionType;

typedef struct ConfigItem {
    WCHAR name[64];
    WCHAR label[128];
    ConfigItemType type;
    WCHAR path[MAX_PATH];     // file/folder path or command target
    WCHAR params[256];        // optional params
    WCHAR iconPath[MAX_PATH]; // optional icon path (.ico), 16x16 preferred
    WCHAR iconPathLight[MAX_PATH]; // optional override icon for light theme
    WCHAR iconPathDark[MAX_PATH];  // optional override icon for dark theme
    BOOL submenu;             // for folder: display as submenu
    BOOL inlineExpand;        // experimental: for folder, expand contents directly in root menu (params contains "inline")
    BOOL inlineNoHeader;      // when inlineExpand, suppress header even if label present (params contains notitle|noheader)
    BOOL inlineOpen;          // when inlineExpand and this set, header becomes clickable and opens folder (params contains inlineopen)
} ConfigItem;

typedef struct Config {
    WCHAR iniPath[MAX_PATH];
    int recentMax;
    int folderMaxDepth; // 1..4 depth for nested folder submenus
    // When true, keep the app running in background mode with a hidden window and message loop
    BOOL runInBackground;
    // Whether folder submenus should offer single-click open of the folder itself
    BOOL folderSingleClickOpen; // General: FolderSubmenuOpen = single|double
    // Visibility options
    BOOL showHidden;   // show items with FILE_ATTRIBUTE_HIDDEN
    BOOL showDotfiles; // show items whose name starts with '.'
    // Extended dotfile visibility mode: 0 = none, 1 = files only, 2 = folders only, 3 = both
    int dotMode; // derived from ShowDotfiles string: false=0, true=3, filesonly=1, foldersonly=2
    
    // Sorting for inline folders
    enum { SORT_NAME=0, SORT_DATE_MODIFIED, SORT_DATE_CREATED, SORT_TYPE, SORT_SIZE } sortField;
    BOOL sortDescending;
    BOOL sortFoldersFirst;
    
    // Paging
    int maxItems; // Maximum items to show per folder page (0 = unlimited)

    // Styles (modern style compiled only when ENABLE_MODERN_STYLE defined)
#ifdef ENABLE_MODERN_STYLE
    enum { STYLE_LEGACY=0, STYLE_MODERN=1 } menuStyle;
#else
    enum { STYLE_LEGACY=0 } menuStyle; // always legacy when modern disabled
#endif
    WCHAR defaultIconPath[MAX_PATH]; // optional default icon for items without explicit icon
    WCHAR defaultIconPathLight[MAX_PATH]; // optional default icon for light theme
    WCHAR defaultIconPathDark[MAX_PATH];  // optional default icon for dark theme
    int showIcons; // show icons in legacy style (0=false, 1=true, 2=other/mixed)
    // Appearance
    BOOL roundedCorners; // (modern only when enabled) selection corner styling
    // Placement settings
    enum { HP_LEFT=0, HP_CENTER=1, HP_RIGHT=2 } hPlacement;
    int hOffset; // pixels from left/right when not centered
    enum { VP_TOP=0, VP_CENTER=1, VP_BOTTOM=2 } vPlacement;
    int vOffset; // pixels from top/bottom when not centered
    // When placement is center on an axis, optionally ignore the corresponding offset
    BOOL ignoreHOffsetWhenCentered; // [Placement] IgnoreOffsetWhenCentered=true|hoffset|voffset|false
    BOOL ignoreVOffsetWhenCentered; // derived from the same key
    // Optional: pointer-relative positioning and menu width (modern-only override)
    BOOL pointerRelative; // Position near mouse pointer instead of edges
    int menuWidth; // (modern only) [General] MenuWidth=226..255 (0 = auto). Ignored when modern disabled.
    BOOL folderShowOpenEntry; // [General] FolderShowOpenEntry=true|false (default true) controls showing "Open <folder>" in submenus when single-click open mode is enabled
    int logLevel; // 0=off,1=basic,2=verbose (from LogConfig=off|basic|verbose|true|false). Backward compatible: LogConfig=true -> basic.
    WCHAR logFolderPath[MAX_PATH]; // Base folder for dynamic log file (LogFolder=...)
    WCHAR logFilePath[MAX_PATH];   // Resolved dynamic log file full path (WinMacMenu_<configBase>_<yyMMdd-HHmm>.log)
    int recentLabelMode; // [General] RecentLabel=fullpath|name (0=full path, 1=file name)
    BOOL showExtensions; // [General] ShowFileExtensions=true keeps file extensions visible (back-compat: ShowExtensions, inverse of deprecated HideExtensions)
    BOOL showFolderIcons; // [General] ShowFolderIcons=true shows system folder icon for folder entries in legacy mode when legacyIcons enabled
    BOOL recentShowExtensions; // [General] RecentShowExtensions=true keeps extensions in recent submenu (inverse of deprecated RecentHideExtensions)
    BOOL recentShowCleanItems; // [General] RecentShowCleanItems=true (default true) adds a "Clear Recent Items" action at bottom of recent submenu
    BOOL recentShowIcons;      // [General] RecentShowIcons=true shows file icons in recent submenu
    
    // TaskKill defaults
    int taskKillMax;
    BOOL taskKillIgnoreSystem;
    BOOL taskKillShowIcons;
    BOOL taskKillListWindows;
    BOOL taskKillAllDesktops;
    WCHAR taskKillExcludes[512];

    // When PointerRelative = true, optionally ignore H/V offsets
    BOOL ignoreHOffsetWhenRelative; // [Placement] IgnoreOffsetWhenRelative=true|hoffset|voffset|false
    BOOL ignoreVOffsetWhenRelative; // derived from the same key
    // Tray icon
    BOOL showTrayIcon; // [General] ShowTrayIcon=true shows system tray icon while running in background
    BOOL startOnLogin; // [General] StartOnLogin=true adds/removes HKCU Run entry for this config
    // When running in background mode, optionally show the menu immediately on first launch
    BOOL showOnLaunch; // [General] ShowOnLaunch=true|false (default true)
    // Themed tray icon paths (optional). If absent fall back to embedded resource IDI_APPICON.
    WCHAR trayIconPath[MAX_PATH];
    WCHAR trayIconPathLight[MAX_PATH];
    WCHAR trayIconPathDark[MAX_PATH];
    // Power menu exclusion flags (Advanced tab): when TRUE, corresponding action is hidden from POWER_MENU aggregate
    BOOL excludeSleep;
    BOOL excludeShutdown;
    BOOL excludeRestart;
    BOOL excludeLock;
    BOOL excludeLogoff;
    BOOL excludeHibernate;
    // Control actions configuration (based on Open-Shell-Menu controls)
    ControlActionType leftClickAction;     // Left click action
    WCHAR leftClickCommand[MAX_PATH];      // Custom command for left click (when action = CA_CUSTOM_COMMAND)
    ControlActionType windowsKeyAction;    // Windows key action
    WCHAR windowsKeyCommand[MAX_PATH];     // Custom command for Windows key (when action = CA_CUSTOM_COMMAND)
    BOOL thisPCItemsAsSubmenus; // [General] ThisPCItemsAsSubmenus=true|false (default true)
    BOOL thisPCShowIcons;       // [General] ThisPCShowIcons=true|false (default true)
    BOOL thisPCAsSubmenu;       // [ThisPC] ThisPCAsSubmenu=true|false (default false)
    BOOL homeItemsAsSubmenus;   // [General] HomeItemsAsSubmenus=true|false (default true)
    BOOL homeShowIcons;         // [General] HomeShowIcons=true|false (default true)
    BOOL homeAsSubmenu;         // [Home] HomeAsSubmenu=true|false (default false)
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
