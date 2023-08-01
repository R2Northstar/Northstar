global function DamageTypes_Init
global function RegisterWeaponDamageSourceName
global function GetObitFromDamageSourceID
global function DamageSourceIDToString
global function DamageSourceIDHasString

#if SERVER
global function RegisterWeaponDamageSource
global function RegisterWeaponDamageSources
#endif

struct
{
	table<int,string> damageSourceIDToName
	table<int,string> damageSourceIDToString

	// For new, modded damageSourceIDs.
	// Holds triplets of [id, enum_name, display name]. Stored with no separation for ease of string conversion.
	array<string> customDamageSourceIDList
} file

// For sending custom damage source IDs to clients
const int SOURCE_ID_MAX_MESSAGE_LENGTH = 200 // JFS - Used to break messages sent to client into chunks in case it would hit the limitation on command argument length
const string MESSAGE_SPACE_PADDING = "\xA6" // The "broken pipe" character. Trash character used to replace spaces in display name to allow sending via commands (args are separated by spaces).

global enum eDamageSourceId
{
	invalid 	= -1  // used in code

	//---------------------------
	// defined in damageDef.txt. This will go away ( you can use damagedef_nuclear_core instead of eDamageSourceId.[enum id] and get rid of it from here )
	// once this list has only damagedef_*, then we can remove eDamageSourceId
	code_reserved  				// may be merged with invalid -1 above
	damagedef_unknown		   	// must start at 1 and order must match what's in damageDefs.txt
	damagedef_unknownBugIt
	damagedef_suicide
	damagedef_despawn
	damagedef_titan_step
	damagedef_crush
	damagedef_nuclear_core
	damagedef_titan_fall
	damagedef_titan_hotdrop
	damagedef_reaper_fall
	damagedef_trip_wire
	damagedef_reaper_groundslam
	damagedef_reaper_nuke
	damagedef_frag_drone_explode
	damagedef_frag_drone_explode_FD
	damagedef_frag_drone_throwable_PLAYER
	damagedef_frag_drone_throwable_NPC
	damagedef_stalker_powersupply_explosion_small
	damagedef_stalker_powersupply_explosion_large
	damagedef_stalker_powersupply_explosion_large_at
	damagedef_shield_captain_arc_shield
	damagedef_fd_explosive_barrel
	damagedef_fd_tether_trap

	//---------------------------

	// Titan Weapons
	mp_titanweapon_40mm
	mp_titanweapon_arc_cannon
	mp_titanweapon_arc_wave
	mp_titanweapon_arc_ball
	mp_titanweapon_arc_pylon
	mp_titanweapon_emp_volley
	mp_titanweapon_rocket_launcher
	mp_titanweapon_rocketeer_missile
	mp_titanweapon_rocketeer_rocketstream
	mp_titanweapon_shoulder_rockets
	mp_titanweapon_shoulder_grenade
	mp_titanweapon_orbital_strike
	mp_titanweapon_tether_shot
	mp_titanweapon_homing_rockets
	mp_titanweapon_dumbfire_rockets
	mp_titanweapon_multi_cluster
	mp_titanweapon_meteor
	mp_titanweapon_meteor_thermite
	mp_titanweapon_meteor_thermite_charged
	mp_titanweapon_salvo_rockets
	mp_titanweapon_tracker_rockets
	mp_titanweapon_sniper
	mp_titanweapon_triple_threat
	mp_titanweapon_vortex_shield
	mp_titanweapon_vortex_shield_ion
	mp_titanweapon_xo16
	mp_titanweapon_xo16_shorty
	mp_titanweapon_xopistol
	mp_titanweapon_at_mine
	mp_titanweapon_leadwall
	mp_titanweapon_jackhammer
	mp_titanweapon_electric_fist
	mp_titanweapon_cabertoss
	mp_titanweapon_flame_wall
	mp_titanweapon_flame_ring
	mp_titanweapon_smash
	mp_titanweapon_particle_accelerator
	mp_titanweapon_sticky_40mm
	mp_titanweapon_predator_cannon
	mp_titanweapon_predator_cannon_siege
	mp_titanability_laser_trip
	mp_titanweapon_laser_lite
	mp_titanweapon_stun_laser
	mp_titanability_smoke
	mp_titanability_arc_field
	mp_titanweapon_arc_minefield
	mp_titanability_hover
	mp_titanability_cloak
	mp_titanability_tether_trap

	mp_titancore_amp_core
	mp_titancore_emp
	mp_titancore_flame_wave
	mp_titancore_flame_wave_secondary
	mp_titancore_laser_cannon
	mp_titancore_nuke_core
	mp_titancore_nuke_missile
	mp_titanweapon_berserker
	mp_titancore_shift_core
	mp_titanweapon_flightcore_rockets
	mp_titancore_salvo_core
	mp_titancore_siege_mode

	//SP weapons
	mp_weapon_grenade_electric_smoke
	proto_titanweapon_deathblossom

	// Pilot Weapons
	mp_weapon_hemlok
	mp_weapon_lmg
	mp_weapon_rspn101
	mp_weapon_vinson
	mp_weapon_lstar
	mp_weapon_g2
	mp_weapon_smart_pistol
	mp_weapon_r97
	mp_weapon_car
	mp_weapon_hemlok_smg
	mp_weapon_dmr
	mp_weapon_wingman
	mp_weapon_wingman_n
	mp_weapon_semipistol
	mp_weapon_autopistol
	mp_weapon_mgl
	mp_weapon_sniper
	mp_weapon_shotgun
	mp_weapon_mastiff
	mp_weapon_frag_drone
	mp_weapon_frag_grenade
	mp_weapon_grenade_emp
	mp_weapon_arc_blast
	mp_weapon_thermite_grenade
	mp_weapon_grenade_sonar
	mp_weapon_grenade_gravity
	mp_weapon_satchel
	mp_weapon_nuke_satchel
	mp_weapon_proximity_mine
	mp_weapon_smr
	mp_weapon_rocket_launcher
	mp_weapon_arc_launcher
	mp_weapon_defender
	mp_weapon_dash_melee
	mp_weapon_tether
	mp_weapon_tripwire
	mp_weapon_flak_rifle
	mp_extreme_environment
	mp_weapon_shotgun_pistol
	mp_weapon_pulse_lmg
	mp_weapon_sword
	mp_weapon_softball
	mp_weapon_shotgun_doublebarrel
	mp_weapon_doubletake
	mp_weapon_arc_rifle
	mp_weapon_gibber_pistol
	mp_weapon_alternator_smg
	mp_weapon_esaw
	mp_weapon_epg
	mp_weapon_arena1
	mp_weapon_arena2
	mp_weapon_arena3
	mp_weapon_rspn101_og

	//
	melee_pilot_emptyhanded
	melee_pilot_arena
	melee_pilot_sword
	melee_titan_punch
	melee_titan_punch_ion
	melee_titan_punch_tone
	melee_titan_punch_legion
	melee_titan_punch_scorch
	melee_titan_punch_northstar
	melee_titan_punch_fighter
	melee_titan_punch_vanguard
	melee_titan_sword
	melee_titan_sword_aoe

	mp_weapon_engineer_turret

	// Turret Weapons
	mp_weapon_yh803
	mp_weapon_yh803_bullet
	mp_weapon_yh803_bullet_overcharged
	mp_weapon_mega_turret
	mp_weapon_mega_turret_aa
	mp_turretweapon_rockets
	mp_turretweapon_blaster
	mp_turretweapon_plasma
	mp_turretweapon_sentry

	// AI only Weapons
	mp_weapon_super_spectre
	mp_weapon_dronebeam
	mp_weapon_dronerocket
	mp_weapon_droneplasma
	mp_weapon_turretplasma
	mp_weapon_turretrockets
	mp_weapon_turretplasma_mega
	mp_weapon_gunship_launcher
	mp_weapon_gunship_turret
	mp_weapon_gunship_missile

	// Misc
	rodeo
	rodeo_forced_titan_eject //For awarding points when you force a pilot to eject via rodeo
	rodeo_execution
	human_melee
	auto_titan_melee
	berserker_melee
	mind_crime
	charge_ball
	grunt_melee
	spectre_melee
	prowler_melee
	super_spectre_melee
	titan_execution
	human_execution
	eviscerate
	wall_smash
	ai_turret
	team_switch
	rocket
	titan_explosion
	flash_surge
	molotov
	sticky_time_bomb
	vortex_grenade
	droppod_impact
	ai_turret_explosion
	rodeo_trap
	round_end
	bubble_shield
	evac_dropship_explosion
	sticky_explosive
	titan_grapple

	// streaks
	satellite_strike

	// Environmental
	fall
	splat
	crushed
	burn
	lasergrid
	outOfBounds
	indoor_inferno
	submerged
	switchback_trap
	floor_is_lava
	suicideSpectreAoE
	titanEmpField
	stuck
	deadly_fog
	exploding_barrel
	electric_conduit
	turbine
	harvester_beam
	toxic_sludge

	mp_weapon_spectre_spawner

	// development
	weapon_cubemap

	// Prototype
	mp_weapon_zipline
	mp_ability_ground_slam
	sp_weapon_arc_tool
	sp_weapon_proto_battery_charger_offhand
	at_turret_override
	rodeo_battery_removal
	phase_shift
	gamemode_bomb_detonation
	nuclear_turret
	proto_viewmodel_test
	mp_titanweapon_heat_shield
	mp_titanability_slow_trap
	mp_titanability_gun_shield
	mp_titanability_power_shot
	mp_titanability_ammo_swap
	mp_titanability_sonar_pulse
	mp_titanability_rearm
	mp_titancore_upgrade
	mp_titanweapon_xo16_vanguard
	mp_weapon_arc_trap
	core_overload

	bombardment
	bleedout
	//damageSourceId=eDamageSourceId.xxxxx
	//fireteam
	//marvin
	//rocketstrike
	//orbitallaser
	//explosion
}

