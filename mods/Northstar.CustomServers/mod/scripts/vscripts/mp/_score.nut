untyped

global function Score_Init

global function AddPlayerScore
global function ScoreEvent_PlayerKilled
global function ScoreEvent_TitanDoomed
global function ScoreEvent_TitanKilled
global function ScoreEvent_NPCKilled

global function ScoreEvent_SetEarnMeterValues
global function ScoreEvent_SetupEarnMeterValuesForMixedModes
global function ScoreEvent_SetupEarnMeterValuesForTitanModes

struct {
	bool firstStrikeDone = false
} file

void function Score_Init()
{
	SvXP_Init()
	AddCallback_OnClientConnected( InitPlayerForScoreEvents )
}

void function InitPlayerForScoreEvents( entity player )
{	
	player.s.currentKillstreak <- 0
	player.s.lastKillTime <- 0.0
	player.s.currentTimedKillstreak <- 0
}

void function AddPlayerScore( entity targetPlayer, string scoreEventName, entity associatedEnt = null, string noideawhatthisis = "", int pointValueOverride = -1 )
{
	ScoreEvent event = GetScoreEvent( scoreEventName )
	
	if ( !event.enabled || !IsValid( targetPlayer ) || !targetPlayer.IsPlayer() )
		return

	var associatedHandle = 0
	if ( associatedEnt != null )
		associatedHandle = associatedEnt.GetEncodedEHandle()
		
	if ( pointValueOverride != -1 )
		event.pointValue = pointValueOverride 
	
	float scale = targetPlayer.IsTitan() ? event.coreMeterScalar : 1.0
	
	float earnValue = event.earnMeterEarnValue * scale
	float ownValue = event.earnMeterOwnValue * scale
	
	PlayerEarnMeter_AddEarnedAndOwned( targetPlayer, earnValue * scale, ownValue * scale )
	
	// PlayerEarnMeter_AddEarnedAndOwned handles this scaling by itself, we just need to do this for the visual stuff
	float pilotScaleVar = ( expect string ( GetCurrentPlaylistVarOrUseValue( "earn_meter_pilot_multiplier", "1" ) ) ).tofloat()
	float titanScaleVar = ( expect string ( GetCurrentPlaylistVarOrUseValue( "earn_meter_titan_multiplier", "1" ) ) ).tofloat()
	
	if ( targetPlayer.IsTitan() )
	{
		earnValue *= titanScaleVar
		ownValue *= titanScaleVar
	}
	else
	{
		earnValue *= pilotScaleVar
		ownValue *= pilotScaleVar
	}
	
	Remote_CallFunction_NonReplay( targetPlayer, "ServerCallback_ScoreEvent", event.eventId, event.pointValue, event.displayType, associatedHandle, ownValue, earnValue )
	
	if ( event.displayType & eEventDisplayType.CALLINGCARD ) // callingcardevents are shown to all players
	{
		foreach ( entity player in GetPlayerArray() )
		{
			if ( player == targetPlayer ) // targetplayer already gets this in the scorevent callback
				continue
				
			Remote_CallFunction_NonReplay( player, "ServerCallback_CallingCardEvent", event.eventId, associatedHandle )
		}
	}
	
	if ( ScoreEvent_HasConversation( event ) )
		PlayFactionDialogueToPlayer( event.conversation, targetPlayer )
		
	HandleXPGainForScoreEvent( targetPlayer, event )
}

void function ScoreEvent_PlayerKilled( entity victim, entity attacker, var damageInfo )
{
	// reset killstreaks and stuff		
	victim.s.currentKillstreak = 0
	victim.s.lastKillTime = 0.0
	victim.s.currentTimedKillstreak = 0
	
	victim.p.numberOfDeathsSinceLastKill++ // this is reset on kill
	
	// have to do this early before we reset victim's player killstreaks
	// nemesis when you kill a player that is dominating you
	if ( attacker.IsPlayer() && attacker in victim.p.playerKillStreaks && victim.p.playerKillStreaks[ attacker ] >= NEMESIS_KILL_REQUIREMENT )
		AddPlayerScore( attacker, "Nemesis" )
	
	// reset killstreaks on specific players
	foreach ( entity killstreakPlayer, int numKills in victim.p.playerKillStreaks )
		delete victim.p.playerKillStreaks[ killstreakPlayer ]

	if ( victim.IsTitan() )
		ScoreEvent_TitanKilled( victim, attacker, damageInfo )

	if ( !attacker.IsPlayer() )
		return

	attacker.p.numberOfDeathsSinceLastKill = 0 // since they got a kill, remove the comeback trigger
	// pilot kill
	AddPlayerScore( attacker, "KillPilot", victim )
	
	// headshot
	if ( DamageInfo_GetCustomDamageType( damageInfo ) & DF_HEADSHOT )
		AddPlayerScore( attacker, "Headshot", victim )
	
	// first strike
	if ( !file.firstStrikeDone )
	{
		file.firstStrikeDone = true
		AddPlayerScore( attacker, "FirstStrike", attacker )
	}
	
	// comeback
	if ( attacker.p.numberOfDeathsSinceLastKill >= COMEBACK_DEATHS_REQUIREMENT )
	{
		AddPlayerScore( attacker, "Comeback" )
		attacker.p.numberOfDeathsSinceLastKill = 0
	}
	
	
	// untimed killstreaks
	attacker.s.currentKillstreak++
	if ( attacker.s.currentKillstreak == 3 )
		AddPlayerScore( attacker, "KillingSpree" )
	else if ( attacker.s.currentKillstreak == 5 )
		AddPlayerScore( attacker, "Rampage" )
	
	// increment untimed killstreaks against specific players
	if ( !( victim in attacker.p.playerKillStreaks ) )
		attacker.p.playerKillStreaks[ victim ] <- 1
	else
		attacker.p.playerKillStreaks[ victim ]++
	
	// dominating
	if ( attacker.p.playerKillStreaks[ victim ] >= DOMINATING_KILL_REQUIREMENT )
		AddPlayerScore( attacker, "Dominating" )
	
	if ( Time() - attacker.s.lastKillTime > CASCADINGKILL_REQUIREMENT_TIME )
	{
		attacker.s.currentTimedKillstreak = 0 // reset first before kill
		attacker.s.lastKillTime = Time()
	}
	
	// timed killstreaks
	if ( Time() - attacker.s.lastKillTime <= CASCADINGKILL_REQUIREMENT_TIME )
	{
		attacker.s.currentTimedKillstreak++
		
		if ( attacker.s.currentTimedKillstreak == DOUBLEKILL_REQUIREMENT_KILLS )
			AddPlayerScore( attacker, "DoubleKill" )
		else if ( attacker.s.currentTimedKillstreak == TRIPLEKILL_REQUIREMENT_KILLS )
			AddPlayerScore( attacker, "TripleKill" )
		else if ( attacker.s.currentTimedKillstreak >= MEGAKILL_REQUIREMENT_KILLS )
			AddPlayerScore( attacker, "MegaKill", attacker )
	}
	
	attacker.s.lastKillTime = Time()
}

