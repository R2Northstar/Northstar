#include "pch.h"
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
	soCompiledKeys << R2::ReadVPKOriginalFile(KB_ACT_PATH);

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

	// push to overrides
	ModOverrideFile overrideFile;
	overrideFile.m_pOwningMod = nullptr;
	overrideFile.m_Path = KB_ACT_PATH;

	if (m_ModFiles.find(KB_ACT_PATH) == m_ModFiles.end())
		m_ModFiles.insert(std::make_pair(KB_ACT_PATH, overrideFile));
	else
		m_ModFiles[KB_ACT_PATH] = overrideFile;
}
