#include "pch.h"
#include "rpakfilesystem.h"
#include "hookutils.h"
#include "modmanager.h"

typedef void* (*LoadCommonPaksForMapType)(char* map);
LoadCommonPaksForMapType LoadCommonPaksForMap;

typedef void* (*LoadPakSyncType)(const char* path, void* unknownSingleton, int flags);
typedef void* (*LoadPakAsyncType)(const char* path, void* unknownSingleton, int flags, void* callback0, void* callback1);

// there are more i'm just too lazy to add
struct PakLoadFuncs
{
	void* unknown[2];
	LoadPakSyncType func2;
	LoadPakAsyncType LoadPakAsync;
};

PakLoadFuncs* g_pakLoadApi;
void** pUnknownPakLoadSingleton;

void LoadPakAsync(const char* path) { g_pakLoadApi->LoadPakAsync(path, *pUnknownPakLoadSingleton, 2, nullptr, nullptr); }

void LoadCommonPaksForMapHook(char* map)
{
	LoadCommonPaksForMap(map);

	// for sp => mp conversions, load the sp rpaks
	if (!strcmp(map, "mp_skyway_v1") || !strcmp(map, "mp_crashsite") || !strcmp(map, "mp_hub_timeshift"))
		map[0] = 's';
}

void InitialiseEngineRpakFilesystem(HMODULE baseAddress)
{
	g_pakLoadApi = (PakLoadFuncs*)((char*)baseAddress + 0x5BED78);
	pUnknownPakLoadSingleton = (void**)((char*)baseAddress + 0x7C5E20);

	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0x15AD20, &LoadCommonPaksForMapHook, reinterpret_cast<LPVOID*>(&LoadCommonPaksForMap));
}