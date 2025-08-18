// Clean implementation of menu building and handlers (sorting removed, visibility filters kept)

#include <windows.h>
#include <shellapi.h>
#include <shlwapi.h>
#include "menu.h"
#include "config.h"
#include "recent.h"
#include "util.h"
#include "theme.h"

#ifndef ARRAYSIZE
#define ARRAYSIZE(a) (sizeof(a)/sizeof((a)[0]))
#endif

#define IDM_DYNAMIC_BASE  1000
#define IDM_RECENT_BASE   2000
#define IDM_FOLDER_BASE   5000
#define IDM_SIZER         9000

typedef struct MapEntry {
    UINT id;
    WCHAR path[MAX_PATH];
} MapEntry;

typedef struct FolderMenuData {
    WCHAR path[MAX_PATH];
    int depth;
} FolderMenuData;

static Config g_cfg; // loaded on demand
static MapEntry g_map[4096];
static UINT g_mapCount = 0;
static UINT g_nextFolderId = IDM_FOLDER_BASE;
typedef struct ItemIcon { UINT id; HICON h; } ItemIcon;
static ItemIcon g_itemIcons[256];
static UINT g_itemIconCount = 0;
typedef struct ItemBmp { UINT id; HBITMAP hbmp; } ItemBmp;
static ItemBmp g_itemBmps[256];
static UINT g_itemBmpCount = 0;
// Forward declarations for legacy icon helpers
static HBITMAP icon_to_hbmp(HICON hico, int cx, int cy);
static void assign_legacy_item_bitmap(HMENU hMenu, UINT id, HICON hico);
static void add_item_icon(UINT id, HICON h) {
    if (!h) return;
    for (UINT i=0;i<g_itemIconCount;i++) if (g_itemIcons[i].id==id) { g_itemIcons[i].h=h; return; }
    if (g_itemIconCount < ARRAYSIZE(g_itemIcons)) { g_itemIcons[g_itemIconCount++] = (ItemIcon){ id, h }; }
}
static HICON get_item_icon(UINT id) {
    for (UINT i=0;i<g_itemIconCount;i++) if (g_itemIcons[i].id==id) return g_itemIcons[i].h;
    return NULL;
}

static void map_add(UINT id, const WCHAR* path) {
    if (g_mapCount < ARRAYSIZE(g_map)) {
        g_map[g_mapCount].id = id;
        lstrcpynW(g_map[g_mapCount].path, path, ARRAYSIZE(g_map[g_mapCount].path));
        g_mapCount++;
    }
}

static void attach_menu_data(HMENU hMenu, const WCHAR* path, int depth) {
    FolderMenuData* data = (FolderMenuData*)LocalAlloc(LMEM_FIXED|LMEM_ZEROINIT, sizeof(FolderMenuData));
    if (!data) return;
    lstrcpynW(data->path, path, ARRAYSIZE(data->path));
    data->depth = depth;
    MENUINFO mi = { sizeof(mi) };
    mi.fMask = MIM_MENUDATA;
    mi.dwMenuData = (ULONG_PTR)data;
    SetMenuInfo(hMenu, &mi);
}

// Escape '&' so the label doesn't get treated as an accelerator and lose characters
static void escape_ampersands(const WCHAR* in, WCHAR* out, size_t cchOut) {
    size_t oi = 0;
    for (size_t i = 0; in && in[i] && oi + 1 < cchOut; ++i) {
        if (in[i] == L'&') {
            if (oi + 2 >= cchOut) break;
            out[oi++] = L'&';
            out[oi++] = L'&';
        } else {
            out[oi++] = in[i];
        }
    }
    out[oi] = 0;
}

