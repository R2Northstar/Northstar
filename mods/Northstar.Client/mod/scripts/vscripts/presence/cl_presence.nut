untyped
globalize_all_functions

GameStateStruct function DiscordRPC_GenerateGameState( GameStateStruct gs )
{
    int highestScore = 0
    int secondHighest = 0

    foreach ( player in GetPlayerArray() )
    {
        if ( GameRules_GetTeamScore( player.GetTeam() ) >= highestScore )
        {
            highestScore = GameRules_GetTeamScore( player.GetTeam() )
        }
        else if ( GameRules_GetTeamScore( player.GetTeam() ) > secondHighest )
        {
            secondHighest = GameRules_GetTeamScore( player.GetTeam() )
        }
    }

    gs.map = GetMapName()
    gs.mapDisplayname = Localize(GetMapDisplayName(GetMapName()))

    gs.playlist = GetCurrentPlaylistName()
    gs.playlistDisplayname = Localize( GetCurrentPlaylistVarString( "name", GetCurrentPlaylistName() ) ) 

    int reservedCount = GetTotalPendingPlayersReserved()
    int connectingCount = GetTotalPendingPlayersConnecting()
    int loadingCount = GetTotalPendingPlayersLoading()
    int connectedCount = GetPlayerArray().len()
    int allKnownPlayersCount = reservedCount + connectingCount + loadingCount + connectedCount

    gs.currentPlayers = allKnownPlayersCount
    gs.maxPlayers = GetCurrentPlaylistVarInt( "max_players", 16 )

    if ( IsValid( GetLocalClientPlayer() ) )
		gs.ownScore = GameRules_GetTeamScore( GetLocalClientPlayer().GetTeam() )

    #if MP
    if ( GameRules_GetGameMode() == FD )
    {
        gs.playlist = "fd" // So it returns only one thing to the plugin side instead of the 5 separate difficulties FD have
        if ( GetGlobalNetInt( "FD_waveState" ) == WAVE_STATE_INCOMING || GetGlobalNetInt( "FD_waveState" ) == WAVE_STATE_IN_PROGRESS )
        {
            gs.fd_waveNumber = GetGlobalNetInt( "FD_currentWave" ) + 1
            gs.fd_totalWaves = GetGlobalNetInt( "FD_totalWaves" )
        }
        else
            gs.fd_waveNumber = -1 // Tells plugin it's on Wave Break
    }
	#else
	gs.fd_waveNumber = -1 // Unecessary for campaign so return -1
	#endif

    gs.serverGameState = GetGameState() == -1 ? 0 : GetGameState()
    gs.otherHighestScore = gs.ownScore == highestScore ? secondHighest : highestScore

    gs.maxScore = IsRoundBased() ? GetCurrentPlaylistVarInt( "roundscorelimit", 0 ) : GetCurrentPlaylistVarInt( "scorelimit", 0 )

	if ( GetServerVar( "roundBased" ) )
		gs.timeEnd = expect float(level.nv.roundEndTime - Time())
	else
		gs.timeEnd = expect float(level.nv.gameEndTime - Time())
    return gs
}
