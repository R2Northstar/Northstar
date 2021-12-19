#include <Windows.h>
#include <TlHelp32.h>
#include <filesystem>
#include <sstream>
#include <iostream>
#include <fstream>

namespace fs = std::filesystem;

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

#define PROCESS_NAME L"Titanfall2-unpacked.exe"
#define DLL_NAME L"Northstar.dll"

int main(int argc, char* argv[]) {
    if (!fs::exists(PROCESS_NAME))
    {
        MessageBoxA(0, "Titanfall2-unpacked.exe not found! Please launch from your titanfall 2 directory and ensure you have Northstar installed correctly!", "", MB_OK);
        return 1;
    }

    if (!fs::exists(DLL_NAME))
    {
        MessageBoxA(0, "Northstar.dll not found! Please launch from your titanfall 2 directory and ensure you have Northstar installed correctly!", "", MB_OK);
        return 1;
    }

    bool isdedi = false;
    for (int i = 0; i < argc; i++)
        if (!strcmp(argv[i], "-dedicated"))
            isdedi = true;

    if (!isdedi && !GetProcessByName(L"Origin.exe") && !GetProcessByName(L"EADesktop.exe"))
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
        CreateProcessA(originPath, (LPSTR)"", NULL, NULL, false, CREATE_DEFAULT_ERROR_MODE | CREATE_NEW_PROCESS_GROUP, NULL, NULL, (LPSTARTUPINFOA)&si, &pi);

        // wait for origin to be ready, this process is created when origin is ready enough to launch game without any errors
        while (!GetProcessByName(L"OriginClientService.exe") && !GetProcessByName(L"EADesktop.exe"))
            Sleep(200);
    }

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

    if (!isdedi)
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

    //if (isdedi)
    //    // copy -dedicated into args if we have it in commandline args
    //    args.append(L" -dedicated");

    STARTUPINFO startupInfo;
    PROCESS_INFORMATION processInfo;

    memset(&startupInfo, 0, sizeof(startupInfo));
    memset(&processInfo, 0, sizeof(processInfo));

    CreateProcessW(PROCESS_NAME, (LPWSTR)args.c_str(), NULL, NULL, FALSE, CREATE_SUSPENDED, NULL, NULL, &startupInfo, &processInfo);

    HMODULE hKernel32 = GetModuleHandleW(L"kernel32.dll");
    LPTHREAD_START_ROUTINE pLoadLibraryW = (LPTHREAD_START_ROUTINE)GetProcAddress(hKernel32, "LoadLibraryW");

    SIZE_T dwLength = (wcslen(DLL_NAME) + 1) * 2;
    LPVOID lpLibName = VirtualAllocEx(processInfo.hProcess, NULL, dwLength, MEM_COMMIT, PAGE_READWRITE);

    SIZE_T written = 0;
    WriteProcessMemory(processInfo.hProcess, lpLibName, DLL_NAME, dwLength, &written);

    HANDLE hThread = CreateRemoteThread(processInfo.hProcess, NULL, NULL, pLoadLibraryW, lpLibName, NULL, NULL);

    if (hThread == NULL)
    {
        // injection failed

        std::string errorMessage = "Injection failed! CreateRemoteThread returned ";
        errorMessage += std::to_string(GetLastError()).c_str();
        errorMessage += ", make sure bob hasn't accidentally shipped a debug build";

        MessageBoxA(0, errorMessage.c_str(), "", MB_OK);
        return 0;
    }

    WaitForSingleObject(hThread, INFINITE);

    //MessageBoxA(0, std::to_string(GetLastError()).c_str(), "", MB_OK);

    CloseHandle(hThread);

    ResumeThread(processInfo.hThread);

    VirtualFreeEx(processInfo.hProcess, lpLibName, dwLength, MEM_RELEASE);

    CloseHandle(processInfo.hProcess);
    CloseHandle(processInfo.hThread);

    return 0;
}