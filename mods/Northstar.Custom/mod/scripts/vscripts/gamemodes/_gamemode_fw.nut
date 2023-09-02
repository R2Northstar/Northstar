untyped
global function GamemodeFW_Init

// spawn points
global function RateSpawnpointsPilot_FW
global function RateSpawnpointsTitan_FW
//global function RateSpawnpoints_FW

// for battery_port.gnut to work
global function FW_ReplaceMegaTurret

// fw specific titanfalls
global function FW_IsPlayerInFriendlyTerritory
global function FW_IsPlayerInEnemyTerritory

// Callbacks for mods to reduce harvester damage of modded weapons
global function FW_AddHarvesterDamageSourceModifier
global function FW_RemoveHarvesterDamageSourceModifier

// you need to deal this much damage to trigger "FortWarTowerDamage" score event
const int FW_HARVESTER_DAMAGE_SEGMENT = 5250

// basically needs to match "waves count - bosswaves count"
const int FW_MAX_LEVELS = 3

// to confirm it's a npc from camps..
const string FW_NPC_SCRIPTNAME = "fw_npcsFromCamp"
const int FW_AI_TEAM = TEAM_BOTH
const float WAVE_STATE_TRANSITION_TIME = 5.0

// from sh_gamemode_fw, if half of these npcs cleared in one camp, it gets escalate
const int FW_GRUNT_COUNT = 36//32
const int FW_SPECTRE_COUNT = 24
const int FW_REAPER_COUNT = 2

// max deployment each camp
const int FW_GRUNT_MAX_DEPLOYED = 8
const int FW_SPECTRE_MAX_DEPLOYED = 8
const int FW_REAPER_MAX_DEPLOYED = 1

// if other camps been cleaned many times, we levelDown
const int FW_CAMP_IGNORE_NEEDED = 2

// debounce for showing damaged infos
const float FW_HARVESTER_DAMAGED_DEBOUNCE = 5.0
const float FW_TURRET_DAMAGED_DEBOUNCE = 2.0

global HarvesterStruct& fw_harvesterMlt
global HarvesterStruct& fw_harvesterImc

// these are not using respawn's remaining code( sh_gamemode_fw.nut )!

// respawn already have a FW_TowerData struct! this struct is only for score events
struct HarvesterDamageStruct
{
	float recentDamageTime
	int storedDamage
}

struct TurretSiteStruct
{
	entity site
	entity turret
	entity minimapstate
	string turretflagid
}

// respawn already have a FW_CampData, FW_WaveOrigin and FW_SpawnData struct!
struct CampSiteStruct
{
	entity camp
	entity info
	entity tracker
	array<entity> validDropPodSpawns
	array<entity> validTitanSpawns
	string campId // "A", "B", "C"
	int npcsAlive
	int ignoredSinceLastClean
}

struct CampSpawnStruct
{
	string spawnContent // what npcs to spawn
	int maxSpawnCount // max spawn count on this camp
	int countPerSpawn // how many npcs to deploy per spawn, for droppods most be 4
	int killsToEscalate // how many kills needed to escalate
}

struct
{
	array<HarvesterStruct> harvesters
	
	// Stores damage source IDs and the modifier applied to them when they damage a harvester
	table< int, float > harvesterDamageSourceMods

	// save camp's info_target, we spawn camps after game starts, or player's first life won't show up correct camp icons
	array<entity> camps

	array<entity> fwTerritories

	array<TurretSiteStruct> turretsites

	array<CampSiteStruct> fwCampSites

	// respawn already have a FW_TowerData struct! this table is only for score events
	table< entity, HarvesterDamageStruct > playerDamageHarvester // team, table< player, time >
    
	// this is for saving territory's connecting time, try not to make faction dialogues play together
	table< int, float > teamTerrLastConnectTime // team, time
	
	// unused
	array<entity> etitaninmlt
	array<entity> etitaninimc

	entity harvesterMlt_info
	entity harvesterImc_info

	table<int, CampSpawnStruct> fwNpcLevel // basically use to powerup certian camp, sync with alertLevel
	table< string, table< string, int > > trackedCampNPCSpawns
}file

void function GamemodeFW_Init()
{
	// _battery_port.gnut needs this
	RegisterSignal( "BatteryActivate" )

	AiGameModes_SetNPCWeapons( "npc_soldier", [ "mp_weapon_rspn101", "mp_weapon_dmr", "mp_weapon_r97", "mp_weapon_lmg" ] )
	AiGameModes_SetNPCWeapons( "npc_spectre", [ "mp_weapon_hemlok_smg", "mp_weapon_doubletake", "mp_weapon_mastiff" ] )

	AddCallback_EntitiesDidLoad( LoadEntities )
	AddCallback_GameStateEnter( eGameState.Prematch, OnFWGamePrematch )
	AddCallback_GameStateEnter( eGameState.Playing, OnFWGamePlaying )

	AddSpawnCallback( "item_powerup", FWAddPowerUpIcon )
	AddSpawnCallback( "npc_turret_mega", OnFWTurretSpawned )

	AddCallback_OnClientConnected( OnFWPlayerConnected )
	AddCallback_PlayerClassChanged( OnFWPlayerClassChanged )
	AddCallback_OnPlayerKilled( OnFWPlayerKilled )
	AddCallback_OnPilotBecomesTitan( OnFWPilotBecomesTitan )
	AddCallback_OnTitanBecomesPilot( OnFWTitanBecomesPilot )

	ScoreEvent_SetupEarnMeterValuesForMixedModes()
	SetRecalculateRespawnAsTitanStartPointCallback( FW_ForcedTitanStartPoint )
	SetRecalculateTitanReplacementPointCallback( FW_ReCalculateTitanReplacementPoint )
	SetRequestTitanAllowedCallback( FW_RequestTitanAllowed )
}



//////////////////////////
///// HACK FUNCTIONS /////
//////////////////////////

const array<string> HACK_CLEANUP_MAPS =
[
	"mp_grave",
	"mp_homestead",
	"mp_complex3"
]

//if npcs outside the map try to fire( like in death animation ), it will cause a engine error

// in mp_grave, npcs will sometimes stuck underground
const float GRAVE_CHECK_HEIGHT = 1700 // the map's lowest ground is 1950+, npcs will stuck under -4000 or -400
// in mp_homestead, npcs will sometimes stuck in the sky
const float HOMESTEAD_CHECK_HIEGHT = 8000 // the map's highest part is 7868+, npcs will stuck above 13800+
// in mp_complex3, npcs will sometimes stuck in the sky
const float COMPLEX_CHECK_HEIGHT = 7000 // the map's highest part is 6716+, npcs will stuck above 9700+

// do a hack
void function HACK_ForceDestroyNPCs()
{
	thread HACK_ForceDestroyNPCs_Threaded()
}

void function HACK_ForceDestroyNPCs_Threaded()
{
	string mapName = GetMapName()
	if( !( HACK_CLEANUP_MAPS.contains( mapName ) ) )
		return

	while( true )
	{
		if( mapName == "mp_grave" )
		{
			foreach( entity npc in GetNPCArray() )
			{
				if( npc.GetOrigin().z <= GRAVE_CHECK_HEIGHT )
				{
					npc.ClearParent()
					npc.Destroy()
				}
			}
		}
		if( mapName == "mp_homestead" )
		{
			foreach( entity npc in GetNPCArray() )
			{
				// neither spawning from droppod nor hotdropping
				if( !IsValid( npc.GetParent() ) && !npc.e.isHotDropping )
				{
					if( npc.GetOrigin().z >= HOMESTEAD_CHECK_HIEGHT )
					{
						npc.Destroy()
					}
				}
			}
		}
		if( mapName == "mp_complex3" )
		{
			foreach( entity npc in GetNPCArray() )
			{
				// neither spawning from droppod nor hotdropping
				if( !IsValid( npc.GetParent() ) && !npc.e.isHotDropping )
				{
					if( npc.GetOrigin().z >= COMPLEX_CHECK_HEIGHT )
					{
						npc.Destroy()
					}
				}
			}
		}
		WaitFrame()
	}
}

//////////////////////////////
///// HACK FUNCTIONS END /////
//////////////////////////////



////////////////////////////////
///// SPAWNPOINT FUNCTIONS /////
////////////////////////////////

void function RateSpawnpointsPilot_FW( int checkClass, array<entity> spawnpoints, int team, entity player )
{
	array<entity> startSpawns = SpawnPoints_GetPilotStart( team )
	RateSpawnpoints_FW( startSpawns, checkClass, spawnpoints, team, player )
}

void function RateSpawnpointsTitan_FW( int checkClass, array<entity> spawnpoints, int team, entity player )
{
	array<entity> startSpawns = SpawnPoints_GetTitanStart( team )
	RateSpawnpoints_FW( startSpawns, checkClass, spawnpoints, team, player )
}

void function RateSpawnpoints_FW( array<entity> startSpawns, int checkClass, array<entity> spawnpoints, int team, entity player )
{
	if ( HasSwitchedSides() )
		team = GetOtherTeam( team )

	// average out startspawn positions
	vector averageFriendlySpawns
	foreach ( entity spawnpoint in startSpawns )
		averageFriendlySpawns += spawnpoint.GetOrigin()

	averageFriendlySpawns /= startSpawns.len()

	entity friendlyTerritory
	foreach ( entity territory in file.fwTerritories )
	{
		if ( team == territory.GetTeam() )
		{
			friendlyTerritory = territory
			break
		}
	}

	vector ratingPos
	if ( IsValid( friendlyTerritory ) )
		ratingPos = friendlyTerritory.GetOrigin()
	else
		ratingPos = averageFriendlySpawns

	foreach ( entity spawnpoint in spawnpoints )
	{
		// idk about magic number here really
		float rating = 1.0 - ( Distance2D( spawnpoint.GetOrigin(), ratingPos ) / 1000.0 )
		spawnpoint.CalculateRating( checkClass, player.GetTeam(), rating, rating )
	}
}

////////////////////////////////////
///// SPAWNPOINT FUNCTIONS END /////
////////////////////////////////////



//////////////////////////////
///// CALLBACK FUNCTIONS /////
//////////////////////////////

void function OnFWGamePrematch()
{
	InitFWScoreEvents()
	FW_createHarvester()
	InitFWCampSites()
	InitCampSpawnerLevel()
}

void function OnFWGamePlaying()
{
	startFWHarvester()
	FWAreaThreatLevelThink()
	StartFWCampThink()
	InitTurretSettings()
	FWPlayerObjectiveState()

	HACK_ForceDestroyNPCs()
}

void function OnFWPlayerConnected( entity player )
{
	InitFWPlayers( player )
}

void function OnFWPlayerClassChanged( entity player )
{
    // give player a friendly highlight
    Highlight_SetFriendlyHighlight( player, "fw_friendly" )
}

void function OnFWPlayerKilled( entity victim, entity attacker, var damageInfo )
{
	HandleFWPlayerKilledScoreEvent( victim, attacker )
}

void function OnFWPilotBecomesTitan( entity player, entity titan )
{
	// objective stuff
	SetTitanObjective( player, titan )
}

void function OnFWTitanBecomesPilot( entity player, entity titan )
{
	// objective stuff
	SetPilotObjective( player, titan )
}

//////////////////////////////////
///// CALLBACK FUNCTIONS END /////
//////////////////////////////////


/////////////////////////////////
///// SCORE EVENT FUNCTIONS /////
/////////////////////////////////