static HMENU build_recent_submenu(void) {
    HMENU sub = CreatePopupMenu();
    RecentItem* items = NULL;
    int maxItems = (g_cfg.recentMax > 0 ? g_cfg.recentMax : 12);
    int n = recent_get_items(&items, maxItems);
    if (n <= 0) {
        AppendMenuW(sub, MF_STRING | MF_GRAYED, 0, L"(None)");
        if (items) LocalFree(items);
        return sub;
    }
    for (int i = 0; i < n; ++i) {
        if (!items[i].path[0]) continue; // skip invalid entries
        const WCHAR* p = wcsrchr(items[i].path, L'\\');
        const WCHAR* name = p ? p + 1 : items[i].path;
        const WCHAR* toShow = g_cfg.recentShowFullPath ? items[i].path : name;
        if (!toShow || !toShow[0]) continue;
        WCHAR label[512];
        escape_ampersands(toShow, label, ARRAYSIZE(label));
        UINT id = IDM_RECENT_BASE + i;
        AppendMenuW(sub, MF_STRING, id, label);
        // Map the command to its exact path to avoid re-enumeration drift on click
        map_add(id, items[i].path);
    }
    if (items) LocalFree(items);
    return sub;
}

static void get_name_from_path(const WCHAR* full, WCHAR* name, size_t cch) {
    const WCHAR* p = wcsrchr(full, L'\\');
    lstrcpynW(name, p ? p + 1 : full, (int)cch);
}

// Populate a folder submenu lazily (filters only, no sorting)
static void populate_folder_menu(HMENU parent, const FolderMenuData* data) {
    if (!data) return;
    int initialCount = GetMenuItemCount(parent);
    if (initialCount > 0) {
        WCHAR txt[32];
        GetMenuStringW(parent, 0, txt, ARRAYSIZE(txt), MF_BYPOSITION);
        if (lstrcmpW(txt, L"(Loading...)") != 0 && lstrcmpW(txt, L"(Empty)") != 0) {
            return; // already populated
        }
        while (GetMenuItemCount(parent) > 0) DeleteMenu(parent, 0, MF_BYPOSITION);
    }

    if (g_cfg.folderSingleClickOpen) {
        WCHAR name[260]; get_name_from_path(data->path, name, ARRAYSIZE(name));
        WCHAR label[300]; wsprintfW(label, L"Open %s", name);
        AppendMenuW(parent, MF_STRING, g_nextFolderId, label); map_add(g_nextFolderId++, data->path);
        AppendMenuW(parent, MF_SEPARATOR, 0, NULL);
    }

    WIN32_FIND_DATAW fd; WCHAR pattern[MAX_PATH];
    PathCombineW(pattern, data->path, L"*");
    HANDLE h = FindFirstFileExW(pattern, FindExInfoBasic, &fd, FindExSearchNameMatch, NULL, FIND_FIRST_EX_LARGE_FETCH);
    if (h == INVALID_HANDLE_VALUE) {
        AppendMenuW(parent, MF_STRING | MF_GRAYED, 0, L"(Empty)");
        return;
    }
    BOOL any = FALSE;
    do {
        if (!lstrcmpW(fd.cFileName, L".") || !lstrcmpW(fd.cFileName, L"..")) continue;
        if (!g_cfg.showHidden && (fd.dwFileAttributes & FILE_ATTRIBUTE_HIDDEN)) continue;
        if (!g_cfg.showDotfiles && fd.cFileName[0] == L'.') continue;
        WCHAR full[MAX_PATH]; PathCombineW(full, data->path, fd.cFileName);
        if (fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) {
            WCHAR name[260]; get_name_from_path(full, name, ARRAYSIZE(name));
            if (data->depth < g_cfg.folderMaxDepth) {
                HMENU sub = CreatePopupMenu();
                AppendMenuW(sub, MF_STRING | MF_GRAYED, 0, L"(Loading...)");
                attach_menu_data(sub, full, data->depth + 1);
                AppendMenuW(parent, MF_POPUP, (UINT_PTR)sub, name);
                MENUITEMINFOW mii = { sizeof(mii) };
                mii.fMask = MIIM_DATA | MIIM_SUBMENU;
                mii.dwItemData = (ULONG_PTR)LocalAlloc(LMEM_FIXED, (lstrlenW(full) + 1) * sizeof(WCHAR));
                if (mii.dwItemData) lstrcpyW((LPWSTR)mii.dwItemData, full);
                mii.hSubMenu = sub;
                int pos = GetMenuItemCount(parent) - 1;
                SetMenuItemInfoW(parent, pos, TRUE, &mii);
            } else {
                AppendMenuW(parent, MF_STRING, g_nextFolderId, name); map_add(g_nextFolderId++, full);
            }
        } else {
            WCHAR name[260]; get_name_from_path(full, name, ARRAYSIZE(name));
            AppendMenuW(parent, MF_STRING, g_nextFolderId, name); map_add(g_nextFolderId++, full);
        }
        any = TRUE;
    } while (FindNextFileW(h, &fd));
    FindClose(h);
    if (!any) AppendMenuW(parent, MF_STRING | MF_GRAYED, 0, L"(Empty)");
}

