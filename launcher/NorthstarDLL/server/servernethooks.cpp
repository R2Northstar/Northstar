#include "core/convar/convar.h"
#include "engine/r2engine.h"
#include "shared/exploit_fixes/ns_limits.h"

#include <string>

AUTOHOOK_INIT()

static ConVar* Cvar_net_debug_atlas_packet;

static void ProcessAtlasConnectionlessPacket(R2::netpacket_t* packet)
{
	bool dbg = Cvar_net_debug_atlas_packet->GetBool();

	// extract kind, null-terminated type, data
	std::string pType, pData;
	for (int i = 5; i < packet->size; i++)
	{
		if (packet->data[i] == '\x00')
		{
			pType.assign((char*)(&packet->data[5]), (size_t)(i - 5));
			if (i + 1 < packet->size)
				pData.assign((char*)(&packet->data[i + 1]), (size_t)(packet->size - i - 1));
			break;
		}
	}

	if (dbg)
		spdlog::warn("ignoring Atlas connectionless packet (size={} type={}): unknown type", packet->size, pType);
	return;
}

AUTOHOOK(ProcessConnectionlessPacket, engine.dll + 0x117800, bool, , (void* a1, R2::netpacket_t* packet))
{
	if (4 < packet->size && packet->data[4] == 'T')
	{
		ProcessAtlasConnectionlessPacket(packet);
		return false;
	}
	if (!g_pServerLimits->CheckConnectionlessPacketLimits(packet))
		return false;
	return ProcessConnectionlessPacket(a1, packet);
}

ON_DLL_LOAD_RELIESON("engine.dll", ServerNetHooks, ConVar, (CModule module))
{
	AUTOHOOK_DISPATCH_MODULE(engine.dll)

	Cvar_net_debug_atlas_packet = new ConVar(
		"net_debug_atlas_packet",
		"0",
		FCVAR_NONE,
		"Whether to log detailed debugging information for Atlas connectionless packets (warning: this allows unlimited amounts of "
		"arbitrary data to be logged)");
}
