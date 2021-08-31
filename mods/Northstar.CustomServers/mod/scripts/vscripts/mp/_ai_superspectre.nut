untyped

global function AiSuperspectre_Init

global function SuperSpectre_OnGroundSlamImpact
global function SuperSpectre_OnGroundLandImpact
global function SuperSpectreThink
global function SuperSpectreOnLeeched
global function SuperSpectre_WarpFall
global function CreateExplosionInflictor
global function FragDroneDeplyAnimation
global function ForceTickLaunch

global function Reaper_LaunchFragDrone_Think
global function ReaperMinionLauncherThink

//==============================================================
// AI Super Spectre
//
// Super Spectre keeps an array of the minions it spawned.
// Each of those minions has a reference back to it's "master."
//==============================================================
const FRAG_DRONE_BATCH_COUNT				= 10
const FRAG_DRONE_IN_FRONT_COUNT				= 2
const FRAG_DRONE_MIN_LAUNCH_COUNT			= 4
const FRAG_DRONE_LAUNCH_INTIAL_DELAY_MIN	= 10
const FRAG_DRONE_LAUNCH_INTIAL_DELAY_MAX	= 20
const FRAG_DRONE_LAUNCH_INTERVAL			= 40
const SPAWN_ENEMY_TOO_CLOSE_RANGE_SQR		= 1048576 	// Don't spawn guys if the target enemy is closer than this range (1024^2).
const SPAWN_HIDDEN_ENEMY_WITHIN_RANGE_SQR	= 1048576 	// If the enemy can't bee seen, and they are within in this range (1024^2), spawn dudes to find him.
const SPAWN_ENEMY_ABOVE_HEIGHT  			= 128		// If the enemy is at least this high up, then spawn dudes to find him.
const SPAWN_FUSE_TIME						= 2.0	  	// How long after being fired before the spawner explodes and spawns a spectre.
const SPAWN_PROJECTILE_AIR_TIME				= 3.0    	// How long the spawn project will be in the air before hitting the ground.
const SPECTRE_EXPLOSION_DMG_MULTIPLIER		= 1.2 		// +20%
const DEV_DEBUG_PRINTS						= false

struct
{
	int activeMinions_GlobalArrayIdx = -1
} file

function AiSuperspectre_Init()
{
	PrecacheParticleSystem( $"P_sup_spectre_death" )
	PrecacheParticleSystem( $"P_sup_spectre_death_nuke" )
	PrecacheParticleSystem( $"P_xo_damage_fire_2" )
	PrecacheParticleSystem( $"P_sup_spec_dam_vent_1" )
	PrecacheParticleSystem( $"P_sup_spec_dam_vent_2" )
	PrecacheParticleSystem( $"P_sup_spectre_dam_1" )
	PrecacheParticleSystem( $"P_sup_spectre_dam_2" )
	PrecacheParticleSystem( $"drone_dam_smoke_2" )
	PrecacheParticleSystem( $"P_wpn_muzzleflash_sspectre" )

	PrecacheImpactEffectTable( "superSpectre_groundSlam_impact" )
	PrecacheImpactEffectTable( "superSpectre_megajump_land" )

	RegisterSignal( "SuperSpectre_OnGroundSlamImpact" )
	RegisterSignal( "SuperSpectre_OnGroundLandImpact" )
	RegisterSignal( "SuperSpectreThinkRunning" )
	RegisterSignal( "OnNukeBreakingDamage" ) // enough damage to break out or skip nuke
	RegisterSignal( "death_explosion" )
	RegisterSignal( "WarpfallComplete" )
	RegisterSignal( "BeginLaunchAttack" )

	AddDeathCallback( "npc_super_spectre", SuperSpectreDeath )
	AddDamageCallback( "npc_super_spectre", SuperSpectre_OnDamage )
	//AddPostDamageCallback( "npc_super_spectre", SuperSpectre_PostDamage )

	file.activeMinions_GlobalArrayIdx = CreateScriptManagedEntArray()
}

