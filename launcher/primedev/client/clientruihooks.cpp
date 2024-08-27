#include "core/convar/convar.h"

ConVar* Cvar_rui_drawEnable;

static bool (*__fastcall o_pDrawRUIFunc)(void* a1, float* a2) = nullptr;
static bool __fastcall h_DrawRUIFunc(void* a1, float* a2)
{
	if (!Cvar_rui_drawEnable->GetBool())
		return 0;

	return o_pDrawRUIFunc(a1, a2);
}

ON_DLL_LOAD_CLIENT_RELIESON("engine.dll", RUI, ConVar, (CModule module))
{
	o_pDrawRUIFunc = module.Offset(0xFC500).RCast<decltype(o_pDrawRUIFunc)>();
	HookAttach(&(PVOID&)o_pDrawRUIFunc, (PVOID)h_DrawRUIFunc);

	Cvar_rui_drawEnable = new ConVar("rui_drawEnable", "1", FCVAR_CLIENTDLL, "Controls whether RUI should be drawn");
}
