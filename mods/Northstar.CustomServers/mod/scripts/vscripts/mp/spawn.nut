untyped

global function InitRatings // temp for testing

global function Spawn_Init
global function SetSpawnsUseFrontline
global function SetRespawnsEnabled
global function RespawnsEnabled
global function SetSpawnpointGamemodeOverride
global function GetSpawnpointGamemodeOverride
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

	table<string, NoSpawnArea> noSpawnAreas
	
	bool frontlineBased = false
	float lastImcFrontlineRatingTime
	float lastMilitiaFrontlineRatingTime
	Frontline& lastImcFrontline
	Frontline& lastMilitiaFrontline
} file

void function Spawn_Init()
{	
	AddSpawnCallback( "info_spawnpoint_human", InitSpawnpoint )
	AddSpawnCallback( "info_spawnpoint_human_start", InitSpawnpoint )
	AddSpawnCallback( "info_spawnpoint_titan", InitSpawnpoint )
	AddSpawnCallback( "info_spawnpoint_titan_start", InitSpawnpoint )
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

// this sucks
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
	if ( HasSwitchedSides() )
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
		
	if ( Riff_FloorIsLava() && spawnpoint.GetOrigin().z < GetLethalFogTop() )
		return false
	
	int compareTeam = spawnpoint.GetTeam()
	if ( HasSwitchedSides() && ( compareTeam == TEAM_MILITIA || compareTeam == TEAM_IMC ) )
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
		
		// check distance, constant here is basically arbitrary
		if ( Distance( enemyPlayer, spawnpoint ) > 1000.0 )
			continue
		
		// check fov, constant here is stolen from every other place this is done
		if ( VectorDot_PlayerToOrigin( enemyPlayer, spawnpoint.GetOrigin() ) < 0.8 )
			continue
		
		// check actual los
		if ( TraceLineSimple( enemyPlayer.EyePosition(), spawnpoint.GetOrigin() + < 0, 0, 48 >, enemyPlayer ) == 1.0 )
			return false
	}
	
	if ( Time() - spawnpoint.s.lastUsedTime <= 1.0 )
		return false
		
	return true
}

void function RateSpawnpoints_Generic( int checkClass, array<entity> spawnpoints, int team, entity player )
{	
	// generic spawns v2
	array<entity> startSpawns = checkClass == TD_TITAN ? SpawnPoints_GetTitanStart( team ) : SpawnPoints_GetPilotStart( team )
	
	// realistically, this should spawn people fairly spread out across the map, preferring being closer to their startspawns
	// should spawn like, near fights, but not in them
}