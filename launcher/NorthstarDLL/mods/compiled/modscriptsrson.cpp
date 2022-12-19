#include "pch.h"
#include "mods/modmanager.h"
#include "core/filesystem/filesystem.h"
#include "squirrel/squirrel.h"

#include <fstream>

const std::string MOD_SCRIPTS_RSON_SUFFIX = "scripts/vscripts/scripts.rson";
const char* VPK_SCRIPTS_RSON_PATH = "scripts\\vscripts\\scripts.rson";

void ModManager::BuildScriptsRson()
{
	spdlog::info("Building custom scripts.rson");
	fs::path MOD_SCRIPTS_RSON_PATH = fs::path(GetCompiledAssetsPath() / MOD_SCRIPTS_RSON_SUFFIX);
	fs::remove(MOD_SCRIPTS_RSON_PATH);

	std::string scriptsRson = R2::ReadVPKOriginalFile(VPK_SCRIPTS_RSON_PATH);
	scriptsRson += "\n\n// START MODDED SCRIPT CONTENT\n\n"; // newline before we start custom stuff

	for (Mod& mod : m_LoadedMods)
	{
		if (!mod.m_bEnabled)
			continue;

		// this isn't needed at all, just nice to have imo
		scriptsRson += "// MOD: ";
		scriptsRson += mod.Name;
		scriptsRson += ":\n\n";

		for (ModScript& script : mod.Scripts)
		{
			/* should create something with this format for each script
			When: "CONTEXT"
			Scripts:
			[
				_coolscript.gnut
			]*/

			scriptsRson += "When: \"";
			scriptsRson += script.RunOn;
			scriptsRson += "\"\n";

			scriptsRson += "Scripts:\n[\n\t";
			scriptsRson += script.Path;
			scriptsRson += "\n]\n\n";
		}
	}

	fs::create_directories(MOD_SCRIPTS_RSON_PATH.parent_path());

	std::ofstream writeStream(MOD_SCRIPTS_RSON_PATH, std::ios::binary);
	writeStream << scriptsRson;
	writeStream.close();

	ModOverrideFile overrideFile;
	overrideFile.m_pOwningMod = nullptr;
	overrideFile.m_Path = VPK_SCRIPTS_RSON_PATH;

	if (m_ModFiles.find(VPK_SCRIPTS_RSON_PATH) == m_ModFiles.end())
		m_ModFiles.insert(std::make_pair(VPK_SCRIPTS_RSON_PATH, overrideFile));
	else
		m_ModFiles[VPK_SCRIPTS_RSON_PATH] = overrideFile;

	// todo: for preventing dupe scripts in scripts.rson, we could actually parse when conditions with the squirrel vm, just need a way to
	// get a result out of squirrelmanager.ExecuteCode this would probably be the best way to do this, imo
}
