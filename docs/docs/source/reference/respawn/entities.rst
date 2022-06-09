Entities
========

There are different Classes for Server and Client. Classes that start with ``C_`` are exclusive to the Client VM and classes that only have the ``C`` Prefix are only usable in the Server VM.

Most entries have three sub entries: The class available to the SERVER, the CLIENT and methods that are available on both VMs.

For a graphic reprasentation of the Server and Client class inheritance, refer to `this chart <http://salzgrube.club/class_graph_dynamic.html>`_

.. note::

	Pay attention to the ``extends`` keyword for each class! You can use every property of that the parent class has access to!

	This List of Classes and their Methods is incomplete!


CBaseEntity / C_BaseEntity
--------------------------

Basic enitity that most other entities inherit from.

Shared
^^^^^^

.. cpp:class:: CBaseEntity / C_BaseEntity

	.. cpp:function:: void Hide()

	.. cpp:function:: void Destroy()

	.. cpp:function:: void Signal( string signal )

	.. cpp:function:: vector GetOrigin()

	.. cpp:function:: entity GetBossPlayer()

	.. cpp:function:: string GetClassName()

	.. cpp:function:: bool IsNPC()

	.. cpp:function:: bool IsTitan()

	.. cpp:function:: bool IsHuman()

	.. cpp:function:: bool IsPhaseShifted()

	.. cpp:function:: bool IsPlayer()

	.. cpp:function:: bool IsProjectile()

	.. cpp:function:: asset GetModelName()

	.. cpp:function:: void SetParent( entity parent, ..., string type = "" )

	.. cpp:function:: void SetValueForEffectNameKey( asset effect )

	.. cpp:function:: table CreateTableFromModelKeyValues()

	.. cpp:function:: void EndSignal( string signal )

	.. cpp:function:: int GetArmorType()

	.. cpp:function:: int GetMaxHealth()

	.. cpp:function:: bool HasGibModel()

	.. cpp:function:: bool HasKey( string key )

	.. cpp:function:: bool IsMarkedForDeletion()

	.. cpp:function:: bool IsMechanical()

	.. cpp:function:: void SetOrigin( vector position )

	.. cpp:function:: string GetTargetName()

	.. cpp:function:: int GetTeam()

	.. cpp:function:: vector GetAngles()

	.. cpp:function:: vector EyePosition()

	.. cpp:function:: var GetValueForKey( string key )

	.. cpp:function:: void WaitSignal( string signal )

	.. cpp:function:: vector GetVelocity()

	.. cpp:function:: void Kill_Deprecated_UseDestroyInstead()

		You should use Destroy instead. Both function do exactly the same.

	.. cpp:function:: vector GetBoundingMaxs()

	.. cpp:function:: vector GetBoundingMins()

	.. cpp:function:: vector SetAngles( vector angle)

	.. cpp:function:: void ClearParent( entity parent )

	.. cpp:function:: void SetValueForModelKey( asset model )

	.. cpp:function:: void Show()

	.. cpp:function:: bool IsInvulnerable()

	.. cpp:function:: entity GetParent()

	.. cpp:function:: vector GetWorldSpaceCenter()

	.. cpp:function:: int Highlight_GetCurrentContext()

	.. cpp:function:: float Highlight_GetCurrentInsideOpacity()

	.. cpp:function:: float Highlight_GetCurrentOutlineOpacity()

	.. cpp:function:: unknown Highlight_GetInheritHighlight()

	.. cpp:function:: int Highlight_GetInsideFunction( int contextID )

	.. cpp:function:: int Highlight_GetOutlineFunction( int contextID )

	.. cpp:function:: float Highlight_GetOutlineRadius()

	.. cpp:function:: unknown Highlight_GetParam( int contextID, int parameterNum )

	.. cpp:function:: int Highlight_GetState( int contextID )

	.. cpp:function:: void Highlight_HideInside( float duration )

	.. cpp:function:: void Highlight_HideOutline( float duration )

	.. cpp:function:: bool Highlight_IsAfterPostProcess( int contextID )

	.. cpp:function:: bool Highlight_IsEntityVisible( int contextID )

	.. cpp:function:: void Highlight_SetCurrentContext( int contextID )

	.. cpp:function:: void Highlight_SetFunctions( int contextID, int hightlightFillID, bool entityVisible, int colorMode, float radius, int highlightID, bool afterPostProcess)

	.. cpp:function:: void Highlight_SetParam( int contextID, int parameterID, vector highlightColor )

	.. cpp:function:: void Highlight_ShowInside( float duration )

	.. cpp:function:: void Highlight_ShowOutline( float duration )

	.. cpp:function:: int GetEntIndex()

	.. cpp:function:: entity GetOwner()

	.. cpp:function:: int GetShieldHealth()

	.. cpp:function:: int GetShieldHealthMax()

	.. cpp:function:: void SetScriptName( string name )

	.. cpp:function:: array<entity> GetLinkEntArray()

	.. cpp:function:: entity GetLinkEnt()

	.. cpp:function:: void Code_SetTeam( int team )

	.. cpp:function:: int GetHealth()

	.. cpp:function:: bool IsCloaked()

	.. cpp:function:: bool IsEntAlive()

	.. cpp:function:: bool IsValidInternal()

	.. cpp:function:: vector GetForwardVector()

	.. cpp:function:: vector GetRightVector()

	.. cpp:function:: vector GetUpVector()

	.. cpp:function:: void SetValueForKey( var key, var val )

	.. cpp:function:: entity constructor( unknown )

		Depends on the class.
		
		Returns a new instance of a class.
		
		You can invoke the constructor with brackets as well, for example like this: ``CBaseEntity()``

	.. cpp:function:: void SetDoDestroyCallback( bool doCallBack )

	.. cpp:function:: int GetLifeState()

	.. cpp:function:: void DisableDraw()

	.. cpp:function:: void EnableDraw()

	.. cpp:function:: void SetCanCloak( bool canCloak )

	.. cpp:function:: bool GetCritsPrevented()

	.. cpp:function:: bool IsHologram()

	.. cpp:function:: bool IsOnGround()

	.. cpp:function:: void SetModel( asset model )

	.. cpp:function:: void MarkAsNonMovingAttachment()

	.. cpp:function:: string GetScriptName()

	.. cpp:function:: vector EyeAngles()

	.. cpp:function:: bool IsBreakableGlass()

	.. cpp:function:: bool IsWorld()

	.. cpp:function:: void DispatchImpactEffects( entity ent, vector startPos, vector endPos, vector hitNormal, enitity prop, int propIndex, int damageType, int impactIndex, entity orig, int impactEffectFlags )

	.. cpp:function:: void IsPlayerDecoy()

	.. cpp:function:: void SetPassThroughDirection( float dir )

	.. cpp:function:: void SetPassThroughThickness( float thickness )

	.. cpp:function:: void SetTakeDamageType( int takeDamageType )

		``DAMAGE_NO``, ``DAMAGE_YES``, ``DAMAGE_EVENTS_ONLY``

	.. cpp:function:: void SetVelocity( vector vel )

	.. cpp:function:: void EnableRenderAlways()

	.. cpp:function:: entity GetParentAttachment()

	.. cpp:function:: void SetFadeDistance( int distance )

	.. cpp:function:: void Highlight_SetInheritHighlight( bool set )

	.. cpp:function:: void DisableRenderAlways()

	.. cpp:function:: void SetLocalOrigin( vector origin )

	.. cpp:function:: bool HasPusherRootParent()

	.. cpp:function:: void StopPhysics()

	.. cpp:function:: void SetPreventCrits( bool prevent )

	.. cpp:function:: void HighlightDisableForTeam( int team )

	.. cpp:function:: void HighlightEnableForTeam( int team )

	.. cpp:function:: void HighlightSetTeamBitField( int bitField )

	.. cpp:function:: void SetLocalAngles( vector angles )

	.. cpp:function:: void SetParentWithHitbox( entity parent, int hitGroup, bool unknown )

	.. cpp:function:: void RenderWithViewModels( bool renderWith )

	.. cpp:function:: void SetValueForTextureKey( asset texture )

	.. cpp:function:: asset GetValueForModelKey()

	.. cpp:function:: vector GetLocalAngles()

	.. cpp:function:: entity GetLinkParent()

	.. cpp:function:: bool GetNoTarget()

	.. cpp:function:: void SetForceVisibleInPhaseShift( bool visible )

	.. cpp:function:: table GetScriptScope()