void function SuperSpectre_OnDamage( entity npc, var damageInfo )
{
	int damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	if ( damageSourceId == eDamageSourceId.suicideSpectreAoE )
	{
		// super spectre takes reduced damage from suicide spectres
		DamageInfo_ScaleDamage( damageInfo, 0.666 )
	}
}

void function SuperSpectre_PostDamage( entity npc, var damageInfo )
{
	float switchRatio = 0.33
	float ratio = HealthRatio( npc )
	if ( ratio < switchRatio )
		return
	float newRatio = ( npc.GetHealth() - DamageInfo_GetDamage( damageInfo ) ) / npc.GetMaxHealth()
	if ( newRatio >= switchRatio )
		return

	// destroy body groups
	int bodygroup
	bodygroup = npc.FindBodyGroup( "lowerbody" )
	npc.SetBodygroup( bodygroup, 1 )
	bodygroup = npc.FindBodyGroup( "upperbody" )
	npc.SetBodygroup( bodygroup, 1 )
}

void function SuperSpectreDeath( entity npc, var damageInfo )
{
	thread DoSuperSpectreDeath( npc, damageInfo )
}

void function SuperSpectreNukes( entity npc, entity attacker )
{
	npc.EndSignal( "OnDestroy" )
	vector origin = npc.GetWorldSpaceCenter()
	EmitSoundAtPosition( npc.GetTeam(), origin, "ai_reaper_nukedestruct_explo_3p" )
	PlayFX( $"P_sup_spectre_death_nuke", origin, npc.GetAngles() )

	thread SuperSpectreNukeDamage( npc.GetTeam(), origin, attacker )
	WaitFrame() // so effect has time to grow and cover the swap to gibs
	npc.Gib( <0,0,100> )
}

void function DoSuperSpectreDeath( entity npc, var damageInfo )
{
	// destroyed?
	if ( !IsValid( npc ) )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )

	const int SUPER_SPECTRE_NUKE_DEATH_THRESHOLD = 300

	bool giveBattery = ( npc.ai.shouldDropBattery && IsSingleplayer() )

	if ( !ShouldNukeOnDeath( npc ) || !npc.IsOnGround() || !npc.IsInterruptable() || DamageInfo_GetDamage( damageInfo ) > SUPER_SPECTRE_NUKE_DEATH_THRESHOLD || ( IsValid( attacker ) && attacker.IsTitan() ) )
	{
		// just boom
		vector origin = npc.GetWorldSpaceCenter()
		EmitSoundAtPosition( npc.GetTeam(), origin, "ai_reaper_explo_3p" )
		npc.Gib( DamageInfo_GetDamageForce( damageInfo ) )
		if ( giveBattery )
			SpawnTitanBatteryOnDeath( npc, null )

		return
	}

	npc.ai.killShotSound = false
	npc.EndSignal( "OnDestroy" )

	entity nukeFXInfoTarget = CreateEntity( "info_target" )
	nukeFXInfoTarget.kv.spawnflags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT
	DispatchSpawn( nukeFXInfoTarget )

	nukeFXInfoTarget.SetParent( npc, "HIJACK" )

	EmitSoundOnEntity( nukeFXInfoTarget, "ai_reaper_nukedestruct_warmup_3p" )

	AI_CreateDangerousArea_DamageDef( damagedef_reaper_nuke, nukeFXInfoTarget, TEAM_INVALID, true, true )

	OnThreadEnd(
	function() : ( nukeFXInfoTarget, npc, attacker, giveBattery )
		{
			if ( IsValid( nukeFXInfoTarget ) )
			{
				StopSoundOnEntity( nukeFXInfoTarget, "ai_reaper_nukedestruct_warmup_3p" )
				nukeFXInfoTarget.Destroy()
			}


			if ( IsValid( npc ) )
			{
				thread SuperSpectreNukes( npc, attacker )
				if ( giveBattery )
				{
					SpawnTitanBatteryOnDeath( npc, null )
				}
			}
		}
	)

	//int bodygroup = npc.FindBodyGroup( "upperbody" )
	//npc.SetBodygroup( bodygroup, 1 )

	// TODO: Add death sound

	WaitSignalOnDeadEnt( npc, "death_explosion" )
}

