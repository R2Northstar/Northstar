untyped

global function CodeCallback_MapInit
global function TransitionSpoke1

const DUMMY_MODEL = $"models/Robots/stalker/robot_stalker.mdl"
const TIMEZONE_DAY = 0
const TIMEZONE_NIGHT = 1
const TIMEZONE_ALL = 2

const ANDERSON_MODEL = $"models/humans/heroes/mlt_hero_anderson.mdl"
const IMC_CORPSE_MODEL_CIV = $"models/levels_terrain/sp_timeshift/civilian_eng_v2_corpse_static_20.mdl"

//const FX_HUMAN_DOOR_OPEN = $"steam_leak_SM_CH_end"
const FX_ANDERSON_DEVICE_FX = $"P_timeshift_gauntlet_hld"
const FX_ARK_LAUNCH_GLOW = $"P_ts_core_hld_sm"
const FX_ARK_LAUNCH_IN_PLACE = $"P_ts_core_hld_sm_lock"

struct
{
	int elevatorDudesDead
	array <entity> elevatorAnimNodes
	array <entity> elevatorDoors

} file


/////////////////////////////////////////////////////////////////////////////////////////
//
//
//			TIMESHIFT SPOKE 2 - MAP INIT
//
//
/////////////////////////////////////////////////////////////////////////////////////////
void function CodeCallback_MapInit()
{
	ShSpTimeshiftSpoke2CommonInit()
	RegisterSignal( "AnimTimeshift" )
	RegisterSignal( "PlayerInsideCage" )
	RegisterSignal( "ReleaseLabRat")

	PrecacheModel( DUMMY_MODEL )
	PrecacheModel( ANDERSON_MODEL )
	PrecacheModel( IMC_CORPSE_MODEL_CIV )

	//PrecacheParticleSystem( FX_HUMAN_DOOR_OPEN )
	PrecacheParticleSystem( FX_ARK_LAUNCH_GLOW )
	PrecacheParticleSystem( FX_ARK_LAUNCH_IN_PLACE )
	PrecacheParticleSystem( FX_ANDERSON_DEVICE_FX )

	//PrecacheModel( LABRAT_MODEL )
	AddCallback_EntitiesDidLoad( EntitiesDidLoad )
	AddPlayerDidLoad( TimeShiftHub_PlayerDidLoad )
	AddSpawnCallback( "npc_soldier", OnSpawnedLevelNPC )
	AddSpawnCallback( "npc_prowler", OnSpawnedLevelNPC )
	AddSpawnCallback( "npc_spectre", OnSpawnedLevelNPC )
	AddSpawnCallback( "prop_dynamic", OnSpawnedPropDynamic )

	AddDeathCallback( "npc_prowler", OnDeathProwlerAcheivement )


	SPTimeshiftUtilityInit()

	//------------------
	// Flags
	//-----------------
	FlagInit( "SwappedToFrozenWorld" )
	FlagInit( "DoneWithFanDropSequence")
	FlagInit( "ProwlerAcheivementUnlocked" )
	FlagInit( "BrokeOutOfFanDropMusicLoop")
	FlagInit( "ProwlerAmbushTriggered" )
	FlagInit( "AndersomHologram2AboutToStart" )
	FlagInit( "AcheivementUnlockedLabProwler" )
	FlagInit( "ForceFlyerTakeoff" )
	FlagInit( "RingVistaSequenceComplete" )
	FlagInit( "AllProwlersSpawnedInHumanControlRoom" )
	FlagInit( "IntelRoom1Finished" )
	FlagInit( "LabRatAcheivementUnlocked" )
	FlagInit( "AllElevatorProwlersSpawned" )
	FlagInit( "player_back_in_amenities_lobby" )
	FlagInit( "StartAndersonHologram1" )
	FlagInit( "StartAndersonHologram2" )
	FlagInit( "StartAndersonHologram3" )
	FlagInit( "StartSphereRoomGunship" )
	FlagInit( "LabBravoEnemiesDead" )
	FlagInit( "human_bridge_soldiers_dead" )
	FlagInit( "CampusReturnConversationFinished" )
	FlagInit( "PlayerPickingUpDevice" )
	FlagInit( "HidePlayerWeaponsDuringShifts")
	FlagInit( "AllElevatorDudesDead" )
	FlagInit( "ElevatorDudesDead1" )
	FlagInit( "ElevatorDudesDead2" )
	FlagInit( "ElevatorDudesDead3" )
	FlagInit( "ElevatorDudesDead4" )
	FlagInit( "CinematicTimeshiftSequenceFinished")
	FlagInit( "retract_bridge_human_01" )
	FlagInit( "retract_bridge_control_panel_pressed" )
	FlagInit( "door_open_amenities_lobby_return_pristine" )
	FlagInit( "finishedHumanVistaSequence" )
	FlagInit( "spawnHumanBridgeEnemies" )
	FlagInit( "player_looking_at_reactor_window" )
	FlagInit( "open_door_lobby_main_overgrown" )
	FlagInit( "PlayerLookingTowardsElevators" )
	FlagInit( "ConcoursePanelHacked01" )
	FlagInit( "ConcoursePanelHacked02" )
	FlagInit( "PlayerPickedUpTimeshiftDevice" )
	FlagInit( "FirstSpectreDeployedLobbyReduxPristine" )
	FlagInit( "FirstSpectreDeployedLobbyReduxOvergrown" )
	FlagInit( "SeveralElevatorDudesDead" )
	FlagInit( "ShowMobilityGhostTurretFirepit" )
	FlagInit( "ShowMobilityGhostElevatorShaft" )
	FlagInit( "ShowMobilityGhostTurretFlank" )
	FlagInit( "ShowMobilityGhostHumanLillypad01" )
	FlagInit( "ShowMobilityGhostHumanLillypad02" )
	FlagInit( "ShowMobilityGhostHumanWallrunChain" )
	FlagInit( "ShowMobilityGhostPowertech" )

	//------------------
	// Start points
	//------------------
					//startPoint, 					mainFunc,							setupFunc							skipFunc
	AddStartPoint( "Timeshift Device", 				AA_TimeshiftDeviceThread,			TimeshiftDeviceStartPointSetup, 	TimeshiftDeviceSkipped )
	AddStartPoint( "WILDLIFE RESEARCH", 			AA_WildlifeResearchThread,			WildlifeResearchStartPointSetup, 	WildlifeResearchSkipped )
	AddStartPoint( "First Timeshift Fight", 		AA_FirstTimeshiftFightThread,		FirstTimeshiftFightStartPointSetup, FirstTimeshiftFightSkipped )
	AddStartPoint( "Elevator Fight", 				AA_ElevatorFightThread,				ElevatorFightStartPointSetup, 		ElevatorFightSkipped )
	AddStartPoint( "HUMAN RESEARCH", 				AA_ElevatorTopThread,				ElevatorTopStartPointSetup, 		ElevatorTopSkipped )
	AddStartPoint( "Sphere Room", 					AA_SphereRoomThread,				SphereRoomStartPointSetup, 			SphereRoomSkipped ) //checkpointIntelRoom2
	AddStartPoint( "Human Room", 					AA_HumanResearchThread,				HumanResearchStartPointSetup, 		HumanResearchSkipped )
	AddStartPoint( "CAMPUS RETURN", 				AA_CampusReturnThread,				CampusReturnStartPointSetup, 		CampusReturnSkipped )
	AddStartPoint( "Fan Drop", 						AA_FanDropThread,					FanDropStartPointSetup, 			FanDropSkipped )
	AddStartPoint( "Fan Drop End", 					AA_FanDropEndThread,				FanDropEndStartPointSetup, 			FanDropEndSkipped )

	AddMobilityGhost( $"anim_recording/timeshift_turret_firepit_overgrown.rpak", "ShowMobilityGhostTurretFirepit" )
	AddMobilityGhost( $"anim_recording/timeshift_elevator_shaft_overgrown.rpak", "ShowMobilityGhostElevatorShaft" )
	AddMobilityGhost( $"anim_recording/timeshift_elevator_shaft_pristine.rpak", "ShowMobilityGhostElevatorShaft" )
	AddMobilityGhost( $"anim_recording/timeshift_turret_flank_overgrown.rpak", "ShowMobilityGhostTurretFlank" )
	AddMobilityGhost( $"anim_recording/timeshift_lillypad01_overgrown.rpak", "ShowMobilityGhostHumanLillypad01" )
	AddMobilityGhost( $"anim_recording/timeshift_lillypad01_pristine.rpak", "ShowMobilityGhostHumanLillypad01" )
	AddMobilityGhost( $"anim_recording/timeshift_lillypad02_overgrown.rpak", "ShowMobilityGhostHumanLillypad02" )
	AddMobilityGhost( $"anim_recording/timeshift_lillypad02_pristine.rpak", "ShowMobilityGhostHumanLillypad02" )
	AddMobilityGhost( $"anim_recording/timeshift_wallchain_overgrown.rpak", "ShowMobilityGhostHumanWallrunChain" )
	AddMobilityGhost( $"anim_recording/timeshift_wallchain_pristine.rpak", "ShowMobilityGhostHumanWallrunChain" )
	AddMobilityGhost( $"anim_recording/timeshift_powertech_overgrown.rpak", "ShowMobilityGhostPowertech" )
	AddMobilityGhost( $"anim_recording/timeshift_powertech_pristine.rpak", "ShowMobilityGhostPowertech" )

}


/////////////////////////////////////////////////////////////////////////////////////////
void function EntitiesDidLoad()
{
	FlagSet( "retract_bridge_human_01" )

	HideStuff( "human_bridge_overgrown" )
	HideStuff( "elevator_doors_upper_overgrown" )
	HideStuff( "blocker_fandrop_pristine" )
	HideStuff( "blocker_fandrop_overgrown" )


	thread SkyboxStart()
	thread RingsThink()

	array <entity> elevatorAnimNodesLocal = GetEntArrayByScriptName( "node_elevator_anim" )
	Assert( elevatorAnimNodesLocal.len() == 4 )
	file.elevatorAnimNodes = elevatorAnimNodesLocal

	array <entity> elevatorDoorsLocal = GetEntArrayByScriptName( "elevator_door_exec_housing_access" )
	Assert( elevatorDoorsLocal.len() == 4 )
	file.elevatorDoors = elevatorDoorsLocal


	//navmesh sep to keep prowlers away from half-open elevators
	entity navmesh_blocker_elevator_overgrown = GetEntByScriptName( "navmesh_blocker_elevator_overgrown" )
	navmesh_blocker_elevator_overgrown.NotSolid() //ok if it's notsolid, will still disconnect the navmesh


	//CleanupEnts( "triggers_instadeath_humanroom" )
	//CleanupEnts( "triggers_quickdeath_humanroom" )
	//CleanupEnts( "trigger_quickdeath_checkpoint_humanroom" )

	thread AndersonSetup()

	// coop code: fuck with entities so we can prevent some weird flags
	//array< entity > doors = 
}

/////////////////////////////////////////////////////////////////////////////////////////
void function TimeShiftHub_PlayerDidLoad( entity player )
{
	/*
	This will run before any start points run.
	Useful for doing common	player-specific setup,
	saving you from having to put a common player
	setup function in each of your start points
	*/

	//---------------------
	// Timeshift thread
	//----------------------
	thread TimeshiftPlayerThink( player )


}


