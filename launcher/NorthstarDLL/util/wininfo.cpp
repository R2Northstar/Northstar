#include "pch.h"

AUTOHOOK_INIT()

HWND* g_gameHWND;
HMODULE g_NorthstarModule = 0;

ON_DLL_LOAD("engine.dll", WinInfo, (CModule module))
{
	g_gameHWND = module.Offset(0x7d88a0).As<HWND*>();
}
