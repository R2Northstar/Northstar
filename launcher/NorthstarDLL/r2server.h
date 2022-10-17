#pragma once

// use the R2 namespace for game funcs
namespace R2
{
	// server entity stuff
	class CBaseEntity;
	extern CBaseEntity* (*Server_GetEntityByIndex)(int index);

#pragma pack(push, 1)
	struct CBasePlayer
	{
		char pad[0x58];
		uint32_t m_nPlayerIndex;

		// +0x5C
		char pad1[0x1C75];
		char m_communityClanTag[16];
	};
#pragma pack(pop)

	extern CBasePlayer*(__fastcall* UTIL_PlayerByIndex)(int playerIndex);
} // namespace R2
