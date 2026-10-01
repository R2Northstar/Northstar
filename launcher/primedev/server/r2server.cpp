#include "r2server.h"
#include "weaponx.h"

CBaseEntity* (*Server_GetEntityByIndex)(int index);
CBasePlayer*(__fastcall* UTIL_PlayerByIndex)(int playerIndex);

const char* (*GetWeaponName)(int index);
void* (*GetWeaponOwner)(CWeaponX* weapon);

static bool(__fastcall* o_pOnWeaponAttack)(CWeaponX* a1, int a2) = nullptr;
static bool __fastcall h_pOnWeaponAttack(CWeaponX* weapon, int a2)
{
	auto weapon_name = GetWeaponName(weapon->m_weaponNameIndex);
	int shotsFired = 1;
	auto player_inst = g_pSquirrel[ScriptContext::SERVER]->__sq_createscriptinstance(GetWeaponOwner(weapon));
	auto weapon_inst = g_pSquirrel[ScriptContext::SERVER]->__sq_createscriptinstance(weapon);
	g_pSquirrel[ScriptContext::SERVER]->Call("CodeCallback_OnWeaponAttack", player_inst, weapon_inst, weapon_name, shotsFired);
	return o_pOnWeaponAttack(weapon, a2);
}

ON_DLL_LOAD("server.dll", R2GameServer, (CModule module))
{
	Server_GetEntityByIndex = module.Offset(0xFB820).RCast<CBaseEntity* (*)(int)>();
	UTIL_PlayerByIndex = module.Offset(0x26AA10).RCast<CBasePlayer*(__fastcall*)(int)>();
	GetWeaponName = module.Offset(0x691300).RCast<const char* (*)(int)>();
	GetWeaponOwner = module.Offset(0xA6A20).RCast<void* (*)(CWeaponX*)>();

	o_pOnWeaponAttack = module.Offset(0x6A0220).RCast<decltype(o_pOnWeaponAttack)>();
	HookAttach(&(PVOID&)o_pOnWeaponAttack, (PVOID)h_pOnWeaponAttack);

	// Remove call to Error for Geo bug: bullet trace ended at (%f, %f, %f), which is outside the max map coord:%i.
	module.Offset(0x43D4D8).NOP(6);
}
