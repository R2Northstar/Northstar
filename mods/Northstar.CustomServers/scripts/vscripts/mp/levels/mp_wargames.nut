untyped

const POD_ATTACHPOINT  	= "REF"

const FX_LIGHT_ORANGE 	= "runway_light_orange"
const FX_LIGHT_GREEN 	= "runway_light_green"
const FX_POD_LASER 		= "P_pod_scan_laser_FP"
const FX_POD_GLOWLIGHT 	= "P_pod_door_glow_FP"
const FX_POD_SCREEN_IN	= "P_pod_screen_lasers_IN"
const FX_POD_SCREEN_OUT	= "P_pod_screen_lasers_OUT"
const FX_POD_DLIGHT_CONSOLE1 		= $"P_pod_Dlight_console1"
const FX_POD_DLIGHT_CONSOLE2 		= $"P_pod_Dlight_console2"
const FX_POD_DLIGHT_BACKLIGHT_SIDE 	= "P_pod_Dlight_backlight_side"
const FX_POD_DLIGHT_BACKLIGHT_TOP 	= "P_pod_Dlight_backlight_top"
const FX_TITAN_COCKPIT_LIGHT 		= "xo_cockpit_dlight"

struct TrainingPod_dLightMapping
{
	string scriptAlias
	asset fxName
	string attachName
	entity fxHandle
}

struct TrainingPod_LaserEmitter
{
	entity ent
	string attachName
	vector ogAng
	bool sweepDone = false
	entity fxHandle
}

struct TrainingPod_GlowLightRow
{
	array<string> fxSpotsL
	array<string> fxSpotsR
}

global function CodeCallback_MapInit
global function WargamesIntroStart

struct {
	entity militiaTrainingPod
	entity imcTrainingPod
	array< TrainingPod_dLightMapping >[2] podDLightMappings
	array< TrainingPod_LaserEmitter >[2] podLaserEmitters
	
	array< entity > playersWatchingIntro
	string currentPodAnim
	float currentPodAnimStartTime
} file

void function CodeCallback_MapInit()
{
	//FlagInit( "TrainingPodSetupDone" )
	//FlagInit( "IntroRunning" )
	//
	//FlagSet( "DogFights" )
	//FlagSet( "StratonFlybys" )
	//
	//ClassicMP_SetIntroLevelSetupFunc( Wargames_Intro_LevelSetupFunc )
	//ClassicMP_SetIntroPlayerSpawnFunc( Wargames_ClassicMPIntroSpawn )
	//ClassicMP_SetPrematchSpawnPlayersFunc( Wargames_PrematchSpawnPlayersFunc )
	//
	//AddCallback_GameStateEnter( eGameState.WaitingForPlayers, WargamesIntroStart )  // This starts the main intro control thread
	//AddCallback_GameStateEnter( eGameState.PickLoadout, Wargames_GameStateEnterFunc_PickLoadout )
	//AddCallback_GameStateEnter( eGameState.Prematch, Wargames_GameStateEnterFunc_PrematchCallback )
}

// setup

bool function Wargames_Intro_LevelSetupFunc()
{
	array< entity > militiaTrainingPods = GetEntArrayByName_Expensive( "training_pod" )
	Assert( militiaTrainingPods.len() == 1 )
	file.militiaTrainingPod = militiaTrainingPods[0]
	file.militiaTrainingPod.s.teamIdx <- TEAM_MILITIA

	array< entity > imcTrainingPods = GetEntArrayByName_Expensive( "training_pod_imc" )
	Assert( imcTrainingPods.len() == 1 )
	file.imcTrainingPod = imcTrainingPods[0]
	file.imcTrainingPod.s.teamIdx <- TEAM_IMC
	
	SetupTrainingPod( file.militiaTrainingPod )
	SetupTrainingPod( file.imcTrainingPod )
	
	FlagSet( "TrainingPodSetupDone" )
	return true
}

