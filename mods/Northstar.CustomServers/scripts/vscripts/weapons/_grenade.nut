untyped

global function Grenade_FileInit
global function GetGrenadeThrowSound_1p
global function GetGrenadeDeploySound_1p
global function GetGrenadeThrowSound_3p
global function GetGrenadeDeploySound_3p
global function GetGrenadeProjectileSound

const DEFAULT_FUSE_TIME = 2.25
const DEFAULT_WARNING_TIME = 1.0
global const float DEFAULT_MAX_COOK_TIME = 99999.9 //Longer than an entire day. Really just an arbitrarily large number

global function Grenade_OnWeaponTossReleaseAnimEvent
global function Grenade_OnWeaponTossCancelDrop
global function Grenade_OnWeaponDeactivate
global function Grenade_OnWeaponTossPrep
global function Grenade_OnProjectileIgnite

#if SERVER
	global function Grenade_OnPlayerNPCTossGrenade_Common
	global function ProxMine_Triggered
	global function EnableTrapWarningSound
	global function AddToProximityTargets
	global function ProximityMineThink
#endif
global function Grenade_Init

const GRENADE_EXPLOSIVE_WARNING_SFX_LOOP = "Weapon_Vortex_Gun.ExplosiveWarningBeep"
const EMP_MAGNETIC_FORCE	= 1600
const MAG_FLIGHT_SFX_LOOP = "Explo_MGL_MagneticAttract"

//Proximity Mine Settings
global const PROXIMITY_MINE_EXPLOSION_DELAY = 1.2
global const PROXIMITY_MINE_ARMING_DELAY = 1.0
const TRIGGERED_ALARM_SFX = "Weapon_ProximityMine_CloseWarning"
global const THERMITE_GRENADE_FX = $"P_grenade_thermite"
global const CLUSTER_BASE_FX = $"P_wpn_meteor_exp"

global const ProximityTargetClassnames = {
	[ "npc_soldier_shield" ]	= true,
	[ "npc_soldier_heavy" ] 	= true,
	[ "npc_soldier" ] 			= true,
	[ "npc_spectre" ] 			= true,
	[ "npc_drone" ] 			= true,
	[ "npc_titan" ] 			= true,
	[ "npc_marvin" ] 			= true,
	[ "player" ] 				= true,
	[ "npc_turret_mega" ]		= true,
	[ "npc_turret_sentry" ]		= true,
	[ "npc_dropship" ]			= true,
}

const SOLDIER_ARC_STUN_ANIMS = [
		"pt_react_ARC_fall",
		"pt_react_ARC_kneefall",
		"pt_react_ARC_sidefall",
		"pt_react_ARC_slowfall",
		"pt_react_ARC_scream",
		"pt_react_ARC_stumble_F",
		"pt_react_ARC_stumble_R" ]

function Grenade_FileInit()
{
	PrecacheParticleSystem( CLUSTER_BASE_FX )

	RegisterSignal( "ThrowGrenade" )
	RegisterSignal( "WeaponDeactivateEvent" )
	RegisterSignal(	"OnEMPPilotHit" )
	RegisterSignal( "StopGrenadeClientEffects" )
	RegisterSignal( "DisableTrapWarningSound" )

	//Globalize( MagneticFlight )

	#if CLIENT
		AddDestroyCallback( "grenade_frag", ClientDestroyCallback_GrenadeDestroyed )
	#endif

	#if SERVER
		level._empForcedCallbacks <- {}
		level._proximityTargetArrayID <- CreateScriptManagedEntArray()

		AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_proximity_mine, ProxMine_Triggered )
		AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_thermite_grenade, Thermite_DamagedPlayerOrNPC )
		AddDamageCallbackSourceID( eDamageSourceId.mp_weapon_frag_grenade, Frag_DamagedPlayerOrNPC )

		level._empForcedCallbacks[eDamageSourceId.mp_weapon_grenade_emp] <- true
		level._empForcedCallbacks[eDamageSourceId.mp_weapon_proximity_mine] <- true

		PrecacheParticleSystem( THERMITE_GRENADE_FX )
	#endif
}

