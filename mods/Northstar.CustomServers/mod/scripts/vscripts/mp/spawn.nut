untyped

global function InitRatings // temp for testing

global function Spawn_Init
global function SetRespawnsEnabled
global function RespawnsEnabled
global function SetSpawnpointGamemodeOverride
global function GetSpawnpointGamemodeOverride
global function AddSpawnpointValidationRule
global function CreateNoSpawnArea
global function DeleteNoSpawnArea

global function FindSpawnPoint

global function RateSpawnpoints_Generic
global function RateSpawnpoints_Frontline

global function SetSpawnZoneRatingFunc
global function SetShouldCreateMinimapSpawnZones
global function CreateTeamSpawnZoneEntity
global function RateSpawnpoints_SpawnZones
global function DecideSpawnZone_Generic
global function DecideSpawnZone_CTF

struct NoSpawnArea
{
	string id
	int blockedTeam
	int blockOtherTeams
	vector position
	float lifetime
	float radius
}

struct {
	bool respawnsEnabled = true
	string spawnpointGamemodeOverride
	array< bool functionref( entity, int ) > customSpawnpointValidationRules

	table<string, NoSpawnArea> noSpawnAreas
} file

void function Spawn_Init()
{	
	AddSpawnCallback( "info_spawnpoint_human", InitSpawnpoint )
	AddSpawnCallback( "info_spawnpoint_human_start", InitSpawnpoint )
	AddSpawnCallback( "info_spawnpoint_titan", InitSpawnpoint )
	AddSpawnCallback( "info_spawnpoint_titan_start", InitSpawnpoint )
	
	// callbacks for generic spawns
	AddCallback_EntitiesDidLoad( InitPreferSpawnNodes )
	
	// callbacks for spawnzone spawns
	AddCallback_GameStateEnter( eGameState.Prematch, ResetSpawnzones )
	AddSpawnCallbackEditorClass( "trigger_multiple", "trigger_mp_spawn_zone", AddSpawnZoneTrigger )
}

void function InitSpawnpoint( entity spawnpoint ) 
{
	spawnpoint.s.lastUsedTime <- -999
}

void function SetRespawnsEnabled( bool enabled )
{
	file.respawnsEnabled = enabled
}

bool function RespawnsEnabled()
{
	return file.respawnsEnabled
}

void function AddSpawnpointValidationRule( bool functionref( entity spawn, int team ) rule )
{
	file.customSpawnpointValidationRules.append( rule )
} 

string function CreateNoSpawnArea( int blockSpecificTeam, int blockEnemiesOfTeam, vector position, float lifetime, float radius )
{
	NoSpawnArea noSpawnArea
	noSpawnArea.blockedTeam = blockSpecificTeam
	noSpawnArea.blockOtherTeams = blockEnemiesOfTeam
	noSpawnArea.position = position
	noSpawnArea.lifetime = lifetime
	noSpawnArea.radius = radius
	
	// generate an id
	noSpawnArea.id = UniqueString( "noSpawnArea" )
	
	thread NoSpawnAreaLifetime( noSpawnArea )
	
	return noSpawnArea.id
}

void function NoSpawnAreaLifetime( NoSpawnArea noSpawnArea )
{
	wait noSpawnArea.lifetime
	DeleteNoSpawnArea( noSpawnArea.id )
}

void function DeleteNoSpawnArea( string noSpawnIdx )
{
	if ( noSpawnIdx in file.noSpawnAreas )
		delete file.noSpawnAreas[ noSpawnIdx ]
}

void function SetSpawnpointGamemodeOverride( string gamemode )
{
	file.spawnpointGamemodeOverride = gamemode
}

string function GetSpawnpointGamemodeOverride()
{
	if ( file.spawnpointGamemodeOverride != "" )
		return file.spawnpointGamemodeOverride
	else
		return GAMETYPE
	
	unreachable
}

void function InitRatings( entity player, int team )
{
	if ( player != null )
		SpawnPoints_InitRatings( player, team ) // no idea what the second arg supposed to be lol
}