void function InitFWScoreEvents()
{
	// common scoreEvents
	ScoreEvent_SetEarnMeterValues( "KillHeavyTurret", 0.0, 0.20 ) // can only adds to titan's in this mode

	// fw special: save for later use of scoreEvents

	// combat
	ScoreEvent_SetEarnMeterValues( "FortWarAssault", 0.0, 0.05, 0.0 ) // titans don't earn
	ScoreEvent_SetEarnMeterValues( "FortWarDefense", 0.0, 0.05, 0.0 ) // titans don't earn
	ScoreEvent_SetEarnMeterValues( "FortWarPerimeterDefense", 0.0, 0.05 ) // unused
	ScoreEvent_SetEarnMeterValues( "FortWarSiege", 0.0, 0.05 ) // unused
	ScoreEvent_SetEarnMeterValues( "FortWarSnipe", 0.0, 0.05 ) // unused

	// constructions
	ScoreEvent_SetEarnMeterValues( "FortWarBaseConstruction", 0.0, 0.15 )
	ScoreEvent_SetEarnMeterValues( "FortWarForwardConstruction", 0.0, 0.15 )
	ScoreEvent_SetEarnMeterValues( "FortWarInvasiveConstruction", 0.0, 0.25 ) // unused
	ScoreEvent_SetEarnMeterValues( "FortWarResourceDenial", 0.0, 0.05 ) // unused
	ScoreEvent_SetEarnMeterValues( "FortWarSecuringGatheredResources", 0.0, 0.05 ) // unused

	// tower
	ScoreEvent_SetEarnMeterValues( "FortWarTowerDamage", 0.0, 0.10, 0.0 ) // using the const FW_HARVESTER_DAMAGE_SEGMENT, titans don't earn
	ScoreEvent_SetEarnMeterValues( "FortWarTowerDefense", 0.0, 0.10, 0.0 ) // titans don't earn
	ScoreEvent_SetEarnMeterValues( "FortWarShieldDestroyed", 0.0, 0.15 )

	// turrets
	ScoreEvent_SetEarnMeterValues( "FortWarTeamTurretControlBonus_One", 0.0, 0.15, 0.5 ) // give more meter if no turret left
	ScoreEvent_SetEarnMeterValues( "FortWarTeamTurretControlBonus_Two", 0.0, 0.15, 0.5 )
	ScoreEvent_SetEarnMeterValues( "FortWarTeamTurretControlBonus_Three", 0.0, 0.10, 0.5 )
	ScoreEvent_SetEarnMeterValues( "FortWarTeamTurretControlBonus_Four", 0.0, 0.10, 0.5 ) // give less meter if controlled most turrets
	ScoreEvent_SetEarnMeterValues( "FortWarTeamTurretControlBonus_Five", 0.0, 0.05, 0.5 )
	ScoreEvent_SetEarnMeterValues( "FortWarTeamTurretControlBonus_Six", 0.0, 0.05, 0.5 )
}

// consider this means victim recently damaged harvester
const float TOWER_DEFENSE_REQURED_TIME = 10.0

void function HandleFWPlayerKilledScoreEvent( entity victim, entity attacker )
{
	// this function only handles player's kills
	if( !attacker.IsPlayer() )
		return
    
	// suicide don't get scores
	if( attacker == victim )
		return

	int attackerTeam = attacker.GetTeam()
	int victimTeam = victim.GetTeam()

	string scoreEvent = ""
	int secondaryScore = 0
	entity attackerHarvester = FW_GetTeamHarvesterProp( attackerTeam )

	if( FW_IsPlayerInEnemyTerritory( victim ) ) // victim is in enemy territory
	{
		scoreEvent = "FortWarDefense" // enemy earn score from defense
		secondaryScore = POINTVALUE_FW_DEFENSE
	}

	if( FW_IsPlayerInFriendlyTerritory( victim ) ) // victim is in friendly territory
	{
		scoreEvent = "FortWarAssault" // enemy earn score from assault
		secondaryScore = POINTVALUE_FW_ASSAULT
	}

	if( victim in file.playerDamageHarvester ) // victim has damaged the harvester this life
	{    
		float damageTime = file.playerDamageHarvester[ victim ].recentDamageTime

		// is victim recently damaged havester?
		if( damageTime + TOWER_DEFENSE_REQURED_TIME >= Time() )
		{
			scoreEvent = "FortWarTowerDefense" // you defend the tower!
			secondaryScore = POINTVALUE_FW_TOWER_DEFENSE
		}

	}

	if( scoreEvent != "" )
	{
		AddPlayerScore( attacker, scoreEvent, victim )
		attacker.AddToPlayerGameStat( PGS_DEFENSE_SCORE, secondaryScore )
	}
}

/////////////////////////////////////
///// SCORE EVENT FUNCTIONS END /////
/////////////////////////////////////



//////////////////////////////////////
///// FACTION DIALOGUE FUNCTIONS /////
//////////////////////////////////////

const float FW_TERRYTORY_DIALOGUE_DEBOUNCE = 5.0

// WORKING IN PROGRESS
bool function TryFWTerritoryDialogue( entity territory, entity player )
{
	bool thisTimeIsTitan = player.IsTitan()
	int terrTeam = territory.GetTeam()
	int enemyTeam = GetOtherTeam( terrTeam )
	bool sameTeam = terrTeam == player.GetTeam()
	bool isInDebounce = file.teamTerrLastConnectTime[ terrTeam ] + FW_TERRYTORY_DIALOGUE_DEBOUNCE >= Time()

	// the territory trigger will only save players and titans
	array<entity> allEntsInside = GetAllEntitiesInTrigger( territory )
	allEntsInside.removebyvalue( null ) // since we're using a fake trigger, need to check this
	array<entity> friendliesInside // this means territory's friendly team
	array<entity> enemiesInside // this means territory's enemy team
	array<entity> enemyTitansInside
	foreach( entity ent in allEntsInside )
	{
		if( !IsValid( ent ) ) // since we're using a fake trigger, need to check this
			continue
		if( ent.GetTeam() == terrTeam )
			friendliesInside.append( ent )
	}
	foreach( entity ent in allEntsInside )
	{
		if( !IsValid( ent ) ) // since we're using a fake trigger, need to check this
			continue
		if( ent.GetTeam() != terrTeam )
			enemiesInside.append( ent )
	}
	foreach( entity enemy in enemiesInside )
	{
		if( !IsValid( enemy ) ) // since we're using a fake trigger, need to check this
			continue
		if( enemy.IsTitan() )
			enemyTitansInside.append( enemy )
	}

	print( "enemy in territory: " + string( enemiesInside.len() ) )
	print( "friendly in territory: " + string( friendliesInside.len() ) )

	print( "sameTeam: " + string( sameTeam ) )
	print( "isInDebounce: " + string( isInDebounce ) )
	print( "thisTimeIsTitan: " + string( thisTimeIsTitan ) )

	if( enemiesInside.len() > 3 || friendliesInside.len() > 1 ) // already have some players triggered dialogue
		return false

	// notify player enemy's behaves
	if( !sameTeam ) // player is not the same team as territory
	{
		// consider this means all enemies has left friendly territory, should use a debounce
		if( enemiesInside.len() == 0 && !isInDebounce )
		{
			PlayFactionDialogueToTeam( "fortwar_terEnemyExpelled", terrTeam )
			return true
		}
		// has more than 3 titans inside including new one, ignores debounce
		else if( enemyTitansInside.len() >= 3 && thisTimeIsTitan )
		{
			PlayFactionDialogueToTeam( "fortwar_terPresentEnemyTitans", terrTeam )
			return true
		}
		// only the player inside terrytory
		else if( enemyTitansInside.len() == 1 )
		{
			// entered territory as titan, ignores debounce
			if( thisTimeIsTitan )
			{
				PlayFactionDialogueToTeam( "fortwar_terEnteredEnemyPilot", terrTeam )
				return true
			}
			// entered territory as pilot
			else if( !isInDebounce )
			{
				PlayFactionDialogueToTeam( "fortwar_terEnteredEnemyPilot", terrTeam )
				return true
			}
		}

		// notify player friendly's behaves
		// consider this means all friendlies has left enemy territory
		if( friendliesInside.len() == 0 && !sameTeam && !isInDebounce )
		{
			PlayFactionDialogueToTeam( "fortwar_terFriendlyExpelled", terrTeam )
			return true
		}
	}

	return false
}

//////////////////////////////////////////
///// FACTION DIALOGUE FUNCTIONS END /////
//////////////////////////////////////////



/////////////////////////////////////////
///// GAMEMODE INITIALIZE FUNCTIONS /////
/////////////////////////////////////////

void function LoadEntities()
{
	// info_target
	foreach ( entity info_target in GetEntArrayByClass_Expensive( "info_target" ) )
	{
		if( info_target.HasKey( "editorclass" ) )
		{
			switch( info_target.kv.editorclass )
			{
				case "info_fw_team_tower":
					if ( info_target.GetTeam() == TEAM_IMC )
					{
						file.harvesterImc_info = info_target
						//print("fw_tower tracker spawned")
					}
					if ( info_target.GetTeam() == TEAM_MILITIA )
					{
						file.harvesterMlt_info = info_target
						//print("fw_tower tracker spawned")
					}
					break
				case "info_fw_camp":
					file.camps.append( info_target )
					//InitCampTracker( info_target )
					//print("fw_camp spawned")
					break
				case "info_fw_turret_site":
					string idString = expect string(info_target.kv.turretId)
					int id = int( info_target.kv.turretId )
					//print("info_fw_turret_siteID : " + idString )

					// set this for replace function to find
					TurretSiteStruct turretsite
					file.turretsites.append( turretsite )

					turretsite.site = info_target

					// create turret, spawn with no team and set it after game starts
					entity turret = CreateNPC( "npc_turret_mega", TEAM_UNASSIGNED, info_target.GetOrigin(), info_target.GetAngles() )
					SetSpawnOption_AISettings( turret, "npc_turret_mega_fortwar" )
					DispatchSpawn( turret )

					turretsite.turret = turret

					// init turret settings
					turret.s.minimapstate <- null               // entity, for saving turret's minimap handler
					turret.s.baseTurret <- false                // bool, is this turret from base
					turret.s.turretflagid <- ""                 // string, turret's id like "1", "2", "3"
					turret.s.lastDamagedTime <- 0.0             // float, for showing turret underattack icons
					turret.s.relatedBatteryPort <- null         // entity, corssfile

					// minimap icons holder
					entity minimapstate = CreateEntity( "prop_script" )
					minimapstate.SetValueForModelKey( info_target.GetModelName() ) // these info must have model to work
					minimapstate.Hide() // hide the model! it will still work on minimaps
					minimapstate.SetOrigin( info_target.GetOrigin() )
					minimapstate.SetAngles( info_target.GetAngles() )
					//SetTeam( minimapstate, info_target.GetTeam() ) // setTeam() for icons is done in TurretStateWatcher()
					minimapstate.kv.solid = SOLID_VPHYSICS
					DispatchSpawn( minimapstate )
					// show on minimaps
					minimapstate.Minimap_AlwaysShow( TEAM_IMC, null )
					minimapstate.Minimap_AlwaysShow( TEAM_MILITIA, null )
					minimapstate.Minimap_SetCustomState( eMinimapObject_prop_script.FW_BUILDSITE_SHIELDED )

					turretsite.minimapstate = minimapstate
					turret.s.minimapstate = minimapstate

					break
			}
		}
	}

	// script_ref
	foreach ( entity script_ref in GetEntArrayByClass_Expensive( "script_ref" ) )
	{
		if( script_ref.HasKey( "editorclass" ) )
		{
			switch( script_ref.kv.editorclass )
			{
				case "info_fw_foundation_plate":
					entity prop = CreatePropScript( script_ref.GetModelName(), script_ref.GetOrigin(), script_ref.GetAngles(), 6 )
					break
				case "info_fw_battery_port":
					entity batteryPort = CreatePropScript( script_ref.GetModelName(), script_ref.GetOrigin(), script_ref.GetAngles(), 6 )
					FW_InitBatteryPort(batteryPort)

					break
			}
		}
	}

	// trigger_multiple
	foreach ( entity trigger_multiple in GetEntArrayByClass_Expensive( "trigger_multiple" ) )
	{
		if( trigger_multiple.HasKey( "editorclass" ) )
		{
			switch( trigger_multiple.kv.editorclass )
			{
				case "trigger_fw_territory":
				SetupFWTerritoryTrigger( trigger_multiple )
				break
			}
		}
	}

	// maybe for tick_spawning reapers?
	ValidateAndFinalizePendingStationaryPositions()
}

