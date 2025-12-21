global function LaserCannon_Init

global function OnAbilityStart_LaserCannon
global function OnAbilityEnd_LaserCannon
global function OnAbilityCharge_LaserCannon
global function OnAbilityChargeEnd_LaserCannon

#if SERVER
global function LaserCore_OnPlayedOrNPCKilled
#endif

const SEVERITY_SLOWTURN_LASERCORE = 0.25
const SEVERITY_SLOWMOVE_LASERCORE = 0.25

const FX_LASERCANNON_AIM = $"P_wpn_lasercannon_aim"
const FX_LASERCANNON_CORE = $"P_lasercannon_core"
const FX_LASERCANNON_MUZZLEFLASH = $"P_handlaser_charge"

const LASER_MODEL = $"models/weapons/empty_handed/w_laser_cannon.mdl"

#if SP
const LASER_FIRE_SOUND_1P = "Titan_Core_Laser_FireBeam_1P_extended"
#else
const LASER_FIRE_SOUND_1P = "Titan_Core_Laser_FireBeam_1P"
#endif

void function LaserCannon_Init()
{
	PrecacheParticleSystem( FX_LASERCANNON_AIM )
	PrecacheParticleSystem( FX_LASERCANNON_CORE )
	PrecacheParticleSystem( FX_LASERCANNON_MUZZLEFLASH )

	PrecacheModel( LASER_MODEL )

	#if SERVER
		AddDamageCallbackSourceID( eDamageSourceId.mp_titancore_laser_cannon, Laser_DamagedTarget )
		AddCallback_OnPlayerKilled( LaserCore_OnPlayedOrNPCKilled )//Move to FD game mode script
		AddCallback_OnNPCKilled( LaserCore_OnPlayedOrNPCKilled )//Move to FD game mode script
	#endif
}

#if SERVER
void function LaserCore_OnPlayedOrNPCKilled( entity victim, entity attacker, var damageInfo )
{
	if ( !attacker.IsPlayer() || !attacker.IsTitan() )//|| !PlayerHasPassive( attacker, ePassives.PAS_SHIFT_CORE ) )
		return

	int damageSource = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	if ( damageSource != eDamageSourceId.mp_titancore_laser_cannon )
		return

	entity soul = attacker.GetTitanSoul()
	if ( !IsValid( soul ) )
		return

	entity weapon = attacker.GetOffhandWeapon( OFFHAND_EQUIPMENT )
	if ( !weapon.HasMod( "fd_laser_cannon" ) )
		return

	float curTime = Time()
	float laserCoreBonus
	if ( victim.IsTitan() )
		laserCoreBonus = 2.5
	else if ( IsSuperSpectre( victim ) )
		laserCoreBonus = 1.5
	else
		laserCoreBonus = 0.5

	float remainingTime = laserCoreBonus + soul.GetCoreChargeExpireTime() - curTime
	float duration
	if ( weapon.HasMod( "pas_ion_lasercannon") )
		duration = 5.0
	else
		duration = 3.0
	float coreFrac = min( 1.0, remainingTime / duration )
	//Defensive fix for this sometimes resulting in a negative value.
	if ( coreFrac > 0.0 )
	{
		soul.SetTitanSoulNetFloat( "coreExpireFrac", coreFrac )
		soul.SetTitanSoulNetFloatOverTime( "coreExpireFrac", 0.0, remainingTime )
		soul.SetCoreChargeExpireTime( remainingTime + curTime )
		weapon.SetSustainedDischargeFractionForced( coreFrac )
	}
}
#endif

