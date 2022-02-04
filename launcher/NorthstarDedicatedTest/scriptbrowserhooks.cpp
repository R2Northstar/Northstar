#include "pch.h"
#include "scriptbrowserhooks.h"
#include "hookutils.h"
#include "dedicated.h"

typedef void (*OpenExternalWebBrowserType)(char* url, char flags);
OpenExternalWebBrowserType OpenExternalWebBrowser;

bool* bIsOriginOverlayEnabled;

void OpenExternalWebBrowserHook(char* url, char flags)
{
	bool bIsOriginOverlayEnabledOriginal = *bIsOriginOverlayEnabled;
	if (flags & 2 && !strncmp(url, "http", 4)) // custom force external browser flag
		*bIsOriginOverlayEnabled = false; // if this bool is false, game will use an external browser rather than the origin overlay one

	OpenExternalWebBrowser(url, flags);
	*bIsOriginOverlayEnabled = bIsOriginOverlayEnabledOriginal;
}

void InitialiseScriptExternalBrowserHooks(HMODULE baseAddress)
{
	if (IsDedicated())
		return;

	bIsOriginOverlayEnabled = (bool*)baseAddress + 0x13978255;

	HookEnabler hook;
	ENABLER_CREATEHOOK(
		hook, (char*)baseAddress + 0x184E40, &OpenExternalWebBrowserHook, reinterpret_cast<LPVOID*>(&OpenExternalWebBrowser));
}