untyped
global function GamemodeAITdm_Init

const SQUADS_PER_TEAM = 3

const REAPERS_PER_TEAM = 2

const LEVEL_SPECTRES = 125
const LEVEL_STALKERS = 380
const LEVEL_REAPERS = 500

struct
{
	// Due to team based escalation everything is an array
	array< int > levels = [ LEVEL_SPECTRES, LEVEL_SPECTRES ]
	array< array< string > > podEntities = [ [ "npc_soldier" ], [ "npc_soldier" ] ]
	array< bool > reapers = [ false, false ]
} file


void function GamemodeAITdm_Init()
{
	SetSpawnpointGamemodeOverride( ATTRITION ) // use bounty hunt spawns as vanilla game has no spawns explicitly defined for aitdm

	AddCallback_GameStateEnter( eGameState.Prematch, OnPrematchStart )
	AddCallback_GameStateEnter( eGameState.Playing, OnPlaying )
	
	AddCallback_OnNPCKilled( HandleScoreEvent )
	AddCallback_OnPlayerKilled( HandleScoreEvent )
		
	AddCallback_OnClientConnected( OnPlayerConnected )
	
	AddCallback_NPCLeeched( OnSpectreLeeched )
	
	if ( GetCurrentPlaylistVarInt( "aitdm_archer_grunts", 0 ) == 0 )
	{
		AiGameModes_SetGruntWeapons( [ "mp_weapon_rspn101", "mp_weapon_dmr", "mp_weapon_r97", "mp_weapon_lmg" ] )
		AiGameModes_SetSpectreWeapons( [ "mp_weapon_hemlok_smg", "mp_weapon_doubletake", "mp_weapon_mastiff" ] )
	}
	else
	{
		AiGameModes_SetGruntWeapons( [ "mp_weapon_rocket_launcher" ] )
		AiGameModes_SetSpectreWeapons( [ "mp_weapon_rocket_launcher" ] )
	}
	
	ScoreEvent_SetupEarnMeterValuesForMixedModes()
}

// Starts skyshow, this also requiers AINs but doesn't crash if they're missing
void function OnPrematchStart()
{
	thread StratonHornetDogfightsIntense()
}

void function OnPlaying()
{	
	// don't run spawning code if ains and nms aren't up to date
	if ( GetAINScriptVersion() == AIN_REV && GetNodeCount() != 0 )
	{
		thread SpawnIntroBatch_Threaded( TEAM_MILITIA )
		thread SpawnIntroBatch_Threaded( TEAM_IMC )
	}
}

// Sets up mode specific hud on client
void function OnPlayerConnected( entity player )
{
	Remote_CallFunction_NonReplay( player, "ServerCallback_AITDM_OnPlayerConnected" )
}

// Used to handle both player and ai events
void function HandleScoreEvent( entity victim, entity attacker, var damageInfo )
{
	// Basic checks
	if ( victim == attacker || !( attacker.IsPlayer() || attacker.IsTitan() ) || GetGameState() != eGameState.Playing )
		return
	
	// Hacked spectre filter
	if ( victim.GetOwner() == attacker )
		return
	
	// Split score so we can check if we are over the score max
	// without showing the wrong value on client
	int teamScore
	int playerScore
	string eventName
	
	// Handle AI, marvins aren't setup so we check for them to prevent crash
	if ( victim.IsNPC() && victim.GetClassName() != "npc_marvin" )
	{
		switch ( victim.GetClassName() )
		{
			case "npc_soldier":
			case "npc_spectre":
			case "npc_stalker":
				playerScore = 1
				break
			case "npc_super_spectre":
				playerScore = 3
				break
			default:
				playerScore = 0
				break
		}
		
		// Titan kills get handled bellow this
		if ( eventName != "KillNPCTitan"  && eventName != "" )
			playerScore = ScoreEvent_GetPointValue( GetScoreEvent( eventName ) )
	}
	
	if ( victim.IsPlayer() )
		playerScore = 5
	
	// Player ejecting triggers this without the extra check
	if ( victim.IsTitan() && victim.GetBossPlayer() != attacker )
		playerScore += 10
	
	
	teamScore = playerScore
	
	// Check score so we dont go over max
	if ( GameRules_GetTeamScore(attacker.GetTeam()) + teamScore > GetScoreLimit_FromPlaylist() )
		teamScore = GetScoreLimit_FromPlaylist() - GameRules_GetTeamScore(attacker.GetTeam())
	
	// Add score + update network int to trigger the "Score +n" popup
	AddTeamScore( attacker.GetTeam(), teamScore )
	attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, playerScore )
	attacker.SetPlayerNetInt("AT_bonusPoints", attacker.GetPlayerGameStat( PGS_ASSAULT_SCORE ) )
}

