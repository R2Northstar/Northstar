untyped

global function VehicleDropshipNew_Init

global function InitLeanDropship
global function CreateDropship
global function GetDropshipSquadSize
global function WarpinEffect
global function WarpoutEffect
global function WarpoutEffectFPS
global function WaitForNPCsDeployed
global function CreateNPCSForDropship
global function GuyDeploysOffShip
global function WaittillPlayDeployAnims
global function GetDropshipRopeAttachments
global function DelayDropshipDelete
global function PlayDropshipRampDoorOpenSound
global function PlayWarpFxOnPlayers
global function DefensiveFreePlayers
global function CreateDropshipAnimTable

global function InitDropShipFlightPaths

// _dropship
//
// dropship/passenger setup:
// 1. Create an npc_dropship and target it with a point_template. Give the point_template a name.
// 2. npc_dropship targets starting path_track (see below for path setup info) AND passenger spawning point_template
// 3. passenger spawning point_template points to six passengers that will spawn and rappel at the unload spot
//
// path/unload spot setup:
// 1. create your path out of path_track entities
// 2. to create rappel targets, add six info_targets on the ground around your unload node, name them all the same
// 3. on the node where the dropship will unload, create a key/value pair called "unload" and point it at the name you gave to the rappel target info_targets
//
// spawning in script:
// 1. use GetEnt to get the point_template that targets the dropship
// 2. pass that point_template into DropshipSpawn(), this returns with the dropship ent
// 3. pass the dropship ent into DropshipDropshipFlyPathAndUnload() (thread it off if you want to do stuff right after)
//


const FX_DROPSHIP_THRUSTERS = $"xo_atlas_jet_large"
const FX_GUNSHIP_DAMAGE =  $"veh_gunship_damage_FULL"
const FX_DROPSHIP_DEATH = $"P_veh_exp_crow"

const DROPSHIP_ROPE_ENDPOINT_FX = $"runway_light_blue"
const DROPSHIP_ACL_LIGHT_GREEN_FX = $"acl_light_green"
const DROPSHIP_ACL_LIGHT_RED_FX = $"acl_light_red"
const DROPSHIP_ACL_LIGHT_WHITE_FX = $"acl_light_white"

const ENGAGEMENT_DIST = 1024
const ENGAGEMENT_DIST_SQD = ENGAGEMENT_DIST * ENGAGEMENT_DIST

const DEFAULT_READYANIM_BLENDTIME = 1.0

table file = {
	dropshipAttachments = null
}

