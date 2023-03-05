#include "engine/r2engine.h"
#include "shared/exploit_fixes/ns_limits.h"

AUTOHOOK_INIT()

AUTOHOOK(ProcessConnectionlessPacket, engine.dll + 0x117800, bool, , (void* a1, R2::netpacket_t* packet))
{
	if (!g_pServerLimits->CheckConnectionlessPacketLimits(packet))
		return false;
	return ProcessConnectionlessPacket(a1, packet);
}

ON_DLL_LOAD_RELIESON("engine.dll", ServerNetHooks, ConVar, (CModule module))
{
	AUTOHOOK_DISPATCH_MODULE(engine.dll)
}