//When adding new mods, they need to be added below and to persistent_player_data_version_N.pdef in r1/cfg/server.
//Then when updating that file, save a new one and increment N.

global enum eModSourceId
{
	accelerator
	afterburners
	arc_triple_threat
	aog
	burn_mod_autopistol
	burn_mod_car
	burn_mod_defender
	burn_mod_dmr
	burn_mod_emp_grenade
	burn_mod_frag_grenade
	burn_mod_grenade_electric_smoke
	burn_mod_grenade_gravity
	burn_mod_thermite_grenade
	burn_mod_g2
	burn_mod_hemlok
	burn_mod_lmg
	burn_mod_mgl
	burn_mod_r97
	burn_mod_rspn101
	burn_mod_satchel
	burn_mod_semipistol
	burn_mod_smart_pistol
	burn_mod_smr
	burn_mod_sniper
	burn_mod_rocket_launcher
	burn_mod_titan_40mm
	burn_mod_titan_arc_cannon
	burn_mod_titan_rocket_launcher
	burn_mod_titan_sniper
	burn_mod_titan_triple_threat
	burn_mod_titan_xo16
	burn_mod_titan_dumbfire_rockets
	burn_mod_titan_homing_rockets
	burn_mod_titan_salvo_rockets
	burn_mod_titan_shoulder_rockets
	burn_mod_titan_vortex_shield
	burn_mod_titan_smoke
	burn_mod_titan_particle_wall
	burst
	capacitor
	enhanced_targeting
	extended_ammo
	fast_lock
	fast_reload
	guided_missile
	hcog
	holosight
	instant_shot
	iron_sights
	overcharge
	quick_shot
	rapid_fire_missiles
	scope_4x
	scope_6x
	scope_8x
	scope_10x
	scope_12x
	burn_mod_shotgun
	silencer
	slammer
	spread_increase_ttt
	stabilizer
	titanhammer
	burn_mod_wingman
	burn_mod_lstar
	burn_mod_mastiff
	burn_mod_vinson
	ricochet
	ar_trajectory
	redline_sight
	threat_scope
	smart_lock
	pro_screen
	rocket_arena
}

