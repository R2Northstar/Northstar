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
	SetServerVar( "roundWinningKillReplayEnabled", true ) // really ought to get a function for setting this

	AddCallback_OnPlayerKilled( OnPlayerKilled )
	AddDeathCallback( "npc_titan", OnTitanKilled )
	
	AddDamageCallback( "player", OnPlayerDamaged )
	AddDamageCallback( "npc_titan", OnTitanDamaged )
	
	AddCallback_OnPilotBecomesTitan( GamemodeLTS_RefreshHighlight )
	AddCallback_OnTitanBecomesPilot( GamemodeLTS_RefreshHighlight )
	
	ClassicMP_SetCustomIntro( GamemodeLTS_Intro, 0.0 )
}

void function GamemodeLTS_Intro()
{
	AddCallback_GameStateEnter( eGameState.Prematch, GamemodeLTS_IntroOnPrematchStart )
}

void function GamemodeLTS_IntroOnPrematchStart()
{
	ClassicMP_OnIntroStarted()
	
	SetGameState( eGameState.Playing )
	foreach ( entity player in GetPlayerArray() )
		thread GamemodeLTS_IntroSpawnPlayer( player )
	
	ClassicMP_OnIntroFinished()
	
	SetKillcamsEnabled( true )
	file.shouldDoHighlights = false
	thread GamemodeLTS_PlayingThink()
}

void function GamemodeLTS_IntroSpawnPlayer( entity player )
{
	if ( IsAlive( player ) )
	{
		player.Die()
		WaitFrame()
	}
	
	RespawnAsTitan( player, false )

	while ( !player.IsTitan() )
		WaitFrame()
		
	TryGameModeAnnouncement( player )
}

void function GamemodeLTS_PlayingThink()
{
	WaitFrame() // due to how this is all written the prematch callbacks might not've run by the time this starts
	// so we need to wait a frame to ensure they've been run so gameEndTime is set
	svGlobal.levelEnt.EndSignal( "RoundEnd" ) // end this on round end
	
	float endTime = expect float ( GetServerVar( "gameEndTime" ) )
	print( "ENDTIME " + endTime )
	
	// wait until 30sec left 
	wait endTime - 30 - Time()
	foreach ( entity player in GetPlayerArray() )
	{	
		// warn there's 30 seconds left
		Remote_CallFunction_NonReplay( player, "ServerCallback_LTSThirtySecondWarning" )
		
		// do highlights
		file.shouldDoHighlights = true
		GamemodeLTS_RefreshHighlight( player, null )
	}
	
	wait endTime - Time()
	thread CheckTitansForDraw() // need to thread this so we don't accidentally signal roundend in the same thread that'll be ended when we hit roundend
}

void function GamemodeLTS_RefreshHighlight( entity player, entity titan )
{
	if ( !file.shouldDoHighlights )
		return
		
	Highlight_SetEnemyHighlight( player, "enemy_sonar" ) // i think this needs a different effect, this works for now tho
		
	if ( player.GetPetTitan() != null )
		Highlight_SetEnemyHighlight( player.GetPetTitan(), "enemy_sonar" )
}

void function CheckTeamTitans( int team )
{
	if ( GetGameState() != eGameState.Playing )
		return

	array<entity> teamPlayers = GetPlayerArrayOfTeam( team )
	
	int numLivingTitans = 0
	int numLivingPlayers = 0
	foreach ( entity player in teamPlayers )
	{
		// wouldn't it be easier just to only track and increment numLivingTitans if the owner is alive?
		// yes it would
		// but for some reason this is not how respawn does it
		if ( IsAlive( player ) )
			numLivingPlayers++
	
		if ( IsAlive( player.GetPetTitan() ) || player.IsTitan() )
			numLivingTitans++
	}
			
	if ( numLivingPlayers == 0 || numLivingTitans == 0 )
	{
		SetKillcamsEnabled( false ) // make sure killcams can't interrupt the round winning kill replay
		//SetRoundWinningKillReplayInfo( file.lastDamageInfoVictim, file.lastDamageInfoAttacker, file.lastDamageInfoMethodOfDeath, file.lastDamageInfoTime )
		SetWinner( GetOtherTeam( team ), "#GAMEMODE_ENEMY_TITANS_DESTROYED", "#GAMEMODE_FRIENDLY_TITANS_DESTROYED" ) 
	}
}

