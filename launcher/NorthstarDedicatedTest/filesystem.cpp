#include "pch.h"
#include "filesystem.h"
#include "hooks.h"
#include "hookutils.h"
#include "sourceinterface.h"
#include "modmanager.h"

#include <iostream>

// hook forward declares
typedef FileHandle_t(*ReadFileFromVPKType)(VPKData* vpkInfo, __int64* b, const char* filename);
ReadFileFromVPKType readFileFromVPK;
FileHandle_t ReadFileFromVPKHook(VPKData* vpkInfo, __int64* b, const char* filename);

typedef bool(*ReadFromCacheType)(IFileSystem* filesystem, const char* path, void* result);
ReadFromCacheType readFromCache;
bool ReadFromCacheHook(IFileSystem* filesystem, const char* path, void* result);

SourceInterface<IFileSystem>* g_Filesystem;

void InitialiseFilesystem(HMODULE baseAddress)
{
	g_Filesystem = new SourceInterface<IFileSystem>("filesystem_stdio.dll", "VFileSystem017");

	// create hooks
	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x5CBA0, &ReadFileFromVPKHook, reinterpret_cast<LPVOID*>(&readFileFromVPK));
	ENABLER_CREATEHOOK(hook, (*g_Filesystem)->m_vtable->ReadFromCache, &ReadFromCacheHook, reinterpret_cast<LPVOID*>(&readFromCache));
}

void SetNewModSearchPaths(Mod* mod)
{
	// put our new path to the head
	// in future we should look into manipulating paths at head manually, might be effort tho
	(*g_Filesystem)->m_vtable->AddSearchPath(&*(*g_Filesystem), (fs::absolute(mod->ModDirectory) / "mod").string().c_str(), "GAME", PATH_ADD_TO_HEAD);
}

bool TryReplaceFile(const char* path)
{
	// is this efficient? no clue
	for (ModOverrideFile* modFile : g_ModManager->m_modFiles)
	{
		if (!modFile->path.compare(fs::path(path).lexically_normal()))
		{
			SetNewModSearchPaths(modFile->owningMod);
			return true;
		}
	}

	return false;
}

FileHandle_t ReadFileFromVPKHook(VPKData* vpkInfo, __int64* b, const char* filename)
{
	// move this to a convar at some point when we can read them in native
	//spdlog::info("ReadFileFromVPKHook {} {}", filename, vpkInfo->path);
	if (TryReplaceFile(filename))
	{
		*b = -1;
		return b;
	}

	return readFileFromVPK(vpkInfo, b, filename);
}

bool ReadFromCacheHook(IFileSystem* filesystem, const char* path, void* result)
{
	// move this to a convar at some point when we can read them in native
	//spdlog::info("ReadFromCacheHook {}", path);

	if (TryReplaceFile(path))
		return false;

	return readFromCache(filesystem, path, result);
}