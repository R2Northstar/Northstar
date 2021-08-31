untyped

//TODO: Should split this up into server, client and shared versions and just globalize_all_functions
global function WeaponUtility_Init

global function ApplyVectorSpread
global function DebugDrawMissilePath
global function DegreesToTarget
global function DetonateAllPlantedExplosives
global function EntityCanHaveStickyEnts
global function EntityShouldStick
global function FireExpandContractMissiles
global function FireExpandContractMissiles_S2S
global function GetVectorFromPositionToCrosshair
global function GetVelocityForDestOverTime
global function GetPlayerVelocityForDestOverTime
global function GetWeaponBurnMods
global function InitMissileForRandomDriftForVortexLow
global function IsPilotShotgunWeapon
global function PlantStickyEntity
global function PlantStickyEntityThatBouncesOffWalls
global function PlantStickyEntityOnWorldThatBouncesOffWalls
global function PlantStickyGrenade
global function PlantSuperStickyGrenade
global function Player_DetonateSatchels
global function PROTO_CanPlayerDeployWeapon
global function ProximityCharge_PostFired_Init
global function RegenerateOffhandAmmoOverTime
global function ShotgunBlast
global function FireGenericBoltWithDrop
global function OnWeaponPrimaryAttack_GenericBoltWithDrop_Player
global function OnWeaponPrimaryAttack_GenericMissile_Player
global function OnWeaponActivate_updateViewmodelAmmo
global function TEMP_GetDamageFlagsFromProjectile
global function WeaponCanCrit
global function GiveEMPStunStatusEffects
global function GetPrimaryWeapons
global function GetSidearmWeapons
global function GetATWeapons
global function GetPlayerFromTitanWeapon
global function ChargeBall_Precache
global function ChargeBall_FireProjectile
global function ChargeBall_ChargeBegin
global function ChargeBall_ChargeEnd
global function ChargeBall_StopChargeEffects
global function ChargeBall_GetChargeTime

global function PlayerUsedOffhand
#if SERVER
global function SetPlayerCooldowns
global function ResetPlayerCooldowns
global function StoreOffhandData
#endif

global function GetRadiusDamageDataFromProjectile

#if DEV
global function DevPrintAllStatusEffectsOnEnt
#endif // #if DEV

#if SERVER
	global function ClusterRocket_Detonate
	global function PassThroughDamage
	global function PROTO_CleanupTrackedProjectiles
	global function PROTO_InitTrackedProjectile
	global function PROTO_PlayTrapLightEffect
	global function Satchel_PostFired_Init
	global function StartClusterExplosions
	global function TrapDestroyOnRoundEnd
	global function TrapExplodeOnDamage
	global function PROTO_DelayCooldown
	global function PROTO_FlakCannonMissiles
	global function GetBulletPassThroughTargets
	global function IsValidPassThroughTarget
	global function GivePlayerAmpedWeapon
	global function GivePlayerAmpedWeaponAndSetAsActive
	global function ReplacePlayerOffhand
	global function ReplacePlayerOrdnance
	global function DisableWeapons
	global function EnableWeapons
	global function WeaponAttackWave
	global function AddActiveThermiteBurn
	global function GetActiveThermiteBurnsWithinRadius
	global function OnWeaponPrimaryAttack_GenericBoltWithDrop_NPC
	global function OnWeaponPrimaryAttack_GenericMissile_NPC
	global function EMP_DamagedPlayerOrNPC
	global function EMP_FX
	global function GetWeaponDPS
	global function GetTTK
	global function GetWeaponModsFromDamageInfo
	global function Thermite_DamagePlayerOrNPCSounds
	global function AddThreatScopeColorStatusEffect
	global function RemoveThreatScopeColorStatusEffect
#endif //SERVER
#if CLIENT
	global function GlobalClientEventHandler
	global function UpdateViewmodelAmmo
	global function ServerCallback_AirburstIconUpdate
	global function ServerCallback_GuidedMissileDestroyed
	global function IsOwnerViewPlayerFullyADSed
#endif //CLIENT

global const PROJECTILE_PREDICTED = true
global const PROJECTILE_NOT_PREDICTED = false

global const PROJECTILE_LAG_COMPENSATED = true
global const PROJECTILE_NOT_LAG_COMPENSATED = false

const float EMP_SEVERITY_SLOWTURN = 0.35
const float EMP_SEVERITY_SLOWMOVE = 0.50
const float LASER_STUN_SEVERITY_SLOWTURN = 0.20
const float LASER_STUN_SEVERITY_SLOWMOVE = 0.30

const asset FX_EMP_BODY_HUMAN			= $"P_emp_body_human"
const asset FX_EMP_BODY_TITAN			= $"P_emp_body_titan"
const asset FX_VANGUARD_ENERGY_BODY_HUMAN		= $"P_monarchBeam_body_human"
const asset FX_VANGUARD_ENERGY_BODY_TITAN		= $"P_monarchBeam_body_titan"
const SOUND_EMP_REBOOT_SPARKS = "marvin_weld"
const FX_EMP_REBOOT_SPARKS = $"weld_spark_01_sparksfly"
const EMP_GRENADE_BEAM_EFFECT	= $"wpn_arc_cannon_beam"
const DRONE_REBOOT_TIME = 5.0
const GUNSHIP_REBOOT_TIME = 5.0

global struct RadiusDamageData
{
	int explosionDamage
	int explosionDamageHeavyArmor
	float explosionRadius
	float explosionInnerRadius
}

#if SERVER

global struct PopcornInfo
{
	string weaponName
	array weaponMods // could be array< string >
	int damageSourceId
	int count
	float delay
	float offset
	float range
	vector normal
	float duration
	int groupSize
	bool hasBase
}

struct ColorSwapStruct
{
	int statusEffectId
	entity weaponOwner
}

struct
{
	float titanRocketLauncherTitanDamageRadius
	float titanRocketLauncherOtherDamageRadius

	int activeThermiteBurnsManagedEnts
	array<ColorSwapStruct> colorSwapStatusEffects
} file

global int HOLO_PILOT_TRAIL_FX

global struct HoverSounds
{
	string liftoff_1p
	string liftoff_3p
	string hover_1p
	string hover_3p
	string descent_1p
	string descent_3p
	string landing_1p
	string landing_3p
}

#endif

function WeaponUtility_Init()
{
	level.weaponsPrecached <- {}

	// what classes can sticky thrown entities stick to?
	level.stickyClasses <- {}
	level.stickyClasses[ "worldspawn" ]			<- true
	level.stickyClasses[ "player" ]				<- true
	level.stickyClasses[ "prop_dynamic" ]		<- true
	level.stickyClasses[ "prop_script" ]		<- true
	level.stickyClasses[ "func_brush" ]			<- true
	level.stickyClasses[ "func_brush_lightweight" ]	<- true
	level.stickyClasses[ "phys_bone_follower" ]	<- true

	level.trapChainReactClasses <- {}
	level.trapChainReactClasses[ "mp_weapon_frag_grenade" ]			<- true
	level.trapChainReactClasses[ "mp_weapon_satchel" ]				<- true
	level.trapChainReactClasses[ "mp_weapon_proximity_mine" ] 		<- true
	level.trapChainReactClasses[ "mp_weapon_laser_mine" ]			<- true

	RegisterSignal( "Planted" )
	RegisterSignal( "EMP_FX" )
	RegisterSignal( "ArcStunned" )

	PrecacheParticleSystem( EMP_GRENADE_BEAM_EFFECT )
	PrecacheParticleSystem( FX_EMP_BODY_TITAN )
	PrecacheParticleSystem( FX_EMP_BODY_HUMAN )
	PrecacheParticleSystem( FX_VANGUARD_ENERGY_BODY_HUMAN )
	PrecacheParticleSystem( FX_VANGUARD_ENERGY_BODY_TITAN )
	PrecacheParticleSystem( FX_EMP_REBOOT_SPARKS )

	PrecacheImpactEffectTable( CLUSTER_ROCKET_FX_TABLE )

	#if SERVER
		AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_triple_threat, TripleThreatGrenade_DamagedPlayerOrNPC )
		AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_defender, Defender_DamagedPlayerOrNPC )
		//AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_rocketeer_rocketstream, TitanRocketLauncher_DamagedPlayerOrNPC )
		AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_smr, SMR_DamagedPlayerOrNPC )
		AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_flak_rifle, PROTO_Flak_Rifle_DamagedPlayerOrNPC )
		AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_stun_laser, VanguardEnergySiphon_DamagedPlayerOrNPC )
		AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_grenade_emp, EMP_DamagedPlayerOrNPC )
		AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_proximity_mine, EMP_DamagedPlayerOrNPC )
		AddDamageCallbackSourceID( eDamageSourceId[ CHARGE_TOOL ], EMP_DamagedPlayerOrNPC )
		if ( IsMultiplayer() )
			AddCallback_OnPlayerRespawned( PROTO_TrackedProjectile_OnPlayerRespawned )
		AddCallback_OnPlayerKilled( PAS_CooldownReduction_OnKill )
		AddCallback_OnPlayerGetsNewPilotLoadout( OnPlayerGetsNewPilotLoadout )
		AddCallback_OnPlayerKilled( OnPlayerKilled )

		file.activeThermiteBurnsManagedEnts = CreateScriptManagedEntArray()

		AddCallback_EntitiesDidLoad( EntitiesDidLoad )

		HOLO_PILOT_TRAIL_FX = PrecacheParticleSystem( $"P_ar_holopilot_trail" )

		PrecacheParticleSystem( $"wpn_laser_blink" )
		PrecacheParticleSystem( $"wpn_laser_blink_fast" )
		PrecacheParticleSystem( $"P_ordinance_icon_owner" )
	#endif
}

#if SERVER
void function EntitiesDidLoad()
{
#if SP
	// if we are going to do this, it should happen in the weapon, not globally
	//float titanRocketLauncherInnerRadius = expect float( GetWeaponInfoFileKeyField_Global( "mp_titanweapon_rocketeer_rocketstream", "explosion_inner_radius" ) )
	//float titanRocketLauncherOuterRadius = expect float( GetWeaponInfoFileKeyField_Global( "mp_titanweapon_rocketeer_rocketstream", "explosionradius" ) )
	//file.titanRocketLauncherTitanDamageRadius = titanRocketLauncherInnerRadius + ( ( titanRocketLauncherOuterRadius - titanRocketLauncherInnerRadius ) * 0.4 )
	//file.titanRocketLauncherOtherDamageRadius = titanRocketLauncherInnerRadius + ( ( titanRocketLauncherOuterRadius - titanRocketLauncherInnerRadius ) * 0.1 )
#endif
}
#endif

////////////////////////////////////////////////////////////////////

#if CLIENT
void function GlobalClientEventHandler( entity weapon, string name )
{
	if ( name == "ammo_update" )
		UpdateViewmodelAmmo( false, weapon )

	if ( name == "ammo_full" )
		UpdateViewmodelAmmo( true, weapon )
}

function UpdateViewmodelAmmo( bool forceFull, entity weapon )
{
	Assert( weapon != null ) // used to be: if ( weapon == null ) weapon = this.self

	if ( !IsValid( weapon ) )
		return
	if ( !IsLocalViewPlayer( weapon.GetWeaponOwner() ) )
		return

	int bodyGroupCount = weapon.GetWeaponSettingInt( eWeaponVar.bodygroup_ammo_index_count )
	if ( bodyGroupCount <= 0 )
		return

	int rounds = weapon.GetWeaponPrimaryClipCount()
	int maxRoundsForClipSize = weapon.GetWeaponPrimaryClipCountMax()
	int maxRoundsForBodyGroup = (bodyGroupCount - 1)
	int maxRounds = minint( maxRoundsForClipSize, maxRoundsForBodyGroup )

	if ( forceFull || (rounds > maxRounds) )
		rounds = maxRounds

	//printt( "ROUNDS:", rounds, "/", maxRounds )
	weapon.SetViewmodelAmmoModelIndex( rounds )
}
#endif // #if CLIENT

void function OnWeaponActivate_updateViewmodelAmmo( entity weapon )
{
#if CLIENT
	UpdateViewmodelAmmo( false, weapon )
#endif // #if CLIENT
}

#if SERVER
//////////////////WEAPON DAMAGE CALLBACKS/////////////////////////////////////////
void function TripleThreatGrenade_DamagedPlayerOrNPC( entity ent, var damageInfo )
{
	if ( !IsValid( ent ) )
		return

	if ( ent.GetClassName() == "grenade_frag" )
		return

	if ( DamageInfo_GetCustomDamageType( damageInfo ) & DF_DOOMED_HEALTH_LOSS )
		return

	vector damagePosition = DamageInfo_GetDamagePosition( damageInfo )

	vector entOrigin = ent.GetOrigin()
	vector entCenter = ent.GetWorldSpaceCenter()
	float distanceToOrigin = Distance( entOrigin, damagePosition )
	float distanceToCenter = Distance( entCenter, damagePosition )

	vector normal = Vector( 0, 0, 1 )
	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	if ( IsValid( inflictor.s ) )
	{
		if ( "collisionNormal" in inflictor.s )
			normal = expect vector( inflictor.s.collisionNormal )
	}

	local zDifferenceOrigin = deg_cos( DegreesToTarget( entOrigin, normal, damagePosition ) ) * distanceToOrigin
	local zDifferenceTop = deg_cos( DegreesToTarget( entCenter, normal, damagePosition ) ) * distanceToCenter - (entCenter.z - entOrigin.z)

	float zDamageDiff
	//Full damage if explosion is between Origin or Center.
	if ( zDifferenceOrigin > 0 && zDifferenceTop < 0 )
		zDamageDiff = 1.0
	else if ( zDifferenceTop > 0 )
		zDamageDiff = GraphCapped( zDifferenceTop, 0.0, 32.0, 1.0, 0.0 )
	else
		zDamageDiff = GraphCapped( zDifferenceOrigin, 0.0, -32.0, 1.0, 0.0 )

	DamageInfo_ScaleDamage( damageInfo, zDamageDiff )
}

void function Defender_DamagedPlayerOrNPC( entity ent, var damageInfo )
{
	if ( !IsValid( ent ) )
		return

	if ( DamageInfo_GetCustomDamageType( damageInfo ) & DF_DOOMED_HEALTH_LOSS )
		return

	local damage = Vortex_HandleElectricDamage( ent, DamageInfo_GetAttacker( damageInfo ), DamageInfo_GetDamage( damageInfo ), DamageInfo_GetWeapon( damageInfo ) )
	DamageInfo_SetDamage( damageInfo, damage )
}

/*
void function TitanRocketLauncher_DamagedPlayerOrNPC( entity ent, var damageInfo )
{
	Assert( IsSingleplayer() )

	if ( !IsValid( ent ) )
		return

	if ( DamageInfo_GetCustomDamageType( damageInfo ) & DF_DOOMED_HEALTH_LOSS )
		return

	vector damagePosition = DamageInfo_GetDamagePosition( damageInfo )

	if ( ent == DamageInfo_GetAttacker( damageInfo ) )
		return

	if ( ent.IsTitan() )
	{
		vector entOrigin = ent.GetOrigin()
		if ( Distance( damagePosition, entOrigin ) > file.titanRocketLauncherTitanDamageRadius )
			DamageInfo_SetDamage( damageInfo, 0 )
	}
	else if ( IsHumanSized( ent ) )
	{
		if ( Distance( damagePosition, ent.GetOrigin() ) > file.titanRocketLauncherOtherDamageRadius )
			DamageInfo_SetDamage( damageInfo, 0 )
	}
}
*/

void function SMR_DamagedPlayerOrNPC( entity ent, var damageInfo )
{
	//Hack - JFS ( The explosion radius is too small on the SMR to deal splash damage to pilots on a Titan. )
	if ( !IsValid( ent ) )
		return

	if ( !ent.IsTitan() )
		return

	if ( DamageInfo_GetCustomDamageType( damageInfo ) & DF_DOOMED_HEALTH_LOSS )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( IsValid( attacker ) && attacker.IsPlayer() && attacker.GetTitanSoulBeingRodeoed() == ent.GetTitanSoul() )
		attacker.TakeDamage( 30, attacker, attacker, { scriptType = DF_GIB | DF_EXPLOSION, damageSourceId = eDamageSourceId.mp_weapon_smr, weapon = DamageInfo_GetWeapon( damageInfo ) } )
}


void function PROTO_Flak_Rifle_DamagedPlayerOrNPC( entity ent, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsValid( ent ) || !IsValid( attacker ) )
		return

	if ( attacker == ent )
		DamageInfo_ScaleDamage( damageInfo, 0.5 )
}

function EngineerRocket_DamagedPlayerOrNPC( ent, damageInfo )
{
	expect entity( ent )

	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsValid( ent ) || !IsValid( attacker ) )
		return

	if ( attacker == ent )
		DamageInfo_SetDamage( damageInfo, 10 )
}
///////////////////////////////////////////////////////////////////////

#endif // SERVER

vector function ApplyVectorSpread( vector vecShotDirection, float spreadDegrees, float bias = 1.0 )
{
	vector angles = VectorToAngles( vecShotDirection )
	vector vecUp = AnglesToUp( angles )
	vector vecRight = AnglesToRight( angles )

	float sinDeg = deg_sin( spreadDegrees / 2.0 )

	// get circular gaussian spread
	float x
	float y
	float z

	if ( bias > 1.0 )
		bias = 1.0
	else if ( bias < 0.0 )
		bias = 0.0

	// code gets these values from cvars ai_shot_bias_min & ai_shot_bias_max
	float shotBiasMin = -1.0
	float shotBiasMax = 1.0

	// 1.0 gaussian, 0.0 is flat, -1.0 is inverse gaussian
	float shotBias = ( ( shotBiasMax - shotBiasMin ) * bias ) + shotBiasMin
	float flatness = ( fabs(shotBias) * 0.5 )

	while ( true )
	{
		x = RandomFloatRange( -1.0, 1.0 ) * flatness + RandomFloatRange( -1.0, 1.0 ) * (1 - flatness)
		y = RandomFloatRange( -1.0, 1.0 ) * flatness + RandomFloatRange( -1.0, 1.0 ) * (1 - flatness)
		if ( shotBias < 0 )
		{
			x = ( x >= 0 ) ? 1.0 - x : -1.0 - x
			y = ( y >= 0 ) ? 1.0 - y : -1.0 - y
		}
		z = x * x + y * y

		if ( z <= 1 )
			break
	}

	vector addX = vecRight * ( x * sinDeg )
	vector addY = vecUp * ( y * sinDeg )
	vector m_vecResult = vecShotDirection + addX + addY

	return m_vecResult
}


