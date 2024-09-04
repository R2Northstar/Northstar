Stryder
=======

Stryder is in a sense like the masterserver Northstar uses but for vanilla. It handles player data, matchmaking, servers and more.

Lobbies
-------

.. note::

  Not exclusive to vanilla lobbies. These may be used in northstar as well

Methods for pregame lobbies.

.. cpp:function:: string GetLobbyType()

.. cpp:function:: entity GetPlayerByIndex( number index )

Parties
-------

.. cpp:function:: void SendPlayersToPartyScreen( var unk1 )

  Sends a group of players off to the party screen, possibly by allocating a server first

.. cpp:function:: void SendAllPlayersBackToPartyScreen()

Stryder API
-----------

Methods for communication with the vanilla master server

.. cpp:function:: void SendTrainingGauntletStatsToBackend( entity player, number numRunsBeforeBeatRequiredTime, number numChallengeRuns, number bestTime )

.. cpp:function:: bool IsMatchmakingServer()

.. cpp:function:: bool ShouldSendDevStats()

PIN
---

Some proprietary telemetry system used by respawn.

.. cpp:function:: void CreatePINTelemetryHeader( int versionMajor, int versionMinor, table keyValuePairs )

.. cpp:function:: void AddPINTelemetryEvent( string eventName, table headerKeyValueParis, table bodyKeyValuePairs )

.. cpp:function:: string GetPINPlatformName()

  Gets the platform name the way PIN likes it.

Matchmaking
-----------

.. cpp:function:: void BeginPrivateMatchSearchForPlayer( entity player )

.. cpp:function:: void MatchmakePlayer( entity player )

.. cpp:function:: void AbortMatchSearchesForPlayer( string unk1, entity player )

.. cpp:function:: string GetDatacenterName()

  Gets the name of this server's datacenter

Balancing
---------

.. cpp:function:: void MarkTeamsAsBalanced_On()

.. cpp:function:: void MarkTeamsAsBalanced_Off()