void function Grenade_OnWeaponTossPrep( entity weapon, WeaponTossPrepParams prepParams )
{
	weapon.w.startChargeTime = Time()

	entity weaponOwner = weapon.GetWeaponOwner()
	weapon.EmitWeaponSound_1p3p( GetGrenadeDeploySound_1p( weapon ), GetGrenadeDeploySound_3p( weapon ) )

	#if SERVER
		thread HACK_CookGrenade( weapon, weaponOwner )
		thread HACK_DropGrenadeOnDeath( weapon, weaponOwner )
	#elseif CLIENT
		if ( weaponOwner.IsPlayer() )
		{
			weaponOwner.p.grenadePulloutTime = Time()
		}
	#endif
}

void function Grenade_OnWeaponDeactivate( entity weapon )
{
	StopSoundOnEntity( weapon, GRENADE_EXPLOSIVE_WARNING_SFX_LOOP )
	weapon.Signal( "WeaponDeactivateEvent" )
}

void function Grenade_OnProjectileIgnite( entity weapon )
{
	printt( "Grenade_OnProjectileIgnite() callback." )
}

function Grenade_Init( entity grenade, entity weapon )
{
	entity weaponOwner = weapon.GetOwner()
	if ( IsValid( weaponOwner ) )
		SetTeam( grenade, weaponOwner.GetTeam() )

	// JFS: this is because I don't know if the above line should be
	// weapon.GetOwner() or it's a typo and should really be weapon.GetWeaponOwner()
	// and it's too close to ship and who knows what effect that will have
	entity owner = weapon.GetWeaponOwner()
	if ( IsMultiplayer() && IsValid( owner ) )
	{
		if ( owner.IsNPC() )
		{
			SetTeam( grenade, owner.GetTeam() )
		}
	}

	#if SERVER
		bool smartPistolVisible = weapon.GetWeaponSettingBool( eWeaponVar.projectile_visible_to_smart_ammo )
		if ( smartPistolVisible )
		{
			grenade.SetDamageNotifications( true )
			grenade.SetTakeDamageType( DAMAGE_EVENTS_ONLY )
			grenade.proj.onlyAllowSmartPistolDamage = true

			if ( !grenade.GetProjectileWeaponSettingBool( eWeaponVar.projectile_damages_owner ) && !grenade.GetProjectileWeaponSettingBool( eWeaponVar.explosion_damages_owner ) )
				SetCustomSmartAmmoTarget( grenade, true ) // prevent friendly target lockon
		}
		else
		{
			grenade.SetTakeDamageType( DAMAGE_NO )
		}
	#endif
	if ( IsValid( weaponOwner ) )
		grenade.s.originalOwner <- weaponOwner  // for later in damage callbacks, to skip damage vs friendlies but not for og owner or his enemies
}


int function Grenade_OnWeaponToss_( entity weapon, WeaponPrimaryAttackParams attackParams, float directionScale )
{
	weapon.EmitWeaponSound_1p3p( GetGrenadeThrowSound_1p( weapon ), GetGrenadeThrowSound_3p( weapon ) )
	bool projectilePredicted = PROJECTILE_PREDICTED
	bool projectileLagCompensated = PROJECTILE_LAG_COMPENSATED
#if SERVER
	if ( weapon.IsForceReleaseFromServer() )
	{
		projectilePredicted = false
		projectileLagCompensated = false
	}
#endif
	entity grenade = Grenade_Launch( weapon, attackParams.pos, (attackParams.dir * directionScale), projectilePredicted, projectileLagCompensated )
	entity weaponOwner = weapon.GetWeaponOwner()
	weaponOwner.Signal( "ThrowGrenade" )

	PlayerUsedOffhand( weaponOwner, weapon ) // intentionally here and in Hack_DropGrenadeOnDeath - accurate for when cooldown actually begins

#if SERVER

	#if BATTLECHATTER_ENABLED
		TryPlayWeaponBattleChatterLine( weaponOwner, weapon )
	#endif

#endif

	return weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
}

