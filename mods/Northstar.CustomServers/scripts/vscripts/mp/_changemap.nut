global function CodeCallback_MatchIsOver


void function CodeCallback_MatchIsOver()
{
	foreach ( entity player in GetPlayerArray() )
		SavePdataForEntityIndex( player.GetPlayerIndex() )

	if ( !IsPrivateMatch() && IsMatchmakingServer() )
		SetUIVar( level, "putPlayerInMatchmakingAfterDelay", true )
	else
		SetUIVar( level, "putPlayerInMatchmakingAfterDelay", false )

	if ( GetCurrentPlaylistVarInt( "return_to_private_lobby", 0 ) == 1 ) // set in _private_lobby.gnut, temp lol
	{
		SetCurrentPlaylist( "private_match" ) // needed for private lobby to load
		
		if ( IsSingleplayer() )
			GameRules_ChangeMap( "mp_lobby", "tdm" ) // need to change back to tdm 
		else
			GameRules_ChangeMap( "mp_lobby", GAMETYPE )
		// this is esp important for sp, since solo will break a bunch of shit in the private lobby
		// idk if even necessary to deal with solo but eh whatever better to have it work than not
	}

#if DEV
	if ( !IsMatchmakingServer() )
		GameRules_ChangeMap( "mp_lobby", GAMETYPE )
#endif // #if DEV
}
