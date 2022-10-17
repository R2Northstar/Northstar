#include "pch.h"
#include "r2engine.h"

using namespace R2;

// use the R2 namespace for game funcs
namespace R2
{
	Cbuf_GetCurrentPlayerType Cbuf_GetCurrentPlayer;
	Cbuf_AddTextType Cbuf_AddText;
	Cbuf_ExecuteType Cbuf_Execute;

	CEngine* g_pEngine;

	void (*CBaseClient__Disconnect)(void* self, uint32_t unknownButAlways1, const char* reason, ...);
	CBaseClient* g_pClientArray;

	server_state_t* g_pServerState;

	char* g_pModName =
		nullptr; // we cant set this up here atm since we dont have an offset to it in engine, instead we store it in IsRespawnMod
} // namespace R2

ON_DLL_LOAD("engine.dll", R2Engine, (CModule module))
{
	Cbuf_GetCurrentPlayer = module.Offset(0x120630).As<Cbuf_GetCurrentPlayerType>();
	Cbuf_AddText = module.Offset(0x1203B0).As<Cbuf_AddTextType>();
	Cbuf_Execute = module.Offset(0x1204B0).As<Cbuf_ExecuteType>();

	g_pEngine = module.Offset(0x7D70C8).Deref().As<CEngine*>();

	CBaseClient__Disconnect = module.Offset(0x1012C0).As<void (*)(void*, uint32_t, const char*, ...)>();
	g_pClientArray = module.Offset(0x12A53F90).As<CBaseClient*>();

	g_pServerState = module.Offset(0x12A53D48).As<server_state_t*>();
}