function VehicleDropshipNew_Init()
{

	RegisterSignal( "sRampOpen" )
	RegisterSignal( "sRampClose" )

	#if SERVER
		PrecacheParticleSystem( FX_GUNSHIP_CRASH_EXPLOSION_ENTRANCE )
		PrecacheParticleSystem( FX_GUNSHIP_CRASH_EXPLOSION_EXIT )
		PrecacheParticleSystem( FX_DROPSHIP_DEATH )
		AddDeathCallback( "npc_dropship", OnNPCDropshipDeath )
		AddDamageCallback( "npc_dropship", OnDropshipDamaged )
	#endif

	PrecacheParticleSystem( FX_HORNET_DEATH )
	PrecacheParticleSystem( FX_GUNSHIP_DAMAGE )
	PrecacheParticleSystem( FX_DROPSHIP_THRUSTERS )
	PrecacheParticleSystem( DROPSHIP_ROPE_ENDPOINT_FX )
	PrecacheParticleSystem( DROPSHIP_ACL_LIGHT_GREEN_FX )
	PrecacheParticleSystem( DROPSHIP_ACL_LIGHT_RED_FX )
	PrecacheParticleSystem( DROPSHIP_ACL_LIGHT_WHITE_FX )

	level.DROPSHIP_DEFAULT_AIRSPEED <- 750

	PrecacheEntity( "keyframe_rope" )
	PrecacheModel( DROPSHIP_MODEL )

	PrecacheSprite( $"sprites/laserbeam.vmt" )
	PrecacheSprite( $"sprites/glow_05.vmt" )


	//Array of all attachments in the dropship model. Used in DropshipDamageEffects
	local names = []
	names.append( "FRONT_TURRET"      )
	names.append( "BOMB_L"            )
	names.append( "BOMB_R"            )
	names.append( "Spotlight"         )
	names.append( "Light_Red0"        )
	names.append( "Light_Red1"        )
	names.append( "Light_Red2"        )
	names.append( "Light_Red3"        )
	names.append( "HeadlightLeft"     )
	names.append( "RopeAttachLeftA"   )
	names.append( "RopeAttachLeftB"   )
	names.append( "RopeAttachLeftC"   )
	names.append( "L_exhaust_rear_1"  )
	names.append( "L_exhaust_rear_2"  )
	names.append( "L_exhaust_front_1" )
	names.append( "Light_Green0"      )
	names.append( "Light_Green1"      )
	names.append( "Light_Green2"      )
	names.append( "Light_Green3"      )
	names.append( "HeadlightRight"    )
	names.append( "RopeAttachRightA"  )
	names.append( "RopeAttachRightB"  )
	names.append( "RopeAttachRightC"  )
	names.append( "R_exhaust_rear_1"  )
	names.append( "R_exhaust_rear_2"  )
	names.append( "R_exhaust_front_1" )

	file.dropshipAttachments = names

	level.DSAIziplineAnims <- {}
	level.DSAIziplineAnims[ "left" ] <- []
	level.DSAIziplineAnims[ "left" ].append( { idle = "pt_dropship_rider_L_A_idle", attach = "RopeAttachLeftA" } )
	level.DSAIziplineAnims[ "left" ].append( { idle = "pt_dropship_rider_L_C_idle", attach = "RopeAttachLeftC" } )
	level.DSAIziplineAnims[ "left" ].append( { idle = "pt_dropship_rider_L_B_idle", attach = "RopeAttachLeftB" } )

	level.DSAIziplineAnims[ "right" ] <- []
	level.DSAIziplineAnims[ "right" ].append( { idle = "pt_dropship_rider_R_A_idle", attach = "RopeAttachRightA" } )
	level.DSAIziplineAnims[ "right" ].append( { idle = "pt_dropship_rider_R_C_idle", attach = "RopeAttachRightC" } )
	level.DSAIziplineAnims[ "right" ].append( { idle = "pt_dropship_rider_R_B_idle", attach = "RopeAttachRightB" } )

	level.DSAIziplineAnims[ "both" ] <- []
	level.DSAIziplineAnims[ "both" ].append( { idle = "pt_dropship_rider_L_A_idle", attach = "RopeAttachLeftA" } )
	level.DSAIziplineAnims[ "both" ].append( { idle = "pt_dropship_rider_R_A_idle", attach = "RopeAttachRightA" } )
	level.DSAIziplineAnims[ "both" ].append( { idle = "pt_dropship_rider_L_C_idle", attach = "RopeAttachLeftC" } )
	level.DSAIziplineAnims[ "both" ].append( { idle = "pt_dropship_rider_R_B_idle", attach = "RopeAttachRightC" } )
	level.DSAIziplineAnims[ "both" ].append( { idle = "pt_dropship_rider_L_B_idle", attach = "RopeAttachLeftB" } )
	level.DSAIziplineAnims[ "both" ].append( { idle = "pt_dropship_rider_R_B_idle", attach = "RopeAttachRightB" } )
}

function InitLeanDropship( dropship )
{
	if ( dropship.kv.desiredSpeed.tofloat() <= 0 )
	{
		dropship.kv.desiredSpeed = level.DROPSHIP_DEFAULT_AIRSPEED
	}

	//dropship.s.dropFunc <- ShipDropsGuys
}

array<entity> function CreateNPCSForDropship( entity ship, array<entity functionref( int, vector, vector )> spawnFuncs, string side = "both" )
{
	int count = minint( spawnFuncs.len(), level.DSAIziplineAnims[ side ].len() )

	int team = ship.GetTeam()
	string squadName = expect string( ship.kv.squadname )
	vector origin = ship.GetOrigin()
	vector angles = ship.GetAngles()

	array<entity> guys = []

	if ( Flag( "disable_npcs" ) )
		return guys //i.e. empty aray

	local guy

	// this is to maintain sketchy support for just passing an array of 1 spawn function
	entity functionref( int, vector, vector ) spawnFunc = spawnFuncs[0]

	for ( int i = 0; i < count; i++ )
	{
		if ( i < spawnFuncs.len() )
			spawnFunc = spawnFuncs[i]

		entity guy = spawnFunc( team, origin, angles )
		guy.kv.squadname = squadName
		DispatchSpawn( guy )

		if ( !IsAlive( guy ) )
			continue

		guys.append( guy )

		local seat 	= i
		table Table = CreateDropshipAnimTable( ship, side, seat )

		thread GuyDeploysOffShip( guy, Table )
	}

	return guys
}



table function CreateDropshipAnimTable( ship, side, seat )
{
	table Table

	Table.idleAnim			<- level.DSAIziplineAnims[ side ][ seat ].idle
	Table.deployAnim		<- "zipline"
	Table.shipAttach 		<- level.DSAIziplineAnims[ side ][ seat ].attach
	Table.attachIndex 		<- null
	Table.ship 				<- ship
	Table.side				<- side
	Table.blendTime			<- DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME

	return Table
}