// When attrition starts both teams spawn ai on preset nodes, after that
// Spawner_Threaded is used to keep the match populated
void function SpawnIntroBatch_Threaded( int team )
{
	array<entity> dropPodNodes = GetEntArrayByClass_Expensive( "info_spawnpoint_droppod_start" )
	array<entity> dropShipNodes = GetValidIntroDropShipSpawn( dropPodNodes )  
	
	array<entity> podNodes
	
	array<entity> shipNodes
	
	
	// mp_rise has weird droppod_start nodes, this gets around it
	// To be more specific the teams aren't setup and some nodes are scattered in narnia
	if( GetMapName() == "mp_rise" )
	{
		entity spawnPoint
		
		// Get a spawnpoint for team
		foreach ( point in GetEntArrayByClass_Expensive( "info_spawnpoint_dropship_start" ) )
		{
			if ( point.HasKey( "gamemode_tdm" ) )
				if ( point.kv[ "gamemode_tdm" ] == "0" )
					continue
			
			if ( point.GetTeam() == team )
			{
				spawnPoint = point
				break
			}
		}
		
		// Get nodes close enough to team spawnpoint
		foreach ( node in dropPodNodes )
		{
			if ( node.HasKey("teamnum") && Distance2D( node.GetOrigin(), spawnPoint.GetOrigin()) < 2000 )
				podNodes.append( node )
		}
	}
	else
	{
		// Sort per team
		foreach ( node in dropPodNodes )
		{
			if ( node.GetTeam() == team )
				podNodes.append( node )
		}
	}

	shipNodes = GetValidIntroDropShipSpawn( podNodes )


	// Spawn logic
	int startIndex = 0
	bool first = true
	entity node
	
	int pods = RandomInt( podNodes.len() + 1 )
	
	int ships = shipNodes.len()
	
	for ( int i = 0; i < SQUADS_PER_TEAM; i++ )
	{
		if ( pods != 0 || ships == 0 )
		{
			int index = i
			
			if ( index > podNodes.len() - 1 )
			index = RandomInt( podNodes.len() )
			
			node = podNodes[ index ]
			thread AiGameModes_SpawnDropPod( node.GetOrigin(), node.GetAngles(), team, "npc_soldier", SquadHandler )
			
			pods--
		}
		else
		{
			if ( startIndex == 0 ) 
			startIndex = i // save where we started
			
			node = shipNodes[ i - startIndex ]
			thread AiGameModes_SpawnDropShip( node.GetOrigin(), node.GetAngles(), team, 4, SquadHandler )
			
			ships--
		}
		
		// Vanilla has a delay after first spawn
		if ( first )
			wait 2
		
		first = false
	}
	
	wait 15
	
	thread Spawner_Threaded( team )
}

