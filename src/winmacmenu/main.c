#include <Windows.h>

int WINAPI WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow) {

    INPUT inputs[4] = { 0 };

    // Press Win key
    inputs[0].type = INPUT_KEYBOARD;
    inputs[0].ki.wVk = VK_LWIN;

    // Press X key
    inputs[1].type = INPUT_KEYBOARD;
    inputs[1].ki.wVk = 'X';

    // Release X key
    inputs[2].type = INPUT_KEYBOARD;
    inputs[2].ki.wVk = 'X';
    inputs[2].ki.dwFlags = KEYEVENTF_KEYUP;

    // Release Win key
    inputs[3].type = INPUT_KEYBOARD;
    inputs[3].ki.wVk = VK_LWIN;
    inputs[3].ki.dwFlags = KEYEVENTF_KEYUP;

    SendInput(4, inputs, sizeof(INPUT));
    return 0;
}
