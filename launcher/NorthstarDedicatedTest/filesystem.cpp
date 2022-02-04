#include "pch.h"
#include "filesystem.h"
#include "hooks.h"
#include "hookutils.h"
#include "sourceinterface.h"
#include "modmanager.h"

#include <iostream>
#include <sstream>

// hook forward declares
typedef FileHandle_t (*ReadFileFromVPKType)(VPKData* vpkInfo, __int64* b, char* filename);
ReadFileFromVPKType readFileFromVPK;
FileHandle_t ReadFileFromVPKHook(VPKData* vpkInfo, __int64* b, char* filename);

typedef bool (*ReadFromCacheType)(IFileSystem* filesystem, char* path, void* result);
ReadFromCacheType readFromCache;
bool ReadFromCacheHook(IFileSystem* filesystem, char* path, void* result);

typedef void (*AddSearchPathType)(IFileSystem* fileSystem, const char* pPath, const char* pathID, SearchPathAdd_t addType);
AddSearchPathType addSearchPathOriginal;
void AddSearchPathHook(IFileSystem* fileSystem, const char* pPath, const char* pathID, SearchPathAdd_t addType);

typedef FileHandle_t (*ReadFileFromFilesystemType)(
	IFileSystem* filesystem, const char* pPath, const char* pOptions, int64_t a4, uint32_t a5);
ReadFileFromFilesystemType readFileFromFilesystem;
FileHandle_t ReadFileFromFilesystemHook(IFileSystem* filesystem, const char* pPath, const char* pOptions, int64_t a4, uint32_t a5);

typedef VPKData* (*MountVPKType)(IFileSystem* fileSystem, const char* vpkPath);
MountVPKType mountVPK;
VPKData* MountVPKHook(IFileSystem* fileSystem, const char* vpkPath);

bool readingOriginalFile;
std::string currentModPath;
SourceInterface<IFileSystem>* g_Filesystem;
void* g_pVGuiLocalize;

void InitialiseFilesystem(HMODULE baseAddress)
{
	g_Filesystem = new SourceInterface<IFileSystem>("filesystem_stdio.dll", "VFileSystem017");

	// create hooks
	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x5CBA0, &ReadFileFromVPKHook, reinterpret_cast<LPVOID*>(&readFileFromVPK));
	ENABLER_CREATEHOOK(hook, (*g_Filesystem)->m_vtable->ReadFromCache, &ReadFromCacheHook, reinterpret_cast<LPVOID*>(&readFromCache));
	ENABLER_CREATEHOOK(
		hook, (*g_Filesystem)->m_vtable->AddSearchPath, &AddSearchPathHook, reinterpret_cast<LPVOID*>(&addSearchPathOriginal));
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x15F20, &ReadFileFromFilesystemHook, reinterpret_cast<LPVOID*>(&readFileFromFilesystem));
	ENABLER_CREATEHOOK(hook, (*g_Filesystem)->m_vtable->MountVPK, &MountVPKHook, reinterpret_cast<LPVOID*>(&mountVPK));
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
		bytesRead = (*g_Filesystem)->m_vtable2->Read(&(*g_Filesystem)->m_vtable2, data, (int)std::size(data), fileHandle);
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

			addSearchPathOriginal(
				&*(*g_Filesystem), (fs::absolute(mod->ModDirectory) / MOD_OVERRIDE_DIR).string().c_str(), "GAME", PATH_ADD_TO_HEAD);
			currentModPath = (fs::absolute(mod->ModDirectory) / MOD_OVERRIDE_DIR).string();
		}
	}
	else // push compiled to head
		addSearchPathOriginal(&*(*g_Filesystem), fs::absolute(GetCompiledAssetsPath()).string().c_str(), "GAME", PATH_ADD_TO_HEAD);
}

bool TryReplaceFile(char* path, bool shouldCompile)
{
	if (readingOriginalFile)
		return false;

	if (shouldCompile)
		(*g_ModManager).CompileAssetsForFile(path);

	// idk how efficient the lexically normal check is
	// can't just set all /s in path to \, since some paths aren't in writeable memory
	auto file = g_ModManager->m_modFiles.find(fs::path(path).lexically_normal().string());
	if (file != g_ModManager->m_modFiles.end())
	{
		SetNewModSearchPaths(file->second.owningMod);
		return true;
	}

	return false;
}

FileHandle_t ReadFileFromVPKHook(VPKData* vpkInfo, __int64* b, char* filename)
{
	// move this to a convar at some point when we can read them in native
	// spdlog::info("ReadFileFromVPKHook {} {}", filename, vpkInfo->path);

	// there is literally never any reason to compile here, since we'll always compile in ReadFileFromFilesystemHook in the same codepath
	// this is called
	if (TryReplaceFile(filename, false))
	{
		*b = -1;
		return b;
	}

	return readFileFromVPK(vpkInfo, b, filename);
}

bool ReadFromCacheHook(IFileSystem* filesystem, char* path, void* result)
{
	// move this to a convar at some point when we can read them in native
	// spdlog::info("ReadFromCacheHook {}", path);

	if (TryReplaceFile(path, true))
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
		addSearchPathOriginal(fileSystem, GetCompiledAssetsPath().string().c_str(), "GAME", PATH_ADD_TO_HEAD);
	}
}

FileHandle_t ReadFileFromFilesystemHook(IFileSystem* filesystem, const char* pPath, const char* pOptions, int64_t a4, uint32_t a5)
{
	// this isn't super efficient, but it's necessary, since calling addsearchpath in readfilefromvpk doesn't work, possibly refactor later
	// it also might be possible to hook functions that are called later, idk look into callstack for ReadFileFromVPK
	if (!readingOriginalFile)
		TryReplaceFile((char*)pPath, true);

	return readFileFromFilesystem(filesystem, pPath, pOptions, a4, a5);
}

VPKData* MountVPKHook(IFileSystem* fileSystem, const char* vpkPath)
{
	spdlog::info("MountVPK {}", vpkPath);
	VPKData* ret = mountVPK(fileSystem, vpkPath);

	for (Mod mod : g_ModManager->m_loadedMods)
	{
		if (!mod.Enabled)
			continue;

		for (std::string& vpkPath : mod.Vpks)
		{
			// note: could potentially not mount these if they're already mounted?
			spdlog::info("MountVPK {}", vpkPath);
			spdlog::info((void*)mountVPK(fileSystem, vpkPath.c_str()));
		}
	}

	return ret;
}