void function InitCampSpawnerLevel() // can edit this to make more spawns, alertLevel icons supports max to lv3( 0,1,2 )
{
	// lv1 spawns: grunts
	CampSpawnStruct campSpawnLv1
	campSpawnLv1.spawnContent = "npc_soldier"
	campSpawnLv1.maxSpawnCount = FW_GRUNT_MAX_DEPLOYED
	campSpawnLv1.countPerSpawn = 4 // how many npcs to deploy per spawn, for droppods most be 4
	campSpawnLv1.killsToEscalate = FW_GRUNT_COUNT / 2

	file.fwNpcLevel[0] <- campSpawnLv1

	// lv2 spawns: spectres
	CampSpawnStruct campSpawnLv2
	campSpawnLv2.spawnContent = "npc_spectre"
	campSpawnLv2.maxSpawnCount = FW_SPECTRE_MAX_DEPLOYED
	campSpawnLv2.countPerSpawn = 4 // how many npcs to deploy per spawn, for droppods most be 4
	campSpawnLv2.killsToEscalate = FW_SPECTRE_COUNT / 2

	file.fwNpcLevel[1] <- campSpawnLv2

	// lv3 spawns: reapers
	CampSpawnStruct campSpawnLv3
	campSpawnLv3.spawnContent = "npc_super_spectre"
	campSpawnLv3.maxSpawnCount = FW_REAPER_MAX_DEPLOYED
	campSpawnLv3.countPerSpawn = 1 // how many npcs to deploy per spawn
	campSpawnLv3.killsToEscalate = FW_REAPER_COUNT / 2 // only 1 kill needed to spawn the boss?

	file.fwNpcLevel[2] <- campSpawnLv3
}

/////////////////////////////////////////////
///// GAMEMODE INITIALIZE FUNCTIONS END /////
/////////////////////////////////////////////



///////////////////////////////////////
///// PLAYER INITIALIZE FUNCTIONS /////
///////////////////////////////////////

void function InitFWPlayers( entity player )
{
	HarvesterDamageStruct emptyStruct
	file.playerDamageHarvester[ player ] <- emptyStruct

	// objective stuff
	player.s.notifiedTitanfall <- false

	// notification stuff
	player.s.lastTurretNotifyTime <- 0.0
}

///////////////////////////////////////////
///// PLAYER INITIALIZE FUNCTIONS END /////
///////////////////////////////////////////



/////////////////////////////
///// POWERUP FUNCTIONS /////
/////////////////////////////

void function FWAddPowerUpIcon( entity powerup )
{
	powerup.Minimap_SetAlignUpright( true )
	powerup.Minimap_SetZOrder( MINIMAP_Z_OBJECT )
	powerup.Minimap_SetClampToEdge( false )
	powerup.Minimap_AlwaysShow( TEAM_MILITIA, null )
	powerup.Minimap_AlwaysShow( TEAM_IMC, null )
}

/////////////////////////////////
///// POWERUP FUNCTIONS END /////
/////////////////////////////////



/////////////////////////////
///// AICAMPS FUNCTIONS /////
/////////////////////////////

void function InitFWCampSites()
{
	// init here
	foreach( entity info_target in file.camps )
	{
		InitCampTracker( info_target )
	}

	// camps don't have a id, set them manually
	foreach( int index, CampSiteStruct campsite in file.fwCampSites )
	{
		entity campInfo = campsite.camp
		float radius = float( campInfo.kv.radius )

		// get droppod spawns
		foreach ( entity spawnpoint in SpawnPoints_GetDropPod() )
			if ( Distance( campInfo.GetOrigin(), spawnpoint.GetOrigin() ) < radius )
				campsite.validDropPodSpawns.append( spawnpoint )

		// get titan spawns
		foreach ( entity spawnpoint in SpawnPoints_GetTitan() )
			if ( Distance( campInfo.GetOrigin(), spawnpoint.GetOrigin() ) < radius )
				campsite.validTitanSpawns.append( spawnpoint )

		if ( index == 0 )
		{
			campsite.campId = "A"
			SetGlobalNetInt( "fwCampAlertA", 0 )
			SetGlobalNetFloat( "fwCampStressA", 0.0 ) // start from empty
			SetLocationTrackerID( campsite.tracker, 0 )
			file.trackedCampNPCSpawns["A"] <- {}
			continue
		}
		if ( index == 1 )
		{
			campsite.campId = "B"
			SetGlobalNetInt( "fwCampAlertB", 0 )
			SetGlobalNetFloat( "fwCampStressB", 0.0 ) // start from empty
			SetLocationTrackerID( campsite.tracker, 1 )
			file.trackedCampNPCSpawns["B"] <- {}
			continue
		}
		if ( index == 2 )
		{
			campsite.campId = "C"
			SetGlobalNetInt( "fwCampAlertC", 0 )
			SetGlobalNetFloat( "fwCampStressC", 0.0 ) // start from empty
			SetLocationTrackerID( campsite.tracker, 2 )
			file.trackedCampNPCSpawns["C"] <- {}
			continue
		}
	}
}

void function InitCampTracker( entity camp )
{
	//print("InitCampTracker")
	CampSiteStruct campsite
	campsite.camp = camp
	file.fwCampSites.append( campsite )

	entity placementHelper = CreateEntity( "info_placement_helper" )
	placementHelper.SetOrigin( camp.GetOrigin() ) // tracker needs a owner to display
	campsite.info = placementHelper
	DispatchSpawn( placementHelper )

	float radius = float( camp.kv.radius ) // radius to show up icon and spawn ais

	entity tracker = GetAvailableCampLocationTracker()
	tracker.SetOwner( placementHelper )
	campsite.tracker = tracker
	SetLocationTrackerRadius( tracker, radius )
	DispatchSpawn( tracker )
}

void function StartFWCampThink()
{
	foreach( CampSiteStruct camp in file.fwCampSites )
	{
		//print( "has " + string( file.fwCampSites.len() ) + " camps in total" )
		//print( "campId is " + camp.campId )
		thread FWAiCampThink( camp )
	}
}

// this is not using respawn's remaining code!
void function FWAiCampThink( CampSiteStruct campsite )
{
	string campId = campsite.campId
	string alertVarName = "fwCampAlert" + campId
	string stressVarName = "fwCampStress" + campId


	bool firstSpawn = true
	while( GamePlayingOrSuddenDeath() )
	{
		wait WAVE_STATE_TRANSITION_TIME

		int alertLevel = GetGlobalNetInt( alertVarName )
		//print( "campsite" + campId + ".ignoredSinceLastClean: " + string( campsite.ignoredSinceLastClean ) )
		if( campsite.ignoredSinceLastClean >= FW_CAMP_IGNORE_NEEDED && alertLevel > 0 ) // has been ignored many times, level > 0
			alertLevel = 0 // reset level
		else if( !firstSpawn ) // not the first spawn!
			alertLevel += 1 // level up

		if( alertLevel >= FW_MAX_LEVELS - 1 ) // reached max level?
			alertLevel = FW_MAX_LEVELS - 1 // stay

		// update netVars, don't know how client update these, sometimes they can't catch up
		SetGlobalNetInt( alertVarName, alertLevel )
		SetGlobalNetFloat( stressVarName, 1.0 ) // refill

		// under attack, clean this
		campsite.ignoredSinceLastClean = 0

		CampSpawnStruct curSpawnStruct = file.fwNpcLevel[alertLevel]
		string npcToSpawn = curSpawnStruct.spawnContent
		int maxSpawnCount = curSpawnStruct.maxSpawnCount
		int countPerSpawn = curSpawnStruct.countPerSpawn
		int killsToEscalate = curSpawnStruct.killsToEscalate

		// for this time's loop
		file.trackedCampNPCSpawns[campId] = {}
		int killsNeeded = killsToEscalate
		int lastNpcLeft
		while( true )
		{
			WaitFrame()

			//print( alertVarName + " : " + string( GetGlobalNetInt( alertVarName ) ) )
			//print( stressVarName + " : " + string( GetGlobalNetFloat( stressVarName ) ) )
			//print( "campsite" + campId + ".ignoredSinceLastClean: " + string( campsite.ignoredSinceLastClean ) )

			if( !( npcToSpawn in file.trackedCampNPCSpawns[campId] ) ) // init it
				file.trackedCampNPCSpawns[campId][npcToSpawn] <- 0

			int npcsLeft = file.trackedCampNPCSpawns[campId][npcToSpawn]
			killsNeeded -= lastNpcLeft - npcsLeft

			if( killsNeeded <= 0 ) // check if needs more kills
			{
				SetGlobalNetFloat( stressVarName, 0.0 ) // empty
				AddIgnoredCountToOtherCamps( campsite )
				break
			}

			// update stress bar
			float campStressLeft = float( killsNeeded ) / float( killsToEscalate )
			SetGlobalNetFloat( stressVarName, campStressLeft )
			//print( "campStressLeft: " + string( campStressLeft ) )

			if( maxSpawnCount - npcsLeft >= countPerSpawn && killsNeeded >= countPerSpawn ) // keep spawning
			{
				// spawn functions, for fw we only spawn one kind of enemy each time
				// light units
				if( npcToSpawn == "npc_soldier"
				|| npcToSpawn == "npc_spectre"
				|| npcToSpawn == "npc_stalker" )
					thread FW_SpawnDroppodSquad( campsite, npcToSpawn )

				// reapers
				if( npcToSpawn == "npc_super_spectre" )
					thread FW_SpawnReaper( campsite )

				file.trackedCampNPCSpawns[campId][npcToSpawn] += countPerSpawn

				// titans?
				//else if( npcToSpawn == "npc_titan" )
				//{
				//	file.trackedCampNPCSpawns[campId][npcToSpawn] += 4
				//}
			}

			lastNpcLeft = file.trackedCampNPCSpawns[campId][npcToSpawn]
		}

		// first loop ends
		firstSpawn = false
	}
}

void function AddIgnoredCountToOtherCamps( CampSiteStruct senderCamp )
{
	foreach( CampSiteStruct camp in file.fwCampSites )
	{
		//print( "senderCampId is: " + senderCamp.campId )
		//print( "curCampId is " + camp.campId )
		if( camp.campId != senderCamp.campId ) // other camps
		{
			camp.ignoredSinceLastClean += 1
		}
	}
}

// functions from at
void function FW_SpawnDroppodSquad( CampSiteStruct campsite, string aiType )
{
	entity spawnpoint
	if ( campsite.validDropPodSpawns.len() == 0 )
		spawnpoint = campsite.tracker // no spawnPoints valid, use camp itself to spawn
	else
		spawnpoint = campsite.validDropPodSpawns.getrandom()

	// add variation to spawns
	wait RandomFloat( 1.0 )

	AiGameModes_SpawnDropPod( spawnpoint.GetOrigin(), spawnpoint.GetAngles(), FW_AI_TEAM, aiType, void function( array<entity> guys ) : ( campsite, aiType )
	{
		FW_HandleSquadSpawn( guys, campsite, aiType )
	})
}

void function FW_HandleSquadSpawn( array<entity> guys, CampSiteStruct campsite, string aiType )
{
	foreach ( entity guy in guys )
	{
		guy.EnableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_HAND_SIGNALS | NPC_ALLOW_FLEE ) // NPC_ALLOW_INVESTIGATE is not allowed
		guy.SetScriptName( FW_NPC_SCRIPTNAME ) // well no need
		// show on minimap to let players kill them
		guy.Minimap_AlwaysShow( TEAM_MILITIA, null )
		guy.Minimap_AlwaysShow( TEAM_IMC, null )

		// untrack them on death
		thread FW_WaitToUntrackNPC( guy, campsite.campId, aiType )
	}
	// at least don't let them running around
	thread FW_ForceAssaultInCamp( guys, campsite.camp )
}