float function DegreesToTarget( vector origin, vector forward, vector targetPos )
{
	vector dirToTarget = targetPos - origin
	dirToTarget = Normalize( dirToTarget )
	float dot = DotProduct( forward, dirToTarget )
	float degToTarget = (acos( dot ) * 180 / PI)

	return degToTarget
}

function ShotgunBlast( entity weapon, vector pos, vector dir, int numBlasts, int damageType, float damageScaler = 1.0, float ornull maxAngle = null, float ornull maxDistance = null )
{
	Assert( numBlasts > 0 )
	int numBlastsOriginal = numBlasts
	entity owner = weapon.GetWeaponOwner()

	/*
	Debug ConVars:
		visible_ent_cone_debug_duration_client - Set to non-zero to see debug output
		visible_ent_cone_debug_duration_server - Set to non-zero to see debug output
		visible_ent_cone_debug_draw_radius - Size of trace endpoint debug draw
	*/

	if ( maxDistance == null )
		maxDistance	= weapon.GetMaxDamageFarDist()
	expect float( maxDistance )

	if ( maxAngle == null )
		maxAngle = owner.GetAttackSpreadAngle() * 0.5
	expect float( maxAngle )

	array<entity> ignoredEntities 	= [ owner ]
	int traceMask 					= TRACE_MASK_SHOT
	int visConeFlags				= VIS_CONE_ENTS_TEST_HITBOXES | VIS_CONE_ENTS_CHECK_SOLID_BODY_HIT | VIS_CONE_ENTS_APPOX_CLOSEST_HITBOX | VIS_CONE_RETURN_HIT_VORTEX

	entity antilagPlayer
	if ( owner.IsPlayer() )
	{
		if ( owner.IsPhaseShifted() )
			return;

		antilagPlayer = owner
	}

	//JFS - Bug 198500
	Assert( maxAngle > 0.0, "JFS returning out at this instance. We need to investigate when a valid mp_titanweapon_laser_lite weapon returns 0 spread")
	if ( maxAngle == 0.0 )
		return

	array<VisibleEntityInCone> results = FindVisibleEntitiesInCone( pos, dir, maxDistance, (maxAngle * 1.1), ignoredEntities, traceMask, visConeFlags, antilagPlayer, weapon )
	foreach ( result in results )
	{
		float angleToHitbox = 0.0
		if ( !result.solidBodyHit )
			angleToHitbox = DegreesToTarget( pos, dir, result.approxClosestHitboxPos )

		numBlasts -= ShotgunBlastDamageEntity( weapon, pos, dir, result, angleToHitbox, maxAngle, numBlasts, damageType, damageScaler )
		if ( numBlasts <= 0 )
			break
	}

	//Something in the TakeDamage above is triggering the weapon owner to become invalid.
	owner = weapon.GetWeaponOwner()
	if ( !IsValid( owner ) )
		return

	// maxTracer limit set in /r1dev/src/game/client/c_player.h
	const int MAX_TRACERS = 16
	bool didHitAnything = ((numBlastsOriginal - numBlasts) != 0)
	bool doTraceBrushOnly = (!didHitAnything)
	if ( numBlasts > 0 )
		weapon.FireWeaponBullet_Special( pos, dir, minint( numBlasts, MAX_TRACERS ), damageType, false, false, true, false, false, false, doTraceBrushOnly )
}


const SHOTGUN_ANGLE_MIN_FRACTION = 0.1;
const SHOTGUN_ANGLE_MAX_FRACTION = 1.0;
const SHOTGUN_DAMAGE_SCALE_AT_MIN_ANGLE = 0.8;
const SHOTGUN_DAMAGE_SCALE_AT_MAX_ANGLE = 0.1;

int function ShotgunBlastDamageEntity( entity weapon, vector barrelPos, vector barrelVec, VisibleEntityInCone result, float angle, float maxAngle, int numPellets, int damageType, float damageScaler )
{
	entity target = result.ent

	//The damage scaler is currently only > 1 for the Titan Shotgun alt fire.
	if ( !target.IsTitan() && damageScaler > 1 )
		damageScaler = max( damageScaler * 0.4, 1.5 )

	entity owner = weapon.GetWeaponOwner()
	// Ent in cone not valid
	if ( !IsValid( target ) || !IsValid( owner ) )
		return 0

	// Fire fake bullet towards entity for visual purposes only
	vector hitLocation = result.visiblePosition
	vector vecToEnt = ( hitLocation - barrelPos )
	vecToEnt.Norm()
	if ( Length( vecToEnt ) == 0 )
		vecToEnt = barrelVec

	// This fires a fake bullet that doesn't do any damage. Currently it triggeres a damage callback with 0 damage which is bad.
	weapon.FireWeaponBullet_Special( barrelPos, vecToEnt, 1, damageType, true, true, true, false, false, false, false ) // fires perfect bullet with no antilag and no spread

#if SERVER
	// Determine how much damage to do based on distance
	float distanceToTarget = Distance( barrelPos, hitLocation )

	if ( !result.solidBodyHit ) // non solid hits take 1 blast more
		distanceToTarget += 130

	int extraMods = result.extraMods
	float damageAmount = CalcWeaponDamage( owner, target, weapon, distanceToTarget, extraMods )

	// vortex needs to scale damage based on number of rounds absorbed
	string className = weapon.GetWeaponClassName()
	if ( (className == "mp_titanweapon_vortex_shield") || (className == "mp_titanweapon_vortex_shield_ion") || (className == "mp_titanweapon_heat_shield") )
	{
		damageAmount *= numPellets
		//printt( "scaling vortex hitscan output damage by", numPellets, "pellets for", weaponNearDamageTitan, "damage vs titans" )
	}

	float coneScaler = 1.0
	//if ( angle > 0 )
	//	coneScaler = GraphCapped( angle, (maxAngle * SHOTGUN_ANGLE_MIN_FRACTION), (maxAngle * SHOTGUN_ANGLE_MAX_FRACTION), SHOTGUN_DAMAGE_SCALE_AT_MIN_ANGLE, SHOTGUN_DAMAGE_SCALE_AT_MAX_ANGLE )

	// Calculate the final damage abount to inflict on the target. Also scale it by damageScaler which may have been passed in by script ( used by alt fire mode on titan shotgun to fire multiple shells )
	float finalDamageAmount = damageAmount * coneScaler * damageScaler
	//printt( "angle:", angle, "- coneScaler:", coneScaler, "- damageAmount:", damageAmount, "- damageScaler:", damageScaler, "  = finalDamageAmount:", finalDamageAmount )

	// Calculate impulse force to apply based on damage
	int maxImpulseForce = expect int( weapon.GetWeaponInfoFileKeyField( "impulse_force" ) )
	float impulseForce = float( maxImpulseForce ) * coneScaler * damageScaler
	vector impulseVec = barrelVec * impulseForce

	int damageSourceID = weapon.GetDamageSourceID()

	//
	float critScale = weapon.GetWeaponSettingFloat( eWeaponVar.critical_hit_damage_scale )
	target.TakeDamage( finalDamageAmount, owner, weapon, { origin = hitLocation, force = impulseVec, scriptType = damageType, damageSourceId = damageSourceID, weapon = weapon, hitbox = result.visibleHitbox, criticalHitScale = critScale } )

	//printt( "-----------" )
	//printt( "    distanceToTarget:", distanceToTarget )
	//printt( "    damageAmount:", damageAmount )
	//printt( "    coneScaler:", coneScaler )
	//printt( "    impulseForce:", impulseForce )
	//printt( "    impulseVec:", impulseVec.x + ", " + impulseVec.y + ", " + impulseVec.z )
	//printt( "        finalDamageAmount:", finalDamageAmount )
	//PrintTable( result )
#endif // #if SERVER

	return 1
}

int function FireGenericBoltWithDrop( entity weapon, WeaponPrimaryAttackParams attackParams, bool isPlayerFired )
{
#if CLIENT
	if ( !weapon.ShouldPredictProjectiles() )
		return 1
#endif // #if CLIENT

	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	const float PROJ_SPEED_SCALE = 1
	const float PROJ_GRAVITY = 1
	int damageFlags = weapon.GetWeaponDamageFlags()
	entity bolt = weapon.FireWeaponBolt( attackParams.pos, attackParams.dir, PROJ_SPEED_SCALE, damageFlags, damageFlags, isPlayerFired, 0 )
	if ( bolt != null )
	{
		bolt.kv.gravity = PROJ_GRAVITY
		bolt.kv.rendercolor = "0 0 0"
		bolt.kv.renderamt = 0
		bolt.kv.fadedist = 1
	}

	return 1
}
var function OnWeaponPrimaryAttack_GenericBoltWithDrop_Player( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return FireGenericBoltWithDrop( weapon, attackParams, true )
}

var function OnWeaponPrimaryAttack_EPG( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity missile = weapon.FireWeaponMissile( attackParams.pos, attackParams.dir, 1, damageTypes.largeCaliberExp, damageTypes.largeCaliberExp, false, PROJECTILE_NOT_PREDICTED )
	if ( missile )
	{
		EmitSoundOnEntity( missile, "Weapon_Sidwinder_Projectile" )
		missile.InitMissileForRandomDriftFromWeaponSettings( attackParams.pos, attackParams.dir )
	}

	return missile
}

#if SERVER
var function OnWeaponPrimaryAttack_GenericBoltWithDrop_NPC( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return FireGenericBoltWithDrop( weapon, attackParams, false )
}
#endif // #if SERVER


var function OnWeaponPrimaryAttack_GenericMissile_Player( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	entity weaponOwner = weapon.GetWeaponOwner()
	vector bulletVec = ApplyVectorSpread( attackParams.dir, weaponOwner.GetAttackSpreadAngle() - 1.0 )
	attackParams.dir = bulletVec

	if ( IsServer() || weapon.ShouldPredictProjectiles() )
	{
		entity missile = weapon.FireWeaponMissile( attackParams.pos, attackParams.dir, 1.0, weapon.GetWeaponDamageFlags(), weapon.GetWeaponDamageFlags(), false, PROJECTILE_PREDICTED )
		if ( missile )
		{
			missile.InitMissileForRandomDriftFromWeaponSettings( attackParams.pos, attackParams.dir )
		}
	}
}

#if SERVER
var function OnWeaponPrimaryAttack_GenericMissile_NPC( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	entity missile = weapon.FireWeaponMissile( attackParams.pos, attackParams.dir, 1.0, weapon.GetWeaponDamageFlags(), weapon.GetWeaponDamageFlags(), true, PROJECTILE_NOT_PREDICTED )
	if ( missile )
	{
		missile.InitMissileForRandomDriftFromWeaponSettings( attackParams.pos, attackParams.dir )
	}
}
#endif // #if SERVER

bool function PlantStickyEntityOnWorldThatBouncesOffWalls( entity ent, table collisionParams, float bounceDot )
{
	entity hitEnt = expect entity( collisionParams.hitEnt )
	if ( hitEnt && ( hitEnt.IsWorld() || hitEnt.HasPusherRootParent() ) )
	{
		float dot = expect vector( collisionParams.normal ).Dot( Vector( 0, 0, 1 ) )

		if ( dot < bounceDot )
			return false

		return PlantStickyEntity( ent, collisionParams )
	}

	return false
}

bool function PlantStickyEntityThatBouncesOffWalls( entity ent, table collisionParams, float bounceDot )
{
	if ( expect entity( collisionParams.hitEnt ) == GetEntByIndex( 0 ) )
	{
		// Satchel hit the world
		float dot = expect vector( collisionParams.normal ).Dot( Vector( 0, 0, 1 ) )

		if ( dot < bounceDot )
			return false
	}

	return PlantStickyEntity( ent, collisionParams )
}


bool function PlantStickyEntity( entity ent, table collisionParams, vector angleOffset = <0.0, 0.0, 0.0> )
{
	if ( !EntityShouldStick( ent, expect entity( collisionParams.hitEnt ) ) )
		return false

	// Don't allow parenting to another "sticky" entity to prevent them parenting onto each other
	if ( collisionParams.hitEnt.IsProjectile() )
		return false

	// Update normal from last bouce so when it explodes it can orient the effect properly

	vector plantAngles = AnglesCompose( VectorToAngles( collisionParams.normal ), angleOffset )
	vector plantPosition = expect vector( collisionParams.pos )

	if ( !LegalOrigin( plantPosition ) )
		return false

	#if SERVER
		ent.SetAbsOrigin( plantPosition )
		ent.SetAbsAngles( plantAngles )
		ent.proj.isPlanted = true
	#else
		ent.SetOrigin( plantPosition )
		ent.SetAngles( plantAngles )
	#endif
	ent.SetVelocity( Vector( 0, 0, 0 ) )

	//printt( " - Hitbox is:", collisionParams.hitbox, " IsWorld:", collisionParams.hitEnt )
	if ( !collisionParams.hitEnt.IsWorld() )
	{
		if ( !ent.IsMarkedForDeletion() && !collisionParams.hitEnt.IsMarkedForDeletion() )
		{
			if ( collisionParams.hitbox > 0 )
				ent.SetParentWithHitbox( collisionParams.hitEnt, collisionParams.hitbox, true )

			// Hit a func_brush
			else
				ent.SetParent( collisionParams.hitEnt )

			if ( collisionParams.hitEnt.IsPlayer() )
			{
				thread HandleDisappearingParent( ent, expect entity( collisionParams.hitEnt ) )
			}
		}
	}
	else
	{
		ent.SetVelocity( Vector( 0, 0, 0 ) )
		ent.StopPhysics()
	}
	#if CLIENT
	if ( ent instanceof C_BaseGrenade )
	#else
	if ( ent instanceof CBaseGrenade )
	#endif
		ent.MarkAsAttached()

	ent.Signal( "Planted" )

	return true
}

bool function PlantStickyGrenade( entity ent, vector pos, vector normal, entity hitEnt, int hitbox, float depth = 0.0, bool allowBounce = true, bool allowEntityStick = true )
{
	if ( ent.GetTeam() == hitEnt.GetTeam() )
		return false

	if ( ent.IsMarkedForDeletion() || hitEnt.IsMarkedForDeletion() )
		return false

	vector plantAngles = VectorToAngles( normal )
	vector plantPosition = pos + normal * -depth

	if ( !allowBounce )
		ent.SetVelocity( Vector( 0, 0, 0 ) )

	if ( !LegalOrigin( plantPosition ) )
		return false

	#if SERVER
		ent.SetAbsOrigin( plantPosition )
		ent.SetAbsAngles( plantAngles )
		ent.proj.isPlanted = true
	#else
		ent.SetOrigin( plantPosition )
		ent.SetAngles( plantAngles )
	#endif

	if ( !hitEnt.IsWorld() && (!hitEnt.IsTitan() || !allowEntityStick) )
		return false

	// SetOrigin might be causing the ent to get markedForDeletion.
	if ( ent.IsMarkedForDeletion() )
		return false

	ent.SetVelocity( Vector( 0, 0, 0 ) )

	if ( hitEnt.IsWorld() )
	{
		ent.SetParent( hitEnt, "", true )
		ent.StopPhysics()
	}
	else
	{
		if ( hitbox > 0 )
			ent.SetParentWithHitbox( hitEnt, hitbox, true )
		else // Hit a func_brush
			ent.SetParent( hitEnt )

		if ( hitEnt.IsPlayer() )
		{
			thread HandleDisappearingParent( ent, hitEnt )
		}
	}

	#if CLIENT
		if ( ent instanceof C_BaseGrenade )
			ent.MarkAsAttached()
	#else
		if ( ent instanceof CBaseGrenade )
			ent.MarkAsAttached()
	#endif

	return true
}


bool function PlantSuperStickyGrenade( entity ent, vector pos, vector normal, entity hitEnt, int hitbox )
{
	if ( ent.GetTeam() == hitEnt.GetTeam() )
		return false

	vector plantAngles = VectorToAngles( normal )
	vector plantPosition = pos

	if ( !LegalOrigin( plantPosition ) )
		return false

	#if SERVER
		ent.SetAbsOrigin( plantPosition )
		ent.SetAbsAngles( plantAngles )
		ent.proj.isPlanted = true
	#else
		ent.SetOrigin( plantPosition )
		ent.SetAngles( plantAngles )
	#endif

	if ( !hitEnt.IsWorld() && !hitEnt.IsPlayer() && !hitEnt.IsNPC() )
		return false

	ent.SetVelocity( Vector( 0, 0, 0 ) )

	if ( hitEnt.IsWorld() )
	{
		ent.StopPhysics()
	}
	else
	{
		if ( !ent.IsMarkedForDeletion() && !hitEnt.IsMarkedForDeletion() )
		{
			if ( hitbox > 0 )
				ent.SetParentWithHitbox( hitEnt, hitbox, true )
			else // Hit a func_brush
				ent.SetParent( hitEnt )

			if ( hitEnt.IsPlayer() )
			{
				thread HandleDisappearingParent( ent, hitEnt )
			}
		}
	}

	#if CLIENT
		if ( ent instanceof C_BaseGrenade )
			ent.MarkAsAttached()
	#else
		if ( ent instanceof CBaseGrenade )
			ent.MarkAsAttached()
	#endif

	return true
}

#if SERVER
void function HandleDisappearingParent( entity ent, entity parentEnt )
{
	parentEnt.EndSignal( "OnDeath" )
	ent.EndSignal( "OnDestroy" )

	OnThreadEnd(
	function() : ( ent )
		{
			ent.ClearParent()
		}
	)

	parentEnt.WaitSignal( "StartPhaseShift" )
}
#else
void function HandleDisappearingParent( entity ent, entity parentEnt )
{
	parentEnt.EndSignal( "OnDeath" )
	ent.EndSignal( "OnDestroy" )

	parentEnt.WaitSignal( "StartPhaseShift" )

	ent.ClearParent()
}
#endif

