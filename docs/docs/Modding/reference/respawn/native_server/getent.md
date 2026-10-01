# Getting Entities {#get-ent-doc}

There are a multitude of selectors to get specific kinds of entities.

Creating entities is documented [here](createent.md).

## Players

!!! cpp-function "array<entity> GetPlayerArray()"

  Get array of all players

!!! cpp-function "array<entity> GetPlayerArrayEx( string classname, int onSameTeamAsNum, int enemiesOfTeamNum, vector origin, float maxdist )"

  Get array of all players by class, team within dist. team -1 for any team, `"any"` for any class, otherwise `"titan"` or `"pilot"`, -1 for any dist

!!! cpp-function "array<entity> GetPlayerArrayOfTeam( int team )"

  Get array of all players that are in a team

!!! cpp-function "array<entity> GetPlayerArrayOfEnemies( int team )"

  Get array of all players that are not allied with the team

!!! cpp-function "array<entity> GetPlayerArray_Alive()"

  Get array of all players that are alive

!!! cpp-function "array<entity> GetPlayerArrayOfTeam_Alive( int team )"

  Get array of all players in a team that are alive

!!! cpp-function "array<entity> GetPlayerArrayOfEnemies_Alive( int team )"

!!! cpp-function "array<entity> GetPlayerArray_Pilots()"

  Get array of all players that are not titans

!!! cpp-function "array<entity> GetPlayerArrayOfTeam_Pilots( int team )"

!!! cpp-function "array<entity> GetPlayerArrayOfEnemies_Pilots( int team )"

!!! cpp-function "array<entity> GetPlayerArray_AlivePilots()"

!!! cpp-function "array<entity> GetPlayerArrayOfTeam_AlivePilots( int team )"

!!! cpp-function "array<entity> GetPlayerArrayOfEnemies_AlivePilots( int team )"

!!! cpp-function "array<entity> GetPlayerDecoryArray()"

### Connecting Players

!!! cpp-function "array<entity> GetConnectingAndConnectedPlayerArray()"

  Get array of all players, even ones who are connecting

!!! cpp-function "int GetPendingClientsCount()"

## Titans

Get all players in a titan and souls.

!!! cpp-function "array<entity> GetTitanArray()"

!!! cpp-function "array<entity> GetTitanArrayOfTeam( int team )"

!!! cpp-function "array<entity> GetTitanArrayOfEnemies( int team )"

!!! cpp-function "array<enitity> GetTitanSoulArray()"

!!! cpp-function "int GetTitanCountForTeam( int team )"

!!! cpp-function "int GetTeamPlayerCount( int team )"

## NPCs & Props

!!! cpp-function "int GetSurfacePropForEntity( entity ent )"

!!! cpp-function "entity GetEntByIndex( int index )"

!!! cpp-function "array<entity> GetNPCArray()"

!!! cpp-function "array<entity> GetNPCArrayOfTeam( int team )"

!!! cpp-function "array<entity> GetNPCArrayOfEnemies( int team )"

!!! cpp-function "array<entity> GetNPCArrayEx( string classname, int onSameTeamAsNum, int enemiesOfTeamNum, vector origin, float maxdist )"

  Get array of all NPCs by class, team, within dist. team -1 for any team, `"any"` for any class, otherwise `"titan"` or `"pilot"`, -1 for any dist

!!! cpp-function "GetNPCArrayWithSubclassEx( string classname, int onSameTeamAsNum, int enemiesOfTeamNum, vector origin, float maxdist, array<int> subclasses )"

  Get array of all NPCs by class, team, and subclass (array), within dist. team -1 for any team, `"'any"` for any class, -1 for any dist

!!! cpp-function "array<entity> GetNPCArrayByClass( string classname )"

  Get array of all NPCs of class

!!! cpp-function "array<entity> ScriptGetNPCArrayByClassAndSubclass( string classname, array<int> subclasses )"

  Get array of all NPCs of class and subclass

## Projectiles

!!! cpp-function "array<entity> GetProjectileArray()"

!!! cpp-function "array<entity> GetProjectileArrayEx( string classname, int onSameTeamAsNum, int enemiesOfTeamNum, vector origin, float maxdist )"

  Get array of all NPCs by class, team, within dist. team -1 for any team, `"any"` for any class, otherwise `"titan"` or `"pilot"`, -1 for any dist

## Find Entities

!!! cpp-function "entity Entities_First()"

!!! cpp-function "entity Entities_Next( entity ent )"

!!! cpp-function "entity Entities_FindByClassname( entity ent, string className )"

!!! cpp-function "entity Entities_FindByName( entity ent, string name )"

!!! cpp-function "entity Entities_FindInSphere( entity ent, vector sphereDir, float radius )"

!!! cpp-function "entity Entities_FindByTarget( entity ent, string target )"

!!! cpp-function "entity Entities_FindByNameNearest( string name, vector dir, float length )"

!!! cpp-function "entity Entities_FindByNameWithin( entity ent, string name, vector v, float len )"

!!! cpp-function "entity Entities_FindByClassnameNearest( string className, vector v, float f )"

!!! cpp-function "entity Entities_FindByClassnameWithin( entity ent, string className, vector v, float f )"

!!! cpp-function "entity GetEntByScriptName( string name )"

!!! cpp-function "entity GetEntByScriptNameInInstance( string name, string instanceName )"

!!! cpp-function "entity GetTeamEnt( int team )"

## Get Multiple Entites

!!! cpp-function "array<entity> GetEntArrayByName_Expensive( string name )"

  Get array of entitites matching a name

!!! cpp-function "array<entity> GetEntArrayByNameWildCard_Expensive( string name )"

  Get array of entities matching a name with support for *

!!! cpp-function "array<entity> GetEntArrayByClass_Expensive( string className )"

  Get array of entities matching a class

!!! cpp-function "array<entity> GetEntArrayByClassWildCard_Expensive( string classname )"

  Get array of entities matching a class with support for *

!!! cpp-function "array<entity> GetEntArrayByScriptName( string name )"

  Get array of entities matching a script name

!!! cpp-function "array<entity> GetEntArrayByScriptNameInInstance( string scriptName, string instanceName )"

  Get array of entities matching a script name and instance

!!! cpp-function "array<entity> GetWeaponArray( bool onlyNotOwned )"

  Get weapons in the world
