#include "pch.h"
#include "dedicated.h"
#include "hookutils.h"
#include "tier0.h"
#include "gameutils.h"

#include <iostream>

bool IsDedicated()
{
	return CommandLine()->HasParm("-dedicated");
}

enum EngineState_t
{
	DLL_INACTIVE = 0,		// no dll
	DLL_ACTIVE,				// engine is focused
	DLL_CLOSE,				// closing down dll
	DLL_RESTART,			// engine is shutting down but will restart right away
	DLL_PAUSED,				// engine is paused, can become active from this state
};

struct CEngine
{
public:
	void* vtable;
	
	int m_nQuitting;
	EngineState_t m_nDllState;
	EngineState_t m_nNextDllState;
	double m_flCurrentTime;
	float m_flFrameTime;
	double m_flPreviousTime;
	float m_flFilteredTime;
	float m_flMinFrameTime; // Expected duration of a frame, or zero if it is unlimited.
};

enum HostState_t
{
	HS_NEW_GAME = 0,
	HS_LOAD_GAME,
	HS_CHANGE_LEVEL_SP,
	HS_CHANGE_LEVEL_MP,
	HS_RUN,
	HS_GAME_SHUTDOWN,
	HS_SHUTDOWN,
	HS_RESTART,
};

void InitialiseDedicated(HMODULE engineAddress)
{
	if (!IsDedicated())
		return;

	spdlog::info("InitialiseDedicated");

	//while (!IsDebuggerPresent())
	//	Sleep(100);

	// create binary patches
	//{
	//	// CEngineAPI::SetStartupInfo
	//	// prevents englishclient_frontend from loading
	//
	//	char* ptr = (char*)engineAddress + 0x1C7CBE;
	//	TempReadWrite rw(ptr);
	//
	//	// je => jmp
	//	*ptr = (char)0xEB;
	//}

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
		// some inputsystem bullshit
		char* ptr = (char*)engineAddress + 0x1CEE28;
		TempReadWrite rw(ptr);

		// nop an accessviolation: temp because we still create game window atm
		*ptr = (char)0x90;
		*(ptr + 1) = (char)0x90;
		*(ptr + 2) = (char)0x90;
	}


	// materialsystem later:
	// do materialsystem + 5f0f1 je => jmp to make material loading not die

	CDedicatedExports* dedicatedApi = new CDedicatedExports;
	dedicatedApi->Sys_Printf = Sys_Printf;
	dedicatedApi->RunServer = RunServer;

	// double ptr to dedicatedApi
	intptr_t* ptr = (intptr_t*)((char*)engineAddress + 0x13F0B668);
	
	// ptr to dedicatedApi
	intptr_t* doublePtr = new intptr_t;
	*doublePtr = (intptr_t)dedicatedApi;

	// ptr to ptr
	*ptr = (intptr_t)doublePtr;

	// extra potential patches:
	// nop engine.dll+1c67d1 and +1c67d8 to skip videomode creategamewindow
	// also look into launcher.dll+d381, seems to cause renderthread to get made
	// this crashes HARD if no window which makes sense tbh
	// also look into materialsystem + 5B344 since it seems to be the base of all the renderthread stuff

	// add cmdline args that are good for dedi
	CommandLine()->AppendParm("-nomenuvid", 0);
	CommandLine()->AppendParm("+host_preload_shaders", 0);
	CommandLine()->AppendParm("-nosound", 0);
}

void Sys_Printf(CDedicatedExports* dedicated, char* msg)
{
	spdlog::info("[DEDICATED PRINT] {}", msg);
}

typedef void(*CHostState__InitType)(CHostState* self);

void RunServer(CDedicatedExports* dedicated)
{
	while (!IsDebuggerPresent())Sleep(100);

	Sys_Printf(dedicated, (char*)"CDedicatedServerAPI::RunServer(): starting");

	HMODULE engine = GetModuleHandleA("engine.dll");
	CEngine__Frame engineFrame = (CEngine__Frame)((char*)engine + 0x1C8650);
	CEngine* cEnginePtr = (CEngine*)((char*)engine + 0x7D70C8);
	CHostState* cHostStatePtr = (CHostState*)((char*)engine + 0x7CF180);
	
	CHostState__InitType CHostState__Init = (CHostState__InitType)((char*)engine + 0x16E110);

	// call once to init
	engineFrame(cEnginePtr);

	// init hoststate, if we don't do this, we get a crash later on
	CHostState__Init(cHostStatePtr);

	// set up engine and host states to allow us to enter CHostState::FrameUpdate, with the state HS_NEW_GAME
	cEnginePtr->m_nNextDllState = EngineState_t::DLL_ACTIVE;
	cHostStatePtr->m_iNextState = HostState_t::HS_NEW_GAME;
	strcpy(cHostStatePtr->m_levelName, "mp_lobby"); // set map to load into

	while (true)
	{
		engineFrame(cEnginePtr);

		//engineApiStartSimulation(nullptr, true);
		Sys_Printf(dedicated, (char*)"engine->Frame()");
		Sleep(50);
	}
}