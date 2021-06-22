untyped
global function GamemodeMfd_Init

struct {
	entity imcLastMark
	entity militiaLastMark
} file

void function GamemodeMfd_Init()
{
	GamemodeMfdShared_Init()
		
	RegisterSignal( "MarkKilled" )
		
	AddCallback_OnPlayerKilled( UpdateMarksForKill )
	AddCallback_GameStateEnter( eGameState.Playing, CreateInitialMarks )
}

void function CreateInitialMarks()
{
	entity imcMark = CreateEntity( MARKER_ENT_CLASSNAME )
	imcMark.kv.spawnflags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT
	SetTeam( imcMark, TEAM_IMC )
	SetTargetName( imcMark, MARKET_ENT_MARKED_NAME ) // why is it market_ent lol
	DispatchSpawn( imcMark )
	FillMFDMarkers( imcMark )
	
	entity imcPendingMark = CreateEntity( MARKER_ENT_CLASSNAME )
	imcPendingMark.kv.spawnflags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT
	SetTeam( imcPendingMark, TEAM_IMC )
	SetTargetName( imcPendingMark, MARKET_ENT_PENDING_MARKED_NAME )
	DispatchSpawn( imcPendingMark )
	FillMFDMarkers( imcPendingMark )
	
	entity militiaMark = CreateEntity( MARKER_ENT_CLASSNAME )
	militiaMark.kv.spawnflags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT
	SetTeam( militiaMark, TEAM_MILITIA )
	SetTargetName( militiaMark, MARKET_ENT_MARKED_NAME )
	DispatchSpawn( militiaMark )
	FillMFDMarkers( militiaMark )
	
	entity militiaPendingMark = CreateEntity( MARKER_ENT_CLASSNAME )
	militiaPendingMark.kv.spawnflags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT
	SetTeam( militiaPendingMark, TEAM_MILITIA )
	SetTargetName( militiaPendingMark, MARKET_ENT_PENDING_MARKED_NAME )
	DispatchSpawn( militiaPendingMark )
	FillMFDMarkers( militiaPendingMark )

	thread MFDThink()
}

void function MFDThink()
{
	svGlobal.levelEnt.EndSignal( "GameStateChanged" )
	
	entity imcMark
	entity militiaMark
	
	while ( true )
	{	
		if ( !TargetsMarkedImmediately() )
			wait MFD_BETWEEN_MARKS_TIME
	
		// wait for enough players to spawn
		array<entity> imcPlayers
		array<entity> militiaPlayers
		while ( imcPlayers.len() == 0 || militiaPlayers.len() == 0 )
		{
			imcPlayers =  GetPlayerArrayOfTeam( TEAM_IMC )
			militiaPlayers = GetPlayerArrayOfTeam( TEAM_MILITIA )
			
			WaitFrame()
		}
		
		// get marks, wanna increment the mark each mark, reset on player change
		int imcIndex = imcPlayers.find( imcMark )
		if ( imcIndex == -1 ) // last mark
			imcIndex = 0
		else
			imcIndex = ( imcIndex + 1 ) % imcPlayers.len()
			
		imcMark = imcPlayers[ imcIndex ]
			
		int militiaIndex = militiaPlayers.find( imcMark )
		if ( militiaIndex == -1 ) // last mark
			militiaIndex = 0
		else
			militiaIndex = ( militiaIndex + 1 ) % militiaPlayers.len()
			
		militiaMark = militiaPlayers[ militiaIndex ]
		
		level.mfdPendingMarkedPlayerEnt[ TEAM_IMC ].SetOwner( imcMark )
		level.mfdPendingMarkedPlayerEnt[ TEAM_MILITIA ].SetOwner( militiaMark )
		
		foreach ( entity player in GetPlayerArray() )
		{
			Remote_CallFunction_NonReplay( player, "SCB_MarkedChanged" )
			Remote_CallFunction_NonReplay( player, "ServerCallback_MFD_StartNewMarkCountdown", Time() + MFD_COUNTDOWN_TIME )
		}
		
		// reset if mark leaves
		bool shouldReset
		float endTime = Time() + MFD_COUNTDOWN_TIME
		while ( endTime > Time() || ( !IsAlive( imcMark ) || !IsAlive( militiaMark ) ) )
		{
			if ( !IsValid( imcMark ) || !IsValid( militiaMark ) )
			{
				shouldReset = true
				break
			}
				
			WaitFrame()
		}
		
		if ( shouldReset )
			continue
		
		waitthread MarkPlayers( imcMark, militiaMark )
	}
}

