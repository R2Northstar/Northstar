#include "core/convar/convar.h"
#include "engine/r2engine.h"

size_t __fastcall ShouldAllowAlltalk()
{
	// this needs to return a 64 bit integer where 0 = true and 1 = false
	static ConVar* Cvar_sv_alltalk = R2::g_pCVar->FindVar("sv_alltalk");
	if (Cvar_sv_alltalk->GetBool())
		return 0;

	// lobby should default to alltalk, otherwise don't allow it
	return strcmp(R2::g_pGlobals->m_pMapName, "mp_lobby");
}

ON_DLL_LOAD_RELIESON("engine.dll", ServerAllTalk, ConVar, (CModule module))
{
	// replace strcmp function called in CClient::ProcessVoiceData with our own code that calls ShouldAllowAllTalk
	MemoryAddress base = module.Offset(0x1085FA);

	base.Patch("48 B8"); // mov rax, 64 bit int
	// (uint8_t*)&ShouldAllowAlltalk doesn't work for some reason? need to make it a uint64 first
	uint64_t pShouldAllowAllTalk = reinterpret_cast<uint64_t>(ShouldAllowAlltalk);
	base.Offset(0x2).Patch((uint8_t*)&pShouldAllowAllTalk, 8);
	base.Offset(0xA).Patch("FF D0"); // call rax

	// nop until compare (test eax, eax)
	base.Offset(0xC).NOP(0x7);
}
