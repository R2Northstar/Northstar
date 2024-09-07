untyped

global function Spawn_Init
global function FindSpawnPoint

global function SetSpawnpointGamemodeOverride
global function GetSpawnpointGamemodeOverride
global function AddSpawnpointValidationRule

global function SetRespawnsEnabled
global function RespawnsEnabled
global function CreateNoSpawnArea
global function DeleteNoSpawnArea
global function SpawnPointInNoSpawnArea

global function RateSpawnpoints_Generic
global function RateSpawnpoints_Frontline
global function RateSpawnpoints_SpawnZones
global function DecideSpawnZone_Generic

global struct spawnZoneProperties{
	int controllingTeam = TEAM_UNASSIGNED
	entity minimapEnt = null
	float zoneRating = 0.0
}

global table< entity, spawnZoneProperties > mapSpawnZones // Global so other scripts can access this for custom ratings if needed

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
	array<NoSpawnArea> noSpawnAreas
	string spawnpointGamemodeOverride
	array< bool functionref( entity, int ) > customSpawnpointValidationRules
	bool shouldCreateMinimapSpawnzones
} file











/*
██████   █████  ███████ ███████     ███████ ██    ██ ███    ██  ██████ ████████ ██  ██████  ███    ██ ███████ 
██   ██ ██   ██ ██      ██          ██      ██    ██ ████   ██ ██         ██    ██ ██    ██ ████   ██ ██      
██████  ███████ ███████ █████       █████   ██    ██ ██ ██  ██ ██         ██    ██ ██    ██ ██ ██  ██ ███████ 
██   ██ ██   ██      ██ ██          ██      ██    ██ ██  ██ ██ ██         ██    ██ ██    ██ ██  ██ ██      ██ 
██████  ██   ██ ███████ ███████     ██       ██████  ██   ████  ██████    ██    ██  ██████  ██   ████ ███████ 
*/

void function Spawn_Init()
{
	// callbacks for generic spawns
	AddSpawnCallback( "info_spawnpoint_human", InitSpawnpoint )
	AddSpawnCallback( "info_spawnpoint_titan", InitSpawnpoint )
	AddSpawnCallback( "info_spawnpoint_droppod", InitSpawnpoint )
	AddSpawnCallback( "info_spawnpoint_dropship", InitSpawnpoint )
	AddSpawnCallback( "info_spawnpoint_human_start", InitSpawnpoint )
	AddSpawnCallback( "info_spawnpoint_titan_start", InitSpawnpoint )
	AddSpawnCallback( "info_spawnpoint_droppod_start", InitSpawnpoint )
	AddSpawnCallback( "info_spawnpoint_dropship_start", InitSpawnpoint )
	
	// callbacks for spawnzone spawns
	AddCallback_GameStateEnter( eGameState.Prematch, ResetSpawnzones )
	AddSpawnCallbackEditorClass( "trigger_multiple", "trigger_mp_spawn_zone", AddSpawnZoneTrigger )
	
	float friendlyAIValue = 1.75
	if ( GameModeHasCapturePoints() )
		friendlyAIValue = 0.75
	
	SpawnPoints_SetRatingMultipliers_Enemy( TD_TITAN, -10.0, -6.0, -1.0 )
	SpawnPoints_SetRatingMultipliers_Enemy( TD_PILOT, -10.0, -6.0, -1.0 )
	SpawnPoints_SetRatingMultipliers_Enemy( TD_AI, -2.0, -0.25, 0.0 )
	
	SpawnPoints_SetRatingMultipliers_Friendly( TD_TITAN, 0.25, 1.75, friendlyAIValue )
	SpawnPoints_SetRatingMultipliers_Friendly( TD_PILOT, 0.25, 1.75, friendlyAIValue )
	SpawnPoints_SetRatingMultipliers_Friendly( TD_AI, 0.5, 0.25, 0.0 )
	
	SpawnPoints_SetRatingMultiplier_PetTitan( 2.0 )
	
	file.shouldCreateMinimapSpawnzones = GetCurrentPlaylistVarInt( "spawn_zone_enabled", 1 ) != 0
}

void function SetRespawnsEnabled( bool enabled )
{
	file.respawnsEnabled = enabled
}

bool function RespawnsEnabled()
{
	return file.respawnsEnabled
}

