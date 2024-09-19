# Custom Northstar Callbacks

Callbacks added by Northstar

Callbacks within squirrel trigger functions when certain events occur.

They will also often pass arguments to those functions based on the callbacks used.


## List of callbacks

Please refer to [Respawn Callbacks](../respawn/callbacks.md)  for the list of callbacks defined in respawn code.

### \_codecallbacks\_common.gnut:

!!! cpp-function "void AddClientCommandNotifyCallback( string commandString, void functionref( entity player, array<string> args ) callbackFunc )"
### \_custom\_codecallbacks.gnut:

!!! cpp-function "void CServerGameDLL_OnReceivedSayTextMessageCallback()"
!!! cpp-function "void AddCallback_OnReceivedSayTextMessage( ClServer_MessageStruct functionref (ClServer_MessageStruct) callbackFunc )"

### \_items.nut:

!!! cpp-function "void AddCallback_OnRegisterCustomItems( void functionref() callback )"


### \_loadouts\_mp.gnut:

!!! cpp-function "bool ClientCommandCallback_RequestPilotLoadout( entity player, array<string> args )"
!!! cpp-function "bool ClientCommandCallback_RequestTitanLoadout( entity player, array<string> args )"
!!! cpp-function "bool ClientCommandCallback_SetPersistentLoadoutValue( entity player, array<string> args )"
!!! cpp-function "bool ClientCommandCallback_SwapSecondaryAndWeapon3PersistentLoadoutData( entity player, array<string> args )"
!!! cpp-function "bool ClientCommandCallback_SetBurnCardPersistenceSlot( entity player, array<string> args )"
!!! cpp-function "bool ClientCommandCallback_SetCallsignIcon( entity player, array<string> args )"
!!! cpp-function "bool ClientCommandCallback_SetCallsignCard( entity player, array<string> args )"
!!! cpp-function "bool ClientCommandCallback_SetFactionChoicePersistenceSlot( entity player, array<string> args )"
!!! cpp-function "bool ClientCommandCallback_LoadoutMenuClosed( entity player, array<string> args )"
!!! cpp-function "bool ClientCommandCallback_InGameMPMenuClosed( entity player, array<string> args )"

### \_menu\_callbacks.gnut:

!!! cpp-function "void MenuCallbacks_Init()"
!!! cpp-function "bool ClientCommandCallback_LeaveMatch( entity player, array<string> args )"
!!! cpp-function "bool ClientCommandCallback_GenUp( entity player, array<string> args )"

### sh\_remote_functions_mp_custom.gnut:

!!! cpp-function "void AddCallback_OnRegisteringCustomNetworkVars( void functionref() callback )"

### evac\\\_evac.gnut:

!!! cpp-function "void Evac( int evacTeam, float initialWait, float arrivalTime, float waitTime, bool functionref( entity, entity ) canBoardCallback, bool functionref( entity ) shouldLeaveEarlyCallback, void functionref( entity ) completionCallback, entity customEvacNode = null )"

### gamemodes\_gamemode_fra.nut:

!!! cpp-function "void GamemodeFRA_AddAdditionalInitCallback()"


### gamemodes\\sh\_gamemodes\_custom.gnut:

!!! cpp-function "void AddCallback_OnCustomGamemodesInit( void functionref() callback )"

### lobby\\\_lobby.gnut:

!!! cpp-function "bool ClientCommandCallback_StartPrivateMatchSearch( entity player, array<string> args )"

### lobby\\\_private\_lobby.gnut:

!!! cpp-function "bool ClientCommandCallback_PrivateMatchLaunch( entity player, array<string> args )"
!!! cpp-function "bool ClientCommandCallback_PrivateMatchSetMode( entity player, array<string> args )"
!!! cpp-function "bool ClientCommandCallback_SetCustomMap( entity player, array<string> args )"
!!! cpp-function "bool ClientCommandCallback_PrivateMatchSwitchTeams( entity player, array<string> args )"
!!! cpp-function "bool ClientCommandCallback_PrivateMatchToggleSpectate( entity player, array<string> args )"
!!! cpp-function "bool ClientCommandCallback_PrivateMatchSetPlaylistVarOverride( entity player, array<string> args )"
!!! cpp-function "bool ClientCommandCallback_ResetMatchSettingsToDefault( entity player, array<string> args )"

### melee\\sh\_melee.gnut:

!!! cpp-function "void AddCallback_IsValidMeleeExecutionTarget( bool functionref( entity attacker, entity target ) callbackFunc )"

   This callback gets triggered after the melee button is pressed to check if the action to execute the target is still valid.
   If one of the added callbacks return false the target won't be executed and will just be meleed.

!!! note

    The execution prompt still pops up.

#### mp\\\_ai_mp.gnut:

!!! cpp-function "bool SPMP_Callback_ForceAIMissPlayer( entity npc, entity player )"


### mp\\\_base\_gametype\_mp.gnut:

!!! cpp-function "bool ClientCommandCallback_spec_next( entity player, array<string> args )"
!!! cpp-function "bool ClientCommandCallback_spec_prev( entity player, array<string> args )"
!!! cpp-function "bool ClientCommandCallback_spec_mode( entity player, array<string> args )"


### mp\\\_gamestate_mp.nut:

!!! cpp-function "void AddCallback_OnRoundEndCleanup( void functionref() callback )"
!!! cpp-function "void SetTimeoutWinnerDecisionFunc( int functionref() callback )"

### ui\\ui_mouse_capture.nut:

!!! cpp-function "void AddMouseMovementCaptureHandler( var capturePanelOrMenu, void functionref( int deltaX, int deltaY ) func )"
