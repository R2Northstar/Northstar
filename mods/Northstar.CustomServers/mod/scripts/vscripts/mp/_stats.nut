untyped // because entity.s

global function Stats_Init
global function AddStatCallback
global function Stats_SaveStatDelayed
global function PlayerStat_GetCurrentInt
global function PlayerStat_GetCurrentFloat
global function UpdatePlayerStat
global function IncrementPlayerDidPilotExecutionWhileCloaked
global function UpdateTitanDamageStat
global function UpdateTitanWeaponDamageStat
global function UpdateTitanCoreEarnedStat
global function PreScoreEventUpdateStats
global function PostScoreEventUpdateStats
global function Stats_OnPlayerDidDamage

struct {
	table< string, array<string> > refs
	table< string, array< void functionref( entity, float, string ) > > callbacks

	table< entity, table< string, int > > cachedIntStatChanges
	table< table< string, float > > cachedFloatStatChanges

	table< entity, float > playerKills
	table< entity, float > playerKillsPvp
	table< entity, float > playerDeaths
	table< entity, float > playerDeathsPvp

	bool isFirstStrike = true
} file

void function Stats_Init()
{
	AddCallback_OnPlayerKilled( OnPlayerOrNPCKilled )
	AddCallback_OnNPCKilled( OnPlayerOrNPCKilled )
	AddCallback_OnPlayerRespawned( OnPlayerRespawned )
	AddCallback_OnClientConnected( OnClientConnected )
	AddCallback_OnClientDisconnected( OnClientDisconnected )
	AddCallback_GameStateEnter( eGameState.WinnerDetermined, OnWinnerDetermined )

	thread HandleDistanceAndTimeStats_Threaded()
	thread SaveStatsPeriodically_Threaded()
}

void function AddStatCallback( string statCategory, string statAlias, string statSubAlias, void functionref( entity, float, string ) callback, string subRef )
{
	if ( !IsValidStat( statCategory, statAlias, statSubAlias ) )
		throw format( "INVALID STAT: %s : %s : %s", statCategory, statAlias, statSubAlias )


	string statVar = GetStatVar( statCategory, statAlias, statSubAlias )

	if ( statVar in file.refs )
	{
		file.refs[ statVar ].append( subRef )
		file.callbacks[ statVar ].append( callback )
	}
	else
	{
		file.refs[ statVar ] <- [ subRef ]
		file.callbacks[ statVar ] <- [ callback ]
	}
}

// a lot of this file seems to be doing caching of stats in some way
void function Stats_SaveStatDelayed( entity player, string statCategory, string statAlias, string statSubAlias, float delay = 0.1 )
{
	// idk how long the delay is meant to be but whatever
	wait delay

	if ( !IsValid( player ) )
		return

	Stats_SaveStat( player, statCategory, statAlias, statSubAlias )
}

void function Stats_SaveAllStats( entity player )
{
	if ( player in file.cachedIntStatChanges )
	{
		foreach( string key, int val in file.cachedIntStatChanges[ player ] )
		{
			player.SetPersistentVar( key, player.GetPersistentVarAsInt( key ) + val )
		}

		delete file.cachedIntStatChanges[ player ]
	}
	// save cached float stat change
	if ( player in file.cachedFloatStatChanges )
	{
		foreach( string key, float val in file.cachedFloatStatChanges[ player ] )
		{
			player.SetPersistentVar( key, expect float( player.GetPersistentVar( key ) ) + val )
		}

		delete file.cachedFloatStatChanges[ player ]
	}
}

void function Stats_SaveStat( entity player, string statCategory, string statAlias, string statSubAlias )
{
	string stat = GetStatVar( statCategory, statAlias, statSubAlias )
	// save cached int stat change
	if ( player in file.cachedIntStatChanges && stat in file.cachedIntStatChanges[ player ] )
	{
		player.SetPersistentVar( stat, player.GetPersistentVarAsInt( stat ) + file.cachedIntStatChanges[ player ][ stat ] )
		delete file.cachedIntStatChanges[ player ][ stat ]
		return
	}
	// save cached float stat change
	if ( player in file.cachedFloatStatChanges && stat in file.cachedFloatStatChanges[ player ] )
	{
		player.SetPersistentVar( stat, expect float( player.GetPersistentVar( stat ) ) + file.cachedFloatStatChanges[ player ][ stat ] )
		delete file.cachedFloatStatChanges[ player ][ stat ]
		return
	}
}

// this gets the cached change, not the actual value
int function PlayerStat_GetCurrentInt( entity player, string statCategory, string statAlias, string statSubAlias )
{
	string str = GetStatVar( statCategory, statAlias, statSubAlias )

	if ( player in file.cachedIntStatChanges && str in file.cachedIntStatChanges[ player ] )
		return file.cachedIntStatChanges[ player ][ str ]
	return 0
}

// this gets the cached change, not the actual value
float function PlayerStat_GetCurrentFloat( entity player, string statCategory, string statAlias, string statSubAlias )
{
	string str = GetStatVar( statCategory, statAlias, statSubAlias )

	if ( player in file.cachedFloatStatChanges && str in file.cachedFloatStatChanges[ player ] )
		return file.cachedFloatStatChanges[ player ][ str ]
	return 0
}