CBaseEntity
^^^^^^^^^^^

.. cpp:class:: CBaseEntity

	.. cpp:function:: int SetHealth( int health )

	.. cpp:function:: int SetMaxHealth( int health )

	.. cpp:function:: void SetOwner( entity owner )

	.. cpp:function:: entity GetSpawner()

	.. cpp:function:: void Die()

	.. cpp:function:: bool NotSolid()

	.. cpp:function:: void MoveTo( vector pos, float moveTime, int unknown1, int unknown2 )

	.. cpp:function:: void RotateTo( vector pos, float moveTime, int unknown1, int unknown2 )

	.. cpp:function:: void ClearInvulnerable()

	.. cpp:function:: void SetInvulnerable()

	.. cpp:function:: void SetNextThinkNow()

	.. cpp:function:: void SetNoTarget( bool noTarget )

	.. cpp:function:: void SetNoTargetSmartAmmo( bool noTarget )

	.. cpp:function:: void Minimap_SetClampToEdge( bool clamp )

	.. cpp:function:: void Minimap_SetCustomState( int state )

	.. cpp:function:: void Minimap_SetZOrder( int order )

	.. cpp:function:: void Minimap_SetAlignUpright( bool align )

	.. cpp:function:: void Minimap_SetObjectScale( float scale )

	.. cpp:function:: void SetShieldHealth( int )

	.. cpp:function:: void SetShieldHealthMax( int )

	.. cpp:function:: int GetEncodedEHandle()

	.. cpp:function:: void SetUsable( bool usable )

	.. cpp:function:: void SetUsableRadius( float distance )

	.. cpp:function:: void Solid()

	.. cpp:function:: void Fire( string unknown, string unknown1 = "", int duration )

	.. cpp:function:: void SetUsableByGroup( string group )

	.. cpp:function:: void DisableHibernation()

	.. cpp:function:: void SetSize( float width, float height )

	.. cpp:function:: void SetCloakFlicker( float intensity, float duration )

	.. cpp:function:: void TakeDamage( int damageAmount, entity attacker_1, entity attacker_2, table { int scriptType, int damageType, int damageSourceId, vector origin, vector force } )

	.. cpp:function:: vector GetCenter()

	.. cpp:function:: void TraceAttackToTriggers( int damageAmount, entity attacker_1, entity attacker_2, table { int scriptType, int damageType, int damageSourceId, vector force }, vector startPos, vector endPos, vector direction )

	.. cpp:function:: void SetBlocksRadiusDamage( bool blocks )

	.. cpp:function:: void SetDamageNotifications( bool getNotifs )

	.. cpp:function:: entity NextMovePeer()

	.. cpp:function:: void SetNameVisibleToEnemy( bool visible )

	.. cpp:function:: void SetNameVisibleToFriendly( bool visible )

	.. cpp:function:: void SetNameVisibleToOwner( bool visible )

	.. cpp:function:: entity FirstMoveChild()

	.. cpp:function:: entity GetRootMoveParent()

	.. cpp:function:: void RemoveFromSpatialPartition()

	.. cpp:function:: void SetUsePrompts( string pc_prompt, string console_prompt)

	.. cpp:function:: void SetAngularVelocity( float x, float y, float z )

	.. cpp:function:: void MakeInvisible()

	.. cpp:function:: void MakeVisible()

	.. cpp:function:: entity GetGroundEntity()

	.. cpp:function:: vector GetGroundRelativePos()

	.. cpp:function:: int GetPhysicsSolidMask()

	.. cpp:function:: void SetBossPlayer( entity boss )

	.. cpp:function:: void EnableAttackableByAI( int ai_priority_no_threat, int unknown, int ai_ap_flag )

	.. cpp:function:: void SetDeathNotifications( bool notifs )

	.. cpp:function:: void SetTitle( string title )

	.. cpp:function:: void LinkToEnt( entity ent )

	.. cpp:function:: void SetAbsAngles( vector angles )

	.. cpp:function:: void SetAbsOrigin( void origin )

	.. cpp:function:: void UnsetUsable()

	.. cpp:function:: void Minimap_AlwaysShow( int team, entity ent )

	.. cpp:function:: void RoundOriginAndAnglesToNearestNetworkValue()

	.. cpp:function:: void ConnectOutput( string event, void functionref( entity self, entity activator, entity caller, var value ) )

	.. cpp:function:: void ClearBossPlayer()

	.. cpp:function:: void SetUsableValue( int val )

	.. cpp:function:: void Minimap_DisplayDefault( int team, entity ent )

	.. cpp:function:: void FireNow( string s )

		``s`` is either ``"Enable"`` or ``Disable``

C_BaseEntity
^^^^^^^^^^^^

.. cpp:class:: C_BaseEntity

	.. cpp:function:: string GetSignifierName()

	.. cpp:function:: string GetBossPlayerName()

	.. cpp:function:: void ForceShadowVisible( bool visible )

	.. cpp:function:: void clKill()

	.. cpp:function:: float Highlight_GetNearFadeDist()

	.. cpp:function:: void Highlight_ResetFlags()

	.. cpp:function:: void Highlight_SetFadeInTime( float time )

	.. cpp:function:: void Highlight_SetFadeOutTime( float time )

	.. cpp:function:: void Highlight_SetFarFadeDist( float dist )

	.. cpp:function:: void Highlight_SetFlag( int highlightFlag, bool enable )

	.. cpp:function:: void Highlight_SetLifeTime( float time )

	.. cpp:function:: void Highlight_SetNearFadeDist( float dist )

	.. cpp:function:: void Highlight_SetVisibilityType( int type )

	.. cpp:function:: void Highlight_StartOn()

		Starts the highlight

	.. cpp:function:: void DisableRenderWithViewModelsNoZoom()

	.. cpp:function:: void EnableRenderWithCockpit()

	.. cpp:function:: void EnableRenderWithHud()

	.. cpp:function:: void SetAttachOffsetAngles( vector angles )

	.. cpp:function:: void SetAttachOffsetOrigin( vector origin )

	.. cpp:function:: void SetVisibleForLocalPlayer( int visible )

	.. cpp:function:: void InitHudElem( var key )

	.. cpp:function:: string GetTitleForUI()

	.. cpp:function:: float GetCloakFadeFactor()

	.. cpp:function:: int Dev_GetEncodedEHandle()

	.. cpp:function:: int Minimap_GetCustomState()

	.. cpp:function:: int Minimap_GetZOrder()

	.. cpp:function:: void DoDeathCallback( bool doCallback )

	.. cpp:function:: void EnableHealthChangedCallback()

	.. cpp:function:: void HideHUD()

	.. cpp:function:: void ShowHUD()

	.. cpp:function:: bool IsHUDVisible()

CDynamicProp / C_DynamicProp
----------------------------

Shared
^^^^^^

.. cpp:class:: CDynamicProp / C_DynamicProp : extends CBaseAnimating / C_BaseAnimating

CDynamicProp
^^^^^^^^^^^^

.. cpp:class:: CDynamicProp : extends CBaseAnimating

	.. cpp:function:: void SetFullBodygroup( int group )

C_DynamicProp
^^^^^^^^^^^^^

.. cpp:class:: C_DynamicProp : extends C_BaseAnimating

CScriptProp / C_ScriptProp
-----------

Shared
^^^^^^

.. cpp:class:: CScriptProp / C_ScriptProp : extends CDynamicProp / C_DynamicProp

	.. cpp:function:: unknown SetSmartAmmoLockType( unknown )

	.. cpp:function:: unknown GetScriptPropFlags( unknown )