void function InitSpawnpoint( entity spawnpoint ) 
{
	spawnpoint.s.lastUsedTime <- -999
	spawnpoint.s.inUse <- false
} 

string function CreateNoSpawnArea( int blockSpecificTeam, int blockEnemiesOfTeam, vector position, float lifetime, float radius )
{
	NoSpawnArea noSpawnArea
	noSpawnArea.blockedTeam = blockSpecificTeam
	noSpawnArea.blockOtherTeams = blockEnemiesOfTeam
	noSpawnArea.position = position
	noSpawnArea.lifetime = lifetime
	noSpawnArea.radius = radius
	
	noSpawnArea.id = UniqueString( "noSpawnArea" )
	
	if ( lifetime > 0 )
		thread NoSpawnAreaLifetime( noSpawnArea )
	
	file.noSpawnAreas.append( noSpawnArea )
	return noSpawnArea.id
}

void function NoSpawnAreaLifetime( NoSpawnArea noSpawnArea )
{
	wait noSpawnArea.lifetime
	DeleteNoSpawnArea( noSpawnArea.id )
}

void function DeleteNoSpawnArea( string noSpawnIdx )
{
	foreach ( noSpawnArea in file.noSpawnAreas )
	{
		if ( noSpawnArea.id == noSpawnIdx )
			file.noSpawnAreas.removebyvalue( noSpawnArea )
	}
}

bool function SpawnPointInNoSpawnArea( vector vec, int team )
{
	foreach ( noSpawnArea in file.noSpawnAreas )
	{
		if ( Distance( noSpawnArea.position, vec ) < noSpawnArea.radius )
		{
			if ( noSpawnArea.blockedTeam != TEAM_INVALID && noSpawnArea.blockedTeam == team )
				return true
			
			if ( noSpawnArea.blockOtherTeams != TEAM_INVALID && noSpawnArea.blockOtherTeams != team )
				return true
		}
	}
	
	return false
}

bool function IsSpawnpointValidDrop( entity spawnpoint, int team )
{
	if ( spawnpoint.IsOccupied() || spawnpoint.s.inUse )
		return false

	return true
}

void function AddSpawnpointValidationRule( bool functionref( entity spawn, int team ) rule )
{
	file.customSpawnpointValidationRules.append( rule )
}

void function SetSpawnpointGamemodeOverride( string gamemode )
{
	file.spawnpointGamemodeOverride = gamemode
}

string function GetSpawnpointGamemodeOverride()
{
	if ( file.spawnpointGamemodeOverride != "" )
		return file.spawnpointGamemodeOverride
	
	return GAMETYPE
}










/*
███████ ██████   █████  ██     ██ ███    ██      ██████  ██████  ██████  ███████ ██████  ██ ███    ██  ██████  
██      ██   ██ ██   ██ ██     ██ ████   ██     ██    ██ ██   ██ ██   ██ ██      ██   ██ ██ ████   ██ ██       
███████ ██████  ███████ ██  █  ██ ██ ██  ██     ██    ██ ██████  ██   ██ █████   ██████  ██ ██ ██  ██ ██   ███ 
     ██ ██      ██   ██ ██ ███ ██ ██  ██ ██     ██    ██ ██   ██ ██   ██ ██      ██   ██ ██ ██  ██ ██ ██    ██ 
███████ ██      ██   ██  ███ ███  ██   ████      ██████  ██   ██ ██████  ███████ ██   ██ ██ ██   ████  ██████  
*/

entity function FindSpawnPoint( entity player, bool isTitan, bool useStartSpawnpoint )
{
	int team = player.GetTeam()
	
	array<entity> spawnpoints
	if ( useStartSpawnpoint )
		spawnpoints = isTitan ? SpawnPoints_GetTitanStart( team ) : SpawnPoints_GetPilotStart( team )
	else
		spawnpoints = isTitan ? SpawnPoints_GetTitan() : SpawnPoints_GetPilot()
	
	SpawnPoints_InitRatings( player, team )
	
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
	
	entity spawnpoint = GetBestSpawnpoint( player, spawnpoints, isTitan )
		
	spawnpoint.s.lastUsedTime = Time()
	player.SetLastSpawnPoint( spawnpoint )
	
	//SpawnPoints_DiscardRatings()
		
	return spawnpoint
}

