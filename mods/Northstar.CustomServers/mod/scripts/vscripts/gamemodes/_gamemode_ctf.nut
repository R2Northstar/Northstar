untyped

global function CaptureTheFlag_Init
global function RateSpawnpoints_CTF

const array<string> SWAP_FLAG_MAPS = [
	"mp_forwardbase_kodai",
	"mp_lf_meadow"
]

struct {
	entity imcFlagSpawn
	entity imcFlag
	
	entity militiaFlagSpawn
	entity militiaFlag
	
	array<entity> imcCaptureAssistList
	array<entity> militiaCaptureAssistList
} file










/*
 ██████  █████  ██████  ████████ ██    ██ ██████  ███████     ████████ ██   ██ ███████     ███████ ██       █████   ██████  
██      ██   ██ ██   ██    ██    ██    ██ ██   ██ ██             ██    ██   ██ ██          ██      ██      ██   ██ ██       
██      ███████ ██████     ██    ██    ██ ██████  █████          ██    ███████ █████       █████   ██      ███████ ██   ███ 
██      ██   ██ ██         ██    ██    ██ ██   ██ ██             ██    ██   ██ ██          ██      ██      ██   ██ ██    ██ 
 ██████ ██   ██ ██         ██     ██████  ██   ██ ███████        ██    ██   ██ ███████     ██      ███████ ██   ██  ██████  
*/

void function CaptureTheFlag_Init()
{
	PrecacheModel( CTF_FLAG_MODEL )
	PrecacheModel( CTF_FLAG_BASE_MODEL )
	PrecacheParticleSystem( FLAG_FX_FRIENDLY )
	PrecacheParticleSystem( FLAG_FX_ENEMY )
	
	CaptureTheFlagShared_Init()
	
	SetSwitchSidesBased( true )
	SetSuddenDeathBased( true )
	
	SetShouldUseRoundWinningKillReplay( true )
	SetRoundWinningKillReplayKillClasses( false, false )
	
	AddCallback_OnClientConnected( CTFInitPlayer )
	AddCallback_OnClientDisconnected( CTFPlayerDisconnected )
	
	AddCallback_GameStateEnter( eGameState.Prematch, CreateFlags )
	AddCallback_GameStateEnter( eGameState.Epilogue, RemoveFlags )
	AddCallback_GameStateEnter( eGameState.Playing, OnPlaying )
	
	AddCallback_OnTouchHealthKit( "item_flag", OnFlagCollected )
	
	AddCallback_OnPlayerKilled( OnPlayerKilled )
	AddCallback_OnPilotBecomesTitan( DropFlagForBecomingTitan )
	
	AddSpawnpointValidationRule( VerifyCTFSpawnpoint )
	
	RegisterSignal( "ResetDropTimeout" )
	
	level.teamFlags <- {}
	
	ScoreEvent_SetEarnMeterValues( "KillPilot", 0.05, 0.20 )
	ScoreEvent_SetEarnMeterValues( "Headshot", 0.0, 0.02 )
	ScoreEvent_SetEarnMeterValues( "FirstStrike", 0.0, 0.05 )
	ScoreEvent_SetEarnMeterValues( "KillTitan", 0.0, 0.25 )
	ScoreEvent_SetEarnMeterValues( "PilotBatteryStolen", 0.0, 0.35 )
	
	ScoreEvent_SetEarnMeterValues( "FlagCarrierKill", 0.0, 0.20 )
	ScoreEvent_SetEarnMeterValues( "FlagTaken", 0.0, 0.10 )
	ScoreEvent_SetEarnMeterValues( "FlagCapture", 0.0, 0.30 )
	ScoreEvent_SetEarnMeterValues( "FlagCaptureAssist", 0.0, 0.20 )
	ScoreEvent_SetEarnMeterValues( "FlagReturn", 0.0, 0.20 )
}









/*
███████ ██████   █████  ██     ██ ███    ██     ██       ██████   ██████  ██  ██████ 
██      ██   ██ ██   ██ ██     ██ ████   ██     ██      ██    ██ ██       ██ ██      
███████ ██████  ███████ ██  █  ██ ██ ██  ██     ██      ██    ██ ██   ███ ██ ██      
     ██ ██      ██   ██ ██ ███ ██ ██  ██ ██     ██      ██    ██ ██    ██ ██ ██      
███████ ██      ██   ██  ███ ███  ██   ████     ███████  ██████   ██████  ██  ██████ 
*/

