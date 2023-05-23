DamageInfo
=========================

DamageInfo is a specific, data type, though of instance ``var`` used in :doc:`rSquirrel <../../squirrel/index>` by Respawn to store information about an attack in one variable.

Most commonly you will find ``damageinfo`` as an argument in a kill or damage callback. Respawn made some helper functions that help us extract or set certain stats in a ``damageinfo``


Getter functions
---------------

.. cpp:function:: int DamageInfo_GetDamageSourceIdentifier( var damageInfo )

    returns the ``eDamageSourceId``
    
    ``damageSourceId`` is an ``int`` that references an ``enum`` and can be used to identify what source damage came from. 

    ``damageSourceId`` is mostly found as an argument in some kill and damage related functions. Respawn has created a function that will attempt to localise the damageSourceId inputed.
    To add your own custom ``damageSourceID`` , see: :doc:`../northstar/customdamagesources`

    Other useful functions can be found in the ``damageinfo`` section of this page and in :doc:`entities`

    ``GetObitFromdamageSourceId`` is a global function that attempts to localise the ``damageSourceId`` inputed, if it cannot get a localised string it will simply return the localisation string of the source.


.. cpp:function:: float DamageInfo_GetDamage( var damageInfo )

    returns the damage inflicted to the target


.. cpp:function:: vector DamageInfo_GetDamagePosition( var damageInfo )


.. cpp:function:: vector DamageInfo_GetDamageForce( var damageInfo )


.. cpp:function:: unknown DamageInfo_GetDamageFlags( var damageInfo )


.. cpp:function:: var DamageInfo_GetDamageWeaponName( var damageInfo )

    While this returns a ``var`` it can be casted to a string with ``expect string( DamageInfo_GetDamageWeaponName( damageInfo ) )``


.. cpp:function:: entity DamageInfo_GetWeapon( var damageInfo )


.. cpp:function:: entity DamageInfo_GetAttacker( var damageInfo )


.. cpp:function:: entity DamageInfo_GetInflictor( var damageInfo )


.. cpp:function:: int DamageInfo_GetCustomDamageType( var damageInfo )


.. cpp:function:: int DamageInfo_GetHitBox( var damageInfo )


.. cpp:function:: int DamageInfo_GetHitGroup( var damageInfo )


.. cpp:function:: float DamageInfo_GetDistFromAttackOrigin( var damageInfo )


.. cpp:function:: float GetCriticalScaler( entity ent, var damageInfo )

.. cpp:function:: int DamageInfo_GetDamageType( damageInfo ) 


Setter functions
----------------

.. cpp:function:: void DamageInfo_SetDamage( damageInfo, float damage )


.. cpp:function:: void DamageInfo_SetDeathPackage( damageInfo, string type )


.. cpp:function:: void DamageInfo_SetDamageForce( damageInfo, vector force )


.. cpp:function:: void DamageInfo_SetForceKill( var damageInfo, bool )


.. cpp:function:: void DamageInfo_SetCustomDamageType( damageInfo, damageType )


Helper functions
----------------

Server only 
^^^^^^^^^^^

.. cpp:function:: bool HeavyArmorCriticalHitRequired( var damageInfo )


.. cpp:function:: bool CritWeaponInDamageInfo( var damageInfo )


.. cpp:function:: float GetCriticalScaler( ent, damageInfo )


Global 
^^^^^^

.. cpp:function:: bool IsValidHeadShot( var damageInfo = null, entity victim = null, entity attacker = null, entity weapon = null, int hitGroup = -1, float attackDist = -1.0, entity inflictor = null )


.. cpp:function:: bool IsMaxRangeShot( damageInfo )


.. cpp:function:: bool IsMidRangeShot( damageInfo )


.. cpp:function:: bool IsInstantDeath( var damageInfo )


.. cpp:function:: bool IsTitanCrushDamage( damageInfo )


.. cpp:function:: bool IsSuicide( entity attacker, entity victim, int damageSourceId )


