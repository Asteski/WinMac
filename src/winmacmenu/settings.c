// Reconstructed clean settings.c to address prior hidden corruption causing C2181.
#include "settings.h"
#include "resource.h"
#include "util.h"
#include <windows.h>
#include <commctrl.h>
#include <shlwapi.h>
#include <commdlg.h>
#include <shellapi.h>

typedef struct SettingsState {
    Config* cfg;
    HWND hTabs;
    HWND pages[6]; // General, Placement, Menu, Icons, Sorting, Advanced
    // Working copy of menu/icon items so Apply/Save commits atomically
    ConfigItem workingItems[64];
    int workingCount;
    BOOL workingDirty; // set when workingItems modified
    int baseW, baseH; // initial dialog size for min constraint
    HFONT hItalic; // italic font for filename label
} SettingsState;

// Prototype so early helpers can reference selection utility without ordering issues
static int icons_get_selected_index(HWND lv);
// Forward declarations for helpers referenced before definition
static void refresh_lists(SettingsState* st);
static void working_clone(SettingsState* st);
static void working_commit(SettingsState* st);
static BOOL Icons_Save(HWND pg, Config* c);
static void Sorting_Load(HWND pg, Config* c);
static BOOL Sorting_Save(HWND pg, Config* c);

// Generic child page dialog procedure: forward button commands to main dialog
static INT_PTR CALLBACK PageDlgProc(HWND dlg, UINT msg, WPARAM wParam, LPARAM lParam){
    switch(msg){
    case WM_INITDIALOG:
        // Store SettingsState* locally if needed later
        SetWindowLongPtrW(dlg, GWLP_USERDATA, lParam);
        return TRUE;
    case WM_NOTIFY: {
        // Forward notifications (e.g., list view selection changes) to main dialog
        HWND parent = GetParent(dlg);
        if(parent){
            SendMessageW(parent, WM_NOTIFY, wParam, lParam);
            return TRUE; // handled (parent will process)
        }
        break; }
    case WM_COMMAND: {
        HWND parent = GetParent(dlg);
        if(parent){
            // Forward to main settings dialog to handle
            SendMessageW(parent, WM_COMMAND, wParam, lParam);
            return TRUE;
        }
        break; }
    }
    return FALSE;
}

static void set_check(HWND d,int id,BOOL v){ CheckDlgButton(d,id,v?BST_CHECKED:BST_UNCHECKED); }
static BOOL get_check(HWND d,int id){ return IsDlgButtonChecked(d,id)==BST_CHECKED; }
static void set_int(HWND d,int id,int v){ WCHAR b[32]; wsprintfW(b,L"%d",v); SetDlgItemTextW(d,id,b);} 
static int  get_int(HWND d,int id,int def){ WCHAR b[32]; if(!GetDlgItemTextW(d,id,b,ARRAYSIZE(b))) return def; int v=_wtoi(b); return (v==0)?def:v; }

static void apply_dialog_icon(HWND dlg,const Config* cfg){
    int cx=GetSystemMetrics(SM_CXICON), cy=GetSystemMetrics(SM_CYICON);
    int cxs=GetSystemMetrics(SM_CXSMICON), cys=GetSystemMetrics(SM_CYSMICON);
    HICON icoBig=NULL, icoSmall=NULL;
    const WCHAR *paths[3]={NULL,NULL,NULL};
    if(cfg){
        if(cfg->trayIconPath[0])      paths[0]=cfg->trayIconPath;
        if(cfg->trayIconPathLight[0]) paths[1]=cfg->trayIconPathLight;
        if(cfg->trayIconPathDark[0])  paths[2]=cfg->trayIconPathDark;
        for(int i=0;i<3 && !icoBig;i++) if(paths[i]) icoBig=(HICON)LoadImageW(NULL,paths[i],IMAGE_ICON,cx,cy,LR_LOADFROMFILE);
        for(int i=0;i<3 && !icoSmall;i++) if(paths[i]) icoSmall=(HICON)LoadImageW(NULL,paths[i],IMAGE_ICON,cxs,cys,LR_LOADFROMFILE);
    }
    if(!icoBig)   icoBig=(HICON)LoadImageW(GetModuleHandleW(NULL),MAKEINTRESOURCEW(IDI_APPICON),IMAGE_ICON,cx,cy,LR_DEFAULTCOLOR);
    if(!icoSmall) icoSmall=(HICON)LoadImageW(GetModuleHandleW(NULL),MAKEINTRESOURCEW(IDI_APPICON),IMAGE_ICON,cxs,cys,LR_DEFAULTCOLOR);
    if(icoBig)   SendMessageW(dlg,WM_SETICON,ICON_BIG,(LPARAM)icoBig);
    if(icoSmall) SendMessageW(dlg,WM_SETICON,ICON_SMALL,(LPARAM)icoSmall);
}

// -------- General Page --------
static void General_Load(HWND pg, Config* c){
    set_check(pg,IDC_RUNINBACKGROUND,c->runInBackground);
    set_check(pg,IDC_SHOWONLAUNCH,c->showOnLaunch);
    set_check(pg,IDC_SHOWTRAYICON,c->showTrayIcon);
    set_check(pg,IDC_STARTONLOGIN,c->startOnLogin);
    set_check(pg,IDC_SHOWICONS,c->showIcons);
    set_check(pg,IDC_SHOWFOLDERICONS,c->showFolderIcons);
    set_check(pg,IDC_SHOWEXTENSIONS,c->showExtensions);
    set_int(pg,IDC_FOLDERDEPTH_EDIT,c->folderMaxDepth);
    SendDlgItemMessageW(pg,IDC_FOLDERDEPTH_SPIN,UDM_SETRANGE,0,MAKELPARAM(4,1));
    // Populate filename label (separate static now). Button text remains static in resource.
    HWND hLabel = GetDlgItem(pg, IDC_CONFIG_FILE_LABEL);
    if(hLabel){
        // Apply italic font (create once and reuse)
        SettingsState* st=(SettingsState*)GetWindowLongPtrW(GetParent(pg),GWLP_USERDATA);
        if(st && !st->hItalic){
            LOGFONTW lf; ZeroMemory(&lf,sizeof(lf));
            // Base on dialog font metrics
            HFONT hDlgFont=(HFONT)SendMessageW(pg,WM_GETFONT,0,0);
            if(hDlgFont){ GetObjectW(hDlgFont,sizeof(lf),&lf); }
            if(lf.lfFaceName[0]==0){ lstrcpynW(lf.lfFaceName,L"Segoe UI",ARRAYSIZE(lf.lfFaceName)); lf.lfHeight=-12; }
            lf.lfItalic = TRUE;
            st->hItalic = CreateFontIndirectW(&lf);
        }
        if(st && st->hItalic){ SendMessageW(hLabel,WM_SETFONT,(WPARAM)st->hItalic,TRUE); }
        if(c && c->iniPath[0]){
            const WCHAR* slash = wcsrchr(c->iniPath, L'\\');
            const WCHAR* base = slash? slash+1 : c->iniPath;
            SetWindowTextW(hLabel, base);
        } else {
            SetWindowTextW(hLabel, L"(none)");
        }
    }
    // Ensure button retains the intended static text (defensive in case of legacy configs)
    SetDlgItemTextW(pg, IDC_OPEN_CONFIG_FOLDER, L"Show config folder");
}
static BOOL General_Save(HWND pg, Config* c){
    BOOL ch=FALSE; BOOL b;
    b=get_check(pg,IDC_RUNINBACKGROUND);            if(c->runInBackground!=b){c->runInBackground=b;ch=TRUE;}
    b=get_check(pg,IDC_SHOWONLAUNCH);               if(c->showOnLaunch!=b){c->showOnLaunch=b;ch=TRUE;}
    b=get_check(pg,IDC_SHOWTRAYICON);               if(c->showTrayIcon!=b){c->showTrayIcon=b;ch=TRUE;}
    b=get_check(pg,IDC_STARTONLOGIN);               if(c->startOnLogin!=b){c->startOnLogin=b;ch=TRUE;}
    b=get_check(pg,IDC_SHOWICONS);                  if(c->showIcons!=b){c->showIcons=b;ch=TRUE;}
    b=get_check(pg,IDC_SHOWFOLDERICONS);            if(c->showFolderIcons!=b){c->showFolderIcons=b;ch=TRUE;}
    b=get_check(pg,IDC_SHOWEXTENSIONS);             if(c->showExtensions!=b){c->showExtensions=b;ch=TRUE;}
    int v=get_int(pg,IDC_FOLDERDEPTH_EDIT,c->folderMaxDepth); if(v!=c->folderMaxDepth){ if(v<1)v=1; if(v>4)v=4; c->folderMaxDepth=v; ch=TRUE; }
    if(!ch) return FALSE;
    if(c->iniPath[0]){
        WritePrivateProfileStringW(L"General",L"RunInBackground",   c->runInBackground?L"true":L"false",c->iniPath);
        WritePrivateProfileStringW(L"General",L"ShowOnLaunch",      c->showOnLaunch?L"true":L"false",c->iniPath);
        WritePrivateProfileStringW(L"General",L"ShowTrayIcon",      c->showTrayIcon?L"true":L"false",c->iniPath);
        WritePrivateProfileStringW(L"General",L"StartOnLogin",      c->startOnLogin?L"true":L"false",c->iniPath);
        WritePrivateProfileStringW(L"General",L"ShowIcons",         c->showIcons?L"true":L"false",c->iniPath);
        WritePrivateProfileStringW(L"General",L"ShowFolderIcons",   c->showFolderIcons?L"true":L"false",c->iniPath);
        WritePrivateProfileStringW(L"General",L"ShowFileExtensions",c->showExtensions?L"true":L"false",c->iniPath);
        WCHAR buf[32]; wsprintfW(buf,L"%d",c->folderMaxDepth); WritePrivateProfileStringW(L"General",L"FolderSubmenuDepth",buf,c->iniPath);
    }
    WCHAR exe[MAX_PATH]; GetModuleFileNameW(NULL,exe,ARRAYSIZE(exe)); WCHAR cmd[2048]; if(c->iniPath[0]) wsprintfW(cmd,L"\"%s\" --config \"%s\"",exe,c->iniPath); else wsprintfW(cmd,L"\"%s\"",exe); WCHAR runName[32]; lstrcpynW(runName,L"WinMac Menu",ARRAYSIZE(runName)); if(c->startOnLogin) set_run_at_login(runName,cmd); else remove_run_at_login(runName);
    return TRUE;
}

