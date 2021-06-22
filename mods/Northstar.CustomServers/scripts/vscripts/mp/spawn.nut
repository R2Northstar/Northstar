untyped

global function InitRatings // temp for testing

global function Spawn_Init
global function SetSpawnsUseFrontline
global function SetRespawnsEnabled
global function RespawnsEnabled
global function SetSpawnpointGamemodeOverride
global function CreateNoSpawnArea
global function DeleteNoSpawnArea

global function GetCurrentFrontline
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

	array<vector> preferSpawnNodes
	table<string, NoSpawnArea> noSpawnAreas
	bool sidesSwitched = false
	
	bool frontlineBased = false
	float lastImcFrontlineRatingTime
	float lastMilitiaFrontlineRatingTime
	Frontline& lastImcFrontline
	Frontline& lastMilitiaFrontline
} file

void function Spawn_Init()
{
	AddCallback_GameStateEnter( eGameState.SwitchingSides, OnSwitchingSides )
	AddCallback_EntitiesDidLoad( InitPreferSpawnNodes )
	
	AddSpawnCallback( "info_spawnpoint_human", InitSpawnpoint )
	AddSpawnCallback( "info_spawnpoint_human_start", InitSpawnpoint )
	AddSpawnCallback( "info_spawnpoint_titan", InitSpawnpoint )
	AddSpawnCallback( "info_spawnpoint_titan_start", InitSpawnpoint )
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
	try // unsure if the trycatch is necessary but better safe than sorry
	{
		delete file.noSpawnAreas[ noSpawnIdx ]
	} 
	catch ( exception )
	{}
}

void function SetSpawnpointGamemodeOverride( string gamemode )
{
	file.spawnpointGamemodeOverride = gamemode
}

void function SetSpawnsUseFrontline( bool useFrontline )
{
	file.frontlineBased = useFrontline
}

bool function InitRatings( entity player, int team )
{
	Frontline frontline = GetCurrentFrontline( team )
	print( team )
	print( frontline.friendlyCenter )
	
	vector offsetOrigin = frontline.friendlyCenter + frontline.combatDir * 256
	SpawnPoints_InitFrontlineData( offsetOrigin, frontline.combatDir, frontline.line, frontline.friendlyCenter, 2.0 ) // temp
	
	if ( player != null )
		SpawnPoints_InitRatings( player, team ) // no idea what the second arg supposed to be lol
	
	return frontline.friendlyCenter == < 0, 0, 0 > && file.frontlineBased // if true, use startspawns
}

Frontline function GetCurrentFrontline( int team )
{
	float lastFrontlineRatingTime
	Frontline lastFrontline
	if ( team == TEAM_IMC )
	{
		lastFrontline = file.lastImcFrontline
		lastFrontlineRatingTime = file.lastImcFrontlineRatingTime
	}
	else
	{
		lastFrontline = file.lastMilitiaFrontline
		lastFrontlineRatingTime = file.lastMilitiaFrontlineRatingTime
	}
	
	// current frontline is old, get a new one
	if ( lastFrontlineRatingTime + 20.0 < Time() || lastFrontline.friendlyCenter == < 0, 0, 0 > )
	{
		print( "rerating frontline..." )
		Frontline frontline = GetFrontline( team )
		
		// this doesn't work lol
		/*if ( frontline.friendlyCenter == < 0, 0, 0 > )
		{
			// recalculate to startspawnpoint positions
			array<entity> startSpawns = SpawnPoints_GetPilotStart( team )
			
			vector averagePos
			vector averageDir
			foreach ( entity spawnpoint in startSpawns )
			{
				averagePos.x += spawnpoint.GetOrigin().x
				averagePos.y += spawnpoint.GetOrigin().y
				averagePos.z += spawnpoint.GetOrigin().z
				
				averageDir.x += spawnpoint.GetAngles().x
				averageDir.y += spawnpoint.GetAngles().y
				averageDir.z += spawnpoint.GetAngles().z
			}
			
			averagePos.x /= startSpawns.len()
			averagePos.y /= startSpawns.len()
			averagePos.z /= startSpawns.len()
			
			averageDir.x /= startSpawns.len()
			averageDir.y /= startSpawns.len()
			averageDir.z /= startSpawns.len()
			
			print( "average " + averagePos )
			
			frontline.friendlyCenter = averagePos
			frontline.origin = averagePos
			frontline.combatDir = averageDir * -1
		}*/
		
		if ( team == TEAM_IMC )
		{
			file.lastImcFrontlineRatingTime = Time()
			file.lastImcFrontline = frontline
		}
		else
		{
			file.lastMilitiaFrontlineRatingTime = Time()
			file.lastMilitiaFrontline = frontline
		}
		
		lastFrontline = frontline
	}

	return lastFrontline
}

entity function FindSpawnPoint( entity player, bool isTitan, bool useStartSpawnpoint )
{
	int team = player.GetTeam()
	if ( file.sidesSwitched )
		team = GetOtherTeam( team )

	useStartSpawnpoint = InitRatings( player, player.GetTeam() ) || useStartSpawnpoint // force startspawns if no frontline
	print( "useStartSpawnpoint: " + useStartSpawnpoint )

	array<entity> spawnpoints
	if ( useStartSpawnpoint )
		spawnpoints = isTitan ? SpawnPoints_GetTitanStart( team ) : SpawnPoints_GetPilotStart( team )
	else
		spawnpoints = isTitan ? SpawnPoints_GetTitan() : SpawnPoints_GetPilot()
	
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
	
	return validSpawns[ RandomInt( validSpawns.len() ) ] // slightly randomize it
}

bool function IsSpawnpointValid( entity spawnpoint, int team )
{
	//if ( !spawnpoint.HasKey( "ignoreGamemode" ) || ( spawnpoint.HasKey( "ignoreGamemode" ) && spawnpoint.kv.ignoreGamemode == "0" ) ) // used by script-spawned spawnpoints
	//{
	//	if ( file.spawnpointGamemodeOverride != "" )
	//	{
	//		string gamemodeKey = "gamemode_" + file.spawnpointGamemodeOverride
	//		if ( spawnpoint.HasKey( gamemodeKey ) && ( spawnpoint.kv[ gamemodeKey ] == "0" || spawnpoint.kv[ gamemodeKey ] == "" ) )
	//			return false
	//	}
	//	else if ( GameModeRemove( spawnpoint ) )
	//		return false
	//}
		
	if ( Riff_FloorIsLava() && spawnpoint.GetOrigin().z < GetLethalFogTop() )
		return false
	
	int compareTeam = spawnpoint.GetTeam()
	if ( file.sidesSwitched && ( compareTeam == TEAM_MILITIA || compareTeam == TEAM_IMC ) )
		compareTeam = GetOtherTeam( compareTeam )
	
	if ( spawnpoint.GetTeam() > 0 && compareTeam != team && !IsFFAGame() )
		return false
	
	if ( spawnpoint.IsOccupied() )
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

	array<entity> projectiles = GetProjectileArrayEx( "any", TEAM_ANY, TEAM_ANY, spawnpoint.GetOrigin(), 400 )
	foreach ( entity projectile in projectiles )
		if ( projectile.GetTeam() != team )
			return false
	
	if ( Time() - spawnpoint.s.lastUsedTime <= 1.0 )
		return false
		
	return true
}

void function RateSpawnpoints_Generic( int checkClass, array<entity> spawnpoints, int team, entity player )
{	
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

void function OnSwitchingSides()
{
	file.sidesSwitched = true
}