entity function GetBestSpawnpoint( entity player, array<entity> spawnpoints, bool isTitan )
{
	array<entity> validSpawns
	
	// I know this looks hacky but the native funcs to get the spawns is returning null arrays for FFA idk why.
	if ( IsFFAGame() )
	{
		spawnpoints.clear()
		if ( isTitan )
			spawnpoints = GetEntArrayByClass_Expensive( "info_spawnpoint_titan" )
		else
			spawnpoints = GetEntArrayByClass_Expensive( "info_spawnpoint_human" )
	}
	
	foreach ( entity spawnpoint in spawnpoints )
	{
		if ( IsSpawnpointValid( spawnpoint, player.GetTeam() ) )
			validSpawns.append( spawnpoint )
	}
	
	if ( !validSpawns.len() ) // First validity check
	{
		CodeWarning( "Map has no valid spawn points for " + GAMETYPE + " gamemode, attempting any other possible spawn point" )
		foreach ( entity spawnpoint in spawnpoints )
			validSpawns.append( spawnpoint )
	}
	
	if ( !validSpawns.len() ) // On all validity check, just gather the most basic spawn
	{
		CodeWarning( "Map has no proper spawn points, falling back to info_player_start" )
		entity start = GetEnt( "info_player_start" )
		
		if ( IsValid( start ) )
		{
			start.s.lastUsedTime <- -999
			validSpawns.append( start )
		}
		else
			throw( "Map has no player spawns at all" )
	}
	
	if ( IsFFAGame() )
		return validSpawns.getrandom()
	
	return validSpawns[0] // Return first entry in the array because native have already sorted everything through the ratings, so first one is the best one
}

bool function IsSpawnpointValid( entity spawnpoint, int team )
{
	if ( !spawnpoint.HasKey( "ignoreGamemode" ) || spawnpoint.HasKey( "ignoreGamemode" ) && spawnpoint.kv.ignoreGamemode == "0" ) // used by script-spawned spawnpoints
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
	
	foreach ( bool functionref( entity, int ) customValidationRule in file.customSpawnpointValidationRules )
		if ( !customValidationRule( spawnpoint, team ) )
			return false
		
	if ( !IsSpawnpointValidDrop( spawnpoint, team ) || Time() - spawnpoint.s.lastUsedTime <= 10.0 )
		return false
	
	if ( SpawnPointInNoSpawnArea( spawnpoint.GetOrigin(), team ) )
		return false

	// Line of Sight Check, could use IsVisibleToEnemies but apparently that considers only players, not NPCs
	array< entity > enemyTitans = GetTitanArrayOfEnemies( team )
	if ( GetConVarBool( "spawnpoint_avoid_npc_titan_sight" ) )
	{
		foreach ( titan in enemyTitans )
		{
			if ( IsAlive( titan ) && titan.IsNPC() && titan.CanSee( spawnpoint ) )
				return false
		}
	}
	
	return !spawnpoint.IsVisibleToEnemies( team )
}










/*
██████   ██████  ██ ███    ██ ████████     ██████   █████  ████████ ██ ███    ██  ██████  
██   ██ ██    ██ ██ ████   ██    ██        ██   ██ ██   ██    ██    ██ ████   ██ ██       
██████  ██    ██ ██ ██ ██  ██    ██        ██████  ███████    ██    ██ ██ ██  ██ ██   ███ 
██      ██    ██ ██ ██  ██ ██    ██        ██   ██ ██   ██    ██    ██ ██  ██ ██ ██    ██ 
██       ██████  ██ ██   ████    ██        ██   ██ ██   ██    ██    ██ ██   ████  ██████  
*/

void function RateSpawnpoints_Generic( int checkClass, array<entity> spawnpoints, int team, entity player )
{	
	foreach ( entity spawnpoint in spawnpoints )
	{
		float currentRating = 0.0
		
		// Gather friendly scoring first to give positive rating first
		currentRating += spawnpoint.NearbyAllyScore( team, "ai" )
		currentRating += spawnpoint.NearbyAllyScore( team, "titan" )
		currentRating += spawnpoint.NearbyAllyScore( team, "pilot" )
		
		// Enemies then subtract that rating ( Values already returns negative, so no need to apply subtract again )
		currentRating += spawnpoint.NearbyEnemyScore( team, "ai" )
		currentRating += spawnpoint.NearbyEnemyScore( team, "titan" )
		currentRating += spawnpoint.NearbyEnemyScore( team, "pilot" )
		
		if ( spawnpoint == player.p.lastSpawnPoint ) // Reduce the rating of the spawn point used previously
			currentRating += GetConVarFloat( "spawnpoint_last_spawn_rating" )
		
		spawnpoint.CalculateRating( checkClass, team, currentRating, currentRating * 0.25 )
	}
}