void function ScoreEvent_TitanDoomed( entity titan, entity attacker, var damageInfo )
{
	// will this handle npc titans with no owners well? i have literally no idea
	
	if ( titan.IsNPC() )
		AddPlayerScore( attacker, "DoomAutoTitan", titan )
	else
		AddPlayerScore( attacker, "DoomTitan", titan )
}

void function ScoreEvent_TitanKilled( entity victim, entity attacker, var damageInfo )
{
	// will this handle npc titans with no owners well? i have literally no idea
	if ( !attacker.IsPlayer() )
		return

	if ( attacker.IsTitan() )
	{
		if( victim.GetBossPlayer() || victim.IsPlayer() ) // to confirm this is a pet titan or player titan
			AddPlayerScore( attacker, "TitanKillTitan", attacker ) // this will show the "Titan Kill" callsign event
		else
			AddPlayerScore( attacker, "TitanKillTitan" )
	}
	else
	{
		if( victim.GetBossPlayer() || victim.IsPlayer() )
			AddPlayerScore( attacker, "KillTitan", attacker )
		else
			AddPlayerScore( attacker, "KillTitan" )
	}

	table<int, bool> alreadyAssisted
	foreach( DamageHistoryStruct attackerInfo in victim.e.recentDamageHistory )
	{
		if ( !IsValid( attackerInfo.attacker ) || !attackerInfo.attacker.IsPlayer() || attackerInfo.attacker == victim )
			continue
			
		bool exists = attackerInfo.attacker.GetEncodedEHandle() in alreadyAssisted ? true : false
		if( attackerInfo.attacker != attacker && !exists )
		{
			alreadyAssisted[attackerInfo.attacker.GetEncodedEHandle()] <- true
			AddPlayerScore(attackerInfo.attacker, "TitanAssist" )
			Remote_CallFunction_NonReplay( attackerInfo.attacker, "ServerCallback_SetAssistInformation", attackerInfo.damageSourceId, attacker.GetEncodedEHandle(), victim.GetEncodedEHandle(), attackerInfo.time ) 
		}
	}
}

void function ScoreEvent_NPCKilled( entity victim, entity attacker, var damageInfo )
{
	try
	{		
		// have to trycatch this because marvins will crash on kill if we dont
		AddPlayerScore( attacker, ScoreEventForNPCKilled( victim, damageInfo ), victim )
	}
	catch ( ex ) {}
}



void function ScoreEvent_SetEarnMeterValues( string eventName, float earned, float owned, float coreScale = 1.0 )
{
	ScoreEvent event = GetScoreEvent( eventName )
	event.earnMeterEarnValue = earned
	event.earnMeterOwnValue = owned
	event.coreMeterScalar = coreScale
}

void function ScoreEvent_SetupEarnMeterValuesForMixedModes() // mixed modes in this case means modes with both pilots and titans
{
	// todo needs earn/overdrive values
	// player-controlled stuff
	ScoreEvent_SetEarnMeterValues( "KillPilot", 0.07, 0.15 )
	ScoreEvent_SetEarnMeterValues( "KillTitan", 0.0, 0.15 )
	ScoreEvent_SetEarnMeterValues( "TitanKillTitan", 0.0, 0.0 ) // unsure
	ScoreEvent_SetEarnMeterValues( "PilotBatteryStolen", 0.0, 0.35 ) // this actually just doesn't have overdrive in vanilla even
	ScoreEvent_SetEarnMeterValues( "Headshot", 0.0, 0.02 )
	ScoreEvent_SetEarnMeterValues( "FirstStrike", 0.0, 0.05 )
	ScoreEvent_SetEarnMeterValues( "PilotBatteryApplied", 0.0, 0.35 )
	
	// ai
	ScoreEvent_SetEarnMeterValues( "KillGrunt", 0.02, 0.02, 0.5 )
	ScoreEvent_SetEarnMeterValues( "KillSpectre", 0.02, 0.02, 0.5 )
	ScoreEvent_SetEarnMeterValues( "LeechSpectre", 0.02, 0.02 )
	ScoreEvent_SetEarnMeterValues( "KillStalker", 0.02, 0.02, 0.5 )
	ScoreEvent_SetEarnMeterValues( "KillSuperSpectre", 0.0, 0.1, 0.5 )
}

void function ScoreEvent_SetupEarnMeterValuesForTitanModes()
{
	// relatively sure we don't have to do anything here but leaving this function for consistency
}