// -------- Placement Page --------
static void Placement_Load(HWND pg, Config* c){
    set_check(pg,IDC_POINTERRELATIVE,c->pointerRelative);
    set_check(pg,IDC_IGNORE_H_CENTERED,c->ignoreHOffsetWhenCentered);
    set_check(pg,IDC_IGNORE_V_CENTERED,c->ignoreVOffsetWhenCentered);
    set_check(pg,IDC_IGNORE_H_REL,c->ignoreHOffsetWhenRelative);
    set_check(pg,IDC_IGNORE_V_REL,c->ignoreVOffsetWhenRelative);
    HWND hH=GetDlgItem(pg,IDC_HPLACEMENT_COMBO), hV=GetDlgItem(pg,IDC_VPLACEMENT_COMBO);
    const WCHAR* Hs[]={L"Left",L"Center",L"Right"};
    const WCHAR* Vs[]={L"Top",L"Center",L"Bottom"};
    for(int i=0;i<3;i++){ SendMessageW(hH,CB_ADDSTRING,0,(LPARAM)Hs[i]); SendMessageW(hV,CB_ADDSTRING,0,(LPARAM)Vs[i]); }
    SendMessageW(hH,CB_SETCURSEL,c->hPlacement,0);
    SendMessageW(hV,CB_SETCURSEL,c->vPlacement,0);
    set_int(pg,IDC_HOFFSET_EDIT,c->hOffset); set_int(pg,IDC_VOFFSET_EDIT,c->vOffset);
}
static BOOL Placement_Save(HWND pg, Config* c){
    BOOL ch=FALSE; BOOL b;
    b=get_check(pg,IDC_POINTERRELATIVE); if(c->pointerRelative!=b){c->pointerRelative=b;ch=TRUE;}
    b=get_check(pg,IDC_IGNORE_H_CENTERED); if(c->ignoreHOffsetWhenCentered!=b){c->ignoreHOffsetWhenCentered=b;ch=TRUE;}
    b=get_check(pg,IDC_IGNORE_V_CENTERED); if(c->ignoreVOffsetWhenCentered!=b){c->ignoreVOffsetWhenCentered=b;ch=TRUE;}
    b=get_check(pg,IDC_IGNORE_H_REL); if(c->ignoreHOffsetWhenRelative!=b){c->ignoreHOffsetWhenRelative=b;ch=TRUE;}
    b=get_check(pg,IDC_IGNORE_V_REL); if(c->ignoreVOffsetWhenRelative!=b){c->ignoreVOffsetWhenRelative=b;ch=TRUE;}
    int v;
    v=(int)SendDlgItemMessageW(pg,IDC_HPLACEMENT_COMBO,CB_GETCURSEL,0,0); if(v>=0 && v!=c->hPlacement){c->hPlacement=v;ch=TRUE;}
    v=(int)SendDlgItemMessageW(pg,IDC_VPLACEMENT_COMBO,CB_GETCURSEL,0,0); if(v>=0 && v!=c->vPlacement){c->vPlacement=v;ch=TRUE;}
    v=get_int(pg,IDC_HOFFSET_EDIT,c->hOffset); if(v!=c->hOffset){c->hOffset=v;ch=TRUE;}
    v=get_int(pg,IDC_VOFFSET_EDIT,c->vOffset); if(v!=c->vOffset){c->vOffset=v;ch=TRUE;}
    if(!ch) return FALSE;
    if(c->iniPath[0]){
        WCHAR buf[32];
        WritePrivateProfileStringW(L"Placement",L"PointerRelative",c->pointerRelative?L"true":L"false",c->iniPath);
        const WCHAR* hp=L"right"; if(c->hPlacement==0) hp=L"left"; else if(c->hPlacement==1) hp=L"center";
        const WCHAR* vp=L"bottom"; if(c->vPlacement==0) vp=L"top"; else if(c->vPlacement==1) vp=L"center";
        WritePrivateProfileStringW(L"Placement",L"Horizontal",hp,c->iniPath);
        WritePrivateProfileStringW(L"Placement",L"Vertical",vp,c->iniPath);
        wsprintfW(buf,L"%d",c->hOffset); WritePrivateProfileStringW(L"Placement",L"HOffset",buf,c->iniPath);
        wsprintfW(buf,L"%d",c->vOffset); WritePrivateProfileStringW(L"Placement",L"VOffset",buf,c->iniPath);
        const WCHAR* cen=L"false"; if(c->ignoreHOffsetWhenCentered&&c->ignoreVOffsetWhenCentered) cen=L"true"; else if(c->ignoreHOffsetWhenCentered) cen=L"HOffset"; else if(c->ignoreVOffsetWhenCentered) cen=L"VOffset"; WritePrivateProfileStringW(L"Placement",L"IgnoreOffsetWhenCentered",cen,c->iniPath);
        const WCHAR* rel=L"false"; if(c->ignoreHOffsetWhenRelative&&c->ignoreVOffsetWhenRelative) rel=L"true"; else if(c->ignoreHOffsetWhenRelative) rel=L"HOffset"; else if(c->ignoreVOffsetWhenRelative) rel=L"VOffset"; WritePrivateProfileStringW(L"Placement",L"IgnoreOffsetWhenRelative",rel,c->iniPath);
    }
    return TRUE;
}

// -------- Sorting Page --------
static void Sorting_Load(HWND pg, Config* c){
    HWND hCombo=GetDlgItem(pg,IDC_SORT_FIELD);
    if(hCombo){
        SendMessageW(hCombo,CB_RESETCONTENT,0,0);
        SendMessageW(hCombo,CB_ADDSTRING,0,(LPARAM)L"Name");
        SendMessageW(hCombo,CB_ADDSTRING,0,(LPARAM)L"Date Modified");
        SendMessageW(hCombo,CB_ADDSTRING,0,(LPARAM)L"Date Created");
        SendMessageW(hCombo,CB_ADDSTRING,0,(LPARAM)L"Size");
        SendMessageW(hCombo,CB_ADDSTRING,0,(LPARAM)L"Type");
        SendMessageW(hCombo,CB_SETCURSEL,c->sortField,0);
    }
    set_check(pg,IDC_SORT_DESCENDING,c->sortDescending);
    set_check(pg,IDC_SORT_FOLDERSFIRST,c->sortFoldersFirst);
    set_int(pg,IDC_MAXITEMS_EDIT,c->maxItems);
    SendDlgItemMessageW(pg,IDC_MAXITEMS_SPIN,UDM_SETRANGE,0,MAKELPARAM(999,1));
}

static BOOL Sorting_Save(HWND pg, Config* c){
    BOOL ch=FALSE; BOOL b;
    int v;
    
    v=(int)SendDlgItemMessageW(pg,IDC_SORT_FIELD,CB_GETCURSEL,0,0);
    if(v>=0 && v!=c->sortField){c->sortField=v;ch=TRUE;}
    
    b=get_check(pg,IDC_SORT_DESCENDING); if(c->sortDescending!=b){c->sortDescending=b;ch=TRUE;}
    b=get_check(pg,IDC_SORT_FOLDERSFIRST); if(c->sortFoldersFirst!=b){c->sortFoldersFirst=b;ch=TRUE;}
    
    v=get_int(pg,IDC_MAXITEMS_EDIT,c->maxItems); if(v!=c->maxItems){c->maxItems=v;ch=TRUE;}
    
    if(!ch) return FALSE;
    
    if(c->iniPath[0]){
        const WCHAR* fields[] = {L"name", L"date", L"created", L"size", L"type"};
        if(c->sortField >= 0 && c->sortField < 5)
            WritePrivateProfileStringW(L"Sorting",L"SortBy",fields[c->sortField],c->iniPath);
            
        WritePrivateProfileStringW(L"Sorting",L"SortDirection",c->sortDescending?L"descending":L"ascending",c->iniPath);
        WritePrivateProfileStringW(L"Sorting",L"FoldersFirst",c->sortFoldersFirst?L"true":L"false",c->iniPath);
        
        WCHAR buf[32];
        wsprintfW(buf,L"%d",c->maxItems);
        WritePrivateProfileStringW(L"General",L"MaxItems",buf,c->iniPath);
    }
    return TRUE;
}