void function RateSpawnpoints_Frontline( int checkClass, array<entity> spawnpoints, int team, entity player )
{
	Frontline currentFrontline = GetFrontline( team )
	
	vector inverseFrontlineDir = currentFrontline.combatDir * -1
	vector adjustedPosition = currentFrontline.origin + currentFrontline.combatDir * 8000
	
	SpawnPoints_InitFrontlineData( adjustedPosition, currentFrontline.combatDir, currentFrontline.origin, currentFrontline.friendlyCenter, 4000 )
	
	foreach ( entity spawnpoint in spawnpoints )
	{
		float frontlineRating = spawnpoint.CalculateFrontlineRating()
		
		spawnpoint.CalculateRating( checkClass, team, frontlineRating, frontlineRating * 0.25 )
	}
}










/*
███████ ██████   █████  ██     ██ ███    ██ ███████  ██████  ███    ██ ███████ ███████ 
██      ██   ██ ██   ██ ██     ██ ████   ██    ███  ██    ██ ████   ██ ██      ██      
███████ ██████  ███████ ██  █  ██ ██ ██  ██   ███   ██    ██ ██ ██  ██ █████   ███████ 
     ██ ██      ██   ██ ██ ███ ██ ██  ██ ██  ███    ██    ██ ██  ██ ██ ██           ██ 
███████ ██      ██   ██  ███ ███  ██   ████ ███████  ██████  ██   ████ ███████ ███████ 
*/

void function ResetSpawnzones()
{
	foreach ( zone, zoneProperties in mapSpawnZones )
	{
		if ( IsValid( zoneProperties.minimapEnt ) )
			zoneProperties.minimapEnt.Destroy()
		
		zoneProperties.controllingTeam = TEAM_UNASSIGNED
		zoneProperties.zoneRating = 0.0
	}
}

void function AddSpawnZoneTrigger( entity trigger )
{
	spawnZoneProperties zoneProperties
	mapSpawnZones[trigger] <- zoneProperties
}

bool function TeamHasDirtySpawnzone( int team )
{
	foreach ( zone, zoneProperties in mapSpawnZones )
	{
		if ( zoneProperties.controllingTeam == team )
		{
			int numDeadInZone = 0
			array<entity> teamPlayers = GetPlayerArrayOfTeam( team )
			foreach ( entity player in teamPlayers )
			{
				if ( Time() - player.p.postDeathThreadStartTime < 20.0 && zone.ContainsPoint( player.p.deathOrigin ) )
					numDeadInZone++
			}
			
			if ( numDeadInZone < teamPlayers.len() )
				return false
		}
	}
	
	return true
}

void function CreateTeamSpawnZoneEntity( entity spawnzone, int team )
{
	entity minimapObj = CreatePropScript( $"models/dev/empty_model.mdl", spawnzone.GetOrigin() )
	SetTeam( minimapObj, team )	
	minimapObj.Minimap_SetObjectScale( Distance2D( < 0, 0, 0 >, spawnzone.GetBoundingMaxs() ) / 16000 ) // 16000 cuz thats the total space Minimap uses
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
	mapSpawnZones[spawnzone].minimapEnt = minimapObj
}

void function RateSpawnpoints_SpawnZones( int checkClass, array<entity> spawnpoints, int team, entity player )
{
	if ( ShouldStartSpawn( player ) )
	{
		RateSpawnpoints_Generic( checkClass, spawnpoints, team, player )
		return
	}
	
	array< entity > zoneTriggers
	foreach ( zone, zoneProperties in mapSpawnZones )
		zoneTriggers.append( zone )
	
	entity spawnzone = DecideSpawnZone_Generic( zoneTriggers, player.GetTeam() )	
	if ( !IsValid( spawnzone ) )
	{
		RateSpawnpoints_Generic( checkClass, spawnpoints, team, player )
		return
	}
	
	foreach ( entity spawn in spawnpoints ) 
	{
		float rating = 0.0
		float distance = Distance2D( spawn.GetOrigin(), spawnzone.GetOrigin() )
		if ( distance < Distance2D( < 0, 0, 0 >, spawnzone.GetBoundingMaxs() ) )
			rating = 10.0
		else
			rating = 2.0 * ( 1 - ( distance / 3000.0 ) )
			
		spawn.CalculateRating( checkClass, team, rating, rating * 0.25 )
	}
}