void function CreateFlags()
{	
	if ( IsValid( file.imcFlagSpawn ) )
	{
		file.imcFlagSpawn.Destroy()
		file.imcFlag.Destroy()
	}
	if ( IsValid( file.militiaFlagSpawn ) )
	{
		file.militiaFlagSpawn.Destroy()
		file.militiaFlag.Destroy()
	}

	foreach ( entity spawn in GetEntArrayByClass_Expensive( "info_spawnpoint_flag" ) )
	{
		bool switchedSides = HasSwitchedSides() == 1
		
		bool shouldSwap = switchedSides 
		if ( !shouldSwap && SWAP_FLAG_MAPS.contains( GetMapName() ) )
			shouldSwap = !shouldSwap

		int flagTeam = spawn.GetTeam()
		if ( shouldSwap )
		{
			flagTeam = GetOtherTeam( flagTeam )
			SetTeam( spawn, flagTeam )
		}
		
		entity base = CreatePropDynamic( CTF_FLAG_BASE_MODEL, spawn.GetOrigin(), spawn.GetAngles(), 0 )
		SetTeam( base, spawn.GetTeam() )
		svGlobal.flagSpawnPoints[ flagTeam ] = base
		
		entity flag = CreateEntity( "item_flag" )
		flag.SetValueForModelKey( CTF_FLAG_MODEL )
		SetTeam( flag, flagTeam )
		flag.MarkAsNonMovingAttachment()
		flag.Minimap_AlwaysShow( TEAM_IMC, null )
		flag.Minimap_AlwaysShow( TEAM_MILITIA, null )
		flag.Minimap_SetAlignUpright( true )
		DispatchSpawn( flag )
		flag.SetModel( CTF_FLAG_MODEL )
		flag.SetOrigin( spawn.GetOrigin() + < 0, 0, base.GetBoundingMaxs().z * 2 > )
		flag.SetVelocity( < 0, 0, 1 > )
		
		flag.s.canTake <- true
		
		level.teamFlags[ flag.GetTeam() ] <- flag
		
		thread FlagProximityTracker( flag )
			
		if ( flagTeam == TEAM_IMC )
		{
			file.imcFlagSpawn = base
			file.imcFlag = flag
			
			SetGlobalNetEnt( "imcFlag", file.imcFlag )
			SetGlobalNetEnt( "imcFlagHome", file.imcFlagSpawn )
		}
		else
		{
			file.militiaFlagSpawn = base
			file.militiaFlag = flag
			
			SetGlobalNetEnt( "milFlag", file.militiaFlag )
			SetGlobalNetEnt( "milFlagHome", file.militiaFlagSpawn )
		}
	}
	
	SetFlagStateForTeam( TEAM_MILITIA, eFlagState.None )
	SetFlagStateForTeam( TEAM_IMC, eFlagState.None )
}

void function RemoveFlags()
{
	if ( IsValid( file.imcFlagSpawn ) )
	{
		PlayFX( $"P_phase_shift_main", file.imcFlagSpawn.GetOrigin() )
		file.imcFlagSpawn.Destroy()
		file.imcFlag.Destroy()
	}
	
	if ( IsValid( file.militiaFlagSpawn ) )
	{
		PlayFX( $"P_phase_shift_main", file.militiaFlagSpawn.GetOrigin() )
		file.militiaFlagSpawn.Destroy()
		file.militiaFlag.Destroy()
	}
	
	SetFlagStateForTeam( TEAM_MILITIA, eFlagState.None )
	SetFlagStateForTeam( TEAM_IMC, eFlagState.None )
}

