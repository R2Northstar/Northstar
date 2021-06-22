untyped

global function Orbitalstrike_Init

global function OrbitalStrike
global function CalculateStrikeDelay

const STRIKE_MODEL = $"models/containers/can_red_soda.mdl"
const ROCKET_START_HEIGHT = 6000
const LASER_START_HEIGHT = 1000 // TODO: Make this taller after making the trace go through sky
const LASER_TIME_LENGTH = 7 // Must match charge length in the weapon
const LASER_DAMAGE = 300
const LASER_DAMAGE_RADIUS = 300
const SPAWN_DELAY = 0.2

table file =
{
	impactEffectTable = null
}


function Orbitalstrike_Init()
{
	PrecacheParticleSystem( $"ar_rocket_strike_small_friend" )
	PrecacheParticleSystem( $"ar_rocket_strike_small_foe" )
	PrecacheParticleSystem( $"ar_rocket_strike_large_friend" )
	PrecacheParticleSystem( $"ar_rocket_strike_large_foe" )
	PrecacheParticleSystem( $"wpn_orbital_beam" )

	//if ( IsServer() )
	//	file.impactEffectTable <- PrecacheImpactEffectTable( GetWeaponInfoFileKeyField_Global( "mp_projectile_orbital_strike", "impact_effect_table" ) )
	#if SERVER
		file.impactEffectTable = PrecacheImpactEffectTable( "orbital_strike" )
	#endif



	RegisterSignal( "TargetDesignated" )
	RegisterSignal( "BeginLaser" )
	RegisterSignal( "MoveLaser" )
	RegisterSignal( "FreezeLaser" )
	RegisterSignal( "EndLaser" )
}


function CalculateStrikeDelay( index, stepCount, duration )
{
	local lastStepDelay = 0
	if ( index )
	{
		local stepFrac = (index - 1) / stepCount.tofloat()
		stepFrac = 1 - (1 - stepFrac) * (1 - stepFrac)
		lastStepDelay = stepFrac * (duration)
	}

	local stepFrac = index / stepCount.tofloat()
	stepFrac = 1 - (1 - stepFrac) * (1 - stepFrac)
	return (stepFrac * (duration)) - lastStepDelay
}


function OrbitalStrike( entity player, vector targetPos, numRockets = 12, float radius = 256.0, float totalTime = 3.0, extraStartDelay = null )
{
	int team = player.GetTeam()
	CreateNoSpawnArea( TEAM_INVALID, TEAM_INVALID, targetPos, totalTime, radius )

	if ( extraStartDelay != null )
		wait extraStartDelay

	// Trace down from max z height until we hit something so we know where rockets should land
	// This makes calling in orbital strike indoors land on the roof like it should, not indoors
	//local downStartPos = Vector( targetPos.x, targetPos.y, 16384 )
	//TraceResults downResult = TraceLine( downStartPos, targetPos, null, (TRACE_MASK_NPCSOLID_BRUSHONLY|TRACE_MASK_WATER), TRACE_COLLISION_GROUP_NONE )
	//DebugDrawLine( downStartPos+ Vector(0,10,0), targetPos + Vector(0,10,0), 255, 255, 255, true, 60 )

	/*
	while ( true ) // retrace because we hit a sky brush from outside the level, not the ground
	{
		if ( !downResult.hitSky )
			break
		printt( "Hit sky" )
		downStartPos = downResult.endPos
		downStartPos.z -= 5
		downResult = TraceLine( downStartPos, targetPos, null, (TRACE_MASK_NPCSOLID_BRUSHONLY|TRACE_MASK_WATER), TRACE_COLLISION_GROUP_NONE )
		DebugDrawLine( downStartPos, downResult.endPos, 0, 255, 0, true, 60.0 )
		DebugDrawLine( downStartPos + Vector(10,0,0), targetPos + Vector(10,0,0), 255, 255, 0, true, 60.0 )
	}
	*/

	/*
	local upEndPos = targetPos + Vector( 0, 0, ROCKET_START_HEIGHT )
	TraceResults upResult = TraceLine( downResult.endPos, upEndPos, null, (TRACE_MASK_NPCSOLID_BRUSHONLY|TRACE_MASK_WATER), TRACE_COLLISION_GROUP_NONE )
	local spawnPos = upResult.endPos

	local rocketPos
	local min = radius * -1
	local max = radius
	local rocket
	*/

	vector rocketOrigin = GetRocketSpawnOrigin( targetPos )

	entity rocket = SpawnRocket( rocketOrigin, Vector( 90, 0, 0 ), player, team ) // First rocket hits center target
	EmitSoundOnEntity( rocket, "weapon_titanmortar_fire" )
	EmitSoundOnEntity( rocket, "weapon_titanmortar_projectile" )

	for ( int i = 1; i < numRockets; i++ )
	{
		wait CalculateStrikeDelay( i, numRockets, totalTime )

		vector offset = Normalize( Vector( RandomFloatRange( -1.0, 1.0 ), RandomFloatRange( -1.0, 1.0 ), 0 ) )
		vector rocketPos = rocketOrigin + ( offset * RandomFloat( radius ) )

		entity rocket = SpawnRocket( rocketPos, Vector( 90, 0, 0 ), player, team )
		EmitSoundOnEntity( rocket, "weapon_titanmortar_fire" )
		EmitSoundOnEntity( rocket, "weapon_titanmortar_projectile" )
	}
}

vector function GetRocketSpawnOrigin( vector point )
{
	vector skyPos = GetSkyOriginAbovePoint( point )
	TraceResults traceResult = TraceLine( skyPos, point, null, (TRACE_MASK_SHOT), TRACE_COLLISION_GROUP_NONE )
	vector rocketOrigin = traceResult.endPos
	rocketOrigin.z += 6000
	if ( rocketOrigin.z > skyPos.z - 1 )
		rocketOrigin.z = skyPos.z - 1
	return rocketOrigin
}

vector function GetSkyOriginAbovePoint( vector point )
{
	vector skyOrigin = Vector( point.x, point.y, MAX_WORLD_COORD )
	vector traceFromPos = Vector( point.x, point.y, point.z )

	while ( true )
	{
		TraceResults traceResult = TraceLine( traceFromPos, skyOrigin, null, (TRACE_MASK_SHOT), TRACE_COLLISION_GROUP_NONE )

		if ( traceResult.hitSky )
		{
			skyOrigin = traceResult.endPos
			break
		}

		traceFromPos = traceResult.endPos
		traceFromPos.z += 1
	}

	return skyOrigin
}

entity function SpawnRocket( vector spawnPos, vector spawnAng, entity owner, int team )
{
	entity rocket = CreateEntity( "rpg_missile" )
	rocket.SetOrigin( spawnPos )
	rocket.SetAngles( spawnAng )
	rocket.SetOwner( owner )
	SetTeam( rocket, team )
	rocket.SetModel( $"models/weapons/bullets/projectile_rocket.mdl" )
	rocket.SetImpactEffectTable( file.impactEffectTable )
	rocket.SetWeaponClassName( "mp_titanweapon_orbital_strike" )
	rocket.kv.damageSourceId = eDamageSourceId.mp_titanweapon_orbital_strike
	DispatchSpawn( rocket )

	return rocket
}
