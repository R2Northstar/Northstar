#include "modmanager.h"
#include "core/convar/convar.h"
#include "core/convar/concommand.h"
#include "client/audio.h"
#include "masterserver/masterserver.h"
#include "core/filesystem/filesystem.h"
#include "core/filesystem/rpakfilesystem.h"
#include "config/profile.h"

#include "rapidjson/error/en.h"
#include "rapidjson/document.h"
#include "rapidjson/ostreamwrapper.h"
#include "rapidjson/prettywriter.h"
#include <filesystem>
#include <fstream>
#include <string>
#include <sstream>
#include <vector>
#include <regex>

ModManager* g_pModManager;

Mod::Mod(fs::path modDir, char* jsonBuf)
{
	m_bWasReadSuccessfully = false;

	m_ModDirectory = modDir;

	rapidjson_document modJson;
	modJson.Parse<rapidjson::ParseFlag::kParseCommentsFlag | rapidjson::ParseFlag::kParseTrailingCommasFlag>(jsonBuf);

	spdlog::info("Loading mod file at path '{}'", modDir.string());

	// fail if parse error
	if (modJson.HasParseError())
	{
		spdlog::error(
			"Failed reading mod file {}: encountered parse error \"{}\" at offset {}",
			(modDir / "mod.json").string(),
			GetParseError_En(modJson.GetParseError()),
			modJson.GetErrorOffset());
		return;
	}

	// fail if it's not a json obj (could be an array, string, etc)
	if (!modJson.IsObject())
	{
		spdlog::error("Failed reading mod file {}: file is not a JSON object", (modDir / "mod.json").string());
		return;
	}

	// basic mod info
	// name is required
	if (!modJson.HasMember("Name"))
	{
		spdlog::error("Failed reading mod file {}: missing required member \"Name\"", (modDir / "mod.json").string());
		return;
	}

	Name = modJson["Name"].GetString();
	spdlog::info("Loading mod '{}'", Name);

	// Don't load blacklisted mods
	if (!strstr(GetCommandLineA(), "-nomodblacklist") && MODS_BLACKLIST.find(Name) != std::end(MODS_BLACKLIST))
	{
		spdlog::warn("Skipping blacklisted mod \"{}\"!", Name);
		return;
	}

	if (modJson.HasMember("Description"))
		Description = modJson["Description"].GetString();
	else
		Description = "";

	if (modJson.HasMember("Version"))
		Version = modJson["Version"].GetString();
	else
	{
		Version = "0.0.0";
		spdlog::warn("Mod file {} is missing a version, consider adding a version", (modDir / "mod.json").string());
	}

	if (modJson.HasMember("DownloadLink"))
		DownloadLink = modJson["DownloadLink"].GetString();
	else
		DownloadLink = "";

	if (modJson.HasMember("RequiredOnClient"))
		RequiredOnClient = modJson["RequiredOnClient"].GetBool();
	else
		RequiredOnClient = false;

	if (modJson.HasMember("LoadPriority"))
		LoadPriority = modJson["LoadPriority"].GetInt();
	else
	{
		spdlog::info("Mod file {} is missing a LoadPriority, consider adding one", (modDir / "mod.json").string());
		LoadPriority = 0;
	}

	// Parse all array fields
	ParseConVars(modJson);
	ParseConCommands(modJson);
	ParseScripts(modJson);
	ParseLocalization(modJson);
	ParseDependencies(modJson);
	ParseInitScript(modJson);

	m_bWasReadSuccessfully = true;
}

void Mod::ParseConVars(rapidjson_document& json)
{
	if (!json.HasMember("ConVars"))
		return;

	if (!json["ConVars"].IsArray())
	{
		spdlog::warn("'ConVars' field is not an array, skipping...");
		return;
	}

	for (auto& convarObj : json["ConVars"].GetArray())
	{
		if (!convarObj.IsObject())
		{
			spdlog::warn("ConVar is not an object, skipping...");
			continue;
		}
		if (!convarObj.HasMember("Name"))
		{
			spdlog::warn("ConVar does not have a Name, skipping...");
			continue;
		}
		// from here on, the ConVar can be referenced by name in logs
		if (!convarObj.HasMember("DefaultValue"))
		{
			spdlog::warn("ConVar '{}' does not have a DefaultValue, skipping...", convarObj["Name"].GetString());
			continue;
		}

		// have to allocate this manually, otherwise convar registration will break
		// unfortunately this causes us to leak memory on reload, unsure of a way around this rn
		ModConVar* convar = new ModConVar;
		convar->Name = convarObj["Name"].GetString();
		convar->DefaultValue = convarObj["DefaultValue"].GetString();

		if (convarObj.HasMember("HelpString"))
			convar->HelpString = convarObj["HelpString"].GetString();
		else
			convar->HelpString = "";

		convar->Flags = FCVAR_NONE;

		if (convarObj.HasMember("Flags"))
		{
			// read raw integer flags
			if (convarObj["Flags"].IsInt())
				convar->Flags = convarObj["Flags"].GetInt();
			else if (convarObj["Flags"].IsString())
			{
				// parse cvar flags from string
				// example string: ARCHIVE_PLAYERPROFILE | GAMEDLL
				convar->Flags |= ParseConVarFlagsString(convar->Name, convarObj["Flags"].GetString());
			}
		}

		ConVars.push_back(convar);

		spdlog::info("'{}' contains ConVar '{}'", Name, convar->Name);
	}
}

