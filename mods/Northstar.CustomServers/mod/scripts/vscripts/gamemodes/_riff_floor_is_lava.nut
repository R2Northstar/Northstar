global function RiffFloorIsLava_Init

void function RiffFloorIsLava_Init()
{
	AddCallback_OnPlayerRespawned( FloorIsLava_PlayerRespawned )
	
	AddSpawnCallback( "env_fog_controller", InitLavaFogController )
	AddCallback_EntitiesDidLoad( CreateCustomSpawns )
	AddSpawnpointValidationRule( VerifyFloorIsLavaSpawnpoint )
}

bool function VerifyFloorIsLavaSpawnpoint( entity spawnpoint, int team )
{
	return spawnpoint.GetOrigin().z > GetLethalFogTop()
}

void function InitLavaFogController( entity fogController )
{
	fogController.kv.fogztop = GetVisibleFogTop()
	fogController.kv.fogzbottom = GetVisibleFogBottom()
	fogController.kv.foghalfdisttop = "60000"
	fogController.kv.foghalfdistbottom = "200"
	fogController.kv.fogdistoffset = "0"
	fogController.kv.fogdensity = ".85"

	fogController.kv.forceontosky = true
	//fogController.kv.foghalfdisttop = "10000"
}

void function CreateCustomSpawns()
{
	thread CreateCustomSpawns_Threaded()
}

void function CreateCustomSpawns_Threaded()
{
	WaitEndFrame() // wait for spawns to clear
	
	float raycastTop = GetLethalFogTop() + 2500.0
	array< vector > raycastPositions
	foreach ( entity hardpoint in GetEntArrayByClass_Expensive( "info_hardpoint" ) )
	{
		if ( !hardpoint.HasKey( "hardpointGroup" ) )
			continue
			
		//if ( hardpoint.kv.hardpointGroup != "A" && hardpoint.kv.hardpointGroup != "B" && hardpoint.kv.hardpointGroup != "C" )
		if ( hardpoint.kv.hardpointGroup != "B" ) // roughly map center
			continue
			
		vector pos = hardpoint.GetOrigin()
		for ( int x = -2000; x < 2000; x += 200 )
			for ( int y = -2000; y < 2000; y += 200 )
				raycastPositions.append( < x, y, raycastTop > )
	}
	
	int validSpawnsCreated = 0
	foreach ( vector raycastPos in raycastPositions )
	{
		//vector hardpoint = validHardpoints[ RandomInt( validHardpoints.len() ) ].GetOrigin()
		//float a = RandomFloat( 1 ) * 2 * PI
		//float r = 1000.0 * sqrt( RandomFloat( 1 ) )
		//
		//vector castStart = < hardpoint.x + r * cos( a ), hardpoint.y + r * sin( a ),  >
		//vector castEnd = < hardpoint.x + r * cos( a ), hardpoint.y + r * sin( a ), GetLethalFogBottom() >
		
		TraceResults trace = TraceLine( raycastPos, < raycastPos.x, raycastPos.y, GetLethalFogBottom() >, [], TRACE_MASK_SOLID, TRACE_COLLISION_GROUP_NONE ) // should only hit world
		print( "raycast: " + trace.endPos )
		if ( trace.endPos.z >= GetLethalFogTop() )
		{
			print( "creating floor is lava spawn at " + trace.endPos )
			validSpawnsCreated++
		
			// valid spot, create a spawn
			entity spawnpoint = CreateEntity( "info_spawnpoint_human" )
			spawnpoint.SetOrigin( trace.endPos )
			spawnpoint.kv.ignoreGamemode = 1
			DispatchSpawn( spawnpoint )
		}
	}
}

void function FloorIsLava_PlayerRespawned( entity player )
{
	thread FloorIsLava_ThinkForPlayer( player )
}

void function FloorIsLava_ThinkForPlayer( entity player )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	
	float lastHeight
	
	while ( true )
	{
		WaitFrame()
		
		float height = player.GetOrigin().z
		if ( height < GetLethalFogTop() )
		{
			// do damage
			float damageMultiplier
			if ( player.IsTitan() )
				damageMultiplier = 0.0025
			else
				damageMultiplier = 0.05
				
			// scale damage by time spent in fog and depth
			player.TakeDamage( player.GetMaxHealth() * GraphCapped( ( GetLethalFogTop() - height ) / ( GetLethalFogTop() - GetLethalFogBottom() ), 0.0, 1.0, 0.2, 1.0 ) * damageMultiplier, null, null, { damageSourceId = eDamageSourceId.floor_is_lava } )
		
			wait 0.1
		}
		
		lastHeight = height
	}
}