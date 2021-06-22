untyped

global function ArcCannon_Init

global function ArcCannon_PrecacheFX
global function ArcCannon_Start
global function ArcCannon_Stop
global function ArcCannon_ChargeBegin
global function ArcCannon_ChargeEnd
global function FireArcCannon
global function ArcCannon_HideIdleEffect
#if SERVER
	global function AddToArcCannonTargets
	global function RemoveArcCannonTarget
	global function ConvertTitanShieldIntoBonusCharge
#endif
global function GetArcCannonChargeFraction

global function IsEntANeutralMegaTurret
global function CreateArcCannonBeam


// Aiming & Range
global const DEFAULT_ARC_CANNON_FOVDOT				= 0.98		// First target must be within this dot to be zapped and start a chain
global const DEFAULT_ARC_CANNON_FOVDOT_MISSILE		= 0.95		// First target must be within this dot to be zapped and start a chain ( if it's a missile, we allow more leaniency )
global const ARC_CANNON_RANGE_CHAIN				= 400		// Max distance we can arc from one target to another
global const ARC_CANNON_TITAN_RANGE_CHAIN			= 900		// Max distance we can arc from one target to another
global const ARC_CANNON_CHAIN_COUNT_MIN			= 5			// Max number of chains at no charge
global const ARC_CANNON_CHAIN_COUNT_MAX			= 5			// Max number of chains at full charge
global const ARC_CANNON_CHAIN_COUNT_NPC			= 2			// Number of chains when an NPC fires the weapon
global const ARC_CANNON_FORK_COUNT_MAX				= 1			// Number of forks that can come out of one target to other targets
global const ARC_CANNON_FORK_DELAY					= 0.1

global const ARC_CANNON_RANGE_CHAIN_BURN			= 400
global const ARC_CANNON_TITAN_RANGE_CHAIN_BURN		= 900
global const ARC_CANNON_CHAIN_COUNT_MIN_BURN		= 100		// Max number of chains at no charge
global const ARC_CANNON_CHAIN_COUNT_MAX_BURN		= 100		// Max number of chains at full charge
global const ARC_CANNON_CHAIN_COUNT_NPC_BURN		= 10		// Number of chains when an NPC fires the weapon
global const ARC_CANNON_FORK_COUNT_MAX_BURN		= 10		// Number of forks that can come out of one target to other targets
global const ARC_CANNON_BEAM_LIFETIME_BURN			= 1

// Visual settings
global const ARC_CANNON_BOLT_RADIUS_MIN 			= 32		// Bolt radius at no charge ( not actually sure what this does to the beam lol )
global const ARC_CANNON_BOLT_RADIUS_MAX 			= 640		// Bold radius at full charge ( not actually sure what this does to the beam lol )
global const ARC_CANNON_BOLT_WIDTH_MIN 			= 1			// Bolt width at no charge
global const ARC_CANNON_BOLT_WIDTH_MAX 			= 26		// Bolt width at full charge
global const ARC_CANNON_BOLT_WIDTH_NPC				= 8			// Bolt width when used by NPC
global const ARC_CANNON_BEAM_COLOR					= "150 190 255"
global const ARC_CANNON_BEAM_LIFETIME				= 0.75

// Player Effects
global const ARC_CANNON_TITAN_SCREEN_SFX 		= "Null_Remove_SoundHook"
global const ARC_CANNON_PILOT_SCREEN_SFX 		= "Null_Remove_SoundHook"
global const ARC_CANNON_EMP_DURATION_MIN 		= 0.1
global const ARC_CANNON_EMP_DURATION_MAX		= 1.8
global const ARC_CANNON_EMP_FADEOUT_DURATION	= 0.4
global const ARC_CANNON_SCREEN_EFFECTS_MIN 	= 0.01
global const ARC_CANNON_SCREEN_EFFECTS_MAX 	= 0.02
global const ARC_CANNON_SCREEN_THRESHOLD		= 0.3385
global const ARC_CANNON_3RD_PERSON_EFFECT_MIN_DURATION = 0.2

// Damage
global const ARC_CANNON_DAMAGE_FALLOFF_SCALER		= 0.75		// Amount of damage carried on to the next target in the chain lightning. If 0.75, then a target that would normally take 100 damage will take 75 damage if they are one chain deep, or 56 damage if 2 levels deep
global const ARC_CANNON_DAMAGE_CHARGE_RATIO		= 0.85		// What amount of charge is required for full damage.
global const ARC_CANNON_DAMAGE_CHARGE_RATIO_BURN	= 0.676		// What amount of charge is required for full damage.
global const ARC_CANNON_CAPACITOR_CHARGE_RATIO		= 1.0

// Options
global const ARC_CANNON_TARGETS_MISSILES 			= 1			// 1 = arc cannon zaps missiles that are active, 0 = missiles are ignored by arc cannon

//Mods
global const OVERCHARGE_MAX_SHIELD_DECAY       	= 0.2
global const OVERCHARGE_SHIELD_DECAY_MULTIPLIER 	= 0.04
global const OVERCHARGE_BONUS_CHARGE_FRACTION		= 0.05

global const SPLITTER_DAMAGE_FALLOFF_SCALER		= 0.6
global const SPLITTER_FORK_COUNT_MAX				= 10

global const ARC_CANNON_SIGNAL_DEACTIVATED	= "ArcCannonDeactivated"
global const ARC_CANNON_SIGNAL_CHARGEEND = "ArcCannonChargeEnd"

global const ARC_CANNON_BEAM_EFFECT = $"wpn_arc_cannon_beam"
global const ARC_CANNON_BEAM_EFFECT_MOD = $"wpn_arc_cannon_beam_mod"

