
bool* bIsOriginOverlayEnabled;

static void(__fastcall* o_pOpenExternalWebBrowser)(char* pUrl, char flags) = nullptr;
static void __fastcall h_OpenExternalWebBrowser(char* pUrl, char flags)
{
	bool bIsOriginOverlayEnabledOriginal = *bIsOriginOverlayEnabled;
	bool isHttp = !strncmp(pUrl, "http://", 7) || !strncmp(pUrl, "https://", 8);
	if (flags & 2 && isHttp) // custom force external browser flag
		*bIsOriginOverlayEnabled = false; // if this bool is false, game will use an external browser rather than the origin overlay one

	o_pOpenExternalWebBrowser(pUrl, flags);
	*bIsOriginOverlayEnabled = bIsOriginOverlayEnabledOriginal;
}

ON_DLL_LOAD_CLIENT("engine.dll", ScriptExternalBrowserHooks, (CModule module))
{
	o_pOpenExternalWebBrowser = module.Offset(0x184E40).RCast<decltype(o_pOpenExternalWebBrowser)>();
	HookAttach(&(PVOID&)o_pOpenExternalWebBrowser, (PVOID)h_OpenExternalWebBrowser);

	bIsOriginOverlayEnabled = module.Offset(0x13978255).RCast<bool*>();
}
