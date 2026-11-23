untyped

global function MpTitanWeaponParticleAccelerator_Init

global function OnWeaponPrimaryAttack_titanweapon_particle_accelerator
global function OnWeaponActivate_titanweapon_particle_accelerator
global function OnWeaponCooldown_titanweapon_particle_accelerator
global function OnWeaponStartZoomIn_titanweapon_particle_accelerator
global function OnWeaponStartZoomOut_titanweapon_particle_accelerator

global function PROTO_GetHeatMeterCharge

#if SERVER
	global function OnWeaponNpcPrimaryAttack_titanweapon_particle_accelerator
#endif

const ADS_SHOT_COUNT_NORMAL = 3
const ADS_SHOT_COUNT_UPGRADE = 5
const TPAC_PROJECTILE_SPEED = 8000
const TPAC_PROJECTILE_SPEED_NPC = 5000
const LSTAR_LOW_AMMO_WARNING_FRAC = 0.25
const LSTAR_COOLDOWN_EFFECT_1P = $"wpn_mflash_snp_hmn_smokepuff_side_FP"
const LSTAR_COOLDOWN_EFFECT_3P = $"wpn_mflash_snp_hmn_smokepuff_side"
const LSTAR_BURNOUT_EFFECT_1P = $"xo_spark_med"
const LSTAR_BURNOUT_EFFECT_3P = $"xo_spark_med"

const TPA_ADS_EFFECT_1P = $"P_TPA_electricity_FP"
const TPA_ADS_EFFECT_3P = $"P_TPA_electricity"

const CRITICAL_ENERGY_RESTORE_AMOUNT = 30
const SPLIT_SHOT_CRITICAL_ENERGY_RESTORE_AMOUNT = 8

struct
{
	float[ ADS_SHOT_COUNT_UPGRADE ] boltOffsets = [ 0.0, 0.022, -0.022, 0.044, -0.044 ]
} file

function MpTitanWeaponParticleAccelerator_Init()
{
	PrecacheParticleSystem( LSTAR_COOLDOWN_EFFECT_1P )
	PrecacheParticleSystem( LSTAR_COOLDOWN_EFFECT_3P )
	PrecacheParticleSystem( LSTAR_BURNOUT_EFFECT_1P )
	PrecacheParticleSystem( LSTAR_BURNOUT_EFFECT_3P )
	PrecacheParticleSystem( TPA_ADS_EFFECT_1P )
	PrecacheParticleSystem( TPA_ADS_EFFECT_3P )

	#if SERVER
		AddDamageCallbackSourceID( eDamageSourceId.mp_titanweapon_particle_accelerator, OnHit_TitanWeaponParticleAccelerator )
	#endif
}

void function OnWeaponStartZoomIn_titanweapon_particle_accelerator( entity weapon )
{
	#if SERVER
		weapon.s.lastZoomState <- true
	#endif

	array<string> mods = weapon.GetMods()
	if ( weapon.HasMod( "fd_split_shot_cost" ) )
	{
		if ( weapon.HasMod( "pas_ion_weapon_ads" ) )
			mods.append( "fd_upgraded_proto_particle_accelerator_pas" )
		else
			mods.append( "fd_upgraded_proto_particle_accelerator" )
	}
	else
	{
		if ( weapon.HasMod( "pas_ion_weapon_ads" ) )
			mods.append( "proto_particle_accelerator_pas" )
		else
			mods.append( "proto_particle_accelerator" )
	}

	weapon.SetMods( mods )

	#if CLIENT
		entity weaponOwner = weapon.GetWeaponOwner()
		if ( weaponOwner == GetLocalViewPlayer() )
			EmitSoundOnEntity( weaponOwner, "Weapon_Particle_Accelerator_WindUp_1P" )
	#endif
	weapon.PlayWeaponEffectNoCull( TPA_ADS_EFFECT_1P, TPA_ADS_EFFECT_3P, "muzzle_flash" )
	// weapon.PlayWeaponEffectNoCull( $"wpn_arc_cannon_charge_fp", $"wpn_arc_cannon_charge", "muzzle_flash" )
	weapon.EmitWeaponSound( "arc_cannon_charged_loop" )
}

