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
	SetRoundBased( true )
	SetRespawnsEnabled( false )
	Riff_ForceSetEliminationMode( eEliminationMode.PilotsTitans )
	SetShouldUseRoundWinningKillReplay( true )
	SetRoundWinningKillReplayKillClasses( true, true ) // both titan and pilot kills are tracked
	
	AddDamageCallback( "player", OnPlayerDamaged )
	AddDamageCallback( "npc_titan", OnTitanDamaged )
	
	AddCallback_OnPilotBecomesTitan( RefreshThirtySecondWallhackHighlight )
	AddCallback_OnTitanBecomesPilot( RefreshThirtySecondWallhackHighlight )
	
	SetTimeoutWinnerDecisionFunc( CheckTitanHealthForDraw )
	
	ClassicMP_SetCustomIntro( GamemodeLTS_Intro, 0.0 ) // dont any sorta 
}

// this should also probably be moved into a generic intro rather than being lts-specific
void function GamemodeLTS_Intro()
{
	AddCallback_GameStateEnter( eGameState.Prematch, LTSIntroOnPrematchStart )
}

void function LTSIntroOnPrematchStart()
{
	ClassicMP_OnIntroStarted()

	foreach ( entity player in GetPlayerArray() )
		thread LTSIntroSpawnPlayer( player )
	
	wait 2.0 // literally a guess number for how long the drop might take
	
	ClassicMP_OnIntroFinished()
	
	thread GamemodeLTS_PlayingThink()
}

void function LTSIntroSpawnPlayer( entity player )
{
	if ( IsAlive( player ) )
	{
		player.Die()
		WaitFrame() // this doesn't work for some reason but the player will die in roundend anyway so not really an issue
	}

	thread RespawnAsTitan( player, false )

	while ( !player.IsTitan() )
		WaitFrame()
		
	TryGameModeAnnouncement( player )
}

void function GamemodeLTS_PlayingThink()
{
	svGlobal.levelEnt.EndSignal( "RoundEnd" ) // end this on round end
	
	float endTime = expect float ( GetServerVar( "gameEndTime" ) )
	
	// wait until 30sec left 
	wait endTime - 30 - Time()
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
	if ( TimeSpentInCurrentState() < 30.0 )
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
	
	// note: due to how stuff is set up rn, there's actually no way to do win/loss reasons in timeout decision funcs
	// as soon as there is, strings in question are "#GAMEMODE_TITAN_TITAN_ADVANTAGE" and "#GAMEMODE_TITAN_TITAN_DISADVANTAGE"
	
	if ( militiaTitans != imcTitans )
		return militiaTitans > imcTitans ? TEAM_MILITIA : TEAM_IMC
	else if ( militiaHealth != imcHealth )
		return militiaHealth > imcHealth ? TEAM_MILITIA : TEAM_IMC
		
	return TEAM_UNASSIGNED
}

// this should be generic, not restricted to a specific gamemode
void function AddToTitanDamageStat( entity victim, var damageInfo )
{
	// todo: this needs to not count selfdamage
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	float amount = DamageInfo_GetDamage( damageInfo )

	if ( attacker.IsPlayer() && attacker != victim )
		attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, amount ) // titan damage on 
}

void function OnPlayerDamaged( entity player, var damageInfo )
{
	if ( player.IsTitan() )
		AddToTitanDamageStat( player, damageInfo )
}

void function OnTitanDamaged( entity titan, var damageInfo )
{
	AddToTitanDamageStat( titan, damageInfo ) 
}