untyped
global function GamemodeLts_Init

struct {
	entity lastDamageInfoVictim
	entity lastDamageInfoAttacker
	int lastDamageInfoMethodOfDeath
	float lastDamageInfoTime
	
	bool shouldDoHighlights
} file

void function GamemodeLts_Init()
{
	// gamemode settings
	SetShouldUsePickLoadoutScreen( true )
	SetSwitchSidesBased( true )
	SetRoundBased( true )
	SetRespawnsEnabled( false )
	Riff_ForceSetEliminationMode( eEliminationMode.PilotsTitans )
	Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Always )
	SetShouldUseRoundWinningKillReplay( true )
	SetRoundWinningKillReplayKillClasses( true, true ) // both titan and pilot kills are tracked
	ScoreEvent_SetupEarnMeterValuesForTitanModes()
	SetLoadoutGracePeriodEnabled( false )
	FlagSet( "ForceStartSpawn" )

	AddCallback_OnPilotBecomesTitan( RefreshThirtySecondWallhackHighlight )
	AddCallback_OnTitanBecomesPilot( RefreshThirtySecondWallhackHighlight )
	
	SetTimeoutWinnerDecisionFunc( CheckTitanHealthForDraw )
	TrackTitanDamageInPlayerGameStat( PGS_ASSAULT_SCORE )
	
	ClassicMP_SetCustomIntro( ClassicMP_DefaultNoIntro_Setup, ClassicMP_DefaultNoIntro_GetLength() )
	ClassicMP_ForceDisableEpilogue( true )
	AddCallback_GameStateEnter( eGameState.Playing, WaitForThirtySecondsLeft )
}

void function WaitForThirtySecondsLeft()
{
	thread WaitForThirtySecondsLeftThreaded()
}

void function WaitForThirtySecondsLeftThreaded()
{
	svGlobal.levelEnt.EndSignal( "RoundEnd" ) // end this on round end
	
	float endTime = expect float ( GetServerVar( "roundEndTime" ) )
	
	// wait until 30sec left 
	wait ( endTime - 30 ) - Time()
	PlayMusicToAll( eMusicPieceID.LEVEL_LAST_MINUTE )
	
	foreach ( entity player in GetPlayerArray() )
	{	
		// warn there's 30 seconds left
		Remote_CallFunction_NonReplay( player, "ServerCallback_LTSThirtySecondWarning" )
		
		// do initial highlight
		RefreshThirtySecondWallhackHighlight( player, null )
	}
}

void function RefreshThirtySecondWallhackHighlight( entity player, entity titan )
{
	if ( TimeSpentInCurrentState() < expect float ( GetServerVar( "roundEndTime" ) ) - 30.0 )
		return
		
	Highlight_SetEnemyHighlight( player, "enemy_sonar" ) // i think this needs a different effect, this works for now tho
		
	if ( player.GetPetTitan() != null )
		Highlight_SetEnemyHighlight( player.GetPetTitan(), "enemy_sonar" )
}

int function CheckTitanHealthForDraw()
{
	int militiaTitans
	int imcTitans
	
	float militiaHealth
	float imcHealth
	
	foreach ( entity titan in GetTitanArray() )
	{
		if ( titan.GetTeam() == TEAM_MILITIA )
		{
			// doomed is counted as 0 health
			militiaHealth += titan.GetTitanSoul().IsDoomed() ? 0.0 : GetHealthFrac( titan )
			militiaTitans++
		}
		else
		{
			// doomed is counted as 0 health in this
			imcHealth += titan.GetTitanSoul().IsDoomed() ? 0.0 : GetHealthFrac( titan )
			imcTitans++
		}
	}
	
	// note: due to how stuff is set up rn, there's actually no way to do win/loss reasons outside of a SetWinner call, i.e. not in timeout winner decision
	// as soon as there is, strings in question are "#GAMEMODE_TITAN_TITAN_ADVANTAGE" and "#GAMEMODE_TITAN_TITAN_DISADVANTAGE"
	
	if ( militiaTitans != imcTitans )
		return militiaTitans > imcTitans ? TEAM_MILITIA : TEAM_IMC
	else if ( militiaHealth != imcHealth )
		return militiaHealth > imcHealth ? TEAM_MILITIA : TEAM_IMC
		
	return TEAM_UNASSIGNED
}