entity function CreateExplosionInflictor( vector origin )
{
	entity inflictor = CreateEntity( "script_ref" )
	inflictor.SetOrigin( origin )
	inflictor.kv.spawnflags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT
	DispatchSpawn( inflictor )
	return inflictor
}

void function SuperSpectreNukeDamage( int team, vector origin, entity attacker )
{
	// all damage must have an inflictor currently
	entity inflictor = CreateExplosionInflictor( origin )

	OnThreadEnd(
		function() : ( inflictor )
		{
			if ( IsValid( inflictor ) )
				inflictor.Destroy()
		}
	)

	int explosions 				= 8
	float time 					= 1.0

	for ( int i = 0; i < explosions; i++ )
	{
		entity explosionOwner
		if ( IsValid( attacker ) )
			explosionOwner = attacker
		else
			explosionOwner = GetTeamEnt( team )

		RadiusDamage_DamageDefSimple(
			damagedef_reaper_nuke,
			origin,								// origin
			explosionOwner,						// owner
			inflictor,							// inflictor
			0 )									// dist from attacker

		wait RandomFloatRange( 0.01, 0.21 )
	}
}

void function SuperSpectre_OnGroundLandImpact( entity npc )
{
	PlayImpactFXTable( npc.GetOrigin(), npc, "superSpectre_megajump_land", SF_ENVEXPLOSION_INCLUDE_ENTITIES )
}


void function SuperSpectre_OnGroundSlamImpact( entity npc )
{
	PlayGroundSlamFX( npc )
}


function PlayGroundSlamFX( entity npc )
{
	int attachment = npc.LookupAttachment( "muzzle_flash" )
	vector origin = 	npc.GetAttachmentOrigin( attachment )
	PlayImpactFXTable( origin, npc, "superSpectre_groundSlam_impact", SF_ENVEXPLOSION_INCLUDE_ENTITIES )
}


bool function EnemyWithinRangeSqr( entity npc, entity enemy, float range )
{
	vector pos		= npc.GetOrigin()
	vector enemyPos = enemy.GetOrigin()
	float distance 	= DistanceSqr( pos, enemyPos )

	return distance <= range
}

bool function ShouldLaunchFragDrones( entity npc, int activeMinions_EntArrayID )
{
//	printt( "active " + GetScriptManagedEntArrayLen( activeMinions_EntArrayID ) )
	if ( !npc.ai.superSpectreEnableFragDrones )
		return false

	// check global minions
	if ( GetScriptManagedEntArrayLen( file.activeMinions_GlobalArrayIdx ) > 5 )
		return false

	// only launch if all minions are dead
	if ( GetScriptManagedEntArrayLen( activeMinions_EntArrayID ) > 5 )
		return false

	entity enemy = npc.GetEnemy()

	// Only spawn dudes if we have an enemy
	if ( !IsValid( enemy ) )
		return false

	vector ornull lkp = npc.LastKnownPosition( enemy )
	if ( lkp == null )
		return false

	expect vector( lkp )

	// Don't spawn if the enemy is too far away
	if ( Distance( npc.GetOrigin(), lkp ) > 1500 )
		return false

	return true
}

function SuperSpectreOnLeeched( npc, player )
{
	local maxHealth = npc.GetMaxHealth()
	npc.SetHealth( maxHealth * 0.5 )	 // refill to half health
}