CScriptProp
^^^^^^^^^^^

.. cpp:class:: CScriptProp : extends CDynamicProp

	.. cpp:function:: unknown SetFootstepType( unknown )

	.. cpp:function:: unknown SetArmorType( unknown )

	.. cpp:function:: unknown SetScriptPropFlags( unknown )


C_ScriptProp
^^^^^^^^^^^^

CBaseCombatWeapon / C_BaseCombatWeapon
--------------------------------------

Shared
^^^^^^

.. cpp:class:: CBaseCombatWeapon / C_BaseCombatWeapon : extends CBaseAnimating / C_BaseAnimating

	.. cpp:function:: string GetWeaponDescription()

CBaseCombatWeapon
^^^^^^^^^^^^^^^^^

.. cpp:class:: CBaseCombatWeapon : extends CBaseAnimating

C_BaseCombatWeapon
^^^^^^^^^^^^^^^^^^

.. cpp:function:: C_BaseCombatWeapon : extends C_BaseAnimating

CWeaponX / C_WeaponX
--------------------

Weapons hold by a player or that are lying on the ground are of this type.

Shared
^^^^^^

.. cpp:class:: CWeaponX / C_WeaponX : extends CBaseCombatWeapon / C_BaseCombatWeapon

	.. cpp:function:: entity GetWeaponOwner()

	.. cpp:function:: bool GetAllowHeadShots()

	.. cpp:function:: float GetMaxDamageFarDist()

	.. cpp:function:: bool GetWeaponSettingBool( int setting )

	.. cpp:function:: float GetWeaponSettingFloat( int setting )

	.. cpp:function:: int GetWeaponSettingInt( int setting )

	.. cpp:function:: vector GetAttackDirection()

	.. cpp:function:: vector GetAttackPosition()

	.. cpp:function:: int GetWeaponPrimaryAmmoCount()

	.. cpp:function:: int GetWeaponPrimaryClipCount()

	.. cpp:function:: int GetWeaponPrimaryClipCountMax()

	.. cpp:function:: bool IsChargeWeapon()

	.. cpp:function:: void SetNextAttackAllowedTime( float time )

		You need to set a game time as time.

	.. cpp:function:: void SetWeaponChargeFractionForced( float frac )

	.. cpp:function:: void SetWeaponPrimaryClipCount( int )

	.. cpp:function:: string GetWeaponClassName()

	.. cpp:function:: var GetWeaponInfoFileKeyField( string key )

	.. cpp:function:: float GetCoreDuration()

	.. cpp:function:: int GetWeaponType()

	.. cpp:function:: array<string> GetMods()

	.. cpp:function:: bool IsWeaponOffhand()

	.. cpp:function:: float GetWeaponChargeFraction()

	.. cpp:function:: float GetWeaponChargeTime()

	.. cpp:function:: bool HasMod( string mod )

	.. cpp:function:: int GetWeaponCurrentEnergyCost()

	.. cpp:function:: bool GetMeleeCanHitHumanSized()

	.. cpp:function:: bool GetMeleeCanHitTitans()

	.. cpp:function:: void DoMeleeHitConfirmation( float severityScale )

	.. cpp:function:: void EmitWeaponNpcSound_DontUpdateLastFiredTime( int volume, float time )

	.. cpp:function:: int GetDamageAmountForArmorType( int armor )

	.. cpp:function:: float GetMeleeAttackRange()

	.. cpp:function:: float GetMeleeLungeTargetRange()

	.. cpp:function:: void SetMods( array<string> mods )

	.. cpp:function:: void EmitWeaponNpcSound( int volume, float duration )

	.. cpp:function:: int GetWeaponDamageFlags()

	.. cpp:function:: bool SmartAmmo_IsEnabled( unknown )

	.. cpp:function:: int SmartAmmo_GetNumTrackersOnEntity( entity target )

	.. cpp:function:: array<entity> SmartAmmo_GetTrackedEntities()

	.. cpp:function:: bool SmartAmmo_IsVisibleTarget( entity trackedEnt )

	.. cpp:function:: string GetWeaponClass()

	.. cpp:function:: void SetWeaponSkin( int skin )

	.. cpp:function:: entity FireWeaponGrenade( vector attackPos, vector throwVelocity, vector angularVelocity, float fuseTime, int contactDamageType, int explosionDamageType, bool isPredicted, bool isLagCompensated, bool bounce? )

	.. cpp:function:: int GetScriptFlags0()

	.. cpp:function:: bool ShouldPredictProjectiles()

	.. cpp:function:: float GetScriptTime0()

	.. cpp:function:: void SetScriptTime0( float gameTime )

		``gameTime`` needs to be game time. The current game time can be retrieved with ``Time()``

	.. cpp:function:: bool IsReloading()

	.. cpp:function:: void SetForcedADS()

	.. cpp:function:: void EmitWeaponSound_1p3p(string sound1P, string sound3P)

	.. cpp:function:: int GetChargeAnimIndex()

	.. cpp:function:: void PlayWeaponEffectNoCull(asset effect1P, asset effect3P, string tagName)

	.. cpp:function:: void RegenerateAmmoReset()

	.. cpp:function:: void SetChargeAnimIndex( int index )

	.. cpp:function:: void SetWeaponPrimaryAmmoCount( int count )

	.. cpp:function:: void StopWeaponEffect(asset effect1P, asset effect3P)

	.. cpp:function:: void ClearForcedADS()

	.. cpp:function:: int GetReloadMilestoneIndex()

		Reload progress. Reloading continues from there.

	.. cpp:function:: int GetAmmoPerShot()

	.. cpp:function:: bool IsBurstFireInProgress()

	.. cpp:function:: void PlayWeaponEffect(asset effect1P, asset effect3P, string tagName)

	.. cpp:function:: void StopWeaponSound(string sound)

	.. cpp:function:: float GetSustainedDischargeDuration()

	.. cpp:function:: void SetSustainedDischargeFractionForced(float frac)

	.. cpp:function:: entity FireWeaponMissile(vector origin, vector dir, float missileSpeed, int contactDamageType, int explosionDamageType, bool doPopup, bool predict)

	.. cpp:function:: int GetBurstFireShotsPending()

	.. cpp:function:: bool AllowUse()

	.. cpp:function:: void RemoveMod( string mod )

	.. cpp:function:: unknown<unknown> SmartAmmo_GetTargets()

	.. cpp:function:: void SmartAmmo_TrackEntity(entity hitEnt, LMG_SMART_AMMO_TRACKER_TIME)

	.. cpp:function:: void EmitWeaponSound( string sound )

	.. cpp:function:: float GetWeaponChargeLevel()

	.. cpp:function:: void SetWeaponBurstFireCount(int amount)

	.. cpp:function:: int GetCurrentAltFireIndex()

	.. cpp:function:: void ForceRelease()

	.. cpp:function:: float SetWeaponChargeFraction()

	.. cpp:function:: int GetProjectilesPerShot()

	.. cpp:function:: entity FireWeaponBolt(vector origin, vector dir, float projectileSpeed, int contactDamageType, int explosionDamageType, bool predict, int index)

	.. cpp:function:: bool IsWeaponInAds()

	.. cpp:function:: void ResetWeaponToDefaultEnergyCost()

	.. cpp:function:: void SetWeaponEnergyCost( int cost )

	.. cpp:function::  entity FireWeaponBullet( vector origin, vector dir, int unknown_purpose, damageType )

	.. cpp:function:: bool IsWeaponAdsButtonPressed()

	.. cpp:function:: float GetWeaponChargeLevelMax()

	.. cpp:function:: bool IsReadyToFire()

	.. cpp:function:: void SetAttackKickRollScale(float scale)

	.. cpp:function:: int GetShotCount()

	.. cpp:function:: void AddMod( string mod )

	.. cpp:function:: void FireWeaponBullet_Special(vector origin, vector direction, int numShots, int damageType, bool unknownPurpose1, bool unknownPurpose2, bool unknownPurpose3, bool unknownPurpose4, bool unknownPurpose5, bool activeShot, bool doTraceBrushOnly)

	.. cpp:function:: string GetWeaponSettingString( string setting )

	.. cpp:function:: void SmartAmmo_UntrackEntity(entity target)

	.. cpp:function:: string GetSmartAmmoWeaponType()

		Check if weaponType is valid: ``Assert( weaponType in VALID_WEAPON_TYPES )``

	.. cpp:function:: int GetWeaponBurstFireCount()

	.. cpp:function:: void SmartAmmo_Clear( bool unknown_purpose1, bool unknown_purpose2 )

	.. cpp:function:: vector SmartAmmo_GetFirePosition(entity target, int burstIndex)

	.. cpp:function:: array<entity> SmartAmmo_GetStoredTargets()

	.. cpp:function:: void SmartAmmo_StoreTargets()

	.. cpp:function:: bool IsSustainedDischargeWeapon()

	.. cpp:function:: int GetDamageSourceID()

	.. cpp:function:: float GetGrenadeFuseTime()

		Note that fuse time of 0 means the grenade won't explode on its own, instead it depends on OnProjectileCollision() functions to be defined and explode there.

	.. cpp:function:: void SetWeaponPrimaryClipCountAbsolute(int clipsize)

	.. cpp:function:: entity GetWeaponUtilityEntity()

	.. cpp:function:: bool IsForceRelease()

	.. cpp:function:: bool IsWeaponRegenDraining()

	.. cpp:function:: void SetWeaponPrimaryClipCountNoRegenReset(int clipsize)