void function FW_SpawnReaper( CampSiteStruct campsite )
{
	entity spawnpoint
	if ( campsite.validDropPodSpawns.len() == 0 )
		spawnpoint = campsite.tracker // no spawnPoints valid, use camp itself to spawn
	else
		spawnpoint = campsite.validDropPodSpawns.getrandom()

	// add variation to spawns
	wait RandomFloat( 1.0 )

	AiGameModes_SpawnReaper( spawnpoint.GetOrigin(), spawnpoint.GetAngles(), FW_AI_TEAM, "npc_super_spectre_aitdm",void function( entity reaper ) : ( campsite )
	{
		reaper.SetScriptName( FW_NPC_SCRIPTNAME ) // no neet rn
		// show on minimap to let players kill them
		reaper.Minimap_AlwaysShow( TEAM_MILITIA, null )
		reaper.Minimap_AlwaysShow( TEAM_IMC, null )

		// at least don't let them running around
		thread FW_ForceAssaultInCamp( [reaper], campsite.camp )
		// untrack them on death
		thread FW_WaitToUntrackNPC( reaper, campsite.campId, "npc_super_spectre" )
	})
}

// maybe this will make them stay around the camp
void function FW_ForceAssaultInCamp( array<entity> guys, entity camp )
{
	while( true )
	{
		bool oneGuyValid = false
		foreach( entity guy in guys )
		{
			if( IsValid( guy ) )
			{
				guy.AssaultPoint( camp.GetOrigin() )
				guy.AssaultSetGoalRadius( float( camp.kv.radius ) ) // the camp's radius
				guy.AssaultSetFightRadius( 0 )
				oneGuyValid = true
			}
		}
		if( !oneGuyValid ) // no guys left
			return

		wait RandomFloatRange( 10, 15 ) // make randomness
	}
}

void function FW_WaitToUntrackNPC( entity guy, string campId, string aiType )
{
	guy.WaitSignal( "OnDeath", "OnDestroy" )
	if( aiType in file.trackedCampNPCSpawns[ campId ] ) // maybe escalated?
		file.trackedCampNPCSpawns[ campId ][ aiType ]--
}

/////////////////////////////////
///// AICAMPS FUNCTIONS END /////
/////////////////////////////////



///////////////////////////////
///// TERRITORY FUNCTIONS /////
///////////////////////////////

void function SetupFWTerritoryTrigger( entity trigger )
{
	//print("trigger_fw_territory detected")
	file.fwTerritories.append( trigger )
	trigger.ConnectOutput( "OnStartTouch", EntityEnterFWTrig )
	trigger.ConnectOutput( "OnEndTouch", EntityLeaveFWTrig )

	// respawn didn't leave a key for trigger's team, let's set it manually.
	if( Distance( trigger.GetOrigin(), file.harvesterMlt_info.GetOrigin() ) > Distance( trigger.GetOrigin(), file.harvesterImc_info.GetOrigin() ) )
		SetTeam( trigger, TEAM_IMC )
	else
		SetTeam( trigger, TEAM_MILITIA )

	// init
	file.teamTerrLastConnectTime[ trigger.GetTeam() ] <- 0.0

	thread FWTerritoryTriggerThink( trigger )
}

// since we're using a trigger_multiple, needs this to remove invalid keys
void function FWTerritoryTriggerThink( entity trigger )
{
	trigger.EndSignal( "OnDestroy" )

	while( true )
	{
		if( null in trigger.e.scriptTriggerData.entities )
			delete trigger.e.scriptTriggerData.entities[ null ]
		WaitFrame()
	}
}

void function EntityEnterFWTrig( entity trigger, entity ent, entity caller, var value )
{
	if( !IsValid( ent ) ) // post-spawns
		return
	if( !ent.IsPlayer() && !ent.IsTitan() ) // no neet to add props and grunts i guess
		return
	// functions that trigger_multiple missing
	if( IsValid( ent ) )
	{
		ScriptTriggerAddEntity( trigger, ent )
		thread ScriptTriggerPlayerDisconnectThink( trigger, ent )
		//TryFWTerritoryDialogue( trigger, ent ) // WIP
		file.teamTerrLastConnectTime[ trigger.GetTeam() ] = Time()
	}

	if( !IsValid(ent) )
		return
	if ( ent.IsPlayer() ) // notifications for player
	{
		MessageToPlayer( ent, eEventNotifications.Clear ) // clean up last message
		bool sameTeam = ent.GetTeam() == trigger.GetTeam()
		if ( sameTeam )
		{
			Remote_CallFunction_NonReplay( ent , "ServerCallback_FW_NotifyEnterFriendlyArea" )
			ent.SetPlayerNetInt( "indicatorId", 1 ) // 1 means "FRIENDLY TERRITORY"
		}
		else
		{
			Remote_CallFunction_NonReplay( ent , "ServerCallback_FW_NotifyEnterEnemyArea" )
			ent.SetPlayerNetInt( "indicatorId", 2 ) // 2 means "ENEMY TERRITORY"
		}
	}
}

void function EntityLeaveFWTrig( entity trigger, entity ent, entity caller, var value )
{
	if( !IsValid( ent ) ) // post-spawns
		return
	if( !ent.IsPlayer() && !ent.IsTitan() ) // no neet to add props and grunts i guess
		return
	// functions that trigger_multiple missing
	 if( IsValid( ent ) )
	{
		if( ent in trigger.e.scriptTriggerData.entities ) // need to check this!
		{
			ScriptTriggerRemoveEntity( trigger, ent )
			//TryFWTerritoryDialogue( trigger, ent ) // WIP
			file.teamTerrLastConnectTime[ trigger.GetTeam() ] = Time()
		}
	}

	if( !IsValid(ent) )
		return
	if ( ent.IsPlayer() ) // notifications for player
	{
		MessageToPlayer( ent, eEventNotifications.Clear ) // clean up
		bool sameTeam = ent.GetTeam() == trigger.GetTeam()
		if ( sameTeam )
			Remote_CallFunction_NonReplay( ent , "ServerCallback_FW_NotifyExitFriendlyArea" )
		else
			Remote_CallFunction_NonReplay( ent , "ServerCallback_FW_NotifyExitEnemyArea" )
		ent.SetPlayerNetInt( "indicatorId", 4 ) // 4 means "NO MAN'S LAND"
	}
}

// globlized!
bool function FW_IsPlayerInFriendlyTerritory( entity player )
{
	foreach( entity trigger in file.fwTerritories )
	{
		if( trigger.GetTeam() == player.GetTeam() ) // is it friendly one?
		{
			if( GetAllEntitiesInTrigger( trigger ).contains( player ) ) // is player inside?
				return true
		}
	}
	return false // can't find the player
}

// globlized!
bool function FW_IsPlayerInEnemyTerritory( entity player )
{
	foreach( entity trigger in file.fwTerritories )
	{
		if( trigger.GetTeam() != player.GetTeam() ) // is it enemy one?
		{
			 if( GetAllEntitiesInTrigger( trigger ).contains( player ) ) // is player inside?
				return true
		}
	}
	return false // can't find the player
}

///////////////////////////////////
///// TERRITORY FUNCTIONS END /////
///////////////////////////////////



////////////////////////////////
///// TITANSPAWN FUNCTIONS /////
////////////////////////////////

// territory trigger don't have a kv.radius, let's use a const
// 2800 will pretty much get harvester's near titan startpoints
const float FW_SPAWNPOINT_SEARCH_RADIUS = 2800.0


Point function FW_ReCalculateTitanReplacementPoint( Point basePoint, entity player )
{
	int team = player.GetTeam()
	// find team's harvester
	entity teamHarvester = FW_GetTeamHarvesterProp( team )

	if ( !IsValid( teamHarvester ) ) // team's havester has been destroyed!
        return basePoint // return given value
		
	if( Distance2D( basePoint.origin, teamHarvester.GetOrigin() ) <= FW_SPAWNPOINT_SEARCH_RADIUS ) // close enough!
		return basePoint // this origin is good enough

	// if not close enough to base, re-calculate
	array<entity> fortWarPoints = FW_GetTitanSpawnPointsForTeam( team )
	entity validPoint = GetClosest( fortWarPoints, basePoint.origin )
	basePoint.origin = validPoint.GetOrigin()
	return basePoint
}

bool function FW_RequestTitanAllowed( entity player, array< string > args )
{
	if( !FW_IsPlayerInFriendlyTerritory( player ) ) // is player in friendly base?
	{
		PlayFactionDialogueToPlayer( "tw_territoryNag", player ) // notify player
		TryPlayTitanfallNegativeSoundToPlayer( player )
		int objectiveID = 101 // which means "#FW_OBJECTIVE_TITANFALL"
		Remote_CallFunction_NonReplay( player, "ServerCallback_FW_SetObjective", objectiveID ) 
		return false
	}
	return true
}

bool function TryPlayTitanfallNegativeSoundToPlayer( entity player )
{
	if( !( "lastNegativeSound" in player.s ) )
		player.s.lastNegativeSound <- 0.0 // float
	if( player.s.lastNegativeSound + 1.0 > Time() ) // in sound cooldown
		return false

	// use a sound to notify player they can't titanfall here
	EmitSoundOnEntityOnlyToPlayer( player, player, "titan_dryfire" )
	player.s.lastNegativeSound = Time()
	
	return true
}

array<entity> function FW_GetTitanSpawnPointsForTeam( int team )
{
	array<entity> validSpawnPoints
	// find team's harvester
	entity teamHarvester = FW_GetTeamHarvesterProp( team )

	array<entity> allPoints
	// same as _replacement_titans_drop.gnut does
	allPoints.extend( GetEntArrayByClass_Expensive( "info_spawnpoint_titan" ) )
	allPoints.extend( GetEntArrayByClass_Expensive( "info_spawnpoint_titan_start" ) )
	allPoints.extend( GetEntArrayByClass_Expensive( "info_replacement_titan_spawn" ) )

	// get valid points from all points
	foreach( entity point in allPoints )
	{
		if( Distance2D( point.GetOrigin(), teamHarvester.GetOrigin() ) <= FW_SPAWNPOINT_SEARCH_RADIUS )
			validSpawnPoints.append( point )
	}

	return validSpawnPoints
}

// some maps have reversed startpoints! we need a hack
const array<string> TITAN_POINT_REVERSED_MAPS =
[
	"mp_grave"
]

// "Respawn as Titan" don't follow the rateSpawnPoints, fix it manually
entity function FW_ForcedTitanStartPoint( entity player, entity basePoint )
{
	int team = player.GetTeam()
	if ( TITAN_POINT_REVERSED_MAPS.contains( GetMapName() ) )
		team = GetOtherTeam( player.GetTeam() )
	array<entity> startPoints = SpawnPoints_GetTitanStart( team )
	entity validPoint = startPoints[ RandomInt( startPoints.len() ) ] // choose a random( maybe not safe ) start point
	return validPoint
}

////////////////////////////////////
///// TITANSPAWN FUNCTIONS END /////
////////////////////////////////////



/////////////////////////////////
///// THREATLEVEL FUNCTIONS /////
/////////////////////////////////

void function FWAreaThreatLevelThink()
{
	thread FWAreaThreatLevelThink_Threaded()
}

