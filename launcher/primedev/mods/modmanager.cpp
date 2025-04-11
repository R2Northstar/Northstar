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

ModManager::ModManager()
{
	cfgPath = GetNorthstarPrefix() + "/enabledmods.json";

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
	default:
		spdlog::error("ModConCommandCallback on invalid Context {}", found->Context);
	};
}

void ModManager::LoadMods()
{
	if (m_bHasLoadedMods)
		UnloadMods();

	// ensure dirs exist
	fs::remove_all(GetCompiledAssetsPath());
	fs::create_directories(GetModFolderPath());
	fs::create_directories(GetThunderstoreModFolderPath());
	fs::create_directories(GetRemoteModFolderPath());

	m_DependencyConstants.clear();

	// read enabled mods cfg
	std::ifstream enabledModsStream(cfgPath);
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

	// Load mod info from filesystem into `m_LoadedMods`
	SearchFilesystemForMods();

	// This is used to check if some mods have a folder but no entry in enabledmods.json
	bool newModsDetected = false;

	for (Mod& mod : m_LoadedMods)
	{
		if (!mod.m_bEnabled)
			continue;

		// Add mod entry to enabledmods.json if it doesn't exist
		if (!mod.m_bIsRemote && m_bHasEnabledModsCfg && !m_EnabledModsCfg.HasMember(mod.Name.c_str()))
		{
			m_EnabledModsCfg.AddMember(rapidjson_document::StringRefType(mod.Name.c_str()), true, m_EnabledModsCfg.GetAllocator());
			newModsDetected = true;
		}

		// register convars
		// for reloads, this is sorta barebones, when we have a good findconvar method, we could probably reset flags and stuff on
		// preexisting convars note: we don't delete convars if they already exist because they're used for script stuff, unfortunately this
		// causes us to leak memory on reload, but not much, potentially find a way to not do this at some point
		for (ModConVar* convar : mod.ConVars)
		{
			// make sure convar isn't registered yet, unsure if necessary but idk what
			// behaviour is for defining same convar multiple times
			if (!g_pCVar->FindVar(convar->Name.c_str()))
			{
				new ConVar(convar->Name.c_str(), convar->DefaultValue.c_str(), convar->Flags, convar->HelpString.c_str());
			}
		}

		for (ModConCommand* command : mod.ConCommands)
		{
			// make sure command isnt't registered multiple times.
			if (!g_pCVar->FindCommand(command->Name.c_str()))
			{
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
						g_pFilesystem->m_vtable->MountVPK(g_pFilesystem, vpkName.c_str());
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
					ModRpakEntry& modPak = mod.Rpaks.emplace_back(mod);

					modPak.m_pakName = pakName;

					if (!bUseRpakJson)
					{
						spdlog::warn("Mod {} contains rpaks without valid rpak.json, rpaks might not be loaded", mod.Name);
					}
					else
					{
						modPak.m_preload =
							(dRpakJson.HasMember("Preload") && dRpakJson["Preload"].IsObject() && dRpakJson["Preload"].HasMember(pakName) &&
							 dRpakJson["Preload"][pakName].IsTrue());

						// only one load method can be used for an rpak.
						if (modPak.m_preload)
							goto REGISTER_STARPAK;

						// postload things
						if (dRpakJson.HasMember("Postload") && dRpakJson["Postload"].IsObject() && dRpakJson["Postload"].HasMember(pakName))
						{
							modPak.m_dependentPakHash = STR_HASH(dRpakJson["Postload"][pakName].GetString());

							// only one load method can be used for an rpak.
							goto REGISTER_STARPAK;
						}

						// this is the only bit of rpak.json that isn't really deprecated. Even so, it will be moved over to the mod.json
						// eventually
						if (dRpakJson.HasMember(pakName))
						{
							if (!dRpakJson[pakName].IsString())
							{
								spdlog::error("Mod {} has invalid rpak.json. Rpak entries must be strings.", mod.Name);
								continue;
							}

							std::string loadStr = dRpakJson[pakName].GetString();
							try
							{
								modPak.m_loadRegex = std::regex(loadStr);
							}
							catch (...)
							{
								spdlog::error("Mod {} has invalid rpak.json. Malformed regex \"{}\" for {}", mod.Name, loadStr, pakName);
								return;
							}
						}
					}

				REGISTER_STARPAK:
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
				}
			}

			if (g_pPakLoadManager != nullptr)
				g_pPakLoadManager->TrackModPaks(mod);
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
					if (!g_CustomAudioManager.TryLoadAudioOverride(file.path(), mod.Name))
					{
						spdlog::warn("Mod {} has an invalid audio def {}", mod.Name, file.path().filename().string());
						continue;
					}
				}
			}
		}
	}

	// If there are new mods, we write entries accordingly in enabledmods.json
	if (newModsDetected)
	{
		std::ofstream writeStream(cfgPath);
		rapidjson::OStreamWrapper writeStreamWrapper(writeStream);
		rapidjson::PrettyWriter<rapidjson::OStreamWrapper> writer(writeStreamWrapper);
		m_EnabledModsCfg.Accept(writer);
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
		if (!mod.m_bEnabled)
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
	if (g_pPakLoadManager != nullptr)
		g_pPakLoadManager->UnloadAllModPaks();

	if (!m_bHasEnabledModsCfg)
		m_EnabledModsCfg.SetObject();

	for (Mod& mod : m_LoadedMods)
	{
		// remove all built kvs
		for (std::pair<size_t, std::string> kvPaths : mod.KeyValues)
			fs::remove(GetCompiledAssetsPath() / fs::path(kvPaths.second).lexically_relative(mod.m_ModDirectory));

		mod.KeyValues.clear();
	}

	// save mods configuration to disk
	ExportModsConfigurationToFile();

	// do we need to dealloc individual entries in m_loadedMods? idk, rework
	m_LoadedMods.clear();
}

