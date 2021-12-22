untyped

global function GamemodeCP_Init
global function RateSpawnpoints_CP

// needed for sh_gamemode_cp_dialogue
global array<entity> HARDPOINTS

struct HardpointStruct
{
	entity hardpoint
	entity trigger
	entity prop
	
	array<entity> imcCappers
	array<entity> militiaCappers
}

struct {
	bool ampingEnabled = true
	
	array<HardpointStruct> hardpoints
} file

void function GamemodeCP_Init()
{
	file.ampingEnabled = GetCurrentPlaylistVarInt( "cp_amped_capture_points", 1 ) == 1

	RegisterSignal( "HardpointCaptureStart" )
	ScoreEvent_SetupEarnMeterValuesForMixedModes()

	AddCallback_EntitiesDidLoad( SpawnHardpoints )
	AddCallback_GameStateEnter( eGameState.Playing, StartHardpointThink )
}

void function RateSpawnpoints_CP( int checkClass, array<entity> spawnpoints, int team, entity player ) 
{
	if ( HasSwitchedSides() )
		team = GetOtherTeam( team )

	// check hardpoints, determine which ones we own
	array<entity> startSpawns = SpawnPoints_GetPilotStart( team )
	vector averageFriendlySpawns
	
	// average out startspawn positions
	foreach ( entity spawnpoint in startSpawns )
		averageFriendlySpawns += spawnpoint.GetOrigin()
		
	averageFriendlySpawns /= startSpawns.len()
	
	entity friendlyHardpoint // determine our furthest out hardpoint
	foreach ( entity hardpoint in HARDPOINTS )
	{
		if ( hardpoint.GetTeam() == player.GetTeam() && GetGlobalNetFloat( "objective" + hardpoint.kv.hardpointGroup + "Progress" ) >= 0.95 )
		{
			if ( IsValid( friendlyHardpoint ) )
			{
				if ( Distance2D( averageFriendlySpawns, hardpoint.GetOrigin() ) > Distance2D( averageFriendlySpawns, friendlyHardpoint.GetOrigin() ) )
					friendlyHardpoint = hardpoint
			}
			else
				friendlyHardpoint = hardpoint
		}
	}
	
	vector ratingPos 
	if ( IsValid( friendlyHardpoint ) )
		ratingPos = friendlyHardpoint.GetOrigin()
	else 
		ratingPos = averageFriendlySpawns
		
	foreach ( entity spawnpoint in spawnpoints )
	{
		// idk about magic number here really
		float rating = 1.0 - ( Distance2D( spawnpoint.GetOrigin(), ratingPos ) / 1000.0 )
		spawnpoint.CalculateRating( checkClass, player.GetTeam(), rating, rating )
	}
}

void function SpawnHardpoints()
{
	foreach ( entity spawnpoint in GetEntArrayByClass_Expensive( "info_hardpoint" ) )
	{
		if ( GameModeRemove( spawnpoint ) )
			continue
		
		// spawnpoints are CHardPoint entities
		// init the hardpoint ent
		int hardpointID = 0
		if ( spawnpoint.kv.hardpointGroup == "B" )
			hardpointID = 1
		else if ( spawnpoint.kv.hardpointGroup == "C" )
			hardpointID = 2

		spawnpoint.SetHardpointID( hardpointID )
	
		HardpointStruct hardpointStruct
		hardpointStruct.hardpoint = spawnpoint
		hardpointStruct.prop = CreatePropDynamic( spawnpoint.GetModelName(), spawnpoint.GetOrigin(), spawnpoint.GetAngles(), 6 )
		
		entity trigger = GetEnt( expect string( spawnpoint.kv.triggerTarget ) )
		hardpointStruct.trigger = trigger
		
		file.hardpoints.append( hardpointStruct )
		HARDPOINTS.append( spawnpoint ) // for vo script
		spawnpoint.s.trigger <- trigger // also for vo script
		
		SetGlobalNetEnt( "objective" + spawnpoint.kv.hardpointGroup + "Ent", spawnpoint ) 
		
		// set up trigger functions
		trigger.SetEnterCallback( OnHardpointEntered )
		trigger.SetLeaveCallback( OnHardpointLeft )
	}
}

// functions for handling hardpoint netvars
void function SetHardpointState( HardpointStruct hardpoint, int state )
{
	SetGlobalNetInt( "objective" + hardpoint.hardpoint.kv.hardpointGroup + "State", state )
	hardpoint.hardpoint.SetHardpointState( state )
}

