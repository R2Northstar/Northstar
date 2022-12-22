#pragma once
#include "core/convar/convar.h"
#include "core/memalloc.h"
#include "squirrel/squirrel.h"

#include "rapidjson/document.h"
#include <string>
#include <vector>
#include <filesystem>

const std::string MOD_FOLDER_SUFFIX = "/mods";
const std::string REMOTE_MOD_FOLDER_SUFFIX = "/runtime/remote/mods";
const fs::path MOD_OVERRIDE_DIR = "mod";
const std::string COMPILED_ASSETS_SUFFIX = "/runtime/compiled";

struct ModConVar
{
  public:
	std::string Name;
	std::string DefaultValue;
	std::string HelpString;
	int Flags;
};

struct ModConCommand
{
  public:
	std::string Name;
	std::string Function;
	std::string HelpString;
	ScriptContext Context;
	int Flags;
};

struct ModScriptCallback
{
  public:
	ScriptContext Context;

	// called before the codecallback is executed
	std::string BeforeCallback;
	// called after the codecallback has finished executing
	std::string AfterCallback;
};

struct ModScript
{
  public:
	std::string Path;
	std::string RunOn;

	std::vector<ModScriptCallback> Callbacks;
};

// these are pretty much identical, could refactor to use the same stuff?
struct ModVPKEntry
{
  public:
	bool m_bAutoLoad;
	std::string m_sVpkPath;
};

struct ModRpakEntry
{
  public:
	bool m_bAutoLoad;
	std::string m_sPakName;
	std::string m_sLoadAfterPak;
};

class Mod
{
  public:
	// runtime stuff
	bool m_bEnabled = true;
	bool m_bWasReadSuccessfully = false;
	fs::path m_ModDirectory;
	// bool m_bIsRemote;

	// mod.json stuff:

	// the mod's name
	std::string Name;
	// the mod's description
	std::string Description;
	// the mod's version, should be in semver
	std::string Version;
	// a download link to the mod, for clients that try to join without the mod
	std::string DownloadLink;

	// whether clients need the mod to join servers running this mod
	bool RequiredOnClient;
	// the priority for this mod's files, mods with prio 0 are loaded first, then 1, then 2, etc
	int LoadPriority;

	// custom scripts used by the mod
	std::vector<ModScript> Scripts;
	// convars created by the mod
	std::vector<ModConVar*> ConVars;
	// concommands created by the mod
	std::vector<ModConCommand*> ConCommands;
	// custom localisation files created by the mod
	std::vector<std::string> LocalisationFiles;

	// other files:

	std::vector<ModVPKEntry> Vpks;
	std::unordered_map<size_t, std::string> KeyValues;
	std::vector<std::string> BinkVideos;
	std::string Pdiff; // only need one per mod

	std::vector<ModRpakEntry> Rpaks;
	std::unordered_map<std::string, std::string>
		RpakAliases; // paks we alias to other rpaks, e.g. to load sp_crashsite paks on the map mp_crashsite
	std::vector<size_t> StarpakPaths; // starpaks that this mod contains
	// there seems to be no nice way to get the rpak that is causing the load of a starpak?
	// hashed with STR_HASH

	std::unordered_map<std::string, std::string> DependencyConstants;

  public:
	Mod(fs::path modPath, char* jsonBuf);
};

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

	// precalculated hashes
	size_t m_hScriptsRsonHash;
	size_t m_hPdefHash;
	size_t m_hKBActHash;

  public:
	std::vector<Mod> m_LoadedMods;
	std::unordered_map<std::string, ModOverrideFile> m_ModFiles;
	std::unordered_map<std::string, std::string> m_DependencyConstants;

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
fs::path GetCompiledAssetsPath();

extern ModManager* g_pModManager;