.. cpp:function:: string GetObitFromdamageSourceId( int damageSourceId )


Extracting information
----------------------

You are able to get additional information about the damage dealt useing ``damageTypes``, you can get those either directly or with the ``DamageInfo_GetDamageType( damageInfo )``.
You are then able to check for certain information using the damageFlags 

.. dropdown:: Damage flags 

    List of all Damage flags


    ======================    =======
    Variable name             Value
    ======================    =======
    DF_GIB					  1
    DF_DISSOLVE				  2
    DF_INSTANT				  3
    DF_NO_SELF_DAMAGE		  4
    DF_IMPACT				  5
    DF_BYPASS_SHIELD		  6
    DF_RAGDOLL				  7
    DF_TITAN_STEP 			  8
    DF_RADIUS_DAMAGE 	      9
    DF_ELECTRICAL 			  10
    DF_BULLET 				  11
    DF_EXPLOSION			  12
    DF_MELEE				  13
    DF_NO_INDICATOR			  14
    DF_KNOCK_BACK			  15
    DF_STOPS_TITAN_REGEN	  16
    DF_DISMEMBERMENT		  17
    DF_MAX_RANGE			  18
    DF_SHIELD_DAMAGE		  19
    DF_CRITICAL				  20
    DF_SKIP_DAMAGE_PROT		  21
    DF_HEADSHOT				  22
    DF_VORTEX_REFIRE		  23
    DF_RODEO				  24
    DF_BURN_CARD_WEAPON		  25
    DF_KILLSHOT				  26
    DF_SHOTGUN				  27
    DF_SKIPS_DOOMED_STATE	  28
    DF_DOOMED_HEALTH_LOSS	  29
    DF_DOOM_PROTECTED		  30
    DF_DOOM_FATALITY		  31
    DF_NO_HITBEEP			  32
    ======================    =======
    


.. dropdown:: Damage types


    .. code-block:: 


        global enum damageTypes
        {
            gibs 				= (DF_GIB)
            largeCaliberExp		= (DF_BULLET | DF_GIB | DF_EXPLOSION)
            gibBullet			= (DF_BULLET | DF_GIB)
            instant				= (DF_INSTANT)
            dissolve			= (DF_DISSOLVE)
            projectileImpact	= (DF_GIB)
            pinkMist 			= (DF_GIB) //If updated from DF_GIB, change the DF_GIB in Arc Cannon to match.
            ragdoll				= (DF_RAGDOLL)
            titanStepCrush		= (DF_TITAN_STEP)
            arcCannon			= (DF_DISSOLVE | DF_GIB | DF_ELECTRICAL )
            electric			= (DF_ELECTRICAL) //Only increases Vortex Shield decay for bullet weapons atm.
            explosive			= (DF_RAGDOLL | DF_EXPLOSION )
            bullet				= (DF_BULLET)
            largeCaliber		= (DF_BULLET | DF_KNOCK_BACK)
            shotgun				= (DF_BULLET | DF_GIB | DF_SHOTGUN )
            titanMelee			= (DF_MELEE | DF_RAGDOLL)
            titanBerserkerMelee	= (DF_MELEE | DF_RAGDOLL)
            titanEjectExplosion	= (DF_GIB | DF_EXPLOSION)
            dissolveForce		= (DF_DISSOLVE | DF_KNOCK_BACK | DF_EXPLOSION)
            rodeoBatteryRemoval	= (DF_RODEO | DF_EXPLOSION | DF_STOPS_TITAN_REGEN )
        }



Now you can check for any of these by using the bitwise and operator ``&``

.. code-block::

    bool isHeadshot = bool( damageType & DF_HEADSHOT )

you can also combine two with the bitwise or operator ``|`` like this:

.. code-block::

    bool isHeadshotWithShotgun = bool( damageType & DF_HEADSHOT ) | bool( damageType & DF_SHOTGUN )