int function GetHardpointState( HardpointStruct hardpoint )
{
	return GetGlobalNetInt( "objective" + hardpoint.hardpoint.kv.hardpointGroup + "State" )
}

void function SetHardpointCappingTeam( HardpointStruct hardpoint, int team )
{
	SetGlobalNetInt( "objective" + hardpoint.hardpoint.kv.hardpointGroup + "CappingTeam", team )
}

int function GetHardpointCappingTeam( HardpointStruct hardpoint )
{
	return GetGlobalNetInt( "objective" + hardpoint.hardpoint.kv.hardpointGroup + "CappingTeam" )
}

void function SetHardpointCaptureProgress( HardpointStruct hardpoint, float progress )
{
	SetGlobalNetFloat( "objective" + hardpoint.hardpoint.kv.hardpointGroup + "Progress", progress )
}

float function GetHardpointCaptureProgress( HardpointStruct hardpoint )
{
	return GetGlobalNetFloat( "objective" + hardpoint.hardpoint.kv.hardpointGroup + "Progress" )
}


void function StartHardpointThink()
{
	thread TrackChevronStates()

	foreach ( HardpointStruct hardpoint in file.hardpoints )
		thread HardpointThink( hardpoint )
}

void function HardpointThink( HardpointStruct hardpoint )
{
	entity hardpointEnt = hardpoint.hardpoint
	
	float lastTime = Time()
	float lastScoreTime = Time()
	
	WaitFrame() // wait a frame so deltaTime is never zero
	while ( GamePlayingOrSuddenDeath() )
	{
		int imcCappers = hardpoint.imcCappers.len()
		int militiaCappers = hardpoint.militiaCappers.len()
		
		float deltaTime = Time() - lastTime
		
		int cappingTeam
		if ( imcCappers > militiaCappers )
			cappingTeam = TEAM_IMC 
		else if ( militiaCappers > imcCappers )
			cappingTeam = TEAM_MILITIA
		
		if ( cappingTeam != TEAM_UNASSIGNED )
		{
			// hardpoint is owned by controlling team
			if ( hardpointEnt.GetTeam() == cappingTeam )
			{
				// hardpoint is being neutralised, reverse the neutralisation
				if ( GetHardpointCappingTeam( hardpoint ) != cappingTeam || GetHardpointCaptureProgress( hardpoint ) < 1.0 )
				{
					SetHardpointCappingTeam( hardpoint, cappingTeam )
					SetHardpointCaptureProgress( hardpoint, min( 1.0, GetHardpointCaptureProgress( hardpoint ) + ( deltaTime / CAPTURE_DURATION_CAPTURE ) ) )
				}
				// hardpoint is fully captured, start amping if amping is enabled
				else if ( file.ampingEnabled && GetHardpointState( hardpoint ) < CAPTURE_POINT_STATE_AMPING )
					SetHardpointState( hardpoint, CAPTURE_POINT_STATE_AMPING )
				
				// amp the hardpoint
				if ( GetHardpointState( hardpoint ) == CAPTURE_POINT_STATE_AMPING )
				{
					SetHardpointCaptureProgress( hardpoint, min( 2.0, GetHardpointCaptureProgress( hardpoint ) + ( deltaTime / HARDPOINT_AMPED_DELAY ) ) )
					if ( GetHardpointCaptureProgress( hardpoint ) == 2.0 )
					{
						SetHardpointState( hardpoint, CAPTURE_POINT_STATE_AMPED )
						
						// can't use the dialogue functions here because for some reason GamemodeCP_VO_Amped isn't global?
						PlayFactionDialogueToTeam( "amphp_youAmped" + hardpointEnt.kv.hardpointGroup, cappingTeam )
						PlayFactionDialogueToTeam( "amphp_enemyAmped" + hardpointEnt.kv.hardpointGroup, GetOtherTeam( cappingTeam ) )
					}
				}
			}
			else // we don't own this hardpoint, cap it
			{
				SetHardpointCappingTeam( hardpoint, cappingTeam )
				GamemodeCP_VO_StartCapping( hardpointEnt ) // this doesn't consistently trigger for some reason
			
				SetHardpointCaptureProgress( hardpoint, min( 1.0, GetHardpointCaptureProgress( hardpoint ) + ( deltaTime / CAPTURE_DURATION_CAPTURE ) ) )
				
				if ( GetHardpointCaptureProgress( hardpoint ) >= 1.0 )
				{
					SetTeam( hardpointEnt, cappingTeam )
					SetTeam( hardpoint.prop, cappingTeam )
					SetHardpointState( hardpoint, CAPTURE_POINT_STATE_CAPTURED )
					
					EmitSoundOnEntityToTeamExceptPlayer( hardpointEnt, "hardpoint_console_captured", cappingTeam, null )
					GamemodeCP_VO_Captured( hardpointEnt )
				}
			}
		}
		// capture halting
		else if ( imcCappers > 0 && imcCappers == militiaCappers )
			SetHardpointState( hardpoint, CAPTURE_POINT_STATE_HALTED )
		// amped decay
		else if ( imcCappers == 0 && militiaCappers == 0 && GetHardpointState( hardpoint ) >= CAPTURE_POINT_STATE_AMPING )
		{
			// it seems like network vars won't change if they're too similar? often we get situations here where it's tryna change from 1.00098 to 1 which doesn't work
			// so we need to check the "real" progress manually
			// have only gotten this issue here so far, but in theory i think this could be an issue in a good few places, worth looking out for
			// tho, idk might not be, we don't work with numbers at this small of a scale too often
			float realProgress = max( 1.0, GetHardpointCaptureProgress( hardpoint ) - ( deltaTime / HARDPOINT_AMPED_DELAY ) )
			SetHardpointCaptureProgress( hardpoint, realProgress )
			
			if ( realProgress == 1 )
				SetHardpointState( hardpoint, CAPTURE_POINT_STATE_CAPTURED )
			// dont use unamping atm
			//else
			//	SetHardpointState( hardpoint, CAPTURE_POINT_STATE_SELF_UNAMPING )
		}
		
		// scoring
		if ( hardpointEnt.GetTeam() != TEAM_UNASSIGNED && GetHardpointState( hardpoint ) >= CAPTURE_POINT_STATE_CAPTURED && Time() - lastScoreTime >= TEAM_OWNED_SCORE_FREQ )
		{
			lastScoreTime = Time()
		
			// 2x score if amped
			if ( GetHardpointState( hardpoint ) == CAPTURE_POINT_STATE_AMPED )
				AddTeamScore( hardpointEnt.GetTeam(), 2 )
			else
				AddTeamScore( hardpointEnt.GetTeam(), 1 )
		}
	
		lastTime = Time()
		WaitFrame()
	}
}

