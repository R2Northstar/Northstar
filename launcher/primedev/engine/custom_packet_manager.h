#pragma once

struct CustomPacketManager
{
	typedef void (*CustomPacketHandlerType)(void* packetHandler, struct netpacket_s* packet, OUT bool& runOriginalHandler);

public:
	bool RegisterPacketHandler(uint8_t controller, CustomPacketHandlerType handler);
	void RegisterPacketHook();

private:
	static bool (*o_pHandlePacket)(void* packetHandler, netpacket_s* packet);
	static bool h_HandlePacket(void* packetHandler, netpacket_s* packet);

	std::unordered_map<uint8_t, CustomPacketHandlerType> customHandlers {};
};

extern CustomPacketManager* g_pCustomPacketManager;
