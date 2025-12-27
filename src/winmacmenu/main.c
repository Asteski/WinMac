#include <windows.h>
#include <shellapi.h>
#include <shlwapi.h>
#include <uxtheme.h>
#include <dwmapi.h>
#include <commctrl.h>
#include <stdio.h>
#include <io.h>
#include <fcntl.h>
#include "menu.h"
#include "theme.h"
#include "util.h"
#include "config.h"
#include "resource.h"
#include "settings.h"
#include "controls.h"
#include "taskbar_hook.h"

#pragma comment(lib, "comctl32.lib")

// CLI operation modes
typedef enum {
    CLI_MODE_NORMAL = 0,    // Regular GUI mode
    CLI_MODE_LIST,          // List all sessions
    CLI_MODE_RELOAD,        // Reload specific PID
    CLI_MODE_SHUTDOWN,      // Shutdown specific PID
    CLI_MODE_SETTINGS,      // Open settings for specific PID
    CLI_MODE_OPEN_INI,      // Open ini file for specific PID
    CLI_MODE_HELP           // Show help
} CliModeType;

// Output format modes for --list
typedef enum {
    OUTPUT_FORMAT_LIST = 0,     // Default list format
    OUTPUT_FORMAT_TABLE         // Table format
} OutputFormat;

typedef struct {
    CliModeType mode;
    DWORD targetPid;        // For reload/shutdown/settings operations
    WCHAR configPath[MAX_PATH];
    OutputFormat outputFormat; // For --list command
} CliArgs;

static const wchar_t *WC_APPWND = L"WinMacMenuWnd";
// Helper builds a unique window title for this config so multiple configs can run simultaneously.
// Default config.ini uses plain "WinMacMenu" title for backward compatibility; custom ini yields "WinMacMenu::<basename>".
static void build_window_title(const Config* cfg, wchar_t* out, size_t cchOut) {
    if (!out || cchOut==0) return;
    out[0]=0;
    if (!cfg || !cfg->iniPath[0]) { lstrcpynW(out, L"WinMacMenu", (int)cchOut); return; }
    WCHAR path[MAX_PATH]; lstrcpynW(path, cfg->iniPath, ARRAYSIZE(path));
    WCHAR *slash = wcsrchr(path, L'\\'); WCHAR *fname = slash ? slash+1 : path;
    WCHAR base[256]; lstrcpynW(base, fname, ARRAYSIZE(base));
    WCHAR *dot = wcsrchr(base, L'.'); if (dot) *dot = 0;
    if (!lstrcmpiW(base, L"config")) { lstrcpynW(out, L"WinMacMenu", (int)cchOut); }
    else { wsprintfW(out, L"WinMacMenu::%s", base); }
}
Config g_cfg; // global config
static HANDLE g_hSingleInstance = NULL;
static BOOL g_menuActive = FALSE;
static BOOL g_menuShowingNow = FALSE; // tracks if a popup is currently displayed (between ShowWinXMenu enter and menu close)
static HWND g_hMainWnd = NULL;
static BOOL g_runInBackground = FALSE; // mirror of config for quick checks
static UINT g_trayMsg = WM_APP + 1; // tray callback message id for Shell_NotifyIcon
static BOOL g_trayAdded = FALSE;
static HICON g_hTrayIcon = NULL;
static HICON g_hTrayIconLight = NULL; // cached themed variants
static HICON g_hTrayIconDark = NULL;
static HHOOK g_hKbHook = NULL;
static HHOOK g_hMouseHook = NULL;
static UINT g_msgTaskbarCreated = 0;
static HWND g_hHookTargetWnd = NULL;
static UINT g_winKeyHotkeyId = 0; // owner for posting close toggles
// Retrieve FileVersion (e.g., "0.4.0") from the executable's VERSIONINFO
static void get_file_version_string(wchar_t* out, size_t cchOut) {
    if (!out || cchOut == 0) return;
    out[0] = 0;
    WCHAR path[MAX_PATH];
    DWORD dummy = 0, size = 0;
    if (!GetModuleFileNameW(NULL, path, ARRAYSIZE(path))) return;
    size = GetFileVersionInfoSizeW(path, &dummy);
    if (size == 0) return;
    void* data = LocalAlloc(LMEM_FIXED, size);
    if (!data) return;
    if (!GetFileVersionInfoW(path, 0, size, data)) { LocalFree(data); return; }
    VS_FIXEDFILEINFO* fixed = NULL; UINT fixedLen = 0;
    if (VerQueryValueW(data, L"\\", (LPVOID*)&fixed, &fixedLen) && fixed && fixedLen >= sizeof(VS_FIXEDFILEINFO)) {
        WORD major = HIWORD(fixed->dwFileVersionMS);
        WORD minor = LOWORD(fixed->dwFileVersionMS);
        WORD build = HIWORD(fixed->dwFileVersionLS);
        // WORD rev = LOWORD(fixed->dwFileVersionLS);
        wsprintfW(out, L"%u.%u.%u", (unsigned)major, (unsigned)minor, (unsigned)build);
    }
    LocalFree(data);
}

// CLI helper: Find WinMacMenu window by PID
static BOOL find_winmacmenu_window_by_pid(DWORD pid, HWND* outHwnd, WCHAR* outTitle, size_t titleSize) {
    if (!outHwnd) return FALSE;
    *outHwnd = NULL;
    if (outTitle && titleSize > 0) outTitle[0] = 0;
    
    // Enumerate all windows with our window class
    HWND hwnd = FindWindowW(WC_APPWND, NULL);
    while (hwnd) {
        DWORD windowPid = 0;
        GetWindowThreadProcessId(hwnd, &windowPid);
        
        if (windowPid == pid) {
            *outHwnd = hwnd;
            if (outTitle && titleSize > 0) {
                GetWindowTextW(hwnd, outTitle, (int)titleSize);
            }
            return TRUE;
        }
        
        hwnd = FindWindowExW(NULL, hwnd, WC_APPWND, NULL);
    }
    
    return FALSE;
}

// CLI helper: Get config path from window title
static void get_config_from_title(const WCHAR* title, WCHAR* configPath, size_t configPathSize) {
    if (!title || !configPath || configPathSize == 0) return;
    configPath[0] = 0;
    
    if (!lstrcmpW(title, L"WinMacMenu")) {
        // Default config
        lstrcpynW(configPath, L"config.ini", (int)configPathSize);
    } else if (wcsstr(title, L"WinMacMenu::")) {
        // Custom config, extract basename
        const WCHAR* basename = title + lstrlenW(L"WinMacMenu::");
        wsprintfW(configPath, L"%s.ini", basename);
    }
}

