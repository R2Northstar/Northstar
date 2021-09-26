#include <Windows.h>
#include <TlHelp32.h>
#include <filesystem>
#include <sstream>
#include <iostream>

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

int main() {
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

    if (!GetProcessByName(L"Origin.exe"))
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
        while (!GetProcessByName(L"OriginClientService.exe"))
            Sleep(200);
    }

    STARTUPINFO startupInfo;
    PROCESS_INFORMATION processInfo;

    memset(&startupInfo, 0, sizeof(startupInfo));
    memset(&processInfo, 0, sizeof(processInfo));

    CreateProcessW(PROCESS_NAME, (wchar_t*)L" -multiple -novid", NULL, NULL, FALSE, CREATE_SUSPENDED, NULL, NULL, &startupInfo, &processInfo);

    HMODULE hKernel32 = GetModuleHandleW(L"kernel32.dll");
    LPTHREAD_START_ROUTINE pLoadLibraryW = (LPTHREAD_START_ROUTINE)GetProcAddress(hKernel32, "LoadLibraryW");

    SIZE_T dwLength = (wcslen(DLL_NAME) + 1) * 2;
    LPVOID lpLibName = VirtualAllocEx(processInfo.hProcess, NULL, dwLength, MEM_COMMIT, PAGE_READWRITE);

    SIZE_T written = 0;
    WriteProcessMemory(processInfo.hProcess, lpLibName, DLL_NAME, dwLength, &written);

    HANDLE hThread = CreateRemoteThread(processInfo.hProcess, NULL, NULL, pLoadLibraryW, lpLibName, NULL, NULL);
    WaitForSingleObject(hThread, INFINITE);

    MessageBoxA(0, std::to_string(GetLastError()).c_str(), "", MB_OK);

    CloseHandle(hThread);

    ResumeThread(processInfo.hThread);

    VirtualFreeEx(processInfo.hProcess, lpLibName, dwLength, MEM_RELEASE);

    CloseHandle(processInfo.hProcess);
    CloseHandle(processInfo.hThread);

    return 0;
}