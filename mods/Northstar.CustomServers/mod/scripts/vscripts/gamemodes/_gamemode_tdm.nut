global function GamemodeTdm_Init
global function RateSpawnpoints_Directional

void function GamemodeTdm_Init()
{
	AddCallback_OnPlayerKilled( GiveScoreForPlayerKill )
	ScoreEvent_SetupEarnMeterValuesForMixedModes()
}

void function GiveScoreForPlayerKill( entity victim, entity attacker, var damageInfo )
{
	if ( victim != attacker && victim.IsPlayer() && attacker.IsPlayer() )
		AddTeamScore( attacker.GetTeam(), 1 )
}

void function RateSpawnpoints_Directional( int checkclass, array<entity> spawnpoints, int team, entity player )
{
	// temp
	RateSpawnpoints_Generic( checkclass, spawnpoints, team, player )
}