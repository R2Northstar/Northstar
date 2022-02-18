Callbacks
======================

Callbacks within squirrel trigger functions when certain events occur and are defined serverside. 

They will also often pass arguments to those functions based on the callbacks used

A few examples
--------------

.. cpp:function:: void AddCallback_OnPlayerRespawned(void functionref(entity))

This script will trigger the function "OnRespawn" when any player respawns, this function can be defined later in the mods file and this callback will pass one argument, the player entity that respawned


.. cpp:function:: void AddCallback_OnPlayerKilled(void functionref(entity, entity, var))

This callback triggers the function "AddPoints" when a player is killed. this function passes 3 arguments: an entity (the attacking player), an entity (the killed player), and the damage informtion

.. cpp:function:: void AddCallback_OnClientConnected(void functionref(entity))

This callback triggers the function "Connected" whenever a player joins and passes 1 argument, the player entity.

List of callbacks
-----------------
This is an **incomplete** list of callbacks.

.. cpp:function:: void AddCallback_OnTouchHealthKit( string className, bool functionref( entity player, entity healthpack ) )
.. cpp:function:: void AddCallback_OnPlayerRespawned( void functionref( entity ) )
.. cpp:function:: void AddCallback_OnPlayerKilled( void functionref( entity victim, entity attacker, var damageInfo ) )
.. cpp:function:: void AddCallback_OnNPCKilled( void functionref( entity victim, entity attacker, var damageInfo ) )
.. cpp:function:: void AddCallback_OnTitanDoomed( void functionref( entity victim, var damageInfo ) )
.. cpp:function:: void AddCallback_OnTitanHealthSegmentLost( void functionref( entity victim, entity attacker ) )
.. cpp:function:: void AddCallback_OnClientConnecting( void functionref( entity player ) )
.. cpp:function:: void AddCallback_OnClientConnected( void functionref( entity player ) )
.. cpp:function:: void AddCallback_OnClientDisconnected( void functionref( entity player ) )
.. cpp:function:: void AddCallback_OnPilotBecomesTitan( void functionref( entity pilot, entity npc_titan ) )
.. cpp:function:: void AddCallback_OnTitanBecomesPilot( void functionref( entity pilot, entity npc_titan ) )
.. cpp:function:: void AddCallback_OnPlayerAssist( void functionref( entity attacker, entity victim ) )
.. cpp:function:: void AddCallback_EntityChangedTeam( string className, void functionref( entity ent ) )
.. cpp:function:: void AddCallback_OnTitanGetsNewTitanLoadout( void functionref( entity titan, TitanLoadoutDef newTitanLoadout ) )
.. cpp:function:: void AddCallback_OnPlayerGetsNewPilotLoadout( void functionref( entity player, PilotLoadoutDef newTitanLoadout ) )
.. cpp:function:: void AddCallback_OnUpdateDerivedTitanLoadout( void functionref( TitanLoadoutDef newTitanLoadout ) )
.. cpp:function:: void AddCallback_OnUpdateDerivedPlayerTitanLoadout( void functionref( entity player, TitanLoadoutDef newTitanLoadout ) )
.. cpp:function:: void AddCallback_OnUpdateDerivedPilotLoadout( void functionref( PilotLoadoutDef newPilotLoadout ) )
.. cpp:function:: void AddCallback_OnPlayerInventoryChanged( void functionref( entity ) )
.. cpp:function:: void AddCallback_OnRegisterCustomItems( void functionref() )
.. cpp:function:: void AddCallback_ScriptTriggerEnter( entity trigger, void functionref( entity, entity ) )
.. cpp:function:: void AddCallback_ScriptTriggerLeave( entity trigger, void functionref( entity, entity )  )
.. cpp:function:: void AddCallback_OnUseEntity( entity ent, )
.. cpp:function:: void AddCallback_EntitiesDidLoad( EntitiesDidLoadCallbackType callback )
.. cpp:function:: void AddCallback_GameStateEnter( int gameState, void functionref() )
.. cpp:function:: void AddCallback_NPCLeeched( void functionref( entity, entity ) )
.. cpp:function:: void AddCallback_OnRegisteringCustomNetworkVars( void functionref() )
.. cpp:function:: void AddCallback_OnCustomGamemodesInit( void functionref() )
.. cpp:function:: void AddCallback_OnRoundEndCleanup( void functionref() )
.. cpp:function:: void AddCallback_ZiplineStart( void functionref(entity,entity) )
.. cpp:function:: void AddCallback_ZiplineStop( void functionref(entity) )