void function FWAreaThreatLevelThink_Threaded()
{
	entity imcTerritory
	entity mltTerritory
	foreach( entity territory in file.fwTerritories )
	{
		if( territory.GetTeam() == TEAM_IMC )
			imcTerritory = territory
		else
			mltTerritory = territory
	}

	float lastWarningTime // for debounce
	bool warnImcTitanApproach
	bool warnMltTitanApproach
	bool warnImcTitanInArea
	bool warnMltTitanInArea

	while( GamePlayingOrSuddenDeath() )
	{
		//print( " imc threat level is: " + string( GetGlobalNetInt( "imcTowerThreatLevel" ) ) )
		//print( " mlt threat level is: " + string( GetGlobalNetInt( "milTowerThreatLevel" ) ) )
		float imcLastDamage = fw_harvesterImc.lastDamage
		float mltLastDamage = fw_harvesterMlt.lastDamage
		bool imcShieldDown = fw_harvesterImc.harvesterShieldDown
		bool mltShieldDown = fw_harvesterMlt.harvesterShieldDown

		// imc threatLevel
		if( imcLastDamage + FW_HARVESTER_DAMAGED_DEBOUNCE >= Time() && imcShieldDown )
			SetGlobalNetInt( "imcTowerThreatLevel", 3 ) // 3 will show a "harvester being damaged" warning to player
		else if( warnImcTitanInArea )
			SetGlobalNetInt( "imcTowerThreatLevel", 2 ) // 2 will show a "titan in area" warning to player
		else if( warnImcTitanApproach )
			SetGlobalNetInt( "imcTowerThreatLevel", 1 ) // 1 will show a "titan approach" waning to player
		else
			SetGlobalNetInt( "imcTowerThreatLevel", 0 ) // 0 will hide all warnings

		// militia threatLevel
		if( mltLastDamage + FW_HARVESTER_DAMAGED_DEBOUNCE >= Time() && mltShieldDown )
			SetGlobalNetInt( "milTowerThreatLevel", 3 ) // 3 will show a "harvester being damaged" warning to player
		else if( warnMltTitanInArea )
			SetGlobalNetInt( "milTowerThreatLevel", 2 ) // 2 will show a "titan in area" warning to player
		else if( warnMltTitanApproach )
			SetGlobalNetInt( "milTowerThreatLevel", 1 ) // 1 will show a "titan approach" waning to player
		else
			SetGlobalNetInt( "milTowerThreatLevel", 0 ) // 0 will hide all warnings


		// clean it here
		warnImcTitanInArea = false
		warnMltTitanInArea = false
		warnImcTitanApproach = false
		warnMltTitanApproach = false

		// get valid titans
		array<entity> allTitans = GetNPCArrayByClass( "npc_titan" )
		array<entity> allPlayers = GetPlayerArray()
		foreach( entity player in allPlayers )
		{
			if( IsAlive( player ) && player.IsTitan() )
			{
				allTitans.append( player )
			}
		}

		// check threats
		array<entity> imcEntArray = GetAllEntitiesInTrigger( imcTerritory )
		array<entity> mltEntArray = GetAllEntitiesInTrigger( mltTerritory )
		imcEntArray.removebyvalue( null ) // since we're using a fake trigger, need to check this
		mltEntArray.removebyvalue( null )
		foreach( entity ent in imcEntArray )
		{
			//print( ent )
			if( !IsValid( ent ) ) // since we're using a fake trigger, need to check this
				continue
			if( ent.IsPlayer() || ent.IsNPC() )
			{
				if( ent.IsTitan() && ent.GetTeam() != TEAM_IMC )
					warnImcTitanInArea = true
			}
		}
		foreach( entity ent in mltEntArray )
		{
			//print( ent )
			if( !IsValid( ent ) ) // since we're using a fake trigger, need to check this
				continue
			if( ent.IsPlayer() || ent.IsNPC() )
			{
				if( ent.IsTitan() && ent.GetTeam() != TEAM_MILITIA )
					warnMltTitanInArea = true
			}
		}

		foreach( entity titan in allTitans )
		{
			if( !imcEntArray.contains( titan )
			&& !mltEntArray.contains( titan )
			&& titan.GetTeam() != TEAM_IMC
			&& !titan.e.isHotDropping )
				warnImcTitanApproach = true // this titan must be in natural space

			if( !mltEntArray.contains( titan )
			&& !imcEntArray.contains( titan )
			&& titan.GetTeam() != TEAM_MILITIA
			&& !titan.e.isHotDropping )
				warnMltTitanApproach = true // this titan must be in natural space
		}

		WaitFrame()
	}
}

/////////////////////////////////////
///// THREATLEVEL FUNCTIONS END /////
/////////////////////////////////////



////////////////////////////
///// TURRET FUNCTIONS /////
////////////////////////////

void function OnFWTurretSpawned( entity turret )
{
	turret.EnableTurret() // always enabled
	SetDefaultMPEnemyHighlight( turret ) // for sonar highlights to work
	AddEntityCallback_OnDamaged( turret, OnMegaTurretDamaged )
	thread FWTurretHighlightThink( turret )
}

// this will clear turret's highlight upon their death, for notifying players to fix them
void function FWTurretHighlightThink( entity turret )
{
	turret.EndSignal( "OnDestroy" )
	WaitFrame() // wait a frame for other turret spawn options to set up
	Highlight_SetFriendlyHighlight( turret, "fw_friendly" ) // initialize the highlight, they will show upon player's next respawn

	turret.WaitSignal( "OnDeath" )
	Highlight_ClearFriendlyHighlight( turret )
}

// for battery_port, replace the turret with new one
entity function FW_ReplaceMegaTurret( entity perviousTurret )
{
	if( !IsValid( perviousTurret ) ) // previous turret not exist!
		return

	entity turret = CreateNPC( "npc_turret_mega", perviousTurret.GetTeam(), perviousTurret.GetOrigin(), perviousTurret.GetAngles() )
	SetSpawnOption_AISettings( turret, "npc_turret_mega_fortwar" )
	DispatchSpawn( turret )

	// apply settings to new turret, must up on date
	turret.s.baseTurret <- perviousTurret.s.baseTurret
	turret.s.minimapstate <- perviousTurret.s.minimapstate
	turret.s.turretflagid <- perviousTurret.s.turretflagid
	turret.s.lastDamagedTime <- perviousTurret.s.lastDamagedTime
	turret.s.relatedBatteryPort <- perviousTurret.s.relatedBatteryPort

	int maxHealth = perviousTurret.GetMaxHealth()
	int maxShield = perviousTurret.GetShieldHealthMax()
	turret.SetMaxHealth( maxHealth )
	turret.SetHealth( maxHealth )
	turret.SetShieldHealth( maxShield )
	turret.SetShieldHealthMax( maxShield )

	// update turretSiteStruct
	foreach( TurretSiteStruct turretsite in file.turretsites )
	{
		if( turretsite.turret == perviousTurret )
		{
			turretsite.turret = turret // only changed this
		}
	}

	perviousTurret.Destroy() // destroy previous one

	return turret
}

// avoid notifications overrides itself
const float TURRET_NOTIFICATION_DEBOUNCE = 10.0

void function OnMegaTurretDamaged( entity turret, var damageInfo )
{
	int damageSourceID = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	float damageAmount = DamageInfo_GetDamage( damageInfo )
	int scriptType = DamageInfo_GetCustomDamageType( damageInfo )
	int turretTeam = turret.GetTeam()

	if ( !damageSourceID && !damageAmount && !attacker )
		return

	if( turret.GetShieldHealth() - damageAmount <= 0 && scriptType != damageTypes.rodeoBatteryRemoval ) // this shot breaks shield
	{
		if ( !attacker.IsTitan() && !IsSuperSpectre( attacker ) )
		{
			if( attacker.IsPlayer() && attacker.GetTeam() != turret.GetTeam() ) // good to have
			{
				// avoid notifications overrides itself
				if( attacker.s.lastTurretNotifyTime + TURRET_NOTIFICATION_DEBOUNCE < Time() )
				{
					MessageToPlayer( attacker, eEventNotifications.Clear ) // clean up last message
					MessageToPlayer( attacker, eEventNotifications.TurretTitanDamageOnly )
					attacker.s.lastTurretNotifyTime = Time()
				}
			}
			DamageInfo_SetDamage( damageInfo, turret.GetShieldHealth() ) // destroy shields
			return
		}
	}

	// successfully damaged turret
	turret.s.lastDamagedTime = Time()

	if ( damageSourceID == eDamageSourceId.mp_titanweapon_heat_shield ||
	damageSourceID == eDamageSourceId.mp_titanweapon_meteor_thermite ||
	damageSourceID == eDamageSourceId.mp_titanweapon_flame_wall ||
	damageSourceID == eDamageSourceId.mp_titanability_slow_trap ||
	damageSourceID == eDamageSourceId.mp_titancore_flame_wave_secondary
	) // scorch's thermite damages
		DamageInfo_SetDamage( damageInfo, DamageInfo_GetDamage( damageInfo )/2 ) // nerf scorch

	// faction dialogue
	damageAmount = DamageInfo_GetDamage( damageInfo )
	if( turret.GetHealth() - damageAmount <= 0 ) // turret killed this shot
	{
		if( GamePlayingOrSuddenDeath() )
			PlayFactionDialogueToTeam( "fortwar_turretDestroyedFriendly", turretTeam )
	}
}

void function InitTurretSettings()
{
	foreach( TurretSiteStruct turretSite in file.turretsites )
	{
		entity turret = turretSite.turret
		entity minimapstate = turretSite.minimapstate
		int teamNum = turretSite.site.GetTeam()
		int id = int( string( turretSite.site.kv.turretId ) )
		string idString = string( id + 1 )
		int team = int( string( turretSite.site.kv.teamnumber ) )

		int stateFlag = 1 // netural

		// spawn with teamNumber?
		if( team == TEAM_IMC || team == TEAM_MILITIA )
			turret.s.baseTurret = true

		//SetTeam( minimapstate, team ) // setTeam() for icons is done in TurretStateWatcher()
		SetTeam( turret, team )

		//print( "Try to set globatNetEnt: " + "turretSite" + idString )

		turret.s.turretflagid = idString
		turretSite.turretflagid = idString

		thread TurretStateWatcher( turretSite )
	}
}

// about networkvar "turretStateFlags" value
// 1 means destoryed/netural
// 2 means imc turret
// 4 means mlt turret
// 10 means shielded imc turret
// 13 means shielded mlt turret
// 16 means destoryed/netural being attacked
// 18 means imc turret being attacked
// 20 means mlt turret being attacked
// 26 means shielded imc turret being attacked
// 28 means shielded mlt turret being attacked

// unsure:
// 24 means destroyed imc turret being attacked?
// 40 means destroyed imc turret?
// 48 means destroyed mlt turret being attacked?

const int TURRET_DESTROYED_FLAG = 1
const int TURRET_NATURAL_FLAG = 1
const int TURRET_IMC_FLAG = 2
const int TURRET_MLT_FLAG = 4
const int TURRET_SHIELDED_IMC_FLAG = 10
const int TURRET_SHIELDED_MLT_FLAG = 13

const int TURRET_UNDERATTACK_NATURAL_FLAG = 16
const int TURRET_UNDERATTACK_IMC_FLAG = 18
const int TURRET_UNDERATTACK_MLT_FLAG = 20
// natural turret noramlly can't get shielded
const int TURRET_SHIELDED_UNDERATTACK_IMC_FLAG = 26
const int TURRET_SHIELDED_UNDERATTACK_MLT_FLAG = 28