// CLI implementation: List all WinMacMenu sessions
static BOOL cli_list_sessions(OutputFormat outputFormat) {
    BOOL foundAny = FALSE;
    HWND hwnd = FindWindowW(WC_APPWND, NULL);
    
    // For table format, we need to collect all data first to format properly
    typedef struct {
        DWORD pid;
        WCHAR title[260];
        WCHAR configName[MAX_PATH];
        WCHAR fullConfigPath[MAX_PATH];
        BOOL showOnLaunch;
        BOOL showTrayIcon;
        BOOL configLoaded;
    } SessionInfo;
    
    SessionInfo sessions[32]; // Max 32 sessions
    int sessionCount = 0;
    
    while (hwnd && sessionCount < 32) {
        SessionInfo* session = &sessions[sessionCount];
        
        GetWindowThreadProcessId(hwnd, &session->pid);
        GetWindowTextW(hwnd, session->title, ARRAYSIZE(session->title));
        get_config_from_title(session->title, session->configName, ARRAYSIZE(session->configName));
        
        // Try to get full config path by opening the process
        HANDLE hProcess = OpenProcess(PROCESS_QUERY_INFORMATION | PROCESS_VM_READ, FALSE, session->pid);
        if (hProcess) {
            if (!lstrcmpW(session->configName, L"config.ini")) {
                lstrcpynW(session->fullConfigPath, L"<default>\\config.ini", ARRAYSIZE(session->fullConfigPath));
            } else {
                lstrcpynW(session->fullConfigPath, session->configName, ARRAYSIZE(session->fullConfigPath));
            }
            CloseHandle(hProcess);
        }
        
        // Load config to get ShowOnLaunch and ShowTrayIcon values
        Config tempConfig = {0};
        WCHAR tempConfigPath[MAX_PATH];
        
        // Build full path for config loading
        if (!lstrcmpW(session->configName, L"config.ini")) {
            config_ensure(&tempConfig);
            session->configLoaded = config_load(&tempConfig);
        } else {
            wsprintfW(tempConfigPath, L"%s", session->configName);
            config_set_path(&tempConfig, tempConfigPath);
            session->configLoaded = config_load(&tempConfig);
        }
        
        if (session->configLoaded) {
            session->showOnLaunch = tempConfig.showOnLaunch;
            session->showTrayIcon = tempConfig.showTrayIcon;
        } else {
            session->showOnLaunch = FALSE;
            session->showTrayIcon = FALSE;
        }
        
        sessionCount++;
        foundAny = TRUE;
        
        hwnd = FindWindowExW(NULL, hwnd, WC_APPWND, NULL);
    }
    
    if (!foundAny) {
        // No output when no sessions found - just return silently
        return TRUE;
    }
    
    // Output the results in the requested format
    if (outputFormat == OUTPUT_FORMAT_TABLE) {
        // Table format - column headers, Window Title first
        wprintf(L"%-20s %-8s %-20s %-12s %-12s %s\n", 
                L"Window Title", L"PID", L"Config File", L"ShowOnLaunch", L"ShowTrayIcon", L"Config Path");
        wprintf(L"%-20s %-8s %-20s %-12s %-12s %s\n", 
                L"--------------------", L"--------", L"--------------------", L"------------", L"------------", L"--------------------");
        
        for (int i = 0; i < sessionCount; i++) {
            SessionInfo* s = &sessions[i];
            WCHAR showOnLaunchStr[16], showTrayIconStr[16];
            
            if (s->configLoaded) {
                lstrcpynW(showOnLaunchStr, s->showOnLaunch ? L"true" : L"false", ARRAYSIZE(showOnLaunchStr));
                lstrcpynW(showTrayIconStr, s->showTrayIcon ? L"true" : L"false", ARRAYSIZE(showTrayIconStr));
            } else {
                lstrcpynW(showOnLaunchStr, L"<unknown>", ARRAYSIZE(showOnLaunchStr));
                lstrcpynW(showTrayIconStr, L"<unknown>", ARRAYSIZE(showTrayIconStr));
            }
            
            // Truncate long strings for table display
            WCHAR titleDisplay[21], configDisplay[21], pathDisplay[41];
            lstrcpynW(titleDisplay, s->title, ARRAYSIZE(titleDisplay));
            lstrcpynW(configDisplay, s->configName, ARRAYSIZE(configDisplay));
            lstrcpynW(pathDisplay, s->fullConfigPath[0] ? s->fullConfigPath : L"<unknown>", ARRAYSIZE(pathDisplay));
            
            wprintf(L"%-20s %-8lu %-20s %-12s %-12s %s\n", 
                    titleDisplay, s->pid, configDisplay, showOnLaunchStr, showTrayIconStr, pathDisplay);
        }
    } else {
        // List format (default) - no headers, Window Title first
        for (int i = 0; i < sessionCount; i++) {
            SessionInfo* s = &sessions[i];
            
            wprintf(L"Window Title: %s\n", s->title);
            wprintf(L"PID: %lu\n", s->pid);
            wprintf(L"Config File: %s\n", s->configName);
            wprintf(L"Config Path: %s\n", s->fullConfigPath[0] ? s->fullConfigPath : L"<unknown>");
            
            if (s->configLoaded) {
                wprintf(L"ShowOnLaunch: %s\n", s->showOnLaunch ? L"true" : L"false");
                wprintf(L"ShowTrayIcon: %s\n", s->showTrayIcon ? L"true" : L"false");
            } else {
                wprintf(L"ShowOnLaunch: <unable to load>\n");
                wprintf(L"ShowTrayIcon: <unable to load>\n");
            }
            
            wprintf(L"\n");
        }
    }
    
    return TRUE;
}

// CLI implementation: Reload specific PID
static BOOL cli_reload_pid(DWORD pid) {
    HWND hwnd = NULL;
    WCHAR title[260] = {0};
    
    if (!find_winmacmenu_window_by_pid(pid, &hwnd, title, ARRAYSIZE(title))) {
        wprintf(L"Error: No WinMacMenu session found with PID %lu\n", pid);
        return FALSE;
    }
    
    wprintf(L"Reloading WinMacMenu session (PID: %lu, Title: %s)...\n", pid, title);
    
    // Send the reload command directly using WM_COMMAND with the reload menu ID
    // From the code, reload is menu item 10010
    PostMessageW(hwnd, WM_COMMAND, 10010, 0);
    
    wprintf(L"Reload signal sent successfully.\n");
    return TRUE;
}

// CLI implementation: Shutdown specific PID
static BOOL cli_shutdown_pid(DWORD pid) {
    HWND hwnd = NULL;
    WCHAR title[260] = {0};
    
    if (!find_winmacmenu_window_by_pid(pid, &hwnd, title, ARRAYSIZE(title))) {
        wprintf(L"Error: No WinMacMenu session found with PID %lu\n", pid);
        return FALSE;
    }
    
    wprintf(L"Shutting down WinMacMenu session (PID: %lu, Title: %s)...\n", pid, title);
    
    // Send close message
    PostMessageW(hwnd, WM_CLOSE, 0, 0);
    
    wprintf(L"Shutdown signal sent successfully.\n");
    return TRUE;
}

// CLI implementation: Open settings for specific PID
static BOOL cli_settings_pid(DWORD pid) {
    HWND hwnd = NULL;
    WCHAR title[260] = {0};
    
    if (!find_winmacmenu_window_by_pid(pid, &hwnd, title, ARRAYSIZE(title))) {
        wprintf(L"Error: No WinMacMenu session found with PID %lu\n", pid);
        return FALSE;
    }
    
    wprintf(L"Opening settings for WinMacMenu session (PID: %lu, Title: %s)...\n", pid, title);
    
    // Send the settings command directly using WM_COMMAND
    // From the code, settings is menu item 10005
    PostMessageW(hwnd, WM_COMMAND, 10005, 0);
    
    wprintf(L"Settings dialog request sent successfully.\n");
    return TRUE;
}

