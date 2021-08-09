#include "pch.h"
#include "modlocalisation.h"
#include "hookutils.h"
#include "modmanager.h"

typedef char(*AddLocalisationFileType)(void* g_pVguiLocalize, const char* path, const char* pathId);
AddLocalisationFileType AddLocalisationFile;

bool loadModLocalisationFiles = true;

char AddLocalisationFileHook(void* g_pVguiLocalize, const char* path, char* pathId)
{
	char ret = AddLocalisationFile(g_pVguiLocalize, path, pathId);

	if (!loadModLocalisationFiles)
		return ret;

	loadModLocalisationFiles = false;

	for (Mod* mod : g_ModManager->m_loadedMods)
	{
		for (std::string& localisationFile : mod->LocalisationFiles)
		{
			spdlog::info("Adding mod localisation file {}", localisationFile);
			AddLocalisationFile(g_pVguiLocalize, localisationFile.c_str(), pathId);
		}
	}

	loadModLocalisationFiles = true;

	return ret;
}

void InitialiseModLocalisation(HMODULE baseAddress)
{
	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x6D80, AddLocalisationFileHook, reinterpret_cast<LPVOID*>(&AddLocalisationFile));
}