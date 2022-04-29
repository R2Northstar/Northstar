global function GamemodeAt_Init
global function RateSpawnpoints_AT

const int BH_AI_TEAM = TEAM_BOTH
const int BOUNTY_TITAN_DAMAGE_POOL = 400 // Rewarded for damage
const int BOUNTY_TITAN_KILL_REWARD = 100 // Rewarded for kill
const float WAVE_STATE_TRANSITION_TIME = 5.0

const array<string> VALID_BOUNTY_TITAN_SETTINGS = [
	"npc_titan_atlas_stickybomb_bounty",
	"npc_titan_atlas_tracker_bounty",
	"npc_titan_ogre_minigun_bounty",
	"npc_titan_ogre_meteor_bounty",
	"npc_titan_stryder_leadwall_bounty",
	"npc_titan_stryder_sniper_bounty",
	"npc_titan_atlas_vanguard_bounty"
]


// IMPLEMENTATION NOTES:
// bounty hunt is a mode that was clearly pretty heavily developed, and had alot of scrapped concepts (i.e. most wanted player bounties, turret bounties, collectable blackbox objectives)
// in the interest of time, this script isn't gonna support any of that atm
// alot of the remote functions also take parameters that aren't used, i'm not gonna populate these and just use default values for now instead
// however, if you do want to mess with this stuff, almost all the remote functions for this stuff are still present in cl_gamemode_at, and should work fine with minimal fuckery in my experience

struct {
	array<entity> campsToRegisterOnEntitiesDidLoad

	array<entity> banks 
	array<AT_WaveOrigin> camps
	
	table< int, table< string, int > > trackedCampNPCSpawns
} file

void function GamemodeAt_Init()
{
	AddCallback_GameStateEnter( eGameState.Playing, RunATGame )
	
	AddCallback_OnClientConnected( InitialiseATPlayer )

	AddSpawnCallbackEditorClass( "info_target", "info_attrition_bank", CreateATBank )
	AddSpawnCallbackEditorClass( "info_target", "info_attrition_camp", CreateATCamp )
	AddCallback_EntitiesDidLoad( CreateATCamps_Delayed )
}

void function RateSpawnpoints_AT( int checkclass, array<entity> spawnpoints, int team, entity player )
{
	RateSpawnpoints_Generic( checkclass, spawnpoints, team, player ) // temp 
}

// world and player inits

void function InitialiseATPlayer( entity player )
{
	Remote_CallFunction_NonReplay( player, "ServerCallback_AT_OnPlayerConnected" )
}

void function CreateATBank( entity spawnpoint )
{
	entity bank = CreatePropDynamic( spawnpoint.GetModelName(), spawnpoint.GetOrigin(), spawnpoint.GetAngles(), SOLID_VPHYSICS )
	bank.SetScriptName( "AT_Bank" )
	
	// create tracker ent
	// we don't need to store these at all, client just needs to get them
	DispatchSpawn( GetAvailableBankTracker( bank ) )
	
	thread PlayAnim( bank, "mh_inactive_idle" )
	
	file.banks.append( bank )
}

void function CreateATCamp( entity spawnpoint )
{
	// delay this so we don't do stuff before all spawns are initialised and that
	file.campsToRegisterOnEntitiesDidLoad.append( spawnpoint )
}

void function CreateATCamps_Delayed()
{
	// we delay registering camps until EntitiesDidLoad since they rely on spawnpoints and stuff, which might not all be ready in the creation callback
	// unsure if this would be an issue in practice, but protecting against it in case it would be
	foreach ( entity camp in file.campsToRegisterOnEntitiesDidLoad )
	{
		AT_WaveOrigin campStruct
		campStruct.ent = camp
		campStruct.origin = camp.GetOrigin()
		campStruct.radius = expect string( camp.kv.radius ).tofloat()
		campStruct.height = expect string( camp.kv.height ).tofloat()
		
		// assumes every info_attrition_camp will have all 9 phases, possibly not a good idea?
		for ( int i = 0; i < 9; i++ )
			campStruct.phaseAllowed.append( expect string( camp.kv[ "phase_" + ( i + 1 ) ] ) == "1" )
		
		// get droppod spawns
		foreach ( entity spawnpoint in SpawnPoints_GetDropPod() )
			if ( Distance( camp.GetOrigin(), spawnpoint.GetOrigin() ) < 1500.0 )
				campStruct.dropPodSpawnPoints.append( spawnpoint )
		
		foreach ( entity spawnpoint in SpawnPoints_GetTitan() )
			if ( Distance( camp.GetOrigin(), spawnpoint.GetOrigin() ) < 1500.0 )
				campStruct.titanSpawnPoints.append( spawnpoint )
	
		// todo: turret spawns someday maybe
	
		file.camps.append( campStruct )
	}
	
	file.campsToRegisterOnEntitiesDidLoad.clear()
}

// scoring funcs

