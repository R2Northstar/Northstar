#include "pch.h"

AUTOHOOK_INIT()

bool* bIsOriginOverlayEnabled;

// clang-format off
AUTOHOOK(OpenExternalWebBrowser, engine.dll + 0x184E40, 
void, __fastcall, (char* pUrl, char flags))
// clang-format on
{
	bool bIsOriginOverlayEnabledOriginal = *bIsOriginOverlayEnabled;
	if (flags & 2 && !strncmp(pUrl, "http", 4)) // custom force external browser flag
		*bIsOriginOverlayEnabled = false; // if this bool is false, game will use an external browser rather than the origin overlay one

	OpenExternalWebBrowser(pUrl, flags);
	*bIsOriginOverlayEnabled = bIsOriginOverlayEnabledOriginal;
}

ON_DLL_LOAD_CLIENT("engine.dll", ScriptExternalBrowserHooks, (CModule module))
{
	AUTOHOOK_DISPATCH()

	bIsOriginOverlayEnabled = module.Offset(0x13978255).As<bool*>();
}
