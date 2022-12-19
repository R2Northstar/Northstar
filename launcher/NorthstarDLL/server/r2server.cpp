#include "pch.h"
#include "r2server.h"

using namespace R2;

// use the R2 namespace for game funcs
namespace R2
{
	CBaseEntity* (*Server_GetEntityByIndex)(int index);
	CBasePlayer*(__fastcall* UTIL_PlayerByIndex)(int playerIndex);
} // namespace R2

ON_DLL_LOAD("server.dll", R2GameServer, (CModule module))
{
	Server_GetEntityByIndex = module.Offset(0xFB820).As<CBaseEntity* (*)(int)>();
	UTIL_PlayerByIndex = module.Offset(0x26AA10).As<CBasePlayer*(__fastcall*)(int)>();
}
