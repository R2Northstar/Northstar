untyped

global function SpawnFunctions_Init

function SpawnFunctions_Init()
{
	if ( IsLobby() )
		return

	// shared OnSpawned callbacks
	AddSpawnCallback( "script_mover",		SpawnScriptMover )
	AddSpawnCallback( "path_track", 		SpawnPathTrack )
	AddSpawnCallback( "info_hint", 		SpawnInfoHint )
	AddDeathCallback( "npc_titan", 					EmptyDeathCallback ) // so death info gets sent to client

	// Arc Cannon Targets
	foreach ( classname, val in ArcCannonTargetClassnames )
	{
		AddSpawnCallback( classname, AddToArcCannonTargets )
	}

	foreach ( classname, val in ProximityTargetClassnames )
	{
		AddSpawnCallback( classname, AddToProximityTargets )
	}
}

void function EmptyDeathCallback( entity _1, var _2 )
{
}


void function SpawnPathTrack( entity node )
{
	if ( node.HasKey( "WaitSignal" ) )
		RegisterSignal( node.kv.WaitSignal )

	if ( node.HasKey( "SendSignal" ) )
		RegisterSignal( node.kv.SendSignal )

	if ( node.HasKey( "WaitFlag" ) )
		FlagInit( expect string( node.kv.WaitFlag ) )

	if ( node.HasKey( "SetFlag" ) )
		FlagInit( expect string( node.kv.SetFlag ) )
}

void function SpawnScriptMover( entity ent )
{
	if ( ent.HasKey( "custom_health" ) )
	{
		//printt( "setting health on " + ent + " to " + ent.kv.custom_health.tointeger() )
		ent.SetHealth( ent.kv.custom_health.tointeger() )
	}
}

void function SpawnInfoHint( entity ent )
{
	Assert( !ent.HasKey( "hotspot" ) || ent.kv.hotspot.tolower() in level.hotspotHints, "info_hint at " + ent.GetOrigin() + " has unknown hotspot hint: " + ent.kv.hotspot.tolower() )
}