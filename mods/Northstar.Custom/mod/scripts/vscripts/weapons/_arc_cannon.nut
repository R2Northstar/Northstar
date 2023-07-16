
// Aiming & Range
const DEFAULT_ARC_CANNON_FOVDOT				= 0.98		// First target must be within this dot to be zapped and start a chain
const DEFAULT_ARC_CANNON_FOVDOT_MISSILE		= 0.95		// First target must be within this dot to be zapped and start a chain ( if it's a missile, we allow more leaniency )
const ARC_CANNON_RANGE_CHAIN				= 400		// Max distance we can arc from one target to another
const ARC_CANNON_TITAN_RANGE_CHAIN			= 900		// Max distance we can arc from one target to another
const ARC_CANNON_CHAIN_COUNT_MIN			= 5			// Max number of chains at no charge
const ARC_CANNON_CHAIN_COUNT_MAX			= 5			// Max number of chains at full charge
const ARC_CANNON_CHAIN_COUNT_NPC			= 2			// Number of chains when an NPC fires the weapon
const ARC_CANNON_FORK_COUNT_MAX				= 1			// Number of forks that can come out of one target to other targets
const ARC_CANNON_FORK_DELAY					= 0.1

const ARC_CANNON_RANGE_CHAIN_BURN			= 400
const ARC_CANNON_TITAN_RANGE_CHAIN_BURN		= 900
const ARC_CANNON_CHAIN_COUNT_MIN_BURN		= 100		// Max number of chains at no charge
const ARC_CANNON_CHAIN_COUNT_MAX_BURN		= 100		// Max number of chains at full charge
const ARC_CANNON_CHAIN_COUNT_NPC_BURN		= 10		// Number of chains when an NPC fires the weapon
const ARC_CANNON_FORK_COUNT_MAX_BURN		= 10		// Number of forks that can come out of one target to other targets
const ARC_CANNON_BEAM_LIFETIME_BURN			= 1

// Visual settings
const ARC_CANNON_BOLT_RADIUS_MIN 			= 32		// Bolt radius at no charge ( not actually sure what this does to the beam lol )
const ARC_CANNON_BOLT_RADIUS_MAX 			= 640		// Bold radius at full charge ( not actually sure what this does to the beam lol )
const ARC_CANNON_BOLT_WIDTH_MIN 			= 1			// Bolt width at no charge
const ARC_CANNON_BOLT_WIDTH_MAX 			= 26		// Bolt width at full charge
const ARC_CANNON_BOLT_WIDTH_NPC				= 8			// Bolt width when used by NPC
const ARC_CANNON_BEAM_COLOR					= "150 190 255"
const ARC_CANNON_BEAM_LIFETIME				= 0.75

// Player Effects
const ARC_CANNON_TITAN_SCREEN_SFX 		= "Weapon_R1_LaserMine.Activate"
const ARC_CANNON_PILOT_SCREEN_SFX 		= "Weapon_R1_LaserMine.Activate"
const ARC_CANNON_EMP_DURATION_MIN 		= 0.1
const ARC_CANNON_EMP_DURATION_MAX		= 1.8
const ARC_CANNON_EMP_FADEOUT_DURATION	= 0.4
const ARC_CANNON_SCREEN_EFFECTS_MIN 	= 0.025
const ARC_CANNON_SCREEN_EFFECTS_MAX 	= 0.075
const ARC_CANNON_SCREEN_THRESHOLD		= 0.3385
const ARC_CANNON_SLOW_SCALE_MIN 		= 0.8
const ARC_CANNON_SLOW_SCALE_MAX 		= 0.7
const ARC_CANNON_3RD_PERSON_EFFECT_MIN_DURATION = 0.2

// Rumble
const ARC_CANNON_RUMBLE_CHARGE_MIN			= 5
const ARC_CANNON_RUMBLE_CHARGE_MAX			= 50
const ARC_CANNON_RUMBLE_TYPE_INDEX			= 14		// These are defined in code, 14 = RUMBLE_FLAT_BOTH

// Damage
const ARC_CANNON_DAMAGE_FALLOFF_SCALER		= 0.75		// Amount of damage carried on to the next target in the chain lightning. If 0.75, then a target that would normally take 100 damage will take 75 damage if they are one chain deep, or 56 damage if 2 levels deep
const ARC_CANNON_DAMAGE_CHARGE_RATIO		= 0.85		// What amount of charge is required for full damage.
const ARC_CANNON_DAMAGE_CHARGE_RATIO_BURN	= 0.676		// What amount of charge is required for full damage.
const ARC_CANNON_CAPACITOR_CHARGE_RATIO		= 1.0

// Options
const ARC_CANNON_TARGETS_MISSILES 			= 1			// 1 = arc cannon zaps missiles that are active, 0 = missiles are ignored by arc cannon

//Mods
const OVERCHARGE_MAX_SHIELD_DECAY       	= 0.2
const OVERCHARGE_SHIELD_DECAY_MULTIPLIER 	= 0.04
const OVERCHARGE_BONUS_CHARGE_FRACTION		= 0.05

const SPLITTER_DAMAGE_FALLOFF_SCALER		= 0.6
const SPLITTER_FORK_COUNT_MAX				= 10