bool function EntityShouldStick( entity stickyEnt, entity hitent )
{
	if ( !EntityCanHaveStickyEnts( stickyEnt, hitent ) )
		return false

	if ( hitent == stickyEnt )
		return false

	return true
}

bool function EntityCanHaveStickyEnts( entity stickyEnt, entity ent )
{
	if ( !IsValid( ent ) )
		return false

	if ( ent.GetModelName() == $"" ) // valid case, other projectiles bullets, etc.. sometimes have no model
		return false;

	local entClassname
	if ( IsServer() )
		entClassname = ent.GetClassName()
	else
		entClassname = ent.GetSignifierName() // Can return null

	if ( !( entClassname in level.stickyClasses ) && !ent.IsNPC() )
		return false

	#if CLIENT
	if ( stickyEnt instanceof C_Projectile )
	#else
	if ( stickyEnt instanceof CProjectile )
	#endif
	{
	string weaponClassName = stickyEnt.ProjectileGetWeaponClassName()
	local stickPlayer = GetWeaponInfoFileKeyField_Global( weaponClassName, "stick_pilot" )
	local stickTitan = GetWeaponInfoFileKeyField_Global( weaponClassName, "stick_titan" )
	local stickNPC = GetWeaponInfoFileKeyField_Global( weaponClassName, "stick_npc" )

	if ( ent.IsTitan() && stickTitan )
		return true
	else if ( ent.IsPlayer() && stickPlayer )
		return true
	else if ( ent.IsNPC() && stickNPC )
		return true

	// not pilots
	if ( ent.IsPlayer() && !ent.IsTitan() )
		return false
	}

	return true
}

#if SERVER
// shared with the vortex script which also needs to create satchels
function Satchel_PostFired_Init( entity satchel, entity player )
{
	satchel.proj.onlyAllowSmartPistolDamage = false
	thread SatchelThink( satchel, player )
}

function SatchelThink( entity satchel, entity player )
{
	player.EndSignal("OnDestroy")
	satchel.EndSignal("OnDestroy")

	int satchelHealth = 15
	thread TrapExplodeOnDamage( satchel, satchelHealth )

	#if DEV
		// temp HACK for FX to use to figure out the size of the particle to play
		if ( Flag( "ShowExplosionRadius" ) )
			thread ShowExplosionRadiusOnExplode( satchel )
	#endif

	player.EndSignal( "OnDeath" )

	OnThreadEnd(
	function() : ( satchel )
		{
			if ( IsValid( satchel ) )
			{
				satchel.Destroy()
			}
		}
	)

	WaitForever()
}

#endif // SERVER

function ProximityCharge_PostFired_Init( entity proximityMine, entity player )
{
	#if SERVER
	proximityMine.proj.onlyAllowSmartPistolDamage = false
	#endif
}

function DetonateAllPlantedExplosives( entity player )
{
	// ToDo: Could use Player_DetonateSatchels but it only tracks satchels, not laser mines.

	// Detonate all explosives - satchels and laser mines are also frag grenades in disguise
	array<entity> grenades = GetProjectileArrayEx( "grenade_frag", TEAM_ANY, TEAM_ANY, Vector( 0, 0, 0 ), -1 )
	foreach( grenade in grenades )
	{
		if ( grenade.GetOwner() != player )
			continue

		if ( grenade.ProjectileGetDamageSourceID() != eDamageSourceId.mp_weapon_satchel && grenade.ProjectileGetDamageSourceID() != eDamageSourceId.mp_weapon_proximity_mine )
			continue

		thread ExplodePlantedGrenadeAfterDelay( grenade, RandomFloatRange( 0.75, 0.95 ) )
	}
}

function ExplodePlantedGrenadeAfterDelay( entity grenade, float delay )
{
	grenade.EndSignal( "OnDeath" )
	grenade.EndSignal( "OnDestroy" )

	float endTime = Time() + delay

	while ( Time() < endTime )
	{
		EmitSoundOnEntity( grenade, DEFAULT_WARNING_SFX	)
		wait 0.1
	}

	grenade.GrenadeExplode( grenade.GetForwardVector() )
}

function Player_DetonateSatchels( entity player )
{
	#if SERVER
	Assert( IsServer() )

	array<entity> traps = GetScriptManagedEntArray( player.s.activeTrapArrayId )
	traps.sort( CompareCreationReverse )
	foreach ( index, satchel in traps )
	{
		if ( IsValidSatchel( satchel ) )
		{

			thread PROTO_ExplodeAfterDelay( satchel, index * 0.25 )
		}
	}
	#endif
}

function IsValidSatchel( entity satchel )
{
	#if SERVER
	if ( satchel.ProjectileGetWeaponClassName() != "mp_weapon_satchel" )
		return false

	if ( satchel.e.isDisabled == true )
		return false

	return true
	#endif
}

#if SERVER
function PROTO_ExplodeAfterDelay( entity satchel, float delay )
{
	satchel.EndSignal( "OnDestroy" )

	#if MP
	while ( !satchel.proj.isPlanted )
	{
		WaitFrame()
	}
	#endif

	wait delay

	satchel.GrenadeExplode( satchel.GetForwardVector() )
}
#endif


#if DEV
function ShowExplosionRadiusOnExplode( entity ent )
{
	ent.WaitSignal( "OnDestroy" )

	float innerRadius = expect float( ent.GetWeaponInfoFileKeyField( "explosion_inner_radius" ) )
	float outerRadius = expect float( ent.GetWeaponInfoFileKeyField( "explosionradius" ) )

	vector org = ent.GetOrigin()
	vector angles = Vector( 0, 0, 0 )
	thread DebugDrawCircle( org, angles, innerRadius, 255, 255, 51, true, 3.0 )
	thread DebugDrawCircle( org, angles, outerRadius, 255, 255, 255, true, 3.0 )
}
#endif // DEV

#if SERVER
// shared between nades, satchels and laser mines
void function TrapExplodeOnDamage( entity trapEnt, int trapEntHealth = 50, float waitMin = 0.0, float waitMax = 0.0 )
{
	Assert( IsValid( trapEnt ), "Given trapEnt entity is not valid, fired from: " + trapEnt.ProjectileGetWeaponClassName() )
	EndSignal( trapEnt, "OnDestroy" )

	trapEnt.SetDamageNotifications( true )
	var results //Really should be a struct
	entity attacker
	entity inflictor

	while ( true )
	{
		if ( !IsValid( trapEnt ) )
			return

		results = WaitSignal( trapEnt, "OnDamaged" )
		attacker = expect entity( results.activator )
		inflictor = expect entity( results.inflictor )

		if ( IsValid( inflictor ) && inflictor == trapEnt )
			continue

		bool shouldDamageTrap = false
		if ( IsValid( attacker ) )
		{
			if ( trapEnt.proj.onlyAllowSmartPistolDamage )
			{
				if ( attacker.IsNPC() || attacker.IsPlayer() )
				{
					entity attackerWeapon = attacker.GetActiveWeapon()
					if ( IsValid( attackerWeapon ) && WeaponIsSmartPistolVariant( attackerWeapon ) )
						shouldDamageTrap = true
				}
			}
			else
			{
				if ( trapEnt.GetTeam() == attacker.GetTeam() )
				{
					if ( trapEnt.GetOwner() != attacker )
						shouldDamageTrap = false
					else
						shouldDamageTrap = !ProjectileIgnoresOwnerDamage( trapEnt )
				}
				else
				{
					shouldDamageTrap = true
				}
			}
		}

		if ( shouldDamageTrap )
			trapEntHealth -= int ( results.value ) //TODO: This returns float even though it feels like it should return int

		if ( trapEntHealth <= 0 )
			break
	}

	if ( !IsValid( trapEnt ) )
		return

	inflictor = expect entity( results.inflictor ) // waiting on code feature to pass inflictor with OnDamaged signal results table

	if ( waitMin >= 0 && waitMax > 0 )
	{
		float waitTime = RandomFloatRange( waitMin, waitMax )

		if ( waitTime > 0 )
			wait waitTime
	}
	else if ( IsValid( inflictor ) && (inflictor.IsProjectile() || (inflictor instanceof CWeaponX)) )
	{
		int dmgSourceID
		if ( inflictor.IsProjectile() )
			dmgSourceID = inflictor.ProjectileGetDamageSourceID()
		else
			dmgSourceID = inflictor.GetDamageSourceID()

		string inflictorClass = GetObitFromDamageSourceID( dmgSourceID )

		if ( inflictorClass in level.trapChainReactClasses )
		{
			// chain reaction delay
			Wait( RandomFloatRange( 0.2, 0.275 ) )
		}
	}

	if ( !IsValid( trapEnt ) )
		return

	if ( IsValid( attacker ) )
	{
		if ( attacker.IsPlayer() )
		{
			AddPlayerScoreForTrapDestruction( attacker, trapEnt )
			trapEnt.SetOwner( attacker )
		}
		else
		{
			entity lastAttacker = GetLastAttacker( attacker )
			if ( IsValid( lastAttacker ) )
			{
				// for chain explosions, figure out the attacking player that started the chain
				trapEnt.SetOwner( lastAttacker )
			}
		}
	}

	trapEnt.GrenadeExplode( trapEnt.GetForwardVector() )
}

bool function ProjectileIgnoresOwnerDamage( entity projectile )
{
	var ignoreOwnerDamage = projectile.ProjectileGetWeaponInfoFileKeyField( "projectile_ignore_owner_damage" )

	if ( ignoreOwnerDamage == null )
		return false

	return ignoreOwnerDamage == 1
}

bool function WeaponIsSmartPistolVariant( entity weapon )
{
	var isSP = weapon.GetWeaponInfoFileKeyField( "is_smart_pistol" )

	//printt( isSP )

	if ( isSP == null )
		return false

	return ( isSP == 1 )
}

// NOTE: we should stop using this
function TrapDestroyOnRoundEnd( entity player, entity trapEnt )
{
	trapEnt.EndSignal( "OnDestroy" )

	svGlobal.levelEnt.WaitSignal( "ClearedPlayers" )

	if ( IsValid( trapEnt ) )
		trapEnt.Destroy()
}

function AddPlayerScoreForTrapDestruction( entity player, entity trapEnt )
{
	// don't get score for killing your own trap
	if ( "originalOwner" in trapEnt.s && trapEnt.s.originalOwner == player )
		return

	string trapClass = trapEnt.ProjectileGetWeaponClassName()
	if ( trapClass == "" )
		return

	string scoreEvent
	if ( trapClass == "mp_weapon_satchel" )
		scoreEvent = "Destroyed_Satchel"
	else if ( trapClass == "mp_weapon_proximity_mine" )
		scoreEvent = "Destored_Proximity_Mine"

	if ( scoreEvent == "" )
		return

	AddPlayerScore( player, scoreEvent, trapEnt )
}

table function GetBulletPassThroughTargets( entity attacker, WeaponBulletHitParams hitParams )
{
	//HACK requires code later
	table passThroughInfo = {
		endPos = null
		targetArray = []
	}

	TraceResults result
	array<entity> ignoreEnts = [ attacker, hitParams.hitEnt ]

	while ( true )
	{
		vector vec = ( hitParams.hitPos - hitParams.startPos ) * 1000
		ArrayRemoveInvalid( ignoreEnts )
		result = TraceLine( hitParams.startPos, vec, ignoreEnts, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )

		if ( result.hitEnt == svGlobal.worldspawn )
			break

		ignoreEnts.append( result.hitEnt )

		if ( IsValidPassThroughTarget( result.hitEnt, attacker ) )
			passThroughInfo.targetArray.append( result.hitEnt )
	}
	passThroughInfo.endPos = result.endPos

	return passThroughInfo
}
#endif // SERVER

bool function WeaponCanCrit( entity weapon )
{
	// player sometimes has no weapon during titan exit, mantle, etc...
	if ( !weapon )
		return false

	return weapon.GetWeaponSettingBool( eWeaponVar.critical_hit )
}


#if SERVER
bool function IsValidPassThroughTarget( entity target, entity attacker )
{
	//Tied to PassThroughHack function remove when supported by code.
	if ( target == svGlobal.worldspawn )
		return false

	if ( !IsValid( target ) )
		return false

	if ( target.GetTeam() == attacker.GetTeam() )
		return false

	if ( target.GetTeam() != TEAM_IMC && target.GetTeam() != TEAM_MILITIA )
		return false

	return true
}

function PassThroughDamage( entity weapon, targetArray )
{
	//Tied to PassThroughHack function remove when supported by code.

	int damageSourceID = weapon.GetDamageSourceID()
	entity owner = weapon.GetWeaponOwner()

	foreach ( ent in targetArray )
	{
		expect entity( ent )

		float distanceToTarget = Distance( weapon.GetOrigin(), ent.GetOrigin() )
		float damageToDeal = CalcWeaponDamage( owner, ent, weapon, distanceToTarget, 0 )

		ent.TakeDamage( damageToDeal, owner, weapon.GetWeaponOwner(), { damageSourceId = damageSourceID } )
	}
}
#endif // SERVER

vector function GetVectorFromPositionToCrosshair( entity player, vector startPos )
{
	Assert( IsValid( player ) )

	// See where we're looking
	vector traceStart = player.EyePosition()
	vector traceEnd = traceStart + ( player.GetViewVector() * 20000 )
	local ignoreEnts = [ player ]
	TraceResults traceResult = TraceLine( traceStart, traceEnd, ignoreEnts, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_NONE )

	// Return vec from startPos to where we are looking
	vector vec = traceResult.endPos - startPos
	vec = Normalize( vec )
	return vec
}

/*
function InitMissileForRandomDriftBasic( missile, startPos, startDir )
{
	missile.s.RandomFloatRange <- RandomFloat( 1.0 )
	missile.s.startPos <- startPos
	missile.s.startDir <- startDir
}
*/

function InitMissileForRandomDriftForVortexHigh( entity missile, vector startPos, vector startDir )
{
	missile.InitMissileForRandomDrift( startPos, startDir, 8, 2.5, 0, 0, 100, 100 )
}

function InitMissileForRandomDriftForVortexLow( entity missile, vector startPos, vector startDir )
{
	missile.InitMissileForRandomDrift( startPos, startDir, 0.3, 0.085, 0, 0, 0.5, 0.5 )
}

/*
function InitMissileForRandomDrift( missile, startPos, startDir )
{
	InitMissileForRandomDriftBasic( missile, startPos, startDir )

	missile.s.drift_windiness <- missile.ProjectileGetWeaponInfoFileKeyField( "projectile_drift_windiness" )
	missile.s.drift_intensity <- missile.ProjectileGetWeaponInfoFileKeyField( "projectile_drift_intensity" )

	missile.s.straight_time_min <- missile.ProjectileGetWeaponInfoFileKeyField( "projectile_straight_time_min" )
	missile.s.straight_time_max <- missile.ProjectileGetWeaponInfoFileKeyField( "projectile_straight_time_max" )

	missile.s.straight_radius_min <- missile.ProjectileGetWeaponInfoFileKeyField( "projectile_straight_radius_min" )
	if ( missile.s.straight_radius_min < 1 )
		missile.s.straight_radius_min = 1
	missile.s.straight_radius_max <- missile.ProjectileGetWeaponInfoFileKeyField( "projectile_straight_radius_max" )
	if ( missile.s.straight_radius_max < 1 )
		missile.s.straight_radius_max = 1
}

function SmoothRandom( x )
{
	return 0.25 * (sin(x) + sin(x * 0.762) + sin(x * 0.363) + sin(x * 0.084))
}

function MissileRandomDrift( timeElapsed, timeStep, windiness, intensity )
{
	// This function makes the missile go in a random direction.
	// Windiness is how frequently the missile changes direction.
	// Intensity is how strongly the missile steers in the direction it has chosen.

	local sampleTime = timeElapsed - timeStep * 0.5

	intensity *= timeStep

	local offset = self.s.RandomFloatRange * 1000

	local offsetx = intensity * SmoothRandom( offset     +       sampleTime * windiness )
	local offsety = intensity * SmoothRandom( offset * 2 + 100 + sampleTime * windiness )

	local right = self.GetRightVector()
	local up = self.GetUpVector()

	//DebugDrawLine( self.GetOrigin(), self.GetOrigin() + right * 100, 255,255,255, true, 0 )
	//DebugDrawLine( self.GetOrigin(), self.GetOrigin() + up * 100, 255,128,255, true, 0 )

	local dir = self.GetVelocity()
	local speed = Length( dir )
	dir = Normalize( dir )
	dir += right * offsetx
	dir += up * offsety
	dir = Normalize( dir )
	dir *= speed

	return dir
}

// designed to be called every frame (GetProjectileVelocity callback) on projectiles that are flying through the air
function ApplyMissileControlledDrift( missile, timeElapsed, timeStep )
{
	// If we have a target, don't do anything fancy; just let code do the homing behavior
	if ( missile.GetMissileTarget() )
		return missile.GetVelocity()

	local s = missile.s
	return MissileControlledDrift( timeElapsed, timeStep, s.drift_windiness, s.drift_intensity, s.straight_time_min, s.straight_time_max, s.straight_radius_min, s.straight_radius_max )
}

function MissileControlledDrift( timeElapsed, timeStep, windiness, intensity, pathTimeMin, pathTimeMax, pathRadiusMin, pathRadiusMax )
{
	// Start with random drift.
	local vel = MissileRandomDrift( timeElapsed, timeStep, windiness, intensity )

	// Straighten our velocity back along our original path if we're below pathTimeMax.
	// Path time is how long it tries to stay on a straight path.
	// Path radius is how far it can get from its straight path.
	if ( timeElapsed < pathTimeMax )
	{
		local org = self.GetOrigin()
		local alongPathLen = self.s.startDir.Dot( org - self.s.startPos )
		local alongPathPos = self.s.startPos + self.s.startDir * alongPathLen
		local offPathOffset = org - alongPathPos
		local pathDist = Length( offPathOffset )

		local speed = Length( vel )

		local lerp = 1
		if ( timeElapsed > pathTimeMin )
			lerp = 1.0 - (timeElapsed - pathTimeMin) / (pathTimeMax - pathTimeMin)

		local pathRadius = pathRadiusMax + (pathRadiusMin - pathRadiusMax) * lerp

		// This circle shows the radius the missile is allowed to be in.
		//if ( IsServer() )
		//	DebugDrawCircle( alongPathPos, VectorToAngles( AnglesToUp( VectorToAngles( self.s.startDir ) ) ), pathRadius, 255,255,255, true, 0.0 )

		local backToPathVel = offPathOffset * -1
		// Cap backToPathVel at speed
		if ( pathDist > pathRadius )
			backToPathVel *= speed / pathDist
		else
			backToPathVel *= speed / pathRadius

		if ( pathDist < pathRadius )
		{
			backToPathVel += self.s.startDir * (speed * (1.0 - pathDist / pathRadius))
		}

		//DebugDrawLine( org, org + vel * 0.1, 255,255,255, true, 0 )
		//DebugDrawLine( org, org + backToPathVel * intensity * lerp * 0.1, 128,255,128, true, 0 )

		vel += backToPathVel * (intensity * timeStep)
		vel = Normalize( vel )
		vel *= speed
	}

	return vel
}
*/

