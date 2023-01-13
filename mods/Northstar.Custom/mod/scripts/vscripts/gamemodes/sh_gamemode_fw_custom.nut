// this script only exists to create the fw gamemode
// all client/shared gamelogic is still done in the gamemode's respective client and shared scripts
// these scripts are shipped with the game's official build so no need to recreate these
// their paths are gamemodes/cl_gamemode_fw.nut and gamemodes/sh_gamemode_fw.nut, respectively

global function SHCreateGamemodeFW_Init

// object settings, changable through playlist vars
// default havester settings
global const int FW_DEFAULT_HARVESTER_HEALTH = 25000
global const int FW_DEFAULT_HARVESTER_SHIELD = 5000
global const float FW_DEFAULT_HARVESTER_REGEN_DELAY = 12.0
global const float FW_DEFAULT_HARVESTER_REGEN_TIME = 10.0
// default turret settings
global const int FW_DEFAULT_TURRET_HEALTH = 12500
global const int FW_DEFAULT_TURRET_SHIELD = 4000

// fix a turret
global const float TURRET_FIXED_HEALTH_PERCENTAGE = 0.33
global const float TURRET_FIXED_SHIELD_PERCENTAGE = 1.0 // default is regen all shield
// hack a turret
global const float TURRET_HACKED_HEALTH_PERCENTAGE = 0.5
global const float TURRET_HACKED_SHIELD_PERCENTAGE = 0.5

void function SHCreateGamemodeFW_Init()
{
	// harvester playlistvar
	AddPrivateMatchModeSettingArbitrary( "#PL_fw", "fw_harvester_health", FW_DEFAULT_HARVESTER_HEALTH.tostring() )
	AddPrivateMatchModeSettingArbitrary( "#PL_fw", "fw_harvester_shield", FW_DEFAULT_HARVESTER_SHIELD.tostring() )
	AddPrivateMatchModeSettingArbitrary( "#PL_fw", "fw_harvester_regen_delay", FW_DEFAULT_HARVESTER_REGEN_DELAY.tostring() )
	AddPrivateMatchModeSettingArbitrary( "#PL_fw", "fw_harvester_regen_time", FW_DEFAULT_HARVESTER_REGEN_TIME.tostring() )
	// turret playlistvar
	AddPrivateMatchModeSettingArbitrary( "#PL_fw", "fw_turret_health", FW_DEFAULT_TURRET_HEALTH.tostring() )
	AddPrivateMatchModeSettingArbitrary( "#PL_fw", "fw_turret_shield", FW_DEFAULT_TURRET_SHIELD.tostring() )
	// battery port playlistvar
	AddPrivateMatchModeSettingArbitrary( "#PL_fw", "fw_turret_fixed_health", TURRET_FIXED_HEALTH_PERCENTAGE.tostring() )
	AddPrivateMatchModeSettingArbitrary( "#PL_fw", "fw_turret_fixed_shield", TURRET_FIXED_SHIELD_PERCENTAGE.tostring() )
	AddPrivateMatchModeSettingArbitrary( "#PL_fw", "fw_turret_hacked_health", TURRET_HACKED_HEALTH_PERCENTAGE.tostring() )
	AddPrivateMatchModeSettingArbitrary( "#PL_fw", "fw_turret_hacked_shield", TURRET_HACKED_SHIELD_PERCENTAGE.tostring() )

	AddCallback_OnCustomGamemodesInit( CreateGamemodeFW )
	AddCallback_OnRegisteringCustomNetworkVars( FWOnRegisteringNetworkVars )
}