global const ARC_CANNON_FX_TABLE = "exp_arc_cannon"

global const ArcCannonTargetClassnames = {
	[ "npc_drone" ] 			= true,
	[ "npc_dropship" ] 			= true,
	[ "npc_marvin" ] 			= true,
	[ "npc_prowler" ]			= true,
	[ "npc_soldier" ] 			= true,
	[ "npc_soldier_heavy" ] 	= true,
	[ "npc_soldier_shield" ]	= true,
	[ "npc_spectre" ] 			= true,
	[ "npc_stalker" ] 			= true,
	[ "npc_super_spectre" ]		= true,
	[ "npc_titan" ] 			= true,
	[ "npc_turret_floor" ] 		= true,
	[ "npc_turret_mega" ]		= true,
	[ "npc_turret_sentry" ] 	= true,
	[ "npc_frag_drone" ] 		= true,
	[ "player" ] 				= true,
	[ "prop_dynamic" ] 			= true,
	[ "prop_script" ] 			= true,
	[ "grenade_frag" ] 			= true,
	[ "rpg_missile" ] 			= true,
	[ "script_mover" ] 			= true,
	[ "turret" ] 				= true,
}

struct {
	array<string> missileCheckTargetnames = [
		// "Arc Pylon",
		"Arc Ball"
	]
} file;

function ArcCannon_Init()
{
	RegisterSignal( ARC_CANNON_SIGNAL_DEACTIVATED )
	RegisterSignal( ARC_CANNON_SIGNAL_CHARGEEND )
	PrecacheParticleSystem( ARC_CANNON_BEAM_EFFECT )
	PrecacheParticleSystem( ARC_CANNON_BEAM_EFFECT_MOD )
	PrecacheImpactEffectTable( ARC_CANNON_FX_TABLE )

	#if CLIENT
		AddDestroyCallback( "mp_titanweapon_arc_cannon", ClientDestroyCallback_ArcCannon_Stop )
	#else
		level._arcCannonTargetsArrayID <- CreateScriptManagedEntArray()
	#endif

	PrecacheParticleSystem( $"impact_arc_cannon_titan" )
}

function ArcCannon_PrecacheFX()
{
	PrecacheParticleSystem( $"wpn_arc_cannon_electricity_fp" )
	PrecacheParticleSystem( $"wpn_arc_cannon_electricity" )

	PrecacheParticleSystem( $"wpn_muzzleflash_arc_cannon_fp" )
	PrecacheParticleSystem( $"wpn_muzzleflash_arc_cannon" )
}

function ArcCannon_Start( weapon )
{
	expect entity( weapon )
	if ( !IsPilot( weapon.GetWeaponOwner() ) )
	{
		weapon.PlayWeaponEffectNoCull( $"wpn_arc_cannon_electricity_fp", $"wpn_arc_cannon_electricity", "muzzle_flash" )
		weapon.EmitWeaponSound( "arc_cannon_charged_loop" )
	}
	else
	{
		weapon.EmitWeaponSound_1p3p( "Arc_Rifle_charged_Loop_1P", "Arc_Rifle_charged_Loop_3P" )
	}
}

function ArcCannon_Stop( weapon, player = null )
{
	expect entity( weapon )
	weapon.Signal( ARC_CANNON_SIGNAL_DEACTIVATED )

	weapon.StopWeaponEffect( $"wpn_arc_cannon_electricity_fp", $"wpn_arc_cannon_electricity" )
	weapon.StopWeaponSound( "arc_cannon_charged_loop" )
}

function ArcCannon_ChargeBegin( entity weapon )
{
	#if SERVER
		if ( weapon.HasMod( "overcharge" ) )
		{
			entity weaponOwner = weapon.GetWeaponOwner()
			if ( weaponOwner.IsTitan() )
			{
				entity soul = weaponOwner.GetTitanSoul()
				thread ConvertTitanShieldIntoBonusCharge( soul, weapon )
			}
		}
	#endif

	#if CLIENT
		if ( !weapon.ShouldPredictProjectiles() )
			return

		entity weaponOwner = weapon.GetWeaponOwner()
		Assert( weaponOwner.IsPlayer() )
		weaponOwner.StartArcCannon();
	#endif
}

function ArcCannon_ChargeEnd( entity weapon, entity player = null )
{
	#if SERVER
		if ( IsValid( weapon ) )
			weapon.Signal( ARC_CANNON_SIGNAL_CHARGEEND )
	#endif

	#if CLIENT
		if ( weapon.GetWeaponOwner() == GetLocalViewPlayer() )
		{
			entity weaponOwner
			if ( player != null )
				weaponOwner = player
			else
				weaponOwner = weapon.GetWeaponOwner()

			if ( IsValid( weaponOwner ) && weaponOwner.IsPlayer() )
				weaponOwner.StopArcCannon()
		}
	#endif
}