// -------- Advanced Page --------
static void Advanced_Load(HWND pg, Config* c){
    set_check(pg,IDC_RECENT_SHOW_EXT,c->recentShowExtensions);
    set_check(pg,IDC_RECENT_SHOW_CLEAN,c->recentShowCleanItems);
    set_check(pg,IDC_THISPC_AS_SUBMENU,c->thisPCAsSubmenu);
    set_check(pg,IDC_HOME_AS_SUBMENU,c->homeAsSubmenu);
    set_check(pg,IDC_TASKKILL_ALL_DESKTOPS,c->taskKillAllDesktops);
    // Power exclusions
    // Checkboxes now represent inclusion (checked = include), so invert exclude flags
    set_check(pg,IDC_EXCL_SLEEP,!c->excludeSleep);
    set_check(pg,IDC_EXCL_HIBERNATE,!c->excludeHibernate);
    set_check(pg,IDC_EXCL_SHUTDOWN,!c->excludeShutdown);
    set_check(pg,IDC_EXCL_RESTART,!c->excludeRestart);
    set_check(pg,IDC_EXCL_LOCK,!c->excludeLock);
    set_check(pg,IDC_EXCL_LOGOFF,!c->excludeLogoff);
    // Populate name display combo (ID 1702): 0=Full path,1=File name
    HWND hCombo=GetDlgItem(pg,1702);
    if(hCombo){
        SendMessageW(hCombo,CB_RESETCONTENT,0,0);
        SendMessageW(hCombo,CB_ADDSTRING,0,(LPARAM)L"Full path");
        SendMessageW(hCombo,CB_ADDSTRING,0,(LPARAM)L"File name");
        int sel=(c->recentLabelMode==1)?1:0;
        SendMessageW(hCombo,CB_SETCURSEL,sel,0);
    }
    SetDlgItemTextW(pg,IDC_DEFAULT_ICON,c->defaultIconPath);
    SetDlgItemTextW(pg,IDC_DEFAULT_ICON_LIGHT,c->defaultIconPathLight);
    SetDlgItemTextW(pg,IDC_DEFAULT_ICON_DARK,c->defaultIconPathDark);
    set_int(pg,IDC_RECENTMAX_EDIT,c->recentMax); SendDlgItemMessageW(pg,IDC_RECENTMAX_SPIN,UDM_SETRANGE,0,MAKELPARAM(99,1));
}
static BOOL Advanced_Save(HWND pg, Config* c){
    BOOL ch=FALSE; BOOL b;
    b=get_check(pg,IDC_RECENT_SHOW_EXT); if(c->recentShowExtensions!=b){c->recentShowExtensions=b;ch=TRUE;}
    b=get_check(pg,IDC_RECENT_SHOW_CLEAN); if(c->recentShowCleanItems!=b){c->recentShowCleanItems=b;ch=TRUE;}
    b=get_check(pg,IDC_THISPC_AS_SUBMENU); if(c->thisPCAsSubmenu!=b){c->thisPCAsSubmenu=b;ch=TRUE;}
    b=get_check(pg,IDC_HOME_AS_SUBMENU); if(c->homeAsSubmenu!=b){c->homeAsSubmenu=b;ch=TRUE;}
    b=get_check(pg,IDC_TASKKILL_ALL_DESKTOPS); if(c->taskKillAllDesktops!=b){c->taskKillAllDesktops=b;ch=TRUE;}
    // Power inclusion checkboxes (checked = include). Store as exclusion flags internally.
    b=!get_check(pg,IDC_EXCL_SLEEP); if(c->excludeSleep!=b){c->excludeSleep=b; ch=TRUE;}
    b=!get_check(pg,IDC_EXCL_HIBERNATE); if(c->excludeHibernate!=b){c->excludeHibernate=b; ch=TRUE;}
    b=!get_check(pg,IDC_EXCL_SHUTDOWN); if(c->excludeShutdown!=b){c->excludeShutdown=b; ch=TRUE;}
    b=!get_check(pg,IDC_EXCL_RESTART); if(c->excludeRestart!=b){c->excludeRestart=b; ch=TRUE;}
    b=!get_check(pg,IDC_EXCL_LOCK); if(c->excludeLock!=b){c->excludeLock=b; ch=TRUE;}
    b=!get_check(pg,IDC_EXCL_LOGOFF); if(c->excludeLogoff!=b){c->excludeLogoff=b; ch=TRUE;}
    HWND hCombo=GetDlgItem(pg,1702);
    if(hCombo){
        int mode=(int)SendMessageW(hCombo,CB_GETCURSEL,0,0);
        if(mode<0) mode=0;
        if(c->recentLabelMode!=mode){c->recentLabelMode=mode;ch=TRUE;}
    }
    int v=get_int(pg,IDC_RECENTMAX_EDIT,c->recentMax); if(v!=c->recentMax){c->recentMax=v;ch=TRUE;}
    WCHAR buf[MAX_PATH];
    if(GetDlgItemTextW(pg,IDC_DEFAULT_ICON,buf,ARRAYSIZE(buf))){ if(lstrcmpW(buf,c->defaultIconPath)!=0){ lstrcpynW(c->defaultIconPath,buf,ARRAYSIZE(c->defaultIconPath)); ch=TRUE; }}
    if(GetDlgItemTextW(pg,IDC_DEFAULT_ICON_LIGHT,buf,ARRAYSIZE(buf))){ if(lstrcmpW(buf,c->defaultIconPathLight)!=0){ lstrcpynW(c->defaultIconPathLight,buf,ARRAYSIZE(c->defaultIconPathLight)); ch=TRUE; }}
    if(GetDlgItemTextW(pg,IDC_DEFAULT_ICON_DARK,buf,ARRAYSIZE(buf))){ if(lstrcmpW(buf,c->defaultIconPathDark)!=0){ lstrcpynW(c->defaultIconPathDark,buf,ARRAYSIZE(c->defaultIconPathDark)); ch=TRUE; }}
    if(!ch) return FALSE;
    if(c->iniPath[0]){
        WritePrivateProfileStringW(L"RecentItems",L"RecentShowExtensions",c->recentShowExtensions?L"true":L"false",c->iniPath);
        WritePrivateProfileStringW(L"RecentItems",L"RecentShowCleanItems",c->recentShowCleanItems?L"true":L"false",c->iniPath);
        WritePrivateProfileStringW(L"RecentItems",L"RecentLabel", c->recentLabelMode==0?L"fullpath":L"name", c->iniPath);
        WritePrivateProfileStringW(L"ThisPC",L"ThisPCAsSubmenu",c->thisPCAsSubmenu?L"true":L"false",c->iniPath);
        WritePrivateProfileStringW(L"Home",L"HomeAsSubmenu",c->homeAsSubmenu?L"true":L"false",c->iniPath);
        WritePrivateProfileStringW(L"TaskKill",L"TaskKillAllDesktops",c->taskKillAllDesktops?L"true":L"false",c->iniPath);
        WCHAR num[32]; wsprintfW(num,L"%d",c->recentMax); WritePrivateProfileStringW(L"RecentItems",L"RecentMax",num,c->iniPath);
        WritePrivateProfileStringW(L"General",L"DefaultIcon",c->defaultIconPath,c->iniPath);
        WritePrivateProfileStringW(L"General",L"DefaultIconLight",c->defaultIconPathLight,c->iniPath);
        WritePrivateProfileStringW(L"General",L"DefaultIconDark",c->defaultIconPathDark,c->iniPath);
        // Persist new inclusion model: only write keys for excluded options as Name=0, remove when included.
        // Names: Sleep, Hibernate, Shutdown, Restart, Lock, Logoff
        WritePrivateProfileStringW(L"Power",L"Sleep", c->excludeSleep? L"0" : NULL, c->iniPath);
        WritePrivateProfileStringW(L"Power",L"Hibernate", c->excludeHibernate? L"0" : NULL, c->iniPath);
        WritePrivateProfileStringW(L"Power",L"Shutdown", c->excludeShutdown? L"0" : NULL, c->iniPath);
        WritePrivateProfileStringW(L"Power",L"Restart", c->excludeRestart? L"0" : NULL, c->iniPath);
        WritePrivateProfileStringW(L"Power",L"Lock", c->excludeLock? L"0" : NULL, c->iniPath);
        WritePrivateProfileStringW(L"Power",L"Logoff", c->excludeLogoff? L"0" : NULL, c->iniPath);
        if(!c->excludeSleep && !c->excludeHibernate && !c->excludeShutdown && !c->excludeRestart && !c->excludeLock && !c->excludeLogoff){
            // All included: remove entire [Power] section if present
            WritePrivateProfileStringW(L"Power", NULL, NULL, c->iniPath);
        }
    }
    return TRUE;
}

