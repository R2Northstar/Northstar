#include "pch.h"
#include "tier0.h"

// use the Tier0 namespace for tier0 funcs
namespace Tier0
{
	IMemAlloc* g_pMemAllocSingleton;

	ErrorType Error;
	CommandLineType CommandLine;
	Plat_FloatTimeType Plat_FloatTime;
	ThreadInServerFrameThreadType ThreadInServerFrameThread;
} // namespace Tier0

typedef Tier0::IMemAlloc* (*CreateGlobalMemAllocType)();
CreateGlobalMemAllocType CreateGlobalMemAlloc;

// needs to be a seperate function, since memalloc.cpp calls it
void TryCreateGlobalMemAlloc()
{
	// init memalloc stuff
	CreateGlobalMemAlloc =
		reinterpret_cast<CreateGlobalMemAllocType>(GetProcAddress(GetModuleHandleA("tier0.dll"), "CreateGlobalMemAlloc"));
	Tier0::g_pMemAllocSingleton = CreateGlobalMemAlloc(); // if it already exists, this returns the preexisting IMemAlloc instance
}

ON_DLL_LOAD("tier0.dll", Tier0GameFuncs, (CModule module))
{
	// shouldn't be necessary, but do this just in case
	TryCreateGlobalMemAlloc();

	// setup tier0 funcs
	Tier0::Error = module.GetExport("Error").As<Tier0::ErrorType>();
	Tier0::CommandLine = module.GetExport("CommandLine").As<Tier0::CommandLineType>();
	Tier0::Plat_FloatTime = module.GetExport("Plat_FloatTime").As<Tier0::Plat_FloatTimeType>();
	Tier0::ThreadInServerFrameThread = module.GetExport("ThreadInServerFrameThread").As<Tier0::ThreadInServerFrameThreadType>();
}
