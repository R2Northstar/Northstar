# Debug Drawing

!!! note

    Only `DebugDrawLine`, `DebugDrawBox` and `DebugDrawScreenText` are native functions.

    The rest are defined in scripts using these.

In Titanfall it is possible to draw shapes in 3D, from the SERVER and CLIENT VM, using the debug draw functions, however in order for them to actually render you will need to set `sv_cheats 1` and `enable_debug_overlays 1` in your launch config or console.

These debug drawing functions are available:


!!! cpp-function "void DebugDrawLine( vector start, vector end, int r, int b, int g, bool drawThroughObject, float time)"

!!! cpp-function "void DebugDrawCylinder( vector origin, vector angles, float radius, float height, int r, int g, int b, bool throughGeo, float time )"

!!! cpp-function "array<vector> DebugDrawCircle( vector origin, vector angles, float radius, int r, int g, int b, bool throughGeo, float time, int segments = 16 )"

!!! cpp-function "void DebugDrawMark( vector origin, float radius, array<int> color, bool alwaysDraw, float drawTime )"

!!! cpp-function "void DebugDrawSphere( vector origin, float radius, int r, int g, int b, bool throughGeo, float time, int segments = 16 )"

!!! cpp-function "void DrawArrow( vector origin, vector angles = <0,0,0>, float time = 5.0, float scale = 50, vector rgb = <0,0,0> )"

!!! cpp-function "void DrawStar( vector origin, int size, float time = 1.0, bool throughWorld = false )"

!!! cpp-function "void DebugDrawBoxSimple( vector origin, vector min = < -4.0, -4.0, -4.0>, vector max = <4.0, 4.0, 4.0>, int r = 255, int g = 255, int b = 100, int alpha = 255, float time = 0.2 )"


!!! cpp-function "void DrawBox( vector org, vector mins, vector maxs, int r, int g, int b, bool throughSolid, float time )"

!!! cpp-function "void DebugDrawCube( vector cubeCenter, float cubeSize, int r, int g, int b, bool throughSolid, float time )"

!!! cpp-function "void DebugDrawBox( vector org, vector min, vector max, int r, int g, int b, int a, float time)"

!!! cpp-function "void DrawAngledBox( vector org, vector ang, vector mins, vector maxs, int r, int g, int b, bool throughSolid, float time )"

!!! cpp-function "void DrawBoxFromEye( vector org, vector mins, vector maxs, int r, int g, int b, bool throughSolid, float time )"

!!! cpp-function "vector[8] GetBoxCorners( vector org, vector ang, vector mins, vector maxs )"

!!! cpp-function "void DebugDrawRotatedBox( vector origin, vector mins, vector maxs, vector angles, int r, int g, int b, bool throughGeo, float duration )"

!!! cpp-function "void DebugDrawCircleTillSignal( entity ent, string signalName, vector origin, float radius, int r, int g, int b )"

!!! cpp-function "void DebugDrawOriginMovement( entity ent, int r, int g, int b, float time = 9999.0, float trailTime = 5.0 )"

!!! cpp-function "void DebugDrawSpawnpoint( entity spawnpoint, int r, int g, int b, bool throughSolid, float time )"

!!! cpp-function "void DrawArrowOnTag( entity ent, string ornull tag = null, float time = 5.0, float scale = 50, vector rgb = <0,0,0> )"

!!! cpp-function "void DrawArrowOnTagThread( entity ent, string ornull tag, float time, float scale, vector rgb = <0,0,0> )"

!!! cpp-function "void DrawTag( entity ent, string tag )"

!!! cpp-function "void DrawOrg( entity ent )"

!!! cpp-function "void DrawAttachment( entity pod, string attachment, float time = 0.1, vector ornull color = null )"

!!! cpp-function "void DrawAttachmentForever( entity pod, string attachment )"

!!! cpp-function "void DrawEntityOrigin( entity ent, float time = 0.1, vector ornull color = null )"

!!! cpp-function "void DrawOrigin( vector origin, float time = 0.1, vector ornull color = null )"

!!! cpp-function "vector[16] DebugDrawTrigger( vector origin, float radius, int r, int g, int b )"

!!! cpp-function "void DebugDrawCircleOnEnt( entity ent, float radius, int r, int g, int b, float time )"

!!! cpp-function "void DebugDrawSphereOnEnt( entity ent, float radius, int r, int g, int b, float time )"

!!! cpp-function "void _DebugThreadDrawCircleOnEnt( entity ent, float radius, int r, int g, int b, float time, vector anglesDelta = Vector( 0, 0, 0 ) )"

!!! cpp-function "void DebugDrawCircleOnTag( entity ent, string tag, float radius, int r, int g, int b, float time )"

!!! cpp-function "void DebugDrawSphereOnTag( entity ent, string tag, float radius, int r, int g, int b, float time )"

!!! cpp-function "void _DebugThreadDrawCircleOnTag( entity ent, string tag, float radius, int r, int g, int b, float time, vector anglesDelta = Vector( 0, 0, 0 ) )"

!!! cpp-function "void DrawTracerOverTime( vector origin, vector dir, float time )"

!!! cpp-function "void DebugDrawWeapon( entity weapon )"

!!! cpp-function "void DebugDrawAngles( vector position, vector angles, float duration = 9999.0 )"

!!! cpp-function "void DrawAnglesForMovingEnt( entity ent, float duration, string optionalTag = "" )"

!!! cpp-function "void DrawLineFromEntToEntForTime( entity ent1, entity ent2, float duration, int r = 255, int g = 255, int b = 0 )"

!!! cpp-function "void DrawLineFromVecToEntForTime( vector vec, entity ent, float duration, int r = 255, int g = 255, int b = 0 )"

!!! cpp-function "void DrawLineForPoints( array<vector> points, vector color, float duration )"


!!! cpp-function "void DebugScreenText( float posX, float posY, string text )"

!!! error

    This function is stripped. It does nothing.
