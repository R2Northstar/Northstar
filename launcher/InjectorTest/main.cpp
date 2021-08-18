#include <Windows.h>

#define PROC_NAME L"Titanfall2-unpacked.exe"
#define DLL_NAME L"Northstar.dll"

int main() {
    STARTUPINFO startupInfo;
    PROCESS_INFORMATION processInfo;

    memset(&startupInfo, 0, sizeof(startupInfo));
    memset(&processInfo, 0, sizeof(processInfo));

    CreateProcessW(PROC_NAME, (LPWSTR)L"-multiple -novid", NULL, NULL, FALSE, CREATE_SUSPENDED, NULL, NULL, &startupInfo, &processInfo);

    HMODULE hKernel32 = GetModuleHandleW(L"kernel32.dll");
    LPTHREAD_START_ROUTINE pLoadLibraryW =
        (LPTHREAD_START_ROUTINE)GetProcAddress(hKernel32, "LoadLibraryW");

    SIZE_T dwLength = (wcslen(DLL_NAME) + 1) * 2;
    LPVOID lpLibName = VirtualAllocEx(processInfo.hProcess, NULL, dwLength, MEM_COMMIT, PAGE_READWRITE);

    SIZE_T written = 0;
    WriteProcessMemory(processInfo.hProcess, lpLibName, DLL_NAME, dwLength, &written);

    HANDLE hThread = CreateRemoteThread(processInfo.hProcess, NULL, NULL, pLoadLibraryW, lpLibName, NULL, NULL);
    WaitForSingleObject(hThread, INFINITE);
    CloseHandle(hThread);

    // TODO: need to call initialisenorthstar in the new process
    // also rewrite injector to be clean lol
    // (this does not currently work!!! )
    //LPTHREAD_START_ROUTINE pInitNorthstar = (LPTHREAD_START_ROUTINE)GetProcAddress((HMODULE)lpLibName, "InitialiseNorthstar");
    //HANDLE hInitThread = CreateRemoteThread(processInfo.hProcess, NULL, NULL, pInitNorthstar, NULL, NULL, NULL);
    //WaitForSingleObject(hInitThread, INFINITE);
    //CloseHandle(hInitThread);
    
    ResumeThread(processInfo.hThread);

    VirtualFreeEx(processInfo.hProcess, lpLibName, dwLength, MEM_RELEASE);

    CloseHandle(processInfo.hProcess);
    CloseHandle(processInfo.hThread);

    return 0;
}

/*
#define DEFAULT_PROCESS_NAME = L"Titanfall2.exe"

int main(int argc, char** argv)
{
    STARTUPINFO startupInfo;
    PROCESS_INFORMATION processInfo;

    memset(&startupInfo, 0, sizeof(startupInfo));
    memset(&processInfo, 0, sizeof(processInfo));
    
    LPCWSTR processName;
    if (argc > 0)
    {
        processName = *argv;
    }
    else
        processName = DEFAULT_PROCESS_NAME;

    CreateProcessW()
}
*/