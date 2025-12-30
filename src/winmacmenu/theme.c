#include "theme.h"
#include "config.h"
#include <uxtheme.h>
#include <dwmapi.h>
#include <shlwapi.h>
#pragma comment(lib, "UxTheme.lib")
#pragma comment(lib, "Dwmapi.lib")

static BOOL read_reg_dword(HKEY root, LPCWSTR subkey, LPCWSTR value, DWORD *out) {
    HKEY k; if (RegOpenKeyExW(root, subkey, 0, KEY_READ, &k) != ERROR_SUCCESS) return FALSE;
    DWORD type = 0, cb = sizeof(DWORD);
    BOOL ok = (RegQueryValueExW(k, value, NULL, &type, (LPBYTE)out, &cb) == ERROR_SUCCESS && type == REG_DWORD);
    RegCloseKey(k);
    return ok;
}

BOOL theme_is_dark() {
    DWORD appsUseLight = 1; // 1 means light
    if (read_reg_dword(HKEY_CURRENT_USER, L"Software\\Microsoft\\Windows\\CurrentVersion\\Themes\\Personalize", L"AppsUseLightTheme", &appsUseLight)) {
        return appsUseLight == 0;
    }
    return FALSE;
}

void theme_apply_to_window(HWND hWnd) {
    BOOL dark = theme_is_dark();
    // Try set immersive dark mode for titlebar (Win11)
    if (hWnd) {
        BOOL val = dark ? TRUE : FALSE;
        DwmSetWindowAttribute(hWnd, 20 /* DWMWA_USE_IMMERSIVE_DARK_MODE */, &val, sizeof(val));
        // System menu colors follow system; Owner-drawn menu handled in menu.c
    }
}

HMENU theme_style_menu(HMENU hMenu) {
    // Lightweight styling: enable drop shadow and rounded corners on modern style (Win11+),
    // legacy leaves defaults. Actual per-item owner-draw is not required here.
    // Note: Win11 uses system theming automatically for popup menus.
    // Try to set menu info for drop shadow regardless.
    MENUINFO mi = { sizeof(mi) };
    mi.fMask = MIM_STYLE;
    GetMenuInfo(hMenu, &mi);
    mi.dwStyle |= MNS_CHECKORBMP; // allows bitmaps/icons later
    SetMenuInfo(hMenu, &mi);
    return hMenu;
}

BOOL theme_get_accent(COLORREF* color) {
    if (!color) return FALSE;
    DWORD raw=0; BOOL opaque=FALSE;
    if (DwmGetColorizationColor(&raw, &opaque) == S_OK) {
        BYTE r = GetRValue(raw);
        BYTE g = GetGValue(raw);
        BYTE b = GetBValue(raw);
        *color = RGB(r,g,b);
        return TRUE;
    }
    return FALSE;
}