static HMENU build_menu(void) {
    config_load(&g_cfg);
    HMENU hMenu = CreatePopupMenu();
    g_mapCount = 0; // reset mapping for this menu build
    g_nextFolderId = IDM_FOLDER_BASE;
    UINT id = IDM_DYNAMIC_BASE;
    for (int i = 0; i < g_cfg.count; ++i) {
        ConfigItem* it = &g_cfg.items[i];
        switch (it->type) {
        case CI_SEPARATOR:
            AppendMenuW(hMenu, MF_SEPARATOR, 0, NULL);
            break;
        case CI_URI:
        case CI_FILE:
        case CI_CMD:
        {
            AppendMenuW(hMenu, MF_STRING, id, it->label[0] ? it->label : it->path);
            // Pick icon path: per-item or default
            const WCHAR* ipath = NULL;
            if (it->iconPath[0]) ipath = it->iconPath;
            else if (g_cfg.defaultIconPath[0]) ipath = g_cfg.defaultIconPath;
            if (ipath) {
                HICON hico = (HICON)LoadImageW(NULL, ipath, IMAGE_ICON, 16, 16, LR_LOADFROMFILE|LR_SHARED);
                add_item_icon(id, hico);
                if (g_cfg.menuStyle == STYLE_LEGACY && g_cfg.legacyIcons) assign_legacy_item_bitmap(hMenu, id, hico);
            }
            id++;
            break;
        }
            break;
        case CI_FOLDER:
        {
            if (it->submenu) {
                HMENU sub = CreatePopupMenu();
                AppendMenuW(sub, MF_STRING | MF_GRAYED, 0, L"(Loading...)");
                attach_menu_data(sub, it->path, 1);
                AppendMenuW(hMenu, MF_POPUP, (UINT_PTR)sub, it->label[0] ? it->label : it->path);
                MENUITEMINFOW mii = { sizeof(mii) };
                mii.fMask = MIIM_DATA | MIIM_SUBMENU;
                mii.dwItemData = (ULONG_PTR)LocalAlloc(LMEM_FIXED, (lstrlenW(it->path) + 1) * sizeof(WCHAR));
                if (mii.dwItemData) lstrcpyW((LPWSTR)mii.dwItemData, it->path);
                mii.hSubMenu = sub;
                int pos = GetMenuItemCount(hMenu) - 1;
                SetMenuItemInfoW(hMenu, pos, TRUE, &mii);
            } else {
                AppendMenuW(hMenu, MF_STRING, id, it->label[0] ? it->label : it->path);
                const WCHAR* ipath = NULL;
                if (it->iconPath[0]) ipath = it->iconPath;
                else if (g_cfg.defaultIconPath[0]) ipath = g_cfg.defaultIconPath;
                if (ipath) {
                    HICON hico = (HICON)LoadImageW(NULL, ipath, IMAGE_ICON, 16, 16, LR_LOADFROMFILE|LR_SHARED);
                    add_item_icon(id, hico);
                    if (g_cfg.menuStyle == STYLE_LEGACY && g_cfg.legacyIcons) assign_legacy_item_bitmap(hMenu, id, hico);
                }
                id++;
            }
            break;
        }
        case CI_FOLDER_SUBMENU:
        {
            HMENU sub = CreatePopupMenu();
            AppendMenuW(sub, MF_STRING | MF_GRAYED, 0, L"(Loading...)");
            attach_menu_data(sub, it->path, 1);
            AppendMenuW(hMenu, MF_POPUP, (UINT_PTR)sub, it->label[0] ? it->label : it->path);
            MENUITEMINFOW mii = { sizeof(mii) };
            mii.fMask = MIIM_DATA | MIIM_SUBMENU;
            mii.dwItemData = (ULONG_PTR)LocalAlloc(LMEM_FIXED, (lstrlenW(it->path) + 1) * sizeof(WCHAR));
            if (mii.dwItemData) lstrcpyW((LPWSTR)mii.dwItemData, it->path);
            mii.hSubMenu = sub;
            int pos = GetMenuItemCount(hMenu) - 1;
            SetMenuItemInfoW(hMenu, pos, TRUE, &mii);
            break;
        }
    case CI_POWER_SLEEP:
    case CI_POWER_SHUTDOWN:
    case CI_POWER_RESTART:
    case CI_POWER_LOCK:
    case CI_POWER_LOGOFF:
            AppendMenuW(hMenu, MF_STRING, id++, it->label);
            break;
    case CI_RECENT_SUBMENU:
        {
            HMENU sub = build_recent_submenu();
            AppendMenuW(hMenu, MF_POPUP, (UINT_PTR)sub, it->label[0] ? it->label : L"Recent Items");
            break;
        }
        }
    }
    theme_style_menu(hMenu);
    if (g_cfg.menuStyle == STYLE_MODERN) {
        // Mark items owner-draw for modern styling
        // forward-declared below
        extern void Menu_SetOwnerDrawRecursive(HMENU m);
        Menu_SetOwnerDrawRecursive(hMenu);
    }
    // No width shim anymore; modern width is controlled in measure/draw, legacy stays native.
    return hMenu;
}

