untyped // AddCallback_OnUseEntity() needs this
global function GamemodeAt_Init
global function RateSpawnpoints_AT

// Old bobr note which still applies after a year :)
// IMPLEMENTATION NOTES:
// bounty hunt is a mode that was clearly pretty heavily developed, and had alot of scrapped concepts (i.e. most wanted player bounties, turret bounties, collectable blackbox objectives)
// in the interest of time, this script isn't gonna support any of that atm
// alot of the remote functions also take parameters that aren't used, i'm not gonna populate these and just use default values for now instead
// however, if you do want to mess with this stuff, almost all the remote functions for this stuff are still present in cl_gamemode_at, and should work fine with minimal fuckery in my experience


// Bank settings
const float AT_BANKS_OPEN_DURATION = 45.0   // Bank open time
const int   AT_BANK_DEPOSIT_RATE = 10       // Amount deposited per second
const int   AT_BANK_DEPOSIT_RADIUS = 256    // bank radius for depositing
const float AT_BANK_FORCE_CLOSE_DELAY = 4.0 // If all bonus money has been deposited close the banks after this constant early

// TODO: The reference function no longer exists, check if this still holds true
// VoyageDB: HACK score events... respawn made things in AT_SetScoreEventOverride() really messed up, have to do some hack here
const array<string> AT_ENABLE_SCOREEVENTS = 
[
	// these are disabled in AT_SetScoreEventOverride(), but related scoreEvents are not implemented into gamemode
	// needs to re-enable them
	"DoomTitan",
	"DoomAutoTitan"
]
const array<string> AT_DISABLE_SCOREEVENTS =
[
	// these are missed in AT_SetScoreEventOverride(), but game actually used them
	// needs to disable them
	"KillStalker"
]

// Wave settings
// General
const int   AT_AI_TEAM = TEAM_BOTH               // Allow AI to attack and be attacked by both player teams
const float AT_FIRST_WAVE_START_DELAY = 10.0     // First wave has an extra delay before begining
const float AT_WAVE_TRANSITION_DELAY = 5.0       // Time between each wave and banks opening/closing
const float AT_WAVE_END_ANNOUNCEMENT_DELAY = 1.0 // Extra wait before announcing wave cleaned

// Squad settings
const int AT_DROPPOD_SQUADS_ALLOWED_ON_FIELD = 4 // default is 4 droppod squads on field, won't use if AT_USE_TOTAL_ALLOWED_ON_FIELD_CHECK turns on // TODO: verify this

// Titan bounty settings
const float AT_BOUNTY_TITAN_CHECK_DELAY = 10.0    // wait for bounty titans landing before we start checking their life state
const float AT_BOUNTY_TITAN_HEALTH_MULTIPLIER = 3 // TODO: Verify this

// Titan boss settings, check sh_gamemode_at.nut for more info
const array<string> AT_BOUNTY_TITANS_AI_SETTINGS =
[
	"npc_titan_atlas_stickybomb_bounty",
	"npc_titan_atlas_tracker_bounty",
	"npc_titan_ogre_minigun_bounty",
	"npc_titan_ogre_meteor_bounty",
	"npc_titan_stryder_leadwall_bounty",
	"npc_titan_stryder_sniper_bounty",
	"npc_titan_atlas_vanguard_bounty"
]

// Extra
// Respawn didn't use the "totalAllowedOnField" for npc spawning, they only allow 1 squad to be on field for each type of npc. enabling this might cause too much npcs spawning and crash the game
const bool AT_USE_TOTAL_ALLOWED_ON_FIELD_CHECK = false

// Objectives
const int AT_OBJECTIVE_EMPTY = -1            // Remove objective
const int AT_OBJECTIVE_KILL_DZ = 104         // #AT_OBJECTIVE_KILL_DZ
const int AT_OBJECTIVE_KILL_DZ_MULTI = 105   // #AT_OBJECTIVE_KILL_DZ_MULTI
const int AT_OBJECTIVE_KILL_BOSS = 106       // #AT_OBJECTIVE_KILL_BOSS
const int AT_OBJECTIVE_KILL_BOSS_MULTI = 107 // #AT_OBJECTIVE_KILL_BOSS_MULTI
const int AT_OBJECTIVE_BANK_OPEN = 109       // #AT_BANK_OPEN_OBJECTIVE

// When a player tries to deposit when they have 0 bonus money
// we show a help mesage, this is the ratelimit for that message
// so that we dont spam it too much
const float AT_PLAYER_HUD_MESSAGE_COOLDOWN = 2.5

// Due to bad navmeshes NPCs may wonder off to bumfuck nowhere or the game
// might teleport them into the map while trying to correct their position
// This obviously breaks bounty hunt where the objective is to kill ALL ai
// so we try to cleanup the camps after a set amount of time of inactivity
const int   AT_CAMP_BORED_NPCS_LEFT_TO_START_CLEANUP = 3
const float AT_CAMP_BORED_CLEANUP_WAIT = 60.0
struct 
{
	array<entity> banks 
	array<AT_WaveOrigin> camps

	// Used to track ScriptmanagedEntArrays of ai squads
	table< int, array<int> > campScriptEntArrays
	
	table< entity, bool > titanIsBountyBoss
	table< entity, int > bountyTitanRewards
	table< entity, int > npcStolenBonus
	table< entity, bool > playerBankUploading
	table< entity, table<entity, int> > playerSavedBountyDamage
	table< entity, float > playerHudMessageAllowedTime
} file

void function GamemodeAt_Init()
{
	// wave
	RegisterSignal( "ATWaveEnd" )
	// camp
	RegisterSignal( "ATCampClean" )
	RegisterSignal( "ATAllCampsClean" )

	// Set-up score callbacks
	ScoreEvent_SetupEarnMeterValuesForMixedModes()
	AddCallback_OnPlayerKilled( AT_PlayerOrNPCKilledScoreEvent )
	AddCallback_OnNPCKilled( AT_PlayerOrNPCKilledScoreEvent )

	// Set npc weapons
	AiGameModes_SetNPCWeapons( "npc_soldier", [ "mp_weapon_rspn101", "mp_weapon_dmr", "mp_weapon_r97", "mp_weapon_lmg" ] )
	AiGameModes_SetNPCWeapons( "npc_spectre", [ "mp_weapon_hemlok_smg", "mp_weapon_doubletake", "mp_weapon_mastiff" ] )
	AiGameModes_SetNPCWeapons( "npc_stalker", [ "mp_weapon_hemlok_smg", "mp_weapon_lstar", "mp_weapon_mastiff" ] )

	// Gamestate callbacks
	AddCallback_GameStateEnter( eGameState.Prematch, OnATGamePrematch )
	AddCallback_GameStateEnter( eGameState.Playing, OnATGamePlaying )

	// Initilaze player
	AddCallback_OnClientConnected( InitialiseATPlayer )

	// Initilaze gamemode entities
	AddCallback_EntitiesDidLoad( OnEntitiesDidLoad )
}

void function RateSpawnpoints_AT( int checkclass, array<entity> spawnpoints, int team, entity player )
{
	RateSpawnpoints_Generic( checkclass, spawnpoints, team, player )
}



////////////////////////////////////////
///// GAMESTATE CALLBACK FUNCTIONS /////
////////////////////////////////////////

void function OnATGamePrematch()
{
	AT_ScoreEventsValueSetUp()
}

void function OnATGamePlaying()
{
	thread AT_GameLoop_Threaded()
}

////////////////////////////////////////////
///// GAMESTATE CALLBACK FUNCTIONS END /////
////////////////////////////////////////////



////////////////////////////
///// PLAYER FUNCTIONS /////
////////////////////////////

void function InitialiseATPlayer( entity player )
{
	Remote_CallFunction_NonReplay( player, "ServerCallback_AT_OnPlayerConnected" )
	player.SetPlayerNetInt( "AT_bonusPointMult", 1 )
	file.playerBankUploading[ player ] <- false
	file.playerSavedBountyDamage[ player ] <- {}
	file.playerHudMessageAllowedTime[ player ] <- 0.0
	thread AT_PlayerTitleThink( player )
	thread AT_PlayerObjectiveThink( player )
}

void function AT_PlayerTitleThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	while ( true )
	{
		if ( GetGameState() == eGameState.Playing )
		{
			// Set player money count
			player.SetTitle( "$" + string( AT_GetPlayerBonusPoints( player ) ) )
		}
		else if ( GetGameState() >= eGameState.WinnerDetermined )
		{
			if ( player.IsTitan() )
				player.SetTitle( GetTitanPlayerTitle( player ) )
			else
				player.SetTitle( "" )
			
			return
		}

		WaitFrame()
	}
}

