`WIP`

## WinMac installation on Windows 10

WinMac can be partially installed on Windows 10 22H2+ as well. Only components that are not supported are:

1. StartAllBack
2. WinMac Menu

You can use [TaskbarX](https://taskbarx.org/) and [OldNewExplorer](https://www.majorgeeks.com/files/details/oldnewexplorer.html) to immitate StartAllBack functionality, by enabling:

1. TaskbarX
2. OldNewExplorer
- *Use command bar instaed of Ribbon* for Windows 7 File Explorer style
- *Use classical drive grouping in This PC*

For WinMac Menu you need to replace content of *C:\Users\Adams\AppData\Local\Microsoft\Windows\WinX* folder, by removing its content first, and copying files from [WinX folder from repository](https://github.com/Asteski/WinMac/tree/main/config/winx) to WinX folder in AppData.

You then need to replace About 