// CLI implementation: Open ini file for specific PID
static BOOL cli_open_ini_pid(DWORD pid) {
    HWND hwnd = NULL;
    WCHAR title[260] = {0};
    
    if (!find_winmacmenu_window_by_pid(pid, &hwnd, title, ARRAYSIZE(title))) {
        wprintf(L"Error: No WinMacMenu session found with PID %lu\n", pid);
        return FALSE;
    }
    
    wprintf(L"Opening ini file for WinMacMenu session (PID: %lu, Title: %s)...\n", pid, title);
    
    // Send the open ini command directly using WM_COMMAND
    // From the code, open ini is menu item 10011
    PostMessageW(hwnd, WM_COMMAND, 10011, 0);
    
    wprintf(L"Open ini file request sent successfully.\n");
    return TRUE;
}

// CLI implementation: Show help
static void cli_show_help(void) {
    wprintf(L"WinMacMenu - Command Line Interface\n");
    wprintf(L"===================================\n\n");
    wprintf(L"Usage: WinMacMenu.exe [options]\n\n");
    wprintf(L"Options:\n");
    wprintf(L"  --config <path>         Use specific config file\n");
    wprintf(L"  --list, -l              List all running WinMacMenu sessions\n");
    wprintf(L"  --output <format>       Output format for --list: 'list' (default) or 'table'\n");
    wprintf(L"  --reload <pid>, -r      Reload specific session by PID\n");
    wprintf(L"  --shutdown <pid>, -k    Shutdown specific session by PID\n");
    wprintf(L"  --settings <pid>, -s    Open settings for specific session by PID\n");
    wprintf(L"  --open-ini <pid>, -o    Open ini file for specific session by PID\n");
    wprintf(L"  --help, -h, /?          Show this help message\n\n");
    wprintf(L"Examples:\n");
    wprintf(L"  WinMacMenu.exe --list\n");
    wprintf(L"  WinMacMenu.exe -l\n");
    wprintf(L"  WinMacMenu.exe --list --output table\n");
    wprintf(L"  WinMacMenu.exe -l --output list\n");
    wprintf(L"  WinMacMenu.exe --reload 1234\n");
    wprintf(L"  WinMacMenu.exe -r 1234\n");
    wprintf(L"  WinMacMenu.exe --shutdown 1234\n");
    wprintf(L"  WinMacMenu.exe -k 1234\n");
    wprintf(L"  WinMacMenu.exe --settings 1234\n");
    wprintf(L"  WinMacMenu.exe -s 1234\n");
    wprintf(L"  WinMacMenu.exe --open-ini 1234\n");
    wprintf(L"  WinMacMenu.exe -o 1234\n");
    wprintf(L"  WinMacMenu.exe --config \"custom.ini\"\n\n");
    wprintf(L"When run without CLI options, WinMacMenu starts normally in GUI mode.\n");
}

#ifndef NIIF_LARGE_ICON
#define NIIF_LARGE_ICON 0x00000020
#endif

// Tray helpers
static void tray_add(HWND hWnd) {
    if (!g_cfg.showTrayIcon || g_trayAdded) return;
    BOOL dark = theme_is_dark();
    // Lazy load themed icons (file paths override resource)
    if (!g_hTrayIconLight) {
        if (g_cfg.trayIconPathLight[0]) {
            g_hTrayIconLight = (HICON)LoadImageW(NULL, g_cfg.trayIconPathLight, IMAGE_ICON, 16, 16, LR_LOADFROMFILE);
        }
        if (!g_hTrayIconLight && g_cfg.trayIconPath[0]) {
            g_hTrayIconLight = (HICON)LoadImageW(NULL, g_cfg.trayIconPath, IMAGE_ICON, 16, 16, LR_LOADFROMFILE);
        }
        if (!g_hTrayIconLight) {
            g_hTrayIconLight = (HICON)LoadImageW(GetModuleHandleW(NULL), MAKEINTRESOURCEW(IDI_TRAY_LIGHT), IMAGE_ICON,
                GetSystemMetrics(SM_CXSMICON), GetSystemMetrics(SM_CYSMICON), LR_DEFAULTCOLOR);
        }
    }
    if (!g_hTrayIconDark) {
        if (g_cfg.trayIconPathDark[0]) {
            g_hTrayIconDark = (HICON)LoadImageW(NULL, g_cfg.trayIconPathDark, IMAGE_ICON, 16, 16, LR_LOADFROMFILE);
        }
        if (!g_hTrayIconDark && g_cfg.trayIconPath[0]) {
            g_hTrayIconDark = (HICON)LoadImageW(NULL, g_cfg.trayIconPath, IMAGE_ICON, 16, 16, LR_LOADFROMFILE);
        }
        if (!g_hTrayIconDark) {
            g_hTrayIconDark = (HICON)LoadImageW(GetModuleHandleW(NULL), MAKEINTRESOURCEW(IDI_TRAY_DARK), IMAGE_ICON,
                GetSystemMetrics(SM_CXSMICON), GetSystemMetrics(SM_CYSMICON), LR_DEFAULTCOLOR);
        }
    }
    if (dark) g_hTrayIcon = g_hTrayIconDark ? g_hTrayIconDark : g_hTrayIconLight;
    else g_hTrayIcon = g_hTrayIconLight ? g_hTrayIconLight : g_hTrayIconDark;
    if (!g_hTrayIcon) {
        // Fallback to embedded resource
        g_hTrayIcon = (HICON)LoadImageW(GetModuleHandleW(NULL), MAKEINTRESOURCEW(IDI_APPICON), IMAGE_ICON,
            GetSystemMetrics(SM_CXSMICON), GetSystemMetrics(SM_CYSMICON), LR_DEFAULTCOLOR);
        if (!g_hTrayIcon) g_hTrayIcon = LoadIcon(NULL, IDI_APPLICATION);
    }
    NOTIFYICONDATAW nid = {0};
    nid.cbSize = sizeof(nid);
    nid.hWnd = hWnd;
    nid.uID = 1;
    nid.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP;
    nid.uCallbackMessage = g_trayMsg;
    nid.hIcon = g_hTrayIcon;
    // New tooltip rules:
    // 1. If ini file name is exactly config.ini -> "WinMac Menu"
    // 2. Else -> "WinMac Menu (<filename_without_extension_truncated>)"
    // Truncate base filename to 256 chars first, then ensure final tooltip fits NOTIFYICONDATAW::szTip (128 wchar incl null).
    WCHAR path[MAX_PATH]; lstrcpynW(path, g_cfg.iniPath, ARRAYSIZE(path));
    WCHAR *slash = wcsrchr(path, L'\\'); WCHAR *fname = slash ? slash+1 : path;
    WCHAR base[512]; lstrcpynW(base, fname, ARRAYSIZE(base));
    WCHAR *dot = wcsrchr(base, L'.'); if (dot) *dot = 0;
    if (!lstrcmpiW(base, L"config")) {
        lstrcpynW(nid.szTip, L"WinMac Menu", ARRAYSIZE(nid.szTip));
    } else {
        // Truncate base to 256 chars (defense against extremely long names before we format)
        WCHAR truncated[257]; truncated[0]=0;
        if (lstrlenW(base) > 256) {
            // Copy first 253 and add ellipsis "..."
            lstrcpynW(truncated, base, 254);
            lstrcatW(truncated, L"...");
        } else {
            lstrcpynW(truncated, base, ARRAYSIZE(truncated));
        }
        WCHAR formatted[256]; // intermediate to avoid overflow; we'll clamp when copying to nid.szTip
        wsprintfW(formatted, L"WinMac Menu (%s)", truncated);
        lstrcpynW(nid.szTip, formatted, ARRAYSIZE(nid.szTip));
    }
    Shell_NotifyIconW(NIM_ADD, &nid);
    g_trayAdded = TRUE;
}

