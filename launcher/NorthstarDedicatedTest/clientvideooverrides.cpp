#include "pch.h"
#include "clientvideooverrides.h"
#include "modmanager.h"
#include "dedicated.h"

typedef void*(*BinkOpenType)(const char* path, uint32_t flags);
BinkOpenType BinkOpen;

void* BinkOpenHook(const char* path, uint32_t flags)
{
	std::string filename(fs::path(path).filename().string());
	spdlog::info("BinkOpen {}", filename);

	// figure out which mod is handling the bink
	Mod* fileOwner = nullptr;
	for (Mod& mod : g_ModManager->m_loadedMods)
	{
		if (!mod.Enabled)
			continue;
		
		if (std::find(mod.BinkVideos.begin(), mod.BinkVideos.end(), filename) != mod.BinkVideos.end())
			fileOwner = &mod;
	}

	if (fileOwner)
	{
		// create new path
		fs::path binkPath(fileOwner->ModDirectory / "media" / filename);
		return BinkOpen(binkPath.string().c_str(), flags);
	}
	else
		return BinkOpen(path, flags);
}

void InitialiseClientVideoOverrides(HMODULE baseAddress)
{
	if (IsDedicated())
		return;

	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, GetProcAddress(GetModuleHandleA("bink2w64.dll"), "BinkOpen"), &BinkOpenHook, reinterpret_cast<LPVOID*>(&BinkOpen));
}