#if SERVER
function ClusterRocket_Detonate( entity rocket, vector normal )
{
	entity owner = rocket.GetOwner()
	if ( !IsValid( owner ) )
		return

	int count
	float duration
	float range

	array mods = rocket.ProjectileGetMods()
	if ( mods.contains( "pas_northstar_cluster" ) )
	{
		count = CLUSTER_ROCKET_BURST_COUNT_BURN
		duration = PAS_NORTHSTAR_CLUSTER_ROCKET_DURATION
		range = CLUSTER_ROCKET_BURST_RANGE * 1.5
	}
	else
	{
		count = CLUSTER_ROCKET_BURST_COUNT
		duration = CLUSTER_ROCKET_DURATION
		range = CLUSTER_ROCKET_BURST_RANGE
	}

	if ( mods.contains( "fd_twin_cluster" ) )
	{
		count = int( count * 0.7 )
		duration *= 0.7
	}
	PopcornInfo popcornInfo

	popcornInfo.weaponName = "mp_titanweapon_dumbfire_rockets"
	popcornInfo.weaponMods = mods
	popcornInfo.damageSourceId = eDamageSourceId.mp_titanweapon_dumbfire_rockets
	popcornInfo.count = count
	popcornInfo.delay = CLUSTER_ROCKET_BURST_DELAY
	popcornInfo.offset = CLUSTER_ROCKET_BURST_OFFSET
	popcornInfo.range = range
	popcornInfo.normal = normal
	popcornInfo.duration = duration
	popcornInfo.groupSize = CLUSTER_ROCKET_BURST_GROUP_SIZE
	popcornInfo.hasBase = true

	thread StartClusterExplosions( rocket, owner, popcornInfo, CLUSTER_ROCKET_FX_TABLE )
}


function StartClusterExplosions( entity projectile, entity owner, PopcornInfo popcornInfo, customFxTable = null )
{
	Assert( IsValid( owner ) )
	owner.EndSignal( "OnDestroy" )

	string weaponName = popcornInfo.weaponName
	float innerRadius
	float outerRadius
	int explosionDamage
	int explosionDamageHeavyArmor

	innerRadius = projectile.GetProjectileWeaponSettingFloat( eWeaponVar.explosion_inner_radius )
	outerRadius = projectile.GetProjectileWeaponSettingFloat( eWeaponVar.explosionradius )
	if ( owner.IsPlayer() )
	{
		explosionDamage = projectile.GetProjectileWeaponSettingInt( eWeaponVar.explosion_damage )
		explosionDamageHeavyArmor = projectile.GetProjectileWeaponSettingInt( eWeaponVar.explosion_damage_heavy_armor )
	}
	else
	{
		explosionDamage = projectile.GetProjectileWeaponSettingInt( eWeaponVar.npc_explosion_damage )
		explosionDamageHeavyArmor = projectile.GetProjectileWeaponSettingInt( eWeaponVar.npc_explosion_damage_heavy_armor )
	}

	local explosionDelay = projectile.ProjectileGetWeaponInfoFileKeyField( "projectile_explosion_delay" )

	if ( owner.IsPlayer() )
		owner.EndSignal( "OnDestroy" )

	vector origin = projectile.GetOrigin()

	vector rotateFX = Vector( 90,0,0 )
	entity placementHelper = CreateScriptMover()
	placementHelper.SetOrigin( origin )
	placementHelper.SetAngles( VectorToAngles( popcornInfo.normal ) )
	SetTeam( placementHelper, owner.GetTeam() )

	array<entity> players = GetPlayerArray()
	foreach ( player in players )
	{
		Remote_CallFunction_NonReplay( player, "SCB_AddGrenadeIndicatorForEntity", owner.GetTeam(), owner.GetEncodedEHandle(), placementHelper.GetEncodedEHandle(), outerRadius )
	}

	int particleSystemIndex = GetParticleSystemIndex( CLUSTER_BASE_FX )
	int attachId = placementHelper.LookupAttachment( "REF" )
	entity fx

	if ( popcornInfo.hasBase )
	{
		fx = StartParticleEffectOnEntity_ReturnEntity( placementHelper, particleSystemIndex, FX_PATTACH_POINT_FOLLOW, attachId )
		EmitSoundOnEntity( placementHelper, "Explo_ThermiteGrenade_Impact_3P" ) // TODO: wants a custom sound
	}

	OnThreadEnd(
		function() : ( fx, placementHelper )
		{
			if ( IsValid( fx ) )
				EffectStop( fx )
			placementHelper.Destroy()
		}
	)

	if ( explosionDelay )
		wait explosionDelay

	waitthread ClusterRocketBursts( origin, explosionDamage, explosionDamageHeavyArmor, innerRadius, outerRadius, owner, popcornInfo, customFxTable )

	if ( IsValid( projectile ) )
		projectile.Destroy()
}


//------------------------------------------------------------
// ClusterRocketBurst() - does a "popcorn airburst" explosion effect over time around the origin. Total distance is based on popRangeBase
// - returns the entity in case you want to parent it
//------------------------------------------------------------
function ClusterRocketBursts( vector origin, int damage, int damageHeavyArmor, float innerRadius, float outerRadius, entity owner, PopcornInfo popcornInfo, customFxTable = null )
{
	owner.EndSignal( "OnDestroy" )

	// this ent remembers the weapon mods
	entity clusterExplosionEnt = CreateEntity( "info_target" )
	DispatchSpawn( clusterExplosionEnt )

	if ( popcornInfo.weaponMods.len() > 0 )
		clusterExplosionEnt.s.weaponMods <- popcornInfo.weaponMods

	clusterExplosionEnt.SetOwner( owner )
	clusterExplosionEnt.SetOrigin( origin )

	AI_CreateDangerousArea_Static( clusterExplosionEnt, null, outerRadius, TEAM_INVALID, true, true, origin )

	OnThreadEnd(
		function() : ( clusterExplosionEnt )
		{
			clusterExplosionEnt.Destroy()
		}
	)

	// No Damage - Only Force
	// Push players
	// Test LOS before pushing
	int flags = 11
	// create a blast that knocks pilots out of the way
	CreatePhysExplosion( origin, outerRadius, PHYS_EXPLOSION_LARGE, flags )

	int count = popcornInfo.groupSize
	for ( int index = 0; index < count; index++ )
	{
		thread ClusterRocketBurst( clusterExplosionEnt, origin, damage, damageHeavyArmor, innerRadius, outerRadius, owner, popcornInfo, customFxTable )
		WaitFrame()
	}

	wait CLUSTER_ROCKET_DURATION
}

function ClusterRocketBurst( entity clusterExplosionEnt, vector origin, damage, damageHeavyArmor, innerRadius, outerRadius, entity owner, PopcornInfo popcornInfo, customFxTable = null )
{
	clusterExplosionEnt.EndSignal( "OnDestroy" )
	Assert( IsValid( owner ), "ClusterRocketBurst had invalid owner" )

	// first explosion always happens where you fired
	//int eDamageSource = popcornInfo.damageSourceId
	int numBursts = popcornInfo.count
	float popRangeBase = popcornInfo.range
	float popDelayBase = popcornInfo.delay
	float popDelayRandRange = popcornInfo.offset
	float duration = popcornInfo.duration
	int groupSize = popcornInfo.groupSize

	int counter = 0
	vector randVec
	float randRangeMod
	float popRange
	vector popVec
	vector popOri = origin
	float popDelay
	float colTrace

	float burstDelay = duration / ( numBursts / groupSize )

	vector clusterBurstOrigin = origin + (popcornInfo.normal * 8.0)
	entity clusterBurstEnt = CreateClusterBurst( clusterBurstOrigin )

	OnThreadEnd(
		function() : ( clusterBurstEnt )
		{
			if ( IsValid( clusterBurstEnt ) )
			{
				foreach ( fx in clusterBurstEnt.e.fxArray )
				{
					if ( IsValid( fx ) )
						fx.Destroy()
				}
				clusterBurstEnt.Destroy()
			}
		}
	)

	while ( IsValid( clusterBurstEnt ) && counter <= numBursts / popcornInfo.groupSize )
	{
		randVec = RandomVecInDome( popcornInfo.normal )
		randRangeMod = RandomFloat( 1.0 )
		popRange = popRangeBase * randRangeMod
		popVec = randVec * popRange
		popOri = origin + popVec
		popDelay = popDelayBase + RandomFloatRange( -popDelayRandRange, popDelayRandRange )

		colTrace = TraceLineSimple( origin, popOri, null )
		if ( colTrace < 1 )
		{
			popVec = popVec * colTrace
			popOri = origin + popVec
		}

		clusterBurstEnt.SetOrigin( clusterBurstOrigin )

		vector velocity = GetVelocityForDestOverTime( clusterBurstEnt.GetOrigin(), popOri, burstDelay - popDelay )
		clusterBurstEnt.SetVelocity( velocity )

		clusterBurstOrigin = popOri

		counter++

		wait burstDelay - popDelay

		Explosion(
			clusterBurstOrigin,
			owner,
			clusterExplosionEnt,
			damage,
			damageHeavyArmor,
			innerRadius,
			outerRadius,
			SF_ENVEXPLOSION_NOSOUND_FOR_ALLIES,
			clusterBurstOrigin,
			damage,
			damageTypes.explosive,
			popcornInfo.damageSourceId,
			customFxTable )
	}
}


entity function CreateClusterBurst( vector origin )
{
	entity prop_physics = CreateEntity( "prop_physics" )
	prop_physics.SetValueForModelKey( $"models/weapons/bullets/projectile_rocket.mdl" )
	prop_physics.kv.spawnflags = 4 // 4 = SF_PHYSPROP_DEBRIS
	prop_physics.kv.fadedist = 2000
	prop_physics.kv.renderamt = 255
	prop_physics.kv.rendercolor = "255 255 255"
	prop_physics.kv.CollisionGroup = TRACE_COLLISION_GROUP_DEBRIS

	prop_physics.kv.minhealthdmg = 9999
	prop_physics.kv.nodamageforces = 1
	prop_physics.kv.inertiaScale = 1.0

	prop_physics.SetOrigin( origin )
	DispatchSpawn( prop_physics )
	prop_physics.SetModel( $"models/weapons/grenades/m20_f_grenade.mdl" )

	entity fx = PlayFXOnEntity( $"P_wpn_dumbfire_burst_trail", prop_physics )
	prop_physics.e.fxArray.append( fx )

	return prop_physics
}
#endif // SERVER

vector function GetVelocityForDestOverTime( vector startPoint, vector endPoint, float duration )
{
	const GRAVITY = 750

	float Vox = (endPoint.x - startPoint.x) / duration
	float Voy = (endPoint.y - startPoint.y) / duration
	float Voz = (endPoint.z + 0.5 * GRAVITY * duration * duration - startPoint.z) / duration

	return Vector( Vox, Voy, Voz )
}

vector function GetPlayerVelocityForDestOverTime( vector startPoint, vector endPoint, float duration )
{
	// Same as above but accounts for player gravity setting not being 1.0

	float gravityScale = expect float( GetPlayerSettingsFieldForClassName( DEFAULT_PILOT_SETTINGS, "gravityscale" ) )
	float GRAVITY = 750 * gravityScale // adjusted for new gravity scale

	float Vox = (endPoint.x - startPoint.x) / duration
	float Voy = (endPoint.y - startPoint.y) / duration
	float Voz = (endPoint.z + 0.5 * GRAVITY * duration * duration - startPoint.z) / duration

	return Vector( Vox, Voy, Voz )
}

bool function HasLockedTarget( weapon )
{
	if ( weapon.SmartAmmo_IsEnabled() )
	{
		local targets = weapon.SmartAmmo_GetTargets()
		if ( targets.len() > 0 )
		{
			foreach ( target in targets )
			{
				if ( target.fraction == 1 )
					return true
			}
		}
	}
	return false
}

function CanWeaponShootWhileRunning( entity weapon )
{
	if ( "primary_fire_does_not_block_sprint" in weapon.s )
		return weapon.s.primary_fire_does_not_block_sprint

	if ( weapon.GetWeaponInfoFileKeyField( "primary_fire_does_not_block_sprint" ) == 1 )
	{
		weapon.s.primary_fire_does_not_block_sprint <- true
		return true
	}

	weapon.s.primary_fire_does_not_block_sprint <- false
	return false
}

#if CLIENT
function ServerCallback_GuidedMissileDestroyed()
{
	entity player = GetLocalViewPlayer()

	// guided missiles has not been updated to work with replays. added this if statement defensively just in case. - Roger
	if ( !( "missileInFlight" in player.s ) )
		return

	player.s.missileInFlight = false
}

function ServerCallback_AirburstIconUpdate( toggle )
{
	entity player = GetLocalViewPlayer()
	entity cockpit = player.GetCockpit()
	if ( cockpit )
	{
		entity mainVGUI = cockpit.e.mainVGUI
		if ( mainVGUI )
		{
			if ( toggle )
				cockpit.s.offhandHud[OFFHAND_RIGHT].icon.SetImage( $"vgui/HUD/dpad_airburst_activate" )
			else
				cockpit.s.offhandHud[OFFHAND_RIGHT].icon.SetImage( $"vgui/HUD/dpad_airburst" )
		}
	}
}

bool function IsOwnerViewPlayerFullyADSed( entity weapon )
{
	entity owner = weapon.GetOwner()
	if ( !IsValid( owner ) )
		return false

	if( !owner.IsPlayer() )
		return false

	if ( owner != GetLocalViewPlayer() )
		return false

	float zoomFrac = owner.GetZoomFrac()
	if ( zoomFrac < 1.0 )
		return false

	return true

}
#endif // CLIENT

array<entity> function FireExpandContractMissiles( entity weapon, WeaponPrimaryAttackParams attackParams, vector attackPos, vector attackDir, int damageType, int explosionDamageType, shouldPredict, int rocketsPerShot, missileSpeed, launchOutAng, launchOutTime, launchInAng, launchInTime, launchInLerpTime, launchStraightLerpTime, applyRandSpread, int burstFireCountOverride = -1, debugDrawPath = false )
{
	local missileVecs = GetExpandContractRocketTrajectories( weapon, attackParams.burstIndex, attackPos, attackDir, rocketsPerShot, launchOutAng, launchInAng, burstFireCountOverride )
	entity owner = weapon.GetWeaponOwner()
	array<entity> firedMissiles

	vector missileEndPos = owner.EyePosition() + ( attackDir * 5000 )

	for ( int i = 0; i < rocketsPerShot; i++ )
	{
		entity missile = weapon.FireWeaponMissile( attackPos, attackDir, missileSpeed, damageType, explosionDamageType, false, shouldPredict )

		if ( missile )
		{
			/*
			missile.s.flightData <- {
								launchOutVec = missileVecs[i].outward,
								launchOutTime = launchOutTime,
								launchInLerpTime = launchInLerpTime,
								launchInVec = missileVecs[i].inward,
								launchInTime = launchInTime,
								launchStraightLerpTime = launchStraightLerpTime,
								endPos = missileEndPos,
								applyRandSpread = applyRandSpread
							}
			*/

			missile.InitMissileExpandContract( missileVecs[i].outward, missileVecs[i].inward, launchOutTime, launchInLerpTime, launchInTime, launchStraightLerpTime, missileEndPos, applyRandSpread )

			if ( IsServer() && debugDrawPath )
				thread DebugDrawMissilePath( missile )

			//InitMissileForRandomDrift( missile, attackPos, attackDir )
			missile.InitMissileForRandomDriftFromWeaponSettings( attackPos, attackDir )

			firedMissiles.append( missile )
		}
	}

	return firedMissiles
}

array<entity> function FireExpandContractMissiles_S2S( entity weapon, WeaponPrimaryAttackParams attackParams, vector attackPos, vector attackDir, shouldPredict, int rocketsPerShot, missileSpeed, launchOutAng, launchOutTime, launchInAng, launchInTime, launchInLerpTime, launchStraightLerpTime, applyRandSpread, int burstFireCountOverride = -1, debugDrawPath = false )
{
	local missileVecs = GetExpandContractRocketTrajectories( weapon, attackParams.burstIndex, attackPos, attackDir, rocketsPerShot, launchOutAng, launchInAng, burstFireCountOverride )
	entity owner = weapon.GetWeaponOwner()
	array<entity> firedMissiles

	vector missileEndPos = attackPos + ( attackDir * 5000 )

	for ( int i = 0; i < rocketsPerShot; i++ )
	{
		entity missile = weapon.FireWeaponMissile( attackPos, attackDir, missileSpeed, DF_GIB | DF_IMPACT, damageTypes.explosive, false, shouldPredict )
		missile.SetOrigin( attackPos )//HACK why do I have to do this?
		if ( missile )
		{
			/*
			missile.s.flightData <- {
								launchOutVec = missileVecs[i].outward,
								launchOutTime = launchOutTime,
								launchInLerpTime = launchInLerpTime,
								launchInVec = missileVecs[i].inward,
								launchInTime = launchInTime,
								launchStraightLerpTime = launchStraightLerpTime,
								endPos = missileEndPos,
								applyRandSpread = applyRandSpread
							}
			*/

			missile.InitMissileExpandContract( missileVecs[i].outward, missileVecs[i].inward, launchOutTime, launchInLerpTime, launchInTime, launchStraightLerpTime, missileEndPos, applyRandSpread )

			if ( IsServer() && debugDrawPath )
				thread DebugDrawMissilePath( missile )

			//InitMissileForRandomDrift( missile, attackPos, attackDir )
			missile.InitMissileForRandomDriftFromWeaponSettings( attackPos, attackDir )

			firedMissiles.append( missile )
		}
	}

	return firedMissiles
}

