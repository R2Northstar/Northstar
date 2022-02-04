#include "pch.h"
#include "sourceinterface.h"
#include "hooks.h"
#include "hookutils.h"

#include "sourceconsole.h"
#include "context.h"
#include "convar.h"
#include <iostream>

// really wanted to do a modular callback system here but honestly couldn't be bothered so hardcoding stuff for now: todo later

CreateInterfaceFn clientCreateInterfaceOriginal;
void* ClientCreateInterfaceHook(const char* pName, int* pReturnCode)
{
	void* ret = clientCreateInterfaceOriginal(pName, pReturnCode);

	spdlog::info("CreateInterface CLIENT {}", pName);
	if (!strcmp(pName, "GameClientExports001"))
		InitialiseConsoleOnInterfaceCreation();

	return ret;
}

CreateInterfaceFn serverCreateInterfaceOriginal;
void* ServerCreateInterfaceHook(const char* pName, int* pReturnCode)
{
	void* ret = serverCreateInterfaceOriginal(pName, pReturnCode);

	std::cout << "CreateInterface SERVER " << pName << std::endl;

	return ret;
}

CreateInterfaceFn engineCreateInterfaceOriginal;
void* EngineCreateInterfaceHook(const char* pName, int* pReturnCode)
{
	void* ret = engineCreateInterfaceOriginal(pName, pReturnCode);

	std::cout << "CreateInterface ENGINE " << pName << std::endl;

	return ret;
}

void HookClientCreateInterface(HMODULE baseAddress)
{
	HookEnabler hook;
	ENABLER_CREATEHOOK(
		hook, GetProcAddress(baseAddress, "CreateInterface"), &ClientCreateInterfaceHook,
		reinterpret_cast<LPVOID*>(&clientCreateInterfaceOriginal));
}

void HookServerCreateInterface(HMODULE baseAddress)
{
	HookEnabler hook;
	ENABLER_CREATEHOOK(
		hook, GetProcAddress(baseAddress, "CreateInterface"), &ServerCreateInterfaceHook,
		reinterpret_cast<LPVOID*>(&serverCreateInterfaceOriginal));
}

void HookEngineCreateInterface(HMODULE baseAddress)
{
	HookEnabler hook;
	ENABLER_CREATEHOOK(
		hook, GetProcAddress(baseAddress, "CreateInterface"), &EngineCreateInterfaceHook,
		reinterpret_cast<LPVOID*>(&engineCreateInterfaceOriginal));
}

void InitialiseInterfaceCreationHooks()
{
	AddDllLoadCallback("client.dll", HookClientCreateInterface);

	// not used atm
	// AddDllLoadCallback("server.dll", HookServerCreateInterface);
	// AddDllLoadCallback("engine.dll", HookEngineCreateInterface);
}