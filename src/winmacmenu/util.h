#pragma once
#include <windows.h>

void open_uri(LPCWSTR uri);
void open_shell_known(LPCWSTR verb, LPCWSTR file, LPCWSTR params);
void open_shell_item(LPCWSTR path);
void system_sleep();
void system_shutdown(BOOL reboot);
void system_lock();
void system_logoff();
