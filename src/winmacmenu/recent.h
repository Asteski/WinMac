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

#ifdef __cplusplus
}
#endif
