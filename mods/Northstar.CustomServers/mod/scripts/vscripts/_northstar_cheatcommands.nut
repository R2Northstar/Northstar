untyped
global function NorthstarCheatCommands_Init

void function NorthstarCheatCommands_Init()
{
	AddClientCommandCallback( "noclip", ClientCommandCallbackToggleNoclip )
	AddClientCommandCallback( "notarget", ClientCommandCallbackToggleNotarget )
	AddClientCommandCallback( "demigod", ClientCommandCallbackToggleDemigod )
	AddClientCommandCallback( "kill", ClientCommandCallbackKill )
	AddClientCommandCallback( "explode", ClientCommandCallbackExplode )
}

bool function ClientCommandCallbackToggleNoclip( entity player, array<string> args )
{
	if ( !GetConVarBool( "sv_cheats" ) )
		return true
	
	print( player + " TOGGLED NOCLIP" )

	if ( player.IsNoclipping() )
		player.SetPhysics( MOVETYPE_WALK )
	else
		player.SetPhysics( MOVETYPE_NOCLIP )
		
	return true
}

bool function ClientCommandCallbackToggleNotarget( entity player, array<string> args )
{
	if ( !GetConVarBool( "sv_cheats" ) )
		return true

	print( player + " TOGGLED NOTARGET" )

	player.SetNoTarget( !player.GetNoTarget() )
	player.SetNoTargetSmartAmmo( player.GetNoTarget() )
	return true
}

bool function ClientCommandCallbackToggleDemigod( entity player, array<string> args )
{
	if ( !GetConVarBool( "sv_cheats" ) )
		return true

	print( player + " TOGGLED DEMIGOD" )

	if ( IsDemigod( player ) )
		DisableDemigod( player )
	else
		EnableDemigod( player )
		
	return true
}

bool function ClientCommandCallbackKill( entity player, array<string> args )
{
	if ( IsAlive( player ) && ( GetConVarBool( "sv_cheats" ) || GetConVarBool( "ns_allow_kill_commands" ) ) )
		player.Die()
	
	return true
}

bool function ClientCommandCallbackExplode( entity player, array<string> args )
{
	if ( IsAlive( player ) && ( GetConVarBool( "sv_cheats" ) || GetConVarBool( "ns_allow_kill_commands" ) ) )
		player.Die( null, null, { scriptType = DF_GIB } )
	
	return true
}