CWeaponX
^^^^^^^^

.. cpp:class:: CWeaponX : extends CBaseCombatWeapon

	.. cpp:function:: void SetWeaponUtilityEntity( entity ent )

	.. cpp:function:: void ForceDryfireEvent()

	.. cpp:function:: void PlayWeaponEffectOnOwner( asset effect, int bodypart )

	.. cpp:function:: void ForceReleaseFromServer()

		Will eventually result in ``Grenade_OnWeaponToss_()`` or equivalent function

	.. cpp:function:: bool IsForceReleaseFromServer()

C_WeaponX
^^^^^^^^^

.. cpp:class:: C_WeaponX : extends C_BaseCombatWeapon

	.. cpp:function:: void PlayWeaponEffectReturnViewEffectHandle( asset fpEffect, asset unknown_purpose, string tag )

	.. cpp:function:: void SetViewmodelAmmoModelIndex( int index )

		``index`` may be the number of rounds in the clip etc.

CProjectile / C_Projectile
--------------------------

Projectiles.

Shared
^^^^^^

.. cpp:class:: CProjectile / C_Projectile : extends CDynamicProp / C_DynamicProp

	.. cpp:function:: bool GetProjectileWeaponSettingBool( string setting )

	.. cpp:function:: float GetProjectileWeaponSettingFloat( string setting )

	.. cpp:function:: int GetProjectileWeaponSettingInt( string setting )

	.. cpp:function:: string ProjectileGetWeaponClassName()

	.. cpp:function:: void SetImpactEffectTable( string fxTableHandle )

	.. cpp:function:: array<string> ProjectileGetMods()

	.. cpp:function:: void SetProjectilTrailEffectIndex( int index )

	.. cpp:function:: void SetProjectileLifetime( float lifetime )

	.. cpp:function:: string ProjectileGetWeaponInfoFileKeyField( string key )

	.. cpp:function:: void SetReducedEffects()

	.. cpp:function:: asset GetProjectileWeaponSettingAsset( string setting )

	.. cpp:function:: void SetVortexRefired( bool refired )

		Tells the code that the projectile was refired from the vortex so that it uses "projectile_vortex_vscript"

	.. cpp:function:: float GetProjectileCreationTime()

	.. cpp:function:: asset ProjectileGetWeaponInfoFileKeyFieldAsset( string key )

CProjectile
^^^^^^^^^^^

.. cpp:class:: CProjectile : extends CDynamicProp

	.. cpp:function:: int ProjectileGetDamageSourceID()

	.. cpp:function:: void ProjectileSetDamageSourceID( int id )

	.. cpp:function:: void SetWeaponClassName( string name )

	.. cpp:function:: void SetProjectileImpactDamageOverride( int flag )

C_Projectile
^^^^^^^^^^^^

.. cpp:class:: C_Projectile : extends C_DynamicProp

CBaseGrenade / C_BaseGrenade
----------------------------

Grenade entities in worldspace. Grenades that are equipped ("cooked") by players are instances from the CWeaponX class.

Shared
^^^^^^

.. cpp:class:: CBaseGrenade / C_BaseGrenade : extends CProjectile / C_Projectile

	.. cpp:function:: float GetDamageRadius()

	.. cpp:function:: float GetExplosionRadius()

	.. cpp:function:: void GrenadeExplode( vector unknown_purpose )

	.. cpp:function:: entity GetThrower()

	.. cpp:function:: bool GrenadeHasIgnited()

	.. cpp:function:: void GrenadeIgnite()

	.. cpp:function:: void SetDoesExplode( bool explodes )

	.. cpp:function:: void InitMagnetic( float force, string attractKey )

	.. cpp:function:: void ExplodeForCollisionCallback( vector unknown_purpose )

	.. cpp:function:: void MarkAsAttached()

CBaseGrenade
^^^^^^^^^^^^

.. cpp:class:: CBaseGrenade : extends CProjectile

	.. cpp:function:: void SetGrenadeTimer( float fuseTime )

	.. cpp:function:: void SetGrenadeIgnitionDuration( float fuseTime )

C_BaseGrenade
^^^^^^^^^^^^^

.. cpp:class:: C_BaseGrenade : extends C_Projectile

CMissile / C_Missile
--------------------

Shared
^^^^^^

.. cpp:class:: CMissile / C_Missile : extends CProjectile / C_Projectile

	.. cpp:function:: void MissileExplode()

	.. cpp:function:: void InitMissileForRandomDriftFromWeaponSettings( vector pos, vector dir )

	.. cpp:function:: void SetHomingSpeeds( int speed, int speed_for_dodging_player )

	.. cpp:function:: void SetMissileTarget( enity target, vector unknown_purpose )

	.. cpp:function:: void SetMissileTargetPosition( vector pos )

	.. cpp:function:: void InitMissileSpiral( vector pos, vector dir, int missileNumber, bool unknown_purpose1, bool unknown_purpose2 )

	.. cpp:function:: void SetSpeed( float speed )

	.. cpp:function:: entity GetMissileTarget()

	.. cpp:function:: void InitMissileExpandContract( vector outward, vector inward, float launchOutTime, float launchInLerpTime, float launchInTime, float launchStraightLerpTime, vector missileEndPos, bool applyRandSpread )

	.. cpp:function:: void InitMissileForRandomDrift( vector pos, vector dir )

CMissile
^^^^^^^^

.. cpp:class:: CMissile : extends CProjectile

C_Missile
^^^^^^^^^

.. cpp:class:: C_Missile : extends C_Projectile



CPlayer / C_Player
------------------

Shared
^^^^^^

