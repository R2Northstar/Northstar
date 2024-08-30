#include "mods/modmanager.h"

void* g_pVguiLocalize;

static bool(__fastcall* o_pCLocalise__AddFile)(
	void* pVguiLocalize, const char* path, const char* pathId, bool bIncludeFallbackSearchPaths) = nullptr;
static bool __fastcall h_CLocalise__AddFile(void* pVguiLocalize, const char* path, const char* pathId, bool bIncludeFallbackSearchPaths)
{
	// save this for later
	g_pVguiLocalize = pVguiLocalize;

	bool ret = o_pCLocalise__AddFile(pVguiLocalize, path, pathId, bIncludeFallbackSearchPaths);
	if (ret)
		spdlog::info("Loaded localisation file {} successfully", path);

	return true;
}

static void(__fastcall* o_pCLocalize__ReloadLocalizationFiles)(void* pVguiLocalize) = nullptr;
static void __fastcall h_CLocalize__ReloadLocalizationFiles(void* pVguiLocalize)
{
	// load all mod localization manually, so we keep track of all files, not just previously loaded ones
	for (Mod mod : g_pModManager->m_LoadedMods)
		if (mod.m_bEnabled)
			for (std::string& localisationFile : mod.LocalisationFiles)
				o_pCLocalise__AddFile(g_pVguiLocalize, localisationFile.c_str(), nullptr, false);

	spdlog::info("reloading localization...");
	o_pCLocalize__ReloadLocalizationFiles(pVguiLocalize);
}

static void(__fastcall* o_pCEngineVGui__Init)(void* self) = nullptr;
static void __fastcall h_CEngineVGui__Init(void* self)
{
	o_pCEngineVGui__Init(self); // this loads r1_english, valve_english, dev_english

	// previously we did this in CLocalize::AddFile, but for some reason it won't properly overwrite localization from
	// files loaded previously if done there, very weird but this works so whatever
	for (Mod mod : g_pModManager->m_LoadedMods)
		if (mod.m_bEnabled)
			for (std::string& localisationFile : mod.LocalisationFiles)
				o_pCLocalise__AddFile(g_pVguiLocalize, localisationFile.c_str(), nullptr, false);
}

ON_DLL_LOAD_CLIENT("engine.dll", VGuiInit, (CModule module))
{
	o_pCEngineVGui__Init = module.Offset(0x247E10).RCast<decltype(o_pCEngineVGui__Init)>();
	HookAttach(&(PVOID&)o_pCEngineVGui__Init, (PVOID)h_CEngineVGui__Init);
}

ON_DLL_LOAD_CLIENT("localize.dll", Localize, (CModule module))
{
	o_pCLocalise__AddFile = module.Offset(0x6D80).RCast<decltype(o_pCLocalise__AddFile)>();
	HookAttach(&(PVOID&)o_pCLocalise__AddFile, (PVOID)h_CLocalise__AddFile);

	o_pCLocalize__ReloadLocalizationFiles = module.Offset(0xB830).RCast<decltype(o_pCLocalize__ReloadLocalizationFiles)>();
	HookAttach(&(PVOID&)o_pCLocalize__ReloadLocalizationFiles, (PVOID)h_CLocalize__ReloadLocalizationFiles);
}