entity function FindSpawnPoint( entity player, bool isTitan, bool useStartSpawnpoint )
{
	int team = player.GetTeam()
	if ( HasSwitchedSides() )
		team = GetOtherTeam( team )

	array<entity> spawnpoints
	if ( useStartSpawnpoint )
		spawnpoints = isTitan ? SpawnPoints_GetTitanStart( team ) : SpawnPoints_GetPilotStart( team )
	else
		spawnpoints = isTitan ? SpawnPoints_GetTitan() : SpawnPoints_GetPilot()
	
	InitRatings( player, player.GetTeam() )
	
	// don't think this is necessary since we call discardratings
	//foreach ( entity spawnpoint in spawnpoints )
	//	spawnpoint.CalculateRating( isTitan ? TD_TITAN : TD_PILOT, team, 0.0, 0.0 )
	
	void functionref( int, array<entity>, int, entity ) ratingFunc = isTitan ? GameMode_GetTitanSpawnpointsRatingFunc( GAMETYPE ) : GameMode_GetPilotSpawnpointsRatingFunc( GAMETYPE )
	ratingFunc( isTitan ? TD_TITAN : TD_PILOT, spawnpoints, team, player )
	
	if ( isTitan )
	{
		if ( useStartSpawnpoint )
			SpawnPoints_SortTitanStart()
		else
			SpawnPoints_SortTitan()
			
		spawnpoints = useStartSpawnpoint ? SpawnPoints_GetTitanStart( team ) : SpawnPoints_GetTitan()
	}
	else
	{
		if ( useStartSpawnpoint )
			SpawnPoints_SortPilotStart()
		else
			SpawnPoints_SortPilot()
			
		spawnpoints = useStartSpawnpoint ? SpawnPoints_GetPilotStart( team ) : SpawnPoints_GetPilot()
	}
	
	entity spawnpoint = GetBestSpawnpoint( player, spawnpoints )
		
	spawnpoint.s.lastUsedTime = Time()
	player.SetLastSpawnPoint( spawnpoint )
		
	return spawnpoint
}

entity function GetBestSpawnpoint( entity player, array<entity> spawnpoints )
{
	// not really 100% sure on this randomisation, needs some thought
	array<entity> validSpawns
	foreach ( entity spawnpoint in spawnpoints )
	{
		if ( IsSpawnpointValid( spawnpoint, player.GetTeam() ) )
		{
			validSpawns.append( spawnpoint )
			
			if ( validSpawns.len() == 3 ) // arbitrary small sample size
				break
		}
	}
	
	if ( validSpawns.len() == 0 )
	{
		// no valid spawns, very bad, so dont care about spawns being valid anymore
		print( "found no valid spawns! spawns may be subpar!" )
		foreach ( entity spawnpoint in spawnpoints )
		{
			validSpawns.append( spawnpoint )
			
			if ( validSpawns.len() == 3 ) // arbitrary small sample size
				break
		}
	}
	
	// last resort
	if ( validSpawns.len() == 0 )
	{
		print( "map has literally 0 spawnpoints, as such everything is fucked probably, attempting to use info_player_start if present" )
		entity start = GetEnt( "info_player_start" )
		
		if ( IsValid( start ) )
		{
			start.s.lastUsedTime <- -999
			validSpawns.append( start )
		}
	}
	
	return validSpawns[ RandomInt( validSpawns.len() ) ] // slightly randomize it
}