.. cpp:class:: CPlayer / C_Player : extends CBaseCombatCharacter / C_BaseCombatCharacter

	.. cpp:function:: int GetGen()

	.. cpp:function:: entity GetFirstPersonProxy()

	.. cpp:function:: string GetPlayerClass()

	.. cpp:function:: void Lunge_ClearTarget()

	.. cpp:function:: bool Lunge_IsActive()

	.. cpp:function:: bool GetForcedDialogueOnly()

	.. cpp:function:: float GetLastPingTime()

	.. cpp:function:: int GetNumPingsAvailable()

	.. cpp:function:: int GetPingGroupAccumulator()

	.. cpp:function:: float GetPingGroupStartTime()

	.. cpp:function:: void SetLastPingTime( float time) 

	.. cpp:function:: void SetNumPingsAvailable( int num )

	.. cpp:function:: void SetNumPingsUsed( int num )

	.. cpp:function:: void SetPingGroupAccumulator( int acc )

	.. cpp:function:: void SetPingGroupStartTime( float gametime )

	.. cpp:function:: string GetPlayerName()

	.. cpp:function:: int GetPlayerGameStat( int PGS )

		returns the score of the player in the provided category. some categories are: PGS_KILLS, PGS_DEATHS, PGS_SCORE etc.

	.. cpp:function:: entity GetPetTitan()

	.. cpp:function:: bool GetTitanDisembarkEnabled()

	.. cpp:function:: bool GetTitanEmbarkEnabled()

	.. cpp:function:: bool IsBot()

	.. cpp:function:: void SetTitanDisembarkEnabled( bool enabled )

	.. cpp:function:: void SetTitanEmbarkEnabled( bool enabled )

	.. cpp:function:: string GetPlayerSettings()

	.. cpp:function:: int GetActiveBurnCardIndex()

		Selected burn card

	.. cpp:function:: int Code_GetActiveBurnCardIndex()

		Use ``GetActiveBurnCardIndex`` instead

	.. cpp:function:: string GetPlayerSettingsField( string field )

	.. cpp:function:: int GetCinematicEventFlags()

	.. cpp:function:: entity GetObserverTarget()

	.. cpp:function:: vector GetViewRight()

	.. cpp:function:: vector GetViewVector()

	.. cpp:function:: vector GetViewForward()

	.. cpp:function:: vector GetViewUp()

	.. cpp:function:: int GetPersistentVarAsInt( string key )

	.. cpp:function:: entity GetViewModelEntity()

	.. cpp:function:: int GetOutOfBoundsDeadTime()

	.. cpp:function:: int GetLevel()

	.. cpp:function:: entity GetTitanSoulBeingRodeoed()

	.. cpp:function:: int GetXP()

	.. cpp:function:: vector CameraAngles()

	.. cpp:function:: float GetObjectiveEndTime()

	.. cpp:function:: entity GetObjectiveEntity()

	.. cpp:function:: int GetObjectiveIndex()

	.. cpp:function:: enitity GetPredictedFirstPersonProxy()

	.. cpp:function:: int GetPetTitanMode()

	.. cpp:function:: bool IsWallHanging()

	.. cpp:function:: float GetNextTitanRespawnAvailable()

	.. cpp:function:: var GetPersistentVar( string key )

	.. cpp:function:: bool HasBadReputation()

	.. cpp:function:: int GetObserverMode()

	.. cpp:function:: float GetPlayerModHealth()

	.. cpp:function:: bool IsInputCommandHeld( int flag )

	.. cpp:function:: int GetPlayerNetInt( string state )

	.. cpp:function:: float GetPlayerNetFloat( string state )

	.. cpp:function:: entity GetHardpointEntity()

	.. cpp:function:: bool GetPlayerNetBool( string key )

	.. cpp:function:: bool IsCrouched()

	.. cpp:function:: void IsTraversing()

	.. cpp:function:: void IsWallRunning()

	.. cpp:function:: vector Lunge_GetStartPositionOffset()

	.. cpp:function:: void Lunge_SetTargetEntity( entity target, bool unknown_purpose )

	.. cpp:function:: int PlayerMelee_GetState()

	.. cpp:function:: bool PlayerMelee_IsAttackActive()

	.. cpp:function:: void PlayerMelee_SetState( int state )

	.. cpp:function:: void Lunge_EnableFlying()

	.. cpp:function:: vector Lunge_GetEndPositionOffset()

	.. cpp:function:: bool Lunge_IsGroundExecute()

	.. cpp:function:: bool Lunge_IsLungingToEntity()

	.. cpp:function:: void Lunge_LockPitch( bool lock )

	.. cpp:function:: void Lunge_SetEndPositionOffset( vector offset )

	.. cpp:function:: void Lunge_SetTargetPosition( vector pos )

	.. cpp:function:: void PlayerMelee_EndAttack()

	.. cpp:function:: entity PlayerMelee_GetAttackHitEntity()

	.. cpp:function:: void PlayerMelee_SetAttackHitEntity( entity ent )

	.. cpp:function:: void PlayerMelee_SetAttackRecoveryShouldBeQuick( bool beQuick )

	.. cpp:function:: void PlayerMelee_StartAttack( int attackState )

	.. cpp:function:: void SetSelectedOffhandToMelee()

	.. cpp:function:: void Weapon_StartCustomActivity( string animation, bool unknown_purpose )

	.. cpp:function:: float GetPlayerNetTime( string key )

	.. cpp:function:: vector CameraPosition()

	.. cpp:function:: entity GetPlayerNetEnt( string key )

	.. cpp:function:: bool IsStanding()

	.. cpp:function:: bool HasPassive( int passive )

	.. cpp:function:: void Lunge_SetSmoothTime( float time )

	.. cpp:function:: float SmartAmmo_GetHighestLockOnMeFraction()

	.. cpp:function:: array<entity> SmartAmmo_GetHighestLocksOnMeEntities()

	.. cpp:function:: float SmartAmmo_GetPreviousHighestLockOnMeFraction()

	.. cpp:function:: void Grapple( vector direction )

	.. cpp:function:: bool MayGrapple()

	.. cpp:function:: int GetSuitGrapplePower()

	.. cpp:function:: bool IsZiplining()

	.. cpp:function:: array<string> GetPlayerSettingsMods()

	.. cpp:function:: void ClearMeleeDisabled()

	.. cpp:function:: void SetMeleeDisabled()

	.. cpp:function:: void RumbleEffect( int x, int y, int z )

	.. cpp:function:: float GetInputAxisForward()

		Y Axis

	.. cpp:function:: float GetInputAxisRight()

		X Axis

	.. cpp:function:: int GetDodgePower()

	.. cpp:function:: void HolsterWeapon()

	.. cpp:function:: void DeployWeapon()

		May not work with ``DeployAndEnableWeapons()`` and ``HolsterAndDisableWeapons()``

	.. cpp:function:: float GetZoomFrac()

	.. cpp:function:: entity GetRemoteTurret()


CPlayer
^^^^^^^

.. cpp:class:: CPlayer : extends CBaseCombatCharacter

	.. cpp:function:: void CockpitStartDisembark()

	.. cpp:function:: void NotifyDidDamage( entity damagedEnt, int hitbox, vector damagePosition, int customDamageType, float damage, int damageFlags, int hitGroup, enitity weapon, float distanceFromAttackOrigin )

	.. cpp:function:: void Server_SetDodgePower( float dodgePower )

	.. cpp:function:: void SetDodgePowerDelayScale( float delay )

	.. cpp:function:: void SetPowerRegenRateScale( float scale )

	.. cpp:function:: void SetPersistentVar( string key, var val )

	.. cpp:function:: void ForceStand()

	.. cpp:function:: void SetPlayerNetBool( string key, bool val )

	.. cpp:function:: void UnforceStand()

	.. cpp:function:: void Anim_StopGesture( int gesture )

	.. cpp:function:: void PlayerCone_Disable()

	.. cpp:function:: void PlayerCone_FromAnim()

	.. cpp:function:: void PlayerCone_SetLerpTime( float time )

	.. cpp:function:: void PlayerCone_SetMaxPitch( int maxPitch )

	.. cpp:function:: void PlayerCone_SetMaxYaw( int maxYaw )

	.. cpp:function:: void PlayerCone_SetMinPitch( int min )

	.. cpp:function:: void PlayerCone_SetMinYaw( int min )

	.. cpp:function:: entity CreateAnimatedPlayerDecoy( string decoyType )

		Decoy Types: ``pt_mp_execution_attacker_hologram_01``, ``pt_mp_execution_attacker_hologram_02``, ``pt_mp_execution_attacker_hologram_03``

	.. cpp:function:: void StopObserverMode()

	.. cpp:function:: void CockpitStartEject()

	.. cpp:function:: void FreezeControlsOnServer()

	.. cpp:function:: void UnfreezeControlsOnServer()

	.. cpp:function:: void CockpitStartBoot()

	.. cpp:function:: void SetStaggering()

	.. cpp:function:: void ForceCrouch()

	.. cpp:function:: void UnforceCrouch()

	.. cpp:function:: bool IsNoclipping()

	.. cpp:function:: void SetCinematicEventFlags( int flag )

	.. cpp:function:: void SetSyncedEntity( entity synced )

	.. cpp:function:: void SnapEyeAngles( vector angles )

	.. cpp:function:: void SnapFeetToEyes()

	.. cpp:function:: void TouchGround()

		Allows the player to double jump again.

	.. cpp:function:: void ViewOffsetEntity_Clear()

	.. cpp:function:: entity CreatePlayerDecoy( float stickPercentToRun )

	.. cpp:function:: void SetPlayerSettingsWithMods( string settings, array<string> newMods )

	.. cpp:function:: void Server_TurnOffhandWeaponsDisabledOff()

	.. cpp:function:: void Server_TurnOffhandWeaponsDisabledOn()

	.. cpp:function:: void SetPlayerNetInt( string key, int val )

	.. cpp:function:: void Anim_PlayGesture( string anim3p, float unknown_purpose, float unknown_purpose1, float unknown_purpose2 )

	.. cpp:function:: void Server_TurnDodgeDisabledOff()

	.. cpp:function:: void Server_TurnDodgeDisabledOn()

	.. cpp:function:: void SetGroundFrictionScale( int scale )

	.. cpp:function:: void PlayerCone_SetSpecific( vector viewAngles )

	.. cpp:function:: void SetSuitGrapplePower( float power )

	.. cpp:function:: void GiveExtraWeaponMod( string mod )