void function UpdatePlayerStat( entity player, string statCategory, string subStat, int count = 1 )
{
	if ( !IsValid( player ) )
		return

	Stats_IncrementStat( player, statCategory, subStat, "", count.tofloat() )
}

void function IncrementPlayerDidPilotExecutionWhileCloaked( entity player )
{
	UpdatePlayerStat( player, "kills_stats", "pilotExecutePilotWhileCloaked" )
}

void function UpdateTitanDamageStat( entity attacker, float savedDamage, var damageInfo )
{
	if ( !IsValid( attacker ) )
		return

	Stats_IncrementStat( attacker, "titan_stats", "titanDamage", GetTitanCharacterName( attacker ), savedDamage )
}

void function UpdateTitanWeaponDamageStat( entity attacker, float savedDamage, var damageInfo )
{
	if ( !IsValid( attacker ) )
		return

	string weaponName = GetPersistenceRefFromDamageInfo( damageInfo )
	if ( weaponName == "" )
		return

	Stats_IncrementStat( attacker, "weapon_stats", "titanDamage", weaponName, savedDamage )
}

void function UpdateTitanCoreEarnedStat( entity player, entity titan, int count = 1 )
{
	if ( !IsValid( player ) )
		return

	if ( !IsValid( titan ) )
		return

	Stats_IncrementStat( player, "titan_stats", "coresEarned", GetTitanCharacterName( titan ), count.tofloat() )
}

void function PreScoreEventUpdateStats( entity attacker, entity ent )
{
	// used to track kill streaks ending i think ( that stuff gets reset during score event update )
}

void function PostScoreEventUpdateStats( entity attacker, entity ent )
{
	if ( !attacker.IsPlayer() )
		return
	// used to track kill streaks starting maybe
	if ( attacker.s.currentKillstreak == KILLINGSPREE_KILL_REQUIREMENT )
	{
		// killingSpressAs_<chassis>
		if ( attacker.IsTitan() )
			Stats_IncrementStat( attacker, "kills_stats", "killingSpressAs_" + GetTitanCharacterName( attacker ), "", 1.0 )

		entity weapon = attacker.GetActiveWeapon()
		// I guess if you dont have a valid active weapon when you get awarded a killing spree
		// you dont get the stat. Too bad!
		if ( !IsValid( weapon ) )
			return
		Stats_IncrementStat( attacker, "weapon_kill_stats", "killingSprees", weapon.GetWeaponClassName(), 1.0 )
	}
}

void function Stats_OnPlayerDidDamage( entity victim, var damageInfo )
{
	// try and get the player
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	// get the player from their titan
	if ( attacker.IsTitan() && IsPetTitan( attacker ) )
		attacker = attacker.GetTitanSoul().GetBossPlayer()

	if ( !attacker.IsPlayer() )
		return

	string weaponName = GetPersistenceRefFromDamageInfo( damageInfo )
	if ( weaponName == "" )
		return

	Stats_IncrementStat( attacker, "weapon_stats", "shotsHit", weaponName, 1.0 )

	if ( DamageInfo_GetCustomDamageType( damageInfo ) & DF_CRITICAL )
		Stats_IncrementStat( attacker, "weapon_stats", "critHits", weaponName, 1.0 )
	if ( DamageInfo_GetCustomDamageType( damageInfo ) & DF_HEADSHOT )
		Stats_IncrementStat( attacker, "weapon_stats", "headshots", weaponName, 1.0 )
}

void function Stats_IncrementStat( entity player, string statCategory, string statAlias, string statSubAlias, float amount )
{
	if ( !IsValidStat( statCategory, statAlias, statSubAlias ) )
	{
		printt( "invalid stat: " + statCategory + " : " + statAlias + " : " + statSubAlias )
		return
	}

	string str = GetStatVar( statCategory, statAlias, statSubAlias )
	int type = GetStatVarType( statCategory, statAlias, statSubAlias )

	// stupid exception because respawn set this up as an int in script
	// but it is actually a float, so the game will crash if we don't fix it somewhere
	// i dont feel like committing all of sh_stats.gnut so im doing this instead
	if ( str == "mapStats[%mapname%].hoursPlayed[%gamemode%]" )
		type = ePlayerStatType.FLOAT

	// this is rather hacky
	string mode = GAMETYPE
	int difficulty = GetDifficultyLevel()
	if ( difficulty >= 5 )
		return

	string saveVar = Stats_GetFixedSaveVar( str, GetMapName(), mode, difficulty.tostring() )
	// check if the map and mode exist in persistence
	try
	{
		PersistenceGetEnumIndexForItemName( "gamemodes", mode )
		PersistenceGetEnumIndexForItemName( "maps", GetMapName() )
	}
	catch( ex )
	{
		// if we have an invalid mode or map for persistence, and it is used in the
		// persistence string, we can't save the persistence so we have to just return
		if ( str != saveVar )
		{
			printt( ex )
			return
		}
	}
	str = saveVar

	switch ( type )
	{
	case ePlayerStatType.INT:
		// populate table if needed
		if ( !( player in file.cachedIntStatChanges ) )
			file.cachedIntStatChanges[ player ] <- {}
		if ( !( str in file.cachedIntStatChanges[ player ] ) )
			file.cachedIntStatChanges[ player ][ str ] <- 0

		file.cachedIntStatChanges[ player ][ str ] += amount.tointeger()
		break
	case ePlayerStatType.FLOAT:
		// populate table if needed
		if ( !( player in file.cachedFloatStatChanges ) )
			file.cachedFloatStatChanges[ player ] <- {}
		if ( !( str in file.cachedFloatStatChanges[ player ] ) )
			file.cachedFloatStatChanges[ player ][ str ] <- 0.0

		file.cachedFloatStatChanges[ player ][ str ] += amount
		break
	default:
		throw "UNIMPLEMENTED STAT TYPE: " + type
	}

	// amount here is never used
	Stats_RunCallbacks( str, player, amount )
}

