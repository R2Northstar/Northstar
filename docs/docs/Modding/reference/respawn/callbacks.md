# Callbacks

Callbacks from Respawn native code

Callbacks within squirrel trigger functions when certain events occur.

They will also often pass arguments to those functions based on the callbacks used.

Please refer to [Custom Northstar Callbacks](../northstar/callbacks.md) for callbacks defined in Northstar.

## _codecallbacks_common.gnut:

!!! cpp-function "void AddDamageCallback( string className, void functionref( entity, var ) callbackFunc )"
!!! cpp-function "void RemoveDamageCallback( string className, void functionref( entity, var ) callbackFunc )"
!!! cpp-function "void RunClassDamageCallbacks( entity ent, var damageInfo )"
!!! cpp-function "void AddDamageFinalCallback( string className, void functionref( entity, var ) callbackFunc )"
!!! cpp-function "void RunClassDamageFinalCallbacks( entity ent, var damageInfo )"
!!! cpp-function "void AddPostDamageCallback( string className, void functionref( entity, var ) callbackFunc )"
!!! cpp-function "void RunClassPostDamageCallbacks( entity ent, var damageInfo )"
!!! cpp-function "void AddDamageByCallback( string className, void functionref( entity, var ) callbackFunc )"
!!! cpp-function "void AddDamageCallbackSourceID( int id, void functionref(entity, var) callbackFunc )"
!!! cpp-function "void AddDeathCallback( string className, void functionref( entity, var ) callbackFunc )"
!!! cpp-function "void RemoveDeathCallback( string className, void functionref( entity, var ) callbackFunc )"
!!! cpp-function "void AddSoulDeathCallback( void functionref( entity, var ) callbackFunc )"
!!! cpp-function "void AddCallback_OnTouchHealthKit( string className, bool functionref( entity player, entity healthpack ) callbackFunc )"
!!! cpp-function "void AddCallback_OnPlayerRespawned( void functionref( entity ) callbackFunc )"
!!! cpp-function "void AddCallback_OnPlayerKilled( void functionref( entity victim, entity attacker, var damageInfo ) callbackFunc )"
!!! cpp-function "void AddCallback_OnNPCKilled( void functionref( entity victim, entity attacker, var damageInfo ) callbackFunc )"
!!! cpp-function "void AddCallback_OnTitanDoomed( void functionref( entity victim, var damageInfo ) callbackFunc )"
!!! cpp-function "void AddCallback_OnTitanHealthSegmentLost( void functionref( entity victim, entity attacker ) callbackFunc )"
!!! cpp-function "void AddCallback_OnClientConnecting( void functionref( entity player ) callbackFunc )"
!!! cpp-function "void AddCallback_OnClientConnected( void functionref( entity player ) callbackFunc )"
!!! cpp-function "void AddCallback_OnClientDisconnected( void functionref( entity player ) callbackFunc )"
!!! cpp-function "void AddCallback_OnPilotBecomesTitan( void functionref( entity pilot, entity npc_titan ) callbackFunc )"
!!! cpp-function "void AddCallback_OnTitanBecomesPilot( void functionref( entity pilot, entity npc_titan ) callbackFunc )"
!!! cpp-function "void AddCallback_OnPlayerAssist( void functionref( entity attacker, entity victim ) callbackFunc )"
!!! cpp-function "void AddCallback_EntityChangedTeam( string className, void functionref( entity ent ) callbackFunc )"
!!! cpp-function "void AddCallback_OnTitanGetsNewTitanLoadout( void functionref( entity titan, TitanLoadoutDef newTitanLoadout ) callbackFunc )"
!!! cpp-function "void AddCallback_OnPlayerGetsNewPilotLoadout( void functionref( entity player, PilotLoadoutDef newTitanLoadout ) callbackFunc )"
!!! cpp-function "void AddCallback_OnUpdateDerivedTitanLoadout( void functionref( TitanLoadoutDef newTitanLoadout ) callbackFunc )"
!!! cpp-function "void AddCallback_OnUpdateDerivedPlayerTitanLoadout( void functionref( entity player, TitanLoadoutDef newTitanLoadout ) callbackFunc )"
!!! cpp-function "void AddCallback_OnUpdateDerivedPilotLoadout( void functionref( PilotLoadoutDef newPilotLoadout ) callbackFunc )"
!!! cpp-function "void AddClientCommandCallback( string commandString, bool functionref( entity player, array<string> args ) callbackFunc )"
!!! cpp-function "void AddPlayerDropScriptedItemsCallback( void functionref(entity player) callbackFunc )"
!!! cpp-function "void RegisterForDamageDeathCallbacks( entity ent )"
!!! cpp-function "void AddTitanCallback_OnHealthSegmentLost( entity ent, void functionref( entity titan, entity victim ) callbackFunc )"
!!! cpp-function "void RemoveTitanCallback_OnHealthSegmentLost( entity ent, void functionref( entity titan, entity victim ) callbackFunc )"
!!! cpp-function "void AddEntityCallback_OnDamaged( entity ent, void functionref( entity ent, var damageInfo ) callbackFunc )"
!!! cpp-function "void RemoveEntityCallback_OnDamaged( entity ent, void functionref( entity ent, var damageInfo ) callbackFunc )"
!!! cpp-function "void AddEntityCallback_OnPostDamaged( entity ent, void functionref( entity ent, var damageInfo ) callbackFunc )"
!!! cpp-function "void RemoveEntityCallback_OnPostDamaged( entity ent, void functionref( entity ent, var damageInfo ) callbackFunc )"
!!! cpp-function "void AddEntityCallback_OnKilled( entity ent, void functionref( entity, var ) callbackFunc )"
!!! cpp-function "void RemoveEntityCallback_OnKilled( entity ent, void functionref( entity, var ) callbackFunc )"
!!! cpp-function "void AddEntityCallback_OnPostShieldDamage( entity ent, void functionref( entity, var, float ) callbackFunc )"
!!! cpp-function "void RemoveEntityCallback_OnPostShieldDamage( entity ent, void functionref( entity, var, float ) callbackFunc )"
!!! cpp-function "void AddPlayerMovementEventCallback( entity player, int playerMovementEvent, void functionref( entity player ) callbackFunc )"
!!! cpp-function "void RemovePlayerMovementEventCallback( entity player, int playerMovementEvent, void functionref( entity player ) callbackFunc )"
!!! cpp-function "void AddCallback_OnPlayerInventoryChanged( void functionref( entity ) callbackFunc )"