const ARC_CANNON_SIGNAL_DEACTIVATED	= "ArcCannonDeactivated"
RegisterSignal( ARC_CANNON_SIGNAL_DEACTIVATED )

const ARC_CANNON_SIGNAL_CHARGEEND = "ArcCannonChargeEnd"
RegisterSignal( ARC_CANNON_SIGNAL_CHARGEEND )

const ARC_CANNON_BEAM_EFFECT = "wpn_arc_cannon_beam"
PrecacheParticleSystem( ARC_CANNON_BEAM_EFFECT )

const ARC_CANNON_BEAM_EFFECT_MOD = "wpn_arc_cannon_beam_mod"
PrecacheParticleSystem( ARC_CANNON_BEAM_EFFECT_MOD )

const ARC_CANNON_FX_TABLE = "exp_arc_cannon"
PrecacheImpactEffectTable( ARC_CANNON_FX_TABLE )

if ( !reloadingScripts )
{
	// Valid Arc Cannon Target Classnames
	level.arcCannonTargetClassnames <- {}
	level.arcCannonTargetClassnames[ "npc_turret_floor" ] 	<- true
	level.arcCannonTargetClassnames[ "npc_spectre" ] 		<- true
	level.arcCannonTargetClassnames[ "npc_soldier_shield" ] <- true
	level.arcCannonTargetClassnames[ "npc_soldier_heavy" ] 	<- true
	level.arcCannonTargetClassnames[ "npc_soldier" ] 		<- true
	level.arcCannonTargetClassnames[ "npc_cscanner" ] 		<- true
	level.arcCannonTargetClassnames[ "npc_titan" ] 			<- true
	level.arcCannonTargetClassnames[ "npc_marvin" ] 		<- true
	level.arcCannonTargetClassnames[ "player" ] 			<- true
	level.arcCannonTargetClassnames[ "script_mover" ] 		<- true
	level.arcCannonTargetClassnames[ "npc_grenade_frag" ] 	<- true
	level.arcCannonTargetClassnames[ "rpg_missile" ] 		<- true
	level.arcCannonTargetClassnames[ "npc_turret_mega" ]	<- true
	level.arcCannonTargetClassnames[ "npc_turret_sentry" ] 	<- true
	level.arcCannonTargetClassnames[ "npc_dropship" ] 		<- true
	level.arcCannonTargetClassnames[ "prop_dynamic" ] 		<- true
}

function main()
{
	Globalize( ArcCannon_PrecacheFX )
	Globalize( ArcCannon_Start )
	Globalize( ArcCannon_Stop )
	Globalize( ArcCannon_ChargeBegin )
	Globalize( ArcCannon_ChargeEnd )
	Globalize( FireArcCannon )
	Globalize( ArcCannon_HideIdleEffect )
	Globalize( AddToArcCannonTargets )
	Globalize( ConvertTitanShieldIntoBonusCharge )
	Globalize( GetArcCannonChargeFraction )
	Globalize( StopChargeEffects )

	if( IsClient() )
	{
		AddDestroyCallback( "mp_titanweapon_arc_cannon", ClientDestroyCallback_ArcCannon_Stop )
	}
	else
	{
		level._arcCannonTargetsArrayID <- CreateScriptManagedEntArray()
	}

	PrecacheParticleSystem( "impact_arc_cannon_titan" )
}

function ArcCannon_PrecacheFX( weapon )
{
	if ( WeaponIsPrecached( weapon ) )
		return

	PrecacheParticleSystem( "wpn_arc_cannon_electricity_fp" )
	PrecacheParticleSystem( "wpn_arc_cannon_electricity" )

	PrecacheParticleSystem( "wpn_ARC_knob_FP" )
	PrecacheParticleSystem( "wpn_ARC_knob" )

	PrecacheParticleSystem( "wpn_arc_cannon_charge_fp" )
	PrecacheParticleSystem( "wpn_arc_cannon_charge" )

	PrecacheParticleSystem( "wpn_arc_cannon_charge_fp" )
	PrecacheParticleSystem( "wpn_arc_cannon_charge" )

	PrecacheParticleSystem( "wpn_muzzleflash_arc_cannon_fp" )
	PrecacheParticleSystem( "wpn_muzzleflash_arc_cannon" )
}

function ArcCannon_Start( weapon )
{
	weapon.PlayWeaponEffectNoCull( "wpn_arc_cannon_electricity_fp", "wpn_arc_cannon_electricity", "muzzle_flash" )
	weapon.EmitWeaponSound( "arc_cannon_charged_loop" )
}

function ArcCannon_Stop( weapon, player = null )
{
	weapon.Signal( ARC_CANNON_SIGNAL_DEACTIVATED )
	StopChargeEffects( weapon, player )

	weapon.StopWeaponEffect( "wpn_arc_cannon_electricity_fp", "wpn_arc_cannon_electricity" )
	weapon.StopWeaponSound( "arc_cannon_charged_loop" )
	weapon.StopWeaponSound( "arc_cannon_charge" )
}

