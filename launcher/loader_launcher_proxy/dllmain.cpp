#include "pch.h"
#include <stdio.h>
#include <string>
#include <system_error>
#include <Shlwapi.h>
#include <sstream>
#include <fstream>
#include <filesystem>

HMODULE hLauncherModule;
HMODULE hHookModule;
HMODULE hTier0Module;

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

bool GetExePathWide(wchar_t* dest, DWORD destSize)
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
    char text[4096];
    std::string message = std::system_category().message(dwMessageId);
    sprintf_s(text, "Failed to load the %ls at \"%ls\" (%lu):\n\n%hs", libName, location, dwMessageId, message.c_str());
    if (dwMessageId == 126 && std::filesystem::exists(location))
    {
        sprintf_s(text, "%s\n\nThe file at the specified location DOES exist, so this error indicates that one of its *dependencies* failed to be found.", text);
    }
    MessageBoxA(GetForegroundWindow(), text, "Northstar Launcher Proxy Error", 0);
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

bool ShouldLoadNorthstar()
{
    bool loadNorthstar = !strstr(GetCommandLineA(), "-vanilla");

    if (!loadNorthstar)
        return loadNorthstar;

    auto runNorthstarFile = std::ifstream("run_northstar.txt");
    if (runNorthstarFile)
    {
        std::stringstream runNorthstarFileBuffer;
        runNorthstarFileBuffer << runNorthstarFile.rdbuf();
        runNorthstarFile.close();
        if (runNorthstarFileBuffer.str()._Starts_with("0"))
            loadNorthstar = false;
    }
    return loadNorthstar;
}

bool LoadNorthstar()
{
    FARPROC Hook_Init = nullptr;
    {
        swprintf_s(dllPath, L"%s\\Northstar.dll", exePath);
        hHookModule = LoadLibraryExW(dllPath, 0, LOAD_WITH_ALTERED_SEARCH_PATH);
        if (hHookModule) Hook_Init = GetProcAddress(hHookModule, "InitialiseNorthstar");
        if (!hHookModule || Hook_Init == nullptr)
        {
            LibraryLoadError(GetLastError(), L"Northstar.dll", dllPath);
            return false;
        }
    }

    ((bool (*)()) Hook_Init)();
    return true;
}

extern "C" __declspec(dllexport) int LauncherMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
    {
        if (!GetExePathWide(exePath, 4096))
        {
            MessageBoxA(GetForegroundWindow(), "Failed getting game directory.\nThe game cannot continue and has to exit.", "Northstar Launcher Proxy Error", 0);
            return 1;
        }

        bool loadNorthstar = ShouldLoadNorthstar();

        if (loadNorthstar)
        {
            swprintf_s(dllPath, L"%s\\bin\\x64_retail\\tier0.dll", exePath);
            hTier0Module = LoadLibraryExW(dllPath, 0, LOAD_WITH_ALTERED_SEARCH_PATH);
            if (!hTier0Module)
            {
                LibraryLoadError(GetLastError(), L"tier0.dll", dllPath);
                return 1;
            }

            if (!LoadNorthstar())
                return 1;
        }
        //else printf("\n\n WILL !!!NOT!!! LOAD NORTHSTAR\n\n");

        swprintf_s(dllPath, L"%s\\bin\\x64_retail\\launcher.org.dll", exePath);
        hLauncherModule = LoadLibraryExW(dllPath, 0, LOAD_WITH_ALTERED_SEARCH_PATH);
        if (!hLauncherModule)
        {
            LibraryLoadError(GetLastError(), L"launcher.org.dll", dllPath);
            return 1;
        }
    }

    auto LauncherMain = GetLauncherMain();
    if (!LauncherMain)
        MessageBoxA(GetForegroundWindow(), "Failed loading launcher.org.dll.\nThe game cannot continue and has to exit.", "Northstar Launcher Proxy Error", 0);
    //auto result = ((__int64(__fastcall*)())LauncherMain)();
    //auto result = ((signed __int64(__fastcall*)(__int64))LauncherMain)(0i64);
    return ((int(__fastcall*)(HINSTANCE, HINSTANCE, LPSTR, int))LauncherMain)(hInstance, hPrevInstance, lpCmdLine, nCmdShow);
}

// doubt that will help us here (in launcher.dll) though
extern "C" {
    __declspec(dllexport) DWORD AmdPowerXpressRequestHighPerformance = 0x00000001;
    __declspec(dllexport) DWORD NvOptimusEnablement = 0x00000001;
}