function WaitForNPCsDeployed( npcArray )
{
	local ent = CreateScriptRef()
	ent.s.count <- 0

	OnThreadEnd(
		function() : ( ent )
		{
			if ( IsValid( ent ) )
				ent.Kill_Deprecated_UseDestroyInstead()
		}
	)

	local func =
		function( ent, guy )
		{
			ent.s.count++

			WaitSignal( guy, "npc_deployed", "OnDeath", "OnDestroy" )
			ent.s.count--

			if ( !ent.s.count )
				ent.Kill_Deprecated_UseDestroyInstead()
		}

	foreach ( entity guy in npcArray )
	{
		if ( IsAlive( guy ) )
			thread func( ent, guy )
	}

	ent.WaitSignal( "OnDestroy" )
}

function InitDropShipFlightPaths( spawnPoints )
{
	entity tempDropShip = CreateEntity( "prop_dynamic" )
	tempDropShip.kv.spawnflags = 0
	tempDropShip.SetModel( DROPSHIP_MODEL )

	DispatchSpawn( tempDropShip )

	foreach ( spawnPoint in spawnPoints )
	{
		tempDropShip.SetOrigin( spawnPoint.GetOrigin() )

		spawnPoint.s.dropShipPathAnims <- {}
		spawnPoint.s.dropShipPathAnims[ "gd_goblin_zipline_strafe" ] <- GetDropShipAnimOffset( tempDropShip, "gd_goblin_zipline_strafe", spawnPoint )
		spawnPoint.s.dropShipPathAnims[ "gd_goblin_zipline_dive" ] <- GetDropShipAnimOffset( tempDropShip, "gd_goblin_zipline_dive", spawnPoint )
	}

	tempDropShip.Destroy()
}

entity function CreateDropship( int team, vector origin, vector angles )
{
	entity dropship = CreateEntity( "npc_dropship" )
	dropship.kv.teamnumber = team
	dropship.SetOrigin( origin )
	dropship.SetAngles( angles )
	return dropship
}

function GetDropShipAnimOffset( dropShip, animName, refEnt )
{
	local animStart = dropShip.Anim_GetStartForRefPoint_Old( animName, refEnt.GetOrigin(), refEnt.GetAngles() )
	return animStart.origin - refEnt.GetOrigin()
}



function GetDropshipSquadSize( squadname )
{
	local squadsize = 0
	array<entity> dropships = GetNPCArrayByClass( "npc_dropship" )

	//printl( dropships.len()+ " dropships, checking squadname: " + squadname )
	foreach ( ship in dropships )
		if ( ship.kv.squadname == squadname )
			squadsize++

	//printl( dropships.len()+ " dropships, squadsize: " + squadsize )
	return squadsize
}

function DelayDropshipDelete( dropship )
{
	dropship.EndSignal( "OnDeath" )

	//very defensive check
	DefensiveFreePlayers( dropship )

	WaitFrame() // so the dropship wont pop out before it warps out

	dropship.Kill_Deprecated_UseDestroyInstead()
}

function DefensiveFreePlayers( dropship )
{
	array<entity> players = GetPlayerArrayOfTeam( dropship.GetTeam() )
	foreach ( player in players )
	{
		if ( !IsValid( player ) )
			continue

		if ( player.GetParent() != dropship )
			continue

		player.ClearParent() //Clear parent before dropship gets deleted with players still attached to it. Defensive fix for bug 178543

		KillPlayer( player, eDamageSourceId.fall )
	}
}

void function OnNPCDropshipDeath( entity dropship, var damageInfo )
{
	if ( !IsValid( dropship ) )
		return

	asset modelName = dropship.GetModelName()

	vector dropshipOrigin = dropship.GetOrigin()

	PlayFX( $"P_veh_exp_crow", dropshipOrigin )

	EmitSoundAtPosition( TEAM_UNASSIGNED, dropshipOrigin, "Goblin_Dropship_Explode" )
}

void function OnDropshipDamaged( entity dropship, var damageInfo )
{
	float damage = DamageInfo_GetDamage( damageInfo )

	//Tried to give visual shield indicator, but it doesn't seem to work?
	//DamageInfo_AddCustomDamageType( damageInfo, DF_SHIELD_DAMAGE )

	// store the damage so all hits can be tallied
	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	Assert( IsValid( inflictor ) )//Done so we can still get the error in dev
	if ( !IsValid( inflictor ) ) //JFS Defensive fix
		return

	StoreDamageHistoryAndUpdate( dropship, 120.0, DamageInfo_GetDamage( damageInfo ), inflictor.GetOrigin(), DamageInfo_GetCustomDamageType( damageInfo ), DamageInfo_GetDamageSourceIdentifier( damageInfo ), DamageInfo_GetAttacker( damageInfo ) )

	if ( DamageInfo_GetDamage( damageInfo ) < 450 )
		return

	vector pos = DamageInfo_GetDamagePosition( damageInfo )
	PlayFX( FX_GUNSHIP_DAMAGE, pos )
}

