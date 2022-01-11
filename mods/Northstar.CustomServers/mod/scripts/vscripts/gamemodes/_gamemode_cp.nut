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
		int imcPilotCappers = 0
		int militiaPilotCappers = 0

		int imcTitanCappers = 0
		int militiaTitanCappers = 0

		float currentTime = Time()
		float deltaTime = currentTime - lastTime


		foreach(entity p in hardpoint.imcCappers)
		{
			if(p.IsTitan()){
				imcTitanCappers = imcTitanCappers + 1
			}
			else if(!p.IsHologram())
			{
				imcPilotCappers = imcPilotCappers + 1
			}

		}
		//printt("Militia")
		foreach(entity p in hardpoint.militiaCappers)
		{

			if(p.IsTitan()){

				militiaTitanCappers = militiaTitanCappers + 1
			}
			else if(!p.IsHologram())
			{

				militiaPilotCappers = militiaPilotCappers + 1
			}


		}
		int imcCappers
		int militiaCappers
//		if(hardpoint.hardpoint.kv.hardpointGroup == "C"){
//			printt("melitia pilots",militiaPilotCappers)
//		}

		bool hardpointBlocked = false
		if((imcTitanCappers+militiaTitanCappers)>0)
		{
			imcCappers = imcTitanCappers
			militiaCappers = militiaTitanCappers
		}
		else
		{
			imcCappers = imcPilotCappers
			militiaCappers = militiaPilotCappers
		}



		int cappingTeam
		int capperAmount = 0
	//	if(hardpoint.hardpoint.kv.hardpointGroup == "C"){
	//		printt("melitia",militiaCappers)
	//	}

		if((imcCappers > 0) && (militiaCappers > 0)){
			hardpointBlocked = true
		}
		else if ( imcCappers > 0 )
		{
			cappingTeam = TEAM_IMC
			capperAmount = imcCappers
		}
		else if ( militiaCappers > 0 )
		{
			cappingTeam = TEAM_MILITIA
			capperAmount = militiaCappers
		}
		if(capperAmount>3) //is there a function for this because min returns float
			capperAmount = 3


		if(hardpointBlocked)
		{
			SetHardpointState(hardpoint,CAPTURE_POINT_STATE_HALTED)
		}
		else if(cappingTeam==TEAM_UNASSIGNED)//nobody on point
		{

			switch(GetHardpointState(hardpoint))
			{
				case CAPTURE_POINT_STATE_UNASSIGNED:
					SetHardpointCaptureProgress(hardpoint,max(0.0,GetHardpointCaptureProgress(hardpoint)-(deltaTime/CAPTURE_DURATION_CAPTURE)))
					if(GetHardpointCaptureProgress(hardpoint)==0.0)
						SetHardpointState(hardpoint,CAPTURE_POINT_STATE_UNASSIGNED)
					break
				case CAPTURE_POINT_STATE_CAPTURED:
					SetHardpointCaptureProgress(hardpoint,min(1.0,GetHardpointCaptureProgress(hardpoint)+(deltaTime/CAPTURE_DURATION_CAPTURE)))
					break
				case CAPTURE_POINT_STATE_AMPED:
				case CAPTURE_POINT_STATE_AMPING:
					SetHardpointCaptureProgress(hardpoint,max(1.0,GetHardpointCaptureProgress(hardpoint)-(deltaTime/HARDPOINT_AMPED_DELAY)))
					if(GetHardpointCaptureProgress(hardpoint)<=1.001)//Float inaccuacy
						SetHardpointState(hardpoint,CAPTURE_POINT_STATE_CAPTURED)
					break;
			}
		}
		else if(hardpointEnt.GetTeam()==TEAM_UNASSIGNED)
		{
			if(GetHardpointCappingTeam(hardpoint)==TEAM_UNASSIGNED)
			{
				SetHardpointCaptureProgress( hardpoint, min(1.0,GetHardpointCaptureProgress( hardpoint ) + ( deltaTime / CAPTURE_DURATION_CAPTURE * capperAmount) ) )
				SetHardpointCappingTeam(hardpoint,cappingTeam)
				if(GetHardpointCaptureProgress(hardpoint)>=1.0)
				{
					SetHardpointState(hardpoint,CAPTURE_POINT_STATE_CAPTURED)
					SetTeam( hardpointEnt, cappingTeam )
					SetTeam( hardpoint.prop, cappingTeam )
					EmitSoundOnEntityToTeamExceptPlayer( hardpointEnt, "hardpoint_console_captured", cappingTeam, null )
					GamemodeCP_VO_Captured( hardpointEnt )
				}
			}
			else if(GetHardpointCappingTeam(hardpoint)==cappingTeam)
			{
				SetHardpointCaptureProgress( hardpoint,min(1.0, GetHardpointCaptureProgress( hardpoint ) + ( deltaTime / CAPTURE_DURATION_CAPTURE * capperAmount) ) )
				if(GetHardpointCaptureProgress(hardpoint)>=1.0)
				{
					SetHardpointState(hardpoint,CAPTURE_POINT_STATE_CAPTURED)
					SetTeam( hardpointEnt, cappingTeam )
					SetTeam( hardpoint.prop, cappingTeam )
					EmitSoundOnEntityToTeamExceptPlayer( hardpointEnt, "hardpoint_console_captured", cappingTeam, null )
					GamemodeCP_VO_Captured( hardpointEnt )
				}
			}
			else
			{
				SetHardpointCaptureProgress( hardpoint,max(0.0, GetHardpointCaptureProgress( hardpoint ) - ( deltaTime / CAPTURE_DURATION_CAPTURE * capperAmount) ) )
				if(GetHardpointCaptureProgress(hardpoint)==0.0)
				{
					SetHardpointCappingTeam(hardpoint,cappingTeam)
					if(GetHardpointCaptureProgress(hardpoint)>=1)
					{
						SetHardpointState(hardpoint,CAPTURE_POINT_STATE_CAPTURED)
						SetTeam( hardpointEnt, cappingTeam )
						SetTeam( hardpoint.prop, cappingTeam )
						EmitSoundOnEntityToTeamExceptPlayer( hardpointEnt, "hardpoint_console_captured", cappingTeam, null )
						GamemodeCP_VO_Captured( hardpointEnt )
					}
				}

			}
		}
		else if(hardpointEnt.GetTeam()!=cappingTeam)
		{
			SetHardpointCaptureProgress( hardpoint,max(0.0, GetHardpointCaptureProgress( hardpoint ) - ( deltaTime / CAPTURE_DURATION_CAPTURE * capperAmount) ) )
			if(GetHardpointCaptureProgress(hardpoint)<=1.0)
			{
				SetHardpointState(hardpoint,CAPTURE_POINT_STATE_CAPTURED)//unamp
			}
			if(GetHardpointCaptureProgress(hardpoint)<=0.0)
			{
				SetHardpointCaptureProgress(hardpoint,1.0)
				SetTeam( hardpointEnt, cappingTeam )
				SetTeam( hardpoint.prop, cappingTeam )
				SetHardpointState(hardpoint,CAPTURE_POINT_STATE_CAPTURED)
				EmitSoundOnEntityToTeamExceptPlayer( hardpointEnt, "hardpoint_console_captured", cappingTeam, null )
				GamemodeCP_VO_Captured( hardpointEnt )
			}
		}
		else if(hardpointEnt.GetTeam()==cappingTeam)
		{
			if(GetHardpointCaptureProgress(hardpoint)<1.0)
			{
				SetHardpointCaptureProgress(hardpoint,GetHardpointCaptureProgress(hardpoint)+(deltaTime/CAPTURE_DURATION_CAPTURE*capperAmount))
			}
			else if(file.ampingEnabled)//amping or reamping
			{
				if(GetHardpointState(hardpoint)<CAPTURE_POINT_STATE_AMPING)
					SetHardpointState(hardpoint,CAPTURE_POINT_STATE_AMPING)
				SetHardpointCaptureProgress( hardpoint, min( 2.0, GetHardpointCaptureProgress( hardpoint ) + ( deltaTime / HARDPOINT_AMPED_DELAY * capperAmount ) ) )
				if(GetHardpointCaptureProgress(hardpoint)==2.0)
				{
					SetHardpointState( hardpoint, CAPTURE_POINT_STATE_AMPED )

					// can't use the dialogue functions here because for some reason GamemodeCP_VO_Amped isn't global?
					PlayFactionDialogueToTeam( "amphp_youAmped" + hardpointEnt.kv.hardpointGroup, cappingTeam )
					PlayFactionDialogueToTeam( "amphp_enemyAmped" + hardpointEnt.kv.hardpointGroup, GetOtherTeam( cappingTeam ) )
				}
			}
		}



		// scoring
		if ( hardpointEnt.GetTeam() != TEAM_UNASSIGNED && GetHardpointState( hardpoint ) >= CAPTURE_POINT_STATE_CAPTURED && currentTime - lastScoreTime >= TEAM_OWNED_SCORE_FREQ )
		{
			lastScoreTime = currentTime

			// 2x score if amped
			if ( GetHardpointState( hardpoint ) == CAPTURE_POINT_STATE_AMPED )
				AddTeamScore( hardpointEnt.GetTeam(), 2 )
			else if( GetHardpointState( hardpoint) >= CAPTURE_POINT_STATE_CAPTURED)
				AddTeamScore( hardpointEnt.GetTeam(), 1 )
		}

		lastTime = currentTime
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
				else
					imcChevron++
			}
			else if ( hardpoint.hardpoint.GetTeam() == TEAM_MILITIA )
			{
				if ( hardpoint.hardpoint.GetHardpointState() == CAPTURE_POINT_STATE_AMPED )
					militiaChevron += 4
				else
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