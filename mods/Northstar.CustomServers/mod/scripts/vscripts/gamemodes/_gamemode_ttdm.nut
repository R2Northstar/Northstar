global function GamemodeTTDM_Init

const float TTDMIntroLength = 15.0

struct
{
	table< entity, int > challengeCount
} file

void function GamemodeTTDM_Init()
{
	Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Always )
	Riff_ForceTitanExitEnabled( eTitanExitEnabled.Never )
	TrackTitanDamageInPlayerGameStat( PGS_ASSAULT_SCORE )
	ScoreEvent_SetupEarnMeterValuesForMixedModes()
	SetLoadoutGracePeriodEnabled( false )

	ClassicMP_SetCustomIntro( TTDMIntroSetup, TTDMIntroLength )
	ClassicMP_ForceDisableEpilogue( true )
	SetTimeoutWinnerDecisionFunc( CheckScoreForDraw )

	AddCallback_OnClientConnected( SetupPlayerTTDMChallenges ) //Just to make up the Match Goals tracking
	AddCallback_OnClientDisconnected( RemovePlayerTTDMChallenges ) //Safety removal of data to prevent crashes
	AddCallback_OnPlayerKilled( AddTeamScoreForPlayerKilled ) // dont have to track autotitan kills since you cant leave your titan in this mode

	// probably needs scoreevent earnmeter values
}

void function TTDMIntroSetup()
{
	// this should show intermission cam for 15 sec in prematch, before spawning players as titans
	AddCallback_GameStateEnter( eGameState.Prematch, TTDMIntroStart )
	AddCallback_OnClientConnected( TTDMIntroShowIntermissionCam )
}

void function TTDMIntroStart()
{
	thread TTDMIntroStartThreaded()
}

void function TTDMIntroStartThreaded()
{
	ClassicMP_OnIntroStarted()

	foreach ( entity player in GetPlayerArray() )
	{
		if ( !IsPrivateMatchSpectator( player ) )
			TTDMIntroShowIntermissionCam( player )
		else
			RespawnPrivateMatchSpectator( player )
	}

	wait TTDMIntroLength

	ClassicMP_OnIntroFinished()
}

void function TTDMIntroShowIntermissionCam( entity player )
{
	if ( GetGameState() != eGameState.Prematch )
		return

	thread PlayerWatchesTTDMIntroIntermissionCam( player )
}

void function SetupPlayerTTDMChallenges( entity player )
{
	file.challengeCount[ player ] <- 0
}

void function RemovePlayerTTDMChallenges( entity player )
{
	if( player in file.challengeCount )
		delete file.challengeCount[ player ]
}

void function PlayerWatchesTTDMIntroIntermissionCam( entity player )
{
	player.EndSignal( "OnDestroy" )
	ScreenFadeFromBlack( player )

	entity intermissionCam = GetEntArrayByClass_Expensive( "info_intermission" )[ 0 ]

	// the angle set here seems sorta inconsistent as to whether it actually works or just stays at 0 for some reason
	player.SetObserverModeStaticPosition( intermissionCam.GetOrigin() )
	player.SetObserverModeStaticAngles( intermissionCam.GetAngles() )
	player.StartObserverMode( OBS_MODE_STATIC_LOCKED )

	wait TTDMIntroLength

	RespawnAsTitan( player, false )
	TryGameModeAnnouncement( player )
}

void function AddTeamScoreForPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( victim == attacker || !victim.IsPlayer() || !attacker.IsPlayer() && GetGameState() == eGameState.Playing )
		return

	if( victim in file.challengeCount )
		file.challengeCount[victim] = 0
	
	if( attacker in file.challengeCount )
	{
		file.challengeCount[attacker]++
		if( file.challengeCount[attacker] >= 2 && !HasPlayerCompletedMeritScore( attacker ) )
		{
			AddPlayerScore( attacker, "ChallengeTTDM" )
			SetPlayerChallengeMeritScore( attacker )
		}
	}

	AddTeamScore( GetOtherTeam( victim.GetTeam() ), 1 )
}

int function CheckScoreForDraw()
{
	if (GameRules_GetTeamScore(TEAM_IMC) > GameRules_GetTeamScore(TEAM_MILITIA))
		return TEAM_IMC
	else if (GameRules_GetTeamScore(TEAM_MILITIA) > GameRules_GetTeamScore(TEAM_IMC))
		return TEAM_MILITIA

	return TEAM_UNASSIGNED
}
