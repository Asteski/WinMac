#pragma once
#include <windows.h>

void open_uri(LPCWSTR uri);
void open_shell_known(LPCWSTR verb, LPCWSTR file, LPCWSTR params);
void open_shell_item(LPCWSTR path);
void system_sleep();
void system_shutdown(BOOL reboot);
void system_lock();
void system_logoff();
void system_hibernate();

// Registry helpers for StartOnLogin (HKCU\Software\Microsoft\Windows\CurrentVersion\Run)
BOOL set_run_at_login(LPCWSTR valueName, LPCWSTR commandLine); // create/update value
BOOL remove_run_at_login(LPCWSTR valueName); // delete value

// Returns TRUE when the current process is elevated (running as admin)
BOOL is_process_elevated(void);