void function RateSpawnpoints_CTF( int checkClass, array<entity> spawnpoints, int team, entity player ) 
{
	vector allyFlagSpot
	vector enemyFlagSpot
	foreach ( entity spawn in GetEntArrayByClass_Expensive( "info_spawnpoint_flag" ) )
	{
		if( spawn.GetTeam() == team )
			allyFlagSpot = spawn.GetOrigin()
		else
			enemyFlagSpot = spawn.GetOrigin()
	}
	
	foreach ( entity spawn in spawnpoints )
	{
		float rating = 0.0
		float allyFlagDistance = Distance2D( spawn.GetOrigin(), allyFlagSpot )
		float enemyFlagDistance = Distance2D( spawn.GetOrigin(), enemyFlagSpot )
		
		if( enemyFlagDistance > allyFlagDistance )
		{
			rating += spawn.NearbyAllyScore( team, "ai" )
			rating += spawn.NearbyAllyScore( team, "titan" )
			rating += spawn.NearbyAllyScore( team, "pilot" )
			
			rating += spawn.NearbyEnemyScore( team, "ai" )
			rating += spawn.NearbyEnemyScore( team, "titan" )
			rating += spawn.NearbyEnemyScore( team, "pilot" )
		
			rating = rating / allyFlagDistance
		}

		if ( spawn == player.p.lastSpawnPoint )
			rating += GetConVarFloat( "spawnpoint_last_spawn_rating" )
		
		spawn.CalculateRating( checkClass, team, rating, rating * 0.25 )
	}
}

bool function VerifyCTFSpawnpoint( entity spawnpoint, int team )
{
	vector allyFlagSpot
	vector enemyFlagSpot
	foreach ( entity spawn in GetEntArrayByClass_Expensive( "info_spawnpoint_flag" ) )
	{
		if( spawn.GetTeam() == team )
			allyFlagSpot = spawn.GetOrigin()
		else
			enemyFlagSpot = spawn.GetOrigin()
	}
	
	if( Distance2D( spawnpoint.GetOrigin(), allyFlagSpot ) > Distance2D( spawnpoint.GetOrigin(), enemyFlagSpot ) )
		return false
	
	return true
}









/*
██████  ██       █████  ██    ██ ███████ ██████      ██       ██████   ██████  ██  ██████ 
██   ██ ██      ██   ██  ██  ██  ██      ██   ██     ██      ██    ██ ██       ██ ██      
██████  ██      ███████   ████   █████   ██████      ██      ██    ██ ██   ███ ██ ██      
██      ██      ██   ██    ██    ██      ██   ██     ██      ██    ██ ██    ██ ██ ██      
██      ███████ ██   ██    ██    ███████ ██   ██     ███████  ██████   ██████  ██  ██████ 
*/

void function OnPlaying()
{
	foreach ( entity player in GetPlayerArray() )
		CTFInitPlayer( player )
}

void function CTFInitPlayer( entity player )
{
	if ( !GamePlaying() )
		return
	
	if ( IsValid( file.imcFlagSpawn ) )
	{
		vector imcSpawn = file.imcFlagSpawn.GetOrigin()
		Remote_CallFunction_NonReplay( player, "ServerCallback_SetFlagHomeOrigin", TEAM_IMC, imcSpawn.x, imcSpawn.y, imcSpawn.z )
	}
	
	if ( IsValid( file.militiaFlagSpawn ) )
	{
		vector militiaSpawn = file.militiaFlagSpawn.GetOrigin()
		Remote_CallFunction_NonReplay( player, "ServerCallback_SetFlagHomeOrigin", TEAM_MILITIA, militiaSpawn.x, militiaSpawn.y, militiaSpawn.z )
	}
}

void function CTFPlayerDisconnected( entity player )
{
	// This has no validity checks on the player because the disconnection callback happens in the exact last frame the player entity still exists
	if( !GamePlaying() )
		return
	
	if ( PlayerHasEnemyFlag( player ) )
		DropFlag( player, false )
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( !IsValid( GetFlagForTeam( GetOtherTeam( victim.GetTeam() ) ) ) ) // getting a crash idk
		return
	
	if ( PlayerHasEnemyFlag( victim ) )
	{
		if ( victim != attacker && attacker.IsPlayer() )
			AddPlayerScore( attacker, "FlagCarrierKill", victim )
		
		DropFlag( victim )
	}
}











/*
███████ ██       █████   ██████      ██       ██████   ██████  ██  ██████ 
██      ██      ██   ██ ██           ██      ██    ██ ██       ██ ██      
█████   ██      ███████ ██   ███     ██      ██    ██ ██   ███ ██ ██      
██      ██      ██   ██ ██    ██     ██      ██    ██ ██    ██ ██ ██      
██      ███████ ██   ██  ██████      ███████  ██████   ██████  ██  ██████ 
*/

