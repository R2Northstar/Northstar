untyped
global function CodeCallback_MapInit

struct {
	array<entity> marvinSpawners

	float introStartTime
	entity militiaPod
	entity imcPod
	
	vector militiaPodFXEyePos
	vector imcPodFXEyePos
} file

void function CodeCallback_MapInit()
{
	AddCallback_EntitiesDidLoad( AddEvacNodes )
	
	// dissolve effects
	AddDeathCallback( "player", WargamesDissolveDeadEntity )	
	AddDeathCallback( "npc_soldier", WargamesDissolveDeadEntity )
	AddDeathCallback( "npc_spectre", WargamesDissolveDeadEntity )
	AddDeathCallback( "npc_pilot_elite", WargamesDissolveDeadEntity )
	AddDeathCallback( "npc_marvin", WargamesDissolveDeadEntity )
	
	AddSpawnCallback( "info_spawnpoint_marvin", AddMarvinSpawner )
	AddCallback_GameStateEnter( eGameState.Prematch, SpawnMarvinsForRound )
	
	// currently disabled until finished: intro
	if ( !IsFFAGame() )
		ClassicMP_SetLevelIntro( WargamesIntroSetup, 20.0 )
}

void function AddEvacNodes()
{
	AddEvacNode( GetEnt( "evac_location1" ) )
	AddEvacNode( GetEnt( "evac_location2" ) )
	AddEvacNode( GetEnt( "evac_location3" ) )
	AddEvacNode( GetEnt( "evac_location4" ) )
	
	SetEvacSpaceNode( GetEnt( "end_spacenode" ) )
}	

// dissolve effects
void function WargamesDissolveDeadEntity( entity deadEnt, var damageInfo )
{
	if ( deadEnt.IsPlayer() || GamePlayingOrSuddenDeath() || GetGameState() == eGameState.Epilogue )
	{
		deadEnt.Dissolve( ENTITY_DISSOLVE_CHAR, < 0, 0, 0 >, 0 )
		EmitSoundAtPosition( TEAM_UNASSIGNED, deadEnt.GetOrigin(), "Object_Dissolve" )
		
		if ( deadEnt.IsPlayer() )
			thread EnsureWargamesDeathEffectIsClearedForPlayer( deadEnt )
	}
}

void function EnsureWargamesDeathEffectIsClearedForPlayer( entity player )
{
	// this is slightly shit but whatever lol
	player.EndSignal( "OnDestroy" )
	
	float startTime = Time()
	while ( player.kv.VisibilityFlags != "0" )
	{
		if ( Time() > startTime + 4.0 ) // if we wait too long, just ignore
			return
	
		WaitFrame() 
	}
	
	player.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
}

void function AddMarvinSpawner( entity spawn )
{
	file.marvinSpawners.append( spawn )
}

void function SpawnMarvinsForRound()
{
	foreach ( entity spawner in file.marvinSpawners )
	{
		entity marvin = CreateMarvin( TEAM_UNASSIGNED, spawner.GetOrigin(), spawner.GetAngles() )
		marvin.kv.health = 1
		marvin.kv.max_health = 1
		//marvin.kv.spawnflags = 516
		marvin.kv.contents = ( int( marvin.kv.contents ) | CONTENTS_NOGRAPPLE )
		DispatchSpawn( marvin )
		HideName( marvin )

		thread MarvinJobThink( marvin )
	}
}

// intro stuff: 
void function WargamesIntroSetup()
{
	PrecacheParticleSystem( FX_POD_SCREEN_IN )
	PrecacheParticleSystem( $"P_pod_scan_laser_FP" )
	PrecacheParticleSystem( $"P_pod_Dlight_console1" )
	PrecacheParticleSystem( $"P_pod_Dlight_console2" )
	PrecacheParticleSystem( $"P_pod_door_glow_FP" )
	
	PrecacheModel( $"models/titans/ogre/ogreposeopen.mdl" )

	file.militiaPod = GetEnt( "training_pod" )
	file.imcPod = GetEnt( "training_pod_imc" )

	AddCallback_OnClientConnected( WargamesIntro_AddPlayer )
	AddCallback_GameStateEnter( eGameState.Prematch, OnPrematchStart )
}

void function WargamesIntro_AddPlayer( entity player )
{
	if ( GetGameState() != eGameState.Prematch )
		return
	
	thread PlayerWatchesWargamesIntro( player )
}

