#include "tier0.h"

IMemAlloc* g_pMemAllocSingleton = nullptr;

CommandLineType CommandLine;
Plat_FloatTimeType Plat_FloatTime;
ThreadInServerFrameThreadType ThreadInServerFrameThread;

typedef IMemAlloc* (*CreateGlobalMemAllocType)();
CreateGlobalMemAllocType CreateGlobalMemAlloc;

// needs to be a seperate function, since memalloc.cpp calls it
void TryCreateGlobalMemAlloc()
{
	// init memalloc stuff
	CreateGlobalMemAlloc =
		reinterpret_cast<CreateGlobalMemAllocType>(GetProcAddress(GetModuleHandleA("tier0.dll"), "CreateGlobalMemAlloc"));
	g_pMemAllocSingleton = CreateGlobalMemAlloc(); // if it already exists, this returns the preexisting IMemAlloc instance
}

ON_DLL_LOAD("tier0.dll", Tier0GameFuncs, (CModule module))
{
	// shouldn't be necessary, but do this just in case
	TryCreateGlobalMemAlloc();

	// setup tier0 funcs
	CommandLine = module.GetExportedFunction("CommandLine").RCast<CommandLineType>();
	Plat_FloatTime = module.GetExportedFunction("Plat_FloatTime").RCast<Plat_FloatTimeType>();
	ThreadInServerFrameThread = module.GetExportedFunction("ThreadInServerFrameThread").RCast<ThreadInServerFrameThreadType>();
}
