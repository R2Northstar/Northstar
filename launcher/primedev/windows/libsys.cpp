#include "libsys.h"
#include "plugins/pluginmanager.h"

#define XINPUT1_3_DLL "XInput1_3.dll"

typedef HMODULE (*WINAPI ILoadLibraryA)(LPCSTR lpLibFileName);
typedef HMODULE (*WINAPI ILoadLibraryExA)(LPCSTR lpLibFileName, HANDLE hFile, DWORD dwFlags);
typedef HMODULE (*WINAPI ILoadLibraryW)(LPCWSTR lpLibFileName);
typedef HMODULE (*WINAPI ILoadLibraryExW)(LPCWSTR lpLibFileName, HANDLE hFile, DWORD dwFlags);

ILoadLibraryA o_LoadLibraryA = nullptr;
ILoadLibraryExA o_LoadLibraryExA = nullptr;
ILoadLibraryW o_LoadLibraryW = nullptr;
ILoadLibraryExW o_LoadLibraryExW = nullptr;

//-----------------------------------------------------------------------------
// Purpose: Run detour callbacks for given HMODULE
//-----------------------------------------------------------------------------
void LibSys_RunModuleCallbacks(HMODULE hModule)
{
	if (!hModule)
	{
		return;
	}

	// Get module base name in ASCII as noone wants to deal with unicode
	CHAR szModuleName[MAX_PATH];
	GetModuleBaseNameA(GetCurrentProcess(), hModule, szModuleName, MAX_PATH);

	// DevMsg(eLog::NONE, "%s\n", szModuleName);

	// Call callbacks
	CallLoadLibraryACallbacks(szModuleName, hModule);
	g_pPluginManager->InformDllLoad(hModule, fs::path(szModuleName));
}

//-----------------------------------------------------------------------------
// Load library callbacks

HMODULE WINAPI WLoadLibraryA(LPCSTR lpLibFileName)
{
	HMODULE hModule = o_LoadLibraryA(lpLibFileName);

	LibSys_RunModuleCallbacks(hModule);

	return hModule;
}

HMODULE WINAPI WLoadLibraryExA(LPCSTR lpLibFileName, HANDLE hFile, DWORD dwFlags)
{
	HMODULE hModule;

	LPCSTR lpLibFileNameEnd = lpLibFileName + strlen(lpLibFileName);
	LPCSTR lpLibName = lpLibFileNameEnd - strlen(XINPUT1_3_DLL);

	// replace xinput dll with one that has ASLR
	if (lpLibFileName <= lpLibName && !strncmp(lpLibName, XINPUT1_3_DLL, strlen(XINPUT1_3_DLL) + 1))
	{
		hModule = o_LoadLibraryExA("XInput9_1_0.dll", hFile, dwFlags);

		if (!hModule)
		{
			MessageBoxA(0, "Could not find XInput9_1_0.dll", "Northstar", MB_ICONERROR);
			exit(EXIT_FAILURE);

			return nullptr;
		}
	}
	else
	{
		hModule = o_LoadLibraryExA(lpLibFileName, hFile, dwFlags);
	}

	bool bShouldRunCallbacks =
		!(dwFlags & (LOAD_LIBRARY_AS_DATAFILE | LOAD_LIBRARY_AS_DATAFILE_EXCLUSIVE | LOAD_LIBRARY_AS_IMAGE_RESOURCE));
	if (bShouldRunCallbacks)
	{
		LibSys_RunModuleCallbacks(hModule);
	}

	return hModule;
}

HMODULE WINAPI WLoadLibraryW(LPCWSTR lpLibFileName)
{
	HMODULE hModule = o_LoadLibraryW(lpLibFileName);

	LibSys_RunModuleCallbacks(hModule);

	return hModule;
}

HMODULE WINAPI WLoadLibraryExW(LPCWSTR lpLibFileName, HANDLE hFile, DWORD dwFlags)
{
	HMODULE hModule = o_LoadLibraryExW(lpLibFileName, hFile, dwFlags);

	bool bShouldRunCallbacks =
		!(dwFlags & (LOAD_LIBRARY_AS_DATAFILE | LOAD_LIBRARY_AS_DATAFILE_EXCLUSIVE | LOAD_LIBRARY_AS_IMAGE_RESOURCE));
	if (bShouldRunCallbacks)
	{
		LibSys_RunModuleCallbacks(hModule);
	}

	return hModule;
}

//-----------------------------------------------------------------------------
// Purpose: Initilase dll load callbacks
//-----------------------------------------------------------------------------
void LibSys_Init()
{
	HMODULE hKernel = GetModuleHandleA("Kernel32.dll");

	o_LoadLibraryA = reinterpret_cast<ILoadLibraryA>(GetProcAddress(hKernel, "LoadLibraryA"));
	o_LoadLibraryExA = reinterpret_cast<ILoadLibraryExA>(GetProcAddress(hKernel, "LoadLibraryExA"));
	o_LoadLibraryW = reinterpret_cast<ILoadLibraryW>(GetProcAddress(hKernel, "LoadLibraryW"));
	o_LoadLibraryExW = reinterpret_cast<ILoadLibraryExW>(GetProcAddress(hKernel, "LoadLibraryExW"));

	HookAttach(&(PVOID&)o_LoadLibraryA, (PVOID)WLoadLibraryA);
	HookAttach(&(PVOID&)o_LoadLibraryExA, (PVOID)WLoadLibraryExA);
	HookAttach(&(PVOID&)o_LoadLibraryW, (PVOID)WLoadLibraryW);
	HookAttach(&(PVOID&)o_LoadLibraryExW, (PVOID)WLoadLibraryExW);
}
