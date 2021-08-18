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

void InjectInjectorIntoProcess(DWORD pid)
{
	HANDLE procHandle = OpenProcess(PROCESS_ALL_ACCESS, false, pid);

	std::wstring path = (fs::current_path() / "GameInjector.dll").wstring();
	size_t length = (path.length() + 1) * 2;
	LPVOID lpLibName = VirtualAllocEx(procHandle, NULL, length, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
	WriteProcessMemory(procHandle, lpLibName, path.c_str(), length, 0);

	// load minhook, since origin's loadlibrary won't load it from the tf directly by default
	std::wstring minhookPath = (fs::current_path() / "MinHook.x86.dll").wstring();
	size_t minhookLength = (minhookPath.length() + 1) * 2;
	LPVOID lpMinhookLibName = VirtualAllocEx(procHandle, NULL, minhookLength, MEM_COMMIT, PAGE_EXECUTE_READWRITE);
	WriteProcessMemory(procHandle, lpMinhookLibName, minhookPath.c_str(), minhookLength, 0);

	HMODULE hKernel32 = GetModuleHandleW(L"kernel32.dll");
	LPTHREAD_START_ROUTINE pLoadLibraryW = (LPTHREAD_START_ROUTINE)GetProcAddress(hKernel32, "LoadLibraryW");
	HANDLE thread = CreateRemoteThread(procHandle, NULL, 0, pLoadLibraryW, lpMinhookLibName, 0, 0);
	WaitForSingleObject(thread, INFINITE);

	thread = CreateRemoteThread(procHandle, NULL, 0, pLoadLibraryW, lpLibName, 0, 0);
	WaitForSingleObject(thread, INFINITE);

	DWORD dwExitCode;
	GetExitCodeThread(thread, &dwExitCode);
	std::cout << dwExitCode << std::endl;

	CloseHandle(procHandle);

	std::cout << pid << std::endl;
}

void CreateAndHookUnpackedTitanfallProcess()
{
	PROCESS_INFORMATION tfPi;
	memset(&tfPi, 0, sizeof(tfPi));
	STARTUPINFO si;
	memset(&si, 0, sizeof(si));
	CreateProcessA("Titanfall2-unpacked.exe", (LPSTR)"", NULL, NULL, false, CREATE_SUSPENDED, NULL, NULL, (LPSTARTUPINFOA)&si, &tfPi);
	
	PROCESS_INFORMATION pi;
	memset(&pi, 0, sizeof(pi));
	memset(&si, 0, sizeof(si));

	std::stringstream argStream;
	argStream << tfPi.dwProcessId;
	argStream << " ";
	argStream << tfPi.dwThreadId;

	CreateProcessA("InjectionProxy64.exe", (LPSTR)(argStream.str().c_str()), NULL, NULL, false, 0, NULL, NULL, (LPSTARTUPINFOA)&si, &pi);
	WaitForSingleObject(pi.hThread, INFINITE);

	CloseHandle(pi.hThread);
	CloseHandle(tfPi.hThread);
}

int main()
{
	//AllocConsole();

	// check if we're in the titanfall directory
	if (!fs::exists("Titanfall2.exe") && !fs::exists("Titanfall2-unpacked.exe"))
	{
		MessageBox(NULL, L"Titanfall2.exe not found! Please launch from your titanfall 2 directory!", L"", MB_OK);
		return 1;
	}

	// check for steam dll and unpacked exe
	bool unpacked = fs::exists("Titanfall2-unpacked.exe");
	bool steamBuild = !unpacked && fs::exists("steam_api64.dll");
	
	// unpacked origin
	if (unpacked)
	{
		// check origin process
		DWORD origin = GetProcessByName(L"Origin.exe");

		if (!origin)
		{
			// unpacked exe will crash if origin isn't open on launch, so launch it
			// get origin path from registry, code here is reversed from OriginSDK.dll
			HKEY key;
			if (RegOpenKeyExA(HKEY_LOCAL_MACHINE, "SOFTWARE\\WOW6432Node\\Origin", 0, KEY_READ, &key) != ERROR_SUCCESS)
				return 1;

			char originPath[520];
			DWORD originPathLength = 520;
			if (RegQueryValueExA(key, "ClientPath", 0, 0, (LPBYTE)&originPath, &originPathLength) != ERROR_SUCCESS)
				return 1;

			PROCESS_INFORMATION pi;
			memset(&pi, 0, sizeof(pi));
			STARTUPINFO si;
			memset(&si, 0, sizeof(si));
			CreateProcessA(originPath, (LPSTR)"", NULL, NULL, false, CREATE_DEFAULT_ERROR_MODE | CREATE_NEW_PROCESS_GROUP, NULL, NULL, (LPSTARTUPINFOA)&si, &pi);

			// bit of a hack, but wait 12.5s to give origin a sec to init
			// would be nice if we could do this dynamically, but idk how rn
			Sleep(12500);
		}
		
		CreateAndHookUnpackedTitanfallProcess();
	}
	// packed origin
	else
	{
		// create a titanfall process, this will cause origin to start launching the game
		// if we're on steam, origin will launch the steam release here, too
		// we can't hook the titanfall process here unfortunately, since the titanfall process we create here dies when origin stuff starts

		PROCESS_INFORMATION pi;
		memset(&pi, 0, sizeof(pi));
		STARTUPINFO si;
		memset(&si, 0, sizeof(si));
		CreateProcessA("Titanfall2.exe", (LPSTR)"", NULL, NULL, false, 0, NULL, NULL, (LPSTARTUPINFOA)&si, &pi);
	
		// hook launcher
		DWORD launcherPID;
		if (steamBuild)
			while (!(launcherPID = GetProcessByName(L"steam.exe"))) Sleep(50);
		else
			while (!(launcherPID = GetProcessByName(L"Origin.exe"))) Sleep(50);

		// injector should clean itself up after its job is done
		InjectInjectorIntoProcess(launcherPID);
	}
}