// dllmain.cpp : Defines the entry point for the DLL application.

#include "pch.h"
#include "MinHook.h"
#include <string>
#include <sstream>
#include <filesystem>
#include <iostream>
#include <iomanip>

#define DLL_NAME L"Northstar.dll"

typedef BOOL(WINAPI *CreateProcessWType)(
    LPCWSTR               lpApplicationName,
    LPWSTR                lpCommandLine,
    LPSECURITY_ATTRIBUTES lpProcessAttributes,
    LPSECURITY_ATTRIBUTES lpThreadAttributes,
    BOOL                  bInheritHandles,
    DWORD                 dwCreationFlags,
    LPVOID                lpEnvironment,
    LPCWSTR               lpCurrentDirectory,
    LPSTARTUPINFOW        lpStartupInfo,
    LPPROCESS_INFORMATION lpProcessInformation
);
CreateProcessWType CreateProcessWOriginal;

HMODULE ownHModule;
std::filesystem::path tf2DirPath;

BOOL WINAPI CreateProcessWHook(
    LPCWSTR               lpApplicationName,
    LPWSTR                lpCommandLine,
    LPSECURITY_ATTRIBUTES lpProcessAttributes,
    LPSECURITY_ATTRIBUTES lpThreadAttributes,
    BOOL                  bInheritHandles,
    DWORD                 dwCreationFlags,
    LPVOID                lpEnvironment,
    LPCWSTR               lpCurrentDirectory,
    LPSTARTUPINFOW        lpStartupInfo,
    LPPROCESS_INFORMATION lpProcessInformation
)
{
    bool isTitanfallProcess = false;

    // origin doesn't use lpApplicationName
    if (lpApplicationName)
    {
        std::wcout << lpApplicationName << std::endl;
        isTitanfallProcess = wcsstr(lpApplicationName, L"Titanfall2\\Titanfall2.exe");
    }
    else
    {
        std::wcout << lpCommandLine << std::endl;
        isTitanfallProcess = wcsstr(lpCommandLine, L"Titanfall2\\Titanfall2.exe");
    }

    // steam will start processes suspended
    bool alreadySuspended = dwCreationFlags & CREATE_SUSPENDED;

    // suspend process on creation so we can hook
    if (isTitanfallProcess && !alreadySuspended)
        dwCreationFlags |= CREATE_SUSPENDED;

    BOOL ret = CreateProcessWOriginal(lpApplicationName, lpCommandLine, lpProcessAttributes, lpThreadAttributes, bInheritHandles, dwCreationFlags, lpEnvironment, lpCurrentDirectory, lpStartupInfo, lpProcessInformation);

    if (isTitanfallProcess)
    {
        std::cout << "Creating titanfall process!" << std::endl;
        std::cout << "Handle: " << lpProcessInformation->hProcess << " ID: " << lpProcessInformation->dwProcessId << " Thread: " << lpProcessInformation->hThread << std::endl;

        STARTUPINFO si;
        memset(&si, 0, sizeof(si));
        PROCESS_INFORMATION pi;
        memset(&pi, 0, sizeof(pi));

        std::stringstream argStr;
        argStr << lpProcessInformation->dwProcessId;
        argStr << " ";
        argStr << lpProcessInformation->dwThreadId;

        CreateProcessA((tf2DirPath / "InjectionProxy64.exe").string().c_str(), (LPSTR)(argStr.str().c_str()), 0, 0, false, 0, 0, tf2DirPath.string().c_str(), (LPSTARTUPINFOA)&si, &pi);
        WaitForSingleObject(pi.hThread, INFINITE);

        if (!alreadySuspended)
            ResumeThread(lpProcessInformation->hThread);

        MH_RemoveHook(&CreateProcessW);
        FreeLibrary(ownHModule);
    }


    return ret;
}

BOOL APIENTRY DllMain(HMODULE hModule,
                       DWORD  ul_reason_for_call,
                       LPVOID lpReserved
                     )
{
    switch (ul_reason_for_call)
    {
    case DLL_PROCESS_ATTACH:
    case DLL_THREAD_ATTACH:
        //DisableThreadLibraryCalls(hModule);
    case DLL_THREAD_DETACH:
    case DLL_PROCESS_DETACH:
        break;
    }

    //AllocConsole();
    //freopen("CONOUT$", "w", stdout);

    ownHModule = hModule;
    char ownDllPath[MAX_PATH];
    GetModuleFileNameA(hModule, ownDllPath, MAX_PATH);

    tf2DirPath = std::filesystem::path(ownDllPath).parent_path();

    //AllocConsole();
    //freopen("CONOUT$", "w", stdout);

    // hook CreateProcessW
    if (MH_Initialize() > MH_ERROR_ALREADY_INITIALIZED) // MH_ERROR_ALREADY_INITIALIZED = 1, MH_OK = 0, these are the only results we should expect
        return TRUE;
    
    MH_CreateHook(&CreateProcessW, &CreateProcessWHook, reinterpret_cast<LPVOID*>(&CreateProcessWOriginal));
    MH_EnableHook(&CreateProcessW);

    return TRUE;
}