void function CheckTitansForDraw()
{
	int militiaLivingTitans
	int imcLivingTitans
	
	float militiaCombinedHealth
	float imcCombinedHealth

	foreach ( entity player in GetPlayerArray() )
	{
		// only need to track titans for this, can assume that neither team has lost due to titan death if the round is still going
		entity titan = IsAlive( player.GetPetTitan() ) ? player.GetPetTitan() : player
		if ( titan.IsPlayer() && !titan.IsTitan() )
			continue
		
		if ( IsAlive( titan ) )
			if ( player.GetTeam() == TEAM_MILITIA )
			{
				// doomed is counted as 0 health in this
				militiaCombinedHealth += titan.GetTitanSoul().IsDoomed() ? 0.0 : GetHealthFrac( titan )
				militiaLivingTitans++
			}
			else
			{
				// doomed is counted as 0 health in this
				imcCombinedHealth += titan.GetTitanSoul().IsDoomed() ? 0.0 : GetHealthFrac( titan )
				imcLivingTitans++
			}
	}
	
	SetKillcamsEnabled( false )
	//SetRoundWinningKillReplayInfo( null, null, 0, 0 ) // make sure we don't do a replay
	
	// default if both teams are equal
	int winner = TEAM_UNASSIGNED
	
	string winnerSubstr
	string loserSubstr
	
	if ( militiaLivingTitans != imcLivingTitans ) // one team has a titan lead
	{
		winnerSubstr = "#GAMEMODE_TITAN_TITAN_ADVANTAGE"
		loserSubstr = "#GAMEMODE_TITAN_TITAN_DISADVANTAGE"
		
		winner =  militiaLivingTitans > imcLivingTitans ? TEAM_MILITIA : TEAM_IMC
	}
	else if ( militiaCombinedHealth != imcCombinedHealth ) // one team has a health lead
	{
		winnerSubstr = "#GAMEMODE_TITAN_DAMAGE_ADVANTAGE"
		loserSubstr = "#GAMEMODE_TITAN_DAMAGE_DISADVANTAGE"

		winner = militiaCombinedHealth > imcCombinedHealth ? TEAM_MILITIA : TEAM_IMC
	}
	
	print( "CheckTitansForDraw(): " + winner )
	SetWinner( winner, winnerSubstr, loserSubstr )
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	file.lastDamageInfoVictim = victim
	file.lastDamageInfoAttacker = DamageInfo_GetAttacker( damageInfo )
	file.lastDamageInfoMethodOfDeath = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	file.lastDamageInfoTime = Time()
	
	if ( !victim.isSpawning )
		CheckTeamTitans( victim.GetTeam() )
}

void function OnTitanKilled( entity titan, var damageInfo )
{
	file.lastDamageInfoVictim = titan.GetOwner()
	file.lastDamageInfoAttacker = DamageInfo_GetAttacker( damageInfo )
	file.lastDamageInfoMethodOfDeath = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	file.lastDamageInfoTime = Time()
	
	if ( IsPetTitan( titan ) && !titan.GetBossPlayer().isSpawning )
		CheckTeamTitans( titan.GetTeam() )
}

void function AddToDamageStat( var damageInfo )
{
	// todo: this needs to not count selfdamage
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	float amount = DamageInfo_GetDamage( damageInfo )

	if ( attacker.IsPlayer() )
		attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, amount ) // titan damage on 
}

void function OnPlayerDamaged( entity player, var damageInfo )
{
	if ( player.IsTitan() )
		AddToDamageStat( damageInfo )
}

void function OnTitanDamaged( entity titan, var damageInfo )
{
	if ( IsPetTitan( titan ) )
		AddToDamageStat( damageInfo ) 
}