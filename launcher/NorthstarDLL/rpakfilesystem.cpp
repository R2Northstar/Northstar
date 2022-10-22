#include "pch.h"
#include "rpakfilesystem.h"
#include "modmanager.h"
#include "dedicated.h"
#include "tier0.h"

AUTOHOOK_INIT()

// there are more i'm just too lazy to add
struct PakLoadFuncs
{
	void* unk0[3];
	int (*LoadPakAsync)(const char* pPath, void* unknownSingleton, int flags, void* callback0, void* callback1);
	void* unk1[2];
	void* (*UnloadPak)(int iPakHandle, void* callback);
	void* unk2[6];
	void* (*LoadFile)(const char* path); // unsure
	void* unk3[10];
	void* (*ReadFileAsync)(const char* pPath, void* a2);
};

PakLoadFuncs* g_pakLoadApi;

PakLoadManager* g_pPakLoadManager;
void** pUnknownPakLoadSingleton;

int PakLoadManager::LoadPakAsync(const char* pPath, const ePakLoadSource nLoadSource)
{
	int nHandle = g_pakLoadApi->LoadPakAsync(pPath, *pUnknownPakLoadSingleton, 2, nullptr, nullptr);

	// set the load source of the pak we just loaded
	if (nHandle != -1)
		GetPakInfo(nHandle)->m_nLoadSource = nLoadSource;

	return nHandle;
}

void PakLoadManager::UnloadPak(const int nPakHandle)
{
	g_pakLoadApi->UnloadPak(nPakHandle, nullptr);
}

void PakLoadManager::UnloadMapPaks()
{
	for (auto& pair : m_vLoadedPaks)
		if (pair.second.m_nLoadSource == ePakLoadSource::MAP)
			UnloadPak(pair.first);
}

LoadedPak* PakLoadManager::TrackLoadedPak(ePakLoadSource nLoadSource, int nPakHandle, size_t nPakNameHash)
{
	LoadedPak pak;
	pak.m_nLoadSource = nLoadSource;
	pak.m_nPakHandle = nPakHandle;
	pak.m_nPakNameHash = nPakNameHash;

	m_vLoadedPaks.insert(std::make_pair(nPakHandle, pak));
	return &m_vLoadedPaks.at(nPakHandle);
}

void PakLoadManager::RemoveLoadedPak(int nPakHandle)
{
	m_vLoadedPaks.erase(nPakHandle);
}

LoadedPak* PakLoadManager::GetPakInfo(const int nPakHandle)
{
	return &m_vLoadedPaks.at(nPakHandle);
}

int PakLoadManager::GetPakHandle(const size_t nPakNameHash)
{
	for (auto& pair : m_vLoadedPaks)
		if (pair.second.m_nPakNameHash == nPakNameHash)
			return pair.first;

	return -1;
}

int PakLoadManager::GetPakHandle(const char* pPath)
{
	return GetPakHandle(STR_HASH(pPath));
}

void* PakLoadManager::LoadFile(const char* path)
{
	return g_pakLoadApi->LoadFile(path);
}

