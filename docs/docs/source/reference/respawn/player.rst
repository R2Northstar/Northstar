Player
------

Functions for getting player, and methods of the player object

.. cpp:function::  bool IsAlive( entity ent )

.. cpp:function::  bool IsValid( entity ent )

.. cpp:function:: entity GetLocalViewPlayer()

    player you're watching (can be replay)

.. cpp:function:: entity GetLocalClientPlayer()

.. cpp:function:: array<entity> GetPlayerArray()

.. cpp:function:: array<entity> GetPlayerArrayEx( string class, int team, vector origin, float radius )

    returns a list of every player of the specified class in radius relative to origin. The parameter ``class`` must be one of these strings:  ``titan``, ``pilot`` or ``any``.

.. cpp:function:: array<entity> GetPlayerArrayOfTeam( int team )

    array of players from team index

.. cpp:function:: array<entity> GetPlayerArrayOfTeam_Alive( int team )

    every player alive in team

.. cpp:function:: array<entity> GetPlayerArrayOfEnemies_Alive( int team )

.. cpp:function:: array<entity> GetSortedPlayers( IntFromEntityCompare compareFunc, int team)

    returns list of every player in ``team`` sorted by ``compareFunc``. If ``team`` is 0 returns a sorted array of every player.
    `squirrel compare function example <http://www.squirrel-lang.org/squirreldoc/reference/language/builtin_functions.html#array.sort>`_

    .. code-block:: javascript

        GetSortedPlayers(int function(entity player1, entity player2) {
            if(player1.GetPlayerGameStat(PGS_PING)>player2.GetPlayerGameStat(PGS_PING))
                return 1

            else if(player1.GetPlayerGameStat(PGS_PING)<player2.GetPlayerGameStat(PGS_PING))
                return -1

            return 0 }, 0)

.. cpp:function:: entity GetTitanFromPlayer( entity player)

    if the player is a titan, returns the player. If not, returns the player's pet titan

