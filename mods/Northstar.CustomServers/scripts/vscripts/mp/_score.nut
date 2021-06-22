untyped

global function Score_Init

global function AddPlayerScore
global function ScoreEvent_PlayerKilled
global function ScoreEvent_TitanDoomed
global function ScoreEvent_TitanKilled
global function ScoreEvent_NPCKilled

global function ScoreEvent_SetEarnMeterValues
global function ScoreEvent_SetupEarnMeterValuesForMixedModes

struct {
	bool firstStrikeDone = false
} file

void function Score_Init()
{

}

void function AddPlayerScore( entity targetPlayer, string scoreEventName, entity associatedEnt = null, string noideawhatthisis = "", int pointValueOverride = -1 )
{
	ScoreEvent event = GetScoreEvent( scoreEventName )
	
	if ( !event.enabled )
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
		thread Delayed_PlayConversationToPlayer( event.conversation, targetPlayer, event.conversationDelay )
}

void function ScoreEvent_PlayerKilled( entity victim, entity attacker, var damageInfo )
{
	AddPlayerScore( attacker, "KillPilot", victim )
	
	if ( DamageInfo_GetCustomDamageType( damageInfo ) & DF_HEADSHOT )
		AddPlayerScore( attacker, "Headshot", victim )
		
	if ( !file.firstStrikeDone )
	{
		file.firstStrikeDone = true
		AddPlayerScore( attacker, "FirstStrike", attacker )
	}
	
	if ( victim.IsTitan() )
		ScoreEvent_TitanKilled( victim, attacker, damageInfo )
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

	if ( attacker.IsTitan() )
		AddPlayerScore( attacker, "TitanKillTitan", victim.GetTitanSoul().GetOwner() )
	else
		AddPlayerScore( attacker, "KillTitan", victim.GetTitanSoul().GetOwner() )
}

void function ScoreEvent_NPCKilled( entity victim, entity attacker, var damageInfo )
{
	AddPlayerScore( attacker, ScoreEventForNPCKilled( victim, damageInfo ), victim )
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
	ScoreEvent_SetEarnMeterValues( "KillPilot", 0.0, 0.05 )
	ScoreEvent_SetEarnMeterValues( "KillTitan", 0.0, 0.15 )
	ScoreEvent_SetEarnMeterValues( "TitanKillTitan", 0.0, 0.0 ) // unsure
	ScoreEvent_SetEarnMeterValues( "PilotBatteryStolen", 0.0, 0.35 )
	
	// ai
	ScoreEvent_SetEarnMeterValues( "KillGrunt", 0.0, 0.02, 0.5 )
	ScoreEvent_SetEarnMeterValues( "KillSpectre", 0.0, 0.02, 0.5 )
	ScoreEvent_SetEarnMeterValues( "LeechSpectre", 0.0, 0.02 )
	ScoreEvent_SetEarnMeterValues( "KillStalker", 0.0, 0.02, 0.5 )
	ScoreEvent_SetEarnMeterValues( "KillSuperSpectre", 0.0, 0.1, 0.5 )
}

void function ScoreEvent_SetupEarnMeterValuesForTitanModes()
{
	// todo needs earn/overdrive values
	
}