/////////////////////////////////////////////////////////////////////////////////////////
/*
████████╗██╗███╗   ███╗███████╗███████╗██╗  ██╗██╗███████╗████████╗        ██████╗ ███████╗██╗   ██╗██╗ ██████╗███████╗
╚══██╔══╝██║████╗ ████║██╔════╝██╔════╝██║  ██║██║██╔════╝╚══██╔══╝        ██╔══██╗██╔════╝██║   ██║██║██╔════╝██╔════╝
   ██║   ██║██╔████╔██║█████╗  ███████╗███████║██║█████╗     ██║           ██║  ██║█████╗  ██║   ██║██║██║     █████╗
   ██║   ██║██║╚██╔╝██║██╔══╝  ╚════██║██╔══██║██║██╔══╝     ██║           ██║  ██║██╔══╝  ╚██╗ ██╔╝██║██║     ██╔══╝
   ██║   ██║██║ ╚═╝ ██║███████╗███████║██║  ██║██║██║        ██║           ██████╔╝███████╗ ╚████╔╝ ██║╚██████╗███████╗
   ╚═╝   ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝           ╚═════╝ ╚══════╝  ╚═══╝  ╚═╝ ╚═════╝╚══════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/*
████████╗██╗███╗   ███╗███████╗███████╗██╗  ██╗██╗███████╗████████╗        ██████╗ ███████╗██╗   ██╗██╗ ██████╗███████╗
╚══██╔══╝██║████╗ ████║██╔════╝██╔════╝██║  ██║██║██╔════╝╚══██╔══╝        ██╔══██╗██╔════╝██║   ██║██║██╔════╝██╔════╝
   ██║   ██║██╔████╔██║█████╗  ███████╗███████║██║█████╗     ██║           ██║  ██║█████╗  ██║   ██║██║██║     █████╗
   ██║   ██║██║╚██╔╝██║██╔══╝  ╚════██║██╔══██║██║██╔══╝     ██║           ██║  ██║██╔══╝  ╚██╗ ██╔╝██║██║     ██╔══╝
   ██║   ██║██║ ╚═╝ ██║███████╗███████║██║  ██║██║██║        ██║           ██████╔╝███████╗ ╚████╔╝ ██║╚██████╗███████╗
   ╚═╝   ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝           ╚═════╝ ╚══════╝  ╚═══╝  ╚═╝ ╚═════╝╚══════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/*
████████╗██╗███╗   ███╗███████╗███████╗██╗  ██╗██╗███████╗████████╗        ██████╗ ███████╗██╗   ██╗██╗ ██████╗███████╗
╚══██╔══╝██║████╗ ████║██╔════╝██╔════╝██║  ██║██║██╔════╝╚══██╔══╝        ██╔══██╗██╔════╝██║   ██║██║██╔════╝██╔════╝
   ██║   ██║██╔████╔██║█████╗  ███████╗███████║██║█████╗     ██║           ██║  ██║█████╗  ██║   ██║██║██║     █████╗
   ██║   ██║██║╚██╔╝██║██╔══╝  ╚════██║██╔══██║██║██╔══╝     ██║           ██║  ██║██╔══╝  ╚██╗ ██╔╝██║██║     ██╔══╝
   ██║   ██║██║ ╚═╝ ██║███████╗███████║██║  ██║██║██║        ██║           ██████╔╝███████╗ ╚████╔╝ ██║╚██████╗███████╗
   ╚═╝   ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝           ╚═════╝ ╚══════╝  ╚═══╝  ╚═╝ ╚═════╝╚══════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/*
████████╗██╗███╗   ███╗███████╗███████╗██╗  ██╗██╗███████╗████████╗        ██████╗ ███████╗██╗   ██╗██╗ ██████╗███████╗
╚══██╔══╝██║████╗ ████║██╔════╝██╔════╝██║  ██║██║██╔════╝╚══██╔══╝        ██╔══██╗██╔════╝██║   ██║██║██╔════╝██╔════╝
   ██║   ██║██╔████╔██║█████╗  ███████╗███████║██║█████╗     ██║           ██║  ██║█████╗  ██║   ██║██║██║     █████╗
   ██║   ██║██║╚██╔╝██║██╔══╝  ╚════██║██╔══██║██║██╔══╝     ██║           ██║  ██║██╔══╝  ╚██╗ ██╔╝██║██║     ██╔══╝
   ██║   ██║██║ ╚═╝ ██║███████╗███████║██║  ██║██║██║        ██║           ██████╔╝███████╗ ╚████╔╝ ██║╚██████╗███████╗
   ╚═╝   ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝           ╚═════╝ ╚══════╝  ╚═══╝  ╚═╝ ╚═════╝╚══════╝
*/
/////////////////////////////////////////////////////////////////////////////////////////
void function TimeshiftDeviceStartPointSetup( entity player )
{
	TeleportPlayerToEnt( player, GetEntByScriptName( "checkpointTimeshiftDevice" ) )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function TimeshiftDeviceSkipped( entity player )
{
	FlagSet( "open_creature_door_start_pristine" )
	FlagSet( "PlayerPickedUpTimeshiftDevice" )
	GiveTimeshiftAbility( player )
	FlagClear( "open_skybridge_door_end_pristine" )
	FlagClear( "open_skybridge_door_end_overgrown" )
	FlagSet( "CinematicTimeshiftSequenceFinished")
}
/////////////////////////////////////////////////////////////////////////////////////////
void function AA_TimeshiftDeviceThread( entity player )
{
	InitBoyleAudioLogs()

	//FlagSet( "open_skybridge_door_end_overgrown" )
	//FlagSet( "open_creature_door_start_pristine" )
	//-----------------------------------------
	// Get timeshift device
	//-----------------------------------------
	wait 1

	thread MusicGetTimeshiftDevice( player )
	thread DialogueCreatureLabAnderson( player )

	thread PickupTimeShiftDevice( player )



	FlagWait( "PlayerPickedUpTimeshiftDevice" )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function MusicGetTimeshiftDevice( entity player )
{
	StopMusic()
	PlayMusic( "music_timeshift_15_gettemporaldevice" )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function DialogueCreatureLabAnderson( entity player )
{
	entity anderson = GetEntByScriptName( "anderson_other_half" )
	local attach_id = anderson.LookupAttachment( "L_HAND" )
	vector objectivePos = anderson.GetAttachmentOrigin( attach_id )

	TimeshiftSetObjectiveSilent( player, "#TIMESHIFT_OBJECTIVE_TAKE_TIME_DEVICE", objectivePos )

/*
██████╗ ██╗ █████╗ ██╗      ██████╗  ██████╗ ██╗   ██╗███████╗
██╔══██╗██║██╔══██╗██║     ██╔═══██╗██╔════╝ ██║   ██║██╔════╝
██║  ██║██║███████║██║     ██║   ██║██║  ███╗██║   ██║█████╗
██║  ██║██║██╔══██║██║     ██║   ██║██║   ██║██║   ██║██╔══╝
██████╔╝██║██║  ██║███████╗╚██████╔╝╚██████╔╝╚██████╔╝███████╗
╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝
*/

	wait 10

	if ( Flag( "PlayerPickingUpDevice" ) )
		return


	Objective_Remind()
	//timeshift device nags
	string nagAlias
	int nextNagNumber = 1


	while( !Flag( "PlayerPickingUpDevice") )
	{
		wait( RandomFloatRange( 35, 45 ) )

		if ( Flag( "PlayerPickingUpDevice" ) )
			break


		if ( nextNagNumber == 1 )
		{
			//BT	Well done, Pilot. You located the wrist mounted device. SRS intel suggests if equipped you can withstand and manipulate the temporal shifts.
			nagAlias = "diag_sp_wildlifeStudy_TS191_01_01_mcor_bt"
		}

		if ( nextNagNumber == 2 )
		{
			//BT	Pilot, recommend you equip the device.
			nagAlias = "diag_sp_wildlifeStudy_TS191_09_01_mcor_bt"
		}
		else if ( nextNagNumber == 3 )
		{
			//BT	The wrist mounted device may be useful. Recommend you equip the device.
			nagAlias = "diag_sp_wildlifeStudy_TS191_10_01_mcor_bt"
		}
		else if ( nextNagNumber == 4 )
		{
			//BT	Advisory: Pilot, I recommend you equip the wrist mounted device.
			nagAlias = "diag_sp_wildlifeStudy_TS191_11_01_mcor_bt"
		}

		waitthread PlayBTDialogue( nagAlias )

		if ( Flag( "PlayerPickingUpDevice" ) )
			break
		Objective_Remind()
		//Objective_Clear()
		//TimeshiftSetObjective( player, "#TIMESHIFT_OBJECTIVE_TAKE_TIME_DEVICE", objectivePos )
		nextNagNumber++
		if ( nextNagNumber > 4 )
			nextNagNumber = 1
	}
}

/////////////////////////////////////////////////////////////////////////////////////////
void function AndersonSetup()
{
	entity node = GetEntByScriptName( "org_get_device_sequence" )
	entity anderson = GetEntByScriptName( "anderson_other_half" )
	anderson.SetModel( ANDERSON_MODEL )
	thread PlayAnimTeleport( anderson, "pt_timeshift_device_equip_corpse_sequence_idle", node )

	entity AndersonDeviceFX = PlayLoopFXOnEntity( FX_ANDERSON_DEVICE_FX, anderson, "L_BACKHAND" )


	int bodyGroupIndex = anderson.FindBodyGroup( "watch" )
	anderson.SetBodygroup( bodyGroupIndex, 1 )

	bodyGroupIndex = anderson.FindBodyGroup( "watch_ts" )
	anderson.SetBodygroup( bodyGroupIndex, 1 )

	FlagWait( "PlayerPickingUpDevice")

	wait 1

	if ( IsValid( AndersonDeviceFX ) )
	{
		StopFX( AndersonDeviceFX )
		EntFireByHandle( AndersonDeviceFX, "Stop", "", 0, null, null )
		AndersonDeviceFX.Destroy()
	}

}


/////////////////////////////////////////////////////////////////////////////////////////
void function PickupTimeShiftDevice( entity player )
{
	entity node = GetEntByScriptName( "org_get_device_sequence" )
	entity anderson = GetEntByScriptName( "anderson_other_half" )

	wait 0.5

	local attach_id = anderson.LookupAttachment( "L_HAND" )
	vector origin = anderson.GetAttachmentOrigin( attach_id )
	vector angles = anderson.GetAttachmentAngles( attach_id )


	//entity useDummy = CreatePropDynamic( TempModel, origin, angles, 6 ) // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	entity useDummy = CreatePropDynamic( DUMMY_MODEL, origin, Vector( 0, 0, 0 ), 2 ) // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
	useDummy.SetOrigin( origin )

	useDummy.SetUsable()
	useDummy.Hide()
	useDummy.SetUsableByGroup( "pilot" )
	useDummy.SetUsePrompts( "#TIMESHIFT_HINT_TAKE_DEVICE" , "#TIMESHIFT_HINT_TAKE_DEVICE_PC" )

	local playerActivator
	while( true )
	{
		playerActivator = useDummy.WaitSignal( "OnPlayerUse" ).player
		if ( IsValid( playerActivator ) && playerActivator.IsPlayer() && !playerActivator.IsTitan() )
		{
			// set player to whoever actually picked up the device, not host
			expect entity( playerActivator )
			player = playerActivator
			break
		}
	}

	//Cooper: Sorry Anderson
	FlagSet( "PlayerPickingUpDevice" )

	Objective_Clear()
	delaythread ( 1 ) PlayDialogue( "diag_sp_extra_GB101_65_01_mcor_player", player )


	useDummy.UnsetUsable()
	useDummy.Destroy()

	player.DisableWeaponWithSlowHolster()
	player.SetInvulnerable()
	//player.FreezeControlsOnServer()
	player.ContextAction_SetBusy()

	FlagSet( "DoingCinematicTimeshift" )

	//----------------------------------
	// Player takes device off Anderson
	//------------------------------------
	entity mover = CreateOwnedScriptMover( node ) //need a mover for first person sequence

	FirstPersonSequenceStruct sequenceTakeDevice
	//sequenceTakeDevice.blendTime = 1
	sequenceTakeDevice.attachment = "ref"
	sequenceTakeDevice.firstPersonAnim = "ptpov_timeshift_device_equip_sequence"
	sequenceTakeDevice.thirdPersonAnim = "pt_timeshift_device_equip_sequence"
	sequenceTakeDevice.viewConeFunction = ViewConeTight

	thread PlayAndersonCorpseAnims( anderson, node )
	waitthread FirstPersonSequence( sequenceTakeDevice, player, mover )

	FlagSet( "PlayerPickedUpTimeshiftDevice" )
	//---------------------------
	// Player equips device
	//----------------------------
	player.ClearParent()
	mover.Destroy()
	entity mover2 = CreateOwnedScriptMover( node ) //need a mover for first person sequence

	FirstPersonSequenceStruct sequenceEquipDevice
	sequenceEquipDevice.blendTime = 0
	sequenceEquipDevice.attachment = "ref"
	sequenceEquipDevice.firstPersonAnim = "ptpov_timeshift_device_equip_sequence_02"
	sequenceEquipDevice.thirdPersonAnim = "pt_timeshift_device_equip_sequence_02"
	sequenceEquipDevice.viewConeFunction = ViewConeTight

	//WaitFrame()

	GiveTimeshiftAbility( player )
	thread TimeshiftSequenceShifts( player, mover2 )

	entity proxy = player.GetFirstPersonProxy()
	int bodyGroupIndex = proxy.FindBodyGroup( "glove_default" )
	proxy.SetBodygroup( bodyGroupIndex, 1 ) // 0 = show, 1 = hide

	int bodyGroupIndex2 = proxy.FindBodyGroup( "glove_animated" )
	proxy.SetBodygroup( bodyGroupIndex2, 1 ) // 0 = show, 1 = hide

	waitthread FirstPersonSequence( sequenceEquipDevice, player, mover2 )

	SetTimeshiftArmDeviceSkin( 1 )

	//player.UnfreezeControlsOnServer()
	player.ClearInvulnerable()
	player.Anim_Stop()
	player.ClearParent()
	ClearPlayerAnimViewEntity( player )
	if ( player.ContextAction_IsBusy() )
		player.ContextAction_ClearBusy()
	player.EnableWeaponWithSlowDeploy()

	FlagClear( "DoingCinematicTimeshift" )

	FlagSet( "CinematicTimeshiftSequenceFinished")


	proxy = player.GetFirstPersonProxy()
	if ( proxy == null )
		return

	bodyGroupIndex = proxy.FindBodyGroup( "glove_default" )
	proxy.SetBodygroup( bodyGroupIndex, 0 ) // 0 = show, 1 = hide

	//bodyGroupIndex2= proxy.FindBodyGroup( "glove_animated" )
	//proxy.SetBodygroup( bodyGroupIndex2, 1 ) // 0 = show, 1 = hide

}

void function PlayAndersonCorpseAnims( entity anderson, entity node )
{
	waitthread PlayAnim( anderson, "pt_timeshift_device_equip_corpse_sequence", node )

	//watch
	//int bodyGroupIndex = anderson.FindBodyGroup( "watch" )
	//anderson.SetBodygroup( bodyGroupIndex, 1 )

	int bodyGroupIndex = anderson.FindBodyGroup( "watch_ts" )
	anderson.SetBodygroup( bodyGroupIndex, 0 )

	thread PlayAnim( anderson, "pt_timeshift_device_equip_corpse_sequence_02", node )

}
void function TimeshiftSequenceShifts( entity player, entity node )
{
	player.EndSignal( "OnDeath" )
	entity proxy = player.GetFirstPersonProxy()
	vector nodeOrigin = node.GetOrigin()
	vector playerOrigin = player.GetOrigin()


	WaitSignal( proxy, "AnimTimeshift" )
	SwapTimelines( player, TIMEZONE_DAY )
	node.SetAbsOrigin( Vector( nodeOrigin.x, nodeOrigin.y, nodeOrigin.z + TIME_ZOFFSET ) )
	//player.SetAbsOrigin( Vector( playerOrigin.x, playerOrigin.y, playerOrigin.z + TIME_ZOFFSET ) )

	wait 0.1
	//EmitSoundOnEntity( player, "Pilot_PhaseShift_End_3P" )

	WaitSignal( proxy, "AnimTimeshift" )
	SwapTimelines( player, TIMEZONE_NIGHT )
	node.SetAbsOrigin( nodeOrigin )
	//player.SetAbsOrigin( playerOrigin )

}

/////////////////////////////////////////////////////////////////////////////////////////
/*
██╗    ██╗██╗██╗     ██████╗ ██╗     ██╗███████╗███████╗        ██████╗ ███████╗███████╗███████╗ █████╗ ██████╗  ██████╗██╗  ██╗
██║    ██║██║██║     ██╔══██╗██║     ██║██╔════╝██╔════╝        ██╔══██╗██╔════╝██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝██║  ██║
██║ █╗ ██║██║██║     ██║  ██║██║     ██║█████╗  █████╗          ██████╔╝█████╗  ███████╗█████╗  ███████║██████╔╝██║     ███████║
██║███╗██║██║██║     ██║  ██║██║     ██║██╔══╝  ██╔══╝          ██╔══██╗██╔══╝  ╚════██║██╔══╝  ██╔══██║██╔══██╗██║     ██╔══██║
╚███╔███╔╝██║███████╗██████╔╝███████╗██║██║     ███████╗        ██║  ██║███████╗███████║███████╗██║  ██║██║  ██║╚██████╗██║  ██║
 ╚══╝╚══╝ ╚═╝╚══════╝╚═════╝ ╚══════╝╚═╝╚═╝     ╚══════╝        ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝
 */
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
██╗    ██╗██╗██╗     ██████╗ ██╗     ██╗███████╗███████╗        ██████╗ ███████╗███████╗███████╗ █████╗ ██████╗  ██████╗██╗  ██╗
██║    ██║██║██║     ██╔══██╗██║     ██║██╔════╝██╔════╝        ██╔══██╗██╔════╝██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝██║  ██║
██║ █╗ ██║██║██║     ██║  ██║██║     ██║█████╗  █████╗          ██████╔╝█████╗  ███████╗█████╗  ███████║██████╔╝██║     ███████║
██║███╗██║██║██║     ██║  ██║██║     ██║██╔══╝  ██╔══╝          ██╔══██╗██╔══╝  ╚════██║██╔══╝  ██╔══██║██╔══██╗██║     ██╔══██║
╚███╔███╔╝██║███████╗██████╔╝███████╗██║██║     ███████╗        ██║  ██║███████╗███████║███████╗██║  ██║██║  ██║╚██████╗██║  ██║
 ╚══╝╚══╝ ╚═╝╚══════╝╚═════╝ ╚══════╝╚═╝╚═╝     ╚══════╝        ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝
 */
/////////////////////////////////////////////////////////////////////////////////////////
 /////////////////////////////////////////////////////////////////////////////////////////
/*
██╗    ██╗██╗██╗     ██████╗ ██╗     ██╗███████╗███████╗        ██████╗ ███████╗███████╗███████╗ █████╗ ██████╗  ██████╗██╗  ██╗
██║    ██║██║██║     ██╔══██╗██║     ██║██╔════╝██╔════╝        ██╔══██╗██╔════╝██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝██║  ██║
██║ █╗ ██║██║██║     ██║  ██║██║     ██║█████╗  █████╗          ██████╔╝█████╗  ███████╗█████╗  ███████║██████╔╝██║     ███████║
██║███╗██║██║██║     ██║  ██║██║     ██║██╔══╝  ██╔══╝          ██╔══██╗██╔══╝  ╚════██║██╔══╝  ██╔══██║██╔══██╗██║     ██╔══██║
╚███╔███╔╝██║███████╗██████╔╝███████╗██║██║     ███████╗        ██║  ██║███████╗███████║███████╗██║  ██║██║  ██║╚██████╗██║  ██║
 ╚══╝╚══╝ ╚═╝╚══════╝╚═════╝ ╚══════╝╚═╝╚═╝     ╚══════╝        ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝
 */
/////////////////////////////////////////////////////////////////////////////////////////
 /////////////////////////////////////////////////////////////////////////////////////////
/*
██╗    ██╗██╗██╗     ██████╗ ██╗     ██╗███████╗███████╗        ██████╗ ███████╗███████╗███████╗ █████╗ ██████╗  ██████╗██╗  ██╗
██║    ██║██║██║     ██╔══██╗██║     ██║██╔════╝██╔════╝        ██╔══██╗██╔════╝██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝██║  ██║
██║ █╗ ██║██║██║     ██║  ██║██║     ██║█████╗  █████╗          ██████╔╝█████╗  ███████╗█████╗  ███████║██████╔╝██║     ███████║
██║███╗██║██║██║     ██║  ██║██║     ██║██╔══╝  ██╔══╝          ██╔══██╗██╔══╝  ╚════██║██╔══╝  ██╔══██║██╔══██╗██║     ██╔══██║
╚███╔███╔╝██║███████╗██████╔╝███████╗██║██║     ███████╗        ██║  ██║███████╗███████║███████╗██║  ██║██║  ██║╚██████╗██║  ██║
 ╚══╝╚══╝ ╚═╝╚══════╝╚═════╝ ╚══════╝╚═╝╚═╝     ╚══════╝        ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝
 */
/////////////////////////////////////////////////////////////////////////////////////////
void function WildlifeResearchStartPointSetup( entity player )
{
	TeleportPlayerToEnt( player, GetEntByScriptName( "checkpointWildlifeResearch" ) )

}
/////////////////////////////////////////////////////////////////////////////////////////
void function WildlifeResearchSkipped( entity player )
{
	CleanupEnts( "flyer_lab" )
	CleanupEnts( "civilian_evac_firehall" )
	//thread MusicWildlifeResearch( player )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function AA_WildlifeResearchThread( entity player )
{
	FlagWait( "CinematicTimeshiftSequenceFinished")

	vector objectivePos = GetEntByScriptName( "obj_creature_labs_after_fire_hall" ).GetOrigin()
	TimeshiftSetObjectiveSilent( player, "#TIMESHIFT_OBJECTIVE_LAB_EXPLORE", objectivePos )

	Remote_CallFunction_NonReplay( player, "ServerCallback_PlayGloveGlow", TIMEZONE_NIGHT )

	CheckPoint_Forced()

	thread MusicWildlifeResearch( player )
	//CheckPoint()

	wait 1

	thread DisplayOnscreenHint( player, "timeshift_hint_default", 3.0 )

																	//failsafeFlagToStart			lookAtEnt = null
	thread QuickSkit( player, GetEntByScriptName( "node_evac_firehall01" ), "headed_into_fire_hall" )
	thread QuickSkit( player, GetEntByScriptName( "node_evac_firehall02" ), "headed_into_fire_hall" )
	thread QuickSkit( player, GetEntByScriptName( "node_creature_soldiers_surprised" ), "open_door_creature_labs_part2" )

	//-------------------------------------------------
	// Use timeshift to get past electricity
	//------------------------------------------------
	thread DialogueTimeShiftEquipped( player )
	thread DialogueCivilianEvacCreatureLabs( player )
	thread DialogueCreaturLabsIMC( player )

	thread TimeshiftHint( player, TIMEZONE_NIGHT, "player_entered_creature_lab", "timeshift_hint_default", GetEntByScriptName( "trig_player_near_first_ts_hazard" ) )


	FlagWait( "player_entered_creature_lab" )
	CleanupEnts( "civilian_walker_courtyard" )
	CleanupEnts( "civilian_actor_firehall01" )
	CleanupEnts( "civilian_actor_firehall02" )


	// remove this so we don't softlock other players lol
	//FlagClear( "open_creature_door_start_pristine" )

	objectivePos = GetEntByScriptName( "objective_spoke1_breadcrumb000" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )

	CheckPoint_Forced()

	thread TimeshiftHint( player, TIMEZONE_DAY, "player_past_creature_first_laser", "timeshift_hint_default", GetEntByScriptName( "trig_player_near_creature_hazard" ) )

	thread ObjectiveRemindUntilFlag( "player_past_creature_first_laser" )

	FlagWait( "player_past_creature_first_laser" )

	objectivePos = GetEntByScriptName( "objective_spoke1_breadcrumb00" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )

	thread TimeshiftHint( player, TIMEZONE_NIGHT, "player_past_creature_second_obstacle", "timeshift_hint_default", GetEntByScriptName( "trig_player_near_creature_hazard2" ) )

	CheckPoint_Forced()

																																	//lookAtEnt
	thread QuickSkit( player, GetEntByScriptName( "node_evac_creaturelabs_2dudes" ), "player_past_creature_second_obstacle" )
	thread QuickSkit( player, GetEntByScriptName( "node_evac_creaturelabs_bench2" ), "player_past_creature_second_obstacle" )

	thread ObjectiveRemindUntilFlag( "player_past_creature_second_obstacle" )

	FlagWait( "player_past_creature_second_obstacle" )


	thread TimeshiftHint( player, TIMEZONE_DAY, "player_entered_creature_fans", "timeshift_hint_default", GetEntByScriptName( "trig_player_near_creature_fan_hazard" ) )

	objectivePos = GetEntByScriptName( "objective_spoke1_breadcrumb00aa" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )


	//---------------------------------------
	// Get past laser door in pristine via fans
	//---------------------------------------

	thread ObjectiveRemindUntilFlag( "player_exited_creature_labs" )

	FlagWait( "player_entered_creature_fans" )

	CleanupEnts( "civilian_evac_firehall" )
	thread TimeshiftHint( player, TIMEZONE_NIGHT, "player_exited_creature_labs", "timeshift_hint_default", GetEntByScriptName( "trig_player_near_creature_fan_blockage" ) )

	FlagWait( "player_exited_creature_labs" )


}


/////////////////////////////////////////////////////////////////////////////////////////
void function MusicWildlifeResearch( entity player )
{
	if ( Flag( "entered_amenities_elevator_room" ) )
		return

	FlagEnd( "entered_amenities_elevator_room" )


	//waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )

	StopMusic()
	SetGlobalNetBool( "music14LoopPausable", false )
	PlayMusicThatCantBeStopped( "music_timeshift_14_pastloop" )


	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_NIGHT )
	//Until the elevator fight, whenever the player switches in the PRESENT - Play music_timeshift_16_explorepresent
	thread PlayMusicInTimezoneUntilFlag( "music_timeshift_16_explorepresent", TIMEZONE_NIGHT, "entered_amenities_elevator_room" )

}



/////////////////////////////////////////////////////////////////////////////////////////
void function OnDeathProwlerAcheivement( entity npc, var damageInfo )
{
	if ( Flag( "ProwlerAcheivementUnlocked" ) )
		return

	if ( Flag( "crossed_elevator_fire_chasm" ) )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( !IsValid ( attacker ) )
		return

	if ( !attacker.IsPlayer() )
		return

	entity player = attacker

	string classname = npc.GetClassName()

	if ( !npc.HasKey( "script_noteworthy") )
		return

	string scriptNoteworthy = expect string( npc.kv.script_noteworthy )

	if ( scriptNoteworthy != "prowler_acheivement" )
		return

	FlagSet( "ProwlerAcheivementUnlocked" )
	UnlockAchievement( player, achievements.TIMESHIFT_PROWLER )

}



/////////////////////////////////////////////////////////////////////////////////////////
void function DialogueTimeShiftEquipped( entity player )
{
	FlagWait( "player_entered_creature_lab" )

	wait 1

	//BT	Pilot Cooper, I have transferred some of my AI functions to the device, in order to permit communication across temporal shifts.
	thread PlayBTDialogue( "diag_sp_wildlifeStudy_TS191_12_01_mcor_bt" )

	FlagWait( "player_nearing_creature_fans" )

	array <entity> grunts
	entity gruntSpeaker
	int gruntLines = 6
	int gruntLinesPlayed = 0
	string gruntAlias

	while( true )
	{
 		if ( gruntLinesPlayed >= gruntLines )
 			break

		waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_NIGHT )
		waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )
 		gruntSpeaker = GetClosestGrunt( player, TIMEZONE_DAY )
 		if ( !IsValid( gruntSpeaker ) )
 			continue
 		if ( Distance( player.GetOrigin(), gruntSpeaker.GetOrigin() ) > 512 )
 			continue

 		switch( gruntLinesPlayed )
 		{
 			case 0:
 				//IMC Grunt 2 (Radio)	What the hell? He was just over there!
 				gruntAlias = "diag_sp_wildlifeStudy_TS191_17_01_imc_grunt2"
 				break
 			case 1:
 				//security3	(radio comms, agitated): Who has visual?
 				gruntAlias = "diag_sp_securityComs_TS104_01_01_imc_security3"
 				break
 			case 2:
 				//security1	(radio comms, agitated): Can't track him, he's bouncing all over the place.
 				gruntAlias = "diag_sp_securityComs_TS104_02_01_imc_security1"
 				break
  			case 3:
 				//security1	(radio comms, agitated): Someone give me a location on this guy!
 				gruntAlias = "diag_sp_securityComs_TS106_01_01_imc_security1"
 				break
 	  		case 4:
 				//security3	(radio comms, agitated): Where the hell did he go?
 				gruntAlias = "diag_sp_securityComs_TS106_03_01_imc_security3"
 				break
  	  		case 5:
 				//security2	(radio comms, agitated): Watch your back! Watch your back!
 				gruntAlias = "diag_sp_securityComs_TS106_02_01_imc_security2"
 				break
 		}

 		waitthread PlayTimeShiftDialogue( player, gruntSpeaker, gruntAlias )
 		gruntLinesPlayed++

 		//Don't do next line till you hit elevator fight
 		FlagWait( "crossed_elevator_fire_chasm" )

	}

}

/////////////////////////////////////////////////////////////////////////////////////////
void function DialogueCivilianEvacCreatureLabs( entity player )
{
	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )

	entity soundEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )

	//IMC Security 3 - PA	...ask that all non-combat personnel and research teams proceed directly to the nearest
	//Emergency Shelter access point due to a minor security breach. Please remain calm and contact the nearest automated security personnel for assistance.
	waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_wildlifeStudy_TS191_13_01_imc_security3" )

	wait 1

	soundEnt.Destroy()

}
/////////////////////////////////////////////////////////////////////////////////////////
void function DialogueCreaturLabsIMC( entity player )
{
	FlagWait( "player_past_creature_first_laser" )

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )

	entity soundEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )

	SetGlobalForcedDialogueOnly( true )

	//IMC Grunt 1 (Radio)	….last spotted him headed towards Wildlife research. Get the rest of the eggheads evacuated and set up a choke point.
	waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_wildlifeStudy_TS191_14_01_imc_grunt1" )

	SetGlobalForcedDialogueOnly( false )

	FlagWait( "player_past_creature_second_obstacle" )
	//IMC Base (Radio)	Additional laser meshes coming online. Let's box him in.
	waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_wildlifeStudy_TS191_15_01_imc_command" )

	FlagWait( "player_entered_creature_fans" )

	SetGlobalForcedDialogueOnly( true )

	//IMC Grunt 3 (Radio)	Control, we have initiated contact with the intruder but his movement is...erratic.
	waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_wildlifeStudy_TS191_18_01_imc_grunt3" )

	SetGlobalForcedDialogueOnly( false )

	soundEnt.Destroy()
}


