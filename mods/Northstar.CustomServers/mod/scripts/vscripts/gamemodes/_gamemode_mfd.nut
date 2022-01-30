untyped
global function GamemodeMfd_Init

struct {
	entity imcLastMark
	entity militiaLastMark
	bool isMfdPro
} file

void function GamemodeMfd_Init()
{
	GamemodeMfdShared_Init()
		
	RegisterSignal( "MarkKilled" )
	ScoreEvent_SetupEarnMeterValuesForMixedModes()
	
	// todo
	if ( GAMETYPE == MARKED_FOR_DEATH_PRO )
	{
		file.isMfdPro = true
		SetRespawnsEnabled( true )
		SetRoundBased( true )
		SetShouldUseRoundWinningKillReplay( true )
		Riff_ForceSetEliminationMode( eEliminationMode.Pilots )
	}
	
	AddCallback_OnClientConnected( SetupMFDPlayer )
	AddCallback_OnPlayerKilled( UpdateMarksForKill )
	AddCallback_GameStateEnter( eGameState.Playing, CreateInitialMarks )
}

void function SetupMFDPlayer( entity player )
{
	player.s.roundsSincePicked <- 0
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
		while ( GetPlayerArrayOfTeam( TEAM_IMC ).len() == 0 || GetPlayerArrayOfTeam( TEAM_MILITIA ).len() == 0 )
			WaitFrame()
		
		imcMark = PickTeamMark( TEAM_IMC )
		militiaMark = PickTeamMark( TEAM_MILITIA )
		
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

entity function PickTeamMark( int team )
{
	array<entity> possibleMarks

	int maxRounds
	foreach ( entity player in GetPlayerArrayOfTeam( team ) )
	{
		if ( maxRounds < player.s.roundsSincePicked )
		{
			maxRounds = expect int( player.s.roundsSincePicked )
			possibleMarks = [ player ]
		}
		else if ( maxRounds == player.s.roundsSincePicked )
			possibleMarks.append( player )
	}
	
	entity mark = possibleMarks.getrandom()
	foreach ( entity player in GetPlayerArrayOfTeam( team ) )
		if ( player != mark )
			player.s.roundsSincePicked++
	
	return mark
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
		imcMark.Minimap_Hide( TEAM_MILITIA, null )
		militiaMark.Minimap_Hide( TEAM_IMC, null )
		
		foreach ( entity player in GetPlayerArray() )
			Remote_CallFunction_NonReplay( player, "SCB_MarkedChanged" )
	})
	
	// clear pending marks
	level.mfdPendingMarkedPlayerEnt[ TEAM_IMC ].SetOwner( null )
	level.mfdPendingMarkedPlayerEnt[ TEAM_MILITIA ].SetOwner( null )
	
	// set marks
	level.mfdActiveMarkedPlayerEnt[ TEAM_IMC ].SetOwner( imcMark )
	level.mfdActiveMarkedPlayerEnt[ TEAM_MILITIA ].SetOwner( militiaMark )
	imcMark.Minimap_AlwaysShow( TEAM_MILITIA, null )
	militiaMark.Minimap_AlwaysShow( TEAM_IMC, null )
	
	foreach ( entity player in GetPlayerArray() )
		Remote_CallFunction_NonReplay( player, "SCB_MarkedChanged" )
		
	// wait until mark dies
	entity deadMark = expect entity( svGlobal.levelEnt.WaitSignal( "MarkKilled" ).mark )
	
	// award points
	entity livingMark = GetMarked( GetOtherTeam( deadMark.GetTeam() ) )
	livingMark.SetPlayerGameStat( PGS_DEFENSE_SCORE, livingMark.GetPlayerGameStat( PGS_DEFENSE_SCORE ) + 1 )
	
	// thread this so we don't kill our own thread
	thread AddTeamScore( livingMark.GetTeam(), 1 )
}

void function UpdateMarksForKill( entity victim, entity attacker, var damageInfo )
{
	if ( victim == GetMarked( victim.GetTeam() ) )
	{
		MessageToAll( eEventNotifications.MarkedForDeathKill, null, victim, attacker.GetEncodedEHandle() )
		svGlobal.levelEnt.Signal( "MarkKilled", { mark = victim } )
		
		if ( attacker.IsPlayer() )
			attacker.SetPlayerGameStat( PGS_ASSAULT_SCORE, attacker.GetPlayerGameStat( PGS_ASSAULT_SCORE ) + 1 )
	}
}