function GetExpandContractRocketTrajectories( entity weapon, int burstIndex, vector attackPos, vector attackDir, int rocketsPerShot, launchOutAng, launchInAng, int burstFireCount = -1 )
{
	bool DEBUG_DRAW_MATH = false

	if ( burstFireCount == -1 )
		burstFireCount = weapon.GetWeaponBurstFireCount()

	local additionalRotation = ( ( 360.0 / rocketsPerShot ) / burstFireCount ) * burstIndex
	//printt( "burstIndex:", burstIndex )
	//printt( "rocketsPerShot:", rocketsPerShot )
	//printt( "burstFireCount:", burstFireCount )

	vector ang = VectorToAngles( attackDir )
	vector forward = AnglesToForward( ang )
	vector right = AnglesToRight( ang )
	vector up = AnglesToUp( ang )

	if ( DEBUG_DRAW_MATH )
		DebugDrawLine( attackPos, attackPos + ( forward * 1000 ), 255, 0, 0, true, 30.0 )

	// Create points on circle
	float offsetAng = 360.0 / rocketsPerShot
	for ( int i = 0; i < rocketsPerShot; i++ )
	{
		local a = offsetAng * i + additionalRotation
		vector vec = Vector( 0, 0, 0 )
		vec += up * deg_sin( a )
		vec += right * deg_cos( a )

		if ( DEBUG_DRAW_MATH )
			DebugDrawLine( attackPos, attackPos + ( vec * 50 ), 10, 10, 10, true, 30.0 )
	}

	// Create missile points
	vector x = right * deg_sin( launchOutAng )
	vector y = up * deg_sin( launchOutAng )
	vector z = forward * deg_cos( launchOutAng )
	vector rx = right * deg_sin( launchInAng )
	vector ry = up * deg_sin( launchInAng )
	vector rz = forward * deg_cos( launchInAng )
	local missilePoints = []
	for ( int i = 0; i < rocketsPerShot; i++ )
	{
		local points = {}

		// Outward vec
		local a = offsetAng * i + additionalRotation
		float s = deg_sin( a )
		float c = deg_cos( a )
		vector vecOut = z + x * c + y * s
		vecOut = Normalize( vecOut )
		points.outward <- vecOut

		// Inward vec
		vector vecIn = rz + rx * c + ry * s
		points.inward <- vecIn

		// Add to array
		missilePoints.append( points )

		if ( DEBUG_DRAW_MATH )
		{
			DebugDrawLine( attackPos, attackPos + ( vecOut * 50 ), 255, 255, 0, true, 30.0 )
			DebugDrawLine( attackPos + vecOut * 50, attackPos + vecOut * 50 + ( vecIn * 50 ), 255, 0, 255, true, 30.0 )
		}
	}

	return missilePoints
}

function DebugDrawMissilePath( entity missile )
{
	EndSignal( missile, "OnDestroy" )
	vector lastPos = missile.GetOrigin()
	while ( true )
	{
		WaitFrame()
		if ( !IsValid( missile ) )
			return
		DebugDrawLine( lastPos, missile.GetOrigin(), 0, 255, 0, true, 20.0 )
		lastPos = missile.GetOrigin()
	}
}


function RegenerateOffhandAmmoOverTime( entity weapon, float rechargeTime, int maxAmmo, int offhandIndex )
{
	weapon.Signal( "RegenAmmo" )
	weapon.EndSignal( "RegenAmmo" )
	weapon.EndSignal( "OnDestroy" )

	#if CLIENT
	entity weaponOwner = weapon.GetWeaponOwner()
	if ( IsValid( weaponOwner ) && weaponOwner.IsPlayer() )
	{
		entity cockpit = weaponOwner.GetCockpit()
		if ( IsValid( cockpit ) )
		{
			cockpit.s.offhandHud[offhandIndex].bar.SetBarProgressSource( ProgressSource.PROGRESS_SOURCE_SCRIPTED )
			cockpit.s.offhandHud[offhandIndex].bar.SetBarProgressRemap( 0.0, 1.0, 0.0, 1.0 )
			cockpit.s.offhandHud[offhandIndex].bar.SetBarProgressAndRate( 1.0 / maxAmmo , 1 / ( rechargeTime * maxAmmo ) )
		}
	}
	#endif

	if ( !( "totalChargeTime" in weapon.s ) )
		weapon.s.totalChargeTime <- rechargeTime

	if ( !( "nextChargeTime" in weapon.s ) )
		weapon.s.nextChargeTime <- null

	for ( ;; )
	{
		weapon.s.nextChargeTime = rechargeTime + Time()

		wait rechargeTime

		if ( IsServer() )
		{
			int max = maxAmmo
			int weaponMax = weapon.GetWeaponPrimaryClipCountMax()
			if ( weaponMax < max )
				max = weaponMax

			int ammo = weapon.GetWeaponPrimaryClipCount()
			if ( ammo < max )
				weapon.SetWeaponPrimaryClipCount( ammo + 1 )
		}
	}
}

bool function IsPilotShotgunWeapon( string weaponName )
{
	return GetWeaponInfoFileKeyField_Global( weaponName, "weaponSubClass" ) == "shotgun"
}

array<string> function GetWeaponBurnMods( string weaponClassName )
{
	array<string> burnMods = []
	array<string> mods = GetWeaponMods_Global( weaponClassName )
	string prefix = "burn_mod"
	foreach ( mod in mods )
	{
		if ( mod.find( prefix ) == 0 )
			burnMods.append( mod )
	}

	return burnMods
}

int function TEMP_GetDamageFlagsFromProjectile( entity projectile )
{
	var damageFlagsString = projectile.ProjectileGetWeaponInfoFileKeyField( "damage_flags" )
	if ( damageFlagsString == null )
		return 0
	expect string( damageFlagsString )

	return TEMP_GetDamageFlagsFromString( damageFlagsString )
}

int function TEMP_GetDamageFlagsFromString( string damageFlagsString )
{
	int damageFlags = 0

	array<string> damageFlagTokens = split( damageFlagsString, "|" )
	foreach ( token in damageFlagTokens )
	{
		damageFlags = damageFlags | getconsttable()[strip(token)]
	}

	return damageFlags
}

#if SERVER
function PROTO_InitTrackedProjectile( entity projectile )
{
	// HACK: accessing ProjectileGetWeaponInfoFileKeyField or ProjectileGetWeaponClassName during CodeCallback_OnSpawned causes a code assert
	projectile.EndSignal( "OnDestroy" )
	WaitFrame()

	entity owner = projectile.GetOwner()

	if ( !IsValid( owner ) || !owner.IsPlayer() )
		return

	int maxDeployed = projectile.GetProjectileWeaponSettingInt( eWeaponVar.projectile_max_deployed )
	if ( maxDeployed != 0 )
	{
		AddToScriptManagedEntArray( owner.s.activeTrapArrayId, projectile )

		array<entity> traps = GetScriptManagedEntArray( owner.s.activeTrapArrayId )
		array<entity> sameTypeTrapEnts
		foreach ( ent in traps )
		{
			if ( ent.ProjectileGetWeaponClassName() != projectile.ProjectileGetWeaponClassName() )
				continue

			sameTypeTrapEnts.append( ent )
		}

		int numToDestroy = sameTypeTrapEnts.len() - maxDeployed
		if ( numToDestroy > 0 )
		{
			sameTypeTrapEnts.sort( CompareCreation )
			foreach ( ent in sameTypeTrapEnts )
			{
				ent.Destroy()
				numToDestroy--

				if ( !numToDestroy )
					break
			}
		}
	}
}


function PROTO_CleanupTrackedProjectiles( entity player )
{
	array<entity> traps = GetScriptManagedEntArray( player.s.activeTrapArrayId )
	foreach ( ent in traps )
	{
		ent.Destroy()
	}
}

int function CompareCreation( entity a, entity b )
{
	if ( a.GetProjectileCreationTime() > b.GetProjectileCreationTime() )
		return 1

	return -1
}

int function CompareCreationReverse( entity a, entity b )
{
	if ( a.GetProjectileCreationTime() > b.GetProjectileCreationTime() )
		return 1

	return -1
}

void function PROTO_TrackedProjectile_OnPlayerRespawned( entity player )
{
	thread PROTO_TrackedProjectile_OnPlayerRespawned_Internal( player )
}

void function PROTO_TrackedProjectile_OnPlayerRespawned_Internal( entity player )
{
	player.EndSignal( "OnDeath" )

	if ( player.s.inGracePeriod )
		player.WaitSignal( "GracePeriodDone" )

	entity ordnance = player.GetOffhandWeapon( OFFHAND_ORDNANCE )

	array<entity> traps = GetScriptManagedEntArray( player.s.activeTrapArrayId )
	foreach ( ent in traps )
	{
		if ( ordnance && ent.ProjectileGetWeaponClassName() == ordnance.GetWeaponClassName() )
			continue

		ent.Destroy()
	}
}

function PROTO_PlayTrapLightEffect( entity ent, string tag, int team )
{
	asset ownerFx = ent.ProjectileGetWeaponInfoFileKeyFieldAsset( "trap_warning_owner_fx" )
	if ( ownerFx != $"" )
	{
		entity ownerFxEnt = CreateServerEffect_Owner( ownerFx, ent.GetOwner() )
		SetServerEffectControlPoint( ownerFxEnt, 0, FRIENDLY_COLOR  )
		StartServerEffectOnEntity( ownerFxEnt, ent, tag )
	}

	asset friendlyFx = ent.ProjectileGetWeaponInfoFileKeyFieldAsset( "trap_warning_friendly_fx" )
	if ( friendlyFx != $"" )
	{
		entity friendlyFxEnt = CreateServerEffect_Friendly( friendlyFx, team )
		SetServerEffectControlPoint( friendlyFxEnt, 0, FRIENDLY_COLOR_FX )
		StartServerEffectOnEntity( friendlyFxEnt, ent, tag )
	}

	asset enemyFx = ent.ProjectileGetWeaponInfoFileKeyFieldAsset( "trap_warning_enemy_fx" )
	if ( enemyFx != $"" )
	{
		entity enemyFxEnt = CreateServerEffect_Enemy( enemyFx, team )
		SetServerEffectControlPoint( enemyFxEnt, 0, ENEMY_COLOR_FX )
		StartServerEffectOnEntity( enemyFxEnt, ent, tag )
	}
}

string ornull function GetCooldownBeepPrefix( weapon )
{
	var reloadBeepPrefix = weapon.GetWeaponInfoFileKeyField( "cooldown_sound_prefix" )
	if ( reloadBeepPrefix == null )
		return null

	expect string( reloadBeepPrefix )

	return reloadBeepPrefix
}

void function PROTO_DelayCooldown( entity weapon )
{
	weapon.s.nextCooldownTime = Time() + weapon.s.cooldownDelay
}

string function GetBeepSuffixForAmmo( int currentAmmo, int maxAmmo )
{
	float frac = float( currentAmmo ) / float( maxAmmo )

	if ( frac >= 1.0 )
		return "_full"

	if ( frac >= 0.25 )
		return ""

	return "_low"
}

#endif //SERVER

bool function PROTO_CanPlayerDeployWeapon( entity player )
{
	if ( player.IsPhaseShifted() )
		return false

	if ( player.ContextAction_IsActive() == true )
	{
		if ( player.IsZiplining() )
			return true
		else
			return false
	}

	return true
}

#if SERVER
void function PROTO_FlakCannonMissiles( entity projectile, float speed )
{
	projectile.EndSignal( "OnDestroy" )

	float radius = projectile.GetProjectileWeaponSettingFloat( eWeaponVar.explosionradius )
	vector velocity = projectile.GetVelocity()
	vector currentPos = projectile.GetOrigin()
	int team = projectile.GetTeam()

	float waitTime = 0.1
	float distanceInterval = speed * waitTime
	int forwardDistanceChecks = int( ceil( distanceInterval / radius ) )
	bool forceExplosion = false
	while ( forceExplosion == false )
	{
		currentPos = projectile.GetOrigin()
		for ( int i = 0; i < forwardDistanceChecks; i++ )
		{
			float frac = float( i ) / float (forwardDistanceChecks )
			if ( PROTO_FlakCannon_HasNearbyEnemies( currentPos + velocity * waitTime * frac , team, radius ) )
			{
				if ( i == 0 )
				{
					forceExplosion = true
					break
				}
				else
				{
					projectile.SetVelocity( velocity * ( frac - 0.05 ) )
					break
				}
			}
		}

		if ( forceExplosion == false )
			wait waitTime
	}

	projectile.MissileExplode()
}

bool function PROTO_FlakCannon_HasNearbyEnemies( vector origin, int team, float radius )
{
	float worldSpaceCenterBuffer = 200

	array<entity> guys = GetPlayerArrayEx( "any", TEAM_ANY, team, origin, radius + worldSpaceCenterBuffer )
	foreach ( guy in guys )
	{
		if ( IsAlive( guy ) && Distance( origin, guy.GetWorldSpaceCenter() ) < radius )
			return true
	}

	array<entity> ai = GetNPCArrayEx( "any", TEAM_ANY, team, origin, radius + worldSpaceCenterBuffer )
	foreach ( guy in ai )
	{
		if ( IsAlive( guy ) && Distance( origin, guy.GetWorldSpaceCenter() ) < radius )
			return true
	}

	return false
}
#endif // #if SERVER

void function GiveEMPStunStatusEffects( entity ent, float duration, float fadeoutDuration = 0.5, float slowTurn = EMP_SEVERITY_SLOWTURN, float slowMove = EMP_SEVERITY_SLOWMOVE)
{
	entity target = ent.IsTitan() ? ent.GetTitanSoul() : ent
	int slowEffect = StatusEffect_AddTimed( target, eStatusEffect.turn_slow, slowTurn, duration, fadeoutDuration )
	int turnEffect = StatusEffect_AddTimed( target, eStatusEffect.move_slow, slowMove, duration, fadeoutDuration )

	#if SERVER
	if ( ent.IsPlayer() )
	{
		ent.p.empStatusEffectsToClearForPhaseShift.append( slowEffect )
		ent.p.empStatusEffectsToClearForPhaseShift.append( turnEffect )
	}
	#endif
}

#if DEV
string ornull function FindEnumNameForValue( table searchTable, int searchVal )
{
	foreach( string keyname, int value in searchTable )
	{
		if ( value == searchVal )
			return keyname;
	}
	return null
}

void function DevPrintAllStatusEffectsOnEnt( entity ent )
{
	printt( "Effects:", ent )
	array<float> effects = StatusEffect_GetAll( ent )
	int length = effects.len()
	int found = 0;
	for ( int idx = 0; idx < length; idx++ )
	{
		float severity = effects[idx];
		if ( severity <= 0.0 )
			continue
		string ornull name = FindEnumNameForValue( eStatusEffect, idx )
		Assert( name )
		expect string( name )
		printt( " eStatusEffect." + name + ": " + severity )
		found++;
	}
	printt( found + " effects active.\n" );
}
#endif // #if DEV

array<entity> function GetPrimaryWeapons( entity player )
{
	array<entity> primaryWeapons
	array<entity> weapons = player.GetMainWeapons()
	foreach ( weaponEnt in weapons )
	{
		int weaponType = weaponEnt.GetWeaponType()
		if ( weaponType == WT_SIDEARM || weaponType == WT_ANTITITAN )
			continue;

		primaryWeapons.append( weaponEnt )
	}
	return primaryWeapons
}

array<entity> function GetSidearmWeapons( entity player )
{
	array<entity> sidearmWeapons
	array<entity> weapons = player.GetMainWeapons()
	foreach ( weaponEnt in weapons )
	{
		if ( weaponEnt.GetWeaponType() != WT_SIDEARM )
			continue

		sidearmWeapons.append( weaponEnt )
	}
	return sidearmWeapons
}

array<entity> function GetATWeapons( entity player )
{
	array<entity> atWeapons
	array<entity> weapons = player.GetMainWeapons()
	foreach ( weaponEnt in weapons )
	{
		if ( weaponEnt.GetWeaponType() != WT_ANTITITAN )
			continue

		atWeapons.append( weaponEnt )
	}
	return atWeapons
}

entity function GetPlayerFromTitanWeapon( entity weapon )
{
	entity titan = weapon.GetWeaponOwner()
	entity player

	if ( titan == null )
		return null

	if ( !titan.IsPlayer() )
		player = titan.GetBossPlayer()
	else
		player = titan

	return player
}


const asset CHARGE_SHOT_PROJECTILE = $"models/weapons/bullets/temp_triple_threat_projectile_large.mdl"

const asset CHARGE_EFFECT_1P = $"P_ordnance_charge_st_FP" // $"P_wpn_defender_charge_FP"
const asset CHARGE_EFFECT_3P = $"P_ordnance_charge_st" // $"P_wpn_defender_charge"
const asset CHARGE_EFFECT_DLIGHT = $"defender_charge_CH_dlight"

const string CHARGE_SOUND_WINDUP_1P = "Weapon_ChargeRifle_WindUp_1P"
const string CHARGE_SOUND_WINDUP_3P = "Weapon_ChargeRifle_WindUp_3P"
const string CHARGE_SOUND_WINDDOWN_1P = "Weapon_ChargeRifle_WindDown_1P"
const string CHARGE_SOUND_WINDDOWN_3P = "Weapon_ChargeRifle_WindDown_3P"

void function ChargeBall_Precache()
{
#if SERVER
	PrecacheModel( CHARGE_SHOT_PROJECTILE )
	PrecacheEffect( CHARGE_EFFECT_1P )
	PrecacheEffect( CHARGE_EFFECT_3P )
#endif // #if SERVER
}

