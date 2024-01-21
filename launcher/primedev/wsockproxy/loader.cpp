#include "loader.h"
#include <string>
#include <system_error>
#include <sstream>
#include <fstream>
#include <filesystem>
#include <iostream>

namespace fs = std::filesystem;

void LibraryLoadError(DWORD dwMessageId, const wchar_t* libName, const wchar_t* location)
{
	char text[4096];
	std::string message = std::system_category().message(dwMessageId);
	sprintf_s(text, "Failed to load the %ls at \"%ls\" (%lu):\n\n%hs", libName, location, dwMessageId, message.c_str());
	if (dwMessageId == 126 && std::filesystem::exists(location))
	{
		sprintf_s(
			text,
			"%s\n\nThe file at the specified location DOES exist, so this error indicates that one of its *dependencies* failed to be "
			"found.",
			text);
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
		if (!runNorthstarFileBuffer.str().starts_with("0"))
			loadNorthstar = true;
	}
	return loadNorthstar;
}

bool LoadNorthstar()
{
	FARPROC Hook_Init = nullptr;
	{
		std::string strProfile = "R2Northstar";
		char* clachar = strstr(GetCommandLineA(), "-profile=");
		if (clachar)
		{
			std::string cla = std::string(clachar);
			if (strncmp(cla.substr(9, 1).c_str(), "\"", 1))
			{
				size_t space = cla.find(" ");
				std::string dirname = cla.substr(9, space - 9);
				std::cout << "[*] Found profile in command line arguments: " << dirname << std::endl;
				strProfile = dirname.c_str();
			}
			else
			{
				std::string quote = "\"";
				size_t quote1 = cla.find(quote);
				size_t quote2 = (cla.substr(quote1 + 1)).find(quote);
				std::string dirname = cla.substr(quote1 + 1, quote2);
				std::cout << "[*] Found profile in command line arguments: " << dirname << std::endl;
				strProfile = dirname;
			}
		}
		else
		{
			std::cout << "[*] Profile was not found in command line arguments. Using default: R2Northstar" << std::endl;
			strProfile = "R2Northstar";
		}

		wchar_t buffer[8192];

		// Check if "Northstar.dll" exists in profile directory, if it doesnt fall back to root
		swprintf_s(buffer, L"%s\\%s\\Northstar.dll", exePath, std::wstring(strProfile.begin(), strProfile.end()).c_str());

		if (!fs::exists(fs::path(buffer)))
			swprintf_s(buffer, L"%s\\Northstar.dll", exePath);

		std::wcout << L"[*] Using: " << buffer << std::endl;

		HMODULE hHookModule = LoadLibraryExW(buffer, 0, 8u);
		if (hHookModule)
			Hook_Init = GetProcAddress(hHookModule, "InitialiseNorthstar");
		if (!hHookModule || Hook_Init == nullptr)
		{
			LibraryLoadError(GetLastError(), L"Northstar.dll", buffer);
			return false;
		}
	}
	((bool (*)())Hook_Init)();

	return true;
}

typedef int (*LauncherMainType)(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpCmdLine, int nCmdShow);
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
		MessageBoxA(
			GetForegroundWindow(), "MH_Initialize failed\nThe game cannot continue and has to exit.", "Northstar Wsock32 Proxy Error", 0);
		return false;
	}

	auto launcherHandle = GetModuleHandleA("launcher.dll");
	if (!launcherHandle)
	{
		MessageBoxA(
			GetForegroundWindow(),
			"Launcher isn't loaded yet.\nThe game cannot continue and has to exit.",
			"Northstar Wsock32 Proxy Error",
			0);
		return false;
	}

	LPVOID pTarget = (LPVOID)GetProcAddress(launcherHandle, "LauncherMain");
	if (MH_CreateHook(pTarget, (LPVOID)&LauncherMainHook, reinterpret_cast<LPVOID*>(&LauncherMainOriginal)) != MH_OK ||
		MH_EnableHook(pTarget) != MH_OK)
		MessageBoxA(GetForegroundWindow(), "Hook creation failed for function LauncherMain.", "Northstar Wsock32 Proxy Error", 0);

	return true;
}
