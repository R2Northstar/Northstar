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

const std::string MOD_FOLDER_SUFFIX = "\\mods";
const std::string THUNDERSTORE_MOD_FOLDER_SUFFIX = "\\packages";
const std::string REMOTE_MOD_FOLDER_SUFFIX = "\\runtime\\remote\\mods";
const fs::path MOD_OVERRIDE_DIR = "mod";
const std::string COMPILED_ASSETS_SUFFIX = "\\runtime\\compiled";

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