void function ChargeBall_FireProjectile( entity weapon, vector position, vector direction, bool shouldPredict )
{
	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	entity owner = weapon.GetWeaponOwner()
	const float MISSILE_SPEED = 1200.0
	const int CONTACT_DAMAGE_TYPES = (damageTypes.projectileImpact | DF_DOOM_FATALITY)
	const int EXPLOSION_DAMAGE_TYPES = damageTypes.explosive
	const bool DO_POPUP = false

	if ( shouldPredict )
	{
		entity missile = weapon.FireWeaponMissile( position, direction, MISSILE_SPEED, CONTACT_DAMAGE_TYPES, EXPLOSION_DAMAGE_TYPES, DO_POPUP, shouldPredict )
		if ( missile )
		{
			EmitSoundOnEntity( owner, "ShoulderRocket_Cluster_Fire_3P" )
			missile.SetModel( CHARGE_SHOT_PROJECTILE )
#if CLIENT
			const ROCKETEER_MISSILE_EXPLOSION = $"xo_exp_death"
			const ROCKETEER_MISSILE_SHOULDER_FX = $"wpn_mflash_xo_rocket_shoulder_FP"
			entity owner = weapon.GetWeaponOwner()
			vector origin = owner.OffsetPositionFromView( Vector(0, 0, 0), Vector(25, -25, 15) )
			vector angles = owner.CameraAngles()
			StartParticleEffectOnEntityWithPos( owner, GetParticleSystemIndex( ROCKETEER_MISSILE_SHOULDER_FX ), FX_PATTACH_EYES_FOLLOW, -1, origin, angles )
#else // #if CLIENT
			missile.SetProjectileImpactDamageOverride( 1440 )
			missile.kv.damageSourceId = eDamageSourceId.charge_ball
#endif // #else // #if CLIENT
		}
	}
}

bool function ChargeBall_ChargeBegin( entity weapon, string tagName )
{
#if CLIENT
	if ( InPrediction() && !IsFirstTimePredicted() )
		return true
#endif // #if CLIENT

	weapon.w.statusEffects.append( StatusEffect_AddEndless( weapon.GetWeaponOwner(), eStatusEffect.move_slow, 0.6 ) )
	weapon.w.statusEffects.append( StatusEffect_AddEndless( weapon.GetWeaponOwner(), eStatusEffect.turn_slow, 0.35 ) )

	weapon.PlayWeaponEffect( CHARGE_EFFECT_1P, CHARGE_EFFECT_3P, tagName )
	weapon.PlayWeaponEffect( $"", CHARGE_EFFECT_DLIGHT, tagName )

#if SERVER
	StopSoundOnEntity( weapon, CHARGE_SOUND_WINDDOWN_3P )
	entity weaponOwner = weapon.GetWeaponOwner()
	if ( IsValid( weaponOwner ) )
	{
		if ( weaponOwner.IsPlayer() )
			EmitSoundOnEntityExceptToPlayer( weapon, weaponOwner, CHARGE_SOUND_WINDUP_3P )
		else
			EmitSoundOnEntity( weapon, CHARGE_SOUND_WINDUP_3P )
	}
#else
	StopSoundOnEntity( weapon, CHARGE_SOUND_WINDDOWN_1P )
	EmitSoundOnEntity( weapon, CHARGE_SOUND_WINDUP_1P )
#endif

	return true
}

void function ChargeBall_ChargeEnd( entity weapon )
{
#if CLIENT
	if ( InPrediction() && !IsFirstTimePredicted() )
		return
#endif

	if ( IsValid( weapon.GetWeaponOwner() ) )
	{
		#if CLIENT
		if ( InPrediction() && IsFirstTimePredicted() )
		{
		#endif

			foreach ( effect in weapon.w.statusEffects )
			{
				StatusEffect_Stop( weapon.GetWeaponOwner(), effect )
			}

		#if CLIENT
		}
		#endif
	}

#if SERVER
	StopSoundOnEntity( weapon, CHARGE_SOUND_WINDUP_3P )
	entity weaponOwner = weapon.GetWeaponOwner()
	if ( IsValid( weaponOwner ) )
	{
		if ( weaponOwner.IsPlayer() )
			EmitSoundOnEntityExceptToPlayer( weapon, weaponOwner, CHARGE_SOUND_WINDDOWN_3P )
		else
			EmitSoundOnEntity( weapon, CHARGE_SOUND_WINDDOWN_3P )
	}
#else
	StopSoundOnEntity( weapon, CHARGE_SOUND_WINDUP_1P )
	EmitSoundOnEntity( weapon, CHARGE_SOUND_WINDDOWN_1P )
#endif

	ChargeBall_StopChargeEffects( weapon )
}

void function ChargeBall_StopChargeEffects( entity weapon )
{
	Assert( IsValid( weapon ) )
	// weapon.StopWeaponEffect( CHARGE_EFFECT_1P, CHARGE_EFFECT_3P )
	// weapon.StopWeaponEffect( CHARGE_EFFECT_3P, CHARGE_EFFECT_1P )
	// weapon.StopWeaponEffect( CHARGE_EFFECT_DLIGHT, CHARGE_EFFECT_DLIGHT )
	thread HACK_Deplayed_ChargeBall_StopChargeEffects( weapon )
}

void function HACK_Deplayed_ChargeBall_StopChargeEffects( entity weapon )
{
	weapon.EndSignal( "OnDestroy" )
	wait 0.2
	weapon.StopWeaponEffect( CHARGE_EFFECT_1P, CHARGE_EFFECT_3P )
	weapon.StopWeaponEffect( CHARGE_EFFECT_3P, CHARGE_EFFECT_1P )
	weapon.StopWeaponEffect( CHARGE_EFFECT_DLIGHT, CHARGE_EFFECT_DLIGHT )
}

float function ChargeBall_GetChargeTime()
{
	return 1.05
}

#if SERVER
void function GivePlayerAmpedWeapon( entity player, string weaponName )
{
	array<entity> weapons = player.GetMainWeapons()
	int numWeapons = weapons.len()
	if ( numWeapons == 0 )
		return

	//Figure out what weapon to take away.
	//This is more complicated than it should be because of rules of what weapons can be in what slots, e.g.  your anti-titan weapon can't be replaced by non anti-titan weapons
	if ( HasWeapon( player, weaponName ) )
	{
		//Simplest case:
		//Take away the currently existing version of the weapon you already have.
		player.TakeWeaponNow( weaponName )
	}
	else
	{
		bool ampedWeaponIsAntiTitan = GetWeaponInfoFileKeyField_Global( weaponName, "weaponType" ) == "anti_titan"
		if ( ampedWeaponIsAntiTitan )
		{
			foreach( weapon in weapons )
			{
				string currentWeaponClassName = weapon.GetWeaponClassName()
				if ( GetWeaponInfoFileKeyField_Global( currentWeaponClassName, "weaponType" ) == "anti_titan" )
				{
					player.TakeWeaponNow( currentWeaponClassName )
					break
				}
			}

			unreachable //We had no anti-titan weapon? Shouldn't ever be possible

		}
		else
		{
			string currentActiveWeaponClassName = player.GetActiveWeapon().GetWeaponClassName()
			if ( ShouldReplaceWeaponInFirstSlot( player, currentActiveWeaponClassName ) )
			{
				//Current weapon is anti_titan, but amped weapon we are trying to give is not. Just replace the weapon that is in the first slot.
				//Assumes that weapon in first slot is not an anti-titan weapon
				//We could get even fancier and look to see if the amped weapon is a primary weapon or a sidearm and replace the slot accordingly, but
				//that makes it more complicated, plus there are cases where you can have no primary weapons/no side arms etc
				string firstWeaponClassName = weapons[ 0 ].GetWeaponClassName()
				Assert( GetWeaponInfoFileKeyField_Global( firstWeaponClassName, "weaponType" ) != "anti_titan"  )
				player.TakeWeaponNow( firstWeaponClassName )
			}
			else
			{
				player.TakeWeaponNow( currentActiveWeaponClassName )
			}
		}
	}

	array<string> burnMods = GetWeaponBurnMods( weaponName )
	entity ampedWeapon = player.GiveWeapon( weaponName, burnMods )
	ampedWeapon.SetWeaponPrimaryClipCount( ampedWeapon.GetWeaponPrimaryClipCountMax() ) //Needed for weapons that give a mod with extra clip size
}

bool function ShouldReplaceWeaponInFirstSlot( entity player, string currentActiveWeaponClassName )
{
	if ( GetWeaponInfoFileKeyField_Global( currentActiveWeaponClassName, "weaponType" ) == "anti_titan" ) //Active weapon is anti-titan weapon. Can't replace anti-titan weapon slot with non-anti-titan weapon
		return true

	if ( currentActiveWeaponClassName == player.GetOffhandWeapon( OFFHAND_ORDNANCE ).GetWeaponClassName() )
		return true

	return false

}

void function GivePlayerAmpedWeaponAndSetAsActive( entity player, string weaponName )
{
	GivePlayerAmpedWeapon( player, weaponName )
	player.SetActiveWeaponByName( weaponName )
}

void function ReplacePlayerOffhand( entity player, string offhandName, array<string> mods = [] )
{
	player.TakeOffhandWeapon( OFFHAND_SPECIAL )
	player.GiveOffhandWeapon( offhandName, OFFHAND_SPECIAL, mods )
}

void function ReplacePlayerOrdnance( entity player, string ordnanceName, array<string> mods = [] )
{
	player.TakeOffhandWeapon( OFFHAND_ORDNANCE )
	player.GiveOffhandWeapon( ordnanceName, OFFHAND_ORDNANCE, mods )
}

void function PAS_CooldownReduction_OnKill( entity victim, entity attacker, var damageInfo )
{
	if ( !IsAlive( attacker ) || !IsPilot( attacker ) )
		return

	array<string> weaponMods = GetWeaponModsFromDamageInfo( damageInfo )

	if ( GetCurrentPlaylistVarInt( "featured_mode_tactikill", 0 ) > 0 )
	{
		entity weapon = attacker.GetOffhandWeapon( OFFHAND_LEFT )

		switch ( GetWeaponInfoFileKeyField_Global( weapon.GetWeaponClassName(), "cooldown_type" ) )
		{
			case "grapple":
				attacker.SetSuitGrapplePower( attacker.GetSuitGrapplePower() + 100 )
				break

			case "ammo":
			case "ammo_instant":
			case "ammo_deployed":
			case "ammo_timed":
				int maxAmmo = weapon.GetWeaponPrimaryClipCountMax()
				weapon.SetWeaponPrimaryClipCountNoRegenReset( maxAmmo )
				break

			case "chargeFrac":
				weapon.SetWeaponChargeFraction( 0 )
				break

	//		case "mp_ability_ground_slam":
	//			break

			default:
				Assert( false, weapon.GetWeaponClassName() + " needs to be updated to support cooldown_type setting" )
				break
		}
	}
	else
	{
		if ( !PlayerHasPassive( attacker, ePassives.PAS_CDR_ON_KILL ) && !weaponMods.contains( "tactical_cdr_on_kill" ) )
			return

		entity weapon = attacker.GetOffhandWeapon( OFFHAND_LEFT )

		switch ( GetWeaponInfoFileKeyField_Global( weapon.GetWeaponClassName(), "cooldown_type" ) )
		{
			case "grapple":
				attacker.SetSuitGrapplePower( attacker.GetSuitGrapplePower() + 25 )
				break

			case "ammo":
			case "ammo_instant":
			case "ammo_deployed":
			case "ammo_timed":
				int maxAmmo = weapon.GetWeaponPrimaryClipCountMax()
				weapon.SetWeaponPrimaryClipCountNoRegenReset( min( maxAmmo, weapon.GetWeaponPrimaryClipCount() + ( maxAmmo / 4 ) ) )
				break

			case "chargeFrac":
				weapon.SetWeaponChargeFraction( max( 0, weapon.GetWeaponChargeFraction() - 0.25 ) )
				break

	//		case "mp_ability_ground_slam":
	//			break

			default:
				Assert( false, weapon.GetWeaponClassName() + " needs to be updated to support cooldown_type setting" )
				break
		}
	}
}

void function DisableWeapons( entity player, array<string> excludeNames )
{
	array<entity> weapons = GetPlayerWeapons( player, excludeNames )
	foreach ( weapon in weapons )
		weapon.AllowUse( false )
}

void function EnableWeapons( entity player, array<string> excludeNames )
{
	array<entity> weapons = GetPlayerWeapons( player, excludeNames )
	foreach ( weapon in weapons )
		weapon.AllowUse( true )
}

array<entity> function GetPlayerWeapons( entity player, array<string> excludeNames )
{
	array<entity> weapons = player.GetMainWeapons()
	weapons.extend( player.GetOffhandWeapons() )

	for ( int idx = weapons.len() - 1; idx > 0; idx-- )
	{
		foreach ( excludeName in excludeNames )
		{
			if ( weapons[idx].GetWeaponClassName() == excludeName )
				weapons.remove( idx )
		}
	}

	return weapons
}

