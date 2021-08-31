untyped //TODO: get rid of player.s.cloakedShotsAllowed. (Referenced in base_gametype_sp, so remove for R5)

global function PlayerCloak_Init

global const CLOAK_FADE_IN = 1.0
global const CLOAK_FADE_OUT = 1.0

global function EnableCloak
global function DisableCloak
global function EnableCloakForever
global function DisableCloakForever

//=========================================================
//	player_cloak
//
//=========================================================

void function PlayerCloak_Init()
{
	RegisterSignal( "OnStartCloak" )
	RegisterSignal( "KillHandleCloakEnd" ) //Somewhat awkward, mainly to smooth out weird interactions with cloak ability and cloak execution

	AddCallback_OnPlayerKilled( AbilityCloak_OnDeath )
	AddSpawnCallback( "npc_titan", SetCannotCloak )
}

void function SetCannotCloak( entity ent )
{
	ent.SetCanCloak( false )
}

void function PlayCloakSounds( entity player )
{
	EmitSoundOnEntityOnlyToPlayer( player, player, "cloak_on_1P" )
	EmitSoundOnEntityExceptToPlayer( player, player, "cloak_on_3P" )

	EmitSoundOnEntityOnlyToPlayer( player, player, "cloak_sustain_loop_1P" )
	EmitSoundOnEntityExceptToPlayer( player, player, "cloak_sustain_loop_3P" )
}

void function EnableCloak( entity player, float duration, float fadeIn = CLOAK_FADE_IN )
{
	if ( player.cloakedForever )
		return

	thread AICalloutCloak( player )

	PlayCloakSounds( player )

	float cloakDuration = duration - fadeIn

	Assert( cloakDuration > 0.0, "Not valid cloak duration. Check that duration is larger than the fadeinTime. When this is not true it will cause the player to be cloaked forever. If you want to do that use EnableCloakForever instead" )

	player.SetCloakDuration( fadeIn, cloakDuration, CLOAK_FADE_OUT )

	player.s.cloakedShotsAllowed = 0

	Battery_StopFXAndHideIconForPlayer( player )

	thread HandleCloakEnd( player )
}

void function AICalloutCloak( entity player )
{
	player.EndSignal( "OnDeath" )

	wait CLOAK_FADE_IN //Give it a beat after cloak has finishing cloaking in

	array<entity> nearbySoldiers = GetNPCArrayEx( "npc_soldier", TEAM_ANY, player.GetTeam(), player.GetOrigin(), 1000  )  //-1 for distance parameter means all spectres in map
	foreach ( entity grunt in nearbySoldiers )
	{
		if ( !IsAlive( grunt ) )
			continue

		if ( grunt.GetEnemy() == player )
		{
			ScriptDialog_PilotCloaked( grunt, player )
			return //Only need one guy to say this instead of multiple guys
		}
	}
}

void function EnableCloakForever( entity player )
{
	player.SetCloakDuration( CLOAK_FADE_IN, -1, CLOAK_FADE_OUT )

	player.cloakedForever = true

	thread HandleCloakEnd( player )
	PlayCloakSounds( player )
}


void function DisableCloak( entity player, float fadeOut = CLOAK_FADE_OUT )
{
	StopSoundOnEntity( player, "cloak_sustain_loop_1P" )
	StopSoundOnEntity( player, "cloak_sustain_loop_3P" )

	bool wasCloaked = player.IsCloaked( CLOAK_INCLUDE_FADE_IN_TIME )

	if ( fadeOut < CLOAK_FADE_OUT && wasCloaked )
	{
		EmitSoundOnEntityOnlyToPlayer( player, player, "cloak_interruptend_1P" )
		EmitSoundOnEntityExceptToPlayer( player, player, "cloak_interruptend_3P" )

		StopSoundOnEntity( player, "cloak_warningtoend_1P" )
		StopSoundOnEntity( player, "cloak_warningtoend_3P" )
	}

	player.SetCloakDuration( 0, 0, fadeOut )
}

void function DisableCloakForever( entity player, float fadeOut = CLOAK_FADE_OUT )
{
	DisableCloak( player, fadeOut )
	player.cloakedForever = false
}


void function HandleCloakEnd( entity player )
{
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnEMPPilotHit" )
	player.EndSignal( "OnChangedPlayerClass" )
	player.Signal( "OnStartCloak" )
	player.EndSignal( "OnStartCloak" )
	player.EndSignal( "KillHandleCloakEnd" ) //Calling DisableCloak() after EnableCloak() doesn't kill this thread by design (to allow attacking through cloak etc), so this signal is for when you want to kill this thread

	float duration = player.GetCloakEndTime() - Time()

	OnThreadEnd(
		function() : ( player )
		{
			if ( !IsValid( player ) )
				return

			if ( PlayerHasBattery( player ) )
				Battery_StartFX( GetBatteryOnBack( player ) )

			StopSoundOnEntity( player, "cloak_sustain_loop_1P" )
			StopSoundOnEntity( player, "cloak_sustain_loop_3P" )
			if ( !IsCloaked( player ) )
				return

			if ( !IsAlive( player ) || !player.IsHuman() )
			{
				DisableCloak( player )
				return
			}

			float duration = player.GetCloakEndTime() - Time()
			if ( duration <= 0 )
			{
				DisableCloak( player )
			}
		}
	)

	float soundBufferTime = 3.45

	if ( duration > soundBufferTime )
	{
		wait ( duration - soundBufferTime )
		if ( !IsCloaked( player ) )
			return
		EmitSoundOnEntityOnlyToPlayer( player, player, "cloak_warningtoend_1P" )
		EmitSoundOnEntityExceptToPlayer( player, player, "cloak_warningtoend_3P" )

		wait soundBufferTime
	}
	else
	{
		wait duration
	}
}


void function AbilityCloak_OnDeath( entity player, entity attacker, var damageInfo )
{
	if ( !IsCloaked( player ) )
		return

	DisableCloak( player, 0 )
}