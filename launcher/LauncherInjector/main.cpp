#define WIN32_LEAN_AND_MEAN
#include <Windows.h>
#include <TlHelp32.h>
#include <filesystem>
#include <sstream>
#include <iostream>
#include <fstream>
#include <Shlwapi.h>

namespace fs = std::filesystem;

extern "C" {
    __declspec(dllexport) DWORD AmdPowerXpressRequestHighPerformance = 0x00000001;
    __declspec(dllexport) DWORD NvOptimusEnablement = 0x00000001;
}

HMODULE hLauncherModule;
HMODULE hHookModule;

wchar_t exePath[4096];
wchar_t buffer[8196];

DWORD GetProcessByName(std::wstring processName)
{
    HANDLE snapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);

    PROCESSENTRY32 processSnapshotEntry = { 0 };
    processSnapshotEntry.dwSize = sizeof(PROCESSENTRY32);

    if (snapshot == INVALID_HANDLE_VALUE)
        return 0;

    if (!Process32First(snapshot, &processSnapshotEntry))
        return 0;

    while (Process32Next(snapshot, &processSnapshotEntry))
    {
        if (!wcscmp(processSnapshotEntry.szExeFile, processName.c_str()))
        {
            CloseHandle(snapshot);
            return processSnapshotEntry.th32ProcessID;
        }
    }

    CloseHandle(snapshot);
    return 0;
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
    char text[2048];
    std::string message = std::system_category().message(dwMessageId);
    sprintf_s(text, "Failed to load the %ls at \"%ls\" (%lu):\n\n%hs\n\nMake sure you followed the Northstar installation instructions carefully.", libName, location, dwMessageId, message.c_str());
    MessageBoxA(GetForegroundWindow(), text, "Launcher Error", 0);
}

