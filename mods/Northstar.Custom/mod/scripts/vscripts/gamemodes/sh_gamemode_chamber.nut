global function Sh_GamemodeChamber_Init

global const string GAMEMODE_CHAMBER = "chamber"

void function Sh_GamemodeChamber_Init()
{
	// create custom gamemode
	AddCallback_OnCustomGamemodesInit( CreateGamemodeChamber )
}

void function CreateGamemodeChamber()
{
	GameMode_Create( GAMEMODE_CHAMBER )
	GameMode_SetName( GAMEMODE_CHAMBER, "#GAMEMODE_CHAMBER" )
	GameMode_SetDesc( GAMEMODE_CHAMBER, "#PL_chamber_desc" )
	GameMode_SetGameModeAnnouncement( GAMEMODE_CHAMBER, "ffa_modeDesc" )
	GameMode_SetDefaultTimeLimits( GAMEMODE_CHAMBER, 10, 0.0 )
	GameMode_AddScoreboardColumnData( GAMEMODE_CHAMBER, "#SCOREBOARD_SCORE", PGS_ASSAULT_SCORE, 2 )
	GameMode_AddScoreboardColumnData( GAMEMODE_CHAMBER, "#SCOREBOARD_PILOT_KILLS", PGS_PILOT_KILLS, 2 )
	GameMode_SetColor( GAMEMODE_CHAMBER, [147, 204, 57, 255] )

	AddPrivateMatchMode( GAMEMODE_CHAMBER ) // add to private lobby modes

	// set this to 25 score limit default
	GameMode_SetDefaultScoreLimits( GAMEMODE_CHAMBER, 25, 0 )

	#if SERVER
		GameMode_AddServerInit( GAMEMODE_CHAMBER, GamemodeChamber_Init )
		GameMode_AddServerInit( GAMEMODE_CHAMBER, GamemodeFFAShared_Init )
		GameMode_SetPilotSpawnpointsRatingFunc( GAMEMODE_CHAMBER, RateSpawnpoints_Generic )
		GameMode_SetTitanSpawnpointsRatingFunc( GAMEMODE_CHAMBER, RateSpawnpoints_Generic )
	#elseif CLIENT
		GameMode_AddClientInit( GAMEMODE_CHAMBER, ClGamemodeChamber_Init )
		GameMode_AddClientInit( GAMEMODE_CHAMBER, GamemodeFFAShared_Init )
		GameMode_AddClientInit( GAMEMODE_CHAMBER, ClGamemodeFFA_Init )
	#endif
	#if !UI
		GameMode_SetScoreCompareFunc( GAMEMODE_CHAMBER, CompareAssaultScore )
		GameMode_AddSharedInit( GAMEMODE_CHAMBER, GamemodeFFA_Dialogue_Init )
	#endif
}
