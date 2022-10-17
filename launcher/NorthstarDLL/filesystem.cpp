#include "pch.h"
#include "filesystem.h"
#include "sourceinterface.h"
#include "modmanager.h"

#include <iostream>
#include <sstream>

AUTOHOOK_INIT()

using namespace R2;

bool bReadingOriginalFile = false;
std::string sCurrentModPath;

ConVar* Cvar_ns_fs_log_reads;

// use the R2 namespace for game funcs
namespace R2
{
	SourceInterface<IFileSystem>* g_pFilesystem;

	std::string ReadVPKFile(const char* path)
	{
		// read scripts.rson file, todo: check if this can be overwritten
		FileHandle_t fileHandle = (*g_pFilesystem)->m_vtable2->Open(&(*g_pFilesystem)->m_vtable2, path, "rb", "GAME", 0);

		std::stringstream fileStream;
		int bytesRead = 0;
		char data[4096];
		do
		{
			bytesRead = (*g_pFilesystem)->m_vtable2->Read(&(*g_pFilesystem)->m_vtable2, data, (int)std::size(data), fileHandle);
			fileStream.write(data, bytesRead);
		} while (bytesRead == std::size(data));

		(*g_pFilesystem)->m_vtable2->Close(*g_pFilesystem, fileHandle);

		return fileStream.str();
	}

	std::string ReadVPKOriginalFile(const char* path)
	{
		// todo: should probably set search path to be g_pModName here also

		bReadingOriginalFile = true;
		std::string ret = ReadVPKFile(path);
		bReadingOriginalFile = false;

		return ret;
	}
} // namespace R2

// clang-format off
HOOK(AddSearchPathHook, AddSearchPath,
void, __fastcall, (IFileSystem * fileSystem, const char* pPath, const char* pathID, SearchPathAdd_t addType))
// clang-format on
{
	AddSearchPath(fileSystem, pPath, pathID, addType);

	// make sure current mod paths are at head
	if (!strcmp(pathID, "GAME") && sCurrentModPath.compare(pPath) && addType == PATH_ADD_TO_HEAD)
	{
		AddSearchPath(fileSystem, sCurrentModPath.c_str(), "GAME", PATH_ADD_TO_HEAD);
		AddSearchPath(fileSystem, GetCompiledAssetsPath().string().c_str(), "GAME", PATH_ADD_TO_HEAD);
	}
}

void SetNewModSearchPaths(Mod* mod)
{
	// put our new path to the head if we need to read from a different mod path
	// in the future we could also determine whether the file we're setting paths for needs a mod dir, or compiled assets
	if (mod != nullptr)
	{
		if ((fs::absolute(mod->m_ModDirectory) / MOD_OVERRIDE_DIR).string().compare(sCurrentModPath))
		{
			spdlog::info("changing mod search path from {} to {}", sCurrentModPath, mod->m_ModDirectory.string());

			AddSearchPath(
				&*(*g_pFilesystem), (fs::absolute(mod->m_ModDirectory) / MOD_OVERRIDE_DIR).string().c_str(), "GAME", PATH_ADD_TO_HEAD);
			sCurrentModPath = (fs::absolute(mod->m_ModDirectory) / MOD_OVERRIDE_DIR).string();
		}
	}
	else // push compiled to head
		AddSearchPath(&*(*g_pFilesystem), fs::absolute(GetCompiledAssetsPath()).string().c_str(), "GAME", PATH_ADD_TO_HEAD);
}

bool TryReplaceFile(const char* pPath, bool shouldCompile)
{
	if (bReadingOriginalFile)
		return false;

	if (shouldCompile)
		g_pModManager->CompileAssetsForFile(pPath);

	// idk how efficient the lexically normal check is
	// can't just set all /s in path to \, since some paths aren't in writeable memory
	auto file = g_pModManager->m_ModFiles.find(g_pModManager->NormaliseModFilePath(fs::path(pPath)));
	if (file != g_pModManager->m_ModFiles.end())
	{
		SetNewModSearchPaths(file->second.m_pOwningMod);
		return true;
	}

	return false;
}

// force modded files to be read from mods, not cache
// clang-format off
HOOK(ReadFromCacheHook, ReadFromCache,
bool, __fastcall, (IFileSystem * filesystem, char* pPath, void* result))
// clang-format off
{
	if (TryReplaceFile(pPath, true))
		return false;

	return ReadFromCache(filesystem, pPath, result);
}

// force modded files to be read from mods, not vpk
// clang-format off
AUTOHOOK(ReadFileFromVPK, filesystem_stdio.dll + 0x5CBA0,
FileHandle_t, __fastcall, (VPKData* vpkInfo, uint64_t* b, char* filename))
// clang-format on
{
	// don't compile here because this is only ever called from OpenEx, which already compiles
	if (TryReplaceFile(filename, false))
	{
		*b = -1;
		return b;
	}

	return ReadFileFromVPK(vpkInfo, b, filename);
}

// clang-format off
AUTOHOOK(CBaseFileSystem__OpenEx, filesystem_stdio.dll + 0x15F50,
FileHandle_t, __fastcall, (IFileSystem* filesystem, const char* pPath, const char* pOptions, uint32_t flags, const char* pPathID, char **ppszResolvedFilename))
// clang-format on
{
	TryReplaceFile(pPath, true);
	return CBaseFileSystem__OpenEx(filesystem, pPath, pOptions, flags, pPathID, ppszResolvedFilename);
}

HOOK(MountVPKHook, MountVPK, VPKData*, , (IFileSystem * fileSystem, const char* pVpkPath))
{
	spdlog::info("MountVPK {}", pVpkPath);
	VPKData* ret = MountVPK(fileSystem, pVpkPath);

	for (Mod mod : g_pModManager->m_LoadedMods)
	{
		if (!mod.m_bEnabled)
			continue;

		for (ModVPKEntry& vpkEntry : mod.Vpks)
		{
			// if we're autoloading, just load no matter what
			if (!vpkEntry.m_bAutoLoad)
			{
				// resolve vpk name and try to load one with the same name
				// todo: we should be unloading these on map unload manually
				std::string mapName(fs::path(pVpkPath).filename().string());
				std::string modMapName(fs::path(vpkEntry.m_sVpkPath.c_str()).filename().string());
				if (mapName.compare(modMapName))
					continue;
			}

			VPKData* loaded = MountVPK(fileSystem, vpkEntry.m_sVpkPath.c_str());
			if (!ret) // this is primarily for map vpks and stuff, so the map's vpk is what gets returned from here
				ret = loaded;
		}
	}

	return ret;
}

ON_DLL_LOAD("filesystem_stdio.dll", Filesystem, (CModule module))
{
	AUTOHOOK_DISPATCH()

	R2::g_pFilesystem = new SourceInterface<IFileSystem>("filesystem_stdio.dll", "VFileSystem017");

	AddSearchPathHook.Dispatch((*g_pFilesystem)->m_vtable->AddSearchPath);
	ReadFromCacheHook.Dispatch((*g_pFilesystem)->m_vtable->ReadFromCache);
	MountVPKHook.Dispatch((*g_pFilesystem)->m_vtable->MountVPK);
}
