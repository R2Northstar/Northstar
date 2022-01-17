global function GamemodeTdm_Init
global function RateSpawnpoints_Directional

void function GamemodeTdm_Init()
{
	AddCallback_OnPlayerKilled( GiveScoreForPlayerKill )
	ScoreEvent_SetupEarnMeterValuesForMixedModes()
	SetTimeoutWinnerDecisionFunc( CheckScoreForDraw )
}

void function GiveScoreForPlayerKill( entity victim, entity attacker, var damageInfo )
{
	if ( victim != attacker && victim.IsPlayer() && attacker.IsPlayer() && GetGameState() == eGameState.Playing )
		AddTeamScore( attacker.GetTeam(), 1 )

	table<int, bool> alreadyAssisted
	foreach( DamageHistoryStruct attackerInfo in victim.e.recentDamageHistory )
	{
		bool exists = attackerInfo.attacker.GetEncodedEHandle() in alreadyAssisted ? true : false
		if( attackerInfo.attacker != attacker && !exists )
		{
			alreadyAssisted[attackerInfo.attacker.GetEncodedEHandle()] <- true
			attackerInfo.attacker.AddToPlayerGameStat( PGS_ASSISTS, 1 )
		}
	}
		// 	try 
		// {
		// 	if( attackerInfo.attacker != attacker && !alreadyAssisted[attackerInfo.attacker.GetEncodedEHandle()] )
		// 	{
		// 		alreadyAssisted[attackerInfo.attacker.GetEncodedEHandle()] <- true
		// 		attackerInfo.attacker.AddToPlayerGameStat( PGS_ASSISTS, 1 )
		// 	}
		// } catch ( ex )
		// print( "Exception found in assist, ignoring: " + ex)
}

void function RateSpawnpoints_Directional( int checkclass, array<entity> spawnpoints, int team, entity player )
{
	// temp
	RateSpawnpoints_Generic( checkclass, spawnpoints, team, player )
}

int function CheckScoreForDraw()
{
	if ( GameRules_GetTeamScore( TEAM_IMC ) > GameRules_GetTeamScore( TEAM_MILITIA ) )
		return TEAM_IMC
	else if ( GameRules_GetTeamScore( TEAM_MILITIA ) > GameRules_GetTeamScore( TEAM_IMC ) )
		return TEAM_MILITIA

	return TEAM_UNASSIGNED
}
