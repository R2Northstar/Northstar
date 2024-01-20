#pragma once

#include "core/math/vector.h"

// server entity stuff
class CBaseEntity;
extern CBaseEntity* (*Server_GetEntityByIndex)(int index);

#pragma pack(push, 1)
class CBasePlayer
{
public:
	char _unk_0x0[88]; // 0x0 ( Size: 88 )
	uint32_t m_nPlayerIndex; // 0x58 ( Size: 4 )
	char _unk_0x5c[572]; // 0x5c ( Size: 572 )
	int32_t m_fFlags; // 0x298 ( Size: 4 )
	char _unk_0x29c[376]; // 0x29c ( Size: 376 )
	int32_t m_hGroundEntity; // 0x414 ( Size: 4 )
	char _unk_0x418[184]; // 0x418 ( Size: 184 )
	int32_t m_iMaxHealth; // 0x4d0 ( Size: 4 )
	int32_t m_iHealth; // 0x4d4 ( Size: 4 )
	char _unk_0x4d8[25]; // 0x4d8 ( Size: 25 )
	int32_t m_lifeState; // 0x4f1 ( Size: 4 )
	char _unk_0x4f5[23]; // 0x4f5 ( Size: 23 )
	float m_flMaxspeed; // 0x50c ( Size: 4 )
	char _unk_0x510[1268]; // 0x510 ( Size: 1268 )
	int32_t m_camoIndex; // 0xa04 ( Size: 4 )
	int32_t m_decalIndex; // 0xa08 ( Size: 4 )
	char _unk_0xa0c[2380]; // 0xa0c ( Size: 2380 )
	int32_t m_selectedOffhandPendingHybridAction; // 0x1358 ( Size: 4 )
	char _unk_0x135c[92]; // 0x135c ( Size: 92 )
	int32_t m_titanSoul; // 0x13b8 ( Size: 4 )
	char _unk_0x13bc[476]; // 0x13bc ( Size: 476 )
	bool m_bZooming; // 0x1598 ( Size: 1 )
	bool m_zoomToggleOn; // 0x1599 ( Size: 1 )
	char _unk_0x159a[2]; // 0x159a ( Size: 2 )
	float m_zoomBaseFrac; // 0x159c ( Size: 4 )
	float m_zoomBaseTime; // 0x15a0 ( Size: 4 )
	float m_zoomFullStartTime; // 0x15a4 ( Size: 4 )
	char _unk_0x15a8[1080]; // 0x15a8 ( Size: 1080 )
	int32_t m_PlayerFog__m_hCtrl; // 0x19e0 ( Size: 4 )
	char _unk_0x19e4[388]; // 0x19e4 ( Size: 388 )
	int32_t m_hColorCorrectionCtrl; // 0x1b68 ( Size: 4 )
	char _unk_0x1b6c[292]; // 0x1b6c ( Size: 292 )
	bool m_hasBadReputation; // 0x1c90 ( Size: 1 )
	char m_communityName[64]; // 0x1c91 ( Size: 64 )
	char m_communityClanTag[16]; // 0x1cd1 ( Size: 16 )
	char m_factionName[16]; // 0x1ce1 ( Size: 16 )
	char m_hardwareIcon[16]; // 0x1cf1 ( Size: 16 )
	bool m_happyHourActive; // 0x1d01 ( Size: 1 )
	char _unk_0x1d02[6]; // 0x1d02 ( Size: 6 )
	uint32_t m_platformUserId; // 0x1d08 ( Size: 4 )
	char _unk_0x1d0c[4]; // 0x1d0c ( Size: 4 )
	int32_t m_classModsActive; // 0x1d10 ( Size: 4 )
	char _unk_0x1d14[120]; // 0x1d14 ( Size: 120 )
	int32_t m_posClassModsActive; // 0x1d8c ( Size: 4 )
	char _unk_0x1d90[60]; // 0x1d90 ( Size: 60 )
	bool m_passives; // 0x1dcc ( Size: 1 )
	char _unk_0x1dcd[179]; // 0x1dcd ( Size: 179 )
	int32_t m_titanSoulBeingRodeoed; // 0x1e80 ( Size: 4 )
	int32_t m_entitySyncingWithMe; // 0x1e84 ( Size: 4 )
	int32_t m_playerFlags; // 0x1e88 ( Size: 4 )
	bool m_hasMic; // 0x1e8c ( Size: 1 )
	bool m_inPartyChat; // 0x1e8d ( Size: 1 )
	char _unk_0x1e8e[2]; // 0x1e8e ( Size: 2 )
	float m_playerMoveSpeedScale; // 0x1e90 ( Size: 4 )
	char _unk_0x1e94[96]; // 0x1e94 ( Size: 96 )
	int32_t m_gestureAutoKillBitfield; // 0x1ef4 ( Size: 4 )
	char _unk_0x1ef8[12]; // 0x1ef8 ( Size: 12 )
	int32_t m_remoteTurret; // 0x1f04 ( Size: 4 )
	char _unk_0x1f08[56]; // 0x1f08 ( Size: 56 )
	float m_damageImpulseNoDecelEndTime; // 0x1f40 ( Size: 4 )
	char _unk_0x1f44[20]; // 0x1f44 ( Size: 20 )
	float m_flDeathTime; // 0x1f58 ( Size: 4 )
	char _unk_0x1f5c[8]; // 0x1f5c ( Size: 8 )
	int32_t m_iObserverMode; // 0x1f64 ( Size: 4 )
	char _unk_0x1f68[4]; // 0x1f68 ( Size: 4 )
	int32_t m_hObserverTarget; // 0x1f6c ( Size: 4 )
	char _unk_0x1f70[52]; // 0x1f70 ( Size: 52 )
	int32_t m_activeBurnCardIndex; // 0x1fa4 ( Size: 4 )
	char _unk_0x1fa8[168]; // 0x1fa8 ( Size: 168 )
	int32_t m_grappleHook; // 0x2050 ( Size: 4 )
	int32_t m_petTitan; // 0x2054 ( Size: 4 )
	char _unk_0x2058[4]; // 0x2058 ( Size: 4 )
	int32_t m_xp; // 0x205c ( Size: 4 )
	int32_t m_generation; // 0x2060 ( Size: 4 )
	int32_t m_rank; // 0x2064 ( Size: 4 )
	int32_t m_serverForceIncreasePlayerListGenerationParity; // 0x2068 ( Size: 4 )
	bool m_isPlayingRanked; // 0x206c ( Size: 1 )
	char _unk_0x206d[3]; // 0x206d ( Size: 3 )
	float m_skill_mu; // 0x2070 ( Size: 4 )
	char _unk_0x2074[4]; // 0x2074 ( Size: 4 )
	float m_nextTitanRespawnAvailable; // 0x2078 ( Size: 4 )
	char _unk_0x207c[28]; // 0x207c ( Size: 28 )
	int32_t m_hViewModel; // 0x2098 ( Size: 4 )
	char _unk_0x209c[436]; // 0x209c ( Size: 436 )
	int32_t m_duckState; // 0x2250 ( Size: 4 )
	Vector3 m_StandHullMin; // 0x2254 ( Size: 12 )
	Vector3 m_StandHullMax; // 0x2260 ( Size: 12 )
	Vector3 m_DuckHullMin; // 0x226c ( Size: 12 )
	Vector3 m_DuckHullMax; // 0x2278 ( Size: 12 )
	char _unk_0x2284[92]; // 0x2284 ( Size: 92 )
	bool m_wallHanging; // 0x22e0 ( Size: 1 )
	char _unk_0x22e1[11]; // 0x22e1 ( Size: 11 )
	int32_t m_traversalType; // 0x22ec ( Size: 4 )
	int32_t m_traversalState; // 0x22f0 ( Size: 4 )
	char _unk_0x22f4[40]; // 0x22f4 ( Size: 40 )
	Vector3 m_traversalForwardDir; // 0x231c ( Size: 12 )
	Vector3 m_traversalRefPos; // 0x2328 ( Size: 12 )
	char _unk_0x2334[32]; // 0x2334 ( Size: 32 )
	float m_traversalYawDelta; // 0x2354 ( Size: 4 )
	int32_t m_traversalYawPoseParameter; // 0x2358 ( Size: 4 )
	char _unk_0x235c[140]; // 0x235c ( Size: 140 )
	bool m_grappleActive; // 0x23e8 ( Size: 1 )
	char _unk_0x23e9[19]; // 0x23e9 ( Size: 19 )
	int32_t m_activeZipline; // 0x23fc ( Size: 4 )
	bool m_ziplineReverse; // 0x2400 ( Size: 1 )
	char _unk_0x2401[11]; // 0x2401 ( Size: 11 )
	bool m_ziplineValid3pWeaponLayerAnim; // 0x240c ( Size: 1 )
	char _unk_0x240d[3]; // 0x240d ( Size: 3 )
	int32_t m_ziplineState; // 0x2410 ( Size: 4 )
	char _unk_0x2414[392]; // 0x2414 ( Size: 392 )
	float m_lastDodgeTime; // 0x259c ( Size: 4 )
	char _unk_0x25a0[8]; // 0x25a0 ( Size: 8 )
	bool m_iSpawnParity; // 0x25a8 ( Size: 1 )
	char _unk_0x25a9[21]; // 0x25a9 ( Size: 21 )
	bool m_isPerformingBoostAction; // 0x25be ( Size: 1 )
	char _unk_0x25bf[233]; // 0x25bf ( Size: 233 )
	int32_t m_lastUCmdSimulationTicks; // 0x26a8 ( Size: 4 )
	float m_lastUCmdSimulationRemainderTime; // 0x26ac ( Size: 4 )
	char _unk_0x26b0[12]; // 0x26b0 ( Size: 12 )
	bool m_bShouldDrawPlayerWhileUsingViewEntity; // 0x26bc ( Size: 1 )
	char _unk_0x26bd[259]; // 0x26bd ( Size: 259 )
	int32_t m_autoSprintForced; // 0x27c0 ( Size: 4 )
	bool m_fIsSprinting; // 0x27c4 ( Size: 1 )
	char _unk_0x27c5[7]; // 0x27c5 ( Size: 7 )
	float m_sprintStartedTime; // 0x27cc ( Size: 4 )
	float m_sprintStartedFrac; // 0x27d0 ( Size: 4 )
	float m_sprintEndedTime; // 0x27d4 ( Size: 4 )
	float m_sprintEndedFrac; // 0x27d8 ( Size: 4 )
	float m_stickySprintStartTime; // 0x27dc ( Size: 4 )
	char _unk_0x27e0[4]; // 0x27e0 ( Size: 4 )
	int32_t m_ubEFNointerpParity; // 0x27e4 ( Size: 4 )
	char _unk_0x27e8[96]; // 0x27e8 ( Size: 96 )
	char m_title[32]; // 0x2848 ( Size: 32 )
	char _unk_0x2868[252]; // 0x2868 ( Size: 252 )
	bool m_useCredit; // 0x2964 ( Size: 1 )
	char _unk_0x2965[51]; // 0x2965 ( Size: 51 )
	float m_smartAmmoPreviousHighestLockOnMeFractionValue; // 0x2998 ( Size: 4 )
	char _unk_0x299c[1292]; // 0x299c ( Size: 1292 )
	int32_t m_pilotClassIndex; // 0x2ea8 ( Size: 4 )
	char _unk_0x2eac[1456]; // 0x2eac ( Size: 1456 )
	int32_t m_playerScriptNetDataGlobal; // 0x345c ( Size: 4 )
	char _unk_0x3460[5352]; // 0x3460 ( Size: 5352 )
	int32_t m_selectedOffhand; // 0x4948 ( Size: 4 )
	char _unk_0x494c[1030980]; // 0x494c ( Size: 1030980 )
	Vector3 m_vecAbsOrigin; // 0x100490 ( Size: 12 )
	char _unk_0x10049c[7656]; // 0x10049c ( Size: 7656 )
	Vector3 m_upDir; // 0x102284 ( Size: 12 )
};
#pragma pack(pop)