C_Player
^^^^^^^^

.. cpp:class:: C_Player : extends C_BaseCombatCharacter

	.. cpp:function:: void ClientCommand( string command )

	.. cpp:function:: entity GetCockpit()

	.. cpp:function:: string GetBodyType()

	.. cpp:function:: float GetAdsFraction()

	.. cpp:function:: bool IsInThirdPersonReplay()

	.. cpp:function:: float GetHotDropImpactTime( entity titan = this.titan, string animation = HOTDROP_TURBO_ANIM )

		If called without paramets returns time for the player's titan drop.

	.. cpp:function:: string GetPlayerNameWithClanTag()

	.. cpp:function:: bool HasMic()

	.. cpp:function:: bool InPartyChat()

	.. cpp:function:: bool IsMuted()

	.. cpp:function:: bool IsPartyLeader()

	.. cpp:function:: bool IsTalking()

	.. cpp:function:: void CockpitJolt( vector joltDir, float severity )

	.. cpp:function:: void SetScriptMenuOff()

	.. cpp:function:: void SetScriptMenuOn()

	.. cpp:function:: EntityScreenSpaceBounds GetEntScreenSpaceBounds( entity ent, int padding )

	.. cpp:function:: void HideCrosshairNames()

	.. cpp:function:: void UnhideCrosshairNames()

	.. cpp:function:: void FreezeControlsOnClient()

	.. cpp:function:: void Rodeo_StartCameraSmoothing( float factor )

	.. cpp:function:: void Rodeo_StopCameraSmoothing( float factor )

	.. cpp:function:: void StartArcCannon()

	.. cpp:function:: void StopArcCannon()

CTitanSoul / C_TitanSoul
------------------------

Shared
^^^^^^

.. cpp:class:: CTitanSoul / C_TitanSoul : extends CBaseEntity / C_BaseEntity

	.. cpp:function:: entity GetTitan()

	.. cpp:function:: bool HasValidTitan()

	.. cpp:function:: bool IsDoomed()

	.. cpp:function:: float GetTitanSoulNetFloat( string key )

	.. cpp:function:: entity GetInvalidHealthBarEnt()

		Returns an instance of CNPC_Titan

	.. cpp:function:: int GetTitanSoulNetInt( string key )

	.. cpp:function:: float GetLastRodeoHitTime()

	.. cpp:function:: bool IsEjecting()

	.. cpp:function:: int GetStance()

	.. cpp:function:: int GetPlayerSettingsNum()

	.. cpp:function:: float GetCoreChargeExpireTime()

	.. cpp:function:: float GetCoreChargeStartTime()

	.. cpp:function:: float GetNextCoreChargeAvailable()

CTitanSoul
^^^^^^^^^^

.. cpp:class:: CTitanSoul : extends CBaseEntity

	.. cpp:function:: void SetEjecting( bool ejecting )

	.. cpp:function:: void SetPlayerSettingsNum( int enum )

	.. cpp:function:: void SetStance( int stance )

	.. cpp:function:: void SoulDestroy()

	.. cpp:function:: void SetCoreChargeExpireTime( float gametime )

	.. cpp:function:: void SetTitanSoulNetFloat( string key, float val )

	.. cpp:function:: void SetTitanSoulNetFloatOverTime( string key, float unknown_purpose, float val )

	.. cpp:function:: float GetCoreUseDuration()

	.. cpp:function:: void SetTitanSoulNetInt( string key, int val )

	.. cpp:function:: void SetLastRodeoHitTime( float gametime )

	.. cpp:function:: void SetCoreChargeStartTime( float gametime )

	.. cpp:function:: void SetCoreUseDuration( float duration )

	.. cpp:function:: void SetNextCoreChargeAvailable( float time )

C_TitanSoul
^^^^^^^^^^^

.. cpp:class:: C_TitanSoul : extends C_BaseEntity

CBaseCombatCharacter / C_BaseCombatCharacter
--------------------------------------------

Shared
^^^^^^

.. cpp:class:: CBaseCombatCharacter / C_BaseCombatCharacter : extends CBaseAnimating / C_BaseAnimating

	.. cpp:function:: entity GetTitanSoul()

	.. cpp:function:: void ContextAction_ClearBusy()

	.. cpp:function:: bool ContextAction_IsActive()

	.. cpp:function:: bool ContextAction_IsBusy()

	.. cpp:function:: void ContextAction_SetBusy()

	.. cpp:function:: vector Anim_GetStartForRefEntity_Old( string anim, vector reference, string optionalTag )

	.. cpp:function:: array<entity> GetMainWeapons()

	.. cpp:function:: entity GetOffhandWeapon( int slot )

	.. cpp:function:: enitity GetActiveWeapon()

	.. cpp:function:: entity GetLatestPrimaryWeapon()

	.. cpp:function:: int GetSkin()

	.. cpp:function:: int LookupSequence( string sequence )

	.. cpp:function:: void SetSkin( int skin )

	.. cpp:function:: entity GetAntiTitanWeapon()

	.. cpp:function:: AnimRefPoint Anim_GetStartForRefPoint( string anim, vector origin, vector angles )

	.. cpp:function:: vector GetPlayerOrNPCViewVector()

	.. cpp:function:: vector Anim_GetStartForRefPoint_Old( animation, origin, angles )

	.. cpp:function:: void Anim_PlayWithRefPoint( string animation, vector origin, vector angles, float blendTime )

	.. cpp:function:: bool IsWeaponDisabled()

	.. cpp:function:: int GetActiveWeaponPrimaryAmmoLoaded()

	.. cpp:function:: bool ContextAction_IsMeleeExecution()

	.. cpp:function:: int GetWeaponAmmoStockpile( entity weapon )

	.. cpp:function:: entity GetMeleeWeapon()

	.. cpp:function:: bool ContextAction_IsMeleeExecutionTarget()

	.. cpp:function:: enitity GetFirstRodeoRider()

		Returns the first rodeo rider found or null if there are none.

	.. cpp:function:: int GetNumRodeoSlots()

		Returns number of rodeo slots available on this entity.

	.. cpp:function:: entity GetRodeoRider()

		Returns rodeo rider (if there is one) at the given slot.

	.. cpp:function:: void PhaseShiftBegin( float warmUpTime, float duration )

	.. cpp:function:: void PhaseShiftCancel()

	.. cpp:function:: vector OffsetPositionFromView( vector startPos, vector offset )

	.. cpp:function:: int GetWeaponAmmoLoaded( entity weapon )

	.. cpp:function:: int GetWeaponAmmoMaxLoaded( entity weapon )

	.. cpp:function:: float GetAttackSpreadAngle()

	.. cpp:function:: array<entity> GetOffhandWeapons()

	.. cpp:function:: bool ContextAction_IsLeeching()

	.. cpp:function:: void DisablePhaseShiftFlags()

	.. cpp:function:: void EnablePhaseShiftFlags()

	.. cpp:function:: entity GetEntityAtPhaseShiftExitPosition()

	.. cpp:function:: float PhaseShiftTimeRemaining()

	.. cpp:function:: bool CanUseSharedEnergy( int curCost )

	.. cpp:function:: bool CanUseSharedEnergy( int curCost )

	.. cpp:function:: void AddSharedEnergy( int amount )

	.. cpp:function:: int GetSharedEnergyTotal()

	.. cpp:function:: int GetSharedEnergyCount()

	.. cpp:function:: void SetSharedEnergyRegenDelay( float delay )

	.. cpp:function:: void TakeSharedEnergy( int amount )

