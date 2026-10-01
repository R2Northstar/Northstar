# NPCs

For settings, see [AI Settings](settings.md#ai-settings)

## NPC Utils

!!! cpp-function "void UpdateEnemyMemoryFromTeammates( entity guy )"

!!! cpp-function "void UpdateEnemyMemoryWithinRadius( entity guy, number radius )"

!!! cpp-function "void SetEnableNPCs( bool enabled )"

!!! cpp-function "void ToggleNPCPathsForEntity( entity ent, bool pathable )"

  Controls if `ent` is traversable by NPCs

!!! cpp-function "void ToggleNPCPathsForEntityAtPosition( entity ent, vector pos, bool pathable )"

!!! cpp-function "void TransitionNPCPathsForEntity( entity ent, vector pos, bool b )"

!!! cpp-function "void SetVisibleEntitiesInConeQueriableEnabled( entity ent, bool enabled )"

## NPC Squads

!!! cpp-function "void CreateNPCSquad( string name )"

!!! cpp-function "int GetNPCSquadSize( string name )"

!!! cpp-function "void SetNPCSquadMode( string name, number mode )"

!!! cpp-function "array<entity> ScriptGetNPCArrayBySquad( string name )"

## NPC Navigation Nodes

!!! cpp-function "void NPCSetSearchPathUseDist( number distance )"

!!! cpp-function "float NPCGetSearchPathUseDist()"

!!! cpp-function "void NPCSetAimConeFocusParams( number a, number b )"

!!! cpp-function "void NPCSetAimPatternFocusParams( number a, number b )"

!!! cpp-function "void NPCSetReacquireParams( number a, number b )"

!!! cpp-function "void NPCSetSquadNoFlankThreshold( string a, number b, number c )"


!!! cpp-function "int GetNearestNodeToPos( vector pos )"

  Returns a node index

!!! cpp-function "int GetBestNodeForPosInWedge( vector tPos, vector startPos, number yaw, number minFov, number maxFov, number fovPenalty, number some_index, number steps_maybe )"

  Returns a node index

!!! cpp-function "vector GetNodePos( int nodeIndex )"

!!! cpp-function "int GetNodeCount()"

!!! cpp-function "bool GetNodeScriptData_Boolean( int nodeIndex, int otherNodeIndex )"

!!! cpp-function "void SetNodeScriptData_Boolean( int nodeIndex, int otherNodeIndex, bool value )"

!!! cpp-function "int GetAINScriptVersion()"

## Navmeshes

!!! cpp-function "bool NavMesh_IsUpToDate()"

!!! cpp-function "vector ornull NavMesh_ClampPointForAI( vector point, entity npc )"

  Clamps a goal point to the NavMesh for a given AI. Uses AIs hull size as test extents

!!! cpp-function "vector ornull NavMesh_ClampPointForAIWithExtents( vector pointToClamp, entity contextAI, vector extents )"

  Clamps a goal point to the NavMesh for a given AI.
  As extents increase in size more possible clamp positions become available,
  but too large and the clamped position may be very far from the original point.

!!! cpp-function "vector ornull NavMesh_ClampPointForHull( vector pointToClamp, int hull )"

  Clamps a goal point to the NavMesh for a given hull

!!! cpp-function "vector ornull NavMesh_ClampPointForHullWithExtents( vector pointToClamp, int hull, vector extents )"

  Clamps a goal point to the NavMesh for a given hull.
  As extents increase in size more possible clamp positions become available,
  but too large clamped position may be very far from the original point.

!!! cpp-function "array<vector> NavMesh_GetNeighborPositions( vector point, int hull_maybe, int nNodesToCheck_maybe )"

  Get nearby ground positions by following the NavMesh graph

!!! cpp-function "array<vector> NavMesh_RandomPositions( vector startPos, int hull, int numPositionsRequested, float minDist, float maxDist )"

  Get n( < 64 ) ground positions around a spot within `minDist` and `maxDist`

!!! cpp-function "array<vector> NavMesh_RandomPositions_LargeArea( vector startPos, int hull, int numPositionsRequested, float minDist, float maxDist )"

  Get up to n ground positions around a spot within `minDist` and `maxDist`. Gets center of random polygons.

!!! cpp-function "bool NavMesh_IsPosReachableForAI( entity npc, vector point )"

  Checks if the npc can reach the position over graph

!!! cpp-function "vector GetBoundsMin( int hull )"

!!! cpp-function "vector GetBoundsMax( int hull )"

## Skits

!!! cpp-function "void SkitSetDistancesToClosestHarpoints()"

!!! cpp-function "array<entity> GetSkitNodeArray_NearPlayers()"

  Get skit nodes sorted by nearest to average player position with some randomization

!!! cpp-function "array<entity> GetSkitNodeArray_NearHardpoints()"

  Get skit nodes sorted by nearest to hardpoints with some randomization

!!! cpp-function "array<entity> GetSkitNodeArray_NearPos()"

  Get skit nodes sorted by nearest to pos with some randomization

## Dangerous Areas

!!! cpp-function "void AI_CreateDangerousArea( entity lifetimeEnt, entity weaponOrProjectile, float radius, int safeTeam, bool affectsNormalArmor, bool affectsHeavyArmor )"

  Create a known dangerous are that AI should avoid if necessary.
  The lifetime of the danger is tied to an entity

!!! cpp-function "void AI_CreateDangerousArea_Static( entity lifetimeEnt, entity weaponOrProjectile, float radius, int safeTeam, bool affectsNormalArmor, bool affectsHeavyArmor, vector staticOrigin )"

  Same as AI_CreateDangerousArea except the origin is always in a single place

!!! cpp-function "void AI_CreateDangerousArea_DamageDef( int damageDef, entity lifetimeEnt, int safeTeam, bool affectsNormalArmor, bool affectsHeavyArmor )"

  Create dangerous area using damage def

## AIN

[AIN on the valve wiki](https://developer.valvesoftware.com/wiki/AIN)

!!! cpp-function "bool AINFileIsUpToDate()"

!!! cpp-function "bool AINExists()"

!!! cpp-function "void SetAINScriptVersion( int version )"

## Spawners

!!! cpp-function "array<entity> GetSpawnerArrayByClassName( string className )"

  Get array of spawners matching a class name

!!! cpp-function "array<entity> GetSpawnerArrayByScriptName( string name )"

  Get array of spawners matching a script name

!!! cpp-function "entity GetSpawnerByScriptName( string name )"