// -------- Menu & Icons Pages (read-only skeleton) --------
static const WCHAR* item_type_name(ConfigItemType t){
    switch(t){
        case CI_SEPARATOR: return L"Separator"; case CI_URI: return L"URI"; case CI_FILE: return L"File"; case CI_CMD: return L"Command"; case CI_FOLDER: return L"Folder"; case CI_FOLDER_SUBMENU: return L"Folder (submenu)"; case CI_POWER_SLEEP: return L"Sleep"; case CI_POWER_HIBERNATE: return L"Hibernate"; case CI_POWER_SHUTDOWN: return L"Shutdown"; case CI_POWER_RESTART: return L"Restart"; case CI_POWER_LOCK: return L"Lock"; case CI_POWER_LOGOFF: return L"Logoff"; case CI_RECENT_SUBMENU: return L"Recent"; case CI_POWER_MENU: return L"Power Menu"; }
    return L"?";
}
static void lv_add_col(HWND lv,int i,int w,const WCHAR* txt){
    LVCOLUMNW c; ZeroMemory(&c,sizeof(c));
    c.mask = LVCF_WIDTH|LVCF_TEXT|LVCF_SUBITEM;
    c.cx   = w;
    WCHAR tmp[128];
    if(!txt) txt=L"";
    lstrcpynW(tmp, txt, ARRAYSIZE(tmp));
    c.pszText = tmp;
    c.iSubItem = i;
    ListView_InsertColumn(lv,i,&c);
} 
static void lv_set_text(HWND lv,int row,int col,const WCHAR* text){ WCHAR tmp[512]; if(!text) text=L""; lstrcpynW(tmp,text,ARRAYSIZE(tmp)); ListView_SetItemText(lv,row,col,tmp);} 
static void Menu_Load(HWND pg, Config* c){
    HWND lv=GetDlgItem(pg,IDC_MENU_LIST);
    if(!lv||!c) return;
    // Determine if we have a SettingsState working copy (parent is the tab child dialog)
    SettingsState* st=(SettingsState*)GetWindowLongPtrW(GetParent(pg),GWLP_USERDATA);
    ListView_SetExtendedListViewStyle(lv,LVS_EX_FULLROWSELECT|LVS_EX_GRIDLINES|LVS_EX_DOUBLEBUFFER);
    while(ListView_DeleteColumn(lv,0));
    lv_add_col(lv,0,40,L"#");
    lv_add_col(lv,1,90,L"Type");
    lv_add_col(lv,2,110,L"Label");
    lv_add_col(lv,3,160,L"Path"); // widen path to reclaim removed column width
    lv_add_col(lv,4,110,L"Params");
    ListView_DeleteAllItems(lv);
    ConfigItem* arr=c->items; int cnt=c->count;
    if(st && st->workingCount>0){ arr=st->workingItems; cnt=st->workingCount; }
    for(int i=0;i<cnt;i++){
        ConfigItem* it=&arr[i];
        WCHAR idx[12]; wsprintfW(idx,L"%d",i+1);
        WCHAR idxCopy[12]; lstrcpynW(idxCopy,idx,ARRAYSIZE(idxCopy));
        LVITEMW li; ZeroMemory(&li,sizeof(li));
        li.mask=LVIF_TEXT|LVIF_PARAM; li.iItem=i; li.pszText=idxCopy; li.lParam=i;
        ListView_InsertItem(lv,&li);
        {
            const WCHAR* tname = item_type_name(it->type);
            WCHAR tmpType[64]; lstrcpynW(tmpType,tname? tname : L"?",ARRAYSIZE(tmpType));
            ListView_SetItemText(lv,i,1,tmpType);
        }
        if(it->label[0]){ ListView_SetItemText(lv,i,2,it->label); }
        else if(it->type==CI_SEPARATOR){ lv_set_text(lv,i,2,L"(separator)"); }
        else { lv_set_text(lv,i,2,L""); }
        if(it->type==CI_URI||it->type==CI_FILE||it->type==CI_CMD||it->type==CI_FOLDER||it->type==CI_FOLDER_SUBMENU){ ListView_SetItemText(lv,i,3,it->path); }
        else if(it->type==CI_POWER_MENU||it->type==CI_RECENT_SUBMENU){ lv_set_text(lv,i,3,L"(auto)"); }
        else { lv_set_text(lv,i,3,L""); }
        if(it->params[0]) ListView_SetItemText(lv,i,4,it->params);
    }
}
// Map internal enum to legacy textual token used in original INI format
static const WCHAR* item_type_token(ConfigItemType t){
    switch(t){
        case CI_SEPARATOR: return L"SEPARATOR"; case CI_URI: return L"URI"; case CI_FILE: return L"FILE"; case CI_CMD: return L"CMD"; case CI_FOLDER: return L"FOLDER"; case CI_FOLDER_SUBMENU: return L"FOLDER_SUBMENU"; case CI_POWER_SLEEP: return L"POWER_SLEEP"; case CI_POWER_HIBERNATE: return L"POWER_HIBERNATE"; case CI_POWER_SHUTDOWN: return L"POWER_SHUTDOWN"; case CI_POWER_RESTART: return L"POWER_RESTART"; case CI_POWER_LOCK: return L"POWER_LOCK"; case CI_POWER_LOGOFF: return L"POWER_LOGOFF"; case CI_RECENT_SUBMENU: return L"RECENT_SUBMENU"; case CI_POWER_MENU: return L"POWER_MENU"; }
    return L"SEPARATOR";
}
static BOOL Menu_Save(HWND pg, Config* c){ UNREFERENCED_PARAMETER(pg); if(!c||!c->iniPath[0]) return FALSE; BOOL any=FALSE;
    // Legacy format: ItemN=Label|TYPE|Path|(optional Params)
    // We overwrite each ItemN key preserving compatibility with existing parser.
    WCHAR key[32]; WCHAR line[2048];
    for(int i=0;i<c->count;i++){
        ConfigItem* it=&c->items[i]; wsprintfW(key,L"Item%d",i+1);
        const WCHAR* token=item_type_token(it->type);
        if(it->type==CI_SEPARATOR){ // Always write canonical separator form
            wsprintfW(line,L"---|SEPARATOR|");
        } else {
            // Label|TYPE|
            if(it->path[0]){
                if(it->params[0]) wsprintfW(line,L"%s|%s|%s|%s",it->label,token,it->path,it->params);
                else wsprintfW(line,L"%s|%s|%s",it->label,token,it->path);
            } else {
                // Ensure trailing bar to indicate empty path field when historically present (power items)
                if(it->params[0]) wsprintfW(line,L"%s|%s||%s",it->label,token,it->params);
                else wsprintfW(line,L"%s|%s|",it->label,token);
            }
        }
        WritePrivateProfileStringW(L"Menu",key,line,c->iniPath); any=TRUE;
    }
    // Write Count for convenience (parser ignores if absent)
    WCHAR buf[16]; wsprintfW(buf,L"%d",c->count); WritePrivateProfileStringW(L"Menu",L"Count",buf,c->iniPath);
    return any; }
static void Icons_Load(HWND pg, Config* c){
    HWND lv=GetDlgItem(pg,IDC_ICONS_LIST); if(!lv||!c) return;
    SettingsState* st=(SettingsState*)GetWindowLongPtrW(GetParent(pg),GWLP_USERDATA);
    ListView_SetExtendedListViewStyle(lv,LVS_EX_FULLROWSELECT|LVS_EX_GRIDLINES|LVS_EX_DOUBLEBUFFER);
    while(ListView_DeleteColumn(lv,0));
    lv_add_col(lv,0,40,L"#");
    lv_add_col(lv,1,120,L"Label");
    lv_add_col(lv,2,110,L"Main");
    lv_add_col(lv,3,110,L"Light");
    lv_add_col(lv,4,110,L"Dark");
    ListView_DeleteAllItems(lv);
    ConfigItem* arr=c->items; int cnt=c->count;
    if(st && st->workingCount>0){ arr=st->workingItems; cnt=st->workingCount; }
    for(int i=0;i<cnt;i++){
        ConfigItem* it=&arr[i];
        if(it->type==CI_SEPARATOR) continue;
        int row=ListView_GetItemCount(lv);
        WCHAR idx[12]; wsprintfW(idx,L"%d",i+1);
        LVITEMW li={0}; li.mask=LVIF_TEXT|LVIF_PARAM; li.iItem=row; li.pszText=idx; li.lParam=i; ListView_InsertItem(lv,&li);
        if(it->label[0]){
            ListView_SetItemText(lv,row,1,it->label);
        } else {
            const WCHAR* tname = item_type_name(it->type);
            WCHAR tmpType[64]; lstrcpynW(tmpType,tname? tname : L"?",ARRAYSIZE(tmpType));
            ListView_SetItemText(lv,row,1,tmpType);
        }
        // Show nothing when unset instead of placeholders
    if(it->iconPath[0]) { ListView_SetItemText(lv,row,2,it->iconPath); } else { lv_set_text(lv,row,2,L""); }
    if(it->iconPathLight[0]) { ListView_SetItemText(lv,row,3,it->iconPathLight); } else { lv_set_text(lv,row,3,L""); }
    if(it->iconPathDark[0]) { ListView_SetItemText(lv,row,4,it->iconPathDark); } else { lv_set_text(lv,row,4,L""); }
    }
}
// Selection helper for Icons list (placed early so later helpers can call without forward decl)
static int icons_get_selected_index(HWND lv){
    int sel=(int)SendMessageW(lv,LVM_GETNEXTITEM,(WPARAM)-1,LVNI_SELECTED);
        if(sel<0) return -1; 
    LVITEMW li; ZeroMemory(&li,sizeof(li));
    li.iItem=sel; li.mask=LVIF_PARAM;
    if(SendMessageW(lv,LVM_GETITEM,0,(LPARAM)&li)) return (int)li.lParam;
    return -1;
}
// Enable/disable Icons page buttons based on current selection/state
static void icons_update_buttons(SettingsState* st, HWND page){
    if(!st||!page) return; HWND lv=GetDlgItem(page,IDC_ICONS_LIST); if(!lv) return; int idx=icons_get_selected_index(lv);
    BOOL can=FALSE, canClear=FALSE; if(idx>=0 && idx<st->workingCount){ ConfigItem* it=&st->workingItems[idx]; if(it->type!=CI_SEPARATOR){ can=TRUE; if(it->iconPath[0]||it->iconPathLight[0]||it->iconPathDark[0]) canClear=TRUE; }}
    EnableWindow(GetDlgItem(page,IDC_ICON_BROWSE_FILE),can);
    EnableWindow(GetDlgItem(page,IDC_ICON_BROWSE_LIGHT),can);
    EnableWindow(GetDlgItem(page,IDC_ICON_BROWSE_DARK),can);
    EnableWindow(GetDlgItem(page,IDC_ICON_CLEAR),can && canClear);
}