// doing this in HardpointThink is effort since it's for individual hardpoints
// so we do it here instead
void function TrackChevronStates()
{
	// you get 1 amped arrow for chevron / 4, 1 unamped arrow for every 1 the amped chevrons
	
	while ( true )
	{
		int imcChevron
		int militiaChevron
		
		foreach ( HardpointStruct hardpoint in file.hardpoints )
		{
			if ( hardpoint.hardpoint.GetTeam() == TEAM_IMC )
			{
				if ( hardpoint.hardpoint.GetHardpointState() == CAPTURE_POINT_STATE_AMPED )
					imcChevron += 4
				else if ( hardpoint.hardpoint.GetHardpointState() >= CAPTURE_POINT_STATE_CAPTURED )
					imcChevron++
			}
			else if ( hardpoint.hardpoint.GetTeam() == TEAM_MILITIA )
			{
				if ( hardpoint.hardpoint.GetHardpointState() == CAPTURE_POINT_STATE_AMPED )
					militiaChevron += 4
				else if ( hardpoint.hardpoint.GetHardpointState() >= CAPTURE_POINT_STATE_CAPTURED )
					militiaChevron++
			}
		}
		
		SetGlobalNetInt( "imcChevronState", imcChevron )
		SetGlobalNetInt( "milChevronState", militiaChevron )
		
		WaitFrame()
	}
}

void function OnHardpointEntered( entity trigger, entity player )
{
	HardpointStruct hardpoint
	foreach ( HardpointStruct hardpointStruct in file.hardpoints )
		if ( hardpointStruct.trigger == trigger )
			hardpoint = hardpointStruct

	if ( player.GetTeam() == TEAM_IMC )
		hardpoint.imcCappers.append( player )
	else
		hardpoint.militiaCappers.append( player )
}

void function OnHardpointLeft( entity trigger, entity player )
{
	HardpointStruct hardpoint
	foreach ( HardpointStruct hardpointStruct in file.hardpoints )
		if ( hardpointStruct.trigger == trigger )
			hardpoint = hardpointStruct

	if ( player.GetTeam() == TEAM_IMC )
		hardpoint.imcCappers.remove( hardpoint.imcCappers.find( player ) )
	else
		hardpoint.militiaCappers.remove( hardpoint.militiaCappers.find( player ) )
}