void Mod::ParseConCommands(rapidjson_document& json)
{
	if (!json.HasMember("ConCommands"))
		return;

	if (!json["ConCommands"].IsArray())
	{
		spdlog::warn("'ConCommands' field is not an array, skipping...");
		return;
	}

	for (auto& concommandObj : json["ConCommands"].GetArray())
	{
		if (!concommandObj.IsObject())
		{
			spdlog::warn("ConCommand is not an object, skipping...");
			continue;
		}
		if (!concommandObj.HasMember("Name"))
		{
			spdlog::warn("ConCommand does not have a Name, skipping...");
			continue;
		}
		// from here on, the ConCommand can be referenced by name in logs
		if (!concommandObj.HasMember("Function"))
		{
			spdlog::warn("ConCommand '{}' does not have a Function, skipping...", concommandObj["Name"].GetString());
			continue;
		}
		if (!concommandObj.HasMember("Context"))
		{
			spdlog::warn("ConCommand '{}' does not have a Context, skipping...", concommandObj["Name"].GetString());
			continue;
		}

		// have to allocate this manually, otherwise concommand registration will break
		// unfortunately this causes us to leak memory on reload, unsure of a way around this rn
		ModConCommand* concommand = new ModConCommand;
		concommand->Name = concommandObj["Name"].GetString();
		concommand->Function = concommandObj["Function"].GetString();
		concommand->Context = ScriptContextFromString(concommandObj["Context"].GetString());
		if (concommand->Context == ScriptContext::INVALID)
		{
			spdlog::warn("ConCommand '{}' has invalid context '{}', skipping...", concommand->Name, concommandObj["Context"].GetString());
			continue;
		}

		if (concommandObj.HasMember("HelpString"))
			concommand->HelpString = concommandObj["HelpString"].GetString();
		else
			concommand->HelpString = "";

		concommand->Flags = FCVAR_NONE;

		if (concommandObj.HasMember("Flags"))
		{
			// read raw integer flags
			if (concommandObj["Flags"].IsInt())
			{
				concommand->Flags = concommandObj["Flags"].GetInt();
			}
			else if (concommandObj["Flags"].IsString())
			{
				// parse cvar flags from string
				// example string: ARCHIVE_PLAYERPROFILE | GAMEDLL
				concommand->Flags |= ParseConVarFlagsString(concommand->Name, concommandObj["Flags"].GetString());
			}
		}

		ConCommands.push_back(concommand);

		spdlog::info("'{}' contains ConCommand '{}'", Name, concommand->Name);
	}
}

