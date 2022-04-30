Weapon
------

Methods of the weapon class

.. cpp:class:: weapon

    .. cpp:function:: string GetWeaponClassName()

        The weapon identifier

    .. cpp:function:: entity GetWeaponOwner()

        The entity that has the gun equipped.

    .. cpp:function:: int GetXP()

        Gun XP points achieved by the player.

    .. cpp:function:: int GetWeaponType()

        Returns the type of the weapon ( Sidearm, antitanweapon, etc. )

    .. cpp:function:: string GetWeaponDescription()

    .. cpp:function:: bool IsWeaponOffhand()

        Wether or not the given weapon is an offhand weaponn.

    .. cpp:function:: int GetDamageSourceID()

    .. cpp:function:: void FireWeaponBullet_Special( vector origin, vector direction, int numShots, int damageType, bool unknownPurpose1, bool unknownPurpose2, bool unknownPurpose3, bool unknownPurpose4, bool unknownPurpose5, bool activeShot, bool doTraceBrushOnly )

        The bullet fired by this has "perfect antilag" and no spread.
        An unknown parameter might control if this fires a fake bullet that doesn't do any damage. According to a comment, the fake bullet still triggers a damage callback with 0 damage, which is not supposed to happen.

    .. cpp:function:: void SetViewmodelAmmoModelIndex( int rounds )

        Set the viewmodel for weapons that have multiple models depending on how many shots are in the clip.

    .. cpp:function:: int GetCurrentAltFireIndex()

    .. cpp:function:: int GetShotCount()

    .. cpp:function:: bool IsWeaponRegenDraining()

    .. cpp:function:: void RegenerateAmmoReset()

    .. cpp:function:: float GetCoreDuration()

        Titan core duration

    Retrieve Weapon Keyvalues
    -------------------------

    .. cpp:function:: var GetWeaponInfoFileKeyField( string field )

        Returns the content of the passed keyvalue field. Use `expect` to specify the return type at compile time.

    .. cpp:function:: int GetWeaponDamageFlags()

    .. cpp:function:: bool GetAllowHeadShots()

        Wether or not the weapon is able to score critical headshot damage.
    
    .. cpp:function:: int GetAmmoPerShot()

    .. cpp:function:: int GetProjectilesPerShot()

        The Amount of individual projectiles that are fired by the weapon.

    .. cpp:function:: float GetMaxDamageFarDist()

        The maximal distance in which the weapon is able to deal damage.

    .. cpp:function:: bool ShouldPredictProjectiles()

    Weapon Settings
    ---------------

    .. cpp:function:: bool GetWeaponSettingBool( unknown )

    .. cpp:function:: int GetWeaponSettingInt( unknown )

    .. cpp:function:: int GetWeaponSettingFloat( unknown )

    .. cpp:function:: int GetWeaponSettingString( unknown )

    Projectile Settings
    -------------------

    .. cpp:function:: float GetProjectileWeaponSettingFloat( unknown)

    .. cpp:function:: int GetProjectileWeaponSettingInt( unknown )

    .. cpp:function:: float GetProjectileWeaponSettingFloat( unknown )

    .. cpp:function:: int GetProjectileWeaponSettingString( unknown )

    Clip Size
    ---------

    .. cpp:function:: int GetWeaponPrimaryClipCount()

    .. cpp:function:: int GetWeaponPrimaryClipCountMax()

    .. cpp:function:: void SetWeaponPrimaryClipCount( int clipsize )

    .. cpp:function:: void SetWeaponPrimaryClipCountAbsolute( int clipsize )

    .. cpp:function:: void SetWeaponPrimaryClipCountNoRegenReset( int clipsize )

    Reloading
    ---------

    .. cpp:function:: bool IsReloading()

    .. cpp:function:: int GetReloadMilestoneIndex()

        Reload Progress. Only used on the LStar

    ADS
    ---

    .. cpp:function:: bool IsWeaponInAds()

        Returns `true` if the gun is aimed down sights.
    
    .. cpp:function:: bool IsWeaponAdsButtonPressed()

        Returns `true` as long as the button set up for aiming is pressed.

    Forced ADS
    ----------

    .. cpp:function:: void SetForcedADS()

    .. cpp:function:: bool GetForcedADS()

    .. cpp:function:: void ClearForcedADS()

    Weapon Mods
    -----------

    .. cpp:function:: array<string> GetMods()
    
    .. cpp:function:: void AddMod( string modname )

    .. cpp:function:: void SetMods( array<string> )

    .. cpp:function:: bool HasMod( string modname )

    .. cpp:function:: void SetModBitField( int mods )

    .. cpp:function:: void SetProScreenOwner( entity player )

    .. cpp:function:: void SetProScreenIntValForIndex( int index, int value )

        consts for index:
        `PRO_SCREEN_INT_LIFETIME_KILLS` & `PRO_SCREEN_INT_MATCH_KILLS`

    Smart Ammo
    ----------

    .. cpp:function:: bool SmartAmmo_IsEnabled()

    .. cpp:function:: unknown<unknown> SmartAmmo_GetTargets()

    .. cpp:function:: void SmartAmmo_TrackEntity( entity hitEnt, LMG_SMART_AMMO_TRACKER_TIME )

    .. cpp:function:: void SmartAmmo_UntrackEntity( entity target )

    .. cpp:function:: array<entity> SmartAmmo_GetStoredTargets()
    
    .. cpp:function:: string GetSmartAmmoWeaponType()

        Check if weaponType is valid: `Assert( weaponType in VALID_WEAPON_TYPES )`

    .. cpp:function:: void SmartAmmo_Clear( true, false )

    .. cpp:function:: vector SmartAmmo_GetFirePosition( entity target, int burstIndex )

    .. cpp:function:: int SmartAmmo_GetNumTrackersOnEntity( entity target )

    Burst Weapons
    -------------

    .. cpp:function:: int GetBurstFireShotsPending()

    .. cpp:function:: int GetWeaponBurstFireCount()

    .. cpp:function:: void SetWeaponBurstFireCount( int amount )

    .. cpp:function:: bool IsBurstFireInProgress()

    Ion Energy Weapons
    ------------------

    .. cpp:function:: int GetWeaponCurrentEnergyCost()

    .. cpp:function:: void ResetWeaponToDefaultEnergyCost()

    .. cpp:function:: void SetWeaponEnergyCost()
    
    Charge Weapons
    --------------

    .. cpp:function:: float GetWeaponChargeLevel()

    .. cpp:function:: float GetWeaponChargeLevelMax()

    .. cpp:function:: float GetWeaponChargeFraction()

    .. cpp:function:: int GetChargeAnimIndex()

    .. cpp:function:: void SetChargeAnimIndex()

    .. cpp:function:: float SetWeaponChargeFraction()

    .. cpp:function:: float SetWeaponChargeFractionForced()

    .. cpp:function:: bool IsChargeWeapon()
    
    .. cpp:function:: float GetWeaponChargeTime()

    .. cpp:function:: void ForceRelease()

    .. cpp:function:: bool IsForceReleaseFromServer()

    Sustained Discharge Weapons
    ---------------------------

    .. cpp:function:: void SetSustainedDischargeFractionForced( float frac )

    .. cpp:function:: bool IsSustainedDischargeWeapon()

    .. cpp:function:: float GetSustainedDischargeDuration()

    Kickscale
    ---------

    .. cpp:function:: void SetAttackKickScale( float scale )

    .. cpp:function:: void SetAttackKickRollScale( float scale )

    Weapon Firing
    -------------

    .. cpp:function:: entity FireWeaponBullet( vector origin, vector dir, 1, damageType )

    .. cpp:function:: entity FireWeaponBolt( vector origin, vector dir, float projectileSpeed, int contactDamageType, int explosionDamageType, bool predict, int index )

    .. cpp:function:: entity FireWeaponMissile( vector origin, vector dir, float missileSpeed, int contactDamageType, int explosionDamageType, bool doPopup, bool predict )

    .. cpp:function:: entity FireWeaponGrenade( vector attackPos, vector throwVelocity, vector angularVelocity, float fuseTime, int contactDamageType, int explosionDamageType, bool isPredicted, bool isLagCompensated, bool bounce? )

    Disabled Weapons
    --------------

    .. cpp:function:: bool AllowUse()

        Allows if the weapon can be used. Independent from `SetNextAttackAllowedTime`.

    .. cpp:function:: void SetNextAttackAllowedTime( int time )

        The Weapon can't be used until the specified time is reached.

        .. code-block:: javascript

            weapon.SetNextAttackAllowedTime( Time() ) // Set the gun now usable

    .. cpp:function:: bool IsReadyToFire()

    .. cpp:function:: void ForceDryfireEvent()

    Weapon Positioning
    ------------------

    .. cpp:function:: vector GetAttackDirection()

        Barrel direction

    .. cpp:function:: vector GetAttackPosition()

        Barrel position

    Weapon Sounds / Effects
    -----------------------

    .. cpp:function:: void StopWeaponEffect( asset effect1P, asset effect3P )
	
    .. cpp:function:: void StopWeaponSound( string sound )

    .. cpp:function:: void EmitWeaponNpcSound( float soundRadius, float idk )

    .. cpp:function:: void PlayWeaponEffect( asset effect1P, asset effect3P, string tagName )

    .. cpp:function:: void PlayWeaponEffectNoCull( asset effect1P, asset effect3P, string tagName )

	.. cpp:function:: void EmitWeaponSound( string sound )

    .. cpp:function:: void EmitWeaponSound_1p3p( string sound1P, string sound3P )

    .. cpp:function:: int PlayWeaponEffectReturnViewEffectHandle( asset fxAlias, asset asset, string tag )

    Grenades
    -----------

    .. cpp:function:: float GetGrenadeFuseTime()

        Note that fuse time of 0 means the grenade won't explode on its own, instead it depends on OnProjectileCollision() functions to be defined and explode there. Arguably in this case grenade_fuse_time shouldn't be 0, but an arbitrarily large number instead.

    Weapon Skins and Camo
    ---------------------

    .. cpp:function:: void SetWeaponSkin( int index )

    .. cpp:function:: void SetSkin( int index )

    .. cpp:function:: void SetWeaponCamo( int index )

    .. cpp:function:: void SetCamo( int index )

    Script
    ------

    .. cpp:function:: unknown GetScriptScope()

    .. cpp:function:: void SetScriptTime0( float time )

    .. cpp:function:: void SetScriptFlags0( int flag )