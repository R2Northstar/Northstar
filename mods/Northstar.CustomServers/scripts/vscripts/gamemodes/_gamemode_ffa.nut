global function FFA_Init

void function FFA_Init()
{
	Evac_SetEnabled( false )

	AddCallback_OnPlayerKilled( OnPlayerKilled )
}

void function OnPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	if ( victim != attacker && victim.IsPlayer() && attacker.IsPlayer() && GetGameState() == eGameState.Playing )
	{
		AddTeamScore( attacker.GetTeam(), 1 )
		attacker.AddToPlayerGameStat( PGS_SCORE, 1 )
	}
}