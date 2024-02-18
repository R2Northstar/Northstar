#include "loader.h"

#include <filesystem>

FARPROC p[73];
HMODULE hL = 0;

static wchar_t wsockPath[4096];

BOOL WINAPI DllMain(HINSTANCE hInst, DWORD reason, LPVOID)
{
	if (reason == DLL_PROCESS_ATTACH)
	{
		// Tell the OS we don't need to know about threads
        DisableThreadLibraryCalls(hInst);

		if (!ProvisionNorthstar()) // does not call InitialiseNorthstar yet, will do it on LauncherMain hook
			return true;

        GetSystemDirectoryW(wsockPath, 4096);
		swprintf_s(wsockPath, 4096, L"%s\\wsock32.dll", wsockPath);

		hL = LoadLibraryExW(wsockPath, 0, LOAD_WITH_ALTERED_SEARCH_PATH);
		if (!hL)
		{
			LibraryLoadError(GetLastError(), L"wsock32.dll", wsockPath);
			return false;
		}

		// load the functions to proxy
		// it's only some of them, because in case of wsock32 most of the functions can actually be natively redirected
		// (see wsock32.def and https://source.winehq.org/WineAPI/wsock32.html)
		p[1] = GetProcAddress(hL, "EnumProtocolsA");
		p[2] = GetProcAddress(hL, "EnumProtocolsW");
		p[4] = GetProcAddress(hL, "GetAddressByNameA");
		p[5] = GetProcAddress(hL, "GetAddressByNameW");
		p[17] = GetProcAddress(hL, "WEP");
		p[30] = GetProcAddress(hL, "WSARecvEx");
		p[36] = GetProcAddress(hL, "__WSAFDIsSet");
		p[45] = GetProcAddress(hL, "getnetbyname");
		p[52] = GetProcAddress(hL, "getsockopt");
		p[56] = GetProcAddress(hL, "inet_network");
		p[67] = GetProcAddress(hL, "s_perror");
		p[72] = GetProcAddress(hL, "setsockopt");
	}

	if (reason == DLL_PROCESS_DETACH)
	{
		FreeLibrary(hL);
		return true;
	}

	return true;
}

extern "C"
{
	FARPROC PA = NULL;
	int RunASM();

	void PROXY_EnumProtocolsA() { p[1](); }
	void PROXY_EnumProtocolsW() { p[2](); }
	void PROXY_GetAddressByNameA() { p[4](); }
	void PROXY_GetAddressByNameW() { p[5](); }
	void PROXY_WEP() { p[17](); }
	void PROXY_WSARecvEx() { p[30](); }
	void PROXY___WSAFDIsSet() { p[36](); }
	void PROXY_getnetbyname() { p[45](); }
	void PROXY_getsockopt() { p[52](); }
	void PROXY_inet_network() { p[56](); }
	void PROXY_s_perror() { p[67](); }
	void PROXY_setsockopt() { p[72](); }
}
