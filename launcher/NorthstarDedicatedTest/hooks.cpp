#include "pch.h"
#include "hooks.h"
#include "hookutils.h"
#include "sigscanning.h"

#include <wchar.h>
#include <iostream>
#include <vector>
#include <filesystem>

typedef HMODULE(*LoadLibraryExAType)(LPCSTR lpLibFileName, HANDLE hFile, DWORD dwFlags);
HMODULE LoadLibraryExAHook(LPCSTR lpLibFileName, HANDLE hFile, DWORD dwFlags);

typedef HMODULE(*LoadLibraryExWType)(LPCWSTR lpLibFileName, HANDLE hFile, DWORD dwFlags);
HMODULE LoadLibraryExWHook(LPCWSTR lpLibFileName, HANDLE hFile, DWORD dwFlags);

typedef BOOLEAN(*PDLL_INIT_ROUTINE)(PVOID DllHandle, ULONG Reason, PCONTEXT Context);
typedef BOOLEAN(*LdrpCallInitRoutineType)(PDLL_INIT_ROUTINE EntryPoint, PVOID BaseAddress, ULONG Reason, PVOID Context);
BOOLEAN LdrpCallInitRoutineHook(PDLL_INIT_ROUTINE EntryPoint, PVOID BaseAddress, ULONG Reason, PVOID Context);

LoadLibraryExAType LoadLibraryExAOriginal;
LoadLibraryExWType LoadLibraryExWOriginal;

LdrpCallInitRoutineType LdrpCallInitRoutineHookOriginal;

void InstallInitialHooks()
{
	if (MH_Initialize() != MH_OK)
		spdlog::error("MH_Initialize failed");
	
	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, &LoadLibraryExA, &LoadLibraryExAHook, reinterpret_cast<LPVOID*>(&LoadLibraryExAOriginal));
	ENABLER_CREATEHOOK(hook, &LoadLibraryExW, &LoadLibraryExWHook, reinterpret_cast<LPVOID*>(&LoadLibraryExWOriginal));

	void* LdrpCallInitRoutine = FindSignature("ntdll.dll", "\x48\x89\x5C\x24\x00\x44\x89\x44\x24\x00\x48\x89\x54\x24", "xxxx?xxxx?xxxx");
	ENABLER_CREATEHOOK(hook, LdrpCallInitRoutine, &LdrpCallInitRoutineHook, reinterpret_cast<LPVOID*>(&LdrpCallInitRoutineHookOriginal));
}

// dll load callback stuff
// this allows for code to register callbacks to be run as soon as a dll is loaded, mainly to allow for patches to be made on dll load
struct DllLoadCallback
{
	std::string dll;
	DllLoadCallbackFuncType callback;
	bool called;
	bool preinit;
};

std::vector<DllLoadCallback*> dllLoadCallbacks;

void AddDllLoadCallback(std::string dll, DllLoadCallbackFuncType callback, bool preinit)
{
	DllLoadCallback* callbackStruct = new DllLoadCallback;
	callbackStruct->dll = dll;
	callbackStruct->callback = callback;
	callbackStruct->called = false;
	callbackStruct->preinit = preinit;

	dllLoadCallbacks.push_back(callbackStruct);
}

HMODULE LoadLibraryExAHook(LPCSTR lpLibFileName, HANDLE hFile, DWORD dwFlags)
{
	HMODULE moduleAddress = LoadLibraryExAOriginal(lpLibFileName, hFile, dwFlags);
	
	if (moduleAddress)
	{
		for (auto& callbackStruct : dllLoadCallbacks)
		{
			if (!callbackStruct->called && strstr(lpLibFileName + (strlen(lpLibFileName) - strlen(callbackStruct->dll.c_str())), callbackStruct->dll.c_str()) != nullptr)
			{
				callbackStruct->callback(moduleAddress);
				callbackStruct->called = true;
			}
		}
	}

	return moduleAddress;
}

HMODULE LoadLibraryExWHook(LPCWSTR lpLibFileName, HANDLE hFile, DWORD dwFlags)
{
	HMODULE moduleAddress = LoadLibraryExWOriginal(lpLibFileName, hFile, dwFlags);

	if (moduleAddress)
	{
		for (auto& callbackStruct : dllLoadCallbacks)
		{
			std::wstring wcharStrDll = std::wstring(callbackStruct->dll.begin(), callbackStruct->dll.end());
			const wchar_t* callbackDll = wcharStrDll.c_str();
			if (!callbackStruct->called && wcsstr(lpLibFileName + (wcslen(lpLibFileName) - wcslen(callbackDll)), callbackDll) != nullptr)
			{
				callbackStruct->callback(moduleAddress);
				callbackStruct->called = true;
			}
		}
	}

	return moduleAddress;
}

BOOLEAN LdrpCallInitRoutineHook(PDLL_INIT_ROUTINE EntryPoint, PVOID BaseAddress, ULONG Reason, PVOID Context)
{
	char fullModulePath[MAX_PATH] = { 0 };
	GetModuleFileNameA((HMODULE)BaseAddress, fullModulePath, sizeof(fullModulePath));

	std::string name = std::filesystem::path(fullModulePath).filename().string();

	for (auto& callbackStruct : dllLoadCallbacks)
	{
		if (!callbackStruct->called && callbackStruct->preinit && name == callbackStruct->dll)
		{
			callbackStruct->callback((HMODULE)BaseAddress);
			callbackStruct->called = true;
		}
	}

	return LdrpCallInitRoutineHookOriginal(EntryPoint, BaseAddress, Reason, Context);
}