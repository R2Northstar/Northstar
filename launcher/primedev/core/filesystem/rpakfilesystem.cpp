#include "rpakfilesystem.h"
#include "mods/modmanager.h"
#include "dedicated/dedicated.h"
#include "core/tier0.h"
#include "util/utils.h"

#pragma pack(push, 1)
struct PakLoadFuncs
{
	void (*InitRpakSystem)();
	void (*AddAssetLoaderWithJobDetails)(/*assetTypeHeader*/ void*, uint32_t, int);
	void (*AddAssetLoader)(/*assetTypeHeader*/ void*);
	PakHandle (*LoadRpakFileAsync)(const char* pPath, void* allocator, int flags);
	void (*LoadRpakFile)(const char*, __int64(__fastcall*)(), __int64, void(__cdecl*)());
	__int64 qword28;
	void (*UnloadPak)(PakHandle iPakHandle, void* callback);
	__int64 qword38;
	__int64 qword40;
	__int64 qword48;
	__int64 qword50;
	FARPROC (*GetDllCallback)(__int16 a1, const CHAR* a2);
	__int64 (*GetAssetByHash)(__int64 hash);
	__int64 (*GetAssetByName)(const char* a1);
	__int64 qword70;
	__int64 qword78;
	__int64 qword80;
	__int64 qword88;
	__int64 qword90;
	__int64 qword98;
	__int64 qwordA0;
	__int64 qwordA8;
	__int64 qwordB0;
	__int64 qwordBB;
	void* (*OpenFile)(const char* pPath);
	__int64 CloseFile;
	__int64 qwordD0;
	__int64 FileReadAsync;
	__int64 ComplexFileReadAsync;
	__int64 GetReadJobState;
	__int64 WaitForFileReadJobComplete;
	__int64 CancelFileReadJob;
	__int64 CancelFileReadJobAsync;
	__int64 qword108;
};
static_assert(sizeof(PakLoadFuncs) == 0x110);
#pragma pack(pop)

PakLoadFuncs* g_pakLoadApi;
PakLoadManager* g_pPakLoadManager;

static char* pszCurrentMapRpakPath = nullptr;
static PakHandle* piCurrentMapRpakHandle = nullptr;
static PakHandle* piCurrentMapPatchRpakHandle = nullptr;
static /*CModelLoader*/ void** ppModelLoader = nullptr;
static void** rpakMemoryAllocator = nullptr;

static __int64 (*o_pLoadGametypeSpecificRpaks)(const char* levelName) = nullptr;
static __int64 (**o_pCleanMaterialSystemStuff)() = nullptr;
static __int64 (**o_pCModelLoader_UnreferenceAllModels)(/*CModelLoader*/ void* a1) = nullptr;
static char* (*o_pLoadlevelLoadscreen)(const char* levelName) = nullptr;
static unsigned int (*o_pGetPakPatchNumber)(const char* pPakPath) = nullptr;

// Marks all mod Paks to be unloaded on next map load.
// Also cleans up any mod Paks that are already unloaded.
void PakLoadManager::UnloadAllModPaks()
{
	NS::log::rpak->info("Reloading RPaks on next map load...");
	for (auto& modPak : m_modPaks)
	{
		modPak.m_markedForDelete = true;
	}
	// clean up any paks that are both marked for unload and already unloaded
	CleanUpUnloadedPaks();
	SetForceReloadOnMapLoad(true);
}

// Tracks all Paks related to a mod.
void PakLoadManager::TrackModPaks(Mod& mod)
{
	const fs::path modPakPath("./" / mod.m_ModDirectory / "paks");

	for (auto& modRpakEntry : mod.Rpaks)
	{
		ModPak_t pak;
		pak.m_modName = mod.Name;
		pak.m_path = (modPakPath / modRpakEntry.m_pakName).string();
		pak.m_pathHash = STR_HASH(pak.m_path);

		pak.m_preload = modRpakEntry.m_preload;
		pak.m_dependentPakHash = modRpakEntry.m_dependentPakHash;
		pak.m_mapRegex = modRpakEntry.m_loadRegex;

		m_modPaks.push_back(pak);
	}
}

// Untracks all paks that aren't currently loaded and are marked for unload.
void PakLoadManager::CleanUpUnloadedPaks()
{
	auto fnRemovePredicate = [](ModPak_t& pak) -> bool { return pak.m_markedForDelete && pak.m_handle == PakHandle::INVALID; };

	m_modPaks.erase(std::remove_if(m_modPaks.begin(), m_modPaks.end(), fnRemovePredicate), m_modPaks.end());
}