void function SetupTrainingPod( entity pod )
{
	pod.DisableHibernation()
	pod.s.glowLightFXHandles <- []
	pod.s.dLights <- []
	
	// FUN hack because can't assign struct => var
	int podStructIndex = pod.s.teamIdx == TEAM_MILITIA ? 0 : 1
	
	array< TrainingPod_dLightMapping > tempLightMappings
	
	TrainingPod_dLightMapping m1
	m1.scriptAlias = "console1"
	m1.fxName = FX_POD_DLIGHT_CONSOLE1
	m1.attachName = "light_console1"
	tempLightMappings.append( m1 )
	
	TrainingPod_dLightMapping m2
	m2.scriptAlias = "console2"
	m2.fxName = FX_POD_DLIGHT_CONSOLE2
	m2.attachName = "light_console2"
	tempLightMappings.append( m2 )
	
	file.podDLightMappings[ podStructIndex ] = tempLightMappings
		
	array< string > laserAttachNames = [ "fx_laser_L", "fx_laser_R" ]
	
	foreach ( string attachName in laserAttachNames )
	{
		entity emitterEnt = CreateScriptMover( pod.GetOrigin(), pod.GetAngles() )
		int attachID = pod.LookupAttachment( attachName )
		vector attachOrg = pod.GetAttachmentOrigin( attachID )
		vector attachAng = pod.GetAttachmentAngles( attachID )

		TrainingPod_LaserEmitter emitter
		emitter.ent 		= emitterEnt
		emitter.attachName 	= attachName
		emitter.ogAng 		= attachAng
				
		file.podLaserEmitters[ podStructIndex ].append( emitter )
	}
	
	// HACK we do this later as well to reset the emitter positions, so it's a separate function
	TrainingPod_SnapLaserEmittersToAttachPoints( pod )
}

void function TrainingPod_SnapLaserEmittersToAttachPoints( entity pod )
{
	foreach ( TrainingPod_LaserEmitter emitter in file.podLaserEmitters[ pod.s.teamIdx == TEAM_MILITIA ? 0 : 1 ] )
	{
		int attachID = pod.LookupAttachment( emitter.attachName )
		vector attachOrg = pod.GetAttachmentOrigin( attachID )
		vector attachAng = pod.GetAttachmentAngles( attachID )

		emitter.ent.ClearParent()
		emitter.ent.SetOrigin( attachOrg )  // HACK set this to ANYTHING  (even 0, 0, 0) and the position is correct, otherwise it's offset from the attachpoint when parented
		emitter.ent.SetParent( pod, emitter.attachName )
	}
}

// spawning/intro sequence

void function Wargames_ClassicMPIntroSpawn( entity player )
{
	Assert( !IsAlive( player ) )
	
	thread PlayerWatchPodIntro( player )
	// return true
}

void function Wargames_PrematchSpawnPlayersFunc( array< entity > players )
{

}

void function PlayerWatchPodIntro( entity player )
{
	player.EndSignal( "Disconnected" )
	player.EndSignal( "OnDeath" )

	int team = player.GetTeam()
	
	entity pod
	if ( team == TEAM_MILITIA )
		pod = file.militiaTrainingPod
	else
		pod = file.imcTrainingPod
		
	AddCinematicFlag( player, CE_FLAG_INTRO )
	file.playersWatchingIntro.append( player )
	
	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid( player ) )
			{			
				printt( "PlayerWatchPodIntro: clearing up player:", player )
				
				//ArrayRemove( file.playersWatchingIntro, player )
				file.playersWatchingIntro.remove( file.playersWatchingIntro.find( player ) )
				
				player.Anim_Stop()
				//player.ClearAnimViewEntity()
				//player.ClearParent()
				player.UnforceStand()
				player.EnableWeaponViewModel()
				player.kv.VisibilityFlags = 7  // All can see now that intro is over

				FadeOutSoundOnEntity( player, "Amb_Wargames_Pod_Ambience", 0.13 )

				// turns hud back on
				if ( HasCinematicFlag( player, CE_FLAG_INTRO ) )
					RemoveCinematicFlag( player, CE_FLAG_INTRO )
			}
		}
	)
	
	// FIRST SPAWN
	int attachID = pod.LookupAttachment( POD_ATTACHPOINT )
	vector podRefOrg = pod.GetAttachmentOrigin( attachID )
	vector podRefAng = pod.GetAttachmentAngles( attachID )
	player.SetOrigin( podRefOrg )
	player.SetAngles( podRefAng )
	player.RespawnPlayer( null )
	
	player.kv.VisibilityFlags = 1 // visible to player only, so others don't see his viewmodel during the anim
	player.DisableWeaponViewModel()
	player.ForceStand()
	
	EmitSoundOnEntityOnlyToPlayer( player, player, "Amb_Wargames_Pod_Ambience" )
	thread Intro_StartPlayerFirstPersonSequence( player )
	
	FlagWait( "IntroRunning" )
	player.UnfreezeControlsOnServer()
	
	// wait for intro to finish for OnThreadEnd cleanup
	FlagWaitClear( "IntroRunning" )
	printt( "PlayerWatchPodIntro: intro finished normally for player", player )
}

