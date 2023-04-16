DamageInfo
==========

DamageInfo is a specific, data type, though of instance ``var`` used in :doc:`rSquirrel <../../squirrel/index>` by Respawn to store information about an attack in one variable.

Most commonly you will find ``damageinfo`` as an argument in a kill or damage callback. Respawn made some helper functions that help us extract or set certain stats in a ``damageinfo``


Getter functions
---------------

.. cpp:function:: int DamageInfo_GetDamageSourceIdentifier( var damageInfo )

    returns the ``eDamageSourceId``


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
