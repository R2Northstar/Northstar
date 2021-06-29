global function CodeCallback_MapInit

void function CodeCallback_MapInit()
{
	// there are some really busted titan startspawns that are on the fucking other side of the map from where they should be, so we remove them
	AddSpawnCallback( "info_spawnpoint_titan_start", TrimBadTitanStartSpawns )
}

void function TrimBadTitanStartSpawns( entity spawn )
{
	vector comparisonOrigin
	if ( spawn.GetTeam() == TEAM_IMC )
		comparisonOrigin = < 160.625, 4748.13, -251.447 >
	else
		comparisonOrigin = < 1087.13, -4914.88, -199.969 >

	if ( Distance2D( spawn.GetOrigin(), comparisonOrigin ) >= 1000.0)
		spawn.Destroy()
}