void function Stats_RunCallbacks( string statVar, entity player, float change )
{
	if ( !( statVar in file.refs ) )
		return

	for( int i = 0; i < file.refs[ statVar ].len(); i++ )
	{
		string ref = file.refs[ statVar ][ i ]
		void functionref( entity, float, string ) callback = file.callbacks[ statVar ][ i ]

		callback( player, change, ref )
	}
}

void function OnClientConnected( entity player )
{
	Stats_IncrementStat( player, "game_stats", "game_joined", "", 1.0 )
}

void function OnClientDisconnected( entity player )
{
	Stats_SaveAllStats( player )
	// maybe we can save this stuff, but idk if we can access persistence in this callback
	if ( player in file.cachedIntStatChanges )
		delete file.cachedIntStatChanges[ player ]

	if ( player in file.cachedFloatStatChanges )
		delete file.cachedFloatStatChanges[ player ]
}

void function OnPlayerOrNPCKilled( entity victim, entity attacker, var damageInfo )
{
	if ( victim.IsPlayer() )
		thread SetLastPosForDistanceStatValid_Threaded( victim, false )

	HandleDeathStats( victim, attacker, damageInfo )
	HandleKillStats( victim, attacker, damageInfo )
	HandleWeaponKillStats( victim, attacker, damageInfo )
	HandleTitanStats( victim, attacker, damageInfo )
}

void function HandleDeathStats( entity player, entity attacker, var damageInfo )
{
	if ( !IsValid( player ) || !player.IsPlayer() )
		return

	if ( player in file.playerDeaths )
		file.playerDeaths[ player ]++
	else
		file.playerDeaths[ player ] <- 1.0
	// total
	Stats_IncrementStat( player, "deaths_stats", "total", "", 1.0 )

	// these all rely on the attacker being valid
	if ( IsValid( attacker ) )
	{
		// totalPVP
		// note: I'm not sure if owned entities count towards totalPVP
		// such as auto-titans, turrets, etc.
		if ( attacker.IsPlayer() || attacker.GetBossPlayer() )
		{
			if ( player in file.playerDeathsPvp )
				file.playerDeathsPvp[ player ]++
			else
				file.playerDeathsPvp[ player ] <- 1.0
			Stats_IncrementStat( player, "deaths_stats", "totalPVP", "", 1.0 )
		}

		// byPilots
		if ( IsPilot( attacker ) )
			Stats_IncrementStat( player, "deaths_stats", "byPilots", "", 1.0 )

		// byTitan_<chassis>
		if ( attacker.IsTitan() && attacker.IsPlayer() )
			Stats_IncrementStat( player, "deaths_stats", "byTitan_" + GetTitanCharacterName( attacker ), "", 1.0 )

		// bySpectres
		if ( IsSpectre( attacker ) )
			Stats_IncrementStat( player, "deaths_stats", "bySpectres", "", 1.0 )

		// byGrunts
		if ( IsGrunt( attacker ) )
			Stats_IncrementStat( player, "deaths_stats", "byGrunts", "", 1.0 )

		// byNPCTitans_<chassis>
		if ( attacker.IsTitan() && attacker.IsNPC() )
			Stats_IncrementStat( player, "deaths_stats", "byNPCTitans_" + GetTitanCharacterName( attacker ), "", 1.0 )
	}

	// asPilot
	if ( IsPilot( player ) )
		Stats_IncrementStat( player, "deaths_stats", "asPilot", "", 1.0 )

	// asTitan_<chassis>
	if ( player.IsTitan() )
		Stats_IncrementStat( player, "deaths_stats", "asTitan_" + GetTitanCharacterName( player ), "", 1.0 )

	// suicides
	if ( IsSuicide( attacker, player, DamageInfo_GetDamageSourceIdentifier( damageInfo ) ) )
		Stats_IncrementStat( player, "deaths_stats", "suicides", "", 1.0 )

	// whileEjecting
	if ( player.p.pilotEjecting )
		Stats_IncrementStat( player, "deaths_stats", "whileEjecting", "", 1.0 )
}