void function CreateGamemodeFW()
{
	// we have to manually add the client/shared scripts to scripts.rson atm so we need to prevent compile errors when they aren't included
	// best way to do this is to just ignore this whole block for now and wait until we don't have to add them manually
	
	GameMode_Create( FORT_WAR )
	GameMode_SetName( FORT_WAR, "#GAMEMODE_fw" )
	GameMode_SetDesc( FORT_WAR, "#PL_fw_desc" )

	// fw lines are unfortunately not registered to faction dialogue, maybe do it in gamemode script manually, current using it's modeName
	GameMode_SetGameModeAnnouncement( FORT_WAR, "fortwar_modeName" ) 
	
	// waiting to be synced with client
	GameMode_AddScoreboardColumnData( FORT_WAR, "#SCOREBOARD_KILLS", PGS_KILLS, 2 )
	GameMode_AddScoreboardColumnData( FORT_WAR, "#SCOREBOARD_SUPPORT_SCORE", PGS_DEFENSE_SCORE, 4 )
	GameMode_AddScoreboardColumnData( FORT_WAR, "#SCOREBOARD_COOP_POINTS", PGS_ASSAULT_SCORE, 6 )

	AddPrivateMatchMode( FORT_WAR )

	#if SERVER
		GameMode_AddServerInit( FORT_WAR, GamemodeFW_Init )
		GameMode_SetPilotSpawnpointsRatingFunc( FORT_WAR, RateSpawnpointsPilot_FW )
		GameMode_SetTitanSpawnpointsRatingFunc( FORT_WAR, RateSpawnpointsTitan_FW )
	#elseif CLIENT
		GameMode_AddClientInit( FORT_WAR, CLGamemodeFW_Init )
	#endif
	#if !UI
		GameMode_AddSharedInit( FORT_WAR, SHGamemodeFW_Init )
	#endif
}

void function FWOnRegisteringNetworkVars()
{
	if ( GAMETYPE != FORT_WAR )
		return
	
	Remote_RegisterFunction( "ServerCallback_FW_NotifyNeedsEnterEnemyArea" )
	
	RegisterNetworkedVariable( "turretSite1", SNDC_GLOBAL, SNVT_ENTITY )
	RegisterNetworkedVariable( "turretSite2", SNDC_GLOBAL, SNVT_ENTITY )
	RegisterNetworkedVariable( "turretSite3", SNDC_GLOBAL, SNVT_ENTITY )
	RegisterNetworkedVariable( "turretSite4", SNDC_GLOBAL, SNVT_ENTITY )
	RegisterNetworkedVariable( "turretSite5", SNDC_GLOBAL, SNVT_ENTITY )
	RegisterNetworkedVariable( "turretSite6", SNDC_GLOBAL, SNVT_ENTITY )
	RegisterNetworkedVariable( "turretSite7", SNDC_GLOBAL, SNVT_ENTITY )
	RegisterNetworkedVariable( "turretSite8", SNDC_GLOBAL, SNVT_ENTITY )
	RegisterNetworkedVariable( "turretSite9", SNDC_GLOBAL, SNVT_ENTITY )
	
	RegisterNetworkedVariable( "turretStateFlags1", SNDC_GLOBAL, SNVT_INT )
	RegisterNetworkedVariable( "turretStateFlags2", SNDC_GLOBAL, SNVT_INT )
	RegisterNetworkedVariable( "turretStateFlags3", SNDC_GLOBAL, SNVT_INT )
	RegisterNetworkedVariable( "turretStateFlags4", SNDC_GLOBAL, SNVT_INT )
	RegisterNetworkedVariable( "turretStateFlags5", SNDC_GLOBAL, SNVT_INT )
	RegisterNetworkedVariable( "turretStateFlags6", SNDC_GLOBAL, SNVT_INT )
	RegisterNetworkedVariable( "turretStateFlags7", SNDC_GLOBAL, SNVT_INT )
	RegisterNetworkedVariable( "turretStateFlags8", SNDC_GLOBAL, SNVT_INT )
	RegisterNetworkedVariable( "turretStateFlags9", SNDC_GLOBAL, SNVT_INT )
	
	RegisterNetworkedVariable( "imcTowerThreatLevel", SNDC_GLOBAL, SNVT_INT )
	RegisterNetworkedVariable( "milTowerThreatLevel", SNDC_GLOBAL, SNVT_INT )
	RegisterNetworkedVariable( "fwCampAlertA", SNDC_GLOBAL, SNVT_INT )
	RegisterNetworkedVariable( "fwCampStressA", SNDC_GLOBAL, SNVT_FLOAT_RANGE, 0.0, 0.0, 1.0 )
	RegisterNetworkedVariable( "fwCampAlertB", SNDC_GLOBAL, SNVT_INT )
	RegisterNetworkedVariable( "fwCampStressB", SNDC_GLOBAL, SNVT_FLOAT_RANGE, 0.0, 0.0, 1.0 )
	RegisterNetworkedVariable( "fwCampAlertC", SNDC_GLOBAL, SNVT_INT )
	RegisterNetworkedVariable( "fwCampStressC", SNDC_GLOBAL, SNVT_FLOAT_RANGE, 0.0, 0.0, 1.0 )
	
	#if CLIENT                  
		CLFortWar_RegisterNetworkFunctions()
	#endif
}
