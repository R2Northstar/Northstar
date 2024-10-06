#include "logging/sourceconsole.h"

// really wanted to do a modular callback system here but honestly couldn't be bothered so hardcoding stuff for now: todo later

static void*(__fastcall* o_pClientCreateInterface)(const char* pName, const int* pReturnCode) = nullptr;
static void* __fastcall h_ClientCreateInterface(const char* pName, const int* pReturnCode)
{
	void* ret = o_pClientCreateInterface(pName, pReturnCode);
	spdlog::info("CreateInterface CLIENT {}", pName);

	if (!strcmp(pName, "GameClientExports001"))
		InitialiseConsoleOnInterfaceCreation();

	return ret;
}

static void*(__fastcall* o_pServerCreateInterface)(const char* pName, const int* pReturnCode) = nullptr;
static void* __fastcall h_ServerCreateInterface(const char* pName, const int* pReturnCode)
{
	void* ret = o_pServerCreateInterface(pName, pReturnCode);
	spdlog::info("CreateInterface SERVER {}", pName);

	return ret;
}

static void*(__fastcall* o_pEngineCreateInterface)(const char* pName, const int* pReturnCode) = nullptr;
static void* __fastcall h_EngineCreateInterface(const char* pName, const int* pReturnCode)
{
	void* ret = o_pEngineCreateInterface(pName, pReturnCode);
	spdlog::info("CreateInterface ENGINE {}", pName);

	return ret;
}

ON_DLL_LOAD("client.dll", ClientInterface, (CModule module))
{
	o_pClientCreateInterface = module.GetExportedFunction("CreateInterface").RCast<decltype(o_pClientCreateInterface)>();
	HookAttach(&(PVOID&)o_pClientCreateInterface, (PVOID)h_ClientCreateInterface);
}

ON_DLL_LOAD("server.dll", ServerInterface, (CModule module))
{
	o_pServerCreateInterface = module.GetExportedFunction("CreateInterface").RCast<decltype(o_pServerCreateInterface)>();
	HookAttach(&(PVOID&)o_pServerCreateInterface, (PVOID)h_ServerCreateInterface);
}

ON_DLL_LOAD("engine.dll", EngineInterface, (CModule module))
{
	o_pEngineCreateInterface = module.GetExportedFunction("CreateInterface").RCast<decltype(o_pEngineCreateInterface)>();
	HookAttach(&(PVOID&)o_pEngineCreateInterface, (PVOID)h_EngineCreateInterface);
}