void function HandleWeaponKillStats( entity victim, entity attacker, var damageInfo )
{
	if ( !IsValid( attacker ) )
		return

	// get the player and it's pet titan
	entity player
	entity playerPetTitan
	if ( attacker.IsPlayer() )
	{
		// the player is just the attacker
		player = attacker
		playerPetTitan = player.GetPetTitan()
	}
	else if ( attacker.IsTitan() && IsPetTitan( attacker ) )
	{
		// the attacker is the player's auto titan
		player = attacker.GetTitanSoul().GetBossPlayer()
		playerPetTitan = attacker
	}
	else
	{
		// attacker could be something like an NPC, or worldspawn
		return
	}

	string damageSourceStr = GetPersistenceRefFromDamageInfo( damageInfo )
	// cant do weapon stats for no weapon
	if ( damageSourceStr == "" )
		return

	// check things once, for performance
	int damageSource = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	bool victimIsPlayer = victim.IsPlayer()
	bool victimIsNPC = victim.IsNPC()
	bool victimIsPilot = IsPilot( victim )
	bool victimIsTitan = victim.IsTitan()

	// total
	Stats_IncrementStat( player, "weapon_kill_stats", "total", damageSourceStr, 1.0 )

	// pilots
	if ( victimIsPilot )
		Stats_IncrementStat( player, "weapon_kill_stats", "pilots", damageSourceStr, 1.0 )

	// ejecting_pilots
	if ( victimIsPilot && victim.p.pilotEjecting )
		Stats_IncrementStat( player, "weapon_kill_stats", "ejecting_pilots", damageSourceStr, 1.0 )

	// titansTotal
	if ( victimIsTitan )
		Stats_IncrementStat( player, "weapon_kill_stats", "titansTotal", damageSourceStr, 1.0 )

	// spectres
	if ( IsSpectre( victim ) )
		Stats_IncrementStat( player, "weapon_kill_stats", "spectres", damageSourceStr, 1.0 )

	// marvins
	if ( IsMarvin( victim ) )
		Stats_IncrementStat( player, "weapon_kill_stats", "marvins", damageSourceStr, 1.0 )

	// grunts
	if ( IsGrunt( victim ) )
		Stats_IncrementStat( player, "weapon_kill_stats", "grunts", damageSourceStr, 1.0 )

	// ai
	if ( victimIsNPC )
		Stats_IncrementStat( player, "weapon_kill_stats", "ai", damageSourceStr, 1.0 )

	// titans_<chassis>
	if ( victimIsPlayer && victimIsTitan )
		Stats_IncrementStat( player, "weapon_kill_stats", "titans_" + GetTitanCharacterName( victim ), damageSourceStr, 1.0 )

	// npcTitans_<chassis>
	if ( victimIsNPC && victimIsTitan )
		Stats_IncrementStat( player, "weapon_kill_stats", "npcTitans_" + GetTitanCharacterName( victim ), damageSourceStr, 1.0 )
}