function ArcCannon_ChargeBegin( weapon )
{
	local weaponOwner = weapon.GetWeaponOwner()
	local weaponScriptScope = weapon.GetScriptScope()
	local useNormalChargeSounds = true
	if( weapon.HasMod( "overcharge" ) )
	{
		if ( weaponOwner.IsTitan() )
		{
			local soul = weaponOwner.GetTitanSoul()
			if ( soul.GetShieldHealth() > 0 )
			{
				weapon.EmitWeaponSound( "arc_cannon_fastcharge" )
				useNormalChargeSounds = false
			}
			if ( IsServer() )
				thread ConvertTitanShieldIntoBonusCharge( soul, weapon )
		}
	}

	if ( useNormalChargeSounds )
	{
		weapon.EmitWeaponSound( "arc_cannon_charge" )
	}

	if( !("maxChargeTime" in weapon.s) )
		weapon.s.maxChargeTime <- weapon.GetWeaponModSetting( "charge_time" )

	weapon.PlayWeaponEffectNoCull( "wpn_arc_cannon_charge_fp", "wpn_arc_cannon_charge", "muzzle_flash" )
	local chargeTime = weapon.GetWeaponChargeTime()

	if ( IsClient() )
	{
		if ( !weapon.ShouldPredictProjectiles() )
			return

		if ( weaponOwner.IsPlayer() )
			weaponOwner.StartArcCannon();

		local handle = weapon.AllocateHandleForViewmodelEffect( "wpn_arc_cannon_charge_fp" )
		if ( handle )
			EffectSkipForwardToTime( handle, chargeTime )

		thread cl_ChargeRumble( weapon, ARC_CANNON_RUMBLE_TYPE_INDEX, ARC_CANNON_RUMBLE_CHARGE_MIN, ARC_CANNON_RUMBLE_CHARGE_MAX, ARC_CANNON_SIGNAL_CHARGEEND )
	}
	thread ChargeEffects( weapon )
}

function ArcCannon_ChargeEnd( weapon, player = null )
{
	if ( IsClient() && weapon.GetWeaponOwner() == GetLocalViewPlayer() )
	{
		local weaponOwner
		if ( player != null )
			weaponOwner = player
		else
			weaponOwner = weapon.GetWeaponOwner()

		if ( IsValid( weaponOwner ) && weaponOwner.IsPlayer() )
			weaponOwner.StopArcCannon()
	}
	if( IsValid( weapon ) )
		StopChargeEffects( weapon )
}

function StopChargeEffects( weapon, player = null )
{
	weapon.Signal( ARC_CANNON_SIGNAL_CHARGEEND )

	local weaponScriptScope = weapon.GetScriptScope()
	weapon.StopWeaponSound( "arc_cannon_charge" )
	weapon.StopWeaponEffect( "wpn_arc_cannon_charge_fp", "wpn_arc_cannon_charge" )
	weapon.StopWeaponSound( "arc_cannon_fastcharge" )
	//weapon.StopWeaponEffect( "wpn_arc_cannon_charge_fp", "wpn_arc_cannon_charge" )
	weapon.StopWeaponEffect( "wpn_ARC_knob_FP", "wpn_ARC_knob" )
}

function ChargeEffects( weapon )
{
	weapon.EndSignal( ARC_CANNON_SIGNAL_CHARGEEND )
	weapon.EndSignal( "OnDestroy" )

	local player = weapon.GetWeaponOwner()

	wait ( weapon.s.maxChargeTime * GetArcCannonChargeFraction( weapon ) )

	weapon.PlayWeaponEffectNoCull( "wpn_ARC_knob_FP", "wpn_ARC_knob", "SPINNING_KNOB" )
}

function ConvertTitanShieldIntoBonusCharge( soul, weapon )
{
	weapon.EndSignal( ARC_CANNON_SIGNAL_CHARGEEND )
	weapon.EndSignal( "OnDestroy" )

	local maxShieldDecay = OVERCHARGE_MAX_SHIELD_DECAY
	local bonusChargeFraction = OVERCHARGE_BONUS_CHARGE_FRACTION
	local shieldDecayMultiplier = OVERCHARGE_SHIELD_DECAY_MULTIPLIER
	local shieldHealthMax = soul.GetShieldHealthMax()
	local chargeRatio = GetArcCannonChargeFraction( weapon )

	while( 1 )
	{
		if( !IsValid( soul ) || !IsValid( weapon ) )
			break

		local baseCharge = weapon.GetWeaponChargeFraction() // + GetOverchargeBonusChargeFraction()
		local charge = clamp ( baseCharge * ( 1 / chargeRatio ), 0.0, 1.0 )
		if( charge < 1.0 || maxShieldDecay > 0)
		{
			local shieldHealth = soul.GetShieldHealth()

			//Slight inconsistency in server updates, this ensures it never takes too much.
			if ( shieldDecayMultiplier > maxShieldDecay )
				shieldDecayMultiplier = maxShieldDecay
			maxShieldDecay -= shieldDecayMultiplier

			local shieldDecayAmount = shieldHealthMax * shieldDecayMultiplier
			local newShieldAmount = shieldHealth - shieldDecayAmount
			soul.SetShieldHealth( max( newShieldAmount, 0 ) )
			soul.s.nextRegenTime = Time() + TITAN_SHIELD_REGEN_DELAY

			if( shieldDecayAmount > shieldHealth )
				bonusChargeFraction = bonusChargeFraction * ( shieldHealth / shieldDecayAmount )
			weapon.SetWeaponChargeFraction( baseCharge + bonusChargeFraction )
		}
		wait 0.1
	}
}