//Attachments intentionally left off. This prevents them from displaying in kill cards.
// modNameStrings should be defined when the mods are created, not in a separate table -Mackey
global const modNameStrings = {
	[ eModSourceId.accelerator ]						= "#MOD_ACCELERATOR_NAME",
	[ eModSourceId.afterburners ]						= "#MOD_AFTERBURNERS_NAME",
	[ eModSourceId.arc_triple_threat ] 					= "#MOD_ARC_TRIPLE_THREAT_NAME",
	[ eModSourceId.burn_mod_autopistol ] 				= "#BC_AUTOPISTOL_M2",
	[ eModSourceId.burn_mod_car ] 						= "#BC_CAR_M2",
	[ eModSourceId.burn_mod_defender ] 					= "#BC_DEFENDER_M2",
	[ eModSourceId.burn_mod_dmr ] 						= "#BC_DMR_M2",
	[ eModSourceId.burn_mod_emp_grenade ] 				= "#BC_EMP_GRENADE_M2",
	[ eModSourceId.burn_mod_frag_grenade ] 				= "#BC_FRAG_GRENADE_M2",
	[ eModSourceId.burn_mod_grenade_electric_smoke ] 	= "#BC_GRENADE_ELECTRIC_SMOKE_M2",
	[ eModSourceId.burn_mod_grenade_gravity ] 			= "#BC_GRENADE_ELECTRIC_SMOKE_M2",
	[ eModSourceId.burn_mod_thermite_grenade ] 			= "#BC_GRENADE_ELECTRIC_SMOKE_M2",
	[ eModSourceId.burn_mod_g2 ] 						= "#BC_G2_M2",
	[ eModSourceId.burn_mod_hemlok ] 					= "#BC_HEMLOK_M2",
	[ eModSourceId.burn_mod_lmg ] 						= "#BC_LMG_M2",
	[ eModSourceId.burn_mod_mgl ] 						= "#BC_MGL_M2",
	[ eModSourceId.burn_mod_r97 ] 						= "#BC_R97_M2",
	[ eModSourceId.burn_mod_rspn101 ] 					= "#BC_RSPN101_M2",
	[ eModSourceId.burn_mod_satchel ] 					= "#BC_SATCHEL_M2",
	[ eModSourceId.burn_mod_semipistol ] 				= "#BC_SEMIPISTOL_M2",
	[ eModSourceId.burn_mod_smr ] 						= "#BC_SMR_M2",
	[ eModSourceId.burn_mod_smart_pistol ] 				= "#BC_SMART_PISTOL_M2",
	[ eModSourceId.burn_mod_sniper ] 					= "#BC_SNIPER_M2",
	[ eModSourceId.burn_mod_rocket_launcher ] 			= "#BC_ROCKET_LAUNCHER_M2",
	[ eModSourceId.burn_mod_titan_40mm ] 				= "#BC_TITAN_40MM_M2",
	[ eModSourceId.burn_mod_titan_arc_cannon ] 			= "#BC_TITAN_ARC_CANNON_M2",
	[ eModSourceId.burn_mod_titan_rocket_launcher ] 	= "#BC_TITAN_ROCKET_LAUNCHER_M2",
	[ eModSourceId.burn_mod_titan_sniper ] 				= "#BC_TITAN_SNIPER_M2",
	[ eModSourceId.burn_mod_titan_triple_threat ] 		= "#BC_TITAN_TRIPLE_THREAT_M2",
	[ eModSourceId.burn_mod_titan_xo16 ]			 	= "#BC_TITAN_XO16_M2",
	[ eModSourceId.burn_mod_titan_dumbfire_rockets ] 	= "#BC_TITAN_DUMBFIRE_MISSILE_M2",
	[ eModSourceId.burn_mod_titan_homing_rockets ] 		= "#BC_TITAN_HOMING_ROCKETS_M2",
	[ eModSourceId.burn_mod_titan_salvo_rockets ] 		= "#BC_TITAN_SALVO_ROCKETS_M2",
	[ eModSourceId.burn_mod_titan_shoulder_rockets ] 	= "#BC_TITAN_SHOULDER_ROCKETS_M2",
	[ eModSourceId.burn_mod_titan_vortex_shield ] 		= "#BC_TITAN_VORTEX_SHIELD_M2",
	[ eModSourceId.burn_mod_titan_smoke ] 				= "#BC_TITAN_ELECTRIC_SMOKE_M2",
	[ eModSourceId.burn_mod_titan_particle_wall ] 		= "#BC_TITAN_SHIELD_WALL_M2",
	[ eModSourceId.burst ] 								= "#MOD_BURST_NAME",
	[ eModSourceId.capacitor ] 							= "#MOD_CAPACITOR_NAME",
	[ eModSourceId.enhanced_targeting ] 				= "#MOD_ENHANCED_TARGETING_NAME",
	[ eModSourceId.extended_ammo ] 						= "#MOD_EXTENDED_MAG_NAME",
	[ eModSourceId.fast_reload ] 						= "#MOD_FAST_RELOAD_NAME",
	[ eModSourceId.instant_shot ]						= "#MOD_INSTANT_SHOT_NAME",
	[ eModSourceId.overcharge ] 						= "#MOD_OVERCHARGE_NAME",
	[ eModSourceId.quick_shot ]							= "#MOD_QUICK_SHOT_NAME",
	[ eModSourceId.rapid_fire_missiles ] 				= "#MOD_RAPID_FIRE_MISSILES_NAME",
	[ eModSourceId.burn_mod_shotgun ] 					= "#BC_SHOTGUN_M2",
	[ eModSourceId.silencer ] 							= "#MOD_SILENCER_NAME",
	[ eModSourceId.slammer ] 							= "#MOD_SLAMMER_NAME",
	[ eModSourceId.spread_increase_ttt ]				= "#MOD_SPREAD_INCREASE_TTT_NAME",
	[ eModSourceId.stabilizer ]							= "#MOD_STABILIZER_NAME",
	[ eModSourceId.titanhammer ] 						= "#MOD_TITANHAMMER_NAME",
	[ eModSourceId.burn_mod_wingman ]					= "#BC_WINGMAN_M2",
	[ eModSourceId.burn_mod_lstar ]						= "#BC_LSTAR_M2",
	[ eModSourceId.burn_mod_mastiff ]					= "#BC_MASTIFF_M2",
	[ eModSourceId.burn_mod_vinson ]					= "#BC_VINSON_M2",
	[ eModSourceId.ricochet ]							= "Ricochet",
	[ eModSourceId.ar_trajectory ]						= "AR Trajectory",
	[ eModSourceId.smart_lock ]							= "Smart Lock",
	[ eModSourceId.pro_screen ]							= "Pro Screen",
	[ eModSourceId.rocket_arena ]						= "Rocket Arena",
}