// don't use this where possible as it doesn't set score and stuff
void function AT_SetPlayerCash( entity player, int amount )
{
	// split into stacks of 256 where necessary
	int stacks = amount / 256 // automatically rounds down because int division

	player.SetPlayerNetInt( "AT_bonusPoints256", stacks )
	player.SetPlayerNetInt( "AT_bonusPoints", amount - stacks * 256 )
}

void function AT_AddPlayerCash( entity player, int amount )
{
	// update score difference
	AddTeamScore( player.GetTeam(), amount / 2 )
	AT_SetPlayerCash( player, player.GetPlayerNetInt( "AT_bonusPoints" ) + ( player.GetPlayerNetInt( "AT_bonusPoints256" ) * 256 ) + amount )
}

// run gamestate

void function RunATGame()
{
	thread RunATGame_Threaded()
}

void function RunATGame_Threaded()
{
	svGlobal.levelEnt.EndSignal( "GameStateChanged" )
	
	OnThreadEnd( function()
	{
		SetGlobalNetBool( "banksOpen", false )
	})
	
	wait WAVE_STATE_TRANSITION_TIME // initial wait before first wave
		
	for ( int waveCount = 1; ; waveCount++  )
	{
		wait WAVE_STATE_TRANSITION_TIME
	
		// cap to number of real waves
		int waveId = ( waveCount / 2 ) 
		// last wave is clearly unfinished so don't use, just cap to last actually used one
		if ( waveId >= GetWaveDataSize() - 1 )
		{
			waveId = GetWaveDataSize() - 2	
			waveCount = waveId * 2
		}
			
		SetGlobalNetInt( "AT_currentWave", waveId )
		bool isBossWave = waveCount / float( 2 ) > waveId // odd number waveCount means boss wave
		
		// announce the wave 
		foreach ( entity player in GetPlayerArray() )
		{
			if ( isBossWave )
				Remote_CallFunction_NonReplay( player, "ServerCallback_AT_AnnounceBoss" )
			else
				Remote_CallFunction_NonReplay( player, "ServerCallback_AT_AnnouncePreParty", 0.0, waveId )	
		}
		
		wait WAVE_STATE_TRANSITION_TIME
		
		// run the wave
		
		AT_WaveData wave = GetWaveData( waveId )
		array< array<AT_SpawnData> > campSpawnData
		
		if ( isBossWave )
			campSpawnData = wave.bossSpawnData
		else
			campSpawnData = wave.spawnDataArrays
		
		// initialise pending spawns
		foreach ( array< AT_SpawnData > campData in campSpawnData )
		{
			foreach ( AT_SpawnData spawnData in campData )
				spawnData.pendingSpawns = spawnData.totalToSpawn
		}
		
		// clear tracked spawns
		file.trackedCampNPCSpawns = {}
		while ( true )
		{		
			// if this is ever 0 by the end of this loop, wave is complete
			int numActiveCampSpawners = 0
		
			// iterate over camp data for wave
			for ( int campIdx = 0; campIdx < campSpawnData.len() && campIdx < file.camps.len(); campIdx++ )
			{
				if ( !( campIdx in file.trackedCampNPCSpawns ) )
					file.trackedCampNPCSpawns[ campIdx ] <- {}
			
				// iterate over ai spawn data for camp
				foreach ( AT_SpawnData spawnData in campSpawnData[ campIdx ] )
				{
					if ( !( spawnData.aitype in file.trackedCampNPCSpawns[ campIdx ] ) )
						file.trackedCampNPCSpawns[ campIdx ][ spawnData.aitype ] <- 0
				
					if ( spawnData.pendingSpawns > 0 || file.trackedCampNPCSpawns[ campIdx ][ spawnData.aitype ] > 0 )
						numActiveCampSpawners++
				
					// try to spawn as many ai as we can, as long as the camp doesn't already have too many spawned
					int spawnCount
					for ( spawnCount = 0; spawnCount < spawnData.pendingSpawns && spawnCount < spawnData.totalAllowedOnField - file.trackedCampNPCSpawns[ campIdx ][ spawnData.aitype ]; )
					{						
						// not doing this in a generic way atm, but could be good for the future if we want to support more ai
						switch ( spawnData.aitype )
						{
							case "npc_soldier":
							case "npc_spectre":
							case "npc_stalker":
								thread AT_SpawnDroppodSquad( campIdx, spawnData.aitype )
								spawnCount += 4
								break
							
							case "npc_super_spectre":
								thread AT_SpawnReaper( campIdx )
								spawnCount += 1
								break
								
							case "npc_titan":
								thread AT_SpawnBountyTitan( campIdx )
								spawnCount += 1
								break
							
							default:
								print( "BOUNTY HUNT: Tried to spawn unsupported ai of type \"" + "\" at camp " + campIdx )
						}
					}
					
					// track spawns
					file.trackedCampNPCSpawns[ campIdx ][ spawnData.aitype ] += spawnCount
					spawnData.pendingSpawns -= spawnCount
				}
			}
			
			if ( numActiveCampSpawners == 0 )
				break
		
			wait 0.5
		}
		
		wait WAVE_STATE_TRANSITION_TIME
		
		// banking phase
	}
}

