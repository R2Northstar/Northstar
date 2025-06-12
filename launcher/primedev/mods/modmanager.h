#pragma once
#include "core/convar/convar.h"
#include "core/memalloc.h"
#include "squirrel/squirrel.h"

#include "rapidjson/document.h"
#include <string>
#include <vector>
#include <filesystem>
#include <unordered_set>
#include <regex>
#include "mod.h"

namespace fs = std::filesystem;

const fs::path MOD_FOLDER_SUFFIX = "mods";
const fs::path THUNDERSTORE_MOD_FOLDER_SUFFIX = "packages";
const fs::path REMOTE_MOD_FOLDER_SUFFIX = "runtime\\remote\\mods";
const fs::path MOD_OVERRIDE_DIR = "mod";
const fs::path COMPILED_ASSETS_SUFFIX = "runtime\\compiled";

const std::set<std::string> MODS_BLACKLIST = {"Mod Settings"};

struct ModOverrideFile
{
public:
	Mod* m_pOwningMod;
	fs::path m_Path;
};

class ModManager
{
private:
	bool m_bHasLoadedMods = false;
	bool m_bHasEnabledModsCfg;
	rapidjson_document m_EnabledModsCfg;
	std::string cfgPath;

	// precalculated hashes
	size_t m_hScriptsRsonHash;
	size_t m_hPdefHash;
	size_t m_hKBActHash;

public:
	std::vector<Mod> m_LoadedMods;
	std::unordered_map<std::string, ModOverrideFile> m_ModFiles;
	std::unordered_map<std::string, std::string> m_DependencyConstants;
	std::unordered_set<std::string> m_PluginDependencyConstants;

private:
	/**
	 * Discovers all mods from disk, and loads their initial state.
	 *
	 * This searches for mods in various ways and loads the mods configuration from
	 * disk, populating `m_LoadedMods`. Note that this does not clear `m_LoadedMods`
	 * before doing work.
	 *
	 * @returns nothing
	 **/
	void DiscoverMods();

	/**
	 * Saves mod enabled state to enabledmods.json file.
	 *
	 * This loops over loaded mods (stored in `m_LoadedMods` list), exports their
	 * state (enabled or disabled) to a local JSON document, then exports this
	 * document to local profile.
	 *
	 * @returns nothing
	 **/
	void ExportModsConfigurationToFile();

	/**
	 * Load information for all mods from filesystem.
	 *
	 * This looks for mods in several directories (expecting them to be formatted in
	 * some way); it then uses respective `mod.json` manifest files to create `Mod`
	 * instances, which are then stored in the `m_LoadedMods` variable.
	 *
	 * @returns nothing
	 **/
	void SearchFilesystemForMods();

	/**
	 * Prevents crashes caused by mods being installed several times.
	 *
	 * Whether through manual install or remote mod downloading, several versions of
	 * a same mod can be located in the current profile: enabling all of them would
	 * lead to a crash, due to some files loaded several times.
	 *
	 * This checks the local `m_LoadedMods` mods list for multiple versions of a
	 * same mod: if so, this disables all versions of the relevant mod.
	 *
	 * @returns nothing
	 **/
	void DisableMultipleModVersions();

	/**
	 * Builds the modinfo object for sending to the masterserver.
	 *
	 * @returns nothing
	 **/
	void BuildModInfo();

public:
	ModManager();
	void LoadMods();
	void UnloadMods();
	std::string NormaliseModFilePath(const fs::path path);
	void CompileAssetsForFile(const char* filename);

	// compile asset type stuff, these are done in files under runtime/compiled/
	void BuildScriptsRson();
	void TryBuildKeyValues(const char* filename);
	void BuildPdef();
	void BuildKBActionsList();
};

fs::path GetModFolderPath();
fs::path GetRemoteModFolderPath();
fs::path GetThunderstoreModFolderPath();
fs::path GetCompiledAssetsPath();

extern ModManager* g_pModManager;