void HandlePakAliases(char** map)
{
	// convert the pak being loaded to it's aliased one, e.g. aliasing mp_hub_timeshift => sp_hub_timeshift
	for (int64_t i = g_pModManager->m_LoadedMods.size() - 1; i > -1; i--)
	{
		Mod* mod = &g_pModManager->m_LoadedMods[i];
		if (!mod->m_bEnabled)
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
	for (Mod& mod : g_pModManager->m_LoadedMods)
	{
		if (!mod.m_bEnabled)
			continue;

		// need to get a relative path of mod to mod folder
		fs::path modPakPath("./" / mod.m_ModDirectory / "paks");

		for (ModRpakEntry& pak : mod.Rpaks)
			if (pak.m_bAutoLoad)
				g_pPakLoadManager->LoadPakAsync((modPakPath / pak.m_sPakName).string().c_str(), ePakLoadSource::CONSTANT);
	}
}

void LoadPostloadPaks(const char* pPath)
{
	// note, loading from ./ is necessary otherwise paks will load from gamedir/r2/paks
	for (Mod& mod : g_pModManager->m_LoadedMods)
	{
		if (!mod.m_bEnabled)
			continue;

		// need to get a relative path of mod to mod folder
		fs::path modPakPath("./" / mod.m_ModDirectory / "paks");

		for (ModRpakEntry& pak : mod.Rpaks)
			if (pak.m_sLoadAfterPak == pPath)
				g_pPakLoadManager->LoadPakAsync((modPakPath / pak.m_sPakName).string().c_str(), ePakLoadSource::CONSTANT);
	}
}

void LoadCustomMapPaks(char** pakName, bool* bNeedToFreePakName)
{
	// whether the vanilla game has this rpak
	bool bHasOriginalPak = fs::exists(fs::path("r2/paks/Win64/") / *pakName);

	// note, loading from ./ is necessary otherwise paks will load from gamedir/r2/paks
	for (Mod& mod : g_pModManager->m_LoadedMods)
	{
		if (!mod.m_bEnabled)
			continue;

		// need to get a relative path of mod to mod folder
		fs::path modPakPath("./" / mod.m_ModDirectory / "paks");

		for (ModRpakEntry& pak : mod.Rpaks)
		{
			if (!pak.m_bAutoLoad && !pak.m_sPakName.compare(*pakName))
			{
				// if the game doesn't have the original pak, let it handle loading this one as if it was the one it was loading originally
				if (!bHasOriginalPak)
				{
					std::string path = (modPakPath / pak.m_sPakName).string();
					*pakName = new char[path.size() + 1];
					strcpy(*pakName, &path[0]);
					(*pakName)[path.size()] = '\0';

					bHasOriginalPak = true;
					*bNeedToFreePakName =
						true; // we can't free this memory until we're done with the pak, so let whatever's calling this deal with it
				}
				else
					g_pPakLoadManager->LoadPakAsync((modPakPath / pak.m_sPakName).string().c_str(), ePakLoadSource::MAP);
			}
		}
	}
}

// clang-format off
HOOK(LoadPakAsyncHook, LoadPakAsync,
int, __fastcall, (char* pPath, void* unknownSingleton, int flags, void* pCallback0, void* pCallback1))
// clang-format on
{
	HandlePakAliases(&pPath);

	// dont load the pak if it's currently loaded already
	size_t nPathHash = STR_HASH(pPath);
	if (g_pPakLoadManager->GetPakHandle(nPathHash) != -1)
		return -1;

	bool bNeedToFreePakName = false;

	static bool bShouldLoadPaks = true;
	if (bShouldLoadPaks)
	{
		// make a copy of the path for comparing to determine whether we should load this pak on dedi, before it could get overwritten by
		// LoadCustomMapPaks
		std::string originalPath(pPath);

		// disable preloading while we're doing this
		bShouldLoadPaks = false;

		LoadPreloadPaks();
		LoadCustomMapPaks(&pPath, &bNeedToFreePakName);

		bShouldLoadPaks = true;

		// do this after custom paks load and in bShouldLoadPaks so we only ever call this on the root pakload call
		// todo: could probably add some way to flag custom paks to not be loaded on dedicated servers in rpak.json
		if (IsDedicatedServer() && (Tier0::CommandLine()->CheckParm("-nopakdedi") ||
									strncmp(&originalPath[0], "common", 6))) // dedicated only needs common and common_mp
		{
			if (bNeedToFreePakName)
				delete[] pPath;

			spdlog::info("Not loading pak {} for dedicated server", originalPath);
			return -1;
		}
	}

	int iPakHandle = LoadPakAsync(pPath, unknownSingleton, flags, pCallback0, pCallback1);
	spdlog::info("LoadPakAsync {} {}", pPath, iPakHandle);

	// trak the pak
	g_pPakLoadManager->TrackLoadedPak(ePakLoadSource::UNTRACKED, iPakHandle, nPathHash);
	LoadPostloadPaks(pPath);

	if (bNeedToFreePakName)
		delete[] pPath;

	return iPakHandle;
}

// clang-format off
HOOK(UnloadPakHook, UnloadPak,
void*, __fastcall, (int nPakHandle, void* pCallback))
// clang-format on
{
	// stop tracking the pak
	g_pPakLoadManager->RemoveLoadedPak(nPakHandle);

	static bool bShouldUnloadPaks = true;
	if (bShouldUnloadPaks)
	{
		bShouldUnloadPaks = false;
		g_pPakLoadManager->UnloadMapPaks();
		bShouldUnloadPaks = true;
	}

	spdlog::info("UnloadPak {}", nPakHandle);
	return UnloadPak(nPakHandle, pCallback);
}

// we hook this exclusively for resolving stbsp paths, but seemingly it's also used for other stuff like vpk, rpak, mprj and starpak loads
// tbh this actually might be for memory mapped files or something, would make sense i think
// clang-format off
HOOK(ReadFileAsyncHook, ReadFileAsync, 
void*, __fastcall, (const char* pPath, void* pCallback))
// clang-format on
{
	fs::path path(pPath);
	std::string newPath = "";
	fs::path filename = path.filename();

	if (path.extension() == ".stbsp")
	{
		spdlog::info("LoadStreamBsp: {}", filename.string());

		// resolve modded stbsp path so we can load mod stbsps
		auto modFile = g_pModManager->m_ModFiles.find(g_pModManager->NormaliseModFilePath(fs::path("maps" / filename)));
		if (modFile != g_pModManager->m_ModFiles.end())
		{
			newPath = (modFile->second.m_pOwningMod->m_ModDirectory / "mod" / modFile->second.m_Path).string();
			pPath = newPath.c_str();
		}
	}
	else if (path.extension() == ".starpak")
	{
		// code for this is mostly stolen from above

		// unfortunately I can't find a way to get the rpak that is causing this function call, so I have to
		// store them on mod init and then compare the current path with the stored paths

		// game adds r2\ to every path, so assume that a starpak path that begins with r2\paks\ is a vanilla one
		// modded starpaks will be in the mod's paks folder (but can be in folders within the paks folder)

		// this might look a bit confusing, but its just an iterator over the various directories in a path.
		// path.begin() being the first directory, r2 in this case, which is guaranteed anyway,
		// so increment the iterator with ++ to get the first actual directory, * just gets the actual value
		// then we compare to "paks" to determine if it's a vanilla rpak or not
		if (*++path.begin() != "paks")
		{
			// remove the r2\ from the start used for path lookups
			std::string starpakPath = path.string().substr(3);
			// hash the starpakPath to compare with stored entries
			size_t hashed = STR_HASH(starpakPath);

			// loop through all loaded mods
			for (Mod& mod : g_pModManager->m_LoadedMods)
			{
				// ignore non-loaded mods
				if (!mod.m_bEnabled)
					continue;

				// loop through the stored starpak paths
				for (size_t hash : mod.StarpakPaths)
				{
					if (hash == hashed)
					{
						// construct new path
						newPath = (mod.m_ModDirectory / "paks" / starpakPath).string();
						// set path to the new path
						pPath = newPath.c_str();
						goto LOG_STARPAK;
					}
				}
			}
		}

	LOG_STARPAK:
		spdlog::info("LoadStreamPak: {}", filename.string());
	}

	return ReadFileAsync(pPath, pCallback);
}

ON_DLL_LOAD("engine.dll", RpakFilesystem, (CModule module))
{
	AUTOHOOK_DISPATCH();

	g_pPakLoadManager = new PakLoadManager;

	g_pakLoadApi = module.Offset(0x5BED78).Deref().As<PakLoadFuncs*>();
	pUnknownPakLoadSingleton = module.Offset(0x7C5E20).As<void**>();

	LoadPakAsyncHook.Dispatch(g_pakLoadApi->LoadPakAsync);
	UnloadPakHook.Dispatch(g_pakLoadApi->UnloadPak);
	ReadFileAsyncHook.Dispatch(g_pakLoadApi->ReadFileAsync);
}
