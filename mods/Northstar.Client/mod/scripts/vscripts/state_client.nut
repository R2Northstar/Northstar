untyped

int highestScore = 0
int secondHighestScore = 0
int ourScore = 0

globalize_all_functions

void function OnPrematchStart()
{
    if (GetServerVar( "roundBased" ))
        NSUpdateTimeInfo( level.nv.roundEndTime - Time() )
    else
        NSUpdateTimeInfo( level.nv.gameEndTime - Time() )
}

void function NSUpdateGameStateClientStart()
{
    AddCallback_GameStateEnter( eGameState.Prematch, OnPrematchStart )
    thread NSUpdateGameStateLoopClient()
    OnPrematchStart()
}

void function NSUpdateGameStateLoopClient()
{
    while ( true )
    {
        foreach ( player in GetPlayerArray() )
        {
            if ( GameRules_GetTeamScore( player.GetTeam() ) >= highestScore )
            {
                highestScore = GameRules_GetTeamScore( player.GetTeam() )
            }
            else if ( GameRules_GetTeamScore( player.GetTeam() ) > secondHighestScore )
            {
                secondHighestScore = GameRules_GetTeamScore( player.GetTeam() )
            }
        }
        if ( GetLocalClientPlayer() != null )
        {
            ourScore = GameRules_GetTeamScore( GetLocalClientPlayer().GetTeam() )
        }
        int limit = GetServerVar( "roundBased" ) ? GetCurrentPlaylistVarInt( "roundscorelimit", 0 ) : GetCurrentPlaylistVarInt( "scorelimit", 0 )
        NSUpdateGameStateClient( GetPlayerArray().len(), GetCurrentPlaylistVarInt( "max_players", 65535 ), ourScore, secondHighestScore, highestScore, GetServerVar( "roundBased" ), limit )
        OnPrematchStart()
        wait 1.0
    }
}