string function GetTitanPlayerTitle( entity player )
{
	entity soul = player.GetTitanSoul()

	if ( !IsValid( soul ) )
		return ""
	
	string settings = GetSoulPlayerSettings( soul )
	var title = GetPlayerSettingsFieldForClassName( settings, "printname" )

	if ( title == null )
		return ""
	
	return expect string( title )
}

void function AT_PlayerObjectiveThink( entity player )
{
	player.EndSignal( "OnDestroy" )

	int curObjective = AT_OBJECTIVE_EMPTY
	while ( true )
	{
		// game entered other state
		if ( GetGameState() >= eGameState.WinnerDetermined )
		{
			player.SetPlayerNetInt( "gameInfoStatusText", AT_OBJECTIVE_EMPTY )
			return
		}

		int nextObjective = AT_OBJECTIVE_EMPTY

		// Determine objective text for player
		if ( !IsAlive( player ) ) // Don't show objective to dead players
		{
			nextObjective = AT_OBJECTIVE_EMPTY
		}
		else // We're still alive
		{
			if ( GetGlobalNetBool( "banksOpen" ) )
			{
				nextObjective = AT_OBJECTIVE_BANK_OPEN
			}
			else if ( GetGlobalNetBool( "preBankPhase" ) )
			{
				nextObjective = AT_OBJECTIVE_EMPTY
			}
			else
			{
				// No checks have passed, try to do a "Kill all x near the marked dropzone" objective
				int dropZoneActiveCount = 0
				int bossAliveCount = 0
				array<entity> campEnts
				campEnts.append( GetGlobalNetEnt( "camp1Ent" ) )
				campEnts.append( GetGlobalNetEnt( "camp2Ent" ) )

				foreach ( entity ent in campEnts )
				{
					if ( IsValid( ent ) )
					{
						if ( ent.IsTitan() )
							bossAliveCount += 1
						else
							dropZoneActiveCount += 1
					}
				}

				switch( dropZoneActiveCount )
				{
					case 1:
						nextObjective = AT_OBJECTIVE_KILL_DZ
						break
					case 2:
						nextObjective = AT_OBJECTIVE_KILL_DZ_MULTI
						break
				}

				switch( bossAliveCount )
				{
					case 1:
						nextObjective = AT_OBJECTIVE_KILL_BOSS
						break
					case 2:
						nextObjective = AT_OBJECTIVE_KILL_BOSS_MULTI
						break
				}

				// We couldn't get an objective, set it to empty
				if ( dropZoneActiveCount == 0 && bossAliveCount == 0 )
					nextObjective = AT_OBJECTIVE_EMPTY
			}
		}

		// Set the objective when changed
		if ( curObjective != nextObjective )
		{
			player.SetPlayerNetInt( "gameInfoStatusText", nextObjective )
			curObjective = nextObjective
		}

		WaitFrame()
	}
}

////////////////////////////////
///// PLAYER FUNCTIONS END /////
////////////////////////////////



////////////////////////////////////////
///// GAMEMODE INITILAZE FUNCTIONS /////
////////////////////////////////////////

void function OnEntitiesDidLoad()
{
	foreach ( entity info_target in GetEntArrayByClass_Expensive( "info_target" ) )
	{
		if( info_target.HasKey( "editorclass" ) )
		{
			switch( info_target.kv.editorclass )
			{
				case "info_attrition_bank":
					entity bank = CreateEntity( "prop_script" )
					bank.SetScriptName( "AT_Bank" ) // VoyageDB: don't know how to make client able to track it
					bank.SetOrigin( info_target.GetOrigin() )
					bank.SetAngles( info_target.GetAngles() )
					DispatchSpawn( bank )
					bank.kv.solid = SOLID_VPHYSICS
					bank.SetModel( info_target.GetModelName() )

					// Minimap icon init
					bank.Minimap_SetCustomState( eMinimapObject_prop_script.AT_BANK )
					bank.Minimap_SetAlignUpright( true )
					bank.Minimap_SetZOrder( MINIMAP_Z_OBJECT )
					bank.Minimap_Hide( TEAM_IMC, null )
					bank.Minimap_Hide( TEAM_MILITIA, null )
					
					// Create tracker ent
					// we don't need to store these at all, client just needs to get them
					DispatchSpawn( GetAvailableBankTracker( bank ) )
					
					// Make sure the bank is in it's disabled pose
					thread PlayAnim( bank, "mh_inactive_idle" )
					// Set the bank usable
					AddCallback_OnUseEntity( bank, OnPlayerUseBank )
					bank.SetUsable()
					bank.SetUsePrompts( "#AT_USE_BANK_CLOSED", "#AT_USE_BANK_CLOSED" )
					
					file.banks.append( bank )
					break;
				case "info_attrition_camp":
					AT_WaveOrigin campStruct
					campStruct.ent = info_target
					campStruct.origin = info_target.GetOrigin()
					campStruct.radius = expect string( info_target.kv.radius ).tofloat()
					campStruct.height = expect string( info_target.kv.height ).tofloat()
					
					// Assumes every info_attrition_camp will have all 9 phases, possibly not a good idea?
					// TODO: verify this on all vanilla maps before release
					for ( int i = 0; i < 9; i++ )
						campStruct.phaseAllowed.append( expect string( info_target.kv[ "phase_" + ( i + 1 ) ] ) == "1" )
					
					// Get droppod spawns within the camp
					foreach ( entity spawnpoint in SpawnPoints_GetDropPod() )
					{
						vector campPos = info_target.GetOrigin()
						vector spawnPos = spawnpoint.GetOrigin()
						if ( Distance( campPos, spawnPos ) < campStruct.radius )
							campStruct.dropPodSpawnPoints.append( spawnpoint )
					}
					
					// Get titan spawns within the camp
					foreach ( entity spawnpoint in SpawnPoints_GetTitan() )
					{
						vector campPos = info_target.GetOrigin()
						vector spawnPos = spawnpoint.GetOrigin()
						if ( Distance( campPos, spawnPos ) < campStruct.radius )
							campStruct.titanSpawnPoints.append( spawnpoint )
					}
				
					file.camps.append( campStruct )
					break;
			}
		}
	}
}

////////////////////////////////////////////
///// GAMEMODE INITILAZE FUNCTIONS END /////
////////////////////////////////////////////



/////////////////////////////
///// SCORING FUNCTIONS /////
/////////////////////////////

// TODO: Don't reward in postmatch
// TODO: Dropping a titan on a bounty with it's dome-shield still up rewards you the bonus, but
//       it doesn't actually damage the bounty titan

void function AT_ScoreEventsValueSetUp()
{
	ScoreEvent_SetEarnMeterValues( "KillTitan", 0.10, 0.15 )
	ScoreEvent_SetEarnMeterValues( "KillAutoTitan", 0.10, 0.15 )
	ScoreEvent_SetEarnMeterValues( "AttritionTitanKilled", 0.10, 0.15 )
	ScoreEvent_SetEarnMeterValues( "KillPilot", 0.10, 0.10 )
	ScoreEvent_SetEarnMeterValues( "AttritionPilotKilled", 0.10, 0.10 )
	ScoreEvent_SetEarnMeterValues( "AttritionBossKilled", 0.10, 0.20 )
	ScoreEvent_SetEarnMeterValues( "AttritionGruntKilled", 0.02, 0.02, 0.5 )
	ScoreEvent_SetEarnMeterValues( "AttritionSpectreKilled", 0.02, 0.02, 0.5 )
	ScoreEvent_SetEarnMeterValues( "AttritionStalkerKilled", 0.02, 0.02, 0.5 )
	ScoreEvent_SetEarnMeterValues( "AttritionSuperSpectreKilled", 0.10, 0.10, 0.5 )

	// HACK
	foreach ( string eventName in AT_ENABLE_SCOREEVENTS )
		ScoreEvent_Enable( GetScoreEvent( eventName ) )

	foreach ( string eventName in AT_DISABLE_SCOREEVENTS )
		ScoreEvent_Disable( GetScoreEvent( eventName ) )
}