.. cpp:class:: player : public entity

    .. cpp:function::  int GetActivePilotLoadoutIndex( entity player )

    .. cpp:function::  entity GetActiveWeapon()

    .. cpp:function::  int GetActiveWeaponPrimaryAmmoLoaded()

    .. cpp:function::  vector GetAngles()

        direction the entity is facing

    .. cpp:function::  entity GetAntiTitanWeapon()

    .. cpp:function::  vector GetAttachmentAngles()

    .. cpp:function::  vector GetAttachmentOrigin()

    .. cpp:function::  int GetBodyGroupModelCount()

    .. cpp:function::  string GetBossPlayerName()

    .. cpp:function::  int GetCinematicEventFlags()

    .. cpp:function::  entity GetCockpit()

    .. cpp:function::  entity GetFirstPersonProxy()

    .. cpp:function::  bool GetForcedDialogueOnly()

    .. cpp:function::  int GetGen()

    .. cpp:function::  float GetHealthFrac( entity player )

    .. cpp:function::  float GetLastPingTime()

    .. cpp:function::  int GetLevel()

    .. cpp:function::  int GetLifeState()

    .. cpp:function::  entity GetLocalClientPlayer()

    .. cpp:function::  entity GetLocalViewPlayer()

    .. cpp:function::  array<entity> GetMainWeapons()

    .. cpp:function::  int GetMaxHealth()

    .. cpp:function::  asset GetModelName()

    .. cpp:function::  float GetNextTitanRespawnAvailable()

    .. cpp:function::  int GetNumPingsAvailable()

    .. cpp:function::  float GetObjectiveEndTime()

    .. cpp:function::  unknown GetObjectiveEntity()

    .. cpp:function::  int GetObjectiveIndex()

        returns the index of the player objective. ObjIndex 0 means no objective

    .. cpp:function::  int GetObserverMode()

        returns either ``OBS_MODE_IN_EYE`` (first person) or ``OBS_MODE_CHASE`` (third person)

    .. cpp:function::  entity GetOffhandWeapon( int slot )

    .. cpp:function::  array<entity> GetOffhandWeapons()

    .. cpp:function::  vector GetOrigin()

        entity position

    .. cpp:function::  entity GetParent()

    .. cpp:function::  int GetPersistentSpawnLoadoutIndex( entity player, string playerClass )

        playerClasses: ``"pilot"`` ``"titan"``. This returns null for every other string.

    .. cpp:function::  entity GetPetTitan()

        auto titan of player

    .. cpp:function::  PilotLoadoutDef GetPilotLoadoutFromPersistentData( entity player, int loadoutIndex )

        stored loadout data of player

    .. cpp:function::  int GetPingGroupAccumulator()

    .. cpp:function::  float GetPingGroupStartTime()

    .. cpp:function::  string GetPlayerClass()

        "titan", "spectator" or "pilot"

    .. cpp:function::  PGS_ELIMINATED GetPlayerGameStat()

    .. cpp:function::  string GetPlayerName()

        player (origin) username

    .. cpp:function::  string GetPlayerNameWithClanTag()

    .. cpp:function::  bool GetPlayerNetBool( string net_bool_name )

        example

        .. code-block:: javascript

            GetPlayerNetBool( "shouldShowWeaponFlyout" )

    .. cpp:function::  string GetPlayerSettings()

    .. cpp:function::  string GetPlayerSettingsField( string )

        some settings: ``"weaponClass"`` ``"gravityscale"`` ``"airSpeed"`` ``"airAcceleration"``

    .. cpp:function::  int GetShieldHealth()

    .. cpp:function::  float GetShieldHealthFrac( entity )

    .. cpp:function::  int GetShieldHealthMax()

    .. cpp:function::  int GetTeam()

    .. cpp:function::  entity GetTitanSoul()

        .. code-block:: javascript

            if IsTitan() | player.GetPetTitan().GetTitanSoul() if !IsTitan()

    .. cpp:function::  vector GetVelocity()

    .. cpp:function::  vector GetViewForward()

    .. cpp:function::  entity GetViewModelEntity()

    .. cpp:function::  vector GetViewRight()

    .. cpp:function::  vector GetViewUp()

    .. cpp:function::  vector GetViewVector()

    .. cpp:function::  int GetWeaponAmmoStockpile()

    .. cpp:function::  int GetXP()

    .. cpp:function::  float GetZoomFrac()

        0.0 (no zoom) - 1.0 (full zoom)

    .. cpp:function::  void GiveArmor( entity player, int amount )

    .. cpp:function::  void GiveOffhandWeapon( string name, int slot )

    .. cpp:function::  void GivePilotLoadout( entity player, int loadout )

    .. cpp:function::  void GiveWeapon( string weapon )

    .. cpp:function::  void GiveWeaponPowerUp( entity player, string newWeapon )

    .. cpp:function::  void TakeOffhandWeapon( int offhandIndex )

        can be used for titans as well.
        some constants are: ``OFFHAND_ORDNANCE`` ``OFFHAND_SPECIAL`` ``OFFHAND_LEFT`` ``OFFHAND_INVENTORY`` ``OFFHAND_MELEE`` ``OFFHAND_EQUIPMENT`` ``OFFHAND_ANTIRODEO``

    .. cpp:function::  void TakeWeaponNow( string weaponToSwitch)

    .. cpp:function::  void SetActiveWeaponByName( string newWeapon )

    .. cpp:function::  void SetBodygroup( int bodyGroupIndex, int stateIndex )

    .. cpp:function::  void SetDodgePowerDelayScale( float delay )

    .. cpp:function::  void SetHealth(int health)

    .. cpp:function::  void SetLastPingTime( float time)

    .. cpp:function::  void SetMaxHealth( int health )

    .. cpp:function::  void SetNumPingsAvailable( int num )

    .. cpp:function::  void SetNumPingsUsed( int num )

    .. cpp:function::  void SetOrigin( vector origin )

    .. cpp:function::  void SetPowerRegenRateScale( float scale )

    .. cpp:function::  void SetShieldHealth( float health)

    .. cpp:function::  void SetShieldHealthMax( float health )

    .. cpp:function::  void SetTitanDisembarkEnabled( bool enabled )

    .. cpp:function::  void AddThreatScopeColorStatusEffect( entity weaponOwner )

    .. cpp:function::  vector CameraPosition()

    .. cpp:function::  void CockpitStartDisembark()

    .. cpp:function::  bool ContextAction_IsActive()

    .. cpp:function::  bool ContextAction_IsBusy()

    .. cpp:function::  vector EyeAngles()

    .. cpp:function::  vector EyePosition()

    .. cpp:function::  int FindBodyGroup( string bodyGroup )

    .. cpp:function::  int LookupAttachment( string attachment = "" )

    .. cpp:function::  void Lunge_ClearTarget()

    .. cpp:function::  int Minimap_GetZOrder()

    .. cpp:function::  int RemoveThreatScopeColorStatusEffect( entity player )

    .. cpp:function::  bool HasBadReputation()

    .. cpp:function::  bool HasMic()

    .. cpp:function::  bool InPartyChat()

    .. cpp:function::  bool IsEjecting()

    .. cpp:function::  bool IsHologram()

    .. cpp:function::  bool IsHuman()

    .. cpp:function::  bool IsInScoreboard( entity player )

    .. cpp:function::  bool IsInThirdPersonReplay()

    .. cpp:function::  bool IsMuted()

    .. cpp:function::  bool IsPartyLeader()

    .. cpp:function::  bool IsPartyMember( entity player )

    .. cpp:function::  bool IsPhaseShifted()

    .. cpp:function::  bool IsPlayer()

    .. cpp:function::  bool IsPlayerEliminated( entity player )

    .. cpp:function::  bool IsPlayerFemale( entity player )

    .. cpp:function::  bool IsRespawnAvailable( entity player )

    .. cpp:function::  bool IsScriptMenuOn()

    .. cpp:function::  bool IsTalking()

    .. cpp:function::  bool IsTitan()

    .. cpp:function::  bool IsTitanAvailable( entity player )

    .. cpp:function::  bool IsUsingOffhandWeapon()

    .. cpp:function::  bool IsWatchingKillReplay()

    .. cpp:function::  bool IsWatchingReplay()

    .. cpp:function::  bool IsWeaponDisabled()

    .. cpp:function::  bool Lunge_IsActive()

    .. cpp:function::  bool PlayerMelee_IsAttackActive()