## _codecallbacks_player_input.gnut:

!!! cpp-function "void AddPlayerInputEventCallback_Internal( entity player, PlayerInputEventCallbackStruct inputCallbackStruct ) //Not really meant to be used directly unless you know what you're doing! Use utility functions like AddButtonPressedPlayerInputCallback instead"
!!! cpp-function "void RemovePlayerInputEventCallback_Internal( entity player, PlayerInputEventCallbackStruct inputCallbackStruct ) //Not really meant to be used directly unless you know what you're doing! Use utility functions like RemoveButtonPressedPlayerInputCallback instead"
!!! cpp-function "bool InputEventCallbackAlreadyExists( entity player, PlayerInputEventCallbackStruct inputCallbackStruct )"
!!! cpp-function "void AddPlayerHeldButtonEventCallback( entity player, int buttonEnum,  void functionref( entity player ) callbackFunc, float buttonHeldTime = 1.0 )"
!!! cpp-function "void RemovePlayerHeldButtonEventCallback( entity player, int buttonEnum,  void functionref( entity player ) callbackFunc, float buttonHeldTime = 1.0 )"
!!! cpp-function "bool HeldEventCallbackAlreadyExists( entity player, PlayerHeldButtonEventCallbackStruct callbackStruct )"
!!! cpp-function "void AddButtonPressedPlayerInputCallback( entity player, int buttonEnum, void functionref( entity player ) callbackFunc )"
!!! cpp-function "void RemoveButtonPressedPlayerInputCallback( entity player, int buttonEnum, void functionref( entity player ) callbackFunc )"
!!! cpp-function "void AddButtonReleasedPlayerInputCallback( entity player, int buttonEnum, void functionref( entity player ) callbackFunc )"
!!! cpp-function "void RemoveButtonReleasedPlayerInputCallback( entity player, int buttonEnum, void functionref( entity player ) callbackFunc )"
!!! cpp-function "void RunHeldCallbackAfterTimePasses( entity player, PlayerHeldButtonEventCallbackStruct callbackStruct )"
!!! cpp-function "string GetEndSignalNameForHeldButtonCallback( PlayerHeldButtonEventCallbackStruct callbackStruct  )"
!!! cpp-function "bool InputCallbackStructsAreTheSame( PlayerInputEventCallbackStruct callbackStruct1, PlayerInputEventCallbackStruct callbackStruct2  ) //Really just a comparison function because == does a compare by reference, not a compare by value"
!!! cpp-function "bool PlayerInputsMatchCallbackInputs( int cmdsHeld, int cmdsPressed, int cmdsReleased, PlayerInputEventCallbackStruct callbackStruct  )"
!!! cpp-function "bool HeldButtonCallbackStructsAreTheSame( PlayerHeldButtonEventCallbackStruct struct1, PlayerHeldButtonEventCallbackStruct struct2 ) //Really just a comparison function because == does a compare by reference, not a compare by value"
!!! cpp-function "void TurnOffInputCallbacksIfNecessary( entity player )"
!!! cpp-function "PlayerInputAxisEventCallbackStruct MakePressedForwardCallbackStruct()"
!!! cpp-function "void AddPlayerPressedForwardCallback( entity player, bool functionref( entity player ) callbackFunc, float debounceTime = 2.0 )"
!!! cpp-function "void RemovePlayerPressedForwardCallback( entity player, bool functionref( entity player ) callbackFunc, float debounceTime = 2.0 )"
!!! cpp-function "PlayerInputAxisEventCallbackStruct MakePressedBackCallbackStruct()"
!!! cpp-function "void AddPlayerPressedBackCallback( entity player, bool functionref( entity player ) callbackFunc, float debounceTime = 2.0 )"
!!! cpp-function "void RemovePlayerPressedBackCallback( entity player, bool functionref( entity player ) callbackFunc, float debounceTime = 2.0 )"
!!! cpp-function "PlayerInputAxisEventCallbackStruct MakePressedLeftCallbackStruct()"
!!! cpp-function "void AddPlayerPressedLeftCallback( entity player, bool functionref( entity player ) callbackFunc, float debounceTime = 2.0 )"
!!! cpp-function "void RemovePlayerPressedLeftCallback( entity player, bool functionref( entity player ) callbackFunc, float debounceTime = 2.0 )"
!!! cpp-function "PlayerInputAxisEventCallbackStruct MakePressedRightCallbackStruct()"
!!! cpp-function "void AddPlayerPressedRightCallback( entity player, bool functionref( entity player ) callbackFunc, float debounceTime = 2.0 )"
!!! cpp-function "void RemovePlayerPressedRightCallback( entity player, bool functionref( entity player ) callbackFunc, float debounceTime = 2.0 )"
!!! cpp-function "void AddPlayerInputAxisEventCallback_Internal( entity player, PlayerInputAxisEventCallbackStruct callbackStruct )"
!!! cpp-function "void RemovePlayerInputAxisEventCallback_Internal( entity player, PlayerInputAxisEventCallbackStruct callbackStruct )"
!!! cpp-function "bool InputAxisEventCallbackAlreadyExists( entity player, PlayerInputAxisEventCallbackStruct callbackStruct )"
!!! cpp-function "bool InputAxisCallbackStructsAreTheSame( PlayerInputAxisEventCallbackStruct callbackStruct1, PlayerInputAxisEventCallbackStruct callbackStruct2  ) //Really just a comparison function because == does a compare by reference, not a compare by value"
!!! cpp-function "bool ShouldRunPlayerInputAxisCallbackFunc( float horizAxis, float vertAxis, PlayerInputAxisEventCallbackStruct callbackStruct )"
!!! cpp-function "bool IsValidPlayerInputAxisEventCallbackStruct( PlayerInputAxisEventCallbackStruct callbackStruct  )"
!!! cpp-function "void RunPlayerInputAxisCallbackFunc( entity player, PlayerInputAxisEventCallbackStruct callbackStruct )"
!!! cpp-function "void RunInputAxisCallbackAfterTimePasses( entity player, PlayerInputAxisEventCallbackStruct callbackStruct )"