function SuperSpectreThink( entity npc )
{
	npc.EndSignal( "OnDeath" )

	int team = npc.GetTeam()

	int activeMinions_EntArrayID = CreateScriptManagedEntArray()
	if ( npc.kv.squadname == "" )
		SetSquad( npc, UniqueString( "super_spec_squad" ) )

	npc.ai.superSpectreEnableFragDrones = expect int( npc.Dev_GetAISettingByKeyField( "enable_frag_drones" ) ) == 1

	OnThreadEnd (
		function() : ( activeMinions_EntArrayID, npc, team )
		{
			entity owner
			if ( IsValid( npc ) )
				owner = npc

			foreach ( minion in GetScriptManagedEntArray( activeMinions_EntArrayID ) )
			{
				// Self destruct the suicide spectres if applicable
				if ( minion.GetClassName() != "npc_frag_drone" )
					continue

				if ( minion.ai.suicideSpectreExplodingAttacker == null )
					minion.TakeDamage( minion.GetHealth(), owner, owner, { scriptType = DF_DOOMED_HEALTH_LOSS, damageSourceId = eDamageSourceId.mp_weapon_super_spectre } )
			}
		}
	)

	wait RandomFloatRange( FRAG_DRONE_LAUNCH_INTIAL_DELAY_MIN, FRAG_DRONE_LAUNCH_INTIAL_DELAY_MAX )

	npc.kv.doScheduleChangeSignal = true

	while ( 1 )
	{
		if ( ShouldLaunchFragDrones( npc, activeMinions_EntArrayID ) )
			waitthread SuperSpectre_LaunchFragDrone_Think( npc, activeMinions_EntArrayID )

		wait FRAG_DRONE_LAUNCH_INTERVAL
	}
}

void function SuperSpectre_LaunchFragDrone_Think( entity npc, int activeMinions_EntArrayID )
{
	array<vector> targetOrigins = GetFragDroneTargetOrigins( npc, npc.GetOrigin(), 200, 2000, 64, FRAG_DRONE_BATCH_COUNT )

	if ( targetOrigins.len() < FRAG_DRONE_MIN_LAUNCH_COUNT )
		return

	npc.RequestSpecialRangeAttack( targetOrigins.len() + FRAG_DRONE_IN_FRONT_COUNT )

	// wait for first attack signal
	npc.WaitSignal( "OnSpecialAttack" )
	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnScheduleChange" ) // kv.doScheduleChangeSignal = true

	// drop a few in front of enemy view
	entity enemy = npc.GetEnemy()
	if ( enemy )
	{
		vector searchOrigin = enemy.GetOrigin() + ( enemy.GetForwardVector() * 400 )
		array<vector> frontOfEnemyOrigins = GetFragDroneTargetOrigins( npc, searchOrigin, 0, 500, 16, FRAG_DRONE_IN_FRONT_COUNT )

		foreach ( targetOrigin in frontOfEnemyOrigins )
		{
			thread LaunchSpawnerProjectile( npc, targetOrigin, activeMinions_EntArrayID )
			//DebugDrawBox( targetOrigin, Vector(-10, -10, 0), Vector(10, 10, 10), 255, 0, 0, 255, 5 )
			npc.WaitSignal( "OnSpecialAttack" )
		}
	}

	// drop rest in pre-searched spots
	foreach ( targetOrigin in targetOrigins )
	{
		thread LaunchSpawnerProjectile( npc, targetOrigin, activeMinions_EntArrayID )
		npc.WaitSignal( "OnSpecialAttack" )
	}
}

void function ReaperMinionLauncherThink( entity reaper )
{
	if ( GetBugReproNum() != 221936 )
		reaper.kv.squadname = ""

	StationaryAIPosition launchPos = GetClosestAvailableStationaryPosition( reaper.GetOrigin(), 8000, eStationaryAIPositionTypes.LAUNCHER_REAPER )
	launchPos.inUse = true

	OnThreadEnd(
		function () : ( launchPos )
		{
			launchPos.inUse = false
		}
	)

	reaper.EndSignal( "OnDeath" )
	reaper.AssaultSetFightRadius( 96 )
	reaper.AssaultSetGoalRadius( reaper.GetMinGoalRadius() )

	while ( true )
	{
		WaitFrame()

		if ( Distance( reaper.GetOrigin(), launchPos.origin ) > 96 )
		{
			printt( reaper," ASSAULT:", launchPos.origin, Distance( reaper.GetOrigin(), launchPos.origin ) )
			reaper.AssaultPoint( launchPos.origin )
			table signalData = WaitSignal( reaper, "OnFinishedAssault", "OnEnterGoalRadius", "OnFailedToPath" )
			printt( reaper," END ASSAULT:", launchPos.origin, signalData.signal )
			if ( signalData.signal == "OnFailedToPath" )
				continue
		}

		printt( reaper," LAUNCH:", launchPos.origin )
		waitthread Reaper_LaunchFragDrone_Think( reaper, "npc_frag_drone_fd" )
		printt( reaper," END LAUNCH:", launchPos.origin )
		while ( GetScriptManagedEntArrayLen( reaper.ai.activeMinionEntArrayID ) > 2 )
			WaitFrame()
	}
}

