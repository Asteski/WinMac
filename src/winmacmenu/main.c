#include <windows.h>
#include <shellapi.h>
#include <shlwapi.h>
#include <uxtheme.h>
#include <dwmapi.h>
#include <commctrl.h>
#include "menu.h"
#include "theme.h"
#include "util.h"
#include "config.h"

#pragma comment(lib, "comctl32.lib")

static const wchar_t *WC_APPWND = L"WinMacMenuWnd";
static HANDLE g_hSingleInstance = NULL;

static DWORD simple_hash_w(const wchar_t* s) {
    DWORD h = 2166136261u; // FNV-1a base
    while (s && *s) { h ^= (DWORD)(*s++); h *= 16777619u; }
    return h;
}

LRESULT CALLBACK WndProc(HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam) {
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
    case WM_CREATE:
        InitCommonControls();
        theme_apply_to_window(hWnd);
        return 0;
    case WM_SETTINGCHANGE:
    case WM_THEMECHANGED:
        theme_apply_to_window(hWnd);
        return 0;
    case WM_RBUTTONUP:
    case WM_LBUTTONUP:
    case WM_MBUTTONUP:
    case WM_APP: // custom trigger
    {
        POINT pt = {0,0};
        ShowWinXMenu(hWnd, pt);
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
        MenuExecuteCommand(hWnd, (UINT)LOWORD(wParam));
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
    case WM_DESTROY:
        PostQuitMessage(0);
        return 0;
    }
    return DefWindowProc(hWnd, msg, wParam, lParam);
}

int APIENTRY wWinMain(HINSTANCE hInstance, HINSTANCE hPrev, LPWSTR lpCmdLine, int nCmdShow) {
    // Parse optional --config "path" from command line early so mutex name is per-config
    WCHAR cfgPath[MAX_PATH] = {0};
    int argc = 0; LPWSTR* argv = CommandLineToArgvW(GetCommandLineW(), &argc);
    if (argv && argc >= 3) {
        for (int i = 1; i < argc - 1; ++i) {
            if (!lstrcmpiW(argv[i], L"--config")) {
                lstrcpynW(cfgPath, argv[i+1], ARRAYSIZE(cfgPath));
                config_set_default_path(cfgPath);
                break;
            }
        }
    }
    if (argv) LocalFree(argv);

    // Single instance per config: mutex name includes hash of ini path (or default path)
    Config tmp = {0}; config_ensure(&tmp);
    DWORD h = simple_hash_w(tmp.iniPath);
    wchar_t mname[128]; wsprintfW(mname, L"Local\\WinMacMenu.SingleInstance.%08X", h);
    g_hSingleInstance = CreateMutexW(NULL, TRUE, mname);
    if (g_hSingleInstance && GetLastError() == ERROR_ALREADY_EXISTS) {
        // Another instance exists: signal it to show the menu and exit
        HWND hExisting = NULL;
        for (int i = 0; i < 10; ++i) { // retry up to ~1s to allow window creation
            hExisting = FindWindowW(WC_APPWND, L"WinMacMenu");
            if (hExisting) break;
            Sleep(100);
        }
        if (hExisting) {
            PostMessageW(hExisting, WM_APP, 0, 0);
        }
        // No need to keep this process
        return 0;
    }
    // DPI awareness for crisp menu sizing
    HMODULE hShcore = LoadLibraryW(L"Shcore.dll");
    if (hShcore) {
        typedef HRESULT (WINAPI *SetProcessDpiAwareness_t)(int);
        SetProcessDpiAwareness_t fn = (SetProcessDpiAwareness_t)GetProcAddress(hShcore, "SetProcessDpiAwareness");
        if (fn) fn(2 /* PROCESS_PER_MONITOR_DPI_AWARE */);
        FreeLibrary(hShcore);
    }

    WNDCLASSEXW wc = { sizeof(wc) };
    wc.style = CS_DBLCLKS;
    wc.lpfnWndProc = WndProc;
    wc.hInstance = hInstance;
    wc.hCursor = LoadCursor(NULL, IDC_ARROW);
    wc.hbrBackground = (HBRUSH)(COLOR_WINDOW+1);
    wc.lpszClassName = WC_APPWND;

    if (!RegisterClassExW(&wc)) return 0;

    HWND hWnd = CreateWindowExW(WS_EX_TOOLWINDOW, WC_APPWND, L"WinMacMenu",
        WS_POPUP, CW_USEDEFAULT, CW_USEDEFAULT, 200, 200, NULL, NULL, hInstance, NULL);
    if (!hWnd) return 0;

    // Command line parsing already done above (for mutex)

    // Make invisible owner window; show menu immediately at cursor
    MSG msg;
    PostMessage(hWnd, WM_APP, 0, 0);

    while (GetMessage(&msg, NULL, 0, 0)) {
        TranslateMessage(&msg);
        DispatchMessage(&msg);
    }
    if (g_hSingleInstance) { CloseHandle(g_hSingleInstance); g_hSingleInstance = NULL; }
    return (int)msg.wParam;
}
