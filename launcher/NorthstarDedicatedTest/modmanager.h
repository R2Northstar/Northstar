#pragma once
#include "convar.h"
#include <string>
#include <vector>
#include <filesystem>
#include "rapidjson/document.h"
#include "memalloc.h"

namespace fs = std::filesystem;

const std::string MOD_FOLDER_SUFFIX = "/mods";
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

struct ModScriptCallback
{
  public:
	// would've liked to make it possible to hook arbitrary codecallbacks, but couldn't find a function that calls some ui ones
	// std::string HookedCodeCallback;

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
	std::string RsonRunOn;

	std::vector<ModScriptCallback> Callbacks;
};

class Mod
{
  public:
	// runtime stuff
	fs::path ModDirectory;
	bool Enabled = true;

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
	// custom localisation files created by the mod
	std::vector<std::string> LocalisationFiles;

	// other files:

	std::vector<std::string> Vpks;
	std::unordered_map<size_t, std::string> KeyValues;
	std::string Pdiff; // only need one per mod

	// other stuff

	bool wasReadSuccessfully = false;

  public:
	Mod(fs::path modPath, char* jsonBuf);
};

struct ModOverrideFile
{
  public:
	Mod* owningMod;
	fs::path path;
};

class ModManager
{
  private:
	bool m_hasLoadedMods = false;
	bool m_hasEnabledModsCfg;
	rapidjson_document m_enabledModsCfg;

	// precalculated hashes
	size_t m_hScriptsRsonHash;
	size_t m_hPdefHash;

  public:
	std::vector<Mod> m_loadedMods;
	std::unordered_map<std::string, ModOverrideFile> m_modFiles;

  public:
	ModManager();
	void LoadMods();
	void UnloadMods();
	void CompileAssetsForFile(const char* filename);

	// compile asset type stuff, these are done in files under Mods/Compiled/
	void BuildScriptsRson();
	void TryBuildKeyValues(const char* filename);
	void BuildPdef();
};

void InitialiseModManager(HMODULE baseAddress);
fs::path GetModFolderPath();
fs::path GetCompiledAssetsPath();

extern ModManager* g_ModManager;