void function CourtyardSoldiersThink( entity npc )
{
	if ( Flag( "player_entered_creature_lab") )
		return
	FlagEnd( "player_entered_creature_lab" )
	npc.EnableNPCFlag( NPC_IGNORE_ALL )
	npc.SetNoTarget( true )

	OnThreadEnd(
	function() : ( npc )
		{
			if ( IsValid( npc ) )
				npc.Destroy()
		}
	)

	WaitSignal( npc, "OnFinishedAssault" )

}

/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗██████╗ ███████╗████████╗    ████████╗██╗███╗   ███╗███████╗███████╗██╗  ██╗██╗███████╗████████╗    ███████╗██╗ ██████╗ ██╗  ██╗████████╗
██╔════╝██║██╔══██╗██╔════╝╚══██╔══╝    ╚══██╔══╝██║████╗ ████║██╔════╝██╔════╝██║  ██║██║██╔════╝╚══██╔══╝    ██╔════╝██║██╔════╝ ██║  ██║╚══██╔══╝
█████╗  ██║██████╔╝███████╗   ██║          ██║   ██║██╔████╔██║█████╗  ███████╗███████║██║█████╗     ██║       █████╗  ██║██║  ███╗███████║   ██║
██╔══╝  ██║██╔══██╗╚════██║   ██║          ██║   ██║██║╚██╔╝██║██╔══╝  ╚════██║██╔══██║██║██╔══╝     ██║       ██╔══╝  ██║██║   ██║██╔══██║   ██║
██║     ██║██║  ██║███████║   ██║          ██║   ██║██║ ╚═╝ ██║███████╗███████║██║  ██║██║██║        ██║       ██║     ██║╚██████╔╝██║  ██║   ██║
╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝          ╚═╝   ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝       ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗██████╗ ███████╗████████╗    ████████╗██╗███╗   ███╗███████╗███████╗██╗  ██╗██╗███████╗████████╗    ███████╗██╗ ██████╗ ██╗  ██╗████████╗
██╔════╝██║██╔══██╗██╔════╝╚══██╔══╝    ╚══██╔══╝██║████╗ ████║██╔════╝██╔════╝██║  ██║██║██╔════╝╚══██╔══╝    ██╔════╝██║██╔════╝ ██║  ██║╚══██╔══╝
█████╗  ██║██████╔╝███████╗   ██║          ██║   ██║██╔████╔██║█████╗  ███████╗███████║██║█████╗     ██║       █████╗  ██║██║  ███╗███████║   ██║
██╔══╝  ██║██╔══██╗╚════██║   ██║          ██║   ██║██║╚██╔╝██║██╔══╝  ╚════██║██╔══██║██║██╔══╝     ██║       ██╔══╝  ██║██║   ██║██╔══██║   ██║
██║     ██║██║  ██║███████║   ██║          ██║   ██║██║ ╚═╝ ██║███████╗███████║██║  ██║██║██║        ██║       ██║     ██║╚██████╔╝██║  ██║   ██║
╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝          ╚═╝   ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝       ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗██████╗ ███████╗████████╗    ████████╗██╗███╗   ███╗███████╗███████╗██╗  ██╗██╗███████╗████████╗    ███████╗██╗ ██████╗ ██╗  ██╗████████╗
██╔════╝██║██╔══██╗██╔════╝╚══██╔══╝    ╚══██╔══╝██║████╗ ████║██╔════╝██╔════╝██║  ██║██║██╔════╝╚══██╔══╝    ██╔════╝██║██╔════╝ ██║  ██║╚══██╔══╝
█████╗  ██║██████╔╝███████╗   ██║          ██║   ██║██╔████╔██║█████╗  ███████╗███████║██║█████╗     ██║       █████╗  ██║██║  ███╗███████║   ██║
██╔══╝  ██║██╔══██╗╚════██║   ██║          ██║   ██║██║╚██╔╝██║██╔══╝  ╚════██║██╔══██║██║██╔══╝     ██║       ██╔══╝  ██║██║   ██║██╔══██║   ██║
██║     ██║██║  ██║███████║   ██║          ██║   ██║██║ ╚═╝ ██║███████╗███████║██║  ██║██║██║        ██║       ██║     ██║╚██████╔╝██║  ██║   ██║
╚═╝     ╚═╝╚═╝  ╚═╝╚══════╝   ╚═╝          ╚═╝   ╚═╝╚═╝     ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝╚═╝        ╚═╝       ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////



/////////////////////////////////////////////////////////////////////////////////////////
void function FirstTimeshiftFightStartPointSetup( entity player )
{
	TeleportPlayerToEnt( player, GetEntByScriptName( "checkpointFirstTimeshiftFight" ) )
	vector objectivePos = GetEntByScriptName( "objective_amenities_elevator_fight" ).GetOrigin()
	TimeshiftSetObjectiveSilent( player, "#TIMESHIFT_OBJECTIVE_LAB_EXPLORE", objectivePos )

}
/////////////////////////////////////////////////////////////////////////////////////////
void function FirstTimeshiftFightSkipped( entity player )
{
	FlagClear( "ShowMobilityGhostTurretFirepit" )
	CleanupEnts( "flyer_lab" )
	CleanupEnts( "lab_prowlers" )
	thread LoudspeakerThread( player )

}
/////////////////////////////////////////////////////////////////////////////////////////
void function AA_FirstTimeshiftFightThread( entity player )
{
	FlagWait( "player_exited_creature_labs" )

	vector objectivePos = GetEntByScriptName( "objective_spoke1_breadcrumb01" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )


	thread LoudspeakerThread( player )
	FlagSet( "ShowMobilityGhostTurretFirepit" )

	CheckPoint()

	thread DialogueToElevatorFight( player )
	thread SecurityRoom( player )
	//-------------------------------
	// Hallway turret setup
	//-------------------------------

	array <entity> turrets = GetEntArrayByScriptName( "turrets_hallway_to_elevators" )
	foreach( turret in turrets )
	{
		//bool hasShield = true
		//thread HACK_DisableTurret( turret, hasShield )
		turret.SetDumbFireMode( true )
	}

	FlagWait( "open_door_elevator_fight_hallway_both" )

	CheckPoint()

	objectivePos = GetEntByScriptName( "objective_amenities_elevator_fight" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )

	//-------------------------------
	// Hallway turret flank
	//-------------------------------

	foreach( turret in turrets )
	{
		//bool hasShield = true
		//thread HACK_EnableTurret( turret )
	}

	FlagWait( "player_entered_turret_to_elevator_hallway" )

	FlagWait( "crossed_elevator_fire_chasm" )

	//FlagClear( "open_door_elevator_fight_hallway_both" )
	FlagClear( "ShowMobilityGhostTurretFirepit" )
	CleanupEnts( "flyer_lab" )
	CleanupEnts( "lab_prowlers" )

	FlagWait( "entered_amenities_elevator_room" )

}


void function CreatureSurprisedSoldiersThink( entity npc )
{
	npc.EndSignal( "OnDeath" )

	FlagWait( "player_past_creature_second_obstacle" )

	npc.Anim_Stop()
}

/////////////////////////////////////////////////////////////////////////////////////////
void function SecurityRoom( entity player )
{
	player.EndSignal( "OnDeath" )

	entity deadCivilian = CreatePropDynamic( IMC_CORPSE_MODEL_CIV, Vector( 3686, -3820, -764 ), Vector( 0, 29.0586, 0 ), 0 ) // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only

	deadCivilian.Hide()
	int shiftCount = 0
	int shiftRequirement = 88
	entity triggerOvergrown = GetEntByScriptName( "trigger_security_underground_overgrown" )
	entity triggerPristine = GetEntByScriptName( "trigger_security_underground_pristine" )

	while( true )
	{
		wait 0.1
		if ( shiftCount >= shiftRequirement )
			break
		FlagWait( "in_fire_pit" )

		if ( level.timeZone == TIMEZONE_DAY )
			waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_NIGHT )
		else
			waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )


		if ( ( triggerOvergrown.IsTouching( player ) ) || ( triggerPristine.IsTouching( player ) ) )
			shiftCount++
		else
			continue
	}

	FlagSet( "open_door_security_underground" )

	deadCivilian.Show()



}
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗     ███████╗██╗   ██╗ █████╗ ████████╗ ██████╗ ██████╗             ███████╗██╗ ██████╗ ██╗  ██╗████████╗
██╔════╝██║     ██╔════╝██║   ██║██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗            ██╔════╝██║██╔════╝ ██║  ██║╚══██╔══╝
█████╗  ██║     █████╗  ██║   ██║███████║   ██║   ██║   ██║██████╔╝            █████╗  ██║██║  ███╗███████║   ██║
██╔══╝  ██║     ██╔══╝  ╚██╗ ██╔╝██╔══██║   ██║   ██║   ██║██╔══██╗            ██╔══╝  ██║██║   ██║██╔══██║   ██║
███████╗███████╗███████╗ ╚████╔╝ ██║  ██║   ██║   ╚██████╔╝██║  ██║            ██║     ██║╚██████╔╝██║  ██║   ██║
╚══════╝╚══════╝╚══════╝  ╚═══╝  ╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝            ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗     ███████╗██╗   ██╗ █████╗ ████████╗ ██████╗ ██████╗             ███████╗██╗ ██████╗ ██╗  ██╗████████╗
██╔════╝██║     ██╔════╝██║   ██║██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗            ██╔════╝██║██╔════╝ ██║  ██║╚══██╔══╝
█████╗  ██║     █████╗  ██║   ██║███████║   ██║   ██║   ██║██████╔╝            █████╗  ██║██║  ███╗███████║   ██║
██╔══╝  ██║     ██╔══╝  ╚██╗ ██╔╝██╔══██║   ██║   ██║   ██║██╔══██╗            ██╔══╝  ██║██║   ██║██╔══██║   ██║
███████╗███████╗███████╗ ╚████╔╝ ██║  ██║   ██║   ╚██████╔╝██║  ██║            ██║     ██║╚██████╔╝██║  ██║   ██║
╚══════╝╚══════╝╚══════╝  ╚═══╝  ╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝            ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
 /////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗     ███████╗██╗   ██╗ █████╗ ████████╗ ██████╗ ██████╗             ███████╗██╗ ██████╗ ██╗  ██╗████████╗
██╔════╝██║     ██╔════╝██║   ██║██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗            ██╔════╝██║██╔════╝ ██║  ██║╚══██╔══╝
█████╗  ██║     █████╗  ██║   ██║███████║   ██║   ██║   ██║██████╔╝            █████╗  ██║██║  ███╗███████║   ██║
██╔══╝  ██║     ██╔══╝  ╚██╗ ██╔╝██╔══██║   ██║   ██║   ██║██╔══██╗            ██╔══╝  ██║██║   ██║██╔══██║   ██║
███████╗███████╗███████╗ ╚████╔╝ ██║  ██║   ██║   ╚██████╔╝██║  ██║            ██║     ██║╚██████╔╝██║  ██║   ██║
╚══════╝╚══════╝╚══════╝  ╚═══╝  ╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝            ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
 /////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗     ███████╗██╗   ██╗ █████╗ ████████╗ ██████╗ ██████╗             ███████╗██╗ ██████╗ ██╗  ██╗████████╗
██╔════╝██║     ██╔════╝██║   ██║██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗            ██╔════╝██║██╔════╝ ██║  ██║╚══██╔══╝
█████╗  ██║     █████╗  ██║   ██║███████║   ██║   ██║   ██║██████╔╝            █████╗  ██║██║  ███╗███████║   ██║
██╔══╝  ██║     ██╔══╝  ╚██╗ ██╔╝██╔══██║   ██║   ██║   ██║██╔══██╗            ██╔══╝  ██║██║   ██║██╔══██║   ██║
███████╗███████╗███████╗ ╚████╔╝ ██║  ██║   ██║   ╚██████╔╝██║  ██║            ██║     ██║╚██████╔╝██║  ██║   ██║
╚══════╝╚══════╝╚══════╝  ╚═══╝  ╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝            ╚═╝     ╚═╝ ╚═════╝ ╚═╝  ╚═╝   ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
void function ElevatorFightStartPointSetup( entity player )
{
	TeleportPlayerToEnt( player, GetEntByScriptName( "checkpointElevatorFight" ) )
	vector objectivePos = GetEntByScriptName( "objective_amenities_elevator_fight" ).GetOrigin()
	TimeshiftSetObjectiveSilent( player, "#TIMESHIFT_OBJECTIVE_LAB_EXPLORE", objectivePos )

}
/////////////////////////////////////////////////////////////////////////////////////////
void function ElevatorFightSkipped( entity player )
{
	FlagClear( "ShowMobilityGhostElevatorShaft" )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function AA_ElevatorFightThread( entity player )
{

	FlagWait( "entered_amenities_elevator_room" )

	thread DialogueElevatorRoom( player )

	FlagSet( "ShowMobilityGhostElevatorShaft" )

	thread MusicElevatorFight( player )

	//FlagClear( "open_door_elevator_fight_hallway_both" )

	CheckPoint()

	vector objectivePos = GetEntByScriptName( "objective_amenities_elevator" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )


	thread SetFlagWhenPlayerLookingAtEnt( player, "PlayerLookingTowardsElevators", GetEntByScriptName( "elevator_look_target"), GetEntByScriptName( "trigger_look_elevators" ) )

	array< entity > propSpawners = GetEntArrayByScriptNameInInstance( "spectre_door_spawner", "spectre_spawner_amenities_elevator_overgrown_upper_02" )
	float delayMin = 0.5
	float delayMax = 0.6
	int maxToSpawn = 1
	string flagToAbort = ""
	thread SpawnShowcaseGroupWhenInRange( player, propSpawners, maxToSpawn, flagToAbort, "", delayMin, delayMax )

	FlagWait( "time_shifted_to_elevator_room_past" )

	//-------------------------------
	// Elevator fight
	//-------------------------------
	thread OpenElevatorDoorsOvergrownThink()
	thread TurretEnemiesComeIntoElevatorRoom()
	FlagWait( "PlayerLookingTowardsElevators" )

	thread AllElevatorDudesDead()
	FlagSet( "DisplayTheDamageHint" )
	thread ElevatorObjectiveReminder( player )
	//-------------------------------
	// Token prowlers elevator room
	//-------------------------------
	int difficulty = GetSpDifficulty()
	if ( difficulty < DIFFICULTY_MASTER )
		maxToSpawn = 5 //max for this room is 10
	else
		maxToSpawn = 8 //max for this room is 10

	propSpawners = GetEntArrayByScriptName( "prowler_spawnvents_elevator_room" )
	delayMin = 3.5
	delayMax = 6
	maxToSpawn = 5 //max for this room is 10
	flagToAbort = "AllElevatorDudesDead"
	string flagToSetWhenAllAreSpawned = "AllElevatorProwlersSpawned"
	bool requiresLookAt = true
	thread SpawnShowcaseGroupWhenInRange( player, propSpawners, maxToSpawn, flagToAbort, flagToSetWhenAllAreSpawned, delayMin, delayMax, "", requiresLookAt )

	//------------------------------------------
	// Player figures out elevator time puzzle
	//-------------------------------------------
	FlagWait( "entered_amenities_elevator" )

	objectivePos = GetEntByScriptName( "objective_elevator_top" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )

	FlagClear( "DisplayTheDamageHint" )

	FlagWait( "at_elevatorshaft_top" )

	FlagClear( "ShowMobilityGhostElevatorShaft" )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function DialogueElevatorRoom( entity player )
{


/*
██████╗ ██╗ █████╗ ██╗      ██████╗  ██████╗ ██╗   ██╗███████╗
██╔══██╗██║██╔══██╗██║     ██╔═══██╗██╔════╝ ██║   ██║██╔════╝
██║  ██║██║███████║██║     ██║   ██║██║  ███╗██║   ██║█████╗
██║  ██║██║██╔══██║██║     ██║   ██║██║   ██║██║   ██║██╔══╝
██████╔╝██║██║  ██║███████╗╚██████╔╝╚██████╔╝╚██████╔╝███████╗
╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝
*/

	FlagWait( "entered_amenities_elevator" )

	entity soundEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )

	if( Flag( "exited_elevator_run") )
		return
	FlagEnd( "exited_elevator_run" )

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )


	if ( Flag( "AllElevatorDudesDead" ) )
	{

		//IMC Base (Radio)	Security, Beta 4, do you copy? Beta 4! What is your position?
		waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_wildlifeStudy_TS191_16_01_imc_command" )
	}
	else
	{
		//IMC Base (Radio)	Has the intruder been neutralized?
		waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_wildlifeStudy_TS191_22_01_imc_command" )

		//IMC Grunt 6 (Radio)	Standby, we can't get a lock on his position
		waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_wildlifeStudy_TS191_23_01_imc_grunt6" )
	}

}
/////////////////////////////////////////////////////////////////////////////////////////
void function HallwayTurretDudesThink( entity npc )
{
	npc.EndSignal( "OnDeath" )

	//Kill these guys if player has finished elevator fight
	FlagWait( "AllElevatorDudesDead" )

	array <entity> players = GetPlayerArray()
	if ( players.len() <= 0 )
		return
	entity player = players[ 0 ]
	thread DeleteNpcWhenOutOfSight( npc, player )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function ElevatorObjectiveReminder( entity player )
{
	if( Flag( "at_elevatorshaft_top") )
		return
	FlagEnd( "at_elevatorshaft_top" )

	FlagWait( "AllElevatorDudesDead" )

	wait 5

	while( true )
	{
		if ( level.timeZone == TIMEZONE_DAY )
			Objective_Remind()
		else if ( ( level.timeZone == TIMEZONE_NIGHT ) && ( !Flag( "enemies_inside_elevator_room_trigger_overgrown") ) )
			Objective_Remind()

		wait ( RandomFloatRange( 30, 40 ) )
	}

}
/////////////////////////////////////////////////////////////////////////////////////////
void function GruntElevatorThink( entity npc )
{
	if ( !IsValid( npc ) )
		return
	npc.EndSignal( "OnDeath" )

	npc.EnableNPCFlag( NPC_NO_MOVING_PLATFORM_DEATH )

	OnThreadEnd(
	function() : (  )
		{
			file.elevatorDudesDead++
			if ( file.elevatorDudesDead >= 4 )
				FlagSet( "SeveralElevatorDudesDead" )
		}
	)

	if ( npc.HasKey( "script_noteworthy") )
	{
		string anim = expect string( npc.kv.script_noteworthy )
		string animIdle = anim + "_idle"
		entity node = GetClosest( file.elevatorAnimNodes, npc.GetOrigin() )
		Assert( IsValid( node ) )
		thread PlayAnimTeleport( npc, animIdle, node )

		entity elevatorDoor = GetClosest( file.elevatorDoors, npc.GetOrigin() )
		Assert( IsValid( elevatorDoor ) )

		string flagToWaitFor = expect string( elevatorDoor.kv.script_flag )

		if ( !Flag( flagToWaitFor ) )
		{
			FlagWait( flagToWaitFor )
			//wait 0.5
		}

		thread PlayAnimTeleport( npc, anim, node )

	}

	WaitForever()
}
/////////////////////////////////////////////////////////////////////////////////////////
void function TurretEnemiesComeIntoElevatorRoom()
{
	/*
	entity goal_lobby_middle = GetEntByScriptName( "goal_lobby_middle" )
	array <entity> grunts = GetNPCArrayBySquad( "kfiejfff" )
	foreach( grunt in grunts )
	{
		if ( !IsAlive( grunt ) )
			continue
		grunt.AssaultPoint( goal_lobby_middle.GetOrigin() )
	}
	*/
}

/////////////////////////////////////////////////////////////////////////////////////////
void function OpenElevatorDoorsOvergrownThink()
{
	FlagWait( "AllElevatorDudesDead" )
	HideStuff( "doors_and_blockers_elevator_overgrown" )
	entity navmesh_blocker_elevator_overgrown = GetEntByScriptName( "navmesh_blocker_elevator_overgrown" )
	navmesh_blocker_elevator_overgrown.Hide()
	navmesh_blocker_elevator_overgrown.NotSolid()
	ToggleNPCPathsForEntity( navmesh_blocker_elevator_overgrown, true )


//ToggleNPCPathsForEntity( GetEntByScriptName( "navmesh_blocker_elevator_overgrown" ), true )

}
/////////////////////////////////////////////////////////////////////////////////////////
void function MusicElevatorFight( entity player )
{
	FlagWait( "entered_amenities_elevator_room" )

	wait 0.1

	StopMusic()
	PlayMusic( "music_timeshift_17_enterelevatorarea" )

	FlagWait( "elevator_open_d" )

	StopMusic()
	PlayMusic( "music_timeshift_18_startelevatorfight" )
	SetGlobalNetBool( "music14LoopPausable", true )

	if( Flag( "entered_amenities_elevator") )
		return

	FlagEnd( "entered_amenities_elevator" )


	//When you climb out of the roof of the elevator - Play music_timeshift_21b_climboutofelevator
	//also need to stop the old music_timeshift_14_pastloop - Just play music_timeshift_21c_pastloop_stop
	OnThreadEnd(
	function() : ( player )
		{
			StopMusic()
			PlayMusicThatCantBeStopped( "music_timeshift_21c_pastloop_stop" )
			if ( IsValid( player ) )
				StopSoundOnEntity( player, "music_timeshift_21_combatpresentdone" )
			PlayMusic( "music_timeshift_21b_climboutofelevator" )
			if ( IsValid( player ) )
			{
				StopSoundOnEntity( player, "music_timeshift_14_pastloop" )
				printl( "manually stopping music: music_timeshift_14_pastloop")
			}
			SetGlobalNetBool( "music14LoopPausable", false )
		}
	)





	//-----------------------------------------------------------------------------------------------
	// Don't start playing different time period-specific tracks till the player starts time traveling
	//-----------------------------------------------------------------------------------------------
	if ( level.timeZone == TIMEZONE_NIGHT )
		waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )
	else
		waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_NIGHT )


	while( true )
	{


		if ( level.timeZone == TIMEZONE_NIGHT )
		{
			//----------------------
			// Enemies still alive TIMEZONE_NIGHT
			//----------------------
			if ( ( Flag( "enemies_inside_elevator_room_trigger_overgrown") ) || ( !Flag( "AllElevatorProwlersSpawned" ) ) )
			{
				//During the combat, if the player switches to PRESENT - Play music_timeshift_20_combatpresent
				//StopMusic()
				StopMusicTrack( "music_timeshift_18_startelevatorfight" )
				PlayMusicThatCantBeStopped( "music_timeshift_20_combatpresent" )

				//While in TIMEZONE_DAY, check to see when all are dead, so we can stop combat music
				while( level.timeZone == TIMEZONE_NIGHT )
				{
					wait 0.1
					if ( ( !Flag( "enemies_inside_elevator_room_trigger_overgrown" ) )
						&& ( Flag( "AllElevatorProwlersSpawned" ) )
						)
						break
				}
			}

			//------------------------------------------------
			// If all enemies spawned and dead in TIMEZONE_NIGHT, play the "done" track
			//------------------------------------------------
			if ( ( !Flag( "enemies_inside_elevator_room_trigger_overgrown") ) && ( Flag( "AllElevatorProwlersSpawned" ) ) && ( level.timeZone == TIMEZONE_NIGHT ) )
			{
				//Each time the player switches to the PRESENT where there are no more enemies - Play music_timeshift_21_combatpresentdone
				//StopMusic()
				if ( IsValid( player ) )
					StopSoundOnEntity( player, "music_timeshift_21_combatpresentdone" )
				PlayMusicThatCantBeStopped( "music_timeshift_21_combatpresentdone" )
			}


			waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )
		}
		else //TIMEZONE_DAY
		{
			//----------------------
			// Enemies still alive TIMEZONE_DAY
			//----------------------
			if ( ( !Flag( "AllElevatorDudesDead" ) ) && ( level.timeZone == TIMEZONE_DAY ) )
			{
				//During the combat, if the player switches to PAST - Play music_timeshift_19_combatpast
				PlayMusic( "music_timeshift_19_combatpast" )

				//While in TIMEZONE_DAY, check to see when all are dead, so we can stop combat music
				while( level.timeZone == TIMEZONE_DAY )
				{
					wait 0.1
					if ( Flag( "AllElevatorDudesDead" ) )
						break
				}

			}

			//------------------------------------------------
			//If all enemies dead in TIMEZONE_DAY, play the "done" track
			//------------------------------------------------
			if ( ( Flag( "AllElevatorDudesDead" ) ) && ( level.timeZone == TIMEZONE_DAY ) )
			{
				//Each time the player switches to the PAST where there are no more enemies - Play music_timeshift_21a_combatpastdone
				//StopMusic()
				PlayMusic( "music_timeshift_21a_combatpastdone" )
			}

			waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_NIGHT )
		}
	}


}