void Mod::ParseScripts(rapidjson_document& json)
{
	if (!json.HasMember("Scripts"))
		return;

	if (!json["Scripts"].IsArray())
	{
		spdlog::warn("'Scripts' field is not an array, skipping...");
		return;
	}

	for (auto& scriptObj : json["Scripts"].GetArray())
	{
		if (!scriptObj.IsObject())
		{
			spdlog::warn("Script is not an object, skipping...");
			continue;
		}
		if (!scriptObj.HasMember("Path"))
		{
			spdlog::warn("Script does not have a Path, skipping...");
			continue;
		}
		// from here on, the Path for a script is used as it's name in logs
		if (!scriptObj.HasMember("RunOn"))
		{
			// "a RunOn" sounds dumb but anything else doesn't match the format of the warnings...
			// this is the best i could think of within 20 seconds
			spdlog::warn("Script '{}' does not have a RunOn field, skipping...", scriptObj["Path"].GetString());
			continue;
		}

		ModScript script;

		script.Path = scriptObj["Path"].GetString();
		script.RunOn = scriptObj["RunOn"].GetString();

		if (scriptObj.HasMember("ServerCallback"))
		{
			if (scriptObj["ServerCallback"].IsObject())
			{
				ModScriptCallback callback;
				callback.Context = ScriptContext::SERVER;

				if (scriptObj["ServerCallback"].HasMember("Before"))
				{
					if (scriptObj["ServerCallback"]["Before"].IsString())
						callback.BeforeCallback = scriptObj["ServerCallback"]["Before"].GetString();
					else
						spdlog::warn("'Before' ServerCallback for script '{}' is not a string, skipping...", scriptObj["Path"].GetString());
				}

				if (scriptObj["ServerCallback"].HasMember("After"))
				{
					if (scriptObj["ServerCallback"]["After"].IsString())
						callback.AfterCallback = scriptObj["ServerCallback"]["After"].GetString();
					else
						spdlog::warn("'After' ServerCallback for script '{}' is not a string, skipping...", scriptObj["Path"].GetString());
				}

				if (scriptObj["ServerCallback"].HasMember("Destroy"))
				{
					if (scriptObj["ServerCallback"]["Destroy"].IsString())
						callback.DestroyCallback = scriptObj["ServerCallback"]["Destroy"].GetString();
					else
						spdlog::warn(
							"'Destroy' ServerCallback for script '{}' is not a string, skipping...", scriptObj["Path"].GetString());
				}

				script.Callbacks.push_back(callback);
			}
			else
			{
				spdlog::warn("ServerCallback for script '{}' is not an object, skipping...", scriptObj["Path"].GetString());
			}
		}

		if (scriptObj.HasMember("ClientCallback"))
		{
			if (scriptObj["ClientCallback"].IsObject())
			{
				ModScriptCallback callback;
				callback.Context = ScriptContext::CLIENT;

				if (scriptObj["ClientCallback"].HasMember("Before"))
				{
					if (scriptObj["ClientCallback"]["Before"].IsString())
						callback.BeforeCallback = scriptObj["ClientCallback"]["Before"].GetString();
					else
						spdlog::warn("'Before' ClientCallback for script '{}' is not a string, skipping...", scriptObj["Path"].GetString());
				}

				if (scriptObj["ClientCallback"].HasMember("After"))
				{
					if (scriptObj["ClientCallback"]["After"].IsString())
						callback.AfterCallback = scriptObj["ClientCallback"]["After"].GetString();
					else
						spdlog::warn("'After' ClientCallback for script '{}' is not a string, skipping...", scriptObj["Path"].GetString());
				}

				if (scriptObj["ClientCallback"].HasMember("Destroy"))
				{
					if (scriptObj["ClientCallback"]["Destroy"].IsString())
						callback.DestroyCallback = scriptObj["ClientCallback"]["Destroy"].GetString();
					else
						spdlog::warn(
							"'Destroy' ClientCallback for script '{}' is not a string, skipping...", scriptObj["Path"].GetString());
				}

				script.Callbacks.push_back(callback);
			}
			else
			{
				spdlog::warn("ClientCallback for script '{}' is not an object, skipping...", scriptObj["Path"].GetString());
			}
		}

		if (scriptObj.HasMember("UICallback"))
		{
			if (scriptObj["UICallback"].IsObject())
			{
				ModScriptCallback callback;
				callback.Context = ScriptContext::UI;

				if (scriptObj["UICallback"].HasMember("Before"))
				{
					if (scriptObj["UICallback"]["Before"].IsString())
						callback.BeforeCallback = scriptObj["UICallback"]["Before"].GetString();
					else
						spdlog::warn("'Before' UICallback for script '{}' is not a string, skipping...", scriptObj["Path"].GetString());
				}

				if (scriptObj["UICallback"].HasMember("After"))
				{
					if (scriptObj["UICallback"]["After"].IsString())
						callback.AfterCallback = scriptObj["UICallback"]["After"].GetString();
					else
						spdlog::warn("'After' UICallback for script '{}' is not a string, skipping...", scriptObj["Path"].GetString());
				}

				if (scriptObj["UICallback"].HasMember("Destroy"))
				{
					if (scriptObj["UICallback"]["Destroy"].IsString())
						callback.DestroyCallback = scriptObj["UICallback"]["Destroy"].GetString();
					else
						spdlog::warn("'Destroy' UICallback for script '{}' is not a string, skipping...", scriptObj["Path"].GetString());
				}

				script.Callbacks.push_back(callback);
			}
			else
			{
				spdlog::warn("UICallback for script '{}' is not an object, skipping...", scriptObj["Path"].GetString());
			}
		}

		Scripts.push_back(script);

		spdlog::info("'{}' contains Script '{}'", Name, script.Path);
	}
}

void Mod::ParseLocalization(rapidjson_document& json)
{
	if (!json.HasMember("Localisation"))
		return;

	if (!json["Localisation"].IsArray())
	{
		spdlog::warn("'Localisation' field is not an array, skipping...");
		return;
	}

	for (auto& localisationStr : json["Localisation"].GetArray())
	{
		if (!localisationStr.IsString())
		{
			// not a string but we still GetString() to log it :trol:
			spdlog::warn("Localisation '{}' is not a string, skipping...", localisationStr.GetString());
			continue;
		}

		LocalisationFiles.push_back(localisationStr.GetString());

		spdlog::info("'{}' registered Localisation '{}'", Name, localisationStr.GetString());
	}
}

