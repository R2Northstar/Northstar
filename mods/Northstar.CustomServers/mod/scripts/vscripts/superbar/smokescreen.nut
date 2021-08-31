
global function Smokescreen_Init
global function Smokescreen
global function IsOriginTouchingSmokescreen
global function IsRayTouchingSmokescreen

#if DEV
const bool SMOKESCREEN_DEBUG = false
#endif

global struct SmokescreenStruct
{
	vector origin
	vector angles
	bool fxUseWeaponOrProjectileAngles = false

	float lifetime = 5.0
	int ownerTeam = TEAM_ANY

	asset smokescreenFX = FX_ELECTRIC_SMOKESCREEN
	float fxXYRadius = 230.0 // single fx xy radius used to create nospawn area and block traces
	float fxZRadius = 170.0 // single fx z radius used to create nospawn area and block traces
	string deploySound1p = SFX_SMOKE_DEPLOY_1P
	string deploySound3p = SFX_SMOKE_DEPLOY_3P
	string stopSound1p = ""
	string stopSound3p = ""
	int damageSource = eDamageSourceId.mp_titanability_smoke

	bool blockLOS = true
	bool shouldHibernate = true

	bool isElectric = true
	entity attacker
	entity inflictor
	entity weaponOrProjectile
	float damageDelay = 2.0
	float damageInnerRadius = 320.0
	float damageOuterRadius = 350.0
	float dangerousAreaRadius = -1.0
	int dpsPilot = 30
	int dpsTitan = 2200

	array<vector> fxOffsets
}

struct SmokescreenFXStruct
{
	vector center	// center of all fx positions
	vector mins 	// approx mins of all fx relative to center
	vector maxs 	// approx maxs of all fx relative to center
	float radius	// approx radius of all fx relative to center
	array<vector> fxWorldPositions
	int ownerTeam = TEAM_ANY
}

struct
{
	array<SmokescreenFXStruct> allSmokescreenFX
	table<entity, float> nextSmokeSoundTime
} file

void function Smokescreen_Init()
{
    PrecacheParticleSystem( FX_ELECTRIC_SMOKESCREEN )
    PrecacheParticleSystem( FX_ELECTRIC_SMOKESCREEN_BURN )
    #if MP
    	PrecacheParticleSystem( FX_ELECTRIC_SMOKESCREEN_HEAL )
    #endif
	PrecacheParticleSystem( FX_GRENADE_SMOKESCREEN )

    PrecacheSprite( $"sprites/physbeam.vmt" )
	PrecacheSprite( $"sprites/glow01.vmt" )

#if SERVER
	AddDamageCallbackSourceID( eDamageSourceId.mp_titanability_smoke, TitanElectricSmoke_DamagedPlayerOrNPC )
	AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_grenade_electric_smoke, GrenadeElectricSmoke_DamagedPlayerOrNPC )
#endif
}

void function Smokescreen( SmokescreenStruct smokescreen )
{
	SmokescreenFXStruct fxInfo = Smokescreen_CalculateFXStruct( smokescreen )
	file.allSmokescreenFX.append( fxInfo )

	array<entity> thermiteBurns = GetActiveThermiteBurnsWithinRadius( fxInfo.center, fxInfo.radius )
	foreach ( thermiteBurn in thermiteBurns )
	{
		entity owner = thermiteBurn.GetOwner()

		if ( IsValid( owner ) && owner.GetTeam() != smokescreen.ownerTeam )
			thermiteBurn.Destroy()
	}

	entity traceBlocker

	if ( smokescreen.blockLOS )
		traceBlocker = Smokescreen_CreateTraceBlockerVol( smokescreen, fxInfo )

#if DEV
	if ( SMOKESCREEN_DEBUG )
		DebugDrawCircle( fxInfo.center, <0,0,0>, fxInfo.radius + 240.0, 255, 255, 0, true, smokescreen.lifetime )
#endif
	CreateNoSpawnArea( TEAM_ANY, TEAM_ANY, fxInfo.center, smokescreen.lifetime, fxInfo.radius + 240.0 )

	if ( IsValid( smokescreen.attacker ) && smokescreen.attacker.IsPlayer() )
	{
		EmitSoundAtPositionExceptToPlayer( TEAM_ANY, fxInfo.center, smokescreen.attacker, smokescreen.deploySound3p )
		EmitSoundAtPositionOnlyToPlayer( TEAM_ANY, fxInfo.center, smokescreen.attacker, smokescreen.deploySound1p)
	}
	else
	{
		EmitSoundAtPosition( TEAM_ANY, fxInfo.center, smokescreen.deploySound3p )
	}

	array<entity> fxEntities = SmokescreenFX( smokescreen, fxInfo )
	if ( smokescreen.isElectric )
		thread SmokescreenAffectsEntitiesInArea( smokescreen, fxInfo )
	//thread CreateSmokeSightTrigger( fxInfo.center, smokescreen.ownerTeam, smokescreen.lifetime ) // disabling for now, this should use the calculated radius if reenabled

	thread DestroySmokescreen( smokescreen, smokescreen.lifetime, fxInfo, traceBlocker, fxEntities )
}