void function AT_PlayerOrNPCKilledScoreEvent( entity victim, entity attacker, var damageInfo )
{
	if ( !IsValid( attacker ) )
		return
	
	// Suicide
	if ( attacker == victim )
	{
		if ( victim.IsPlayer() )
			AT_PlayerBonusLoss( victim, AT_GetPlayerBonusPoints( victim ) / 2 )
		
		return
	}
	
	// NPC is the attacker
	if ( !attacker.IsPlayer() )
	{
		if ( attacker.IsTitan() && IsValid( GetPetTitanOwner( attacker ) ) ) // Re-asign attacker
			attacker = GetPetTitanOwner( attacker )
		else // NPC steals money from player, killing it will award the stolen bonus + normal reward
			AT_NPCTryStealBonusPoints( attacker, victim )
		
		return
	}
	
	// Get event name
	string eventName = GetAttritionScoreEventName( victim.GetClassName() )

	if ( victim.IsTitan() ) // titan specific
		eventName = GetAttritionScoreEventNameFromAI( victim )

	if ( eventName == "" ) // no valid scoreEvent
		return
	
	int scoreVal = ScoreEvent_GetPointValue( GetScoreEvent( eventName ) )

	// pet titan check
	if ( victim.IsTitan() && IsValid( GetPetTitanOwner( victim ) ) )
	{
		if( GetPetTitanOwner( victim ) == attacker ) // Player ejected
			return
		
		if( GetPetTitanOwner( victim ).IsPlayer() ) // Killed player npc titan
			return
		
		scoreVal = ATTRITION_SCORE_TITAN_MIN
	}

	// killed npc
	if ( victim.IsNPC() )
	{
		int bonusFromNPC = 0
		// If NPC was carrying a bonus award it to the attacker
		if ( victim in file.npcStolenBonus )
		{
			bonusFromNPC = file.npcStolenBonus[ victim ]
			delete file.npcStolenBonus[ victim ]
		}
		AT_AddPlayerBonusPointsForEntityKilled( attacker, scoreVal, damageInfo, bonusFromNPC )
		AddPlayerScore( attacker, eventName ) // we add scoreEvent here, since basic score events has been overwrited by sh_gamemode_at.nut
		// update score difference and scoreboard
		AT_AddToPlayerTeamScore( attacker, scoreVal )
	}

	// bonus stealing check
	if ( victim.IsPlayer() )
		AT_PlayerTryStealBonusPoints( attacker, victim, damageInfo )
}

bool function AT_NPCTryStealBonusPoints( entity attacker, entity victim )
{
	// basic checks
	if ( !attacker.IsNPC() )
		return false
	
	if ( !victim.IsPlayer() )
		return false
	
	int victimBonus = AT_GetPlayerBonusPoints( victim )
	int bonusToSteal = victimBonus / 2 // npc always steal half the bonus from player, no extra bonus for killing the player
	if ( bonusToSteal == 0 ) // player has no bonus!
		return false

	if ( !( attacker in file.npcStolenBonus ) ) // init
		file.npcStolenBonus[ attacker ] <- 0
	
	file.npcStolenBonus[ attacker ] += bonusToSteal

	AT_PlayerBonusLoss( victim, bonusToSteal ) // tell victim of bonus stolen

	if ( !( attacker in file.titanIsBountyBoss ) ) // if attacker npc is not a bounty titan, we make them highlighted
		NPCBountyStolenHighlight( attacker )

	return true
}

void function NPCBountyStolenHighlight( entity npc )
{
	Highlight_SetEnemyHighlight( npc, "enemy_boss_bounty" )
}

bool function AT_PlayerTryStealBonusPoints( entity attacker, entity victim, var damageInfo )
{
	// basic checks
	if ( !attacker.IsPlayer() )
		return false
	
	if ( !victim.IsPlayer() )
		return false
	
	int victimBonus = AT_GetPlayerBonusPoints( victim )

	int minScoreCanSteal = ATTRITION_SCORE_PILOT_MIN
	if ( victim.IsTitan() )
		minScoreCanSteal = ATTRITION_SCORE_TITAN_MIN

	int bonusToSteal = victimBonus / 2
	int attackerScore = bonusToSteal
	bool realStealBonus = true
	if ( bonusToSteal <= minScoreCanSteal ) // no enough bonus to steal
	{
		attackerScore = minScoreCanSteal // give attacker min bonus
		realStealBonus = false // we don't do attacker steal events below, just half victim's bonus
	}

	// servercallback
	int victimEHandle = victim.GetEncodedEHandle()
	vector damageOrigin = DamageInfo_GetDamagePosition( damageInfo )

	// only do attacker events if victim has enough bonus to steal
	if ( realStealBonus )
	{
		Remote_CallFunction_NonReplay( 
			attacker, 
			"ServerCallback_AT_PlayerKillScorePopup",
			bonusToSteal,   // stolenScore
			victimEHandle,  // victimEHandle
			damageOrigin.x, // x
			damageOrigin.y, // y
			damageOrigin.z  // z
		)
	}
	else // otherwise we do a normal entity killed scoreEvent
	{
		AT_AddPlayerBonusPointsForEntityKilled( attacker, attackerScore, damageInfo )
	}

	// update score difference and scoreboard
	AT_AddToPlayerTeamScore( attacker, minScoreCanSteal )

	// steal bonus
	// only do attacker events if victim has enough bonus to steal
	if ( realStealBonus )
	{
		AT_AddPlayerBonusPoints( attacker, bonusToSteal )
		AddPlayerScore( attacker, "AttritionBonusStolen" )
	}

	// tell victim of bonus stolen
	AT_PlayerBonusLoss( victim, bonusToSteal )
	
	return realStealBonus
}

void function AT_PlayerBonusLoss( entity player, int bonusLoss )
{
	AT_AddPlayerBonusPoints( player, -bonusLoss )
	Remote_CallFunction_NonReplay( 
		player, 
		"ServerCallback_AT_ShowStolenBonus",
		bonusLoss // stolenScore
	)
}

// team score meter
void function AT_AddToPlayerTeamScore( entity player, int amount )
{
	// do not award any score after the match is ended
	if ( GetGameState() > eGameState.Playing )
		return

	// add to scoreboard
	player.AddToPlayerGameStat( PGS_ASSAULT_SCORE, amount )

	// Check score so we dont go over max
	if ( GameRules_GetTeamScore(player.GetTeam()) + amount > GetScoreLimit_FromPlaylist() )
	{
		amount = GetScoreLimit_FromPlaylist() - GameRules_GetTeamScore(player.GetTeam())
	}
	
	// update score difference
	AddTeamScore( player.GetTeam(), amount )
}

// bonus points, players earn from killing
void function AT_AddPlayerBonusPoints( entity player, int amount )
{
	// do not award any score after the match is ended
	if ( GetGameState() > eGameState.Playing )
		return

	// add to scoreboard
	player.AddToPlayerGameStat( PGS_SCORE, amount )
	AT_SetPlayerBonusPoints( player, player.GetPlayerNetInt( "AT_bonusPoints" ) + ( player.GetPlayerNetInt( "AT_bonusPoints256" ) * 256 ) + amount )
}

int function AT_GetPlayerBonusPoints( entity player )
{
	return player.GetPlayerNetInt( "AT_bonusPoints" ) + player.GetPlayerNetInt( "AT_bonusPoints256" ) * 256
}

void function AT_SetPlayerBonusPoints( entity player, int amount )
{
	// split into stacks of 256 where necessary
	int stacks = amount / 256 // automatically rounds down because int division

	player.SetPlayerNetInt( "AT_bonusPoints256", stacks )
	player.SetPlayerNetInt( "AT_bonusPoints", amount - stacks * 256 )
}

// total points, the value player actually uploaded to team score
void function AT_AddPlayerTotalPoints( entity player, int amount )
{
	// update score difference and scoreboard, calling this function meaning player has deposited their bonus to team score
	AT_AddToPlayerTeamScore( player, amount )
	AT_SetPlayerTotalPoints( player, player.GetPlayerNetInt( "AT_totalPoints" ) + ( player.GetPlayerNetInt( "AT_totalPoints256" ) * 256 ) + amount )
}

void function AT_SetPlayerTotalPoints( entity player, int amount )
{
	// split into stacks of 256 where necessary
	int stacks = amount / 256 // automatically rounds down because int division

	player.SetPlayerNetInt( "AT_totalPoints256", stacks )
	player.SetPlayerNetInt( "AT_totalPoints", amount - stacks * 256 )
}

// earn points, seems not used
void function AT_AddPlayerEarnedPoints( entity player, int amount )
{
	AT_SetPlayerBonusPoints( player, player.GetPlayerNetInt( "AT_earnedPoints" ) + ( player.GetPlayerNetInt( "AT_earnedPoints256" ) * 256 ) + amount )
}

