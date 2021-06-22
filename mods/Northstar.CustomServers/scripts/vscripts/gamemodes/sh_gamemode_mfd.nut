untyped

global function GamemodeMfdShared_Init
global function GetMarked
global function GetPendingMarked
global function FillMFDMarkers
global function TargetsMarkedImmediately
global function IsTitanMarkedForDeathMode

void function GamemodeMfdShared_Init()
{
	// mfd mfdActiveMarkedPlayerEnt are server side entities with a boss player that marks the marked
	level.mfdActiveMarkedPlayerEnt <- {}
	level.mfdActiveMarkedPlayerEnt[ TEAM_IMC ] <- null
	level.mfdActiveMarkedPlayerEnt[ TEAM_MILITIA ] <- null

	level.mfdPendingMarkedPlayerEnt <- {}
	level.mfdPendingMarkedPlayerEnt[ TEAM_IMC ] <- null
	level.mfdPendingMarkedPlayerEnt[ TEAM_MILITIA ] <- null

	SetWaveSpawnInterval( 8.0 )
}

entity function GetMarked( int team )
{
	if ( IsValid( level.mfdActiveMarkedPlayerEnt[ team ] ) )
		return expect entity( level.mfdActiveMarkedPlayerEnt[ team ] ).GetOwner()

	return null
}

entity function GetPendingMarked( int team )
{
	if ( IsValid( level.mfdPendingMarkedPlayerEnt[ team ] ) )
		return expect entity( level.mfdPendingMarkedPlayerEnt[ team ] ).GetOwner()

	return null
}

function FillMFDMarkers( entity ent ) //Ent used for kill replay related issues...
{
	print( "FillMFDMarkers " + ent )

	if ( ent.GetTargetName() == MARKET_ENT_MARKED_NAME )
	{
		Assert( ent.GetTeam() != TEAM_UNASSIGNED )
		level.mfdActiveMarkedPlayerEnt[ ent.GetTeam() ] = ent
	}
	else if ( ent.GetTargetName() == MARKET_ENT_PENDING_MARKED_NAME )
	{
		Assert( ent.GetTeam() != TEAM_UNASSIGNED )
		level.mfdPendingMarkedPlayerEnt[ ent.GetTeam() ] = ent
	}

	return
}

function TargetsMarkedImmediately()
{
	return IsRoundBased() && IsPilotEliminationBased()
}

bool function IsTitanMarkedForDeathMode()
{
	return GetCurrentPlaylistVarInt( "titan_marked_for_death", 0 ) == 1
}