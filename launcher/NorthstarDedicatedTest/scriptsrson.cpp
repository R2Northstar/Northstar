#include "pch.h"
#include "modmanager.h"
#include "scriptsrson.h"
#include "filesystem.h"

#include <sstream>
#include <fstream>

void ModManager::BuildScriptsRson()
{
	spdlog::info("Building custom scripts.rson");
	fs::remove(MOD_SCRIPTS_RSON_PATH);

	// not really important since it doesn't affect actual functionality at all, but the rson we output is really weird
	// has a shitload of newlines added, even in places where we don't modify it at all

	std::string scriptsRson = ReadVPKOriginalFile("scripts/vscripts/scripts.rson");
	scriptsRson += "\n\n// START MODDED SCRIPT CONTENT\n\n"; // newline before we start custom stuff

	for (Mod* mod : m_loadedMods)
	{
		for (ModScript* script : mod->Scripts)
		{
			/* should create something with the format
			When: "CONTEXT"
			Scripts:
			[
				"_coolscript.gnut"
			]*/

			scriptsRson += "When: \"";
			scriptsRson += script->RsonRunOn;
			scriptsRson += "\"\n";

			scriptsRson += "Scripts:\n[\n\t";
			scriptsRson += script->Path;
			scriptsRson += "\n]\n\n";
		}
	}

	fs::create_directories(MOD_SCRIPTS_RSON_PATH.parent_path());

	std::ofstream writeStream(MOD_SCRIPTS_RSON_PATH);
	writeStream << scriptsRson;
	writeStream.close();

	ModOverrideFile* overrideFile = new ModOverrideFile;
	overrideFile->owningMod = nullptr;
	overrideFile->path = "scripts/vscripts/scripts.rson";
	m_modFiles.push_back(overrideFile);
}