void function AT_SetPlayerEarnedPoints( entity player, int amount )
{
	// split into stacks of 256 where necessary
	int stacks = amount / 256 // automatically rounds down because int division

	player.SetPlayerNetInt( "AT_earnedPoints256", stacks )
	player.SetPlayerNetInt( "AT_earnedPoints", amount - stacks * 256 )
}

// damaging bounty
void function AT_AddPlayerBonusPointsForBossDamaged( entity player, entity victim, int amount, var damageInfo )
{
	AT_AddPlayerBonusPoints( player, amount )
	// update score difference and scoreboard
	AT_AddToPlayerTeamScore( player, amount )

	// send servercallback for damaging
	int bossEHandle = victim.GetEncodedEHandle()
	vector damageOrigin = DamageInfo_GetDamagePosition( damageInfo )

	Remote_CallFunction_NonReplay( 
		player, 
		"ServerCallback_AT_BossDamageScorePopup",
		amount,         // damageScore
		amount,         // damageBonus
		bossEHandle,    // bossEHandle
		damageOrigin.x, // x
		damageOrigin.y, // y
		damageOrigin.z  // z
	)
}

void function AT_AddPlayerBonusPointsForEntityKilled( entity player, int amount, var damageInfo, int extraBonus = 0 )
{
	AT_AddPlayerBonusPoints( player, amount + extraBonus )

	// send servercallback for damaging
	int attackerEHandle = player.GetEncodedEHandle()
	vector damageOrigin = DamageInfo_GetDamagePosition( damageInfo )
	
	Remote_CallFunction_NonReplay( 
		player, 
		"ServerCallback_AT_ShowATScorePopup",
		attackerEHandle,     // attackerEHandle
		amount,              // damageScore
		amount + extraBonus, // damageBonus
		damageOrigin.x,      // damagePosX
		damageOrigin.y,      // damagePosX
		damageOrigin.z,      // damagePosX
		0                    // damageType ( not used )
	)
}

/////////////////////////////////
///// SCORING FUNCTIONS END /////
/////////////////////////////////



//////////////////////////////
///// GAMELOOP FUNCTIONS /////
//////////////////////////////

void function AT_GameLoop_Threaded()
{
	svGlobal.levelEnt.EndSignal( "GameStateChanged" )
	
	// game end func
	// TODO: Cant seem to be able to get this crash ???
	OnThreadEnd
	( 
		function()
		{
			// prevent crash before entity creation on map change
			if ( GetGameState() >= eGameState.Prematch )
			{
				SetGlobalNetBool( "preBankPhase", false )
				SetGlobalNetBool( "banksOpen", false )
			}
		}
	)
	
	// Initial wait before first wave
	wait AT_FIRST_WAVE_START_DELAY - AT_WAVE_TRANSITION_DELAY
	
	int lastWaveId = -1
	for ( int waveCount = 1; ; waveCount++ )
	{
		wait AT_WAVE_TRANSITION_DELAY
	
		// cap to number of real waves
		int waveId = ( waveCount - 1 ) / 2
		int waveCapAmount = 2
		waveId = int( min( waveId, GetWaveDataSize() - waveCapAmount ) )

		// New wave dialogue
		bool waveChanged = lastWaveId != waveId
		if ( waveChanged )
		{
			PlayFactionDialogueToTeam( "bh_newWave", TEAM_IMC )
			PlayFactionDialogueToTeam( "bh_newWave", TEAM_MILITIA )
		}
		else // same wave, second half
		{
			PlayFactionDialogueToTeam( "bh_incoming", TEAM_IMC )
			PlayFactionDialogueToTeam( "bh_incoming", TEAM_MILITIA )
		}

		lastWaveId = waveId
			
		SetGlobalNetInt( "AT_currentWave", waveId )
		bool isBossWave = waveCount % 2 == 0 // even number waveCount means boss wave
		
		// announce the wave 
		foreach ( entity player in GetPlayerArray() )
		{
			if ( isBossWave )
			{
				Remote_CallFunction_NonReplay( player, "ServerCallback_AT_AnnounceBoss" )
			}
			else
			{
				Remote_CallFunction_NonReplay( 
					player, 
					"ServerCallback_AT_AnnouncePreParty", 
					0.0,   // endTime ( not used )
					waveId // waveNum
				)
			}
		}
		
		wait AT_WAVE_TRANSITION_DELAY
		
		// Run the wave
		thread AT_CampSpawnThink( waveId, isBossWave )

		if ( !isBossWave )
		{
			svGlobal.levelEnt.WaitSignal( "ATAllCampsClean" ) // signaled when all camps cleaned in spawn functions
		}
			else
		{
			wait AT_BOUNTY_TITAN_CHECK_DELAY
			// wait until all bounty titans killed
			while ( IsAlive( GetGlobalNetEnt( "camp1Ent" ) ) || IsAlive( GetGlobalNetEnt( "camp2Ent" ) ) )
				WaitFrame()
		}

		// wave end, prebank phase
		svGlobal.levelEnt.Signal( "ATWaveEnd" ) // defensive fix, destroy existing campEnts
		SetGlobalNetBool( "preBankPhase", true )

		wait AT_WAVE_END_ANNOUNCEMENT_DELAY
		
		// announce wave end
		foreach ( entity player in GetPlayerArray() )
		{
			Remote_CallFunction_NonReplay( 
				player, 
				"ServerCallback_AT_AnnounceWaveOver",
				waveId, // waveNum            ( not used )
				0,      // militiaDamageTotal ( not used )
				0,      // imcDamageTotal     ( not used )
				0,      // milMVP             ( not used )
				0,      // imcMVP             ( not used )
				0,      // milMVPDamage       ( not used )
				0       // imcMVPDamage       ( not used )
			)
		}

		wait AT_WAVE_TRANSITION_DELAY
		
		// banking phase
		SetGlobalNetBool( "preBankPhase", false )
		SetGlobalNetTime( "AT_bankStartTime", Time() )
		SetGlobalNetTime( "AT_bankEndTime", Time() + AT_BANKS_OPEN_DURATION )
		SetGlobalNetBool( "banksOpen", true )

		foreach ( entity player in GetPlayerArray() )
			Remote_CallFunction_NonReplay( player, "ServerCallback_AT_BankOpen" )

		foreach ( entity bank in file.banks )
			thread AT_BankActiveThink( bank )

		
		float endTime = Time() + AT_BANKS_OPEN_DURATION
		bool forceCloseTriggered = false
		// wait until no player is holding bonus, or max wait time
		while ( Time() <= endTime )
		{
			// If everyone has deposited their bonuses close the banks early
			if ( !ATAnyPlayerHasBonus() && !forceCloseTriggered )
			{
				forceCloseTriggered = true
				endTime = Time() + AT_BANK_FORCE_CLOSE_DELAY
			}

			WaitFrame()
		}
		
		SetGlobalNetBool( "banksOpen", false )
		foreach ( entity player in GetPlayerArray() )
			Remote_CallFunction_NonReplay( player, "ServerCallback_AT_BankClose" )
	}
}

bool function ATAnyPlayerHasBonus()
{
	foreach ( entity player in GetPlayerArray() )
	{
		if ( AT_GetPlayerBonusPoints( player ) )
			return true
	}
	return false
}

//////////////////////////////////
///// GAMELOOP FUNCTIONS END /////
//////////////////////////////////



//////////////////////////
///// CAMP FUNCTIONS /////
//////////////////////////