void function MarkPlayers( entity imcMark, entity militiaMark )
{
	imcMark.EndSignal( "OnDestroy" )
	imcMark.EndSignal( "Disconnected" )
	
	militiaMark.EndSignal( "OnDestroy" )
	militiaMark.EndSignal( "Disconnected" )
	
	OnThreadEnd( function() : ( imcMark, militiaMark ) 
	{
		// clear marks
		level.mfdActiveMarkedPlayerEnt[ TEAM_IMC ].SetOwner( null )
		level.mfdActiveMarkedPlayerEnt[ TEAM_MILITIA ].SetOwner( null )
		
		foreach ( entity player in GetPlayerArray() )
			Remote_CallFunction_NonReplay( player, "SCB_MarkedChanged" )
	})
	
	// clear pending marks
	level.mfdPendingMarkedPlayerEnt[ TEAM_IMC ].SetOwner( null )
	level.mfdPendingMarkedPlayerEnt[ TEAM_MILITIA ].SetOwner( null )
	
	// set marks
	level.mfdActiveMarkedPlayerEnt[ TEAM_IMC ].SetOwner( imcMark )
	level.mfdActiveMarkedPlayerEnt[ TEAM_MILITIA ].SetOwner( militiaMark )
	
	foreach ( entity player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "SCB_MarkedChanged" )
		
	// wait until mark dies
	entity deadMark = expect entity( svGlobal.levelEnt.WaitSignal( "MarkKilled" ).mark )
	
	// award points
	entity livingMark = GetMarked( GetOtherTeam( deadMark.GetTeam() ) )
	livingMark.SetPlayerGameStat( PGS_DEFENSE_SCORE, livingMark.GetPlayerGameStat( PGS_DEFENSE_SCORE ) + 1 )
	AddTeamScore( livingMark.GetTeam(), 1 )
}

void function UpdateMarksForKill( entity victim, entity attacker, var damageInfo )
{
	if ( victim == GetMarked( victim.GetTeam() ) )
	{
		svGlobal.levelEnt.Signal( "MarkKilled", { mark = victim } )
	
		if ( attacker.IsPlayer() )
			attacker.SetPlayerGameStat( PGS_ASSAULT_SCORE, attacker.GetPlayerGameStat( PGS_ASSAULT_SCORE ) + 1 )
	}
}

/*
void function MarkPlayers()
{
	// todo: need to handle disconnecting marks
	if ( !TargetsMarkedImmediately() )
		wait MFD_BETWEEN_MARKS_TIME
	

	// wait until we actually have 2 valid players
	array<entity> imcPlayers
	array<entity> militiaPlayers
	while ( imcPlayers.len() == 0 || militiaPlayers.len() == 0 )
	{
		imcPlayers =  GetPlayerArrayOfTeam( TEAM_IMC )
		militiaPlayers = GetPlayerArrayOfTeam( TEAM_MILITIA )
		
		WaitFrame()
	}
	
	// decide marks
	entity imcMark = imcPlayers[ RandomInt( imcPlayers.len() ) ]
	level.mfdPendingMarkedPlayerEnt[ TEAM_IMC ].SetOwner( imcMark )
	
	entity militiaMark = militiaPlayers[ RandomInt( militiaPlayers.len() ) ]
	level.mfdPendingMarkedPlayerEnt[ TEAM_MILITIA ].SetOwner( militiaMark )
	
	foreach ( entity player in GetPlayerArray() )
	{
		Remote_CallFunction_NonReplay( player, "SCB_MarkedChanged" )
		Remote_CallFunction_NonReplay( player, "ServerCallback_MFD_StartNewMarkCountdown", Time() + MFD_COUNTDOWN_TIME )
	}
		
	wait MFD_COUNTDOWN_TIME
	
	while ( !IsAlive( imcMark ) || !IsAlive( militiaMark ) )
		WaitFrame()
	
	// clear pending marks
	level.mfdPendingMarkedPlayerEnt[ TEAM_IMC ].SetOwner( null )
	level.mfdPendingMarkedPlayerEnt[ TEAM_MILITIA ].SetOwner( null )
	
	// set marks
	level.mfdActiveMarkedPlayerEnt[ TEAM_IMC ].SetOwner( imcMark )
	level.mfdActiveMarkedPlayerEnt[ TEAM_MILITIA ].SetOwner( militiaMark )
	
	foreach ( entity player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "SCB_MarkedChanged" )
	
	while ( IsAlive( imcMark ) && IsAlive( militiaMark ) )
		WaitFrame()
		
	// clear marks
	level.mfdActiveMarkedPlayerEnt[ TEAM_IMC ].SetOwner( null )
	level.mfdActiveMarkedPlayerEnt[ TEAM_MILITIA ].SetOwner( null )
		
	foreach ( entity player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "SCB_MarkedChanged" )
	
	thread MarkPlayers()
}*/