void function Reaper_LaunchFragDrone_Think( entity reaper, string fragDroneSettings = "" )
{
	if ( reaper.ai.activeMinionEntArrayID < 0 )
		reaper.ai.activeMinionEntArrayID = CreateScriptManagedEntArray()

	int activeMinions_EntArrayID = reaper.ai.activeMinionEntArrayID

	const int MAX_TICKS = 4

	int currentMinions = GetScriptManagedEntArray( reaper.ai.activeMinionEntArrayID ).len()
	int minionsToSpawn = MAX_TICKS - currentMinions

	if ( minionsToSpawn <= 0 )
		return

	array<vector> targetOrigins = GetFragDroneTargetOrigins( reaper, reaper.GetOrigin(), 200, 2000, 64, MAX_TICKS )

	if ( targetOrigins.len() < minionsToSpawn )
		return

	if ( IsAlive( reaper.GetEnemy() ) && ( reaper.GetEnemy().IsPlayer() || reaper.GetEnemy().IsNPC() ) && reaper.CanSee( reaper.GetEnemy() ) )
		return

	OnThreadEnd(
		function() : ( reaper )
		{
			if ( IsValid( reaper ) )
			{
				reaper.Anim_Stop()
			}
		}
	)

	printt( reaper, "   BEGIN LAUNCHING: ", minionsToSpawn, reaper.GetCurScheduleName() )

	reaper.EndSignal( "OnDeath" )

	while ( !reaper.IsInterruptable() )
		WaitFrame()

	waitthread PlayAnim( reaper, "sspec_idle_to_speclaunch" )

	while ( minionsToSpawn > 0 )
	{
		// drop rest in pre-searched spots
		foreach ( targetOrigin in targetOrigins )
		{
			if ( minionsToSpawn <= 0 )
				break

			printt( reaper, "    LAUNCHING: ", minionsToSpawn )
			thread LaunchSpawnerProjectile( reaper, targetOrigin, activeMinions_EntArrayID, fragDroneSettings )
			minionsToSpawn--

			if ( minionsToSpawn <= 0 )
				break

			waitthread PlayAnim( reaper, "sspec_speclaunch_fire" )
		}
	}

	waitthread PlayAnim( reaper, "sspec_speclaunch_to_idle" )
}



array<vector> function GetFragDroneTargetOrigins( entity npc, vector origin, float minRadius, float maxRadius, int randomCount, int desiredCount )
{
	array<vector> targetOrigins
/*
	vector angles = npc.GetAngles()
	angles.x = 0
	angles.z = 0

	vector origin = npc.GetOrigin() + Vector( 0, 0, 1 )
	float arc = 0
	float dist = 200

	for ( ;; )
	{
		if ( dist > 2000 || targetOrigins.len() >= 12 )
			break

		angles = AnglesCompose( angles, <0,arc,0> )
		arc += 35
		arc %= 360
		dist += 200

		vector ornull tryOrigin = TryCreateFragDroneLaunchTrajectory( npc, origin, angles, dist )
		if ( tryOrigin == null )
			continue
		expect vector( tryOrigin )
		targetOrigins.append( tryOrigin )
	}
*/
	float traceFrac = TraceLineSimple( origin, origin + <0, 0, 200>, npc )
	if ( traceFrac < 1 )
		return targetOrigins;

	array< vector > randomSpots = NavMesh_RandomPositions_LargeArea( origin, HULL_HUMAN, randomCount, minRadius, maxRadius )

	int numFragDrones = 0
	foreach( spot in randomSpots )
	{
		targetOrigins.append( spot )
		numFragDrones++
		if ( numFragDrones == desiredCount )
			break
	}

	return targetOrigins
}