void function AT_CampSpawnThink( int waveId, bool isBossWave )
{
	AT_WaveData wave = GetWaveData( waveId )
	array< array<AT_SpawnData> > campSpawnData

	if ( isBossWave )
		campSpawnData = wave.bossSpawnData
	else
		campSpawnData = wave.spawnDataArrays

	array<AT_WaveOrigin> allCampsToUse
	foreach ( AT_WaveOrigin campStruct in file.camps )
	{
		if ( campStruct.phaseAllowed[ waveId ] )
			allCampsToUse.append( campStruct )
	}

	// HACK
	// There's too many phase3 camps on exoplanet and rise, make sure we always have the correct count
	int maxCampsForWave = waveId == 0 ? 1 : 2
	while( allCampsToUse.len() > maxCampsForWave )
	{
		// Get the required number of camps
		array<AT_WaveOrigin> tempCamps
		for( int i = 0; i < maxCampsForWave; i++ )
			tempCamps.append( allCampsToUse[RandomInt( allCampsToUse.len() )] )
		

		// Check if they're intersecting, if they are, try again
		bool intersecting = false
		for( int i = 0; i < tempCamps.len(); i++ )
		{
			AT_WaveOrigin campA = tempCamps[i]
			for( int j = 0; j < tempCamps.len(); j++ )
			{
				// Don't compare the same two camps
				if( j == i )
					continue
				
				AT_WaveOrigin campB = tempCamps[j]
				
				if( Distance( campA.origin, campB.origin ) < campA.radius + campB.radius )
					intersecting = true
			}
		}

		if( !intersecting )
			allCampsToUse = tempCamps
		
		// If we ever get really unlucky just wait a frame
		WaitFrame()
	}

	foreach ( int spawnId, AT_WaveOrigin curCampData in allCampsToUse )
	{
		array<AT_SpawnData> curSpawnData = campSpawnData[ spawnId ]

		int totalNPCsToSpawn = 0
		// initialise pending spawns and get total npcs
		foreach ( AT_SpawnData spawnData in curSpawnData )
		{
			spawnData.pendingSpawns = spawnData.totalToSpawn
			// add to network variables
			string npcNetVar = GetNPCNetVarName( spawnData.aitype, spawnId )
			SetGlobalNetInt( npcNetVar, spawnData.totalToSpawn )

			totalNPCsToSpawn += spawnData.totalToSpawn
		}

		if ( !isBossWave ) 
		{
			// camp Ent, boss wave will use boss themselves as campEnt
			string campEntVarName = "camp" + string( spawnId + 1 ) + "Ent"
			bool waveNotActive = GetGlobalNetBool( "preBankPhase" ) || GetGlobalNetBool( "banksOpen" )
			if ( !IsValid( GetGlobalNetEnt( campEntVarName ) ) && !waveNotActive )
				SetGlobalNetEnt( campEntVarName, CreateCampTracker( curCampData, spawnId ) )
			
			array<AT_SpawnData> minionSquadDatas
			foreach ( AT_SpawnData data in curSpawnData )
			{
				switch ( data.aitype )
				{
					case "npc_soldier":
					case "npc_spectre":
					case "npc_stalker":
						if ( !AT_USE_TOTAL_ALLOWED_ON_FIELD_CHECK )
							minionSquadDatas.append( data )
						else
							thread AT_DroppodSquadEvent_Single( curCampData, spawnId, data )
						break
					
					case "npc_super_spectre":
						thread AT_ReaperEvent( curCampData, spawnId, data )
						break
				}
			}

			// minions squad spawn
			if ( !AT_USE_TOTAL_ALLOWED_ON_FIELD_CHECK )
			{
				if ( minionSquadDatas.len() > 0 )
					thread AT_DroppodSquadEvent( curCampData, spawnId, minionSquadDatas )
			}

			// use campProgressThink for handling wave state
			thread CampProgressThink( spawnId, totalNPCsToSpawn )
		}
		else // bosswave spawn
		{
			foreach ( AT_SpawnData data in curSpawnData )
			{
				if( data.aitype != "npc_titan" )
					continue
				
				thread AT_BountyTitanEvent( curCampData, spawnId, data )
				break
			}
		}
	}
}

void function CampProgressThink( int spawnId, int totalNPCsToSpawn )
{
	string campLetter = GetCampLetter( spawnId )
	string campProgressName = campLetter + "campProgress"
	string campEntVarName = "camp" + string( spawnId + 1 ) + "Ent"

	// initial wait
	SetGlobalNetFloat( campProgressName, 1.0 )

	// TODO: random wait, make this a constant ??
	wait 3.0

	float cleanUpTime = -1.0

	while ( true )
	{
		int npcsLeft
		// get all npcs might be in this camp
		for ( int i = 0; i < 5; i++ )
		{
			string netVarName = string( i + 1 ) + campLetter + "campCount"
			int netVarValue = GetGlobalNetInt( netVarName )
			if ( netVarValue >= 0 ) // uninitialized network var starts from -1, avoid checking them
				npcsLeft += netVarValue
		}

		float campLeft = float( npcsLeft ) / float( totalNPCsToSpawn )
		SetGlobalNetFloat( campProgressName, campLeft )

		if( npcsLeft <= AT_CAMP_BORED_NPCS_LEFT_TO_START_CLEANUP && cleanUpTime < 0.0 )
		{
			cleanUpTime = Time() + AT_CAMP_BORED_CLEANUP_WAIT
			print("Cleanup timer started!")
		}

		if( Time() > cleanUpTime && cleanUpTime > 0.0 && spawnId in file.campScriptEntArrays )
		{
			foreach( int handle in file.campScriptEntArrays[spawnId] )
			{
				array<entity> entities = GetScriptManagedEntArray( handle )
				entities.removebyvalue( null )
				foreach ( entity ent in entities )
				{
					if ( IsAlive( ent ) && ent.IsNPC() )
					{
						printt( "Killing bored AI " + ent.GetClassName() + " at " + ent.GetOrigin() )
						ent.Die()
					}
				}
			}
		}

		if ( campLeft <= 0.0 ) // camp wiped!
		{
			PlayFactionDialogueToTeam( "bh_cleared" + campLetter, TEAM_IMC )
			PlayFactionDialogueToTeam( "bh_cleared" + campLetter, TEAM_MILITIA )

			entity campEnt = GetGlobalNetEnt( campEntVarName )
			if ( IsValid( campEnt ) )
				campEnt.Signal( "ATCampClean" ) // destroy the camp ent

			// check if both camps being destroyed
			if ( !IsValid( GetGlobalNetEnt( "camp1Ent" ) ) && !IsValid( GetGlobalNetEnt( "camp2Ent" ) ) )
				svGlobal.levelEnt.Signal( "ATAllCampsClean" ) // end the wave
			
			return
		}

		WaitFrame()
	}
}

// entity funcs
// camp
entity function CreateCampTracker( AT_WaveOrigin campData, int spawnId )
{
	// store data
	vector campOrigin = campData.origin
	float campRadius = campData.radius
	float campHeight = campData.height
	// add a minimap icon
	entity mapIconEnt = CreateEntity( "prop_script" )
	DispatchSpawn( mapIconEnt )

	mapIconEnt.SetOrigin( campOrigin )
	mapIconEnt.DisableHibernation()
	SetTeam( mapIconEnt, AT_AI_TEAM )
	mapIconEnt.Minimap_AlwaysShow( TEAM_IMC, null )
	mapIconEnt.Minimap_AlwaysShow( TEAM_MILITIA, null )

	mapIconEnt.Minimap_SetCustomState( GetCampMinimapState( spawnId ) )
	mapIconEnt.Minimap_SetAlignUpright( true )
	mapIconEnt.Minimap_SetZOrder( MINIMAP_Z_OBJECT )
	mapIconEnt.Minimap_SetObjectScale( campRadius / 16000.0 ) // proper icon on the map

	// attach a location tracker
	entity tracker = GetAvailableLocationTracker()
	tracker.SetOwner( mapIconEnt ) // needs a owner to show up
	tracker.SetOrigin( campOrigin )
	SetLocationTrackerRadius( tracker, campRadius )
	SetLocationTrackerID( tracker, spawnId )
	DispatchSpawn( tracker )

	thread TrackWaveEndForCampInfo( tracker, mapIconEnt )
	return tracker
}

void function TrackWaveEndForCampInfo( entity tracker, entity mapIconEnt )
{
	tracker.EndSignal( "OnDestroy" )
	tracker.EndSignal( "ATCampClean" )

	OnThreadEnd
	(
		function(): ( tracker, mapIconEnt )
		{
			// camp cleaned, wave or game ended, destroy the camp info
			if ( IsValid( tracker ) )
				tracker.Destroy()
			
			if ( IsValid( mapIconEnt ) )
				mapIconEnt.Destroy()
		}
	)

	WaitSignal( svGlobal.levelEnt, "GameStateChanged", "ATWaveEnd" )
}

string function GetCampLetter( int spawnId )
{
	return spawnId == 0 ? "A" : "B"
}

int function GetCampMinimapState( int id )
{
	switch ( id )
	{
		case 0:
			return eMinimapObject_prop_script.AT_DROPZONE_A
		case 1:
			return eMinimapObject_prop_script.AT_DROPZONE_B
		case 2:
			return eMinimapObject_prop_script.AT_DROPZONE_C
	}

	unreachable
}

