untyped

globalize_all_functions

function Weapon_Dialogue_Init()
{
	RegisterConversation( "CoopTD_TurretAvailable", 				VO_PRIORITY_PLAYERSTATE )	// player turret becomes available
	RegisterConversation( "CoopTD_TurretAvailableNag", 			VO_PRIORITY_PLAYERSTATE ) 	// player turret available nag
	RegisterConversation( "CoopTD_TurretDestroyed", 				VO_PRIORITY_PLAYERSTATE ) 	// player turret destroyed
	RegisterConversation( "CoopTD_TurretDeadAndReady", 			VO_PRIORITY_PLAYERSTATE ) 	// player turret destroyed, and one ready
	RegisterConversation( "CoopTD_TurretKillstreak", 			VO_PRIORITY_PLAYERSTATE ) 	// player turret has lots of kills
	RegisterConversation( "CoopTD_TurretKilledTitan", 			VO_PRIORITY_PLAYERSTATE ) 	// player turret killed a titan
	RegisterConversation( "CoopTD_TurretKilledTitan_Multi", 		VO_PRIORITY_PLAYERSTATE ) 	// player turret killed multiple titans

	#if CLIENT

	AddVDULineForSarah( "CoopTD_TurretAvailable", "diag_gm_coop_playerTurretEarned_mcor_Sarah" )
	AddVDULineForSpyglass( "CoopTD_TurretAvailable", "diag_gm_coop_playerTurretEarned_mcor_Sarah" )

	// player turret available nag
	AddVDULineForSarah( "CoopTD_TurretAvailableNag", "diag_gm_coop_playerTurretNag_mcor_Sarah" )
	AddVDULineForSpyglass( "CoopTD_TurretAvailableNag", "diag_gm_coop_playerTurretNag_mcor_Sarah" )

	// player turret destroyed
	AddVDULineForSarah( "CoopTD_TurretDestroyed", "diag_gm_coop_playerTurretDestro_mcor_Sarah" )
	AddVDULineForSpyglass( "CoopTD_TurretDestroyed", "diag_gm_coop_playerTurretDestro_mcor_Sarah" )

	// player turret destroyed and another one ready
	AddVDULineForSarah( "CoopTD_TurretDeadAndReady", "diag_gm_coop_playerTurretDeadAndReady_mcor_Sarah" )
	AddVDULineForSpyglass( "CoopTD_TurretDeadAndReady", "diag_gm_coop_playerTurretDeadAndReady_mcor_Sarah" )

	// player turret has lots of kills
	AddVDULineForSarah( "CoopTD_TurretKillstreak", "diag_gm_coop_playerTurretHighKills_mcor_Sarah" )
	AddVDULineForSpyglass( "CoopTD_TurretKillstreak", "diag_gm_coop_playerTurretHighKills_mcor_Sarah" )

	// player turret killed a titan
	AddVDULineForSarah( "CoopTD_TurretKilledTitan", "diag_gm_coop_playerTurretKilledTitan_mcor_Sarah" )
	AddVDULineForSpyglass( "CoopTD_TurretKilledTitan", "diag_gm_coop_playerTurretKilledTitan_mcor_Sarah" )

	// player turret killed multiple titans
	AddVDULineForSarah( "CoopTD_TurretKilledTitan_Multi", "diag_gm_coop_playerTurretKilledTitanAgain_mcor_Sarah" )
	AddVDULineForSpyglass( "CoopTD_TurretKilledTitan_Multi", "diag_gm_coop_playerTurretKilledTitanAgain_mcor_Sarah" )
	#endif
}