void function GuyDeploysOffShip( entity guy, table Table )
{
	guy.EndSignal( "OnDeath" )
	entity ship 		= expect entity( Table.ship )
	local shipAttach 	= Table.shipAttach

	OnThreadEnd(
		function() : ( guy, ship )
		{
			if ( !IsValid( guy ) )
				return

			if ( ship != null )
			{
				if ( !IsAlive( ship ) && IsAlive( guy ) )
				{
					// try to transfer the last attacker from the ship to the attached guys.
					entity attacker = null
					entity lastAttacker = GetLastAttacker( ship )
					if ( IsValid( lastAttacker ) )
						attacker = lastAttacker

					guy.TakeDamage( 500, attacker, attacker, null )
				}
			}

			if ( !IsAlive( guy ) )
				guy.BecomeRagdoll( Vector(0,0,0), false )
			}
	)

	guy.SetEfficientMode( true )
	HideName( guy )

	Assert( shipAttach, "Ship but no shipAttach" )
	ship.EndSignal( "OnDeath" )
	GuyAnimatesRelativeToShipAttachment( guy, Table )

	WaittillPlayDeployAnims( ship )

	GuyAnimatesOut( guy, Table )
}

function WaittillPlayDeployAnims( ref )
{
	waitthread WaittillPlayDeployAnimsThread( ref )
}

function WaittillPlayDeployAnimsThread( ref )
{
	ref.EndSignal( "OnDeath" )

	ref.WaitSignal( "deploy" )
}

void function GuyAnimatesOut( entity guy, table Table )
{
	switch ( Table.side )
	{
		case "left":
		case "right":
		case "both":
		case "zipline":
			waitthread GuyZiplinesToGround( guy, Table )
			break

		default:
			thread PlayAnim( guy, Table.deployAnim, Table.ship, Table.shipAttach )
			break
	}


	guy.SetEfficientMode( false )
	guy.SetNameVisibleToOwner( true )

	WaittillAnimDone( guy )
	guy.ClearParent()

	UpdateEnemyMemoryFromTeammates( guy )

	guy.Signal( "npc_deployed" )
}

function GuyAnimatesRelativeToShipAttachment( guy, Table )
{
	expect entity( guy )
	Table.attachIndex <- Table.ship.LookupAttachment( Table.shipAttach )
	guy.SetOrigin( Table.ship.GetOrigin() )

	guy.SetParent( Table.ship, Table.shipAttach, false, 0 )

	guy.Anim_ScriptedPlay( Table.idleAnim )
}

table<string, array<string> > function GetDropshipRopeAttachments( string side = "both" )
{
	table<string, array<string> > attachments

	if ( side == "both" )
	{
		attachments[ "left" ] <- []
		attachments[ "right" ] <- []

		foreach ( seat, Table in level.DSAIziplineAnims[ "left"] )
		{
			attachments[ "left" ].append( expect string( Table.attach ) )
		}

		foreach ( seat, Table in level.DSAIziplineAnims[ "right"] )
		{
			attachments[ "right" ].append( expect string( Table.attach ) )
		}
	}
	else
	{
		attachments[ side ] <- []

		foreach ( seat, Table in level.DSAIziplineAnims[ side ] )
		{
			attachments[ side ].append( expect string( Table.attach ) )
		}
	}

	return attachments
}

function PlayDropshipRampDoorOpenSound( entity dropship )
{
	entity snd = CreateOwnedScriptMover( dropship )
	snd.SetParent( dropship, "RAMPDOORLIP" )

	EmitSoundOnEntity( snd, "fracture_scr_intro_dropship_dooropen" )
}

void function WarpoutEffect( entity dropship )
{
	if ( !IsValid( dropship ) )
		return

	__WarpOutEffectShared( dropship )

	thread DelayDropshipDelete( dropship )
}

void function WarpoutEffectFPS( entity dropship )
{
	__WarpOutEffectShared( dropship )
}

void function WarpinEffect( asset model, string animation, vector origin, vector angles, string sfx = "" )
{
	//we need a temp dropship to get the anim offsets
	Point start = GetWarpinPosition( model, animation, origin, angles )

	__WarpInEffectShared( start.origin, start.angles, sfx )
}

function PlayWarpFxOnPlayers( guys )
{
	foreach ( entity guy in guys )
	{
		if ( !IsAlive( guy ) )
			continue

		Remote_CallFunction_Replay( guy, "ServerCallback_PlayScreenFXWarpJump" )
	}
}