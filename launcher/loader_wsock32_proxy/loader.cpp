#include "pch.h"
#include "loader.h"
#include "../NorthstarDedicatedTest/hookutils.h"
#include <string>
#include <system_error>
#include <sstream>
#include <fstream>
#include <filesystem>

void LibraryLoadError(DWORD dwMessageId, const wchar_t* libName, const wchar_t* location)
{
	char text[4096];
	std::string message = std::system_category().message(dwMessageId);
	sprintf_s(text, "Failed to load the %ls at \"%ls\" (%lu):\n\n%hs", libName, location, dwMessageId, message.c_str());
	if (dwMessageId == 126 && std::filesystem::exists(location))
	{
		sprintf_s(text, "%s\n\nThe file at the specified location DOES exist, so this error indicates that one of its *dependencies* failed to be found.", text);
	}
	MessageBoxA(GetForegroundWindow(), text, "Northstar Wsock32 Proxy Error", 0);
}

bool ShouldLoadNorthstar()
{
	bool loadNorthstar = strstr(GetCommandLineA(), "-northstar");

	if (loadNorthstar)
		return loadNorthstar;

	auto runNorthstarFile = std::ifstream("run_northstar.txt");
	if (runNorthstarFile)
	{
		std::stringstream runNorthstarFileBuffer;
		runNorthstarFileBuffer << runNorthstarFile.rdbuf();
		runNorthstarFile.close();
		if (!runNorthstarFileBuffer.str()._Starts_with("0"))
			loadNorthstar = true;
	}
	return loadNorthstar;
}

bool LoadNorthstar()
{
	FARPROC Hook_Init = nullptr;
	{
		swprintf_s(buffer1, L"%s\\Northstar.dll", exePath);
		auto hHookModule = LoadLibraryExW(buffer1, 0, LOAD_WITH_ALTERED_SEARCH_PATH);
		if (hHookModule) Hook_Init = GetProcAddress(hHookModule, "InitialiseNorthstar");
		if (!hHookModule || Hook_Init == nullptr)
		{
			LibraryLoadError(GetLastError(), L"Northstar.dll", buffer1);
			return false;
		}
	}

	((bool (*)()) Hook_Init)();
	return true;
}

typedef int(*LauncherMainType)(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow);
LauncherMainType LauncherMainOriginal;

int LauncherMainHook(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow)
{
	if (ShouldLoadNorthstar())
		LoadNorthstar();
	return LauncherMainOriginal(hInstance, hPrevInstance, lpCmdLine, nCmdShow);
}

bool ProvisionNorthstar()
{
	if (!ShouldLoadNorthstar())
		return true;

	if (MH_Initialize() != MH_OK)
	{
		MessageBoxA(GetForegroundWindow(), "MH_Initialize failed\nThe game cannot continue and has to exit.", "Northstar Wsock32 Proxy Error", 0);
		return false;
	}

	auto launcherHandle = GetModuleHandleA("launcher.dll");
	if (!launcherHandle)
	{
		MessageBoxA(GetForegroundWindow(), "Launcher isn't loaded yet.\nThe game cannot continue and has to exit.", "Northstar Wsock32 Proxy Error", 0);
		return false;
	}

	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, GetProcAddress(launcherHandle, "LauncherMain"), &LauncherMainHook, reinterpret_cast<LPVOID*>(&LauncherMainOriginal));

	return true;
}