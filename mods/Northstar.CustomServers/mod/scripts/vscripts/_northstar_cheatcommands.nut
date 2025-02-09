untyped
global function NorthstarCheatCommands_Init

void function NorthstarCheatCommands_Init()
{
	AddClientCommandCallback( "noclip", ClientCommandCallbackToggleNoclip )
	AddClientCommandCallback( "notarget", ClientCommandCallbackToggleNotarget )
	AddClientCommandCallback( "demigod", ClientCommandCallbackToggleDemigod )
	AddClientCommandCallback( "god", ClientCommandCallbackToggleDemigod )
	AddClientCommandCallback( "kill", ClientCommandCallbackKill )
	AddClientCommandCallback( "explode", ClientCommandCallbackExplode )
}

bool function ClientCommandCallbackToggleNoclip( entity player, array<string> args )
{
	if ( !GetConVarBool( "sv_cheats" ) )
		return true
	if ( player.GetParent() ) // change movetype while setparented will crash the server
	{
		print( player + " failed noclipping because the entity is parented" )
		return true
	}

	if ( player.IsNoclipping() )
	{
		player.SetPhysics( MOVETYPE_WALK )
		print( player + " TOGGLED NOCLIP OFF" )
	}
	else
	{
		player.SetPhysics( MOVETYPE_NOCLIP )
		print( player + " TOGGLED NOCLIP ON" )
	}

	return true
}

bool function ClientCommandCallbackToggleNotarget( entity player, array<string> args )
{
	if ( !GetConVarBool( "sv_cheats" ) )
		return true

	if ( player.GetNoTarget() )
		print( player + " TOGGLED NOTARGET OFF" )
	else
		print( player + " TOGGLED NOTARGET ON" )

	player.SetNoTarget( !player.GetNoTarget() )
	player.SetNoTargetSmartAmmo( player.GetNoTarget() )

	return true
}

bool function ClientCommandCallbackToggleDemigod( entity player, array<string> args )
{
	if ( !GetConVarBool( "sv_cheats" ) )
		return true

	if ( IsDemigod( player ) )
	{
		DisableDemigod( player )
		print( player + " TOGGLED DEMIGOD OFF" )
	}
	else
	{
		EnableDemigod( player )
		print( player + " TOGGLED DEMIGOD ON" )
	}

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
