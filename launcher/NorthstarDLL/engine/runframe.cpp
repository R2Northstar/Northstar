#include "pch.h"
#include "engine/r2engine.h"
#include "server/r2server.h"
#include "hoststate.h"
#include "server/serverpresence.h"

AUTOHOOK_INIT()
// clang-format off
AUTOHOOK(CEngine__Frame, engine.dll + 0x1C8650,
void, __fastcall, (R2::CEngine* self))
// clang-format on
{
	CEngine__Frame(self);
}
ON_DLL_LOAD("engine.dll", RunFrame, (CModule module))
{
	AUTOHOOK_DISPATCH()
}