void function TurretStateWatcher( TurretSiteStruct turretSite )
{
	entity mapIcon = turretSite.minimapstate
	entity turret = turretSite.turret
	entity batteryPort = expect entity( turret.s.relatedBatteryPort )

	int turretHealth = GetCurrentPlaylistVarInt( "fw_turret_health", FW_DEFAULT_TURRET_HEALTH )
	int turretShield = GetCurrentPlaylistVarInt( "fw_turret_shield", FW_DEFAULT_TURRET_SHIELD )
	turret.SetMaxHealth( turretHealth )
	turret.SetHealth( turretHealth )
	turret.SetShieldHealthMax( turretShield )

	string idString = turretSite.turretflagid
	string siteVarName = "turretSite" + idString
	string stateVarName = "turretStateFlags" + idString

	// battery overlay icons holder
	entity overlayState = CreateEntity( "prop_script" )
	overlayState.SetValueForModelKey( $"models/communication/flag_base.mdl" ) // requires a model to show overlays
	overlayState.Hide() // this can still show players overlay icons
	overlayState.SetOrigin( batteryPort.GetOrigin() ) // tracking batteryPort's positions
	overlayState.SetAngles( batteryPort.GetAngles() )
	overlayState.kv.solid = SOLID_VPHYSICS
	DispatchSpawn( overlayState )

	svGlobal.levelEnt.EndSignal( "CleanUpEntitiesForRoundEnd" ) // end dialogues is good
	mapIcon.EndSignal( "OnDestroy" ) // mapIcon should be valid all time, tracking it
	batteryPort.EndSignal( "OnDestroy" ) // also track this
	overlayState.EndSignal( "OnDestroy" )

	SetGlobalNetEnt( siteVarName, overlayState ) // tracking batteryPort's positions and team
	SetGlobalNetInt( stateVarName, TURRET_NATURAL_FLAG ) // init for all turrets

	int lastFrameTeam
	bool lastFrameIsAlive

	while( true )
	{
		WaitFrame() // start of the loop

		turret = turretSite.turret // need to keep updating, for sometimes it being replaced

		if( !IsValid( turret ) ) // replacing turret this frame
			continue // skip the loop once

		bool isBaseTurret = expect bool( turret.s.baseTurret )
		int turretTeam = turret.GetTeam()
		bool turretAlive = IsAlive( turret )

		bool changedTeamThisFrame = lastFrameTeam != turretTeam // turret has changed team?
		bool killedThisFrame = lastFrameIsAlive != turretAlive // turret has no health left?

		if( !turretAlive ) // turret down, waiting to be repaired
		{
			if( !isBaseTurret ) // never reset base turret's team
			{
				SetTeam( turret, TEAM_UNASSIGNED )
				SetTeam( mapIcon, TEAM_UNASSIGNED )
				SetTeam( batteryPort, TEAM_UNASSIGNED )
				SetTeam( overlayState, TEAM_UNASSIGNED )
				batteryPort.SetUsableByGroup( "pilot" ) // show hints to any pilot
			}
			SetGlobalNetInt( stateVarName, TURRET_DESTROYED_FLAG )
			continue
		}

		// wrong dialogue, it will say "The turret you requested is on the way"
		//if( changedTeamThisFrame ) // has been hacked!
		//    PlayFactionDialogueToTeam( "fortwar_turretDeployFriendly", turretTeam )

		int iconTeam = turretTeam == TEAM_BOTH ? TEAM_UNASSIGNED : turretTeam // specific check
		SetTeam( mapIcon, iconTeam ) // update icon's team
		SetTeam( batteryPort, turretTeam ) // update batteryPort's team
		SetTeam( overlayState, iconTeam ) // update overlayEnt's team

		if( turretTeam != TEAM_BOTH && turretTeam != TEAM_UNASSIGNED ) // not a natural turret nor dead
			batteryPort.SetUsableByGroup( "friendlies pilot" ) // only show hint to friendlies

		float lastDamagedTime = expect float( turret.s.lastDamagedTime )
		int stateFlag = TURRET_NATURAL_FLAG

		// imc states
		if( iconTeam == TEAM_IMC )
		{
			if( lastDamagedTime + FW_TURRET_DAMAGED_DEBOUNCE >= Time() ) // recent underattack
			{
				if( turret.GetShieldHealth() > 0 ) // has shields
					stateFlag = TURRET_SHIELDED_UNDERATTACK_IMC_FLAG
				else
					stateFlag = TURRET_UNDERATTACK_IMC_FLAG

				// these dialogue have 30s debounce inside
				if( isBaseTurret )
					PlayFactionDialogueToTeam( "fortwar_baseTurretsUnderAttack", TEAM_IMC )
				else
					PlayFactionDialogueToTeam( "fortwar_awayTurretsUnderAttack", TEAM_IMC )
			}
			else if( turret.GetShieldHealth() > 0 ) // has shields left
				stateFlag = TURRET_SHIELDED_IMC_FLAG
			else
				stateFlag = TURRET_IMC_FLAG
		}

		// mlt states
		if( iconTeam == TEAM_MILITIA )
		{
			if( lastDamagedTime + FW_TURRET_DAMAGED_DEBOUNCE >= Time() ) // recent underattack
			{
				if( turret.GetShieldHealth() > 0 ) // has shields
					stateFlag = TURRET_SHIELDED_UNDERATTACK_MLT_FLAG
				else
					stateFlag = TURRET_UNDERATTACK_MLT_FLAG

				// these dialogue have 30s debounce inside
				if( isBaseTurret )
					PlayFactionDialogueToTeam( "fortwar_baseTurretsUnderAttack", TEAM_MILITIA )
				else
					PlayFactionDialogueToTeam( "fortwar_awayTurretsUnderAttack", TEAM_MILITIA )
			}
			else if( turret.GetShieldHealth() > 0 ) // has shields left
				stateFlag = TURRET_SHIELDED_MLT_FLAG
			else
				stateFlag = TURRET_MLT_FLAG
		}

		// natural states
		if( iconTeam == TEAM_UNASSIGNED )
		{
			if( lastDamagedTime + FW_TURRET_DAMAGED_DEBOUNCE >= Time() ) // recent underattack
				stateFlag = TURRET_UNDERATTACK_NATURAL_FLAG
			else
				stateFlag = TURRET_NATURAL_FLAG
		}

		SetGlobalNetInt( stateVarName, stateFlag )

		// update these
		lastFrameTeam = turretTeam
		lastFrameIsAlive = turretAlive

		WaitFrame()
	}
}

////////////////////////////////
///// TURRET FUNCTIONS END /////
////////////////////////////////



///////////////////////////////
///// HARVESTER FUNCTIONS /////
///////////////////////////////

void function startFWHarvester()
{
	thread HarvesterThink(fw_harvesterImc)
	thread HarvesterAlarm(fw_harvesterImc)
	thread UpdateHarvesterHealth( TEAM_IMC )

	thread HarvesterThink(fw_harvesterMlt)
	thread HarvesterAlarm(fw_harvesterMlt)
	thread UpdateHarvesterHealth( TEAM_MILITIA )
}

entity function FW_GetTeamHarvesterProp( int team )
{
	if( team == TEAM_IMC )
		return fw_harvesterImc.harvester
	else if( team == TEAM_MILITIA )
		return fw_harvesterMlt.harvester

	unreachable // crash the game
}

void function FW_createHarvester()
{
	// imc havester spawn
	fw_harvesterImc = SpawnHarvester( file.harvesterImc_info.GetOrigin(), file.harvesterImc_info.GetAngles(), GetCurrentPlaylistVarInt( "fw_harvester_health", FW_DEFAULT_HARVESTER_HEALTH ), GetCurrentPlaylistVarInt( "fw_harvester_shield", FW_DEFAULT_HARVESTER_SHIELD ), TEAM_IMC )
	fw_harvesterImc.harvester.SetArmorType( ARMOR_TYPE_HEAVY )
	fw_harvesterImc.harvester.Minimap_SetAlignUpright( true )
	fw_harvesterImc.harvester.Minimap_AlwaysShow( TEAM_IMC, null )
	fw_harvesterImc.harvester.Minimap_AlwaysShow( TEAM_MILITIA, null )
	fw_harvesterImc.harvester.Minimap_SetHeightTracking( true )
	fw_harvesterImc.harvester.Minimap_SetZOrder( MINIMAP_Z_OBJECT )
	fw_harvesterImc.harvester.Minimap_SetCustomState( eMinimapObject_prop_script.FD_HARVESTER )
	AddEntityCallback_OnFinalDamaged( fw_harvesterImc.harvester, OnHarvesterDamaged )
	AddEntityCallback_OnPostDamaged( fw_harvesterImc.harvester, OnHarvesterPostDamaged )
	
	// imc havester settings
	// don't set this, or sonar pulse will try to find it and failed to set highlight
	//fw_harvesterMlt.harvester.SetScriptName("fw_team_tower")
	file.harvesters.append(fw_harvesterImc)
	entity trackerImc = GetAvailableBaseLocationTracker()
	trackerImc.SetOwner( fw_harvesterImc.harvester )
	DispatchSpawn( trackerImc )
	SetLocationTrackerRadius( trackerImc, 1 ) // whole map

	// scores starts from 100, TeamScore means harvester health; TeamScore2 means shield bar
	GameRules_SetTeamScore( TEAM_MILITIA , 100 )
	GameRules_SetTeamScore2( TEAM_MILITIA , 100 )


	// mlt havester spawn
	fw_harvesterMlt = SpawnHarvester( file.harvesterMlt_info.GetOrigin(), file.harvesterMlt_info.GetAngles(), GetCurrentPlaylistVarInt( "fw_harvester_health", FW_DEFAULT_HARVESTER_HEALTH ), GetCurrentPlaylistVarInt( "fw_harvester_shield", FW_DEFAULT_HARVESTER_SHIELD ), TEAM_MILITIA )
	fw_harvesterMlt.harvester.SetArmorType( ARMOR_TYPE_HEAVY )
	fw_harvesterMlt.harvester.Minimap_SetAlignUpright( true )
	fw_harvesterMlt.harvester.Minimap_AlwaysShow( TEAM_IMC, null )
	fw_harvesterMlt.harvester.Minimap_AlwaysShow( TEAM_MILITIA, null )
	fw_harvesterMlt.harvester.Minimap_SetHeightTracking( true )
	fw_harvesterMlt.harvester.Minimap_SetZOrder( MINIMAP_Z_OBJECT )
	fw_harvesterMlt.harvester.Minimap_SetCustomState( eMinimapObject_prop_script.FD_HARVESTER )
	AddEntityCallback_OnFinalDamaged( fw_harvesterMlt.harvester, OnHarvesterDamaged )
	AddEntityCallback_OnPostDamaged( fw_harvesterMlt.harvester, OnHarvesterPostDamaged )

	// mlt havester settings
	// don't set this, or sonar pulse will try to find it and failed to set highlight
	//fw_harvesterImc.harvester.SetScriptName("fw_team_tower")
	file.harvesters.append(fw_harvesterMlt)
	entity trackerMlt = GetAvailableBaseLocationTracker()
	trackerMlt.SetOwner( fw_harvesterMlt.harvester )
	DispatchSpawn( trackerMlt )
	SetLocationTrackerRadius( trackerMlt, 1 ) // whole map

	// scores starts from 100, TeamScore means harvester health; TeamScore2 means shield bar
	GameRules_SetTeamScore( TEAM_IMC , 100 )
	GameRules_SetTeamScore2( TEAM_IMC , 100 )

	InitHarvesterDamageMods()
}

void function FW_AddHarvesterDamageSourceModifier( int id, float mod )
{
	if ( !( id in file.harvesterDamageSourceMods ) )
		file.harvesterDamageSourceMods[id] <- 1.0

	file.harvesterDamageSourceMods[id] *= mod
}

void function FW_RemoveHarvesterDamageSourceModifier( int id, float mod )
{
	if ( !( id in file.harvesterDamageSourceMods ) )
		return

	file.harvesterDamageSourceMods[id] /= mod

	if ( file.harvesterDamageSourceMods[id] == 1.0 )
		delete file.harvesterDamageSourceMods[id]
}

void function InitHarvesterDamageMods()
{
	// Damage balancing
	const float CORE_DAMAGE_FRAC = 0.67
	const float NUKE_EJECT_DAMAGE_FRAC = 0.25
	const float DOT_DAMAGE_FRAC = 0.5

	// Core balancing
	FW_AddHarvesterDamageSourceModifier( eDamageSourceId.mp_titancore_laser_cannon, CORE_DAMAGE_FRAC )
	FW_AddHarvesterDamageSourceModifier( eDamageSourceId.mp_titancore_salvo_core, CORE_DAMAGE_FRAC )
	FW_AddHarvesterDamageSourceModifier( eDamageSourceId.mp_titanweapon_flightcore_rockets, CORE_DAMAGE_FRAC )
	FW_AddHarvesterDamageSourceModifier( eDamageSourceId.mp_titancore_shift_core, CORE_DAMAGE_FRAC )
	// Flame Core is not included since its single target damage is low compared to the others

	// Nuke eject balancing
	FW_AddHarvesterDamageSourceModifier( eDamageSourceId.damagedef_nuclear_core, NUKE_EJECT_DAMAGE_FRAC )

	// Damage over time balancing
	FW_AddHarvesterDamageSourceModifier( eDamageSourceId.mp_titanweapon_dumbfire_rockets, DOT_DAMAGE_FRAC )
	FW_AddHarvesterDamageSourceModifier( eDamageSourceId.mp_titanweapon_meteor_thermite, DOT_DAMAGE_FRAC )
	FW_AddHarvesterDamageSourceModifier( eDamageSourceId.mp_titanweapon_flame_wall, DOT_DAMAGE_FRAC )
	FW_AddHarvesterDamageSourceModifier( eDamageSourceId.mp_titanability_slow_trap, DOT_DAMAGE_FRAC )
	FW_AddHarvesterDamageSourceModifier( eDamageSourceId.mp_titancore_flame_wave_secondary, DOT_DAMAGE_FRAC )
	FW_AddHarvesterDamageSourceModifier( eDamageSourceId.mp_titanweapon_heat_shield, DOT_DAMAGE_FRAC )
}

