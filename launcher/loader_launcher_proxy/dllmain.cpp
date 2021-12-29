#include "pch.h"
#include <stdio.h>
#include <string>
#include <system_error>
#include <Shlwapi.h>

HMODULE hLauncherModule;
HMODULE hHookModule;

using CreateInterfaceFn = void* (*)(const char* pName, int* pReturnCode);

// does not seem to ever be used
extern "C" _declspec(dllexport) void* __fastcall CreateInterface(const char* pName, int* pReturnCode)
{
    //AppSystemCreateInterfaceFn(pName, pReturnCode);
    printf("external CreateInterface: name: %s\n", pName);

    static CreateInterfaceFn launcher_CreateInterface = (CreateInterfaceFn)GetProcAddress(hLauncherModule, "CreateInterface");
    auto res = launcher_CreateInterface(pName, pReturnCode);

    printf("external CreateInterface: return code: %p\n", res);
    return res;
}

bool GetExePathWide(wchar_t* dest, size_t destSize)
{
    if (!dest) return NULL;
    if (destSize < MAX_PATH) return NULL;

    DWORD length = GetModuleFileNameW(NULL, dest, destSize);
    return length && PathRemoveFileSpecW(dest);
}

FARPROC GetLauncherMain()
{
    static FARPROC Launcher_LauncherMain;
    if (!Launcher_LauncherMain)
        Launcher_LauncherMain = GetProcAddress(hLauncherModule, "LauncherMain");
    return Launcher_LauncherMain;
}

void LibraryLoadError(DWORD dwMessageId, const wchar_t* libName, const wchar_t* location)
{
    char text[2048];
    std::string message = std::system_category().message(dwMessageId); 
    sprintf_s(text, "Failed to load the %ls at \"%ls\" (%lu):\n\n%hs", libName, location, dwMessageId, message.c_str());
    MessageBoxA(GetForegroundWindow(), text, "Launcher Error", 0);
}

BOOL APIENTRY DllMain( HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
                     )
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
    case DLL_THREAD_ATTACH:
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }
    return TRUE;
}

wchar_t exePath[4096];
wchar_t dllPath[4096];

extern "C" _declspec(dllexport) void LauncherMain(__int64, __int64, __int64, uint32_t)
{
    {

        if (!GetExePathWide(exePath, 4096))
        {
            MessageBoxA(GetForegroundWindow(), "Failed getting game directory.\nThe game cannot continue and has to exit.", "Launcher Error", 0);
            return;
        }

        FARPROC Hook_Init = nullptr;
        {
            swprintf_s(dllPath, L"%s\\Northstar.dll", exePath);
            hHookModule = LoadLibraryExW(dllPath, 0i64, 8u);
            if (hHookModule) Hook_Init = GetProcAddress(hHookModule, "InitialiseNorthstar");
            if (!hHookModule || Hook_Init == nullptr)
            {
                LibraryLoadError(GetLastError(), L"Northstar.dll", dllPath);
                return;
            }
        }

        ((void (*)()) Hook_Init)();
    }

    {
        swprintf_s(dllPath, L"%s\\bin\\x64_retail\\launcher.org.dll", exePath);
        hLauncherModule = LoadLibraryExW(dllPath, 0i64, 8u);
        if (!hLauncherModule)
        {
            LibraryLoadError(GetLastError(), L"launcher.org.dll", dllPath);
            return;
        }
    }

    auto LauncherMain = GetLauncherMain();
    //auto result = ((__int64(__fastcall*)())LauncherMain)();
    //auto result = ((signed __int64(__fastcall*)(__int64))LauncherMain)(0i64);
    auto result = ((signed __int64(__fastcall*)(__int64, __int64, __int64, uint32_t))LauncherMain)(0i64, 0i64, 0i64, 0);
}

// doubt that will help us here (in launcher.dll) though
extern "C" {
    __declspec(dllexport) DWORD AmdPowerXpressRequestHighPerformance = 0x00000001;
    __declspec(dllexport) DWORD NvOptimusEnablement = 0x00000001;
}