// Persist icon paths in legacy compatible sections
static BOOL Icons_Save(HWND pg, Config* c){ UNREFERENCED_PARAMETER(pg); if(!c||!c->iniPath[0]) return FALSE; BOOL any=FALSE;
    WCHAR key[32];
    for(int i=0;i<c->count;i++){
        ConfigItem* it=&c->items[i];
        wsprintfW(key,L"Icon%d",i+1);
        if(it->iconPath[0]){ WritePrivateProfileStringW(L"Icons",key,it->iconPath,c->iniPath); any=TRUE; } else { WritePrivateProfileStringW(L"Icons",key,NULL,c->iniPath); }
        wsprintfW(key,L"Icon%d",i+1);
        if(it->iconPathLight[0]){ WritePrivateProfileStringW(L"IconsLight",key,it->iconPathLight,c->iniPath); any=TRUE; } else { WritePrivateProfileStringW(L"IconsLight",key,NULL,c->iniPath); }
        wsprintfW(key,L"Icon%d",i+1);
        if(it->iconPathDark[0]){ WritePrivateProfileStringW(L"IconsDark",key,it->iconPathDark,c->iniPath); any=TRUE; } else { WritePrivateProfileStringW(L"IconsDark",key,NULL,c->iniPath); }
        // Remove obsolete experimental triplet
        wsprintfW(key,L"Item%d",i+1); WritePrivateProfileStringW(L"Icons",key,NULL,c->iniPath);
    }
    for(int i=c->count;i<64;i++){ wsprintfW(key,L"Item%d",i+1); WritePrivateProfileStringW(L"Icons",key,NULL,c->iniPath); }
    if(!any){
        // No icons referenced in any of the three sections: remove them entirely
        WritePrivateProfileStringW(L"Icons", NULL, NULL, c->iniPath);
        WritePrivateProfileStringW(L"IconsLight", NULL, NULL, c->iniPath);
        WritePrivateProfileStringW(L"IconsDark", NULL, NULL, c->iniPath);
    } else {
        // If there were only light/dark variants but not main we still keep sections with entries removed above
        // Clean empty companion sections (heuristic): check if main had none but flags set? Simplicity: rely on any flag.
        // Optional refinement could parse file again; omitted for performance.
    }
    return any; }

// Enable/disable Menu buttons (Add always enabled; others depend on selection & position)
// (menu_update_buttons & refresh_lists implemented later with working copy helpers)

// ---------------- Item Edit Dialog -----------------
typedef struct ItemEditCtx { ConfigItem tmp; BOOL editing; } ItemEditCtx;
static void item_fill_type_combo(HWND h){
    const struct { ConfigItemType t; const WCHAR* n; } types[]={
        {CI_SEPARATOR,L"Separator"},{CI_URI,L"URI"},{CI_FILE,L"File"},{CI_CMD,L"Command"},{CI_FOLDER,L"Folder"},{CI_FOLDER_SUBMENU,L"Folder (submenu)"},{CI_POWER_SLEEP,L"Sleep"},{CI_POWER_HIBERNATE,L"Hibernate"},{CI_POWER_SHUTDOWN,L"Shutdown"},{CI_POWER_RESTART,L"Restart"},{CI_POWER_LOCK,L"Lock"},{CI_POWER_LOGOFF,L"Logoff"},{CI_RECENT_SUBMENU,L"Recent"},{CI_POWER_MENU,L"Power Menu"}
    }; for(int i=0;i< (int)(sizeof(types)/sizeof(types[0])); i++){ int idx=(int)SendMessageW(h,CB_ADDSTRING,0,(LPARAM)types[i].n); SendMessageW(h,CB_SETITEMDATA,idx,types[i].t); }
}
static INT_PTR CALLBACK ItemEditDlg(HWND dlg, UINT msg, WPARAM wParam, LPARAM lParam){
    ItemEditCtx* ctx=(ItemEditCtx*)GetWindowLongPtrW(dlg,GWLP_USERDATA);
    switch(msg){
    case WM_INITDIALOG:{
        ctx=(ItemEditCtx*)lParam; SetWindowLongPtrW(dlg,GWLP_USERDATA,(LONG_PTR)ctx);
        HWND hType=GetDlgItem(dlg,IDC_ITEM_TYPE_COMBO); item_fill_type_combo(hType);
        // Preselect type
        int count=(int)SendMessageW(hType,CB_GETCOUNT,0,0); for(int i=0;i<count;i++){ if((ConfigItemType)SendMessageW(hType,CB_GETITEMDATA,i,0)==ctx->tmp.type){ SendMessageW(hType,CB_SETCURSEL,i,0); break; } }
        SetDlgItemTextW(dlg,IDC_ITEM_LABEL,ctx->tmp.label);
        SetDlgItemTextW(dlg,IDC_ITEM_PATH,ctx->tmp.path);
        SetDlgItemTextW(dlg,IDC_ITEM_PARAMS,ctx->tmp.params);
        return TRUE; }
    case WM_COMMAND:
        switch(LOWORD(wParam)){
        case IDOK:{
            HWND hType=GetDlgItem(dlg,IDC_ITEM_TYPE_COMBO); int sel=(int)SendMessageW(hType,CB_GETCURSEL,0,0); if(sel>=0){ ctx->tmp.type=(ConfigItemType)SendMessageW(hType,CB_GETITEMDATA,sel,0);} else ctx->tmp.type=CI_FILE;
            GetDlgItemTextW(dlg,IDC_ITEM_LABEL,ctx->tmp.label,ARRAYSIZE(ctx->tmp.label));
            GetDlgItemTextW(dlg,IDC_ITEM_PATH,ctx->tmp.path,ARRAYSIZE(ctx->tmp.path));
            GetDlgItemTextW(dlg,IDC_ITEM_PARAMS,ctx->tmp.params,ARRAYSIZE(ctx->tmp.params));
            // submenu flag is implied by CI_FOLDER_SUBMENU item type now; clear for others
            ctx->tmp.submenu = (ctx->tmp.type==CI_FOLDER_SUBMENU);
            // Basic validation
            if(ctx->tmp.type==CI_FILE||ctx->tmp.type==CI_CMD||ctx->tmp.type==CI_FOLDER){ if(!ctx->tmp.path[0]){ MessageBoxW(dlg,L"Path required for this type",L"Validation",MB_ICONWARNING); return TRUE; } }
            // URI validation relaxed: allow arbitrary text (user may supply custom handler forms)
            EndDialog(dlg,IDOK); return TRUE; }
        case IDCANCEL: EndDialog(dlg,IDCANCEL); return TRUE; }
        break;
    }
    return FALSE;
}

static BOOL edit_item_modal(HWND parent, ConfigItem* outItem, BOOL editing){
    ItemEditCtx ctx; ZeroMemory(&ctx,sizeof(ctx)); if(outItem) ctx.tmp=*outItem; else ctx.tmp.type=CI_FILE; ctx.editing=editing; INT_PTR r=DialogBoxParamW(GetModuleHandleW(NULL),MAKEINTRESOURCEW(IDD_ITEM_EDIT),parent,ItemEditDlg,(LPARAM)&ctx); if(r==IDOK){ if(outItem) *outItem=ctx.tmp; return TRUE; } return FALSE; }

