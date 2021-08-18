#include <string>
#include <Windows.h>

#define DLL_NAME L"Northstar.dll"

int main(int argc, char** argv)
{
    // this a proxy process used for injecting into titanfall, since launchers are 32bit you can't inject from those into 64bit titanfall
	// dont bother to do any error checking here, just assume it's getting called right
    DWORD pid = std::stoi(argv[0]);
    DWORD threadId = std::stoi(argv[1]);

    HANDLE process = OpenProcess(PROCESS_ALL_ACCESS, false, pid);
    HANDLE thread = OpenThread(THREAD_ALL_ACCESS, false, threadId);

    HMODULE hKernel32 = GetModuleHandleW(L"kernel32.dll");
    LPTHREAD_START_ROUTINE pLoadLibraryW = (LPTHREAD_START_ROUTINE)GetProcAddress(hKernel32, "LoadLibraryW");
    
    SIZE_T dwLength = (wcslen(DLL_NAME) + 1) * 2;
    LPVOID lpLibName = VirtualAllocEx(process, NULL, dwLength, MEM_COMMIT, PAGE_READWRITE);
    
    SIZE_T written = 0;
    WriteProcessMemory(process, lpLibName, DLL_NAME, dwLength, &written);
    
    HANDLE hThread = CreateRemoteThread(process, NULL, NULL, pLoadLibraryW, lpLibName, NULL, NULL);
    
    WaitForSingleObject(hThread, INFINITE);

    // TODO: need to call initialisenorthstar in the new process
    // (this does not currently work!!! )
    //LPTHREAD_START_ROUTINE pInitNorthstar = (LPTHREAD_START_ROUTINE)GetProcAddress((HMODULE)lpLibName, "InitialiseNorthstar");
    //HANDLE hInitThread = CreateRemoteThread(processInfo.hProcess, NULL, NULL, pInitNorthstar, NULL, NULL, NULL);
    //WaitForSingleObject(hInitThread, INFINITE);
    //CloseHandle(hInitThread);
    
    ResumeThread(thread);
    CloseHandle(hThread);
    
    VirtualFreeEx(process, lpLibName, dwLength, MEM_RELEASE);
}