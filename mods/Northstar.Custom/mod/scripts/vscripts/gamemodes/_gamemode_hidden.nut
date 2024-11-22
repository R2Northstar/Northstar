global function GamemodeHidden_Init

struct {
	bool isVisible = false
	array<entity> hiddens
} file

void function GamemodeHidden_Init()
{
	SetShouldUseRoundWinningKillReplay( true )
	SetLoadoutGracePeriodEnabled( false ) // prevent modifying loadouts with grace period
	SetWeaponDropsEnabled( false )
	SetRespawnsEnabled( false )
	SetGamemodeAllowsTeamSwitch( false )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )
	Riff_ForceBoostAvailability( eBoostAvailability.Disabled )
	Riff_ForceSetEliminationMode( eEliminationMode.Pilots )

	ClassicMP_SetCustomIntro( ClassicMP_DefaultNoIntro_Setup, ClassicMP_DefaultNoIntro_GetLength() )
	ClassicMP_ForceDisableEpilogue( true )

	AddCallback_OnClientConnected( HiddenInitPlayer )
	AddCallback_OnPlayerKilled( HiddenOnPlayerKilled )
	AddCallback_GameStateEnter( eGameState.Playing, SelectFirstHidden )
	AddCallback_GameStateEnter( eGameState.Postmatch, RemoveHidden )
	SetTimeoutWinnerDecisionFunc( TimeoutCheckSurvivors )

	RegisterSignal( "VisibleNotification" )
}

void function HiddenInitPlayer( entity player )
{
	SetTeam( player, TEAM_MILITIA )
}

void function SelectFirstHidden()
{
	thread SelectFirstHiddenDelayed()
}

void function SelectFirstHiddenDelayed()
{
	wait 10.0 + RandomFloat( 5.0 )

	array<entity> players = GetPlayerArray()
	entity hidden = players[ RandomInt( players.len() ) ]

	if (hidden != null || IsAlive(hidden))
		MakePlayerHidden( hidden ) // randomly selected player becomes hidden

	foreach ( entity otherPlayer in GetPlayerArray() )
			if ( hidden != otherPlayer )
				Remote_CallFunction_NonReplay( otherPlayer, "ServerCallback_AnnounceHidden", hidden.GetEncodedEHandle() )

	PlayMusicToAll( eMusicPieceID.GAMEMODE_1 )

	thread UpdateSurvivorsLoadout()
}

void function UpdateSurvivorsLoadout()
{
	foreach (entity player in GetPlayerArray())
	{
		if (player.GetTeam() != TEAM_MILITIA || !IsAlive(player) || player == null)
			continue;

		foreach ( entity weapon in player.GetOffhandWeapons() )
			player.TakeWeaponNow( weapon.GetWeaponClassName() )

		try {
			player.GiveOffhandWeapon("mp_ability_cloak", OFFHAND_SPECIAL )
			player.GiveOffhandWeapon("mp_weapon_grenade_emp", OFFHAND_ORDNANCE )
			player.GiveOffhandWeapon( "melee_pilot_emptyhanded", OFFHAND_MELEE )
		} catch (ex) {}
	}
}

void function MakePlayerHidden(entity player)
{
	if (player == null)
		return;

	SetTeam( player, TEAM_IMC )
	player.SetPlayerGameStat( PGS_ASSAULT_SCORE, 0 ) // reset kills
	file.hiddens.append( player )
	RespawnHidden( player )
	thread PredatorMain( player )
	thread VisibleNotification( player )
	Remote_CallFunction_NonReplay( player, "ServerCallback_YouAreHidden" )
}