CBaseCombatCharacter
^^^^^^^^^^^^^^^^^^^^

.. cpp:class:: CBaseCombatCharacter : extends CBaseAnimating

	.. cpp:function:: void SetFullBodygroup( int group )

	.. cpp:function:: void GetSettingsHeadshotFX()

		Looks for "headshotFX" in an AI settings file or a player set file

	.. cpp:function:: void GiveOffhandWeapon( string ordnanceName, int slot, array<string> mods )

	.. cpp:function:: void GiveWeapon( string weapon )

	.. cpp:function:: void SetActiveWeaponByName( string weapon )

	.. cpp:function:: void TakeOffhandWeapon( int slot )

	.. cpp:function:: void TakeWeaponNow( string weapon )

	.. cpp:function:: void TakeWeapon( string weapon )

	.. cpp:function:: int GetOutOfBoundsDeadTime()

	.. cpp:function:: void SetNumRodeoSlots( int )

		Sets the maximum number of rodeo slots available on this entity.

	.. cpp:function:: void SetRodeoRider( int slot, entity rider )

		Sets the rodeo rider at the given slot

	.. cpp:function:: void SetNPCPriorityOverride_NoThreat()

	.. cpp:function:: void SetTitanSoul( entity soul )

	.. cpp:function:: vector GetPlayerOrNPCViewRight()

	.. cpp:function:: void ResetHealthChangeRate()

C_BaseCombatCharacter
^^^^^^^^^^^^^^^^^^^^^

.. cpp:class:: C_BaseCombatCharacter : extends C_BaseAnimating

	.. cpp:function:: TraceResults TraceToLocalPlayer()

	.. cpp:function:: float TraceToLocalPlayerSimple()

CAI_BaseNPC / C_AI_BaseNPC
----------------------------

Shared
^^^^^^

.. cpp:class:: CAI_BaseNPC / C_AI_BaseNPC : extends CBaseCombatCharacter

	.. cpp:function:: var Dev_GetAISettingByKeyField( string key )

		Expect as string

	.. cpp:function:: bool IsInterruptable()

	.. cpp:function:: int GetAIClass()

		``AIC_SMALL_TURRET``, ``AIC_MARVIN``, ``AIC_SPECTRE``, ``AIC_STALKER_CRAWLING``, ``AIC_FRAG_DRONE``, ``AIC_HUMAN``

	.. cpp:function:: string GetBodyType()

	.. cpp:function:: string GetAISettingsName()

	.. cpp:function:: int GetMeleeDamageMaxForTarget( entity target )

	.. cpp:function:: float AISetting_MaxFlyingSpeed( unknown )

	.. cpp:function:: string AISetting_LeechAnimSet()

	.. cpp:function:: string AISetting_LeechDataKnifeTag()

CAI_BaseNPC
^^^^^^^^^^^^

.. cpp:class:: CAI_BaseNPC : extends C_BaseCombatCharacter

	.. cpp:function:: void AssaultPoint( vector point )

	.. cpp:function:: void EnableBehavior( string behaviour )

	.. cpp:function:: void DisableBehavior( string behaviour )

		Possible behaviours: ``Follow``, ``Assault``

	.. cpp:function:: void SetThinkEveryFrame( bool think )

	.. cpp:function:: void ClearEnemy( entity enemy )

	.. cpp:function:: void SetEnemy( entity enemy )

	.. cpp:function:: void Anim_ScriptedPlay( string anim )

	.. cpp:function:: void ForceCheckGroundEntity()

	.. cpp:function:: string GetNPCState()

	.. cpp:function:: float GetMaxEnemyDist()

		Max pilot engagement distance

	.. cpp:function:: float GetMaxEnemyDistHeavyArmor()

		Max titan engagement distance

	.. cpp:function:: float GetMaxTurretYaw()

	.. cpp:function:: void SetSecondaryEnemy( entity enemy )

	.. cpp:function:: void DisableNPCMoveFlag( int flag )

	.. cpp:function:: void EnableNPCMoveFlag( int flag )

	.. cpp:function:: void SetAISettings( string settings )

	.. cpp:function:: void SetCapabilityFlag( int flag, bool unknown_purpose )

	.. cpp:function:: void Anim_ScriptedPlayActivityByName( string activity, bool unknown_purpose1, float unknown_purpose2 )

	.. cpp:function:: entity GetEnemy()

	.. cpp:function:: bool CanSee( entity ent )

	.. cpp:function:: bool IsCrouching()

	.. cpp:function:: bool IsSecondaryAttack()

	.. cpp:function:: entity GetFollowTarget()

	.. cpp:function:: void InitFollowBehavior( entity followMe, string followBehaviour )

	.. cpp:function:: void DisableNPCFlag( int flag )

	.. cpp:function:: void EnableNPCFlag( int flag )

	.. cpp:function:: void Freeze()

	.. cpp:function:: void Unfreeze()

C_AI_BaseNPC
^^^^^^^^^^^^^

.. cpp:class:: C_AI_BaseNPC : extends C_BaseCombatCharacter

CNPC_Titan / C_NPC_Titan
------------------------

Shared
^^^^^^

.. cpp:class:: CNPC_Titan / C_NPC_Titan : extends CAI_BaseNPC / C_AI_BaseNPC

	.. cpp:function:: bool GetCanStand()

CNPC_Titan
^^^^^^^^^^

.. cpp:class:: CNPC_Titan : extends CAI_BaseNPC

	.. cpp:function:: void SetCanStand( bool canStand )

	.. cpp:function:: void GrappleNPC( vector dir )

C_NPC_Titan
^^^^^^^^^^^

CNPC_Dropship / C_NPC_Dropship
------------------------------

Shared
^^^^^^

.. cpp:class:: CNPC_Dropship / C_NPC_Dropship : extends CAI_BaseNPC / C_AI_BaseNPC

	.. cpp:function:: bool IsJetWakeFXEnabled()

CNPC_Dropship
^^^^^^^^^^^^^

.. cpp:class:: CNPC_Dropship : extends CAI_BaseNPC

C_NPC_Dropship
^^^^^^^^^^^^^^

.. cpp:class:: C_NPC_Dropship : extends C_AI_BaseNPC

CNPC_Drone
----------

.. cpp:class:: CNPC_Drone : extends CAI_BaseNPC

	.. cpp:function:: unknown SetAttackMode( unknown )

CNPC_SentryTurret / C_NPC_SentryTurret

Shared
^^^^^^

.. cpp:class:: CNPC_SentryTurret / C_NPC_SentryTurret : extends CAI_BaseNPC / C_AI_BaseNPC

	.. cpp:function:: unknown GetTurretState( unknown )

	.. cpp:function:: unknown GetControlPanel( unknown )

CNPC_SentryTurret
^^^^^^^^^^^^^^^^^

