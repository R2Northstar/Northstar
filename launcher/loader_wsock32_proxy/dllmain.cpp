#include "pch.h"
#include "loader.h"

#include <Shlwapi.h>
#include <filesystem>

HINSTANCE hLThis = 0;
FARPROC p[857];
HINSTANCE hL = 0;

bool GetExePathWide(wchar_t* dest, DWORD destSize)
{
	if (!dest) return NULL;
	if (destSize < MAX_PATH) return NULL;

	DWORD length = GetModuleFileNameW(NULL, dest, destSize);
	return length && PathRemoveFileSpecW(dest);
}

wchar_t exePath[4096];
wchar_t buffer1[8192];
wchar_t buffer2[12288];

BOOL WINAPI DllMain(HINSTANCE hInst, DWORD reason, LPVOID)
{
	if (reason == DLL_PROCESS_ATTACH)
	{
		hLThis = hInst;

		if (!GetExePathWide(exePath, 4096))
		{
			MessageBoxA(GetForegroundWindow(), "Failed getting game directory.\nThe game cannot continue and has to exit.", "Northstar Wsock32 Proxy Error", 0);
			return true;
		}

		if (!ProvisionNorthstar()) // does not call InitialiseNorthstar yet, will do it on LauncherMain hook
			return true;

		// copy the original library for system to our local directory, with changed name so that we can load it
		swprintf_s(buffer1, L"%s\\bin\\x64_retail\\wsock32.org.dll", exePath);
		GetSystemDirectoryW(buffer2, 4096);
		swprintf_s(buffer2, L"%s\\wsock32.dll", buffer2);
		try
		{
			std::filesystem::copy_file(buffer2, buffer1);
		}
		catch (const std::exception& e1)
		{
			if (!std::filesystem::exists(buffer1))
			{
				// fallback by copying to temp dir...
				// because apparently games installed by EA Desktop app don't have write permissions in their directories
				auto temp_dir = std::filesystem::temp_directory_path() / L"wsock32.org.dll";
				try
				{
					std::filesystem::copy_file(buffer2, temp_dir);
				}
				catch (const std::exception& e2)
				{
					if (!std::filesystem::exists(temp_dir))
					{
						swprintf_s(buffer2, L"Failed copying wsock32.dll from system32 to \"%s\"\n\n%S\n\nFurthermore, we failed copying wsock32.dll into temporary directory at \"%s\"\n\n%S", buffer1, e1.what(), temp_dir.c_str(), e2.what());
						MessageBoxW(GetForegroundWindow(), buffer2, L"Northstar Wsock32 Proxy Error", 0);
						return false;
					}
				}
				swprintf_s(buffer1, L"%s", temp_dir.c_str());
			}
		}
		hL = LoadLibraryExW(buffer1, 0, LOAD_WITH_ALTERED_SEARCH_PATH);
		if (!hL) {
			LibraryLoadError(GetLastError(), L"wsock32.org.dll", buffer1);
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

	void PROXY_EnumProtocolsA() {
		PA = p[1];
		RunASM();
	}
	void PROXY_EnumProtocolsW() {
		PA = p[2];
		RunASM();
	}
	void PROXY_GetAddressByNameA() {
		PA = p[4];
		RunASM();
	}
	void PROXY_GetAddressByNameW() {
		PA = p[5];
		RunASM();
	}
	void PROXY_WEP() {
		PA = p[17];
		RunASM();
	}
	void PROXY_WSARecvEx() {
		PA = p[30];
		RunASM();
	}
	void PROXY___WSAFDIsSet() {
		PA = p[36];
		RunASM();
	}
	void PROXY_getnetbyname() {
		PA = p[45];
		RunASM();
	}
	void PROXY_getsockopt() {
		PA = p[52];
		RunASM();
	}
	void PROXY_inet_network() {
		PA = p[56];
		RunASM();
	}
	void PROXY_s_perror() {
		PA = p[67];
		RunASM();
	}
	void PROXY_setsockopt() {
		PA = p[72];
		RunASM();
	}
}