static POINT compute_menu_pos(HWND owner) {
    POINT cursor; GetCursorPos(&cursor);
    HMONITOR mon = MonitorFromPoint(cursor, MONITOR_DEFAULTTONEAREST);
    MONITORINFO mi = { sizeof(mi) };
    GetMonitorInfoW(mon, &mi);

    if (g_cfg.count == 0) config_load(&g_cfg);

    RECT wa = mi.rcWork;
    LONG x = 0, y = 0;
    if (g_cfg.pointerRelative) {
        // Anchor relative to pointer using configured offsets
        x = cursor.x + g_cfg.hOffset;
        y = cursor.y + g_cfg.vOffset;
    } else {
    if (g_cfg.hPlacement == 0) {
        x = wa.left + g_cfg.hOffset;
    } else if (g_cfg.hPlacement == 1) {
        x = wa.left + (wa.right - wa.left) / 2;
    } else {
        x = wa.right - g_cfg.hOffset;
    }
    if (g_cfg.hPlacement == 0 && g_cfg.hOffset < 0) x = wa.left - g_cfg.hOffset;
    if (g_cfg.hPlacement == 2 && g_cfg.hOffset < 0) x = wa.right + g_cfg.hOffset;

    if (g_cfg.vPlacement == 0) {
        y = wa.top + g_cfg.vOffset;
    } else if (g_cfg.vPlacement == 1) {
        y = wa.top + (wa.bottom - wa.top) / 2;
    } else {
        y = wa.bottom - g_cfg.vOffset;
    }
    if (g_cfg.vPlacement == 0 && g_cfg.vOffset < 0) y = wa.top - g_cfg.vOffset;
    if (g_cfg.vPlacement == 2 && g_cfg.vOffset < 0) y = wa.bottom + g_cfg.vOffset;
    }

    if (x < wa.left) x = wa.left;
    if (x > wa.right) x = wa.right;
    if (y < wa.top) y = wa.top;
    if (y > wa.bottom) y = wa.bottom;
    POINT pt = { x, y };
    return pt;
}