// this function can't handle specific damageSourceID, such as plasma railgun, but is the best to scale both shield and health damage
void function OnHarvesterDamaged( entity harvester, var damageInfo )
{
	if ( !IsValid( harvester ) )
		return

	// Entities (non-Players and non-NPCs) don't consider damaged entity lists, which makes ground attacks (e.g. Arc Wave) and thermite hit more than they should
	entity inflictor = DamageInfo_GetInflictor( damageInfo )
	if ( IsValid( inflictor ) && ( inflictor.e.onlyDamageEntitiesOnce || inflictor.e.onlyDamageEntitiesOncePerTick ) )
	{
		if ( inflictor.e.damagedEntities.contains( harvester ) )
		{
			DamageInfo_SetDamage( damageInfo, 0 )
			return
		}
		else
		{
			inflictor.e.damagedEntities.append( harvester )
		}
	}

	int friendlyTeam = harvester.GetTeam()
	int enemyTeam = GetOtherTeam( friendlyTeam )
	int damageSourceID = DamageInfo_GetDamageSourceIdentifier( damageInfo )
		
	HarvesterStruct harvesterstruct // current harveter's struct
	if( friendlyTeam == TEAM_MILITIA )
		harvesterstruct = fw_harvesterMlt
	if( friendlyTeam == TEAM_IMC )
		harvesterstruct = fw_harvesterImc

	float damageAmount = DamageInfo_GetDamage( damageInfo )
	if((harvester.GetShieldHealth()-damageAmount)<0)
	{
		if( !harvesterstruct.harvesterShieldDown )
		{
			PlayFactionDialogueToTeam( "fortwar_baseShieldDownFriendly", friendlyTeam )
			PlayFactionDialogueToTeam( "fortwar_baseShieldDownEnemy", enemyTeam )
			harvesterstruct.harvesterShieldDown = true // prevent shield dialogues from repeating
		}
	}

	// always reset harvester's recharge delay
	harvesterstruct.lastDamage = Time()

	// Should be moved to a final damage callback once those are added
	if ( damageSourceID in file.harvesterDamageSourceMods )
		DamageInfo_ScaleDamage( damageInfo, file.harvesterDamageSourceMods[ damageSourceID ] )
}
void function OnHarvesterPostDamaged( entity harvester, var damageInfo )
{
	if ( !IsValid( harvester ) )
		return

	int friendlyTeam = harvester.GetTeam()
	int enemyTeam = GetOtherTeam( friendlyTeam )

	GameRules_SetTeamScore( friendlyTeam , 1.0 * GetHealthFrac( harvester ) * 100 )

	int damageSourceID = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	int scriptType = DamageInfo_GetCustomDamageType( damageInfo )
	float damageAmount = DamageInfo_GetDamage( damageInfo )

	if(damageAmount == 0)
		return

	if ( !damageSourceID && !damageAmount && !attacker ) // actually not dealing any damage?
		return
	
	// prevent player from sniping the harvester cross-map
	if ( attacker.IsPlayer() && !FW_IsPlayerInEnemyTerritory( attacker ) )
	{
		Remote_CallFunction_NonReplay( attacker , "ServerCallback_FW_NotifyNeedsEnterEnemyArea" )
		DamageInfo_SetDamage( damageInfo, 0 )
		DamageInfo_SetCustomDamageType( damageInfo, scriptType | DF_NO_INDICATOR ) // hide the hitmarker
		return // these damage won't do anything to the harvester
	}

	HarvesterStruct harvesterstruct // current harveter's struct
	if( friendlyTeam == TEAM_MILITIA )
		harvesterstruct = fw_harvesterMlt
	if( friendlyTeam == TEAM_IMC )
		harvesterstruct = fw_harvesterImc


	damageAmount = DamageInfo_GetDamage( damageInfo ) // get damageAmount again after all damage adjustments

	if ( !attacker.IsTitan() )
	{
		if( attacker.IsPlayer() )
			Remote_CallFunction_NonReplay( attacker , "ServerCallback_FW_NotifyTitanRequired" )
		DamageInfo_SetDamage( damageInfo, harvester.GetShieldHealth() )
		damageAmount = 0 // never damage haveter's prop
	}

	if( !harvesterstruct.harvesterShieldDown )
	{
		PlayFactionDialogueToTeam( "fortwar_baseShieldDownFriendly", friendlyTeam )
		PlayFactionDialogueToTeam( "fortwar_baseShieldDownEnemy", enemyTeam )
		harvesterstruct.harvesterShieldDown = true // prevent shield dialogues from repeating
	}

	harvesterstruct.harvesterDamageTaken = harvesterstruct.harvesterDamageTaken + damageAmount // track damage for wave recaps
	float newHealth = harvester.GetHealth() - damageAmount
	float oldhealthpercent = ( ( harvester.GetHealth().tofloat() / harvester.GetMaxHealth() ) * 100 )
	float healthpercent = ( ( newHealth / harvester.GetMaxHealth() ) * 100 )

	if (healthpercent <= 75 && oldhealthpercent > 75) // we don't want the dialogue to keep saying "Harvester is below 75% health" everytime they take additional damage
	{
		PlayFactionDialogueToTeam( "fortwar_baseDmgFriendly75", friendlyTeam )
		PlayFactionDialogueToTeam( "fortwar_baseDmgEnemy75", enemyTeam )
	}

	if (healthpercent <= 50 && oldhealthpercent > 50)
	{
		PlayFactionDialogueToTeam( "fortwar_baseDmgFriendly50", friendlyTeam )
		PlayFactionDialogueToTeam( "fortwar_baseDmgEnemy50", enemyTeam )
	}

	if (healthpercent <= 25 && oldhealthpercent > 25)
	{
		PlayFactionDialogueToTeam( "fortwar_baseDmgFriendly25", friendlyTeam )
		PlayFactionDialogueToTeam( "fortwar_baseDmgEnemy25", enemyTeam )
	}

	if( newHealth <= 0 )
	{
		EmitSoundAtPosition(TEAM_UNASSIGNED,harvesterstruct.harvester.GetOrigin(),"coop_generator_destroyed")
		newHealth = 0
		harvesterstruct.rings.Destroy()
		harvesterstruct.harvester.Dissolve( ENTITY_DISSOLVE_CORE, Vector( 0, 0, 0 ), 500 )
	}

	harvester.SetHealth( newHealth )
	harvesterstruct.havesterWasDamaged = true

	if ( attacker.IsPlayer() )
	{
        // dialogue for enemy attackers
        if( !harvesterstruct.harvesterShieldDown )
            PlayFactionDialogueToTeam( "fortwar_baseEnemyAllyAttacking", enemyTeam )

		attacker.NotifyDidDamage( harvester, DamageInfo_GetHitBox( damageInfo ), DamageInfo_GetDamagePosition( damageInfo ), DamageInfo_GetCustomDamageType( damageInfo ), DamageInfo_GetDamage( damageInfo ), DamageInfo_GetDamageFlags( damageInfo ), DamageInfo_GetHitGroup( damageInfo ), DamageInfo_GetWeapon( damageInfo ), DamageInfo_GetDistFromAttackOrigin( damageInfo ) )

        // get newest damage for adding score!
        int scoreDamage = int( DamageInfo_GetDamage( damageInfo ) )
        // score events
        attacker.AddToPlayerGameStat( PGS_ASSAULT_SCORE, scoreDamage )

        // add to player structs
        file.playerDamageHarvester[ attacker ].recentDamageTime = Time()
        file.playerDamageHarvester[ attacker ].storedDamage += scoreDamage

        // enough to earn score?
        if( file.playerDamageHarvester[ attacker ].storedDamage >= FW_HARVESTER_DAMAGE_SEGMENT )
        {
            AddPlayerScore( attacker, "FortWarTowerDamage", attacker )
            attacker.AddToPlayerGameStat( PGS_DEFENSE_SCORE, POINTVALUE_FW_TOWER_DAMAGE )
            file.playerDamageHarvester[ attacker ].storedDamage -= FW_HARVESTER_DAMAGE_SEGMENT // reset stored damage
        }
	}

	// harvester down!
    if ( harvester.GetHealth() == 0 )
    {
		// force deciding winner
        SetWinner( enemyTeam )
        //PlayFactionDialogueToTeam( "scoring_wonMercy", enemyTeam )
        //PlayFactionDialogueToTeam( "fortwar_matchLoss", friendlyTeam )
        GameRules_SetTeamScore2( friendlyTeam, 0 ) // force set score2 to 0( shield bar will empty )
        GameRules_SetTeamScore( friendlyTeam, 0 ) // force set score to 0( health 0% )
    }
}

void function HarvesterThink( HarvesterStruct fw_harvester )
{
	entity harvester = fw_harvester.harvester


	EmitSoundOnEntity( harvester, "coop_generator_startup" )

	float lastTime = Time()
	wait 4
	int lastShieldHealth = harvester.GetShieldHealth()
	generateBeamFX( fw_harvester )
	generateShieldFX( fw_harvester )

	EmitSoundOnEntity( harvester, "coop_generator_ambient_healthy" )

	bool isRegening = false // stops the regenning sound to keep stacking on top of each other

	while ( IsAlive( harvester ) )
	{
		float currentTime = Time()
		float deltaTime = currentTime -lastTime

		if ( IsValid( fw_harvester.particleShield ) )
		{
			vector shieldColor = GetShieldTriLerpColor( 1.0 - ( harvester.GetShieldHealth().tofloat() / harvester.GetShieldHealthMax().tofloat() ) )
			EffectSetControlPointVector( fw_harvester.particleShield, 1, shieldColor )
		}

		if( IsValid( fw_harvester.particleBeam ) )
		{
			vector beamColor = GetShieldTriLerpColor( 1.0 - ( harvester.GetHealth().tofloat() / harvester.GetMaxHealth().tofloat() ) )
			EffectSetControlPointVector( fw_harvester.particleBeam, 1, beamColor )
		}

		if ( fw_harvester.harvester.GetShieldHealth() == 0 )
			if( IsValid( fw_harvester.particleShield ) )
				fw_harvester.particleShield.Destroy()

		if ( ( ( currentTime-fw_harvester.lastDamage ) >= GetCurrentPlaylistVarFloat( "fw_harvester_regen_delay", FW_DEFAULT_HARVESTER_REGEN_DELAY ) ) && ( harvester.GetShieldHealth() < harvester.GetShieldHealthMax() ) )
		{
			if( !IsValid( fw_harvester.particleShield ) )
				generateShieldFX( fw_harvester )

			if( harvester.GetShieldHealth() == 0 )
				EmitSoundOnEntity( harvester, "coop_generator_shieldrecharge_start" )

			if (!isRegening)
			{
				EmitSoundOnEntity( harvester, "coop_generator_shieldrecharge_resume" )
				fw_harvester.harvesterShieldDown = false
				isRegening = true
			}

			float newShieldHealth = ( harvester.GetShieldHealthMax() / GetCurrentPlaylistVarFloat( "fw_harvester_regen_time", FW_DEFAULT_HARVESTER_REGEN_TIME ) * deltaTime ) + harvester.GetShieldHealth()

			// shield full
			if ( newShieldHealth >= harvester.GetShieldHealthMax() )
			{
				StopSoundOnEntity( harvester, "coop_generator_shieldrecharge_resume" )
				harvester.SetShieldHealth( harvester.GetShieldHealthMax() )
				EmitSoundOnEntity( harvester, "coop_generator_shieldrecharge_end" )
				PlayFactionDialogueToTeam( "fortwar_baseShieldUpFriendly", harvester.GetTeam() )
				isRegening = false
			}
			else
			{
				harvester.SetShieldHealth( newShieldHealth )
			}
		}
		else if ( ( ( currentTime-fw_harvester.lastDamage ) < GENERATOR_SHIELD_REGEN_DELAY ) && ( harvester.GetShieldHealth() < harvester.GetShieldHealthMax() ) )
		{
			isRegening = false
		}

		if ( ( lastShieldHealth > 0 ) && ( harvester.GetShieldHealth() == 0 ) )
		{
			EmitSoundOnEntity( harvester, "TitanWar_Harvester_ShieldDown" ) // add this
			EmitSoundOnEntity( harvester, "coop_generator_shielddown" )
		}

		lastShieldHealth = harvester.GetShieldHealth()
		lastTime = currentTime
		WaitFrame()
	}
}

