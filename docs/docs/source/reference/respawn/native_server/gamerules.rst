Gamerules
=========

.. cpp:function:: string GameRules_GetGameMode()

.. cpp:function:: int GameRules_GetTeamScore( int team )

.. cpp:function:: int GameRules_GetTeamScore2( int team )

  Used for round based game modes

.. cpp:function:: int GameRules_GetTeamKills( int team )

.. cpp:function:: int GameRules_GetTeamDeaths( int team )

.. cpp:function:: string GameRules_GetTeamName( int team )

.. cpp:function:: bool GameRules_TimeLimitEnabled()

.. cpp:function:: bool GameRules_AllowMatchEnd()

.. cpp:function:: int GameRules_GetClassMax( string class )

.. cpp:function:: void GameRules_SetGameMode( string gameMode )

.. cpp:function:: void GameRules_SetTeamScore( int team, int score )

.. cpp:function:: void GameRules_SetTeamScore2( int team, int score )

  Presumably used for round based game modes

.. cpp:function:: void GameRules_EndMatch()

.. cpp:function:: void GameRules_MarkGameStatePrematchEnding()

.. cpp:function:: void GameRules_MarkGameStateWinnerDetermined()

.. cpp:function:: void GameRules_ChangeMap( string mapName, string gameMode )

.. cpp:function:: string GameRules_GetRecentMap( number unk1 )

.. cpp:function:: string GameRules_GetRecentGameMode( number unk1 )

.. cpp:function:: int GameRules_GetRecentTeamScore( number unk1, int team )

.. cpp:function:: void GameRules_EnableGlobalChat( bool enabled )

.. cpp:function:: string GameRules_GetUniqueMatchID()

.. cpp:function:: void GameRules_SetDeadPlayersCanOnlySpeakToDeadPlayersInHudChat( bool b )