//////////////////////////////
///// CAMP FUNCTIONS END /////
//////////////////////////////



//////////////////////////
///// BANK FUNCTIONS /////
//////////////////////////

void function AT_BankActiveThink( entity bank )
{
	svGlobal.levelEnt.EndSignal( "GameStateChanged" )
	bank.EndSignal( "OnDestroy" )
	
	// Banks closed
	OnThreadEnd
	(
		function(): ( bank )
		{
			if ( IsValid( bank ) )
			{
				// Update use prompt
				if ( GetGameState() != eGameState.Playing )
					bank.UnsetUsable()
				else
					bank.SetUsePrompts( "#AT_USE_BANK_CLOSED", "#AT_USE_BANK_CLOSED" )

				thread PlayAnim( bank, "mh_active_2_inactive" )
				FadeOutSoundOnEntity( bank, "Mobile_Hardpoint_Idle", 0.5 )
				bank.Minimap_Hide( TEAM_IMC, null )
				bank.Minimap_Hide( TEAM_MILITIA, null )
			}
		}
	)

	// Update use prompt to usable
	bank.SetUsable()
	bank.SetUsePrompts( "#AT_USE_BANK", "#AT_USE_BANK_PC" )

	thread PlayAnim( bank, "mh_inactive_2_active" )
	EmitSoundOnEntity( bank, "Mobile_Hardpoint_Idle" )

	// Show minimap icon for bank
	bank.Minimap_AlwaysShow( TEAM_IMC, null )
	bank.Minimap_AlwaysShow( TEAM_MILITIA, null )
	bank.Minimap_SetCustomState( eMinimapObject_prop_script.AT_BANK )
	
	// Wait for bank close or game end
	while ( GetGlobalNetBool( "banksOpen" ) )
		WaitFrame()
}

function OnPlayerUseBank( bank, player )
{
	// Banks are always usable so that we can show the use prompt
	// Only allow deposit when banks are open
	if ( !GetGlobalNetBool( "banksOpen" ) )
		return

	expect entity( bank )
	expect entity( player )

	// bank.SetUsableByGroup( "pilot" ) didn't seem to work so we just
	// exit here if player is in a titan
	if( player.IsTitan() )
		return

	// Player has no bonus, try to send a tip using SendHUDMessage
	if ( AT_GetPlayerBonusPoints( player ) == 0 )
	{
		ATSendDepositTipToPlayer( player, "#AT_USE_BANK_NO_BONUS_HINT" )
		return
	}

	// Prevent more than one instance of this thread running
	if ( !file.playerBankUploading[ player ] )
		thread PlayerUploadingBonus_Threaded( bank, player )
}

bool function ATSendDepositTipToPlayer( entity player, string message )
{
	if ( Time() < file.playerHudMessageAllowedTime[ player ] )
		return false
	
	SendHudMessage( player, message, -1, 0.4, 255, 255, 255, 255, 0.5, 1.0, 0.5 )
	file.playerHudMessageAllowedTime[ player ] = Time() + AT_PLAYER_HUD_MESSAGE_COOLDOWN

	return true
}

struct AT_playerUploadStruct
{
	bool uploadSuccess = false
	int depositedPoints = 0
}

void function PlayerUploadingBonus_Threaded( entity bank, entity player )
{
	bank.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	file.playerBankUploading[ player ] = true

	// this literally only exists because structs are passed by ref,
	// and primitives like ints and bools are passed by val
	// which meant that the OnThreadEnd was just getting 0 and false
	AT_playerUploadStruct uploadInfo

	// Cleanup and call finish deposit func
	OnThreadEnd
	(
		function(): ( player, uploadInfo )
		{
			if ( IsValid( player ) )
			{
				file.playerBankUploading[ player ] = false

				// Clean up looping sound
				StopSoundOnEntity( player, "HUD_MP_BountyHunt_BankBonusPts_Ticker_Loop_1P" )
				StopSoundOnEntity( player, "HUD_MP_BountyHunt_BankBonusPts_Ticker_Loop_3P" )

				// Do medal event
				// TODO: Check if vanilla actually do.s this every time you finish depositing???
				AddPlayerScore( player, "AttritionCashedBonus" )

				// Do server callback
				Remote_CallFunction_NonReplay( 
					player, 
					"ServerCallback_AT_FinishDeposit",
					uploadInfo.depositedPoints // deposit
				)

				player.SetPlayerNetBool( "AT_playerUploading", false )

				if ( uploadInfo.uploadSuccess ) // Player deposited all remaining bonus
				{
					// Emit uploading successful sound
					EmitSoundOnEntityOnlyToPlayer( player, player, "HUD_MP_BountyHunt_BankBonusPts_Deposit_End_Successful_1P" )
					EmitSoundOnEntityExceptToPlayer( player, player, "HUD_MP_BountyHunt_BankBonusPts_Deposit_End_Successful_3P" )

					// player is MVP
					int ourScore = player.GetPlayerGameStat( PGS_ASSAULT_SCORE )
					bool isMVP = true
					foreach(teamPlayer in GetPlayerArrayOfTeam(player.GetTeam()))
					{
						if (ourScore < teamPlayer.GetPlayerGameStat( PGS_ASSAULT_SCORE ))
						{
							isMVP = false
							break
						}
					}
					if (isMVP)
						PlayFactionDialogueToPlayer( "bh_mvp", player )
				}
				else // Player was killed or left the bank radius
				{
					// Emit uploading failed sound
					EmitSoundOnEntityOnlyToPlayer( player, player, "HUD_MP_BountyHunt_BankBonusPts_Deposit_End_Unsuccessful_1P" )
					EmitSoundOnEntityExceptToPlayer( player, player, "HUD_MP_BountyHunt_BankBonusPts_Deposit_End_Unsuccessful_3P" )
				}
			}
		}
	)

	// Uploading start sound
	EmitSoundOnEntityOnlyToPlayer( player, player, "HUD_MP_BountyHunt_BankBonusPts_Deposit_Start_1P" )
	EmitSoundOnEntityExceptToPlayer( player, player, "HUD_MP_BountyHunt_BankBonusPts_Deposit_Start_3P" )
	EmitSoundOnEntityOnlyToPlayer( player, player, "HUD_MP_BountyHunt_BankBonusPts_Ticker_Loop_1P" )
	EmitSoundOnEntityExceptToPlayer( player, player, "HUD_MP_BountyHunt_BankBonusPts_Ticker_Loop_3P" )

	player.SetPlayerNetBool( "AT_playerUploading", true )
	
	// Upload bonus while the player is within range of the bank
	while ( Distance( player.GetOrigin(), bank.GetOrigin() ) <= AT_BANK_DEPOSIT_RADIUS && GetGlobalNetBool( "banksOpen" ) )
	{
		// Calling this moves the "Uploading..." graphic to the same place it is
		// in vanilla
		Remote_CallFunction_NonReplay( player, "ServerCallback_AT_ShowRespawnBonusLoss" )

		int bonusToUpload = int( min( AT_BANK_DEPOSIT_RATE, AT_GetPlayerBonusPoints( player ) ) )
		// No more bonus to upload, return
		if ( bonusToUpload == 0 )
		{
			uploadInfo.uploadSuccess = true
			return
		}

		// Remove bonus points and add them to total poins
		AT_AddPlayerBonusPoints( player, -bonusToUpload )
		AT_AddPlayerTotalPoints( player, bonusToUpload )

		uploadInfo.depositedPoints += bonusToUpload
		WaitFrame()
	}
}

//////////////////////////////
///// BANK FUNCTIONS END /////
//////////////////////////////



/////////////////////////
///// NPC FUNCTIONS /////
/////////////////////////

int function GetScriptManagedNPCArrayLength_Alive( int scriptManagerId )
{
	array<entity> entities = GetScriptManagedEntArray( scriptManagerId )
	entities.removebyvalue( null )
	int npcsAlive = 0
	foreach ( entity ent in entities )
	{
		if ( IsAlive( ent ) && ent.IsNPC() )
			npcsAlive += 1
	}
	return npcsAlive
}

