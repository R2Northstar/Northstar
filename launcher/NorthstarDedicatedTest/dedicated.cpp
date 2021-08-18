#include "pch.h"
#include "dedicated.h"
#include "hookutils.h"

#include <iostream>

bool IsDedicated()
{
	// temp: should get this from commandline
	return true;
	return false;
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
	char unknown[12];

	EngineState_t m_nDllState;
	EngineState_t m_nNextDllState;
};

void InitialiseDedicated(HMODULE engineAddress)
{
	spdlog::info("InitialiseDedicated");

	while (!IsDebuggerPresent())
		Sleep(100);

	// create binary patches
	{
		// CEngineAPI::SetStartupInfo
		// prevents englishclient_frontend from loading

		char* ptr = (char*)engineAddress + 0x1C7CBE;
		TempReadWrite rw(ptr);

		// je => jmp
		*ptr = (char)0xEB;
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
}

void Sys_Printf(CDedicatedExports* dedicated, char* msg)
{
	std::cout << msg << std::endl;
}

void RunServer(CDedicatedExports* dedicated)
{
	Sys_Printf(dedicated, (char*)"CDedicatedServerAPI::RunServer(): starting");

	HMODULE engine = GetModuleHandleA("engine.dll");
	CEngine__Frame engineFrame = (CEngine__Frame)((char*)engine + 0x1C8650);
	CEngineAPI__ActivateSimulation engineApiStartSimulation = (CEngineAPI__ActivateSimulation)((char*)engine + 0x1C4370);

	CEngine* cEnginePtr = (CEngine*)((char*)engine + 0x7D70C8);

	CEngineAPI__SetMap engineApiSetMap = (CEngineAPI__SetMap)((char*)engine + 0x1C7B30);
	
	// call once to init
	engineFrame(cEnginePtr);

	// allow us to hit CHostState::FrameUpdate
	cEnginePtr->m_nDllState = EngineState_t::DLL_ACTIVE;
	cEnginePtr->m_nNextDllState = EngineState_t::DLL_ACTIVE;

	while (true)
	{
		engineFrame(cEnginePtr);
		//engineApiStartSimulation(nullptr, true);
		Sys_Printf(dedicated, (char*)"engine->Frame()");
		engineApiSetMap(nullptr, "mp_thaw");
		Sleep(50);
	}
}