#if SERVER
function ConvertTitanShieldIntoBonusCharge( entity soul, entity weapon )
{
	weapon.EndSignal( ARC_CANNON_SIGNAL_CHARGEEND )
	weapon.EndSignal( "OnDestroy" )

	local maxShieldDecay = OVERCHARGE_MAX_SHIELD_DECAY
	local bonusChargeFraction = OVERCHARGE_BONUS_CHARGE_FRACTION
	local shieldDecayMultiplier = OVERCHARGE_SHIELD_DECAY_MULTIPLIER
	int shieldHealthMax = soul.GetShieldHealthMax()
	local chargeRatio = GetArcCannonChargeFraction( weapon )

	while( 1 )
	{
		if ( !IsValid( soul ) || !IsValid( weapon ) )
			break

		local baseCharge = GetWeaponChargeFrac( weapon ) // + GetOverchargeBonusChargeFraction()
		local charge = clamp ( baseCharge * ( 1 / chargeRatio ), 0.0, 1.0 )
		if ( charge < 1.0 || maxShieldDecay > 0)
		{
			int shieldHealth = soul.GetShieldHealth()

			//Slight inconsistency in server updates, this ensures it never takes too much.
			if ( shieldDecayMultiplier > maxShieldDecay )
				shieldDecayMultiplier = maxShieldDecay
			maxShieldDecay -= shieldDecayMultiplier

			local shieldDecayAmount = shieldHealthMax * shieldDecayMultiplier
			local newShieldAmount = shieldHealth - shieldDecayAmount
			soul.SetShieldHealth( max( newShieldAmount, 0 ) )
			soul.nextRegenTime = Time() + GetShieldRegenTime( soul )

			if ( shieldDecayAmount > shieldHealth )
				bonusChargeFraction = bonusChargeFraction * ( shieldHealth / shieldDecayAmount )
			weapon.SetWeaponChargeFraction( baseCharge + bonusChargeFraction )
		}
		wait 0.1
	}
}
#endif

function FireArcCannon( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	local weaponScriptScope = weapon.GetScriptScope()
	local baseCharge = GetWeaponChargeFrac( weapon ) // + GetOverchargeBonusChargeFraction()
	local charge = clamp( baseCharge * ( 1 / GetArcCannonChargeFraction( weapon ) ), 0.0, 1.0 )
	float newVolume = GraphCapped( charge, 0.25, 1.0, 0.0, 1.0 )

	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	weapon.PlayWeaponEffect( $"wpn_muzzleflash_arc_cannon_fp", $"wpn_muzzleflash_arc_cannon", "muzzle_flash" )

	local attachmentName = "muzzle_flash"
	local attachmentIndex = weapon.LookupAttachment( attachmentName )
	Assert( attachmentIndex >= 0 )
	local muzzleOrigin = weapon.GetAttachmentOrigin( attachmentIndex )

	//printt( "-------- FIRING ARC CANNON --------" )

	table firstTargetInfo = GetFirstArcCannonTarget( weapon, attackParams )
	if ( !IsValid( firstTargetInfo.target ) )
		FireArcNoTargets( weapon, attackParams, muzzleOrigin )
	else
		FireArcWithTargets( weapon, firstTargetInfo, attackParams, muzzleOrigin )

	return 1
}

table function GetFirstArcCannonTarget( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner 				= weapon.GetWeaponOwner()
	local coneHeight 			= weapon.GetMaxDamageFarDist()

	local angleToAxis 			= 2 // set this too high and auto-titans using it will error on FindVisibleEntitiesInCone
	array<entity> ignoredEntities = [ owner, weapon ]
	int traceMask 				= TRACE_MASK_SHOT
	int flags					= VIS_CONE_ENTS_TEST_HITBOXES
	local antilagPlayer			= null
	if ( owner.IsPlayer() )
	{
		angleToAxis = owner.GetAttackSpreadAngle() * 0.11
		antilagPlayer = owner
	}

	int ownerTeam = owner.GetTeam()

	// Get a missile target and a non-missile target in the cone that the player can zap
	// We do this in a separate check so we can use a wider cone to be more forgiving for targeting missiles
	table firstTargetInfo = {}
	firstTargetInfo.target <- null
	firstTargetInfo.hitLocation <- null

	for ( int i = 0; i < 2; i++ )
	{
		local missileCheck = i == 0
		local coneAngle = angleToAxis
		if ( missileCheck && owner.IsPlayer() ) // missile check only if owner is player
			coneAngle *= 8.0

		coneAngle = clamp( coneAngle, 0.1, 89.9 )

		array<VisibleEntityInCone> results = FindVisibleEntitiesInCone( attackParams.pos, attackParams.dir, coneHeight, coneAngle, ignoredEntities, traceMask, flags, antilagPlayer )
		foreach ( result in results )
		{
			entity visibleEnt = result.ent

			if ( !IsValid( visibleEnt ) )
				continue

			if ( visibleEnt.IsPhaseShifted() )
				continue

			local classname = IsServer() ? visibleEnt.GetClassName() : visibleEnt.GetSignifierName()

			if ( !( classname in ArcCannonTargetClassnames ) )
				continue

			if ( "GetTeam" in visibleEnt )
			{
				int visibleEntTeam = visibleEnt.GetTeam()
				if ( visibleEntTeam == ownerTeam )
					continue
				if ( IsEntANeutralMegaTurret( visibleEnt, ownerTeam ) )
					continue
			}

			expect string( classname )
			string targetname = visibleEnt.GetTargetName()

			if ( missileCheck && ( classname != "rpg_missile" && !file.missileCheckTargetnames.contains( targetname ) ) )
				continue

			if ( !missileCheck && ( classname == "rpg_missile" || file.missileCheckTargetnames.contains( targetname ) ) )
				continue

			firstTargetInfo.target = visibleEnt
			firstTargetInfo.hitLocation = result.visiblePosition
			break
		}
	}
	//Creating a whiz-by sound.
	weapon.FireWeaponBullet_Special( attackParams.pos, attackParams.dir, 1, 0, true, true, true, true, true, false, false )

	return firstTargetInfo
}