bool function OnAbilityCharge_LaserCannon( entity weapon )
{
	OnAbilityCharge_TitanCore( weapon )

#if CLIENT
	if ( !InPrediction() || IsFirstTimePredicted() )
	{
		weapon.PlayWeaponEffectNoCull( FX_LASERCANNON_AIM, FX_LASERCANNON_AIM, "muzzle_flash" )
		weapon.PlayWeaponEffectNoCull( FX_LASERCANNON_AIM, FX_LASERCANNON_AIM, "laser_canon_1" )
		weapon.PlayWeaponEffectNoCull( FX_LASERCANNON_AIM, FX_LASERCANNON_AIM, "laser_canon_2" )
		weapon.PlayWeaponEffectNoCull( FX_LASERCANNON_AIM, FX_LASERCANNON_AIM, "laser_canon_3" )
		weapon.PlayWeaponEffectNoCull( FX_LASERCANNON_AIM, FX_LASERCANNON_AIM, "laser_canon_4" )
		weapon.PlayWeaponEffect( FX_LASERCANNON_MUZZLEFLASH, FX_LASERCANNON_MUZZLEFLASH, "muzzle_flash" )
	}
#endif // #if CLIENT

#if SERVER
	entity player = weapon.GetWeaponOwner()
	float chargeTime = weapon.GetWeaponSettingFloat( eWeaponVar.charge_time )
	entity soul = player.GetTitanSoul()
	if ( soul == null )
		soul = player

	StatusEffect_AddTimed( soul, eStatusEffect.move_slow, SEVERITY_SLOWMOVE_LASERCORE, chargeTime, 0 )

	weapon.w.laserWorldModel = CreatePropDynamic( LASER_MODEL )

	int index = player.LookupAttachment( "PROPGUN" )
	vector origin = player.GetAttachmentOrigin( index )
	vector angles = player.GetAttachmentAngles( index )

	if ( player.IsPlayer() )
		player.Server_TurnOffhandWeaponsDisabledOn()

	weapon.w.laserWorldModel.SetOrigin( origin )
	weapon.w.laserWorldModel.SetAngles( angles - Vector(90,0,0)  )

	weapon.w.laserWorldModel.SetParent( player, "PROPGUN", true, 0.0 )
	PlayFXOnEntity( FX_LASERCANNON_AIM, weapon.w.laserWorldModel, "muzzle_flash", null, null, 6, player )
	PlayFXOnEntity( FX_LASERCANNON_AIM, weapon.w.laserWorldModel, "laser_canon_1", null, null, 6, player )
	PlayFXOnEntity( FX_LASERCANNON_AIM, weapon.w.laserWorldModel, "laser_canon_2", null, null, 6, player )
	PlayFXOnEntity( FX_LASERCANNON_AIM, weapon.w.laserWorldModel, "laser_canon_3", null, null, 6, player )
	PlayFXOnEntity( FX_LASERCANNON_AIM, weapon.w.laserWorldModel, "laser_canon_4", null, null, 6, player )

	weapon.w.laserWorldModel.Anim_Play( "charge_seq" )

	if ( player.IsNPC() )
	{
		player.SetVelocity( <0,0,0> )
		player.Anim_ScriptedPlayActivityByName( "ACT_SPECIAL_ATTACK_START", true, 0.0 )
	}
#endif // #if SERVER

	weapon.EmitWeaponSound_1p3p( "Titan_Core_Laser_ChargeUp_1P", "Titan_Core_Laser_ChargeUp_3P" )

	return true
}

void function OnAbilityChargeEnd_LaserCannon( entity weapon )
{
	#if SERVER
	OnAbilityChargeEnd_TitanCore( weapon )
	#endif

	#if CLIENT
	if ( IsFirstTimePredicted() )
	{
		weapon.StopWeaponEffect( FX_LASERCANNON_AIM, FX_LASERCANNON_AIM )
	}
	#endif

	#if SERVER
	if ( IsValid( weapon.w.laserWorldModel ) )
		weapon.w.laserWorldModel.Destroy()

	entity player = weapon.GetWeaponOwner()

	if ( player == null )
		return

	if ( player.IsPlayer() )
		player.Server_TurnOffhandWeaponsDisabledOff()

	if ( player.IsNPC() && IsAlive( player ) )
	{
		player.Anim_Stop()
	}
	#endif
}

bool function OnAbilityStart_LaserCannon( entity weapon )
{
	OnAbilityStart_TitanCore( weapon )

#if SERVER
	weapon.e.onlyDamageEntitiesOncePerTick = true

	entity player = weapon.GetWeaponOwner()
	float stunDuration = weapon.GetSustainedDischargeDuration()
	float fadetime = 2.0
	entity soul = player.GetTitanSoul()
	if ( soul == null )
		soul = player

	if ( !player.ContextAction_IsMeleeExecution() ) //don't do this during executions
	{
		StatusEffect_AddTimed( soul, eStatusEffect.turn_slow, SEVERITY_SLOWTURN_LASERCORE, stunDuration + fadetime, fadetime )
		StatusEffect_AddTimed( soul, eStatusEffect.move_slow, SEVERITY_SLOWMOVE_LASERCORE, stunDuration + fadetime, fadetime )
	}

	if ( player.IsPlayer() )
	{
		player.Server_TurnDodgeDisabledOn()
		player.Server_TurnOffhandWeaponsDisabledOn()
		EmitSoundOnEntityOnlyToPlayer( player, player, "Titan_Core_Laser_FireStart_1P" )
		EmitSoundOnEntityOnlyToPlayer( player, player, LASER_FIRE_SOUND_1P )
		EmitSoundOnEntityExceptToPlayer( player, player, "Titan_Core_Laser_FireStart_3P" )
		EmitSoundOnEntityExceptToPlayer( player, player, "Titan_Core_Laser_FireBeam_3P" )
	}
	else
	{
		EmitSoundOnEntity( player, "Titan_Core_Laser_FireStart_3P" )
		EmitSoundOnEntity( player, "Titan_Core_Laser_FireBeam_3P" )
	}

	if ( player.IsNPC() )
	{
		player.SetVelocity( <0,0,0> )
		player.Anim_ScriptedPlayActivityByName( "ACT_SPECIAL_ATTACK", true, 0.1 )
	}

	// thread LaserEndingWarningSound( weapon, player )

	SetCoreEffect( player, CreateCoreEffect, FX_LASERCANNON_CORE )
#endif

	#if CLIENT
	thread PROTO_SustainedDischargeShake( weapon )
	#endif

	return true
}