static void tray_remove(HWND hWnd) {
    if (!g_trayAdded) return;
    NOTIFYICONDATAW nid = {0};
    nid.cbSize = sizeof(nid);
    nid.hWnd = hWnd;
    nid.uID = 1;
    Shell_NotifyIconW(NIM_DELETE, &nid);
    g_trayAdded = FALSE;
}

static void tray_reload(HWND hWnd) {
    if (!g_cfg.showTrayIcon) return;
    // Remove existing icon if present
    if (g_trayAdded) tray_remove(hWnd);
    // Do not destroy themed cache icons—they may be reused; only clear selection handle
    g_hTrayIcon = NULL;
    tray_add(hWnd);
}

static void tray_show_balloon(HWND hWnd, const WCHAR* title, const WCHAR* text) {
    NOTIFYICONDATAW nid = {0};
    nid.cbSize = sizeof(nid);
    nid.hWnd = hWnd;
    nid.uID = 1;
    nid.uFlags = NIF_INFO;
    lstrcpynW(nid.szInfoTitle, title ? title : L"WinMac Menu", ARRAYSIZE(nid.szInfoTitle));
    lstrcpynW(nid.szInfo, text ? text : L"Running in background", ARRAYSIZE(nid.szInfo));
    nid.dwInfoFlags = NIIF_INFO | NIIF_LARGE_ICON;
    Shell_NotifyIconW(NIM_MODIFY, &nid);
}

// Hook helpers
static LRESULT CALLBACK lowlevel_kb_proc(int nCode, WPARAM wParam, LPARAM lParam) {
    if (nCode == HC_ACTION && g_hHookTargetWnd) {
        const KBDLLHOOKSTRUCT* ks = (const KBDLLHOOKSTRUCT*)lParam;
        
        if (g_menuShowingNow) {
            // When menu is showing, handle escape and Windows key to close menu
            if ((wParam == WM_KEYDOWN || wParam == WM_SYSKEYDOWN) && (ks->vkCode == VK_LWIN || ks->vkCode == VK_RWIN || ks->vkCode == VK_ESCAPE || ks->vkCode == VK_MENU)) {
                PostMessageW(g_hHookTargetWnd, WM_APP, 0, 0);
            }
        }
    }
    return CallNextHookEx(g_hKbHook, nCode, wParam, lParam);
}

static BOOL is_point_in_menu_window(POINT pt) {
    HWND hw = WindowFromPoint(pt);
    if (!hw) return FALSE;
    WCHAR cls[64];
    if (GetClassNameW(hw, cls, ARRAYSIZE(cls))) {
        if (!lstrcmpW(cls, L"#32768")) return TRUE; // menu window class
    }
    return FALSE;
}

#ifndef MN_GETHMENU
#define MN_GETHMENU 0x01E1
#endif

#include "util.h"

static LRESULT CALLBACK lowlevel_mouse_proc(int nCode, WPARAM wParam, LPARAM lParam) {
    if (nCode == HC_ACTION && g_hHookTargetWnd && g_menuShowingNow) {
        const MSLLHOOKSTRUCT* ms = (const MSLLHOOKSTRUCT*)lParam;
        
        if (wParam == WM_LBUTTONUP) {
            HWND hMenuWnd = WindowFromPoint(ms->pt);
            WCHAR cls[64];
            if (hMenuWnd && GetClassNameW(hMenuWnd, cls, ARRAYSIZE(cls)) && !lstrcmpW(cls, L"#32768")) {
                HMENU hMenu = (HMENU)SendMessageW(hMenuWnd, MN_GETHMENU, 0, 0);
                if (hMenu) {
                    int pos = MenuItemFromPoint(hMenuWnd, hMenu, ms->pt);
                    if (pos != -1) {
                        MENUITEMINFOW mii = { sizeof(mii) };
                        mii.fMask = MIIM_DATA | MIIM_SUBMENU;
                        if (GetMenuItemInfoW(hMenu, pos, TRUE, &mii)) {
                            // If it has a submenu (is a folder) and has data (path), open it
                            if (mii.hSubMenu && mii.dwItemData) {
                                WCHAR* path = (WCHAR*)mii.dwItemData;
                                if (path && path[0]) {
                                    open_shell_item(path);
                                    PostMessageW(g_hHookTargetWnd, WM_CANCELMODE, 0, 0); // Close menu
                                    return 1; // Swallow click
                                }
                            }
                        }
                    }
                }
            }
        }

        if (wParam == WM_LBUTTONDOWN || wParam == WM_RBUTTONDOWN || wParam == WM_MBUTTONDOWN || wParam == WM_MOUSEWHEEL) {
            if (!is_point_in_menu_window(ms->pt)) {
                PostMessageW(g_hHookTargetWnd, WM_APP, 0, 0);
            }
        }
    }
    return CallNextHookEx(g_hMouseHook, nCode, wParam, lParam);
}

static void install_menu_hooks(HWND hOwner) {
    g_hHookTargetWnd = hOwner;
    if (!g_hKbHook) g_hKbHook = SetWindowsHookExW(WH_KEYBOARD_LL, lowlevel_kb_proc, GetModuleHandleW(NULL), 0);
    if (!g_hMouseHook) g_hMouseHook = SetWindowsHookExW(WH_MOUSE_LL, lowlevel_mouse_proc, GetModuleHandleW(NULL), 0);
}

static void uninstall_menu_hooks(void) {
    if (g_hKbHook) { UnhookWindowsHookEx(g_hKbHook); g_hKbHook = NULL; }
    if (g_hMouseHook) { UnhookWindowsHookEx(g_hMouseHook); g_hMouseHook = NULL; }
    g_hHookTargetWnd = NULL;
}

// Background mode: hooks and triggers managed by this process

static DWORD simple_hash_w(const wchar_t* s) {
    DWORD h = 2166136261u; // FNV-1a base
    while (s && *s) { h ^= (DWORD)(*s++); h *= 16777619u; }
    return h;
}

