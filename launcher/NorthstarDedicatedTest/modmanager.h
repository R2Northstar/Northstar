#pragma once
#include <string>
#include <vector>
#include <filesystem>

namespace fs = std::filesystem;

const fs::path MOD_FOLDER_PATH = "R2Northstar/mods";
const fs::path MOD_OVERRIDE_DIR = "mod";

const fs::path COMPILED_ASSETS_PATH = "R2Northstar/runtime/compiled";

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
	//std::string HookedCodeCallback;

	Context Context;

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

	std::vector<ModScriptCallback*> Callbacks;
};

class Mod
{
public:
	fs::path ModDirectory;

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
	bool RequiredOnClient = true;

	// custom scripts used by the mod
	std::vector<ModScript*> Scripts;
	// convars created by the mod
	std::vector<ModConVar*> ConVars;

	// other files:

	std::vector<std::string> Vpks;
	//std::vector<ModKeyValues*> KeyValues;

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
public:
	std::vector<Mod*> m_loadedMods;
	std::vector<ModOverrideFile*> m_modFiles;

public:
	ModManager();
	void LoadMods();
	void CompileAssetsForFile(const char* filename);

	// compile asset type stuff, these are done in files under Mods/Compiled/
	void BuildScriptsRson();
};

void InitialiseModManager(HMODULE baseAddress);

extern ModManager* g_ModManager;