#include "config.h"
#include <shlwapi.h>
#include <shlobj.h>
#include <stdio.h>
#include <wctype.h>

static void write_default_ini(const WCHAR* path) {
    // Create parent folder
    WCHAR parent[MAX_PATH]; lstrcpynW(parent, path, MAX_PATH); PathRemoveFileSpecW(parent); SHCreateDirectoryExW(NULL, parent, NULL);
    // Populate defaults using profile API (handles formatting)
    WritePrivateProfileStringW(L"General", L"RecentMax", L"12", path);
    WritePrivateProfileStringW(L"General", L"RecentLabel", L"filename", path);
    WritePrivateProfileStringW(L"Placement", L"Horizontal", L"right", path);
    WritePrivateProfileStringW(L"Placement", L"HOffset", L"16", path);
    WritePrivateProfileStringW(L"Placement", L"Vertical", L"bottom", path);
    WritePrivateProfileStringW(L"Placement", L"VOffset", L"48", path);
    WritePrivateProfileStringW(L"General", L"FolderSubmenuDepth", L"1", path);
    WritePrivateProfileStringW(L"General", L"FolderSubmenuOpen", L"double", path);
    WritePrivateProfileStringW(L"General", L"MenuStyle", L"modern", path);
    WritePrivateProfileStringW(L"General", L"DefaultIcon", L"", path);
    WritePrivateProfileStringW(L"General", L"LegacyIcons", L"false", path);
    WritePrivateProfileStringW(L"Modern", L"Corners", L"rounded", path);
    // Sorting options omitted (reverted)
    WritePrivateProfileStringW(L"General", L"ShowHidden", L"false", path);
    WritePrivateProfileStringW(L"General", L"ShowDotfiles", L"false", path);
    WritePrivateProfileStringW(L"Placement", L"PointerRelative", L"false", path);
    // Menu
    WritePrivateProfileStringW(L"Menu", L"Item1",  L"Apps and Features|URI|ms-settings:appsfeatures", path);
    WritePrivateProfileStringW(L"Menu", L"Item2",  L"About Windows|FILE|winver.exe", path);
    WritePrivateProfileStringW(L"Menu", L"Item3",  L"Settings|URI|ms-settings:", path);
    WritePrivateProfileStringW(L"Menu", L"Item4",  L"File Explorer|FILE|explorer.exe", path);
    WritePrivateProfileStringW(L"Menu", L"Item5",  L"---|SEPARATOR|", path);
    WritePrivateProfileStringW(L"Menu", L"Item6",  L"Sleep|POWER_SLEEP|", path);
    WritePrivateProfileStringW(L"Menu", L"Item7",  L"Shut down|POWER_SHUTDOWN|", path);
    WritePrivateProfileStringW(L"Menu", L"Item8",  L"Restart|POWER_RESTART|", path);
    WritePrivateProfileStringW(L"Menu", L"Item9",  L"Lock|POWER_LOCK|", path);
    WritePrivateProfileStringW(L"Menu", L"Item10", L"Log off|POWER_LOGOFF|", path);
    WritePrivateProfileStringW(L"Menu", L"Item11", L"---|SEPARATOR|", path);
    WritePrivateProfileStringW(L"Menu", L"Item12", L"Event Viewer|FILE|eventvwr.msc", path);
    WritePrivateProfileStringW(L"Menu", L"Item13", L"Task Scheduler|FILE|taskschd.msc", path);
    WritePrivateProfileStringW(L"Menu", L"Item14", L"Recent Items|RECENT_SUBMENU|", path);
    WritePrivateProfileStringW(L"Menu", L"Item15", L"Task Manager|FILE|taskmgr.exe", path);
    WritePrivateProfileStringW(L"Menu", L"Item16", L"Properties|URI|ms-settings:about", path);
}

static WCHAR g_defaultIniPath[MAX_PATH];