function FireArcNoTargets( entity weapon, WeaponPrimaryAttackParams attackParams, muzzleOrigin )
{
	Assert( IsValid( weapon ) )
	entity player = weapon.GetWeaponOwner()
	local chargeFrac = GetWeaponChargeFrac( weapon )
	local beamVec = attackParams.dir * weapon.GetMaxDamageFarDist()
	local playerEyePos = player.EyePosition()
	TraceResults traceResults = TraceLineHighDetail( playerEyePos, (playerEyePos + beamVec), weapon, (TRACE_MASK_PLAYERSOLID_BRUSHONLY | TRACE_MASK_BLOCKLOS), TRACE_COLLISION_GROUP_NONE )
	local beamEnd = traceResults.endPos

	VortexBulletHit ornull vortexHit = VortexBulletHitCheck( player, playerEyePos, beamEnd )
	if ( vortexHit )
	{
		expect VortexBulletHit( vortexHit )
		#if SERVER
			entity vortexWeapon = vortexHit.vortex.GetOwnerWeapon()
			string className = vortexWeapon.GetWeaponClassName()
			if ( vortexWeapon && ( className == "mp_titanweapon_vortex_shield" || className == "mp_titanweapon_vortex_shield_ion" ) )
			{
				// drain the vortex shield
				VortexDrainedByImpact( vortexWeapon, weapon, null, null )
			}
			else if ( IsVortexSphere( vortexHit.vortex ) )
			{
				// do damage to vortex_sphere entities that isn't the titan "vortex shield"
				local damageNear = weapon.GetWeaponInfoFileKeyField( "damage_near_value" )
				local damage = damageNear * GraphCapped( chargeFrac, 0, 0.5, 0.0, 1.0 ) * 10 // do more damage the more charged the weapon is.
				VortexSphereDrainHealthForDamage( vortexHit.vortex, damage )
			}
		#endif
		beamEnd = vortexHit.hitPos
	}

	float radius = Graph( chargeFrac, 0, 1, ARC_CANNON_BOLT_RADIUS_MIN, ARC_CANNON_BOLT_RADIUS_MAX )
	local boltWidth = Graph( chargeFrac, 0, 1, ARC_CANNON_BOLT_WIDTH_MIN, ARC_CANNON_BOLT_WIDTH_MAX )
	if ( player.IsNPC() )
		boltWidth = ARC_CANNON_BOLT_WIDTH_NPC
	thread CreateArcCannonBeam( weapon, null, muzzleOrigin, beamEnd, player, ARC_CANNON_BEAM_LIFETIME, radius, boltWidth, 2, false, true )

	#if SERVER
		PlayImpactFXTable( expect vector( beamEnd ), player, ARC_CANNON_FX_TABLE, SF_ENVEXPLOSION_INCLUDE_ENTITIES )
	#endif
}

function FireArcWithTargets( entity weapon, table firstTargetInfo, WeaponPrimaryAttackParams attackParams, muzzleOrigin )
{
	local beamStart = muzzleOrigin
	local beamEnd
	entity player = weapon.GetWeaponOwner()
	local chargeFrac = GetWeaponChargeFrac( weapon )
	float radius = Graph( chargeFrac, 0, 1, ARC_CANNON_BOLT_RADIUS_MIN, ARC_CANNON_BOLT_RADIUS_MAX )
	float boltWidth = Graph( chargeFrac, 0, 1, ARC_CANNON_BOLT_WIDTH_MIN, ARC_CANNON_BOLT_WIDTH_MAX )
	local maxChains
	local minChains

	if ( weapon.HasMod( "burn_mod_titan_arc_cannon" ) )
	{
		if ( player.IsNPC() )
			maxChains = ARC_CANNON_CHAIN_COUNT_NPC_BURN
		else
			maxChains = ARC_CANNON_CHAIN_COUNT_MAX_BURN

		minChains = ARC_CANNON_CHAIN_COUNT_MIN_BURN
	}
	else
	{
		if ( player.IsNPC() )
			maxChains = ARC_CANNON_CHAIN_COUNT_NPC
		else
			maxChains = ARC_CANNON_CHAIN_COUNT_MAX

		minChains = ARC_CANNON_CHAIN_COUNT_MIN
	}

	if ( !player.IsNPC() )
		maxChains = Graph( chargeFrac, 0, 1, minChains, maxChains )

	table zapInfo = {}
	zapInfo.weapon 			<- weapon
	zapInfo.player 			<- player
	zapInfo.muzzleOrigin	<- muzzleOrigin
	zapInfo.radius			<- radius
	zapInfo.boltWidth		<- boltWidth
	zapInfo.maxChains		<- maxChains
	zapInfo.chargeFrac		<- chargeFrac
	zapInfo.zappedTargets 	<- {}
	zapInfo.zappedTargets[ firstTargetInfo.target ] <- true
	zapInfo.dmgSourceID 	<- weapon.GetDamageSourceID()
	local chainNum = 1
	thread ZapTargetRecursive( expect entity( firstTargetInfo.target), zapInfo, zapInfo.muzzleOrigin, expect vector( firstTargetInfo.hitLocation ), chainNum )
}