/////////////////////////////////////////////////////////////////////////////////////////

void function DialogueToElevatorFight( entity player )
{
	player.EndSignal( "OnDeath" )

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )

	entity soundEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )

	FlagWait( "open_door_elevator_fight_hallway_both" )

	SetGlobalForcedDialogueOnly( true )

	//IMC Grunt 8 (Radio)	In position. Activating turrets at south-east corridor.
	waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_wildlifeStudy_TS191_26_01_imc_grunt8" )

	//IMC Base (Radio)	We have an intruder, heavily armed and dangerous. All units in the area proceed to the south-east elevator banks on level 4 to intercept.
	waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_wildlifeStudy_TS191_19_01_imc_command" )


	if ( !Flag( "entered_amenities_elevator_room" ) )
	{
		//IMC Grunt  4 (Radio)	Copy that, control!
		waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_wildlifeStudy_TS191_20_01_imc_grunt4" )

	}

	if ( !Flag( "entered_amenities_elevator_room" ) )
	{
		//IMC Grunt 5 (Radio)	On our way, control!
		thread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_wildlifeStudy_TS191_21_01_imc_grunt5" )

	}

	FlagWait( "SeveralElevatorDudesDead" )

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )

	soundEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )

	if ( Flag( "entered_amenities_elevator" ) || Flag( "AllElevatorDudesDead" ) )
	{
		SetGlobalForcedDialogueOnly( false )
		return
	}

	//IMC Base (Radio)	Sitrep on the unknown target.
	waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_wildlifeStudy_TS191_24_01_imc_command" )


	if ( Flag( "entered_amenities_elevator" ) || Flag( "AllElevatorDudesDead" ) )
	{
		SetGlobalForcedDialogueOnly( false )
		return
	}

	entity soldier = GetClosestGrunt( player, TIMEZONE_DAY, "grunts_elevator" )

	if ( IsValid( soldier ) )
	{
		//IMC Grunt 7 (Radio)	We're getting our asses kicked out here, that's the bloody SitRep!
		waitthread PlayTimeShiftDialogue( player, soldier, "diag_sp_wildlifeStudy_TS191_25_01_imc_grunt7" )
	}

	SetGlobalForcedDialogueOnly( false )

	soundEnt.Destroy()

}

void function AllElevatorDudesDead()
{
	FlagWaitAll( "ElevatorDudesDead1", "ElevatorDudesDead2", "ElevatorDudesDead3", "ElevatorDudesDead4" )
	FlagSet( "AllElevatorDudesDead" )
}
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗     ███████╗██╗   ██╗ █████╗ ████████╗ ██████╗ ██████╗             ████████╗ ██████╗ ██████╗
██╔════╝██║     ██╔════╝██║   ██║██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗            ╚══██╔══╝██╔═══██╗██╔══██╗
█████╗  ██║     █████╗  ██║   ██║███████║   ██║   ██║   ██║██████╔╝               ██║   ██║   ██║██████╔╝
██╔══╝  ██║     ██╔══╝  ╚██╗ ██╔╝██╔══██║   ██║   ██║   ██║██╔══██╗               ██║   ██║   ██║██╔═══╝
███████╗███████╗███████╗ ╚████╔╝ ██║  ██║   ██║   ╚██████╔╝██║  ██║               ██║   ╚██████╔╝██║
╚══════╝╚══════╝╚══════╝  ╚═══╝  ╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝               ╚═╝    ╚═════╝ ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗     ███████╗██╗   ██╗ █████╗ ████████╗ ██████╗ ██████╗             ████████╗ ██████╗ ██████╗
██╔════╝██║     ██╔════╝██║   ██║██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗            ╚══██╔══╝██╔═══██╗██╔══██╗
█████╗  ██║     █████╗  ██║   ██║███████║   ██║   ██║   ██║██████╔╝               ██║   ██║   ██║██████╔╝
██╔══╝  ██║     ██╔══╝  ╚██╗ ██╔╝██╔══██║   ██║   ██║   ██║██╔══██╗               ██║   ██║   ██║██╔═══╝
███████╗███████╗███████╗ ╚████╔╝ ██║  ██║   ██║   ╚██████╔╝██║  ██║               ██║   ╚██████╔╝██║
╚══════╝╚══════╝╚══════╝  ╚═══╝  ╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝               ╚═╝    ╚═════╝ ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗     ███████╗██╗   ██╗ █████╗ ████████╗ ██████╗ ██████╗             ████████╗ ██████╗ ██████╗
██╔════╝██║     ██╔════╝██║   ██║██╔══██╗╚══██╔══╝██╔═══██╗██╔══██╗            ╚══██╔══╝██╔═══██╗██╔══██╗
█████╗  ██║     █████╗  ██║   ██║███████║   ██║   ██║   ██║██████╔╝               ██║   ██║   ██║██████╔╝
██╔══╝  ██║     ██╔══╝  ╚██╗ ██╔╝██╔══██║   ██║   ██║   ██║██╔══██╗               ██║   ██║   ██║██╔═══╝
███████╗███████╗███████╗ ╚████╔╝ ██║  ██║   ██║   ╚██████╔╝██║  ██║               ██║   ╚██████╔╝██║
╚══════╝╚══════╝╚══════╝  ╚═══╝  ╚═╝  ╚═╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝               ╚═╝    ╚═════╝ ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////

void function ElevatorTopStartPointSetup( entity player )
{
	TeleportPlayerToEnt( player, GetEntByScriptName( "checkpointElevatorTop" ) )
	vector objectivePos = GetEntByScriptName( "objective_intel_data_panel01" ).GetOrigin()
	TimeshiftSetObjectiveSilent( player, "#TIMESHIFT_OBJECTIVE_LAB_EXPLORE", objectivePos )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function ElevatorTopSkipped( entity player )
{
	FlagSet( "LabBravoEnemiesDead" )
	FlagSet( "entered_hallways_to_human_research" )
	FlagSet( "open_door_elevator_top_lab" )
	FlagSet( "StartAndersonHologram1" )
	FlagClear( "open_door_lab_civilian_escape_01" )

}

/////////////////////////////////////////////////////////////////////////////////////////
void function AA_ElevatorTopThread( entity player )
{
	FlagWait( "at_elevatorshaft_top" )
	FlagClear( "open_door_elevator_top_lab" )
																	//failsafeFlagToStart
	thread QuickSkit( player, GetEntByScriptName( "node_holo1_evac" ), 	"exited_elevator_run" )

	thread LabSoldierA( player )

	FlagWait( "exited_elevator_run" )

	SetGlobalForcedDialogueOnly( true )

	thread MusicElevatorTop( player )
	thread DialogueLabAlphaEvac( player )
	thread DialogueLabAlpha( player )
	thread ProwlerGagLabAlpha( player )
	thread AndersonHologramSequence( player, "node_hologram_lab1", "StartAndersonHologram1" )
	thread AchievementAndersonsFirstLog( player )

	vector objectivePos = GetEntByScriptName( "objective_intel_data_panel01" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )

	CheckPoint()

	FlagWait( "open_door_elevator_top_lab" )

	CheckPoint()

	CleanupEnts( "grunts_elevator" )

	thread CleanupAI( player )

	ShowStuff( "elevator_doors_upper_overgrown" )

	wait 2

	SetGlobalForcedDialogueOnly( false )

	FlagClear( "open_door_lab_civilian_escape_01" )

	FlagWait( "AndersonHologram1Finished" )


	FlagSet( "IntelRoom1Finished" )

	if ( !Flag( "back_in_hall_after_anderson_first_log" ) )
		CheckPoint()

	objectivePos = GetEntByScriptName( "objective_sphere_room_breadcrumb01" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )

	thread ObjectiveRemindUntilFlag( "entered_hallways_to_human_research" )

	FlagWait( "entered_hallways_to_human_research" )

}

void function AchievementAndersonsFirstLog( entity player )
{
	FlagWait( "AndersonHologram1Playing" )
	UnlockAchievement( player, achievements.VIEW_LOG )
}


/////////////////////////////////////////////////////////////////////////////////////////

void function LabSoldierA( entity player )
{
	entity node = GetEntByScriptName( "node_sandtable_soldier_react" )
	Assert( IsValid( node ) )
	entity spawner = GetEntByScriptName( "labA_soldier" )
	Assert( IsValid( spawner ) )
	entity npc = spawner.SpawnEntity()
	DispatchSpawn( npc )
	Assert( IsValid( npc ) )

	npc.EndSignal( "OnDeath" )

	if( Flag( "open_door_elevator_top_lab") )
		return
	FlagEnd( "open_door_elevator_top_lab" )

	OnThreadEnd(
	function() : ( npc )
		{
			if ( IsValid( npc ) )
				npc.Destroy()
		}
	)

	npc.EnableNPCFlag( NPC_IGNORE_ALL )
	npc.SetNoTarget( true )
	thread PlayAnimTeleport( npc, "pt_cloak_react_app_far_point_timeshift_idle", node )

	FlagWait( "exited_elevator_run" )
	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )

	waitthread PlayAnim( npc, "pt_cloak_react_app_far_point_timeshift", node )
	npc.AssaultPoint( Vector( 4804.74, -3668.88, 11744 ) )

	WaitSignal( npc, "OnFinishedAssault" )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function MusicElevatorTop( entity player )
{
	FlagWait( "exited_elevator_run" )
	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )

	StopMusic()
	PlayMusicThatCantBeStopped( "music_timeshift_22_panicburst" )

	FlagWait( "StartAndersonHologram1" )

	StopMusic()
	PlayMusic( "music_timeshift_23_andersonlog02" )

	thread MusicHologram1Ambush()

	FlagWait( "AndersonHologram1Finished" )


	SetGlobalNetBool( "music14LoopPausable", false )
	PlayMusicThatCantBeStopped( "music_timeshift_14_pastloop" )
	//Following the ambush, when the player switches to the PRESENT - Play music_timeshift_16_explorepresent

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_NIGHT )
	thread PlayMusicInTimezoneUntilFlag( "music_timeshift_16_explorepresent", TIMEZONE_NIGHT, "StartAndersonHologram2" )


}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function MusicHologram1Ambush()
{
	//Ambush could happen in either past of present
	FlagWaitAny( "open_door_lab_reinforcements_pristine", "ProwlerAmbushTriggered" )

	//StopMusic()
	PlayMusicThatCantBeStopped( "music_timeshift_24_ambush" )
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function ProwlerGagLabAlpha( entity player )
{
	entity door = GetEntByScriptName( "door_prowler_lab_a" )
	entity spawner = GetEntByScriptName( "prowler_lab_a" )
	vector origin = door.GetOrigin()
	vector angles = door.GetAngles()

	entity prowler = spawner.SpawnEntity()
	DispatchSpawn( prowler )

	prowler.EnableNPCFlag( NPC_NO_MOVING_PLATFORM_DEATH )
	prowler.Hide()
	prowler.NotSolid()
	MakeInvincible( prowler )

	thread PlayAnimTeleport( prowler, "pr_timeshift_door_tease_01_idle", origin, angles )
	thread PlayAnimTeleport( door, "door_door_spawn_core_idle", origin, angles )

	string animDoor
	string animProwler

	FlagWait( "near_lab_alpha_prowler_skit" )

	if ( !Flag( "IntelRoom1Finished" ) )
	{
		prowler.Show()
		prowler.Solid()
		thread PlayAnimTeleport( door, "door_timeshift_prowler_tease_01", origin, angles )
		waitthread PlayAnimTeleport( prowler, "pr_timeshift_door_tease_01", origin, angles )
		prowler.Hide()
		prowler.NotSolid()
		thread PlayAnimTeleport( prowler, "pr_timeshift_door_tease_01_idle", origin, angles )
		thread PlayAnimTeleport( door, "door_door_spawn_core_idle", origin, angles )
		FlagWait( "AndersonHologram1Finished" )
		FlagWait( "near_lab_alpha_prowler_skit" )
	}

	FlagSet( "ProwlerAmbushTriggered" )
	prowler.Show()
	prowler.Solid()
	ClearInvincible( prowler )
	thread PlayAnimTeleport( prowler, "pr_timeshift_door_spawn_01", origin, angles )
	thread PlayAnimTeleport( door, "door_timeshift_prowler_spawn_01", origin, angles )
	DisableNavmeshSeperatorTargetedByEnt( door )
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function DialogueLabAlphaEvac( entity player )
{
	if( Flag( "open_door_elevator_top_lab") )
		return
	FlagEnd( "open_door_elevator_top_lab" )


	//entity panel_intel_room1 = GetEntByScriptName( "panel_intel_room1" )
	entity loudspeakerEnt1 = CreateLoudspeakerEnt( Vector( 5488,-3718, 11736 ) )
	entity loudspeakerEnt2 = CreateLoudspeakerEnt( Vector( 5488,-3718, 11736 ) )
	entity loudspeakerEnt3 = CreateLoudspeakerEnt( Vector( 5488,-3718, 11736 ) )


	OnThreadEnd(
	function() : ( loudspeakerEnt1, loudspeakerEnt2, loudspeakerEnt3 )
		{
			loudspeakerEnt1.Destroy()
			loudspeakerEnt2.Destroy()
			loudspeakerEnt3.Destroy()
		}
	)


/*
██████╗ ██╗ █████╗ ██╗      ██████╗  ██████╗ ██╗   ██╗███████╗
██╔══██╗██║██╔══██╗██║     ██╔═══██╗██╔════╝ ██║   ██║██╔════╝
██║  ██║██║███████║██║     ██║   ██║██║  ███╗██║   ██║█████╗
██║  ██║██║██╔══██║██║     ██║   ██║██║   ██║██║   ██║██╔══╝
██████╔╝██║██║  ██║███████╗╚██████╔╝╚██████╔╝╚██████╔╝███████╗
╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝
*/

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )

	//Scientist 1	What about the intruder?!
	//thread PlayTimeShiftDialogue( player, loudspeakerEnt1, "diag_sp_humanStudy_TS201_03_01_imc_scientist1" )

	wait 0.5

	//He's here!
	//thread PlayTimeShiftDialogue( player, loudspeakerEnt, "diag_sp_humanStudy_TS202_01_01_imc_scientist1" )


	//Grunt: Intruder spotted! Code 83!
	thread PlayTimeShiftDialogue( player, loudspeakerEnt2, "diag_sp_humanStudy_TS201_14_01_imc_security1" )

	wait 1.8

	//Scientist 2	We have to leave!
	thread PlayTimeShiftDialogue( player, loudspeakerEnt3, "diag_sp_humanStudy_TS201_04_01_imc_scientist2" )

	wait 1


	//General Marder	We're going forward with this. The test must be completed.
	waitthread PlayTimeShiftDialogue( player, player, "diag_sp_humanStudy_TS201_01_01_imc_genMarder" )


}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function DialogueLabAlpha( entity player )
{
	FlagWait( "open_door_elevator_top_lab" )

	wait 1



/*
██████╗ ██╗ █████╗ ██╗      ██████╗  ██████╗ ██╗   ██╗███████╗
██╔══██╗██║██╔══██╗██║     ██╔═══██╗██╔════╝ ██║   ██║██╔════╝
██║  ██║██║███████║██║     ██║   ██║██║  ███╗██║   ██║█████╗
██║  ██║██║██╔══██║██║     ██║   ██║██║   ██║██║   ██║██╔══╝
██████╔╝██║██║  ██║███████╗╚██████╔╝╚██████╔╝╚██████╔╝███████╗
╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝
*/

	FlagSet( "StartAndersonHologram1" )

	//BT	Pilot, a fragment of Anderson's damaged log may be relevant here. Activating log playback...
	waitthread PlayBTDialogue( "diag_sp_humanStudy_TS201_11_01_imc_bt" )



	FlagWaitAny( "AndersonHologram1Finished" )

	wait 0.5


	FlagWait( "entered_hallways_to_human_research" )
	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )
	if ( !Flag( "player_inside_intel_room2" ) )
	{
		entity soundEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )
		//General Marder	If we don't test the Sculptor Core now we may never have another chance. Zulu Team, prep the Sculptor Core for delivery.
		waitthread PlayTimeShiftDialogue( player, player, "diag_sp_humanStudy_TS201_02_01_imc_genMarder" )
	}

}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function LabAlphaScientistThink( entity npc )
{
	npc.EndSignal( "OnDeath" )
	thread DestroyNPCOnFlag( npc, "open_door_elevator_top_lab" )

	WaitSignal( npc, "OnFinishedAssault" )

	if ( IsValid( npc ) )
		npc.Destroy()

}


