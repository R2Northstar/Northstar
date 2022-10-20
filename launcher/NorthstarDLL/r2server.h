#pragma once

#include "vector.h"

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
		char pad1[0x1C34];
		bool m_hasBadReputation; // 0x1C90
		char m_communityName[64]; // 0x1C91
		char m_communityClanTag[16]; // 0x1CD1
		char m_factionName[16]; // 0x1CE1
		char m_hardwareIcon[16]; // 0x1CF1
		bool m_happyHourActive; // 0x1D01
	};
#pragma pack(pop)

	extern CBasePlayer*(__fastcall* UTIL_PlayerByIndex)(int playerIndex);
} // namespace R2