void function AT_DroppodSquadEvent( AT_WaveOrigin campData, int spawnId, array<AT_SpawnData> minionDatas )
{
	svGlobal.levelEnt.EndSignal( "GameStateChanged" )
	// create a script managed array for all handled minions
	int eventManager = CreateScriptManagedEntArray()

	if( !(spawnId in file.campScriptEntArrays) )
		file.campScriptEntArrays[spawnId] <- []
	
	file.campScriptEntArrays[spawnId].append(eventManager)

	int totalAllowedOnField = SQUAD_SIZE * AT_DROPPOD_SQUADS_ALLOWED_ON_FIELD
	while ( true )
	{
		foreach ( AT_SpawnData data in minionDatas )
		{
			string ent = data.aitype
			waitthread AT_SpawnDroppodSquad( campData, spawnId, ent, eventManager )
			data.pendingSpawns -= SQUAD_SIZE
			if ( data.pendingSpawns <= 0 ) // current spawn data has reached max spawn amount
				minionDatas.removebyvalue( data ) // remove this data
			if ( GetScriptManagedNPCArrayLength_Alive( eventManager ) >= totalAllowedOnField ) // we have enough npcs on field?
				break // stop following spawning functions
		}
		if ( minionDatas.len() == 0 ) // all spawn data has finished spawn
			return

		int npcOnFieldCount = GetScriptManagedNPCArrayLength_Alive( eventManager )
		while ( npcOnFieldCount >= totalAllowedOnField - SQUAD_SIZE ) // wait until we have lost more than 1 squad
		{
			WaitFrame()
			npcOnFieldCount = GetScriptManagedNPCArrayLength_Alive( eventManager )
		}
	}
}

// for AT_USE_TOTAL_ALLOWED_ON_FIELD_CHECK, handles a single spawndata
void function AT_DroppodSquadEvent_Single( AT_WaveOrigin campData, int spawnId, AT_SpawnData data )
{
	svGlobal.levelEnt.EndSignal( "GameStateChanged" )

	// get ent and create a script managed array for current event
	string ent = data.aitype
	int eventManager = CreateScriptManagedEntArray()

	if( !(spawnId in file.campScriptEntArrays) )
		file.campScriptEntArrays[spawnId] <- []
	
	file.campScriptEntArrays[spawnId].append(eventManager)

	int totalAllowedOnField = data.totalAllowedOnField // mostly 12 for grunts and spectres, too much!
	// start spawner
	while ( true )
	{
		waitthread AT_SpawnDroppodSquad( campData, spawnId, ent, eventManager )
		data.pendingSpawns -= SQUAD_SIZE
		if ( data.pendingSpawns <= 0 ) // we have reached max npcs
			return // stop any spawning functions

		int npcOnFieldCount = GetScriptManagedNPCArrayLength_Alive( eventManager )
		while ( npcOnFieldCount >= totalAllowedOnField - SQUAD_SIZE ) // wait until we have less npcs than allowed count
		{
			WaitFrame()
			npcOnFieldCount = GetScriptManagedNPCArrayLength_Alive( eventManager )
		}
	}
}

void function AT_SpawnDroppodSquad( AT_WaveOrigin campData, int spawnId, string aiType, int scriptManagerId )
{
	entity spawnpoint
	if ( campData.dropPodSpawnPoints.len() == 0 )
		spawnpoint = campData.ent
	else
		spawnpoint = campData.dropPodSpawnPoints.getrandom()
	// anti-crash
	if ( !IsValid( spawnpoint ) ) 
		spawnpoint = campData.ent
	
	// add variation to spawns
	wait RandomFloat( 1.0 )
	
	AiGameModes_SpawnDropPod( 
		spawnpoint.GetOrigin(), 
		spawnpoint.GetAngles(), 
		AT_AI_TEAM, 
		aiType, 
		// squad handler
		void function( array<entity> guys ) : ( campData, spawnId, aiType, scriptManagerId ) 
		{
			AT_HandleSquadSpawn( guys, campData, spawnId, aiType, scriptManagerId )
		},
		eDropPodFlag.DISSOLVE_AFTER_DISEMBARKS
	)
}

void function AT_HandleSquadSpawn( array<entity> guys, AT_WaveOrigin campData, int spawnId, string aiType, int scriptManagerId )
{
	foreach ( entity guy in guys )
	{
		// TODO: NPCs still seem to go outside their camp ???
		//guy.EnableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE )

		// tracking lifetime
		AddToScriptManagedEntArray( scriptManagerId, guy )
		thread AT_TrackNPCLifeTime( guy, spawnId, aiType )

		thread AT_ForceAssaultAroundCamp( guy, campData )
	}
}

void function AT_ForceAssaultAroundCamp( entity guy, AT_WaveOrigin campData )
{
	guy.EndSignal( "OnDestroy" )
	guy.EndSignal( "OnDeath" )

	// goal check
	vector ornull goalPos = NavMesh_ClampPointForAI(campData.origin, guy)
	goalPos = goalPos == null ? campData.origin : goalPos
	expect vector(goalPos)

	float goalRadius = campData.radius / 4
	float guyGoalRadius = guy.GetMinGoalRadius()
	if ( guyGoalRadius > goalRadius ) // this npc cannot use forced goal radius?
		goalRadius = guyGoalRadius
	
	while( true )
	{
		guy.AssaultPoint( goalPos )
		guy.AssaultSetGoalRadius( goalRadius )
		guy.AssaultSetFightRadius( 0 ) 
		guy.AssaultSetArrivalTolerance( int(goalRadius) )

		wait RandomFloatRange( 1, 5 )
	}
}

void function AT_ReaperEvent( AT_WaveOrigin campData, int spawnId, AT_SpawnData data )
{
	svGlobal.levelEnt.EndSignal( "GameStateChanged" )

	// create a script managed array for current event
	int eventManager = CreateScriptManagedEntArray()

	if( !(spawnId in file.campScriptEntArrays) )
		file.campScriptEntArrays[spawnId] <- []
	
	file.campScriptEntArrays[spawnId].append(eventManager)
	
	int totalAllowedOnField = 1 // 1 allowed at the same time for heavy armor units
	if ( AT_USE_TOTAL_ALLOWED_ON_FIELD_CHECK )
		totalAllowedOnField = data.totalAllowedOnField
	
	while ( true )
	{
		waitthread AT_SpawnReaper( campData, spawnId, eventManager )
		data.pendingSpawns -= 1
		if ( data.pendingSpawns <= 0 ) // we have reached max npcs
			return // stop any spawning functions

		int npcOnFieldCount = GetScriptManagedNPCArrayLength_Alive( eventManager )
		while ( npcOnFieldCount >= totalAllowedOnField ) // wait until we have less npcs than allowed count
		{
			WaitFrame()
			npcOnFieldCount = GetScriptManagedNPCArrayLength_Alive( eventManager )
		}
	}
}

void function AT_SpawnReaper( AT_WaveOrigin campData, int spawnId, int scriptManagerId )
{
	entity spawnpoint
	if ( campData.dropPodSpawnPoints.len() == 0 )
		spawnpoint = campData.ent
	else
		spawnpoint = campData.dropPodSpawnPoints.getrandom()
	// anti-crash
	if ( !IsValid( spawnpoint ) ) 
		spawnpoint = campData.ent

	// add variation to spawns
	wait RandomFloat( 1.0 )
	
	AiGameModes_SpawnReaper( 
		spawnpoint.GetOrigin(), 
		spawnpoint.GetAngles(), 
		AT_AI_TEAM, 
		"npc_super_spectre_aitdm", 
		// reaper handler
		void function( entity reaper ) : ( campData, spawnId, scriptManagerId ) 
		{
			AT_HandleReaperSpawn( reaper, campData, spawnId, scriptManagerId )
		}
	)
}

void function AT_HandleReaperSpawn( entity reaper, AT_WaveOrigin campData, int spawnId, int scriptManagerId )
{
	// tracking lifetime
	AddToScriptManagedEntArray( scriptManagerId, reaper )
	thread AT_TrackNPCLifeTime( reaper, spawnId, "npc_super_spectre" )

	thread AT_ForceAssaultAroundCamp( reaper, campData )
}

void function AT_BountyTitanEvent( AT_WaveOrigin campData, int spawnId, AT_SpawnData data )
{
	svGlobal.levelEnt.EndSignal( "GameStateChanged" )

	// create a script managed array for current event
	int eventManager = CreateScriptManagedEntArray()
	
	int totalAllowedOnField = 1 // 1 allowed at the same time for heavy armor units
	if ( AT_USE_TOTAL_ALLOWED_ON_FIELD_CHECK )
		totalAllowedOnField = data.totalAllowedOnField
	while ( true )
	{
		waitthread AT_SpawnBountyTitan( campData, spawnId, eventManager )
		data.pendingSpawns -= 1
		if ( data.pendingSpawns <= 0 ) // we have reached max npcs
			return // stop any spawning functions

		int npcOnFieldCount = GetScriptManagedNPCArrayLength_Alive( eventManager )
		while ( npcOnFieldCount >= totalAllowedOnField ) // wait until we have less npcs than allowed count
		{
			WaitFrame()
			npcOnFieldCount = GetScriptManagedNPCArrayLength_Alive( eventManager )
		}
	}
}