/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██████╗ ██╗  ██╗███████╗██████╗ ███████╗            ██████╗  ██████╗  ██████╗ ███╗   ███╗
██╔════╝██╔══██╗██║  ██║██╔════╝██╔══██╗██╔════╝            ██╔══██╗██╔═══██╗██╔═══██╗████╗ ████║
███████╗██████╔╝███████║█████╗  ██████╔╝█████╗              ██████╔╝██║   ██║██║   ██║██╔████╔██║
╚════██║██╔═══╝ ██╔══██║██╔══╝  ██╔══██╗██╔══╝              ██╔══██╗██║   ██║██║   ██║██║╚██╔╝██║
███████║██║     ██║  ██║███████╗██║  ██║███████╗            ██║  ██║╚██████╔╝╚██████╔╝██║ ╚═╝ ██║
╚══════╝╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝            ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝     ╚═╝
*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██████╗ ██╗  ██╗███████╗██████╗ ███████╗            ██████╗  ██████╗  ██████╗ ███╗   ███╗
██╔════╝██╔══██╗██║  ██║██╔════╝██╔══██╗██╔════╝            ██╔══██╗██╔═══██╗██╔═══██╗████╗ ████║
███████╗██████╔╝███████║█████╗  ██████╔╝█████╗              ██████╔╝██║   ██║██║   ██║██╔████╔██║
╚════██║██╔═══╝ ██╔══██║██╔══╝  ██╔══██╗██╔══╝              ██╔══██╗██║   ██║██║   ██║██║╚██╔╝██║
███████║██║     ██║  ██║███████╗██║  ██║███████╗            ██║  ██║╚██████╔╝╚██████╔╝██║ ╚═╝ ██║
╚══════╝╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝            ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝     ╚═╝
*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██████╗ ██╗  ██╗███████╗██████╗ ███████╗            ██████╗  ██████╗  ██████╗ ███╗   ███╗
██╔════╝██╔══██╗██║  ██║██╔════╝██╔══██╗██╔════╝            ██╔══██╗██╔═══██╗██╔═══██╗████╗ ████║
███████╗██████╔╝███████║█████╗  ██████╔╝█████╗              ██████╔╝██║   ██║██║   ██║██╔████╔██║
╚════██║██╔═══╝ ██╔══██║██╔══╝  ██╔══██╗██╔══╝              ██╔══██╗██║   ██║██║   ██║██║╚██╔╝██║
███████║██║     ██║  ██║███████╗██║  ██║███████╗            ██║  ██║╚██████╔╝╚██████╔╝██║ ╚═╝ ██║
╚══════╝╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝  ╚═╝╚══════╝            ╚═╝  ╚═╝ ╚═════╝  ╚═════╝ ╚═╝     ╚═╝
*/
/////////////////////////////////////////////////////////////////////////////////////////

void function SphereRoomStartPointSetup( entity player )
{
	TeleportPlayerToEnt( player, GetEntByScriptName( "checkpointIntelRoom2" ) )
	vector 	objectivePos = GetEntByScriptName( "objective_intel_data_panel02" ).GetOrigin()
	TimeshiftSetObjectiveSilent( player, "#TIMESHIFT_OBJECTIVE_LAB_EXPLORE", objectivePos )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function SphereRoomSkipped( entity player )
{
	FlagSet( "RingsShouldBeSpinning" )
	FlagSet( "player_inside_intel_room2" )
	//thread HumanPodsThink( "biodoors_terminal01_pristine", "biodoors_terminal01_overgrown", player )
	//thread HumanPodsThinkNoHack( "biodoors_terminal01_pristine", "biodoors_terminal02_overgrown", player )
	//thread HumanPodsThinkNoHack( "biodoors_terminal02_pristine", "biodoors_terminal02_overgrown", player )

	FlagClear( "ShowMobilityGhostTurretFlank" )
	thread QuickSkit( player, GetEntByScriptName( "node_reactor_flyers" ) )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function AA_SphereRoomThread( entity player )
{
	FlagWait( "entered_hallways_to_human_research" )

	FlagSet( "ShowMobilityGhostTurretFlank" )

	thread MusicSphereRoom( player )
	thread DialogueLabBravo( player )
	thread DialogueHumanAnteroom( player )
	thread DialogueGunshipDeploys( player )
	thread GunshipPadSequenceWait( player )
	thread GunshipSequence( "gunship_pad",  player, "node_gunship_intel_room_2", "pad", "StartSphereRoomGunship" )
	thread AndersonHologramSequence( player, "node_hologram_lab2", "StartAndersonHologram2" )

	CheckPoint()

	FlagWait( "dropped_into_fire_hallways" )
	vector objectivePos = GetEntByScriptName( "objective_intel_data_panel02" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )

	FlagWait( "player_inside_intel_room2" )

	thread TurretNotargetHack( player )
	FlagWait( "AndersonHologram2Finished" )
	CheckPoint()
	FlagSet( "open_door_diorama2_exit_pristine" )
	FlagSet( "open_door_diorama2_exit_overgrown" )

	thread CheckpointSphereRoomOvergrown( player )
	thread CheckpointSphereRoomPristine( player )

	objectivePos = GetEntByScriptName( "objective_human_research_breadcrumb_01a" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )

	thread ObjectiveRemindUntilFlag( "exited_intel_room2" )

	FlagWait( "exited_intel_room2" )

	objectivePos = GetEntByScriptName( "objective_human_research_breadcrumb_02" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )

	FlagWait( "entering_human_hallway_room" )

	//thread HumanPodsThink( "biodoors_terminal01_pristine", "biodoors_terminal01_overgrown", player )
	//thread HumanPodsThinkNoHack( "biodoors_terminal01_pristine", "biodoors_terminal02_overgrown", player )
	//thread HumanPodsThinkNoHack( "biodoors_terminal02_pristine", "biodoors_terminal02_overgrown", player )

	//-------------------------------
	// Token stalkers
	//-------------------------------
	array< entity > propSpawners = GetEntArrayByScriptName( "stalker_spawnvents_human_hallway_room" )
	float delayMin = 1.3
	float delayMax = 3
	int maxToSpawn = 3
	string flagToAbort = "entering_human_main_room"
	string flagToSetWhenAllAreSpawned = ""
	bool requiresLookAt = false
	thread SpawnShowcaseGroupWhenInRange( player, propSpawners, maxToSpawn, flagToAbort, flagToSetWhenAllAreSpawned, delayMin, delayMax, "", requiresLookAt )

	FlagWait( "past_human_hall_turrets" )
	thread QuickSkit( player, GetEntByScriptName( "node_reactor_flyers" ) )
	CheckPoint()

	FlagClear( "ShowMobilityGhostTurretFlank" )


	FlagWait( "entering_human_anteroom" )

	//entity rings_pristine = GetEntByScriptName( "rings_pristine" )

	//Spawn a sound dummy model to attach the sound to since doing it on an info_target
	//or "AtPosition" is unreliable with Timeshift teleports (can get culled)
	entity lookEnt = GetEntByScriptName( "lookent_rings" )
	EmitSoundAtPosition( TEAM_UNASSIGNED, lookEnt.GetOrigin(), "timeshift_scr_rings_spin_slow_lp" )

	FlagSet( "RingsShouldBeSpinning" )

	CheckPoint()


	objectivePos = GetEntByScriptName( "objective_human_research_main_door" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )

	FlagWait( "entering_human_main_room" )

}






void function GruntsSphereRoomThink( entity npc )
{
	//TODO: make these guys constanly get the player as an enemy
	if ( !IsValid( npc ) )
		return

	npc.EndSignal( "OnDeath" )

	while( true )
	{
		AttackPlayer( npc )
		wait RandomFloatRange( 2, 5 )
	}



}
void function CheckpointSphereRoomOvergrown( entity player )
{
	FlagEnd( "entering_human_anteroom" )
	FlagWait( "sphere_room_stalkers_dead" )
	CheckPoint()
}

void function CheckpointSphereRoomPristine( entity player )
{
	FlagEnd( "entering_human_anteroom" )
	FlagWait( "sphere_room_pristine_enemies_dead" )
	CheckPoint()
}

void function DialogueHumanAnteroom( entity player )
{
	FlagWait( "entering_human_anteroom" )

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )

	entity soundEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )

	//General Marder - Radio	Spin up the outer rings. Test sequence will commence once Sculptor Core is in place.
	thread PlayTimeShiftDialogue( player, player, "diag_sp_miniSculptor_TS221_02_01_imc_genMarder" )


}

void function TurretNotargetHack( entity player )
{
	if( Flag( "entering_human_main_room") )
		return
	FlagEnd( "entering_human_main_room" )
	OnThreadEnd(
	function() : ( player )
		{
			if ( IsValid( player ) )
				player.SetNoTarget( false )
		}
	)
	while( true )
	{
		FlagWait( "player_no_target" )
		player.SetNoTarget( true )
		FlagWaitClear( "player_no_target" )
		player.SetNoTarget( false )
	}

}

/////////////////////////////////////////////////////////////////////////////////////////
void function MusicSphereRoom( entity player )
{
	FlagWait( "StartAndersonHologram2" )

	//FlagWait( "AndersonHologram2Playing" )

	// When the third Anderson log starts - Play music_timeshift_25_andersonlog03
	// At the same time - Play music_timeshift_21c_pastloop_stop
	StopMusic()
	PlayMusic( "music_timeshift_25_andersonlog03" )

	if ( IsValid( player ) )
	{
		StopSoundOnEntity( player, "music_timeshift_14_pastloop" )
		printl( "manually stopping music: music_timeshift_14_pastloop")
	}

	PlayMusicThatCantBeStopped( "music_timeshift_21c_pastloop_stop" )

	//When the door drops down revealing the dudes
	FlagWaitAny( "open_door_diorama2_exit_pristine", "open_door_diorama2_exit_overgrown" )

	StopMusic()
	PlayMusicThatCantBeStopped( "music_timeshift_24_ambush" )
	SetGlobalNetBool( "music14LoopPausable", false )
	PlayMusicThatCantBeStopped( "music_timeshift_14_pastloop" )

	// Following the ambush, when the player switches to the PRESENT - Play music_timeshift_16_explorepresent
	FlagWait( "AndersonHologram2Finished" )
	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_NIGHT )

	thread PlayMusicInTimezoneUntilFlag( "music_timeshift_16_explorepresent", TIMEZONE_NIGHT, "entering_human_anteroom" )


	FlagWait( "entering_human_anteroom" )

	// When you enter human testing - Play music_timeshift_26_humanresearch
	// At the same time - Play music_timeshift_21c_pastloop_stop

	wait 0.1

	StopMusic()
	if ( IsValid( player ) )
	{
		StopSoundOnEntity( player, "music_timeshift_14_pastloop" )
		printl( "manually stopping music: music_timeshift_14_pastloop")
	}

	PlayMusicThatCantBeStopped( "music_timeshift_21c_pastloop_stop" )

	PlayMusic( "music_timeshift_26_humanresearch" )



}




///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function DialogueLabBravo( entity player )
{
	FlagWaitAny( "LabBravoEnemiesDead", "player_near_intel_room_2_landing_pad" )

	FlagWait( "player_inside_intel_room2" )

	FlagWait( "player_inside_intel_room2_halfway" )

	FlagClear( "open_doors_sphere_room_entrance_all" )


/*
██████╗ ██╗ █████╗ ██╗      ██████╗  ██████╗ ██╗   ██╗███████╗
██╔══██╗██║██╔══██╗██║     ██╔═══██╗██╔════╝ ██║   ██║██╔════╝
██║  ██║██║███████║██║     ██║   ██║██║  ███╗██║   ██║█████╗
██║  ██║██║██╔══██║██║     ██║   ██║██║   ██║██║   ██║██╔══╝
██████╔╝██║██║  ██║███████╗╚██████╔╝╚██████╔╝╚██████╔╝███████╗
╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝
*/

	FlagSet( "StartAndersonHologram2" )
	FlagSetDelayed( "AndersomHologram2AboutToStart", 3)


	FlagWait( "AndersonHologram2Finished" )

	wait 0.5



}


void function DialogueGunshipDeploys( entity player )
{

	/*
	FlagWaitAny( "LabBravoEnemiesDead", "player_inside_intel_room2_halfway" )


	//FlagWait( "LookingAtPad" )

	entity soundEnt = CreateLoudspeakerEnt( GetEntByScriptName( "lookent_pad" ).GetOrigin() )

	FlagWait( "AndersonHologram2Finished" )
	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )

	//waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )

	if ( !Flag( "AndersomHologram2AboutToStart" ) )
	{
		//Scientist 5 (Radio)	Sculptor Core prepped for delivery and en route to the test chamber.
		waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_miniSculptor_TS221_01_01_imc_scientist5" )
	}

	*/

	FlagWait( "StartSphereRoomGunship")

	wait 1

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )
	entity soundEnt = CreateLoudspeakerEnt( GetEntByScriptName( "lookent_pad" ).GetOrigin() )

	//Scientist 5 (Radio)	Sculptor Core prepped for delivery and en route to the test chamber.
	waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_miniSculptor_TS221_01_01_imc_scientist5" )

}

/////////////////////////////////////////////////////////////////////////////////////////
void function GunshipPadSequenceWait( entity player )
{
	FlagEnd( "exited_intel_room2" )

	FlagWait( "AndersonHologram2Finished" )

	entity lookEnt = GetEntByScriptName( "lookent_pad" )
		 									 		//doTrace	degrees		minDist	 	timeOut 	trigger, 	failsafeFlag )
	waitthread WaitTillLookingAt( player, lookEnt, 	false, 		30, 		0, 			0, 			null, 		"player_near_intel_room_2_landing_pad" )

	FlagSet( "StartSphereRoomGunship" )
}


/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
██╗  ██╗██╗   ██╗███╗   ███╗ █████╗ ███╗   ██╗            ██████╗ ███████╗███████╗███████╗ █████╗ ██████╗  ██████╗██╗  ██╗
██║  ██║██║   ██║████╗ ████║██╔══██╗████╗  ██║            ██╔══██╗██╔════╝██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝██║  ██║
███████║██║   ██║██╔████╔██║███████║██╔██╗ ██║            ██████╔╝█████╗  ███████╗█████╗  ███████║██████╔╝██║     ███████║
██╔══██║██║   ██║██║╚██╔╝██║██╔══██║██║╚██╗██║            ██╔══██╗██╔══╝  ╚════██║██╔══╝  ██╔══██║██╔══██╗██║     ██╔══██║
██║  ██║╚██████╔╝██║ ╚═╝ ██║██║  ██║██║ ╚████║            ██║  ██║███████╗███████║███████╗██║  ██║██║  ██║╚██████╗██║  ██║
╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝            ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
██╗  ██╗██╗   ██╗███╗   ███╗ █████╗ ███╗   ██╗            ██████╗ ███████╗███████╗███████╗ █████╗ ██████╗  ██████╗██╗  ██╗
██║  ██║██║   ██║████╗ ████║██╔══██╗████╗  ██║            ██╔══██╗██╔════╝██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝██║  ██║
███████║██║   ██║██╔████╔██║███████║██╔██╗ ██║            ██████╔╝█████╗  ███████╗█████╗  ███████║██████╔╝██║     ███████║
██╔══██║██║   ██║██║╚██╔╝██║██╔══██║██║╚██╗██║            ██╔══██╗██╔══╝  ╚════██║██╔══╝  ██╔══██║██╔══██╗██║     ██╔══██║
██║  ██║╚██████╔╝██║ ╚═╝ ██║██║  ██║██║ ╚████║            ██║  ██║███████╗███████║███████╗██║  ██║██║  ██║╚██████╗██║  ██║
╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝            ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
 /////////////////////////////////////////////////////////////////////////////////////////
