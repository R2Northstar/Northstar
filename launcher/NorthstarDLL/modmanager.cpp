#include "pch.h"
#include "modmanager.h"
#include "convar.h"
#include "concommand.h"
#include "audio.h"
#include "masterserver.h"
#include "filesystem.h"
#include "rpakfilesystem.h"
#include "nsprefix.h"

#include "rapidjson/error/en.h"
#include "rapidjson/document.h"
#include "rapidjson/ostreamwrapper.h"
#include "rapidjson/writer.h"
#include <filesystem>
#include <fstream>
#include <string>
#include <sstream>
#include <vector>

ModManager* g_pModManager;

Mod::Mod(fs::path modDir, char* jsonBuf)
{
	m_bWasReadSuccessfully = false;

	m_ModDirectory = modDir;

	rapidjson_document modJson;
	modJson.Parse<rapidjson::ParseFlag::kParseCommentsFlag | rapidjson::ParseFlag::kParseTrailingCommasFlag>(jsonBuf);

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

	// mod convars
	if (modJson.HasMember("ConVars") && modJson["ConVars"].IsArray())
	{
		for (auto& convarObj : modJson["ConVars"].GetArray())
		{
			if (!convarObj.IsObject() || !convarObj.HasMember("Name") || !convarObj.HasMember("DefaultValue"))
				continue;

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

					std::string sFlags = convarObj["Flags"].GetString();
					sFlags += '|'; // add additional | so we register the last flag
					std::string sCurrentFlag;

					for (int i = 0; i < sFlags.length(); i++)
					{
						if (isspace(sFlags[i]))
							continue;

						// if we encounter a |, add current string as a flag
						if (sFlags[i] == '|')
						{
							bool bHasFlags = false;
							int iCurrentFlags;

							for (auto& flagPair : g_PrintCommandFlags)
							{
								if (!sCurrentFlag.compare(flagPair.second))
								{
									iCurrentFlags = flagPair.first;
									bHasFlags = true;
									break;
								}
							}

							if (bHasFlags)
								convar->Flags |= iCurrentFlags;
							else
								spdlog::warn("Mod ConVar {} has unknown flag {}", convar->Name, sCurrentFlag);

							sCurrentFlag = "";
						}
						else
							sCurrentFlag += sFlags[i];
					}
				}
			}

			ConVars.push_back(convar);
		}
	}

	// mod scripts
	if (modJson.HasMember("Scripts") && modJson["Scripts"].IsArray())
	{
		for (auto& scriptObj : modJson["Scripts"].GetArray())
		{
			if (!scriptObj.IsObject() || !scriptObj.HasMember("Path") || !scriptObj.HasMember("RunOn"))
				continue;

			ModScript script;

			script.Path = scriptObj["Path"].GetString();
			script.RunOn = scriptObj["RunOn"].GetString();

			if (scriptObj.HasMember("ServerCallback") && scriptObj["ServerCallback"].IsObject())
			{
				ModScriptCallback callback;
				callback.Context = ScriptContext::SERVER;

				if (scriptObj["ServerCallback"].HasMember("Before") && scriptObj["ServerCallback"]["Before"].IsString())
					callback.BeforeCallback = scriptObj["ServerCallback"]["Before"].GetString();

				if (scriptObj["ServerCallback"].HasMember("After") && scriptObj["ServerCallback"]["After"].IsString())
					callback.AfterCallback = scriptObj["ServerCallback"]["After"].GetString();

				script.Callbacks.push_back(callback);
			}

			if (scriptObj.HasMember("ClientCallback") && scriptObj["ClientCallback"].IsObject())
			{
				ModScriptCallback callback;
				callback.Context = ScriptContext::CLIENT;

				if (scriptObj["ClientCallback"].HasMember("Before") && scriptObj["ClientCallback"]["Before"].IsString())
					callback.BeforeCallback = scriptObj["ClientCallback"]["Before"].GetString();

				if (scriptObj["ClientCallback"].HasMember("After") && scriptObj["ClientCallback"]["After"].IsString())
					callback.AfterCallback = scriptObj["ClientCallback"]["After"].GetString();

				script.Callbacks.push_back(callback);
			}

			if (scriptObj.HasMember("UICallback") && scriptObj["UICallback"].IsObject())
			{
				ModScriptCallback callback;
				callback.Context = ScriptContext::UI;

				if (scriptObj["UICallback"].HasMember("Before") && scriptObj["UICallback"]["Before"].IsString())
					callback.BeforeCallback = scriptObj["UICallback"]["Before"].GetString();

				if (scriptObj["UICallback"].HasMember("After") && scriptObj["UICallback"]["After"].IsString())
					callback.AfterCallback = scriptObj["UICallback"]["After"].GetString();

				script.Callbacks.push_back(callback);
			}

			Scripts.push_back(script);
		}
	}

	if (modJson.HasMember("Localisation") && modJson["Localisation"].IsArray())
	{
		for (auto& localisationStr : modJson["Localisation"].GetArray())
		{
			if (!localisationStr.IsString())
				continue;

			LocalisationFiles.push_back(localisationStr.GetString());
		}
	}

	if (modJson.HasMember("Dependencies") && modJson["Dependencies"].IsObject())
	{
		for (auto v = modJson["Dependencies"].MemberBegin(); v != modJson["Dependencies"].MemberEnd(); v++)
		{
			if (!v->name.IsString() || !v->value.IsString())
				continue;

			spdlog::info("Constant {} defined by {} for mod {}", v->name.GetString(), Name, v->value.GetString());
			if (DependencyConstants.find(v->name.GetString()) != DependencyConstants.end() &&
				v->value.GetString() != DependencyConstants[v->name.GetString()])
			{
				spdlog::error("A dependency constant with the same name already exists for another mod. Change the constant name.");
				return;
			}

			if (DependencyConstants.find(v->name.GetString()) == DependencyConstants.end())
				DependencyConstants.emplace(v->name.GetString(), v->value.GetString());
		}
	}

	m_bWasReadSuccessfully = true;
}