var function Grenade_OnWeaponTossReleaseAnimEvent( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	var result = Grenade_OnWeaponToss_( weapon, attackParams, 1.0 )
	return result
}

var function Grenade_OnWeaponTossCancelDrop( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	var result = Grenade_OnWeaponToss_( weapon, attackParams, 0.2 )
	return result
}

// Can return entity or nothing
entity function Grenade_Launch( entity weapon, vector attackPos, vector throwVelocity, bool isPredicted, bool isLagCompensated  )
{
	#if CLIENT
		if ( !weapon.ShouldPredictProjectiles() )
			return null
	#endif

	//TEMP FIX while Deploy anim is added to sprint
	float currentTime = Time()
	if ( weapon.w.startChargeTime == 0.0 )
		weapon.w.startChargeTime = currentTime

	entity weaponOwner = weapon.GetWeaponOwner()

	var discThrow = weapon.GetWeaponInfoFileKeyField( "grenade_disc_throw" )

	vector angularVelocity = Vector( 3600, RandomFloatRange( -1200, 1200 ), 0 )

	if ( discThrow == 1 )
		angularVelocity = Vector( 100, 100, RandomFloatRange( 1200, 2200 ) )


	float fuseTime

	float baseFuseTime = weapon.GetGrenadeFuseTime() //Note that fuse time of 0 means the grenade won't explode on its own, instead it depends on OnProjectileCollision() functions to be defined and explode there. Arguably in this case grenade_fuse_time shouldn't be 0, but an arbitrarily large number instead.
	if ( baseFuseTime > 0.0 )
	{
		fuseTime = baseFuseTime - ( currentTime - weapon.w.startChargeTime )
		if ( fuseTime <= 0 )
			fuseTime = 0.001
	}
	else
	{
		fuseTime = baseFuseTime
	}

	int damageFlags = weapon.GetWeaponDamageFlags()
	entity frag = weapon.FireWeaponGrenade( attackPos, throwVelocity, angularVelocity, fuseTime, damageFlags, damageFlags, isPredicted, isLagCompensated, true )
	if ( frag == null )
		return null

	if ( discThrow == 1 ) // add wobble by pitching it slightly
	{
		Assert( !frag.IsMarkedForDeletion(), "Frag before .SetAngles() is marked for deletion." )
		frag.SetAngles( frag.GetAngles() + < RandomFloatRange( 7,11 ),0,0 > )
		//Assert( !frag.IsMarkedForDeletion(), "Frag after .SetAngles() is marked for deletion." )
		if ( frag.IsMarkedForDeletion() )
		{
			CodeWarning( "Frag after .SetAngles() was marked for deletion." )
			return null
		}
	}

	Grenade_OnPlayerNPCTossGrenade_Common( weapon, frag )

	return frag
}

void function Grenade_OnPlayerNPCTossGrenade_Common( entity weapon, entity frag )
{
	Grenade_Init( frag, weapon )
	#if SERVER
		thread TrapExplodeOnDamage( frag, 20, 0.0, 0.0 )

		string projectileSound = GetGrenadeProjectileSound( weapon )
		if ( projectileSound != "" )
			EmitSoundOnEntity( frag, projectileSound )
	#endif

	if( weapon.HasMod( "burn_mod_emp_grenade" ) )
		frag.InitMagnetic( EMP_MAGNETIC_FORCE, MAG_FLIGHT_SFX_LOOP )
}

struct CookGrenadeStruct //Really just a convenience struct so we can read the changed value of a bool in an OnThreadEnd
{
	bool shouldOverrideFuseTime = false
}

