#include "pch.h"
#include "core/convar/convar.h"

AUTOHOOK_INIT()

ConVar* Cvar_rui_drawEnable;

// clang-format off
AUTOHOOK(DrawRUIFunc, engine.dll + 0xFC500,
bool, __fastcall, (void* a1, float* a2))
// clang-format on
{
	if (!Cvar_rui_drawEnable->GetBool())
		return 0;

	return DrawRUIFunc(a1, a2);
}

ON_DLL_LOAD_CLIENT_RELIESON("engine.dll", RUI, ConVar, (CModule module))
{
	AUTOHOOK_DISPATCH()

	Cvar_rui_drawEnable = new ConVar("rui_drawEnable", "1", FCVAR_CLIENTDLL, "Controls whether RUI should be drawn");
}