ModManager::ModManager()
{
	// precaculated string hashes
	// note: use backslashes for these, since we use lexically_normal for file paths which uses them
	m_hScriptsRsonHash = STR_HASH("scripts\\vscripts\\scripts.rson");
	m_hPdefHash = STR_HASH(
		"cfg\\server\\persistent_player_data_version_231.pdef" // this can have multiple versions, but we use 231 so that's what we hash
	);

	LoadMods();
}

void ModManager::LoadMods()
{
	if (m_bHasLoadedMods)
		UnloadMods();

	std::vector<fs::path> modDirs;

	// ensure dirs exist
	fs::remove_all(GetCompiledAssetsPath());
	fs::create_directories(GetModFolderPath());

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
	for (fs::directory_entry dir : fs::directory_iterator(GetModFolderPath()))
		if (fs::exists(dir.path() / "mod.json"))
			modDirs.push_back(dir.path());

	for (fs::path modDir : modDirs)
	{
		// read mod json file
		std::ifstream jsonStream(modDir / "mod.json");
		std::stringstream jsonStringStream;

		// fail if no mod json
		if (jsonStream.fail())
		{
			spdlog::warn("Mod {} has a directory but no mod.json", modDir.string());
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
				spdlog::error("Constant {} in mod {} already exists in another mod.", pair.first, mod.Name);
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
			spdlog::info("Loaded mod {} successfully", mod.Name);
			if (mod.m_bEnabled)
				spdlog::info("Mod {} is enabled", mod.Name);
			else
				spdlog::info("Mod {} is disabled", mod.Name);

			m_LoadedMods.push_back(mod);
		}
		else
			spdlog::warn("Skipping loading mod file {}", (modDir / "mod.json").string());
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
			if (!R2::g_pCVar->FindVar(convar->Name.c_str())) // make sure convar isn't registered yet, unsure if necessary but idk what
															 // behaviour is for defining same convar multiple times
				new ConVar(convar->Name.c_str(), convar->DefaultValue.c_str(), convar->Flags, convar->HelpString.c_str());

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
	modinfoDoc.SetObject();
	modinfoDoc.AddMember("Mods", rapidjson_document::GenericValue(rapidjson::kArrayType), modinfoDoc.GetAllocator());

	int currentModIndex = 0;
	for (Mod& mod : m_LoadedMods)
	{
		if (!mod.m_bEnabled || (!mod.RequiredOnClient && !mod.Pdiff.size()))
			continue;

		modinfoDoc["Mods"].PushBack(rapidjson_document::GenericValue(rapidjson::kObjectType), modinfoDoc.GetAllocator());
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
			m_EnabledModsCfg.AddMember(
				rapidjson_document::StringRefType(mod.Name.c_str()),
				rapidjson_document::GenericValue(false),
				m_EnabledModsCfg.GetAllocator());

		m_EnabledModsCfg[mod.Name.c_str()].SetBool(mod.m_bEnabled);
	}

	std::ofstream writeStream(GetNorthstarPrefix() + "/enabledmods.json");
	rapidjson::OStreamWrapper writeStreamWrapper(writeStream);
	rapidjson::Writer<rapidjson::OStreamWrapper> writer(writeStreamWrapper);
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
fs::path GetCompiledAssetsPath()
{
	return fs::path(GetNorthstarPrefix() + COMPILED_ASSETS_SUFFIX);
}

ON_DLL_LOAD_RELIESON("engine.dll", ModManager, (ConCommand, MasterServer), (CModule module))
{
	g_pModManager = new ModManager;

	RegisterConCommand("reload_mods", ConCommand_reload_mods, "reloads mods", FCVAR_NONE);
}
