#include "pch.h"
#include "clientruihooks.h"
#include "convar.h"

ConVar* Cvar_rui_drawEnable;

typedef char (*DrawRUIFuncType)(void* a1, float* a2);
DrawRUIFuncType DrawRUIFunc;

char DrawRUIFuncHook(void* a1, float* a2)
{
	if (!Cvar_rui_drawEnable->GetBool())
		return 0;

	return DrawRUIFunc(a1, a2);
}

void InitialiseEngineClientRUIHooks(HMODULE baseAddress)
{
	Cvar_rui_drawEnable = new ConVar("rui_drawEnable", "1", FCVAR_CLIENTDLL, "Controls whether RUI should be drawn");

	HookEnabler hook;
	ENABLER_CREATEHOOK(hook, (char*)baseAddress + 0xFC500, &DrawRUIFuncHook, reinterpret_cast<LPVOID*>(&DrawRUIFunc));
}
