#include "mods/modmanager.h"
#include "core/filesystem/filesystem.h"

#include <fstream>

const char* KB_ACT_PATH = "scripts\\kb_act.lst";

// compiles the file kb_act.lst, that defines entries for keybindings in the options menu
void ModManager::BuildKBActionsList()
{
	spdlog::info("Building kb_act.lst");

	fs::create_directories(GetCompiledAssetsPath() / "scripts");
	std::ofstream soCompiledKeys(GetCompiledAssetsPath() / KB_ACT_PATH, std::ios::binary);

	// write vanilla file's content to compiled file
	soCompiledKeys << ReadVPKFile(KB_ACT_PATH, FileSourceType_Original);

	for (Mod& mod : m_LoadedMods)
	{
		if (!mod.m_bEnabled)
			continue;

		// write content of each modded file to compiled file
		std::ifstream siModKeys(mod.m_ModDirectory / "kb_act.lst");

		if (siModKeys.good())
			soCompiledKeys << siModKeys.rdbuf() << std::endl;

		siModKeys.close();
	}

	soCompiledKeys.close();

	m_CompiledFiles.insert(KB_ACT_PATH);
}