void function OnPrematchStart()
{
	ClassicMP_OnIntroStarted()
	file.introStartTime = Time()
	
	// set up shared objects
	// this breaks glowlights, not sure why
	//file.imcPod.RenderWithViewModels( true )
	//file.militiaPod.RenderWithViewModels( true )
	
	PodFXLights( file.imcPod )
	PodFXLights( file.militiaPod )
	
	FirstPersonSequenceStruct openPodSequence
	openPodSequence.thirdPersonAnimIdle = "trainingpod_doors_open_idle"
	thread FirstPersonSequence( openPodSequence, file.imcPod )
	thread FirstPersonSequence( openPodSequence, file.militiaPod )
	
	// militia titans/marvins
	entity militiaOgre = CreatePropDynamic( $"models/titans/ogre/ogreposeopen.mdl", < -2060, 2856, -1412.5 >, < 0, 0, 0 > )
	
	entity militiaOgreMarvin1 = CreateMarvin( TEAM_UNASSIGNED, < -2113, 2911, -1412 >, < 0, 20, 0 > )
	DispatchSpawn( militiaOgreMarvin1 )
	thread PlayAnim( militiaOgreMarvin1, "mv_idle_weld" )
	
	entity militiaOgreMarvin2 = CreateMarvin( TEAM_UNASSIGNED, < -2040, 2788, -1412 >, < 0, 140, 0 > )
	DispatchSpawn( militiaOgreMarvin2 )
	thread PlayAnim( militiaOgreMarvin2, "mv_idle_weld" )
	
	entity militiaOgreMarvin3 = CreateMarvin( TEAM_UNASSIGNED, < -2116, 2868, -1458 >, < 0, 127, 0 > )
	DispatchSpawn( militiaOgreMarvin3 )
	thread PlayAnim( militiaOgreMarvin3, "mv_turret_repair_A_idle" )
	
	entity militiaIon = CreatePropDynamic( $"models/titans/medium/titan_medium_ajax.mdl", < -1809.98, 2790.39, -1409 >, < 0, 80, 0 > )
	thread PlayAnim( militiaIon, "at_titan_activation_wargames_intro" )
	militiaIon.Anim_SetInitialTime( 4.5 )

	entity militiaPilot = CreateElitePilot( TEAM_UNASSIGNED, < 0, 0, 0 >, < 0, 0, 0 > )
	DispatchSpawn( militiaPilot )
	militiaPilot.SetParent( militiaIon, "HIJACK" )
	militiaPilot.MarkAsNonMovingAttachment()
	militiaPilot.Anim_ScriptedPlay( "pt_titan_activation_pilot" )
	militiaPilot.Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion()
	
	entity militiaMarvinChillin = CreateMarvin( TEAM_UNASSIGNED, < -1786, 3060, -1412 >, < 0, -120, 0 > )
	DispatchSpawn( militiaMarvinChillin )
	thread PlayAnim( militiaMarvinChillin, "mv_idle_unarmed" )
	
	// imc grunts
	entity imcGrunt1 = CreatePropDynamic( $"models/humans/grunts/imc_grunt_rifle.mdl", < -2915, 2867, -1788 >, < 0, -137, 0 > )
	thread PlayAnim( imcGrunt1, "pt_console_idle" )
	
	entity imcGrunt2 = CreatePropDynamic( $"models/humans/grunts/imc_grunt_rifle.mdl", < -2870, 2746, -1786 >, < 0, -167, 0 > )
	thread PlayAnim( imcGrunt2, "pt_console_idle" )
	imcGrunt2.Anim_SetInitialTime( 2.0 )
	
	entity imcGrunt3 = CreatePropDynamic( $"models/humans/grunts/imc_grunt_rifle.mdl", < -3037, 2909, -1786 >, < 0, -60, 0 > )
	thread PlayAnim( imcGrunt3, "pt_console_idle" )
	imcGrunt3.Anim_SetInitialTime( 4.0 )
	
	entity imcGrunt4 = CreatePropDynamic( $"models/humans/grunts/imc_grunt_rifle.mdl", < -3281, 2941, -1790 >, < 0, 138, 0 > )
	thread PlayAnim( imcGrunt4, "pt_console_idle" )
	imcGrunt4.Anim_SetInitialTime( 6.0 )
	
	// launch players into intro
	foreach ( entity player in GetPlayerArray() )
	{
		if ( !IsPrivateMatchSpectator( player ) )
			thread PlayerWatchesWargamesIntro( player )
		else
			RespawnPrivateMatchSpectator( player )
	}
	
	// 7 seconds of nothing until we start the pod sequence
	wait 7.0
	
	FirstPersonSequenceStruct podCloseSequence
	podCloseSequence.thirdPersonAnim = "trainingpod_doors_close"
	podCloseSequence.thirdPersonAnimIdle = "trainingpod_doors_close_idle"
	thread FirstPersonSequence( podCloseSequence, file.imcPod )
	thread FirstPersonSequence( podCloseSequence, file.militiaPod )
	
	wait 7.0
	thread PodBootFXThread( file.imcPod )
	thread PodBootFXThread( file.militiaPod )
	
	wait 6.0
	ClassicMP_OnIntroFinished()
	
	// make sure we stop using viewmodels for these otherwise everyone can see them in the floor 24/7
	file.imcPod.RenderWithViewModels( false )
	file.militiaPod.RenderWithViewModels( false )
	
	//PodFXCleanup( file.imcPod )
	//PodFXCleanup( file.militiaPod )
	
	// cleanup intro objects
	militiaOgre.Destroy()
	militiaIon.Destroy()
	militiaPilot.Destroy()
	militiaOgreMarvin1.Destroy()
	militiaOgreMarvin2.Destroy()
	militiaOgreMarvin3.Destroy()
	militiaMarvinChillin.Destroy()
	
	imcGrunt1.Destroy()
	imcGrunt2.Destroy()
	imcGrunt3.Destroy()
	imcGrunt4.Destroy()
}