void function HandleKillStats( entity victim, entity attacker, var damageInfo )
{
	if ( !IsValid( attacker ) )
		return
	// get the player and it's pet titan
	entity player
	entity playerPetTitan
	if ( attacker.IsPlayer() )
	{
		// the player is just the attacker
		player = attacker
		playerPetTitan = player.GetPetTitan()
	}
	else if ( attacker.IsTitan() && IsPetTitan( attacker ) )
	{
		// the attacker is the player's auto titan
		player = attacker.GetTitanSoul().GetBossPlayer()
		playerPetTitan = attacker
	}
	else
	{
		// attacker could be something like an NPC, or worldspawn
		return
	}

	// check things once, for performance
	int damageSource = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	bool victimIsPlayer = victim.IsPlayer()
	bool victimIsNPC = victim.IsNPC()
	bool victimIsPilot = IsPilot( victim )
	bool victimIsTitan = victim.IsTitan()

	if ( player in file.playerKills )
		file.playerKills[ player ]++
	else
		file.playerKills[ player ] <- 1.0
	// total
	Stats_IncrementStat( player, "kills_stats", "total", "", 1.0 )

	// totalPVP
	if ( victimIsPlayer )
	{
		if ( player in file.playerKillsPvp )
			file.playerKillsPvp[ player ]++
		else
			file.playerKillsPvp[ player ] <- 1.0
		Stats_IncrementStat( player, "kills_stats", "totalPVP", "", 1.0 )
	}

	// pilots
	if ( victimIsPilot )
		Stats_IncrementStat( player, "kills_stats", "pilots", "", 1.0 )

	// spectres
	if ( IsSpectre( victim ) )
		Stats_IncrementStat( player, "kills_stats", "spectres", "", 1.0 )

	// marvins
	if ( IsMarvin( victim ) )
		Stats_IncrementStat( player, "kills_stats", "marvins", "", 1.0 )

	// grunts
	if ( IsGrunt( victim ) )
		Stats_IncrementStat( player, "kills_stats", "grunts", "", 1.0 )

	// totalTitans
	if ( victimIsTitan )
		Stats_IncrementStat( player, "kills_stats", "totalTitans", "", 1.0 )

	// totalPilots
	if ( victimIsPilot )
		Stats_IncrementStat( player, "kills_stats", "totalPilots", "", 1.0 )

	// totalNPC
	if ( victimIsNPC )
		Stats_IncrementStat( player, "kills_stats", "totalNPC", "", 1.0 )

	// totalTitansWhileDoomed
	if ( victimIsTitan && attacker.IsTitan() && GetDoomedState( attacker ) )
		Stats_IncrementStat( player, "kills_stats", "totalTitansWhileDoomed", "", 1.0 )

	// asPilot
	if ( IsPilot( attacker ) )
		Stats_IncrementStat( player, "kills_stats", "asPilot", "", 1.0 )

	// totalAssists
	// assistsTotal ( weapon_kill_stats )
	// note: eww
	table<int, bool> alreadyAssisted
	foreach( DamageHistoryStruct attackerInfo in victim.e.recentDamageHistory )
	{
		if ( !IsValid( attackerInfo.attacker ) || !attackerInfo.attacker.IsPlayer() || attackerInfo.attacker == victim )
			continue

		bool exists = attackerInfo.attacker.GetEncodedEHandle() in alreadyAssisted ? true : false
		if( attackerInfo.attacker != attacker && !exists )
		{
			alreadyAssisted[ attackerInfo.attacker.GetEncodedEHandle() ] <- true
			Stats_IncrementStat( attackerInfo.attacker, "kills_stats", "totalAssists", "", 1.0 )

			string source = DamageSourceIDToString( attackerInfo.damageSourceId )

			if ( IsValidStatItemString( source ) )
				Stats_IncrementStat( attacker, "weapon_kill_stats", "assistsTotal", source, 1.0 )
		}
	}

	// asTitan_<chassis>
	if ( player.IsTitan() )
		Stats_IncrementStat( player, "kills_stats", "asTitan_" + GetTitanCharacterName( player ), "", 1.0 )

	// firstStrikes
	if ( file.isFirstStrike && attacker.IsPlayer() && victimIsPlayer )
	{
		Stats_IncrementStat( player, "kills_stats", "firstStrikes", "", 1.0 )
		file.isFirstStrike = false
	}

	// ejectingPilots
	if ( victimIsPilot && victim.p.pilotEjecting )
		Stats_IncrementStat( player, "kills_stats", "ejectingPilots", "", 1.0 )

	// whileEjecting
	if ( attacker.IsPlayer() && attacker.p.pilotEjecting )
		Stats_IncrementStat( player, "kills_stats", "whileEjecting", "", 1.0 )

	// cloakedPilots
	if ( victimIsPilot && IsCloaked( victim ) )
		Stats_IncrementStat( player, "kills_stats", "cloakedPilots", "", 1.0 )

	// whileCloaked
	if ( attacker == player && IsCloaked( attacker ) )
		Stats_IncrementStat( player, "kills_stats", "whileCloaked", "", 1.0 )

	// wallrunningPilots
	if ( victimIsPilot && victim.IsWallRunning() )
		Stats_IncrementStat( player, "kills_stats", "wallrunningPilots", "", 1.0 )

	// whileWallrunning
	if ( attacker == player && attacker.IsWallRunning() )
		Stats_IncrementStat( player, "kills_stats", "whileWallrunning", "", 1.0 )

	// wallhangingPilots
	if ( victimIsPilot && victim.IsWallHanging() )
		Stats_IncrementStat( player, "kills_stats", "wallhangingPilots", "", 1.0 )

	// whileWallhanging
	if ( attacker == player && attacker.IsWallHanging() )
		Stats_IncrementStat( player, "kills_stats", "whileWallhanging", "", 1.0 )

	// pilotExecution
	if ( damageSource == eDamageSourceId.human_execution )
		Stats_IncrementStat( player, "kills_stats", "pilotExecution", "", 1.0 )

	// pilotExecutePilot
	if ( victimIsPilot && damageSource == eDamageSourceId.human_execution )
		Stats_IncrementStat( player, "kills_stats", "pilotExecutePilot", "", 1.0 )

	// pilotKillsWithHoloPilotActive
	if ( victimIsPilot && GetDecoyActiveCountForPlayer( player ) > 0 )
		Stats_IncrementStat( player, "kills_stats", "pilotKillsWithHoloPilotActive", "", 1.0 )

	// pilotKillsWithAmpedWallActive
	if ( victimIsPilot && GetAmpedWallsActiveCountForPlayer( player ) > 0 )
		Stats_IncrementStat( player, "kills_stats", "pilotKillsWithAmpedWallActive", "", 1.0 )

	// pilotExecutePilotUsing_<execution>
	if ( victimIsPilot && damageSource == eDamageSourceId.human_execution )
		Stats_IncrementStat( player, "kills_stats", "pilotExecutePilotUsing_" + player.p.lastExecutionUsed, "", 1.0 )

	// pilotKickMelee
	if ( damageSource == eDamageSourceId.human_melee )
		Stats_IncrementStat( player, "kills_stats", "pilotKickMelee", "", 1.0 )

	// pilotKickMeleePilot
	if ( victimIsPilot && damageSource == eDamageSourceId.human_melee )
		Stats_IncrementStat( player, "kills_stats", "pilotKickMeleePilot", "", 1.0 )

	// titanMelee
	if ( DamageIsTitanMelee( damageSource ) )
		Stats_IncrementStat( player, "kills_stats", "titanMelee", "", 1.0 )

	// titanMeleePilot
	if ( victimIsPilot && DamageIsTitanMelee( damageSource ) )
		Stats_IncrementStat( player, "kills_stats", "titanMeleePilot", "", 1.0 )

	// titanStepCrush
	if ( IsTitanCrushDamage( damageInfo ) )
		Stats_IncrementStat( player, "kills_stats", "titanStepCrush", "", 1.0 )

	// titanStepCrushPilot
	if ( victimIsPilot && IsTitanCrushDamage( damageInfo ) )
		Stats_IncrementStat( player, "kills_stats", "titanStepCrushPilot", "", 1.0 )

	// titanExocution<capitalisedChassis>
	// note: RESPAWN WHY? EXPLAIN
	if ( damageSource == eDamageSourceId.titan_execution )
	{
		string titanName = GetTitanCharacterName( player )
		titanName = titanName.slice( 0, 1 ).toupper() + titanName.slice( 1, titanName.len() )
		Stats_IncrementStat( player, "kills_stats", "titanExocution" + titanName, "", 1.0 )
	}

	// titanFallKill
	if ( damageSource == eDamageSourceId.damagedef_titan_fall )
		Stats_IncrementStat( player, "kills_stats", "titanFallKill", "", 1.0 )

	// petTitanKillsFollowMode
	if ( attacker == playerPetTitan && player.GetPetTitanMode() == eNPCTitanMode.FOLLOW )
		Stats_IncrementStat( player, "kills_stats", "petTitanKillsFollowMode", "", 1.0 )

	// petTitanKillsGuardMode
	if ( attacker == playerPetTitan && player.GetPetTitanMode() == eNPCTitanMode.STAY )
		Stats_IncrementStat( player, "kills_stats", "petTitanKillsGuardMode", "", 1.0 )

	// rodeo_total
	if ( damageSource == eDamageSourceId.rodeo_battery_removal )
		Stats_IncrementStat( player, "kills_stats", "rodeo_total", "", 1.0 )

	// pilot_headshots_total
	if ( victimIsPilot && DamageInfo_GetCustomDamageType( damageInfo ) & DF_HEADSHOT )
		Stats_IncrementStat( player, "kills_stats", "pilot_headshots_total", "", 1.0 )

	// evacShips
	if ( IsEvacDropship( victim ) )
		Stats_IncrementStat( player, "kills_stats", "evacShips", "", 1.0 )

	// nuclearCore
	if ( damageSource == eDamageSourceId.damagedef_nuclear_core )
		Stats_IncrementStat( player, "kills_stats", "nuclearCore", "", 1.0 )

	// meleeWhileCloaked
	if ( IsCloaked( attacker ) && damageSource == eDamageSourceId.human_melee )
		Stats_IncrementStat( player, "kills_stats", "meleeWhileCloaked", "", 1.0 )

	// titanKillsAsPilot
	if ( victimIsTitan && IsPilot( attacker ) )
		Stats_IncrementStat( player, "kills_stats", "titanKillsAsPilot", "", 1.0 )

	// pilotKillsWhileStimActive
	if ( victimIsPilot && StatusEffect_Get( attacker, eStatusEffect.stim_visual_effect ) <= 0 )
		Stats_IncrementStat( player, "kills_stats", "pilotKillsWhileStimActive", "", 1.0 )

	// pilotKillsAsTitan
	if ( victimIsPilot && attacker.IsTitan() )
		Stats_IncrementStat( player, "kills_stats", "pilotKillsAsTitan", "", 1.0 )

	// pilotKillsAsPilot
	if ( victimIsPilot && IsPilot( attacker ) )
		Stats_IncrementStat( player, "kills_stats", "pilotKillsAsPilot", "", 1.0 )

	// titanKillsAsTitan
	if ( victimIsTitan && attacker.IsTitan() )
		Stats_IncrementStat( player, "kills_stats", "titanKillsAsTitan", "", 1.0 )

}

