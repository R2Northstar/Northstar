global function CodeCallback_MatchIsOver

void function CodeCallback_MatchIsOver()
{
	if ( !IsPrivateMatch() && IsMatchmakingServer() )
		SetUIVar( level, "putPlayerInMatchmakingAfterDelay", true )
	else
		SetUIVar( level, "putPlayerInMatchmakingAfterDelay", false )

	AddCreditsForXPGained()
	PopulatePostgameData()

	if ( ShouldReturnToLobby() )
	{
		SetCurrentPlaylist( "private_match" ) // needed for private lobby to load
		
		if ( IsSingleplayer() )
			GameRules_ChangeMap( "mp_lobby", "tdm" ) // need to change back to mp playlist or loadouts will break in lobby
		else
			GameRules_ChangeMap( "mp_lobby", GAMETYPE )
	}

#if DEV
	if ( !IsMatchmakingServer() )
		GameRules_ChangeMap( "mp_lobby", GAMETYPE )
#endif // #if DEV
}

void function PopulatePostgameData()
{
	// something's busted here because this isn't showing automatically on match end, ag
	foreach ( entity player in GetPlayerArray() )
	{
		int teams = GetCurrentPlaylistVarInt( "max_teams", 2 )
		bool standardTeams = teams != 2
		
		int enumModeIndex = 0
		int enumMapIndex = 0
		
		try
		{
			enumModeIndex = PersistenceGetEnumIndexForItemName( "gamemodes", GAMETYPE )
			enumMapIndex = PersistenceGetEnumIndexForItemName( "maps", GetMapName() )
		}	
		catch( ex ) {}
	
		player.SetPersistentVar( "postGameData.myTeam", player.GetTeam() )
		player.SetPersistentVar( "postGameData.myXuid", player.GetUID() )
		player.SetPersistentVar( "postGameData.gameMode", PersistenceGetEnumIndexForItemName( "gamemodes", GAMETYPE ) )
		player.SetPersistentVar( "postGameData.map", PersistenceGetEnumIndexForItemName( "maps", GetMapName() ) )
		player.SetPersistentVar( "postGameData.teams", standardTeams )
		player.SetPersistentVar( "postGameData.maxTeamSize", teams )
		player.SetPersistentVar( "postGameData.privateMatch", true )
		player.SetPersistentVar( "postGameData.ranked", true )
		player.SetPersistentVar( "postGameData.hadMatchLossProtection", false )
		
		player.SetPersistentVar( "isFDPostGameScoreboardValid", GAMETYPE == FD )
		
		if ( standardTeams )
		{
			if ( player.GetTeam() == TEAM_MILITIA )
			{
				player.SetPersistentVar( "postGameData.factionMCOR", GetFactionChoice( player ) )
				player.SetPersistentVar( "postGameData.factionIMC", GetEnemyFaction( player ) )
			}
			else
			{
				player.SetPersistentVar( "postGameData.factionIMC", GetFactionChoice( player ) )
				player.SetPersistentVar( "postGameData.factionMCOR", GetEnemyFaction( player ) )
			}
			
			player.SetPersistentVar( "postGameData.scoreMCOR", GameRules_GetTeamScore( TEAM_MILITIA ) )
			player.SetPersistentVar( "postGameData.scoreIMC", GameRules_GetTeamScore( TEAM_IMC ) )
		}
		else
		{
			player.SetPersistentVar( "postGameData.factionMCOR", GetFactionChoice( player ) )
			player.SetPersistentVar( "postGameData.scoreMCOR", GameRules_GetTeamScore( player.GetTeam() ) )
		}
		
		array<entity> otherPlayers = GetPlayerArray()
		array<int> scoreTypes = GameMode_GetScoreboardColumnScoreTypes( GAMETYPE )
		int persistenceArrayCount = PersistenceGetArrayCount( "postGameData.players" )
		for ( int i = 0; i < min( otherPlayers.len(), persistenceArrayCount ); i++ )
		{
			player.SetPersistentVar( "postGameData.players[" + i + "].team", otherPlayers[ i ].GetTeam() )
			player.SetPersistentVar( "postGameData.players[" + i + "].name", otherPlayers[ i ].GetPlayerName() )
			player.SetPersistentVar( "postGameData.players[" + i + "].xuid", otherPlayers[ i ].GetUID() )
			player.SetPersistentVar( "postGameData.players[" + i + "].callsignIconIndex", otherPlayers[ i ].GetPersistentVarAsInt( "activeCallsignIconIndex" ) )
			
			for ( int j = 0; j < scoreTypes.len(); j++ )
				player.SetPersistentVar( "postGameData.players[" + i + "].scores[" + j + "]", otherPlayers[ i ].GetPlayerGameStat( scoreTypes[ j ] ) )
		}
		
		player.SetPersistentVar( "isPostGameScoreboardValid", true )
	}
}