entity function DecideSpawnZone_Generic( array<entity> spawnzones, int team )
{
	if ( !spawnzones.len() )
		return null
	
	array<entity> startSpawns = SpawnPoints_GetPilotStart( team )
	array<entity> enemyStartSpawns = SpawnPoints_GetPilotStart( GetOtherTeam( team ) )
	
	if ( !startSpawns.len() || !enemyStartSpawns.len() )
		return null

	vector averageFriendlySpawns
	foreach ( entity spawn in startSpawns )
		averageFriendlySpawns += spawn.GetOrigin()
	
	averageFriendlySpawns /= startSpawns.len()
	
	vector averageEnemySpawns
	foreach ( entity spawn in enemyStartSpawns )
		averageEnemySpawns += spawn.GetOrigin()
	
	averageEnemySpawns /= enemyStartSpawns.len()
	
	float baseDistance = Distance2D( averageFriendlySpawns, averageEnemySpawns )
	
	if ( TeamHasDirtySpawnzone( team ) )
	{
		array<entity> possibleZones
		foreach ( zone, zoneProperties in mapSpawnZones )
		{
			if ( zoneProperties.controllingTeam == GetOtherTeam( team ) )
				continue
			
			bool spawnzoneHasEnemies = false
			foreach ( entity enemy in GetPlayerArrayOfEnemies_Alive( team ) )
			{
				if ( zone.ContainsPoint( enemy.GetOrigin() ) )
				{
					spawnzoneHasEnemies = true
					break
				}
			}
			
			if ( !spawnzoneHasEnemies && Distance2D( zone.GetOrigin(), averageFriendlySpawns ) > Distance2D( zone.GetOrigin(), averageEnemySpawns ) )
				spawnzoneHasEnemies = true
			
			if ( spawnzoneHasEnemies )
				continue
			
			Frontline frontline = GetFrontline( team )
			float rating = 10 * ( 1.0 - Distance2D( averageFriendlySpawns, zone.GetOrigin() ) / baseDistance )
		
			if ( frontline.friendlyCenter != < 0, 0, 0 > )
			{
				rating += rating * ( 1.0 - ( Distance2D( zone.GetOrigin(), frontline.friendlyCenter ) / baseDistance ) )
				rating *= fabs( frontline.combatDir.y - Normalize( zone.GetOrigin() - averageFriendlySpawns ).y )
			}
			
			zoneProperties.zoneRating = rating
			possibleZones.append( zone )
		}
		
		if ( !possibleZones.len() )
			return null
		
		possibleZones.sort( SortPossibleZones )
		
		entity chosenZone = possibleZones[ minint( RandomInt( 3 ), possibleZones.len() - 1 ) ]
		
		if ( file.shouldCreateMinimapSpawnzones )
		{
			foreach ( zone, zoneProperties in mapSpawnZones )
			{
				if ( chosenZone == zone )
					continue
				
				if ( IsValid( zoneProperties.minimapEnt ) && zoneProperties.controllingTeam == team )
					zoneProperties.minimapEnt.Destroy()
			}
			
			CreateTeamSpawnZoneEntity( chosenZone, team )
		}
		
		foreach ( zone, zoneProperties in mapSpawnZones )
		{
			if ( chosenZone == zone )
				continue
				
			if ( zoneProperties.controllingTeam == team )
				zoneProperties.controllingTeam = TEAM_UNASSIGNED
		}
		
		mapSpawnZones[chosenZone].controllingTeam = team
		return chosenZone
	}
	
	return null
}

int function SortPossibleZones( entity a, entity b ) 
{
	if ( mapSpawnZones[a].zoneRating > mapSpawnZones[b].zoneRating )
		return -1
		
	if ( mapSpawnZones[b].zoneRating > mapSpawnZones[a].zoneRating )
		return 1
		
	return 0
}