void MenuOnMenuSelect(HWND owner, WPARAM wParam, LPARAM lParam) {
    static UINT lastItem = (UINT)-1;
    static DWORD lastTime = 0;
    UINT item = LOWORD(wParam);
    UINT flags = HIWORD(wParam);
    HMENU hMenu = (HMENU)lParam;
    if (!(flags & MF_POPUP)) { return; }
    DWORD now = GetTickCount();
    if (!g_cfg.folderSingleClickOpen && item == lastItem && (now - lastTime) <= GetDoubleClickTime()) {
        MENUITEMINFOW mii = { sizeof(mii) };
        mii.fMask = MIIM_DATA;
        if (GetMenuItemInfoW(hMenu, item, TRUE, &mii) && mii.dwItemData) {
            open_shell_item((LPCWSTR)mii.dwItemData);
        }
    }
    lastItem = item;
    lastTime = now;
}

void MenuOnInitMenuPopup(HWND owner, HMENU hMenu, UINT item, BOOL isSystemMenu) {
    MENUINFO mi = { sizeof(mi) };
    mi.fMask = MIM_MENUDATA;
    if (GetMenuInfo(hMenu, &mi) && mi.dwMenuData) {
        FolderMenuData* data = (FolderMenuData*)mi.dwMenuData;
        populate_folder_menu(hMenu, data);
    }
}

void MenuExecuteCommand(HWND owner, UINT cmd) {
    if (!cmd) return;
    for (UINT i = 0; i < g_mapCount; ++i) {
        if (g_map[i].id == (UINT)cmd) { open_shell_item(g_map[i].path); return; }
    }
    if (cmd >= IDM_RECENT_BASE && cmd < IDM_RECENT_BASE + 1000) {
        // If not mapped (should be mapped), do nothing to avoid System32 fallback
        return;
    }
    UINT id = IDM_DYNAMIC_BASE;
    for (int i = 0; i < g_cfg.count; ++i) {
        ConfigItem* it = &g_cfg.items[i];
        switch (it->type) {
        case CI_SEPARATOR: break;
        case CI_URI:
            if (id == cmd) { open_uri(it->path); return; } id++; break;
        case CI_FILE:
            if (id == cmd) { open_shell_known(L"open", it->path, it->params[0]?it->params:NULL); return; } id++; break;
        case CI_CMD:
            if (id == cmd) { open_shell_known(L"open", L"cmd.exe", it->params[0] ? it->params : it->path); return; } id++; break;
        case CI_FOLDER:
            if (!it->submenu) { if (id == cmd) { open_shell_item(it->path); return; } id++; }
            break;
        case CI_FOLDER_SUBMENU:
            break;
        case CI_POWER_SLEEP:
            if (id == cmd) { system_sleep(); return; } id++; break;
        case CI_POWER_SHUTDOWN:
            if (id == cmd) { system_shutdown(FALSE); return; } id++; break;
        case CI_POWER_RESTART:
            if (id == cmd) { system_shutdown(TRUE); return; } id++; break;
        case CI_POWER_LOCK:
            if (id == cmd) { system_lock(); return; } id++; break;
        case CI_POWER_LOGOFF:
            if (id == cmd) { system_logoff(); return; } id++; break;
        case CI_RECENT_SUBMENU:
            break;
        }
    }
}

void ShowWinXMenu(HWND owner, POINT screenPt) {
    HMENU hMenu = build_menu();
    if (screenPt.x == 0 && screenPt.y == 0) {
        screenPt = compute_menu_pos(owner);
    }
    SetForegroundWindow(owner);
    UINT flags = TPM_RIGHTBUTTON | TPM_LEFTALIGN | TPM_TOPALIGN | TPM_VERPOSANIMATION | TPM_HORIZONTAL | TPM_RETURNCMD;
    int cmd = TrackPopupMenu(hMenu, flags, screenPt.x, screenPt.y, 0, owner, NULL);
    PostMessageW(owner, WM_NULL, 0, 0);
    MenuExecuteCommand(owner, (UINT)cmd);
    DestroyMenu(hMenu);
    PostMessageW(owner, WM_CLOSE, 0, 0);
}

// ===== Modern owner-draw implementation =====

