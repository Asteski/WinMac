#pragma once
#include <windows.h>

#ifdef __cplusplus
extern "C" {
#endif

BOOL theme_is_dark();
void theme_apply_to_window(HWND hWnd);
HMENU theme_style_menu(HMENU hMenu);
// Returns TRUE if accent color retrieved; outputs RGB accent in *color (ignores alpha)
BOOL theme_get_accent(COLORREF* color);

#ifdef __cplusplus
}
#endif
