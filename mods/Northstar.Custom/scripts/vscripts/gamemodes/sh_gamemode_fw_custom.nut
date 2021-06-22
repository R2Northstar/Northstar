// this script only exists to create the fw gamemode
// all client/shared gamelogic is still done in the gamemode's respective client and shared scripts
// these scripts are shipped with the game's official build so no need to recreate these
// their paths are gamemodes/cl_gamemode_fw.nut and gamemodes/sh_gamemode_fw.nut, respectively

global function SHCreateGamemodeFW_Init

void function SHCreateGamemodeFW_Init()
{
	AddCallback_OnCustomGamemodesInit( CreateGamemodeFW )
	AddCallback_OnRegisteringCustomNetworkVars( FWOnRegisteringNetworkVars )
}

void function CreateGamemodeFW()
{
	//entity e = CreateEntity("npc_turret_mega"); SetAISettingsWrapper( e, "npc_turret_mega_fortwar" ); e.SetOrigin(GetPlayerArray()[0].GetOrigin()); SetTeam(e,3); DispatchSpawn(e)

	// we have to manually add the client/shared scripts to scripts.rson atm so we need to prevent compile errors when they aren't included
	// best way to do this is to just ignore this whole block for now and wait until we don't have to add them manually
	
	GameMode_Create( FORT_WAR )
	GameMode_SetName( FORT_WAR, "#GAMEMODE_fw" )
	GameMode_SetDesc( FORT_WAR, "#PL_fw_desc" )
	GameMode_SetGameModeAnnouncement( FORT_WAR, "ffa_modeDesc" ) // fw lines are unfortunately not registered to faction dialogue
	
		#if SERVER
			//GameMode_AddServerInit( FORT_WAR, GamemodeFW_Init ) // doesn't exist yet lol
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
	RegisterNetworkedVariable( "fwCampStressA", SNDC_GLOBAL, SNVT_INT )
	RegisterNetworkedVariable( "fwCampAlertB", SNDC_GLOBAL, SNVT_INT )
	RegisterNetworkedVariable( "fwCampStressB", SNDC_GLOBAL, SNVT_INT )
	RegisterNetworkedVariable( "fwCampAlertC", SNDC_GLOBAL, SNVT_INT )
	RegisterNetworkedVariable( "fwCampStressC", SNDC_GLOBAL, SNVT_INT )
	
	#if CLIENT                  
		CLFortWar_RegisterNetworkFunctions()
	#endif
}