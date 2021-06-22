# Collision & Tracing

!!! cpp-function "bool AABBIntersectsAABB( vector a1, vector a2, vector a3, vector b1, vector b2, vector b3, number c1 )"

!!! cpp-function "bool OBBIntersectsOBB( vector a1, vector a2, vector a3, vector a4, vector b1, vector b2, vector b3, vector b4, number c1 )"

!!! cpp-function "bool TraceLOSMultiple( array startsArray, array endsArray, entity ignoreEntity, int mask, int group )"

  Do muliple LOS checks, early out if any return true. Runs on multiple threads.

  `mask`: `TRACE_MASK_*`

  `group`: `TRACE_COLLISION_GROUP_*`

!!! cpp-function "TraceResults TraceLine( vector startPos, vector endPos, var ignoreEntOrArrayOfEnts = null, int traceMask = 0, int collisionGroup = 0 )"

  Does a trace and returns struct of result values.

!!! cpp-function "TraceResults TraceLineHighDetail( vector startPos, vector endPos, var ignoreEntOrArrayOfEnts = null, int traceMask = 0, int collisionGroup = 0 )"

  Does a high-detail (per poly on static models) trace and returns struct of result values.

!!! cpp-function "TraceResults TraceHull( vector startPos, vector endPos, vector hullMins, vector hullMaxs, var ignoreEntOrArrayOfEnts = null, int traceMask = 0, int collisionGroup = 0 )"

  Does a hull trace and returns table of result values.

!!! cpp-function "TraceResults TraceLineNoEnts( vector startPos, vector endPos, int traceMask = 0 )"

  Does a trace and returns table of result values.

!!! cpp-function "float TraceLineSimple( vector startPos, vector endPos, entity ignoreEnt )"

  Does a trace and returns the distance from `startPos` to hit.

!!! cpp-function "float TraceHullSimple( vector startPos, vector endPos, vector hullMins, vector hullMaxs, entity ignoreEnt )"

  Does a trace and returns the distance from `startPos` to hit.

!!! cpp-function "void DoTraceCoordCheck( bool check )"

!!! cpp-function "array<entity> TraceGetEntsAlongLine( vector startPos, vector endPos, int traceMask = 0, int collisionGroup = 0 )"

  Does a trace and returns all ents along a line.

!!! cpp-function "bool CheckPassThroughDir( entity ent, vector dir, vector endPos )"

!!! cpp-function "bool IsPointInFrontofLine( vector point, vector startPos, vector endPos )"

!!! cpp-function "array<VisibleEntityInCone> FindVisibleEntitiesInCone( vector coneApex, vector coneAxis, float coneHeight, float coneAngleToAxis, array<entity> ignoredEntities, int traceMask, int flags, entity antilagPlayer, entity weapon = null )"

  Returns an array of entities that are inside of a cone and visible to the apex

!!! cpp-function "VortexBulletHit ornull VortexBulletHitCheck( entity attacker, vector startPos, vector endPos )"

  Check for vortexSphere collisions between two points.