vector ornull function TryCreateFragDroneLaunchTrajectory( entity npc, vector origin, vector angles, float dist )
{
	vector forward = AnglesToForward( angles )
	vector targetOrigin = origin + forward * dist

	vector ornull clampedPos = NavMesh_ClampPointForHullWithExtents( targetOrigin, HULL_HUMAN, < 300, 300, 100 > )

	if ( clampedPos == null )
			return null

	vector vel = GetVelocityForDestOverTime( origin, expect vector( clampedPos ), SPAWN_PROJECTILE_AIR_TIME )
	float traceFrac = TraceLineSimple( origin, origin + vel, npc )
	//DebugDrawLine( origin, origin + vel, 255, 0, 0, true, 5.0 )
	if ( traceFrac >= 0.5 )
		return clampedPos
	return null
}

void function FragDroneDeplyAnimation( entity drone, float minDelay = 0.5, float maxDelay = 2.5 )
{
	Assert( !drone.ai.fragDroneArmed, "Armed drone was told to play can animation. Spawn drone with CreateFragDroneCan()" )
	drone.EndSignal( "OnDeath" )

	drone.SetInvulnerable()
	OnThreadEnd(
		function() : ( drone )
		{
			drone.ClearInvulnerable()
		}
	)

	drone.Anim_ScriptedPlay( "sd_closed_idle" )
	wait RandomFloatRange( minDelay, maxDelay )

	#if MP
	while ( !drone.IsInterruptable() )
	{
		WaitFrame()
	}
	#endif

	drone.Anim_ScriptedPlay( "sd_closed_to_open" )

	// Wait for P_drone_frag_open_flicker FX to play inside sd_closed_to_open
	wait 0.6
}

void function LaunchSpawnerProjectile( entity npc, vector targetOrigin, int activeMinions_EntArrayID, string droneSettings = "" )
{
	//npc.EndSignal( "OnDeath" )

	entity weapon  			= npc.GetOffhandWeapon( 0 )

	if ( !IsValid( weapon ) )
		return

	int id 	   				= npc.LookupAttachment( "launch" )
	vector launchPos		= npc.GetAttachmentOrigin( id )
	int team 				= npc.GetTeam()
	vector launchAngles		= npc.GetAngles()
	string squadname = expect string( npc.kv.squadname )
	vector vel = GetVelocityForDestOverTime( launchPos, targetOrigin, SPAWN_PROJECTILE_AIR_TIME )

//	DebugDrawLine( npc.GetOrigin() + <3,3,3>, launchPos + <3,3,3>, 255, 0, 0, true, 5.0 )
	float armTime = SPAWN_PROJECTILE_AIR_TIME + RandomFloatRange( 1.0, 2.5 )
	entity nade = weapon.FireWeaponGrenade( launchPos, vel, <200,0,0>, armTime, damageTypes.dissolve, damageTypes.explosive, PROJECTILE_NOT_PREDICTED, true, true )

	AddToScriptManagedEntArray( activeMinions_EntArrayID, nade )
	AddToScriptManagedEntArray( file.activeMinions_GlobalArrayIdx, nade )

	nade.SetOwner( npc )
	nade.EndSignal( "OnDestroy" )

	OnThreadEnd(
	function() : ( nade, team, activeMinions_EntArrayID, squadname, droneSettings )
		{
			vector origin = nade.GetOrigin()
			vector angles = nade.GetAngles()

			vector ornull clampedPos = NavMesh_ClampPointForHullWithExtents( origin, HULL_HUMAN, < 100, 100, 100 > )
			if ( clampedPos == null )
				return

			entity drone = CreateFragDroneCan( team, expect vector( clampedPos ), < 0, angles.y, 0 > )
			SetSpawnOption_SquadName( drone, squadname )
			if ( droneSettings != "" )
			{
				SetSpawnOption_AISettings( drone, droneSettings )
			}
			drone.kv.spawnflags = SF_NPC_ALLOW_SPAWN_SOLID // clamped to navmesh no need to check solid
			DispatchSpawn( drone )

			thread FragDroneDeplyAnimation( drone )

			AddToScriptManagedEntArray( activeMinions_EntArrayID, drone )
			AddToScriptManagedEntArray( file.activeMinions_GlobalArrayIdx, drone )
		}
	)

	Grenade_Init( nade, weapon )

	EmitSoundOnEntity( npc, "SpectreLauncher_AI_WpnFire" )
	WaitForever()

//	wait SPAWN_PROJECTILE_AIR_TIME + SPAWN_FUSE_TIME
}


