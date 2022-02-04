#include "pch.h"
#include "modlocalisation.h"
#include "hookutils.h"
#include "modmanager.h"
#include "dedicated.h"

typedef bool (*AddLocalisationFileType)(void* g_pVguiLocalize, const char* path, const char* pathId, char unknown);
AddLocalisationFileType AddLocalisationFile;

bool loadModLocalisationFiles = true;

bool AddLocalisationFileHook(void* g_pVguiLocalize, const char* path, const char* pathId, char unknown)
{
	bool ret = AddLocalisationFile(g_pVguiLocalize, path, pathId, unknown);

	if (ret)
		spdlog::info("Loaded localisation file {} successfully", path);

	if (!loadModLocalisationFiles)
		return ret;

	loadModLocalisationFiles = false;

	for (Mod mod : g_ModManager->m_loadedMods)
		if (mod.Enabled)
			for (std::string& localisationFile : mod.LocalisationFiles)
				AddLocalisationFile(g_pVguiLocalize, localisationFile.c_str(), pathId, unknown);

	loadModLocalisationFiles = true;

	return ret;
}

void InitialiseModLocalisation(HMODULE baseAddress)
{
	if (IsDedicated())
		return;

	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x6D80, AddLocalisationFileHook, reinterpret_cast<LPVOID*>(&AddLocalisationFile));
}