void function HandleTitanStats( entity victim, entity attacker, var damageInfo )
{
	if ( !IsValid( attacker ) )
		return

	// get the player and it's pet titan
	entity player
	entity playerPetTitan
	if ( attacker.IsPlayer() )
	{
		// the player is just the attacker
		player = attacker
		playerPetTitan = player.GetPetTitan()
	}
	else if ( attacker.IsTitan() && IsPetTitan( attacker ) )
	{
		// the attacker is the player's auto titan
		player = attacker.GetTitanSoul().GetBossPlayer()
		playerPetTitan = attacker
	}
	else
	{
		// attacker could be something like an NPC, or worldspawn
		return
	}

	int damageSource = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	bool victimIsPlayer = victim.IsPlayer()
	bool victimIsNPC = victim.IsNPC()
	bool victimIsPilot = IsPilot( victim )
	bool victimIsTitan = victim.IsTitan()
	bool titanIsPrime = IsTitanPrimeTitan( player )

	// pilots
	if ( victimIsPilot && attacker.IsTitan() )
		Stats_IncrementStat( player, "titan_stats", "pilots", GetTitanCharacterName( attacker ), 1.0 )

	// titansTotal
	if ( victimIsTitan && attacker.IsTitan() )
		Stats_IncrementStat( player, "titan_stats", "titansTotal", GetTitanCharacterName( attacker ), 1.0 )

	// pilotsAsPrime
	if ( victimIsPilot && attacker.IsTitan() && titanIsPrime )
		Stats_IncrementStat( player, "titan_stats", "pilotsAsPrime", GetTitanCharacterName( attacker ), 1.0 )

	// titansAsPrime
	if ( victimIsTitan && attacker.IsTitan() && titanIsPrime )
		Stats_IncrementStat( player, "titan_stats", "titansAsPrime", GetTitanCharacterName( attacker ), 1.0 )

	// executionsAsPrime
	if ( damageSource == eDamageSourceId.titan_execution && attacker.IsTitan() && titanIsPrime )
		Stats_IncrementStat( player, "titan_stats", "executionsAsPrime", GetTitanCharacterName( attacker ), 1.0 )
}

void function OnPlayerRespawned( entity player )
{
	thread SetLastPosForDistanceStatValid_Threaded( player, true )
}

