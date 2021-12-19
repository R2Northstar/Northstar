global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
	SetupLiveFireMaps()
	
	// worker drone model
	PrecacheModel( $"models/robots/aerial_unmanned_worker/aerial_unmanned_worker.mdl" )
	
	// note: this map has no marvin spawns, have to spawn them using idle nodes
	AddSpawnCallback_ScriptName( "worker_drone_spawn", DeckSpawnWorkerDrone )
	AddSpawnCallback_ScriptName( "marvin_idle_node", DeckSpawnMarvinForIdleNode )
}

void function DeckSpawnWorkerDrone( entity spawnpoint )
{

	entity drone = CreateWorkerDrone( TEAM_UNASSIGNED, spawnpoint.GetOrigin(), spawnpoint.GetAngles() )
	DispatchSpawn( drone )
}

void function DeckSpawnMarvinForIdleNode( entity node )
{
	entity marvin = CreateMarvin( TEAM_UNASSIGNED, node.GetOrigin(), node.GetAngles() )
	DispatchSpawn( marvin )
	
	// doing this because no ai rn
	if ( GetAINScriptVersion() == -1 )
		thread PlayAnim( marvin, node.kv.leveled_animation )
}