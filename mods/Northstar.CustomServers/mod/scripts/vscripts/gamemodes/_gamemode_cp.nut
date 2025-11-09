untyped

global function GamemodeCP_Init
global function RateSpawnpoints_CP

void function GamemodeCP_Init()
{
	Hardpoints_Init()

	ScoreEvent_SetupEarnMeterValuesForMixedModes()

	AddCallback_EntitiesDidLoad( EntitiesDidLoad_SpawnHardpoints )
	AddCallback_OnPlayerKilled( Hardpoints_OnPlayerKilled_UpdateMedals )

	ScoreEvent_SetEarnMeterValues("KillPilot", 0.1, 0.12)
	ScoreEvent_SetEarnMeterValues("KillTitan", 0, 0)
	ScoreEvent_SetEarnMeterValues("TitanKillTitan", 0, 0)
	ScoreEvent_SetEarnMeterValues("PilotBatteryStolen", 0, 35)
	ScoreEvent_SetEarnMeterValues("Headshot", 0, 0.02)
	ScoreEvent_SetEarnMeterValues("FirstStrike", 0, 0.05)

	ScoreEvent_SetEarnMeterValues("ControlPointCapture", 0.1, 0.1)
	ScoreEvent_SetEarnMeterValues("ControlPointHold", 0.02, 0.02)
	ScoreEvent_SetEarnMeterValues("ControlPointAmped", 0.2, 0.15)
	ScoreEvent_SetEarnMeterValues("ControlPointAmpedHold", 0.05, 0.05)

	ScoreEvent_SetEarnMeterValues("HardpointAssault", 0.10, 0.15)
	ScoreEvent_SetEarnMeterValues("HardpointDefense", 0.5, 0.10)
	ScoreEvent_SetEarnMeterValues("HardpointPerimeterDefense", 0.1, 0.12)
	ScoreEvent_SetEarnMeterValues("HardpointSiege", 0.1, 0.15)
	ScoreEvent_SetEarnMeterValues("HardpointSnipe", 0.1, 0.15)
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
		if ( hardpoint.GetTeam() == player.GetTeam() && GetGlobalNetFloat( "objective" + CapturePoint_GetGroup(hardpoint) + "Progress" ) >= 0.95 )
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

void function EntitiesDidLoad_SpawnHardpoints()
{
	foreach ( entity hp in GetEntArrayByClass_Expensive("info_hardpoint") )
	{
		if ( GameModeRemove( hp ) )
			continue

		HardpointState hpState
		hpState.group = CapturePoint_GetGroup( hp )
		hpState.ent = hp
		hpState.prop = CreatePropDynamic( hp.GetModelName(), hp.GetOrigin(), hp.GetAngles(), SOLID_VPHYSICS )
		hpState.trigger = GetEnt( expect string(hp.kv.triggerTarget) )
		CPstate.hardpoints.append( hpState )

		switch (hpState.group) {
			case "A":
				hp.SetHardpointID( 0 )
				break
			case "B":
				hp.SetHardpointID( 1 )
				break
			case "C":
				hp.SetHardpointID( 2 )
				break
			default:
				throw "unknown hardpoint group name"
		}

		SetTeam( hpState.ent, TEAM_UNASSIGNED )
		SetGlobalNetEnt( "objective" + hpState.group + "Ent", hpState.ent )
		
		hpState.trigger.SetEnterCallback( OnHardpointEnter )
		hpState.trigger.SetLeaveCallback( OnHardpointLeave )
		hpState.trigger.SetOwner( hp )

		hpState.ent.Minimap_SetCustomState( hpState.ent.GetHardpointID() + 1 )
		hpState.ent.Minimap_AlwaysShow( TEAM_MILITIA, null )
		hpState.ent.Minimap_AlwaysShow( TEAM_IMC, null )
		hpState.ent.Minimap_SetAlignUpright( true )

		hpState.ent.s.prop <- hpState.prop
		hpState.ent.s.state <- CAPTURE_POINT_STATE_UNASSIGNED
		hpState.ent.s.lastCappedBy <- TEAM_UNASSIGNED
		hpState.ent.s.wasJustCapping <- false


		HARDPOINTS.append( hpState.ent ) // for vo script
		hpState.ent.s.trigger <- hpState.trigger // also for vo script

		thread PlayAnim( hpState.prop, "mh_inactive_idle" )

		thread Hardpoint_Think( hpState )
	}

	thread TrackChevronStates()
}