void function OnWeaponStartZoomOut_titanweapon_particle_accelerator( entity weapon )
{
	#if SERVER
		weapon.s.lastZoomState <- false
	#endif

	array<string> mods = weapon.GetMods()
	mods.fastremovebyvalue( "proto_particle_accelerator" )
	mods.fastremovebyvalue( "proto_particle_accelerator_pas" )
	weapon.SetMods( mods )
	// weapon.StopWeaponEffect( $"wpn_arc_cannon_charge_fp", $"wpn_arc_cannon_charge" )
	weapon.StopWeaponEffect( TPA_ADS_EFFECT_1P, TPA_ADS_EFFECT_3P )
	weapon.StopWeaponSound( "arc_cannon_charged_loop" )
}

void function OnWeaponActivate_titanweapon_particle_accelerator( entity weapon )
{
	if ( !( "initialized" in weapon.s ) )
	{
		weapon.s.initialized <- true
	}

	#if SERVER
		if ( !( "lastZoomState" in weapon.s ) )
			weapon.s.lastZoomState <- false

		if ( weapon.IsWeaponInAds() != weapon.s.lastZoomState )
		{
			if ( weapon.IsWeaponInAds() )
				OnWeaponStartZoomIn_titanweapon_particle_accelerator( weapon )
			else
				OnWeaponStartZoomOut_titanweapon_particle_accelerator( weapon )
		}
	#endif

	#if SERVER
		entity owner = weapon.GetWeaponOwner()
		owner.SetSharedEnergyRegenDelay( 0.5 )
	#endif
}

function OnWeaponPrimaryAttack_titanweapon_particle_accelerator( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	entity owner = weapon.GetWeaponOwner()
	float zoomFrac = owner.GetZoomFrac()
	if ( zoomFrac < 1 && zoomFrac > 0 )
		return 0

	weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
	return FireWeaponPlayerAndNPC( weapon, attackParams, true )
}

#if SERVER
	var function OnWeaponNpcPrimaryAttack_titanweapon_particle_accelerator( entity weapon, WeaponPrimaryAttackParams attackParams )
	{
		weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
		return FireWeaponPlayerAndNPC( weapon, attackParams, false )
	}
#endif // #if SERVER

function FireWeaponPlayerAndNPC( entity weapon, WeaponPrimaryAttackParams attackParams, bool playerFired )
{
	bool shouldCreateProjectile = false
	if ( IsServer() || weapon.ShouldPredictProjectiles() )
		shouldCreateProjectile = true

	#if CLIENT
		if ( !playerFired )
			shouldCreateProjectile = false
	#endif

	entity owner = weapon.GetWeaponOwner()
	bool inADS = weapon.IsWeaponInAds()
	int ADS_SHOT_COUNT = weapon.HasMod( "pas_ion_weapon_ads" ) ? ADS_SHOT_COUNT_UPGRADE : ADS_SHOT_COUNT_NORMAL

	if ( shouldCreateProjectile )
	{
		int shotCount = inADS ? ADS_SHOT_COUNT : 1
		weapon.ResetWeaponToDefaultEnergyCost()
		int cost = weapon.GetWeaponCurrentEnergyCost()
		int currentEnergy = owner.GetSharedEnergyCount()
		bool outOfEnergy = ( currentEnergy < cost ) || ( currentEnergy == 0 )
		if ( !inADS || outOfEnergy )
		{
			weapon.SetWeaponEnergyCost( 0 )
			shotCount = 1

			#if CLIENT
				if ( outOfEnergy )
					FlashEnergyNeeded_Bar( cost )
			#endif
			// Single Shots
			weapon.EmitWeaponSound_1p3p( "Weapon_Particle_Accelerator_Fire_1P", "Weapon_Particle_Accelerator_SecondShot_3P" )
		}
		else
		{
			shotCount = ADS_SHOT_COUNT
			// Split Shots
			weapon.EmitWeaponSound_1p3p( "Weapon_Particle_Accelerator_AltFire_1P", "Weapon_Particle_Accelerator_AltFire_SecondShot_3P" )
		}

		vector attackAngles = VectorToAngles( attackParams.dir )
		vector baseRightVec = AnglesToRight( attackAngles )
		for ( int index = 0; index < shotCount; index++ )
		{
			vector attackVec = attackParams.dir + baseRightVec * file.boltOffsets[ index ]
			int damageType = damageTypes.largeCaliber | DF_STOPS_TITAN_REGEN

			float speed = TPAC_PROJECTILE_SPEED
			if ( owner.IsNPC() )
				speed = TPAC_PROJECTILE_SPEED_NPC

			entity bolt = weapon.FireWeaponBolt( attackParams.pos, attackVec, speed, damageType, damageType, playerFired, 0 )
			if ( bolt != null )
			{
				// bolt.kv.gravity = -0.1
				bolt.kv.rendercolor = "0 0 0"
				bolt.kv.renderamt = 0
				bolt.kv.fadedist = 1
			}
		}
	}
	return 1
}