SmokescreenFXStruct function Smokescreen_CalculateFXStruct( SmokescreenStruct smokescreen )
{
	SmokescreenFXStruct fxInfo

	foreach ( i, position in smokescreen.fxOffsets )
	{
		//mins
		if ( i == 0 || position.x < fxInfo.mins.x )
			fxInfo.mins = <position.x, fxInfo.mins.y, fxInfo.mins.z>

		if ( i == 0 || position.y < fxInfo.mins.y )
			fxInfo.mins = <fxInfo.mins.x, position.y, fxInfo.mins.z>

		if ( i == 0 || position.z < fxInfo.mins.z )
			fxInfo.mins = <fxInfo.mins.x, fxInfo.mins.y, position.z>

		// maxs
		if ( i == 0 || position.x > fxInfo.maxs.x )
			fxInfo.maxs = <position.x, fxInfo.maxs.y, fxInfo.maxs.z>

		if ( i == 0 || position.y > fxInfo.maxs.y )
			fxInfo.maxs = <fxInfo.maxs.x, position.y, fxInfo.maxs.z>

		if ( i == 0 || position.z > fxInfo.maxs.z )
			fxInfo.maxs = <fxInfo.maxs.x, fxInfo.maxs.y, position.z>
	}

	vector offsetCenter = fxInfo.mins + ( fxInfo.maxs - fxInfo.mins ) * 0.5

	float xyRadius = smokescreen.fxXYRadius * 0.7071
	float zRadius = smokescreen.fxZRadius * 0.7071

	fxInfo.mins = <fxInfo.mins.x - xyRadius, fxInfo.mins.y - xyRadius, fxInfo.mins.z - zRadius> - offsetCenter
	fxInfo.maxs = <fxInfo.maxs.x + xyRadius, fxInfo.maxs.y + xyRadius, fxInfo.maxs.z + zRadius> - offsetCenter

	float radiusSqr
	float singleFXRadius = max( smokescreen.fxXYRadius, smokescreen.fxZRadius )

	vector forward = AnglesToForward( smokescreen.angles )
	vector right = AnglesToRight( smokescreen.angles )
	vector up = AnglesToUp( smokescreen.angles )

	foreach ( i, position in smokescreen.fxOffsets )
	{
		float distanceSqr = DistanceSqr( position, offsetCenter )

		if ( radiusSqr < distanceSqr )
			radiusSqr = distanceSqr

		fxInfo.fxWorldPositions.append( smokescreen.origin + ( position.x * forward ) + ( position.y * right ) + ( position.z * up ) )
	}

	fxInfo.center = smokescreen.origin + ( offsetCenter.x * forward ) + ( offsetCenter.y * right ) + ( offsetCenter.z * up )
	fxInfo.radius = sqrt( radiusSqr ) + singleFXRadius
	fxInfo.ownerTeam = smokescreen.ownerTeam

	return fxInfo
}