bool function OnFlagCollected( entity player, entity flag )
{
	if ( !IsAlive( player ) || flag.GetParent() != null || player.IsTitan() || player.IsPhaseShifted() ) 
		return false

	if ( player.GetTeam() != flag.GetTeam() && flag.s.canTake )
		GiveFlag( player, flag )
	else if ( player.GetTeam() == flag.GetTeam() && IsFlagHome( flag ) && PlayerHasEnemyFlag( player ) )
		CaptureFlag( player, GetFlagForTeam( GetOtherTeam( flag.GetTeam() ) ) )

	return false // Don't delete the flag
}

void function GiveFlag( entity player, entity flag )
{
	print( player + " picked up the flag!" )
	flag.Signal( "ResetDropTimeout" )

	flag.SetParent( player, "FLAG" )
	if ( GetCurrentPlaylistVarInt( "phase_shift_drop_flag", 0 ) == 1 )
		thread DropFlagIfPhased( player, flag )

	// do notifications
	MessageToPlayer( player, eEventNotifications.YouHaveTheEnemyFlag )
	EmitSoundOnEntityOnlyToPlayer( player, player, "UI_CTF_1P_GrabFlag" )
	AddPlayerScore( player, "FlagTaken", player )
	PlayFactionDialogueToPlayer( "ctf_flagPickupYou", player )
	
	MessageToTeam( player.GetTeam(), eEventNotifications.PlayerHasEnemyFlag, player, player )
	EmitSoundOnEntityToTeamExceptPlayer( flag, "UI_CTF_3P_TeamGrabFlag", player.GetTeam(), player )
	PlayFactionDialogueToTeamExceptPlayer( "ctf_flagPickupFriendly", player.GetTeam(), player )
	
	MessageToTeam( flag.GetTeam(), eEventNotifications.PlayerHasFriendlyFlag, player, player )
	EmitSoundOnEntityToTeam( flag, "UI_CTF_3P_EnemyGrabFlag", flag.GetTeam() )
	
	SetFlagStateForTeam( flag.GetTeam(), eFlagState.Away ) // used for held
}

void function CaptureFlag( entity player, entity flag )
{
	// can only capture flags during normal play or sudden death
	if ( GetGameState() != eGameState.Playing && GetGameState() != eGameState.SuddenDeath )
	{
		printt( player + " tried to capture the flag, but the game state was " + GetGameState() + " not " + eGameState.Playing + " or " + eGameState.SuddenDeath)
		return
	}
	// reset flag
	ResetFlag( flag )
	
	print( player + " captured the flag!" )
	
	// score
	int team = player.GetTeam() 
	AddTeamScore( team, 1 )
	AddPlayerScore( player, "FlagCapture", player )
	player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, 1 ) // add 1 to captures on scoreboard
	SetRoundWinningKillReplayAttacker( player ) // set attacker for last cap replay
	
	array<entity> assistList
	if ( player.GetTeam() == TEAM_IMC )
		assistList = file.imcCaptureAssistList
	else
		assistList = file.militiaCaptureAssistList
	
	foreach( entity assistPlayer in assistList )
	{
		if ( IsValidPlayer( assistPlayer ) )
		{
			if ( player != assistPlayer )
				AddPlayerScore( assistPlayer, "FlagCaptureAssist", player )
			if( !HasPlayerCompletedMeritScore( assistPlayer ) )
			{
				AddPlayerScore( assistPlayer, "ChallengeCTFCapAssist" )
				SetPlayerChallengeMeritScore( assistPlayer )
			}
		}
	}
		
	assistList.clear()

	// notifs
	MessageToPlayer( player, eEventNotifications.YouCapturedTheEnemyFlag )
	EmitSoundOnEntityOnlyToPlayer( player, player, "UI_CTF_1P_PlayerScore" )
	
	if( !HasPlayerCompletedMeritScore( player ) )
		SetPlayerChallengeMeritScore( player )
	
	MessageToTeam( team, eEventNotifications.PlayerCapturedEnemyFlag, player, player )
	EmitSoundOnEntityToTeamExceptPlayer( flag, "UI_CTF_3P_TeamScore", player.GetTeam(), player )
	
	MessageToTeam( GetOtherTeam( team ), eEventNotifications.PlayerCapturedFriendlyFlag, player, player )
	EmitSoundOnEntityToTeam( flag, "UI_CTF_3P_EnemyScores", flag.GetTeam() )
	
	if ( GameRules_GetTeamScore( team ) == GetScoreLimit_FromPlaylist() - 1 )
	{
		PlayFactionDialogueToTeam( "ctf_notifyWin1more", team )
		PlayFactionDialogueToTeam( "ctf_notifyLose1more", GetOtherTeam( team ) )
		foreach( entity otherPlayer in GetPlayerArray() )
			Remote_CallFunction_NonReplay( otherPlayer, "ServerCallback_CTF_PlayMatchNearEndMusic" )
	}
}