void function HACK_CookGrenade( entity weapon, entity weaponOwner )
{
	float maxCookTime = GetMaxCookTime( weapon )
	if ( maxCookTime >= DEFAULT_MAX_COOK_TIME )
		return

	weaponOwner.EndSignal( "OnDeath" )
	weaponOwner.EndSignal( "ThrowGrenade" )
	weapon.EndSignal( "WeaponDeactivateEvent" )
	weapon.EndSignal( "OnDestroy" )

	/*CookGrenadeStruct grenadeStruct

	OnThreadEnd(
	function() : ( weapon, grenadeStruct )
		{
			if ( grenadeStruct.shouldOverrideFuseTime )
			{
				var minFuseTime = weapon.GetWeaponInfoFileKeyField( "min_fuse_time" )
				printt( "minFuseTime: " + minFuseTime )
				if ( minFuseTime != null )
				{
					expect float( minFuseTime )
					printt( "Setting overrideFuseTime to : " + weapon.GetWeaponInfoFileKeyField( "min_fuse_time" ) )
					weapon.w.overrideFuseTime =  minFuseTime
				}
			}
		}
	)
*/
	if ( maxCookTime - DEFAULT_WARNING_TIME <= 0 )
	{
		EmitSoundOnEntity( weapon, GRENADE_EXPLOSIVE_WARNING_SFX_LOOP )
		wait maxCookTime
	}
	else
	{
		wait( maxCookTime - DEFAULT_WARNING_TIME )

		EmitSoundOnEntity( weapon, GRENADE_EXPLOSIVE_WARNING_SFX_LOOP )

		wait( DEFAULT_WARNING_TIME )
	}

	if ( !IsValid( weapon.GetWeaponOwner() ) )
		return

	weapon.ForceReleaseFromServer() // Will eventually result in Grenade_OnWeaponToss_() or equivalent function

	// JFS: prevent grenade cook exploit in coliseum
	if ( GameRules_GetGameMode() == COLISEUM )
	{
		#if SERVER
		int damageSource = weapon.GetDamageSourceID()

		if ( damageSource == eDamageSourceId.mp_weapon_frag_grenade )
		{
			var impact_effect_table = weapon.GetWeaponInfoFileKeyField( "impact_effect_table" )
			if ( impact_effect_table != null )
			{
				string fx = expect string( impact_effect_table )
				PlayImpactFXTable( weaponOwner.EyePosition(), weaponOwner, fx )
			}
			weaponOwner.Die( weaponOwner, weapon, { damageSourceId = damageSource } )
		}
		#endif
	}

	weaponOwner.Signal( "ThrowGrenade" ) // Only necessary to end HACK_DropGrenadeOnDeath
}


void function HACK_WaitForGrenadeDropEvent( weapon, entity weaponOwner )
{
	weapon.EndSignal( "WeaponDeactivateEvent" )

	weaponOwner.WaitSignal( "OnDeath" )
}


void function HACK_DropGrenadeOnDeath( entity weapon, entity weaponOwner )
{
	if ( weapon.HasMod( "burn_card_weapon_mod" ) ) //JFS: Primarily to stop boost grenade weapons (e.g. frag_drone ) not doing TryUsingBurnCardWeapon() when dropped through this function.
		return

	weaponOwner.EndSignal( "ThrowGrenade" )
	weaponOwner.EndSignal( "OnDestroy" )

	waitthread HACK_WaitForGrenadeDropEvent( weapon, weaponOwner )

	if( !IsValid( weaponOwner ) || !IsValid( weapon ) || IsAlive( weaponOwner ) )
		return

	float elapsedTime = Time() - weapon.w.startChargeTime
	float baseFuseTime = weapon.GetGrenadeFuseTime()
	float fuseDelta = (baseFuseTime - elapsedTime)

	if ( (baseFuseTime == 0.0) || (fuseDelta > -0.1) )
	{
		float forwardScale = weapon.GetWeaponSettingFloat( eWeaponVar.grenade_death_drop_velocity_scale )
		vector velocity = weaponOwner.GetForwardVector() * forwardScale
		velocity.z += weapon.GetWeaponSettingFloat( eWeaponVar.grenade_death_drop_velocity_extraUp )
		vector angularVelocity = Vector( 0, 0, 0 )
		float fuseTime = baseFuseTime ? baseFuseTime - elapsedTime : baseFuseTime

		int primaryClipCount = weapon.GetWeaponPrimaryClipCount()
		int ammoPerShot = weapon.GetWeaponSettingInt( eWeaponVar.ammo_per_shot )
		weapon.SetWeaponPrimaryClipCountAbsolute( maxint( 0, primaryClipCount - ammoPerShot ) )

		PlayerUsedOffhand( weaponOwner, weapon ) // intentionally here and in ReleaseAnimEvent - for cases where grenade is dropped on death

		entity grenade = Grenade_Launch( weapon, weaponOwner.GetOrigin(), velocity, PROJECTILE_NOT_PREDICTED, PROJECTILE_NOT_LAG_COMPENSATED )
	}
}


