global function GamemodePs_Init

void function GamemodePs_Init()
{
	AddCallback_OnPlayerKilled( GiveScoreForPlayerKill )
}

void function GiveScoreForPlayerKill( entity victim, entity attacker, var damageInfo )
{
	if ( victim != attacker && victim.IsPlayer() && attacker.IsPlayer() )
		AddTeamScore( attacker.GetTeam(), 1 )
}