/*
██╗  ██╗██╗   ██╗███╗   ███╗ █████╗ ███╗   ██╗            ██████╗ ███████╗███████╗███████╗ █████╗ ██████╗  ██████╗██╗  ██╗
██║  ██║██║   ██║████╗ ████║██╔══██╗████╗  ██║            ██╔══██╗██╔════╝██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝██║  ██║
███████║██║   ██║██╔████╔██║███████║██╔██╗ ██║            ██████╔╝█████╗  ███████╗█████╗  ███████║██████╔╝██║     ███████║
██╔══██║██║   ██║██║╚██╔╝██║██╔══██║██║╚██╗██║            ██╔══██╗██╔══╝  ╚════██║██╔══╝  ██╔══██║██╔══██╗██║     ██╔══██║
██║  ██║╚██████╔╝██║ ╚═╝ ██║██║  ██║██║ ╚████║            ██║  ██║███████╗███████║███████╗██║  ██║██║  ██║╚██████╗██║  ██║
╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝            ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
 /////////////////////////////////////////////////////////////////////////////////////////
/*
██╗  ██╗██╗   ██╗███╗   ███╗ █████╗ ███╗   ██╗            ██████╗ ███████╗███████╗███████╗ █████╗ ██████╗  ██████╗██╗  ██╗
██║  ██║██║   ██║████╗ ████║██╔══██╗████╗  ██║            ██╔══██╗██╔════╝██╔════╝██╔════╝██╔══██╗██╔══██╗██╔════╝██║  ██║
███████║██║   ██║██╔████╔██║███████║██╔██╗ ██║            ██████╔╝█████╗  ███████╗█████╗  ███████║██████╔╝██║     ███████║
██╔══██║██║   ██║██║╚██╔╝██║██╔══██║██║╚██╗██║            ██╔══██╗██╔══╝  ╚════██║██╔══╝  ██╔══██║██╔══██╗██║     ██╔══██║
██║  ██║╚██████╔╝██║ ╚═╝ ██║██║  ██║██║ ╚████║            ██║  ██║███████╗███████║███████╗██║  ██║██║  ██║╚██████╗██║  ██║
╚═╝  ╚═╝ ╚═════╝ ╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝            ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
void function HumanResearchStartPointSetup( entity player )
{
	TeleportPlayerToEnt( player, GetEntByScriptName( "checkpointHumanResearch" ) )
	vector objectivePos = GetEntByScriptName( "objective_human_research_vista" ).GetOrigin()
	TimeshiftSetObjectiveSilent( player, "#TIMESHIFT_OBJECTIVE_LAB_EXPLORE", objectivePos )

}
/////////////////////////////////////////////////////////////////////////////////////////
void function HumanResearchSkipped( entity player )
{
	FlagClear( "ShowMobilityGhostHumanLillypad01" )
	FlagClear( "ShowMobilityGhostHumanLillypad02" )
	thread ElectricalScreenEffects( player, "inside_human_control_room" )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function AA_HumanResearchThread( entity player )
{

	FlagWait( "entering_human_main_room" )
	FlagSet( "ShowMobilityGhostHumanLillypad01" )
	FlagSet( "ShowMobilityGhostHumanLillypad02" )

	//thread DebugX( player )

	thread FlyersHumanRoom()
	thread MusicHumanRoom( player )
	thread DialogueHumanRoomStart( player )
	vector objectivePos = GetEntByScriptName( "objective_human_research_tower1" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )

	//thread HumanPanelHacks( player )
	CheckPoint()

	delaythread ( 60 ) TimeshiftHint( player, TIMEZONE_DAY, "reached_concourse_tower1", "timeshift_hint_default", GetEntByScriptName( "trig_player_near_first_liilypad_puzzle_pristine" ) )


	FlagWait( "reached_concourse_tower1" )

	objectivePos = GetEntByScriptName( "objective_human_research_fight" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )

	thread ElectricalScreenEffects( player, "inside_human_control_room" )

	FlagClear( "ShowMobilityGhostHumanLillypad01" )


	CheckPoint()

	FlagWait( "inside_human_control_room" )

	objectivePos = GetEntByScriptName( "objective_human_research_tower2" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )

	FlagSet( "DisplayTheDamageHint" )
	thread HumanRoomCheckpointSoldiers()
	thread HumanRoomCheckpointProwlers()

	CheckPoint()

	//-------------------------------
	// Token prowlers
	//-------------------------------
	array< entity > propSpawners = GetEntArrayByScriptName( "prowler_spawnvents_human_control_room" )
	float delayMin = 2.5
	float delayMax = 5
	int maxToSpawn = 1
	string flagToAbort = "reached_concourse_tower2"
	string flagToSetWhenAllAreSpawned = "AllProwlersSpawnedInHumanControlRoom"
	bool requiresLookAt = true
	thread SpawnShowcaseGroupWhenInRange( player, propSpawners, maxToSpawn, flagToAbort, flagToSetWhenAllAreSpawned, delayMin, delayMax, "", requiresLookAt )

	FlagWait( "reached_concourse_tower2" )

	FlagClear( "DisplayTheDamageHint" )
	FlagClear( "ShowMobilityGhostHumanLillypad02" )
}

void function FlyersHumanRoom()
{
	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_NIGHT )
	FlagSet( "ForceFlyerTakeoff")
}
/////////////////////////////////////////////////////////////////////////////////////////
void function HumanRoomCheckpointSoldiers()
{
	FlagWait( "inside_human_control_room" )
	if ( Flag( "reached_concourse_tower2") )
		return
	FlagEnd( "reached_concourse_tower2" )
	FlagWait( "human_room_soldiers_dead" )
	CheckPoint()
}
/////////////////////////////////////////////////////////////////////////////////////////
void function HumanRoomCheckpointProwlers()
{
	FlagWait( "inside_human_control_room" )
	if ( Flag( "reached_concourse_tower2") )
		return
	FlagEnd( "reached_concourse_tower2" )

	FlagWait( "AllProwlersSpawnedInHumanControlRoom" )
	FlagWaitClear( "prowlers_alive_in_human_control_room")

	CheckPoint()
}


/////////////////////////////////////////////////////////////////////////////////////////
void function MusicHumanRoom( entity player )
{


}

/////////////////////////////////////////////////////////////////////////////////////////

void function GunshipRingSequenceWait( entity player )
{
	FlagWait( "crossed_wallrun_chain" )

	wait 0.25

	entity lookEnt = GetEntByScriptName( "lookent_rings" )
		 									 			//doTrace	degrees		minDist	 	timeOut 	trigger, 	failsafeFlag )
	waitthread WaitTillLookingAt( player, lookEnt, 	false, 		30, 		0, 			0, 			null, 	"player_crossing_human_bridge" )

	FlagSet( "player_looking_at_reactor_window" )

}

/////////////////////////////////////////////////////////////////////////////////////////
void function DialogueHumanRoomStart( entity player )
{

/*
██████╗ ██╗ █████╗ ██╗      ██████╗  ██████╗ ██╗   ██╗███████╗
██╔══██╗██║██╔══██╗██║     ██╔═══██╗██╔════╝ ██║   ██║██╔════╝
██║  ██║██║███████║██║     ██║   ██║██║  ███╗██║   ██║█████╗
██║  ██║██║██╔══██║██║     ██║   ██║██║   ██║██║   ██║██╔══╝
██████╔╝██║██║  ██║███████╗╚██████╔╝╚██████╔╝╚██████╔╝███████╗
╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝
*/


	FlagWait( "entering_human_main_room" )

	//wait 1
	//Player 	Option A	Were they doing experiments on these people?
	//BT 	Option A	SRS files indicated large-scale cryogenic stasis for testing on humans for unknown reasons. They are likely not volunteers.

	//Player 	Option B	Who are these people?
	//BT	Option B	Scanning... The genetic makeup matches those captured from the distant planet Colony led by former Militia leader MacAllan.
	//waitthread PlayerConversation( "TsHumanExperiments", player )
}

/////////////////////////////////////////////////////////////////////////////////////////
/*
void function HumanPanelHacks( entity player )
{
	//--------------------------------------------
	// Override all security terminals (optional)
	//----------------------------------------------
	array< entity > controlPanels
	controlPanels.append( GetEntByScriptName( "security_panel_concourse_01" ) )
	//controlPanels.append( GetEntByScriptName( "security_panel_concourse_02" ) )
	foreach( panel in controlPanels )
		thread SecurityPanelConcourseThink( panel, player )


}
*/
/////////////////////////////////////////////////////////////////////////////////////////
void function SecurityPanelConcourseThink( entity panel, entity player )
{
	panel.WaitSignal( "PanelReprogram_Success" )

	string flagToSetWhenHacked

	string scriptName = panel.GetScriptName()
	string laserMeshInstanceName
	if ( scriptName == "security_panel_concourse_01" )
	{
		laserMeshInstanceName = "laser_mesh_concourse_terminal_01"
		flagToSetWhenHacked = "ConcoursePanelHacked01"
	}
	else if ( scriptName == "security_panel_concourse_02" )
	{
		laserMeshInstanceName = "laser_mesh_concourse_terminal_02"
		flagToSetWhenHacked = "ConcoursePanelHacked02"
	}
	else
		Assert( 0, "Can't find lasermesh trigger associated with " + scriptName )

	FlagSet( flagToSetWhenHacked )

	if ( !Flag( "LabRatAcheivementUnlocked" ) )
	{
		FlagSet( "LabRatAcheivementUnlocked" )
		Dev_PrintMessage( player, "#TIMESHIFT_ACHEIVEMENT_HEADING", "#TIMESHIFT_ACHEIVEMENT_TEXT_LAB_RATS", 5 )
	}

	wait 1.5

	CheckPoint()

	LaserMeshDestroyByInstanceName( laserMeshInstanceName )
	Remote_CallFunction_NonReplay( player, "ServerCallback_LabRatLasers" )


}

/////////////////////////////////////////////////////////////////////////////////////////
/*
void function HumanPodsThink( string instanceNamePristine, string instanceNameOvergrown, entity player )
{
	array< entity > doorsPristine = GetEntArrayByScriptNameInInstance( "bio_pod_door", instanceNamePristine )
	array< entity > doorsOvergrown = GetEntArrayByScriptNameInInstance( "bio_pod_door", instanceNameOvergrown )
	Assert( doorsPristine.len() == 4 )
	Assert( doorsOvergrown.len() == 4 )

	string flagToReleasePrisoners = "security_concourse_01_hacked"
	//Militia Prisoner 1		What? What where am I?
	string prisonerDialogue = "diag_sp_humanStudy_TS202_03_01_mcor_prisoner1"
	if ( instanceNamePristine == "biodoors_terminal02_pristine" )
	{
		//Militia Prisoner 2		What's going on? This isn't Colony....
		string prisonerDialogue = "diag_sp_humanStudy_TS202_04_01_mcor_prisoner2"
		flagToReleasePrisoners = "security_concourse_02_hacked"

	}

	entity dialogueEnt

	foreach( door in doorsPristine )
	{
		if ( !IsValid( dialogueEnt ) )
			dialogueEnt = CreateLoudspeakerEnt( door.GetOrigin() )
		thread HumanPodThinkPristine( door )
	}
	foreach( door in doorsOvergrown )
		thread HumanPodThinkOvergrown( door )

	FlagWait( flagToReleasePrisoners )

	foreach( door in doorsOvergrown )
		door.Signal( "ReleaseLabRat")
	foreach( door in doorsPristine )
		door.Signal( "ReleaseLabRat")

	wait 5

	thread PlayTimeShiftDialogue( player, dialogueEnt, prisonerDialogue )
}

*/
/////////////////////////////////////////////////////////////////////////////////////////
/*
void function HumanPodsThinkNoHack( string instanceNamePristine, string instanceNameOvergrown, entity player )
{
	array< entity > spawners = GetEntArrayByScriptNameInInstance( "bio_pod_body", instanceNamePristine )
	foreach( spawner in spawners )
		thread HumanPodThinkPristine( null, spawner )
}
&*/
/////////////////////////////////////////////////////////////////////////////////////////
/*
void function HumanPodThinkPristine( entity door = null, entity bodySpawner = null )
{
	entity spawner
	if ( !bodySpawner )
		spawner = door.GetLinkEnt()
	else
		spawner = bodySpawner
	string animIdle
	string animWakeUp
	string animIdleEnd
	entity labRat = spawner.SpawnEntity()
	DispatchSpawn( labRat )
	Assert( IsValid( labRat) )
	entity node = CreateScriptRef( labRat.GetOrigin(), labRat.GetAngles() )
	vector originOffset = PositionOffsetFromEnt( node, -15, 0, 0 )
	node.SetOrigin( originOffset )

	MakeInvincible( labRat )
	MakeCivilian( labRat )
	labRat.SetNoTarget( true )
	SetTeam( labRat, TEAM_MILITIA )
	labRat.SetModel( LABRAT_MODEL )
	Assert( labRat.HasKey( "script_noteworthy") )
	animIdle = labRat.kv.script_noteworthy + "_start_idle"
	animWakeUp = labRat.kv.script_noteworthy + "_start"
	animIdleEnd = labRat.kv.script_noteworthy + "_end_idle"

	thread PlayAnimTeleport( labRat, animIdle, node )

	if ( !door )
		return

	door.WaitSignal( "ReleaseLabRat" )

	waitthread OpenLabRatDoor( door, labRat )

	labRat.EndSignal( "OnDeath" )
	wait 0.25

	ClearInvincible( labRat )
	labRat.e.forceRagdollDeath = true

	waitthread PlayAnim( labRat, animWakeUp, node )
	thread PlayAnim( labRat, animIdleEnd, node )
}
*/
/////////////////////////////////////////////////////////////////////////////////////////
/*
void function HumanPodThinkOvergrown( entity door )
{
	entity body = door.GetLinkEnt()

	door.WaitSignal( "ReleaseLabRat" )

	body.Destroy()
	OpenLabRatDoor( door, body )
}
*/
/////////////////////////////////////////////////////////////////////////////////////////
/*
void function OpenLabRatDoor( entity door, entity body )
{
	entity soundDummy = CreateInfoTarget( body.GetOrigin() + Vector( 0, 0, 72 ), Vector( 0, 0, 0 ) )
	vector soundOrigin = soundDummy.GetOrigin()
	entity lookEnt = CreateInfoTarget( body.GetOrigin() + Vector( 0, 0, 72 ), Vector( 0, 0, 0 ) )
	vector originOffset = PositionOffsetFromEnt( lookEnt, 15, 0, 0 )
	lookEnt.SetOrigin( originOffset )

	vector fxOrigin = body.GetOrigin()
	vector fxAngles = body.GetAngles()

	bool snapToOpen = false
	if ( GetEntityTimelinePosition( door ) == TIMEZONE_NIGHT )
		snapToOpen = true

	vector startPos = door.GetOrigin()
	vector endPos = startPos + Vector( 0, 0, -105 )

	if ( snapToOpen == true )
	{
		door.SetOrigin( endPos )
		return
	}

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )

	array <entity> players = GetPlayerArray()
	if ( players.len() <= 0 )
		return
	entity player = players[ 0 ]
	player.EndSignal( "OnDeath" )

	//WaitTillLookingAt( entity player, entity ent, bool doTrace, float degrees, float minDist = 0, float timeOut = 0, entity trigger = null, string failsafeFlag = "" )
	waitthread WaitTillLookingAt( player, lookEnt, true, 45, 0, 3 )

	wait( RandomFloatRange( 0, 0.75 ) )
	entity mover = CreateScriptMover( door.GetOrigin(), door.GetAngles() )
	door.SetParent( mover )
	float moveTime = 5

	mover.NonPhysicsMoveTo( endPos, moveTime, moveTime*0.4, moveTime*0.4 )


	EmitSoundAtPosition( TEAM_UNASSIGNED, soundOrigin, "Timeshift_Scr_LabRatPodDoor_Open" )
	//EmitSoundOnEntity( soundDummy, "door_open_loop" )
	PlayFX( FX_HUMAN_DOOR_OPEN, fxOrigin, fxAngles )

	wait moveTime

	//StopSoundOnEntity( soundDummy, "door_open_loop" )
	//EmitSoundAtPosition( TEAM_UNASSIGNED, soundOrigin, "door_stop" )

}
*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
 ██████╗ █████╗ ███╗   ███╗██████╗ ██╗   ██╗███████╗            ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
██╔════╝██╔══██╗████╗ ████║██╔══██╗██║   ██║██╔════╝            ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
██║     ███████║██╔████╔██║██████╔╝██║   ██║███████╗            ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
██║     ██╔══██║██║╚██╔╝██║██╔═══╝ ██║   ██║╚════██║            ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
╚██████╗██║  ██║██║ ╚═╝ ██║██║     ╚██████╔╝███████║            ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
 ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝      ╚═════╝ ╚══════╝            ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/*
 ██████╗ █████╗ ███╗   ███╗██████╗ ██╗   ██╗███████╗            ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
██╔════╝██╔══██╗████╗ ████║██╔══██╗██║   ██║██╔════╝            ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
██║     ███████║██╔████╔██║██████╔╝██║   ██║███████╗            ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
██║     ██╔══██║██║╚██╔╝██║██╔═══╝ ██║   ██║╚════██║            ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
╚██████╗██║  ██║██║ ╚═╝ ██║██║     ╚██████╔╝███████║            ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
 ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝      ╚═════╝ ╚══════╝            ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/*
 ██████╗ █████╗ ███╗   ███╗██████╗ ██╗   ██╗███████╗            ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
██╔════╝██╔══██╗████╗ ████║██╔══██╗██║   ██║██╔════╝            ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
██║     ███████║██╔████╔██║██████╔╝██║   ██║███████╗            ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
██║     ██╔══██║██║╚██╔╝██║██╔═══╝ ██║   ██║╚════██║            ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
╚██████╗██║  ██║██║ ╚═╝ ██║██║     ╚██████╔╝███████║            ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
 ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝      ╚═════╝ ╚══════╝            ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
 */
/////////////////////////////////////////////////////////////////////////////////////////
/*
 ██████╗ █████╗ ███╗   ███╗██████╗ ██╗   ██╗███████╗            ██████╗ ███████╗████████╗██╗   ██╗██████╗ ███╗   ██╗
██╔════╝██╔══██╗████╗ ████║██╔══██╗██║   ██║██╔════╝            ██╔══██╗██╔════╝╚══██╔══╝██║   ██║██╔══██╗████╗  ██║
██║     ███████║██╔████╔██║██████╔╝██║   ██║███████╗            ██████╔╝█████╗     ██║   ██║   ██║██████╔╝██╔██╗ ██║
██║     ██╔══██║██║╚██╔╝██║██╔═══╝ ██║   ██║╚════██║            ██╔══██╗██╔══╝     ██║   ██║   ██║██╔══██╗██║╚██╗██║
╚██████╗██║  ██║██║ ╚═╝ ██║██║     ╚██████╔╝███████║            ██║  ██║███████╗   ██║   ╚██████╔╝██║  ██║██║ ╚████║
 ╚═════╝╚═╝  ╚═╝╚═╝     ╚═╝╚═╝      ╚═════╝ ╚══════╝            ╚═╝  ╚═╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═══╝
 */
/////////////////////////////////////////////////////////////////////////////////////////


void function CampusReturnStartPointSetup( entity player )
{
	TeleportPlayerToEnt( player, GetEntByScriptName( "checkpointCampusReturn" ) )
	vector objectivePos = GetEntByScriptName( "objective_human_research_vista" ).GetOrigin()
	TimeshiftSetObjectiveSilent( player, "#TIMESHIFT_OBJECTIVE_LAB_EXPLORE", objectivePos )

}
/////////////////////////////////////////////////////////////////////////////////////////
void function CampusReturnSkipped( entity player )
{
	FlagSet( "CampusReturnConversationFinished" )
	FlagClear( "ShowMobilityGhostHumanWallrunChain" )
	FlagClear( "ShowMobilityGhostPowertech" )

}
/////////////////////////////////////////////////////////////////////////////////////////
void function AA_CampusReturnThread( entity player )
{
	FlagWait( "reached_concourse_tower2" )

	vector objectivePos = GetEntByScriptName( "objective_human_research_vista" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )

	thread ObjectiveRemindUntilFlag( "crossed_wallrun_chain" )

	FlagSet( "ShowMobilityGhostHumanWallrunChain" )
	FlagSet( "ShowMobilityGhostPowertech" )

	CheckPoint()
	thread ArtifactLaunchThink( player )
	thread BridgeThink()
	thread MusicCampusReturn( player )
	thread GunshipRingSequenceWait( player )
	thread GunshipSequence( "gunship_rings", player, "node_gunship_rings", "rings", "player_looking_at_reactor_window" )

	FlagWait( "crossed_wallrun_chain" )

	wait 0.25

	//Checkpoint done with a trigger with safe spot here

	objectivePos = GetEntByScriptName( "objective_return_breadcrumb00" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )

	thread DialogueHumanRoomEnd( player )

	FlagSet( "finishedHumanVistaSequence" )


	thread HumanBridgeEnemies( player )
	thread HumanBridgeOvergrownThink( player )


	FlagWait( "entered_powertech_return" )

	objectivePos = GetEntByScriptName( "objective_return_breadcrumb01" ).GetOrigin()
	TimeshiftSetObjective( player, "#TIMESHIFT_OBJECTIVE_RETURN", objectivePos )

	CheckPoint()

	FlagWait( "approaching_fan_drop" )
}