// entity funcs

void function AT_SpawnDroppodSquad( int camp, string aiType )
{
	entity spawnpoint
	if ( file.camps[ camp ].dropPodSpawnPoints.len() == 0 )
		spawnpoint = file.camps[ camp ].ent
	else
		spawnpoint = file.camps[ camp ].dropPodSpawnPoints.getrandom()
	
	// add variation to spawns
	wait RandomFloat( 1.0 )
	
	AiGameModes_SpawnDropPod( spawnpoint.GetOrigin(), spawnpoint.GetAngles(), BH_AI_TEAM, aiType, void function( array<entity> guys ) : ( camp, aiType ) 
	{
		AT_HandleSquadSpawn( guys, camp, aiType )
	})
}

void function AT_HandleSquadSpawn( array<entity> guys, int camp, string aiType )
{
	foreach ( entity guy in guys )
	{
		guy.EnableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE )
		
		// untrack them on death
		thread AT_WaitToUntrackNPC( guy, camp, aiType )
	}
}

void function AT_SpawnReaper( int camp )
{
	entity spawnpoint
	if ( file.camps[ camp ].dropPodSpawnPoints.len() == 0 )
		spawnpoint = file.camps[ camp ].ent
	else
		spawnpoint = file.camps[ camp ].titanSpawnPoints.getrandom()

	// add variation to spawns
	wait RandomFloat( 1.0 )
	
	AiGameModes_SpawnReaper( spawnpoint.GetOrigin(), spawnpoint.GetAngles(), BH_AI_TEAM, "npc_super_spectre",void function( entity reaper ) : ( camp ) 
	{
		thread AT_WaitToUntrackNPC( reaper, camp, "npc_super_spectre" )
	})
}

void function AT_SpawnBountyTitan( int camp )
{
	entity spawnpoint
	if ( file.camps[ camp ].dropPodSpawnPoints.len() == 0 )
		spawnpoint = file.camps[ camp ].ent
	else
		spawnpoint = file.camps[ camp ].titanSpawnPoints.getrandom()

	// add variation to spawns
	wait RandomFloat( 1.0 )
	
	// look up titan to use
	int bountyID = 0
	try 
	{
		bountyID = ReserveBossID( VALID_BOUNTY_TITAN_SETTINGS.getrandom() )
	}
	catch ( ex ) {} // if we go above the expected wave count that vanilla supports, there's basically no way to ensure that this func won't error, so default 0 after that point
	
	string aisettings = GetTypeFromBossID( bountyID )
	string titanClass = expect string( Dev_GetAISettingByKeyField_Global( aisettings, "npc_titan_player_settings" ) )
	
	
	AiGameModes_SpawnTitan( spawnpoint.GetOrigin(), spawnpoint.GetAngles(), BH_AI_TEAM, titanClass, aisettings, void function( entity titan ) : ( camp, bountyID ) 
	{
		// set up titan-specific death/damage callbacks
		AddEntityCallback_OnDamaged( titan, OnBountyDamaged)
		AddEntityCallback_OnKilled( titan, OnBountyKilled )
		
		titan.GetTitanSoul().soul.skipDoomState = true
		// i feel like this should be localised, but there's nothing for it in r1_english?
		titan.SetTitle( GetNameFromBossID( bountyID ) )
		thread AT_WaitToUntrackNPC( titan, camp, "npc_titan" )
	} )
}

// Tracked entities will require their own "wallet"
// for titans it should be used for rounding error compenstation
// for infantry it sould be used to store money if the npc kills a player
void function OnBountyDamaged( entity titan, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( !attacker.IsPlayer() )
		attacker = GetLatestAssistingPlayerInfo( titan ).player
	
	if ( IsValid( attacker ) && attacker.IsPlayer() )
	{
			int reward = int ( BOUNTY_TITAN_DAMAGE_POOL * DamageInfo_GetDamage( damageInfo ) / titan.GetMaxHealth() )
			printt ( titan.GetMaxHealth(), DamageInfo_GetDamage( damageInfo ) )
			
			AT_AddPlayerCash( attacker, reward )
	}
}

void function OnBountyKilled( entity titan, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( !attacker.IsPlayer() )
		attacker = GetLatestAssistingPlayerInfo( titan ).player
	
	if ( IsValid( attacker ) && attacker.IsPlayer() )
		AT_AddPlayerCash( attacker, BOUNTY_TITAN_KILL_REWARD )
}

void function AT_WaitToUntrackNPC( entity guy, int camp, string aiType )
{
	guy.WaitSignal( "OnDeath", "OnDestroy" )
	file.trackedCampNPCSpawns[ camp ][ aiType ]--
}
