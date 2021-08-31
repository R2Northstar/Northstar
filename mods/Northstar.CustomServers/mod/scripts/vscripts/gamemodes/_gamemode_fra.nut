global function GamemodeFRA_AddAdditionalInitCallback
	
// fra doesn't register a gamemode init by default, adding one just so we can set stuff up for it
void function GamemodeFRA_AddAdditionalInitCallback()
{
	AddCallback_OnCustomGamemodesInit( GamemodeFRA_AddAdditionalInit )
}

void function GamemodeFRA_AddAdditionalInit()
{
	GameMode_AddServerInit( FREE_AGENCY, GamemodeFRA_Init )
}

void function GamemodeFRA_Init()
{
	// need a way to disable passive earnmeter gain
	ScoreEvent_SetEarnMeterValues( "PilotBatteryPickup", 0.0, 0.34 )
	EarnMeterMP_SetPassiveMeterGainEnabled( false )
	PilotBattery_SetMaxCount( 3 )

	AddCallback_OnPlayerKilled( FRARemoveEarnMeter )
}

void function FRARemoveEarnMeter( entity victim, entity attacker, var damageInfo )
{
	PlayerEarnMeter_Reset( victim )
}