void function Intro_StartPlayerFirstPersonSequence( entity player )
{
	player.EndSignal( "Disconnected" )
	player.EndSignal( "OnDeath" )
	
	entity pod
	if ( player.GetTeam() == TEAM_MILITIA )
		pod = file.militiaTrainingPod
	else
		pod = file.imcTrainingPod
	
	FirstPersonSequenceStruct playerSequence
	playerSequence.blendTime = 0.0
	playerSequence.attachment = POD_ATTACHPOINT
	playerSequence.renderWithViewModels = true
	playerSequence.firstPersonAnimIdle = "ptpov_trainingpod_idle"
	
	//FirstPersonSequenceStruct podSequence
	//podSequence.blendTime 				= 0.25
	//podSequence.thirdPersonAnim 		= "trainingpod_doors_close"
	//podSequence.thirdPersonAnimIdle 	= "trainingpod_doors_close_idle"
	//podSequence.renderWithViewModels 	= true
	
	void functionref( entity ) viewconeFunc = null
	viewconeFunc = TrainingPod_ViewConeLock_SemiStrict
		
	// i don't get this whole animevent system tbh, might just skip it lol
	entity viewmodel = player.GetFirstPersonProxy()
	//if ( !HasAnimEvent( viewmodel, "PlaySound_SimPod_DoorShut" ) )
	//{
		printt( "adding anim event... this probably won't work", player )
		AddAnimEvent( viewmodel, "PlaySound_SimPod_DoorShut", PlaySound_SimPod_DoorShut )
		AddAnimEvent( viewmodel, "PlaySound_SimPod_DoorShut", PlaySound_SimPod_DoorShut )
		AddAnimEvent( viewmodel, "PlaySound_SimPod_DoorShut", PlaySound_SimPod_DoorShut )
		AddAnimEvent( viewmodel, "PlaySound_SimPod_DoorShut", PlaySound_SimPod_DoorShut )
		AddAnimEvent( viewmodel, "PlaySound_SimPod_DoorShut", PlaySound_SimPod_DoorShut )

		print( "this SHOULD have caused errors in console due to registering it multiple times but doesn't????" )
	//}
	
	if ( file.currentPodAnim == "closing" )
	{
		playerSequence.firstPersonAnim = "ptpov_trainingpod_doors_close"
	}
	
	// TODO: correct viewcone funcs and catchup stuff
		
	//thread FirstPersonSequence( podSequence, pod )
	thread FirstPersonSequence( playerSequence, player, pod )
	
	if ( viewconeFunc != null )
		viewconeFunc( player )
		
	FlagClear( "IntroRunning" )
}

void function Intro_StartPlayerFirstPersonSequenceForAll()
{
	foreach ( entity player in file.playersWatchingIntro )
		thread Intro_StartPlayerFirstPersonSequence( player )
}

void function TrainingPod_ViewConeLock_SemiStrict( entity player )
{
	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -10 )
	player.PlayerCone_SetMaxYaw( 10 )
	player.PlayerCone_SetMinPitch( -10 )
	player.PlayerCone_SetMaxPitch( 10 )
}

