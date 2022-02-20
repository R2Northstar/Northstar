Player
------

Functions for getting player, and methods of the player object

.. cpp:function::  bool IsAlive( entity ent )

.. cpp:function::  bool IsValid( entity ent )

.. cpp:function:: entity GetLocalViewPlayer()

    player you're watching (can be replay)

.. cpp:function:: entity GetLocalClientPlayer()

.. cpp:function:: array<entity> GetPlayerArray()

.. cpp:function:: array<entity> GetPlayerArrayOfTeam( int team )

.. cpp:function:: array<entity> GetPlayerArrayOfTeam_Alive( int team )

.. cpp:function:: array<entity> GetPlayerArrayOfEnemies_Alive( int team )

.. cpp:function:: array<entity> GetSortedPlayers( IntFromEntityCompare compareFunc, int team)

    returns list of every player in ``team`` sorted by ``compareFunc``. If ``team`` is 0 returns a sorted array of every player.
    `squirrel compare function example <http://www.squirrel-lang.org/squirreldoc/reference/language/builtin_functions.html#array.sort>`_
    .. code-block:: javascript
        GetSortedPlayers(function(entity player1, entity player2) {
            if(player1.GetPlayerGameStat(PGS_PING)>player2.GetPlayerGameStat(PGS_PING))
                return 1

            else if(player1.GetPlayerGameStat(PGS_PING)<player2.GetPlayerGameStat(PGS_PING))
                return -1

            return 0 }, 0)

.. cpp:class:: player : public entity

    .. cpp:function::  int GetActivePilotLoadoutIndex( player )

    .. cpp:function::  entity GetActiveWeapon()

    .. cpp:function::  int GetActiveWeaponPrimaryAmmoLoaded()

    .. cpp:function::  vector GetAngles()

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

    .. cpp:function::  float GetHealthFrac(player)

    .. cpp:function::  unknown GetLastPingTime()

    .. cpp:function::  int GetLevel()

    .. cpp:function::  int GetLifeState()

    .. cpp:function::  entity GetLocalClientPlayer()

    .. cpp:function::  entity GetLocalViewPlayer()

    .. cpp:function::  array<entity> GetMainWeapons()

    .. cpp:function::  int GetMaxHealth()

    .. cpp:function::  asset GetModelName()

    .. cpp:function::  float GetNextTitanRespawnAvailable()

    .. cpp:function::  unknown GetNumPingsAvailable()

    .. cpp:function::  unknown GetObjectiveEndTime()

    .. cpp:function::  unknown GetObjectiveEntity()

    .. cpp:function::  unknown GetObjectiveIndex()

    .. cpp:function::  int GetObserverMode()

    .. cpp:function::  entity GetOffhandWeapon(slot)

    .. cpp:function::  array<entity> GetOffhandWeapons()

    .. cpp:function::  vector GetOrigin()

    .. cpp:function::  entity GetParent()

    .. cpp:function::  int GetPersistentSpawnLoadoutIndex( player, "pilot" )

    .. cpp:function::  entity GetPetTitan()

    .. cpp:function::  PilotLoadoutDef GetPilotLoadoutFromPersistentData( player, loadoutIndex )

    .. cpp:function::  unknown GetPingGroupAccumulator()

    .. cpp:function::  unknown GetPingGroupStartTime()

    .. cpp:function::  string GetPlayerClass()

    .. cpp:function::  PGS_ELIMINATED GetPlayerGameStat()

    .. cpp:function::  string GetPlayerName()

    .. cpp:function::  string GetPlayerNameWithClanTag()

    .. cpp:function::  bool GetPlayerNetBool( net_bool_name )

        example

        .. code-block:: javascript

            GetPlayerNetBool( "shouldShowWeaponFlyout" )

    .. cpp:function::  string GetPlayerSettings()

    .. cpp:function::  unknown GetPlayerSettingsField( "weaponClass" )

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

    .. cpp:function::  unknown GetXP()

    .. cpp:function::  float GetZoomFrac()

        0.0 (no zoom) - 1.0 (full zoom)

    .. cpp:function::  void GiveArmor( player, int amount )

    .. cpp:function::  void GiveOffhandWeapon( name, slot )

    .. cpp:function::  void GivePilotLoadout( player, loadout )

    .. cpp:function::  void GiveWeapon()

    .. cpp:function::  void GiveWeaponPowerUp( player, string newWeapon )

    .. cpp:function::  void TakeOffhandWeapon()

    .. cpp:function::  void TakeWeaponNow()

    .. cpp:function::  void SetActiveWeaponByName()

    .. cpp:function::  void SetBodygroup()

    .. cpp:function::  void SetDodgePowerDelayScale()

    .. cpp:function::  void SetHealth()

    .. cpp:function::  void SetLastPingTime()

    .. cpp:function::  void SetMaxHealth()

    .. cpp:function::  void SetNumPingsAvailable()

    .. cpp:function::  void SetNumPingsUsed()

    .. cpp:function::  void SetOrigin()

    .. cpp:function::  void SetPowerRegenRateScale()

    .. cpp:function::  void SetShieldHealth()

    .. cpp:function::  void SetShieldHealthMax()

    .. cpp:function::  void SetTitanDisembarkEnabled( bool )



    .. cpp:function::  void AddThreatScopeColorStatusEffect(weaponOwner)

    .. cpp:function::  vector CameraPosition()

    .. cpp:function::  void CockpitStartDisembark()

    .. cpp:function::  bool ContextAction_IsActive()

    .. cpp:function::  bool ContextAction_IsBusy()

    .. cpp:function::  vector EyeAngles()

    .. cpp:function::  vector EyePosition()

    .. cpp:function::  int FindBodyGroup()

    .. cpp:function::  int LookupAttachment()

    .. cpp:function::  void Lunge_ClearTarget()

    .. cpp:function::  int Minimap_GetZOrder()

    .. cpp:function::  int RemoveThreatScopeColorStatusEffect(weaponOwner)

    .. cpp:function::  bool HasBadReputation()

    .. cpp:function::  bool HasMic()

    .. cpp:function::  bool InPartyChat()

    .. cpp:function::  bool IsEjecting()

    .. cpp:function::  bool IsHologram()

    .. cpp:function::  bool IsHuman()

    .. cpp:function::  bool IsInScoreboard( player )

    .. cpp:function::  bool IsInThirdPersonReplay()

    .. cpp:function::  bool IsMuted()

    .. cpp:function::  bool IsPartyLeader()

    .. cpp:function::  bool IsPartyMember( player )

    .. cpp:function::  bool IsPhaseShifted()

    .. cpp:function::  bool IsPlayer()

    .. cpp:function::  bool IsPlayerEliminated( player )

    .. cpp:function::  bool IsPlayerFemale( player )

    .. cpp:function::  bool IsRespawnAvailable( player )

    .. cpp:function::  bool IsScriptMenuOn()

    .. cpp:function::  bool IsTalking()

    .. cpp:function::  bool IsTitan()

    .. cpp:function::  bool IsTitanAvailable( player )

    .. cpp:function::  bool IsUsingOffhandWeapon()

    .. cpp:function::  bool IsWatchingKillReplay()

    .. cpp:function::  bool IsWatchingReplay()

    .. cpp:function::  bool IsWeaponDisabled()

    .. cpp:function::  bool Lunge_IsActive()

    .. cpp:function::  bool PlayerMelee_IsAttackActive()
