#include "mods/modmanager.h"

static void* (*__fastcall o_pBinkOpen)(const char* path, uint32_t flags) = nullptr;
static void* __fastcall h_BinkOpen(const char* path, uint32_t flags)
{
	std::string filename(fs::path(path).filename().string());
	spdlog::info("BinkOpen {}", filename);

	// figure out which mod is handling the bink
	Mod* fileOwner = nullptr;
	for (Mod& mod : g_pModManager->m_LoadedMods)
	{
		if (!mod.m_bEnabled)
			continue;

		if (std::find(mod.BinkVideos.begin(), mod.BinkVideos.end(), filename) != mod.BinkVideos.end())
			fileOwner = &mod;
	}

	if (fileOwner)
	{
		// create new path
		fs::path binkPath(fileOwner->m_ModDirectory / "media" / filename);
		return o_pBinkOpen(binkPath.string().c_str(), flags);
	}
	else
		return o_pBinkOpen(path, flags);
}

ON_DLL_LOAD_CLIENT("bink2w64.dll", BinkRead, (CModule module))
{
	o_pBinkOpen = module.GetExportedFunction("BinkOpen").RCast<decltype(o_pBinkOpen)>();
	HookAttach(&(PVOID&)o_pBinkOpen, (PVOID)h_BinkOpen);
}

ON_DLL_LOAD_CLIENT("engine.dll", BinkVideo, (CModule module))
{
	// remove engine check for whether the bik we're trying to load exists in r2/media, as this will fail for biks in mods
	// note: the check in engine is actually unnecessary, so it's just useless in practice and we lose nothing by removing it
	module.Offset(0x459AD).NOP(6);
}