// Unloads all paks that are marked for unload.
void PakLoadManager::UnloadMarkedPaks()
{
	++m_reentranceCounter;
	const ScopeGuard guard([&]() { --m_reentranceCounter; });

	(*o_pCModelLoader_UnreferenceAllModels)(*ppModelLoader);
	(*o_pCleanMaterialSystemStuff)();

	for (auto& modPak : m_modPaks)
	{
		if (modPak.m_handle == PakHandle::INVALID || !modPak.m_markedForDelete)
			continue;

		g_pakLoadApi->UnloadPak(modPak.m_handle, *o_pCleanMaterialSystemStuff);
		modPak.m_handle = PakHandle::INVALID;
	}
}

// Loads all modded paks for the given map.
void PakLoadManager::LoadModPaksForMap(const char* mapName)
{
	++m_reentranceCounter;
	const ScopeGuard guard([&]() { --m_reentranceCounter; });

	for (auto& modPak : m_modPaks)
	{
		// don't load paks that are already loaded
		if (modPak.m_handle != PakHandle::INVALID)
			continue;
		std::cmatch matches;
		if (!std::regex_match(mapName, matches, modPak.m_mapRegex))
			continue;

		modPak.m_handle = g_pakLoadApi->LoadRpakFileAsync(modPak.m_path.c_str(), *rpakMemoryAllocator, 7);
		m_mapPaks.push_back(modPak.m_pathHash);
	}
}

// Unloads all modded map paks.
void PakLoadManager::UnloadModPaks()
{
	++m_reentranceCounter;
	const ScopeGuard guard([&]() { --m_reentranceCounter; });

	(*o_pCModelLoader_UnreferenceAllModels)(*ppModelLoader);
	(*o_pCleanMaterialSystemStuff)();

	for (auto& modPak : m_modPaks)
	{
		for (auto it = m_mapPaks.begin(); it != m_mapPaks.end(); ++it)
		{
			if (*it != modPak.m_pathHash)
				continue;

			m_mapPaks.erase(it, it + 1);
			g_pakLoadApi->UnloadPak(modPak.m_handle, *o_pCleanMaterialSystemStuff);
			modPak.m_handle = PakHandle::INVALID;
			break;
		}
	}

	// If this has happened, we may have leaked a pak?
	// It basically means that none of the entries in m_modPaks matched the hash in m_mapPaks so we didn't end up unloading it
	assert_msg(m_mapPaks.size() == 0, "Not all map paks were unloaded?");
}

// Called after a Pak was loaded.
void PakLoadManager::OnPakLoaded(std::string& originalPath, std::string& resultingPath, PakHandle resultingHandle)
{
	if (IsVanillaCall())
	{
		// add entry to loaded vanilla rpaks
		m_vanillaPaks.emplace_back(originalPath, resultingHandle);
	}

	LoadDependentPaks(resultingPath, resultingHandle);
}

// Called before a Pak was unloaded.
void PakLoadManager::OnPakUnloading(PakHandle handle)
{
	UnloadDependentPaks(handle);

	if (IsVanillaCall())
	{
		// remove entry from loaded vanilla rpaks
		auto fnRemovePredicate = [handle](std::pair<std::string, PakHandle>& pair) -> bool { return pair.second == handle; };

		m_vanillaPaks.erase(std::remove_if(m_vanillaPaks.begin(), m_vanillaPaks.end(), fnRemovePredicate), m_vanillaPaks.end());

		// no need to handle aliasing here, if vanilla wants it gone, it's gone
	}
	else
	{
		// note: aliasing is handled the old way, long term todo: move it over to the PakLoadManager
		// handle the potential unloading of an aliased vanilla rpak (we aliased it, and we are now unloading the alias, so we should load
		// the vanilla one again)
		// for (auto& [path, resultingHandle] : m_vanillaPaks)
		//{
		//	if (resultingHandle != handle)
		//		continue;

		//	// load vanilla rpak
		//}
	}

	// set handle of the mod pak (if any) that has this handle for proper tracking
	for (auto& modPak : m_modPaks)
	{
		if (modPak.m_handle == handle)
			modPak.m_handle = PakHandle::INVALID;
	}
}