LRESULT CALLBACK WndProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam) {
    switch (msg) {
    case WM_CREATE:
        InitCommonControls();
        theme_apply_to_window(hWnd);
        g_msgTaskbarCreated = RegisterWindowMessageW(L"TaskbarCreated");
        if (g_runInBackground && g_cfg.showTrayIcon) tray_add(hWnd);
        return 0;
    case WM_DESTROY:
        if (g_trayAdded) tray_remove(hWnd);
        PostQuitMessage(0);
        return 0;
    case WM_SETTINGCHANGE:
    case WM_THEMECHANGED:
        theme_apply_to_window(hWnd);
        if (g_runInBackground && g_cfg.showTrayIcon) tray_reload(hWnd); // ensure themed tray icon updates
        return 0;
    case WM_DEVICECHANGE: // try to ensure tray is restored on some device changes
        if (g_runInBackground && g_cfg.showTrayIcon && !g_trayAdded) tray_add(hWnd);
        break;
    case WM_DPICHANGED:
        // Reload icons at new DPI (tray + class small) for sharpness
        if (g_runInBackground && g_cfg.showTrayIcon) {
            tray_reload(hWnd);
        }
        break;
    case WM_ACTIVATEAPP:
        if (g_menuShowingNow && wParam == FALSE) { EndMenu(); return 0; }
        break;
    case WM_CANCELMODE:
        if (g_menuShowingNow) { EndMenu(); return 0; }
        break;
    case WM_HOTKEY:
        // Handle registered Windows key hotkey
        if (wParam == g_winKeyHotkeyId && g_runInBackground) {
            WCHAR debug[256];
            wsprintfW(debug, L"WM_HOTKEY Windows key received, action=%d\n", g_cfg.windowsKeyAction);
            OutputDebugStringW(debug);
            
            // Windows key was pressed - execute configured action
            ExecuteControlAction(g_cfg.windowsKeyAction, g_cfg.windowsKeyCommand, hWnd);
            return 0;
        }
        break;
    case WM_SYSCOMMAND:
        // Handle Windows key press via SC_TASKLIST (fallback approach)
        if ((wParam & 0xFFF0) == SC_TASKLIST && g_runInBackground && g_cfg.windowsKeyAction != CA_WINDOWS_MENU) {
            WCHAR debug[256];
            wsprintfW(debug, L"WM_SYSCOMMAND SC_TASKLIST received, action=%d\n", g_cfg.windowsKeyAction);
            OutputDebugStringW(debug);
            
            // Windows key was pressed - execute configured action
            ExecuteControlAction(g_cfg.windowsKeyAction, g_cfg.windowsKeyCommand, hWnd);
            return 0;
        }
        break;
    default:
        break;
    }
    // Handle taskbar recreation (Explorer restart broadcasts this)
    if (msg == g_msgTaskbarCreated) {
        if (g_runInBackground && g_cfg.showTrayIcon) {
            tray_reload(hWnd);
        }
        return 0;
    }
    // Tray callback
    if (msg == g_trayMsg) {
        if (lParam == WM_LBUTTONUP || lParam == WM_LBUTTONDBLCLK) {
            // Toggle: if menu visible, close; else open
            if (g_menuShowingNow) { EndMenu(); }
            else if (!g_menuActive) {
                g_menuActive = TRUE; g_menuShowingNow = TRUE;
                install_menu_hooks(hWnd);
                POINT pt = {0,0}; ShowWinXMenu(hWnd, pt);
                uninstall_menu_hooks();
                g_menuShowingNow = FALSE; g_menuActive = FALSE;
            }
            return 0;
        } else if (lParam == WM_RBUTTONUP) {
            // Small context with Exit
            POINT pt; GetCursorPos(&pt);
            HMENU m = CreatePopupMenu();
            AppendMenuW(m, MF_STRING, 10001, L"Show menu");
            AppendMenuW(m, MF_STRING, 10003, L"Hide tray");
            BOOL elevated = is_process_elevated();
            if (elevated) {
                AppendMenuW(m, MF_STRING | MF_GRAYED, 10004, L"Elevated");
            } else {
                AppendMenuW(m, MF_STRING, 10004, L"Elevate");
            }
            AppendMenuW(m, MF_SEPARATOR, 0, NULL);
            // Insert Reload option (restart the application) before Start on login per request
            AppendMenuW(m, MF_STRING, 10010, L"Reload");
            // Toggles with check marks
            UINT fSOL = (g_cfg.startOnLogin ? MF_CHECKED : MF_UNCHECKED);
            AppendMenuW(m, MF_STRING | fSOL, 10008, L"Start on login");
            // ShowIcons toggle with dynamic label
            WCHAR iconsLabel[64];
            lstrcpynW(iconsLabel, g_cfg.showIcons ? L"Hide menu icons" : L"Show menu icons", ARRAYSIZE(iconsLabel));
            AppendMenuW(m, MF_STRING, 10009, iconsLabel);
            AppendMenuW(m, MF_SEPARATOR, 0, NULL);
            AppendMenuW(m, MF_STRING, 10011, L"Open ini file");
            AppendMenuW(m, MF_STRING, 10006, L"Help");
            AppendMenuW(m, MF_STRING, 10007, L"About");
            AppendMenuW(m, MF_SEPARATOR, 0, NULL);
            AppendMenuW(m, MF_STRING, 10002, L"Exit");
            SetForegroundWindow(hWnd);
            UINT cmd = TrackPopupMenu(m, TPM_RIGHTBUTTON | TPM_RETURNCMD | TPM_LEFTALIGN | TPM_TOPALIGN, pt.x, pt.y, 0, hWnd, NULL);
            DestroyMenu(m);
            if (cmd == 10001) {
                PostMessageW(hWnd, WM_APP, 0, 0);
            } else if (cmd == 10003) {
                // Hide tray: update INI and remove icon
                WritePrivateProfileStringW(L"General", L"ShowTrayIcon", L"false", g_cfg.iniPath);
                g_cfg.showTrayIcon = FALSE;
                tray_remove(hWnd);
            } else if (cmd == 10004) {
                // Elevate: launch same exe with runas and same --config, then exit current
                WCHAR exePath[MAX_PATH]; GetModuleFileNameW(NULL, exePath, ARRAYSIZE(exePath));
                WCHAR params[2048] = L"";
                if (g_cfg.iniPath[0]) wsprintfW(params, L"--config \"%s\"", g_cfg.iniPath);
                SHELLEXECUTEINFOW sei = { sizeof(sei) };
                sei.lpVerb = L"runas";
                sei.lpFile = exePath;
                sei.lpParameters = (params[0] ? params : NULL);
                sei.nShow = SW_SHOWNORMAL;
                if (ShellExecuteExW(&sei)) {
                    // Release mutex and exit
                    if (g_hSingleInstance) { ReleaseMutex(g_hSingleInstance); CloseHandle(g_hSingleInstance); g_hSingleInstance = NULL; }
                    PostMessageW(hWnd, WM_CLOSE, 0, 0);
                }
            } else if (cmd == 10010) {
                // Reload: relaunch same executable (non-elevated) with same config path, then exit
                WCHAR exePath[MAX_PATH]; GetModuleFileNameW(NULL, exePath, ARRAYSIZE(exePath));
                WCHAR cmdline[4096];
                if (g_cfg.iniPath[0]) wsprintfW(cmdline, L"\"%s\" --config \"%s\"", exePath, g_cfg.iniPath);
                else wsprintfW(cmdline, L"\"%s\"", exePath);
                STARTUPINFOW si = { sizeof(si) }; PROCESS_INFORMATION pi = {0};
                if (CreateProcessW(exePath, cmdline, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi)) {
                    CloseHandle(pi.hThread); CloseHandle(pi.hProcess);
                    if (g_hSingleInstance) { ReleaseMutex(g_hSingleInstance); CloseHandle(g_hSingleInstance); g_hSingleInstance = NULL; }
                    PostMessageW(hWnd, WM_CLOSE, 0, 0);
                }
            } else if (cmd == 10008) {
                // Toggle StartOnLogin
                g_cfg.startOnLogin = !g_cfg.startOnLogin;
                WritePrivateProfileStringW(L"General", L"StartOnLogin", g_cfg.startOnLogin ? L"true" : L"false", g_cfg.iniPath);
                // Update registry Run entry immediately
                WCHAR exePath[MAX_PATH]; GetModuleFileNameW(NULL, exePath, ARRAYSIZE(exePath));
                WCHAR cmdline[2048];
                if (g_cfg.iniPath[0]) wsprintfW(cmdline, L"\"%s\" --config \"%s\"", exePath, g_cfg.iniPath);
                else wsprintfW(cmdline, L"\"%s\"", exePath);
                WCHAR runValName[64]; lstrcpynW(runValName, L"WinMac Menu", ARRAYSIZE(runValName));
                if (g_cfg.startOnLogin) set_run_at_login(runValName, cmdline); else remove_run_at_login(runValName);
            } else if (cmd == 10009) {
                // Toggle ShowIcons (legacy icons in menu)
                g_cfg.showIcons = !g_cfg.showIcons;
                WritePrivateProfileStringW(L"General", L"ShowIcons", g_cfg.showIcons ? L"true" : L"false", g_cfg.iniPath);
            } else if (cmd == 10005) {
                // Show settings dialog (replaces opening raw INI)
                Config before = g_cfg; // snapshot
                if (ShowSettingsDialog(hWnd, &g_cfg)) {
                    // Apply changes that need runtime updates
                    g_runInBackground = g_cfg.runInBackground;
                    if (g_cfg.showTrayIcon != before.showTrayIcon) {
                        if (g_cfg.showTrayIcon) tray_add(hWnd); else tray_remove(hWnd);
                    } else if (g_cfg.showTrayIcon) {
                        // Reload to reflect possible theme/tooltip changes
                        tray_reload(hWnd);
                    }
                }
            } else if (cmd == 10011) {
                ShellExecuteW(NULL, L"open", g_cfg.iniPath, NULL, NULL, SW_SHOWNORMAL);
            } else if (cmd == 10006) {
                ShellExecuteW(NULL, L"open", L"https://github.com/Asteski/WinMac-Menu/wiki", NULL, NULL, SW_SHOWNORMAL);
            } else if (cmd == 10007) {
                // About dialog using custom application icon instead of default information icon.
                // Switching from MessageBoxW to MessageBoxIndirectW with MB_USERICON allows specifying IDI_APPICON.
                WCHAR msg[512];
                wsprintfW(msg, L"WinMac\r\nVersion: v1.4.0\r\n\r\nWinMac Menu\r\nVersion: v0.8.0\r\n\r\n\u00A9 2025 Asteski\r\nhttps://github.com/Asteski");
                MSGBOXPARAMSW mbp = {0};
                mbp.cbSize = sizeof(mbp);
                mbp.hwndOwner = hWnd;
                mbp.hInstance = GetModuleHandleW(NULL);
                mbp.lpszText = msg;
                mbp.lpszCaption = L"About WinMac";
                mbp.dwStyle = MB_OK | MB_USERICON; // custom icon style
                mbp.lpszIcon = MAKEINTRESOURCEW(IDI_ABOUT_ICON); // use about-specific icon resource
                mbp.dwLanguageId = MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT);
                MessageBoxIndirectW(&mbp);
            } else if (cmd == 10002) {
                PostMessageW(hWnd, WM_CLOSE, 0, 0);
            }
            return 0;
        }
    }
    // Original message handling follows
    switch (msg) {
    case WM_MENUCHAR:
    {
        // Make pressing the first letter execute the item immediately.
        // wParam low word is the character, high word has flags.
        WCHAR ch = (WCHAR)LOWORD(wParam);
        HMENU hMenu = (HMENU)lParam; // actually the menu handle in some contexts
        if (hMenu) {
            int count = GetMenuItemCount(hMenu);
            for (int i = 0; i < count; ++i) {
                WCHAR text[256];
                GetMenuStringW(hMenu, i, text, ARRAYSIZE(text), MF_BYPOSITION);
                if (text[0] == L'&') {
                    // Skip ampersand accelerator
                    if (towlower(text[1]) == towlower(ch)) {
                        // Return the command id
                        UINT id = GetMenuItemID(hMenu, i);
                        return MAKELRESULT(id, MNC_EXECUTE);
                    }
                } else if (towlower(text[0]) == towlower(ch)) {
                    UINT id = GetMenuItemID(hMenu, i);
                    return MAKELRESULT(id, MNC_EXECUTE);
                }
            }
        }
        return MAKELRESULT(0, MNC_CLOSE);
    }
    case WM_RBUTTONUP:
    case WM_MBUTTONUP:
    {
        if (g_menuActive) return 0;
        g_menuActive = TRUE;
        g_menuShowingNow = TRUE;
        install_menu_hooks(hWnd);
        POINT pt = {0,0};
        ShowWinXMenu(hWnd, pt);
        uninstall_menu_hooks();
        g_menuShowingNow = FALSE;
        g_menuActive = FALSE;
        return 0;
    }
    case WM_LBUTTONUP:
    {
        if (g_menuActive) return 0;
        g_menuActive = TRUE;
        g_menuShowingNow = TRUE;
        install_menu_hooks(hWnd);
        POINT pt = {0,0};
        ShowWinXMenu(hWnd, pt);
        uninstall_menu_hooks();
        g_menuShowingNow = FALSE;
        g_menuActive = FALSE;
        return 0;
    }
    case WM_KEYDOWN:
        if (wParam == VK_APPS || (wParam == 'X' && (GetKeyState(VK_LWIN) & 0x8000))) {
            POINT pt = {0,0};
            ShowWinXMenu(hWnd, pt);
            return 0;
        }
        break;
    case WM_COMMAND:
        // Handle CLI commands
        if (LOWORD(wParam) == 10010) {
            // Reload command from CLI
            WCHAR exePath[MAX_PATH]; GetModuleFileNameW(NULL, exePath, ARRAYSIZE(exePath));
            WCHAR cmdline[4096];
            if (g_cfg.iniPath[0]) wsprintfW(cmdline, L"\"%s\" --config \"%s\"", exePath, g_cfg.iniPath);
            else wsprintfW(cmdline, L"\"%s\"", exePath);
            STARTUPINFOW si = { sizeof(si) }; PROCESS_INFORMATION pi = {0};
            if (CreateProcessW(exePath, cmdline, NULL, NULL, FALSE, 0, NULL, NULL, &si, &pi)) {
                CloseHandle(pi.hThread); CloseHandle(pi.hProcess);
                if (g_hSingleInstance) { ReleaseMutex(g_hSingleInstance); CloseHandle(g_hSingleInstance); g_hSingleInstance = NULL; }
                PostMessageW(hWnd, WM_CLOSE, 0, 0);
            }
            return 0;
        } else if (LOWORD(wParam) == 10005) {
            // Settings command from CLI
            Config before = g_cfg; // snapshot
            if (ShowSettingsDialog(hWnd, &g_cfg)) {
                // Apply changes that need runtime updates
                g_runInBackground = g_cfg.runInBackground;
                if (g_cfg.showTrayIcon != before.showTrayIcon) {
                    if (g_cfg.showTrayIcon) tray_add(hWnd); else tray_remove(hWnd);
                } else if (g_cfg.showTrayIcon) {
                    // Reload to reflect possible theme/tooltip changes
                    tray_reload(hWnd);
                }
            }
            return 0;
        } else if (LOWORD(wParam) == 10011) {
            // Open ini file command
            ShellExecuteW(NULL, L"open", g_cfg.iniPath, NULL, NULL, SW_SHOWNORMAL);
            return 0;
        }
        MenuExecuteCommand(hWnd, (UINT)LOWORD(wParam));
        return 0;
    case WM_APP:
        // Toggle behavior: if menu visible, close it; else open it.
        if (g_menuShowingNow) {
            EndMenu(); // dismiss current popup
            return 0;
        } else if (!g_menuActive) {
            g_menuActive = TRUE; g_menuShowingNow = TRUE;
            install_menu_hooks(hWnd);
            POINT pt = {0,0};
            ShowWinXMenu(hWnd, pt);
            uninstall_menu_hooks();
            g_menuShowingNow = FALSE; g_menuActive = FALSE;
            return 0;
        }
        return 0;
    case WM_MENUSELECT:
        MenuOnMenuSelect(hWnd, wParam, lParam);
        return 0;
    case WM_INITMENUPOPUP:
        MenuOnInitMenuPopup(hWnd, (HMENU)wParam, LOWORD(lParam), HIWORD(lParam));
        return 0;
    case WM_MEASUREITEM:
        if (MenuOnMeasureItem(hWnd, (MEASUREITEMSTRUCT*)lParam)) return TRUE;
        break;
    case WM_DRAWITEM:
        if (MenuOnDrawItem(hWnd, (const DRAWITEMSTRUCT*)lParam)) return TRUE;
        break;
    }
    return DefWindowProc(hWnd, msg, wParam, lParam);
}