bool function IsSpawnpointValid( entity spawnpoint, int team )
{
	if ( !spawnpoint.HasKey( "ignoreGamemode" ) || ( spawnpoint.HasKey( "ignoreGamemode" ) && spawnpoint.kv.ignoreGamemode == "0" ) ) // used by script-spawned spawnpoints
	{
		if ( file.spawnpointGamemodeOverride != "" )
		{
			string gamemodeKey = "gamemode_" + file.spawnpointGamemodeOverride
			if ( spawnpoint.HasKey( gamemodeKey ) && ( spawnpoint.kv[ gamemodeKey ] == "0" || spawnpoint.kv[ gamemodeKey ] == "" ) )
				return false
		}
		else if ( GameModeRemove( spawnpoint ) )
			return false
	}
	
	int compareTeam = spawnpoint.GetTeam()
	if ( HasSwitchedSides() && ( compareTeam == TEAM_MILITIA || compareTeam == TEAM_IMC ) )
		compareTeam = GetOtherTeam( compareTeam )
		
	foreach ( bool functionref( entity, int ) customValidationRule in file.customSpawnpointValidationRules )
		if ( !customValidationRule( spawnpoint, team ) )
			return false
		
	if ( spawnpoint.GetTeam() > 0 && compareTeam != team && !IsFFAGame() )
		return false
	
	if ( spawnpoint.IsOccupied() )
		return false
		
	if ( Time() - spawnpoint.s.lastUsedTime <= 10.0 )
		return false
		
	foreach ( k, NoSpawnArea noSpawnArea in file.noSpawnAreas )
	{
		if ( Distance( noSpawnArea.position, spawnpoint.GetOrigin() ) > noSpawnArea.radius )
			continue
			
		if ( noSpawnArea.blockedTeam != TEAM_INVALID && noSpawnArea.blockedTeam == team )
			return false
			
		if ( noSpawnArea.blockOtherTeams != TEAM_INVALID && noSpawnArea.blockOtherTeams != team )
			return false
	}

	array<entity> projectiles = GetProjectileArrayEx( "any", TEAM_ANY, TEAM_ANY, spawnpoint.GetOrigin(), 600 )
	foreach ( entity projectile in projectiles )
		if ( projectile.GetTeam() != team )
			return false
	
	// los check
	return !spawnpoint.IsVisibleToEnemies( team )
}


// SPAWNPOINT RATING FUNCS BELOW

// generic
struct {
	array<vector> preferSpawnNodes
} spawnStateGeneric

void function RateSpawnpoints_Generic( int checkClass, array<entity> spawnpoints, int team, entity player )
{	
	if ( !IsFFAGame() )
	{
		// use frontline spawns in 2-team modes
		RateSpawnpoints_Frontline( checkClass, spawnpoints, team, player )
		return
	}
	else
	{
		// todo: ffa spawns :terror:
	}

	// old algo: keeping until we have a better ffa spawn algo

	// i'm not a fan of this func, but i really don't have a better way to do this rn, and it's surprisingly good with los checks implemented now
	
	// calculate ratings for preferred nodes
	// this tries to prefer nodes with more teammates, then activity on them
	// todo: in the future it might be good to have this prefer nodes with enemies up to a limit of some sort
	// especially in ffa modes i could deffo see this falling apart a bit rn
	// perhaps dead players could be used to calculate some sort of activity rating? so high-activity points with an even balance of friendly/unfriendly players are preferred
	array<float> preferSpawnNodeRatings
	foreach ( vector preferSpawnNode in spawnStateGeneric.preferSpawnNodes )
	{
		float currentRating
		
		// this seems weird, not using rn
		//Frontline currentFrontline = GetCurrentFrontline( team )
		//if ( !IsFFAGame() || currentFrontline.friendlyCenter != < 0, 0, 0 > )
		//	currentRating += max( 0.0, ( 1000.0 - Distance2D( currentFrontline.origin, preferSpawnNode ) ) / 200 )
		
		foreach ( entity nodePlayer in GetPlayerArray() )
		{
			float currentChange = 0.0
			
			// the closer a player is to a node the more they matter
			float dist = Distance2D( preferSpawnNode, nodePlayer.GetOrigin() )
			if ( dist > 600.0 )
				continue
			
			currentChange = ( 600.0 - dist ) / 5
			if ( player == nodePlayer )
				currentChange *= -3 // always try to stay away from places we've already spawned
			else if ( !IsAlive( nodePlayer ) ) // dead players mean activity which is good, but they're also dead so they don't matter as much as living ones
				currentChange *= 0.6
			if ( nodePlayer.GetTeam() != player.GetTeam() ) // if someone isn't on our team and alive they're probably bad
			{
				if ( IsFFAGame() ) // in ffa everyone is on different teams, so this isn't such a big deal
					currentChange *= -0.2
				else
					currentChange *= -0.6
			}
				
			currentRating += currentChange
		}
		
		preferSpawnNodeRatings.append( currentRating )
	}
	
	foreach ( entity spawnpoint in spawnpoints )
	{
		float currentRating
		float petTitanModifier
		// scale how much a given spawnpoint matters to us based on how far it is from each node
		bool spawnHasRecievedInitialBonus = false
		for ( int i = 0; i < spawnStateGeneric.preferSpawnNodes.len(); i++ )
		{
			// bonus if autotitan is nearish
			if ( IsAlive( player.GetPetTitan() ) && Distance( player.GetPetTitan().GetOrigin(), spawnStateGeneric.preferSpawnNodes[ i ] ) < 1200.0 )
				petTitanModifier += 10.0
			
			float dist = Distance2D( spawnpoint.GetOrigin(), spawnStateGeneric.preferSpawnNodes[ i ] )
			if ( dist > 750.0 )
				continue
						
			if ( dist < 600.0 && !spawnHasRecievedInitialBonus )
			{
				currentRating += 10.0
				spawnHasRecievedInitialBonus = true // should only get a bonus for simply being by a node once to avoid over-rating
			}
		
			currentRating += ( preferSpawnNodeRatings[ i ] * ( ( 750.0 - dist ) / 75 ) ) +  max( RandomFloat( 1.25 ), 0.9 )
			if ( dist < 250.0 ) // shouldn't get TOO close to an active node
				currentRating *= 0.7 
				
			if ( spawnpoint.s.lastUsedTime < 10.0 )
				currentRating *= 0.7
		}
	
		float rating = spawnpoint.CalculateRating( checkClass, team, currentRating, currentRating + petTitanModifier )
		//print( "spawnpoint at " + spawnpoint.GetOrigin() + " has rating: " +  )
		
		if ( rating != 0.0 || currentRating != 0.0 )
			print( "rating = " + rating + ", internal rating = " + currentRating )
	}
}

