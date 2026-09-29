#include "engine/custom_packet_manager.h"
#include "r2engine.h"
#include <shared/exploit_fixes/ns_limits.h>

static const std::unordered_set<uint8_t> nativeHandlers({0x41, 0x48, 0x49, 0x4E}); // Not sure if there are others... probably!

CustomPacketManager* g_pCustomPacketManager = new CustomPacketManager;

bool (*CustomPacketManager::o_pHandlePacket)(void* packetHandler, netpacket_s* packet) = nullptr;
bool CustomPacketManager::h_HandlePacket(void* packetHandler, netpacket_s* packet)
{
	if (packet->size >= 5)
	{
		uint32_t header = *reinterpret_cast<uint32_t*>(packet->data);

		// packet->data consists of 0xFFFFFFFF (int32 -1) to indicate packets aren't split, followed by a header consisting of a single
		// character, which is used to uniquely identify the packet kind. Most kinds follow this with a null-terminated string payload
		// then an arbitrary amoount of data.
		if (header == 0xFFFFFFFF)
		{
			uint8_t controller = packet->data[sizeof(header)];

			if (g_pCustomPacketManager->customHandlers.contains(controller))
			{
				bool shouldFallback = true;
				const auto callback = g_pCustomPacketManager->customHandlers.at(controller);
				callback(packetHandler, packet, shouldFallback);

				if (!shouldFallback)
				{
					return true;
				}
			}
		}
	}

	// check rate limits for the original unconnected packets
	if (!g_pServerLimits->CheckConnectionlessPacketLimits(packet))
	{
		return false;
	}

	return o_pHandlePacket(packetHandler, packet);
}

bool CustomPacketManager::RegisterPacketHandler(uint8_t controller, CustomPacketHandlerType handler)
{

	if (customHandlers.contains(controller))
	{
		NS::log::NORTHSTAR->error("Tried to register a custom packet handler for {}, which is already taken", controller);
		return false;
	}

	if (nativeHandlers.contains(controller))
	{
		NS::log::NORTHSTAR->error("Tried to register a custom packet handler for {}, which is already a native handler", controller);
		return false;
	}

	customHandlers.insert(std::make_pair(controller, handler));
	return true;
}

void CustomPacketManager::RegisterPacketHook()
{
	const auto module = CModule("engine.dll");
	assert(module.GetModuleBase()); // Make sure it is proper

	o_pHandlePacket = module.Offset(0x117800).RCast<decltype(o_pHandlePacket)>();
	HookAttach(&(PVOID&)o_pHandlePacket, (PVOID)h_HandlePacket);
}

ON_DLL_LOAD("engine.dll", CustomPacketManager, (CModule module))
{
	assert(g_pCustomPacketManager);
	g_pCustomPacketManager->RegisterPacketHook();
}
