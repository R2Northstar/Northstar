#include "pch.h"
#include "hooks.h"
#include "hookutils.h"

#include <wchar.h>
#include <iostream>
#include <vector>
#include <fstream>
#include <sstream>
#include <filesystem>

typedef LPSTR(*GetCommandLineAType)();
LPSTR GetCommandLineAHook();

// note that these load library callbacks only support explicitly loaded dynamic libraries

typedef HMODULE(*LoadLibraryExAType)(LPCSTR lpLibFileName, HANDLE hFile, DWORD dwFlags);
HMODULE LoadLibraryExAHook(LPCSTR lpLibFileName, HANDLE hFile, DWORD dwFlags);

typedef HMODULE(*LoadLibraryAType)(LPCSTR lpLibFileName);
HMODULE LoadLibraryAHook(LPCSTR lpLibFileName);

typedef HMODULE(*LoadLibraryExWType)(LPCWSTR lpLibFileName, HANDLE hFile, DWORD dwFlags);
HMODULE LoadLibraryExWHook(LPCWSTR lpLibFileName, HANDLE hFile, DWORD dwFlags);

typedef HMODULE(*LoadLibraryWType)(LPCWSTR lpLibFileName);
HMODULE LoadLibraryWHook(LPCWSTR lpLibFileName);

GetCommandLineAType GetCommandLineAOriginal;
LoadLibraryExAType LoadLibraryExAOriginal;
LoadLibraryAType LoadLibraryAOriginal;
LoadLibraryExWType LoadLibraryExWOriginal;
LoadLibraryWType LoadLibraryWOriginal;

void InstallInitialHooks()
{
	if (MH_Initialize() != MH_OK)
		spdlog::error("MH_Initialize failed");
	
	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, &GetCommandLineA, &GetCommandLineAHook, reinterpret_cast<LPVOID*>(&GetCommandLineAOriginal));
	ENABLER_CREATEHOOK(hook, &LoadLibraryExA, &LoadLibraryExAHook, reinterpret_cast<LPVOID*>(&LoadLibraryExAOriginal));
	ENABLER_CREATEHOOK(hook, &LoadLibraryA, &LoadLibraryAHook, reinterpret_cast<LPVOID*>(&LoadLibraryAOriginal));
	ENABLER_CREATEHOOK(hook, &LoadLibraryExW, &LoadLibraryExWHook, reinterpret_cast<LPVOID*>(&LoadLibraryExWOriginal));
	ENABLER_CREATEHOOK(hook, &LoadLibraryW, &LoadLibraryWHook, reinterpret_cast<LPVOID*>(&LoadLibraryWOriginal));
}

char* cmdlineResult;
LPSTR GetCommandLineAHook()
{
	static char* cmdlineOrg;

	if (cmdlineOrg == nullptr || cmdlineResult == nullptr)
	{
		cmdlineOrg = GetCommandLineAOriginal();
		bool isDedi = strstr(cmdlineOrg, "-dedicated"); // well, this one has to be a real argument

		std::string args;
		std::ifstream cmdlineArgFile;

		// it looks like CommandLine() prioritizes parameters apprearing first, so we want the real commandline to take priority
		// not to mention that cmdlineOrg starts with the EXE path
		args.append(cmdlineOrg);
		args.append(" ");

		// append those from the file

		cmdlineArgFile = std::ifstream(!isDedi ? "ns_startup_args.txt" : "ns_startup_args_dedi.txt");

		if (cmdlineArgFile)
		{
			std::stringstream argBuffer;
			argBuffer << cmdlineArgFile.rdbuf();
			cmdlineArgFile.close();

			args.append(argBuffer.str());
		}

		auto len = args.length();
		cmdlineResult = reinterpret_cast<char*>(_malloc_base(len + 1));
		if (!cmdlineResult)
		{
			spdlog::error("malloc failed for command line");
			return cmdlineOrg;
		}
		memcpy(cmdlineResult, args.c_str(), len + 1);
		
		spdlog::info("Command line: {}", cmdlineResult);
	}

	return cmdlineResult;
}

// dll load callback stuff
// this allows for code to register callbacks to be run as soon as a dll is loaded, mainly to allow for patches to be made on dll load
struct DllLoadCallback
{
	std::string dll;
	DllLoadCallbackFuncType callback;
	bool called;
};

std::vector<DllLoadCallback*> dllLoadCallbacks;

void AddDllLoadCallback(std::string dll, DllLoadCallbackFuncType callback)
{
	DllLoadCallback* callbackStruct = new DllLoadCallback;
	callbackStruct->dll = dll;
	callbackStruct->callback = callback;
	callbackStruct->called = false;

	dllLoadCallbacks.push_back(callbackStruct);
}

void CallLoadLibraryACallbacks(LPCSTR lpLibFileName, HMODULE moduleAddress)
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

void CallLoadLibraryWCallbacks(LPCWSTR lpLibFileName, HMODULE moduleAddress)
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

HMODULE LoadLibraryExAHook(LPCSTR lpLibFileName, HANDLE hFile, DWORD dwFlags)
{
	HMODULE moduleAddress = LoadLibraryExAOriginal(lpLibFileName, hFile, dwFlags);
	
	if (moduleAddress)
	{
		CallLoadLibraryACallbacks(lpLibFileName, moduleAddress);
	}

	return moduleAddress;
}

HMODULE LoadLibraryAHook(LPCSTR lpLibFileName)
{
	HMODULE moduleAddress = LoadLibraryAOriginal(lpLibFileName);

	if (moduleAddress)
	{
		CallLoadLibraryACallbacks(lpLibFileName, moduleAddress);
	}

	return moduleAddress;
}

HMODULE LoadLibraryExWHook(LPCWSTR lpLibFileName, HANDLE hFile, DWORD dwFlags)
{
	HMODULE moduleAddress = LoadLibraryExWOriginal(lpLibFileName, hFile, dwFlags);

	if (moduleAddress)
	{
		CallLoadLibraryWCallbacks(lpLibFileName, moduleAddress);
	}

	return moduleAddress;
}

HMODULE LoadLibraryWHook(LPCWSTR lpLibFileName)
{
	HMODULE moduleAddress = LoadLibraryWOriginal(lpLibFileName);

	if (moduleAddress)
	{
		CallLoadLibraryWCallbacks(lpLibFileName, moduleAddress);
	}

	return moduleAddress;
}