function FireArcCannon( weapon, attackParams )
{
	local weaponScriptScope = weapon.GetScriptScope()
	local owner = weapon.GetWeaponOwner()

	local baseCharge = weapon.GetWeaponChargeFraction() // + GetOverchargeBonusChargeFraction()
	local charge = clamp ( baseCharge * ( 1 / GetArcCannonChargeFraction( weapon ) ), 0.0, 1.0 )
	local newVolume = GraphCapped( charge, 0.25, 1.0, 0.0, 1.0 )
	if ( weapon.HasMod( "burn_mod_titan_arc_cannon" ) )
	{
		weapon.EmitWeaponSound( "arc_cannon_fire_SmallShot_Amped" )
		weaponScriptScope.PlayWeaponSoundWithVolume( "arc_cannon_fire_BigShot_Amped", newVolume )
	}
	else
	{
		weapon.EmitWeaponSound( "arc_cannon_fire_SmallShot" )
		weaponScriptScope.PlayWeaponSoundWithVolume( "arc_cannon_Fire_BigShot", newVolume )
	}

	weapon.StopWeaponSound( "arc_cannon_charged_loop" )

	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )

	weapon.PlayWeaponEffect( "wpn_muzzleflash_arc_cannon_fp", "wpn_muzzleflash_arc_cannon", "muzzle_flash" )

	StopChargeEffects( weapon )

	local attachmentName = "muzzle_flash"
	local attachmentIndex = weapon.LookupAttachment( attachmentName )
	Assert( attachmentIndex >= 0 )
	local muzzleOrigin = weapon.GetAttachmentOrigin( attachmentIndex )

	//printt( "-------- FIRING ARC CANNON --------" )

	local firstTargetInfo = GetFirstArcCannonTarget( weapon, attackParams )
	if ( !IsValid( firstTargetInfo.target ) )
		FireArcNoTargets( weapon, attackParams, muzzleOrigin )
	else
		FireArcWithTargets( weapon, firstTargetInfo, attackParams, muzzleOrigin )

	return 1
}

function GetFirstArcCannonTarget( weapon, attackParams )
{
	local owner 				= weapon.GetWeaponOwner()
	local coneHeight 			= weapon.GetMaxDamageFarDist()

	local angleToAxis 			= 8  // set this too high and auto-titans using it will error on GetVisibleEntitiesInCone
	local ignoredEntities 		= [ owner, weapon ]
	local traceMask 			= TRACE_MASK_SHOT
	local flags					= VIS_CONE_ENTS_TEST_HITBOXES  // | VIS_CONE_ENTS_IGNORE_VORTEX
	local antilagPlayer			= null
	if ( owner.IsPlayer() )
	{
		angleToAxis = owner.GetAttackSpreadAngle() * 0.095
		antilagPlayer = owner
	}

	local results
	local ownerTeam = owner.GetTeam()

	// Get a missile target and a non-missile target in the cone that the player can zap
	// We do this in a separate check so we can use a wider cone to be more forgiving for targeting missiles
	local firstTargetInfo = {}
	firstTargetInfo.target <- null
	firstTargetInfo.hitLocation <- null
	for ( local i = 0 ; i < 2 ; i++ )
	{
		local missileCheck = i == 0
		local coneAngle = angleToAxis
		if ( missileCheck )
			coneAngle *= 3.0

		results = GetVisibleEntitiesInCone( attackParams.pos, attackParams.dir, coneHeight, coneAngle, ignoredEntities, traceMask, flags, antilagPlayer, false, false )
		foreach( result in results )
		{
			local visibleEnt = result.entity

			if ( !IsValid( visibleEnt ) )
				continue

			local classname = IsServer() ? visibleEnt.GetClassname() : visibleEnt.GetSignifierName()

			if ( !( classname in level.arcCannonTargetClassnames ) )
				continue

			if ( "GetTeam" in visibleEnt )
			{
				local visibleEntTeam = visibleEnt.GetTeam()
				if ( visibleEntTeam == ownerTeam )
					continue
				if ( IsEntANeutralMegaTurret( visibleEnt, ownerTeam ) )
					continue
			}

			if ( missileCheck && classname != "rpg_missile" )
				continue

			if ( !missileCheck && classname == "rpg_missile" )
				continue

			firstTargetInfo.target = visibleEnt
			firstTargetInfo.hitLocation = result.visiblePosition
			break
		}
	}
	//Creating a whiz-by sound.
	weapon.FireWeaponBullet_Special( attackParams.pos, attackParams.dir, 1, 0, true, true, true, true )

	return firstTargetInfo
}