// ---------------- Menu actions -----------------
static int menu_get_selected_index(HWND lv){ int sel=(int)SendMessageW(lv,LVM_GETNEXTITEM,(WPARAM)-1,LVNI_SELECTED); if(sel<0) return -1; LVITEMW li; ZeroMemory(&li,sizeof(li)); li.iItem=sel; li.mask=LVIF_PARAM; if(SendMessageW(lv,LVM_GETITEM,0,(LPARAM)&li)) return (int)li.lParam; return -1; }
static void menu_action_add(SettingsState* st, HWND pg){ if(!st) return; if(st->workingCount>=64){ MessageBoxW(pg,L"Maximum items reached",L"Menu",MB_ICONINFORMATION); return; } ConfigItem ni; ZeroMemory(&ni,sizeof(ni)); ni.type=CI_FILE; if(edit_item_modal(pg,&ni,FALSE)){ st->workingItems[st->workingCount++]=ni; st->workingDirty=TRUE; refresh_lists(st);} }
static void menu_action_edit(SettingsState* st, HWND pg){ if(!st) return; HWND lv=GetDlgItem(pg,IDC_MENU_LIST); int idx=menu_get_selected_index(lv); if(idx<0||idx>=st->workingCount) return; ConfigItem tmp=st->workingItems[idx]; if(edit_item_modal(pg,&tmp,TRUE)){ st->workingItems[idx]=tmp; st->workingDirty=TRUE; refresh_lists(st);} }
static void menu_action_delete(SettingsState* st, HWND pg){ if(!st) return; HWND lv=GetDlgItem(pg,IDC_MENU_LIST); int idx=menu_get_selected_index(lv); if(idx<0||idx>=st->workingCount) return; if(MessageBoxW(pg,L"Delete selected item?",L"Confirm",MB_ICONQUESTION|MB_OKCANCEL)!=IDOK) return; for(int i=idx;i<st->workingCount-1;i++) st->workingItems[i]=st->workingItems[i+1]; st->workingCount--; st->workingDirty=TRUE; refresh_lists(st); }
static void menu_action_move(SettingsState* st, HWND pg, int dir){ if(!st) return; HWND lv=GetDlgItem(pg,IDC_MENU_LIST); int idx=menu_get_selected_index(lv); if(idx<0) return; int ni=idx+dir; if(ni<0||ni>=st->workingCount) return; ConfigItem t=st->workingItems[idx]; st->workingItems[idx]=st->workingItems[ni]; st->workingItems[ni]=t; st->workingDirty=TRUE; refresh_lists(st); // reselect moved item
    HWND lv2=GetDlgItem(pg,IDC_MENU_LIST); int rowCount=(int)SendMessageW(lv2,LVM_GETITEMCOUNT,0,0); for(int r=0;r<rowCount;r++){ ListView_SetItemState(lv2,r,0,LVIS_SELECTED); }
    // Find new visual row with lParam==ni
    for(int r=0;r<rowCount;r++){ LVITEMW li; ZeroMemory(&li,sizeof(li)); li.iItem=r; li.mask=LVIF_PARAM; if(SendMessageW(lv2,LVM_GETITEM,0,(LPARAM)&li) && li.lParam==ni){ ListView_SetItemState(lv2,r,LVIS_SELECTED,LVIS_SELECTED); break; } }
}

// ---------------- Icons actions -----------------
static BOOL browse_icon(HWND owner, WCHAR* out, int cap){ OPENFILENAMEW ofn; ZeroMemory(&ofn,sizeof(ofn)); ofn.lStructSize=sizeof(ofn); ofn.hwndOwner=owner; ofn.lpstrFilter=L"Icons (*.ico)\0*.ico\0All Files (*.*)\0*.*\0"; ofn.nFilterIndex=1; ofn.lpstrFile=out; ofn.nMaxFile=cap; ofn.Flags=OFN_PATHMUSTEXIST|OFN_FILEMUSTEXIST; ofn.lpstrTitle=L"Select Icon"; return GetOpenFileNameW(&ofn); }
static void icons_action_browse(SettingsState* st, HWND pg, int which){ if(!st) return; HWND lv=GetDlgItem(pg,IDC_ICONS_LIST); int idx=icons_get_selected_index(lv); if(idx<0||idx>=st->workingCount) return; ConfigItem* it=&st->workingItems[idx]; WCHAR path[MAX_PATH]={0}; if(browse_icon(pg,path,ARRAYSIZE(path))){ if(which==0) lstrcpynW(it->iconPath,path,ARRAYSIZE(it->iconPath)); else if(which==1) lstrcpynW(it->iconPathLight,path,ARRAYSIZE(it->iconPathLight)); else if(which==2) lstrcpynW(it->iconPathDark,path,ARRAYSIZE(it->iconPathDark)); st->workingDirty=TRUE; refresh_lists(st);} }
static void icons_action_clear(SettingsState* st, HWND pg){ if(!st) return; HWND lv=GetDlgItem(pg,IDC_ICONS_LIST); int idx=icons_get_selected_index(lv); if(idx<0||idx>=st->workingCount) return; ConfigItem* it=&st->workingItems[idx]; it->iconPath[0]=0; it->iconPathLight[0]=0; it->iconPathDark[0]=0; st->workingDirty=TRUE; refresh_lists(st); }

// ---------------- Working copy helpers (restored) -----------------
static void working_clone(SettingsState* st){
    if(!st||!st->cfg) return;
    st->workingCount = st->cfg->count;
    if(st->workingCount>64) st->workingCount=64;
    for(int i=0;i<st->workingCount;i++) st->workingItems[i]=st->cfg->items[i];
    st->workingDirty=FALSE;
}
static void working_commit(SettingsState* st){
    if(!st||!st->cfg) return;
    if(st->workingCount<0) st->workingCount=0;
    if(st->workingCount>64) st->workingCount=64;
    st->cfg->count=st->workingCount;
    for(int i=0;i<st->workingCount;i++) st->cfg->items[i]=st->workingItems[i];
    st->workingDirty=FALSE;
}
// Enable/disable Menu buttons (Add always enabled; others depend on selection & position)
static void menu_update_buttons(SettingsState* st, HWND page){
    if(!st||!page) return;
    HWND lv=GetDlgItem(page,IDC_MENU_LIST); if(!lv) return;
    int idx=menu_get_selected_index(lv);
    int count=st->workingCount;
    BOOL hasSel=(idx>=0 && idx<count);
    EnableWindow(GetDlgItem(page,IDC_MENU_ADD), TRUE); // always enabled
    EnableWindow(GetDlgItem(page,IDC_MENU_EDIT), hasSel);
    EnableWindow(GetDlgItem(page,IDC_MENU_DELETE), hasSel);
    EnableWindow(GetDlgItem(page,IDC_MENU_UP), hasSel && idx>0);
    EnableWindow(GetDlgItem(page,IDC_MENU_DOWN), hasSel && idx < (count-1));
}
// Refresh both list views after working copy changes
static void refresh_lists(SettingsState* st){
    if(!st) return;
    if(st->pages[2]){ Menu_Load(st->pages[2],st->cfg); menu_update_buttons(st, st->pages[2]); }
    if(st->pages[3]){ Icons_Load(st->pages[3],st->cfg); icons_update_buttons(st, st->pages[3]); }
}


