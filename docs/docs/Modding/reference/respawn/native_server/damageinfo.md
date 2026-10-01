# DamageInfo

DamageInfos are variables holding information about damage inflicted on an entity.

Because damageInfo instances are implemented as userdata they can't be typed.

## Getters

!!! cpp-function "entity DamageInfo_GetAttacker( var damageInfo )"

  Returns the attacker of this damageInfo

!!! cpp-function "entity DamageInfo_GetInflictor( var damageInfo )"

  Returns the inflictor of this damageInfo

!!! cpp-function "entity DamageInfo_GetWeapon( var damageInfo )"

  Returns the weapon that dealt this damage

!!! cpp-function "bool DamageInfo_GetForceKill( var damageInfo )"

  Get if this damage is supposed to kill the victim regardless of health

!!! cpp-function "float DamageInfo_GetDamage( var damageInfo )"

  Get the inflicted damage

!!! cpp-function "float DamageInfo_GetDamageCriticalHitScale( var damageInfo )"

!!! cpp-function "vector DamageInfo_GetDamagePosition( var damageInfo )"

  Returns the position where the damage originated.
  Usually this is the barrel attachment of the weapon that inflicted the damage.

!!! cpp-function "int DamageInfo_GetHitGroup( var damageInfo )"

!!! cpp-function "int DamageInfo_GetHitBox( var damageInfo )"

!!! cpp-function "string DamageInfo_GetDeathPackage( var damageInfo )"


!!! cpp-function "int DamageInfo_GetDamageType( var damageInfo )"

!!! cpp-function "int DamageInfo_GetCustomDamageType( var damageInfo )"


!!! cpp-function "int DamageInfo_GetDamageSourceIdentifier( var damageInfo )"

    Returns the `eDamageSourceId`

    `damageSourceId` is an `int` that references an `enum` and can be used to identify what source damage came from.

    `damageSourceId` is mostly found as an argument in some kill and damage related functions. Respawn has created a function that will attempt to localise the damageSourceId inputed.
    To add your own custom `damageSourceID` , see: :doc:`../../northstar/customdamagesources`

    Other useful functions can be found in the `damageinfo` section of this page and in :doc:`entities`

    `GetObitFromdamageSourceId` is a global function that attempts to localise the `damageSourceId` inputed, if it cannot get a localised string it will simply return the localisation string of the source.

!!! cpp-function "float DamageInfo_GetViewPunchMultiplier( vare damageInfo )"

!!! cpp-function "float DamageInfo_GetDistFromAttackOrigin( var damageInfo )"

  Get the distance from where the bullet/projectile was fired.

!!! cpp-function "float DamageInfo_GetDistFromExplosionCenter( var damageInfo )"

  If it's a radius damage, gives the distance from the center of the blast. Otherwise defaults to zero.

!!! cpp-function "vector DamageInfo_GetDamageForce( var damageInfo )"

  Get damage force vector.

!!! cpp-function "bool DamageInfo_IsRagdollAllowed( var damageInfo )"

  Checks if code is allowing this entity to ragdoll on death

!!! cpp-function "int DamageInfo_GetDamageFlags( var damageInfo )"

  Get all DAMAGEFLAG_* flags.

!!! cpp-function "bool DamageInfo_HasDamageFlags( var damageInfo, int damageFlags )"

  "Returns true if contains all given DAMAGEFLAG_* flags.

!!! cpp-function "string DamageInfo_GetDamageWeaponName( var damageInfo )"

  Returns weapon name, even if weapon entity is gone

!!! cpp-function "bool DamageInfo_ShouldRecordStatsForWeapon( var damageInfo )"

  Returns if stats should be recorded for damage weapon

## Setters

!!! cpp-function "void DamageInfo_SetForceKill( var damageInfo, bool force )"

  Sets whether this damage should force a kill

!!! cpp-function "void DamageInfo_SetDamage( var damageInfo, float damage )"

  Set the amount of damage

!!! cpp-function "void DamageInfo_SetCustomDamageType( var damageInfo, int damageType )"

  Overrides the damage type that was set by script when firing the weapon.

!!! cpp-function "void DamageInfo_AddCustomDamageType( var damageInfo, int damageType )"

  Add a damage flag.

!!! cpp-function "void DamageInfo_RemoveCustomDamageType( var damageInfo, int damageType )"

  Remove damage flag.

!!! cpp-function "void DamageInfo_SetDamageSourceIdentifier( var damageInfo, int identifier )"

  Sets the damage source identifier.

!!! cpp-function "void DamageInfo_SetDeathPackage( var damageInfo, string package )"

  Set what death (anim) package to use if this damage kills the guy.

!!! cpp-function "void DamageInfo_SetDamageForce( var damageInfo, vector force )"

  Set damage force vector

!!! cpp-function "void DamageInfo_SetFlinchDirection( var damageInfo, number direction )"

  Set which direction the target should flinch in.

