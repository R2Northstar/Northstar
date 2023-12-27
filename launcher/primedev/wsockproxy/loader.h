#pragma once

extern wchar_t exePath[4096];
extern wchar_t buffer1[8192];
extern wchar_t buffer2[12288];

void LibraryLoadError(DWORD dwMessageId, const wchar_t* libName, const wchar_t* location);
bool ShouldLoadNorthstar();
bool ProvisionNorthstar();
