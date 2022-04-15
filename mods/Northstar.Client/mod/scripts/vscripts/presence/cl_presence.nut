untyped
globalize_all_functions

struct {
	int highestScore = 0
	int secondHighestScore = 0
} file

void function OnPrematchStart()
{
    if ( GetServerVar( "roundBased" ) )
        NSUpdateTimeInfo( level.nv.roundEndTime - Time() )
    else
        NSUpdateTimeInfo( level.nv.gameEndTime - Time() )
}

void function NSUpdateGameStateClientStart()
{
    #if MP
		AddCallback_GameStateEnter( eGameState.Prematch, OnPrematchStart )
    #endif
	
    thread NSUpdateGameStateLoopClient()
    OnPrematchStart()
}

void function NSUpdateGameStateLoopClient()
{
    while ( true )
    {
		if ( IsSingleplayer() )
		{
			NSUpdateGameStateClient( GetPlayerArray().len(), GetCurrentPlaylistVarInt( "max_players", 65535 ), 1, 1, 1, GetServerVar( "roundBased" ), 1 )
			wait 1.0
		}
		else
		{
			foreach ( player in GetPlayerArray() )
			{
				if ( GameRules_GetTeamScore( player.GetTeam() ) >= file.highestScore )
				{
					file.highestScore = GameRules_GetTeamScore( player.GetTeam() )
				}
				else if ( GameRules_GetTeamScore( player.GetTeam() ) > file.secondHighestScore )
				{
					file.secondHighestScore = GameRules_GetTeamScore( player.GetTeam() )
				}
			}
			
			int ourScore = 0
			if ( IsValid( GetLocalClientPlayer() ) )
				ourScore = GameRules_GetTeamScore( GetLocalClientPlayer().GetTeam() )
			
			int limit = IsRoundBased() ? GetCurrentPlaylistVarInt( "roundscorelimit", 0 ) : GetCurrentPlaylistVarInt( "scorelimit", 0 )
			NSUpdateGameStateClient( GetPlayerArray().len(), GetCurrentPlaylistVarInt( "max_players", 65535 ), ourScore, file.secondHighestScore, file.highestScore, GetServerVar( "roundBased" ), limit )
			OnPrematchStart()
			wait 1.0
		}
    }
}
