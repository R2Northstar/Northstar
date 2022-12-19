#include "pch.h"
#include "mods/modmanager.h"

AUTOHOOK_INIT()

// clang-format off
AUTOHOOK(AddLocalisationFile, localize.dll + 0x6D80,
bool, __fastcall, (void* pVguiLocalize, const char* path, const char* pathId, char unknown))
// clang-format on
{
	static bool bLoadModLocalisationFiles = true;
	bool ret = AddLocalisationFile(pVguiLocalize, path, pathId, unknown);

	if (ret)
		spdlog::info("Loaded localisation file {} successfully", path);

	if (!bLoadModLocalisationFiles)
		return ret;

	bLoadModLocalisationFiles = false;

	for (Mod mod : g_pModManager->m_LoadedMods)
		if (mod.m_bEnabled)
			for (std::string& localisationFile : mod.LocalisationFiles)
				AddLocalisationFile(pVguiLocalize, localisationFile.c_str(), pathId, unknown);

	bLoadModLocalisationFiles = true;

	return ret;
}

ON_DLL_LOAD_CLIENT("localize.dll", Localize, (CModule module))
{
	AUTOHOOK_DISPATCH()
}
