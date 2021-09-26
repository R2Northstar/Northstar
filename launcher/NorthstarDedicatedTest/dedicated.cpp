#include "pch.h"
#include "dedicated.h"
#include "hookutils.h"
#include "tier0.h"
#include "gameutils.h"

bool IsDedicated()
{
	return CommandLine()->CheckParm("-dedicated");
}

// CDedidcatedExports defs
struct CDedicatedExports; // forward declare

typedef void (*DedicatedSys_PrintfType)(CDedicatedExports* dedicated, char* msg);
typedef void (*DedicatedRunServerType)(CDedicatedExports* dedicated);

struct CDedicatedExports
{
	void* vtable; // because it's easier, we just set this to &this, since CDedicatedExports has no props we care about other than funcs

	char unused[56];

	DedicatedSys_PrintfType Sys_Printf;
	DedicatedRunServerType RunServer;
};

void Sys_Printf(CDedicatedExports* dedicated, char* msg)
{
	spdlog::info("[DEDICATED PRINT] {}", msg);
}

typedef bool (*CEngine__FrameType)(void* engineSelf);
typedef void(*CHostState__InitType)(CHostState* self);

void RunServer(CDedicatedExports* dedicated)
{
	Sys_Printf(dedicated, (char*)"CDedicatedExports::RunServer(): starting");

	HMODULE engine = GetModuleHandleA("engine.dll");
	CEngine__FrameType CEngine__Frame = (CEngine__FrameType)((char*)engine + 0x1C8650);
	CHostState__InitType CHostState__Init = (CHostState__InitType)((char*)engine + 0x16E110);

	// init hoststate, if we don't do this, we get a crash later on
	CHostState__Init(g_pHostState);

	// set host state to allow us to enter CHostState::FrameUpdate, with the state HS_NEW_GAME
	g_pHostState->m_iNextState = HostState_t::HS_NEW_GAME;
	strncpy(g_pHostState->m_levelName, CommandLine()->ParmValue("+map", "mp_lobby"), sizeof(g_pHostState->m_levelName)); // set map to load into

	while (true)
	{
		CEngine__Frame(g_pEngine);

		spdlog::info("CEngine::Frame() on map {} took {}ms", g_pHostState->m_levelName, g_pEngine->m_flFrameTime);
		Sleep(50);
	}
}