static void init_tabs(HWND dlg, SettingsState* st){
    st->hTabs=GetDlgItem(dlg,IDC_SETTINGS_TABS);
    TCITEMW ti; ZeroMemory(&ti,sizeof(ti)); ti.mask=TCIF_TEXT; WCHAR label[32];
    const WCHAR* names[] = {L"General",L"Placement",L"Menu",L"Icons",L"Sorting",L"Advanced"};
    for(int i=0;i<6;i++){
        lstrcpynW(label,names[i],ARRAYSIZE(label));
        ti.pszText=label;
        TabCtrl_InsertItem(st->hTabs,i,&ti);
    }

    RECT rcClient; GetClientRect(st->hTabs,&rcClient); // client of tab control (0,0 origin)
    RECT rcDisplay = rcClient; TabCtrl_AdjustRect(st->hTabs,FALSE,&rcDisplay); // area for pages (still tab-local)

    // Map to dialog coordinates.
    MapWindowPoints(st->hTabs, dlg, (POINT*)&rcDisplay, 2);

    // Determine header bottom using first tab item rectangle.
    RECT rcItem0; SetRectEmpty(&rcItem0);
    if(TabCtrl_GetItemRect(st->hTabs,0,&rcItem0)){
        MapWindowPoints(st->hTabs, dlg, (POINT*)&rcItem0, 2);
    }
    int headerBottom = rcItem0.bottom; // in dialog coords

    const int gapBelowTabs = 6;   // vertical gap under tabs
    const int leftPadding   = 12; // pad from left edge of tab control frame
    const int rightPadding  = 8;  // right margin inside frame
    const int bottomPadding = 8;  // bottom margin inside frame

    int x = rcDisplay.left + leftPadding;
    int y = headerBottom + gapBelowTabs;
    int w = (rcDisplay.right - leftPadding) - rightPadding - rcDisplay.left;
    int h = (rcDisplay.bottom - bottomPadding) - y; if(h < 0) h = 0;

    st->pages[0]=CreateDialogParamW(GetModuleHandleW(NULL),MAKEINTRESOURCEW(IDD_PAGE_GENERAL),dlg,PageDlgProc,(LPARAM)st); SetWindowPos(st->pages[0],NULL,x,y,w,h,SWP_SHOWWINDOW);
    st->pages[1]=CreateDialogParamW(GetModuleHandleW(NULL),MAKEINTRESOURCEW(IDD_PAGE_PLACEMENT),dlg,PageDlgProc,(LPARAM)st); SetWindowPos(st->pages[1],NULL,x,y,w,h,SWP_HIDEWINDOW);
    st->pages[2]=CreateDialogParamW(GetModuleHandleW(NULL),MAKEINTRESOURCEW(IDD_PAGE_MENU),dlg,PageDlgProc,(LPARAM)st); SetWindowPos(st->pages[2],NULL,x,y,w,h,SWP_HIDEWINDOW);
    st->pages[3]=CreateDialogParamW(GetModuleHandleW(NULL),MAKEINTRESOURCEW(IDD_PAGE_ICONS),dlg,PageDlgProc,(LPARAM)st); SetWindowPos(st->pages[3],NULL,x,y,w,h,SWP_HIDEWINDOW);
    st->pages[4]=CreateDialogParamW(GetModuleHandleW(NULL),MAKEINTRESOURCEW(IDD_PAGE_SORTING),dlg,PageDlgProc,(LPARAM)st); SetWindowPos(st->pages[4],NULL,x,y,w,h,SWP_HIDEWINDOW);
    st->pages[5]=CreateDialogParamW(GetModuleHandleW(NULL),MAKEINTRESOURCEW(IDD_PAGE_ADVANCED),dlg,PageDlgProc,(LPARAM)st); SetWindowPos(st->pages[5],NULL,x,y,w,h,SWP_HIDEWINDOW);

    // Attach st pointer to parent dialog for child retrieval (used in loads)
    SetWindowLongPtrW(dlg,GWLP_USERDATA,(LONG_PTR)st);
    working_clone(st);
    General_Load(st->pages[0],st->cfg);
    Placement_Load(st->pages[1],st->cfg);
    Menu_Load(st->pages[2],st->cfg);
    Icons_Load(st->pages[3],st->cfg);
    Sorting_Load(st->pages[4],st->cfg);
    Advanced_Load(st->pages[5],st->cfg);
}
// Re-layout controls inside a page (currently only Menu & Icons) when page resized
static void relayout_page(HWND page, int w, int h){
    if(!page) return;
    // Determine which page by child IDs present
    HWND lvMenu=GetDlgItem(page,IDC_MENU_LIST);
    if(lvMenu){
        // Compute natural widest button text to size buttons
        int margin=6; int btnSpacing=4; int btnPad=14; // horizontal padding inside button text area
        const int btnIds[]={IDC_MENU_ADD,IDC_MENU_EDIT,IDC_MENU_DELETE,IDC_MENU_UP,IDC_MENU_DOWN};
        int btnWidth=70; // minimum
        HDC hdc=GetDC(page); HFONT hf=(HFONT)SendMessageW(page,WM_GETFONT,0,0); HFONT of=(HFONT)SelectObject(hdc,hf);
        for(int i=0;i< (int)(sizeof(btnIds)/sizeof(btnIds[0])); i++){ HWND b=GetDlgItem(page,btnIds[i]); if(!b) continue; WCHAR txt[64]; if(GetWindowTextW(b,txt,ARRAYSIZE(txt))){ SIZE sz; if(GetTextExtentPoint32W(hdc,txt,lstrlenW(txt),&sz)){ int wCandidate=sz.cx+btnPad; if(wCandidate>btnWidth) btnWidth=wCandidate; } } }
        SelectObject(hdc,of); ReleaseDC(page,hdc);
        if(btnWidth>140) btnWidth=140; // cap
        int listRightPadding= (btnWidth + 2*margin);
        int listW = w - margin - listRightPadding; if(listW<80) listW=80;
        int listH = h - 2*margin; if(listH<40) listH=40;
        SetWindowPos(lvMenu,NULL,6,10,listW,listH,SWP_NOZORDER);
    int bx = 6 + listW + margin; // align buttons just to right of list
    int y = 10;
    int bh=28; // enlarged: resource 20 + extra vertical padding
        HWND b;
        int vgap=6; int groupGap=10;
    b=GetDlgItem(page,IDC_MENU_ADD); if(b) SetWindowPos(b,NULL,bx,y,btnWidth,bh,SWP_NOZORDER); y+=bh+vgap;
        b=GetDlgItem(page,IDC_MENU_EDIT); if(b) SetWindowPos(b,NULL,bx,y,btnWidth,bh,SWP_NOZORDER); y+=bh+vgap;
        b=GetDlgItem(page,IDC_MENU_DELETE); if(b) SetWindowPos(b,NULL,bx,y,btnWidth,bh,SWP_NOZORDER); y+=bh+groupGap;
        b=GetDlgItem(page,IDC_MENU_UP); if(b) SetWindowPos(b,NULL,bx,y,btnWidth,bh,SWP_NOZORDER); y+=bh+vgap;
        b=GetDlgItem(page,IDC_MENU_DOWN); if(b) SetWindowPos(b,NULL,bx,y,btnWidth,bh,SWP_NOZORDER);
        return;
    }
    HWND lvIcons=GetDlgItem(page,IDC_ICONS_LIST);
    if(lvIcons){
        int margin=6; int btnPad=14; int btnSpacing=6; const int btnIds[]={IDC_ICON_BROWSE_FILE,IDC_ICON_BROWSE_LIGHT,IDC_ICON_BROWSE_DARK,IDC_ICON_CLEAR};
        int btnWidth=70; HDC hdc=GetDC(page); HFONT hf=(HFONT)SendMessageW(page,WM_GETFONT,0,0); HFONT of=(HFONT)SelectObject(hdc,hf); for(int i=0;i< (int)(sizeof(btnIds)/sizeof(btnIds[0])); i++){ HWND b=GetDlgItem(page,btnIds[i]); if(!b) continue; WCHAR txt[64]; if(GetWindowTextW(b,txt,ARRAYSIZE(txt))){ SIZE sz; if(GetTextExtentPoint32W(hdc,txt,lstrlenW(txt),&sz)){ int wCandidate=sz.cx+btnPad; if(wCandidate>btnWidth) btnWidth=wCandidate; } } } SelectObject(hdc,of); ReleaseDC(page,hdc); if(btnWidth>160) btnWidth=160; int listRightPadding=(btnWidth + 2*margin);
        int listW = w - margin - listRightPadding; if(listW<80) listW=80;
        int listH = h - 2*margin; if(listH<40) listH=40;
        SetWindowPos(lvIcons,NULL,6,10,listW,listH,SWP_NOZORDER);
    int bx=6 + listW + margin; int y=10; int bh=28; HWND b;
        b=GetDlgItem(page,IDC_ICON_BROWSE_FILE); if(b) SetWindowPos(b,NULL,bx,y,btnWidth,bh,SWP_NOZORDER); y+=bh+btnSpacing;
        b=GetDlgItem(page,IDC_ICON_BROWSE_LIGHT); if(b) SetWindowPos(b,NULL,bx,y,btnWidth,bh,SWP_NOZORDER); y+=bh+btnSpacing;
        b=GetDlgItem(page,IDC_ICON_BROWSE_DARK); if(b) SetWindowPos(b,NULL,bx,y,btnWidth,bh,SWP_NOZORDER); y+=bh+btnSpacing;
        b=GetDlgItem(page,IDC_ICON_CLEAR); if(b) SetWindowPos(b,NULL,bx,y,btnWidth,bh,SWP_NOZORDER);
        return;
    }
}
static void show_page(SettingsState* st,int idx){ for(int i=0;i<6;i++){ if(st->pages[i]) ShowWindow(st->pages[i], i==idx?SW_SHOW:SW_HIDE); } }
static BOOL save_all(SettingsState* st){ if(!st) return FALSE; if(st->workingDirty){ working_commit(st); } BOOL any=FALSE; any|=General_Save(st->pages[0],st->cfg); any|=Placement_Save(st->pages[1],st->cfg); any|=Advanced_Save(st->pages[5],st->cfg); any|=Menu_Save(st->pages[2],st->cfg); any|=Icons_Save(st->pages[3],st->cfg); any|=Sorting_Save(st->pages[4],st->cfg); return any; }

