#include "rapidjson/error/en.h"

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
	ParsePluginDependencies(modJson);
	ParseInitScript(modJson);

	// A mod is remote if it's located in the remote mods folder
	m_bIsRemote = m_ModDirectory.generic_string().find(GetRemoteModFolderPath().generic_string()) != std::string::npos;

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

void Mod::ParsePluginDependencies(rapidjson_document& json)
{
	if (!json.HasMember("PluginDependencies"))
		return;

	if (!json["PluginDependencies"].IsArray())
	{
		spdlog::warn("'PluginDependencies' field is not an object, skipping...");
		return;
	}

	for (auto& name : json["PluginDependencies"].GetArray())
	{
		if (!name.IsString())
			continue;

		spdlog::info("Plugin Constant {} defined by {}", name.GetString(), Name);

		PluginDependencyConstants.push_back(name.GetString());
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