void function PlayerWatchesWargamesIntro( entity player )
{
	if ( IsAlive( player ) )
		player.Die()

	OnThreadEnd( function() : ( player )
	{
		if ( IsValid( player ) )
		{
			RemoveCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING )
			player.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
			ClearPlayerAnimViewEntity( player )
			player.EnableWeaponViewModel()
			DeployAndEnableWeapons(player)
			player.ClearParent()
			player.UnforceStand()
			player.MovementEnable()
			player.ClearInvulnerable()
			Remote_CallFunction_NonReplay( player, "ServerCallback_ClearFactionLeaderIntro" )
		}
	})
	
	// we need to wait a frame if we killed ourselves to spawn into this, so just easier to do it all the time to remove any weirdness
	WaitFrame()
	
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )
	
	int factionTeam = ConvertPlayerFactionToIMCOrMilitiaTeam( player )
	entity playerPod
	if ( factionTeam == TEAM_IMC )
		playerPod = file.imcPod
	else
		playerPod = file.militiaPod
	
	// setup player
	int podAttachId = playerPod.LookupAttachment( "REF" )
	player.SetOrigin( playerPod.GetAttachmentOrigin( podAttachId ) )
	player.SetAngles( playerPod.GetAttachmentAngles( podAttachId ) )
	player.RespawnPlayer( null )
	player.SetParent( playerPod, "REF" )
	player.ForceStand()
	
	if ( !HasAnimEvent( player.GetFirstPersonProxy(), "PlaySound_SimPod_DoorShut" ) )
		AddAnimEvent( player.GetFirstPersonProxy(), "PlaySound_SimPod_DoorShut", PlaySound_SimPod_DoorShut )
	
	AddCinematicFlag( player, CE_FLAG_CLASSIC_MP_SPAWNING )
	player.kv.VisibilityFlags = ENTITY_VISIBLE_TO_OWNER
	TrainingPod_ViewConeLock_PodClosed( player )
	player.DisableWeaponViewModel()
	HolsterAndDisableWeapons(player)
	player.MovementDisable()
	player.SetInvulnerable()
	
	if ( factionTeam == TEAM_MILITIA && GetFactionChoice( player ) == "faction_marvin" )
		Remote_CallFunction_NonReplay( player, "ServerCallback_SpawnMilitiaFactionLeaderForIntro", file.introStartTime, playerPod.GetEncodedEHandle() )
	else if ( factionTeam == TEAM_MILITIA )
		Remote_CallFunction_NonReplay( player, "ServerCallback_SpawnMilitiaFactionLeaderForIntro", file.introStartTime + 1.75, playerPod.GetEncodedEHandle() )
	else
		Remote_CallFunction_NonReplay( player, "ServerCallback_SpawnIMCFactionLeaderForIntro", file.introStartTime + 4.5, playerPod.GetEncodedEHandle() )
	
	// idle pod sequence
	FirstPersonSequenceStruct podIdleSequence
	podIdleSequence.firstPersonAnimIdle = "ptpov_trainingpod_idle"
	podIdleSequence.renderWithViewModels = true
	podIdleSequence.attachment = "REF"
	thread FirstPersonSequence( podIdleSequence, player, playerPod )
	
	ScreenFadeFromBlack( player, max( 0.0, ( file.introStartTime + 0.5 ) - Time() ), max( 0.0, ( file.introStartTime + 0.5 ) - Time() ) )
	
	// also get eye positions for fx here
	if ( file.imcPodFXEyePos == < 0, 0, 0 > && factionTeam == TEAM_IMC )
		file.imcPodFXEyePos = player.EyePosition()
	else if ( file.militiaPodFXEyePos == < 0, 0, 0 > && factionTeam == TEAM_MILITIA )
		file.militiaPodFXEyePos = player.EyePosition()
	
	// 7 seconds of nothing before we start the pod sequence
	wait ( file.introStartTime + 7.0 ) - Time()
	
	FirstPersonSequenceStruct podCloseSequence
	podCloseSequence.firstPersonAnim = "ptpov_trainingpod_doors_close"
	podCloseSequence.renderWithViewModels = true
	podCloseSequence.attachment = "REF"
	podCloseSequence.viewConeFunction = TrainingPod_ViewConeLock_SemiStrict
	podCloseSequence.setInitialTime = Time() - ( file.introStartTime + 7.0 )
	waitthread FirstPersonSequence( podCloseSequence, player, playerPod )
				
	// boot sequence
	EmitSoundOnEntityOnlyToPlayer( player, player, "NPE_Scr_SimPod_PowerUp" )
	TrainingPod_ViewConeLock_PodClosed( player )
	
	// 10 seconds of starting pod before we run effects and spawn players
	// note, this is cool because it waits for a specific time, so we can have a blocking call directly before it just fine
	wait ( file.introStartTime + 15.5 ) - Time()
	Remote_CallFunction_NonReplay( player, "ServerCallback_PlayPodTransitionScreenFX" )
	
	// need to wait no matter what the delay is here so fx will sync up
	wait 3.5
	
	entity spawnpoint = FindSpawnPoint( player, false, true )
	spawnpoint.s.lastUsedTime = Time()
	player.SetOrigin( spawnpoint.GetOrigin() )
	player.SetAngles( spawnpoint.GetAngles() )
	
	thread DelayedGamemodeAnnouncement( player )
}