## _global_entities.gnut:

!!! cpp-function "function( callback )"

## _items.nut:

!!! cpp-function "void StatsCallback_ItemUnlockUpdate( entity player, float changeInValue, string itemRef )"
!!! cpp-function "void StatsCallback_SubItemUnlockUpdate( entity player, float changeInValue, string fullRef )"

## _on_spawned.gnut:

!!! cpp-function "void AddSpawnCallback( string classname, void functionref( entity ) func )"
!!! cpp-function "void AddSpawnCallbackEditorClass( string classname, string editorClassname, void functionref( entity ) func )"
!!! cpp-function "function( entity self )"
!!! cpp-function "function( entity self )"
!!! cpp-function "void RunScriptNameCallbacks( entity ent )"
!!! cpp-function "void AddSpawnCallback_ScriptName( string scriptName, void functionref( entity ) func )"
!!! cpp-function "void RunScriptNoteworthyCallbacks( entity ent )"
!!! cpp-function "void AddScriptNoteworthySpawnCallback( string script_noteworthy, void functionref( entity ) func )"

## _passives.gnut:

!!! cpp-function "void PassiveDeathCallback( entity player, var damageInfo )"

## _script_triggers.gnut:

!!! cpp-function "void AddCallback_ScriptTriggerEnter( entity trigger, void functionref( entity, entity ) callbackFunc )"
!!! cpp-function "void AddCallback_ScriptTriggerLeave( entity trigger, void functionref( entity, entity )  callbackFunc )"