void function PlaySound_SimPod_DoorShut( entity playerFirstPersonProxy )
{
	print( "playing anim event!" )
	// never called lol

	entity player = playerFirstPersonProxy.GetOwner()
	if ( !IsValid( player ) )
		return

	EmitSoundOnEntityOnlyToPlayer( player, player, "NPE_Scr_SimPod_DoorShut" )
}

void function WargamesIntroStart()
{
	thread WargamesIntroStartThreaded()
}

void function WargamesIntroStartThreaded()
{
	FlagWait( "TrainingPodSetupDone" )
	
	// early connecting players start idling
	file.currentPodAnim = "idle"
	
	file.militiaTrainingPod.s.ambienceLoud <- "Wargames_Emit_MCOR_Intro_HighPass"
	file.militiaTrainingPod.s.ambienceQuiet <- "Wargames_Emit_MCOR_Intro_LowPass"
	
	file.imcTrainingPod.s.ambienceLoud <- "Wargames_Emit_IMC_Intro_HighPass"
	file.imcTrainingPod.s.ambienceQuiet <- "Wargames_Emit_IMC_Intro_LowPass"
	
	OnThreadEnd(
		function() : ()
		{
			
		}
	)
	
	// wait for prematch, after waiting for players
	WaittillGameStateOrHigher( eGameState.Prematch )
	
	EmitSoundOnEntity( file.militiaTrainingPod, "Wargames_Emit_MCOR_Intro_HighPass" )
	EmitSoundOnEntity( file.militiaTrainingPod, "Wargames_Emit_MCOR_Intro_LowPass" )
	
	EmitSoundOnEntity( file.imcTrainingPod, "Wargames_Emit_IMC_Intro_HighPass")
	EmitSoundOnEntity( file.imcTrainingPod, "Wargames_Emit_IMC_Intro_LowPass" )
	
	// todo: intro skits
	
	FlagSet( "IntroRunning" )
	float startTime = Time()
	
	file.currentPodAnimStartTime = Time()
	FirstPersonSequenceStruct podSequence
	podSequence.blendTime = 0.0
	podSequence.thirdPersonAnimIdle = "trainingpod_doors_open_idle"
	podSequence.renderWithViewModels = true
	
	// turn on top lights
	TrainingPod_TurnOnInteriorDLight( "console1", file.militiaTrainingPod )
	TrainingPod_TurnOnInteriorDLight( "console2", file.militiaTrainingPod )
	thread FirstPersonSequence( podSequence, file.militiaTrainingPod )

	TrainingPod_TurnOnInteriorDLight( "console1", file.imcTrainingPod )
	TrainingPod_TurnOnInteriorDLight( "console2", file.imcTrainingPod )
	thread FirstPersonSequence( podSequence, file.imcTrainingPod )
	
	//thread Intro_PlayersHearPodVO()
	
	Intro_StartPlayerFirstPersonSequenceForAll()
	wait 8
	
	file.currentPodAnim = "closing"
	file.currentPodAnimStartTime = Time()
	podSequence.blendTime = 0.0
	podSequence.thirdPersonAnim = "trainingpod_doors_close"
	podSequence.thirdPersonAnimIdle 	= "trainingpod_doors_close_idle"

	Intro_StartPlayerFirstPersonSequenceForAll()

	thread FirstPersonSequence( podSequence, file.militiaTrainingPod )
	waitthread FirstPersonSequence( podSequence, file.imcTrainingPod )

	file.currentPodAnim = "done"
	
	wait 4.5
	
	
	FlagClear( "IntroRunning" )
}

void function TrainingPod_TurnOnInteriorDLight( string alias, entity pod )
{
	int teamIdx = pod.s.teamIdx == TEAM_MILITIA ? 0 : 1
	foreach ( TrainingPod_dLightMapping mapping in file.podDLightMappings[ teamIdx ] )
	{
		if ( mapping.scriptAlias == alias )
		{
			PlayLoopFXOnEntity( mapping.fxName, pod, mapping.attachName )
			pod.s.dLights.append( mapping.fxName )
			break
		}
	}
}

void function Wargames_GameStateEnterFunc_PickLoadout()
{
	level.nv.minPickLoadOutTime = Time() + 0.5
}

void function Wargames_GameStateEnterFunc_PrematchCallback()
{

}