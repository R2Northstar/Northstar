#include "pch.h"
#include "filesystem.h"
#include "hooks.h"
#include "hookutils.h"
#include "sourceinterface.h"
#include "modmanager.h"

#include <iostream>
#include <sstream>

// hook forward declares
typedef FileHandle_t(*ReadFileFromVPKType)(VPKData* vpkInfo, __int64* b, const char* filename);
ReadFileFromVPKType readFileFromVPK;
FileHandle_t ReadFileFromVPKHook(VPKData* vpkInfo, __int64* b, const char* filename);

typedef bool(*ReadFromCacheType)(IFileSystem* filesystem, const char* path, void* result);
ReadFromCacheType readFromCache;
bool ReadFromCacheHook(IFileSystem* filesystem, const char* path, void* result);

typedef void(*AddSearchPathType)(IFileSystem* fileSystem, const char* pPath, const char* pathID, SearchPathAdd_t addType);
AddSearchPathType addSearchPathOriginal;
void AddSearchPathHook(IFileSystem* fileSystem, const char* pPath, const char* pathID, SearchPathAdd_t addType);

bool readingOriginalFile;
std::string currentModPath;
SourceInterface<IFileSystem>* g_Filesystem;

void InitialiseFilesystem(HMODULE baseAddress)
{
	g_Filesystem = new SourceInterface<IFileSystem>("filesystem_stdio.dll", "VFileSystem017");

	// create hooks
	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x5CBA0, &ReadFileFromVPKHook, reinterpret_cast<LPVOID*>(&readFileFromVPK));
	ENABLER_CREATEHOOK(hook, (*g_Filesystem)->m_vtable->ReadFromCache, &ReadFromCacheHook, reinterpret_cast<LPVOID*>(&readFromCache));
	ENABLER_CREATEHOOK(hook, (*g_Filesystem)->m_vtable->AddSearchPath, &AddSearchPathHook, reinterpret_cast<LPVOID*>(&addSearchPathOriginal));
}

std::string ReadVPKFile(const char* path)
{
	// read scripts.rson file, todo: check if this can be overwritten
	FileHandle_t fileHandle = (*g_Filesystem)->m_vtable2->Open(&(*g_Filesystem)->m_vtable2, path, "rb", "GAME", 0);

	std::stringstream fileStream;
	int bytesRead = 0;
	char data[4096];
	do
	{
		bytesRead = (*g_Filesystem)->m_vtable2->Read(&(*g_Filesystem)->m_vtable2, data, std::size(data), fileHandle);
		fileStream.write(data, bytesRead);
	} while (bytesRead == std::size(data));

	(*g_Filesystem)->m_vtable2->Close(*g_Filesystem, fileHandle);

	return fileStream.str();
}

std::string ReadVPKOriginalFile(const char* path)
{
	readingOriginalFile = true;
	std::string ret = ReadVPKFile(path);
	readingOriginalFile = false;

	return ret;
}

void SetNewModSearchPaths(Mod* mod)
{
	// put our new path to the head if we need to read from a different mod path
	// in the future we could also determine whether the file we're setting paths for needs a mod dir, or compiled assets
	if (mod != nullptr)
	{
		if ((fs::absolute(mod->ModDirectory) / MOD_OVERRIDE_DIR).string().compare(currentModPath))
		{
			spdlog::info("changing mod search path from {} to {}", currentModPath, mod->ModDirectory.string());

			addSearchPathOriginal(&*(*g_Filesystem), (fs::absolute(mod->ModDirectory) / MOD_OVERRIDE_DIR).string().c_str(), "GAME", PATH_ADD_TO_HEAD);
			currentModPath = (fs::absolute(mod->ModDirectory) / MOD_OVERRIDE_DIR).string();
		}
	}
	else if (!currentModPath.size()) // if currentModPath isn't set yet, then push compiled to head
		addSearchPathOriginal(&*(*g_Filesystem), fs::absolute(COMPILED_ASSETS_PATH).string().c_str(), "GAME", PATH_ADD_TO_HEAD);

}

bool TryReplaceFile(const char* path)
{
	if (readingOriginalFile)
		return false;

	(*g_ModManager).CompileAssetsForFile(path);

	// is this efficient? could probably be improved
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

void AddSearchPathHook(IFileSystem* fileSystem, const char* pPath, const char* pathID, SearchPathAdd_t addType)
{
	addSearchPathOriginal(fileSystem, pPath, pathID, addType);

	// make sure current mod paths are at head
	if (!strcmp(pathID, "GAME") && currentModPath.compare(pPath) && addType == PATH_ADD_TO_HEAD)
	{
		addSearchPathOriginal(fileSystem, currentModPath.c_str(), "GAME", PATH_ADD_TO_HEAD);
		addSearchPathOriginal(fileSystem, COMPILED_ASSETS_PATH.string().c_str(), "GAME", PATH_ADD_TO_HEAD);
	}
}