## _utility_shared.nut:

!!! cpp-function "void AddCallback_OnUseEntity( entity ent, callbackFunc )"
!!! cpp-function "void RunCallbacks_EntitiesDidLoad()"
!!! cpp-function "void AddCallback_EntitiesDidLoad( EntitiesDidLoadCallbackType callback )"

## _utility.gnut:

!!! cpp-function "void AddCallback_GameStateEnter( int gameState, void functionref() callbackFunc )"
!!! cpp-function "void GM_SetObserverFunc( void functionref( entity ) callbackFunc )"
!!! cpp-function "void GM_AddPlayingThinkFunc( void functionref() callbackFunc )"
!!! cpp-function "void GM_AddThirtySecondsLeftFunc( void functionref() callbackFunc )"
!!! cpp-function "void GM_SetMatchProgressAnnounceFunc( void functionref( int ) callbackFunc )"
!!! cpp-function "void AddCallback_NPCLeeched( void functionref( entity, entity ) callbackFunc )"

## sh_loadouts.nut:

!!! cpp-function "void UpdateDerivedPilotLoadoutData( PilotLoadoutDef loadout, bool doOverrideCallback = true )"

## ai/_ai_marvin_faces.gnut:

!!! cpp-function "void MarvinSpawnCallback( entity npc_marvin )"

## ai/_ai_mortar_titans.gnut:

!!! cpp-function "void MortarMissileFiredCallback( entity missile, entity weaponOwner )"

## ai/_ai_nuke_titans.gnut:

!!! cpp-function "void AutoTitan_NuclearPayload_PostDamageCallback( entity titan, var damageInfo )"

## ai/_ai_pilots.gnut:

!!! cpp-function "function( pilot, titan )"
!!! cpp-function "function( pilot, titan )"
!!! cpp-function "function( callbackFunc )"
!!! cpp-function "function( callbackFunc )"

## ai/_ai_suicide_spectres.gnut:

!!! cpp-function "void SpectreSuicideOnDamaged_Callback( entity spectre, var damageInfo )"

## earn_meter/sv_earn_meter.gnut:

!!! cpp-function "void AddEarnMeterThresholdEarnedCallback( float thresholdForCallback, void functionref( entity player ) callbackFunc, bool triggerFunctionOnFullEarnMeter = false )"
!!! cpp-function "bool AlreadyContainsThresholdCallback( EarnMeterThresholdEarnedStruct thresholdStruct )"
!!! cpp-function "void SetCallback_EarnMeterGoalEarned( void functionref( entity player ) callback )"
!!! cpp-function "void SetCallback_EarnMeterRewardEarned( void functionref( entity player ) callback )"
!!! cpp-function "void DummyRewardEarnedCallback( entity player )"
!!! cpp-function "void DummyGoalEarnedCallback( entity player )"

## gamemodes/_frontline.gnut:

!!! cpp-function "void AddCalculateFrontlineCallback( void functionref() callbackFunc )"

## mp/_base_gametype.gnut:

!!! cpp-function "bool ScriptCallback_ShouldEntTakeDamage( entity ent, damageInfo )"
!!! cpp-function "function( ent, callbackFunc )"

## mp/_bleedout.gnut:

!!! cpp-function "void Bleedout_SetCallback_OnPlayerStartBleedout( void functionref(entity) callback )"
!!! cpp-function "void Bleedout_SetCallback_OnPlayerGiveFirstAid( void functionref(entity) callback )"


## mp/_spawn_functions.nut:

!!! cpp-function "void EmptyDeathCallback( entity _1, var _2 )"

## mp/_spectre_rack.nut:

!!! cpp-function "void AddSpectreRackCallback( void functionref( entity, entity ) func )"


## mp/_titan_tether.gnut:

!!! cpp-function "void AddOnTetherCallback( void functionref( entity, entity ) callback )"

## mp/_vr.nut:

!!! cpp-function "void VR_GroundTroopsDeathCallback( entity guy, var damageInfo )"

## pilot/_leeching.gnut:

!!! cpp-function "void TryLeechStartCallback( entity self, entity leecher )"
!!! cpp-function "void TryLeechAbortCallback( entity self, entity leecher )"

## pilot/_zipline.gnut:

!!! cpp-function "void AddCallback_ZiplineStart( void functionref(entity,entity) callback )"
!!! cpp-function "void AddCallback_ZiplineStop( void functionref(entity) callback )"

## rodeo/_rodeo_titan.gnut:

!!! cpp-function "void AddOnRodeoStartedCallback( void functionref(entity,entity) callbackFunc )"
!!! cpp-function "void AddOnRodeoEndedCallback( void functionref(entity,entity) callbackFunc )"
!!! cpp-function "void SetApplyBatteryCallback( void functionref(entity,entity,entity) func )"

## weapons/_arc_cannon.nut:

!!! cpp-function "void ClientDestroyCallback_ArcCannon_Stop( entity ent )"

## weapons/_grenade.nut:

!!! cpp-function "void ClientDestroyCallback_GrenadeDestroyed( entity grenade )"

## weapons/_weapon_utility.nut:

!!! cpp-function "unknown ServerCallback_GuidedMissileDestroyed()"
!!! cpp-function "unknown ServerCallback_AirburstIconUpdate( toggle )"