void function DamageTypes_Init()
{
	#if SERVER
	AddCallback_OnClientConnected( SendNewDamageSourceIDsConnected )
	#else
	AddServerToClientStringCommandCallback( "register_damage_source_ids", ReceiveNewDamageSourceIDs )
	#endif

	foreach ( name, number in eDamageSourceId )
	{
		file.damageSourceIDToString[ number ] <- name
	}

	PrecacheWeapon( "mp_weapon_rspn101" ) // used by npc_soldier ><

#if DEV

	int numDamageDefs = DamageDef_GetCount()
	table damageSourceIdEnum = expect table( getconsttable().eDamageSourceId )
	foreach ( name, id in damageSourceIdEnum )
	{
		expect int( id )
		if ( id <= eDamageSourceId.code_reserved || id >= numDamageDefs )
			continue

		string damageDefName = DamageDef_GetName( id )
		Assert( damageDefName == name, "damage def (" + id + ") name: '" + damageDefName + "' doesn't match damage source id '" + name + "'" )
	}
#endif

	file.damageSourceIDToName =
	{
		//sp
		[ eDamageSourceId.mp_weapon_grenade_electric_smoke ]		= "#DEATH_ELECTRIC_SMOKE_SCREEN",
		[ eDamageSourceId.proto_titanweapon_deathblossom ] 			= "#WPN_TITAN_ROCKET_LAUNCHER",

		//mp
		[ eDamageSourceId.mp_extreme_environment ] 					= "#DAMAGE_EXTREME_ENVIRONMENT",

		[ eDamageSourceId.mp_weapon_engineer_turret ] 				= "#WPN_ENGINEER_TURRET",

		[ eDamageSourceId.mp_weapon_yh803 ] 						= "#WPN_LIGHT_TURRET",
		[ eDamageSourceId.mp_weapon_yh803_bullet ]					= "#WPN_LIGHT_TURRET",
		[ eDamageSourceId.mp_weapon_yh803_bullet_overcharged ]		= "#WPN_LIGHT_TURRET",
		[ eDamageSourceId.mp_weapon_mega_turret ]					= "#WPN_MEGA_TURRET",
		[ eDamageSourceId.mp_weapon_mega_turret_aa ]				= "#WPN_MEGA_TURRET",
		[ eDamageSourceId.mp_turretweapon_rockets ]					= "#WPN_TURRET_ROCKETS",
		[ eDamageSourceId.mp_weapon_super_spectre ]					= "#WPN_SUPERSPECTRE_ROCKETS",
		[ eDamageSourceId.mp_weapon_dronebeam ] 					= "#WPN_DRONERBEAM",
		[ eDamageSourceId.mp_weapon_dronerocket ] 					= "#WPN_DRONEROCKET",
		[ eDamageSourceId.mp_weapon_droneplasma ] 					= "#WPN_DRONEPLASMA",
		[ eDamageSourceId.mp_weapon_turretplasma ] 					= "#WPN_TURRETPLASMA",
		[ eDamageSourceId.mp_weapon_turretrockets ] 				= "#WPN_TURRETROCKETS",
		[ eDamageSourceId.mp_weapon_turretplasma_mega ] 			= "#WPN_TURRETPLASMA_MEGA",
		[ eDamageSourceId.mp_weapon_gunship_launcher ] 				= "#WPN_GUNSHIP_LAUNCHER",
		[ eDamageSourceId.mp_weapon_gunship_turret ]				= "#WPN_GUNSHIP_TURRET",
		[ eDamageSourceId.mp_weapon_gunship_turret ]				= "#WPN_GUNSHIP_MISSILE",

		[ eDamageSourceId.mp_titanability_smoke ]					= "#DEATH_ELECTRIC_SMOKE_SCREEN",
		[ eDamageSourceId.mp_titanability_laser_trip ]				= "#DEATH_LASER_TRIPWIRE",
		[ eDamageSourceId.mp_titanability_slow_trap ]				= "#DEATH_SLOW_TRAP",
		[ eDamageSourceId.mp_titanability_tether_trap ]				= "#DEATH_TETHER_TRAP",

		[ eDamageSourceId.rodeo ] 									= "#DEATH_TITAN_RODEO",
		[ eDamageSourceId.rodeo_forced_titan_eject ] 				= "#DEATH_TITAN_RODEO",
		[ eDamageSourceId.rodeo_execution ] 						= "#DEATH_RODEO_EXECUTION",
		[ eDamageSourceId.nuclear_turret ] 							= "#DEATH_NUCLEAR_TURRET",
		[ eDamageSourceId.mp_titanweapon_flightcore_rockets ] 		= "#WPN_TITAN_FLIGHT_ROCKET",
		[ eDamageSourceId.mp_titancore_amp_core ]					= "#TITANCORE_AMP_CORE",
		[ eDamageSourceId.mp_titancore_emp ] 						= "#TITANCORE_EMP",
		[ eDamageSourceId.mp_titancore_siege_mode ]					= "#TITANCORE_SIEGE_MODE",
		[ eDamageSourceId.mp_titancore_flame_wave ]					= "#TITANCORE_FLAME_WAVE",
		[ eDamageSourceId.mp_titancore_flame_wave_secondary ]		= "#GEAR_SCORCH_FLAMECORE",
		[ eDamageSourceId.mp_titancore_nuke_core ] 					= "#TITANCORE_NUKE",
		[ eDamageSourceId.mp_titancore_nuke_missile ]				= "#TITANCORE_NUKE_MISSILE",
		[ eDamageSourceId.mp_titancore_shift_core ]					= "#TITANCORE_SWORD",
		[ eDamageSourceId.berserker_melee ]							= "#DEATH_BERSERKER_MELEE",
		[ eDamageSourceId.human_melee ] 							= "#DEATH_HUMAN_MELEE",
		[ eDamageSourceId.auto_titan_melee ] 						= "#DEATH_AUTO_TITAN_MELEE",

		[ eDamageSourceId.prowler_melee ] 							= "#DEATH_PROWLER_MELEE",
		[ eDamageSourceId.super_spectre_melee ] 					= "#DEATH_SUPER_SPECTRE",
		[ eDamageSourceId.grunt_melee ] 							= "#DEATH_GRUNT_MELEE",
		[ eDamageSourceId.spectre_melee ] 							= "#DEATH_SPECTRE_MELEE",
		[ eDamageSourceId.eviscerate ]	 							= "#DEATH_EVISCERATE",
		[ eDamageSourceId.wall_smash ] 								= "#DEATH_WALL_SMASH",
		[ eDamageSourceId.ai_turret ] 								= "#DEATH_TURRET",
		[ eDamageSourceId.team_switch ] 							= "#DEATH_TEAM_CHANGE",
		[ eDamageSourceId.rocket ] 									= "#DEATH_ROCKET",
		[ eDamageSourceId.titan_explosion ] 						= "#DEATH_TITAN_EXPLOSION",
		[ eDamageSourceId.evac_dropship_explosion ] 				= "#DEATH_EVAC_DROPSHIP_EXPLOSION",
		[ eDamageSourceId.flash_surge ] 							= "#DEATH_FLASH_SURGE",
		[ eDamageSourceId.molotov ] 								= "#DEATH_MOLOTOV",
		[ eDamageSourceId.sticky_time_bomb ] 						= "#DEATH_STICKY_TIME_BOMB",
		[ eDamageSourceId.vortex_grenade ] 							= "#DEATH_VORTEX_GRENADE",
		[ eDamageSourceId.droppod_impact ] 							= "#DEATH_DROPPOD_CRUSH",
		[ eDamageSourceId.ai_turret_explosion ] 					= "#DEATH_TURRET_EXPLOSION",
		[ eDamageSourceId.rodeo_trap ] 								= "#DEATH_RODEO_TRAP",
		[ eDamageSourceId.round_end ] 								= "#DEATH_ROUND_END",
		[ eDamageSourceId.burn ]	 								= "#DEATH_BURN",
		[ eDamageSourceId.mind_crime ]								= "Mind Crime",
		[ eDamageSourceId.charge_ball ]								= "Charge Ball",
		[ eDamageSourceId.mp_titanweapon_rocketeer_missile ]		= "Rocketeer Missile",
		[ eDamageSourceId.core_overload ]							= "#DEATH_CORE_OVERLOAD",
		[ eDamageSourceId.mp_weapon_arc_trap ]						= "#WPN_ARC_TRAP",


		[ eDamageSourceId.mp_turretweapon_sentry ] 					= "#WPN_SENTRY_TURRET",
		[ eDamageSourceId.mp_turretweapon_blaster ] 				= "#WPN_BLASTER_TURRET",
		[ eDamageSourceId.mp_turretweapon_rockets ] 				= "#WPN_ROCKET_TURRET",
		[ eDamageSourceId.mp_turretweapon_plasma ]	 				= "#WPN_PLASMA_TURRET",

		[ eDamageSourceId.bubble_shield ] 							= "#DEATH_BUBBLE_SHIELD",
		[ eDamageSourceId.sticky_explosive ] 						= "#DEATH_STICKY_EXPLOSIVE",
		[ eDamageSourceId.titan_grapple ] 							= "#DEATH_TITAN_GRAPPLE",

		[ eDamageSourceId.satellite_strike ] 						= "#DEATH_SATELLITE_STRIKE",

		[ eDamageSourceId.mp_titanweapon_meteor ] 					= "#WPN_TITAN_METEOR",
		[ eDamageSourceId.mp_titanweapon_meteor_thermite ]			= "#WPN_TITAN_METEOR",
		[ eDamageSourceId.mp_titanweapon_meteor_thermite_charged ]	= "Thermite Meteor",
		[ eDamageSourceId.mp_titanweapon_flame_ring ]				= "Flame Wreath",

		// Instant death. Show no percentages on death recap.
		[ eDamageSourceId.fall ]		 							= "#DEATH_FALL",
		 //Todo: Rename eDamageSourceId.splat with a more appropriate name. This damage type was used for enviornmental damage, but it was for eject killing pilots if they were near a ceiling. I've changed the localized string to "Enviornment Damage", but this will cause confusion in the future.
		[ eDamageSourceId.splat ] 									= "#DEATH_SPLAT",
		[ eDamageSourceId.titan_execution ] 						= "#DEATH_TITAN_EXECUTION",
		[ eDamageSourceId.human_execution ] 						= "#DEATH_HUMAN_EXECUTION",
		[ eDamageSourceId.outOfBounds ] 							= "#DEATH_OUT_OF_BOUNDS",
		[ eDamageSourceId.indoor_inferno ]	 						= "#DEATH_INDOOR_INFERNO",
		[ eDamageSourceId.submerged ]								= "#DEATH_SUBMERGED",
		[ eDamageSourceId.switchback_trap ]							= "#DEATH_ELECTROCUTION", // Damages teammates and opposing team
		[ eDamageSourceId.floor_is_lava ]							= "#DEATH_ELECTROCUTION",
		[ eDamageSourceId.suicideSpectreAoE ]						= "#DEATH_SUICIDE_SPECTRE", // Used for distinguishing the initial spectre from allies.
		[ eDamageSourceId.titanEmpField ] 							= "#DEATH_TITAN_EMP_FIELD",
		[ eDamageSourceId.deadly_fog ] 								= "#DEATH_DEADLY_FOG",


		// Prototype
		[ eDamageSourceId.mp_weapon_zipline ]						= "Zipline",
		[ eDamageSourceId.mp_ability_ground_slam ]					= "Ground Slam",
		[ eDamageSourceId.sp_weapon_arc_tool ]						= "#WPN_ARC_TOOL",
		[ eDamageSourceId.sp_weapon_proto_battery_charger_offhand ]	= "Battery Charger",
		[ eDamageSourceId.at_turret_override ]						= "AT Turret",
		[ eDamageSourceId.phase_shift ]								= "#WPN_SHIFTER",
		[ eDamageSourceId.gamemode_bomb_detonation ]				= "Bomb Detonation",
		[ eDamageSourceId.bleedout ]								= "#DEATH_BLEEDOUT",

		[ eDamageSourceId.damagedef_unknownBugIt ] 					= "#DEATH_GENERIC_KILLED",
		[ eDamageSourceId.damagedef_unknown ] 						= "#DEATH_GENERIC_KILLED",
		[ eDamageSourceId.weapon_cubemap ] 							= "#DEATH_GENERIC_KILLED",
		[ eDamageSourceId.stuck ]		 							= "#DEATH_GENERIC_KILLED",
		[ eDamageSourceId.rodeo_battery_removal ]					= "#DEATH_RODEO_BATTERY_REMOVAL",

		[ eDamageSourceId.melee_pilot_emptyhanded ] 				= "#DEATH_MELEE",
		[ eDamageSourceId.melee_pilot_arena ]		 				= "#DEATH_MELEE",
		[ eDamageSourceId.melee_pilot_sword ] 						= "#DEATH_SWORD",
		[ eDamageSourceId.melee_titan_punch ] 						= "#DEATH_TITAN_MELEE",
		[ eDamageSourceId.melee_titan_punch_ion ] 					= "#DEATH_TITAN_MELEE",
		[ eDamageSourceId.melee_titan_punch_tone ] 					= "#DEATH_TITAN_MELEE",
		[ eDamageSourceId.melee_titan_punch_northstar ] 			= "#DEATH_TITAN_MELEE",
		[ eDamageSourceId.melee_titan_punch_scorch ] 				= "#DEATH_TITAN_MELEE",
		[ eDamageSourceId.melee_titan_punch_legion ] 				= "#DEATH_TITAN_MELEE",
		[ eDamageSourceId.melee_titan_punch_fighter ]		 		= "#DEATH_TITAN_MELEE",
		[ eDamageSourceId.melee_titan_punch_vanguard ] 				= "#DEATH_TITAN_MELEE",
		[ eDamageSourceId.melee_titan_sword ]						= "#DEATH_TITAN_SWORD",
		[ eDamageSourceId.melee_titan_sword_aoe ]					= "#DEATH_TITAN_SWORD",
		[ eDamageSourceId.mp_titanweapon_arc_cannon ]				= "#WPN_TITAN_ARC_CANNON_SHORT",
		[ eDamageSourceId.mp_weapon_shotgun_doublebarrel ]			= "#WPN_SHOTGUN_DBLBARREL_SHORT"
	}

	#if DEV
		//development, with retail versions incase a rare bug happens we dont want to show developer text
		file.damageSourceIDToName[ eDamageSourceId.damagedef_unknownBugIt ] 			= "UNKNOWN! BUG IT!"
		file.damageSourceIDToName[ eDamageSourceId.damagedef_unknown ] 				= "Unknown"
		file.damageSourceIDToName[ eDamageSourceId.weapon_cubemap ] 					= "Cubemap"
		//file.damageSourceIDToName[ eDamageSourceId.invalid ] 						= "INVALID (BUG IT!)"
		file.damageSourceIDToName[ eDamageSourceId.stuck ]		 					= "NPC got Stuck (Don't Bug it!)"
	#endif
}

