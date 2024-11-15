#include "engine/r2engine.h"
#include "server/r2server.h"
#include "hoststate.h"
#include "server/serverpresence.h"

static void(__fastcall* o_pCEngine__Frame)(CEngine* self) = nullptr;
static void __fastcall h_CEngine__Frame(CEngine* self)
{
	o_pCEngine__Frame(self);
}

ON_DLL_LOAD("engine.dll", RunFrame, (CModule module))
{
	o_pCEngine__Frame = module.Offset(0x1C8650).RCast<decltype(o_pCEngine__Frame)>();
	HookAttach(&(PVOID&)o_pCEngine__Frame, (PVOID)h_CEngine__Frame);
}
