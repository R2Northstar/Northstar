global function Sh_GamemodeHidden_Init

global const string GAMEMODE_HIDDEN = "hidden"

void function Sh_GamemodeHidden_Init()
{
	// create custom gamemode
	AddCallback_OnCustomGamemodesInit( CreateGamemodeHidden )
	AddCallback_OnRegisteringCustomNetworkVars( HiddenRegisterNetworkVars )
}

void function CreateGamemodeHidden()
{
	GameMode_Create( GAMEMODE_HIDDEN )
	GameMode_SetName( GAMEMODE_HIDDEN, "#GAMEMODE_HIDDEN" )
	GameMode_SetDesc( GAMEMODE_HIDDEN, "#PL_hidden_desc" )
	GameMode_SetGameModeAnnouncement( GAMEMODE_HIDDEN, "ffa_modeDesc" )
	GameMode_SetDefaultTimeLimits( GAMEMODE_HIDDEN, 5, 0.0 )
	GameMode_AddScoreboardColumnData( GAMEMODE_HIDDEN, "#SCOREBOARD_SCORE", PGS_ASSAULT_SCORE, 2 )
	GameMode_AddScoreboardColumnData( GAMEMODE_HIDDEN, "#SCOREBOARD_PILOT_KILLS", PGS_PILOT_KILLS, 2 )
	GameMode_SetColor( GAMEMODE_HIDDEN, [147, 204, 57, 255] )

	AddPrivateMatchMode( GAMEMODE_HIDDEN ) // add to private lobby modes

	#if SERVER
		GameMode_AddServerInit( GAMEMODE_HIDDEN, GamemodeHidden_Init )
		GameMode_SetPilotSpawnpointsRatingFunc( GAMEMODE_HIDDEN, RateSpawnpoints_Generic )
		GameMode_SetTitanSpawnpointsRatingFunc( GAMEMODE_HIDDEN, RateSpawnpoints_Generic )
	#elseif CLIENT
		GameMode_AddClientInit( GAMEMODE_HIDDEN, ClGamemodeHidden_Init )
	#endif
	#if !UI
		GameMode_SetScoreCompareFunc( GAMEMODE_HIDDEN, CompareAssaultScore )
	#endif
}

void function HiddenRegisterNetworkVars()
{
	if ( GAMETYPE != GAMEMODE_HIDDEN )
		return

	Remote_RegisterFunction( "ServerCallback_YouAreHidden" )
	Remote_RegisterFunction( "ServerCallback_AnnounceHidden" )
}
