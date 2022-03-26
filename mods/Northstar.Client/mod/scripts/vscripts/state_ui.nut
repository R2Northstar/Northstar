untyped

globalize_all_functions

void function NSUpdateGameStateUIStart()
{
    thread NSUpdateGameStateLoopUI()
}

void function NSUpdateGameStateLoopUI()
{
    while ( true )
    {
        wait 1.0
        if ( uiGlobal.loadedLevel == "" )
        {
            if ( uiGlobal.isLoading )
                NSSetLoading( true )
            else
            {
                NSSetLoading( false )
                NSUpdateGameStateUI( "", "", "", "", true, false )
            }
            continue
        }
        NSSetLoading( false )
        NSUpdateGameStateUI( GetActiveLevel(), Localize( GetMapDisplayName( GetActiveLevel() ) ), GetConVarString( "mp_gamemode" ), Localize( GetPlaylistDisplayName( GetConVarString("mp_gamemode") ) ), IsFullyConnected(), false )
    }
}