void Mod::ParseDependencies(rapidjson_document& json)
{
	if (!json.HasMember("Dependencies"))
		return;

	if (!json["Dependencies"].IsObject())
	{
		spdlog::warn("'Dependencies' field is not an object, skipping...");
		return;
	}

	for (auto v = json["Dependencies"].MemberBegin(); v != json["Dependencies"].MemberEnd(); v++)
	{
		if (!v->name.IsString())
		{
			spdlog::warn("Dependency constant '{}' is not a string, skipping...", v->name.GetString());
			continue;
		}
		if (!v->value.IsString())
		{
			spdlog::warn("Dependency constant '{}' is not a string, skipping...", v->value.GetString());
			continue;
		}

		if (DependencyConstants.find(v->name.GetString()) != DependencyConstants.end() &&
			v->value.GetString() != DependencyConstants[v->name.GetString()])
		{
			// this is fatal because otherwise the mod will probably try to use functions that dont exist,
			// which will cause errors further down the line that are harder to debug
			spdlog::error(
				"'{}' attempted to register a dependency constant '{}' for '{}' that already exists for '{}'. "
				"Change the constant name.",
				Name,
				v->name.GetString(),
				v->value.GetString(),
				DependencyConstants[v->name.GetString()]);
			return;
		}

		if (DependencyConstants.find(v->name.GetString()) == DependencyConstants.end())
			DependencyConstants.emplace(v->name.GetString(), v->value.GetString());

		spdlog::info("'{}' registered dependency constant '{}' for mod '{}'", Name, v->name.GetString(), v->value.GetString());
	}
}

void Mod::ParseInitScript(rapidjson_document& json)
{
	if (!json.HasMember("InitScript"))
		return;

	if (!json["InitScript"].IsString())
	{
		spdlog::warn("'InitScript' field is not a string, skipping...");
		return;
	}

	initScript = json["InitScript"].GetString();
}

ModManager::ModManager()
{
	// precaculated string hashes
	// note: use backslashes for these, since we use lexically_normal for file paths which uses them
	m_hScriptsRsonHash = STR_HASH("scripts\\vscripts\\scripts.rson");
	m_hPdefHash = STR_HASH(
		"cfg\\server\\persistent_player_data_version_231.pdef" // this can have multiple versions, but we use 231 so that's what we hash
	);
	m_hKBActHash = STR_HASH("scripts\\kb_act.lst");

	LoadMods();
}

struct Test
{
	std::string funcName;
	ScriptContext context;
};

template <ScriptContext context> auto ModConCommandCallback_Internal(std::string name, const CCommand& command)
{
	if (g_pSquirrel<context>->m_pSQVM && g_pSquirrel<context>->m_pSQVM)
	{
		if (command.ArgC() == 1)
		{
			g_pSquirrel<context>->AsyncCall(name);
		}
		else
		{
			std::vector<std::string> args;
			args.reserve(command.ArgC());
			for (int i = 1; i < command.ArgC(); i++)
				args.push_back(command.Arg(i));
			g_pSquirrel<context>->AsyncCall(name, args);
		}
	}
	else
	{
		spdlog::warn("ConCommand `{}` was called while the associated Squirrel VM `{}` was unloaded", name, GetContextName(context));
	}
}

auto ModConCommandCallback(const CCommand& command)
{
	ModConCommand* found = nullptr;
	auto commandString = std::string(command.GetCommandString());

	// Finding the first space to remove the command's name
	auto firstSpace = commandString.find(' ');
	if (firstSpace)
	{
		commandString = commandString.substr(0, firstSpace);
	}

	// Find the mod this command belongs to
	for (auto& mod : g_pModManager->m_LoadedMods)
	{
		auto res = std::find_if(
			mod.ConCommands.begin(),
			mod.ConCommands.end(),
			[&commandString](const ModConCommand* other) { return other->Name == commandString; });
		if (res != mod.ConCommands.end())
		{
			found = *res;
			break;
		}
	}
	if (!found)
		return;

	switch (found->Context)
	{
	case ScriptContext::CLIENT:
		ModConCommandCallback_Internal<ScriptContext::CLIENT>(found->Function, command);
		break;
	case ScriptContext::SERVER:
		ModConCommandCallback_Internal<ScriptContext::SERVER>(found->Function, command);
		break;
	case ScriptContext::UI:
		ModConCommandCallback_Internal<ScriptContext::UI>(found->Function, command);
		break;
	};
}