// Forward declarations for CLI functions
static BOOL cli_list_sessions(OutputFormat outputFormat);
static BOOL cli_reload_pid(DWORD pid);
static BOOL cli_shutdown_pid(DWORD pid);
static BOOL cli_settings_pid(DWORD pid);
static BOOL cli_open_ini_pid(DWORD pid);
static void cli_show_help(void);
static BOOL find_winmacmenu_window_by_pid(DWORD pid, HWND* outHwnd, WCHAR* outTitle, size_t titleSize);

// Parse command line arguments
static BOOL parse_cli_args(CliArgs* args) {
    ZeroMemory(args, sizeof(*args));
    args->mode = CLI_MODE_NORMAL;
    args->outputFormat = OUTPUT_FORMAT_LIST; // Default format
    
    int argc = 0;
    LPWSTR* argv = CommandLineToArgvW(GetCommandLineW(), &argc);
    if (!argv) return FALSE;
    
    BOOL result = TRUE;
    
    for (int i = 1; i < argc; ++i) {
        if (!lstrcmpiW(argv[i], L"--config") && i + 1 < argc) {
            lstrcpynW(args->configPath, argv[i + 1], ARRAYSIZE(args->configPath));
            ++i; // Skip next argument
        }
        else if (!lstrcmpiW(argv[i], L"--list") || !lstrcmpiW(argv[i], L"-l")) {
            args->mode = CLI_MODE_LIST;
        }
        else if ((!lstrcmpiW(argv[i], L"--reload") || !lstrcmpiW(argv[i], L"-r")) && i + 1 < argc) {
            args->mode = CLI_MODE_RELOAD;
            args->targetPid = _wtoi(argv[i + 1]);
            if (args->targetPid == 0) {
                wprintf(L"Error: Invalid PID '%s' for %s\n", argv[i + 1], argv[i]);
                result = FALSE;
                break;
            }
            ++i; // Skip next argument
        }
        else if ((!lstrcmpiW(argv[i], L"--shutdown") || !lstrcmpiW(argv[i], L"-k")) && i + 1 < argc) {
            args->mode = CLI_MODE_SHUTDOWN;
            args->targetPid = _wtoi(argv[i + 1]);
            if (args->targetPid == 0) {
                wprintf(L"Error: Invalid PID '%s' for %s\n", argv[i + 1], argv[i]);
                result = FALSE;
                break;
            }
            ++i; // Skip next argument
        }
        else if ((!lstrcmpiW(argv[i], L"--settings") || !lstrcmpiW(argv[i], L"-s")) && i + 1 < argc) {
            args->mode = CLI_MODE_SETTINGS;
            args->targetPid = _wtoi(argv[i + 1]);
            if (args->targetPid == 0) {
                wprintf(L"Error: Invalid PID '%s' for %s\n", argv[i + 1], argv[i]);
                result = FALSE;
                break;
            }
            ++i; // Skip next argument
        }
        else if ((!lstrcmpiW(argv[i], L"--open-ini") || !lstrcmpiW(argv[i], L"-o")) && i + 1 < argc) {
            args->mode = CLI_MODE_OPEN_INI;
            args->targetPid = _wtoi(argv[i + 1]);
            if (args->targetPid == 0) {
                wprintf(L"Error: Invalid PID '%s' for %s\n", argv[i + 1], argv[i]);
                result = FALSE;
                break;
            }
            ++i; // Skip next argument
        }
        else if (!lstrcmpiW(argv[i], L"--help") || !lstrcmpiW(argv[i], L"-h") || !lstrcmpiW(argv[i], L"/?")) {
            args->mode = CLI_MODE_HELP;
        }
        else if (!lstrcmpiW(argv[i], L"--output") && i + 1 < argc) {
            if (!lstrcmpiW(argv[i + 1], L"table")) {
                args->outputFormat = OUTPUT_FORMAT_TABLE;
            } else if (!lstrcmpiW(argv[i + 1], L"list")) {
                args->outputFormat = OUTPUT_FORMAT_LIST;
            } else {
                wprintf(L"Error: Invalid output format '%s'. Valid options: table, list\n", argv[i + 1]);
                result = FALSE;
                break;
            }
            ++i; // Skip next argument
        }
    }
    
    LocalFree(argv);
    return result;
}