function FireArcNoTargets( weapon, attackParams, muzzleOrigin )
{
	Assert( IsValid( weapon ) )
	local player = weapon.GetWeaponOwner()
	local chargeFrac = weapon.GetWeaponChargeFraction()
	local beamVec = attackParams.dir * weapon.GetMaxDamageFarDist()
	local playerEyePos = player.EyePosition()
	local traceResults = TraceLineHighDetail( playerEyePos, (playerEyePos + beamVec), weapon, (TRACE_MASK_PLAYERSOLID_BRUSHONLY | TRACE_MASK_BLOCKLOS), TRACE_COLLISION_GROUP_NONE )
	local beamEnd = traceResults.endPos

	local vortexHit = VortexBulletHitCheck( player, playerEyePos, beamEnd )
	if ( vortexHit )
	{
		if( IsServer() )
		{
			local vortexWeapon = vortexHit.vortex.GetOwnerWeapon()
			if( vortexWeapon && vortexWeapon.GetClassname() == "mp_titanweapon_vortex_shield" )
				VortexDrainedByImpact( vortexWeapon, weapon, null, null )
		}
		beamEnd = vortexHit.hitPos
	}

	local radius = Graph( chargeFrac, 0, 1, ARC_CANNON_BOLT_RADIUS_MIN, ARC_CANNON_BOLT_RADIUS_MAX )
	local boltWidth = Graph( chargeFrac, 0, 1, ARC_CANNON_BOLT_WIDTH_MIN, ARC_CANNON_BOLT_WIDTH_MAX )
	if ( player.IsNPC() )
		boltWidth = ARC_CANNON_BOLT_WIDTH_NPC
	thread CreateArcCannonBeam( weapon, null, muzzleOrigin, beamEnd, player, ARC_CANNON_BEAM_LIFETIME, radius, boltWidth, 2, false, true )
	if( IsServer() )
		CreateExplosion( beamEnd, 0, 0, 1, 1, player, 0, null, -1, false, ARC_CANNON_FX_TABLE )
}

function FireArcWithTargets( weapon, firstTargetInfo, attackParams, muzzleOrigin )
{
	local beamStart = muzzleOrigin
	local beamEnd
	local player = weapon.GetWeaponOwner()
	local chargeFrac = weapon.GetWeaponChargeFraction()
	local radius = Graph( chargeFrac, 0, 1, ARC_CANNON_BOLT_RADIUS_MIN, ARC_CANNON_BOLT_RADIUS_MAX )
	local boltWidth = Graph( chargeFrac, 0, 1, ARC_CANNON_BOLT_WIDTH_MIN, ARC_CANNON_BOLT_WIDTH_MAX )
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

	local zapInfo = {}
	zapInfo.weapon 			<- weapon
	zapInfo.player 			<- player
	zapInfo.muzzleOrigin	<- muzzleOrigin
	zapInfo.radius			<- radius
	zapInfo.boltWidth		<- boltWidth
	zapInfo.maxChains		<- maxChains
	zapInfo.chargeFrac		<- chargeFrac
	zapInfo.zappedTargets 	<- {}
	zapInfo.zappedTargets[ firstTargetInfo.target ] <- true
	local chainNum = 1
	thread ZapTargetRecursive( firstTargetInfo.target, zapInfo, zapInfo.muzzleOrigin, firstTargetInfo.hitLocation, chainNum )
}

function ZapTargetRecursive( target, zapInfo, beamStartPos, firstTargetBeamEndPos = null, chainNum = 1 )
{
	if ( !IsValid( target ) )
		return

	if ( !IsValid( zapInfo.weapon ) )
		return

	Assert( target in zapInfo.zappedTargets )
	if ( chainNum > zapInfo.maxChains )
		return
	local beamEndPos
	if ( firstTargetBeamEndPos == null )
		beamEndPos = target.GetWorldSpaceCenter()
	else
		beamEndPos = firstTargetBeamEndPos

	waitthread ZapTarget( zapInfo, target, beamStartPos, beamEndPos, chainNum )

	// Get other nearby targets we can chain to
	if ( IsServer() )
	{
	    if ( !IsValid( target ) )
		    return

	    if ( !IsValid( zapInfo.weapon ) )
		    return

		local chainTargets = GetArcCannonChainTargets( beamEndPos, target, zapInfo )
		foreach( chainTarget in chainTargets )
		{
			local newChainNum = chainNum
			if( !chainTarget.GetClassname() != "rpg_missile" )
				newChainNum++
			zapInfo.zappedTargets[ chainTarget ] <- true
			thread ZapTargetRecursive( chainTarget, zapInfo, beamEndPos, null, newChainNum )
		}

		if ( IsValid( zapInfo.player ) && zapInfo.player.IsPlayer() && zapInfo.zappedTargets.len() >= 5 )
		{
			if ( PlayerProgressionAllowed( zapInfo.player ) )
				zapInfo.player.SetPersistentVar( "ach_multikillArcRifle", true )
			if ( chainNum == 5 )
				UpdatePlayerStat( zapInfo.player, "misc_stats", "arcCannonMultiKills", 1 )
		}
	}
}