static HFONT get_menu_font() {
    NONCLIENTMETRICSW ncm = { sizeof(ncm) };
    if (SystemParametersInfoW(SPI_GETNONCLIENTMETRICS, sizeof(ncm), &ncm, 0)) {
        return CreateFontIndirectW(&ncm.lfMenuFont);
    }
    return (HFONT)GetStockObject(DEFAULT_GUI_FONT);
}

static COLORREF blend(COLORREF a, COLORREF b, int alpha /*0..255*/) {
    int inv = 255 - alpha;
    int r = (GetRValue(a)*inv + GetRValue(b)*alpha) / 255;
    int g = (GetGValue(a)*inv + GetGValue(b)*alpha) / 255;
    int bl = (GetBValue(a)*inv + GetBValue(b)*alpha) / 255;
    return RGB(r,g,bl);
}

static void draw_chevron(HDC hdc, RECT rc, COLORREF color) {
    // Draw a simple '>' chevron near the right edge
    SetBkMode(hdc, TRANSPARENT);
    SetTextColor(hdc, color);
    WCHAR ch = L'>';
    RECT r = rc; r.left = r.right - 16; // padding for chevron
    DrawTextW(hdc, &ch, 1, &r, DT_SINGLELINE | DT_VCENTER | DT_RIGHT);
}

static int get_item_index_from_dis(const DRAWITEMSTRUCT* dis) {
    HMENU m = (HMENU)dis->hwndItem;
    int count = GetMenuItemCount(m);
    // Prefer stored index when provided (non-zero, within range)
    UINT idx = (UINT)dis->itemData;
    if (idx < (UINT)count) return (int)idx;
    // Fallback: match rectangle
    for (int i = 0; i < count; ++i) {
        RECT r; if (GetMenuItemRect(NULL, m, i, &r)) {
            if (r.top == dis->rcItem.top && r.bottom == dis->rcItem.bottom) return i;
        }
    }
    return -1;
}

static void set_owner_for_menu_item(HMENU m, int i) {
    MENUITEMINFOW mii = { sizeof(mii) };
    mii.fMask = MIIM_FTYPE | MIIM_SUBMENU | MIIM_DATA | MIIM_ID | MIIM_STATE;
    if (!GetMenuItemInfoW(m, i, TRUE, &mii)) return;
    if (mii.fType & MFT_SEPARATOR) return;
    mii.fType |= MFT_OWNERDRAW;
    // Only set positional itemData if not already used (e.g., we use dwItemData to store paths on folder popups)
    if (mii.dwItemData == 0 && mii.hSubMenu == NULL) {
        mii.dwItemData = (ULONG_PTR)i; // local index for lookup
        mii.fMask |= MIIM_DATA;
    }
    SetMenuItemInfoW(m, i, TRUE, &mii);
}

void Menu_SetOwnerDrawRecursive(HMENU m) {
    int count = GetMenuItemCount(m);
    for (int i = 0; i < count; ++i) {
        set_owner_for_menu_item(m, i);
        MENUITEMINFOW mii = { sizeof(mii) };
        mii.fMask = MIIM_SUBMENU;
        if (GetMenuItemInfoW(m, i, TRUE, &mii) && mii.hSubMenu) {
            Menu_SetOwnerDrawRecursive(mii.hSubMenu);
        }
    }
}