void function SmokescreenAffectsEntitiesInArea( SmokescreenStruct smokescreen, SmokescreenFXStruct fxInfo )
{
	float startTime = Time()
	float tickRate = 0.1

	float dpsPilot = smokescreen.dpsPilot * tickRate
	float dpsTitan = smokescreen.dpsTitan * tickRate
	Assert( dpsPilot || dpsTitan > 0, "Electric smokescreen with 0 damage created" )

	entity aiDangerTarget = CreateEntity( "info_target" )
	DispatchSpawn( aiDangerTarget )
	aiDangerTarget.SetOrigin( fxInfo.center )
	SetTeam( aiDangerTarget, smokescreen.ownerTeam )

	float dangerousAreaRadius = smokescreen.damageOuterRadius
	if ( smokescreen.dangerousAreaRadius != -1.0 )
		dangerousAreaRadius = smokescreen.dangerousAreaRadius

	AI_CreateDangerousArea_Static( aiDangerTarget, smokescreen.weaponOrProjectile, dangerousAreaRadius, TEAM_INVALID, true, true, fxInfo.center )

	OnThreadEnd(
		function () : ( aiDangerTarget )
		{
			aiDangerTarget.Destroy()
		}
	)

	wait smokescreen.damageDelay

	while ( Time() - startTime <= smokescreen.lifetime )
	{
#if DEV
		if ( SMOKESCREEN_DEBUG )
		{
			DebugDrawCircle( fxInfo.center, <0,0,0>, smokescreen.damageInnerRadius, 255, 0, 0, true, tickRate )
			DebugDrawCircle( fxInfo.center, <0,0,0>, smokescreen.damageOuterRadius, 255, 0, 0, true, tickRate )
		}
#endif

		RadiusDamage(
			fxInfo.center,															// center
			smokescreen.attacker,													// attacker
			smokescreen.inflictor,													// inflictor
			dpsPilot,																// damage
			dpsTitan,																// damageHeavyArmor
			smokescreen.damageInnerRadius,											// innerRadius
			smokescreen.damageOuterRadius,											// outerRadius
			SF_ENVEXPLOSION_MASK_BRUSHONLY,	// flags
			0.0,																	// distanceFromAttacker
			0.0,																	// explosionForce
			DF_ELECTRICAL | DF_NO_HITBEEP,											// scriptDamageFlags
			smokescreen.damageSource )												// scriptDamageSourceIdentifier

			wait tickRate
	}
}

entity function Smokescreen_CreateTraceBlockerVol( SmokescreenStruct smokescreen, SmokescreenFXStruct fxInfo )
{
	entity traceBlockerVol = CreateEntity( "trace_volume" )
	traceBlockerVol.kv.targetname = UniqueString( "smokescreen_traceblocker_vol" )
	traceBlockerVol.kv.origin = fxInfo.center
	traceBlockerVol.kv.angles = smokescreen.angles
	DispatchSpawn( traceBlockerVol )
	traceBlockerVol.SetBox( fxInfo.mins * 0.9, fxInfo.maxs * 0.9 )

#if DEV
	if ( SMOKESCREEN_DEBUG )
		DrawAngledBox( fxInfo.center, smokescreen.angles, fxInfo.mins, fxInfo.maxs, 255, 0, 0, true, smokescreen.lifetime - 0.6 )
#endif

	return traceBlockerVol
}

array<entity> function SmokescreenFX( SmokescreenStruct smokescreen, SmokescreenFXStruct fxInfo )
{
	array<entity> fxEntities

	foreach ( position in fxInfo.fxWorldPositions )
	{
#if DEV
		if ( SMOKESCREEN_DEBUG )
			DebugDrawCircle( position, <0.0, 0.0, 0.0>, smokescreen.fxXYRadius, 0, 0, 255, true, smokescreen.lifetime )
#endif
		int fxID = GetParticleSystemIndex( smokescreen.smokescreenFX )
		vector angles = smokescreen.fxUseWeaponOrProjectileAngles ? smokescreen.weaponOrProjectile.GetAngles() : <0.0, 0.0, 0.0>
		entity fxEnt = StartParticleEffectInWorld_ReturnEntity( fxID, position, angles )
		float fxLife = smokescreen.lifetime

		EffectSetControlPointVector( fxEnt, 1, <fxLife, 0.0, 0.0> )

		if ( !smokescreen.shouldHibernate )
			fxEnt.DisableHibernation()

		fxEntities.append( fxEnt )
	}

	return fxEntities
}

void function DestroySmokescreen( SmokescreenStruct smokescreen, float lifetime, SmokescreenFXStruct fxInfo, entity traceBlocker, array<entity> fxEntities )
{
	float timeToWait = 0.0

	timeToWait = max( lifetime - 0.5, 0.0 )

	wait( timeToWait )
	if ( IsValid( traceBlocker ) )
		traceBlocker.Destroy()
	file.allSmokescreenFX.fastremovebyvalue( fxInfo )

	StopSoundAtPosition( fxInfo.center, smokescreen.deploySound1p )
	StopSoundAtPosition( fxInfo.center, smokescreen.deploySound3p )

	if ( IsValid( smokescreen.attacker ) && smokescreen.attacker.IsPlayer() )
	{
		if ( smokescreen.stopSound3p != "" )
			EmitSoundAtPositionExceptToPlayer( TEAM_ANY, fxInfo.center, smokescreen.attacker, smokescreen.stopSound3p )

		if ( smokescreen.stopSound1p != "" )
			EmitSoundAtPositionOnlyToPlayer( TEAM_ANY, fxInfo.center, smokescreen.attacker, smokescreen.stopSound1p)
	}
	else
	{
		if ( smokescreen.stopSound3p != "" )
			EmitSoundAtPosition( TEAM_ANY, fxInfo.center, smokescreen.stopSound3p )
	}

	timeToWait = max( ( lifetime + 0.1 ) - timeToWait, 0.0 )
	wait( timeToWait )

	foreach ( fxEnt in fxEntities )
	{
		if ( IsValid( fxEnt ) )
			fxEnt.Destroy()
	}
}

