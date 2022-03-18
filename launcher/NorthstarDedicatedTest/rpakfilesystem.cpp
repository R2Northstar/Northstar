#include "pch.h"
#include "rpakfilesystem.h"
#include "hookutils.h"
#include "modmanager.h"

typedef void* (*LoadCommonPaksForMapType)(char* map);
LoadCommonPaksForMapType LoadCommonPaksForMap;

typedef void* (*LoadPakSyncType)(const char* path, void* unknownSingleton, int flags);
typedef int(*LoadPakAsyncType)(const char* path, void* unknownSingleton, int flags, void* callback0, void* callback1);

// there are more i'm just too lazy to add
struct PakLoadFuncs
{
	void* unknown[2];
	LoadPakSyncType LoadPakSync;
	LoadPakAsyncType LoadPakAsync;
};

PakLoadFuncs* g_pakLoadApi;
void** pUnknownPakLoadSingleton;

PakLoadManager* g_PakLoadManager;
void PakLoadManager::LoadPakSync(const char* path) { g_pakLoadApi->LoadPakSync(path, *pUnknownPakLoadSingleton, 0); }
void PakLoadManager::LoadPakAsync(const char* path) { g_pakLoadApi->LoadPakAsync(path, *pUnknownPakLoadSingleton, 2, nullptr, nullptr); }

void HandlePakAliases(char** map)
{
	// convert the pak being loaded to it's aliased one, e.g. aliasing mp_hub_timeshift => sp_hub_timeshift
	for (int64_t i = g_ModManager->m_loadedMods.size() - 1; i > -1; i--)
	{
		Mod* mod = &g_ModManager->m_loadedMods[i];
		if (!mod->Enabled)
			continue;

		if (mod->RpakAliases.find(*map) != mod->RpakAliases.end())
		{
			*map = &mod->RpakAliases[*map][0];
			return;
		}
	}
}

bool bShouldPreload = true;
void LoadPreloadPaks()
{
	// disable preloading while we're doing this
	bShouldPreload = false;

	// note, loading from ./ is necessary otherwise paks will load from gamedir/r2/paks
	for (Mod& mod : g_ModManager->m_loadedMods)
	{
		if (!mod.Enabled)
			continue;

		// need to get a relative path of mod to mod folder
		fs::path modPakPath("./" / mod.ModDirectory / "paks");

		for (ModRpakEntry& pak : mod.Rpaks)
			if (pak.m_bAutoLoad)
				g_PakLoadManager->LoadPakAsync((modPakPath / pak.m_sPakPath).string().c_str());
	} 

	bShouldPreload = true;
}

LoadPakSyncType LoadPakSyncOriginal;
void* LoadPakSyncHook(char* path, void* unknownSingleton, int flags)
{ 
	HandlePakAliases(&path);
	// note: we don't handle loading any preloaded custom paks synchronously since LoadPakSync is never actually called in retail, just load them async instead
	LoadPreloadPaks();

	spdlog::info("LoadPakSync {}", path);
	return LoadPakSyncOriginal(path, unknownSingleton, flags); 
}

LoadPakAsyncType LoadPakAsyncOriginal;
int LoadPakAsyncHook(char* path, void* unknownSingleton, int flags, void* callback0, void* callback1)
{
	HandlePakAliases(&path);

	if (bShouldPreload)
		LoadPreloadPaks();

	int ret = LoadPakAsyncOriginal(path, unknownSingleton, flags, callback0, callback1);
	spdlog::info("LoadPakAsync {} {}", path, ret);
	return ret;
}

void InitialiseEngineRpakFilesystem(HMODULE baseAddress)
{
	g_PakLoadManager = new PakLoadManager;

	g_pakLoadApi = *(PakLoadFuncs**)((char*)baseAddress + 0x5BED78);
	pUnknownPakLoadSingleton = (void**)((char*)baseAddress + 0x7C5E20);

	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, g_pakLoadApi->LoadPakSync, &LoadPakSyncHook, reinterpret_cast<LPVOID*>(&LoadPakSyncOriginal));
	ENABLER_CREATEHOOK(hook, g_pakLoadApi->LoadPakAsync, &LoadPakAsyncHook, reinterpret_cast<LPVOID*>(&LoadPakAsyncOriginal));
}