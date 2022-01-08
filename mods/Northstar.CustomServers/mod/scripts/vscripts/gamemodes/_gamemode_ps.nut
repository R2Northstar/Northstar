untyped
global function GamemodePs_Init
global function RateSpawnpoints_SpawnZones

struct {
	array<entity> spawnzones
	
	entity militiaActiveSpawnZone
	entity imcActiveSpawnZone
	
	array<entity> militiaPreviousSpawnZones
	array<entity> imcPreviousSpawnZones
} file

void function GamemodePs_Init()
{
	Riff_ForceTitanAvailability( eTitanAvailability.Never )

	AddCallback_OnPlayerKilled( GiveScoreForPlayerKill )
	ScoreEvent_SetupEarnMeterValuesForMixedModes()
	SetTimeoutWinnerDecisionFunc( CheckScoreForDraw )

	// spawnzone stuff
	AddCallback_OnPlayerKilled( CheckSpawnzoneSuspiciousDeaths )
	AddSpawnCallbackEditorClass( "trigger_multiple", "trigger_mp_spawn_zone", SpawnzoneTriggerInit )
	
	file.militiaPreviousSpawnZones = [ null, null, null ]
	file.imcPreviousSpawnZones = [ null, null, null ]
}

void function GiveScoreForPlayerKill( entity victim, entity attacker, var damageInfo )
{
	if ( victim != attacker && victim.IsPlayer() && attacker.IsPlayer() || GetGameState() != eGameState.Playing )
		AddTeamScore( attacker.GetTeam(), 1 )
}

int function CheckScoreForDraw()
{
	if ( GameRules_GetTeamScore( TEAM_IMC ) > GameRules_GetTeamScore( TEAM_MILITIA ) )
		return TEAM_IMC
	else if ( GameRules_GetTeamScore( TEAM_MILITIA ) > GameRules_GetTeamScore( TEAM_IMC ) )
		return TEAM_MILITIA

	return TEAM_UNASSIGNED
}

// spawnzone logic
void function SpawnzoneTriggerInit( entity spawnzone )
{
	// initialise spawnzone script vars
	spawnzone.s.lastDeathRateCheck <- 0.0
	spawnzone.s.numRecentSuspiciousDeaths <- 0
	spawnzone.s.minimapObj <- null
	
	file.spawnzones.append( spawnzone )
}

void function SetNewSpawnzoneForTeam( int team, entity spawnzone )
{
	entity minimapObj = CreatePropScript( $"models/dev/empty_model.mdl", spawnzone.GetOrigin() )
	SetTeam( minimapObj, team )	
	minimapObj.Minimap_SetObjectScale( 100.0 / Distance2D( < 0, 0, 0 >, spawnzone.GetBoundingMaxs() ) )
	minimapObj.Minimap_SetAlignUpright( true )
	minimapObj.Minimap_AlwaysShow( TEAM_IMC, null )
	minimapObj.Minimap_AlwaysShow( TEAM_MILITIA, null )
	minimapObj.Minimap_SetHeightTracking( true )
	minimapObj.Minimap_SetZOrder( MINIMAP_Z_OBJECT )
	
	if ( team == TEAM_IMC ) 
	{
		if ( IsValid( file.imcActiveSpawnZone ) )
			file.imcActiveSpawnZone.s.minimapObj.Destroy()
	
		// update last 3 zones
		file.imcPreviousSpawnZones[ 2 ] = file.imcPreviousSpawnZones[ 1 ]
		file.imcPreviousSpawnZones[ 1 ] = file.imcPreviousSpawnZones[ 0 ]
		file.imcPreviousSpawnZones[ 0 ] = file.imcActiveSpawnZone
	
		file.imcActiveSpawnZone = spawnzone
		minimapObj.Minimap_SetCustomState( eMinimapObject_prop_script.SPAWNZONE_IMC )
	}
	else
	{
		if ( IsValid( file.militiaActiveSpawnZone ) )
			file.militiaActiveSpawnZone.s.minimapObj.Destroy()
	
		// update last 3 zones
		file.militiaPreviousSpawnZones[ 2 ] = file.militiaPreviousSpawnZones[ 1 ]
		file.militiaPreviousSpawnZones[ 1 ] = file.militiaPreviousSpawnZones[ 0 ]
		file.militiaPreviousSpawnZones[ 0 ] = file.militiaActiveSpawnZone
	
		file.militiaActiveSpawnZone = spawnzone
		minimapObj.Minimap_SetCustomState( eMinimapObject_prop_script.SPAWNZONE_MIL )
	}
	
	minimapObj.DisableHibernation()	
	
	spawnzone.s.minimapObj = minimapObj
	spawnzone.s.lastDeathRateCheck = 0.0
	spawnzone.s.numRecentSuspiciousDeaths = Time()
}

