#include "util/version.h"
#include "pch.h"
#include "ns_version.h"
#include "dedicated/dedicated.h"

char version[16];
char NSUserAgent[256];

void InitialiseVersion()
{
	constexpr int northstar_version[4] {NORTHSTAR_VERSION};
	int ua_len = 0;

	// We actually use the rightmost integer do determine whether or not we're a debug/dev build
	// If it is set to 1, we are a dev build
	// On github CI, we set this 1 to a 0 automatically as we replace the 0,0,0,1 with the real version number
	if (northstar_version[3] == 1)
	{
		sprintf(version, "%d.%d.%d.%d+dev", northstar_version[0], northstar_version[1], northstar_version[2], northstar_version[3]);
		ua_len += snprintf(
			NSUserAgent + ua_len,
			sizeof(NSUserAgent) - ua_len,
			"R2Northstar/%d.%d.%d+dev",
			northstar_version[0],
			northstar_version[1],
			northstar_version[2]);
	}
	else
	{
		sprintf(version, "%d.%d.%d.%d", northstar_version[0], northstar_version[1], northstar_version[2], northstar_version[3]);
		ua_len += snprintf(
			NSUserAgent + ua_len,
			sizeof(NSUserAgent) - ua_len,
			"R2Northstar/%d.%d.%d",
			northstar_version[0],
			northstar_version[1],
			northstar_version[2]);
	}

	if (IsDedicatedServer())
		ua_len += snprintf(NSUserAgent + ua_len, sizeof(NSUserAgent) - ua_len, " (Dedicated)");

	// Add the host platform info to the user agent.
	//
	// note: ntdll will always be loaded
	HMODULE ntdll = GetModuleHandleA("ntdll");
	if (ntdll)
	{
		// real win32 version info (i.e., ignore manifest)
		DWORD(WINAPI * RtlGetVersion)(LPOSVERSIONINFOEXW);
		*(FARPROC*)(&RtlGetVersion) = GetProcAddress(ntdll, "RtlGetVersion");

		// wine version (7.0-rc1, 7.0, 7.11, etc)
		const char*(CDECL * wine_get_version)(void);
		*(FARPROC*)(&wine_get_version) = GetProcAddress(ntdll, "wine_get_version");

		// human-readable build string (e.g., "wine-7.22 (Staging)")
		const char*(CDECL * wine_get_build_id)(void);
		*(FARPROC*)(&wine_get_build_id) = GetProcAddress(ntdll, "wine_get_build_id");

		// uname sysname (Darwin, Linux, etc) and release (kernel version string)
		void(CDECL * wine_get_host_version)(const char** sysname, const char** release);
		*(FARPROC*)(&wine_get_host_version) = GetProcAddress(ntdll, "wine_get_host_version");

		OSVERSIONINFOEXW osvi = {};
		const char *wine_version = NULL, *wine_build_id = NULL, *wine_sysname = NULL, *wine_release = NULL;
		if (RtlGetVersion)
			RtlGetVersion(&osvi);
		if (wine_get_version)
			wine_version = wine_get_version();
		if (wine_get_build_id)
			wine_build_id = wine_get_build_id();
		if (wine_get_host_version)
			wine_get_host_version(&wine_sysname, &wine_release);

		// windows version
		if (osvi.dwMajorVersion)
			ua_len += snprintf(
				NSUserAgent + ua_len,
				sizeof(NSUserAgent) - ua_len,
				" Windows/%d.%d.%d",
				osvi.dwMajorVersion,
				osvi.dwMinorVersion,
				osvi.dwBuildNumber);

		// wine version
		if (wine_version && wine_build_id)
			ua_len += snprintf(NSUserAgent + ua_len, sizeof(NSUserAgent) - ua_len, " Wine/%s (%s)", wine_version, wine_build_id);

		// wine host system version
		if (wine_sysname && wine_release)
			ua_len += snprintf(NSUserAgent + ua_len, sizeof(NSUserAgent) - ua_len, " %s/%s", wine_sysname, wine_release);
	}

	return;
}
