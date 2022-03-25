#include "version.h"
#include "pch.h"

char version[16];
char NSUserAgent[32];

void InitialiseVersion() {
	HRSRC hResInfo;
	DWORD dwSize;
	HGLOBAL hResData;
	LPVOID pRes, pResCopy;
	UINT uLen = 0;
	VS_FIXEDFILEINFO* lpFfi = NULL;
	HINSTANCE hInst = ::GetModuleHandle(NULL);

	hResInfo = FindResourceW(hInst, MAKEINTRESOURCE(1), RT_VERSION);
	if (hResInfo != NULL) {
		dwSize = SizeofResource(hInst, hResInfo);
		hResData = LoadResource(hInst, hResInfo);
		if (hResData != NULL) {
			pRes = LockResource(hResData);
			pResCopy = LocalAlloc(LMEM_FIXED, dwSize);
			if (pResCopy != 0) {
				CopyMemory(pResCopy, pRes, dwSize);
				VerQueryValueW(pResCopy, L"\\", (LPVOID*)&lpFfi, &uLen);

				DWORD dwFileVersionMS = lpFfi->dwFileVersionMS;
				DWORD dwFileVersionLS = lpFfi->dwFileVersionLS;

				DWORD dwLeftMost = HIWORD(dwFileVersionMS);
				DWORD dwSecondLeft = LOWORD(dwFileVersionMS);
				DWORD dwSecondRight = HIWORD(dwFileVersionLS);
				DWORD dwRightMost = LOWORD(dwFileVersionLS);

				// We actually use the rightmost integer do determine whether or not we're a debug/dev build
				// If it is set to 1 (as in resources.rc), we are a dev build
				// On github CI, we set this 1 to a 0 automatically as we replace the 0.0.0.1 with the real version number
				if (dwRightMost == 1) {
					sprintf(version, "%d.%d.%d.%d+dev", dwLeftMost, dwSecondLeft, dwSecondRight, dwRightMost);
					sprintf(NSUserAgent, "R2Northstar/%d.%d.%d+dev", dwLeftMost, dwSecondLeft, dwSecondRight);
				}
				else {
					sprintf(version, "%d.%d.%d.%d", dwLeftMost, dwSecondLeft, dwSecondRight, dwRightMost);
					sprintf(NSUserAgent, "R2Northstar/%d.%d.%d", dwLeftMost, dwSecondLeft, dwSecondRight);
				}
				UnlockResource(hResData);
				FreeResource(hResData);
				LocalFree(pResCopy);
				return;
			}
			UnlockResource(hResData);
			FreeResource(hResData);
			LocalFree(pResCopy);
		}
	}
	// Could not locate version info for whatever reason
	spdlog::error("Failed to load version info:\n{}", std::system_category().message(GetLastError()));
	sprintf(NSUserAgent, "R2Northstar/0.0.0");
}