void InitialiseDedicated(HMODULE engineAddress)
{
	if (!IsDedicated())
		return;

	spdlog::info("InitialiseDedicated");

	{
		// Host_Init
		// prevent a particle init that relies on client dll

		char* ptr = (char*)engineAddress + 0x156799;
		TempReadWrite rw(ptr);

		*ptr = (char)0x90;
		*(ptr + 1) = (char)0x90;
		*(ptr + 2) = (char)0x90;
		*(ptr + 3) = (char)0x90;
		*(ptr + 4) = (char)0x90;
	}

	{
		// CModAppSystemGroup::Create
		// force the engine into dedicated mode by changing the first comparison to IsServerOnly to an assignment
		char* ptr = (char*)engineAddress + 0x1C4EBD;
		TempReadWrite rw(ptr);
		
		// cmp => mov
		*(ptr + 1) = (char)0xC6;
		*(ptr + 2) = (char)0x87;
		
		// 00 => 01
		*((char*)ptr + 7) = (char)0x01;
	}

	{
		// Some init that i'm not sure of that crashes
		char* ptr = (char*)engineAddress + 0x156A63;
		TempReadWrite rw(ptr);

		// nop the call to it
		*ptr = (char)0x90;
		*(ptr + 1) = (char)0x90;
		*(ptr + 2) = (char)0x90;
		*(ptr + 3) = (char)0x90;
		*(ptr + 4) = (char)0x90;
	}

	{
		// runframeserver
		char* ptr = (char*)engineAddress + 0x159819;
		TempReadWrite rw(ptr);

		// nop some access violations
		*ptr = (char)0x90;
		*(ptr + 1) = (char)0x90;
		*(ptr + 2) = (char)0x90;
		*(ptr + 3) = (char)0x90;
		*(ptr + 4) = (char)0x90;
		*(ptr + 5) = (char)0x90;
		*(ptr + 6) = (char)0x90;
		*(ptr + 7) = (char)0x90;
		*(ptr + 8) = (char)0x90;
		*(ptr + 9) = (char)0x90;
		*(ptr + 10) = (char)0x90;
		*(ptr + 11) = (char)0x90;
		*(ptr + 12) = (char)0x90;
		*(ptr + 13) = (char)0x90;
		*(ptr + 14) = (char)0x90;
		*(ptr + 15) = (char)0x90;
		*(ptr + 16) = (char)0x90;
	}

	{
		// HostState_State_NewGame
		char* ptr = (char*)engineAddress + 0x156B4C;
		TempReadWrite rw(ptr);

		// nop some access violations
		*ptr = (char)0x90;
		*(ptr + 1) = (char)0x90;
		*(ptr + 2) = (char)0x90;
		*(ptr + 3) = (char)0x90;
		*(ptr + 4) = (char)0x90;
		*(ptr + 5) = (char)0x90;
		*(ptr + 6) = (char)0x90;
		*(ptr + 7) = (char)0x90;
		*(ptr + 8) = (char)0x90;
		*(ptr + 9) = (char)0x90;
		*(ptr + 10) = (char)0x90;
		*(ptr + 11) = (char)0x90;
		*(ptr + 12) = (char)0x90;
		*(ptr + 13) = (char)0x90;
		*(ptr + 14) = (char)0x90;
		*(ptr + 15) = (char)0x90;
		*(ptr + 16) = (char)0x90;
		*(ptr + 17) = (char)0x90;
		*(ptr + 18) = (char)0x90;
		*(ptr + 19) = (char)0x90;
		*(ptr + 20) = (char)0x90;
		*(ptr + 21) = (char)0x90;
	}

	{
		// HostState_State_NewGame
		char* ptr = (char*)engineAddress + 0xB934C;
		TempReadWrite rw(ptr);

		// nop an access violation
		*ptr = (char)0x90;
		*(ptr + 1) = (char)0x90;
		*(ptr + 2) = (char)0x90;
		*(ptr + 3) = (char)0x90;
		*(ptr + 4) = (char)0x90;
		*(ptr + 5) = (char)0x90;
		*(ptr + 6) = (char)0x90;
		*(ptr + 7) = (char)0x90;
		*(ptr + 8) = (char)0x90;
	}

	{
		// CEngineAPI::Connect
		char* ptr = (char*)engineAddress + 0x1C4D7D;
		TempReadWrite rw(ptr);

		// remove call to Shader_Connect
		*ptr = 0x90;
		*(ptr + 1) = (char)0x90;
		*(ptr + 2) = (char)0x90;
		*(ptr + 3) = (char)0x90;
		*(ptr + 4) = (char)0x90;
	}

	// not currently using this because it's for nopping renderthread/gamewindow stuff i.e. very hard
	//{
	//	// CEngineAPI::Init
	//	char* ptr = (char*)engineAddress + 0x1C60CE;
	//	TempReadWrite rw(ptr);
	//
	//	// remove call to something or other that reads video settings
	//	*ptr = 0x90;
	//	*(ptr + 1) = (char)0x90;
	//	*(ptr + 2) = (char)0x90;
	//	*(ptr + 3) = (char)0x90;
	//	*(ptr + 4) = (char)0x90;
	//}

	{
		// some inputsystem bullshit
		char* ptr = (char*)engineAddress + 0x1CEE28;
		TempReadWrite rw(ptr);

		// nop an accessviolation: temp because we still create game window atm
		*ptr = (char)0x90;
		*(ptr + 1) = (char)0x90;
		*(ptr + 2) = (char)0x90;
	}

	CDedicatedExports* dedicatedExports = new CDedicatedExports;
	dedicatedExports->vtable = dedicatedExports;
	dedicatedExports->Sys_Printf = Sys_Printf;
	dedicatedExports->RunServer = RunServer;

	CDedicatedExports** exports = (CDedicatedExports**)((char*)engineAddress + 0x13F0B668);
	*exports = dedicatedExports;
	
	// extra potential patches:
	// nop engine.dll+1c67d1 and +1c67d8 to skip videomode creategamewindow
	// also look into launcher.dll+d381, seems to cause renderthread to get made
	// this crashes HARD if no window which makes sense tbh
	// also look into materialsystem + 5B344 since it seems to be the base of all the renderthread stuff

	// add cmdline args that are good for dedi
	CommandLine()->AppendParm("-nomenuvid", 0);
	CommandLine()->AppendParm("-nosound", 0);
	CommandLine()->AppendParm("+host_preload_shaders", "0");
}