BOOL MenuOnMeasureItem(HWND owner, MEASUREITEMSTRUCT* mis) {
    if (mis->CtlType != ODT_MENU) return FALSE;
    // Handle the width sizer (both styles)
    if (mis->itemID == IDM_SIZER) {
        // No longer used
        return FALSE;
    }
    if (g_cfg.menuStyle != STYLE_MODERN) return FALSE;
    // Measure text size
    HMENU m = (HMENU)mis->itemID; // not reliable for menus; use owner window DC
    HDC hdc = GetDC(owner);
    HFONT hf = get_menu_font();
    HFONT old = (HFONT)SelectObject(hdc, hf);
    WCHAR text[512] = L"";
    // Retrieve by scanning rectangle index
    // We don't have DRAWITEMSTRUCT here; measure uses MEASUREITEMSTRUCT, which doesn't give rect.
    // But system calls measure before draw, with itemData we set to index for non-popup items.
    UINT idx = (UINT)mis->itemData;
    int width = 0, height = 0;
    if (idx != 0xFFFFFFFF) {
        // Try to get text via GetMenuString by position using the menu handle stored in CtlID? Not available.
        // As a fallback, pick a reasonable width based on item ID text length later; use a safe default.
    }
    RECT rc = {0,0,1,1};
    // Use a generic sample text to compute height; final width gets adjusted in Draw with DT_CALCRECT
    DrawTextW(hdc, L"Ay", -1, &rc, DT_SINGLELINE | DT_CALCRECT);
    height = (rc.bottom - rc.top);
    int padY = 10; // top/bottom padding
    int minH = 28;
    mis->itemHeight = max(minH, (UINT)(height + padY*2));
    // Width: will be recomputed in Draw via DT_CALCRECT; provide nominal
    // Target width for modern: MenuWidth override (226..255) if set, else DPI-based default (~264 @ 96dpi)
    int w = 0;
    if (g_cfg.menuWidth >= 226 && g_cfg.menuWidth <= 255) {
        // Scale the logical width similarly across DPI to keep perceived width consistent
        HDC sdc = GetDC(owner);
        int dpi = GetDeviceCaps(sdc, LOGPIXELSX);
        ReleaseDC(owner, sdc);
        w = MulDiv(g_cfg.menuWidth, dpi, 96);
    } else {
        HDC sdc = GetDC(owner);
        int dpi = GetDeviceCaps(sdc, LOGPIXELSX);
        ReleaseDC(owner, sdc);
        w = MulDiv(264, dpi, 96);
    }
    mis->itemWidth = w;
    SelectObject(hdc, old);
    if (hf && hf != GetStockObject(DEFAULT_GUI_FONT)) DeleteObject(hf);
    ReleaseDC(owner, hdc);
    return TRUE;
}

BOOL MenuOnDrawItem(HWND owner, const DRAWITEMSTRUCT* dis) {
    if (dis->CtlType != ODT_MENU) return FALSE;
    // The sizer is no longer used
    if (dis->itemID == IDM_SIZER) return FALSE;
    if (g_cfg.menuStyle != STYLE_MODERN) return FALSE;
    HDC hdc = dis->hDC;
    RECT rc = dis->rcItem;
    BOOL selected = (dis->itemState & ODS_SELECTED) != 0;
    BOOL disabled = (dis->itemState & (ODS_DISABLED | ODS_GRAYED)) != 0;
    BOOL dark = theme_is_dark();
    BOOL modern = TRUE;

    COLORREF bg = (dark ? RGB(32,32,32) : RGB(255,255,255));
    COLORREF txt = (dark ? RGB(240,240,240) : RGB(32,32,32));
    COLORREF disTxt = (dark ? RGB(120,120,120) : RGB(160,160,160));
    COLORREF sel = (dark ? RGB(60,60,60) : RGB(230,230,230));

    // Fill background
    HBRUSH hbrBg = CreateSolidBrush(bg);
    FillRect(hdc, &rc, hbrBg);
    DeleteObject(hbrBg);

    // Selection pill
    if (selected && modern) {
        RECT pill = rc;
        pill.left += 6; pill.right -= 6; pill.top += 2; pill.bottom -= 2;
        HBRUSH hbrSel = CreateSolidBrush(sel);
        HBRUSH oldB = (HBRUSH)SelectObject(hdc, hbrSel);
        HPEN hPen = CreatePen(PS_NULL, 0, sel);
        HPEN oldP = (HPEN)SelectObject(hdc, hPen);
        if (g_cfg.roundedCorners) {
            RoundRect(hdc, pill.left, pill.top, pill.right, pill.bottom, 8, 8);
        } else {
            Rectangle(hdc, pill.left, pill.top, pill.right, pill.bottom);
        }
        SelectObject(hdc, oldP); DeleteObject(hPen);
        SelectObject(hdc, oldB); DeleteObject(hbrSel);
    }

    // Discover item index and submenu presence
    HMENU m = (HMENU)dis->hwndItem;
    int idx = get_item_index_from_dis(dis);
    BOOL hasSub = FALSE;
    if (idx >= 0) {
        MENUITEMINFOW mii = { sizeof(mii) };
        mii.fMask = MIIM_SUBMENU;
        if (GetMenuItemInfoW(m, idx, TRUE, &mii)) hasSub = (mii.hSubMenu != NULL);
    }

    // Fetch text by position
    WCHAR text[512] = L"";
    if (idx >= 0) GetMenuStringW(m, idx, text, ARRAYSIZE(text), MF_BYPOSITION);

    // Draw text
    HFONT hf = get_menu_font();
    HFONT oldF = (HFONT)SelectObject(hdc, hf);
    SetBkMode(hdc, TRANSPARENT);
    SetTextColor(hdc, disabled ? disTxt : txt);
    // Optional icon mapped by command ID
    HICON icon = NULL;
    if (idx >= 0) {
        UINT id = GetMenuItemID(m, idx);
        if (id != (UINT)-1) icon = get_item_icon(id);
    }
    int leftPad = 16;
    if (icon) {
        int cx=16, cy=16;
        int x = rc.left + 8; int y = rc.top + ( (rc.bottom-rc.top) - cy )/2;
        DrawIconEx(hdc, x, y, icon, cx, cy, 0, NULL, DI_NORMAL);
        leftPad = 8 + cx + 8;
    }
    RECT trc = rc; trc.left += leftPad; trc.right -= (hasSub ? 20 : 8); // right room for chevron
    DrawTextW(hdc, text, -1, &trc, DT_SINGLELINE | DT_VCENTER | DT_LEFT | DT_END_ELLIPSIS);
    if (hasSub && modern) draw_chevron(hdc, rc, disabled ? disTxt : txt);
    SelectObject(hdc, oldF);
    if (hf && hf != GetStockObject(DEFAULT_GUI_FONT)) DeleteObject(hf);
    return TRUE;
}