void function OnWeaponCooldown_titanweapon_particle_accelerator( entity weapon )
{
	weapon.PlayWeaponEffect( LSTAR_COOLDOWN_EFFECT_1P, LSTAR_COOLDOWN_EFFECT_3P, "SPINNING_KNOB" ) // "DWAY_ROTATE"
	weapon.EmitWeaponSound_1p3p( "LSTAR_VentCooldown", "LSTAR_VentCooldown" )
}

int function PROTO_GetHeatMeterCharge( entity weapon )
{
	if ( !IsValid( weapon ) )
		return 0

	entity owner = weapon.GetWeaponOwner()
	if ( !IsValid( owner ) )
		return 0

	if ( weapon.IsReloading() )
		return 8

	float max = float( owner.GetWeaponAmmoMaxLoaded( weapon ) )
	float currentAmmo = float( owner.GetWeaponAmmoLoaded( weapon ) )

	float crosshairSegments = 8.0
	return int( GraphCapped( currentAmmo, max, 0.0, 0.0, crosshairSegments ) )
}

#if SERVER
	void function OnHit_TitanWeaponParticleAccelerator( entity victim, var damageInfo )
	{
		entity inflictor = DamageInfo_GetInflictor( damageInfo )
		if ( !IsValid( inflictor ) )
			return
		if ( !inflictor.IsProjectile() )
			return

		entity attacker = DamageInfo_GetAttacker( damageInfo )

		if ( !IsValid( attacker ) || attacker.IsProjectile() ) // Is projectile check is necessary for when the original attacker is no longer valid it becomes the projectile.
			return

		if ( attacker.GetSharedEnergyTotal() <= 0 )
			return

		if ( attacker.GetTeam() == victim.GetTeam() )
			return

		entity soul = attacker.GetTitanSoul()
		if ( !IsValid( soul ) )
			return

		if ( ( IsSingleplayer() || SoulHasPassive( soul, ePassives.PAS_ION_WEAPON ) ) &&
			IsCriticalHit( attacker, victim, DamageInfo_GetHitBox( damageInfo ), DamageInfo_GetDamage( damageInfo ), DamageInfo_GetDamageType( damageInfo ) ) )
		{
			array<string> mods = inflictor.ProjectileGetMods()
			if ( mods.contains( "proto_particle_accelerator" ) )
				attacker.AddSharedEnergy( SPLIT_SHOT_CRITICAL_ENERGY_RESTORE_AMOUNT )
			else
				attacker.AddSharedEnergy( CRITICAL_ENERGY_RESTORE_AMOUNT )
		}
	}
#endif
