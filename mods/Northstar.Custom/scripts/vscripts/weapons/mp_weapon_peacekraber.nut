untyped

// created by JustANormalUser#0001 on discord

global function OnWeaponPrimaryAttack_peacekraber;
global function OnWeaponDeactivate_peacekraber
global function OnWeaponActivate_peacekraber

#if SERVER
global function OnWeaponNpcPrimaryAttack_peacekraber
#endif // #if SERVER


const PEACEKRABER_MAX_BOLTS = 11 // this is the code limit for bolts per frame... do not increase.
bool isWeaponActive = false;
entity clientWeapon = null;

struct
{
	float[2][PEACEKRABER_MAX_BOLTS] boltOffsets = [
		[0.0, 0.0], // center
		[0.0, 1.0], // top
		[-0.683, 0.327],
		[0.683, 0.327],
		[-0.636, -0.683],
		[0.636, -0.683],
		[0.0, 0.5],
		[-0.342, 0.174],
		[0.342, 0.174],
		[-0.318, -0.342],
		[0.318, -0.342],
	]

	int maxAmmo
	float ammoRegenTime
} file
//	"OnWeaponActivate"								"OnWeaponActivate_peacekraber"
//	"OnWeaponDeactivate"							"OnWeaponDeactivate_peacekraber"
void function OnWeaponActivate_peacekraber (entity weapon) {
	#if CLIENT
	if (!weapon.GetWeaponOwner().IsPlayer() || weapon.GetWeaponOwner() != GetLocalViewPlayer()) return;
	isWeaponActive = true;
	clientWeapon = weapon;
	thread CrosshairCycle();
	#endif
}

void function OnWeaponDeactivate_peacekraber (entity weapon) {
	#if CLIENT
	if (!weapon.GetWeaponOwner().IsPlayer() || weapon.GetWeaponOwner() != GetLocalViewPlayer()) return;
	isWeaponActive = false;
	#endif
}
#if CLIENT
void function CrosshairCycle() {
	var rui = RuiCreate( $"ui/crosshair_shotgun.rpak", clGlobal.topoCockpitHudPermanent, RUI_DRAW_COCKPIT, 0 )
	RuiSetFloat(rui, "adjustedSpread", 0.1)
	array<int> spreadFrac = [1, 0.65, 0.45, 0.2]
	array<vector> colors = [<1, 1, 1>, <0.666, 1, 1>, <0.333, 1, 1>, <0, 1, 1>]
	int chargeLevel;
	float chargeFrac;
	while (isWeaponActive) {
		WaitFrame()
		chargeLevel = clientWeapon.GetWeaponChargeLevel();
		chargeFrac = clientWeapon.GetWeaponChargeFraction();
		RuiSetFloat3(rui, "teamColor", colors[chargeLevel]);
		switch (chargeLevel) {
			case 0: 
				if (chargeFrac > 0.266) {
					RuiSetFloat(rui, "adjustedSpread", Graph(chargeFrac, 0.266, 0.333, 0.1, 0.065))
				}
				else RuiSetFloat(rui, "adjustedSpread", 0.1)
				break;
			case 1: 
				if (chargeFrac > 0.6) {
					RuiSetFloat(rui, "adjustedSpread", Graph(chargeFrac, 0.6, 0.666, 0.065, 0.045))
				}
				else RuiSetFloat(rui, "adjustedSpread", 0.065)
				break;
			case 2: 
				if (chargeFrac > 0.933) {
					RuiSetFloat(rui, "adjustedSpread", Graph(chargeFrac, 0.933, 1, 0.045, 0.02))
				}
				else RuiSetFloat(rui, "adjustedSpread", 0.045)
				break;
			case 3: 
				RuiSetFloat(rui, "adjustedSpread", 0.025)
				break;
			default:
				break;
		}
	}

	RuiDestroy(rui);
	clientWeapon = null;
}
#endif

var function OnWeaponPrimaryAttack_peacekraber( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	#if CLIENT
		weapon.EmitWeaponSound( "Weapon_Titan_Sniper_LevelTick_2" )
	#endif

	return FireWeaponPlayerAndNPC( attackParams, true, weapon )
}

#if SERVER
var function OnWeaponNpcPrimaryAttack_peacekraber( entity weapon, WeaponPrimaryAttackParams attackParams )
{
	return FireWeaponPlayerAndNPC( attackParams, false, weapon )
}
#endif // #if SERVER

function FireWeaponPlayerAndNPC( WeaponPrimaryAttackParams attackParams, bool playerFired, entity weapon )
{
	entity owner = weapon.GetWeaponOwner()
	bool shouldCreateProjectile = false
	if ( IsServer() || weapon.ShouldPredictProjectiles() )
		shouldCreateProjectile = true
	#if CLIENT
		if ( !playerFired )
			shouldCreateProjectile = false
	#endif

	vector attackAngles = VectorToAngles( attackParams.dir )
	vector baseUpVec = AnglesToUp( attackAngles )
	vector baseRightVec = AnglesToRight( attackAngles )

	if ( shouldCreateProjectile )
	{
		weapon.EmitWeaponNpcSound( LOUD_WEAPON_AI_SOUND_RADIUS_MP, 0.2 )
		array<int> spreadFrac = [1, 0.65, 0.45, 0.2]

		for ( int index = 0; index < PEACEKRABER_MAX_BOLTS; index++ )
		{
			vector upVec = baseUpVec * file.boltOffsets[index][1] * 0.05 * spreadFrac[weapon.GetWeaponChargeLevel()]
			vector rightVec = baseRightVec * file.boltOffsets[index][0] * 0.05 * spreadFrac[weapon.GetWeaponChargeLevel()]

			vector attackDir = attackParams.dir + upVec + rightVec
			float projectileSpeed = 2800

			if ( weapon.GetWeaponClassName() == "mp_weapon_peacekraber" )
				{
					projectileSpeed = 6400
				}

			entity bolt = weapon.FireWeaponBolt( attackParams.pos, attackDir, projectileSpeed, damageTypes.largeCaliber | DF_SHOTGUN, damageTypes.largeCaliber | DF_SHOTGUN, playerFired, index )
			if ( bolt )
			{
				bolt.kv.gravity = 0.4 // 0.09

				if ( weapon.GetWeaponClassName() == "mp_weapon_peacekraber" )
					bolt.SetProjectileLifetime( RandomFloatRange( 1.0, 1.3 ) )
				else
					bolt.SetProjectileLifetime( RandomFloatRange( 0.50, 0.65 ) )
			}
		}
	}

	return 1
}