void function RegisterWeaponDamageSourceName( string weaponRef, string damageSourceName )
{
	int sourceID = eDamageSourceId[weaponRef]
	file.damageSourceIDToName[ sourceID ] <- damageSourceName
}

bool function DamageSourceIDHasString( int index )
{
	return (index in file.damageSourceIDToString)
}

string function DamageSourceIDToString( int index )
{
	return file.damageSourceIDToString[ index ]
}

string function GetObitFromDamageSourceID( int damageSourceID )
{
	if ( damageSourceID > 0 && damageSourceID < DamageDef_GetCount() )
	{
		return DamageDef_GetObituary( damageSourceID )
	}

	if ( damageSourceID in file.damageSourceIDToName )
		return file.damageSourceIDToName[ damageSourceID ]

	table damageSourceIdEnum = expect table( getconsttable().eDamageSourceId )
	foreach ( name, id in damageSourceIdEnum )
	{
		if ( id == damageSourceID )
			return expect string( name )
	}

	return ""
}

#if SERVER
void function RegisterWeaponDamageSource( string weaponRef, string damageSourceName )
{
	// Have to do this since squirrel table initialization only supports literals for string keys
	table< string, string > temp
	temp[ weaponRef ] <- damageSourceName
	RegisterWeaponDamageSources( temp )
}