void function RespawnHidden(entity player)
{
	if (player.GetTeam() != TEAM_IMC )
		return

	// scale health of the hidden, with 50 as base health
	player.SetMaxHealth( 80 + ( (GetPlayerArrayOfTeam( TEAM_MILITIA ).len() + 1 ) * 20) )
	player.SetHealth( 80 + ( (GetPlayerArrayOfTeam( TEAM_MILITIA ).len() + 1 ) * 20) )

	if ( !player.IsMechanical() )
		player.SetBodygroup( player.FindBodyGroup( "head" ), 1 )

	// set loadout
	foreach ( entity weapon in player.GetMainWeapons() )
		player.TakeWeaponNow( weapon.GetWeaponClassName() )

	foreach ( entity weapon in player.GetOffhandWeapons() )
		player.TakeWeaponNow( weapon.GetWeaponClassName() )

	player.GiveWeapon("mp_weapon_wingman_n")
	player.GiveOffhandWeapon( "melee_pilot_emptyhanded", OFFHAND_MELEE )
	player.GiveOffhandWeapon( "mp_weapon_grenade_sonar", OFFHAND_SPECIAL );
	thread UpdateLoadout(player)
	thread GiveArcGrenade(player)
}

void function GiveArcGrenade(entity player)
{
	wait 45.0
	if (IsAlive(player) || player != null)
		player.GiveOffhandWeapon( "mp_weapon_grenade_emp", OFFHAND_ORDNANCE );
}

void function HiddenOnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( !victim.IsPlayer() || GetGameState() != eGameState.Playing )
		return

	if ( attacker.IsPlayer() )
	{
		// increase kills by 1
		attacker.SetPlayerGameStat( PGS_ASSAULT_SCORE, attacker.GetPlayerGameStat( PGS_ASSAULT_SCORE ) + 1 )
	}

}

void function UpdateLoadout( entity player )
{
	string p2016 = "mp_weapon_wingman_n"
	foreach ( entity weapon in player.GetMainWeapons() )
	{
		if (weapon.GetWeaponClassName() == p2016)
		{
        	weapon.SetWeaponPrimaryAmmoCount(0)
        	weapon.SetWeaponPrimaryClipCount(weapon.GetWeaponPrimaryClipCountMax())
		}
	}
	WaitFrame()
	if ( IsValid( player ) )
		PlayerEarnMeter_SetMode( player, eEarnMeterMode.DISABLED )
}

void function RemoveHidden()
{
	foreach (entity player in GetPlayerArray())
	{
		if (player.GetTeam() == TEAM_IMC && player != null)
			player.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	}
}

void function PredatorMain( entity player )
{
        player.EndSignal( "OnDeath" )
        player.EndSignal( "OnDestroy" )
	float playerVel

	while (true) 
	{
		WaitFrame()
		if(!IsLobby())
		{
			if ( !IsValid( player ) || !IsAlive( player ) || player.GetTeam() != TEAM_IMC )
				continue

			vector playerVelV = player.GetVelocity()
			playerVel = sqrt( playerVelV.x * playerVelV.x + playerVelV.y * playerVelV.y + playerVelV.z * playerVelV.z )

			if ( playerVel/300 < 1.3 )
			{
				player.SetCloakFlicker( 0, 0 )
				player.kv.VisibilityFlags = 0
				wait 0.5
				if ( file.isVisible )
				{
					file.isVisible = false
					player.Signal( "VisibleNotification" )
				}
			}
			else
			{
				player.SetCloakFlicker( 0.2 , 1 )
				player.kv.VisibilityFlags = 0
				float waittime = RandomFloat( 0.5 )
				wait waittime
				player.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
				file.isVisible = true
			}
		}
	}
}

void function VisibleNotification( entity player )
{
        player.EndSignal( "OnDeath" )
        player.EndSignal( "OnDestroy" )
	while (IsAlive(player))
	{
		WaitFrame()
		if (!file.isVisible)
		{
			NSDeleteStatusMessageOnPlayer( player, "visibleTitle" )
			NSDeleteStatusMessageOnPlayer( player, "visibleDesc" )
			continue
		}
		else
		{
			NSCreateStatusMessageOnPlayer( player, "You are visible!", "", "visibleTitle" )
			NSCreateStatusMessageOnPlayer( player, "Note:", "Slow down to remain invisible!", "visibleDesc" )
			player.WaitSignal( "VisibleNotification" )
			continue
		}
	}
}

int function TimeoutCheckSurvivors()
{
	if ( GetPlayerArrayOfTeam( TEAM_MILITIA ).len() > 0 )
		return TEAM_IMC

	return TEAM_MILITIA
}