void function WeaponAttackWave( entity ent, int projectileCount, entity inflictor, vector pos, vector dir, bool functionref( entity, int, entity, entity, vector, vector, int ) waveFunc )
{
	ent.EndSignal( "OnDestroy" )

	entity weapon
	entity projectile
	int maxCount
	float step
	entity owner
	int damageNearValueTitanArmor
	int count = 0
	array<vector> positions = []
	vector lastDownPos
	bool firstTrace = true

	dir = <dir.x, dir.y, 0.0>
	dir = Normalize( dir )
	vector angles = VectorToAngles( dir )

	if ( ent.IsProjectile() )
	{
		projectile = ent
		string chargedPrefix = ""
		if ( ent.proj.isChargedShot )
			chargedPrefix = "charge_"

		maxCount = expect int( ent.ProjectileGetWeaponInfoFileKeyField( chargedPrefix + "wave_max_count" ) )
		step = expect float( ent.ProjectileGetWeaponInfoFileKeyField( chargedPrefix + "wave_step_dist" ) )
		owner = ent.GetOwner()
		damageNearValueTitanArmor = projectile.GetProjectileWeaponSettingInt( eWeaponVar.damage_near_value_titanarmor )
	}
	else
	{
		weapon = ent
		maxCount = expect int( ent.GetWeaponInfoFileKeyField( "wave_max_count" ) )
		step = expect float( ent.GetWeaponInfoFileKeyField( "wave_step_dist" ) )
		owner = ent.GetWeaponOwner()
		damageNearValueTitanArmor = weapon.GetWeaponSettingInt( eWeaponVar.damage_near_value_titanarmor )
	}

	owner.EndSignal( "OnDestroy" )

	for ( int i = 0; i < maxCount; i++ )
	{
		vector newPos = pos + dir * step

		vector traceStart = pos
		vector traceEndUnder = newPos
		vector traceEndOver = newPos

		if ( !firstTrace )
		{
			traceStart = lastDownPos + <0.0, 0.0, 80.0 >
			traceEndUnder = <newPos.x, newPos.y, traceStart.z - 40.0 >
			traceEndOver = <newPos.x, newPos.y, traceStart.z + step * 0.57735056839> // The over height is to cover the case of a sheer surface that then continues gradually upwards (like mp_box)
		}
		firstTrace = false

		VortexBulletHit ornull vortexHit = VortexBulletHitCheck( owner, traceStart, traceEndOver )
		if ( vortexHit )
		{
			expect VortexBulletHit( vortexHit )
			entity vortexWeapon = vortexHit.vortex.GetOwnerWeapon()

			if ( vortexWeapon && vortexWeapon.GetWeaponClassName() == "mp_titanweapon_vortex_shield" )
				VortexDrainedByImpact( vortexWeapon, weapon, projectile, null ) // drain the vortex shield
			else if ( IsVortexSphere( vortexHit.vortex ) )
				VortexSphereDrainHealthForDamage( vortexHit.vortex, damageNearValueTitanArmor )

			WaitFrame()
			continue
		}

		//DebugDrawLine( traceStart, traceEndUnder, 0, 255, 0, true, 25.0 )
		array ignoreArray = []
		if ( IsValid( inflictor ) && inflictor.GetOwner() != null )
			ignoreArray.append( inflictor.GetOwner() )

		TraceResults forwardTrace = TraceLine( traceStart, traceEndUnder, ignoreArray, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
		if ( forwardTrace.fraction == 1.0 )
		{
			//DebugDrawLine( forwardTrace.endPos, forwardTrace.endPos + <0.0, 0.0, -1000.0>, 255, 0, 0, true, 25.0 )
			TraceResults downTrace = TraceLine( forwardTrace.endPos, forwardTrace.endPos + <0.0, 0.0, -1000.0>, ignoreArray, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
			if ( downTrace.fraction == 1.0 )
				break

			entity movingGeo = null
			if ( downTrace.hitEnt && downTrace.hitEnt.HasPusherRootParent() && !downTrace.hitEnt.IsMarkedForDeletion() )
				movingGeo = downTrace.hitEnt

			if ( !waveFunc( ent, projectileCount, inflictor, movingGeo, downTrace.endPos, angles, i ) )
				return

			lastDownPos = downTrace.endPos
			pos = forwardTrace.endPos

			WaitFrame()
			continue
		}
		else
		{
			if ( IsValid( forwardTrace.hitEnt ) && (StatusEffect_Get( forwardTrace.hitEnt, eStatusEffect.pass_through_amps_weapon ) > 0) && !CheckPassThroughDir( forwardTrace.hitEnt, forwardTrace.surfaceNormal, forwardTrace.endPos ) )
				break;
		}

		TraceResults upwardTrace = TraceLine( traceStart, traceEndOver, ignoreArray, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
		//DebugDrawLine( traceStart, traceEndOver, 0, 0, 255, true, 25.0 )
		if ( upwardTrace.fraction < 1.0 )
		{
			if ( IsValid( upwardTrace.hitEnt ) )
			{
				if ( upwardTrace.hitEnt.IsWorld() || upwardTrace.hitEnt.IsPlayer() || upwardTrace.hitEnt.IsNPC() )
					break
			}
		}
		else
		{
			TraceResults downTrace = TraceLine( upwardTrace.endPos, upwardTrace.endPos + <0.0, 0.0, -1000.0>, ignoreArray, TRACE_MASK_SHOT, TRACE_COLLISION_GROUP_BLOCK_WEAPONS )
			if ( downTrace.fraction == 1.0 )
				break

			entity movingGeo = null
			if ( downTrace.hitEnt && downTrace.hitEnt.HasPusherRootParent() && !downTrace.hitEnt.IsMarkedForDeletion() )
				movingGeo = downTrace.hitEnt

			if ( !waveFunc( ent, projectileCount, inflictor, movingGeo, downTrace.endPos, angles, i ) )
				return

			lastDownPos = downTrace.endPos
			pos = forwardTrace.endPos
		}

		WaitFrame()
	}
}

void function AddActiveThermiteBurn( entity ent )
{
	AddToScriptManagedEntArray( file.activeThermiteBurnsManagedEnts, ent )
}

array<entity> function GetActiveThermiteBurnsWithinRadius( vector origin, float dist, team = TEAM_ANY )
{
	return GetScriptManagedEntArrayWithinCenter( file.activeThermiteBurnsManagedEnts, team, origin, dist )
}

void function EMP_DamagedPlayerOrNPC( entity ent, var damageInfo )
{
	Elecriticy_DamagedPlayerOrNPC( ent, damageInfo, FX_EMP_BODY_HUMAN, FX_EMP_BODY_TITAN, EMP_SEVERITY_SLOWTURN, EMP_SEVERITY_SLOWMOVE )
}

void function VanguardEnergySiphon_DamagedPlayerOrNPC( entity ent, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( IsValid( attacker ) && attacker.GetTeam() == ent.GetTeam() )
		return

	Elecriticy_DamagedPlayerOrNPC( ent, damageInfo, FX_VANGUARD_ENERGY_BODY_HUMAN, FX_VANGUARD_ENERGY_BODY_TITAN, LASER_STUN_SEVERITY_SLOWTURN, LASER_STUN_SEVERITY_SLOWMOVE )
}

void function Elecriticy_DamagedPlayerOrNPC( entity ent, var damageInfo, asset humanFx, asset titanFx, float slowTurn, float slowMove )
{
	if ( !IsValid( ent ) )
		return

	if ( DamageInfo_GetCustomDamageType( damageInfo ) & DF_DOOMED_HEALTH_LOSS )
		return

	local inflictor = DamageInfo_GetInflictor( damageInfo )
	if( !IsValid( inflictor ) )
		return

	// Do electrical effect on this ent that everyone can see if they are a titan
	string tag = ""
	asset effect

	if ( ent.IsTitan() )
	{
		tag = "exp_torso_front"
		effect = titanFx
	}
	else if ( IsStalker( ent ) || IsSpectre( ent ) )
	{
		tag = "CHESTFOCUS"
		effect = humanFx
		if ( !ent.ContextAction_IsActive() && IsAlive( ent ) && ent.IsInterruptable() )
		{
			ent.Anim_ScriptedPlayActivityByName( "ACT_STUNNED", true, 0.1 )
		}
	}
	else if ( IsSuperSpectre( ent ) )
	{
		tag = "CHESTFOCUS"
		effect = humanFx

		if ( ent.GetParent() == null && !ent.ContextAction_IsActive() && IsAlive( ent ) && ent.IsInterruptable() )
		{
			ent.Anim_ScriptedPlayActivityByName( "ACT_STUNNED", true, 0.1 )
		}
	}
	else if ( IsGrunt( ent ) )
	{
		tag = "CHESTFOCUS"
		effect = humanFx
		if ( !ent.ContextAction_IsActive() && IsAlive( ent ) && ent.IsInterruptable() )
		{
			ent.Anim_ScriptedPlayActivityByName( "ACT_STUNNED", true, 0.1 )
			ent.EnableNPCFlag( NPC_PAIN_IN_SCRIPTED_ANIM )
		}
	}
	else if ( IsPilot( ent ) )
	{
		tag = "CHESTFOCUS"
		effect = humanFx
	}
	else if ( IsAirDrone( ent ) )
	{
		if ( GetDroneType( ent ) == "drone_type_marvin" )
			return
		tag = "HEADSHOT"
		effect = humanFx
		thread NpcEmpRebootPrototype( ent, damageInfo, humanFx, titanFx )
	}
	else if ( IsGunship( ent ) )
	{
		tag = "ORIGIN"
		effect = titanFx
		thread NpcEmpRebootPrototype( ent, damageInfo, humanFx, titanFx )
	}

	ent.Signal( "ArcStunned" )

	if ( tag != "" )
	{
		local inflictor = DamageInfo_GetInflictor( damageInfo )
		Assert( !(inflictor instanceof CEnvExplosion) )
		if ( IsValid( inflictor ) )
		{
			float duration = EMP_GRENADE_PILOT_SCREEN_EFFECTS_DURATION_MAX
			if ( inflictor instanceof CBaseGrenade )
			{
				local entCenter = ent.GetWorldSpaceCenter()
				local dist = Distance( DamageInfo_GetDamagePosition( damageInfo ), entCenter )
				local damageRadius = inflictor.GetDamageRadius()
				duration = GraphCapped( dist, damageRadius * 0.5, damageRadius, EMP_GRENADE_PILOT_SCREEN_EFFECTS_DURATION_MIN, EMP_GRENADE_PILOT_SCREEN_EFFECTS_DURATION_MAX )
			}
			thread EMP_FX( effect, ent, tag, duration )
		}
	}

	if ( StatusEffect_Get( ent, eStatusEffect.destroyed_by_emp ) )
		DamageInfo_SetDamage( damageInfo, ent.GetHealth() )

	// Don't do arc beams to entities that are on the same team... except the owner
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( IsValid( attacker ) && attacker.GetTeam() == ent.GetTeam() && attacker != ent )
		return

	if ( ent.IsPlayer() )
	{
		thread EMPGrenade_EffectsPlayer( ent, damageInfo )
	}
	else if ( ent.IsTitan() )
	{
		EMPGrenade_AffectsShield( ent, damageInfo )
		#if MP
		GiveEMPStunStatusEffects( ent, 2.5, 1.0, slowTurn, slowMove )
		#endif
		thread EMPGrenade_AffectsAccuracy( ent )
	}
	else if ( ent.IsMechanical() )
	{
		#if MP
		GiveEMPStunStatusEffects( ent, 2.5, 1.0, slowTurn, slowMove )
		DamageInfo_ScaleDamage( damageInfo, 2.05 )
		#endif
	}
	else if ( ent.IsHuman() )
	{
		#if MP
		DamageInfo_ScaleDamage( damageInfo, 0.99 )
		#endif
	}

	if ( inflictor instanceof CBaseGrenade )
	{
		if ( !ent.IsPlayer() || ent.IsTitan() ) //Beam should hit cloaked targets, when cloak is updated make IsCloaked() function.
			EMPGrenade_ArcBeam( DamageInfo_GetDamagePosition( damageInfo ), ent )
	}
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// HACK: might make sense to move this to code
void function NpcEmpRebootPrototype( entity npc, var damageInfo, asset humanFx, asset titanFx )
{
	if ( !IsValid( npc ) )
		return

	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )

	if ( !( "rebooting" in npc.s ) )
		npc.s.rebooting <- null

	 if ( npc.s.rebooting ) // npc already knocked down and in rebooting process
		return

	float rebootTime
	vector groundPos
	local nearestNode
	local neighborNodes
	local groundNodePos
	local origin = npc.GetOrigin()
	local startOrigin = origin
	local classname = npc.GetClassName()
	local soundPowerDown
	local soundPowerUp

	//------------------------------------------------------
	// Custom stuff depending on AI type
	//------------------------------------------------------
	switch ( classname )
	{
		case "npc_drone":
			soundPowerDown = "Drone_Power_Down"
			soundPowerUp = "Drone_Power_On"
			rebootTime = DRONE_REBOOT_TIME
			break
		case "npc_gunship":
			soundPowerDown = "Gunship_Power_Down"
			soundPowerUp = "Gunship_Power_On"
			rebootTime = GUNSHIP_REBOOT_TIME
			break
		default:
			Assert( 0, "Unhandled npc type: " + classname )

	}

	//------------------------------------------------------
	// NPC stunned and is rebooting
	//------------------------------------------------------
	npc.Signal( "OnStunned" )
	npc.s.rebooting = true


	//TODO: make drone/gunship slowly drift to the ground while rebooting
	/*
	groundPos = OriginToGround( origin )
	groundPos += Vector( 0, 0, 32 )


	//DebugDrawLine(origin, groundPos, 255, 0, 0, true, 15 )

	//thread AssaultOrigin( drone, groundPos, 16 )
	//thread PlayAnim( drone, "idle" )
	*/


	thread EmpRebootFxPrototype( npc, humanFx, titanFx )
	npc.EnableNPCFlag( NPC_IGNORE_ALL )
	npc.SetNoTarget( true )
	npc.EnableNPCFlag( NPC_DISABLE_SENSING )	// don't do traces to look for enemies or players

	if ( IsAttackDrone( npc ) )
		npc.SetAttackMode( false )

	EmitSoundOnEntity( npc, soundPowerDown )

	wait rebootTime

	EmitSoundOnEntity( npc, soundPowerUp )
	npc.DisableNPCFlag( NPC_IGNORE_ALL )
	npc.SetNoTarget( false )
	npc.DisableNPCFlag( NPC_DISABLE_SENSING )	// don't do traces to look for enemies or players

	if ( IsAttackDrone( npc ) )
		npc.SetAttackMode( true )

	npc.s.rebooting = false
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
// HACK: might make sense to move this to code
function EmpRebootFxPrototype( npc, asset humanFx, asset titanFx )
{
	expect entity( npc )

	if ( !IsValid( npc ) )
		return

	npc.EndSignal( "OnDeath" )
	npc.EndSignal( "OnDestroy" )

	string classname = npc.GetClassName()
	vector origin
	float delayDuration
	entity fxHandle
	asset fxEMPdamage
	string fxTag
	float rebootTime
	string soundEMPdamage

	//------------------------------------------------------
	// Custom stuff depending on AI type
	//------------------------------------------------------
	switch ( classname )
	{
		case "npc_drone":
			if ( GetDroneType( npc ) == "drone_type_marvin" )
				return
			fxEMPdamage = humanFx
			fxTag = "HEADSHOT"
			rebootTime = DRONE_REBOOT_TIME
			soundEMPdamage = "Titan_Blue_Electricity_Cloud"
			break
		case "npc_gunship":
			fxEMPdamage = titanFx
			fxTag = "ORIGIN"
			rebootTime = GUNSHIP_REBOOT_TIME
			soundEMPdamage = "Titan_Blue_Electricity_Cloud"
			break
		default:
			Assert( 0, "Unhandled npc type: " + classname )

	}

	//------------------------------------------------------
	// Play Fx/Sound till reboot finishes
	//------------------------------------------------------
	fxHandle = ClientStylePlayFXOnEntity( fxEMPdamage, npc, fxTag, rebootTime )
	EmitSoundOnEntity( npc, soundEMPdamage )

	while ( npc.s.rebooting == true )
	{
		delayDuration = RandomFloatRange( 0.4, 1.2 )
		origin = npc.GetOrigin()


		EmitSoundAtPosition( npc.GetTeam(), origin, SOUND_EMP_REBOOT_SPARKS )
		PlayFX( FX_EMP_REBOOT_SPARKS, origin )
		PlayFX( FX_EMP_REBOOT_SPARKS, origin )

		OnThreadEnd(
			function() : ( fxHandle, npc, soundEMPdamage )
			{
				if ( IsValid( fxHandle ) )
					fxHandle.Fire( "StopPlayEndCap" )
				if ( IsValid( npc ) )
					StopSoundOnEntity( npc, soundEMPdamage )
			}
		)

		wait ( delayDuration )
	}
}

function EMP_FX( asset effect, entity ent, string tag, float duration )
{
	if ( !IsAlive( ent ) )
		return

	ent.Signal( "EMP_FX" )
	ent.EndSignal( "OnDestroy" )
	ent.EndSignal( "OnDeath" )
	ent.EndSignal( "StartPhaseShift" )
	ent.EndSignal( "EMP_FX" )

	bool isPlayer = ent.IsPlayer()

	int fxId = GetParticleSystemIndex( effect )
	int attachId = ent.LookupAttachment( tag )

	entity fxHandle = StartParticleEffectOnEntity_ReturnEntity( ent, fxId, FX_PATTACH_POINT_FOLLOW, attachId )
	fxHandle.kv.VisibilityFlags = ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY
	fxHandle.SetOwner( ent )

	OnThreadEnd(
		function() : ( fxHandle, ent )
		{
			if ( IsValid( fxHandle ) )
			{
				EffectStop( fxHandle )
			}

			if ( IsValid( ent ) )
				StopSoundOnEntity( ent, "Titan_Blue_Electricity_Cloud" )
		}
	)

	if ( !isPlayer )
	{
		EmitSoundOnEntity( ent, "Titan_Blue_Electricity_Cloud" )
		wait duration
	}
	else
	{
		EmitSoundOnEntityExceptToPlayer( ent, ent, "Titan_Blue_Electricity_Cloud" )

		var endTime = Time() + duration
		bool effectsActive = true
		while( endTime > Time() )
		{
			if ( ent.IsPhaseShifted() )
			{
				if ( effectsActive )
				{
					effectsActive = false
					if ( IsValid( fxHandle ) )
						EffectSleep( fxHandle )

					if ( IsValid( ent ) )
						StopSoundOnEntity( ent, "Titan_Blue_Electricity_Cloud" )
				}
			}
			else if ( effectsActive == false )
			{
				EffectWake( fxHandle )
				EmitSoundOnEntityExceptToPlayer( ent, ent, "Titan_Blue_Electricity_Cloud" )
				effectsActive = true
			}

			WaitFrame()
		}
	}
}

function EMPGrenade_AffectsShield( entity titan, damageInfo )
{
	int shieldHealth = titan.GetTitanSoul().GetShieldHealth()
	int shieldDamage = int( titan.GetTitanSoul().GetShieldHealthMax() * 0.5 )

	titan.GetTitanSoul().SetShieldHealth( maxint( 0, shieldHealth - shieldDamage ) )

	// attacker took down titan shields
	if ( shieldHealth && !titan.GetTitanSoul().GetShieldHealth() )
	{
		entity attacker = DamageInfo_GetAttacker( damageInfo )
		if ( attacker && attacker.IsPlayer() )
			EmitSoundOnEntityOnlyToPlayer( attacker, attacker, "titan_energyshield_down" )
	}
}

function EMPGrenade_AffectsAccuracy( npcTitan )
{
	npcTitan.EndSignal( "OnDestroy" )

	npcTitan.kv.AccuracyMultiplier = 0.5
	wait EMP_GRENADE_PILOT_SCREEN_EFFECTS_DURATION_MAX
	npcTitan.kv.AccuracyMultiplier = 1.0
}


function EMPGrenade_EffectsPlayer( entity player, damageInfo )
{
	player.Signal( "OnEMPPilotHit" )
	player.EndSignal( "OnEMPPilotHit" )

	if ( player.IsPhaseShifted() )
		return

	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	local dist = Distance( DamageInfo_GetDamagePosition( damageInfo ), player.GetWorldSpaceCenter() )
	local damageRadius = 128
	if ( inflictor instanceof CBaseGrenade )
		damageRadius = inflictor.GetDamageRadius()
	float frac = GraphCapped( dist, damageRadius * 0.5, damageRadius, 1.0, 0.0 )
	local strength = EMP_GRENADE_PILOT_SCREEN_EFFECTS_MIN + ( ( EMP_GRENADE_PILOT_SCREEN_EFFECTS_MAX - EMP_GRENADE_PILOT_SCREEN_EFFECTS_MIN ) * frac )
	float fadeoutDuration = EMP_GRENADE_PILOT_SCREEN_EFFECTS_FADE * frac
	float duration = EMP_GRENADE_PILOT_SCREEN_EFFECTS_DURATION_MIN + ( ( EMP_GRENADE_PILOT_SCREEN_EFFECTS_DURATION_MAX - EMP_GRENADE_PILOT_SCREEN_EFFECTS_DURATION_MIN ) * frac ) - fadeoutDuration
	local origin = inflictor.GetOrigin()

	int dmgSource = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	if ( dmgSource == eDamageSourceId.mp_weapon_proximity_mine || dmgSource == eDamageSourceId.mp_titanweapon_stun_laser )
	{
		strength *= 0.1
	}

	if ( player.IsTitan() )
	{
		// Hit player should do EMP screen effects locally
		Remote_CallFunction_Replay( player, "ServerCallback_TitanCockpitEMP", duration )

		EMPGrenade_AffectsShield( player, damageInfo )

		Remote_CallFunction_Replay( player, "ServerCallback_TitanEMP", strength, duration, fadeoutDuration )
	}
	else
	{
		if ( IsCloaked( player ) )
			player.SetCloakFlicker( 0.5, duration )

		// duration = 0
		// fadeoutDuration = 0

		StatusEffect_AddTimed( player, eStatusEffect.emp, strength, duration, fadeoutDuration )
		//DamageInfo_SetDamage( damageInfo, 0 )
	}

	GiveEMPStunStatusEffects( player, (duration + fadeoutDuration), fadeoutDuration)
}

function EMPGrenade_ArcBeam( grenadePos, ent )
{
	if ( !ent.IsPlayer() && !ent.IsNPC() )
		return

	Assert( IsValid( ent ) )
	local lifeDuration = 0.5

	// Control point sets the end position of the effect
	entity cpEnd = CreateEntity( "info_placement_helper" )
	SetTargetName( cpEnd, UniqueString( "emp_grenade_beam_cpEnd" ) )
	cpEnd.SetOrigin( grenadePos )
	DispatchSpawn( cpEnd )

	entity zapBeam = CreateEntity( "info_particle_system" )
	zapBeam.kv.cpoint1 = cpEnd.GetTargetName()
	zapBeam.SetValueForEffectNameKey( EMP_GRENADE_BEAM_EFFECT )
	zapBeam.kv.start_active = 0
	zapBeam.SetOrigin( ent.GetWorldSpaceCenter() )
	if ( !ent.IsMarkedForDeletion() ) // TODO: This is a hack for shipping. Should not be parenting to deleted entities
	{
		zapBeam.SetParent( ent, "", true, 0.0 )
	}

	DispatchSpawn( zapBeam )

	zapBeam.Fire( "Start" )
	zapBeam.Fire( "StopPlayEndCap", "", lifeDuration )
	zapBeam.Kill_Deprecated_UseDestroyInstead( lifeDuration )
	cpEnd.Kill_Deprecated_UseDestroyInstead( lifeDuration )
}

void function GetWeaponDPS( bool vsTitan = false )
{
	entity player = GetPlayerArray()[0]
	entity weapon = player.GetActiveWeapon()

	local fire_rate = weapon.GetWeaponInfoFileKeyField( "fire_rate" )
	local burst_fire_count = weapon.GetWeaponInfoFileKeyField( "burst_fire_count" )
	local burst_fire_delay = weapon.GetWeaponInfoFileKeyField( "burst_fire_delay" )

	local damage_near_value = weapon.GetWeaponInfoFileKeyField( "damage_near_value" )
	local damage_far_value = weapon.GetWeaponInfoFileKeyField( "damage_far_value" )

	if ( vsTitan )
	{
		damage_near_value = weapon.GetWeaponInfoFileKeyField( "damage_near_value_titanarmor" )
		damage_far_value = weapon.GetWeaponInfoFileKeyField( "damage_far_value_titanarmor" )
	}

	if ( burst_fire_count )
	{
		local timePerShot = 1 / fire_rate
		local timePerBurst = (timePerShot * burst_fire_count) + burst_fire_delay
		local burstPerSecond = 1 / timePerBurst

		printt( timePerBurst )

		printt( "DPS Near", (burstPerSecond * burst_fire_count) * damage_near_value )
		printt( "DPS Far ", (burstPerSecond * burst_fire_count) * damage_far_value )
	}
	else
	{
		printt( "DPS Near", fire_rate * damage_near_value )
		printt( "DPS Far ", fire_rate * damage_far_value )
	}
}


void function GetTTK( string weaponRef, float health = 100.0 )
{
	local fire_rate = GetWeaponInfoFileKeyField_Global( weaponRef, "fire_rate" ).tofloat()
	local burst_fire_count = GetWeaponInfoFileKeyField_Global( weaponRef, "burst_fire_count" )
	if ( burst_fire_count != null )
		burst_fire_count = burst_fire_count.tofloat()

	local burst_fire_delay = GetWeaponInfoFileKeyField_Global( weaponRef, "burst_fire_delay" )
	if ( burst_fire_delay != null )
		burst_fire_delay = burst_fire_delay.tofloat()

	local damage_near_value = GetWeaponInfoFileKeyField_Global( weaponRef, "damage_near_value" ).tointeger()
	local damage_far_value = GetWeaponInfoFileKeyField_Global( weaponRef, "damage_far_value" ).tointeger()

	local nearBodyShots = ceil( health / damage_near_value ) - 1
	local farBodyShots = ceil( health / damage_far_value ) - 1

	local delayAdd = 0
	if ( burst_fire_count && burst_fire_count < nearBodyShots )
		delayAdd += burst_fire_delay

	printt( "TTK Near", (nearBodyShots * (1 / fire_rate)) + delayAdd, " (" + (nearBodyShots + 1) + ")" )


	delayAdd = 0
	if ( burst_fire_count && burst_fire_count < farBodyShots )
		delayAdd += burst_fire_delay

	printt( "TTK Far ", (farBodyShots * (1 / fire_rate)) + delayAdd, " (" + (farBodyShots + 1) + ")" )
}

array<string> function GetWeaponModsFromDamageInfo( var damageInfo )
{
	entity weapon = DamageInfo_GetWeapon( damageInfo )
	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	int damageType = DamageInfo_GetCustomDamageType( damageInfo )

	if ( IsValid( weapon ) )
	{
		return weapon.GetMods()
	}
	else if ( IsValid( inflictor ) )
	{
		if ( "weaponMods" in inflictor.s && inflictor.s.weaponMods )
		{
			array<string> temp
			foreach ( string mod in inflictor.s.weaponMods )
			{
				temp.append( mod )
			}

			return temp
		}
		else if( inflictor.IsProjectile() )
			return inflictor.ProjectileGetMods()
		else if ( damageType & DF_EXPLOSION && inflictor.IsPlayer() && IsValid( inflictor.GetActiveWeapon() ) )
			return inflictor.GetActiveWeapon().GetMods()
		//Hack - Splash damage doesn't pass mod weapon through. This only works under the assumption that offhand weapons don't have mods.
	}
	return []
}

void function OnPlayerGetsNewPilotLoadout( entity player, PilotLoadoutDef loadout )
{
	if ( GetCurrentPlaylistVarInt( "featured_mode_amped_tacticals", 0 ) >= 1 )
	{
		player.GiveExtraWeaponMod( "amped_tacticals" )
	}

	if ( GetCurrentPlaylistVarInt( "featured_mode_all_grapple", 0 ) >= 1 )
	{
		player.GiveExtraWeaponMod( "all_grapple" )
	}

	if ( GetCurrentPlaylistVarInt( "featured_mode_all_phase", 0 ) >= 1 )
	{
		player.GiveExtraWeaponMod( "all_phase" )
	}

	SetPlayerCooldowns( player )
}

void function SetPlayerCooldowns( entity player )
{
	if ( player.IsTitan() )
		return

	array<int> offhandIndices = [ OFFHAND_LEFT, OFFHAND_RIGHT ]

	foreach ( index in offhandIndices )
	{
		float lastUseTime = player.p.lastPilotOffhandUseTime[ index ]
		float lastChargeFrac = player.p.lastPilotOffhandChargeFrac[ index ]
		float lastClipFrac = player.p.lastPilotClipFrac[ index ]

		if ( lastUseTime >= 0.0 )
		{
			entity weapon = player.GetOffhandWeapon( index )
			if ( !IsValid( weapon ) )
				continue

			string weaponClassName = weapon.GetWeaponClassName()

			switch ( GetWeaponInfoFileKeyField_Global( weaponClassName, "cooldown_type" ) )
			{
				case "grapple":
					// GetPlayerSettingsField isn't working for moddable fields? - Bug 129567
					float powerRequired = 100.0 // GetPlayerSettingsField( "grapple_power_required" )
					float regenRefillDelay = 3.0 // GetPlayerSettingsField( "grapple_power_regen_delay" )
					float regenRefillRate = 5.0 // GetPlayerSettingsField( "grapple_power_regen_rate" )
					float suitPowerToRestore = powerRequired - player.p.lastSuitPower
					float regenRefillTime = suitPowerToRestore / regenRefillRate

					float regenStartTime = lastUseTime + regenRefillDelay

					float newSuitPower = GraphCapped( Time() - regenStartTime, 0.0, regenRefillTime, player.p.lastSuitPower, powerRequired )

					player.SetSuitGrapplePower( newSuitPower )
					break

				case "ammo":
				case "ammo_instant":
				case "ammo_deployed":
				case "ammo_timed":
					int maxAmmo = weapon.GetWeaponPrimaryClipCountMax()
					float fireDuration = weapon.GetWeaponSettingFloat( eWeaponVar.fire_duration )
					float regenRefillDelay = weapon.GetWeaponSettingFloat( eWeaponVar.regen_ammo_refill_start_delay )
					float regenRefillRate = weapon.GetWeaponSettingFloat( eWeaponVar.regen_ammo_refill_rate )
					int startingClipCount = int( lastClipFrac * maxAmmo )
					int ammoToRestore = maxAmmo - startingClipCount
					float regenRefillTime = ammoToRestore / regenRefillRate

					float regenStartTime = lastUseTime + fireDuration + regenRefillDelay

					int newAmmo = int( GraphCapped( Time() - regenStartTime, 0.0, regenRefillTime, startingClipCount, maxAmmo ) )

					weapon.SetWeaponPrimaryClipCountAbsolute( newAmmo )
					break

				case "chargeFrac":
					float chargeCooldownDelay = weapon.GetWeaponSettingFloat( eWeaponVar.charge_cooldown_delay )
					float chargeCooldownTime = weapon.GetWeaponSettingFloat( eWeaponVar.charge_cooldown_time )
					float regenRefillTime = lastChargeFrac * chargeCooldownTime
					float regenStartTime = lastUseTime + chargeCooldownDelay

					float newCharge = GraphCapped( Time() - regenStartTime, 0.0, regenRefillTime, lastChargeFrac, 0.0 )

					weapon.SetWeaponChargeFraction( newCharge )
					break

				default:
					printt( weaponClassName + " needs to be updated to support cooldown_type setting" )
					break
			}
		}
	}
}

void function ResetPlayerCooldowns( entity player )
{
	if ( player.IsTitan() )
		return

	array<int> offhandIndices = [ OFFHAND_LEFT, OFFHAND_RIGHT ]

	foreach ( index in offhandIndices )
	{
		float lastUseTime = -99.0//player.p.lastPilotOffhandUseTime[ index ]
		float lastChargeFrac = -1.0//player.p.lastPilotOffhandChargeFrac[ index ]
		float lastClipFrac = 1.0//player.p.lastPilotClipFrac[ index ]

		entity weapon = player.GetOffhandWeapon( index )
		if ( !IsValid( weapon ) )
			continue

		string weaponClassName = weapon.GetWeaponClassName()

		switch ( GetWeaponInfoFileKeyField_Global( weaponClassName, "cooldown_type" ) )
		{
			case "grapple":
				// GetPlayerSettingsField isn't working for moddable fields? - Bug 129567
				float powerRequired = 100.0 // GetPlayerSettingsField( "grapple_power_required" )
				player.SetSuitGrapplePower( powerRequired )
				break

			case "ammo":
			case "ammo_instant":
			case "ammo_deployed":
			case "ammo_timed":
				int maxAmmo = weapon.GetWeaponPrimaryClipCountMax()
				weapon.SetWeaponPrimaryClipCountAbsolute( maxAmmo )
				break

			case "chargeFrac":
				weapon.SetWeaponChargeFraction( 1.0 )
				break

			default:
				printt( weaponClassName + " needs to be updated to support cooldown_type setting" )
				break
		}
	}
}

void function OnPlayerKilled( entity player, entity attacker, var damageInfo )
{
	StoreOffhandData( player )
}

void function StoreOffhandData( entity player, bool waitEndFrame = true )
{
	thread StoreOffhandDataThread( player, waitEndFrame )
}

void function StoreOffhandDataThread( entity player, bool waitEndFrame )
{
	if ( !IsValid( player ) )
		return

	player.EndSignal( "OnDestroy" )

	if ( waitEndFrame )
		WaitEndFrame() // Need to WaitEndFrame so clip counts can be updated if player is dying the same frame

	array<int> offhandIndices = [ OFFHAND_LEFT, OFFHAND_RIGHT ]

	// Reset all values for full cooldown
	player.p.lastSuitPower = 0.0

	foreach ( index in offhandIndices )
	{
		player.p.lastPilotOffhandChargeFrac[ index ] = 1.0
		player.p.lastPilotClipFrac[ index ] = 1.0

		player.p.lastTitanOffhandChargeFrac[ index ] = 1.0
		player.p.lastTitanClipFrac[ index ] = 1.0
	}

	if ( player.IsTitan() )
		return

	foreach ( index in offhandIndices )
	{
		entity weapon = player.GetOffhandWeapon( index )
		if ( !IsValid( weapon ) )
			continue

		string weaponClassName = weapon.GetWeaponClassName()

		switch ( GetWeaponInfoFileKeyField_Global( weaponClassName, "cooldown_type" ) )
		{
			case "grapple":
				player.p.lastSuitPower = player.GetSuitGrapplePower()
				break

			case "ammo":
			case "ammo_instant":
			case "ammo_deployed":
			case "ammo_timed":

				if ( player.IsTitan() )
				{
					if ( !weapon.IsWeaponRegenDraining() )
						player.p.lastTitanClipFrac[ index ] = min( 1.0, weapon.GetWeaponPrimaryClipCount() / float( weapon.GetWeaponPrimaryClipCountMax() ) ) //Was returning greater than one with extraweaponmod timing.
					else
						player.p.lastTitanClipFrac[ index ] = 0.0
				}
				else
				{
					if ( !weapon.IsWeaponRegenDraining() )
						player.p.lastPilotClipFrac[ index ] = min( 1.0, weapon.GetWeaponPrimaryClipCount() / float( weapon.GetWeaponPrimaryClipCountMax() ) ) //Was returning greater than one with extraweaponmod timing.
					else
						player.p.lastPilotClipFrac[ index ] = 0.0
				}
				break

			case "chargeFrac":
				if ( player.IsTitan() )
					player.p.lastTitanOffhandChargeFrac[ index ] = weapon.GetWeaponChargeFraction()
				else
					player.p.lastPilotOffhandChargeFrac[ index ] = weapon.GetWeaponChargeFraction()
				break

			default:
				printt( weaponClassName + " needs to be updated to support cooldown_type setting" )
				break
		}
	}
}
#endif // #if SERVER

void function PlayerUsedOffhand( entity player, entity offhandWeapon )
{
	array<int> offhandIndices = [ OFFHAND_LEFT, OFFHAND_RIGHT, OFFHAND_ANTIRODEO, OFFHAND_EQUIPMENT ]

	foreach ( index in offhandIndices )
	{
		entity weapon = player.GetOffhandWeapon( index )
		if ( !IsValid( weapon ) )
			continue

		if ( weapon != offhandWeapon )
			continue

		#if SERVER
			if ( player.IsTitan() )
				player.p.lastTitanOffhandUseTime[ index ] = Time()
			else
				player.p.lastPilotOffhandUseTime[ index ] = Time()

			#if MP
				string weaponName = offhandWeapon.GetWeaponClassName()
				if ( weaponName != "mp_ability_grapple" ) // handled in CodeCallback_OnGrapple   // nope, it's not (?)
				{
					string category
					float duration
					if ( index == OFFHAND_EQUIPMENT && player.IsTitan() )
					{
						category = "core"
						duration = -1
					}
					else
					{
						category = ""
						duration = Time() - offhandWeapon.GetNextAttackAllowedTimeRaw()
					}
					PIN_PlayerAbility( player, category, weaponName, {}, duration )
				}
			#endif
		#endif // SERVER

		#if HAS_TITAN_TELEMETRY && CLIENT
			ClTitanHints_ClearOffhandHint( index )
		#endif

		#if HAS_TITAN_TELEMETRY && SERVER
			TitanHints_NotifyUsedOffhand( index )
		#endif

		return
	}
}

RadiusDamageData function GetRadiusDamageDataFromProjectile( entity projectile, entity owner )
{
	RadiusDamageData radiusDamageData

	radiusDamageData.explosionDamage = -1
	radiusDamageData.explosionDamageHeavyArmor = -1

	if ( owner.IsNPC() )
	{
		radiusDamageData.explosionDamage = projectile.GetProjectileWeaponSettingInt( eWeaponVar.npc_explosion_damage )
		radiusDamageData.explosionDamageHeavyArmor = projectile.GetProjectileWeaponSettingInt( eWeaponVar.npc_explosion_damage_heavy_armor )
	}

	if ( radiusDamageData.explosionDamage == -1 )
		radiusDamageData.explosionDamage = projectile.GetProjectileWeaponSettingInt( eWeaponVar.explosion_damage )

	if ( radiusDamageData.explosionDamageHeavyArmor == -1 )
		radiusDamageData.explosionDamageHeavyArmor = projectile.GetProjectileWeaponSettingInt( eWeaponVar.explosion_damage_heavy_armor )

	radiusDamageData.explosionRadius = projectile.GetProjectileWeaponSettingFloat( eWeaponVar.explosionradius )
	radiusDamageData.explosionInnerRadius = projectile.GetProjectileWeaponSettingFloat( eWeaponVar.explosion_inner_radius )

	Assert( radiusDamageData.explosionRadius > 0, "Created RadiusDamageData with 0 radius" )
	Assert( radiusDamageData.explosionDamage > 0 || radiusDamageData.explosionDamageHeavyArmor > 0, "Created RadiusDamageData with 0 damage" )
	return radiusDamageData
}

#if SERVER
void function Thermite_DamagePlayerOrNPCSounds( entity ent )
{
	if ( ent.IsTitan() )
	{
		if ( ent.IsPlayer() )
		{
		 	EmitSoundOnEntityOnlyToPlayer( ent, ent, "titan_thermiteburn_3p_vs_1p" )
			EmitSoundOnEntityExceptToPlayer( ent, ent, "titan_thermiteburn_1p_vs_3p" )
		}
		else
		{
		 	EmitSoundOnEntity( ent, "titan_thermiteburn_1p_vs_3p" )
		}
	}
	else
	{
		if ( ent.IsPlayer() )
		{
		 	EmitSoundOnEntityOnlyToPlayer( ent, ent, "flesh_thermiteburn_3p_vs_1p" )
			EmitSoundOnEntityExceptToPlayer( ent, ent, "flesh_thermiteburn_1p_vs_3p" )
		}
		else
		{
		 	EmitSoundOnEntity( ent, "flesh_thermiteburn_1p_vs_3p" )
		}
	}
}
#endif

#if SERVER
void function RemoveThreatScopeColorStatusEffect( entity player )
{
	for ( int i = file.colorSwapStatusEffects.len() - 1; i >= 0; i-- )
	{
		entity owner = file.colorSwapStatusEffects[i].weaponOwner
		if ( !IsValid( owner ) )
		{
			file.colorSwapStatusEffects.remove( i )
			continue
		}
		if ( owner == player )
		{
			StatusEffect_Stop( player, file.colorSwapStatusEffects[i].statusEffectId )
			file.colorSwapStatusEffects.remove( i )
		}
	}
}

void function AddThreatScopeColorStatusEffect( entity player )
{
	ColorSwapStruct info
	info.weaponOwner = player
	info.statusEffectId = StatusEffect_AddTimed( player, eStatusEffect.cockpitColor, COCKPIT_COLOR_THREAT, 100000, 0 )
	file.colorSwapStatusEffects.append( info )
}
#endif