function ZapTargetRecursive( entity target, table zapInfo, beamStartPos, vector ornull firstTargetBeamEndPos = null, chainNum = 1 )
{
	if ( !IsValid( target ) )
		return

	if ( !IsValid( zapInfo.weapon ) )
		return

	Assert( target in zapInfo.zappedTargets )
	if ( chainNum > zapInfo.maxChains )
		return
	vector beamEndPos
	if ( firstTargetBeamEndPos == null )
		beamEndPos = target.GetWorldSpaceCenter()
	else
		beamEndPos = expect vector( firstTargetBeamEndPos )

	waitthread ZapTarget( zapInfo, target, beamStartPos, beamEndPos, chainNum )

	// Get other nearby targets we can chain to
	#if SERVER
		if ( !IsValid( zapInfo.weapon ) )
			return

		var noArcing = expect entity( zapInfo.weapon ).GetWeaponInfoFileKeyField( "disable_arc" )

		if ( noArcing != null && noArcing == 1 )
			return // no chaining on new arc cannon

		// NOTE: 'target' could be invalid at this point (no corpse)
		array<entity> chainTargets = GetArcCannonChainTargets( beamEndPos, target, zapInfo )
		foreach( entity chainTarget in chainTargets )
		{
			local newChainNum = chainNum
			if ( chainTarget.GetClassName() != "rpg_missile" )
				newChainNum++
			zapInfo.zappedTargets[ chainTarget ] <- true
			thread ZapTargetRecursive( chainTarget, zapInfo, beamEndPos, null, newChainNum )
		}

		if ( IsValid( zapInfo.player ) && zapInfo.player.IsPlayer() && zapInfo.zappedTargets.len() >= 5 )
		{
			#if HAS_STATS
			if ( chainNum == 5 )
				UpdatePlayerStat( expect entity( zapInfo.player ), "misc_stats", "arcCannonMultiKills", 1 )
			#endif
		}
	#endif
}

function ZapTarget( zapInfo, target, beamStartPos, beamEndPos, chainNum = 1 )
{
	expect entity( target )
	expect vector( beamStartPos )
	expect vector( beamEndPos )

	//DebugDrawLine( beamStartPos, beamEndPos, 255, 0, 0, true, 5.0 )
	local boltWidth = zapInfo.boltWidth
	if ( zapInfo.player.IsNPC() )
		boltWidth = ARC_CANNON_BOLT_WIDTH_NPC
	local firstBeam = ( chainNum == 1 )
	#if SERVER
		if ( firstBeam )
		{
			PlayImpactFXTable( beamEndPos, expect entity( zapInfo.player ), ARC_CANNON_FX_TABLE, SF_ENVEXPLOSION_INCLUDE_ENTITIES )
		}
	#endif

	thread CreateArcCannonBeam( zapInfo.weapon, target, beamStartPos, beamEndPos, zapInfo.player, ARC_CANNON_BEAM_LIFETIME, zapInfo.radius, boltWidth, 5, true, firstBeam )

	#if SERVER
		local isMissile = ( target.GetClassName() == "rpg_missile" )
		if ( !isMissile )
			wait ARC_CANNON_FORK_DELAY
		else
			wait 0.05

		local deathPackage = damageTypes.arcCannon

		float damageAmount
		int damageMin
		int damageMax

		int damageFarValue = eWeaponVar.damage_far_value
		int damageNearValue = eWeaponVar.damage_near_value
		int damageFarValueTitanArmor = eWeaponVar.damage_far_value_titanarmor
		int damageNearValueTitanArmor = eWeaponVar.damage_near_value_titanarmor
		if ( zapInfo.player.IsNPC() )
		{
			damageFarValue = eWeaponVar.npc_damage_far_value
			damageNearValue = eWeaponVar.npc_damage_near_value
			damageFarValueTitanArmor = eWeaponVar.npc_damage_far_value_titanarmor
			damageNearValueTitanArmor = eWeaponVar.npc_damage_near_value_titanarmor
		}

		if ( IsValid( target ) && IsValid( zapInfo.player ) )
		{
			bool hasFastPacitor = false
			bool noArcing = false

			if ( IsValid( zapInfo.weapon ) )
			{
				entity weap = expect entity( zapInfo.weapon )
				hasFastPacitor = weap.GetWeaponInfoFileKeyField( "push_apart" ) != null && weap.GetWeaponInfoFileKeyField( "push_apart" ) == 1
				noArcing = weap.GetWeaponInfoFileKeyField( "no_arcing" ) != null && weap.GetWeaponInfoFileKeyField( "no_arcing" ) == 1
			}

			if ( target.GetArmorType() == ARMOR_TYPE_HEAVY )
			{
				if ( IsValid( zapInfo.weapon ) )
				{
					entity weapon = expect entity( zapInfo.weapon )
					damageMin = weapon.GetWeaponSettingInt( damageFarValueTitanArmor )
					damageMax = weapon.GetWeaponSettingInt( damageNearValueTitanArmor )
				}
				else
				{
					damageMin = 100
					damageMax = zapInfo.player.IsNPC() ? 1200 : 800
				}
			}
			else
			{
				if ( IsValid( zapInfo.weapon ) )
				{
					entity weapon = expect entity( zapInfo.weapon )
					damageMin = weapon.GetWeaponSettingInt( damageFarValue )
					damageMax = weapon.GetWeaponSettingInt( damageNearValue )
				}
				else
				{
					damageMin = 120
					damageMax = zapInfo.player.IsNPC() ? 140 : 275
				}

				if ( target.IsNPC() )
				{
					damageMin *= 3	// more powerful against NPC humans so they die easy
					damageMax *= 3
				}
			}


			local chargeRatio = GetArcCannonChargeFraction( zapInfo.weapon )
			if  ( IsValid( zapInfo.weapon ) && !zapInfo.weapon.GetWeaponSettingBool( eWeaponVar.charge_require_input ) )
			{
				// use distance for damage if the weapon auto-fires
				entity weapon = expect entity( zapInfo.weapon )
				float nearDist = weapon.GetWeaponSettingFloat( eWeaponVar.damage_near_distance )
				float farDist = weapon.GetWeaponSettingFloat( eWeaponVar.damage_far_distance )

				float dist = Distance( weapon.GetOrigin(), target.GetOrigin() )
				damageAmount = GraphCapped( dist, farDist, nearDist, damageMin, damageMax )
			}
			else
			{
				// Scale damage amount based on how many chains deep we are
				damageAmount = GraphCapped( zapInfo.chargeFrac, 0, chargeRatio, damageMin, damageMax )
			}
			local damageFalloff = ARC_CANNON_DAMAGE_FALLOFF_SCALER
			if ( IsValid( zapInfo.weapon ) && zapInfo.weapon.HasMod( "splitter" ) )
				damageFalloff = SPLITTER_DAMAGE_FALLOFF_SCALER
			damageAmount *= pow( damageFalloff, chainNum - 1 )

			local dmgSourceID = zapInfo.dmgSourceID

			// Update Later - This shouldn't be done here, this is not where we determine if damage actually happened to the target
			// move to Damaged callback instead
			if ( damageAmount > 0 )
			{
				float empDuration = GraphCapped( zapInfo.chargeFrac, 0, chargeRatio, ARC_CANNON_EMP_DURATION_MIN, ARC_CANNON_EMP_DURATION_MAX )

				if ( target.IsPlayer() && target.IsTitan() && !hasFastPacitor && !noArcing )
				{
					float empViewStrength = GraphCapped( zapInfo.chargeFrac, 0, chargeRatio, ARC_CANNON_SCREEN_EFFECTS_MIN, ARC_CANNON_SCREEN_EFFECTS_MAX )

					if ( target.IsTitan() && zapInfo.chargeFrac >= ARC_CANNON_SCREEN_THRESHOLD )
					{
						Remote_CallFunction_Replay( target, "ServerCallback_TitanEMP", empViewStrength, empDuration, ARC_CANNON_EMP_FADEOUT_DURATION )
						EmitSoundOnEntityOnlyToPlayer( target, target, ARC_CANNON_TITAN_SCREEN_SFX )
					}
					else if ( zapInfo.chargeFrac >= ARC_CANNON_SCREEN_THRESHOLD )
					{
						StatusEffect_AddTimed( target, eStatusEffect.emp, empViewStrength, empDuration, ARC_CANNON_EMP_FADEOUT_DURATION )
						EmitSoundOnEntityOnlyToPlayer( target, target, ARC_CANNON_PILOT_SCREEN_SFX )
					}
				}

				// Do 3rd person effect on the body
				asset effect
				string tag
				target.TakeDamage( damageAmount, zapInfo.player, zapInfo.player, { origin = beamEndPos, force = Vector(0,0,0), scriptType = deathPackage, weapon = zapInfo.weapon, damageSourceId = dmgSourceID } )
				//vector dir = Normalize( beamEndPos - beamStartPos )
				//vector velocity = dir * 600
				//PushPlayerAway( target, velocity )
				//PushPlayerAway( expect entity( zapInfo.player ), -velocity )

				if ( IsValid( zapInfo.weapon ) && hasFastPacitor )
				{
					if ( IsAlive( target ) && IsAlive( expect entity( zapInfo.player ) ) && target.IsTitan() )
					{
						float pushPercent = GraphCapped( damageAmount, damageMin, damageMax, 0.0, 1.0 )

						if ( pushPercent > 0.6 )
							PushPlayersApart( target, expect entity( zapInfo.player ), pushPercent * 400.0 )
					}
				}

				if ( zapInfo.chargeFrac < ARC_CANNON_SCREEN_THRESHOLD )
					empDuration = ARC_CANNON_3RD_PERSON_EFFECT_MIN_DURATION
				else
					empDuration += ARC_CANNON_EMP_FADEOUT_DURATION

				if ( target.GetArmorType() == ARMOR_TYPE_HEAVY )
				{
					effect = $"impact_arc_cannon_titan"
					tag = "exp_torso_front"
				}
				else
				{
					effect = $"P_emp_body_human"
					tag = "CHESTFOCUS"
				}

				if ( target.IsPlayer() )
				{
					if ( target.LookupAttachment( tag ) != 0 )
						ClientStylePlayFXOnEntity( effect, target, tag, empDuration )
				}

				if ( target.IsPlayer() )
					EmitSoundOnEntityExceptToPlayer( target, target, "Titan_Blue_Electricity_Cloud" )
				else
					EmitSoundOnEntity( target, "Titan_Blue_Electricity_Cloud" )

				thread FadeOutSoundOnEntityAfterDelay( target, "Titan_Blue_Electricity_Cloud", empDuration * 0.6666, empDuration * 0.3333 )
			}
			else
			{
				//Don't bounce if the beam is set to do 0 damage.
				chainNum = zapInfo.maxChains
			}

			if ( isMissile )
			{
				if ( IsValid( zapInfo.player ) )
					target.SetOwner( zapInfo.player )
				target.MissileExplode()
			}
		}
	#endif // SERVER
}


