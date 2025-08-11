#pragma once
#include <windows.h>

void ShowWinXMenu(HWND owner, POINT screenPt);
void MenuExecuteCommand(HWND owner, UINT cmd);
void MenuOnMenuSelect(HWND owner, WPARAM wParam, LPARAM lParam);
void MenuOnInitMenuPopup(HWND owner, HMENU hMenu, UINT item, BOOL isSystemMenu);
void MenuExecuteCommand(HWND owner, UINT cmd);
BOOL MenuOnMeasureItem(HWND owner, MEASUREITEMSTRUCT* mis);
BOOL MenuOnDrawItem(HWND owner, const DRAWITEMSTRUCT* dis);