void function OnWinnerDetermined()
{
	// award players for match completed, wins, and losses
	foreach ( entity player in GetPlayerArray() )
	{
		Stats_IncrementStat( player, "game_stats", "game_completed", "", 1.0 )

		if ( player.GetTeam() == GetWinningTeam() )
			Stats_IncrementStat( player, "game_stats", "game_won", "", 1.0 )
		else
			Stats_IncrementStat( player, "game_stats", "game_lost", "", 1.0 )
	}

	if ( IsValidGamemodeString( GAMETYPE ) )
	{
		// award players with matches played on the mode
		foreach ( entity player in GetPlayerArray() )
		{
			Stats_IncrementStat( player, "game_stats", "mode_played", GAMETYPE, 1.0 )

			if ( player.GetTeam() == GetWinningTeam() )
				Stats_IncrementStat( player, "game_stats", "mode_won", GAMETYPE, 1.0 )
		}
	}

	// update player's KD
	foreach ( entity player in GetPlayerArray() )
	{
		// kd stats
		// index 0 is most recent game
		// index 9 is least recent game
		float playerKills = ( player in file.playerKills ) ? file.playerKills[ player ] : 0.0
		float playerDeaths = ( player in file.playerDeaths ) ? file.playerDeaths[ player ] : 0.0
		float kdratio_match
		if ( playerDeaths == 0.0 )
			kdratio_match = playerKills
		else
			kdratio_match = playerKills / playerDeaths

		float playerKillsPvp = ( player in file.playerKillsPvp ) ? file.playerKillsPvp[ player ] : 0.0
		float playerDeathsPvp = ( player in file.playerDeathsPvp ) ? file.playerDeathsPvp[ player ] : 0.0
		float kdratiopvp_match
		if ( playerDeathsPvp == 0.0 )
			kdratiopvp_match = playerKillsPvp
		else
			kdratiopvp_match = playerKillsPvp / playerDeathsPvp

		float totalDeaths = player.GetPersistentVarAsInt( "deathStats.total" ).tofloat()
		float totalKills = player.GetPersistentVarAsInt( "killStats.total" ).tofloat()
		float totalDeathsPvp = player.GetPersistentVarAsInt( "deathStats.totalPVP" ).tofloat()
		float totalKillsPvp = player.GetPersistentVarAsInt( "killStats.totalPVP" ).tofloat()
		float kdratio_lifetime
		if ( totalDeaths == 0.0 )
			kdratio_lifetime = totalKills
		else
			kdratio_lifetime = totalKills / totalDeaths
		float kdratio_lifetimepvp
		if ( totalDeathsPvp == 0.0 )
			kdratio_lifetimepvp = totalKillsPvp
		else
			kdratio_lifetimepvp = totalKillsPvp / totalDeathsPvp

		// shift stats by 1 to make room for new game data
		for ( int i = NUM_GAMES_TRACK_KDRATIO - 2; i >= 0; --i )
		{
			player.SetPersistentVar( format( "kdratio_match[%i]", ( i + 1 ) ), player.GetPersistentVar( format("kdratio_match[%i]", i ) ) )
			player.SetPersistentVar( format( "kdratiopvp_match[%i]", ( i + 1 ) ), player.GetPersistentVar( format( "kdratiopvp_match[%i]", i ) ) )
		}
		// add new game data
		player.SetPersistentVar( "kdratio_match[0]", kdratio_match )
		player.SetPersistentVar( "kdratiopvp_match[0]", kdratiopvp_match )
		player.SetPersistentVar( "kdratio_lifetime", kdratio_lifetime )
		player.SetPersistentVar( "kdratio_lifetime_pvp", kdratio_lifetimepvp )
	}

	// award mvp and top 3 in each team
	if ( !IsFFAGame() )
	{
		string gamemode = GameRules_GetGameMode()
		int functionref( entity, entity ) compareFunc = GameMode_GetScoreCompareFunc( gamemode )

		for( int team = 0; team < MAX_TEAMS; team++ )
		{
			array<entity> players = GetPlayerArrayOfTeam( team )
			if ( compareFunc == null )
			{
				printt( "gamemode doesn't have a compare func to get the top 3" )
				return
			}
			players.sort( compareFunc )
			int maxAwards = int( min( players.len(), 3 ) )
			for ( int i = 0; i < maxAwards; i++ )
			{
				if ( i == 0 )
					Stats_IncrementStat( players[ i ], "game_stats", "mvp", "", 1.0 )
				Stats_IncrementStat( players[ i ], "game_stats", "top3OnTeam", "", 1.0 )
			}
		}

	}
}

void function SetLastPosForDistanceStatValid_Threaded( entity player, bool val )
{
	WaitFrame()
	if ( !IsValid( player ) )
		return
	player.p.lastPosForDistanceStatValid = val
}