/*	Values are expected to be in a table containing the enum variable name and the string name, e.g.
	{"mp_titanweapon_sniper" : "Plasma Railgun", "mp_titanweapon_meteor" : "T203 Thermite Launcher"}
	Only works properly if used after the match starts, e.g. called in "after" callbacks.
*/
void function RegisterWeaponDamageSources( table< string, string > newValueTable )
{
	int trgt = file.damageSourceIDToString.len() - 1 // -1 accounts for invalid.
	int lastCustomSize = file.customDamageSourceIDList.len() // Used to only send new IDs to clients if any are added during runtime.

	foreach ( newVal, stringVal in newValueTable )
	{
		// Don't replace existing enum values
		while ( trgt in file.damageSourceIDToString )
			trgt++

		// Only move insertion point if insertion succeeded
		if ( RegisterWeaponDamageSourceInternal( trgt, newVal, stringVal ) )
			trgt++;
	}

	// Send IDs created during match runtime. IDs made on inits get sent through client connected callback.
	foreach( player in GetPlayerArray() )
		SendNewDamageSourceIDs( player, lastCustomSize )
}
#endif

bool function RegisterWeaponDamageSourceInternal( int id, string newVal, string stringVal )
{
	table damageSourceID = expect table( getconsttable()[ "eDamageSourceId" ] )

	// Fail invalid new source IDs (already exists or cannot be sent via string commands). Length condition has loose padding to account for ID string length.
	if ( newVal in damageSourceID || newVal.len() + stringVal.len() > SOURCE_ID_MAX_MESSAGE_LENGTH - 15 || id in file.damageSourceIDToString )
		return false

	damageSourceID[ newVal ] <- id
	file.damageSourceIDToString[ id ] <- newVal
	file.damageSourceIDToName[ id ] <- stringVal
	file.customDamageSourceIDList.extend( [ id.tostring(), newVal, StringReplace( stringVal, " ", MESSAGE_SPACE_PADDING ) ] )
	return true
}

