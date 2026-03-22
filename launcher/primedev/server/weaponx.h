#pragma once

inline void* CWeaponX_vftable = nullptr;

#pragma pack(push, 1)
struct CWeaponX
{
public:
	void* vftable;
	const char gap_8[4800];
	int currentModBitfield; // 0x12C8
	const char gap_12CC[12]; // 0x12CC
	int m_weaponNameIndex; // 0x12D8
	const char gap_12DC[308]; // 0x12DC
	// this is used by the game as the initial offset
	// for getting eWeaponVar values. No idea about
	// the actual datatype. Start of another struct?
	const char weaponVars[0xCA0]; // 0x1410
};
#pragma pack(pop)
static_assert(offsetof(CWeaponX, weaponVars) == 0x1410);
static_assert(offsetof(CWeaponX, m_weaponNameIndex) == 0x12D8);