void ModManager::LoadMods()
{
	if (m_bHasLoadedMods)
		UnloadMods();

	std::vector<fs::path> modDirs;

	// ensure dirs exist
	fs::remove_all(GetCompiledAssetsPath());
	fs::create_directories(GetModFolderPath());
	fs::create_directories(GetThunderstoreModFolderPath());
	fs::create_directories(GetRemoteModFolderPath());

	m_DependencyConstants.clear();

	// read enabled mods cfg
	std::ifstream enabledModsStream(GetNorthstarPrefix() + "/enabledmods.json");
	std::stringstream enabledModsStringStream;

	if (!enabledModsStream.fail())
	{
		while (enabledModsStream.peek() != EOF)
			enabledModsStringStream << (char)enabledModsStream.get();

		enabledModsStream.close();
		m_EnabledModsCfg.Parse<rapidjson::ParseFlag::kParseCommentsFlag | rapidjson::ParseFlag::kParseTrailingCommasFlag>(
			enabledModsStringStream.str().c_str());

		m_bHasEnabledModsCfg = m_EnabledModsCfg.IsObject();
	}

	// get mod directories
	std::filesystem::directory_iterator classicModsDir = fs::directory_iterator(GetModFolderPath());
	std::filesystem::directory_iterator remoteModsDir = fs::directory_iterator(GetRemoteModFolderPath());
	std::filesystem::directory_iterator thunderstoreModsDir = fs::directory_iterator(GetThunderstoreModFolderPath());

	for (fs::directory_entry dir : classicModsDir)
		if (fs::exists(dir.path() / "mod.json"))
			modDirs.push_back(dir.path());

	// Special case for Thunderstore and remote mods directories
	// Set up regex for `AUTHOR-MOD-VERSION` pattern
	std::regex pattern(R"(.*\\([a-zA-Z0-9_]+)-([a-zA-Z0-9_]+)-(\d+\.\d+\.\d+))");

	for (fs::directory_iterator dirIterator : {thunderstoreModsDir, remoteModsDir})
	{
		for (fs::directory_entry dir : dirIterator)
		{
			fs::path modsDir = dir.path() / "mods"; // Check for mods folder in the Thunderstore mod
			// Use regex to match `AUTHOR-MOD-VERSION` pattern
			if (!std::regex_match(dir.path().string(), pattern))
			{
				spdlog::warn("The following directory did not match 'AUTHOR-MOD-VERSION': {}", dir.path().string());
				continue; // skip loading mod that doesn't match
			}
			if (fs::exists(modsDir) && fs::is_directory(modsDir))
			{
				for (fs::directory_entry subDir : fs::directory_iterator(modsDir))
				{
					if (fs::exists(subDir.path() / "mod.json"))
					{
						modDirs.push_back(subDir.path());
					}
				}
			}
		}
	}

	for (fs::path modDir : modDirs)
	{
		// read mod json file
		std::ifstream jsonStream(modDir / "mod.json");
		std::stringstream jsonStringStream;

		// fail if no mod json
		if (jsonStream.fail())
		{
			spdlog::warn(
				"Mod file at '{}' does not exist or could not be read, is it installed correctly?", (modDir / "mod.json").string());
			continue;
		}

		while (jsonStream.peek() != EOF)
			jsonStringStream << (char)jsonStream.get();

		jsonStream.close();

		Mod mod(modDir, (char*)jsonStringStream.str().c_str());

		for (auto& pair : mod.DependencyConstants)
		{
			if (m_DependencyConstants.find(pair.first) != m_DependencyConstants.end() && m_DependencyConstants[pair.first] != pair.second)
			{
				spdlog::error(
					"'{}' attempted to register a dependency constant '{}' for '{}' that already exists for '{}'. "
					"Change the constant name.",
					mod.Name,
					pair.first,
					pair.second,
					m_DependencyConstants[pair.first]);
				mod.m_bWasReadSuccessfully = false;
				break;
			}
			if (m_DependencyConstants.find(pair.first) == m_DependencyConstants.end())
				m_DependencyConstants.emplace(pair);
		}

		if (m_bHasEnabledModsCfg && m_EnabledModsCfg.HasMember(mod.Name.c_str()))
			mod.m_bEnabled = m_EnabledModsCfg[mod.Name.c_str()].IsTrue();
		else
			mod.m_bEnabled = true;

		if (mod.m_bWasReadSuccessfully)
		{
			if (mod.m_bEnabled)
				spdlog::info("'{}' loaded successfully", mod.Name);
			else
				spdlog::info("'{}' loaded successfully (DISABLED)", mod.Name);

			m_LoadedMods.push_back(mod);
		}
		else
			spdlog::warn("Mod file at '{}' failed to load", (modDir / "mod.json").string());
	}

	// sort by load prio, lowest-highest
	std::sort(m_LoadedMods.begin(), m_LoadedMods.end(), [](Mod& a, Mod& b) { return a.LoadPriority < b.LoadPriority; });

	for (Mod& mod : m_LoadedMods)
	{
		if (!mod.m_bEnabled)
			continue;

		// register convars
		// for reloads, this is sorta barebones, when we have a good findconvar method, we could probably reset flags and stuff on
		// preexisting convars note: we don't delete convars if they already exist because they're used for script stuff, unfortunately this
		// causes us to leak memory on reload, but not much, potentially find a way to not do this at some point
		for (ModConVar* convar : mod.ConVars)
		{
			// make sure convar isn't registered yet, unsure if necessary but idk what
			// behaviour is for defining same convar multiple times
			if (!R2::g_pCVar->FindVar(convar->Name.c_str()))
			{
				new ConVar(convar->Name.c_str(), convar->DefaultValue.c_str(), convar->Flags, convar->HelpString.c_str());
			}
		}

		for (ModConCommand* command : mod.ConCommands)
		{
			// make sure command isnt't registered multiple times.
			if (!R2::g_pCVar->FindCommand(command->Name.c_str()))
			{
				ConCommand* newCommand = new ConCommand();
				std::string funcName = command->Function;
				RegisterConCommand(command->Name.c_str(), ModConCommandCallback, command->HelpString.c_str(), command->Flags);
			}
		}

		// read vpk paths
		if (fs::exists(mod.m_ModDirectory / "vpk"))
		{
			// read vpk cfg
			std::ifstream vpkJsonStream(mod.m_ModDirectory / "vpk/vpk.json");
			std::stringstream vpkJsonStringStream;

			bool bUseVPKJson = false;
			rapidjson::Document dVpkJson;

			if (!vpkJsonStream.fail())
			{
				while (vpkJsonStream.peek() != EOF)
					vpkJsonStringStream << (char)vpkJsonStream.get();

				vpkJsonStream.close();
				dVpkJson.Parse<rapidjson::ParseFlag::kParseCommentsFlag | rapidjson::ParseFlag::kParseTrailingCommasFlag>(
					vpkJsonStringStream.str().c_str());

				bUseVPKJson = !dVpkJson.HasParseError() && dVpkJson.IsObject();
			}

			for (fs::directory_entry file : fs::directory_iterator(mod.m_ModDirectory / "vpk"))
			{
				// a bunch of checks to make sure we're only adding dir vpks and their paths are good
				// note: the game will literally only load vpks with the english prefix
				if (fs::is_regular_file(file) && file.path().extension() == ".vpk" &&
					file.path().string().find("english") != std::string::npos &&
					file.path().string().find(".bsp.pak000_dir") != std::string::npos)
				{
					std::string formattedPath = file.path().filename().string();

					// this really fucking sucks but it'll work
					std::string vpkName = formattedPath.substr(strlen("english"), formattedPath.find(".bsp") - 3);

					ModVPKEntry& modVpk = mod.Vpks.emplace_back();
					modVpk.m_bAutoLoad = !bUseVPKJson || (dVpkJson.HasMember("Preload") && dVpkJson["Preload"].IsObject() &&
														  dVpkJson["Preload"].HasMember(vpkName) && dVpkJson["Preload"][vpkName].IsTrue());
					modVpk.m_sVpkPath = (file.path().parent_path() / vpkName).string();

					if (m_bHasLoadedMods && modVpk.m_bAutoLoad)
						(*R2::g_pFilesystem)->m_vtable->MountVPK(*R2::g_pFilesystem, vpkName.c_str());
				}
			}
		}

		// read rpak paths
		if (fs::exists(mod.m_ModDirectory / "paks"))
		{
			// read rpak cfg
			std::ifstream rpakJsonStream(mod.m_ModDirectory / "paks/rpak.json");
			std::stringstream rpakJsonStringStream;

			bool bUseRpakJson = false;
			rapidjson::Document dRpakJson;

			if (!rpakJsonStream.fail())
			{
				while (rpakJsonStream.peek() != EOF)
					rpakJsonStringStream << (char)rpakJsonStream.get();

				rpakJsonStream.close();
				dRpakJson.Parse<rapidjson::ParseFlag::kParseCommentsFlag | rapidjson::ParseFlag::kParseTrailingCommasFlag>(
					rpakJsonStringStream.str().c_str());

				bUseRpakJson = !dRpakJson.HasParseError() && dRpakJson.IsObject();
			}

			// read pak aliases
			if (bUseRpakJson && dRpakJson.HasMember("Aliases") && dRpakJson["Aliases"].IsObject())
			{
				for (rapidjson::Value::ConstMemberIterator iterator = dRpakJson["Aliases"].MemberBegin();
					 iterator != dRpakJson["Aliases"].MemberEnd();
					 iterator++)
				{
					if (!iterator->name.IsString() || !iterator->value.IsString())
						continue;

					mod.RpakAliases.insert(std::make_pair(iterator->name.GetString(), iterator->value.GetString()));
				}
			}

			for (fs::directory_entry file : fs::directory_iterator(mod.m_ModDirectory / "paks"))
			{
				// ensure we're only loading rpaks
				if (fs::is_regular_file(file) && file.path().extension() == ".rpak")
				{
					std::string pakName(file.path().filename().string());

					ModRpakEntry& modPak = mod.Rpaks.emplace_back();
					modPak.m_bAutoLoad =
						!bUseRpakJson || (dRpakJson.HasMember("Preload") && dRpakJson["Preload"].IsObject() &&
										  dRpakJson["Preload"].HasMember(pakName) && dRpakJson["Preload"][pakName].IsTrue());

					// postload things
					if (!bUseRpakJson ||
						(dRpakJson.HasMember("Postload") && dRpakJson["Postload"].IsObject() && dRpakJson["Postload"].HasMember(pakName)))
						modPak.m_sLoadAfterPak = dRpakJson["Postload"][pakName].GetString();

					modPak.m_sPakName = pakName;

					// read header of file and get the starpak paths
					// this is done here as opposed to on starpak load because multiple rpaks can load a starpak
					// and there is seemingly no good way to tell which rpak is causing the load of a starpak :/

					std::ifstream rpakStream(file.path(), std::ios::binary);

					// seek to the point in the header where the starpak reference size is
					rpakStream.seekg(0x38, std::ios::beg);
					int starpaksSize = 0;
					rpakStream.read((char*)&starpaksSize, 2);

					// seek to just after the header
					rpakStream.seekg(0x58, std::ios::beg);
					// read the starpak reference(s)
					std::vector<char> buf(starpaksSize);
					rpakStream.read(buf.data(), starpaksSize);

					rpakStream.close();

					// split the starpak reference(s) into strings to hash
					std::string str = "";
					for (int i = 0; i < starpaksSize; i++)
					{
						// if the current char is null, that signals the end of the current starpak path
						if (buf[i] != 0x00)
						{
							str += buf[i];
						}
						else
						{
							// only add the string we are making if it isnt empty
							if (!str.empty())
							{
								mod.StarpakPaths.push_back(STR_HASH(str));
								spdlog::info("Mod {} registered starpak '{}'", mod.Name, str);
								str = "";
							}
						}
					}

					// not using atm because we need to resolve path to rpak
					// if (m_hasLoadedMods && modPak.m_bAutoLoad)
					//	g_pPakLoadManager->LoadPakAsync(pakName.c_str());
				}
			}
		}

		// read keyvalues paths
		if (fs::exists(mod.m_ModDirectory / "keyvalues"))
		{
			for (fs::directory_entry file : fs::recursive_directory_iterator(mod.m_ModDirectory / "keyvalues"))
			{
				if (fs::is_regular_file(file))
				{
					std::string kvStr =
						g_pModManager->NormaliseModFilePath(file.path().lexically_relative(mod.m_ModDirectory / "keyvalues"));
					mod.KeyValues.emplace(STR_HASH(kvStr), kvStr);
				}
			}
		}

		// read pdiff
		if (fs::exists(mod.m_ModDirectory / "mod.pdiff"))
		{
			std::ifstream pdiffStream(mod.m_ModDirectory / "mod.pdiff");

			if (!pdiffStream.fail())
			{
				std::stringstream pdiffStringStream;
				while (pdiffStream.peek() != EOF)
					pdiffStringStream << (char)pdiffStream.get();

				pdiffStream.close();

				mod.Pdiff = pdiffStringStream.str();
			}
		}

		// read bink video paths
		if (fs::exists(mod.m_ModDirectory / "media"))
		{
			for (fs::directory_entry file : fs::recursive_directory_iterator(mod.m_ModDirectory / "media"))
				if (fs::is_regular_file(file) && file.path().extension() == ".bik")
					mod.BinkVideos.push_back(file.path().filename().string());
		}

		// try to load audio
		if (fs::exists(mod.m_ModDirectory / "audio"))
		{
			for (fs::directory_entry file : fs::directory_iterator(mod.m_ModDirectory / "audio"))
			{
				if (fs::is_regular_file(file) && file.path().extension().string() == ".json")
				{
					if (!g_CustomAudioManager.TryLoadAudioOverride(file.path()))
					{
						spdlog::warn("Mod {} has an invalid audio def {}", mod.Name, file.path().filename().string());
						continue;
					}
				}
			}
		}
	}

	// in a seperate loop because we register mod files in reverse order, since mods loaded later should have their files prioritised
	for (int64_t i = m_LoadedMods.size() - 1; i > -1; i--)
	{
		if (!m_LoadedMods[i].m_bEnabled)
			continue;

		if (fs::exists(m_LoadedMods[i].m_ModDirectory / MOD_OVERRIDE_DIR))
		{
			for (fs::directory_entry file : fs::recursive_directory_iterator(m_LoadedMods[i].m_ModDirectory / MOD_OVERRIDE_DIR))
			{
				std::string path =
					g_pModManager->NormaliseModFilePath(file.path().lexically_relative(m_LoadedMods[i].m_ModDirectory / MOD_OVERRIDE_DIR));
				if (file.is_regular_file() && m_ModFiles.find(path) == m_ModFiles.end())
				{
					ModOverrideFile modFile;
					modFile.m_pOwningMod = &m_LoadedMods[i];
					modFile.m_Path = path;
					m_ModFiles.insert(std::make_pair(path, modFile));
				}
			}
		}
	}

	// build modinfo obj for masterserver
	rapidjson_document modinfoDoc;
	auto& alloc = modinfoDoc.GetAllocator();
	modinfoDoc.SetObject();
	modinfoDoc.AddMember("Mods", rapidjson::kArrayType, alloc);

	int currentModIndex = 0;
	for (Mod& mod : m_LoadedMods)
	{
		if (!mod.m_bEnabled || (!mod.RequiredOnClient && !mod.Pdiff.size()))
			continue;

		modinfoDoc["Mods"].PushBack(rapidjson::kObjectType, modinfoDoc.GetAllocator());
		modinfoDoc["Mods"][currentModIndex].AddMember("Name", rapidjson::StringRef(&mod.Name[0]), modinfoDoc.GetAllocator());
		modinfoDoc["Mods"][currentModIndex].AddMember("Version", rapidjson::StringRef(&mod.Version[0]), modinfoDoc.GetAllocator());
		modinfoDoc["Mods"][currentModIndex].AddMember("RequiredOnClient", mod.RequiredOnClient, modinfoDoc.GetAllocator());
		modinfoDoc["Mods"][currentModIndex].AddMember("Pdiff", rapidjson::StringRef(&mod.Pdiff[0]), modinfoDoc.GetAllocator());

		currentModIndex++;
	}

	rapidjson::StringBuffer buffer;
	buffer.Clear();
	rapidjson::Writer<rapidjson::StringBuffer> writer(buffer);
	modinfoDoc.Accept(writer);
	g_pMasterServerManager->m_sOwnModInfoJson = std::string(buffer.GetString());

	m_bHasLoadedMods = true;
}