void function InitPreferSpawnNodes()
{
	foreach ( entity hardpoint in GetEntArrayByClass_Expensive( "info_hardpoint" ) )
	{
		if ( !hardpoint.HasKey( "hardpointGroup" ) )
			continue
			
		if ( hardpoint.kv.hardpointGroup != "A" && hardpoint.kv.hardpointGroup != "B" && hardpoint.kv.hardpointGroup != "C" )
			continue
			
		spawnStateGeneric.preferSpawnNodes.append( hardpoint.GetOrigin() )
	}
	
	//foreach ( entity frontline in GetEntArrayByClass_Expensive( "info_frontline" ) )
	//	spawnStateGeneric.preferSpawnNodes.append( frontline.GetOrigin() )
}

// frontline
void function RateSpawnpoints_Frontline( int checkClass, array<entity> spawnpoints, int team, entity player )
{
	foreach ( entity spawnpoint in spawnpoints )
	{
		float rating = spawnpoint.CalculateFrontlineRating()
		spawnpoint.CalculateRating( checkClass, player.GetTeam(), rating, rating > 0 ? rating * 0.25 : rating )
	}
}

// spawnzones
struct {
	array<entity> mapSpawnzoneTriggers
	entity functionref( array<entity>, int ) spawnzoneRatingFunc
	bool shouldCreateMinimapSpawnzones = false
	
	// for DecideSpawnZone_Generic
	table<int, entity> activeTeamSpawnzones
	table<int, entity> activeTeamSpawnzoneMinimapEnts
} spawnStateSpawnzones

void function ResetSpawnzones()
{
	spawnStateSpawnzones.activeTeamSpawnzones.clear()
	
	foreach ( int team, entity minimapEnt in spawnStateSpawnzones.activeTeamSpawnzoneMinimapEnts )
		if ( IsValid( minimapEnt ) )
			minimapEnt.Destroy()
	
	spawnStateSpawnzones.activeTeamSpawnzoneMinimapEnts.clear()
}

void function AddSpawnZoneTrigger( entity trigger )
{
	trigger.s.spawnzoneRating <- 0.0
	spawnStateSpawnzones.mapSpawnzoneTriggers.append( trigger )
}

void function SetSpawnZoneRatingFunc( entity functionref( array<entity>, int ) ratingFunc )
{
	spawnStateSpawnzones.spawnzoneRatingFunc = ratingFunc
}

void function SetShouldCreateMinimapSpawnZones( bool shouldCreateMinimapSpawnzones )
{
	spawnStateSpawnzones.shouldCreateMinimapSpawnzones = shouldCreateMinimapSpawnzones
}