static_assert(offsetof(CBasePlayer, m_nPlayerIndex) == 0x58);

static_assert(offsetof(CBasePlayer, m_grappleActive) == 0x23e8);
static_assert(offsetof(CBasePlayer, m_platformUserId) == 0x1D08);
static_assert(offsetof(CBasePlayer, m_classModsActive) == 0x1D10);
static_assert(offsetof(CBasePlayer, m_posClassModsActive) == 0x1D8C);
static_assert(offsetof(CBasePlayer, m_passives) == 0x1DCC);
static_assert(offsetof(CBasePlayer, m_selectedOffhand) == 0x4948);
static_assert(offsetof(CBasePlayer, m_selectedOffhandPendingHybridAction) == 0x1358);
static_assert(offsetof(CBasePlayer, m_playerFlags) == 0x1E88);
static_assert(offsetof(CBasePlayer, m_lastUCmdSimulationTicks) == 0x26A8);
static_assert(offsetof(CBasePlayer, m_lastUCmdSimulationRemainderTime) == 0x26AC);
static_assert(offsetof(CBasePlayer, m_remoteTurret) == 0x1F04);
static_assert(offsetof(CBasePlayer, m_hGroundEntity) == 0x414);
static_assert(offsetof(CBasePlayer, m_titanSoul) == 0x13B8);
static_assert(offsetof(CBasePlayer, m_petTitan) == 0x2054);
static_assert(offsetof(CBasePlayer, m_iHealth) == 0x4D4);
static_assert(offsetof(CBasePlayer, m_iMaxHealth) == 0x4D0);
static_assert(offsetof(CBasePlayer, m_lifeState) == 0x4F1);
static_assert(offsetof(CBasePlayer, m_flMaxspeed) == 0x50C);
static_assert(offsetof(CBasePlayer, m_fFlags) == 0x298);
static_assert(offsetof(CBasePlayer, m_iObserverMode) == 0x1F64);
static_assert(offsetof(CBasePlayer, m_hObserverTarget) == 0x1F6C);
static_assert(offsetof(CBasePlayer, m_hViewModel) == 0x2098);
static_assert(offsetof(CBasePlayer, m_ubEFNointerpParity) == 0x27E4);
static_assert(offsetof(CBasePlayer, m_activeBurnCardIndex) == 0x1FA4);
static_assert(offsetof(CBasePlayer, m_hColorCorrectionCtrl) == 0x1B68);
static_assert(offsetof(CBasePlayer, m_PlayerFog__m_hCtrl) == 0x19E0);
static_assert(offsetof(CBasePlayer, m_bShouldDrawPlayerWhileUsingViewEntity) == 0x26BC);
static_assert(offsetof(CBasePlayer, m_title) == 0x2848);
static_assert(offsetof(CBasePlayer, m_useCredit) == 0x2964);
static_assert(offsetof(CBasePlayer, m_damageImpulseNoDecelEndTime) == 0x1F40);
static_assert(offsetof(CBasePlayer, m_hasMic) == 0x1E8C);
static_assert(offsetof(CBasePlayer, m_inPartyChat) == 0x1E8D);
static_assert(offsetof(CBasePlayer, m_playerMoveSpeedScale) == 0x1E90);
static_assert(offsetof(CBasePlayer, m_flDeathTime) == 0x1F58);
static_assert(offsetof(CBasePlayer, m_iSpawnParity) == 0x25A8);
static_assert(offsetof(CBasePlayer, m_upDir) == 0x102284);
static_assert(offsetof(CBasePlayer, m_lastDodgeTime) == 0x259C);
static_assert(offsetof(CBasePlayer, m_wallHanging) == 0x22E0);
static_assert(offsetof(CBasePlayer, m_traversalType) == 0x22EC);
static_assert(offsetof(CBasePlayer, m_traversalState) == 0x22F0);
static_assert(offsetof(CBasePlayer, m_traversalRefPos) == 0x2328);
static_assert(offsetof(CBasePlayer, m_traversalForwardDir) == 0x231C);
static_assert(offsetof(CBasePlayer, m_traversalYawDelta) == 0x2354);
static_assert(offsetof(CBasePlayer, m_traversalYawPoseParameter) == 0x2358);
static_assert(offsetof(CBasePlayer, m_grappleHook) == 0x2050);
static_assert(offsetof(CBasePlayer, m_autoSprintForced) == 0x27C0);
static_assert(offsetof(CBasePlayer, m_fIsSprinting) == 0x27C4);
static_assert(offsetof(CBasePlayer, m_sprintStartedTime) == 0x27CC);
static_assert(offsetof(CBasePlayer, m_sprintStartedFrac) == 0x27D0);
static_assert(offsetof(CBasePlayer, m_sprintEndedTime) == 0x27D4);
static_assert(offsetof(CBasePlayer, m_sprintEndedFrac) == 0x27D8);
static_assert(offsetof(CBasePlayer, m_stickySprintStartTime) == 0x27DC);
static_assert(offsetof(CBasePlayer, m_smartAmmoPreviousHighestLockOnMeFractionValue) == 0x2998);
static_assert(offsetof(CBasePlayer, m_activeZipline) == 0x23FC);
static_assert(offsetof(CBasePlayer, m_ziplineReverse) == 0x2400);
static_assert(offsetof(CBasePlayer, m_ziplineState) == 0x2410);
static_assert(offsetof(CBasePlayer, m_duckState) == 0x2250);
static_assert(offsetof(CBasePlayer, m_StandHullMin) == 0x2254);
static_assert(offsetof(CBasePlayer, m_StandHullMax) == 0x2260);
static_assert(offsetof(CBasePlayer, m_DuckHullMin) == 0x226C);
static_assert(offsetof(CBasePlayer, m_DuckHullMax) == 0x2278);
static_assert(offsetof(CBasePlayer, m_xp) == 0x205C);
static_assert(offsetof(CBasePlayer, m_generation) == 0x2060);
static_assert(offsetof(CBasePlayer, m_rank) == 0x2064);
static_assert(offsetof(CBasePlayer, m_serverForceIncreasePlayerListGenerationParity) == 0x2068);
static_assert(offsetof(CBasePlayer, m_isPlayingRanked) == 0x206C);
static_assert(offsetof(CBasePlayer, m_skill_mu) == 0x2070);
static_assert(offsetof(CBasePlayer, m_titanSoulBeingRodeoed) == 0x1E80);
static_assert(offsetof(CBasePlayer, m_entitySyncingWithMe) == 0x1E84);
static_assert(offsetof(CBasePlayer, m_nextTitanRespawnAvailable) == 0x2078);
static_assert(offsetof(CBasePlayer, m_hasBadReputation) == 0x1C90);
static_assert(offsetof(CBasePlayer, m_communityName) == 0x1C91);
static_assert(offsetof(CBasePlayer, m_communityClanTag) == 0x1CD1);
static_assert(offsetof(CBasePlayer, m_factionName) == 0x1CE1);
static_assert(offsetof(CBasePlayer, m_hardwareIcon) == 0x1CF1);
static_assert(offsetof(CBasePlayer, m_happyHourActive) == 0x1D01);
static_assert(offsetof(CBasePlayer, m_gestureAutoKillBitfield) == 0x1EF4);
static_assert(offsetof(CBasePlayer, m_pilotClassIndex) == 0x2EA8);
static_assert(offsetof(CBasePlayer, m_vecAbsOrigin) == 0x100490);
static_assert(offsetof(CBasePlayer, m_isPerformingBoostAction) == 0x25BE);
static_assert(offsetof(CBasePlayer, m_ziplineValid3pWeaponLayerAnim) == 0x240C);
static_assert(offsetof(CBasePlayer, m_playerScriptNetDataGlobal) == 0x345C);
static_assert(offsetof(CBasePlayer, m_bZooming) == 0x1598);
static_assert(offsetof(CBasePlayer, m_zoomToggleOn) == 0x1599);
static_assert(offsetof(CBasePlayer, m_zoomBaseFrac) == 0x159C);
static_assert(offsetof(CBasePlayer, m_zoomBaseTime) == 0x15A0);
static_assert(offsetof(CBasePlayer, m_zoomFullStartTime) == 0x15A4);
static_assert(offsetof(CBasePlayer, m_camoIndex) == 0xA04);
static_assert(offsetof(CBasePlayer, m_decalIndex) == 0xA08);

extern CBasePlayer*(__fastcall* UTIL_PlayerByIndex)(int playerIndex);