#if SERVER

void function PushEntForTime( entity ent, vector velocity, float time )
{
	ent.EndSignal( "OnDeath" )
	float endTime = Time() + time
	float startTime = Time()
	for ( ;; )
	{
		if ( Time() >= endTime )
			break
		float multiplier = Graph( Time(), startTime, endTime, 1.0, 0.0 )
		vector currentVel = ent.GetVelocity()
		currentVel += velocity * multiplier
		ent.SetVelocity( currentVel )
		WaitFrame()
	}
}

array<entity> function GetArcCannonChainTargets( vector fromOrigin, entity fromTarget, table zapInfo )
{
	// NOTE: fromTarget could be null/invalid if it was a drone
	array<entity> results = []
	if ( !IsValid( zapInfo.player ) )
		return results

	int playerTeam = expect entity( zapInfo.player ).GetTeam()
	array<entity> allTargets = GetArcCannonTargetsInRange( fromOrigin, playerTeam, expect entity( zapInfo.weapon ) )
	allTargets = ArrayClosest( allTargets, fromOrigin )

	local viewVector
	if ( zapInfo.player.IsPlayer() )
		viewVector = zapInfo.player.GetViewVector()
	else
		viewVector = AnglesToForward( zapInfo.player.EyeAngles() )

	local eyePosition = zapInfo.player.EyePosition()

	foreach ( ent in allTargets )
	{
		local forkCount = ARC_CANNON_FORK_COUNT_MAX
		if ( zapInfo.weapon.HasMod( "splitter" ) )
			forkCount = SPLITTER_FORK_COUNT_MAX
		else if ( zapInfo.weapon.HasMod( "burn_mod_titan_arc_cannon" ) )
			forkCount = ARC_CANNON_FORK_COUNT_MAX_BURN

		if ( results.len() >= forkCount )
			break

		if ( ent.IsPhaseShifted() )
			continue

		if ( ent.IsPlayer() )
		{
			// Ignore players that are passing damage to their parent. This is to address zapping a friendly rodeo player
			local entParent = ent.GetParent()
			if ( IsValid( entParent ) && ent.kv.PassDamageToParent.tointeger() )
				continue

			// only chains to other titan players for now
			if ( !ent.IsTitan() )
				continue
		}

		if ( ent.GetClassName() == "script_mover" )
			continue

		if ( IsEntANeutralMegaTurret( ent, playerTeam ) )
			continue

		if ( !IsAlive( ent ) )
			continue

		// Don't consider targets that already got zapped
		if ( ent in zapInfo.zappedTargets )
			continue

		//Preventing the arc-cannon from firing behind.
		local vecToEnt = ( ent.GetWorldSpaceCenter() - eyePosition )
		vecToEnt.Norm()
		local dotVal = DotProduct( vecToEnt, viewVector )
		if ( dotVal < 0 )
			continue

		// Check if we can see them, they aren't behind a wall or something
		local ignoreEnts = []
		ignoreEnts.append( zapInfo.player )
		ignoreEnts.append( ent )

		foreach( zappedTarget, val in zapInfo.zappedTargets )
		{
			if ( IsValid( zappedTarget ) )
				ignoreEnts.append( zappedTarget )
		}

		TraceResults traceResult = TraceLineHighDetail( fromOrigin, ent.GetWorldSpaceCenter(), ignoreEnts, (TRACE_MASK_PLAYERSOLID_BRUSHONLY | TRACE_MASK_BLOCKLOS), TRACE_COLLISION_GROUP_NONE )

		// Trace failed, lets try an eye to eye trace
		if ( traceResult.fraction < 1 )
		{
			// 'fromTarget' may be invalid
			if ( IsValid( fromTarget ) )
				traceResult = TraceLineHighDetail( fromTarget.EyePosition(), ent.EyePosition(), ignoreEnts, (TRACE_MASK_PLAYERSOLID_BRUSHONLY | TRACE_MASK_BLOCKLOS), TRACE_COLLISION_GROUP_NONE )
		}

		if ( traceResult.fraction < 1 )
			continue

		// Enemy is in visible, and within range.
		if ( !results.contains( ent ) )
			results.append( ent )
	}

	//printt( "NEARBY TARGETS VALID AND VISIBLE:", results.len() )

	return results
}
#endif // SERVER

