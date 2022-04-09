#include "pch.h"
#include "rpakfilesystem.h"
#include "hookutils.h"
#include "modmanager.h"

typedef void* (*LoadCommonPaksForMapType)(char* map);
LoadCommonPaksForMapType LoadCommonPaksForMap;

typedef void* (*LoadPakSyncType)(const char* path, void* unknownSingleton, int flags);
typedef int (*LoadPakAsyncType)(const char* path, void* unknownSingleton, int flags, void* callback0, void* callback1);
typedef void* (*ReadFullFileFromDiskType)(const char* requestedPath, void* a2);

// there are more i'm just too lazy to add
struct PakLoadFuncs
{
	void* unk0[2];
	LoadPakSyncType LoadPakSync;
	LoadPakAsyncType LoadPakAsync;
	void* unk1[20];
	ReadFullFileFromDiskType ReadFullFileFromDisk;
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

void LoadPreloadPaks()
{
	// note, loading from ./ is necessary otherwise paks will load from gamedir/r2/paks
	for (Mod& mod : g_ModManager->m_loadedMods)
	{
		if (!mod.Enabled)
			continue;

		// need to get a relative path of mod to mod folder
		fs::path modPakPath("./" / mod.ModDirectory / "paks");

		for (ModRpakEntry& pak : mod.Rpaks)
			if (pak.m_bAutoLoad)
				g_PakLoadManager->LoadPakAsync((modPakPath / pak.m_sPakName).string().c_str());
	}
}

void LoadCustomMapPaks(char** pakName)
{
	// whether the vanilla game has this rpak
	bool bHasOriginalPak = fs::exists(fs::path("./r2/paks") / *pakName);

	// note, loading from ./ is necessary otherwise paks will load from gamedir/r2/paks
	for (Mod& mod : g_ModManager->m_loadedMods)
	{
		if (!mod.Enabled)
			continue;

		// need to get a relative path of mod to mod folder
		fs::path modPakPath("./" / mod.ModDirectory / "paks");

		for (ModRpakEntry& pak : mod.Rpaks)
		{
			if (!pak.m_bAutoLoad && !pak.m_sPakName.compare(*pakName))
			{
				// if the game doesn't have the original pak, let it handle loading this one as if it was the one it was loading originally
				if (!bHasOriginalPak)
				{
					*pakName = &pak.m_sPakName[0];
					bHasOriginalPak = true;
				}
				else
					g_PakLoadManager->LoadPakAsync((modPakPath / pak.m_sPakName).string().c_str());
			}
		}
	}
}

LoadPakSyncType LoadPakSyncOriginal;
void* LoadPakSyncHook(char* path, void* unknownSingleton, int flags)
{
	HandlePakAliases(&path);

	// note: we don't handle loading any preloaded custom paks synchronously since LoadPakSync is never actually called in retail, just load
	// them async instead
	static bool bShouldLoadPaks = true;
	if (bShouldLoadPaks)
	{
		// disable preloading while we're doing this
		bShouldLoadPaks = false;

		LoadPreloadPaks();
		LoadCustomMapPaks(&path);

		bShouldLoadPaks = true;
	}

	spdlog::info("LoadPakSync {}", path);
	return LoadPakSyncOriginal(path, unknownSingleton, flags);
}

LoadPakAsyncType LoadPakAsyncOriginal;
int LoadPakAsyncHook(char* path, void* unknownSingleton, int flags, void* callback0, void* callback1)
{
	HandlePakAliases(&path);

	static bool bShouldLoadPaks = true;
	if (bShouldLoadPaks)
	{
		// disable preloading while we're doing this
		bShouldLoadPaks = false;

		LoadPreloadPaks();
		LoadCustomMapPaks(&path);

		bShouldLoadPaks = true;
	}

	int ret = LoadPakAsyncOriginal(path, unknownSingleton, flags, callback0, callback1);
	spdlog::info("LoadPakAsync {} {}", path, ret);
	return ret;
}

// we hook this exclusively for resolving stbsp paths, but seemingly it's also used for other stuff like vpk and rpak loads
// possibly just async loading all together?
ReadFullFileFromDiskType ReadFullFileFromDiskOriginal;
void* ReadFullFileFromDiskHook(const char* requestedPath, void* a2)
{
	fs::path path(requestedPath);
	char* allocatedNewPath = nullptr;

	if (path.extension() == ".stbsp")
	{
		fs::path filename = path.filename();
		spdlog::info("LoadStreamBsp: {}", filename.string());

		// resolve modded stbsp path so we can load mod stbsps
		auto modFile = g_ModManager->m_modFiles.find(fs::path("maps" / filename).lexically_normal().string());
		if (modFile != g_ModManager->m_modFiles.end())
		{
			// need to allocate a new string for this
			std::string newPath = (modFile->second.owningMod->ModDirectory / "mod" / modFile->second.path).string();
			allocatedNewPath = new char[newPath.size() + 1];
			strncpy(allocatedNewPath, newPath.c_str(), newPath.size());
			allocatedNewPath[newPath.size() + 1] = '\0';
			requestedPath = allocatedNewPath;
		}
	}

	void* ret = ReadFullFileFromDiskOriginal(requestedPath, a2);
	if (allocatedNewPath)
		delete[] allocatedNewPath;

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
	ENABLER_CREATEHOOK(
		hook, g_pakLoadApi->ReadFullFileFromDisk, &ReadFullFileFromDiskHook, reinterpret_cast<LPVOID*>(&ReadFullFileFromDiskOriginal));
}