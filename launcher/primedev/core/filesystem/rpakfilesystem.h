#pragma once

#include <regex>
#include "rtech/pakfile.h"

struct ModPak_t
{
	std::string m_modName;

	std::string m_path;
	size_t m_pathHash = 0;

	// If the map being loaded matches this regex, this pak will be loaded.
	std::regex m_mapRegex;
	// If a pak with a hash matching this is loaded, this pak will be loaded.
	size_t m_dependentPakHash = 0;
	// If this is set, this pak will be loaded whenever any other pak is loaded.
	bool m_preload = false;

	// If this is set, the Pak will be unloaded on next map load
	bool m_markedForDelete = false;
	// The current rpak handle associated with this Pak
	PakHandle m_handle = PakHandle::INVALID;
};

class PakLoadManager
{
public:
	void UnloadAllModPaks();
	void TrackModPaks(Mod& mod);

	void CleanUpUnloadedPaks();
	void UnloadMarkedPaks();

	void LoadModPaksForMap(const char* mapName);
	void UnloadModPaks();

	// Whether the current context is a vanilla call to a function, or a modded one
	bool IsVanillaCall() const { return m_reentranceCounter == 0; }
	// Whether paks will be forced to reload on the next map load
	bool GetForceReloadOnMapLoad() const { return m_forceReloadOnMapLoad; }
	void SetForceReloadOnMapLoad(bool value) { m_forceReloadOnMapLoad = value; }

	void OnPakLoaded(std::string& originalPath, std::string& resultingPath, PakHandle resultingHandle);
	void OnPakUnloading(PakHandle handle);

	void FixupPakPath(std::string& path);

	void LoadPreloadPaks();
	void ReloadPostloadPaks();

	void* OpenFile(const char* path);

private:
	void LoadDependentPaks(std::string& path, PakHandle handle);
	void UnloadDependentPaks(PakHandle handle);

	// All paks that vanilla has attempted to load. (they may have been aliased away)
	// Also known as a list of rpaks that the vanilla game would have loaded at this point in time.
	std::vector<std::pair<std::string, PakHandle>> m_vanillaPaks;

	// All mod Paks that are currently tracked
	std::vector<ModPak_t> m_modPaks;
	// Hashes of the currently loaded map mod paks
	std::vector<size_t> m_mapPaks;
	// Currently loaded Pak path hashes that depend on a handle to remain loaded (Postload)
	std::vector<std::pair<PakHandle, size_t>> m_dependentPaks;

	// Used to force rpaks to be unloaded and reloaded on the next map load.
	// Vanilla behaviour is to not do this when loading into mp_lobby, or loading into the same map you were last in.
	bool m_forceReloadOnMapLoad = false;
	// Used to track if the current hook call is a vanilla call or not.
	// When loading/unloading a mod Pak, increment this before doing so, and decrement afterwards.
	int m_reentranceCounter = 0;
};

extern PakLoadManager* g_pPakLoadManager;