// Whether the vanilla game has this rpak
static bool VanillaHasPak(const char* pakName)
{
	fs::path originalPath = fs::path("./r2/paks/Win64") / pakName;
	unsigned int highestPatch = o_pGetPakPatchNumber(pakName);
	if (highestPatch)
	{
		// add the patch path to the extension
		char buf[16];
		snprintf(buf, sizeof(buf), "(%02u).rpak", highestPatch);
		// remove the .rpak and add the new suffix
		originalPath = originalPath.replace_extension().string() + buf;
	}
	else
	{
		originalPath /= pakName;
	}

	return fs::exists(originalPath);
}

// If vanilla doesn't have an rpak for this path, tries to map it to a modded rpak of the same name.
void PakLoadManager::FixupPakPath(std::string& pakPath)
{
	if (VanillaHasPak(pakPath.c_str()))
		return;

	for (ModPak_t& modPak : m_modPaks)
	{
		if (modPak.m_markedForDelete)
			continue;

		fs::path modPakFilename = fs::path(modPak.m_path).filename();
		if (pakPath == modPakFilename.string())
		{
			pakPath = modPak.m_path;
			return;
		}
	}
}

// Loads all "Preload" Paks. todo: deprecate Preload.
void PakLoadManager::LoadPreloadPaks()
{
	++m_reentranceCounter;
	const ScopeGuard guard([&]() { --m_reentranceCounter; });

	for (auto& modPak : m_modPaks)
	{
		if (modPak.m_markedForDelete || modPak.m_handle != PakHandle::INVALID || !modPak.m_preload)
			continue;

		modPak.m_handle = g_pakLoadApi->LoadRpakFileAsync(modPak.m_path.c_str(), *rpakMemoryAllocator, 7);
	}
}

// Causes all "Postload" paks to be loaded again.
void PakLoadManager::ReloadPostloadPaks()
{
	++m_reentranceCounter;
	const ScopeGuard guard([&]() { --m_reentranceCounter; });

	// pretend that we just loaded all of these vanilla paks
	for (auto& [path, handle] : m_vanillaPaks)
	{
		LoadDependentPaks(path, handle);
	}
}

// Wrapper for Pak load API.
void* PakLoadManager::OpenFile(const char* path)
{
	return g_pakLoadApi->OpenFile(path);
}

// Loads Paks that depend on this Pak.
void PakLoadManager::LoadDependentPaks(std::string& path, PakHandle handle)
{
	++m_reentranceCounter;
	const ScopeGuard guard([&]() { --m_reentranceCounter; });

	const size_t hash = STR_HASH(path);
	for (auto& modPak : m_modPaks)
	{
		if (modPak.m_handle != PakHandle::INVALID)
			continue;
		if (modPak.m_dependentPakHash != hash)
			continue;

		// load pak
		modPak.m_handle = g_pakLoadApi->LoadRpakFileAsync(modPak.m_path.c_str(), *rpakMemoryAllocator, 7);
		m_dependentPaks.emplace_back(handle, hash);
	}
}

// Unloads Paks that depend on this Pak.
void PakLoadManager::UnloadDependentPaks(PakHandle handle)
{
	++m_reentranceCounter;
	const ScopeGuard guard([&]() { --m_reentranceCounter; });

	auto fnRemovePredicate = [&](std::pair<PakHandle, size_t>& pair) -> bool
	{
		if (pair.first != handle)
			return false;

		for (auto& modPak : m_modPaks)
		{
			if (modPak.m_pathHash != pair.second || modPak.m_handle == PakHandle::INVALID)
				continue;

			// unload pak
			g_pakLoadApi->UnloadPak(modPak.m_handle, *o_pCleanMaterialSystemStuff);
			modPak.m_handle = PakHandle::INVALID;
		}

		return true;
	};
	m_dependentPaks.erase(std::remove_if(m_dependentPaks.begin(), m_dependentPaks.end(), fnRemovePredicate), m_dependentPaks.end());
}