static void exe_config_path(WCHAR* buf, size_t cch) {
    GetModuleFileNameW(NULL, buf, (DWORD)cch);
    PathRemoveFileSpecW(buf);
    PathAppendW(buf, L"config.ini");
}

BOOL config_ensure(Config* out) {
    if (!out) return FALSE;
    if (g_defaultIniPath[0]) {
        lstrcpynW(out->iniPath, g_defaultIniPath, ARRAYSIZE(out->iniPath));
    } else {
        exe_config_path(out->iniPath, MAX_PATH);
    }
    if (!PathFileExistsW(out->iniPath)) {
        write_default_ini(out->iniPath);
    }
    return TRUE;
}

static ConfigItemType parse_type(const WCHAR* s) {
    if (!s) return CI_SEPARATOR;
    if (!lstrcmpiW(s, L"SEPARATOR")) return CI_SEPARATOR;
    if (!lstrcmpiW(s, L"URI")) return CI_URI;
    if (!lstrcmpiW(s, L"FILE")) return CI_FILE;
    if (!lstrcmpiW(s, L"CMD")) return CI_CMD;
    if (!lstrcmpiW(s, L"FOLDER")) return CI_FOLDER;
    if (!lstrcmpiW(s, L"FOLDER_SUBMENU")) return CI_FOLDER_SUBMENU;
    if (!lstrcmpiW(s, L"POWER_SLEEP")) return CI_POWER_SLEEP;
    if (!lstrcmpiW(s, L"POWER_SHUTDOWN")) return CI_POWER_SHUTDOWN;
    if (!lstrcmpiW(s, L"POWER_RESTART")) return CI_POWER_RESTART;
    if (!lstrcmpiW(s, L"POWER_LOCK")) return CI_POWER_LOCK;
    if (!lstrcmpiW(s, L"POWER_LOGOFF")) return CI_POWER_LOGOFF;
    if (!lstrcmpiW(s, L"RECENT_SUBMENU")) return CI_RECENT_SUBMENU;
    return CI_SEPARATOR;
}

// Whitespace helpers for token parsing
static void rtrim_inplace(WCHAR* s) {
    if (!s) return;
    size_t n = wcslen(s);
    while (n > 0 && iswspace((wint_t)s[n-1])) s[--n] = 0;
}

static WCHAR* ltrim_ptr(WCHAR* s) {
    if (!s) return s;
    while (*s && iswspace((wint_t)*s)) ++s;
    return s;
}

// Expand %VAR% environment variables; if expansion fails, fall back to input
static void expand_env(const WCHAR* in, WCHAR* out, size_t cchOut) {
    if (!in || !out || cchOut == 0) return;
    DWORD n = ExpandEnvironmentStringsW(in, out, (DWORD)cchOut);
    if (n == 0 || n > cchOut) {
        // Copy original (truncated) on failure or overflow
        lstrcpynW(out, in, (int)cchOut);
    }
}