entity function CreateTeamSpawnZoneEntity( entity spawnzone, int team )
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
		minimapObj.Minimap_SetCustomState( eMinimapObject_prop_script.SPAWNZONE_IMC )
	else
		minimapObj.Minimap_SetCustomState( eMinimapObject_prop_script.SPAWNZONE_MIL )
		
	minimapObj.DisableHibernation()
	return minimapObj
}

void function RateSpawnpoints_SpawnZones( int checkClass, array<entity> spawnpoints, int team, entity player )
{
	if ( spawnStateSpawnzones.spawnzoneRatingFunc == null )
		spawnStateSpawnzones.spawnzoneRatingFunc = DecideSpawnZone_Generic

	// don't use spawnzones if we're using start spawns
	if ( ShouldStartSpawn( player ) )
	{
		RateSpawnpoints_Generic( checkClass, spawnpoints, team, player )
		return
	}

	entity spawnzone = spawnStateSpawnzones.spawnzoneRatingFunc( spawnStateSpawnzones.mapSpawnzoneTriggers, player.GetTeam() )	
	if ( !IsValid( spawnzone ) ) // no spawn zone, use generic algo
	{
		RateSpawnpoints_Generic( checkClass, spawnpoints, team, player )
		return
	}
	
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

entity function DecideSpawnZone_Generic( array<entity> spawnzones, int team )
{
	if ( spawnzones.len() == 0 )
		return null
	
	// get average team startspawn positions
	int spawnCompareTeam = team
	if ( HasSwitchedSides() )
		spawnCompareTeam = GetOtherTeam( team )
	
	array<entity> startSpawns = SpawnPoints_GetPilotStart( spawnCompareTeam )
	array<entity> enemyStartSpawns = SpawnPoints_GetPilotStart( GetOtherTeam( spawnCompareTeam ) )
	
	if ( startSpawns.len() == 0 || enemyStartSpawns.len() == 0 ) // ensure we don't crash
		return null
	
	// get average startspawn position and max dist between spawns
	// could probably cache this, tbh, not like it should change outside of halftimes
	vector averageFriendlySpawns	
	foreach ( entity spawn in startSpawns )
		averageFriendlySpawns += spawn.GetOrigin()
	
	averageFriendlySpawns /= startSpawns.len()
	
	// get average enemy startspawn position
	vector averageEnemySpawns
	foreach ( entity spawn in enemyStartSpawns )
		averageEnemySpawns += spawn.GetOrigin()
	
	averageEnemySpawns /= enemyStartSpawns.len()
	
	float baseDistance = Distance2D( averageFriendlySpawns, averageEnemySpawns )
	
	bool needNewZone = true
	if ( team in spawnStateSpawnzones.activeTeamSpawnzones )
	{
		foreach ( entity player in GetPlayerArray() )
		{
			// couldn't get IsTouching, GetTouchingEntities or enter callbacks to work in testing, so doing this
			if ( player.GetTeam() != team && spawnStateSpawnzones.activeTeamSpawnzones[ team ].ContainsPoint( player.GetOrigin() ) )
				break
		}
		
		int numDeadInZone = 0
		array<entity> teamPlayers = GetPlayerArrayOfTeam( team )
		foreach ( entity player in teamPlayers )
		{
			// check if they died in the zone recently, get a new zone if too many died
			if ( Time() - player.p.postDeathThreadStartTime < 15.0 && spawnStateSpawnzones.activeTeamSpawnzones[ team ].ContainsPoint( player.p.deathOrigin ) )
				numDeadInZone++
		}
		
		// cast to float so result is float
		if ( float( numDeadInZone ) / teamPlayers.len() <= 0.1 )
			needNewZone = false
	}
	
	if ( needNewZone )
	{
		// find new zone
		array<entity> possibleZones
		foreach ( entity spawnzone in spawnStateSpawnzones.mapSpawnzoneTriggers )
		{
			// don't remember if you can do a "value in table.values" sorta thing in squirrel so doing manual lookup
			bool spawnzoneTaken = false
			foreach ( int otherTeam, entity otherSpawnzone in spawnStateSpawnzones.activeTeamSpawnzones )
			{			
				if ( otherSpawnzone == spawnzone )
				{
					spawnzoneTaken = true
					break
				}
			}
			
			if ( spawnzoneTaken )
				continue
			
			// check zone validity
			bool spawnzoneEvil = false
			foreach ( entity player in GetPlayerArray() )
			{
				// couldn't get IsTouching, GetTouchingEntities or enter callbacks to work in testing, so doing this
				if ( player.GetTeam() != team && spawnzone.ContainsPoint( player.GetOrigin() ) )
				{
					spawnzoneEvil = true
					break
				}
			}
			
			// don't choose spawnzones that are closer to enemy base than friendly base
			// note: vanilla spawns might not necessarily require this, worth checking
			if ( !spawnzoneEvil && Distance2D( spawnzone.GetOrigin(), averageFriendlySpawns ) > Distance2D( spawnzone.GetOrigin(), averageEnemySpawns ) )
				spawnzoneEvil = true
			
			if ( spawnzoneEvil )
				continue
			
			// rate spawnzone based on distance to frontline
			Frontline frontline = GetFrontline( team )

			// prefer spawns close to base pos
			float rating = 10 * ( 1.0 - Distance2D( averageFriendlySpawns, spawnzone.GetOrigin() ) / baseDistance )
		
			if ( frontline.friendlyCenter != < 0, 0, 0 > )
			{
				// rate based on distance to frontline, and then prefer spawns in the same dir from the frontline as the combatdir
				rating += rating * ( 1.0 - ( Distance2D( spawnzone.GetOrigin(), frontline.friendlyCenter ) / baseDistance ) )
				rating *= fabs( frontline.combatDir.y - Normalize( spawnzone.GetOrigin() - averageFriendlySpawns ).y )
			}
			
			spawnzone.s.spawnzoneRating = rating
			possibleZones.append( spawnzone )
		}
		
		if ( possibleZones.len() == 0 )
			return null
		
		possibleZones.sort( int function( entity a, entity b ) 
		{
			if ( a.s.spawnzoneRating > b.s.spawnzoneRating )
				return -1
			
			if ( b.s.spawnzoneRating > a.s.spawnzoneRating )
				return 1
			
			return 0
		} )
		entity chosenZone = possibleZones[ minint( RandomInt( 3 ), possibleZones.len() - 1 ) ]
		
		if ( spawnStateSpawnzones.shouldCreateMinimapSpawnzones )
		{
			entity oldEnt
			if ( team in spawnStateSpawnzones.activeTeamSpawnzoneMinimapEnts )
				oldEnt = spawnStateSpawnzones.activeTeamSpawnzoneMinimapEnts[ team ]
					
			spawnStateSpawnzones.activeTeamSpawnzoneMinimapEnts[ team ] <- CreateTeamSpawnZoneEntity( chosenZone, team )
			if ( IsValid( oldEnt ) )
				oldEnt.Destroy()
		}
		
		spawnStateSpawnzones.activeTeamSpawnzones[ team ] <- chosenZone
	}
	
	return spawnStateSpawnzones.activeTeamSpawnzones[ team ]
}

// ideally this should be in the gamemode_ctf file, but would need refactors to expose more stuff that's not available there rn 
entity function DecideSpawnZone_CTF( array<entity> spawnzones, int team )
{
	if ( spawnzones.len() == 0 )
		return null
	
	int otherTeam = GetOtherTeam( team )
	array<entity> enemyPlayers = GetPlayerArrayOfTeam( otherTeam )
	
	// get average team startspawn positions
	int spawnCompareTeam = team
	if ( HasSwitchedSides() )
		spawnCompareTeam = GetOtherTeam( team )
	
	array<entity> startSpawns = SpawnPoints_GetPilotStart( spawnCompareTeam )
	array<entity> enemyStartSpawns = SpawnPoints_GetPilotStart( GetOtherTeam( spawnCompareTeam ) )
	
	if ( startSpawns.len() == 0 || enemyStartSpawns.len() == 0 ) // ensure we don't crash
		return null
	
	// get average startspawn position and max dist between spawns
	// could probably cache this, tbh, not like it should change outside of halftimes
	vector averageFriendlySpawns	
	foreach ( entity spawn in startSpawns )
		averageFriendlySpawns += spawn.GetOrigin()
	
	averageFriendlySpawns /= startSpawns.len()
	
	// get average enemy startspawn position
	vector averageEnemySpawns
	foreach ( entity spawn in enemyStartSpawns )
		averageEnemySpawns += spawn.GetOrigin()
	
	averageEnemySpawns /= enemyStartSpawns.len()
	
	float baseDistance = Distance2D( averageFriendlySpawns, averageEnemySpawns )
	
	// find new zone
	array<entity> possibleZones
	foreach ( entity spawnzone in spawnStateSpawnzones.mapSpawnzoneTriggers )
	{
		// can't choose zone if another team has it
		if ( otherTeam in spawnStateSpawnzones.activeTeamSpawnzones && spawnStateSpawnzones.activeTeamSpawnzones[ otherTeam ] == spawnzone )
			continue
		
		// check zone validity
		bool spawnzoneEvil = false
		foreach ( entity player in enemyPlayers )
		{
			// couldn't get IsTouching, GetTouchingEntities or enter callbacks to work in testing, so doing this
			if ( spawnzone.ContainsPoint( player.GetOrigin() ) )
			{
				spawnzoneEvil = true
				break
			}
		}
		
		// don't choose spawnzones that are closer to enemy base than friendly base
		if ( !spawnzoneEvil && Distance2D( spawnzone.GetOrigin(), averageFriendlySpawns ) > Distance2D( spawnzone.GetOrigin(), averageEnemySpawns ) )
			spawnzoneEvil = true
		
		if ( spawnzoneEvil )
			continue
		
		// rate spawnzone based on distance to frontline
		Frontline frontline = GetFrontline( team )

		// prefer spawns close to base pos
		float rating = 10 * ( 1.0 - Distance2D( averageFriendlySpawns, spawnzone.GetOrigin() ) / baseDistance )
	
		if ( frontline.friendlyCenter != < 0, 0, 0 > )
		{
			// rate based on distance to frontline, and then prefer spawns in the same dir from the frontline as the combatdir
			rating += rating * ( 1.0 - ( Distance2D( spawnzone.GetOrigin(), frontline.friendlyCenter ) / baseDistance ) )
			rating *= fabs( frontline.combatDir.y - Normalize( spawnzone.GetOrigin() - averageFriendlySpawns ).y )
			
			// reduce rating based on players that can currently see the zone
			bool hasAppliedInitialLoss = false
			foreach ( entity player in enemyPlayers )
			{
				// don't trace here, just do an angle check
				if ( PlayerCanSee( player, spawnzone, false, 65 ) && Distance2D( player.GetOrigin(), spawnzone.GetOrigin() ) <= 2000.0 )
				{
					float distFrac = TraceLineSimple( player.GetOrigin(), spawnzone.GetOrigin(), player )
					
					if ( distFrac >= 0.65 )
					{
						// give a fairly large loss if literally anyone can see it
						if ( !hasAppliedInitialLoss )
						{
							rating *= 0.8
							hasAppliedInitialLoss = true
						}
					
						rating *= ( 1.0 / enemyPlayers.len() ) * distFrac
					}
				}
			}
		}
		
		spawnzone.s.spawnzoneRating = rating
		possibleZones.append( spawnzone )
	}
	
	if ( possibleZones.len() == 0 )
		return null
	
	possibleZones.sort( int function( entity a, entity b ) 
	{
		if ( a.s.spawnzoneRating > b.s.spawnzoneRating )
			return -1
		
		if ( b.s.spawnzoneRating > a.s.spawnzoneRating )
			return 1
		
		return 0
	} )
	entity chosenZone = possibleZones[ minint( RandomInt( 3 ), possibleZones.len() - 1 ) ]
	
	if ( spawnStateSpawnzones.shouldCreateMinimapSpawnzones )
	{
		entity oldEnt
		if ( team in spawnStateSpawnzones.activeTeamSpawnzoneMinimapEnts )
			oldEnt = spawnStateSpawnzones.activeTeamSpawnzoneMinimapEnts[ team ]
				
		spawnStateSpawnzones.activeTeamSpawnzoneMinimapEnts[ team ] <- CreateTeamSpawnZoneEntity( chosenZone, team )
		if ( IsValid( oldEnt ) )
			oldEnt.Destroy()
	}
	
	spawnStateSpawnzones.activeTeamSpawnzones[ team ] <- chosenZone
	
	return spawnStateSpawnzones.activeTeamSpawnzones[ team ]
}