.. cpp:class:: CNPC_SentryTurret : extends CAI_BaseNPC

	.. cpp:function:: unknown StartDeployed( unknown )

C_NPC_SentryTurret
^^^^^^^^^^^^^^^^^^

.. cpp:class:: C_NPC_SentryTurret : extends C_AI_BaseNPC
	

CFirstPersonProxy / C_FirstPersonProxy
--------------------------------------

Shared
^^^^^^

.. cpp:class:: CFirstPersonProxy / C_FirstPersonProxy : extends CBaseAnimating / C_BaseAnimating

CFirstPersonProxy
^^^^^^^^^^^^^^^^^

.. cpp:class:: CFirstPersonProxy : extends CBaseAnimating

C_FirstPersonProxy
^^^^^^^^^^^^^^^^^^

.. cpp:class:: C_FirstPersonProxy : extends C_BaseAnimating

CBaseAnimating / C_BaseAnimating
--------------------------------

Shared
^^^^^^

.. cpp:class:: CBaseAnimating / C_BaseAnimating : extends CBaseEntity / C_BaseEntity

	.. cpp:function:: vector GetAttachmentOrigin()

	.. cpp:function:: int LookupAttachment( string attachment )

	.. cpp:function:: int FindBodyGroup( string group )

	.. cpp:function:: int GetBodyGroupState( int bodyGroupIndex )

	.. cpp:function:: int GetBodyGroupModelCount( int bodyGroupIndex )

	.. cpp:function:: void SetBodygroup( int groupIndex, int newIndex )

	.. cpp:function:: vector GetAttachmentAngles()

	.. cpp:function:: Attachment Anim_GetAttachmentAtTime( string animation, string attachmentName, float time )

	.. cpp:function:: float GetScriptedAnimEventCycleFrac( string anim, string event )

	.. cpp:function:: float GetSequenceDuration( string anim )

	.. cpp:function:: bool Anim_IsActive()

	.. cpp:function:: void Anim_Play( string anim )

	.. cpp:function:: void Anim_SetInitialTime( float time )

	.. cpp:function:: void Anim_Stop()

	.. cpp:function:: vector Anim_GetStartForRefEntity_Old( string anim, vector reference, string optionalTag )

	.. cpp:function:: int GetSkin()

	.. cpp:function:: int LookupSequence( string sequence )

	.. cpp:function:: void SetSkin( int skin )

	.. cpp:function:: AnimRefPoint Anim_GetStartForRefPoint( string anim, vector origin, vector angles )

	.. cpp:function:: unknown Anim_GetStartForRefPoint_Old( animation, origin, angles )

	.. cpp:function:: void Anim_PlayWithRefPoint( string animation, vector origin, vector angles, float blendTime )

	.. cpp:function:: void Anim_NonScriptedPlay( string animation )

	.. cpp:function:: bool Anim_HasSequence( string animation )

	.. cpp:function:: void SetPlaybackRate( float rate )

	.. cpp:function:: void Anim_SetStartTime( float time )

	.. cpp:function:: void LerpSkyScale( float skyScale, float time )

	.. cpp:function:: void SetPoseParameter( int pose, float offset )

	.. cpp:function:: vector GetAttachmentForward( int attachID )


CBaseAnimating
^^^^^^^^^^^^^^

.. cpp:class:: CBaseAnimating : extends CBaseEntity

	.. cpp:function:: int GetFullBodygroup()

	.. cpp:function:: void BecomeRagdoll( vector push, bool skipAnim )

	.. cpp:function:: void Dissolve( int dissolveID, vector unknown_purpose1, int unknown_purpose2 )

	.. cpp:function:: void Gib( vector forceVec )

	.. cpp:function:: void SetContinueAnimatingAfterRagdoll( bool cont )

	.. cpp:function:: void PlayRecordedAnimation( asset animation, vector unknown_purpose1, vecor unknown_purpose2 )

	.. cpp:function:: void SetRecordedAnimationPlaybackRate( float rate )

	.. cpp:function:: void Anim_EnablePlanting()

	.. cpp:function:: int LookupPoseParameterIndex( string poseParam )

	.. cpp:function:: void Anim_DisableUpdatePosition()

C_BaseAnimating
^^^^^^^^^^^^^^^

.. cpp:function:: C_BaseAnimatin : extends C_BaseEntity

	.. cpp:function:: void SetGroundEffectTable( string tableIdentifier )

	.. cpp:function:: float GetAttachmentOrigin_ViewModelNoFOVAdjust( int index )

	.. cpp:function:: void Anim_SetPaused( bool pause )

	.. cpp:function:: void SetCycle( float cycle )

	.. cpp:function:: void DoBodyGroupChangeScriptCallback( bool unknown_purpose, int bodygroup )

CPlayerDecoy / C_PlayerDecoy
----------------------------

Shared
^^^^^^

.. cpp:class:: CPlayerDecoy / C_PlayerDecoy : extends CBaseAnimating / C_BaseAnimating

CPlayerDecoy
^^^^^^^^^^^^

.. cpp:class:: CPlayerDecoy : extends CBaseAnimating

	.. cpp:function:: void Decoy_Dissolve()

	.. cpp:function:: void SetTimeout( int duration )

	.. cpp:function:: void SetDecoyRandomPulseRateMax( float pulse_amount_per_second )

	.. cpp:function:: void SetFriendlyFire( bool ff )

	.. cpp:function:: void SetKillOnCollision( bool kill )

C_PlayerDecoy
^^^^^^^^^^^^^

.. cpp:class:: CPlayerDecoy : extends CBaseAnimating

CTurret
-------

.. cpp:function:: CTurret : extends CBaseAnimating

	.. cpp:function:: void ClearDriver()

	.. cpp:function:: entity GetDriver()

	.. cpp:function:: voit SetDriver( enitity driver )

C_Titan_Cockpit
---------------

.. cpp:function:: C_Titan_Cockpit : extends C_BaseEntity

	.. cpp:function:: void AddToTitanHudDamageHistory( int panel, int damage )

	.. cpp:function:: void SetCaptureScreenBeforeViewmodels( bool cap )

	.. cpp:function:: float GetTimeInCockpit()

		Cockpit booting takes 1.3 seconds.

	.. cpp:function:: void SetOpenViewmodelOffset( float a, float b, float c )

CParticleSystem
---------------

.. cpp:class:: CParticleSystem : extends CBaseEntity

	.. cpp:function:: void FXEnableRenderAlways()

	.. cpp:function:: void SetStopType( string type )

	.. cpp:function:: void SetControlPointEnt( int unknown_purpose, entity destEnt )

CVortexSphere / C_VortexSphere
------------------------------

Shared
^^^^^^

.. cpp:class:: CVortexSphere / C_VortexSphere : extends CBaseEntity / C_BaseEntity

	.. cpp:function:: int GetBulletAbsorbedCount()

	.. cpp:function:: int GetProjectileAbsorbedCount()

CVortexSphere
^^^^^^^^^^^^^

.. cpp:class:: CVortexSphere : extends CBaseEntity

	.. cpp:function:: void SetGunVortexAngles( vector angles )

	.. cpp:function:: void SetGunVortexAttachment( string attach )

	.. cpp:function:: void SetOwnerWeapon( entity owner )

	.. cpp:function:: void SetVortexEffect( entity fx )

	.. cpp:function:: void DisableVortexBlockLOS()

	.. cpp:function:: enitity GetOwnerWeapon()

	.. cpp:function:: void AddBulletToSphere()

	.. cpp:function:: void AddProjectileToSphere()

	.. cpp:function:: void ClearAllBulletsFromSphere()

	.. cpp:function:: void RemoveBulletFromSphere()

	.. cpp:function:: void RemoveProjectileFromSphere()

C_VortexSphere
^^^^^^^^^^^^^^

.. cpp:class:: C_VortexSphere : extends C_BaseEntity

CEnvExplosion

.. cpp:class:: CEnvExplosion : extends CBaseEntity