function ZapTarget( zapInfo, target, beamStartPos, beamEndPos, chainNum = 1 )
{
	//DebugDrawLine( beamStartPos, beamEndPos, 255, 0, 0, true, 5.0 )
	local boltWidth = zapInfo.boltWidth
	if ( zapInfo.player.IsNPC() )
		boltWidth = ARC_CANNON_BOLT_WIDTH_NPC
	local firstBeam = ( chainNum == 1 )
	if( firstBeam && IsServer() )
		CreateExplosion( beamEndPos, 0, 0, 1, 1, zapInfo.player, 0, null, -1, false, ARC_CANNON_FX_TABLE )
	thread CreateArcCannonBeam( zapInfo.weapon, target, beamStartPos, beamEndPos, zapInfo.player, ARC_CANNON_BEAM_LIFETIME, zapInfo.radius, boltWidth, 5, true, firstBeam )

	if ( IsClient() )
		return

	local isMissile = ( target.GetClassname() == "rpg_missile" )
	if( !isMissile )
		wait ARC_CANNON_FORK_DELAY
	else
		wait 0.05

	local deathPackage = damageTypes.ArcCannon

	local damageAmount
	local damageMin
	local damageMax

	if ( IsValid( target ) && IsValid( zapInfo.player ) )
	{
		if ( target.GetArmorType() == ARMOR_TYPE_HEAVY )
		{
			if ( IsValid( zapInfo.weapon ) )
			{
				damageMin = zapInfo.weapon.GetWeaponModSetting( "damage_far_value_titanarmor" )
				damageMax = zapInfo.weapon.GetWeaponModSetting( "damage_near_value_titanarmor" )
			}
			else
			{
				damageMin = GetWeaponInfoFileKeyField_Global( "mp_titanweapon_arc_cannon", "damage_far_value_titanarmor" )
				damageMax = GetWeaponInfoFileKeyField_Global( "mp_titanweapon_arc_cannon", "damage_near_value_titanarmor" )
			}

			// Due to auto-titans not charging, they do very little damage with this weapon against one another.
			if ( zapInfo.player.IsNPC() )
			{
				damageMin *= 7.0
				damageMax *= 7.0
			}

			// HACK; temp fix for non titan heavy armor targets (e.g. mega turret)
		}
		else
		{
			if ( IsValid( zapInfo.weapon ) )
			{
				damageMin = zapInfo.weapon.GetWeaponModSetting( "damage_far_value" )
				damageMax = zapInfo.weapon.GetWeaponModSetting( "damage_near_value" )
			}
			else
			{
				damageMin = GetWeaponInfoFileKeyField_Global( "mp_titanweapon_arc_cannon", "damage_far_value" )
				damageMax = GetWeaponInfoFileKeyField_Global( "mp_titanweapon_arc_cannon", "damage_near_value" )
			}

			if ( target.IsNPC() )
			{
				damageMin *= 3.0	// more powerful against NPC humans so they die easy
				damageMax *= 3.0
			}
		}


		// Scale damage amount based on how many chains deep we are
		local chargeRatio = GetArcCannonChargeFraction( zapInfo.weapon )
		damageAmount = GraphCapped( zapInfo.chargeFrac, 0, chargeRatio, damageMin, damageMax )
		local damageFalloff = ARC_CANNON_DAMAGE_FALLOFF_SCALER
		if( IsValid( zapInfo.weapon ) && zapInfo.weapon.HasMod( "splitter" ) )
			damageFalloff = SPLITTER_DAMAGE_FALLOFF_SCALER
		damageAmount *= pow( damageFalloff, chainNum - 1 )

		local dmgSourceID = eDamageSourceId.mp_titanweapon_arc_cannon

		// Update Later - This shouldn't be done here, this is not where we determine if damage actually happened to the target
		// move to Damaged callback instead
		if( damageAmount > 0 )
		{
			local empDuration = GraphCapped( zapInfo.chargeFrac, 0, chargeRatio, ARC_CANNON_EMP_DURATION_MIN, ARC_CANNON_EMP_DURATION_MAX )

			if ( target.IsPlayer() )
			{
				local empViewStrength = GraphCapped( zapInfo.chargeFrac, 0, chargeRatio, ARC_CANNON_SCREEN_EFFECTS_MIN, ARC_CANNON_SCREEN_EFFECTS_MAX )

				if ( target.IsTitan() && zapInfo.chargeFrac >= ARC_CANNON_SCREEN_THRESHOLD )
				{
					Remote.CallFunction_Replay( target, "ServerCallback_TitanEMP", empViewStrength, empDuration, ARC_CANNON_EMP_FADEOUT_DURATION )
					EmitSoundOnEntityOnlyToPlayer( target, target, ARC_CANNON_TITAN_SCREEN_SFX )

					local scale = GraphCapped( zapInfo.chargeFrac, 0, chargeRatio, ARC_CANNON_SLOW_SCALE_MIN, ARC_CANNON_SLOW_SCALE_MAX )
					thread EMP_SlowPlayer( target, scale, empDuration )
				}
				else if ( zapInfo.chargeFrac >= ARC_CANNON_SCREEN_THRESHOLD )
				{
					Remote.CallFunction_Replay( target, "ServerCallback_PilotEMP", empViewStrength, empDuration, ARC_CANNON_EMP_FADEOUT_DURATION )
					EmitSoundOnEntityOnlyToPlayer( target, target, ARC_CANNON_PILOT_SCREEN_SFX )
				}
			}

			// Do 3rd person effect on the body
			local effect = null
			local tag = null
			target.TakeDamage( damageAmount, zapInfo.player, zapInfo.player, { origin = zapInfo.player.GetOrigin(), force = Vector(0,0,0), scriptType = deathPackage, weapon = zapInfo.weapon, damageSourceId = dmgSourceID } )

			if ( zapInfo.chargeFrac < ARC_CANNON_SCREEN_THRESHOLD )
				empDuration = ARC_CANNON_3RD_PERSON_EFFECT_MIN_DURATION
			else
				empDuration += ARC_CANNON_EMP_FADEOUT_DURATION

			if ( target.GetArmorType() == ARMOR_TYPE_HEAVY )
			{
				effect = "impact_arc_cannon_titan"
				tag = "exp_torso_front"
			}
			else
			{
				effect = "P_emp_body_human"
				tag = "CHESTFOCUS"
			}

			if ( target.IsPlayer() && effect != null && tag != null )
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
			if ( IsValid ( zapInfo.player ) )
				target.SetOwner( zapInfo.player )
			target.Explode()
		}
	}
}