// Populates the match
void function Spawner_Threaded( int team )
{
	svGlobal.levelEnt.EndSignal( "GameStateChanged" )

	// used to index into escalation arrays
	int index = team == TEAM_MILITIA ? 0 : 1
	
	
	while( true )
	{
		Escalate( team )
		
		// TODO: this should possibly not count scripted npc spawns, probably only the ones spawned by this script
		array<entity> npcs = GetNPCArrayOfTeam( team )
		int count = npcs.len()
		int reaperCount = GetNPCArrayEx( "npc_super_spectre", team, -1, <0,0,0>, -1 ).len()
		
		// REAPERS
		if ( file.reapers[ index ] )
		{
			array< entity > points = SpawnPoints_GetDropPod()
			if ( reaperCount < REAPERS_PER_TEAM )
			{
				entity node = points[ GetSpawnPointIndex( points, team ) ]
				waitthread AiGameModes_SpawnReaper( node.GetOrigin(), node.GetAngles(), team, "npc_super_spectre_aitdm", ReaperHandler )
			}
		}
		
		// NORMAL SPAWNS
		if ( count < SQUADS_PER_TEAM * 4 - 2 )
		{
			string ent = file.podEntities[ index ][ RandomInt( file.podEntities[ index ].len() ) ]
			
			array< entity > points = GetZiplineDropshipSpawns()
			// Prefer dropship when spawning grunts
			if ( ent == "npc_soldier" && points.len() != 0 )
			{
				if ( RandomInt( points.len() ) )
				{
					entity node = points[ GetSpawnPointIndex( points, team ) ]
					waitthread Aitdm_SpawnDropShip( node, team )
					continue
				}
			}
			
			points = SpawnPoints_GetDropPod()
			entity node = points[ GetSpawnPointIndex( points, team ) ]
			waitthread AiGameModes_SpawnDropPod( node.GetOrigin(), node.GetAngles(), team, ent, SquadHandler )
		}
		
		WaitFrame()
	}
}

void function Aitdm_SpawnDropShip( entity node, int team )
{
	thread AiGameModes_SpawnDropShip( node.GetOrigin(), node.GetAngles(), team, 4, SquadHandler )
	wait 20
}

// Based on points tries to balance match
void function Escalate( int team )
{
	int score = GameRules_GetTeamScore( team )
	int index = team == TEAM_MILITIA ? 1 : 0
	// This does the "Enemy x incoming" text
	string defcon = team == TEAM_MILITIA ? "IMCdefcon" : "MILdefcon"
	
	// Return if the team is under score threshold to escalate
	if ( score < file.levels[ index ] || file.reapers[ index ] )
		return
	
	// Based on score escalate a team
	switch ( file.levels[ index ] )
	{
		case LEVEL_SPECTRES:
			file.levels[ index ] = LEVEL_STALKERS
			file.podEntities[ index ].append( "npc_spectre" )
			SetGlobalNetInt( defcon, 2 )
			return
		
		case LEVEL_STALKERS:
			file.levels[ index ] = LEVEL_REAPERS
			file.podEntities[ index ].append( "npc_stalker" )
			SetGlobalNetInt( defcon, 3 )
			return
		
		case LEVEL_REAPERS:
			file.reapers[ index ] = true
			SetGlobalNetInt( defcon, 4 )
			return
	}
	
	unreachable // hopefully
}


// Decides where to spawn ai
// Each team has their "zone" where they and their ai spawns
// These zones should swap based on which team is dominating where
int function GetSpawnPointIndex( array< entity > points, int team )
{
	entity zone = DecideSpawnZone_Generic( points, team )
	
	if ( IsValid( zone ) )
	{
		// 20 Tries to get a random point close to the zone
		for ( int i = 0; i < 20; i++ )
		{
			int index = RandomInt( points.len() )
		
			if ( Distance2D( points[ index ].GetOrigin(), zone.GetOrigin() ) < 6000 )
				return index
		}
	}
	
	return RandomInt( points.len() )
}

// tells infantry where to go
// In vanilla there seem to be preset paths ai follow to get to the other teams vone and capture it
// AI can also flee deeper into their zone suggesting someone spent way too much time on this
void function SquadHandler( array<entity> guys )
{
	// Not all maps have assaultpoints / have weird assault points ( looking at you ac )
	// So we use enemies with a large radius
	array< entity > points = GetNPCArrayOfEnemies( guys[0].GetTeam() )
	
	if ( points.len()  == 0 )
		return
	
	vector point
	point = points[ RandomInt( points.len() ) ].GetOrigin()
	
	array<entity> players = GetPlayerArrayOfEnemies( guys[0].GetTeam() )
	
	// Setup AI
	foreach ( guy in guys )
	{
		guy.EnableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE )
		guy.AssaultPoint( point )
		guy.AssaultSetGoalRadius( 1600 ) // 1600 is minimum for npc_stalker, works fine for others
		
		// show on enemy radar
		foreach ( player in players )
			guy.Minimap_AlwaysShow( 0, player )
		
		
		//thread AITdm_CleanupBoredNPCThread( guy )
	}
	
	// Every 5 - 15 secs change AssaultPoint
	while ( true )
	{	
		foreach ( guy in guys )
		{
			// Check if alive
			if ( !IsAlive( guy ) )
			{
				guys.removebyvalue( guy )
				continue
			}
			// Stop func if our squad has been killed off
			if ( guys.len() == 0 )
				return
			
			// Get point and send guy to it
			points = GetNPCArrayOfEnemies( guy.GetTeam() )
			if ( points.len() == 0 )
				continue
				
			point = points[ RandomInt( points.len() ) ].GetOrigin()
			
			guy.AssaultPoint( point )
		}
		wait RandomFloatRange(5.0,15.0)
	}
}