void function OnAbilityEnd_LaserCannon( entity weapon )
{
	weapon.Signal( "OnSustainedDischargeEnd" )
	weapon.StopWeaponEffect( FX_LASERCANNON_MUZZLEFLASH, FX_LASERCANNON_MUZZLEFLASH )

	#if SERVER
	OnAbilityEnd_TitanCore( weapon )

	entity player = weapon.GetWeaponOwner()

	if ( player == null )
		return

	if ( player.IsPlayer() )
	{
		player.Server_TurnDodgeDisabledOff()
		player.Server_TurnOffhandWeaponsDisabledOff()

		EmitSoundOnEntityOnlyToPlayer( player, player, "Titan_Core_Laser_FireStop_1P" )
		EmitSoundOnEntityExceptToPlayer( player, player, "Titan_Core_Laser_FireStop_3P" )
	}
	else
	{
		EmitSoundOnEntity( player, "Titan_Core_Laser_FireStop_3P" )
	}

	if ( player.IsNPC() && IsAlive( player ) )
	{
		player.SetVelocity( <0,0,0> )
		player.Anim_ScriptedPlayActivityByName( "ACT_SPECIAL_ATTACK_END", true, 0.0 )
	}

	StopSoundOnEntity( player, "Titan_Core_Laser_FireBeam_3P" )
	StopSoundOnEntity( player, LASER_FIRE_SOUND_1P )
	#endif
}

#if SERVER
void function LaserEndingWarningSound( entity weapon, entity player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnSyncedMelee" )
	player.EndSignal( "CoreEnd" )
	player.EndSignal( "DisembarkingTitan" )
	player.EndSignal( "TitanEjectionStarted" )

	float duration = weapon.GetSustainedDischargeDuration()

//	Assert( duration > 2.0, "Titan_Core_Laser_Fire_EndWarning_1P needs to be played 2.0 seconds before. Ask audio to adjust the sound and change the values in this function" )
//	wait duration - 2.0

//	EmitSoundOnEntityOnlyToPlayer( player, player, "Titan_Core_Laser_Fire_EndWarning_1P")
}

void function Laser_DamagedTarget( entity target, var damageInfo )
{
	if ( IsAlive( target ) )
		Laser_DamagedTargetInternal( target, damageInfo )
}

void function Laser_DamagedTargetInternal( entity target, var damageInfo )
{
	entity weapon = DamageInfo_GetWeapon( damageInfo )
	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( attacker == target )
	{
		DamageInfo_SetDamage( damageInfo, 0 )
		return
	}

	if ( IsValid( weapon ) )
	{
		float damage = min( DamageInfo_GetDamage( damageInfo ), weapon.GetWeaponSettingInt( eWeaponVar.damage_near_value_titanarmor ) )
		DamageInfo_SetDamage( damageInfo, damage )
	}

	if ( target.GetTargetName() == "#NPC_EVAC_DROPSHIP" )
		DamageInfo_ScaleDamage( damageInfo, EVAC_SHIP_DAMAGE_MULTIPLIER_AGAINST_NUCLEAR_CORE )

	#if SP
	if ( target.IsNPC() && ( IsMercTitan( target ) || target.ai.bossTitanType == TITAN_BOSS ) )
	{
		DamageInfo_ScaleDamage( damageInfo, BOSS_TITAN_CORE_DAMAGE_SCALER )
	}
	#endif
}
#endif