static int parse_menu(Config* cfg) {
    cfg->count = 0;
    WCHAR section[] = L"Menu";
    for (int i = 1; i <= 64; ++i) {
        WCHAR key[32]; wsprintfW(key, L"Item%d", i);
        WCHAR line[1024] = {0};
        GetPrivateProfileStringW(section, key, L"", line, ARRAYSIZE(line), cfg->iniPath);
        if (!line[0]) continue;

        // Expected: Label|TYPE|Path|Params(optional)|Icon(optional)
        WCHAR* p = line;
        WCHAR* label = p;
        WCHAR* type = NULL;
        WCHAR* path = NULL;
        WCHAR* params = NULL;
        WCHAR* icon = NULL;
        for (int part=0; part<5; ++part) {
            WCHAR* bar = wcschr(p, L'|');
            if (!bar) {
                if (part==0) { type = L"SEPARATOR"; p = L""; }
                else if (part==1) { type = p; p = L""; }
                else if (part==2) { path = p; p = L""; }
                else if (part==3) { params = p; p = L""; }
                else if (part==4) { icon = p; p = L""; }
                break;
            }
            *bar = 0;
            if (part==0) type = bar+1;
            else if (part==1) path = bar+1;
            else if (part==2) params = bar+1;
            else if (part==3) icon = bar+1;
            p = bar+1;
        }
        // Trim tokens (especially type) to prevent accidental separators due to spaces
    if (label) { label = ltrim_ptr(label); rtrim_inplace(label); }
    if (type)  { type  = ltrim_ptr(type);  rtrim_inplace(type); }
    if (path)  { path  = ltrim_ptr(path);  rtrim_inplace(path); }
    if (params){ params= ltrim_ptr(params);rtrim_inplace(params); }
    if (icon)  { icon  = ltrim_ptr(icon);  rtrim_inplace(icon); }
    ConfigItem* it = &cfg->items[cfg->count++];
    // Expand env vars in label/path/params/icon
    WCHAR tmp[1024];
    expand_env(label, tmp, ARRAYSIZE(tmp));
    lstrcpynW(it->label, tmp, ARRAYSIZE(it->label));
    it->type = parse_type(type);
    if (path) { expand_env(path, tmp, ARRAYSIZE(tmp)); lstrcpynW(it->path, tmp, ARRAYSIZE(it->path)); } else it->path[0]=0;
    if (params) { expand_env(params, tmp, ARRAYSIZE(tmp)); lstrcpynW(it->params, tmp, ARRAYSIZE(it->params)); } else it->params[0]=0;
    if (icon) { expand_env(icon, tmp, ARRAYSIZE(tmp)); lstrcpynW(it->iconPath, tmp, ARRAYSIZE(it->iconPath)); } else it->iconPath[0]=0;
        it->submenu = (it->type == CI_FOLDER_SUBMENU || it->type == CI_RECENT_SUBMENU);
        // Allow FOLDER items to set mode via 4th field: "submenu" or "link"
        if (it->type == CI_FOLDER && it->params[0]) {
            WCHAR pLower[256]; lstrcpynW(pLower, it->params, ARRAYSIZE(pLower));
            for (WCHAR* q=pLower; *q; ++q) *q = (WCHAR)towlower(*q);
            if (wcsstr(pLower, L"submenu")) it->submenu = TRUE;
            else if (wcsstr(pLower, L"link")) it->submenu = FALSE;
        }
        if (cfg->count >= 64) break;
    }
    return cfg->count;
}

static void parse_icons(Config* cfg) {
    // Optional [Icons] section: Icon1..IconN map to Item1..ItemN
    WCHAR section[] = L"Icons";
    for (int i = 1; i <= cfg->count; ++i) {
        WCHAR key[32]; wsprintfW(key, L"Icon%d", i);
        WCHAR path[MAX_PATH] = {0};
        GetPrivateProfileStringW(section, key, L"", path, ARRAYSIZE(path), cfg->iniPath);
        if (path[0]) {
            lstrcpynW(cfg->items[i-1].iconPath, path, ARRAYSIZE(cfg->items[i-1].iconPath));
        }
    }
}