void function AT_SpawnBountyTitan( AT_WaveOrigin campData, int spawnId, int scriptManagerId )
{
	entity spawnpoint
	if ( campData.titanSpawnPoints.len() == 0 )
		spawnpoint = campData.ent
	else
		spawnpoint = campData.titanSpawnPoints.getrandom()
	// anti-crash
	if ( !IsValid( spawnpoint ) ) 
		spawnpoint = campData.ent

	// add variation to spawns
	wait RandomFloat( 1.0 )
	
	// look up titan to use
	int bountyID = 0
	try 
	{
		bountyID = ReserveBossID( AT_BOUNTY_TITANS_AI_SETTINGS.getrandom() )
	}
	catch ( ex ) {} // if we go above the expected wave count that vanilla supports, there's basically no way to ensure that this func won't error, so default 0 after that point
	
	string aisettings = GetTypeFromBossID( bountyID )
	string titanClass = expect string( Dev_GetAISettingByKeyField_Global( aisettings, "npc_titan_player_settings" ) )
	
	AiGameModes_SpawnTitan( 
		spawnpoint.GetOrigin(), 
		spawnpoint.GetAngles(), 
		AT_AI_TEAM, 
		titanClass, 
		aisettings,
		// titan handler 
		void function( entity titan ) : ( campData, spawnId, bountyID, scriptManagerId ) 
		{
			AT_HandleBossTitanSpawn( titan, campData, spawnId, bountyID, scriptManagerId )
		} 
	)
}

void function AT_HandleBossTitanSpawn( entity titan, AT_WaveOrigin campData, int spawnId, int bountyID, int scriptManagerId )
{
	// set the bounty to be campEnt, for client tracking
	SetGlobalNetEnt( "camp" + string( spawnId + 1 ) + "Ent", titan )
	// set up health
	titan.SetMaxHealth( titan.GetMaxHealth() * AT_BOUNTY_TITAN_HEALTH_MULTIPLIER )
	titan.SetHealth( titan.GetMaxHealth() )
	// make minimap always show them and highlight them
	titan.Minimap_AlwaysShow( TEAM_IMC, null )
	titan.Minimap_AlwaysShow( TEAM_MILITIA, null )
	thread BountyBossHighlightThink( titan )

	// set up titan-specific death callbacks, mark it as bounty boss
	file.titanIsBountyBoss[ titan ] <- true
	file.bountyTitanRewards[ titan ] <- ATTRITION_SCORE_BOSS_DAMAGE
	AddEntityCallback_OnPostDamaged( titan, OnBountyTitanPostDamage )
	AddEntityCallback_OnKilled( titan, OnBountyTitanKilled )
	
	titan.GetTitanSoul().soul.skipDoomState = true
	// i feel like this should be localised, but there's nothing for it in r1_english?
	titan.SetTitle( GetNameFromBossID( bountyID ) )

	// tracking lifetime
	AddToScriptManagedEntArray( scriptManagerId, titan )
	thread AT_TrackNPCLifeTime( titan, spawnId, "npc_titan" )
}

void function BountyBossHighlightThink( entity titan )
{
	titan.EndSignal( "OnDestroy" )
	titan.EndSignal( "OnDeath" )

	while ( true )
	{
		Highlight_SetEnemyHighlight( titan, "enemy_boss_bounty" )
		titan.WaitSignal( "StopPhaseShift" ) // prevent phase shift mess up highlights
	}
}

void function OnBountyTitanPostDamage( entity titan, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( !IsValid( attacker ) ) // delayed by projectile shots
		return
	// damaged by npc or something?
	if ( !attacker.IsPlayer() )
	{
		attacker = GetBountyBossDamageOwner( attacker, titan )
		if ( !IsValid( attacker ) || !attacker.IsPlayer() )
			return
	}

	int rewardSegment = ATTRITION_SCORE_BOSS_DAMAGE
	int healthSegment = titan.GetMaxHealth() / rewardSegment

	// sometimes damage is not enough to add 1 point, we save the damage for player's next attack
	if ( !( titan in file.playerSavedBountyDamage[ attacker ] ) )
		file.playerSavedBountyDamage[ attacker ][ titan ] <- 0

	file.playerSavedBountyDamage[ attacker ][ titan ] += int( DamageInfo_GetDamage( damageInfo ) )
	if ( file.playerSavedBountyDamage[ attacker ][ titan ] < healthSegment )
		return // they can't earn reward from this shot
	
	int damageSegment = file.playerSavedBountyDamage[ attacker ][ titan ] / healthSegment
	int savedDamageLeft = file.playerSavedBountyDamage[ attacker ][ titan ] % healthSegment
	file.playerSavedBountyDamage[ attacker ][ titan ] = savedDamageLeft

	float damageFrac = float( damageSegment ) / rewardSegment
	int rewardLeft = file.bountyTitanRewards[ titan ]
	int reward = int( ATTRITION_SCORE_BOSS_DAMAGE * damageFrac )
	if ( reward >= rewardLeft ) // overloaded shot?
		reward = rewardLeft
	file.bountyTitanRewards[ titan ] -= reward
	
	if ( reward > 0 )
		AT_AddPlayerBonusPointsForBossDamaged( attacker, titan, reward, damageInfo )
}

void function OnBountyTitanKilled( entity titan, var damageInfo )
{
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	if ( !IsValid( attacker ) ) // delayed by projectile shots
		return
	// damaged by npc or something?
	if ( !attacker.IsPlayer() )
	{
		attacker = GetBountyBossDamageOwner( attacker, titan )
		if ( !IsValid( attacker ) || !attacker.IsPlayer() )
			return
	}

	// add all remaining reward to attacker
	// bounty killed bonus handled by AT_PlayerOrNPCKilledScoreEvent()
	int rewardLeft = file.bountyTitanRewards[ titan ]
	delete file.bountyTitanRewards[ titan ]
	if ( rewardLeft > 0 )
		AT_AddPlayerBonusPointsForBossDamaged( attacker, titan, rewardLeft, damageInfo )

	// remove this bounty's damage saver
	foreach ( entity player in GetPlayerArray() )
	{
		if ( titan in file.playerSavedBountyDamage[ player ] )
			delete file.playerSavedBountyDamage[ player ][ titan ]
	}

	// faction dialogue
	int team = attacker.GetTeam()
	PlayFactionDialogueToPlayer( "bh_playerKilledBounty", attacker )
	PlayFactionDialogueToTeamExceptPlayer( "bh_bountyClaimedByFriendly", team, attacker )
	PlayFactionDialogueToTeam( "bh_bountyClaimedByEnemy", GetOtherTeam( team ) )
}

entity function GetBountyBossDamageOwner( entity attacker, entity titan )
{
	if ( attacker.IsPlayer() ) // already a player
		return attacker
	
	if ( attacker.IsTitan() ) // attacker is a npc titan
	{
		// try to find it's pet titan owner
		if ( IsValid( GetPetTitanOwner( attacker ) ) )
			return GetPetTitanOwner( attacker )
	}

	// other damages or non-owner npcs, not sure how it happens, just use this titan's last attacker
	return GetLatestAssistingPlayerInfo( titan ).player
}

void function AT_TrackNPCLifeTime( entity guy, int spawnId, string aiType )
{
	guy.WaitSignal( "OnDeath", "OnDestroy" )

	string npcNetVar = GetNPCNetVarName( aiType, spawnId )
	SetGlobalNetInt( npcNetVar, GetGlobalNetInt( npcNetVar ) - 1 )
}


// network var
string function GetNPCNetVarName( string className, int spawnId )
{
	string npcId = string( GetAiTypeInt( className ) + 1 )
	string campLetter = GetCampLetter( spawnId )
	if ( npcId == "0" ) // cannot find this ai support!
	{
		if ( className == "npc_super_spectre" ) // stupid, reapers are not handled by GetAiTypeInt(), but it must be 4
			return "4" + campLetter + "campCount"
		return ""
	}
	return npcId + campLetter + "campCount"
}

/////////////////////////////
///// NPC FUNCTIONS END /////
/////////////////////////////
