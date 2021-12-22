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
	
	array<vector> preferSpawnNodes
} file

void function Spawn_Init()
{	
	AddSpawnCallback( "info_spawnpoint_human", InitSpawnpoint )
	AddSpawnCallback( "info_spawnpoint_human_start", InitSpawnpoint )
	AddSpawnCallback( "info_spawnpoint_titan", InitSpawnpoint )
	AddSpawnCallback( "info_spawnpoint_titan_start", InitSpawnpoint )
	
	AddCallback_EntitiesDidLoad( InitPreferSpawnNodes )
}

void function InitPreferSpawnNodes()
{
	foreach ( entity hardpoint in GetEntArrayByClass_Expensive( "info_hardpoint" ) )
	{
		if ( !hardpoint.HasKey( "hardpointGroup" ) )
			continue
			
		if ( hardpoint.kv.hardpointGroup != "A" && hardpoint.kv.hardpointGroup != "B" && hardpoint.kv.hardpointGroup != "C" )
			continue
			
		file.preferSpawnNodes.append( hardpoint.GetOrigin() )
	}
	
	//foreach ( entity frontline in GetEntArrayByClass_Expensive( "info_frontline" ) )
	//	file.preferSpawnNodes.append( frontline.GetOrigin() )
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
	array<entity> enemyLosPlayers
	if ( IsFFAGame() )
		enemyLosPlayers = GetPlayerArray()
	else 
		enemyLosPlayers = GetPlayerArrayOfTeam( GetOtherTeam( team ) )
	
	foreach ( entity enemyPlayer in enemyLosPlayers )
	{
		if ( enemyPlayer.GetTeam() == team || !IsAlive( enemyPlayer ) )
			continue
			
		float dist = 1000.0
		// check fov, constant here is stolen from every other place this is done
		if ( VectorDot_PlayerToOrigin( enemyPlayer, spawnpoint.GetOrigin() ) > 0.8 )
			dist /= 0.75
		
		// check distance, constant here is basically arbitrary
		if ( Distance( enemyPlayer.GetOrigin(), spawnpoint.GetOrigin() ) > dist )
			continue
		
		// check actual los
		if ( TraceLineSimple( enemyPlayer.EyePosition(), spawnpoint.GetOrigin() + < 0, 0, 48 >, enemyPlayer ) == 1.0 )
			return false
	}
		
	return true
}

void function RateSpawnpoints_Generic( int checkClass, array<entity> spawnpoints, int team, entity player )
{	
	// i'm not a fan of this func, but i really don't have a better way to do this rn, and it's surprisingly good with los checks implemented now
	
	// calculate ratings for preferred nodes
	// this tries to prefer nodes with more teammates, then activity on them
	// todo: in the future it might be good to have this prefer nodes with enemies up to a limit of some sort
	// especially in ffa modes i could deffo see this falling apart a bit rn
	// perhaps dead players could be used to calculate some sort of activity rating? so high-activity points with an even balance of friendly/unfriendly players are preferred
	array<float> preferSpawnNodeRatings
	foreach ( vector preferSpawnNode in file.preferSpawnNodes )
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
		for ( int i = 0; i < file.preferSpawnNodes.len(); i++ )
		{
			// bonus if autotitan is nearish
			if ( IsAlive( player.GetPetTitan() ) && Distance( player.GetPetTitan().GetOrigin(), file.preferSpawnNodes[ i ] ) < 1200.0 )
				petTitanModifier += 10.0
			
			float dist = Distance2D( spawnpoint.GetOrigin(), file.preferSpawnNodes[ i ] )
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