void function DelayedGamemodeAnnouncement( entity player )
{
	wait 1.0
	TryGameModeAnnouncement( player )
}

void function PlaySound_SimPod_DoorShut( entity playerFirstPersonProxy  ) // stolen from sp_training
{
	entity player = playerFirstPersonProxy.GetOwner()
	if ( !IsValid( player ) )
		return

	EmitSoundOnEntityOnlyToPlayer( player, player, "NPE_Scr_SimPod_DoorShut" )
}

// intro viewcones
void function TrainingPod_ViewConeLock_PodOpen( entity player )
{
	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -25 )
	player.PlayerCone_SetMaxYaw( 25 )
	player.PlayerCone_SetMinPitch( -30 )
	player.PlayerCone_SetMaxPitch( 35 )
}

void function TrainingPod_ViewConeLock_PodClosed( entity player )
{
	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -25 )
	player.PlayerCone_SetMaxYaw( 25 )
	player.PlayerCone_SetMinPitch( -30 )
	player.PlayerCone_SetMaxPitch( 30 )
}

void function TrainingPod_ViewConeLock_SemiStrict( entity player )
{
	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -10 )
	player.PlayerCone_SetMaxYaw( 10 )
	player.PlayerCone_SetMinPitch( -10 )
	player.PlayerCone_SetMaxPitch( 10 )
}

// intro pod fx
// here be dragons etc hell code probably
void function PodFXLights( entity pod ) 
{
	// dlights
	pod.s.podLightFXHandles <- []
	pod.s.podLightFXHandles.append( PlayLoopFXOnEntity( $"P_pod_Dlight_console1", pod, "light_console1" ) )
	pod.s.podLightFXHandles.append( PlayLoopFXOnEntity( $"P_pod_Dlight_console2", pod, "light_console2" ) )
}

void function PodFXLasers( entity pod )
{
	entity leftEmitter = CreateScriptMover( pod.GetOrigin() )
	pod.s.leftLaserEmitter <- leftEmitter
	entity rightEmitter = CreateScriptMover( pod.GetOrigin() )
	pod.s.rightLaserEmitter <- rightEmitter
	
	thread PodFXLaserSweep( leftEmitter, pod, pod == file.imcPod ? file.imcPodFXEyePos : file.militiaPodFXEyePos, "fx_laser_L" )
	thread PodFXLaserSweep( rightEmitter, pod, pod == file.imcPod ? file.imcPodFXEyePos : file.militiaPodFXEyePos, "fx_laser_R" )
}

