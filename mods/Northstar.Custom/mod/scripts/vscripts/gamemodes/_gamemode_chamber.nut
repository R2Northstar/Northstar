global function GamemodeChamber_Init

void function GamemodeChamber_Init()
{
	SetSpawnpointGamemodeOverride( FFA )

	SetShouldUseRoundWinningKillReplay( true )
	SetLoadoutGracePeriodEnabled( false ) // prevent modifying loadouts with grace period
	SetWeaponDropsEnabled( false )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )
	Riff_ForceBoostAvailability( eBoostAvailability.Disabled )
	ClassicMP_ForceDisableEpilogue( true )

	AddCallback_OnClientConnected( ChamberInitPlayer )
	AddCallback_OnPlayerKilled( ChamberOnPlayerKilled )
	AddCallback_OnPlayerRespawned( UpdateLoadout )

}

void function ChamberInitPlayer( entity player )
{
	UpdateLoadout( player )
}

int function GetChamberWingmanN(){
	return GetCurrentPlaylistVarInt( "chamber_wingman_n", 0 )
}

void function ChamberOnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( !victim.IsPlayer() || GetGameState() != eGameState.Playing || attacker == victim)
		return

	if ( attacker.IsPlayer() )
	{
		if ( (DamageInfo_GetDamageSourceIdentifier( damageInfo ) == eDamageSourceId.mp_weapon_wingman_n) || (DamageInfo_GetDamageSourceIdentifier( damageInfo ) == eDamageSourceId.mp_weapon_wingman) )
		{
			attacker.SetPlayerGameStat( PGS_ASSAULT_SCORE, attacker.GetPlayerGameStat( PGS_ASSAULT_SCORE ) + 1 )
			AddTeamScore( attacker.GetTeam(), 1 )
		}

		if ( DamageInfo_GetDamageSourceIdentifier( damageInfo ) == eDamageSourceId.human_execution )
		{
			attacker.SetPlayerGameStat( PGS_ASSAULT_SCORE, attacker.GetPlayerGameStat( PGS_ASSAULT_SCORE ) + 1 )
			AddTeamScore( attacker.GetTeam(), 1 )

			string message = victim.GetPlayerName() + " got executed."
			foreach ( entity player in GetPlayerArray() )
				SendHudMessage( player, message, -1, 0.4, 255, 0, 0, 0, 0, 3, 0.15 )

			foreach ( entity weapon in attacker.GetMainWeapons() )
			{
				weapon.SetWeaponPrimaryAmmoCount(0)
				int clip = weapon.GetWeaponPrimaryClipCount() + 4
				if (weapon.GetWeaponPrimaryClipCountMax() < clip)
					weapon.SetWeaponPrimaryClipCount(weapon.GetWeaponPrimaryClipCountMax())
				else
					weapon.SetWeaponPrimaryClipCount(weapon.GetWeaponPrimaryClipCount() + 4)
			}
		} else
		{
			foreach ( entity weapon in attacker.GetMainWeapons() )
       	 		{
				weapon.SetWeaponPrimaryAmmoCount(0)
				int clip = weapon.GetWeaponPrimaryClipCount() + 1
				if (weapon.GetWeaponPrimaryClipCountMax() < clip)
					weapon.SetWeaponPrimaryClipCount(weapon.GetWeaponPrimaryClipCountMax())
				else
					weapon.SetWeaponPrimaryClipCount(weapon.GetWeaponPrimaryClipCount() + 1)
			}
		}
		SetRoundWinningKillReplayAttacker(attacker)
	}
}

void function UpdateLoadout( entity player )
{
	if (IsAlive(player) && player != null)
	{

		// set loadout
		foreach ( entity weapon in player.GetMainWeapons() )
			player.TakeWeaponNow( weapon.GetWeaponClassName() )

		foreach ( entity weapon in player.GetOffhandWeapons() )
			player.TakeWeaponNow( weapon.GetWeaponClassName() )

		array<string> mods = ["one_in_the_chamber"]
		player.GiveWeapon( (GetChamberWingmanN() ? "mp_weapon_wingman_n" : "mp_weapon_wingman"), mods)
		player.GiveOffhandWeapon( "melee_pilot_kunai", OFFHAND_MELEE )

		thread SetAmmo( player )
	}
}

void function SetAmmo( entity player )
{
	foreach ( entity weapon in player.GetMainWeapons() )
	{
        	weapon.SetWeaponPrimaryAmmoCount(0)
        	weapon.SetWeaponPrimaryClipCount(1)
	}
	WaitFrame()
	if ( IsValid( player ) )
		PlayerEarnMeter_SetMode( player, eEarnMeterMode.DISABLED )
}