bool function IsEntANeutralMegaTurret( ent, int playerTeam )
{
	expect entity( ent )

	if ( ent.GetClassName() != "npc_turret_mega" )
		return false
	int entTeam = ent.GetTeam()
	if ( entTeam == playerTeam )
		return false
	if ( !IsEnemyTeam( playerTeam, entTeam ) )
		return true

	return false
}

function ArcCannon_HideIdleEffect( entity weapon, delay )
{
	bool weaponOwnerIsPilot = IsPilot( weapon.GetWeaponOwner() )
	weapon.EndSignal( ARC_CANNON_SIGNAL_DEACTIVATED )
	if ( weaponOwnerIsPilot == false )
	{
		weapon.StopWeaponEffect( $"wpn_arc_cannon_electricity_fp", $"wpn_arc_cannon_electricity" )
		weapon.StopWeaponSound( "arc_cannon_charged_loop" )
	}
	wait delay

	if ( !IsValid( weapon ) )
		return

	entity weaponOwner = weapon.GetWeaponOwner()
	//The weapon can be valid, but the player isn't a Titan during melee execute.
	// JFS: threads with waits should just end on "OnDestroy"
	if ( !IsValid( weaponOwner ) )
		return

	if ( weapon != weaponOwner.GetActiveWeapon() )
		return

	if ( weaponOwnerIsPilot == false )
	{
		weapon.PlayWeaponEffectNoCull( $"wpn_arc_cannon_electricity_fp", $"wpn_arc_cannon_electricity", "muzzle_flash" )
		weapon.EmitWeaponSound( "arc_cannon_charged_loop" )
	}
	else
	{
		weapon.EmitWeaponSound_1p3p( "Arc_Rifle_charged_Loop_1P", "Arc_Rifle_charged_Loop_3P" )
	}
}

#if SERVER
void function AddToArcCannonTargets( entity ent )
{
	AddToScriptManagedEntArray( level._arcCannonTargetsArrayID, ent );
}

function RemoveArcCannonTarget( ent )
{
	RemoveFromScriptManagedEntArray( level._arcCannonTargetsArrayID, ent )
}

array<entity> function GetArcCannonTargets( vector origin, int team )
{
	array<entity> targets = GetScriptManagedEntArrayWithinCenter( level._arcCannonTargetsArrayID, team, origin, ARC_CANNON_TITAN_RANGE_CHAIN )

	if ( ARC_CANNON_TARGETS_MISSILES )
		targets.extend( GetProjectileArrayEx( "rpg_missile", TEAM_ANY, team, origin, ARC_CANNON_TITAN_RANGE_CHAIN ) )

	return targets
}