void function BridgeThink()
{
	FlagWait( "bridge_control_panel_pressed" )
	FlagClear( "retract_bridge_human_01" )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function HumanBridgeOvergrownThink( entity player )
{
	//Show it when enemies extend it in other time zone
	FlagWaitClear( "retract_bridge_human_01" )

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )

	ShowStuff( "human_bridge_overgrown" )


	//Hide it again if player manually retracts it
	//FlagWait( "retract_bridge_human_01" )

	//waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )

	//HideStuff( "human_bridge_overgrown" )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function MusicCampusReturn( entity player )
{
	FlagWait( "crossing_wallrun_chain" )

	StopMusic()
	PlayMusic( "music_timeshift_27_towardthemachine" )

	FlagWait( "spawnHumanBridgeEnemies" )

	//Only play drone spawn music if player is actually in the trigger spawning the drones

	if ( !Flag( "player_touching_drone_spawn_area_bridge_pristine") )
		return

	StopMusic()
	PlayMusic( "music_timeshift_28_bridge" )

}
/////////////////////////////////////////////////////////////////////////////////////////

void function ArtifactLaunchThink( entity player )
{
	entity arkShell = GetEntByScriptName( "core_model_pristine" )
	entity arkSphere = GetEntByScriptName( "core_glow_model_pristine" )
	vector startPos = arkShell.GetOrigin()
	vector startAng = arkShell.GetAngles()
	vector endPos = GetEntByScriptName( "artifact_ring_startpoint" ).GetOrigin()

	entity fxLaunchGlow = PlayLoopFXOnEntity( FX_ARK_LAUNCH_GLOW, arkShell )
	entity mover = CreateScriptMover( startPos, startAng )
	arkSphere.SetParent( arkShell )
	arkShell.SetParent( mover )
	float moveTime = 2

	FlagWait( "crossed_wallrun_chain" )

	wait 0.25

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )
	wait 0.1

	mover.NonPhysicsMoveTo( endPos, moveTime, moveTime*0.4, moveTime*0.4 )
	EmitSoundOnEntity( player, "timeshift_scr_core_rise_start" )

	wait moveTime

	entity fxLaunchInPlace = PlayFXOnEntity( FX_ARK_LAUNCH_IN_PLACE, arkShell )

	//StopSoundOnEntity( player, "timeshift_scr_core_rise_start" )
	EmitSoundAtPosition( TEAM_UNASSIGNED, endPos, "timeshift_scr_core_rise_end" )
	EmitSoundAtPosition( TEAM_UNASSIGNED, endPos, "timeshift_scr_core_pulse" )
			//CreateShake( vector org, float amplitude = 16, float frequency = 150, float duration = 1.5, float radius = 2048 )
	thread CreateAirShake( startPos, 32, 200, 1.5, 10000 )
	thread CreateShakeWhileFlagSet( 0.5, 0.5, 1, "player_near_rings", "DoneWithFanDropSequence" )

	FlagSet( "RingVistaSequenceComplete" )

}



/////////////////////////////////////////////////////////////////////////////////////////
void function DialogueHumanRoomEnd( entity player )
{


/*
██████╗ ██╗ █████╗ ██╗      ██████╗  ██████╗ ██╗   ██╗███████╗
██╔══██╗██║██╔══██╗██║     ██╔═══██╗██╔════╝ ██║   ██║██╔════╝
██║  ██║██║███████║██║     ██║   ██║██║  ███╗██║   ██║█████╗
██║  ██║██║██╔══██║██║     ██║   ██║██║   ██║██║   ██║██╔══╝
██████╔╝██║██║  ██║███████╗╚██████╔╝╚██████╔╝╚██████╔╝███████╗
╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝
*/

	FlagWait( "crossed_wallrun_chain" )

	wait 0.25

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )
	entity soundEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )

	//Scientist 5	PA	Ark successfully delivered to fold weapon rings. Commencing test run.
	waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_humanStudy_TS203_01_01_imc_sci" )

	//FlagWaitAny( "human_bridge_soldiers_dead", "entered_powertech_return" )

	FlagWaitAny( "RingVistaSequenceComplete", "player_crossing_human_bridge" )


	//BT: Pilot, the rings at my location contain a large amount of residual energy. This was the Ark's final destination.
	waitthread PlayBTDialogue( "diag_sp_targeting_TS231_01_01_mcor_bt" )

	//BT: Anderson's plan indicated a recon mission within close proximity to the center of the active rings.
	waitthread PlayBTDialogue( "diag_sp_targeting_TS231_07_01_mcor_bt" )

	if ( !Flag( "approaching_fan_drop" ) )
	{
		// Player (Option A)	You want me to do what?
		// Player (Option B)	Are you sure I'll be safe over there? (diag_sp_pristine_TS242_03_01_mcor_player)

		// BT (Option A)	If we can obtain the Ark's energy signature, the Militia fleet will be able to track its current location in the present day.
		// BT (Option B)	No. But a true Militia Pilot takes risks for the welfare of others. As did Major Anderson and Captain Lastimosa before you. (diag_sp_pristine_TS242_04_01_mcor_bt)

		waitthread PlayerConversationStopOnFlag( "TsSeeingCoreFlownToRings", player, "entered_powertech_return" )
	}

	FlagSet( "CampusReturnConversationFinished" )

	FlagSet( "spawnHumanBridgeEnemies" )


}



/////////////////////////////////////////////////////////////////////////////////////////
void function HumanBridgeEnemies( entity player )
{
	FlagWait( "finishedHumanVistaSequence" )

	entity lookEnt = GetEntByScriptName( "look_ent_human_bridge" )
	entity trigger = GetEntByScriptName( "trig_player_at_human_vista_pristine" )
	 									 			//doTrace	degrees		minDist	 	timeOut 	trigger, 	failsafeFlag )
	waitthread WaitTillLookingAt( player, lookEnt, 	true, 		30, 		0, 			0, 			trigger, 	"player_crossing_human_bridge" )


	//entity triggerBridgeVolume = GetEntByScriptName( "trigger_bridge_human_volume" )
	//entity bridge = GetEntByScriptName( "human_bridge" )
	//FlagSet( "spawnHumanBridgeEnemies" )

	/*
	//FlagClearDelayed( "retract_bridge_human_01", 3 )

	FlagWait( "retract_bridge_control_panel_pressed" )
	FlagSet( "retract_bridge_human_01" )
	bridge.NotSolid()

	SetGlobalForcedDialogueOnly( true )
	bool screamPlayed = false
	array<entity> ai = GetNPCArrayByClass( "npc_soldier" )
	entity tempNode
	float delayTime = 0
	string floorDropAnim = "pt_react_bridgedrop_A"
	foreach( guy in ai )
	{
		if ( !triggerBridgeVolume.IsTouching( guy ) )
			continue

		if ( IsAlive( guy ) )
		{
			//guy.NotSolid()
			if ( screamPlayed == false )
			{
				EmitSoundOnEntity( guy, "Grunt_DroppedByFlyer" )
				screamPlayed = true
			}
			if ( CoinFlip() )
				floorDropAnim = "pt_react_bridgedrop_B"
			tempNode = CreateScriptMover( guy.GetOrigin(), guy.GetAngles() )
			guy.SetParent( tempNode )
			delayTime = RandomFloatRange( 0, 0.3 )
			delaythread ( delayTime ) PlayAnim( guy, floorDropAnim, tempNode )
			//guy.TakeDamage( guy.GetHealth() / 2, null, null, { damageSourceId=damagedef_suicide } )
		}
	}
	if ( screamPlayed == true )
	{
		delaythread ( 2 ) Dev_PrintMessage( player, "#TIMESHIFT_ACHEIVEMENT_HEADING", "#TIMESHIFT_ACHEIVEMENT_TEXT_BRIDGE_FALL", 5 )
	}

	wait 1

	SetGlobalForcedDialogueOnly( false )

	DestroyIfValid( "human_bridge" )
	*/

}

/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗ █████╗ ███╗   ██╗        ██████╗ ██████╗  ██████╗ ██████╗
██╔════╝██╔══██╗████╗  ██║        ██╔══██╗██╔══██╗██╔═══██╗██╔══██╗
█████╗  ███████║██╔██╗ ██║        ██║  ██║██████╔╝██║   ██║██████╔╝
██╔══╝  ██╔══██║██║╚██╗██║        ██║  ██║██╔══██╗██║   ██║██╔═══╝
██║     ██║  ██║██║ ╚████║        ██████╔╝██║  ██║╚██████╔╝██║
╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝        ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗ █████╗ ███╗   ██╗        ██████╗ ██████╗  ██████╗ ██████╗
██╔════╝██╔══██╗████╗  ██║        ██╔══██╗██╔══██╗██╔═══██╗██╔══██╗
█████╗  ███████║██╔██╗ ██║        ██║  ██║██████╔╝██║   ██║██████╔╝
██╔══╝  ██╔══██║██║╚██╗██║        ██║  ██║██╔══██╗██║   ██║██╔═══╝
██║     ██║  ██║██║ ╚████║        ██████╔╝██║  ██║╚██████╔╝██║
╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝        ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗ █████╗ ███╗   ██╗        ██████╗ ██████╗  ██████╗ ██████╗
██╔════╝██╔══██╗████╗  ██║        ██╔══██╗██╔══██╗██╔═══██╗██╔══██╗
█████╗  ███████║██╔██╗ ██║        ██║  ██║██████╔╝██║   ██║██████╔╝
██╔══╝  ██╔══██║██║╚██╗██║        ██║  ██║██╔══██╗██║   ██║██╔═══╝
██║     ██║  ██║██║ ╚████║        ██████╔╝██║  ██║╚██████╔╝██║
╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝        ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗ █████╗ ███╗   ██╗        ██████╗ ██████╗  ██████╗ ██████╗
██╔════╝██╔══██╗████╗  ██║        ██╔══██╗██╔══██╗██╔═══██╗██╔══██╗
█████╗  ███████║██╔██╗ ██║        ██║  ██║██████╔╝██║   ██║██████╔╝
██╔══╝  ██╔══██║██║╚██╗██║        ██║  ██║██╔══██╗██║   ██║██╔═══╝
██║     ██║  ██║██║ ╚████║        ██████╔╝██║  ██║╚██████╔╝██║
╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝        ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝

*/
/////////////////////////////////////////////////////////////////////////////////////////