// Respawn did this through stuff found in _entitystructs.gnut (stuff like stats_wallrunTime)
// but their implementation seems kinda bad. The advantage it has over this method is not polling
// every 0.25 seconds, and using movement callbacks and stuff instead. However, since i can't find
// callbacks for things like changing weapon, i would have to poll for that *anyway* and thus,
// there is no point in doing things Respawn's way here
void function HandleDistanceAndTimeStats_Threaded()
{
	// just to be safe
	if ( IsLobby() )
		return

	while ( GetGameState() < eGameState.Playing )
		WaitFrame()

	float lastTickTime = Time()

	while( true )
	{
		// track distance stats
		foreach ( entity player in GetPlayerArray() )
		{
			if ( player.p.lastPosForDistanceStatValid )
			{
				// not 100% sure on using Distance2D over Distance tbh
				float distInches = Distance2D( player.p.lastPosForDistanceStat, player.GetOrigin() )
				float distMiles = distInches / 63360.0

				// more generic distance stats
				Stats_IncrementStat( player, "distance_stats", "total", "", distMiles )
				if ( player.IsTitan() )
				{
					Stats_IncrementStat( player, "distance_stats", "asTitan_" + GetTitanCharacterName( player ), "", distMiles )
					Stats_IncrementStat( player, "distance_stats", "asTitan", "", distMiles )
				}
				else
					Stats_IncrementStat( player, "distance_stats", "asPilot", "", distMiles )


				string state = ""
				// specific distance stats
				if ( player.IsWallRunning() )
					state = "wallrunning"
				else if ( PlayerIsRodeoingTitan( player ) )
				{
					if ( player.GetTitanSoulBeingRodeoed().GetTeam() == player.GetTeam() )
						state = "onFriendlyTitan"
					else
						state = "onEnemyTitan"
				}
				else if ( player.IsZiplining() )
					state = "ziplining"
				else if ( !player.IsOnGround() )
					state = "inAir"

				if ( state != "" )
					Stats_IncrementStat( player, "distance_stats", state, "", distMiles )
			}

			player.p.lastPosForDistanceStat = player.GetOrigin()
		}

		float timeSeconds = Time() - lastTickTime
		float timeHours = timeSeconds / 3600.0

		// track time stats
		foreach ( entity player in GetPlayerArray() )
		{
			// first tick i dont count
			if ( timeSeconds == 0 )
				break

			// more generic time stats
			Stats_IncrementStat( player, "time_stats", "hours_total", "", timeHours )
			if ( player.IsTitan() )
			{
				Stats_IncrementStat( player, "time_stats", "hours_as_titan_" + GetTitanCharacterName( player ), "", timeHours )
				Stats_IncrementStat( player, "time_stats", "hours_as_titan", "", timeHours )
			}
			else
				Stats_IncrementStat( player, "time_stats", "hours_as_pilot", "", timeHours )

			string state = ""
			// specific time stats
			if ( !IsAlive( player ) )
				state = "hours_dead"
			else if ( player.IsWallHanging() )
				state = "hours_wallhanging"
			else if ( player.IsWallRunning() )
				state = "hours_wallrunning"
			else if ( !player.IsOnGround() )
				state = "hours_inAir"

			if ( state != "" )
				Stats_IncrementStat( player, "time_stats", state, "", timeHours )

			// weapon time stats
			entity activeWeapon = player.GetActiveWeapon()
			if ( IsValid( activeWeapon ) )
			{
				if ( IsValidStatItemString( activeWeapon.GetWeaponClassName() ) )
					Stats_IncrementStat( player, "weapon_stats", "hoursUsed", activeWeapon.GetWeaponClassName(), timeHours )

				foreach( entity weapon in player.GetMainWeapons() )
				{
					if ( IsValidStatItemString( weapon.GetWeaponClassName() ) )
						Stats_IncrementStat( player, "weapon_stats", "hoursEquipped", weapon.GetWeaponClassName(), timeHours )
				}
			}

			// map time stats
			Stats_IncrementStat( player, "game_stats", "hoursPlayed", "", timeHours )
		}

		lastTickTime = Time()
		// not rly worth doing this every frame, just a couple of times per second should be fine
		wait 0.25
	}
}

// this is kinda shit
void function SaveStatsPeriodically_Threaded()
{
	while( true )
	{
		foreach( entity player in GetPlayerArray() )
			Stats_SaveAllStats( player )
		wait 5
	}
}

bool function IsValidGamemodeString( string mode )
{
	int gameModeCount = PersistenceGetEnumCount( "gameModes" )
	for ( int modeIndex = 0; modeIndex < gameModeCount; modeIndex++ )
	{
		string gameModeName = PersistenceGetEnumItemNameForIndex( "gameModes", modeIndex )

		if ( gameModeName == mode )
			return true
	}

	return false
}

bool function IsValidStatItemString( string item )
{
	foreach( str in shGlobalMP.statsItemsList )
	{
		if ( str == item )
			return true
	}

	return false
}

string function GetPersistenceRefFromDamageInfo( var damageInfo )
{
	string damageSourceString = DamageSourceIDToString( DamageInfo_GetDamageSourceIdentifier( damageInfo ) )

	foreach( str in shGlobalMP.statsItemsList )
	{
		if ( str == damageSourceString )
			return damageSourceString
	}

	return ""
}

bool function DamageIsTitanMelee( int damageSourceId )
{
	switch( damageSourceId )
	{
		case eDamageSourceId.melee_titan_punch:
		case eDamageSourceId.melee_titan_punch_ion:
		case eDamageSourceId.melee_titan_punch_legion:
		case eDamageSourceId.melee_titan_punch_tone:
		case eDamageSourceId.melee_titan_punch_scorch:
		case eDamageSourceId.melee_titan_punch_northstar:
		case eDamageSourceId.melee_titan_punch_fighter:
		case eDamageSourceId.melee_titan_sword:
		case eDamageSourceId.melee_titan_sword_aoe:
			return true
		default:
			return false
	}
	unreachable
}
