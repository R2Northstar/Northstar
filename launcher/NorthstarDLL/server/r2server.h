#pragma once

#include "core/math/vector.h"

// use the R2 namespace for game funcs
namespace R2
{
	// server entity stuff
	class CBaseEntity;
	extern CBaseEntity* (*Server_GetEntityByIndex)(int index);

	// clang-format off
	OFFSET_STRUCT(CBasePlayer)
	{
		STRUCT_SIZE(0x1D02);
		FIELD(0x58, uint32_t m_nPlayerIndex)

		FIELD(0x1C90, bool m_hasBadReputation)
		FIELD(0x1C91, char m_communityName[64])
		FIELD(0x1CD1, char m_communityClanTag[16])
		FIELD(0x1CE1, char m_factionName[16])
		FIELD(0x1CF1, char m_hardwareIcon[16])
		FIELD(0x1D01, bool m_happyHourActive)
	};
	// clang-format on

	extern CBasePlayer*(__fastcall* UTIL_PlayerByIndex)(int playerIndex);
} // namespace R2