void function FanDropStartPointSetup( entity player )
{
	//entity temp = CreateInfoTarget( Vector( 3536, -4641, -127), Vector( 35.5, -90, 0 ) )
	//TeleportPlayerToEnt( player, temp )

	TeleportPlayerToEnt( player, GetEntByScriptName( "checkpointFanDrop" ) )
	vector objectivePos = GetEntByScriptName( "objective_concourse_panel" ).GetOrigin()
	TimeshiftSetObjectiveSilent( player, "#TIMESHIFT_OBJECTIVE_RETURN", objectivePos )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function FanDropSkipped( entity player )
{
	CleanupEnts( "rings_pristine" )
	FlagSet( "approaching_fan_drop" )
	FlagSet( "DoneWithFanDropSequence" )
	thread QuickSkit( player, GetEntByScriptName( "node_labC_deathpose_overgrown" ), "approaching_fan_drop" )
	thread QuickSkit( player, GetEntByScriptName( "node_labC_deathpose_pristine" ), "approaching_fan_drop" )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function AA_FanDropThread( entity player )
{
	FlagWait( "approaching_fan_drop" )

	thread MusicFanDrop( player )
	thread FanDropTeleport( player )
	thread QuickSkit( player, GetEntByScriptName( "node_labC_deathpose_overgrown" ), "approaching_fan_drop" )
	thread QuickSkit( player, GetEntByScriptName( "node_labC_deathpose_pristine" ), "approaching_fan_drop" )
	thread FanDropLanding( player )

	vector objectivePos = GetEntByScriptName( "objective_return_breadcrumb01" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )



	FlagWait( "doing_fan_drop_pristine" )


	while( true )
	{
		FlagWait( "exited_fan_drop" )

		WaitEndFrame() //even if player hit the "exited_fan_drop", he might already be starting a quickDeath

		if ( player.p.doingQuickDeath )
		{
			printl( "player doing quickDeath...waiting 2 secs")
			wait 2
			printl( "Waiting to exit fan drop..." )
			continue
		}
		else
		{
			if ( IsAlive( player ) )
				thread FanDropQuickdeathFailsafe( player )
			break
		}

	}


	FlagSet( "DoneWithFanDropSequence" )

}

void function FanDropQuickdeathFailsafe( entity player )
{
	player.EndSignal( "OnDeath" )
	//If player gets into a state where the game thinks he has exited the fan sequence, but is in fact doing a quick death, restart from last checkpoint
	wait 0.5
	if ( player.p.doingQuickDeath )
		player.TakeDamage( 9999, null, null, { damageSourceId=damagedef_suicide } )
}

void function FanDropLanding( entity player )
{

	entity node = GetEntByScriptName( "checkpointFanDropEnd" )
	entity nodePristine = CreateScriptRef( node.GetOrigin() + Vector( 0, 0, TIME_ZOFFSET ), node.GetAngles() )

	FlagWait( "DoneWithFanDropSequence" )



	printl( "Done with fan drop...playing land anim" )

	player.FreezeControlsOnServer()
	level.allowTimeTravel = false
	ShowStuff( "blocker_fandrop_pristine" )
	ShowStuff( "blocker_fandrop_overgrown" )

	player.DisableWeapon()
	player.ForceStand()


	waitthread AdjustPlayerTimelineHack( player, true )

	WaitFrame()
	if ( GetEntityTimelinePosition( player ) == TIMEZONE_NIGHT )
		waitthread PlayerDropLand( player, node, true )
	else
		waitthread PlayerDropLand( player, nodePristine, true )

	waitthread AdjustPlayerTimelineHack( player )

	wait 0.5
	player.UnfreezeControlsOnServer()
	level.allowTimeTravel = true
}
/////////////////////////////////////////////////////////////////////////////////////////
void function AdjustPlayerTimelineHack( entity player, bool isBeforePlayerLandAnim = false )
{
	vector newPos
	var playerCurrentTimeline = GetEntityTimelinePosition( player )

	if ( playerCurrentTimeline != level.timeZone )
	{
		printl( "*********WARNING***************" )
		printl( "Rare bug: Player timeline and level timeline don't match....adjusting player pos" )
		printl( "Adjusting before player land animation: " + isBeforePlayerLandAnim )
		printl( "*******************************" )
		newPos = GetPosInOtherTimeline( player.GetOrigin() )
		player.SetOrigin( newPos )
	}
}
/////////////////////////////////////////////////////////////////////////////////////////
void function FanDropTeleport( entity player )
{
	player.EndSignal( "OnDeath" )
	FlagEnd( "DoneWithFanDropSequence" )
	entity orgFanDropOvergrownMain = GetEntByScriptName( "fandrop_start_overgrown_main" )
	entity orgFanDropOvergrownAlt = GetEntByScriptName( "fandrop_start_overgrown_alt" )
	vector vectorOffset = orgFanDropOvergrownAlt.GetOrigin() - orgFanDropOvergrownMain.GetOrigin()


	while( true )
	{
		//wait till player timeshifts past first fire
		FlagWait( "doing_fan_drop_pristine" )

		//now wait till he switches back to dodge the spinning fan
		FlagWait( "past_first_spinning_fan_and_back_in_overgrown" )
		//WaittillPlayerSwitchesTimezone( TIMEZONE_NIGHT )

		//if we haven't died yet, do the teleport while in overgrown
		if ( CanDoFanTeleport( player, vectorOffset ) )
			player.SetOrigin( player.GetOrigin() + vectorOffset )

		//otherwise, we died, wait for player to be in reset pos
		else
			FlagWait( "standing_at_top_of_fan" )

	}


}

/////////////////////////////////////////////////////////////////////////////////////////
bool function CanDoFanTeleport( entity player, vector vectorOffset )
{
	//trying to teleport while in overgrown

	if ( !IsValid( player ) )
		return false

	player.EndSignal( "OnDeath" )

	if ( Flag( "standing_at_top_of_fan" ) )
		return false
	if ( !Flag( "dropping_down_fan" ) )
		return false
	if ( player.p.doingQuickDeath )
		return false
	if ( GetEntityTimelinePosition( player ) != TIMEZONE_NIGHT )
		return false
	if ( GetTimelinePosition( player.GetOrigin() + vectorOffset ) != TIMEZONE_NIGHT )
		return false

	return true

}

/////////////////////////////////////////////////////////////////////////////////////////
void function MusicFanDrop( entity player )
{
	if ( Flag( "StartAndersonHologram3") )
		return

	FlagEnd( "StartAndersonHologram3")

	OnThreadEnd(
	function() : ()
		{
			FlagSet( "BrokeOutOfFanDropMusicLoop")
		}
	)
	while( true )
	{
		FlagWait( "dropping_down_fan" )
		StopMusic()
		PlayMusic( "music_timeshift_29_downtherabbithole" )
		wait 2
		FlagWait( "standing_at_top_of_fan" )
		StopMusic()

	}

}

/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗ █████╗ ███╗   ██╗        ██████╗ ██████╗  ██████╗ ██████╗         ███████╗███╗   ██╗██████╗
██╔════╝██╔══██╗████╗  ██║        ██╔══██╗██╔══██╗██╔═══██╗██╔══██╗        ██╔════╝████╗  ██║██╔══██╗
█████╗  ███████║██╔██╗ ██║        ██║  ██║██████╔╝██║   ██║██████╔╝        █████╗  ██╔██╗ ██║██║  ██║
██╔══╝  ██╔══██║██║╚██╗██║        ██║  ██║██╔══██╗██║   ██║██╔═══╝         ██╔══╝  ██║╚██╗██║██║  ██║
██║     ██║  ██║██║ ╚████║        ██████╔╝██║  ██║╚██████╔╝██║             ███████╗██║ ╚████║██████╔╝
╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝        ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝             ╚══════╝╚═╝  ╚═══╝╚═════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
 /////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗ █████╗ ███╗   ██╗        ██████╗ ██████╗  ██████╗ ██████╗         ███████╗███╗   ██╗██████╗
██╔════╝██╔══██╗████╗  ██║        ██╔══██╗██╔══██╗██╔═══██╗██╔══██╗        ██╔════╝████╗  ██║██╔══██╗
█████╗  ███████║██╔██╗ ██║        ██║  ██║██████╔╝██║   ██║██████╔╝        █████╗  ██╔██╗ ██║██║  ██║
██╔══╝  ██╔══██║██║╚██╗██║        ██║  ██║██╔══██╗██║   ██║██╔═══╝         ██╔══╝  ██║╚██╗██║██║  ██║
██║     ██║  ██║██║ ╚████║        ██████╔╝██║  ██║╚██████╔╝██║             ███████╗██║ ╚████║██████╔╝
╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝        ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝             ╚══════╝╚═╝  ╚═══╝╚═════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
 /////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗ █████╗ ███╗   ██╗        ██████╗ ██████╗  ██████╗ ██████╗         ███████╗███╗   ██╗██████╗
██╔════╝██╔══██╗████╗  ██║        ██╔══██╗██╔══██╗██╔═══██╗██╔══██╗        ██╔════╝████╗  ██║██╔══██╗
█████╗  ███████║██╔██╗ ██║        ██║  ██║██████╔╝██║   ██║██████╔╝        █████╗  ██╔██╗ ██║██║  ██║
██╔══╝  ██╔══██║██║╚██╗██║        ██║  ██║██╔══██╗██║   ██║██╔═══╝         ██╔══╝  ██║╚██╗██║██║  ██║
██║     ██║  ██║██║ ╚████║        ██████╔╝██║  ██║╚██████╔╝██║             ███████╗██║ ╚████║██████╔╝
╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝        ╚═════╝ ╚═╝  ╚═╝ ╚═════╝ ╚═╝             ╚══════╝╚═╝  ╚═══╝╚═════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////


void function FanDropEndStartPointSetup( entity player )
{
	TeleportPlayerToEnt( player, GetEntByScriptName( "checkpointFanDropEnd" ) )
	vector objectivePos = GetEntByScriptName( "objective_concourse_panel" ).GetOrigin()
	TimeshiftSetObjectiveSilent( player, "#TIMESHIFT_OBJECTIVE_RETURN", objectivePos )

}

/////////////////////////////////////////////////////////////////////////////////////////
void function FanDropEndSkipped( entity player )
{

	CleanupEnts( "triggers_instadeath_humanroom" )
	CleanupEnts( "triggers_quickdeath_humanroom" )
	CleanupEnts( "trigger_quickdeath_checkpoint_humanroom" )

}
/////////////////////////////////////////////////////////////////////////////////////////
void function AA_FanDropEndThread( entity player )
{
	FlagWait( "DoneWithFanDropSequence" )


	CleanupEnts( "rings_pristine" )
	CleanupEnts( "triggers_instadeath_humanroom" )
	CleanupEnts( "triggers_quickdeath_humanroom" )
	CleanupEnts( "trigger_quickdeath_checkpoint_humanroom" )

	Remote_CallFunction_Replay( player, "ServerCallback_ShowHologramTitles" )
	thread MusicFanDropEnd( player)
	thread StalkerDoorSequences( player )
	thread DialogueLabCharlie( player )
	thread DialogueTransitionHall( player )
	delaythread ( 1 ) AndersonHologramSequence( player, "node_hologram_lab3", "StartAndersonHologram3" )

	vector objectivePos = GetEntByScriptName( "objective_concourse_panel_breadcrumb_01" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )


	wait 2

	CheckPoint()


	FlagWait( "exited_intel_room3" )

	objectivePos = GetEntByScriptName( "objective_concourse_panel" ).GetOrigin()
	TimeshiftUpdateObjective( player, objectivePos )

	//-------------------------------
	// Token overgrown/pristine wall Spectres
	//-------------------------------
	array< entity > propSpawners = GetEntArrayByScriptNameInInstance( "spectre_door_spawner", "spectre_spawner_return_overgrown" )
	float delayMin = 0
	float delayMax = 0.4
	int maxToSpawn = 1
	string flagToAbort = "transition_hallway_return_finished"
	string flagToSetWhenSpectreSpawned = ""
	bool requiresLookAt = true
	thread SpawnShowcaseGroupWhenInRange( player, propSpawners, maxToSpawn, flagToAbort, "", delayMin, delayMax, flagToSetWhenSpectreSpawned, requiresLookAt )

	propSpawners = GetEntArrayByScriptNameInInstance( "spectre_door_spawner", "spectre_spawner_return_pristine" )
	delayMin = 0
	delayMax = 0.4
	maxToSpawn = 1
	flagToAbort = "transition_hallway_return_finished"
	flagToSetWhenSpectreSpawned = ""
	requiresLookAt = true
	thread SpawnShowcaseGroupWhenInRange( player, propSpawners, maxToSpawn, flagToAbort, "", delayMin, delayMax, flagToSetWhenSpectreSpawned, requiresLookAt )


	FlagWait( "transition_hallway_return_finished" )



	//ScreenFadeToBlack( player, 1.5, 5 )
	//wait 1.5
	//player.SetInvulnerable()
	//player.FreezeControlsOnServer()

	thread TransitionSpoke1()
}


void function TransitionSpoke1()
{
	LevelTransitionStruct trans = SaveBoyleAudioLogs()
	if ( level.timeZone == TIMEZONE_NIGHT )
		trans.timeshiftMostRecentTimeline = 1
	else
		trans.timeshiftMostRecentTimeline = 0

	PickStartPoint( "sp_hub_timeshift", "PRISTINE CAMPUS", trans )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function MusicFanDropEnd( entity player )
{
	FlagWait( "StartAndersonHologram3" )
	FlagWait( "BrokeOutOfFanDropMusicLoop" )

	//FlagWait( "AndersonHologram3Playing" )

	//StopMusic()
	PlayMusicThatCantBeStopped( "music_timeshift_30_andersonlog04")

}
/////////////////////////////////////////////////////////////////////////////////////////
void function StalkerDoorSequences( entity player )
{

	thread QuickSkit( player, GetEntByScriptName( "node_intel_room3_stalker_door_overgrown" ), 	"player_near_intel3_exit", GetEntByScriptName( "intel3_exit_overgrown_look_ent" ), GetEntByScriptName( "trig_approaching_lab3_exit_overgrown" ) )
	thread QuickSkit( player, GetEntByScriptName( "node_intel_room3_stalker_door_pristine" ), 	"player_near_intel3_exit", GetEntByScriptName( "intel3_exit_pristine_look_ent" ), GetEntByScriptName( "trig_approaching_lab3_exit_pristine" ) )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function DialogueLabCharlie( entity player )
{


/*
██████╗ ██╗ █████╗ ██╗      ██████╗  ██████╗ ██╗   ██╗███████╗
██╔══██╗██║██╔══██╗██║     ██╔═══██╗██╔════╝ ██║   ██║██╔════╝
██║  ██║██║███████║██║     ██║   ██║██║  ███╗██║   ██║█████╗
██║  ██║██║██╔══██║██║     ██║   ██║██║   ██║██║   ██║██╔══╝
██████╔╝██║██║  ██║███████╗╚██████╔╝╚██████╔╝╚██████╔╝███████╗
╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝
*/

	FlagWait( "DoneWithFanDropSequence" )

	wait 1.5

	FlagSet( "StartAndersonHologram3" )


	FlagWaitAny( "AndersonHologram3Finished", "exited_intel_room3" )

	wait 0.75

	//That was Major Anderson's final recording.
	waitthread PlayBTDialogue( "diag_sp_targeting_TS232_02_01_mcor_bt" )

	while( true )
	{
		wait 0.25
		if ( IsAudioLogPlaying( player ) )
			continue

		else
		{
			//Cooper, based on your recon of this facility, I may have a plan. Meet me outside.	diag_sp_targeting_TS232_03_01_mcor_bt
			waitthread PlayBTDialogue( "diag_sp_targeting_TS232_03_01_mcor_bt" )
			Objective_Remind()
			break
		}
	}

	thread ObjectiveRemindUntilFlag( "transition_hallway_return_finished" )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function DialogueTransitionHall( entity player )
{


/*
██████╗ ██╗ █████╗ ██╗      ██████╗  ██████╗ ██╗   ██╗███████╗
██╔══██╗██║██╔══██╗██║     ██╔═══██╗██╔════╝ ██║   ██║██╔════╝
██║  ██║██║███████║██║     ██║   ██║██║  ███╗██║   ██║█████╗
██║  ██║██║██╔══██║██║     ██║   ██║██║   ██║██║   ██║██╔══╝
██████╔╝██║██║  ██║███████╗╚██████╔╝╚██████╔╝╚██████╔╝███████╗
╚═════╝ ╚═╝╚═╝  ╚═╝╚══════╝ ╚═════╝  ╚═════╝  ╚═════╝ ╚══════╝
*/


	FlagWaitAny( "player_near_intel3_exit_overgrown", "player_near_intel3_exit_pristine" )

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )
	entity soundEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )

	wait 1.5

	//Security - PA	Attention. Automated security personnel have now been deployed in all non-combatant sectors.
	//Please display security credentials clearly to avoid accidental termination. Thank you.
	waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_targeting_TS231_12_01_imc_facilityPA" )

	wait 3

	soundEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )

	//Security -PA	Automated security personnel: Please target all non-IMC military subjects.
	waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_targeting_TS231_11_01_imc_facilityPA" )

}
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗  ██╗ █████╗ ██████╗ ███████╗██████╗
██╔════╝██║  ██║██╔══██╗██╔══██╗██╔════╝██╔══██╗
███████╗███████║███████║██████╔╝█████╗  ██║  ██║
╚════██║██╔══██║██╔══██║██╔══██╗██╔══╝  ██║  ██║
███████║██║  ██║██║  ██║██║  ██║███████╗██████╔╝
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗  ██╗ █████╗ ██████╗ ███████╗██████╗
██╔════╝██║  ██║██╔══██╗██╔══██╗██╔════╝██╔══██╗
███████╗███████║███████║██████╔╝█████╗  ██║  ██║
╚════██║██╔══██║██╔══██║██╔══██╗██╔══╝  ██║  ██║
███████║██║  ██║██║  ██║██║  ██║███████╗██████╔╝
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗  ██╗ █████╗ ██████╗ ███████╗██████╗
██╔════╝██║  ██║██╔══██╗██╔══██╗██╔════╝██╔══██╗
███████╗███████║███████║██████╔╝█████╗  ██║  ██║
╚════██║██╔══██║██╔══██║██╔══██╗██╔══╝  ██║  ██║
███████║██║  ██║██║  ██║██║  ██║███████╗██████╔╝
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////
/*
███████╗██╗  ██╗ █████╗ ██████╗ ███████╗██████╗
██╔════╝██║  ██║██╔══██╗██╔══██╗██╔════╝██╔══██╗
███████╗███████║███████║██████╔╝█████╗  ██║  ██║
╚════██║██╔══██║██╔══██║██╔══██╗██╔══╝  ██║  ██║
███████║██║  ██║██║  ██║██║  ██║███████╗██████╔╝
╚══════╝╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝╚══════╝╚═════╝

*/
/////////////////////////////////////////////////////////////////////////////////////////

void function OnSpawnedPropDynamic( entity propDynamic )
{
	string scriptName = propDynamic.GetScriptName()

	if ( scriptName == "flyer_lab" )
		thread LabCreatureThink( propDynamic )

		if ( scriptName == "labrats_idlers" )
			thread LabRatIdlerThink( propDynamic )

}
/////////////////////////////////////////////////////////////////////////////////////////
void function LabRatIdlerThink( entity propDynamic )
{
	entity node = CreateScriptRef( propDynamic.GetOrigin(), propDynamic.GetAngles() )
	vector originOffset = PositionOffsetFromEnt( node, -15, 0, 0 )
	node.SetOrigin( originOffset )
	thread PlayAnimTeleport( propDynamic, propDynamic.kv.script_noteworthy, node )

}
/////////////////////////////////////////////////////////////////////////////////////////
void function OnSpawnedLevelNPC( entity npc )
{
	string scriptName = npc.GetScriptName()

	if ( scriptName == "lab_prowlers" )
	{
		thread LabCreatureThink( npc )

	}

	if ( scriptName == "soldiers_human_room_fight_01" )
		AttackPlayer( npc )


	//if ( scriptName == "doctor_science_intel_room_01" )
		//thread LabAlphaDoctorScienceThink( npc )

	if ( scriptName == "civilian_walker_evac_elevator_labs" )
		thread LabAlphaScientistThink( npc )

	if ( scriptName == "labA_dudes" )
		thread LabAlphaScientistThink( npc )

	if ( scriptName == "grunts_elevator" )
		thread GruntElevatorThink( npc )

	if ( scriptName == "prowlers_courtyard" )
		thread ProwlersAmbientThink( npc )

	if ( scriptName == "courtyard_responders" )
		thread CourtyardSoldiersThink( npc )

	if ( scriptName == "civilian_walker_courtyard" )
		thread CourtyardSoldiersThink( npc )

	if ( scriptName == "creature_surprised_dudes" )
		thread CreatureSurprisedSoldiersThink( npc )

	if ( scriptName == "elevator_turret_dudes" )
		thread HallwayTurretDudesThink( npc )

	if ( scriptName == "sphere_room_dudes" )
		thread GruntsSphereRoomThink( npc )

	if ( scriptName == "first_timeshift_soldiers" )
		AttackPlayer( npc )



}


void function LabCreatureThink( entity creature )
{
	creature.EndSignal( "PlayerInsideCage" )
	creature.EndSignal( "OnDeath" )
	creature.EndSignal( "OnDestroy" )

	thread AnimalCrueltyAcheivement( creature )
	wait 1 //need to wait for player to spawn, otherwise it may early out

	if ( creature.IsNPC() )
		creature.SetNoTarget( true )

	entity trigger
	entity node
	array <entity> linkedEnts = creature.GetLinkEntArray()
	foreach ( entity ent in linkedEnts )
	{
		if ( ent.GetClassName() == "script_ref" )
		{
			node = ent
			continue
		}
		if ( ent.GetClassName() == "trigger_multiple" )
		{
			trigger = ent
			continue
		}
	}
	//if ( creature.IsNPC() )
		//Assert( IsValid( trigger ), "creature at " + creature.GetOrigin() + " is not linked to a trigger"  )

	Assert( IsValid( node ), "creature at " + creature.GetOrigin() + " is not linked to a node"  )


	string animIdle = ""
	string animBreakout = ""
	string animAggroLoop = ""

	switch ( node.GetScriptName() )
	{
		case "variant01":
			animIdle = "pr_timeshift_caged_sleeping_01"
			animBreakout = "pr_timeshift_caged_sleeping_01_interrupt"
			animAggroLoop = "pr_timeshift_caged_small_aggro_01"
			break
		case "variant02":
			animIdle = "pr_timeshift_caged_sleeping_02"
			animBreakout = "pr_timeshift_caged_sleeping_02_interrupt"
			animAggroLoop = "pr_timeshift_caged_small_aggro_02"
			break
		case "variant03":
			animIdle = "pr_timeshift_caged_sleeping_03"
			animBreakout = "pr_timeshift_caged_sleeping_03_interrupt"
			animAggroLoop = "pr_timeshift_caged_small_aggro_03"
			break
		case "variant04":
			animIdle = "pr_timeshift_caged_laying_01"
			animBreakout = "pr_timeshift_caged_laying_01_interrupt"
			animAggroLoop = "pr_timeshift_caged_small_aggro_04"
			break
		case "variant05":
			animIdle = "pr_timeshift_caged_sitting_01"
			animBreakout = "pr_timeshift_caged_sitting_01_interrupt"
			animAggroLoop = "pr_timeshift_caged_small_aggro_05"
			break
		case "variant06":
			animIdle = "pr_timeshift_caged_standing_01"
			animBreakout = "pr_timeshift_caged_standing_01_interrupt"
			animAggroLoop = "pr_timeshift_caged_small_aggro_03"
			break
		case "variant07":
			animIdle = "pr_timeshift_caged_long_14"
			animBreakout = ""
			animAggroLoop = ""
			break
		case "variantCageTogeterA1":
			animIdle = "pr_timeshift_caged_long_06"
			animBreakout = ""
			animAggroLoop = ""
			break
		case "variantCageTogeterA2":
			animIdle = "pr_timeshift_caged_long_07"
			animBreakout = ""
			animAggroLoop = ""
			break
		case "variantCageTogeterA3":
			animIdle = "pr_timeshift_caged_long_08"
			animBreakout = ""
			animAggroLoop = ""
			break
		case "variantCageTogeterA4":
			animIdle = "pr_timeshift_caged_long_09"
			animBreakout = ""
			animAggroLoop = ""
			break
		case "variantCageTogeterA5":
			animIdle = "pr_timeshift_caged_long_10"
			animBreakout = ""
			animAggroLoop = ""
			break
		case "variantCageTogeterA6":
			animIdle = "pr_timeshift_caged_long_11"
			animBreakout = ""
			animAggroLoop = ""
			break
		case "variantCageTogeterA7":
			animIdle = "pr_timeshift_caged_long_12"
			animBreakout = ""
			animAggroLoop = ""
			break
		case "variantCageTogeterA8":
			animIdle = "pr_timeshift_caged_long_13"
			animBreakout = ""
			animAggroLoop = ""
			break
		case "variantCageTogeterB1":
			animIdle = "pr_timeshift_caged_long_01"
			animBreakout = ""
			animAggroLoop = ""
			break
		case "variantCageTogeterB2":
			animIdle = "pr_timeshift_caged_long_02"
			animBreakout = ""
			animAggroLoop = ""
			break
		case "variantCageTogeterB3":
			animIdle = "pr_timeshift_caged_long_03"
			animBreakout = ""
			animAggroLoop = ""
			break
		case "variantCageTogeterB4":
			animIdle = "pr_timeshift_caged_long_04"
			animBreakout = ""
			animAggroLoop = ""
			break
		case "variantCageTogeterB5":
			animIdle = "pr_timeshift_caged_long_05"
			animBreakout = ""
			animAggroLoop = ""
			break
		case "variantLab01":
			animIdle = "fl_timeshift_caged_tall_laying_01"
			animBreakout = "fl_timeshift_caged_tall_interrupt_01"
			animAggroLoop = "fl_timeshift_caged_tall_aggro_01"
			break
		case "variantLab02":
			animIdle = "fl_timeshift_caged_tall_laying_02"
			animBreakout = "fl_timeshift_caged_tall_interrupt_02"
			animAggroLoop = "fl_timeshift_caged_tall_aggro_02"
			break
		case "variantLab03":
			animIdle = "fl_timeshift_caged_tall_laying_03"
			animBreakout = "fl_timeshift_caged_tall_interrupt_03"
			animAggroLoop = "fl_timeshift_caged_tall_aggro_03"
			break
		case "variantLab04":
			animIdle = "fl_timeshift_caged_tall_laying_04"
			animBreakout = "fl_timeshift_caged_tall_interrupt_04"
			animAggroLoop = "fl_timeshift_caged_tall_aggro_04"
			break
		case "variantCylinder01":
			animIdle = "fl_timeshift_caged_cylinder_01"
			animBreakout = ""
			animAggroLoop = ""
			thread PlayDeathAnimWhenShot( creature, "fl_timeshift_caged_cylinder_death_01" )
			break
		case "variantCylinder02":
			animIdle = "fl_timeshift_caged_cylinder_02"
			animBreakout = ""
			animAggroLoop = ""
			thread PlayDeathAnimWhenShot( creature, "fl_timeshift_caged_cylinder_death_01" )
			break
		default:
			Assert( 0, "creatureNode at " + node.GetOrigin() + " has an unhandled script_name" )

	}

	//-------------------------------------------------------------
	// Go back into AI if this thread ends (player inside cage)
	//--------------------------------------------------------------

	OnThreadEnd(
	function() : ( creature )
		{
			if ( !IsAlive( creature ) )
				return
			creature.Anim_Stop()
		}
	)

	//------------------------------------------
	// Play chill idle
	//------------------------------------------
	thread PlayAnimTeleport( creature, animIdle, node )

	array <entity> players = GetPlayerArray()
	if ( players.len() <= 0 )
		return
	entity player = players[ 0 ]

	if ( ( creature.IsNPC() ) && ( trigger != null ) )
		thread LabProwlerPlayerInsideCage( creature, trigger, player )

	while( !PlayerInRange( player.GetOrigin(), creature.GetOrigin(), 256 ) )
		wait 0.2

	wait ( RandomFloatRange( 0, 0.8 ) )

	//------------------------------------------
	// Player close, breakout into aggro idle
	//------------------------------------------
	if ( animBreakout != "" )
		waitthread PlayAnim( creature, animBreakout, node )

	if ( animAggroLoop != "" )
		thread PlayAnim( creature, animAggroLoop, node )


	WaitForever()
}


void function AnimalCrueltyAcheivement( creature )
{
	if ( Flag( "AcheivementUnlockedLabProwler") )
		return
	if ( !creature.IsNPC() )
		return
	if ( creature.GetClassName() != "npc_prowler" )
		return

	if ( Flag( "AcheivementUnlockedLabProwler") )
		return

	FlagEnd( "AcheivementUnlockedLabProwler" )


	//To do: detect if killed by the player
	//creature.WaitSignal( "OnDeath" )


}
void function PlayDeathAnimWhenShot( entity propCreature, string anim )
{




}

void function LabProwlerPlayerInsideCage( entity prowler, entity trigger, entity player )
{
	prowler.EndSignal( "OnDeath" )
	player.EndSignal( "OnDeath" )

	trigger.WaitSignal( "OnTrigger" )

	prowler.Signal( "PlayerInsideCage" )

}


void function PlayMusicInTimezoneUntilFlag( string track, var timeZone, string flagToAbort )
{
	if ( Flag( flagToAbort ) )
		return

	FlagEnd( flagToAbort )

	var otherTimeZone
	if ( timeZone == TIMEZONE_NIGHT )
		otherTimeZone = TIMEZONE_DAY
	else
		otherTimeZone = TIMEZONE_NIGHT

	while( true )
	{

		waitthread WaittillPlayerSwitchesTimezone( timeZone )

		StopMusic()
		PlayMusic( track )

		waitthread WaittillPlayerSwitchesTimezone( otherTimeZone )
	}
}




void function DebugX( entity player )
{
	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )

	entity soundEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )

	waitthread PlayTimeShiftDialogue( player, soundEnt, "diag_sp_wildlifeStudy_TS191_18_01_imc_grunt3" )
}