!!! cpp-function "void DamageInfo_AddDamageFlags( var damageInfo, int flags )"

  Add a DAMAGEFLAG_* flag.

## Utils

!!! cpp-function "bool IsCriticalHit( entity attacker, entity victim, number hitBox, number damage, int damageType )"

!!! cpp-function "bool IsRodeoHitBox( entity e, number f )"

## Helpers

!!! cpp-function "bool HeavyArmorCriticalHitRequired( var damageInfo )"

  !!! note

    SERVER only

!!! cpp-function "bool CritWeaponInDamageInfo( var damageInfo )"

  !!! note

    SERVER only

!!! cpp-function "float GetCriticalScaler( ent, damageInfo )"

  !!! note

    SERVER only

!!! cpp-function "bool IsValidHeadShot( var damageInfo = null, entity victim = null, entity attacker = null, entity weapon = null, int hitGroup = -1, float attackDist = -1.0, entity inflictor = null )"

!!! cpp-function "bool IsMaxRangeShot( damageInfo )"

!!! cpp-function "bool IsMidRangeShot( damageInfo )"

!!! cpp-function "bool IsInstantDeath( var damageInfo )"

!!! cpp-function "bool IsTitanCrushDamage( damageInfo )"

!!! cpp-function "bool IsSuicide( entity attacker, entity victim, int damageSourceId )"

!!! cpp-function "string GetObitFromdamageSourceId( int damageSourceId )"



## Damage Flags

You can get a bitflag of all damage types used with `DamageInfo_GetDamageType`.


??? "Damage flags"

    List of all Damage flags

    |Variable name          |Value|
    |-----------------------|-------|
    |DF_GIB                 |1|
    |DF_DISSOLVE            |2|
    |DF_INSTANT             |3|
    |DF_NO_SELF_DAMAGE      |4|
    |DF_IMPACT              |5|
    |DF_BYPASS_SHIELD       |6|
    |DF_RAGDOLL             |7|
    |DF_TITAN_STEP          |8|
    |DF_RADIUS_DAMAGE       |9|
    |DF_ELECTRICAL          |10|
    |DF_BULLET              |11|
    |DF_EXPLOSION           |12|
    |DF_MELEE               |13|
    |DF_NO_INDICATOR        |14|
    |DF_KNOCK_BACK          |15|
    |DF_STOPS_TITAN_REGEN   |16|
    |DF_DISMEMBERMENT       |17|
    |DF_MAX_RANGE           |18|
    |DF_SHIELD_DAMAGE       |19|
    |DF_CRITICAL            |20|
    |DF_SKIP_DAMAGE_PROT    |21|
    |DF_HEADSHOT            |22|
    |DF_VORTEX_REFIRE       |23|
    |DF_RODEO               |24|
    |DF_BURN_CARD_WEAPON    |25|
    |DF_KILLSHOT            |26|
    |DF_SHOTGUN             |27|
    |DF_SKIPS_DOOMED_STATE  |28|
    |DF_DOOMED_HEALTH_LOSS  |29|
    |DF_DOOM_PROTECTED      |30|
    |DF_DOOM_FATALITY       |31|
    |DF_NO_HITBEEP          |32|

??? "Damage types"

    ```squirrel


    global enum damageTypes
    {
        gibs = (DF_GIB)
        largeCaliberExp  = (DF_BULLET | DF_GIB | DF_EXPLOSION)
        gibBullet = (DF_BULLET | DF_GIB)
        instant = (DF_INSTANT)
        dissolve = (DF_DISSOLVE)
        projectileImpact = (DF_GIB)
        pinkMist = (DF_GIB) //If updated from DF_GIB, change the DF_GIB in Arc Cannon to match.
        ragdoll = (DF_RAGDOLL)
        titanStepCrush = (DF_TITAN_STEP)
        arcCannon = (DF_DISSOLVE | DF_GIB | DF_ELECTRICAL )
        electric = (DF_ELECTRICAL) //Only increases Vortex Shield decay for bullet weapons atm.
        explosive = (DF_RAGDOLL | DF_EXPLOSION )
        bullet = (DF_BULLET)
        largeCaliber = (DF_BULLET | DF_KNOCK_BACK)
        shotgun = (DF_BULLET | DF_GIB | DF_SHOTGUN )
        titanMelee = (DF_MELEE | DF_RAGDOLL)
        titanBerserkerMelee = (DF_MELEE | DF_RAGDOLL)
        titanEjectExplosion = (DF_GIB | DF_EXPLOSION)
        dissolveForce = (DF_DISSOLVE | DF_KNOCK_BACK | DF_EXPLOSION)
        rodeoBatteryRemoval = (DF_RODEO | DF_EXPLOSION | DF_STOPS_TITAN_REGEN )
    }
    ```