void ModManager::UnloadMods()
{
	// clean up stuff from mods before we unload
	m_ModFiles.clear();
	fs::remove_all(GetCompiledAssetsPath());

	g_CustomAudioManager.ClearAudioOverrides();

	if (!m_bHasEnabledModsCfg)
		m_EnabledModsCfg.SetObject();

	for (Mod& mod : m_LoadedMods)
	{
		// remove all built kvs
		for (std::pair<size_t, std::string> kvPaths : mod.KeyValues)
			fs::remove(GetCompiledAssetsPath() / fs::path(kvPaths.second).lexically_relative(mod.m_ModDirectory));

		mod.KeyValues.clear();

		// write to m_enabledModsCfg
		// should we be doing this here or should scripts be doing this manually?
		// main issue with doing this here is when we reload mods for connecting to a server, we write enabled mods, which isn't necessarily
		// what we wanna do
		if (!m_EnabledModsCfg.HasMember(mod.Name.c_str()))
			m_EnabledModsCfg.AddMember(rapidjson_document::StringRefType(mod.Name.c_str()), false, m_EnabledModsCfg.GetAllocator());

		m_EnabledModsCfg[mod.Name.c_str()].SetBool(mod.m_bEnabled);
	}

	std::ofstream writeStream(GetNorthstarPrefix() + "/enabledmods.json");
	rapidjson::OStreamWrapper writeStreamWrapper(writeStream);
	rapidjson::PrettyWriter<rapidjson::OStreamWrapper> writer(writeStreamWrapper);
	m_EnabledModsCfg.Accept(writer);

	// do we need to dealloc individual entries in m_loadedMods? idk, rework
	m_LoadedMods.clear();
}