#if SERVER
void function ProxMine_Triggered( entity ent, var damageInfo )
{
	if ( !IsValid( ent ) )
		return

	if ( DamageInfo_GetCustomDamageType( damageInfo ) & DF_DOOMED_HEALTH_LOSS )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsValid( attacker ) )
		return

	if ( attacker == ent )
		return

	if ( ent.IsPlayer() || ent.IsNPC() )
		thread ShowProxMineTriggeredIcon( ent )

	//If this feature is good, we should add this to NPCs as well. Currently script errors if applied to an NPC.
	//if ( ent.IsPlayer() )
	//	thread ProxMine_ShowOnMinimapTimed( ent, GetOtherTeam( ent.GetTeam() ), PROX_MINE_MARKER_TIME )
}

/*
function ProxMine_ShowOnMinimapTimed( ent, teamToDisplayEntTo, duration )
{
	ent.Minimap_AlwaysShow( teamToDisplayEntTo, null )
	Minimap_CreatePingForTeam( teamToDisplayEntTo, ent.GetOrigin(), $"vgui/HUD/titanFiringPing", 1.0 )

	wait duration

	if ( IsValid( ent ) && ent.IsPlayer() )
		ent.Minimap_DisplayDefault( teamToDisplayEntTo, ent )
}
*/

void function Thermite_DamagedPlayerOrNPC( entity ent, var damageInfo )
{
	if ( !IsValid( ent ) )
		return

	Thermite_DamagePlayerOrNPCSounds( ent )
}

void function Frag_DamagedPlayerOrNPC( entity ent, var damageInfo )
{
	#if MP
	if ( !IsValid( ent ) || ent.IsPlayer() || ent.IsTitan() )
		return

	if ( ent.IsMechanical() )
		DamageInfo_ScaleDamage( damageInfo, 0.5 )
	#endif
}

#endif // SERVER


#if CLIENT
void function ClientDestroyCallback_GrenadeDestroyed( entity grenade )
{
}
#endif // CLIENT

#if SERVER
function EnableTrapWarningSound( entity trap, delay = 0, warningSound = DEFAULT_WARNING_SFX )
{
	trap.EndSignal( "OnDestroy" )
	trap.EndSignal( "DisableTrapWarningSound" )

	if ( delay > 0 )
		wait delay

	  while ( IsValid( trap ) )
	  {
		  EmitSoundOnEntity( trap, warningSound )
		  wait 1.0
	  }
}

void function AddToProximityTargets( entity ent )
{
	AddToScriptManagedEntArray( level._proximityTargetArrayID, ent );
}

