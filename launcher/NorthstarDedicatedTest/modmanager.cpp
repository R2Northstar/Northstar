#include "pch.h"
#include "modmanager.h"
#include "convar.h"

#include "rapidjson/error/en.h"
#include "rapidjson/document.h"
#include <filesystem>
#include <fstream>
#include <string>
#include <sstream>
#include <vector>

ModManager* g_ModManager;

Mod::Mod(fs::path modDir, char* jsonBuf)
{
	wasReadSuccessfully = false;

	rapidjson::Document modJson;
	modJson.Parse<rapidjson::ParseFlag::kParseCommentsFlag | rapidjson::ParseFlag::kParseTrailingCommasFlag>(jsonBuf);

	// fail if parse error
	if (modJson.HasParseError())
	{
		spdlog::error("Failed reading mod file {}: encountered parse error \"{}\" at offset {}", (modDir / "mod.json").string(), GetParseError_En(modJson.GetParseError()), modJson.GetErrorOffset());
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

	// mod convars
	if (modJson.HasMember("ConVars") && modJson["ConVars"].IsArray())
	{
		for (auto& convarObj : modJson["ConVars"].GetArray())
		{
			if (!convarObj.IsObject() || !convarObj.HasMember("Name") || !convarObj.HasMember("DefaultValue"))
				continue;

			ModConVar* convar = new ModConVar;
			convar->Name = convarObj["Name"].GetString();
			convar->DefaultValue = convarObj["DefaultValue"].GetString();

			if (convarObj.HasMember("HelpString"))
				convar->HelpString = convarObj["HelpString"].GetString();
			else
				convar->HelpString = "";

			// todo: could possibly parse FCVAR names here instead
			if (convarObj.HasMember("Flags"))
				convar->Flags = convarObj["Flags"].GetInt();
			else
				convar->Flags = FCVAR_NONE;

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
			
			ModScript* script = new ModScript;

			script->Path = scriptObj["Path"].GetString();
			script->RsonRunOn = scriptObj["RunOn"].GetString();

			// callbacks
			for (auto iterator = scriptObj.MemberBegin(); iterator != scriptObj.MemberEnd(); iterator++)
			{
				if (!iterator->name.IsString() || !iterator->value.IsObject())
					continue;

				ModScriptCallback* callback = new ModScriptCallback;
				callback->HookedCodeCallback = iterator->name.GetString();

				if (iterator->value.HasMember("Before") && iterator->value["Before"].IsString())
					callback->BeforeCallback = iterator->value["Before"].GetString();

				if (iterator->value.HasMember("After") && iterator->value["After"].IsString())
					callback->AfterCallback = iterator->value["After"].GetString();

				script->Callbacks.push_back(callback);
			}

			Scripts.push_back(script);
		}
	}

	wasReadSuccessfully = true;
}

ModManager::ModManager()
{
	LoadMods();
}

void ModManager::LoadMods()
{
	std::vector<fs::path> modDirs;

	// get mod directories
	for (fs::directory_entry dir : fs::directory_iterator(MOD_FOLDER_PATH))
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
	
		Mod* mod = new Mod(modDir, (char*)jsonStringStream.str().c_str());

		if (mod->wasReadSuccessfully)
		{
			spdlog::info("Loaded mod {} successfully", mod->Name);
			loadedMods.push_back(mod);
		}
		else
		{
			spdlog::warn("Skipping loading mod file {}", (modDir / "mod.json").string());
			delete mod;
		}
	}

	for (Mod* mod : loadedMods)
	{
		for (ModConVar* convar : mod->ConVars)
			if (g_CustomConvars.find(convar->Name) == g_CustomConvars.end()) // make sure convar isn't registered yet
				RegisterConVar(convar->Name.c_str(), convar->DefaultValue.c_str(), convar->Flags, convar->HelpString.c_str());
	}

}

void InitialiseModManager(HMODULE baseAddress)
{
	g_ModManager = new ModManager();
}