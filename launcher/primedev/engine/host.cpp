#include "core/convar/convar.h"
#include "mods/modmanager.h"
#include "util/printcommands.h"
#include "util/printmaps.h"
#include "shared/misccommands.h"
#include "r2engine.h"
#include "core/tier0.h"

static void(__fastcall* o_pHost_Init)(bool bDedicated) = nullptr;
static void __fastcall h_Host_Init(bool bDedicated)
{
	spdlog::info("Host_Init()");
	o_pHost_Init(bDedicated);
	FixupCvarFlags();
	// need to initialise these after host_init since they do stuff to preexisting concommands/convars without being client/server specific
	InitialiseCommandPrint();
	InitialiseMapsPrint();
	// client/server autoexecs on necessary platforms
	// dedi needs autoexec_ns_server on boot, while non-dedi will run it on on listen server start
	if (bDedicated)
		Cbuf_AddText(Cbuf_GetCurrentPlayer(), "exec autoexec_ns_server", cmd_source_t::kCommandSrcCode);
	else
		Cbuf_AddText(Cbuf_GetCurrentPlayer(), "exec autoexec_ns_client", cmd_source_t::kCommandSrcCode);
}

ON_DLL_LOAD("engine.dll", Host_Init, (CModule module))
{
	o_pHost_Init = module.Offset(0x155EA0).RCast<decltype(o_pHost_Init)>();
	HookAttach(&(PVOID&)o_pHost_Init, (PVOID)h_Host_Init);
}