void function PodFXLaserSweep( entity emitter, entity pod, vector eyePos, string attachment )
{
	// setup emitter attachments
	emitter.SetOrigin( < 5, 5, 5 > )
	emitter.SetParent( pod, attachment )

	float sweepTime = RandomFloatRange( 2.9, 3.15 )
	
	vector centerAng = VectorToAngles( ( eyePos + < 0, 0, 7 > ) - emitter.GetOrigin() )
	vector topAng = centerAng + < -270, 0, 0 >
	vector bottomAng = centerAng + < -90, 0, 0 >
	
	emitter.s.fxHandle <- PlayLoopFXOnEntity( $"P_pod_scan_laser_FP", emitter )
	
	float finalCenterTime = sweepTime * 0.15
	float bigSweepTime = ( sweepTime - finalCenterTime ) / 2
	
	emitter.SetAbsAngles( topAng )
	emitter.NonPhysicsRotateTo( topAng, bigSweepTime, 0.0, bigSweepTime * 0.2 )
	wait bigSweepTime - 0.1
	
	emitter.NonPhysicsRotateTo( bottomAng, bigSweepTime, 0.0, bigSweepTime * 0.2 )
	wait bigSweepTime
	
	emitter.NonPhysicsRotateTo( centerAng, finalCenterTime, 0.0, finalCenterTime * 0.2 )
}

void function PodFXGlowLights( entity pod )
{
	// see sp_training:5533 (TrainingPod_GlowLightsArraySetup)	
	array< array< string > > glowLightGroups = [
		[ "fx_glow_L_door012", "fx_glow_R_door014" ],
		[ "fx_glow_L_door013", "fx_glow_R_door013" ],
		[ "fx_glow_L_door014", "fx_glow_R_door012" ],
		[ "fx_glow_L_door011", "fx_glow_R_door011" ],
		[ "fx_glow_L_door09", "fx_glow_R_door09" ],
		[ "fx_glow_L_door010", "fx_glow_R_door010" ],
		[ "fx_glow_L_door07", "fx_glow_R_door07" ],
		[ "fx_glow_L_door08", "fx_glow_R_door08" ],
		[ "fx_glow_L_door05", "fx_glow_R_door05" ],
		[ "fx_glow_L_door06", "fx_glow_R_door06" ],
		[ "fx_glow_L_door03", "fx_glow_R_door03" ],
		[ "fx_glow_L_door04", "fx_glow_R_door04" ],
		[ "fx_glow_L_door01", "fx_glow_R_door01" ],
		[ "fx_glow_L_door02", "fx_glow_R_door02" ]
	]
	
	pod.s.podGlowLightFXHandles <- []
	
	foreach ( array<string> group in glowLightGroups )
	{
		foreach ( string attachName in group )
			pod.s.podGlowLightFXHandles.append( PlayLoopFXOnEntity( $"P_pod_door_glow_FP", pod, attachName ) )
		
		wait 0.1
	}
}

void function PodBootFXThread( entity pod )
{
	PodFXGlowLights( pod )
	PodFXLasers( pod )
}

void function PodFXCleanup( entity pod )
{
	foreach ( entity handle in pod.s.podLightFXHandles )
	{
		if ( IsValid_ThisFrame( handle ) )
		{
			handle.SetStopType( "DestroyImmediately" )
			handle.ClearParent()
			handle.Destroy()
		}
	}
	
	pod.s.podLightFXHandles = []
	
	foreach ( entity handle in pod.s.podGlowLightFXHandles )
	{
		if ( IsValid_ThisFrame( handle ) )
		{
			handle.SetStopType( "DestroyImmediately" )
			handle.ClearParent()
			handle.Destroy()
		}
	}
	
	pod.s.podGlowLightFXHandles = []
	
	pod.s.leftLaserEmitter.s.fxHandle.SetStopType( "DestroyImmediately" )
	pod.s.leftLaserEmitter.s.fxHandle.ClearParent()
	pod.s.leftLaserEmitter.s.fxHandle.Destroy()
	pod.s.leftLaserEmitter.Destroy()
	
	pod.s.rightLaserEmitter.s.fxHandle.SetStopType( "DestroyImmediately" )
	pod.s.rightLaserEmitter.s.fxHandle.ClearParent()
	pod.s.rightLaserEmitter.s.fxHandle.Destroy()
	pod.s.rightLaserEmitter.Destroy()
}
