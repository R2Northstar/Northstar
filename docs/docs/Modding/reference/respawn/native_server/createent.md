.. _create-ent-doc:

Create Entites
==============

Created entites do not spawn until they are :ref:`dispatched <DispatchSpawn>`.
Some script wrappers may dispatch entites themselves.

Getting entities is documented :ref:`here <get-ent-doc>`.

Internal Factories
------------------

.. cpp:function:: entity CreateProp( string type, vector origin, string s1, number n1 )

.. _DispatchSpawn:

.. cpp:function:: void DispatchSpawn( entity ent )

  Tells the specified entity to spawn. Should only be called once per entity.

.. cpp:function:: entity Entities_CreateByClassname( string className )

.. cpp:function:: entity Entities_CreateProjectileByClassname( string entName, string weaponClassName )

.. cpp:function:: entity Entities_CreateByTemplate( string template )

.. cpp:function:: array Entities_CreateByTemplateMultiple( string template )

  Create zero or more entities from templates that match the given string, and return them as an array. Wildcards allowed.

  All array contents are entites but the array is not typed itself.

.. cpp:function:: array Entities_CreateByPointTemplates( string matchingString , vector origin, vector angles )

  Create zero or more entities from point-templates that match the given string, and return them as an array. Wildcards allowed

.. cpp:function:: entity CreateWeaponEntityByName( string weaponName, vector origin, vector angles )

.. cpp:function:: entity CreateWeaponEntityByNameConstrained( string name, vector origin, vector angles )

.. cpp:function:: entity CreateWeaponEntityByNameWithPhysics( string name, vector origin, vector angles )

Interactable Props
^^^^^^^^^^^^^^^^^^

.. cpp:function:: entity CreateTurretEnt( vector origin, vector angles, entity ownerEnt, asset turretModel, string turretSettingsName )

.. cpp:function:: entity CreateControlPanelEnt( vector origin, vector angles, entity ownerEnt, asset model )

Script Wrappers
---------------

.. note::

  These are defined in ``ai/_ai_spawn.gnut```

Titans
^^^^^^

.. cpp:function:: entity CreateArcTitan( int team, vector origin, vector angles, array<string> settingsMods = [] )

.. cpp:function:: entity CreateAtlas( int team, vector origin, vector angles, array<string> settingsMods = [] )

.. cpp:function:: entity CreateHenchTitan( string titanType, vector origin, vector angles )

.. cpp:function:: entity CreateNPCTitan( string settings, int team, vector origin, vector angles, array<string> settingsMods = [] )

.. cpp:function:: entity CreateOgre( int team, vector origin, vector angles, array<string> settingsMods = [] )


Drones
^^^^^^

.. cpp:function:: entity CreateFragDrone( int team, vector origin, vector angles )

.. cpp:function:: entity CreateFragDroneCan( int team, vector origin, vector angles )

  Creates an unarmed drone

.. cpp:function:: entity CreateGenericDrone( int team, vector origin, vector angles )

.. cpp:function:: entity CreateRocketDrone( int team, vector origin, vector angles )

.. cpp:function:: entity CreateShieldDrone( int team, vector origin, vector angles )

Common
^^^^^^

.. cpp:function:: entity CreateElitePilot( int team, vector origin, vector angles )

.. cpp:function:: entity CreateElitePilotAssassin( int team, vector origin, vector angles )

.. cpp:function:: entity CreateSoldier( int team, vector origin, vector angles )

.. cpp:function:: entity CreateRocketDroneGrunt( int team, vector origin, vector angles )

.. cpp:function:: entity CreateShieldDroneGrunt( int team, vector origin, vector angles )

.. cpp:function:: entity CreateSpectre( int team, vector origin, vector angles )

.. cpp:function:: entity CreateStalker( int team, vector origin, vector angles )

.. cpp:function:: entity CreateStryder( int team, vector origin, vector angles, array<string> settingsMods = [] )

.. cpp:function:: entity CreateSuperSpectre( int team, vector origin, vector angles )

.. cpp:function:: entity CreateZombieStalker( int team, vector origin, vector angles )

.. cpp:function:: entity CreateZombieStalkerMossy( int team, vector origin, vector angles )

.. cpp:function:: entity CreateMarvin( int team, vector origin, vector angles )

.. cpp:function:: entity CreateWorkerDrone( int team, vector origin, vector angles )

.. cpp:function:: entity CreateProwler( int team, vector origin, vector angles )

.. cpp:function:: entity CreateGunship( int team, vector origin, vector angles )

.. cpp:function:: entity CreateNPC( string baseClass, int team, vector origin, vector angles )

.. cpp:function:: entity CreateNPCFromAISettings( string aiSettings, int team, vector origin, vector angles )