function FadeOutSoundOnEntityAfterDelay( entity, soundAlias, delay, fadeTime )
{

	if ( !IsValid( entity ) )
		return

	entity.EndSignal( "OnDestroy" )
	wait delay
	FadeOutSoundOnEntity( entity, soundAlias, fadeTime )
}


function GetArcCannonChainTargets( fromOrigin, fromTarget, zapInfo )
{
	Assert( IsServer() )

	local results = []
	if ( !IsValid( zapInfo.player ) )
		return results

	local playerTeam = zapInfo.player.GetTeam()
	local allTargets = GetArcCannonTargetsInRange( fromOrigin, playerTeam, zapInfo.weapon )
	allTargets = ArrayClosest( allTargets, fromOrigin )

	local viewVector
	if ( zapInfo.player.IsPlayer() )
		viewVector = zapInfo.player.GetViewVector()
	else
		viewVector = zapInfo.player.EyeAngles().AnglesToForward()

	local eyePosition = zapInfo.player.EyePosition()

	foreach( ent in allTargets )
	{
		local forkCount = ARC_CANNON_FORK_COUNT_MAX
		if ( zapInfo.weapon.HasMod( "splitter" ) )
			forkCount = SPLITTER_FORK_COUNT_MAX
		else if ( zapInfo.weapon.HasMod( "burn_mod_titan_arc_cannon" ) )
			forkCount = ARC_CANNON_FORK_COUNT_MAX_BURN

		if ( results.len() >= forkCount )
			break

		if ( ent.IsPlayer() )
		{
			if ( ent.GetPlayerClass() == "operator" )
				continue

			if ( ent.GetPlayerClass() == "dronecontroller" )
				continue

			// Ignore players that are passing damage to their parent. This is to address zapping a friendly rodeo player
			local entParent = ent.GetParent()
			if ( IsValid( entParent ) && ent.kv.PassDamageToParent.tointeger() )
				continue
		}

		if ( ent.GetClassname() == "script_mover" )
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
		local dotVal = vecToEnt.Dot( viewVector )
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

		local traceResult = TraceLineHighDetail( fromOrigin, ent.GetWorldSpaceCenter(), ignoreEnts, (TRACE_MASK_PLAYERSOLID_BRUSHONLY | TRACE_MASK_BLOCKLOS), TRACE_COLLISION_GROUP_NONE )

		// Trace failed, lets try an eye to eye trace
		if ( traceResult.fraction < 1 && IsValid( fromTarget ) )
			traceResult = TraceLineHighDetail( fromTarget.EyePosition(), ent.EyePosition(), ignoreEnts, (TRACE_MASK_PLAYERSOLID_BRUSHONLY | TRACE_MASK_BLOCKLOS), TRACE_COLLISION_GROUP_NONE )

		if ( traceResult.fraction < 1 )
			continue

		// Enemy is in visible, and within range.
		if ( !IsValueInArray( results, ent ) )
			results.append( ent )
	}

	//printt( "NEARBY TARGETS VALID AND VISIBLE:", results.len() )

	return results
}
Globalize( GetArcCannonChainTargets )


function IsEntANeutralMegaTurret( ent, playerTeam )
{
	if ( ent.GetClassname() != "npc_turret_mega" )
		return false
	local entTeam = ent.GetTeam()
	if ( entTeam == playerTeam )
		return false
	if ( entTeam != GetOtherTeam( playerTeam ) )
		return true

	return false
}
Globalize( IsEntANeutralMegaTurret )

function ArcCannon_HideIdleEffect( weapon, delay )
{
	//printt( "HideIdleEffect" )
	weapon.EndSignal( ARC_CANNON_SIGNAL_DEACTIVATED )
	weapon.StopWeaponEffect( "wpn_arc_cannon_electricity_fp", "wpn_arc_cannon_electricity" )
	wait delay

	if( !IsValid( weapon ) )
		return

	local weaponOwner = weapon.GetWeaponOwner()
	//The weapon can be valid, but the player isn't a Titan during melee execute.
	// JFS: threads with waits should just end on "OnDestroy"
	if ( !IsValid(weaponOwner) )
		return

	if (  !weapon.GetWeaponOwner().IsTitan() || weapon != weaponOwner.GetActiveWeapon() )
		return

	weapon.PlayWeaponEffectNoCull( "wpn_arc_cannon_electricity_fp", "wpn_arc_cannon_electricity", "muzzle_flash" )
	weapon.EmitWeaponSound( "arc_cannon_charged_loop" )
}