void function CheckSpawnzoneSuspiciousDeaths( entity victim, entity attacker, var damageInfo )
{
	if ( victim.s.respawnTime + 10.0 < Time() )
		return

	entity spawnzone
	if ( victim.GetTeam() == TEAM_IMC )
		spawnzone = file.imcActiveSpawnZone
	else
		spawnzone = file.militiaActiveSpawnZone
	
	if ( Distance2D( victim.GetOrigin(), spawnzone.GetOrigin() ) <= Distance2D( < 0, 0, 0 >, spawnzone.GetBoundingMaxs() ) * 1.2 )
		spawnzone.s.numRecentSuspiciousDeaths++
}

entity function FindNewSpawnZone( int team )
{
	array<entity> startSpawns = SpawnPoints_GetPilotStart( team )
	array<entity> enemyStartSpawns = SpawnPoints_GetPilotStart( GetOtherTeam( team ) )
	
	// get average friendly startspawn position
	vector averageFriendlySpawns
	foreach ( entity spawn in startSpawns )
		averageFriendlySpawns += spawn.GetOrigin()
	averageFriendlySpawns /= startSpawns.len()
	
	// get average enemy startspawn position
	vector averageEnemySpawns
	foreach ( entity spawn in enemyStartSpawns )
		averageEnemySpawns += spawn.GetOrigin()
	averageEnemySpawns /= enemyStartSpawns.len()
	
	array<entity> validZones
	array<entity> enemyPlayers = GetPlayerArrayOfTeam( GetOtherTeam( team ) )
	float averageFriendlySpawnDist
	
	foreach ( entity spawnzone in file.spawnzones )
	{
		if ( team == TEAM_IMC && file.imcPreviousSpawnZones.contains( spawnzone ) )
			continue
		else if ( file.militiaPreviousSpawnZones.contains( spawnzone ) )
			continue
	
		// check if it's too far from startspawns
		float friendlySpawnDist = Distance2D( spawnzone.GetOrigin(), averageFriendlySpawns )
		if ( friendlySpawnDist > Distance2D( averageFriendlySpawns, averageEnemySpawns ) * 1.2 )
			continue
		
		// check if it's safe atm
		bool safe = true
		foreach ( entity enemy in enemyPlayers )
		{
			if ( Distance2D( enemy.GetOrigin(), spawnzone.GetOrigin() ) < Distance2D( < 0, 0, 0 >, spawnzone.GetBoundingMaxs() ) * 1.2 )
			{
				safe = false
				break
			}
		}
		
		if ( !safe )
			continue
		
		averageFriendlySpawnDist += friendlySpawnDist
		validZones.append( spawnzone )
	}
	
	averageFriendlySpawnDist /= validZones.len()
	
	array<entity> realValidZones = clone validZones
	foreach ( entity validzone in validZones )
	{
		if ( Distance2D( averageFriendlySpawns, validzone.GetOrigin() ) < averageFriendlySpawnDist * 1.4 )
			realValidZones.append( validzone )
	}
	
	entity spawnzone = realValidZones.getrandom()
	SetNewSpawnzoneForTeam( team, spawnzone )
		
	return spawnzone
}

void function RateSpawnpoints_SpawnZones( int checkClass, array<entity> spawnpoints, int team, entity player )
{
	entity spawnzone
	if ( player.GetTeam() == TEAM_IMC )
		spawnzone = file.imcActiveSpawnZone
	else
		spawnzone = file.militiaActiveSpawnZone
	
	// spawnzones don't exist yet, create them now
	if ( !IsValid( spawnzone ) )
		spawnzone = FindNewSpawnZone( player.GetTeam() )
	
	// check if we should shift spawnzones
	// if it's been more than 15 seconds since last check, reset
	if ( spawnzone.s.lastDeathRateCheck + 15.0 < Time() )
	{
		spawnzone.s.numRecentSuspiciousDeaths = 0
		spawnzone.s.lastDeathRateCheck = Time()
	}
	
	// check if we've gone over the threshold for recent deaths too close to our current spawnzone
	if ( spawnzone.s.numRecentSuspiciousDeaths >= GetPlayerArrayOfTeam( player.GetTeam() ).len() * 0.4 )
		// over the threshold, find a new spawn zone
		spawnzone = FindNewSpawnZone( player.GetTeam() )
	
	// rate spawnpoints
	foreach ( entity spawn in spawnpoints ) 
	{
		float rating = 0.0
		float distance = Distance2D( spawn.GetOrigin(), spawnzone.GetOrigin() )
		if ( distance < Distance2D( < 0, 0, 0 >, spawnzone.GetBoundingMaxs() ) )
			rating = 100.0
		else // max 35 rating if not in zone, rate by closest
			rating = 35.0 * ( 1 - ( distance / 5000.0 ) )
			
		spawn.CalculateRating( checkClass, player.GetTeam(), rating, rating )
	}
}