std::string ModManager::NormaliseModFilePath(const fs::path path)
{
	std::string str = path.lexically_normal().string();

	// force to lowercase
	for (char& c : str)
		if (c <= 'Z' && c >= 'A')
			c = c - ('Z' - 'z');

	return str;
}

void ModManager::CompileAssetsForFile(const char* filename)
{
	size_t fileHash = STR_HASH(NormaliseModFilePath(fs::path(filename)));

	if (fileHash == m_hScriptsRsonHash)
		BuildScriptsRson();
	else if (fileHash == m_hPdefHash)
		BuildPdef();
	else if (fileHash == m_hKBActHash)
		BuildKBActionsList();
	else
	{
		// check if we should build keyvalues, depending on whether any of our mods have patch kvs for this file
		for (Mod& mod : m_LoadedMods)
		{
			if (!mod.m_bEnabled)
				continue;

			if (mod.KeyValues.find(fileHash) != mod.KeyValues.end())
			{
				TryBuildKeyValues(filename);
				return;
			}
		}
	}
}

void ConCommand_reload_mods(const CCommand& args)
{
	g_pModManager->LoadMods();
}

fs::path GetModFolderPath()
{
	return fs::path(GetNorthstarPrefix() + MOD_FOLDER_SUFFIX);
}
fs::path GetThunderstoreModFolderPath()
{
	return fs::path(GetNorthstarPrefix() + THUNDERSTORE_MOD_FOLDER_SUFFIX);
}
fs::path GetRemoteModFolderPath()
{
	return fs::path(GetNorthstarPrefix() + REMOTE_MOD_FOLDER_SUFFIX);
}
fs::path GetCompiledAssetsPath()
{
	return fs::path(GetNorthstarPrefix() + COMPILED_ASSETS_SUFFIX);
}

ON_DLL_LOAD_RELIESON("engine.dll", ModManager, (ConCommand, MasterServer), (CModule module))
{
	g_pModManager = new ModManager;

	RegisterConCommand("reload_mods", ConCommand_reload_mods, "reloads mods", FCVAR_NONE);
}