function ProximityMineThink( entity proximityMine, entity owner )
{
	proximityMine.EndSignal( "OnDestroy" )

	OnThreadEnd(
		function() : ( proximityMine )
		{
			if ( IsValid( proximityMine ) )
				proximityMine.Destroy()
		}
	)
	thread TrapExplodeOnDamage( proximityMine, 50 )

	wait PROXIMITY_MINE_ARMING_DELAY

	int teamNum = proximityMine.GetTeam()
	float explodeRadius = proximityMine.GetDamageRadius()
	float triggerRadius = ( ( explodeRadius * 0.75 ) + 0.5 )
	local lastTimeNPCsChecked = 0
	local NPCTickRate = 0.5
	local PlayerTickRate = 0.2

	// Wait for someone to enter proximity
	while( IsValid( proximityMine ) && IsValid( owner ) )
	{
		if ( lastTimeNPCsChecked + NPCTickRate <= Time() )
		{
			array<entity> nearbyNPCs = GetNPCArrayEx( "any", TEAM_ANY, teamNum, proximityMine.GetOrigin(), triggerRadius )
			foreach( ent in nearbyNPCs )
			{
				if ( ShouldSetOffProximityMine( proximityMine, ent ) )
				{
					ProximityMine_Explode( proximityMine )
					return
				}
			}
			lastTimeNPCsChecked = Time()
		}

		array<entity> nearbyPlayers = GetPlayerArrayEx( "any", TEAM_ANY, teamNum, proximityMine.GetOrigin(), triggerRadius )
		foreach( ent in nearbyPlayers )
		{
			if ( ShouldSetOffProximityMine( proximityMine, ent ) )
			{
				ProximityMine_Explode( proximityMine )
				return
			}
		}

		wait PlayerTickRate
	}
}

function ProximityMine_Explode( proximityMine )
{
	local explodeTime = Time() + PROXIMITY_MINE_EXPLOSION_DELAY
	EmitSoundOnEntity( proximityMine, TRIGGERED_ALARM_SFX )

	wait PROXIMITY_MINE_EXPLOSION_DELAY

	if ( IsValid( proximityMine ) )
		proximityMine.GrenadeExplode( proximityMine.GetForwardVector() )
}

bool function ShouldSetOffProximityMine( entity proximityMine, entity ent )
{
	if ( !IsAlive( ent ) )
		return false

	if ( ent.IsPhaseShifted() )
		return false

	TraceResults results = TraceLine( proximityMine.GetOrigin(), ent.EyePosition(), proximityMine, (TRACE_MASK_SHOT | CONTENTS_BLOCKLOS), TRACE_COLLISION_GROUP_NONE )
	if ( results.fraction >= 1 || results.hitEnt == ent )
		return true

	return false
}

#endif // SERVER



float function GetMaxCookTime( entity weapon )
{
	var cookTime = weapon.GetWeaponInfoFileKeyField( "max_cook_time" )
	if (cookTime == null )
		return DEFAULT_MAX_COOK_TIME

	expect float ( cookTime )
	return cookTime
}

function GetGrenadeThrowSound_1p( weapon )
{
	return weapon.GetWeaponInfoFileKeyField( "sound_throw_1p" ) ? weapon.GetWeaponInfoFileKeyField( "sound_throw_1p" ) : ""
}


function GetGrenadeDeploySound_1p( weapon )
{
	return weapon.GetWeaponInfoFileKeyField( "sound_deploy_1p" ) ? weapon.GetWeaponInfoFileKeyField( "sound_deploy_1p" ) : ""
}


function GetGrenadeThrowSound_3p( weapon )
{
	return weapon.GetWeaponInfoFileKeyField( "sound_throw_3p" ) ? weapon.GetWeaponInfoFileKeyField( "sound_throw_3p" ) : ""
}


function GetGrenadeDeploySound_3p( weapon )
{
	return weapon.GetWeaponInfoFileKeyField( "sound_deploy_3p" ) ? weapon.GetWeaponInfoFileKeyField( "sound_deploy_3p" ) : ""
}

string function GetGrenadeProjectileSound( weapon )
{
	return expect string( weapon.GetWeaponInfoFileKeyField( "sound_grenade_projectile" ) ? weapon.GetWeaponInfoFileKeyField( "sound_grenade_projectile" ) : "" )
}
