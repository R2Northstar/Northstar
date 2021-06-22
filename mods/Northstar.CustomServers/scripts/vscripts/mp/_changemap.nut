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
		ServerCommand( "changelevel mp_lobby" )
	}

#if DEV
	if ( !IsMatchmakingServer() )
		GameRules_ChangeMap( "mp_lobby", GAMETYPE )
#endif // #if DEV
}