// Seriously don't use this unless absolutely necessary!  Used for scripted moment in Reapertown.
// Bypasses all of the tick launch rules and sends a request for launching ticks to code immediately.
void function ForceTickLaunch( entity npc )
{
	SuperSpectre_LaunchFragDrone_Think( npc, file.activeMinions_GlobalArrayIdx )
}


/************************************************************************************************\
########  ########   #######  ########  #######  ######## ##    ## ########  ########
##     ## ##     ## ##     ##    ##    ##     ##    ##     ##  ##  ##     ## ##
##     ## ##     ## ##     ##    ##    ##     ##    ##      ####   ##     ## ##
########  ########  ##     ##    ##    ##     ##    ##       ##    ########  ######
##        ##   ##   ##     ##    ##    ##     ##    ##       ##    ##        ##
##        ##    ##  ##     ##    ##    ##     ##    ##       ##    ##        ##
##        ##     ##  #######     ##     #######     ##       ##    ##        ########
\************************************************************************************************/


function SuperSpectre_WarpFall( entity ai )
{
	ai.EndSignal( "OnDestroy" )

	vector origin = ai.GetOrigin()
	entity mover = CreateOwnedScriptMover( ai )
	ai.SetParent( mover, "", false, 0 )
	ai.Hide()
	ai.SetEfficientMode( true )
	ai.SetInvulnerable()

	WaitFrame() // give AI time to hide before moving

	vector warpPos = origin + < 0, 0, 1000 >
	mover.SetOrigin( warpPos )

	#if GRUNTCHATTER_ENABLED
		GruntChatter_TryIncomingSpawn( ai, origin )
	#endif

	EmitSoundAtPosition( TEAM_UNASSIGNED, origin, "Titan_1P_Warpfall_Start" )

	local e = {}
	e.warpfx <- PlayFX( TURBO_WARP_FX, warpPos + < 0, 0, -104 >, mover.GetAngles() )
	e.smokeFx <- null

	OnThreadEnd(
		function() : ( e, mover, ai )
		{
			if ( IsAlive( ai ) )
			{
				ai.ClearParent()
				ai.SetVelocity( <0,0,0> )
				ai.Signal( "WarpfallComplete" )
			}
			if ( IsValid( e.warpfx ) )
				e.warpfx.Destroy()
			if ( IsValid( e.smokeFx ) )
				e.smokeFx.Destroy()
			if ( IsValid( mover ) )
				mover.Destroy()
		}
	)
	wait 0.5

	EmitSoundAtPosition( TEAM_UNASSIGNED, origin, "Titan_3P_Warpfall_WarpToLanding" )

	wait 0.4

	ai.Show()

	e.smokeFx = PlayFXOnEntity( TURBO_WARP_COMPANY, ai, "", <0.0, 0.0, 152.0> )

	local time = 0.2
	mover.MoveTo( origin, time, 0, 0 )
	wait time

	ai.SetEfficientMode( false )
	ai.ClearInvulnerable()

	e.smokeFx.Destroy()
	PlayFX( $"droppod_impact", origin )

	Explosion_DamageDefSimple(
		damagedef_reaper_fall,
		origin,
		ai,								// attacker
		ai,								// inflictor
		origin )

	wait 0.1
}

bool function ShouldNukeOnDeath( entity ent )
{
	if ( IsMultiplayer() )
		return false

	return ent.Dev_GetAISettingByKeyField( "nuke_on_death" ) == 1
}