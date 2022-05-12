#include "pch.h"
#include "cvar.h"

ConVar* sv_cheats;

typedef char(__fastcall* function_containing_emit_t)(uint64_t a1, uint64_t a2);
function_containing_emit_t function_containing_emit;

char function_containing_emit_hook(uint64_t unknown_value, uint64_t command_ptr)
{
	char* command_string = *(char**)(command_ptr + 1040); // From decompile
	if (!sv_cheats->m_Value.m_nValue && !strncmp(command_string, "emit", 5))
	{
		spdlog::info("Blocking command \"emit\" because sv_cheats was 0");
		return 1;
	}
	return function_containing_emit(unknown_value, command_ptr);
}

void InitialiseServerEmit_Blocker(HMODULE baseAddress)
{
	HookEnabler hook;
	sv_cheats = g_pCVar->FindVar("sv_cheats");
	ENABLER_CREATEHOOK(
		hook, (char*)baseAddress + 0x5889A0, &function_containing_emit_hook, reinterpret_cast<LPVOID*>(&function_containing_emit));
}