// Award for hacking
void function OnSpectreLeeched( entity spectre, entity player )
{
	// Set Owner so we can filter in HandleScore
	spectre.SetOwner( player )
	// Add score + update network int to trigger the "Score +n" popup
	AddTeamScore( player.GetTeam(), 1 )
	player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, 1 )
	player.SetPlayerNetInt("AT_bonusPoints", player.GetPlayerGameStat( PGS_ASSAULT_SCORE ) )
}

// Same as SquadHandler, just for reapers
void function ReaperHandler( entity reaper )
{
	array<entity> players = GetPlayerArrayOfEnemies( reaper.GetTeam() )
	foreach ( player in players )
		reaper.Minimap_AlwaysShow( 0, player )
	
	reaper.AssaultSetGoalRadius( 500 )
	
	// Every 10 - 20 secs get a player and go to him
	// Definetly not annoying or anything :)
	while( IsAlive( reaper ) )
	{
		players = GetPlayerArrayOfEnemies( reaper.GetTeam() )
		if ( players.len() != 0 )
		{
			entity player = GetClosest2D( players, reaper.GetOrigin() )
			reaper.AssaultPoint( player.GetOrigin() )
		}
		wait RandomFloatRange(10.0,20.0)
	}
	// thread AITdm_CleanupBoredNPCThread( reaper )
}

// Currently unused as this is handled by SquadHandler
// May need to use this if my implementation falls apart
void function AITdm_CleanupBoredNPCThread( entity guy )
{
	// track all ai that we spawn, ensure that they're never "bored" (i.e. stuck by themselves doing fuckall with nobody to see them) for too long
	// if they are, kill them so we can free up slots for more ai to spawn
	// we shouldn't ever kill ai if players would notice them die
	
	// NOTE: this partially covers up for the fact that we script ai alot less than vanilla probably does
	// vanilla probably messes more with making ai assaultpoint to fights when inactive and stuff like that, we don't do this so much

	guy.EndSignal( "OnDestroy" )
	wait 15.0 // cover spawning time from dropship/pod + before we start cleaning up
	
	int cleanupFailures = 0 // when this hits 2, cleanup the npc
	while ( cleanupFailures < 2 )
	{
		wait 10.0
	
		if ( guy.GetParent() != null )
			continue // never cleanup while spawning
	
		array<entity> otherGuys = GetPlayerArray()
		otherGuys.extend( GetNPCArrayOfTeam( GetOtherTeam( guy.GetTeam() ) ) )
		
		bool failedChecks = false
		
		foreach ( entity otherGuy in otherGuys )
		{	
			// skip dead people
			if ( !IsAlive( otherGuy ) )
				continue
		
			failedChecks = false
		
			// don't kill if too close to anything
			if ( Distance( otherGuy.GetOrigin(), guy.GetOrigin() ) < 2000.0 )
				break
			
			// don't kill if ai or players can see them
			if ( otherGuy.IsPlayer() )
			{
				if ( PlayerCanSee( otherGuy, guy, true, 135 ) )
					break
			}
			else
			{
				if ( otherGuy.CanSee( guy ) )
					break
			}
			
			// don't kill if they can see any ai
			if ( guy.CanSee( otherGuy ) )
				break
				
			failedChecks = true
		}
		
		if ( failedChecks )
			cleanupFailures++
		else
			cleanupFailures--
	}
	
	print( "cleaning up bored npc: " + guy + " from team " + guy.GetTeam() )
	guy.Destroy()
}