Player
------

Functions for getting player, and methods of the player object

.. cpp:function:: entity GetLocalViewPlayer()

    player you're watching (can be replay)

.. cpp:function:: entity GetLocalClientPlayer()

.. cpp:function:: array<entity> GetPlayerArray()


.. cpp:function:: array<entity> GetPlayerArrayOfTeam( int team )

.. cpp:function:: array<entity> GetPlayerArrayOfEnemies_Alive( int team )

.. cpp:class:: player : public entity	

    .. cpp:function::  unknown GetActivePilotLoadoutIndex( player )

    .. cpp:function::  entity GetActiveWeapon()

    .. cpp:function::  unknown GetActiveWeaponPrimaryAmmoLoaded()

    .. cpp:function::  unknown GetAngles()

    .. cpp:function::  unknown GetAntiTitanWeapon()

    .. cpp:function::  unknown GetAttachmentAngles()

    .. cpp:function::  unknown GetAttachmentOrigin()

    .. cpp:function::  unknown GetBodyGroupModelCount()

    .. cpp:function::  unknown GetBossPlayerName()

    .. cpp:function::  unknown GetCinematicEventFlags()

    .. cpp:function::  unknown GetCockpit()

    .. cpp:function::  unknown GetFirstPersonProxy()

    .. cpp:function::  unknown GetForcedDialogueOnly()

    .. cpp:function::  unknown GetGen()

    .. cpp:function::  float GetHealthFrac(player)

    .. cpp:function::  unknown GetLastPingTime()

    .. cpp:function::  unknown GetLevel()

    .. cpp:function::  unknown GetLifeState()

    .. cpp:function::  entity GetLocalClientPlayer()

    .. cpp:function::  entity GetLocalViewPlayer()

    .. cpp:function::  entity GetMainWeapons()

    .. cpp:function::  unknown GetMaxHealth()

    .. cpp:function::  unknown GetModelName()

    .. cpp:function::  unknown GetNextTitanRespawnAvailable()

    .. cpp:function::  unknown GetNumPingsAvailable()

    .. cpp:function::  unknown GetObjectiveEndTime()

    .. cpp:function::  unknown GetObjectiveEntity()

    .. cpp:function::  unknown GetObjectiveIndex()

    .. cpp:function::  unknown GetObserverMode()

    .. cpp:function::  entity GetOffhandWeapon(slot)

    .. cpp:function::  unknown GetOffhandWeapons()

    .. cpp:function::  Vector GetOrigin() 
            
            (x, y, z)

    .. cpp:function::  unknown GetParent()

    .. cpp:function::  unknown GetPersistentSpawnLoadoutIndex( player, "pilot" )

    .. cpp:function::  unknown GetPetTitan()

    .. cpp:function::  unknown GetPilotLoadoutFromPersistentData( player, loadoutIndex )

    .. cpp:function::  unknown GetPingGroupAccumulator()

    .. cpp:function::  unknown GetPingGroupStartTime()

    .. cpp:function::  array<entity> GetPlayerArray()

    .. cpp:function::  array<entity> GetPlayerArrayOfEnemies_Alive( int team )

    .. cpp:function::  array<entity> GetPlayerArrayOfTeam( int team )

    .. cpp:function::  unknown GetPlayerClass()

    .. cpp:function::  PGS_ELIMINATED GetPlayerGameStat()

    .. cpp:function::  string GetPlayerName()

    .. cpp:function::  string GetPlayerNameWithClanTag() 
    
        networks are disabled in northstar

    .. cpp:function::  unknown GetPlayerNetBool( net_bool_name )

        example

        .. code-block:: javascript

            GetPlayerNetBool( "shouldShowWeaponFlyout" )

    .. cpp:function::  unknown GetPlayerSettings()

    .. cpp:function::  unknown GetPlayerSettingsField( "weaponClass" )

    .. cpp:function::  unknown GetShieldHealth()

    .. cpp:function::  float GetShieldHealthFrac( entity )

    .. cpp:function::  unknown GetShieldHealthMax()

    .. cpp:function::  int GetTeam()

    .. cpp:function::  unknown GetTitanSoul()
        
        .. code-block:: javascript
        
            if IsTitan() | player.GetPetTitan().GetTitanSoul() if !IsTitan()

    .. cpp:function::  vector GetVelocity()

    .. cpp:function::  unknown GetViewForward()

    .. cpp:function::  unknown GetViewModelEntity()

    .. cpp:function::  unknown GetViewRight()

    .. cpp:function::  unknown GetViewUp()

    .. cpp:function::  Vector GetViewVector() 
    
        vector representation of your look direction. <0, 0, 1> -> looking straight up

    .. cpp:function::  unknown GetWeaponAmmoStockpile()

    .. cpp:function::  unknown GetXP()

    .. cpp:function::  float GetZoomFrac() 
    
        0.0 (no zoom) - 1.0 (full zoom)

    .. cpp:function::  unknown GiveArmor( player, int amount )

    .. cpp:function::  unknown GiveOffhandWeapon( name, slot )

    .. cpp:function::  unknown GivePilotLoadout( player, loadout )

    .. cpp:function::  unknown GiveWeapon()

    .. cpp:function::  unknown GiveWeaponPowerUp( player, string newWeapon )

    .. cpp:function::  unknown TakeOffhandWeapon()

    .. cpp:function::  unknown TakeWeaponNow()

    .. cpp:function::  unknown SetActiveWeaponByName()

    .. cpp:function::  unknown SetBodygroup()

    .. cpp:function::  unknown SetDodgePowerDelayScale()

    .. cpp:function::  unknown SetHealth()

    .. cpp:function::  unknown SetLastPingTime()

    .. cpp:function::  unknown SetMaxHealth()

    .. cpp:function::  unknown SetNumPingsAvailable()

    .. cpp:function::  unknown SetNumPingsUsed()

    .. cpp:function::  unknown SetOrigin()

    .. cpp:function::  unknown SetPowerRegenRateScale()

    .. cpp:function::  unknown SetShieldHealth()

    .. cpp:function::  unknown SetShieldHealthMax()

    .. cpp:function::  unknown SetTitanDisembarkEnabled( bool )



    .. cpp:function::  unknown AddThreatScopeColorStatusEffect(weaponOwner)

    .. cpp:function::  unknown CameraPosition()

    .. cpp:function::  unknown CockpitStartDisembark()

    .. cpp:function::  unknown ContextAction_IsActive()

    .. cpp:function::  unknown ContextAction_IsBusy()

    .. cpp:function::  unknown EyeAngles()

    .. cpp:function::  unknown EyePosition()

    .. cpp:function::  unknown FindBodyGroup()

    .. cpp:function::  unknown LookupAttachment()

    .. cpp:function::  unknown Lunge_ClearTarget()

    .. cpp:function::  unknown Minimap_GetZOrder()

    .. cpp:function::  unknown RemoveThreatScopeColorStatusEffect(weaponOwner)

    .. cpp:function::  bool HasBadReputation()

    .. cpp:function::  bool HasMic()

    .. cpp:function::  bool InPartyChat()

    .. cpp:function::  bool IsAlive(player)

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

    .. cpp:function::  bool IsValid( player )

    .. cpp:function::  bool IsWatchingKillReplay()

    .. cpp:function::  bool IsWatchingReplay()

    .. cpp:function::  bool IsWeaponDisabled()

    .. cpp:function::  bool Lunge_IsActive()

    .. cpp:function::  bool PlayerMelee_IsAttackActive()