function AddToArcCannonTargets( ent )
{
	AddToScriptManagedEntArray( level._arcCannonTargetsArrayID, ent );
}

function GetArcCannonTargets( origin, team )
{
	local targets = GetScriptManagedEntArrayWithinCenter( level._arcCannonTargetsArrayID, team, origin, ARC_CANNON_TITAN_RANGE_CHAIN )

	if ( ARC_CANNON_TARGETS_MISSILES )
	{
		local enemyTeam = GetEnemyTeam( team )
		targets.extend( GetProjectileArrayEx( "rpg_missile", enemyTeam, origin, ARC_CANNON_TITAN_RANGE_CHAIN ) )
	}

	return targets
}
Globalize( GetArcCannonTargets )

function GetArcCannonTargetsInRange( origin, team, weapon )
{
	local allTargets = GetArcCannonTargets( origin, team )
	local targetsInRange = []

	local titanDistSq
	local distSq
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
		local d = DistanceSqr( target.GetOrigin(), origin )
		local validDist = target.IsTitan() ? titanDistSq : distSq
		if ( d <= validDist )
			targetsInRange.append( target )
	}

	return targetsInRange
}

function SortArcCannonTargets( weapon, targets )
{
	Assert( targets.len() > 0 )
	local originalTargetCount = targets.len()
	//printt( "    sorting", originalTargetCount, "targets" )

	local sortedTargets = []
	local lastEnt = weapon.GetWeaponOwner()
	local closestIndex = null
	local closestEnt = null

	while( targets.len() > 0 )
	{
		closestEnt = null
		closestIndex = null

		closestIndex = GetClosestIndex( targets, lastEnt.GetOrigin() )
		Assert( closestIndex != null )
		closestEnt = targets[ closestIndex ]
		Assert( closestEnt != null )

		sortedTargets.append( closestEnt )
		targets.remove( closestIndex )

		lastEnt = closestEnt
	}

	Assert( sortedTargets.len() == originalTargetCount )
	return sortedTargets
}

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
	if ( IsClient() && firstBeam )
		thread CreateClientArcBeam( weapon, endPos, lifeDuration, target )

	if ( IsClient() )
		return

	// Control point sets the end position of the effect
	local cpEnd = CreateEntity( "info_placement_helper" )
	cpEnd.SetName( UniqueString( "arc_cannon_beam_cpEnd" ) )
	cpEnd.SetOrigin( endPos )
	DispatchSpawn( cpEnd, false )

	local zapBeam = CreateEntity( "info_particle_system" )
	zapBeam.kv.cpoint1 = cpEnd.GetName()

	zapBeam.kv.effect_name = GetBeamEffect( weapon )

	zapBeam.kv.start_active = 0
	zapBeam.SetOwner( player )
	zapBeam.SetOrigin( startPos )
	if ( firstBeam )
	{
		zapBeam.kv.VisibilityFlags = 6	// everyone but owner
		zapBeam.SetParent( player.GetActiveWeapon(), "muzzle_flash", false, 0.0 )
	}
	DispatchSpawn( zapBeam )

	zapBeam.Fire( "Start" )
	zapBeam.Fire( "StopPlayEndCap", "", lifeDuration )
	zapBeam.Kill( lifeDuration )
	cpEnd.Kill( lifeDuration )
}

function GetBeamEffect( weapon )
{
	if ( weapon.HasMod( "burn_mod_titan_arc_cannon" ) )
		return ARC_CANNON_BEAM_EFFECT_MOD

	return ARC_CANNON_BEAM_EFFECT
}

function CreateClientArcBeam( weapon, endPos, lifeDuration, target )
{
	Assert( IsClient() )

	local beamEffect = GetBeamEffect( weapon )

	weapon.PlayWeaponEffect( beamEffect, null, "muzzle_flash" )
	local handle = weapon.AllocateHandleForViewmodelEffect( beamEffect )
	if ( !EffectDoesExist( handle ) )
		return

	EffectSetControlPointVector( handle, 1, endPos )

	if ( weapon.HasMod( "burn_mod_titan_arc_cannon" ) )
		lifeDuration = ARC_CANNON_BEAM_LIFETIME_BURN

	wait( lifeDuration )

	if ( IsValid( weapon ) )
		weapon.StopWeaponEffect( beamEffect, null )
}

function ClientDestroyCallback_ArcCannon_Stop( entity )
{
	ArcCannon_Stop( entity )
}

function GetArcCannonChargeFraction( weapon )
{
	if ( IsValid( weapon ) )
	{
		local chargeRatio = ARC_CANNON_DAMAGE_CHARGE_RATIO
		if( weapon.HasModDefined( "capacitor" ) && weapon.HasMod( "capacitor" ) )
			chargeRatio = ARC_CANNON_CAPACITOR_CHARGE_RATIO
		if( weapon.GetWeaponModSetting( "is_burn_mod" ) )
			chargeRatio = ARC_CANNON_DAMAGE_CHARGE_RATIO_BURN
		return chargeRatio
	}

	return 0
}