void function DropFlag( entity player, bool realDrop = true )
{
	entity flag = GetFlagForTeam( GetOtherTeam( player.GetTeam() ) )
	
	if( !IsValid( flag ) || flag.GetParent() != player )
		return
		
	print( player + " dropped the flag!" )
	
	flag.ClearParent()
	flag.SetAngles( < 0, 0, 0 > )
	flag.SetVelocity( < 0, 0, 0 > )
	
	if ( realDrop )
	{
		if ( player.GetTeam() == TEAM_IMC && !file.imcCaptureAssistList.contains( player ) )
			file.imcCaptureAssistList.append( player )
		
		else if( !file.militiaCaptureAssistList.contains( player ) )
			file.militiaCaptureAssistList.append( player )

		MessageToPlayer( player, eEventNotifications.YouDroppedTheEnemyFlag )
		EmitSoundOnEntityOnlyToPlayer( player, player, "UI_CTF_1P_FlagDrop" )

		MessageToTeam( player.GetTeam(), eEventNotifications.PlayerDroppedEnemyFlag, player, player )
		MessageToTeam( GetOtherTeam( player.GetTeam() ), eEventNotifications.PlayerDroppedFriendlyFlag, player, player )
	}
	
	thread TrackFlagDropTimeout( flag )
	SetFlagStateForTeam( flag.GetTeam(), eFlagState.Home )
}

void function ResetFlag( entity flag )
{
	flag.s.canTake = false
	
	if ( flag.GetParent() != null )
		DropFlag( flag.GetParent(), false )
	
	entity flagBase
	if ( flag.GetTeam() == TEAM_IMC )
		flagBase = file.imcFlagSpawn
	else
		flagBase = file.militiaFlagSpawn
		
	flag.SetOrigin( flagBase.GetOrigin() + < 0, 0, flagBase.GetBoundingMaxs().z + 1 > )
	
	flag.s.canTake = true
	
	SetFlagStateForTeam( flag.GetTeam(), eFlagState.None )
	
	flag.Signal( "ResetDropTimeout" )
}

//-----------------------------------------------------------------------------
// Purpose: Check proximity for flag returns
// Input  : flag - The flag entity
//-----------------------------------------------------------------------------
void function FlagProximityTracker( entity flag )
{
	flag.EndSignal( "OnDestroy" )
	
	array < entity > playerInsidePerimeter
	while( true )
	{
		if( !playerInsidePerimeter.len() )
			ArrayRemoveDead( playerInsidePerimeter )
		
		foreach ( player in GetPlayerArrayOfTeam_Alive( flag.GetTeam() ) )
		{
			if ( Distance( player.GetOrigin(), flag.GetOrigin() ) < CTF_GetFlagReturnRadius() )
			{
				if ( player.IsTitan() || player.GetTeam() != flag.GetTeam() || IsFlagHome( flag ) || flag.GetParent() != null )
					continue
				
				if( playerInsidePerimeter.contains( player ) )
					continue
				
				playerInsidePerimeter.append( player )
				thread TryReturnFlag( player, flag )
			}
			else
			{
				if( playerInsidePerimeter.contains( player ) )
				{
					player.Signal( "CTF_LeftReturnTriggerArea" ) // Cut the progress if outside range
					playerInsidePerimeter.removebyvalue( player )
				}
			}
		}
		
		WaitFrame()
	}
}