bool function IsOriginTouchingSmokescreen( vector origin, int teamToIgnore = TEAM_UNASSIGNED )
{
	foreach ( fxInfo in file.allSmokescreenFX )
	{
		if ( teamToIgnore == fxInfo.ownerTeam )
			continue

		if ( DistanceSqr( origin, fxInfo.center ) < fxInfo.radius * fxInfo.radius )
			return true
	}

	return false
}

bool function IsRayTouchingSmokescreen( vector rayStart, vector rayEnd, int teamToIgnore = TEAM_UNASSIGNED )
{
	foreach ( fxInfo in file.allSmokescreenFX )
	{
		if ( teamToIgnore == fxInfo.ownerTeam )
			continue

		if ( IntersectRayWithSphere( rayStart, rayEnd, fxInfo.center, fxInfo.radius ).result )
			return true
	}

	return false
}

#if SERVER
void function TitanElectricSmoke_DamagedPlayerOrNPC( entity ent, var damageInfo )
{
	if ( !IsAlive( ent ) )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( ent.GetTeam() == attacker.GetTeam() )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

	PlayDamageSounds( ent, attacker, ELECTRIC_SMOKESCREEN_SFX_DAMAGE_TITAN_1P, ELECTRIC_SMOKESCREEN_SFX_DAMAGE_TITAN_3P, ELECTRIC_SMOKESCREEN_SFX_DAMAGE_PILOT_1P, ELECTRIC_SMOKESCREEN_SFX_DAMAGE_PILOT_3P )
}

void function GrenadeElectricSmoke_DamagedPlayerOrNPC( entity ent, var damageInfo )
{
	if ( !IsAlive( ent ) )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )

	PlayDamageSounds( ent, attacker, ELECTRIC_SMOKE_GRENADE_SFX_DAMAGE_TITAN_1P, ELECTRIC_SMOKE_GRENADE_SFX_DAMAGE_TITAN_3P, ELECTRIC_SMOKE_GRENADE_SFX_DAMAGE_PILOT_1P, ELECTRIC_SMOKE_GRENADE_SFX_DAMAGE_PILOT_3P )
}

void function PlayDamageSounds( entity ent, entity attacker, string titan1P_SFX, string titan3P_SFX, string pilot1P_SFX, string pilot3P_SFX )
{
	float currentTime = Time()

	if ( !( ent in file.nextSmokeSoundTime ) )
	{
		if ( ent.IsPlayer() )
			file.nextSmokeSoundTime[ ent ] <- currentTime
		else
			file.nextSmokeSoundTime[ ent ] <- currentTime + RandomFloat( 0.5 )
	}

	if ( file.nextSmokeSoundTime[ ent ] <= currentTime )
	{
		if ( ent.IsPlayer() )
		{
			if ( ent.IsTitan() )
			{
				EmitSoundOnEntityExceptToPlayer( ent, ent, titan3P_SFX )
				EmitSoundOnEntityOnlyToPlayer( ent, ent, titan1P_SFX )
				file.nextSmokeSoundTime[ ent ] = currentTime + RandomFloatRange( 0.75, 1.25 )
			}
			else
			{
				EmitSoundOnEntityExceptToPlayer( ent, ent, pilot3P_SFX )
				EmitSoundOnEntityOnlyToPlayer( ent, ent, pilot1P_SFX )
			}

			if ( IsValid( attacker ) && attacker.IsPlayer() )
				EmitSoundOnEntityOnlyToPlayer( attacker, attacker, "Player.Hitbeep" )
		}
		else
		{
			if ( ent.IsTitan() )
				EmitSoundOnEntity( ent, titan3P_SFX )
			else if ( IsHumanSized( ent ) )
				EmitSoundOnEntity( ent, pilot3P_SFX )
		}

		file.nextSmokeSoundTime[ ent ] = currentTime + RandomFloatRange( 0.75, 1.25 )
	}
}
#endif