static INT_PTR CALLBACK MainDlgProc(HWND dlg, UINT msg, WPARAM wParam, LPARAM lParam){
    static SettingsState* st=NULL;
    switch(msg){
    case WM_GETMINMAXINFO:
        if(st){
            MINMAXINFO* mmi=(MINMAXINFO*)lParam;
            mmi->ptMinTrackSize.x = st->baseW;
            mmi->ptMinTrackSize.y = st->baseH;
        }
        return 0;
    case WM_SYSCOMMAND:
        if((wParam & 0xFFF0) == SC_CLOSE){
            EndDialog(dlg, IDCANCEL);
            return TRUE;
        }
        break;
    case WM_CLOSE:
        EndDialog(dlg, IDCANCEL);
        return TRUE;
    case WM_INITDIALOG:
        st=(SettingsState*)calloc(1,sizeof(SettingsState));
        st->cfg=(Config*)lParam;
        {
            RECT rc; GetWindowRect(dlg,&rc); st->baseW = rc.right-rc.left; st->baseH = rc.bottom-rc.top;
        }
        {
            LONG_PTR ex=GetWindowLongPtrW(dlg,GWL_EXSTYLE); SetWindowLongPtrW(dlg,GWL_EXSTYLE,ex|WS_EX_APPWINDOW);
        }
        apply_dialog_icon(dlg,st->cfg);
        init_tabs(dlg,st);
        // Center window manually (DS_CENTER removed). Use work area.
        {
            RECT rc; GetWindowRect(dlg,&rc); RECT wa; SystemParametersInfoW(SPI_GETWORKAREA,0,&wa,0);
            int w=rc.right-rc.left; int h=rc.bottom-rc.top;
            int x=wa.left + ( (wa.right-wa.left) - w)/2; int y=wa.top + ( (wa.bottom-wa.top) - h)/2;
            SetWindowPos(dlg,NULL,x,y,0,0,SWP_NOZORDER|SWP_NOSIZE);
        }
        return TRUE;
    case WM_SIZE:
        if(st){
            int cw = LOWORD(lParam); int ch = HIWORD(lParam);
            // Layout: buttons anchored bottom-right, tabs fill remaining above button row
            HWND hApply=GetDlgItem(dlg,IDC_APPLY);
            HWND hSave=GetDlgItem(dlg,IDC_SAVEEXIT);
            HWND hCancel=GetDlgItem(dlg,IDC_CANCEL);
            RECT rb; GetWindowRect(hApply,&rb); MapWindowPoints(NULL,dlg,(POINT*)&rb,2); int btnH = rb.bottom-rb.top; int btnW = rb.right-rb.left;
            int margin=6; int gap=4;
            int cancelW, cancelH; RECT rc; GetWindowRect(hCancel,&rc); MapWindowPoints(NULL,dlg,(POINT*)&rc,2); cancelW=rc.right-rc.left; cancelH=rc.bottom-rc.top;
            int saveW, saveH; GetWindowRect(hSave,&rc); MapWindowPoints(NULL,dlg,(POINT*)&rc,2); saveW=rc.right-rc.left; saveH=rc.bottom-rc.top;
            int applyW, applyH; GetWindowRect(hApply,&rc); MapWindowPoints(NULL,dlg,(POINT*)&rc,2); applyW=rc.right-rc.left; applyH=rc.bottom-rc.top;
            int btnY = ch - margin - btnH;
            // Total width of button cluster with equal gaps
            int totalW = applyW + saveW + cancelW + gap*2;
            // Center cluster; keep at least margin from edges
            int clusterX = (cw - totalW)/2; if(clusterX < margin) clusterX = margin; if(clusterX + totalW > cw - margin) clusterX = cw - margin - totalW;
            int xApply = clusterX;
            int xSave  = xApply + applyW + gap;
            int xCancel= xSave + saveW + gap;
            SetWindowPos(hApply,NULL,xApply,btnY,0,0,SWP_NOZORDER|SWP_NOSIZE);
            SetWindowPos(hSave,NULL,xSave,btnY,0,0,SWP_NOZORDER|SWP_NOSIZE);
            SetWindowPos(hCancel,NULL,xCancel,btnY,0,0,SWP_NOZORDER|SWP_NOSIZE);
            // Resize tab control
            HWND hTabs=st->hTabs; if(hTabs){
                RECT rTabs; GetWindowRect(hTabs,&rTabs); MapWindowPoints(NULL,dlg,(POINT*)&rTabs,2);
                int tabsX = rTabs.left; int tabsY = rTabs.top; // keep original top-left
                int tabsW = cw - tabsX - margin;
                int tabsH = btnY - tabsY - margin;
                if(tabsW<100) tabsW=100; if(tabsH<100) tabsH=100;
                SetWindowPos(hTabs,NULL,tabsX,tabsY,tabsW,tabsH,SWP_NOZORDER);
                // Adjust pages to new tab display area
                RECT rcClient; GetClientRect(hTabs,&rcClient); RECT rcDisplay=rcClient; TabCtrl_AdjustRect(hTabs,FALSE,&rcDisplay); MapWindowPoints(hTabs,dlg,(POINT*)&rcDisplay,2);
                // Compute consistent padding like in init_tabs
                RECT rItem0; if(TabCtrl_GetItemRect(hTabs,0,&rItem0)){ MapWindowPoints(hTabs,dlg,(POINT*)&rItem0,2);} int headerBottom=rItem0.bottom; int gapBelowTabs=6; int leftPadding=12; int rightPadding=8; int bottomPadding=8;
                int x = rcDisplay.left + leftPadding; int y = headerBottom + gapBelowTabs; int w = (rcDisplay.right - leftPadding) - rightPadding - rcDisplay.left; int h = (rcDisplay.bottom - bottomPadding) - y; if(h<0) h=0;
                for(int i=0;i<6;i++){ if(st->pages[i]){ SetWindowPos(st->pages[i],NULL,x,y,w,h,SWP_NOZORDER); relayout_page(st->pages[i],w,h); } }
            }
        }
        return 0;
    case WM_NOTIFY:{
        LPNMHDR nh=(LPNMHDR)lParam;
        if(nh->idFrom==IDC_SETTINGS_TABS && nh->code==TCN_SELCHANGE){
            int sel=TabCtrl_GetCurSel(st->hTabs);
            show_page(st,sel);
            if(sel==2) menu_update_buttons(st, st->pages[2]);
            if(sel==3) icons_update_buttons(st, st->pages[3]);
        }
        // Live selection changes in Icons list
        if(nh->idFrom==IDC_ICONS_LIST && nh->code==LVN_ITEMCHANGED){
            LPNMLISTVIEW lv=(LPNMLISTVIEW)nh; if((lv->uChanged & LVIF_STATE) && ( (lv->uNewState^lv->uOldState) & LVIS_SELECTED)){
                icons_update_buttons(st, st->pages[3]);
            }
        }
        // Live selection changes in Menu list
        if(nh->idFrom==IDC_MENU_LIST && nh->code==LVN_ITEMCHANGED){
            LPNMLISTVIEW lv=(LPNMLISTVIEW)nh; if((lv->uChanged & LVIF_STATE) && ( (lv->uNewState^lv->uOldState) & LVIS_SELECTED)){
                menu_update_buttons(st, st->pages[2]);
            }
        }
        break; }
    case WM_COMMAND:
        switch(LOWORD(wParam)){
            case IDC_APPLY: save_all(st); return TRUE;
            case IDC_SAVEEXIT: save_all(st); EndDialog(dlg,IDOK); return TRUE;
            case IDC_CANCEL: EndDialog(dlg,IDCANCEL); return TRUE;
            case IDC_OPEN_CONFIG_FOLDER: {
                if(st && st->cfg && st->cfg->iniPath[0]){
                    WCHAR folder[MAX_PATH]; lstrcpynW(folder, st->cfg->iniPath, ARRAYSIZE(folder));
                    PathRemoveFileSpecW(folder);
                    if(folder[0]) ShellExecuteW(dlg, L"open", folder, NULL, NULL, SW_SHOWNORMAL);
                }
                return TRUE; }
            case IDC_MENU_ADD: menu_action_add(st, st->pages[2]); return TRUE;
            case IDC_MENU_EDIT: menu_action_edit(st, st->pages[2]); return TRUE;
            case IDC_MENU_DELETE: menu_action_delete(st, st->pages[2]); return TRUE;
            case IDC_MENU_UP: menu_action_move(st, st->pages[2], -1); return TRUE;
            case IDC_MENU_DOWN: menu_action_move(st, st->pages[2], 1); return TRUE;
            case IDC_ICON_BROWSE_FILE: icons_action_browse(st, st->pages[3], 0); return TRUE;
            case IDC_ICON_BROWSE_LIGHT: icons_action_browse(st, st->pages[3], 1); return TRUE;
            case IDC_ICON_BROWSE_DARK: icons_action_browse(st, st->pages[3], 2); return TRUE;
            case IDC_ICON_CLEAR: icons_action_clear(st, st->pages[3]); return TRUE;
        }
        break;
    case WM_DESTROY:
        if(st){
            if(st->hItalic){ DeleteObject(st->hItalic); st->hItalic=NULL; }
            free(st); st=NULL;
        }
        break;
    }
    return FALSE;
}

BOOL ShowSettingsDialog(HWND owner, Config* cfg){ UNREFERENCED_PARAMETER(owner); if(!cfg) return FALSE; static BOOL active=FALSE; if(active) return FALSE; active=TRUE; INT_PTR r=DialogBoxParamW(GetModuleHandleW(NULL),MAKEINTRESOURCEW(IDD_SETTINGS),owner?owner:NULL,MainDlgProc,(LPARAM)cfg); active=FALSE; return (r==IDOK); }