void function TryReturnFlag( entity player, entity flag )
{
	Remote_CallFunction_NonReplay( player, "ServerCallback_CTF_StartReturnFlagProgressBar", Time() + CTF_GetFlagReturnTime() )
	EmitSoundOnEntityOnlyToPlayer( player, player, "UI_CTF_1P_FlagReturnMeter" )
	
	OnThreadEnd( function() : ( flag, player )
	{
		if ( IsValidPlayer( player ) )
		{
			Remote_CallFunction_NonReplay( player, "ServerCallback_CTF_StopReturnFlagProgressBar" )
			StopSoundOnEntity( player, "UI_CTF_1P_FlagReturnMeter" )
		}
	})
	
	flag.EndSignal( "CTF_ReturnedFlag" )
	flag.EndSignal( "OnDestroy" )
	
	player.EndSignal( "CTF_LeftReturnTriggerArea" )
	player.EndSignal( "OnDeath" )
	player.EndSignal( "OnDestroy" )
	
	wait CTF_GetFlagReturnTime()
	
	ResetFlag( flag )
	
	MessageToTeam( flag.GetTeam(), eEventNotifications.PlayerReturnedFriendlyFlag, null, player )
	EmitSoundOnEntityToTeam( flag, "UI_CTF_3P_TeamReturnsFlag", flag.GetTeam() )
	PlayFactionDialogueToTeam( "ctf_flagReturnedFriendly", flag.GetTeam() )
	
	MessageToPlayer( player, eEventNotifications.YouReturnedFriendlyFlag )
	AddPlayerScore( player, "FlagReturn", player )
	player.AddToPlayerGameStat( PGS_DEFENSE_SCORE, 1 )
	
	if ( !HasPlayerCompletedMeritScore( player ) )
	{
		AddPlayerScore( player, "ChallengeCTFRetAssist" )
		SetPlayerChallengeMeritScore( player )
	}
	
	MessageToTeam( GetOtherTeam( flag.GetTeam() ), eEventNotifications.PlayerReturnedEnemyFlag, null, player )
	EmitSoundOnEntityToTeam( flag, "UI_CTF_3P_EnemyReturnsFlag", GetOtherTeam( flag.GetTeam() ) )
	EmitSoundOnEntityOnlyToPlayer( player, player, "UI_CTF_1P_ReturnsFlag" )
	PlayFactionDialogueToTeam( "ctf_flagReturnedEnemy", GetOtherTeam( flag.GetTeam() ) )
	
	flag.Signal( "CTF_ReturnedFlag" )
}

void function SetFlagStateForTeam( int team, int state )
{
	if ( state == eFlagState.Away ) // we tell the client the flag is the player carrying it if they're carrying it
		SetGlobalNetEnt( team == TEAM_IMC ? "imcFlag" : "milFlag", ( team == TEAM_IMC ? file.imcFlag : file.militiaFlag ).GetParent() )
	else
		SetGlobalNetEnt( team == TEAM_IMC ? "imcFlag" : "milFlag", team == TEAM_IMC ? file.imcFlag : file.militiaFlag )

	SetGlobalNetInt( team == TEAM_IMC ? "imcFlagState" : "milFlagState", state )
}

void function DropFlagIfPhased( entity player, entity flag )
{
	player.EndSignal( "StartPhaseShift" )
	player.EndSignal( "OnDestroy" )
	flag.EndSignal( "OnDestroy" )
	
	OnThreadEnd( function() : ( player ) 
	{
		if ( IsValidPlayer( player ) )
		{
			if ( GetGameState() == eGameState.Playing || GetGameState() == eGameState.SuddenDeath )
				DropFlag( player, true )
		}
	})

	while( flag.GetParent() == player )
		WaitFrame()
}

void function DropFlagForBecomingTitan( entity pilot, entity titan )
{
	DropFlag( pilot, true )
}

void function TrackFlagDropTimeout( entity flag )
{
	flag.EndSignal( "CTF_ReturnedFlag" )
	flag.EndSignal( "ResetDropTimeout" )
	flag.EndSignal( "OnDestroy" )
	
	wait CTF_GetDropTimeout()
	
	ResetFlag( flag )
}