int main(int argc, char* argv[]) {

    // checked to avoid starting origin, Northstar.dll will check for -dedicated as well on its own
    bool isDedicated = false;
    for (int i = 0; i < argc; i++)
        if (!strcmp(argv[i], "-dedicated"))
            isDedicated = true;

    bool noOriginStartup = false;
    for (int i = 0; i < argc; i++)
        if (!strcmp(argv[i], "-noOriginStartup"))
            noOriginStartup = true;

    if (!isDedicated && !GetProcessByName(L"Origin.exe") && !GetProcessByName(L"EADesktop.exe") && !noOriginStartup)
    {
        // unpacked exe will crash if origin isn't open on launch, so launch it
        // get origin path from registry, code here is reversed from OriginSDK.dll
        HKEY key;
        if (RegOpenKeyExA(HKEY_LOCAL_MACHINE, "SOFTWARE\\WOW6432Node\\Origin", 0, KEY_READ, &key) != ERROR_SUCCESS)
        {
            MessageBoxA(0, "Error: failed reading origin path!", "", MB_OK);
            return 1;
        }

        char originPath[520];
        DWORD originPathLength = 520;
        if (RegQueryValueExA(key, "ClientPath", 0, 0, (LPBYTE)&originPath, &originPathLength) != ERROR_SUCCESS)
        {
            MessageBoxA(0, "Error: failed reading origin path!", "", MB_OK);
            return 1;
        }

        PROCESS_INFORMATION pi;
        memset(&pi, 0, sizeof(pi));
        STARTUPINFO si;
        memset(&si, 0, sizeof(si));
        CreateProcessA(originPath, (char*)"", NULL, NULL, false, CREATE_DEFAULT_ERROR_MODE | CREATE_NEW_PROCESS_GROUP, NULL, NULL, (LPSTARTUPINFOA)&si, &pi);

        // wait for origin to be ready, this process is created when origin is ready enough to launch game without any errors
        while (!GetProcessByName(L"OriginClientService.exe") && !GetProcessByName(L"EADesktop.exe"))
            Sleep(200);

        CloseHandle(pi.hProcess);
        CloseHandle(pi.hThread);
    }

#if 0
    // TODO: MOVE TO Northstar.dll itself and inject in some place
    // for example hook GetCommandLineA() before real LauncherMain gets called (ie. during InitialiseNorthstar)
    // GetCommandLineA() is always used, the parameters passed to LauncherMain are basically ignored
    // get cmdline args from file
    std::wstring args;
    std::ifstream cmdlineArgFile;

    args.append(L" ");
    for (int i = 0; i < argc; i++)
    {
        std::string str = argv[i];

        args.append(std::wstring(str.begin(), str.end()));
        args.append(L" ");
    }

    if (!isDedi)
        cmdlineArgFile = std::ifstream("ns_startup_args.txt");
    else
        cmdlineArgFile = std::ifstream("ns_startup_args_dedi.txt");

    if (cmdlineArgFile)
    {
        std::stringstream argBuffer;
        argBuffer << cmdlineArgFile.rdbuf();
        cmdlineArgFile.close();
    
        std::string str = argBuffer.str();
        args.append(std::wstring(str.begin(), str.end()));
    }

    //if (isDedicated)
    //    // copy -dedicated into args if we have it in commandline args
    //    args.append(L" -dedicated");
#endif

    //

    bool loadNorthstar = true;
    for (int i = 0; i < argc; i++)
        if (!strcmp(argv[i], "-vanilla"))
            loadNorthstar = false;

    {

        if (!GetExePathWide(exePath, 4096))
        {
            MessageBoxA(GetForegroundWindow(), "Failed getting game directory.\nThe game cannot continue and has to exit.", "Launcher Error", 0);
            return 1;
        }

        {
            wchar_t* pPath;
            size_t len;
            errno_t err = _wdupenv_s(&pPath, &len, L"PATH");
            if (!err)
            {
                swprintf_s(buffer, L"PATH=%s\\bin\\x64_retail\\;%s", exePath, pPath);
                auto result = _wputenv(buffer);
                if (result == -1)
                {
                    MessageBoxW(GetForegroundWindow(), L"Warning: could not prepend the current directory to app's PATH environment variable. Something may break because of that.", L"Launcher Warning", 0);
                }
                free(pPath);
            }
            else
            {
                MessageBoxW(GetForegroundWindow(), L"Warning: could not get current PATH environment variable in order to prepend the current directory to it. Something may break because of that.", L"Launcher Warning", 0);
            }
        }

        if (loadNorthstar)
        {
            FARPROC Hook_Init = nullptr;
            {
                swprintf_s(buffer, L"%s\\Northstar.dll", exePath);
                hHookModule = LoadLibraryExW(buffer, 0i64, 8u);
                if (hHookModule) Hook_Init = GetProcAddress(hHookModule, "InitialiseNorthstar");
                if (!hHookModule || Hook_Init == nullptr)
                {
                    LibraryLoadError(GetLastError(), L"Northstar.dll", buffer);
                    return 1;
                }
            }

            ((bool (*)()) Hook_Init)();
        }

        swprintf_s(buffer, L"%s\\bin\\x64_retail\\launcher.dll", exePath);
        hLauncherModule = LoadLibraryExW(buffer, 0i64, 8u);
        if (!hLauncherModule)
        {
            LibraryLoadError(GetLastError(), L"launcher.dll", buffer);
            return 1;
        }
    }

    auto LauncherMain = GetLauncherMain();
    if (!LauncherMain)
        MessageBoxA(GetForegroundWindow(), "Failed loading launcher.dll.\nThe game cannot continue and has to exit.", "Launcher Error", 0);
    //auto result = ((__int64(__fastcall*)())LauncherMain)();
    //auto result = ((signed __int64(__fastcall*)(__int64))LauncherMain)(0i64);
    return ((int(__fastcall*)(HINSTANCE, HINSTANCE, LPSTR, int))LauncherMain)(NULL, NULL, NULL, 0); // the parameters aren't really used anyways
}