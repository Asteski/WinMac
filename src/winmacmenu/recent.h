#pragma once
#include <windows.h>
#include <shlobj.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct RecentItem {
    WCHAR path[MAX_PATH];
    BOOL isFolder;
} RecentItem;

// Fills recent items up to maxItems; returns count. Caller must LocalFree(list) when non-NULL.
int recent_get_items(RecentItem **list, int maxItems);
void recent_open_item(const RecentItem *item);
// Deletes all .lnk files from the Recent items folder (best-effort)
void recent_clear_all(void);

#ifdef __cplusplus
}
#endif