array<entity> function GetArcCannonTargetsInRange( vector origin, int team, entity weapon )
{
	array<entity> allTargets = GetArcCannonTargets( origin, team )
	array<entity> targetsInRange

	float titanDistSq
	float distSq
	if ( weapon.HasMod( "burn_mod_titan_arc_cannon" ) )
	{
		titanDistSq = ARC_CANNON_TITAN_RANGE_CHAIN_BURN * ARC_CANNON_TITAN_RANGE_CHAIN_BURN
		distSq = ARC_CANNON_RANGE_CHAIN_BURN * ARC_CANNON_RANGE_CHAIN_BURN
	}
	else
	{
		titanDistSq = ARC_CANNON_TITAN_RANGE_CHAIN * ARC_CANNON_TITAN_RANGE_CHAIN
		distSq = ARC_CANNON_RANGE_CHAIN * ARC_CANNON_RANGE_CHAIN
	}

	foreach( target in allTargets )
	{
		float d = DistanceSqr( target.GetOrigin(), origin )
		float validDist = target.IsTitan() ? titanDistSq : distSq
		if ( d <= validDist )
			targetsInRange.append( target )
	}

	return targetsInRange
}
#endif // SERVER

function CreateArcCannonBeam( weapon, target, startPos, endPos, player, lifeDuration = ARC_CANNON_BEAM_LIFETIME, radius = 256, boltWidth = 4, noiseAmplitude = 5, hasTarget = true, firstBeam = false )
{
	Assert( startPos )
	Assert( endPos )

	//**************************
	// 	LIGHTNING BEAM EFFECT
	//**************************
	if ( weapon.HasMod( "burn_mod_titan_arc_cannon" ) )
		lifeDuration = ARC_CANNON_BEAM_LIFETIME_BURN
	// If it's the first beam and on client we do a special beam so it's lined up with the muzzle origin
	#if CLIENT
		if ( firstBeam )
			thread CreateClientArcBeam( weapon, endPos, lifeDuration, target )
	#endif

	#if SERVER
		// Control point sets the end position of the effect
		entity cpEnd = CreateEntity( "info_placement_helper" )
		SetTargetName( cpEnd, UniqueString( "arc_cannon_beam_cpEnd" ) )
		cpEnd.SetOrigin( endPos )
		DispatchSpawn( cpEnd )

		entity zapBeam = CreateEntity( "info_particle_system" )
		zapBeam.kv.cpoint1 = cpEnd.GetTargetName()

		zapBeam.SetValueForEffectNameKey( GetBeamEffect( weapon ) )

		zapBeam.kv.start_active = 0
		zapBeam.SetOwner( player )
		zapBeam.SetOrigin( startPos )
		if ( firstBeam )
		{
			zapBeam.kv.VisibilityFlags = (ENTITY_VISIBLE_TO_FRIENDLY | ENTITY_VISIBLE_TO_ENEMY)	// everyone but owner
			zapBeam.SetParent( player.GetActiveWeapon(), "muzzle_flash", false, 0.0 )
		}
		DispatchSpawn( zapBeam )

		zapBeam.Fire( "Start" )
		zapBeam.Fire( "StopPlayEndCap", "", lifeDuration )
		zapBeam.Kill_Deprecated_UseDestroyInstead( lifeDuration )
		cpEnd.Kill_Deprecated_UseDestroyInstead( lifeDuration )
	#endif
}

function GetBeamEffect( weapon )
{
	if ( weapon.HasMod( "burn_mod_titan_arc_cannon" ) )
		return ARC_CANNON_BEAM_EFFECT_MOD

	return ARC_CANNON_BEAM_EFFECT
}

#if CLIENT
function CreateClientArcBeam( weapon, endPos, lifeDuration, target )
{
	Assert( IsClient() )

	local beamEffect = GetBeamEffect( weapon )

	// HACK HACK HACK HACK
	string tag = "muzzle_flash"
	if ( weapon.GetWeaponInfoFileKeyField( "client_tag_override" ) != null )
		tag = expect string( weapon.GetWeaponInfoFileKeyField( "client_tag_override" ) )

	local handle = weapon.PlayWeaponEffectReturnViewEffectHandle( beamEffect, $"", tag )
	if ( !EffectDoesExist( handle ) )
		return

	EffectSetControlPointVector( handle, 1, endPos )

	if ( weapon.HasMod( "burn_mod_titan_arc_cannon" ) )
		lifeDuration = ARC_CANNON_BEAM_LIFETIME_BURN

	wait( lifeDuration )

	if ( IsValid( weapon ) )
		weapon.StopWeaponEffect( beamEffect, $"" )
}

void function ClientDestroyCallback_ArcCannon_Stop( entity ent )
{
	ArcCannon_Stop( ent )
}
#endif // CLIENT

function GetArcCannonChargeFraction( weapon )
{
	if ( IsValid( weapon ) )
	{
		local chargeRatio = ARC_CANNON_DAMAGE_CHARGE_RATIO
		if ( weapon.HasMod( "capacitor" ) )
			chargeRatio = ARC_CANNON_CAPACITOR_CHARGE_RATIO
		if ( weapon.GetWeaponSettingBool( eWeaponVar.is_burn_mod ) )
			chargeRatio = ARC_CANNON_DAMAGE_CHARGE_RATIO_BURN
		return chargeRatio
	}

	return 0
}

function GetWeaponChargeFrac( weapon )
{
	if ( weapon.IsChargeWeapon() )
		return weapon.GetWeaponChargeFraction()
	return 1.0
}