BOOL config_load(Config* out) {
    if (!out) return FALSE;
    config_ensure(out);
    out->recentMax = GetPrivateProfileIntW(L"General", L"RecentMax", 12, out->iniPath);
    WCHAR rlab[32];
    GetPrivateProfileStringW(L"General", L"RecentLabel", L"filename", rlab, ARRAYSIZE(rlab), out->iniPath);
    out->recentShowFullPath = (!lstrcmpiW(rlab, L"fullpath") || !lstrcmpiW(rlab, L"full"));
    out->folderMaxDepth = GetPrivateProfileIntW(L"General", L"FolderSubmenuDepth", 1, out->iniPath);
    if (out->folderMaxDepth < 1) out->folderMaxDepth = 1; if (out->folderMaxDepth > 4) out->folderMaxDepth = 4;
    WCHAR buf[32];
    GetPrivateProfileStringW(L"General", L"FolderSubmenuOpen", L"double", buf, ARRAYSIZE(buf), out->iniPath);
    out->folderSingleClickOpen = (!lstrcmpiW(buf, L"single")) ? TRUE : FALSE;
    // Sorting options omitted (reverted)
    GetPrivateProfileStringW(L"General", L"ShowHidden", L"false", buf, ARRAYSIZE(buf), out->iniPath);
    out->showHidden = (!lstrcmpiW(buf, L"true") || !lstrcmpiW(buf, L"1"));
    GetPrivateProfileStringW(L"General", L"ShowDotfiles", L"false", buf, ARRAYSIZE(buf), out->iniPath);
    out->showDotfiles = (!lstrcmpiW(buf, L"true") || !lstrcmpiW(buf, L"1"));
    GetPrivateProfileStringW(L"General", L"MenuStyle", L"modern", buf, ARRAYSIZE(buf), out->iniPath);
    out->menuStyle = (!lstrcmpiW(buf, L"legacy")) ? 0 : 1;
    GetPrivateProfileStringW(L"General", L"DefaultIcon", L"", out->defaultIconPath, ARRAYSIZE(out->defaultIconPath), out->iniPath);
    GetPrivateProfileStringW(L"General", L"LegacyIcons", L"false", buf, ARRAYSIZE(buf), out->iniPath);
    out->legacyIcons = (!lstrcmpiW(buf, L"true") || !lstrcmpiW(buf, L"1"));
    // Modern-only options (with [General] fallback for backward compatibility)
    GetPrivateProfileStringW(L"Modern", L"Corners", L"", buf, ARRAYSIZE(buf), out->iniPath);
    if (!buf[0]) GetPrivateProfileStringW(L"General", L"Corners", L"rounded", buf, ARRAYSIZE(buf), out->iniPath);
    out->roundedCorners = (lstrcmpiW(buf, L"square") != 0); // default rounded
    GetPrivateProfileStringW(L"Placement", L"Horizontal", L"right", buf, ARRAYSIZE(buf), out->iniPath);
    if (!lstrcmpiW(buf, L"left")) out->hPlacement = 0; else if (!lstrcmpiW(buf, L"center")) out->hPlacement = 1; else out->hPlacement = 2;
    out->hOffset = GetPrivateProfileIntW(L"Placement", L"HOffset", 16, out->iniPath);
    GetPrivateProfileStringW(L"Placement", L"Vertical", L"bottom", buf, ARRAYSIZE(buf), out->iniPath);
    if (!lstrcmpiW(buf, L"top")) out->vPlacement = 0; else if (!lstrcmpiW(buf, L"center")) out->vPlacement = 1; else out->vPlacement = 2;
    out->vOffset = GetPrivateProfileIntW(L"Placement", L"VOffset", 48, out->iniPath);
    GetPrivateProfileStringW(L"Placement", L"PointerRelative", L"false", buf, ARRAYSIZE(buf), out->iniPath);
    out->pointerRelative = (!lstrcmpiW(buf, L"true") || !lstrcmpiW(buf, L"1"));
    // Modern-only width override
    out->menuWidth = GetPrivateProfileIntW(L"General", L"MenuWidth", 0, out->iniPath);
    parse_menu(out);
    parse_icons(out);
    return TRUE;
}

void config_set_path(Config* out, const WCHAR* path) {
    if (!out || !path) return;
    lstrcpynW(out->iniPath, path, ARRAYSIZE(out->iniPath));
    if (!PathFileExistsW(out->iniPath)) {
        write_default_ini(out->iniPath);
    }
}

void config_set_default_path(const WCHAR* path) {
    if (!path) { g_defaultIniPath[0] = 0; return; }
    lstrcpynW(g_defaultIniPath, path, ARRAYSIZE(g_defaultIniPath));
}
