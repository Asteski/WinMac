#include "util.h"
#include <shellapi.h>
#include <shlwapi.h>
#include <powrprof.h>
#include <processthreadsapi.h>
#include <winternl.h>
#include <wtsapi32.h>
#pragma comment(lib, "PowrProf.lib")
// Lock/logoff don't need extra libs beyond user32/advapi32 which are already linked

void open_uri(LPCWSTR uri) {
    ShellExecuteW(NULL, L"open", uri, NULL, NULL, SW_SHOWNORMAL);
}

void open_shell_known(LPCWSTR verb, LPCWSTR file, LPCWSTR params) {
    SHELLEXECUTEINFOW sei = { sizeof(sei) };
    sei.fMask = SEE_MASK_FLAG_LOG_USAGE;
    sei.lpVerb = verb;
    sei.lpFile = file;
    sei.lpParameters = params;
    sei.nShow = SW_SHOWNORMAL;
    ShellExecuteExW(&sei);
}

void open_shell_item(LPCWSTR path) {
    ShellExecuteW(NULL, L"open", path, NULL, NULL, SW_SHOWNORMAL);
}

void system_sleep() {
    // Request privileges may be required for some power actions; use SetSuspendState
    // Use powrprof SetSuspendState; requires SE_SHUTDOWN_NAME for force? Usually not.
    // FALSE: Suspend, FALSE: forceCritical, FALSE: disableWakeEvent
    SetSuspendState(FALSE, FALSE, FALSE);
}

static BOOL acquire_shutdown_privilege() {
    HANDLE hToken;
    if (!OpenProcessToken(GetCurrentProcess(), TOKEN_ADJUST_PRIVILEGES | TOKEN_QUERY, &hToken))
        return FALSE;
    TOKEN_PRIVILEGES tp = {0};
    LookupPrivilegeValue(NULL, SE_SHUTDOWN_NAME, &tp.Privileges[0].Luid);
    tp.PrivilegeCount = 1;
    tp.Privileges[0].Attributes = SE_PRIVILEGE_ENABLED;
    AdjustTokenPrivileges(hToken, FALSE, &tp, sizeof(tp), NULL, NULL);
    CloseHandle(hToken);
    return GetLastError() == ERROR_SUCCESS;
}

void system_shutdown(BOOL reboot) {
    acquire_shutdown_privilege();
    UINT flags = EWX_SHUTDOWN | EWX_FORCEIFHUNG;
    if (reboot) flags = EWX_REBOOT | EWX_FORCEIFHUNG;
    ExitWindowsEx(flags, SHTDN_REASON_MAJOR_OTHER);
}

void system_lock() {
    // Lock the workstation; user32 exports this
    LockWorkStation();
}

void system_logoff() {
    acquire_shutdown_privilege();
    ExitWindowsEx(EWX_LOGOFF | EWX_FORCEIFHUNG, SHTDN_REASON_MAJOR_OTHER);
}
