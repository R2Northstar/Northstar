// dllmain.cpp : Defines the entry point for the DLL application.

#include "pch.h"
#include "MinHook.h"
#include <string>
#include <sstream>
#include <filesystem>
#include <iostream>
#include <iomanip>

#define DLL_NAME L"Northstar.dll"

class TempReadWrite
{
private:
    DWORD m_origProtection;
    void* m_ptr;

public:
    TempReadWrite(void* ptr)
    {
        m_ptr = ptr;
        MEMORY_BASIC_INFORMATION mbi;
        VirtualQuery(m_ptr, &mbi, sizeof(mbi));
        VirtualProtect(mbi.BaseAddress, mbi.RegionSize, PAGE_EXECUTE_READWRITE, &mbi.Protect);
        m_origProtection = mbi.Protect;
    }    

    ~TempReadWrite()
    {
        MEMORY_BASIC_INFORMATION mbi;
        VirtualQuery(m_ptr, &mbi, sizeof(mbi));
        VirtualProtect(mbi.BaseAddress, mbi.RegionSize, m_origProtection, &mbi.Protect);
    }
};

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
    std::wcout << lpCommandLine << std::endl;
    isTitanfallProcess = wcsstr(lpCommandLine, L"Titanfall2\\Titanfall2.exe");

    // steam will start processes suspended (since we don't actually inject into steam directly this isn't required anymore, but whatever)
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

        // check if we're launching EASteamProxy for steam users, or just launching tf2 directly for origin users
        // note: atm we fully disable steam integration in origin when we inject, return to this later
        if (!wcsstr(lpApplicationName, L"Origin\\EASteamProxy.exe"))
        {
            std::stringstream argStr;
            argStr << lpProcessInformation->dwProcessId;
            argStr << " ";
            argStr << lpProcessInformation->dwThreadId;

            CreateProcessA((tf2DirPath / "InjectionProxy64.exe").string().c_str(), (LPSTR)(argStr.str().c_str()), 0, 0, false, 0, 0, tf2DirPath.string().c_str(), (LPSTARTUPINFOA)&si, &pi);
            WaitForSingleObject(pi.hThread, INFINITE);
        }
        else
        {
            // for easteamproxy, we have to inject ourself into it
            // todo: atm we fully disable steam integration in origin when we inject, do this properly later
        }

        // this doesn't seem to work super well
        //if (!alreadySuspended)
        ResumeThread(lpProcessInformation->hThread);

        // cleanup
        MH_DisableHook(&CreateProcessW);
        MH_RemoveHook(&CreateProcessW);
        MH_Uninitialize();

        // allow steam integrations to work again
        void* ptr = (char*)GetModuleHandleA("OriginClient.dll") + 0x2A83FA;
        TempReadWrite rw(ptr);

        *((char*)ptr) = 0x0F; // jmp => je
        *((char*)ptr + 1) = 0x84;
        *((char*)ptr + 2) = 0xE5;
        *((char*)ptr + 3) = 0x01;
        *((char*)ptr + 4) = 0x00;
        *((char*)ptr + 5) = 0x00;

        // is this undefined behaviour? idk
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
        DisableThreadLibraryCalls(hModule);
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

    // hook CreateProcessW
    if (MH_Initialize() > MH_ERROR_ALREADY_INITIALIZED) // MH_ERROR_ALREADY_INITIALIZED = 1, MH_OK = 0, these are the only results we should expect
        return TRUE;
    
    MH_CreateHook(&CreateProcessW, &CreateProcessWHook, reinterpret_cast<LPVOID*>(&CreateProcessWOriginal));
    MH_EnableHook(&CreateProcessW);

    // TEMP: temporarily disable steam stuff because it's a huge pain
    // change conditional jump to EASteamProxy stuff in launchStep2 to never hit EASteamProxy launch
    void* ptr = (char*)GetModuleHandleA("OriginClient.dll") + 0x2A83FA;
    TempReadWrite rw(ptr);
    
    *((char*)ptr) = 0xE9; // je => jmp
    *((char*)ptr + 1) = 0xE6;
    *((char*)ptr + 2) = 0x01;
    *((char*)ptr + 3) = 0x00;
    *((char*)ptr + 4) = 0x00;

    return TRUE;
}

