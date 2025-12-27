#include "recent.h"
#include <shlwapi.h>
#include <shellapi.h>
#include <stdio.h>
#include <initguid.h>

static int add_from_jump_list(RecentItem **out, int maxItems) {
    // Basic approach: enumerate Recent Items folder
    // %AppData%\Microsoft\Windows\Recent
    WCHAR recentPath[MAX_PATH];
    if (!SUCCEEDED(SHGetFolderPathW(NULL, CSIDL_RECENT, NULL, SHGFP_TYPE_CURRENT, recentPath))) return 0;

    WIN32_FIND_DATAW fd; WCHAR pattern[MAX_PATH];
    PathCombineW(pattern, recentPath, L"*.lnk");
    HANDLE h = FindFirstFileW(pattern, &fd);
    if (h == INVALID_HANDLE_VALUE) return 0;

    int count = 0;
    RecentItem *items = (RecentItem*)LocalAlloc(LMEM_ZEROINIT, sizeof(RecentItem) * maxItems);
    if (!items) { FindClose(h); return 0; }

    do {
        if (fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) continue;
        if (count >= maxItems) break;
        WCHAR full[MAX_PATH]; PathCombineW(full, recentPath, fd.cFileName);
        // Resolve shortcut target
        IShellLinkW *psl = NULL; HRESULT hr = CoCreateInstance(&CLSID_ShellLink, NULL, CLSCTX_INPROC_SERVER, &IID_IShellLinkW, (void**)&psl);
        if (SUCCEEDED(hr)) {
            IPersistFile *ppf; if (SUCCEEDED(IShellLinkW_QueryInterface(psl, &IID_IPersistFile, (void**)&ppf))) {
                if (SUCCEEDED(IPersistFile_Load(ppf, full, STGM_READ))) {
                    WIN32_FIND_DATAW wfd; WCHAR target[MAX_PATH];
                    if (SUCCEEDED(IShellLinkW_GetPath(psl, target, MAX_PATH, &wfd, SLGP_RAWPATH))) {
                        // Skip if empty or target does not exist anymore
                        if (target[0]) {
                            DWORD attrs = GetFileAttributesW(target);
                            if (attrs != INVALID_FILE_ATTRIBUTES) {
                                lstrcpynW(items[count].path, target, MAX_PATH);
                                items[count].isFolder = (wfd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) != 0 || (attrs & FILE_ATTRIBUTE_DIRECTORY);
                                count++;
                            }
                        }
                    }
                }
                IPersistFile_Release(ppf);
            }
            IShellLinkW_Release(psl);
        }
    } while (FindNextFileW(h, &fd));

    FindClose(h);
    *out = items;
    return count;
}

int recent_get_items(RecentItem **list, int maxItems) {
    *list = NULL;
    CoInitializeEx(NULL, COINIT_APARTMENTTHREADED);
    int n = add_from_jump_list(list, maxItems);
    CoUninitialize();
    return n;
}

void recent_open_item(const RecentItem *item) {
    if (!item) return;
    if (!item->path[0]) return;
    DWORD attrs = GetFileAttributesW(item->path);
    if (attrs == INVALID_FILE_ATTRIBUTES) return; // silently ignore stale entry
    ShellExecuteW(NULL, L"open", item->path, NULL, NULL, SW_SHOWNORMAL);
}

void recent_clear_all(void) {
    WCHAR recentPath[MAX_PATH];
    if (!SUCCEEDED(SHGetFolderPathW(NULL, CSIDL_RECENT, NULL, SHGFP_TYPE_CURRENT, recentPath))) return;
    WIN32_FIND_DATAW fd; WCHAR pattern[MAX_PATH];
    PathCombineW(pattern, recentPath, L"*.lnk");
    HANDLE h = FindFirstFileW(pattern, &fd);
    if (h == INVALID_HANDLE_VALUE) return;
    do {
        if (fd.dwFileAttributes & FILE_ATTRIBUTE_DIRECTORY) continue;
        WCHAR full[MAX_PATH]; PathCombineW(full, recentPath, fd.cFileName);
        DeleteFileW(full);
    } while (FindNextFileW(h, &fd));
    FindClose(h);
}