// ===== Legacy icons via item bitmaps (no owner-draw) =====
static HBITMAP icon_to_hbmp(HICON hico, int cx, int cy) {
    if (!hico) return NULL;
    BITMAPINFO bmi = {0};
    bmi.bmiHeader.biSize = sizeof(BITMAPINFOHEADER);
    bmi.bmiHeader.biWidth = cx;
    bmi.bmiHeader.biHeight = -cy; // top-down
    bmi.bmiHeader.biPlanes = 1;
    bmi.bmiHeader.biBitCount = 32;
    bmi.bmiHeader.biCompression = BI_RGB;
    void* bits = NULL;
    HDC hdc = GetDC(NULL);
    HBITMAP hbmp = CreateDIBSection(hdc, &bmi, DIB_RGB_COLORS, &bits, NULL, 0);
    if (hbmp) {
        HDC mem = CreateCompatibleDC(hdc);
        HBITMAP old = (HBITMAP)SelectObject(mem, hbmp);
        RECT rc = {0,0,cx,cy};
        HBRUSH hb = CreateSolidBrush(RGB(0,0,0)); // clear to 0
        FillRect(mem, &rc, hb); DeleteObject(hb);
        DrawIconEx(mem, 0, 0, hico, cx, cy, 0, NULL, DI_NORMAL);
        SelectObject(mem, old);
        DeleteDC(mem);
    }
    ReleaseDC(NULL, hdc);
    return hbmp;
}

static void assign_legacy_item_bitmap(HMENU hMenu, UINT id, HICON hico) {
    if (!hico) return;
    HBITMAP hb = icon_to_hbmp(hico, 16, 16);
    if (!hb) return;
    MENUITEMINFOW mii = { sizeof(mii) };
    mii.fMask = MIIM_BITMAP;
    mii.hbmpItem = hb;
    SetMenuItemInfoW(hMenu, id, FALSE, &mii);
    if (g_itemBmpCount < ARRAYSIZE(g_itemBmps)) g_itemBmps[g_itemBmpCount++] = (ItemBmp){ id, hb };
}
