#include "pch.h"
#include "filesystem.h"
#include "hooks.h"
#include "hookutils.h"
#include "sourceinterface.h"

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

bool ShouldReplaceFile(const char* path)
{
	return false;
}

FileHandle_t ReadFileFromVPKHook(VPKData* vpkInfo, __int64* b, const char* filename)
{
	// move this to a convar at some point when we can read them in native
	//spdlog::info("ReadFileFromVPKHook {} {}", filename, vpkInfo->path);
	if (ShouldReplaceFile(filename))
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


	return readFromCache(filesystem, path, result);
}