int APIENTRY wWinMain(HINSTANCE hInstance, HINSTANCE hPrev, LPWSTR lpCmdLine, int nCmdShow) {
    // Parse command line arguments
    CliArgs cliArgs;
    if (!parse_cli_args(&cliArgs)) {
        return 1; // Error in parsing
    }
    
    // Handle CLI modes
    if (cliArgs.mode != CLI_MODE_NORMAL) {
        // Try to attach to parent console first, then allocate if needed
        BOOL hasConsole = FALSE;
        if (AttachConsole(ATTACH_PARENT_PROCESS)) {
            hasConsole = TRUE;
        } else if (AllocConsole()) {
            hasConsole = TRUE;
        }
        
        if (hasConsole) {
            // Redirect stdout and stderr to console
            FILE* pCout;
            FILE* pCerr;
            freopen_s(&pCout, "CONOUT$", "w", stdout);
            freopen_s(&pCerr, "CONOUT$", "w", stderr);
            SetConsoleOutputCP(CP_UTF8);
        }
        
        BOOL success = FALSE;
        switch (cliArgs.mode) {
            case CLI_MODE_LIST:
                success = cli_list_sessions(cliArgs.outputFormat);
                break;
            case CLI_MODE_RELOAD:
                success = cli_reload_pid(cliArgs.targetPid);
                break;
            case CLI_MODE_SHUTDOWN:
                success = cli_shutdown_pid(cliArgs.targetPid);
                break;
            case CLI_MODE_SETTINGS:
                success = cli_settings_pid(cliArgs.targetPid);
                break;
            case CLI_MODE_OPEN_INI:
                success = cli_open_ini_pid(cliArgs.targetPid);
                break;
            case CLI_MODE_HELP:
                cli_show_help();
                success = TRUE;
                break;
        }
        
        // Flush output
        fflush(stdout);
        fflush(stderr);
        
        // Brief pause to ensure output is visible
        if (hasConsole) {
            Sleep(100);
        }
        
        return success ? 0 : 1;
    }
    
    // Set config path if provided
    if (cliArgs.configPath[0]) {
        config_set_default_path(cliArgs.configPath);
    }

    // Single instance per config remains enforced via mutex hash of ini path.
    Config tmp = {0}; config_ensure(&tmp);
    DWORD h = simple_hash_w(tmp.iniPath);
    wchar_t mname[128]; wsprintfW(mname, L"Local\\WinMacMenu.SingleInstance.%08X", h);
    g_hSingleInstance = CreateMutexW(NULL, TRUE, mname);
    if (g_hSingleInstance && GetLastError() == ERROR_ALREADY_EXISTS) {
        // Another instance with SAME config exists: find its window title for this config and signal.
        wchar_t title[260]; build_window_title(&tmp, title, ARRAYSIZE(title));
        HWND hExisting = NULL;
        for (int i = 0; i < 10; ++i) { // retry up to ~1s to allow window creation
            hExisting = FindWindowW(WC_APPWND, title);
            if (hExisting) break;
            Sleep(100);
        }
        if (hExisting) PostMessageW(hExisting, WM_APP, 0, 0);
        return 0; // exit; other instance will handle showing menu
    }
    // DPI awareness for crisp menu sizing
    HMODULE hShcore = LoadLibraryW(L"Shcore.dll");
    if (hShcore) {
        typedef HRESULT (WINAPI *SetProcessDpiAwareness_t)(int);
        SetProcessDpiAwareness_t fn = (SetProcessDpiAwareness_t)GetProcAddress(hShcore, "SetProcessDpiAwareness");
        if (fn) fn(2 /* PROCESS_PER_MONITOR_DPI_AWARE */);
        FreeLibrary(hShcore);
    }

    // Load config before creating window so tray-add logic has correct flags
    config_load(&g_cfg);
    g_runInBackground = g_cfg.runInBackground;

    WNDCLASSEXW wc = { sizeof(wc) };
    wc.style = CS_DBLCLKS;
    wc.lpfnWndProc = WndProc;
    wc.hInstance = hInstance;
    wc.hCursor = LoadCursor(NULL, IDC_ARROW);
    // Dynamically pick system metrics sizes so on high DPI we request the right resource variant.
    int bigW = GetSystemMetrics(SM_CXICON);
    int bigH = GetSystemMetrics(SM_CYICON);
    int smW  = GetSystemMetrics(SM_CXSMICON);
    int smH  = GetSystemMetrics(SM_CYSMICON);
    wc.hIcon = (HICON)LoadImageW(hInstance, MAKEINTRESOURCEW(IDI_APPICON), IMAGE_ICON, bigW, bigH, LR_DEFAULTCOLOR);
    wc.hIconSm = (HICON)LoadImageW(hInstance, MAKEINTRESOURCEW(IDI_APPICON), IMAGE_ICON, smW, smH, LR_DEFAULTCOLOR);
    if (!wc.hIcon) wc.hIcon = LoadIcon(NULL, IDI_APPLICATION);
    if (!wc.hIconSm) wc.hIconSm = (HICON)CopyImage(wc.hIcon, IMAGE_ICON, 16, 16, 0);
    wc.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
    wc.lpszClassName = WC_APPWND;

    if (!RegisterClassExW(&wc)) return 0;

    wchar_t windowTitle[260]; build_window_title(&g_cfg, windowTitle, ARRAYSIZE(windowTitle));
    HWND hWnd = CreateWindowExW(WS_EX_TOOLWINDOW, WC_APPWND, windowTitle,
        WS_POPUP, CW_USEDEFAULT, CW_USEDEFAULT, 200, 200, NULL, NULL, hInstance, NULL);
    if (!hWnd) return 0;
    g_hMainWnd = hWnd;

    // Command line parsing already done above (for mutex)
    // Honor StartOnLogin by setting/removing HKCU Run entry for this config
    // Use per-config value name so multiple configs won't collide
    // Startup Apps title: friendly value name
    wchar_t runValName[64]; lstrcpynW(runValName, L"WinMac Menu", ARRAYSIZE(runValName));
    // Build command line: quoted exe path plus optional --config "path"
    WCHAR exePath[MAX_PATH]; GetModuleFileNameW(NULL, exePath, ARRAYSIZE(exePath));
    WCHAR cmd[2048];
    if (g_cfg.iniPath[0]) {
        wsprintfW(cmd, L"\"%s\" --config \"%s\"", exePath, g_cfg.iniPath);
    } else {
        wsprintfW(cmd, L"\"%s\"", exePath);
    }
    if (g_cfg.startOnLogin) {
        set_run_at_login(runValName, cmd);
    } else {
        remove_run_at_login(runValName);
    }
    g_runInBackground = g_cfg.runInBackground;
    // TaskbarCreated broadcast to detect Explorer restarts
    g_msgTaskbarCreated = RegisterWindowMessageW(L"TaskbarCreated");

    if (g_runInBackground) {
        // Initialize taskbar hook to intercept start button clicks
        if (!InitTaskbarHook()) {
            OutputDebugStringW(L"Warning: Failed to initialize taskbar hook\n");
        }
        
        // Register Windows key hotkey if the action is not to show Windows menu
        if (g_cfg.windowsKeyAction != CA_WINDOWS_MENU) {
            g_winKeyHotkeyId = GlobalAddAtom(L"WinMacMenu.WinKey");
            if (g_winKeyHotkeyId && RegisterHotKey(hWnd, g_winKeyHotkeyId, MOD_WIN, 0)) {
                OutputDebugStringW(L"Windows key hotkey registered successfully\n");
            } else {
                OutputDebugStringW(L"Warning: Failed to register Windows key hotkey\n");
                if (g_winKeyHotkeyId) {
                    GlobalDeleteAtom(g_winKeyHotkeyId);
                    g_winKeyHotkeyId = 0;
                }
            }
        }
        
        // Optionally show menu on first launch
        if (g_cfg.showOnLaunch) {
            POINT pt = {0,0};
            g_menuActive = TRUE; g_menuShowingNow = TRUE;
            install_menu_hooks(hWnd);
            ShowWinXMenu(hWnd, pt);
            uninstall_menu_hooks();
            g_menuShowingNow = FALSE; g_menuActive = FALSE;
        }
        // Message loop
        MSG msg;
        while (GetMessageW(&msg, NULL, 0, 0)) {
            TranslateMessage(&msg);
            DispatchMessageW(&msg);
        }
        // Cleanup
        ShutdownTaskbarHook();
        if (g_winKeyHotkeyId) {
            UnregisterHotKey(hWnd, g_winKeyHotkeyId);
            GlobalDeleteAtom(g_winKeyHotkeyId);
            g_winKeyHotkeyId = 0;
        }
        if (g_hSingleInstance) { CloseHandle(g_hSingleInstance); g_hSingleInstance = NULL; }
        return 0;
    } else {
        // One-shot mode: show menu and exit as before
        POINT pt = {0,0};
        ShowWinXMenu(hWnd, pt);
        DestroyWindow(hWnd);
        if (g_hSingleInstance) { CloseHandle(g_hSingleInstance); g_hSingleInstance = NULL; }
        return 0;
    }
}