void ModManager::SearchFilesystemForMods()
{
	std::vector<fs::path> modDirs;
	m_LoadedMods.clear();

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

		for (std::string& dependency : mod.PluginDependencyConstants)
		{
			m_PluginDependencyConstants.insert(dependency);
		}

		if (m_bHasEnabledModsCfg && m_EnabledModsCfg.HasMember(mod.Name.c_str()))
			mod.m_bEnabled = m_EnabledModsCfg[mod.Name.c_str()].IsTrue();
		else
			mod.m_bEnabled = true;

		if (mod.m_bWasReadSuccessfully)
		{
			if (mod.m_bEnabled)
				spdlog::info("'{}' loaded successfully, version {}", mod.Name, mod.Version);
			else
				spdlog::info("'{}' loaded successfully, version {} (DISABLED)", mod.Name, mod.Version);

			m_LoadedMods.push_back(mod);
		}
		else
			spdlog::warn("Mod file at '{}' failed to load", (modDir / "mod.json").string());
	}

	// sort by load prio, lowest-highest
	std::sort(m_LoadedMods.begin(), m_LoadedMods.end(), [](Mod& a, Mod& b) { return a.LoadPriority < b.LoadPriority; });
}

void ModManager::ExportModsConfigurationToFile()
{
	m_EnabledModsCfg.SetObject();

	for (Mod& mod : m_LoadedMods)
	{
		// write to m_enabledModsCfg
		// should we be doing this here or should scripts be doing this manually?
		// main issue with doing this here is when we reload mods for connecting to a server, we write enabled mods, which isn't necessarily
		// what we wanna do
		if (!m_EnabledModsCfg.HasMember(mod.Name.c_str()))
			m_EnabledModsCfg.AddMember(rapidjson_document::StringRefType(mod.Name.c_str()), false, m_EnabledModsCfg.GetAllocator());

		m_EnabledModsCfg[mod.Name.c_str()].SetBool(mod.m_bEnabled);
	}

	std::ofstream writeStream(cfgPath);
	rapidjson::OStreamWrapper writeStreamWrapper(writeStream);
	rapidjson::PrettyWriter<rapidjson::OStreamWrapper> writer(writeStreamWrapper);
	m_EnabledModsCfg.Accept(writer);
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
	NOTE_UNUSED(args);
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