#if SERVER
void function SendNewDamageSourceIDsConnected( entity player )
{
	SendNewDamageSourceIDs( player )
}

void function SendNewDamageSourceIDs( entity player, int index = 0 )
{
	while ( index < file.customDamageSourceIDList.len() )
	{
		int curSize = 0
		int curIndex = index

		// Figure out how many sources to send in this message chunk
		while ( curIndex < file.customDamageSourceIDList.len() )
		{
			// Sources are inserted to the custom list in triplets, so we can trust these indices exist.
			curSize += file.customDamageSourceIDList[ curIndex ].len()
			curSize += file.customDamageSourceIDList[ curIndex + 1 ].len()
			curSize += file.customDamageSourceIDList[ curIndex + 2 ].len()

			// Stop before including strings in current message if it exceeds max message length.
			// This will never stall on a singular source that exceeds the size since new sources are size limited.
			if ( curSize > SOURCE_ID_MAX_MESSAGE_LENGTH )
				break

			curIndex += 3
		}

		// Create the string to pass to client
		string message = ""
		while ( index < curIndex )
			message += file.customDamageSourceIDList[ index++ ] + " "

		ServerToClientStringCommand( player, "register_damage_source_ids " + message )
	}
}
#else
void function ReceiveNewDamageSourceIDs( array<string> args )
{
	// IDs are inserted to the custom list in triplets, so we can trust these indices exist and the loop will end properly
	for ( int i = 0; i < args.len(); i += 3 )
		RegisterWeaponDamageSourceInternal( args[ i ].tointeger(), args[ i + 1 ], StringReplace( args[ i + 2 ], MESSAGE_SPACE_PADDING, " " ) )
}
#endif