void function HarvesterAlarm( HarvesterStruct fw_harvester )
{
	while( IsAlive( fw_harvester.harvester ) )
	{
		if( fw_harvester.harvester.GetShieldHealth() == 0 )
		{
			wait EmitSoundOnEntity( fw_harvester.harvester, "coop_generator_underattack_alarm" )
		}
		else
		{
			WaitFrame()
		}
	}
}

void function UpdateHarvesterHealth( int team )
{
	entity harvester
	if( team == TEAM_MILITIA )
		harvester = fw_harvesterMlt.harvester
	if( team == TEAM_IMC )
		harvester = fw_harvesterImc.harvester

	while( true )
	{
		if( IsValid(harvester) )
		{
			GameRules_SetTeamScore2( team, 1.0 * harvester.GetShieldHealth() / harvester.GetShieldHealthMax() * 100 )
			WaitFrame()
		}
		else // harvester down
		{
			int winnerTeam = GetOtherTeam(team)
			SetWinner( winnerTeam )
			//PlayFactionDialogueToTeam( "scoring_wonMercy", winnerTeam )
			//PlayFactionDialogueToTeam( "fortwar_matchLoss", team )
			GameRules_SetTeamScore2( team, 0 ) // force set score2 to 0( shield bar will empty )
			GameRules_SetTeamScore( team, 0 ) // force set score to 0( health 0% )
			break
		}
	}
}

///////////////////////////////////
///// HARVESTER FUNCTIONS END /////
///////////////////////////////////



//////////////////////////////////////
///// PLAYER OBJECTIVE FUNCTIONS /////
//////////////////////////////////////

const int APPLY_BATTERY_TEXT_INDEX = 96 // notify player to use batteries on turrets
const int EARN_TITAN_TEXT_INDEX = 100 // notify player to earn titans
const int CALL_IN_TITAN_TEXT_INDEX = 101 // notify player to call in titans in territory
const int EMBARK_TITAN_TEXT_INDEX = 102 // notify player to embark titans
const int ATTACK_HARVESTER_TEXT_INDEX = 103 // notify player to attack harvester

void function FWPlayerObjectiveState()
{
	thread FWPlayerObjectiveState_Threaded()
}

void function FWPlayerObjectiveState_Threaded()
{
	while( GamePlayingOrSuddenDeath() )
	{
		foreach( player in GetPlayerArray() )
		{
			entity petTitan = player.GetPetTitan()
			entity titanSoul
			if( IsValid( petTitan ) )
				titanSoul = petTitan.GetTitanSoul()

			if ( IsValid( GetBatteryOnBack( player ) ) )
				player.SetPlayerNetInt( "gameInfoStatusText", APPLY_BATTERY_TEXT_INDEX ) 
			else if ( IsTitanAvailable( player ) )
			{
				if( !player.s.notifiedTitanfall ) // first notification, also do a objective announcement
				{
					SetObjective( player, CALL_IN_TITAN_TEXT_INDEX )
					player.s.notifiedTitanfall = true
				}
				else
					player.SetPlayerNetInt( "gameInfoStatusText", CALL_IN_TITAN_TEXT_INDEX ) 
			}
			else if ( IsValid( petTitan ) )
				player.SetPlayerNetInt( "gameInfoStatusText", EMBARK_TITAN_TEXT_INDEX )
			else if ( IsAlive( player ) && !player.IsTitan() )
				player.SetPlayerNetInt( "gameInfoStatusText", EARN_TITAN_TEXT_INDEX )
			else if( !IsValid( titanSoul ) ) // titan died or player first embarked
				player.s.notifiedTitanfall = false

			if ( !IsAlive( player ) ) // don't show objetive for dying players
				player.SetPlayerNetInt( "gameInfoStatusText", -1 )
		}
		WaitFrame()
	}

	// game entered other state, clean this
	foreach( player in GetPlayerArray() )
	{
		player.SetPlayerNetInt( "gameInfoStatusText", -1 )
	}
}

void function SetObjective( entity player, int stringid )
{
	Remote_CallFunction_NonReplay( player, "ServerCallback_FW_SetObjective", stringid )
	player.SetPlayerNetInt( "gameInfoStatusText", stringid )
}

void function SetTitanObjective( entity player, entity titan )
{
	SetObjective( player, ATTACK_HARVESTER_TEXT_INDEX )
}

void function SetPilotObjective( entity player, entity titan )
{
	if( titan.GetTitanSoul().IsEjecting() ) // this time titan is ejecting
	{
		SetObjective( player, EARN_TITAN_TEXT_INDEX )
		player.s.notifiedTitanfall = false
	}
	else
		player.SetPlayerNetInt( "gameInfoStatusText", EMBARK_TITAN_TEXT_INDEX )
}

//////////////////////////////////////////
///// PLAYER OBJECTIVE FUNCTIONS END /////
//////////////////////////////////////////



/////////////////////////////////
///// BatteryPort Functions /////
/////////////////////////////////

void function FW_InitBatteryPort( entity batteryPort )
{
	batteryPort.kv.fadedist = 10000 // try not to fade
	InitTurretBatteryPort( batteryPort )

	batteryPort.s.relatedTurret <- null             // entity, for saving batteryPort's nearest turret

	entity turret = GetNearestMegaTurret( batteryPort ) // consider this is the port's related turret
	
	bool isBaseTurret = expect bool( turret.s.baseTurret )
	SetTeam( batteryPort, turret.GetTeam() )
	batteryPort.s.relatedTurret = turret
	batteryPort.s.isUsable <- FW_IsBatteryPortUsable
	batteryPort.s.useBattery <- FW_UseBattery
	if( isBaseTurret ) // this is a base turret!
	{
		batteryPort.s.hackAvaliable = false
		batteryPort.SetUsableByGroup( "friendlies pilot" ) // only show hint to friendlies
	} // it can never be hacked!
	
	turret.s.relatedBatteryPort = batteryPort // do it here
}

function FW_IsBatteryPortUsable( batteryPortvar, playervar ) //actually bool function( entity, entity )
{	
	entity batteryPort = expect entity( batteryPortvar )
	entity player = expect entity( playervar )
	entity turret = expect entity( batteryPort.s.relatedTurret )
    if( !IsValid( turret ) ) // turret has been destroyed!
        return false

	// get turret's settings, decide behavior
	bool validTeam = turret.GetTeam() == player.GetTeam() || turret.GetTeam() == TEAM_BOTH || turret.GetTeam() == TEAM_UNASSIGNED
    bool isBaseTurret = expect bool( turret.s.baseTurret )
    // is this port able to be hacked
    bool portHackAvaliable = expect bool( batteryPort.s.hackAvaliable )

    // player has a battery, team valid or able to hack && not a base turret
    return ( PlayerHasBattery( player ) && ( validTeam || ( portHackAvaliable && !isBaseTurret ) ) )
}

function FW_UseBattery( batteryPortvar, playervar ) //actually void function( entity, entity )
{
	entity batteryPort = expect entity( batteryPortvar )
	entity player = expect entity( playervar )
	// change turret settings
    entity turret = expect entity( batteryPort.s.relatedTurret ) // consider this is the port's related turret

    int playerTeam = player.GetTeam()
    bool turretReplaced = false
    bool sameTeam = turret.GetTeam() == player.GetTeam()

    if( !IsAlive( turret ) ) // turret has been killed!
    {
        turret = FW_ReplaceMegaTurret( turret )
        if( !IsValid( turret ) ) // replace failed!
            return
        batteryPort.s.relatedTurret = turret
        turretReplaced = true // if turret has been replaced, mostly reset team!
    }

    bool teamChanged = false
    bool isBaseTurret = expect bool( turret.s.baseTurret )
    if( ( !sameTeam || turretReplaced ) && !isBaseTurret ) // is there a need to change team?
    {
        SetTeam( turret, playerTeam )
        teamChanged = true
    }

    // restore turret health
    int newHealth = int ( min( turret.GetMaxHealth(), turret.GetHealth() + ( turret.GetMaxHealth() * GetCurrentPlaylistVarFloat( "fw_turret_fixed_health", TURRET_FIXED_HEALTH_PERCENTAGE ) ) ) )
    if( turretReplaced || teamChanged ) // replaced/hacked turret will spawn with 50% health
        newHealth = int ( turret.GetMaxHealth() * GetCurrentPlaylistVarFloat( "fw_turret_hacked_health", TURRET_HACKED_HEALTH_PERCENTAGE ) )
    // restore turret shield
    int newShield = int ( min( turret.GetShieldHealthMax(), turret.GetShieldHealth() + ( turret.GetShieldHealth() * GetCurrentPlaylistVarFloat( "fw_turret_fixed_shield", TURRET_FIXED_SHIELD_PERCENTAGE ) ) ) )
    if( turretReplaced || teamChanged ) // replaced/hacked turret will spawn with 50% shield
        newShield = int ( turret.GetShieldHealthMax() * GetCurrentPlaylistVarFloat( "fw_turret_hacked_shield", TURRET_HACKED_SHIELD_PERCENTAGE ) )
    // only do team score event if turret's shields down, encourage players to hack more turrets
    bool additionalScore = turret.GetShieldHealth() <= 0
    // this can be too much powerful
    turret.SetHealth( newHealth )
    turret.SetShieldHealth( newShield )

    // score event
    string scoreEvent = "FortWarForwardConstruction"
    int secondaryScore = POINTVALUE_FW_FORWARD_CONSTRUCTION
    if( isBaseTurret ) // this is a base turret
    {
        scoreEvent = "FortWarBaseConstruction"
        secondaryScore = POINTVALUE_FW_BASE_CONSTRUCTION
    }
    AddPlayerScore( player, scoreEvent, player ) // player themself gets more meter
    player.AddToPlayerGameStat( PGS_DEFENSE_SCORE, secondaryScore )

    // only do team score event if turret's shields down
    if( additionalScore )
    {
        // get turrets alive, for adding scores
        string teamTurretCount = GetTeamAliveTurretCount_ReturnString( playerTeam )
        foreach( entity friendly in GetPlayerArrayOfTeam( playerTeam ) )
            AddPlayerScore( friendly, "FortWarTeamTurretControlBonus_" + teamTurretCount, friendly )

        PlayFactionDialogueToTeam( "fortwar_turretShieldedByFriendlyPilot", playerTeam )
    }

}

// get nearest turret, consider it belongs to the port
entity function GetNearestMegaTurret( entity ent )
{
    array<entity> allTurrets = GetNPCArrayByClass( "npc_turret_mega" )
    entity turret = GetClosest( allTurrets, ent.GetOrigin() )
    return turret
}

// this will get english name of the count, since the "FortWarTeamTurretControlBonus_" score event uses it
string function GetTeamAliveTurretCount_ReturnString( int team )
{
    int turretCount
    foreach( entity turret in GetNPCArrayByClass( "npc_turret_mega" ) )
    {
        if( turret.GetTeam() == team && IsAlive( turret ) )
            turretCount += 1
    }

    switch( turretCount )
    {
        case 1:
            return "One"
        case 2:
            return "Two"
        case 3:
            return "Three"
        case 4:
            return "Four"
        case 5:
            return "Five"
        case 6:
            return "Six"
    }

    return ""
}

/////////////////////////////////////
///// BatteryPort Functions End /////
/////////////////////////////////////