// Handles aliases for rpaks defined in rpak.json, effectively redirecting an rpak load to a different path.
static void HandlePakAliases(std::string& originalPath)
{
	// convert the pak being loaded to its aliased one, e.g. aliasing mp_hub_timeshift => sp_hub_timeshift
	for (int64_t i = g_pModManager->m_LoadedMods.size() - 1; i > -1; i--)
	{
		Mod* mod = &g_pModManager->m_LoadedMods[i];
		if (!mod->m_bEnabled)
			continue;

		if (mod->RpakAliases.find(originalPath) != mod->RpakAliases.end())
		{
			originalPath = mod->RpakAliases[originalPath];
			return;
		}
	}
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

static bool (*o_pLoadMapRpaks)(char* mapPath) = nullptr;
static bool h_LoadMapRpaks(char* mapPath)
{
	// unload all mod rpaks that are marked for unload
	g_pPakLoadManager->UnloadMarkedPaks();
	g_pPakLoadManager->CleanUpUnloadedPaks();

	// strip file extension
	const std::string mapName = fs::path(mapPath).replace_extension().string();

	// load mp_common, sp_common etc.
	o_pLoadGametypeSpecificRpaks(mapName.c_str());

	// unload old modded map paks
	g_pPakLoadManager->UnloadModPaks();
	// load modded map paks
	g_pPakLoadManager->LoadModPaksForMap(mapName.c_str());

	// don't load/unload anything when going to the lobby, presumably to save load times when going back to the same map
	if (!g_pPakLoadManager->GetForceReloadOnMapLoad() && !strcmp("mp_lobby", mapName.c_str()))
		return false;

	if (g_pPakLoadManager->GetForceReloadOnMapLoad())
	{
		g_pPakLoadManager->LoadPreloadPaks();
		g_pPakLoadManager->ReloadPostloadPaks();
	}

	char mapRpakStr[272];
	snprintf(mapRpakStr, 272, "%s.rpak", mapName.c_str());

	// if level being loaded is the same as current level, do nothing
	if (!g_pPakLoadManager->GetForceReloadOnMapLoad() && !strcmp(mapRpakStr, pszCurrentMapRpakPath))
		return true;

	strcpy(pszCurrentMapRpakPath, mapRpakStr);

	(*o_pCleanMaterialSystemStuff)();
	o_pLoadlevelLoadscreen(mapName.c_str());

	// unload old map rpaks
	PakHandle curHandle = *piCurrentMapRpakHandle;
	PakHandle curPatchHandle = *piCurrentMapPatchRpakHandle;
	if (curHandle != PakHandle::INVALID)
	{
		(*o_pCModelLoader_UnreferenceAllModels)(*ppModelLoader);
		(*o_pCleanMaterialSystemStuff)();
		g_pakLoadApi->UnloadPak(curHandle, *o_pCleanMaterialSystemStuff);
		*piCurrentMapRpakHandle = PakHandle::INVALID;
	}
	if (curPatchHandle != PakHandle::INVALID)
	{
		(*o_pCModelLoader_UnreferenceAllModels)(*ppModelLoader);
		(*o_pCleanMaterialSystemStuff)();
		g_pakLoadApi->UnloadPak(curPatchHandle, *o_pCleanMaterialSystemStuff);
		*piCurrentMapPatchRpakHandle = PakHandle::INVALID;
	}

	*piCurrentMapRpakHandle = g_pakLoadApi->LoadRpakFileAsync(mapRpakStr, *rpakMemoryAllocator, 7);

	// load special _patch rpak (seemingly used for dev things?)
	char levelPatchRpakStr[272];
	snprintf(levelPatchRpakStr, 272, "%s_patch.rpak", mapName.c_str());
	*piCurrentMapPatchRpakHandle = g_pakLoadApi->LoadRpakFileAsync(levelPatchRpakStr, *rpakMemoryAllocator, 7);

	// we just reloaded the paks, so we don't need to force it again
	g_pPakLoadManager->SetForceReloadOnMapLoad(false);
	return true;
}

// clang-format off
HOOK(LoadPakAsyncHook, LoadPakAsync,
PakHandle, __fastcall, (const char* pPath, void* memoryAllocator, int flags))
// clang-format on
{
	// make a copy of the path for comparing to determine whether we should load this pak on dedi, before it could get overwritten
	std::string svOriginalPath(pPath);

	std::string resultingPath(pPath);
	HandlePakAliases(resultingPath);

	if (g_pPakLoadManager->IsVanillaCall())
	{
		g_pPakLoadManager->LoadPreloadPaks();
		g_pPakLoadManager->FixupPakPath(resultingPath);

		// do this after custom paks load and in bShouldLoadPaks so we only ever call this on the root pakload call
		// todo: could probably add some way to flag custom paks to not be loaded on dedicated servers in rpak.json

		// dedicated only needs common, common_mp, common_sp, and sp_<map> rpaks
		// sp_<map> rpaks contain tutorial ghost data
		// sucks to have to load the entire rpak for that but sp was never meant to be done on dedi
		if (IsDedicatedServer() &&
			(CommandLine()->CheckParm("-nopakdedi") || strncmp(&svOriginalPath[0], "common", 6) && strncmp(&svOriginalPath[0], "sp_", 3)))
		{
			NS::log::rpak->info("Not loading pak {} for dedicated server", svOriginalPath);
			return PakHandle::INVALID;
		}
	}

	PakHandle iPakHandle = LoadPakAsync(resultingPath.c_str(), memoryAllocator, flags);
	NS::log::rpak->info("LoadPakAsync {} {}", resultingPath, iPakHandle);

	g_pPakLoadManager->OnPakLoaded(svOriginalPath, resultingPath, iPakHandle);

	return iPakHandle;
}

// clang-format off
HOOK(UnloadPakHook, UnloadPak,
void*, __fastcall, (PakHandle nPakHandle, void* pCallback))
// clang-format on
{
	g_pPakLoadManager->OnPakUnloading(nPakHandle);

	NS::log::rpak->info("UnloadPak {}", nPakHandle);
	return UnloadPak(nPakHandle, pCallback);
}

// we hook this exclusively for resolving stbsp paths, but seemingly it's also used for other stuff like vpk, rpak, mprj and starpak loads
// tbh this actually might be for memory mapped files or something, would make sense i think
// clang-format off
HOOK(OpenFileHook, o_pOpenFile, 
void*, __fastcall, (const char* pPath, void* pCallback))
// clang-format on
{
	// NOTE [Fifty]: For some reason some users are getting pPath as null when
	//               loading a server, o_pOpenFile uses CreateFileA and checks
	//               its return value so this is completely safe
	if (pPath == NULL)
	{
		return o_pOpenFile(pPath, pCallback);
	}

	fs::path path(pPath);
	std::string newPath = "";
	fs::path filename = path.filename();

	if (path.extension() == ".stbsp")
	{
		if (IsDedicatedServer())
			return nullptr;

		NS::log::rpak->info("LoadStreamBsp: {}", filename.string());

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
		if (IsDedicatedServer())
			return nullptr;

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
		NS::log::rpak->info("LoadStreamPak: {}", filename.string());
	}

	return o_pOpenFile(pPath, pCallback);
}

ON_DLL_LOAD("engine.dll", RpakFilesystem, (CModule module))
{
	g_pPakLoadManager = new PakLoadManager;

	g_pakLoadApi = module.Offset(0x5BED78).Deref().RCast<PakLoadFuncs*>();

	LoadPakAsyncHook.Dispatch((LPVOID*)g_pakLoadApi->LoadRpakFileAsync);
	UnloadPakHook.Dispatch((LPVOID*)g_pakLoadApi->UnloadPak);
	OpenFileHook.Dispatch((LPVOID*)g_pakLoadApi->OpenFile);

	pszCurrentMapRpakPath = module.Offset(0x1315C3E0).RCast<decltype(pszCurrentMapRpakPath)>();
	piCurrentMapRpakHandle = module.Offset(0x7CB5A0).RCast<decltype(piCurrentMapRpakHandle)>();
	piCurrentMapPatchRpakHandle = module.Offset(0x7CB5A4).RCast<decltype(piCurrentMapPatchRpakHandle)>();
	ppModelLoader = module.Offset(0x7C4AC0).RCast<decltype(ppModelLoader)>();
	rpakMemoryAllocator = module.Offset(0x7C5E20).RCast<decltype(rpakMemoryAllocator)>();

	o_pLoadGametypeSpecificRpaks = module.Offset(0x15AD20).RCast<decltype(o_pLoadGametypeSpecificRpaks)>();
	o_pCleanMaterialSystemStuff = module.Offset(0x12A11F00).RCast<decltype(o_pCleanMaterialSystemStuff)>();
	o_pCModelLoader_UnreferenceAllModels = module.Offset(0x5ED580).RCast<decltype(o_pCModelLoader_UnreferenceAllModels)>();
	o_pLoadlevelLoadscreen = module.Offset(0x15A810).RCast<decltype(o_pLoadlevelLoadscreen)>();

	o_pLoadMapRpaks = module.Offset(0x15A8C0).RCast<decltype(o_pLoadMapRpaks)>();
	HookAttach(&(PVOID&)o_pLoadMapRpaks, (PVOID)h_LoadMapRpaks);

	// kinda bad, doing things in rtech in an engine callback but it seems fine for now
	CModule rtechModule(GetModuleHandleA("rtech_game.dll"));
	o_pGetPakPatchNumber = rtechModule.Offset(0x9A00).RCast<decltype(o_pGetPakPatchNumber)>();
}
