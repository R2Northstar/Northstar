global function CodeCallback_MapInit

#if DEV
global function skyboxchange
global function GetOGPilot
global function wallruntest
global function Record_ZenGarden_Wallrun
global function Record_ZenGarden_Slide
global function Record_ZenGarden_DoubleJump
global function shutdownscreentest
global function SendTrainingGauntletStats
global function FancyTeleport_EffectsAndSound
global function Training_WeaponRacks_SetSolidity
global function setfakeinstalldone

global function Training_EnvArtColorCorrection_SetEnabled
global function SimpleScreenShake
global function GetSkitGuyInfo_ByName
global function NudgeSkitGuy
#endif

const MARVIN_MODEL 							= $"models/robots/marvin/marvin.mdl"
const asset FX_POD_LASER 					= $"P_pod_scan_laser_FP"
const asset FX_POD_GLOWLIGHT 				= $"P_pod_door_glow_FP"
const asset FX_POD_SCREEN_IN				= $"P_pod_screen_lasers_IN"
const asset FX_POD_SCREEN_OUT				= $"P_pod_screen_lasers_OUT"
const asset FX_POD_DLIGHT_CONSOLE1 			= $"P_pod_Dlight_console1"
const asset FX_POD_DLIGHT_CONSOLE2 			= $"P_pod_Dlight_console2"
//const asset FX_POD_DLIGHT_BACKLIGHT_SIDE 	= $"P_pod_Dlight_backlight_side"
//const asset FX_POD_DLIGHT_BACKLIGHT_TOP 	= $"P_pod_Dlight_backlight_top"
const asset FX_FANCY_TELEPORT_ENV_PULSE 	= $"P_ar_holopulse_CP"
const asset FX_COCKPIT_LIGHT 				= $"xo_cockpit_dlight"
const asset OG_PILOT_HELMET_MODEL 			= $"models/Humans/heroes/mlt_hero_anderson_helmet.mdl"
const asset ANDERSON_PILOT_MODEL 			= $"models/humans/heroes/mlt_hero_anderson.mdl"
const asset PILOT_MODEL_BAY1 				= $"models/humans/pilots/sp_medium_geist_f.mdl"
const asset PILOT_MODEL_BAY2 				= $"models/humans/pilots/sp_medium_reaper_m.mdl"
const asset BUDDY_MODEL_POSED_NO_ANIMS 		= $"models/Titans/buddy/BT_posed.mdl"
const asset SAFETY_BATON_MODEL 				= $"models/industrial/safety_baton.mdl"

const asset OG_PILOT_MODEL 					= $"models/humans/heroes/mlt_hero_lastimosa.mdl"
const int OG_PILOT_MODEL_HEAD_IDX_BARE 		= 0
const int OG_PILOT_MODEL_HEAD_IDX_HELMET 	= 2
const int OG_PILOT_MODEL_DECAL_IDX 			= 0
const int OG_PILOT_MODEL_DECAL_IDX_BARE 	= 1

const string OG_WEAPON = "mp_weapon_rspn101"

const string ANIM_OG_STANDING_IDLE 		= "OG_stand_upright_idle"
const string ANIM_OG_STANDING_TALK 		= "OG_stand_upright_talk"
const string ANIM_OG_SITTING_IDLE 		= "OG_sit_high_idle"
const string ANIM_OG_SITTING_TALK 		= "OG_sit_high_talk"
const string ANIM_OG_LEANING_IDLE 		= "OG_stand_lean_idle"
const string ANIM_OG_LEANING_TALK 		= "OG_stand_lean_talk"

const int SCRIPTED_PATH_WALK 	= 0
const int SCRIPTED_PATH_RUN 	= 1

const int MAX_RECREATED_OLD_WEAPONS = 16

const float TITANFALL_NAG_DURATION = 3.0  // extra time compensation for nag line playing when titanfall started

const string TRAINING_PLAYER_SETTINGS = "pilot_solo_training"

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

struct LoudspeakerVO_Info
{
	string scriptAlias
	string soundAlias
	float duration
}

struct FiringRangeTarget
{
	entity ent
	entity angleRefEnt
	entity mover
	bool wasDamaged
	vector ogAngles
}

struct SkitGuyInfo
{
	int 	id
	string 	name
	string 	skitAnim
	entity 	guy
	entity 	skitRef
}

struct HangarTitanGroup
{
	entity 	ref

	entity 	titan
	entity 	rack
	entity 	marvin
	entity 	pilot

	int 	titanSkin = -1

	string 	titanAnim
	string 	rackAnim
	string 	marvinAnim
	string 	pilotAnim

	asset 	pilotModel

	vector 	rack_ogPos
	vector 	rack_ogAng

	float 	sequenceDuration
	float 	animInitialTime = 0.0

	bool 	isInited = false
}

struct TrainingGauntletStats
{
	bool didBeatRequiredTime 			= false
	int numRunsBeforeBeatRequiredTime 	= 0
	int numChallengeRuns 				= 0
	int numRestarts 					= 0
	float bestTime 						= -1.0
	int recommendedDifficulty 			= 0
}

struct
{
	#if DEV
	bool fakeInstallDone = false
	#endif

	bool 	gauntletMode = false

	entity 	player
	int 	playerInputType

	entity ogPilot
	entity ogTwin
	entity anderson
	entity titanTwin
	entity ogHelmet
	entity playerAnimWeapon

	entity ogPathMover

	entity animref_hangar
	entity animref_leaveGauntlet

	entity trainingPod
	array<TrainingPod_GlowLightRow> trainingPodGlowLightRows
	array<entity> trainingPodGlowLightFXHandles
	array<TrainingPod_dLightMapping> trainingPodDLightMappings
	array<TrainingPod_LaserEmitter> trainingPodLaserEmitters

	float postWallrunVOEndTime = -1

	float titanfallNagStartTime = -1
	vector playerTitanCallInPos

	entity envArt_colorCorrectionEnt
	entity skycam_default
	entity skycam_glitch

	table<string,LoudspeakerVO_Info> loudspeakerVO = {}
	entity loudspeaker

	array<FiringRangeTarget> firingRangeTargets = []

	//table<string,SkitGuyInfo> skitguys = {}
	array<SkitGuyInfo> skitguys = []

	TrainingGauntletStats trainingGauntletStats

	array<entity> scriptCreatedWeaponPickups = []
	bool weaponPickupsHaveAmmo = false

	bool displayWeaponHUD = true
} file

void function CodeCallback_MapInit()
{
	FlagSet( "FlightPath_TitanDrop" )

	PrecacheParticleSystem( FX_POD_LASER )
	PrecacheParticleSystem( FX_POD_GLOWLIGHT )
	PrecacheParticleSystem( FX_POD_SCREEN_IN )
	PrecacheParticleSystem( FX_POD_SCREEN_OUT )
	PrecacheParticleSystem( FX_POD_DLIGHT_CONSOLE1 )
	PrecacheParticleSystem( FX_POD_DLIGHT_CONSOLE2 )
	//PrecacheParticleSystem( FX_POD_DLIGHT_BACKLIGHT_SIDE )
	//PrecacheParticleSystem( FX_POD_DLIGHT_BACKLIGHT_TOP )
	PrecacheParticleSystem( FX_FANCY_TELEPORT_ENV_PULSE )
	PrecacheParticleSystem( FX_COCKPIT_LIGHT )

	PrecacheModel( OG_PILOT_HELMET_MODEL )
	PrecacheModel( OG_PILOT_MODEL )
	PrecacheModel( ANDERSON_PILOT_MODEL )
	PrecacheModel( PILOT_MODEL_BAY1 )
	PrecacheModel( PILOT_MODEL_BAY2 )
	PrecacheModel( BUDDY_MODEL_POSED_NO_ANIMS )
	PrecacheModel( SAFETY_BATON_MODEL )
	PrecacheModel( MARVIN_MODEL )
	PrecacheModel( DATA_KNIFE_MODEL )

	LoudspeakerVO_Setup()
	Training_SharedInit()

	RegisterSignal( "ButtonPressedJump" )
	RegisterSignal( "ButtonPressedAttack" )
	RegisterSignal( "PodIntro_OG_StartPodAnim" )
	RegisterSignal( "PodInteriorSequenceDone" )
	RegisterSignal( "FancyTeleportStart" )
	RegisterSignal( "TargetRotate" )
	RegisterSignal( "TargetDamaged" )
	RegisterSignal( "Target_WaitForDamage_Start" )
	RegisterSignal( "StopRepeatingGhostRecorder" )
	RegisterSignal( "FiringRange_StopResettingTargets" )
	RegisterSignal( "Gauntlet_StopTeleportingPlayerAtFinishLine" )
	RegisterSignal( "FirstRun_OG_Creates_Ghost" )
	RegisterSignal( "GauntletChallenge_FirstGhostAppear" )
	RegisterSignal( "PlayerMadeSelection" )
	RegisterSignal( "TrainingPod_BeginInteriorShutdown" )
	RegisterSignal( "NPC_NewCommand" )
	RegisterSignal( "LoudspeakerVO_Stop" )
	RegisterSignal( "glitch_start" )

	FlagInit( "PlayerPressedUse" )
	FlagInit( "PlayerReloaded" )
	FlagInit( "PodIntro_PodDoorsClosed" )
	FlagInit( "PlayerLookedAtTopTarget" )
	FlagInit( "PlayerLookedAtBottomTarget" )
	FlagInit( "PodIntro_InteriorBootSequence_Starting" )
	FlagInit( "OG_WhyWeFight_VO_Done" )
	FlagInit( "FiringRange_Approach_OG_Sequence_Done" )
	FlagInit( "ReloadTraining_PlayerPressedReload" )
	FlagInit( "PlayerSprinted" )
	FlagInit( "PlayerADSed" )
	FlagInit( "FiringRangeWeaponSwapped" )
	FlagInit( "FiringRange_AllTargetsKilled" )
	FlagInit( "OG_MovedTo_GauntletEntrance" )
	FlagInit( "Gauntlet_FirstRun_All_VO_Finished" )
	FlagInit( "Gauntlet_FirstRun_Done" )
	FlagInit( "ChallengeIntro_VO_Done" )
	FlagInit( "Gauntlet_PlayingFeedbackVO" )
	FlagInit( "PlayerUsedConversationInterface" )
	FlagInit( "GauntletExitConvo_FinishedResponse" )
	FlagInit( "TitanfallIntroConvo_FinishedResponse" )
	FlagInit( "PlayerConfirmedGauntletExit" )
	FlagInit( "PlayerLeavingGauntlet" )
	FlagInit( "PlayerStartedTitanfall" )
	FlagInit( "Titanfall_OG_FallingIn_VO_Start" )
	FlagInit( "TitanfallGlitchStart" )
	FlagInit( "PlayerWorldChangeThread" )
	FlagInit( "Glitch_WorldChanging_Zen" )
	FlagInit( "Glitch_WorldChanging_NonZen" )
	FlagInit( "PodOutroStarted" )
	FlagInit( "SimPodShutdown_LoudspeakerVO_Done" )
	FlagInit( "MeetOG_StartScene" )
	FlagInit( "CadillacMoment_MeetOG_Done" )
	FlagInit( "CadillacMoment_MeetOG_StartFadeOut" )
	FlagInit( "MeetOG_VO_Done" )

	FlagClear( "AutomaticCheckpointsEnabled" )

	AddClientCommandCallback( "Training_SetInputType", ClientCommand_Training_SetInputType )
	AddClientCommandCallback( "Training_PlayerPressedUse", ClientCommand_Training_PlayerPressedUse )
	AddClientCommandCallback( "Training_PlayerReloaded", ClientCommand_Training_PlayerReloaded )
	AddClientCommandCallback( "topTarget", ClientCommand_LookTarget_Top )
	AddClientCommandCallback( "bottomTarget", ClientCommand_LookTarget_Bottom )

	AddCallback_EntitiesDidLoad( EntitiesDidLoad )
	AddPlayerDidLoad( Training_PlayerDidLoad )
	AddCallback_OnLoadSaveGame( Training_OnLoadSaveGame )

	AddDamageCallback( "func_brush", Training_FuncBrush_OnDamaged )

	TimerInit( "firingRangeNag", 15.0 )
	TimerInit( "installWaitComment", 60.0 )

	AddStartPoint( "Pod Intro", 			Training_PodIntro, 			null, 								Training_Skipped_PodIntro )
	AddStartPoint( "Basic Movement", 		Training_BasicMovement, 	Training_Setup_BasicMovement, 		Training_Skipped_BasicMovement )
	AddStartPoint( "Zen Garden", 			Training_ZenGarden, 		Training_Setup_ZenGarden, 			Training_Skipped_ZenGarden )
	AddStartPoint( "Firing Range", 			Training_FiringRange, 		Training_Setup_FiringRange, 		Training_Skipped_FiringRange )
	AddStartPoint( "Gauntlet", 				Training_Gauntlet, 			Training_Setup_Gauntlet, 			Training_Skipped_Gauntlet )
	AddStartPoint( "Gauntlet Challenge", 	Training_GauntletChallenge, Training_Setup_GauntletChallenge, 	Training_Skipped_GauntletChallenge )
	AddStartPoint( "Titanfall", 			Training_Titanfall, 		Training_Setup_Titanfall, 			Training_Skipped_Titanfall )
	AddStartPoint( "Pod Outro", 			Training_PodOutro, 			Training_Setup_PodOutro, 			Training_Skipped_PodOutro )
	AddStartPoint( "Meet OG", 				Training_MeetOG, 			Training_Setup_MeetOG, 				Training_Skipped_MeetOG )
	AddStartPoint( "Gauntlet Mode", 		Training_GauntletModeStart, Training_Setup_GauntletMode, 		null 	)

	#if DEV
	AddStartPoint( "DEV_GHOSTREC_GAUNTLET_FIRSTRUN", TrainingGauntlet_RecordGhostStart_FirstRun, null, null )
	AddStartPoint( "DEV_GHOSTREC_GAUNTLET_CHAL_WIP", TrainingGauntlet_RecordGhostStart_Challenge_WIP, null, null )
	AddStartPoint( "DEV_GHOSTREC_GAUNTLET_CHAL_01", TrainingGauntlet_RecordGhostStart_Challenge_01, null, null )
	AddStartPoint( "DEV_GHOSTREC_GAUNTLET_CHAL_02", TrainingGauntlet_RecordGhostStart_Challenge_02, null, null )
	AddStartPoint( "DEV_GHOSTREC_GAUNTLET_CHAL_03", TrainingGauntlet_RecordGhostStart_Challenge_03, null, null )
	AddStartPoint( "DEV_GHOSTREC_GAUNTLET_CHAL_04", TrainingGauntlet_RecordGhostStart_Challenge_04, null, null )
	AddStartPoint( "DEV_GHOSTREC_GAUNTLET_CHAL_05", TrainingGauntlet_RecordGhostStart_Challenge_05, null, null )
	AddStartPoint( "DEV_GHOSTREC_GAUNTLET_CHAL_06", TrainingGauntlet_RecordGhostStart_Challenge_06, null, null )
	AddStartPoint( "DEV_GHOSTREC_GAUNTLET_CHAL_07", TrainingGauntlet_RecordGhostStart_Challenge_07, null, null )
	AddStartPoint( "DEV_GHOSTREC_GAUNTLET_CHAL_08", TrainingGauntlet_RecordGhostStart_Challenge_08, null, null )
	AddStartPoint( "DEV_GHOSTREC_GAUNTLET_CHAL_09", TrainingGauntlet_RecordGhostStart_Challenge_09, null, null )

	AddStartPoint( "Pod Intro DEV", DEV_PodIntro, null, null )
	AddStartPoint( "Pod Outro DEV", DEV_PodOutro, null, null )
	#endif
}


void function EntitiesDidLoad()
{
	QuickDeathTrigger_SetIsPunitive( false )

	SetupTrainingPod()
	TrainingPod_GlowLightsArraySetup()

	FiringRangeTargets_Init()

	file.animref_hangar = GetEntByScriptName( "animref_hangar" )
	file.animref_hangar.DisableHibernation()

	file.skycam_default = GetEnt( "skybox_cam_level" )
	file.skycam_glitch = GetEnt( "skybox_cam_glitch" )
}


void function Training_PlayerDidLoad( entity player )
{
	player.SetNoTarget( true )
	SetGlobalForcedDialogueOnly( true )

	AddButtonPressedPlayerInputCallback( player, IN_JUMP, Training_ButtonPressedJump )
	AddButtonPressedPlayerInputCallback( player, IN_ATTACK, Training_ButtonPressedAttack )

	file.envArt_colorCorrectionEnt = GetEnt( "color_correction_1" )

	file.player = player

	EnableDemigod( player )

	player.ForceMPAimassist()  // TODO doublecheck this

	player.SetSkyCamera( file.skycam_default )

	Training_WeaponPickups_Init( player )
	player.PreventWeaponDestroyNoAmmo()  // makes it so when player swaps empty weapon for another pickup, doesn't destroy empty weapon

	thread Training_PlayerQuickdeathSFX( player )

	DisableFriendlyHighlight()
}


void function Training_OnLoadSaveGame( entity player )
{
	thread Training_OnLoadSaveGame_Think( player )
}

void function Training_OnLoadSaveGame_Think( entity player )
{
	EndSignal( player, "OnDestroy" )

	wait 0.5  // HACK have to wait otherwise it doesn't work
	SetWeaponHUDEnabled( player, file.displayWeaponHUD )
}


void function Training_ButtonPressedJump( entity player )
{
	player.Signal( "ButtonPressedJump" )
}

void function Training_ButtonPressedAttack( entity player )
{
	player.Signal( "ButtonPressedAttack" )
}

void function Training_FuncBrush_OnDamaged( entity ent, var damageInfo )
{
	if( !IsValid( ent ) )
		return

	entity attacker = DamageInfo_GetAttacker( damageInfo )

	if ( ent.GetScriptName() == "firingrange_target" )
	{
		if ( IsValid( attacker ) && attacker.IsPlayer() )
		{
			table<string,vector> resultTable = {}
			resultTable["damagePos"] <- DamageInfo_GetDamagePosition( damageInfo )
			ent.Signal( "TargetDamaged", resultTable )
		}
	}
}


// ==============================
// ========= POD INTRO ==========
// ==============================
void function Training_Skipped_PodIntro( entity player )
{
	player.SetExtraWeaponMods( [ "low_ammo_disable" ] )
	SetWeaponHUDEnabled( player, false )
}

#if DEV
// bare bones start in pod
void function DEV_PodIntro( entity player )
{
	player.EndSignal( "OnDestroy" )

	TakeAllWeapons( player )

	player.SetExtraWeaponMods( [ "low_ammo_disable" ] )
	SetWeaponHUDEnabled( player, false )

	Training_EnvArtColorCorrection_SetEnabled( false )
	SetDoF_Hangar( player )

	thread PodIntro_BackgroundSkits( player )

	entity pod = file.trainingPod

	TrainingPod_PlayerSequence_DoorsOpenIdle( player, false )

	// anim starts at a slightly different spot
	player.SetOrigin( < 10564, -10235, -6056.9 > )
	player.SetAngles( < -6, 90, 0 > )

	WaitForever()
}
#endif //DEV


void function Training_PodIntro( entity player )
{
	player.EndSignal( "OnDestroy" )

	player.SetExtraWeaponMods( [ "low_ammo_disable" ] )
	SetWeaponHUDEnabled( player, false )

	Training_EnvArtColorCorrection_SetEnabled( false )

	entity pod = file.trainingPod

	OnThreadEnd(
		function() : ( player, pod )
		{
			if ( IsValid( player ) )
			{
				player.Anim_Stop()
				ClearPlayerAnimViewEntity( player )
				player.ClearParent()
				player.UnforceStand()

				Training_EnvArtColorCorrection_SetEnabled( true )
			}

			if ( IsValid ( pod ) )
			{
				pod.Anim_Stop()

				thread TrainingPod_ResetLaserEmitterRotation( pod )
				thread TrainingPod_KillLasers( pod )
				thread TrainingPod_KillGlowFX( pod )
				TrainingPod_KillInteriorDLights()
			}
		}
	)

	// NORMAL LEVEL START
	SetDoF_Hangar( player )

	ShowIntroScreen( player )

	thread PodIntro_MeetOG( player )

	TrainingPod_PlayerSequence_DoorsOpenIdle( player )

	FlagWait( "IntroScreenFading" )
	wait 1.2
	Remote_CallFunction_Replay( player, "ScriptCallback_LevelIntroText" )
	wait 4.2  // matches fade time in sp_introscreen data

	thread PodIntro_BackgroundSkits( player )


	player.Signal( "PodIntro_OG_StartPodAnim" )

	// time for OG to animate before starting viewmodel anim
	wait 11.8

	FirstPersonSequenceStruct playerSequence
	playerSequence.blendTime 			= 0.25
	playerSequence.attachment 			= "REF"
	playerSequence.firstPersonAnim 		= "ptpov_trainingpod_doors_close"
	playerSequence.firstPersonAnimIdle 	= "ptpov_trainingpod_idle"
	playerSequence.thirdPersonAnim 		= "pt_trainingpod_doors_close"
	playerSequence.thirdPersonAnimIdle 	= "pt_trainingpod_idle"
	playerSequence.viewConeFunction 	= TrainingPod_ViewConeLock_SemiStrict
	playerSequence.renderWithViewModels = true

	FirstPersonSequenceStruct podSequence
	podSequence.blendTime 				= 0.25
	podSequence.thirdPersonAnim 		= "trainingpod_doors_close"
	podSequence.thirdPersonAnimIdle 	= "trainingpod_doors_close_idle"
	podSequence.renderWithViewModels 	= true

	entity viewmodel = player.GetFirstPersonProxy()

	if ( !HasAnimEvent( viewmodel, "PlaySound_SimPod_DoorShut" ) )
		AddAnimEvent( viewmodel, "PlaySound_SimPod_DoorShut", PlaySound_SimPod_DoorShut )

	// HACK this should be based on an anim event
	thread TrainingPod_KillInteriorDLights_Delayed( player, 2.65 )

	thread FirstPersonSequence( podSequence, pod )
	waitthread FirstPersonSequence( playerSequence, player, pod )

	FlagSet( "PodIntro_PodDoorsClosed" )

	TrainingPod_ViewConeLock_PodClosed( player )

	waitthread LookTraining( player )

	// "Let's see how much you remember from last time."
	waitthread PlayDialogue( "og_how_much_you_remember", player )

	// "Setting the neural link."
	waitthread PlayDialogue( "og_neural_link", player )

	// "Not quite the same as a Titan link, but it's similar."
	waitthread PlayDialogue( "og_neural_link_2", player )

	thread TrainingPod_Interior_BootSequence( player )

	// "To learn new skills, we need to be in the right state of mind."
	thread PlayDialogue( "og_simulation_starting", player, 2.5 )

	player.WaitSignal( "PodInteriorSequenceDone" )
	printt( "POD SEQUENCE DONE" )

	wait 2.0  // timed to match the screen effect white screen flash

	SetDoF_Default( player )
}

void function PlaySound_SimPod_DoorShut( entity playerFirstPersonProxy  ) //Hack, needed for wargames but has unfortunate side effect for Training. 
{
	entity player = playerFirstPersonProxy.GetOwner()
	if ( !IsValid( player ) )
		return

	EmitSoundOnEntityOnlyToPlayer( player, player, "NPE_Scr_SimPod_DoorShut" )

}

void function PodIntro_MeetOG( entity player )
{
	entity animref = file.animref_hangar
	vector animrefOrigin = animref.GetOrigin()
	vector animrefAngles = animref.GetAngles()
	vector btSpawnOrg = <0,0,0>  // to avoid red text errors about BT spawning in solid

	entity animEnt = CreateScriptMover( animrefOrigin, animrefAngles )

	// Spawn scene actors
	entity og = Training_SpawnOGPilot( animref )
	Training_OGPilot_SetHelmetOn( og, false )
	AddAnimEvent( file.ogPilot, "pod_slap", PodIntro_OG_Slaps_Pod )

	TitanLoadoutDef loadout = GetTitanLoadoutForCurrentMap()
	entity bt = CreateAutoTitanForPlayer_FromTitanLoadout( player, loadout, btSpawnOrg, animrefAngles )
	SetSpawnOption_AISettings( bt, "npc_titan_buddy" )
	bt.kv.spawnflags = SF_NPC_ALLOW_SPAWN_SOLID
	DispatchSpawn( bt )
	FreeAutoTitan( bt )  // HACK this disables the worldspace BT locator icon
	TakeAllWeapons( bt )

	array<entity> actors = [ bt, og ]

	asset btWeaponModel = GetWeaponInfoFileKeyFieldAsset_Global( "mp_titanweapon_xo16_shorty", "playermodel" )
	Assert( btWeaponModel != $"" )
	entity btWeapon = CreatePropDynamic( btWeaponModel )
	btWeapon.SetParent( bt, "PROPGUN" )

	asset ogWeaponModel = GetWeaponInfoFileKeyFieldAsset_Global( OG_WEAPON, "playermodel" )
	Assert( ogWeaponModel != $"" )
	entity ogWeapon = CreatePropDynamic( ogWeaponModel )
	ogWeapon.SetParent( og, "PROPGUN" )

	entity ogHelmet = CreatePropDynamic( OG_PILOT_HELMET_MODEL )
	ogHelmet.DisableHibernation()

	array<entity> props = [ btWeapon, ogWeapon, ogHelmet ]

	OnThreadEnd(
	function() : ( actors, props, animEnt )
		{
			if ( IsValid( file.ogPilot ) )
				DeleteAnimEvent( file.ogPilot, "pod_slap" )

			foreach ( weapon in props )
			{
				if ( IsValid( weapon ) )
				{
					weapon.ClearParent()
					weapon.Destroy()
				}
			}

			foreach ( actor in actors )
			{
				if ( !IsValid( actor ) )
					continue

				actor.ClearParent()

				if ( IsInvincible( actor ) )
					ClearInvincible( actor )

				if ( !actor.IsPlayer() )
					actor.Destroy()
			}

			if ( IsValid( animEnt ) )
				animEnt.Destroy()
		}
	)

	foreach ( guy in actors )
	{
		MakeInvincible( guy )
		guy.SetEfficientMode( true )
		Highlight_ClearFriendlyHighlight( guy )
	}

	string anim_og_idle 		= "pt_OG_training_rail_sit_idle"
	string anim_og_helmet_idle 	= "helmet_intro_scene_OG_idle"
	string anim_bt_idle 		= "BT_intro_scene_OG_idle"

	string anim_og 				= "pt_pod_setup_OG"
	string anim_bt 				= "BT_pod_setup_OG"

	thread PlayAnimTeleport( og, anim_og_idle, animEnt )
	thread PlayAnimTeleport( ogHelmet, anim_og_helmet_idle, animEnt )
	thread PlayAnimTeleport( bt, anim_bt_idle, animEnt )

	player.WaitSignal( "PodIntro_OG_StartPodAnim" )

	if ( !IsValid( og ) )
		return

	og.Anim_Stop()
	thread PlayAnim( og, anim_og, animEnt )

	bt.Anim_Stop()
	thread PlayAnim( bt, anim_bt, animEnt )

	float animDuration = og.GetSequenceDuration( anim_og )
	wait animDuration - 0.1

	if ( !IsValid( og ) )
		return

	og.Anim_Stop()
	thread PlayAnimTeleport( og, anim_og_idle, animEnt )

	bt.Anim_Stop()
	thread PlayAnimTeleport( bt, anim_bt_idle, animEnt )

	// wait for look training to get started before killing the scene
	FlagWaitAny( "PlayerLookedAtTopTarget", "PlayerLookedAtBottomTarget" )
}

void function PodIntro_OG_Slaps_Pod( entity ogPilot )
{
	array<entity> players = GetPlayerArray()
	if ( !players.len() )
		return

	entity player = players[0]
	if ( !IsValid( player ) )
		return

	float shakeDuration = 0.45
	float shakeAmplitude = 0.14
	float screenBlurFrac = 0
	SimpleScreenShake( player, shakeDuration, shakeAmplitude, screenBlurFrac )
}

void function LookTraining( entity player )
{
	thread LookTraining_StartNag( player, "PlayerLookedAtTopTarget", "PlayerLookedAtBottomTarget" )

	Remote_CallFunction_Replay( player, "ScriptCallback_ShowInvertCrosshair", true )

	// LOOKAT SECTION
	Remote_CallFunction_Replay( player, "ScriptCallback_SetupLookTargets" )
	wait 0.5
	Remote_CallFunction_Replay( player, "ScriptCallback_LookTargets_WaitForLookat" )

	DialogueGroup invertConfirmVO = GetDialogueGroup( "ogInvertConfirm" )

	int numInverts = 0
	int maxInverts = 2
	//while ( numInverts < maxInverts )
	while ( 1 )
	{
		Remote_CallFunction_Replay( player, "ScriptCallback_SetupLookTargets" )
		wait 0.5
		Remote_CallFunction_Replay( player, "ScriptCallback_LookTargets_WaitForLookat" )

		string hintAlias = "invert_look_at_lights"
		if ( numInverts > 0 )
			hintAlias = "invert_look_at_lights_again"

		// only play this VO once
		if ( numInverts == 1 )
		{
			// "You sure?"
			thread PlayDialogue( "og_invert_confirm_3", player )
		}

		DisplayOnscreenHint( player, hintAlias )

		printt( "Waiting for player to look at either target" )

		FlagWaitAny( "PlayerLookedAtTopTarget", "PlayerLookedAtBottomTarget" )

		printt( "Player looked at one of the targets" )

		hintAlias = "invert_look_at_lights_1_left"
		if ( numInverts > 0 )
			hintAlias = "invert_look_at_lights_again_1_left"

		DisplayOnscreenHint( player, hintAlias )

		FlagWait( "PlayerLookedAtTopTarget" )
		FlagWait( "PlayerLookedAtBottomTarget" )

		printt( "Player looked at both targets" )

		hintAlias = "invert_look_at_lights_0_left"
		if ( numInverts > 0 )
			hintAlias = "invert_look_at_lights_again_0_left"

		DisplayOnscreenHint( player, hintAlias )

		printt( "invert waiting for OG dialogue" )

		// "Does that feel right to you?"
		// "How about now? Feel alright?"
		string askAlias = DialogueGroup_GetNextLine( invertConfirmVO )
		waitthread PlayDialogue( askAlias, player )

		printt( "invert OG dialogue done" )

		ClearOnscreenHint( player )

		string invertConvar = file.playerInputType == 0 ? INVERT_CONVAR_GAMEPAD : INVERT_CONVAR_MOUSE
		printt( "invertConvar:", invertConvar )
		bool invertSettingBeforeMenu = GetConVarBool( invertConvar )

		printt( "Opening invert look dialog" )

		// THIS PAUSES THE GAME UNTIL MENU IS CLOSED
		Remote_CallFunction_UI( player, "ScriptCallback_OpenInvertLookDialog" )
		wait 0.5  // let the game come back after menu is closed

		// if player didn't change setting, don't repeat
		invertConvar = file.playerInputType == 0 ? INVERT_CONVAR_GAMEPAD : INVERT_CONVAR_MOUSE
		printt( "invertConvar:", invertConvar )
		if ( GetConVarBool( invertConvar ) == invertSettingBeforeMenu )
		{
			printt( "player didn't change setting, not repeating" )
			break
		}

		printt( "invert- player changed setting, repeating to confirm" )

		numInverts++

		// kill lights and reset flags
		Remote_CallFunction_Replay( player, "ScriptCallback_LookTargets_KillLights" )

		FlagClear( "PlayerLookedAtTopTarget" )
		FlagClear( "PlayerLookedAtBottomTarget" )
	}

	ClearOnscreenHint( player )
	Remote_CallFunction_Replay( player, "ScriptCallback_ShowInvertCrosshair", false )

	// "Alright, we're good to go."
	waitthread PlayDialogue( "og_invert_complete", player )

	TrainingPod_ViewConeLock_PodClosed( player )

	TrainingPod_ViewConeLock_SemiStrict( player )  // recenter player view
	Remote_CallFunction_Replay( player, "ScriptCallback_LookTargets_KillLights" )
}

void function LookTraining_StartNag( entity player, string flag1, string flag2 )
{
	EndSignal( player, "OnDestroy" )

	if ( Flag( flag1 ) || Flag( flag2 ) )
		return

	FlagEnd( flag1 )
	FlagEnd( flag2 )

	float nagInterval = 15.0
	float nextNagTime = Time() + nagInterval

	while( 1 )
	{
		wait 1

		if ( Time() < nextNagTime )
			continue

		// "We have to calibrate the pod. It won't boot up until you look at both of those lights."
		waitthread PlayDialogue( "og_pod_calibrate", player )

		nextNagTime = Time() + nagInterval
	}
}

void function TrainingPod_PlayerSequence_DoorsOpenIdle( entity player, bool doPlayerAnim = true )
{
	entity pod = file.trainingPod

	// Have to do this first so the anim starts centered on the ref attachment angles
	string podAttach = "REF"
	int attachID = pod.LookupAttachment( podAttach )
	vector podRefOrg = pod.GetAttachmentOrigin( attachID )
	vector podRefAng = pod.GetAttachmentAngles( attachID )
	player.SetOrigin( podRefOrg )
	player.SetAngles( podRefAng )
	player.ForceStand()

	player.DisableWeapon()

	// default start anim starts open
	void functionref( entity ) viewConeFunction_start = TrainingPod_ViewConeLock_PodOpen
	string podAnim_start = "trainingpod_doors_open_idle"

	// start open idle
	FirstPersonSequenceStruct playerSequence
	playerSequence.blendTime 			= 0.0
	playerSequence.attachment 			= podAttach
	playerSequence.firstPersonAnimIdle 	= "ptpov_trainingpod_idle"
	playerSequence.thirdPersonAnimIdle 	= "pt_trainingpod_idle"
	playerSequence.viewConeFunction 	= viewConeFunction_start
	playerSequence.renderWithViewModels = true

	FirstPersonSequenceStruct podSequence
	podSequence.blendTime 				= 0.0
	podSequence.thirdPersonAnimIdle 	= podAnim_start
	podSequence.renderWithViewModels 	= true

	thread FirstPersonSequence( podSequence, pod )

	if ( doPlayerAnim )
		thread FirstPersonSequence( playerSequence, player, pod )

	TrainingPod_TurnOnInteriorDLight( "console1" )
	TrainingPod_TurnOnInteriorDLight( "console2" )
	//TrainingPod_TurnOnInteriorDLight( "backlight_side_L" )
	//TrainingPod_TurnOnInteriorDLight( "backlight_side_R" )
}



// ------ POD INTRO BACKGROUND SKITS ------
void function PodIntro_BackgroundSkits( entity player )
{
	string endFlag = "PodIntro_PodDoorsClosed"
	FlagEnd( endFlag )

	thread PodIntro_LoudspeakerVO( player, "PodIntro_InteriorBootSequence_Starting" )

	thread PodIntro_TitanRacks( endFlag )

	thread PodIntro_Background_WalkingGuys()

	// ---- ANIMATING SKIT GUYS ---
	// script NudgeSkitGuy( "back_console_supervisor", 0, 5, 0 )

	// guy sitting at console in back center of room
	SkitGuyInfo backConsoleGuy1 = SpawnSkitGuy( "back_console_sitting", "pt_console_idle", < 10521.1, -9679.33, -6044.1 >, < 0, 88.3541, 0 >, TEAM_MILITIA, "npc_soldier" )
	SkitGuy_PlayAnim( backConsoleGuy1 )
	SkitGuyInfo backConsoleGuy2 = SpawnSkitGuy( "back_console_supervisor", "pt_bored_interface_leanback", < 10527.6, -9656.36, -6043.97 >, < 0, -26.564, 0 >, TEAM_MILITIA, "npc_soldier_specialist_militia", "mp_weapon_g2" )
	SkitGuy_PlayAnim( backConsoleGuy2 )

	// extra marvins working on titans 1 and 2
	SkitGuyInfo titanBay1_marvin = SpawnSkitGuy( "bay1_marvin", "mv_idle_weld", < 10711.2, -9781.04, -6080.65 >, < 0, 153.715, 0 > )
	SkitGuy_PlayAnim( titanBay1_marvin, 3.0 )  // don't play same anim at same time
	SkitGuyInfo titanBay2_marvin = SpawnSkitGuy( "bay2_marvin", "mv_idle_weld", < 10316.2, -9730.23, -6079.97 >, < 0, -69.965, 0 > )
	SkitGuy_PlayAnim( titanBay2_marvin )

	// guys looking at console in back left
	SkitGuyInfo leftConsoleGuy1 = SpawnSkitGuy( "console_lean", "pt_bored_interface_leanin", < 10257.6, -9846.63, -6079.97 >, < 0, 34.5175, 0 >, TEAM_MILITIA, "npc_soldier" )
	SkitGuy_PlayAnim( leftConsoleGuy1 )
	SkitGuyInfo leftConsoleGuy2 = SpawnSkitGuy( "console_supervisor", "pt_bored_interface_leanback", < 10260.5, -9874.78, -6079.97 >, < 0, -42.534, 0 >, TEAM_MILITIA, "npc_soldier", "mp_weapon_mastiff" )
	SkitGuy_PlayAnim( leftConsoleGuy2 )

	OnThreadEnd(
	function() : ()
		{
			DeleteAllSkitGuys()
		}
	)

	WaitForever()
}

void function PodIntro_LoudspeakerVO( entity player, string endFlag )
{
	EndSignal( player, "OnDestroy" )

	array<string> aliases
	// "Inbound to Planet Typhon. Subspace rendezvous in approximately 20 minutes."
	aliases.append( "intro_0" )
	// "Reminder to dock personnel: Titan ordnance is a Type 3 Hazardous Material."
	aliases.append( "intro_2" )
	// "Running Lifeboat diagnostic test two point one. All Mark Eight lifeboats are in the green."
	aliases.append( "intro_4" )
	// "3rd Militia Grenadiers - prep dropship MacAllan 17."
	aliases.append( "intro_5" )
	// "Captain Cole to communications."
	aliases.append( "intro_3" )
	// "Major Anderson, please report to the briefing room."
	aliases.append( "intro_1" )

	thread LoopLoudspeakerVO( aliases, endFlag, 1.0, 2.0 )
}

void function PodIntro_Background_WalkingGuys()
{
	// group of guys walking left to right
	array<Point> path1 = []
	ScriptedPath_AddPoint( path1, < 10327.9, -10000.28, -6079.97 >, < 0, 0.918, 0 > )
	ScriptedPath_AddPoint( path1, < 10373.5, -9987.14, -6079.97 >, < 0, 0.093, 0 > )
	ScriptedPath_AddPoint( path1, < 10688.3, -9973.76, -6079.97 >, < 0, 0, 0 > )
	ScriptedPath_AddPoint( path1, < 10856.4, -9973.58, -6079.97 >, < 0, 0, 0 > )
	SkitGuyInfo walkerInfo_1 = SpawnSkitGuy( "walker_1", "", path1[0].origin, path1[0].angles, TEAM_MILITIA, "npc_soldier_specialist_militia", "mp_weapon_hemlok_smg" )
	thread ScriptedPath_Walk( walkerInfo_1, path1, 0.75 )

	array<Point> path2 = []
	ScriptedPath_AddPoint( path2, < 10248.6, -9925.06, -6079.97 >, < 0, 6.36392, 0 > )
	ScriptedPath_AddPoint( path2, < 10373.5, -9939.14, -6079.97 >, < 0, 0.093, 0 > )
	ScriptedPath_AddPoint( path2, < 10688.3, -9973.76, -6079.97 >, < 0, 0, 0 > )
	ScriptedPath_AddPoint( path2, < 10856.4, -9973.58, -6079.97 >, < 0, 0, 0 > )
	SkitGuyInfo walkerInfo_2 = SpawnSkitGuy( "walker_2", "", path2[0].origin, path2[0].angles, TEAM_MILITIA, "npc_soldier", "mp_weapon_hemlok" )
	thread ScriptedPath_Walk( walkerInfo_2, path2, 0.85 )
}

void function PodIntro_TitanRacks( string endFlag )
{
	FlagEnd( endFlag )

	array<HangarTitanGroup> titanGroups

	HangarTitanGroup bay1
	bay1.ref 		= GetEntByScriptName( "animref_drop_hangar_titan_1" )
	bay1.titan 		= GetEntByScriptName( "hangar_titan_1" )
	bay1.rack 	 	= GetEntByScriptName( "hangar_titan_rack_1" )
	bay1.titanAnim 	= "bt_TDay_drop_titan4"
	bay1.rackAnim 	= "rack_TDay_drop_rack4"
	bay1.marvinAnim = "mv_TDay_drop_marvin4"
	HangarTitanGroup_Init( bay1 )
	titanGroups.append( bay1 )

	// ---  BAY 2 ---
	HangarTitanGroup bay2
	bay2.ref 		= GetEntByScriptName( "animref_drop_hangar_titan_2" )
	bay2.titan 		= GetEntByScriptName( "hangar_titan_2" )
	bay2.rack 	 	= GetEntByScriptName( "hangar_titan_rack_2" )
	bay2.titanAnim 	= "bt_TDay_drop_titan3"
	bay2.rackAnim 	= "rack_TDay_drop_rack3"
	bay2.marvinAnim = "mv_TDay_drop_marvin3"
	HangarTitanGroup_Init( bay2 )
	titanGroups.append( bay2 )

	float wait_earlyEnd = 27.0
	thread HangarTitanGroup_Animate( bay1, endFlag, wait_earlyEnd )
	thread HangarTitanGroup_Animate( bay2, endFlag, wait_earlyEnd )

	wait wait_earlyEnd
	thread PodIntro_TitanRacks( endFlag )
}



// ===================================
// ========= BASIC MOVEMENT ==========
// ===================================
void function Training_Setup_BasicMovement( entity player )
{
	player.DisableWeapon()
}

void function Training_Skipped_BasicMovement( entity player )
{
	player.SetPlayerSettingsWithMods( TRAINING_PLAYER_SETTINGS, [ "disable_doublejump", "disable_wallrun" ] )

	Objective_SetSilent( "#TRAINING_OBJ_DEFAULT" )
}

void function Training_BasicMovement( entity player )
{
	entity standNearJumpRef = GetEntByScriptName( "basic_movement_og_stand_near_jump" )
	standNearJumpRef.SetOrigin( OriginToGround( standNearJumpRef.GetOrigin() + <0,0,0.5> ) )  // HACK HACK the ref node is a tiny bit in the geo which causes OG to dip when blending between anims
	entity ogStart = GetEntByScriptName( "basic_movement_og_start" )
	entity og = Training_SpawnOGPilot( ogStart )

	player.SetPlayerSettingsWithMods( TRAINING_PLAYER_SETTINGS, [ "disable_doublejump", "disable_wallrun" ] )
	player.ForceAutoSprintOff()

	entity playerStart = GetEntByScriptName( "startpoint_basic_movement" )
	waitthread PlayerAndOGTeleport_Fancy( player, playerStart.GetOrigin(), "basic_movement_og_start", playerStart.GetAngles() )
	Training_OG_Idles_Sitting( ogStart, "OG_base_move_A_idle" )

	thread BasicMovement_DelayedWeaponDeploy( player, 1.5 )
	Objective_SetSilent( "#TRAINING_OBJ_DEFAULT" )

	// "Ah. Much better."
	waitthread Training_OG_ScriptedAnim( ogStart, "OG_base_move_A" )
	thread Training_OG_Idles_Sitting( ogStart, "OG_base_move_B_idle" )

	CheckPoint_Silent()

	thread OnscreenHint_DisplayUntilFlag( player, "move_hint", "BasicMovement_PlayerMovedForward", 10.0 )

	FlagWait( "BasicMovement_PlayerMovedForward" )

	if ( !Flag( "BasicMovement_PlayerJumped" ) )
	{
		// "Technically, I'm not supposed to be training you. But in you, I see potential.
		waitthread Training_OG_ScriptedAnim( ogStart, "OG_base_move_B1")
	}

	if ( !Flag( "BasicMovement_PlayerJumped" ) )
	{
		// "Besides, we're at war. Who's got time for classes, eh?"
		waitthread Training_OG_ScriptedAnim( ogStart, "OG_base_move_B2")
		thread Training_OG_Idles_Sitting( ogStart )
	}

	if ( !Flag( "BasicMovement_PlayerJumped" ) && player.IsOnGround() )
	{
		DisplayOnscreenHint( player, "jump_hint" )

		// "Here you go, up and over."
		waitthread Training_OG_ScriptedAnim( ogStart, "OG_base_move_C" )
		waitthread Training_OG_Moves( standNearJumpRef )
	}

	if ( !Flag( "BasicMovement_PlayerJumped" ) )
	{
		// "Cmon, schedule's tight today."
		// "Here you go, up and over."
		array<string> jumpNags = [ "og_jump_nag_2", "og_jump_nag" ]

		thread Training_OG_NagPlayerUntilFlag( player, jumpNags, 20.0, standNearJumpRef, "BasicMovement_PlayerJumped" )
	}

	FlagWait( "BasicMovement_PlayerJumped" )

	ClearOnscreenHint( player )

	waitthread BasicMovement_Sprint( player )
}

void function BasicMovement_Sprint( entity player )
{
	thread BasicMovement_Sprint_OG_Moves( player )

	//player.ForceAutoSprintOn()

	FlagClear( "PlayerSprinted" )
	thread BasicMovement_PlayerSprintDetection( player )

	// "Let's pick up the pace. Enabling jumpkit assist."
	float endVOTime = Time() + 3.5
	thread PlayDialogue( "og_autosprint_on", file.ogPilot )

	wait 2.5  // let the VO play a bit before showing the hint

	player.UnforceAutoSprint()
	thread BasicMovement_SprintHint_Think( player )

	wait endVOTime - Time()

	// HACK- Create a fake VO speaker where OG will eventually move to/from so the lines emit in worldspace for audio
	entity ref = GetEntByScriptName( "basic_movement_og_mid_hallway" )
	entity tempSpeaker = CreateScriptMover( ref.GetOrigin(), <0,0,0> )
	thread HACK_MoveTempSpeaker_WithOGPathMover( player, tempSpeaker )

	// "Jumpkits operate on the principle of relaxed stability."
	EmitSoundOnEntity( tempSpeaker, "diag_sp_addtional_TR411_53_mcor_og" )  // do this instead of PlayDialogue because it will follow the ent around
	wait 3.4  // HACK

	// "Once your jumpkit calibrates to your movement style, enhanced mobility becomes second nature."
	EmitSoundOnEntity( tempSpeaker, "diag_sp_movement_TR121_08_01_mcor_og" )
	wait 6.0  // HACK

	tempSpeaker.Destroy()
}

void function HACK_MoveTempSpeaker_WithOGPathMover( entity player, entity tempSpeaker )
{
	EndSignal( player, "OnDestroy" )
	EndSignal( tempSpeaker, "OnDestroy" )

	vector prevOrg = < -1,-1,-1 >

	while ( 1 )
	{
		WaitFrame()

		vector newOrg = < -1,-1,-1 >

		// if we are doing a path move, use the pathMover origin- otherwise use OG's origin
		if ( IsValid( file.ogPathMover ) )
			newOrg = file.ogPathMover.GetOrigin()
		else if ( IsValid( file.ogPilot ) )
			file.ogPilot.GetOrigin()

		if ( newOrg != < -1,-1,-1 > && newOrg != prevOrg )
		{
			tempSpeaker.SetOrigin( newOrg )
			prevOrg = newOrg
		}
	}
}

void function BasicMovement_SprintHint_Think( entity player )
{
	EndSignal( player, "OnDestroy" )

	float autosprintHintTime = 10.0

	// player with autosprint on will already be sprinting
	if ( GetAutosprintEnabled() )
	{
		thread DisplayOnscreenHint( player, "autosprint_hint", autosprintHintTime )
		return
	}

	// Below this point assume that autosprint is NOT enabled
	if ( !Flag( "PlayerSprinted" ) )
	{
		thread OnscreenHint_DisplayUntilFlag( player, "sprint_button_hint", "PlayerSprinted", 0.0, true )
		FlagWait( "PlayerSprinted" )

		wait 1.0
	}

	DisplayOnscreenHint( player, "autosprint_available", autosprintHintTime )
}

void function BasicMovement_Sprint_OG_Moves( entity player )
{
	EndSignal( player, "OnDestroy" )

	entity ogMidHallwayRef = GetEntByScriptName( "basic_movement_og_mid_hallway" )
	waitthread Training_OG_Moves_ToSitting( ogMidHallwayRef, "", 0.8 )

	FlagWait( "BasicMovement_PlayerReachedMidHallway" )

	entity og_zenGarden_start = GetEntByScriptName( "basic_movement_og_zen_start" )
	thread Training_OG_Moves( og_zenGarden_start, "OG_Beautiful_idle" )
}

void function BasicMovement_PlayerSprintDetection( entity player )
{
	EndSignal( player, "OnDestroy" )
	FlagEnd( "BasicMovement_PlayerReachedOpenArea" )

	while ( 1 )
	{
		WaitFrame()

		if (  player.IsSprinting() )
			break
	}

	FlagSet( "PlayerSprinted" )
}

void function BasicMovement_DelayedWeaponDeploy( entity player, float delay )
{
	player.EndSignal( "OnDestroy" )

	wait delay
	player.EnableWeaponWithSlowDeploy()
	thread TakeAmmoFromPlayerASAP( player )
}


// =================================================
// ========= BASIC MOVEMENT 2: ZEN GARDEN ==========
// =================================================
void function Training_Setup_ZenGarden( entity player )
{
	entity ogStart = GetEntByScriptName( "basic_movement_og_zen_start" )
	entity og = Training_SpawnOGPilot( ogStart )
	Training_OG_Idles( ogStart, "OG_Beautiful_idle" )

	thread TakeAmmoFromPlayerASAP( player )

	TeleportPlayerAndBT( "startpoint_zen_garden" )
}

void function Training_Skipped_ZenGarden( entity player )
{
	player.SetPlayerSettingsWithMods( TRAINING_PLAYER_SETTINGS, [] )

	OpenZenGardenExitDoor()
}

void function Training_ZenGarden( entity player )
{
	entity og = GetOGPilot()
	Assert( IsValid( og ) )

	entity ref_hillclimbFinish = GetEntByScriptName( "zengarden_hillclimb_finish_idle" )
	entity ref_exitSpot = GetEntByScriptName( "zengarden_og_exit_ref" )

	OpenZenGardenExitDoor()

	FlagWait( "BasicMovement_PlayerReachedOpenArea" )

	player.SetPlayerSettingsWithMods( TRAINING_PLAYER_SETTINGS, ["disable_doublejump"] )

	CheckPoint_Silent()

	thread ZenGarden_WhyWeFight_VO( player, og )

	waitthread Training_ZenGarden_Wallrun( player )

	waitthread Training_ZenGarden_Crouch( player )

	player.SetPlayerSettingsWithMods( TRAINING_PLAYER_SETTINGS, [] )

	CheckPoint_Silent()

	waitthread Training_ZenGarden_DoubleJump( player )

	waitthread Training_ZenGarden_HillClimb( player, ref_hillclimbFinish, ref_exitSpot )

	if ( IsValid( level ) )
		Signal( level, "StopRepeatingGhostRecorder" )
}

// ZEN GARDEN SHARED BETWEEN PATHS
void function ZenGarden_WhyWeFight_VO( entity player, entity og )
{
	entity ogStart = GetEntByScriptName( "basic_movement_og_zen_start" )
	entity firstRockRef = GetEntByScriptName( "zengarden_og_rock1_ref" )
	entity pathRef = GetEntByScriptName( "zengarden_og_path_ref" )
	entity treeRef = GetEntByScriptName( "zengarden_og_tree_ref" )

	string stopFlag = "ZenGarden_PlayerReachedWallrunStart"
	string setFlag = "OG_WhyWeFight_VO_Done"

	if ( !Flag( stopFlag ) )
	{
		// "Beautiful, isn't it?"
		waitthread Training_OG_ScriptedAnim( ogStart, "OG_Beautiful" )
	}

	if ( !Flag( stopFlag ) )
	{
		waitthread Training_OG_Moves( firstRockRef, "", 0.25 )
	}

	if ( !Flag( stopFlag ) )
	{
		// "It's inspired by my home planet of Harmony."
		waitthread Training_OG_ScriptedAnim( firstRockRef, "OG_harmony_A" )
	}

	if ( !Flag( stopFlag ) )
	{
		// "This is where I grew up."
		waitthread Training_OG_ScriptedAnim( firstRockRef, "OG_harmony_B" )
	}

	if ( !Flag( stopFlag ) && !Flag( "ZenGarden_PlayerReachedFirstRock" ) )
	{
		waitthread Training_OG_Moves( pathRef )
	}

	FlagWaitAny( stopFlag, "ZenGarden_PlayerReachedFirstRock" )

	if ( !Flag( stopFlag ) )
	{
		waitthread Training_OG_Moves_ToSitting( treeRef, "", 0.5 )
	}

	if ( !Flag( stopFlag ) )
	{
		// "This is what we're fighting for, Cooper."
		waitthread Training_OG_ScriptedAnim( treeRef, "OG_freedom_A" )
	}

	if ( !Flag( stopFlag ) )
	{
		// "A world that's not metal and smoke."
		waitthread Training_OG_ScriptedAnim( treeRef, "OG_freedom_B" )
	}

	if ( !Flag( stopFlag ) )
	{
		// "The freedom to live in peace and prosperity."
		waitthread Training_OG_ScriptedAnim( treeRef, "OG_freedom_C" )
	}

	FlagSet( setFlag )
}

void function Training_ZenGarden_Wallrun( entity player )
{
	entity wallrunRef = GetEntByScriptName( "basic_movement_og_zen_wallrun_idle" )
	entity recorderRef = GetEntByScriptName( "basic_movement_wallrun_start_ref" )

	FlagWaitAny( "ZenGarden_PlayerReachedWallrunStart", "OG_WhyWeFight_VO_Done" )

	FlagWait( "OG_WhyWeFight_VO_Done" )

	waitthread Training_OG_Moves_ToSitting( wallrunRef, "OG_primed_idle", 0.5 )

	FlagWait( "ZenGarden_PlayerReachedWallrunStart" )

	thread GhostRecorder_RepeatUntilFlag( player, "ZenGarden_PlayerFinishedWallrun", recorderRef, $"anim_recording/training_record_zengarden_wallrun.rpak" )

	if ( !Flag( "ZenGarden_PlayerFinishedWallrun" ) )
		thread OnscreenHint_DisplayUntilFlag( player, "wallrun_hint", "ZenGarden_PlayerFinishedWallrun" )

	wait 1.0  // wait to see if player starts wallrunning right away

	if ( !Flag( "ZenGarden_PlayerFinishedWallrun" ) && !Flag( "ZenGarden_PlayerTouchingWallrunPanel" ) )
	{
		// "Let's make sure your jump kit is primed. Basic wallrun here, give it a try."
		waitthread Training_OG_ScriptedAnim( wallrunRef, "OG_primed" )
		thread Training_OG_Idles_Sitting( wallrunRef, "OG_primed_idle" )
	}

	if ( !Flag( "ZenGarden_PlayerFinishedWallrun" ) && !Flag( "ZenGarden_PlayerTouchingWallrunPanel" ) )
		wait 1.0

	if ( !Flag( "ZenGarden_PlayerFinishedWallrun" ) && !Flag( "ZenGarden_PlayerTouchingWallrunPanel" ) )
	{
		// "Same routine as last time- watch the ghost pilot, and try to follow along."
		thread PlayDialogue( "og_wallrun_follow_ghost", file.ogPilot )
		waitthread Training_OG_ScriptedAnim( wallrunRef, "OG_primed_generic" )
		thread Training_OG_Idles_Sitting( wallrunRef, "OG_primed_idle" )
	}

	FlagWait( "ZenGarden_PlayerFinishedWallrun" )

	if ( !Flag( "ZenGarden_PlayerReachedCrouchArea" ) )
	{
		// "Good! Now you're moving."
		file.postWallrunVOEndTime = Time() + 3.0
		thread PlayDialogue( "og_wallrun_done", player )
		wait 0.3  // min wait after
	}
}

void function Training_ZenGarden_Crouch( entity player )
{
	entity ogIdle_crouchSpot = GetEntByScriptName( "zengarden_og_slide_idle")
	entity ref_slideStart = GetEntByScriptName( "zengarden_slide_ref" )

	if ( Flag( "ZenGarden_PlayerCrouched" ) )
		return

	waitthread Training_OG_Moves_ToSitting( ogIdle_crouchSpot, "OG_low_idle", 0.8 )
	thread GhostRecorder_RepeatUntilFlag( player, "ZenGarden_PlayerCrouched", ref_slideStart, $"anim_recording/training_record_zengarden_slide.rpak", 1.0 )

	FlagWait( "ZenGarden_PlayerReachedCrouchArea" )

	DisplayOnscreenHint( player, "crouch_hint", 5.0 )

	while ( file.postWallrunVOEndTime > 0 && file.postWallrunVOEndTime - Time() > 0 )
		wait 0.1

	if ( Flag( "ZenGarden_PlayerCrouched" ) )
		return

	// "Under here. Stay low."
	waitthread Training_OG_ScriptedAnim( ogIdle_crouchSpot, "OG_low" )
	thread Training_OG_Idles_Sitting( ogIdle_crouchSpot, "OG_low_idle", true )

	thread Training_ZenGarden_CrouchHint_WithNags( player, 10.0, ogIdle_crouchSpot, "OG_low_idle" )

	FlagWait( "ZenGarden_PlayerCrouched" )

	ClearOnscreenHint( player )
}

void function Training_ZenGarden_CrouchHint_WithNags( entity player, float nagInterval, entity idleRef, string ogIdleAnim )
{
	player.EndSignal( "OnDestroy" )

	string endFlag = "ZenGarden_PlayerCrouched"
	string activeFlag = "ZenGarden_PlayerAtCrouchStart"

	// "Crouch underneath, and we'll keep moving."
	// "You need to get low here."
	array<string> nags = [ "og_crouch_nag_1", "og_crouch_nag_2" ]

	int nagIdx = 0
	float nextNagTime = Time() + nagInterval

	bool showingHint = false

	while ( !Flag( endFlag ) )
	{
		FlagWait( activeFlag )

		while ( Flag( activeFlag ) )
		{
			wait 0.1

			if ( player.IsCrouched() )
			{
				if ( showingHint )
				{
					showingHint = false
					ClearOnscreenHint( player )
				}

				continue
			}

			if ( !showingHint )
			{
				DisplayOnscreenHint( player, "crouch_hint" )
				showingHint = true
			}

			if ( Time() - nextNagTime >= nagInterval )
			{
				thread Training_OG_Talks_Sitting( nags[nagIdx], idleRef, "", ogIdleAnim )
				nextNagTime = Time() + nagInterval

				nagIdx++
				if ( nagIdx >= nags.len() )
					nagIdx = 0
			}
		}

		if ( showingHint )
		{
			showingHint = false
			ClearOnscreenHint( player )
		}
	}
}

void function Training_ZenGarden_DoubleJump( entity player )
{
	entity pathRef = GetEntByScriptName( "zengarden_og_postslide_idle" )
	entity ogIdleRef = GetEntByScriptName( "zengarden_og_doublejump_idle" )
	entity recordedAnimRef = GetEntByScriptName( "zengarden_doublejump_ref" )

	waitthread Training_OG_Moves( pathRef, "", 0.5 )

	// "Simple double jump. Follow the ghost."
	waitthread Training_OG_Talks( "og_doublejump_hint", pathRef )

	thread GhostRecorder_RepeatUntilFlag( player, "ZenGarden_PlayerDoubleJumped", recordedAnimRef, $"anim_recording/training_record_zengarden_doublejump.rpak", 1.0 )

	waitthread Training_OG_Moves_ToSitting( ogIdleRef, "OG_doublejump_idle", 0.5 )

	// "We've retaken over a quarter of Frontier space since the Battle of Demeter. The Militia's better organized now. More people join everyday to fight the IMC. People like you."
	waitthread Training_OG_ScriptedAnim( ogIdleRef, "OG_doublejump_A" )
	Training_OG_Idles( ogIdleRef, "OG_doublejump_B_idle" )

	FlagWait( "ZenGarden_PlayerReachedDoubleJumpArea" )

	if ( !Flag( "ZenGarden_PlayerDoubleJumped" ) )
	{
		DisplayOnscreenHint( player, "doublejump_hint", 5.0 )
		thread OnscreenHint_NagUntilFlag( player, "doublejump_hint", "ZenGarden_PlayerDoubleJumped", 10.0, 5.0 )

		wait 0.8
	}

	FlagWait( "ZenGarden_PlayerDoubleJumped" )
}

void function Training_ZenGarden_HillClimb( entity player, entity ref_hillclimbFinish, entity ref_exitSpot )
{
	// "We used to just run and hide from them. But now we chase them."
	string nextAnim = "OG_doublejump_B"

	if ( !Flag( "ZenGarden_PlayerClimbedHill" ) )
	{
		waitthread Training_OG_Moves( ref_hillclimbFinish, "", 0.25 )
		//waitthread Training_OG_Talks( nextLine, ref_hillclimbFinish )
		waitthread Training_OG_ScriptedAnim( ref_hillclimbFinish, nextAnim )
		FlagWait( "ZenGarden_PlayerClimbedHill" )
		waitthread Training_OG_Moves( ref_exitSpot, ANIM_OG_LEANING_IDLE, 0.5 )
	}
	else if ( !Flag( "ZenGarden_PlayerReachedExitArea" ) )
	{
		waitthread Training_OG_Moves( ref_exitSpot, ANIM_OG_LEANING_IDLE, 0.5 )

		if ( !Flag( "ZenGarden_PlayerReachedExitArea" ) )
			waitthread Training_OG_ScriptedAnim( ref_exitSpot, nextAnim )

		if ( !Flag( "ZenGarden_PlayerReachedExitArea" ) )
			waitthread Training_OG_Moves( ref_exitSpot, ANIM_OG_LEANING_IDLE, 0.5 )
	}

	FlagWait( "ZenGarden_PlayerReachedExitArea" )
}


// =================================
// ========= FIRING RANGE ==========
// =================================
void function Training_Setup_FiringRange( entity player )
{
	entity ogStart = GetEntByScriptName( "firingrange_og_needguns_start_sitting" )
	entity og = Training_SpawnOGPilot( ogStart )
	Training_OG_Idles_Sitting( ogStart )

	thread TakeAmmoFromPlayerASAP( player )

	TeleportPlayerAndBT( "startpoint_firing_range" )
}

void function Training_Skipped_FiringRange( entity player )
{
	CloseZenGardenExitDoor()
	OpenGauntletDoor()

	FlagSet( "ineedguns" )
	Training_WeaponRacks_SetSolidity( true )

	player.SetExtraWeaponMods( [ "" ] )  // turns off low_ammo_disable
	SetWeaponHUDEnabled( player, true )

	Training_SetWeaponPickupsFullAmmo()
}

void function Training_FiringRange( entity player )
{
	entity ref_og_needGunsStart = GetEntByScriptName( "firingrange_og_needguns_start_sitting" )
	entity ref_og_firingRangeSpot = GetEntByScriptName( "firingrange_og_spot" )
	entity ref_og_firingRangeAttractSpot = GetEntByScriptName( "firingrange_og_attract_spot" )

	float ogMoveTime = -1

	Training_WeaponRacks_SetSolidity( false )
	Training_SetWeaponPickupsEmptyAmmo()

	thread FiringRange_CloseZenGardenDoor_WhenPlayerReachesRange( player )

	waitthread Training_OG_Moves_ToSitting( ref_og_needGunsStart, "OG_Weapons_idle", ogMoveTime )

	FlagWait( "PlayerApproachingFiringRange" )

	thread FiringRange_DetectWeaponSwitch( player )

	waitthread FiringRange_ApproachAndEntry( player, ref_og_needGunsStart, ref_og_firingRangeAttractSpot, ref_og_firingRangeSpot )

	waitthread FiringRange_TrainReload( player, ref_og_firingRangeSpot )

	Training_WeaponRacks_SetSolidity( true )
	thread FiringRange_InfiniteAmmo_WhenNearRange( player, "PodOutroStarted" )
	thread FiringRange_ResetTargets_Think( player )

	thread Training_OG_Idles( ref_og_firingRangeSpot, "OG_firingrange_idle" )

	waitthread FiringRange_TrainADS( player, ref_og_firingRangeSpot )

	waitthread FiringRange_PlayerMustDamageAllTargets( player, ref_og_firingRangeSpot, true, false )

	Training_SetWeaponPickupsFullAmmo()

	if ( !Flag( "FiringRangeWeaponSwapped" ) )
	{
		waitthread FiringRange_TrainWeaponSwap( player, ref_og_firingRangeSpot )

		FlagWait( "PlayerNearFiringRange" )  // if player moved away to get a weapon, wait for them to come back
		wait 0.25  // extra wait for player to see the targets reset

		waitthread FiringRange_PlayerMustDamageAllTargets( player, ref_og_firingRangeSpot, false )
	}

	OpenGauntletDoor()

	CheckPoint_Silent()

	// "Good. Practice more if you want, then head to the Gauntlet."
	waitthread Training_OG_ScriptedAnim( ref_og_firingRangeSpot, "OG_firingrange_ending" )

	array<string> moveToGauntletNags = [ "og_moving_to_gauntlet_nag_1", "og_moving_to_gauntlet_nag_2", "og_moving_to_gauntlet_nag_3" ]

	if ( Flag( "PlayerNearFiringRange" ) )
	{
		entity ref_og_midway2Gauntlet = GetEntByScriptName( "og_between_firingrange_and_gauntlet" )
		thread Training_OG_NagPlayerUntilFlag_Sitting( player, moveToGauntletNags, 45.0, ref_og_midway2Gauntlet, "OG_MovedTo_GauntletEntrance" )

		waitthread Training_OG_Moves_ToSitting( ref_og_midway2Gauntlet )

		FlagWaitClear( "PlayerNearFiringRange" )
	}

	FlagSet( "OG_MovedTo_GauntletEntrance" )

	entity ref_og_gauntletEntrance = GetEntByScriptName( "og_gauntlet_entrance_attract_spot" )
	thread Training_OG_NagPlayerUntilFlag( player, moveToGauntletNags, 45.0, ref_og_gauntletEntrance, "PlayerInGauntletEntryway" )

	waitthread Training_OG_Moves( ref_og_gauntletEntrance )
}

void function FiringRange_CloseZenGardenDoor_WhenPlayerReachesRange( entity player )
{
	EndSignal( player, "OnDestroy" )

	vector doorFarEdge = < -6368, -952, 48 >  // HACK this is the bottom edge of the door farthest from the firing range

	while ( 1 )
	{
		WaitFrame()

		if ( !Flag( "PlayerNearFiringRange" ) )
			continue

		if ( PlayerCanSeePos( player, doorFarEdge, true, 90 ) )
			continue

		break
	}

	CloseZenGardenExitDoor()
}

void function FiringRange_ApproachAndEntry( entity player, entity ref_og_needGunsStart, entity ref_og_firingRangeAttractSpot, entity ref_og_firingRangeSpot )
{
	thread FiringRange_Approach_OG_Sequence( player, ref_og_needGunsStart )

	FlagWait( "FiringRange_Approach_OG_Sequence_Done" )

	if ( !Flag( "PlayerNearFiringRange" ) )
	{
		// "Time to hit the range."
		waitthread Training_OG_ScriptedAnim( ref_og_needGunsStart, "OG_Weapons_D" )
	}

	if ( !Flag( "PlayerNearFiringRange" ) )
	{
		// "I'm over here at the range, Cooper."
		thread Training_OG_NagPlayerUntilFlag( player, [ "og_firingrange_attract_nag" ], 40.0, ref_og_firingRangeAttractSpot, "PlayerNearFiringRange" )

		waitthread Training_OG_Moves( ref_og_firingRangeAttractSpot )
	}

	FlagWait( "PlayerNearFiringRange" )

	waitthread Training_OG_Moves( ref_og_firingRangeSpot, "OG_firingrange_idle" )
}

void function FiringRange_Approach_OG_Sequence( entity player, entity ref_og_needGunsStart )
{
	EndSignal( player, "OnDestroy" )

	if ( !Flag( "PlayerNearFiringRange" ) )
		Training_OG_Idles_Sitting( ref_og_needGunsStart )

	if ( Flag( "PlayerNearFiringRange" ) )
	{
		// player is rushing forward
		FlagSet( "ineedguns" )
		thread FiringRange_INeedGuns_SFX( player, 0.0 )
	}
	else
	{
		FlagSetDelayed( "ineedguns", 2.0 )
		thread FiringRange_INeedGuns_SFX( player, 2.0 )
	}

	if ( !Flag( "PlayerNearFiringRange" ) )
	{
		// "In combat, things never go as you expect."
		waitthread Training_OG_ScriptedAnim( ref_og_needGunsStart, "OG_Weapons_A" )
	}

	if ( !Flag( "PlayerNearFiringRange" ) )
	{
		// "You must be ready to use any weapon you can find on the field."
		waitthread Training_OG_ScriptedAnim( ref_og_needGunsStart, "OG_Weapons_B" )
	}

	if ( !Flag( "PlayerNearFiringRange" ) )
	{
		// "These are just a few of the weapons I've come across out there."
		waitthread Training_OG_ScriptedAnim( ref_og_needGunsStart, "OG_Weapons_C" )
	}

	FlagSet( "FiringRange_Approach_OG_Sequence_Done" )
}

void function FiringRange_INeedGuns_SFX( entity player, float delayTime )
{
	EndSignal( player, "OnDestroy" )


	entity centerEmitter 		= GetEntByScriptName( "ref_firingrange_rack_sfx_center" )
	entity backCenterEmitter 	= GetEntByScriptName( "ref_firingrange_rack_sfx_backcenter" )
	entity leftEmitter 			= GetEntByScriptName( "ref_firingrange_rack_sfx_left" )
	entity rightEmitter 		= GetEntByScriptName( "ref_firingrange_rack_sfx_right" )

	entity moverCenter 		= CreateScriptMover( centerEmitter.GetOrigin(), centerEmitter.GetAngles() )
	entity moverBackCenter 	= CreateScriptMover( backCenterEmitter.GetOrigin(), backCenterEmitter.GetAngles() )
	entity moverLeft 		= CreateScriptMover( leftEmitter.GetOrigin(), leftEmitter.GetAngles() )
	entity moverRight 		= CreateScriptMover( rightEmitter.GetOrigin(), rightEmitter.GetAngles() )
	array<entity> movers = [ moverCenter, moverBackCenter, moverLeft, moverRight ]

	OnThreadEnd(
	function() : ( movers )
		{
			foreach ( mover in movers )
			{
				if( !IsValid( mover ) )
					continue

				mover.Destroy()
			}
		}
	)

	if ( delayTime > 0.0 )
		wait delayTime

	EmitSoundOnEntity( moverCenter, 	"training_scr_center_racks" )
	EmitSoundOnEntity( moverBackCenter, "training_scr_back_racks" )
	EmitSoundOnEntity( moverLeft, 		"training_scr_left_racks" )
	EmitSoundOnEntity( moverRight, 		"training_scr_right_racks" )

	wait 15.0  // wait before cleaning up movers
}

void function FiringRange_DetectWeaponSwitch( entity player )
{
	player.EndSignal( "OnDestroy" )

	entity ogWeapon = WaitForPlayerActiveWeapon( player )
	string ogWeaponName = ogWeapon.GetWeaponClassName()

	while ( 1 )
	{
		entity weapon = WaitForPlayerActiveWeapon( player )
		string weaponName = weapon.GetWeaponClassName()

		if ( weaponName != "" && weaponName != ogWeaponName )
		{
			FlagSet( "FiringRangeWeaponSwapped" )
			break
		}

		wait 0.5
	}
}

void function FiringRange_TrainReload( entity player, entity ogIdleSpot )
{
	FlagClear( "PlayerReloaded" )

	SetWeaponHUDEnabled( player, true )

	player.SetExtraWeaponMods( [ "" ] )  // turns off low_ammo_disable
	thread TakeAmmoFromPlayerASAP( player )

	thread TrainReload_GivePlayerAmmoAfterButtonPressed( player )

	// "Load your weapon."
	// "Swap in a fresh mag."
	array<string> reloadNags = [ "og_reload_hint", "og_reload_nag" ]

	wait 1.1 // let pro players reload before prompting

	int nagIdx = 0

	if ( !Flag( "PlayerReloaded" ) )
	{
		thread OnscreenHint_DisplayUntilFlag( player, "reload_hint", "PlayerReloaded" )

		float nagInterval = 15
		float lastNagTime = -100

		while ( !Flag( "PlayerReloaded" ) )
		{
			wait 0.1

			if ( Time() - lastNagTime >= nagInterval )
			{
				waitthread Training_OG_Talks( reloadNags[nagIdx], ogIdleSpot, "OG_firingrange_talk", "OG_firingrange_idle", true )
				lastNagTime = Time()

				nagIdx++
				if ( nagIdx >= reloadNags.len() )
					nagIdx = 0
			}
		}
	}
}

void function TrainReload_GivePlayerAmmoAfterButtonPressed( entity player )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "PlayerReloaded" )

	FlagSet( "ReloadTraining_PlayerPressedReload" )

	player.SetActiveWeaponPrimaryAmmoTotal( 50 )
}

void function FiringRange_InfiniteAmmo_WhenNearRange( entity player, string endFlag )
{
	player.EndSignal( "OnDestroy" )
	FlagEnd( endFlag )

	while ( 1 )
	{
		wait 0.5

		if ( !Flag( "PlayerNearFiringRange" ) )
			continue

		entity weapon = player.GetActiveWeapon()

		if ( weapon == null )
			continue

		int currAmmo 		= player.GetWeaponAmmoStockpile( weapon )
		int magSize 		= weapon.GetWeaponSettingInt( eWeaponVar.ammo_clip_size )
		int maxAmmo 		= weapon.GetWeaponSettingInt( eWeaponVar.ammo_stockpile_max )

		// let player reload before restocking
		if ( currAmmo > (maxAmmo-magSize + 1) )
			continue

		printt( "firing range restock ammo" )

		RestockPlayerAmmo_Silent( player )
	}
}

void function FiringRange_TrainADS( entity player, entity ref_og_firingRangeSpot )
{
	thread FlagSetWhenPlayerADS( player, "PlayerADSed" )

	FlagWaitWithTimeout( "PlayerADSed", 2.5 )  // give player time to ADS before hinting

	if ( !Flag( "PlayerADSed" ) )
	{
		// "Aim down the sights when engaging more distant targets."
		// "You can focus more tightly on your targets if you aim down the sights."
		array<string> adsNags = [ "og_ads_nag_1", "og_ads_nag_2" ]
		thread Training_OG_NagPlayerUntilFlag( player, adsNags, 10.0, ref_og_firingRangeSpot, "PlayerADSed", "OG_firingrange_talk", "OG_firingrange_idle" )

		thread OnscreenHint_DisplayUntilFlag( player, "ads_hint", "PlayerADSed" )

		// "To get more precision, aim down the sights of your weapon."
		waitthread Training_OG_Talks( "og_ads_hint", ref_og_firingRangeSpot, "OG_firingrange_talk", "OG_firingrange_idle", true )
	}

	FlagWait( "PlayerADSed" )
}

void function FiringRange_TrainWeaponSwap( entity player, entity ref_og_firingRangeSpot )
{
	Signal( player, "FiringRange_StopResettingTargets" )

	if ( !Flag( "FiringRangeWeaponSwapped" ) )
	{
		DisplayOnscreenHint( player, "weapon_pickup_hint", 5.0 )
		thread OnscreenHint_NagUntilFlag( player, "weapon_pickup_hint", "FiringRangeWeaponSwapped", 10.0, 5.0 )

		// "Use a different weapon this time. Grab another one off the rack."
		thread Training_OG_Talks( "og_weaponswap_hint", ref_og_firingRangeSpot, "OG_firingrange_talk", "OG_firingrange_idle", true )

		// "Switch to a different weapon."
		array<string> weaponSwapNags = [ "og_weaponswap_nag" ]
		waitthread Training_OG_NagPlayerUntilFlag( player, weaponSwapNags, 10.0, ref_og_firingRangeSpot, "FiringRangeWeaponSwapped", "OG_firingrange_talk", "OG_firingrange_idle" )
	}
}

void function FiringRange_PlayerMustDamageAllTargets( entity player, entity ref_og_firingRangeSpot, bool firstTime, bool resetTargetsAtStart = true )
{
	EndSignal( player, "OnDestroy" )

	FlagClear( "FiringRange_AllTargetsKilled" )
	thread FiringRange_ResetTargets_Think( player, resetTargetsAtStart )

	thread OnscreenHint_DisplayUntilFlag( player, "firingrange_dmg_targets_hint", "FiringRange_AllTargetsKilled" )

	wait 2.0

	// "Gotta take 'em all out before we can move on."
	// "Just aim, take a breath, and squeeze the trigger."
	// "In the real world, the targets don't just stand still. They shoot back."
	DialogueGroup nags = GetDialogueGroup( "shootTargetsNag" )

	int numTargetsKilled = FiringRange_GetNumDamagedTargets()

	while ( !Flag( "FiringRange_AllTargetsKilled" ) )
	{
		wait 1.0

		// don't nag player if they recently damaged a target
		if ( FiringRange_GetNumDamagedTargets() > numTargetsKilled )
		{
			numTargetsKilled = FiringRange_GetNumDamagedTargets()
			TimerReset( "firingRangeNag" )

			continue
		}

		if ( !TimerCheck( "firingRangeNag" ) )
			continue

		string nagLine = DialogueGroup_GetNextLine( nags )
		waitthread Training_OG_Talks( nagLine, ref_og_firingRangeSpot, "OG_firingrange_talk", "OG_firingrange_idle", true )

		TimerReset( "firingRangeNag" )
	}
}

void function FiringRangeTargets_Init()
{
	string targetScriptName = "firingrange_target"
	array<entity> targetEnts = GetEntArrayByScriptName( targetScriptName )
	Assert( targetEnts.len(), "Couldn't get firing range targets with script_name " + targetScriptName )

	foreach ( ent in targetEnts )
	{
		ent.SetTakeDamageType( DAMAGE_EVENTS_ONLY )
		ent.SetDamageNotifications( true )

		entity angleRefEnt = ent.GetLinkEnt()
		Assert( IsValid( angleRefEnt ), "Firing range target needs an angle reference entity linked" )
		angleRefEnt.SetParent( ent )

		FiringRangeTarget target
		target.ent = ent
		target.angleRefEnt = angleRefEnt
		target.ogAngles = ent.GetAngles()
		target.mover = CreateScriptMover( ent.GetOrigin(), ent.GetAngles() )
		ent.SetParent( target.mover )

		file.firingRangeTargets.append( target )
	}
}

int function FiringRange_GetNumDamagedTargets()
{
	int numDamaged = 0

	foreach ( target in file.firingRangeTargets )
		if ( target.wasDamaged )
			numDamaged++

	return numDamaged
}

void function FiringRange_ResetAllTargets()
{
	foreach ( target in file.firingRangeTargets )
		FiringRangeTarget_Reset( target )
}

void function FiringRangeTarget_Reset( FiringRangeTarget target )
{
	if ( !IsValid( target.ent ) )
		return

	target.wasDamaged = false

	thread FiringRangeTarget_RotateBack( target )
}

void function FiringRange_ResetTargets_Think( entity player, bool resetTargetsAtStart = true )
{
	Signal( player, "FiringRange_StopResettingTargets" )
	EndSignal( player, "FiringRange_StopResettingTargets" )
	EndSignal( player, "OnDestroy" )

	FlagEnd( "PodOutroStarted" )

	array<FiringRangeTarget> firingRangeTargets = file.firingRangeTargets

	bool firstLoop = true
	float targetResetWait = 1.75

	while ( 1 )
	{
		bool resetTargets = true
		if ( firstLoop && !resetTargetsAtStart )
			resetTargets = false

		if ( resetTargets )
			FiringRange_ResetAllTargets()

		foreach ( target in firingRangeTargets )
			thread FiringRangeTarget_WaitForDamage( target )

		// wait for all targets to take damage
		while ( 1 )
		{
			wait 0.2

			bool allDamaged = true
			foreach ( target in firingRangeTargets )
			{
				if ( !target.wasDamaged )
				{
					allDamaged = false
					break
				}
			}

			if ( allDamaged )
				break
		}

		FlagSet( "FiringRange_AllTargetsKilled" )

		wait targetResetWait

		if ( firstLoop )
			firstLoop = false
	}
}

void function FiringRangeTarget_WaitForDamage( FiringRangeTarget target )
{
	Signal( target.ent, "Target_WaitForDamage_Start" )
	EndSignal( target.ent, "Target_WaitForDamage_Start" )
	EndSignal( target.ent, "OnDestroy" )

	bool first = true
	while ( 1 )
	{
		table result = WaitSignal( target.ent, "TargetDamaged" )
		vector damagePos = expect vector( result.damagePos )

		if ( first )
		{
			thread FiringRangeTarget_FirstDamage( target, damagePos )
			first = false
		}
	}

	return
}

string function FiringRangeTarget_GetDamageSide( FiringRangeTarget target, vector damagePos )
{
	vector upEntPos = target.angleRefEnt.GetOrigin()
	vector upEntAngles = target.angleRefEnt.GetAngles()

	vector facingVec = AnglesToForward( upEntAngles )
	vector vecToDamage = Normalize( damagePos - upEntPos )
	float dot2Damage = DotProduct( vecToDamage, facingVec )
	printt( "damage dot product:", dot2Damage )

	#if DEV
	//float debugDrawTime = 3.0
	//DebugDrawAngles( damagePos, upEntAngles, debugDrawTime )
	//DebugDrawLine( upEntPos, upEntPos + (facingVec * 200), 200, 200, 0, true, debugDrawTime )
	#endif

	vector frontFacingVec = AnglesToRight( upEntAngles )
	bool isOnLeft = IsPointInFrontofLine( damagePos, upEntPos, frontFacingVec )

	string returnStr = "left"
	if ( isOnLeft )
	{
		printt( "LEFT SIDE" )
	}
	else
	{
		printt( "RIGHT SIDE" )
		returnStr = "right"
	}

	return returnStr
}

void function FiringRangeTarget_FirstDamage( FiringRangeTarget target, vector damagePos )
{
	//Assert( !target.wasDamaged, "Target not expected to be damaged yet" )
	if ( target.wasDamaged )
		return

	target.wasDamaged = true

	if ( IsAlive( file.player ) )
		EmitSoundOnEntity( file.player, "training_scr_hit_target" )

	// rotate left by default
	float rotateAngY = 179.9
	if ( FiringRangeTarget_GetDamageSide( target, damagePos ) == "right" )
		rotateAngY *= -1

	vector newAngles = target.ogAngles + Vector( 0, rotateAngY, 0 )
	thread FiringRangeTarget_Rotate( target, newAngles )
}

void function FiringRangeTarget_Rotate( FiringRangeTarget target, vector targetAngles )
{
	Signal( target.mover, "TargetRotate" )
	EndSignal( target.mover, "TargetRotate" )
	EndSignal( target.mover, "OnDestroy" )

	float rotateTime = 0.14
	float accelTime = 0
	float decelTime = 0.1
	target.mover.NonPhysicsRotateTo( targetAngles, rotateTime, accelTime, decelTime )

	wait rotateTime
}

void function FiringRangeTarget_RotateBack( FiringRangeTarget target )
{
	if ( target.ent.GetAngles() == target.ogAngles )
		return

	EmitSoundAtPosition( TEAM_UNASSIGNED, target.ent.GetOrigin(), "training_scr_range_target_spin" )

	waitthread FiringRangeTarget_Rotate( target, target.ogAngles )
}


void function FlagSetWhenPlayerADS( entity player, string setFlag )
{
	player.EndSignal( "OnDestroy" )

	while ( player.GetZoomFrac() < 0.9 )
		wait 0.1

	FlagSet( setFlag )
}



// =============================
// ========= GAUNTLET ==========
// =============================
void function Training_Setup_Gauntlet( entity player )
{
	entity ogStart = GetEntByScriptName( "og_gauntlet_entrance_attract_spot" )
	entity og = Training_SpawnOGPilot( ogStart )
	Training_OG_Idles( ogStart )

	TeleportPlayerAndBT( "startpoint_gauntlet_entrance" )
}

void function Training_Skipped_Gauntlet( entity player )
{
	FlagSet( "Gauntlet_FirstRun_Done" )
	thread TrainingGauntlet_RemindPlayerAboutMobility( player )
	thread TrainingGauntlet_CrouchHint( player )
	thread TrainingGauntlet_SetsDifficulty( player )
}

void function Training_Gauntlet( entity player )
{
	entity og = GetOGPilot()

	entity ref_og_gauntletStartPos = GetEntByScriptName( "og_near_gauntlet_start_pos" )
	GauntletInfo trainingGauntlet = GetTrainingGauntlet()

	// HACK
	vector resultsBoardCenterPos = < -4899.15, 666.269, 107.187 >

	if ( !Flag( "PlayerInGauntletEntryway" ) && !trainingGauntlet.isActive && !PlayerCanSeePos( player, resultsBoardCenterPos, true, 90 ) )
		DisableGauntlet( trainingGauntlet )  // let a rushing player start the gauntlet

	if ( !trainingGauntlet.isActive )
		FlagWait( "PlayerInGauntletEntryway" )

	if ( !trainingGauntlet.isActive )
		CheckPoint_Silent()

	waitthread Training_OG_Moves( ref_og_gauntletStartPos, ANIM_OG_LEANING_IDLE )

	thread Training_Gauntlet_FirstRunDialogue( player, trainingGauntlet, ref_og_gauntletStartPos )
	wait 1.0

	EnableGauntlet( trainingGauntlet )
	thread Training_Gauntlet_FirstRunGhostPlaybackStart( player, trainingGauntlet )
	thread TrainingGauntlet_TeleportPlayerAtFinishLine( player )
	thread TrainingGauntlet_RemindPlayerAboutMobility( player, "Gauntlet_FirstRun_All_VO_Finished" )
	thread TrainingGauntlet_CrouchHint( player )
	thread TrainingGauntlet_SetsDifficulty( player )

	thread Training_Gauntlet_WaitForRequiredTime( player, ref_og_gauntletStartPos )
	FlagWait( "Gauntlet_FirstRun_Done" )

	if ( !trainingGauntlet.isActive )
		CheckPoint_Silent()

	Gauntlet_StopGhostPlayback( trainingGauntlet )

	waitthread Training_Gauntlet_PostFirstRunDialogue( player, trainingGauntlet )
}


void function Training_Gauntlet_FirstRunDialogue( entity player, GauntletInfo gauntlet, entity ogIdleSpot )
{
	player.EndSignal( "OnDestroy" )

	if ( !gauntlet.isActive )
	{
		// "Alright. Got a new gauntlet for you to run today."
		waitthread Training_OG_ScriptedAnim( ogIdleSpot, "OG_gauntlet_start_A" )
	}

	if ( !gauntlet.isActive )
	{
		// "Par time is a minute-forty-five."
		waitthread Training_OG_ScriptedAnim( ogIdleSpot, "OG_gauntlet_start_B" )
	}

	if ( !gauntlet.isActive )
	{
		// "Gotta do better than that to continue."
		waitthread Training_OG_ScriptedAnim( ogIdleSpot, "OG_gauntlet_start_C" )
	}

	Objective_Set( "#TRAINING_OBJ_GAUNTLET_FIRSTRUN" )

	//if ( gauntlet.isActive )
	//	Training_Gauntlet_OG_Creates_FirstRun_Ghost( file.ogPilot )

	AddAnimEvent( file.ogPilot, "create_ghost", Training_Gauntlet_OG_Creates_FirstRun_Ghost )

	// "Follow the ghost, or find your own path."
	waitthread Training_OG_ScriptedAnim( ogIdleSpot, "OG_gauntlet_start_D" )
	thread Training_OG_Idles( ogIdleSpot, "OG_gauntlet_start_endidle" )

	DeleteAnimEvent( file.ogPilot, "create_ghost" )

	float minDelayEnd = 5.0 + Time()
	DialogueGroup firstRunGauntletLore = GetDialogueGroup( "firstRunGauntletLore" )
	while ( !Flag( "Gauntlet_FirstRun_Done" ) && !firstRunGauntletLore.allPlayed )
	{
		wait 1

		if ( !gauntlet.isActive )
			continue

		if ( Time() < minDelayEnd )
			continue

		string line = DialogueGroup_GetNextLine( firstRunGauntletLore )
		PlayDialogue( line, player )
	}

	FlagSet( "Gauntlet_FirstRun_All_VO_Finished" )
}

void function Training_Gauntlet_OG_Creates_FirstRun_Ghost( entity og )
{
	entity player = file.player
	if ( !IsValid( player ) )
		return

	player.Signal( "FirstRun_OG_Creates_Ghost" )
}

void function TrainingGauntlet_RemindPlayerAboutMobility( entity player, string waitFlag = "" )
{
	EndSignal( player, "OnDestroy" )
	FlagEnd( "PlayerLeavingGauntlet" )

	GauntletInfo trainingGauntlet = GetTrainingGauntlet()

	//if ( waitFlag != "" && !Flag( waitFlag ) )
	//	FlagWait( waitFlag )

	float nagInterval = 300  // 5 minutes
	float nextNagTime = -1

	float minSampleTime = 15.0
	float lowWallrunningFrac = 0.05

	bool hasSprinted = false

	FlagWait( "Gauntlet_FirstRun_All_VO_Finished" )

	while ( !Flag( "PlayerLeavingGauntlet" ) )
	{
		if ( !trainingGauntlet.isActive )
			WaitSignal( player, "Gauntlet_RunStarted" )

		float startTime = Time()
		float samplePoints = 0
		float samplesWallrunning = 0

		while ( trainingGauntlet.isActive )
		{
			wait 0.1

			if ( player.IsSprinting() && !hasSprinted )
				hasSprinted = true

			samplePoints++
			if ( player.IsWallRunning() )
				samplesWallrunning++

			if ( (Time() - startTime) < minSampleTime )
				continue

			float wallrunningFrac = samplesWallrunning / samplePoints
			printt( "wallrunningFrac:", wallrunningFrac )

			// Has player done all the stuff we would want to remind them about?
			if ( wallrunningFrac >= lowWallrunningFrac && hasSprinted )
				break

			if ( Time() >= nextNagTime )
			{
				if ( !hasSprinted )
					thread TrainingGauntlet_SprintNag( player )
				else if ( wallrunningFrac < lowWallrunningFrac )
					thread TrainingGauntlet_WallrunNag( player, trainingGauntlet )

				nextNagTime = Time() + nagInterval
			}

			break
		}

		if ( trainingGauntlet.isActive )
			WaitSignal( player, "Gauntlet_RunStopped" )
	}
}

void function TrainingGauntlet_SprintNag( entity player )
{
	EndSignal( player, "OnDestroy" )

	float hintDuration = 10.0
	float hintEndTime = Time() + hintDuration
	DisplayOnscreenHint( player, "sprint_button_hint", hintDuration )

	EndSignal( player, "DisplayingOnscreenHint" )

	while ( Time() < hintEndTime && !player.IsSprinting() )
		WaitFrame()

	ClearOnscreenHint( player )
}

void function TrainingGauntlet_WallrunNag( entity player, GauntletInfo trainingGauntlet )
{
	EndSignal( player, "OnDestroy" )

	//printt( "playing mobility nag" )

	DisplayOnscreenHint( player, "gauntlet_wallrun_hint", 8.0 )

	DialogueGroup gauntletHints_wallrun = GetDialogueGroup( "gauntletHints_wallrun" )
	string line = DialogueGroup_GetNextLine( gauntletHints_wallrun )
	waitthread PlayDialogue( line, player )

	if ( !trainingGauntlet.isActive )
		return

	waitthread PlayDialogue( "og_gauntlet_hint_wallrun_capper", player )
}

void function TrainingGauntlet_CrouchHint( entity player )
{
	EndSignal( player, "OnDestroy" )

	string checkFlag = "Gauntlet_PlayerInCrouchHintZone"
	string nagTimer = "gauntlet_crouchHint"

	TimerInit( nagTimer, 2.5 )

	float waitTime = 1.0
	bool hintShowing = false

	while ( 1 )
	{
		wait waitTime

		if ( !Flag( checkFlag ) )
			continue

		TimerReset( nagTimer )

		while ( Flag( checkFlag ) )
		{
			wait waitTime

			if ( !TimerCheck( "gauntlet_crouchHint" ) )
				continue

			if ( !hintShowing )
			{
				DisplayOnscreenHint( player, "crouch_hint" )
				hintShowing = true
			}
		}

		if ( hintShowing )
		{
			ClearOnscreenHint( player )
			hintShowing = false
		}
	}
}

void function Training_Gauntlet_PostFirstRunDialogue( entity player, GauntletInfo gauntlet )
{
	player.EndSignal( "OnDestroy" )
	player.EndSignal( "Gauntlet_RunStarted" )

	entity ref_og_gauntletResults = GetEntByScriptName( "og_ref_gauntlet_results_display" )

	Objective_SetSilent( "#TRAINING_OBJ_DEFAULT" )

	waitthread Training_OG_Moves( ref_og_gauntletResults, "", 1.0 )

	AddAnimEvent( file.ogPilot, "highlight_results_board_tip", Gauntlet_PostFirstRun_SetRandomTip )

	// "Nice run! See the results board on the wall? You set a new Best Time."
	// "Everyone has different strengths and weaknesses, so be sure to run this a few times with different weapons."
	// "Look at the results board for more tips on how to improve."
	waitthread Training_OG_ScriptedAnim( ref_og_gauntletResults, "OG_Gauntlet_return" )

	DeleteAnimEvent( file.ogPilot, "highlight_results_board_tip" )
}

// update tip while OG is talking about the tips
void function Gauntlet_PostFirstRun_SetRandomTip( entity og )
{
	entity player = file.player
	if ( !IsValid( player ) )
		return

	GauntletInfo gauntlet = GetTrainingGauntlet()
	Remote_CallFunction_Replay( player, "ScriptCallback_GauntletResultsDisplay_SetRandomTip", gauntlet.id )
}

void function Training_Gauntlet_FirstRunGhostPlaybackStart( entity player, GauntletInfo gauntlet )
{
	if ( !gauntlet.isActive )
		WaitSignal( player, "Gauntlet_RunStarted", "FirstRun_OG_Creates_Ghost" )

	thread Gauntlet_StartGhostPlayback( gauntlet, GHOST_NAME_FIRSTRUN, "#GAUNTLET_GHOST_NAME_FIRSTRUN" )
}

void function Training_Gauntlet_WaitForRequiredTime( entity player, entity ogIdleSpot )
{
	player.EndSignal( "OnDestroy" )

	GauntletInfo gauntlet = GetTrainingGauntlet()

	// "The first run of the day is always the toughest."
	// "Too slow! I know you can do better. Give it another try."
	DialogueGroup firstRunFailedGroup = GetDialogueGroup( "firstRunFailed" )

	int failCount = 0
	while ( 1 )
	{
		// keep setting this here because by default the gauntlet updates its random tip after each finished run
		Remote_CallFunction_Replay( player, "ScriptCallback_TrainingGauntlet_ResultsDisplay_SetTip", gauntlet.id, 0 )

		player.WaitSignal( "Gauntlet_RunStopped" )

		wait 0.1  // HACK let the gauntlet struct get updated before checking it

		TrainingGauntletStats_PostRunUpdate( player, gauntlet, 0 )

		if ( !gauntlet.runFinished )
			continue

		failCount++

		if ( gauntlet.bestTime <= TRAINING_GAUNTLET_MAX_TIME_TO_PROGRESS || failCount == NUM_GAUNTLET_FAILS_BEFORE_FORCED_PROGRESS )
		{
			if ( gauntlet.bestTime <= TRAINING_GAUNTLET_MAX_TIME_TO_PROGRESS )
				printt( "Gauntlet moving on: beat required time" )
			else if ( failCount == NUM_GAUNTLET_FAILS_BEFORE_FORCED_PROGRESS )
				printt( "Gauntlet moving on: forced progress after", NUM_GAUNTLET_FAILS_BEFORE_FORCED_PROGRESS, "failures" )

			break
		}

		wait 0.5  // let player get settled before VO starts

		EmitSoundOnEntityOnlyToPlayer( player, player, "training_scr_gaunlet_fail_01" )

		string firstRunFailedLine = DialogueGroup_GetNextLine( firstRunFailedGroup )
		thread Training_OG_Talks_Leaning( firstRunFailedLine, ogIdleSpot, "", "", true )

		Objective_Remind()
		//DisplayOnscreenHint( player, "gauntlet_first_run_progression_hint", 9.0 )

		if ( failCount == 2 )
			thread DoSprintEnableDialogForGauntletIfNeeded_Thread( player, 3.5 )
	}

	TrainingGauntletPostRun_TryAchievements( player, gauntlet )

	FlagSet( "Gauntlet_FirstRun_Done" )
}

void function DoSprintEnableDialogForGauntletIfNeeded_Thread( entity player, float waitTime )
{
	EndSignal( player, "OnDestroy" )
	wait waitTime

	if ( GetAutosprintEnabled() )
		return

	Remote_CallFunction_UI( player, "ScriptCallback_OpenAutosprintDialogForGauntlet" )
}

void function TrainingGauntlet_TeleportPlayerAtFinishLine( entity player )
{
	Signal( player, "Gauntlet_StopTeleportingPlayerAtFinishLine" )
	EndSignal( player, "Gauntlet_StopTeleportingPlayerAtFinishLine" )
	EndSignal( player, "OnDestroy" )

	entity startEnt = GetEntByScriptName( "results_room_teleport_refA" )
	entity endEnt = GetEntByScriptName( "results_room_teleport_refB" )
	vector startPos = startEnt.GetOrigin()
	vector endPos 	= endEnt.GetOrigin()

	while ( 1 )
	{
		player.WaitSignal( "Gauntlet_PlayerHitFinishTrig" )

		vector currentPos = player.GetOrigin()
		float offsetX = currentPos.x - startPos.x
		float offsetY = currentPos.y - startPos.y
		float offsetZ = currentPos.z - startPos.z

		float newPosX = endPos.x + offsetX
		float newPosY = endPos.y + offsetY
		float newPosZ = endPos.z + offsetZ

		vector newPos = < newPosX, newPosY, newPosZ >

		player.SetOrigin( newPos )
	}
}


void function TrainingGauntlet_SetsDifficulty( entity player )
{
	if ( Flag( "PlayerLeavingGauntlet" ) )
		return

	FlagEnd( "PlayerLeavingGauntlet" )

	player.EndSignal( "OnDestroy" )

	GauntletInfo gauntlet = GetTrainingGauntlet()

	bool diffSetOnce = false

	while ( 1 )
	{
		WaitSignal( player, "Gauntlet_RunStopped" )

		if ( file.gauntletMode )
			return

		wait 0.2 // HACK let the gauntlet struct and file variables get set up after the run

		// extra wait for player to finish seeing their time, etc.
		wait 2.0

		if ( !gauntlet.runFinished )
			continue

		if ( !gauntlet.lastRunBestTime )
			continue

		int prevDiff = -1
		if ( diffSetOnce )
			prevDiff = GetConVarInt( "sp_difficulty" )

		Training_SetDifficultyForGauntletTime( gauntlet.bestTime )
		if ( GetConVarInt( "sp_difficulty" ) > prevDiff )
			Training_AnnounceDifficultyForGauntletTime( player, 8.0 )

		if ( !diffSetOnce )
			diffSetOnce = true
	}
}

void function Training_SetDifficultyForGauntletTime( float time )
{
	float time = file.trainingGauntletStats.bestTime
	if ( time == -1 )
		time = TRAINING_GAUNTLET_MAX_TIME_TO_PROGRESS

	int difficulty = DIFFICULTY_EASY
	//if ( time <= REC_DIFF_GAUNTLET_TIME_MASTER )
	//	difficulty = DIFFICULTY_MASTER
	// else if
	if ( time <= REC_DIFF_GAUNTLET_TIME_HARD )
		difficulty = DIFFICULTY_HARD
	else if ( time <= REC_DIFF_GAUNTLET_TIME_NORMAL )
		difficulty = DIFFICULTY_NORMAL

	printt( "GetDifficultyForGauntletTime: diff", difficulty, "for time", time )

	file.trainingGauntletStats.recommendedDifficulty = difficulty

	SetConVarInt( "sp_difficulty", difficulty )
}

void function Training_AnnounceDifficultyForGauntletTime( entity player, float displayTime = 5.0 )
{
	string hintAlias = "hint_diff_"
	hintAlias += file.trainingGauntletStats.recommendedDifficulty.tostring()
	DisplayOnscreenHint( player, hintAlias, displayTime )
}


// ======================================================
// ========= GAUNTLET CHALLENGE (post 1st run) ==========
// ======================================================
void function Training_Setup_GauntletChallenge( entity player )
{
	entity ogStart = GetEntByScriptName( "og_ref_gauntlet_results_display" )
	entity og = Training_SpawnOGPilot( ogStart )
	Training_OG_Idles( ogStart )

	TeleportPlayerAndBT( "playerstart_gauntlet_challenge" )
}

void function Training_Skipped_GauntletChallenge( entity player )
{
}

void function Training_GauntletChallenge( entity player )
{
	GauntletInfo gauntlet = GetTrainingGauntlet()

	thread TrainingGauntlet_TeleportPlayerAtFinishLine( player )

	entity ref_og_gauntletLeaderboardPos = GetEntByScriptName( "og_near_leaderboard" )

	// in gauntlet mode OG spawns here before player fade finishes, no need to move him
	if ( !file.gauntletMode )
		waitthread Training_OG_Moves( ref_og_gauntletLeaderboardPos, "" )

	Gauntlet_ShowLeaderboard( gauntlet )

	thread GauntletChallenge_GhostsThink( player, gauntlet, "GauntletChallenge_FirstGhostAppear", "PlayerLeavingGauntlet" )
	thread GauntletChallenge_IntroDialogue( player, gauntlet, ref_og_gauntletLeaderboardPos )
	thread GauntletChallege_RestartGauntletHint( player, gauntlet )

	FlagWait( "ChallengeIntro_VO_Done" )

	bool installRuiStarted = false
	if ( !Training_IsGameFullyInstalled() )
		Remote_CallFunction_Replay( player, "ScriptCallback_ShowInstallProgress", true )

	entity ref_og_gauntletExitPos = GetEntByScriptName( "og_gauntlet_exit_pos" )
	thread Training_GauntletChallenge_DialogueThink( player, gauntlet, ref_og_gauntletExitPos )
	thread Training_OG_Moves( ref_og_gauntletExitPos, "OG_all_done_idle" )

	wait 1.0
	thread Training_LeaveGauntletThink( player, ref_og_gauntletExitPos )

	FlagWait( "PlayerConfirmedGauntletExit" )

	Remote_CallFunction_Replay( player, "ScriptCallback_ShowInstallProgress", false )

	Objective_SetSilent( "#TRAINING_OBJ_DEFAULT" )

	DisableGauntlet( gauntlet )

	FlagWait( "PlayerLeavingGauntlet" )

	Signal( player, "Gauntlet_StopTeleportingPlayerAtFinishLine" )

	if ( file.gauntletMode )
	{
		thread Training_PodOutro( player )
		WaitForever()  // stall normal progression
	}
	else
	{
		thread DisableWeaponDelayed( player, 0.3 )  // disable weapon so crosshairs aren't visible during white screen

		entity destEnt = GetEntByScriptName( "startpoint_titanfall" )
		waitthread PlayerAndOGTeleport_Fancy( player, destEnt.GetOrigin(), "og_titanfall_start_pos", destEnt.GetAngles() )

		CheckPoint_Silent()
	}
}

void function DisableWeaponDelayed( entity player, float delay )
{
	EndSignal( player, "OnDestroy" )

	if ( delay > 0 )
		wait delay

	player.DisableWeapon()
}

void function GauntletChallege_RestartGauntletHint( entity player, GauntletInfo gauntlet )
{
	EndSignal( player, "OnDestroy" )

	float displayTime = 5.0
	float delayTime = 2.5

	const int RUNS_BETWEEN_REMINDERS = 3
	int runsSinceLastReminder = 3  // do reminder on first run

	while ( 1 )
	{
		if ( !gauntlet.isActive )
			WaitSignal( player, "Gauntlet_RunStarted" )

		float displayEndTime = -1

		// check if we should remind after run starts
		if ( runsSinceLastReminder >= RUNS_BETWEEN_REMINDERS )
		{
			thread OnscreenHint_DisplayAfterDelay( player, "gauntlet_restart_hint", displayTime, delayTime )
			displayEndTime = Time() + displayTime + delayTime
		}

		// wait for run to stop
		table result = WaitSignal( player, "Gauntlet_RunStopped", "Gauntlet_ForceRestart" )
		string signal = expect string( result.signal )

		// clear initial hint if player cancelled the run before it would auto clear
		if ( displayEndTime != -1 && Time() < displayEndTime )
			ClearOnscreenHint( player )

		// player went back through the starting gate?
		if ( signal == "Gauntlet_RunStopped" && !gauntlet.runFinished )
		{
			// Don't care about how many runs between reminders here- if player does this it means they don't really get it yet
			thread DisplayOnscreenHint( player, "gauntlet_restart_hint", displayTime )
			runsSinceLastReminder = 0
		}
		// player used menu to restart?
		else if ( signal == "Gauntlet_ForceRestart" )
		{
			runsSinceLastReminder = 0  // reset the counter when force restarted
		}

		if ( runsSinceLastReminder >= RUNS_BETWEEN_REMINDERS )
			runsSinceLastReminder = 0
		if ( gauntlet.runFinished )  // player restarted from menu or went back through the gate
			runsSinceLastReminder++
	}
}

void function GauntletChallenge_IntroDialogue( entity player, GauntletInfo gauntlet, entity ogRef )
{
	if ( file.gauntletMode )
	{
		thread GauntletChallengeModeOnly_IntroDialogue( player, gauntlet, ogRef )
		return
	}

	player.EndSignal( "OnDestroy" )

	if ( !gauntlet.isActive )
	{
		// "Now that you're warmed up: if you want a REAL challenge, you can race against other Pilot ghosts."
		waitthread Training_OG_ScriptedAnim( ogRef, "OG_Leaderboard_A" )
	}

	player.Signal( "GauntletChallenge_FirstGhostAppear" )

	if ( !gauntlet.isActive )
	{
		// "Word of warning, though- the Pilots who recorded these ghosts are the best in the SRS.
		waitthread Training_OG_ScriptedAnim( ogRef, "OG_Leaderboard_B" )
	}

	if ( !gauntlet.isActive )
	{
		// "If you can beat them, you'll be halfway to being a real Pilot."
		waitthread Training_OG_ScriptedAnim( ogRef, "OG_Leaderboard_C" )
	}

	if ( !gauntlet.isActive )
	{
		// "Go ahead and run the Gauntlet as much as you want."
		waitthread Training_OG_ScriptedAnim( ogRef, "OG_Leaderboard_D" )
	}

	// "When you're done, I've got something special to show you."
	waitthread Training_OG_ScriptedAnim( ogRef, "OG_Leaderboard_E" )

	if ( !Training_IsGameFullyInstalled() )
	{
		Objective_Set( "#TRAINING_OBJ_GAUNTLET_CHALLENGE_INSTALLING" )
		thread ChangeGauntletObjective_OnInstallComplete( player )
	}
	else
	{
		Objective_Set( "#TRAINING_OBJ_GAUNTLET_CHALLENGE" )
	}

	FlagSet( "ChallengeIntro_VO_Done" )
}

void function GauntletChallengeModeOnly_IntroDialogue( entity player, GauntletInfo gauntlet, entity ogRef )
{
	player.EndSignal( "OnDestroy" )

	SetSignalDelayed( player, "GauntletChallenge_FirstGhostAppear", 0.25 )

	wait 1.5 // let player teleport and fade in before starting to talk

	if ( !gauntlet.isActive )
	{
		// "Go ahead and run the Gauntlet as much as you want."
		waitthread Training_OG_ScriptedAnim( ogRef, "OG_Leaderboard_D", true )
	}

	// "When you're done, I've got something special to show you."
	//waitthread Training_OG_ScriptedAnim( ogRef, "OG_Leaderboard_E" )

	Objective_Set( "#TRAINING_OBJ_GAUNTLET_CHALLENGE" )

	FlagSet( "ChallengeIntro_VO_Done" )
}

void function ChangeGauntletObjective_OnInstallComplete( entity player )
{
	EndSignal( player, "OnDestroy" )

	while ( !Training_IsGameFullyInstalled() )
		wait 1.0

	Objective_Set( "#TRAINING_OBJ_GAUNTLET_CHALLENGE" )
}

void function GauntletChallenge_GhostsThink( entity player, GauntletInfo gauntlet, string signalWait, string endFlag )
{
	if ( Flag( endFlag ) )
		return

	player.EndSignal( "OnDestroy" )
	gauntlet.signalEnt.EndSignal( "OnDestroy" )

	FlagEnd( endFlag )

	if ( !gauntlet.isActive )
		WaitSignal( player, "Gauntlet_RunStarted", signalWait )

	thread Gauntlet_ChallengeLeaderboardGhosts( player, gauntlet, "PlayerLeavingGauntlet" )
}

void function Training_GauntletChallenge_DialogueThink( entity player, GauntletInfo gauntlet, entity ogSpot )
{
	player.EndSignal( "OnDestroy" )

	FlagWait( "ChallengeIntro_VO_Done" )

	DialogueGroup clearedLeaderboard = GetDialogueGroup( "clearedLeaderboard" )
	DialogueGroup defeatedGhost = GetDialogueGroup( "defeatedGhost" )
	DialogueGroup notBestTime = GetDialogueGroup( "notBestTime" )
	DialogueGroup newBestTime = GetDialogueGroup( "newBestTime" )

	while ( 1 )
	{
		FlagClear( "Gauntlet_PlayingFeedbackVO" )

		WaitSignal( player, "Gauntlet_RunStopped" )

		wait 0.1  // HACK let the gauntlet struct get updated before checking

		TrainingGauntletStats_PostRunUpdate( player, gauntlet, 1 )

		if ( !gauntlet.runFinished )
			continue

		TrainingGauntletPostRun_TryAchievements( player, gauntlet )

		FlagSet( "Gauntlet_PlayingFeedbackVO" )

		string feedbackLine = ""

		// SPECIAL- defeated a Hero Ghost
		if ( gauntlet.lastRunDefeatedGhost && !gauntlet.allGhostsDefeated )
		{
			array<GauntletGhost> leaderboard = Gauntlet_GetLeaderboard( gauntlet )
			GauntletGhost playerGhost = Gauntlet_GetPlayerGhost( gauntlet )

			array<string> heroFileNames = [ GHOST_NAME_ALIAS_LASTIMOSA, GHOST_NAME_ALIAS_ANDERSON, GHOST_NAME_ALIAS_BRIGGS ]

			GauntletGhost loserGhost
			foreach ( ghost in leaderboard )
			{
				if ( playerGhost.duration <= ghost.duration && heroFileNames.contains( ghost.fileName ) )
				{
					loserGhost = ghost
					break
				}
			}

			switch ( loserGhost.fileName )
			{
				case GHOST_NAME_ALIAS_LASTIMOSA:
					// "Hey - that was my best time! I must be getting slow."
					feedbackLine = "og_gauntlet_unlocked_leaderboard_entry_og"
					break

				case GHOST_NAME_ALIAS_ANDERSON:
					// "Heh. Can't wait to tell Anderson about that. Son of a bitch..."
					feedbackLine = "og_gauntlet_unlocked_leaderboard_entry_anderson"
					break

				case GHOST_NAME_ALIAS_BRIGGS:
					// "You just beat Commander Briggs. Might not stay that way for long though, she's very competitive."
					feedbackLine = "og_gauntlet_unlocked_leaderboard_entry_briggs"
					break
			}

			if ( feedbackLine != "" )
				waitthread Training_OG_Talks( feedbackLine, ogSpot, "OG_all_done_talk", "OG_all_done_idle", true )
		}

		// SPECIAL - cleared leaderboard
		if ( gauntlet.allGhostsDefeated && !clearedLeaderboard.allPlayed )
		{
			while ( !clearedLeaderboard.allPlayed && !gauntlet.isActive )
			{
				feedbackLine = DialogueGroup_GetNextLine( clearedLeaderboard )
				waitthread Training_OG_Talks( feedbackLine, ogSpot, "OG_all_done_talk", "OG_all_done_idle", true )
			}
		}

		// If we played a line by now, it was Special, so we don't want the generic ones below.
		if ( feedbackLine != "" )
			continue

		// LAST RUN: DEFEATED GHOST (GENERIC)
		if ( gauntlet.lastRunDefeatedGhost && !gauntlet.allGhostsDefeated )
		{
			feedbackLine = DialogueGroup_GetNextLine( defeatedGhost )
		}
		// LAST RUN: BEAT BEST TIME
		else if ( gauntlet.lastRunBestTime )
		{
			feedbackLine = DialogueGroup_GetNextLine( newBestTime )
		}
		// LAST RUN: FAILED TO BEAT BEST TIME
		else
		{
			feedbackLine = DialogueGroup_GetNextLine( notBestTime )
		}

		Assert( feedbackLine != "" )
		waitthread Training_OG_Talks( feedbackLine, ogSpot, "OG_all_done_talk", "OG_all_done_idle", true )
	}
}

void function TrainingGauntletPostRun_TryAchievements( entity player, GauntletInfo gauntlet )
{
	Assert( gauntlet.runFinished )

	GauntletGhost andersonGhost = Gauntlet_GetGhostByFileName( gauntlet, GHOST_NAME_ALIAS_ANDERSON )
	if ( gauntlet.lastRunTime < andersonGhost.duration )
	{
		// Achievement - Beat Pilot Anderson's gauntlet ghost recorder time
		UnlockAchievement( player, achievements.GAUNTLET_BEAT_ANDERSON )
	}

	GauntletGhost playerGhost = Gauntlet_GetPlayerGhost( gauntlet )
	int playerLeaderboardPos = Gauntlet_GetLeaderboardPosition_ForGhostID( gauntlet, playerGhost.id )
	if ( playerLeaderboardPos <= 2 )
	{
		// Achievement - Get a top-3 spot on the Gauntlet scoreboard
		UnlockAchievement( player, achievements.GAUNTLET_TOPTHREE )
	}
}

void function Training_LeaveGauntletThink( entity player, entity ogSpot )
{
	string gauntletExitConversation = "Gauntlet_Exit"
	if ( file.gauntletMode )
		gauntletExitConversation = "Gauntlet_Exit_TechTest"

	GauntletInfo trainingGauntlet = GetTrainingGauntlet()

	// NOTE conversation callbacks need this defined
	file.animref_leaveGauntlet = ogSpot
	AddConversationCallback( gauntletExitConversation, ConvoCallback_TrainingExit )
	AddConversationCallback( "Titanfall_Intro", ConvoCallback_TitanfallIntro)

	int numTimesInitiated = 0

	while ( !Flag( "PlayerConfirmedGauntletExit" ) )
	{
		FlagWait( "Gauntlet_PlayerInExitZone" )

		FlagWaitClear( "Gauntlet_PlayingFeedbackVO" )

		if ( !Flag( "Gauntlet_PlayerInExitZone" ) )
			continue

		if ( !Training_IsGameFullyInstalled() )
		{
			waitthread Gauntlet_GameNotFullyInstalled_Response( player, ogSpot )
			wait 0.1  // HACK make sure we always wait before continuing
			continue
		}

		numTimesInitiated++

		// All done with the gauntlet?
		waitthread Training_OG_ScriptedAnim( ogSpot, "OG_all_done", true )
		Training_OG_Idles( ogSpot, "OG_all_done_idle", true )

		// if player rushed to the gauntlet during the anim, don't wait for conversation
		if ( trainingGauntlet.isActive )
			continue

		// hint if player can't figure out how to conversate
		bool displayedOnscreenHint = false
		if ( numTimesInitiated > 1 && !Flag( "PlayerUsedConversationInterface" ) )
		{
			thread OnscreenHint_DisplayAfterDelay( player, "conversation_hint", 5.0, 1.5 )
			displayedOnscreenHint = true
		}

		// interactive dialogue: Gauntlet Exit
		FlagClear( "GauntletExitConvo_FinishedResponse" )
		thread PlayerConversation( gauntletExitConversation, player, file.ogPilot )

		table result = WaitSignal( player, "ConversationEnded", "PlayerMadeSelection", "Gauntlet_RunStarted" )
		string sig = expect string( result.signal )

		// bug 202299: Also check flag for player confirmed gauntlet exit
		// - player can confirm exit, but if player starts a gauntlet run just before the response line ends, convo can "cancel" causing a prog break here
		if ( sig == "Gauntlet_RunStarted" )
		{
			// HACK- wait a bit to make sure player didn't confirm exit before the conversation ended due to gauntlet run starting
			wait 0.5

			if ( !Flag( "PlayerConfirmedGauntletExit" ) )
			{
				StopConversationNow( player )
				continue
			}
		}

		/*
		#if DEV
		if ( sig == "Gauntlet_RunStarted" && Flag( "PlayerConfirmedGauntletExit" ) )
			printt( "BUG CONDITION DEFEATED" )
		#endif
		*/

		if ( sig == "PlayerMadeSelection" )
			FlagSet( "PlayerUsedConversationInterface" )

		if ( displayedOnscreenHint )
			ClearOnscreenHint( player )

		// wait for callback function to finish doing its thing
		FlagWait( "GauntletExitConvo_FinishedResponse" )

		if ( Flag( "PlayerConfirmedGauntletExit" ) )
			break

		FlagWaitClear( "Gauntlet_PlayerInExitZone" )

		StopConversationNow( player )
	}

	if ( file.gauntletMode )
	{
		GauntletMode_Finished( player )
	}
	else
	{
		// interactive dialogue: Titanfall Intro
		FlagClear( "TitanfallIntroConvo_FinishedResponse" )
		waitthread PlayerConversation( "Titanfall_Intro", player, file.ogPilot )

		FlagWait( "TitanfallIntroConvo_FinishedResponse" )
	}

	wait 0.2

	FlagSet( "PlayerLeavingGauntlet" )
}

void function Gauntlet_GameNotFullyInstalled_Response( entity player, entity ogRef )
{
	EndSignal( player, "OnDestroy" )

	float progress = GetGameFullyInstalledProgress()
	printt( "Game is not fully installed- cannot continue past Gauntlet. Progress:", progress, "/ 1.0" )

	DisplayOnscreenHint( player, "gauntlet_install_hint" )

	OnThreadEnd(
	function() : ( player )
		{
			if ( IsValid( player ) )
				ClearOnscreenHint( player )
		}
	)

	if ( TimerCheck( "installWaitComment" ) )
	{
		DialogueGroup installWait = GetDialogueGroup( "installWait" )
		string line = DialogueGroup_GetNextLine( installWait )
		waitthread Training_OG_Talks( line, ogRef, "OG_all_done_talk", "OG_all_done_idle", true )

		TimerReset( "installWaitComment" )
	}

	while ( Flag( "Gauntlet_PlayerInExitZone" ) && !Training_IsGameFullyInstalled() )
	{
		wait 0.25
	}
}

void function ConvoCallback_TrainingExit( int choice )
{
	EndSignal( file.player, "OnDestroy" )

	OnThreadEnd(
	function() : (  )
		{
			if ( IsValid( file.player ) )
				FlagSet( "GauntletExitConvo_FinishedResponse" )
		}
	)

	printt( "TRAINING EXIT CALLBACK: player chose", choice )
	Assert( choice >= 0 && choice <= 2, "Nothing set up for Training Exit convo choice " + choice )

	// prompt timed out
	if ( choice == 0 )
		return

	Signal( file.player, "PlayerMadeSelection" )

	// player chooses to stay
	if ( choice == 2 )
	{
		waitthread Training_OG_ScriptedAnim( file.animref_leaveGauntlet, "OG_all_done_respond", true )
		Training_OG_Idles( file.animref_leaveGauntlet, "OG_all_done_idle", true )
		return
	}

	// player chooses to leave
	FlagSet( "PlayerConfirmedGauntletExit" )
	printt( "PLAYER CONFIRMED GAUNTLET EXIT" )

	// Good. You're gonna like this.
	 // It's time you learned the other half of being a Pilot: the Titan. Let's go call one in.
	string anim = "OG_gonna_like_this"
	if ( file.gauntletMode )
	{
		// Good. You're gonna like this.
		// Let's get back to the real world.
		anim = "OG_gonna_like_this_tech_test_end"
	}

	waitthread Training_OG_ScriptedAnim( file.animref_leaveGauntlet, anim, true )
	Training_OG_Idles( file.animref_leaveGauntlet, "OG_gonna_like_this_endidle", true )
}

void function ConvoCallback_TitanfallIntro( int choice )
{
	EndSignal( file.player, "OnDestroy" )

	OnThreadEnd(
	function() : (  )
		{
			if ( IsValid( file.player ) )
				FlagSet( "TitanfallIntroConvo_FinishedResponse" )
		}
	)

	printt( "TITANFALL INTRO CALLBACK: player chose", choice )
	Assert( choice >= 0 && choice <= 2, "Nothing set up for Titanfall Intro convo choice " + choice )

	// It's only a simulation, Cooper. It's not the real thing.
	// But first- We're gonna need a little more space
	string responseAnim = "OG_gonna_like_this_respond_A"
	if ( choice == 2 )
	{
		// That's the spirit.
		// But first- We're gonna need a little more space
		responseAnim = "OG_gonna_like_this_respond_B"
	}

	thread Training_OG_ScriptedAnim( file.animref_leaveGauntlet, responseAnim, true )
	float duration = GetOGPilot().GetSequenceDuration( responseAnim )
	wait duration - 1.0

	//Training_OG_Idles( file.animref_leaveGauntlet, "OG_gonna_like_this_endidle", true )
}


// runType: 0 = before beating required time; 1 = in challenge mode
void function TrainingGauntletStats_PostRunUpdate( entity player, GauntletInfo gauntlet, int runType )
{
	Assert( !gauntlet.isActive, "Can't update gauntlet stats reliably while gauntlet is active." )

	// restarted gauntlet from menu
	if ( !gauntlet.runFinished )
	{
		file.trainingGauntletStats.numRestarts++
		printt( "training gauntlet stats updated: numRestarts", file.trainingGauntletStats.numRestarts )

		SendTrainingGauntletStats( player )
		return
	}

	if ( gauntlet.lastRunBestTime )
	{
		file.trainingGauntletStats.bestTime = gauntlet.bestTime
		printt( "training gauntlet stats updated: bestTime", file.trainingGauntletStats.bestTime )
	}

	if ( runType == 0 )
	{
		file.trainingGauntletStats.numRunsBeforeBeatRequiredTime++
		printt( "training gauntlet stats updated: numRunsBeforeBeatRequiredTime", file.trainingGauntletStats.numRunsBeforeBeatRequiredTime )

		if ( gauntlet.bestTime > TRAINING_GAUNTLET_MAX_TIME_TO_PROGRESS )
		{
			// failed to get required time
			SendTrainingGauntletStats( player )
			return
		}
		else
		{
			file.trainingGauntletStats.didBeatRequiredTime = true
			printt( "training gauntlet stats updated: didBeatRequiredTime", file.trainingGauntletStats.didBeatRequiredTime )
		}
	}
	else if ( runType == 1 )
	{
		file.trainingGauntletStats.numChallengeRuns++
		printt( "training gauntlet stats updated: numChallengeRuns", file.trainingGauntletStats.numChallengeRuns )
	}

	SendTrainingGauntletStats( player )
}


void function SendTrainingGauntletStats( entity player )
{
	printt("======== TRAINING GAUNTLET STATS =========" )
	printt( "numRestarts:", 					file.trainingGauntletStats.numRestarts )
	printt( "numRunsBeforeBeatRequiredTime:", 	file.trainingGauntletStats.numRunsBeforeBeatRequiredTime )
	printt( "didBeatRequiredTime:", 			file.trainingGauntletStats.didBeatRequiredTime )
	printt( "numChallengeRuns:", 				file.trainingGauntletStats.numChallengeRuns )
	printt( "bestTime:", 						file.trainingGauntletStats.bestTime )
	printt("========= END TRAINING GAUNTLET STATS ==========" )
	SendTrainingGauntletStatsToBackend(
			player,
			file.trainingGauntletStats.didBeatRequiredTime ? file.trainingGauntletStats.numRunsBeforeBeatRequiredTime : 0,
			file.trainingGauntletStats.numChallengeRuns,
			file.trainingGauntletStats.bestTime
			)
}


bool function Training_IsGameFullyInstalled()
{
	#if DEV
	if ( INSTALL_DELAY_TEST )
		return file.fakeInstallDone
	#endif

	return IsGameFullyInstalled()
}

#if DEV
void function setfakeinstalldone( bool isDone )
{
	file.fakeInstallDone = isDone
}
#endif


// ===================================
// ============ TITANFALL ============
// ===================================
void function Training_Setup_Titanfall( entity player )
{
	entity ogRef_titanfall = GetEntByScriptName( "og_titanfall_start_pos" )
	entity og = Training_SpawnOGPilot( ogRef_titanfall )
	Training_OG_Idles_Sitting( ogRef_titanfall, "OG_first_titan_idle" )

	player.DisableWeapon()  // player weapon is disabled before teleport to Titanfall area starts

	TeleportPlayerAndBT( "startpoint_titanfall" )
}

void function Training_Skipped_Titanfall( entity player )
{
	player.SetExtraWeaponMods( ["training_low_ammo_disable"] )
	SetWeaponHUDEnabled( player, false )
}

void function Training_Titanfall( entity player )
{
	thread Titanfall_EnableWeaponDelayed( player, 0.9 )

	thread TakeAmmoFromPlayerASAP( player )
	thread Titanfall_SpecialWeaponRemove( player )

	entity og = GetOGPilot()
	entity ogRef_titanfall = GetEntByScriptName( "og_titanfall_start_pos" )
	Training_OG_Idles_Sitting( ogRef_titanfall, "OG_first_titan_idle" )

	vector twinRefSpawnOrg = TitanfallGlitch_WorldChange_GetOtherWorldPos( ogRef_titanfall.GetOrigin(), true )
	entity ogRef_titanfall_twin = CreateScriptMover( twinRefSpawnOrg, ogRef_titanfall.GetAngles() )
	entity ogTwin = Training_SpawnOGTwin( ogRef_titanfall_twin )
	Training_NPC_Idles_Sitting( ogTwin, ogRef_titanfall_twin, "OG_first_titan_idle" )

	OnThreadEnd(
	function() : ( player, ogTwin, ogRef_titanfall_twin )
		{
			if ( IsValid( player ) )
				player.UnfreezeControlsOnServer()

			if ( IsValid( ogTwin ) )
				ogTwin.Destroy()

			if ( IsValid( ogRef_titanfall_twin ) )
				ogRef_titanfall_twin.Destroy()
		}
	)

	//testglitch()
	//wait 1000000

	thread Titanfall_BT_Think( player, 6.5 )

	wait 2.0

	// "That's my partner, BT. He's a Vanguard-class."
	// "Homegrown Militia technology."
	// "The first Titan chassis we designed ourselves. One we didn't have to steal from the IMC."
	waitthread Training_OG_ScriptedAnim( ogRef_titanfall, "OG_Partner_BT", true )
	Training_OG_Idles_Sitting( ogRef_titanfall, "OG_first_titan_idle", true )

	wait 1.1  // take a breath between lines

	thread Training_EnableTitanfallAndNag( player, ogRef_titanfall, 25.0 )

	// "Go ahead Rifleman, call in your first Titan."
	Titanfall_ResetHintVOTimer()  // in case player calls in Titan during this line
	waitthread Training_OG_ScriptedAnim( ogRef_titanfall, "OG_First_Titan", true )
	Training_OG_Idles_Sitting( ogRef_titanfall, "OG_first_titan_idle", true )

	FlagWait( "PlayerStartedTitanfall" )
	// Don't start OG's next line until the nag is done, to avoid overlap
	wait Titanfall_GetHintVORemainingDuration()

	// "Look up, to the sky- there he is."
	waitthread Training_OG_ScriptedAnim( ogRef_titanfall, "OG_Look_Up", true )
	Training_OG_Idles_Sitting( ogRef_titanfall, "OG_first_titan_idle", true )

	thread Titanfall_QuickdeathCustomResetPlayerPos( player, file.playerTitanCallInPos, "PodOutroStarted" )

	// wait for titan to appear
	while ( !GetPlayerTitanInMap( player ) )
		wait 0.1

	entity titan = GetPlayerTitanInMap( player )

	// "glitch" interrupts titan drop
	FlagWait( "TitanfallGlitchStart" )

	PlayMusic( "music_training_01_glitch" )

	// Glitch ends when this function ends
	float totalGlitchTime = 2.9
	float glitchEndTime = Time() + totalGlitchTime

	wait 1.0
	player.FreezeControlsOnServer()

	thread Training_OG_ScriptedAnim( ogRef_titanfall, "OG_Pulling_You_Out", true )

	wait glitchEndTime - Time()

	if ( IsValid( titan ) )
		titan.Destroy()

	if ( IsValid( file.titanTwin ) )
		file.titanTwin.Destroy()
}

void function Titanfall_EnableWeaponDelayed( entity player, float delay )
{
	EndSignal( player, "OnDestroy" )

	if ( delay > 0 )
		wait delay

	player.EnableWeapon()
	player.SetExtraWeaponMods( ["training_low_ammo_disable"] )
	SetWeaponHUDEnabled( player, false )
}

void function Titanfall_SpecialWeaponRemove( entity player )
{
	array<entity> weapons = player.GetMainWeapons()
	int numWeaponsStart = weapons.len()

	foreach ( equippedWeapon in weapons )
	{
		string equippedWeaponClassName = equippedWeapon.GetWeaponClassName()
		if ( equippedWeaponClassName == "mp_weapon_lstar" )  // LSTAR display blinks annoyingly if ammo is gone
		{
			// give player a weapon if we are going to take their only weapon
			if ( numWeaponsStart <= 1 )
				player.GiveWeapon( "mp_weapon_semipistol" )

			player.TakeWeapon( equippedWeaponClassName )

			break
		}
	}
}

void function Titanfall_BT_Think( entity player, float getUpDelay = 0.0 )
{
	EndSignal( player, "OnDestroy" )

	entity spawnRef = GetEntByScriptName( "titanfall_bt_spawn_ref" )
	vector spawnOrg = spawnRef.GetOrigin()
	vector spawnAng = spawnRef.GetAngles()

	// create BT
	TitanLoadoutDef loadout = GetTitanLoadoutForPlayer( player )
	entity bt = CreateNPCTitan( loadout.setFile, player.GetTeam(), spawnOrg, spawnAng, loadout.setFileMods )
	bt.ai.titanSpawnLoadout = loadout
	bt.kv.spawnflags = SF_NPC_ALLOW_SPAWN_SOLID
	DispatchSpawn( bt )

	entity animref = CreateScriptMover( spawnOrg, spawnAng )

	OnThreadEnd(
	function() : ( bt, animref )
		{
			if ( IsValid( bt ) )
				bt.Destroy()

			if ( IsValid( animref ) )
				animref.Destroy()
		}
	)

	bt.EnableNPCFlag( NPC_IGNORE_FRIENDLY_SOUND )
	bt.SetEfficientMode( true )
	bt.SetTouchTriggers( false )
	bt.SetNoTarget( true )
	bt.UnsetUsable()
	bt.SetInvulnerable()
	bt.EnableRenderAlways()

	bt.SetTitle( "#NPC_BT_NAME" )
	ShowName( bt )

	DisableTitanfallForLifetimeOfEntityNearOrigin( bt, bt.GetOrigin(), TITANHOTDROP_DISABLE_ENEMY_TITANFALL_RADIUS )

	// HACK this anim pops if it's played off of the animref,
	//  but looks good if played off BT before using the animref for the rest
	thread PlayAnim( bt, "bt_training_scripted_kneel_idle", bt )

	if ( getUpDelay > 0 )
		wait getUpDelay

	waitthread PlayAnim( bt, "bt_training_scripted_kneel2stand", animref )
	thread PlayAnim( bt, "bt_training_scripted_stand_idle", animref )

	FlagWait( "PodOutroStarted" )
}

void function Titanfall_QuickdeathCustomResetPlayerPos( entity player, vector titanCallInPos, string endFlag )
{
	FlagEnd( endFlag )

	entity resetEnt = GetEntByScriptName( "ref_titanfall_quickdeath_reset" )
	vector resetPos = resetEnt.GetOrigin()

	while ( 1 )
	{
		WaitSignal( player, "QuickDeath" )

		vector angToCallInPos = VectorToAngles( titanCallInPos - resetPos )
		float viewTiltUpAngX = -10.0  // goose the view up a little
		vector viewAng = <viewTiltUpAngX, angToCallInPos.y, 0>

		player.p.quickDeathOrigin = resetPos
		player.p.quickDeathAngles = viewAng
	}
}

void function Training_EnableTitanfallAndNag( entity player, entity ogRef, float nagDelay )
{
	EndSignal( player, "OnDestroy" )

	SetGlobalNetBool( "trainingTitanfallEnabled", true )
	AddClientCommandCallback( "ClientCommand_TrainingRequestedTitanfall", Training_RequestTitanfall )

	float onscreenHintDisplayTime = nagDelay * 0.5
	thread OnscreenHint_DisplayAfterDelay( player, "titanfall_hint", onscreenHintDisplayTime, 3.5 )  // extra delay on first screen prompt so pros can call it in

	Objective_SetSilent( "#TRAINING_OBJ_CALL_TITAN" )

	// "Titan's ready. Call it in."
	// "Titan's ready to drop. On your mark."
	array<string> titanfallNags = [ "og_titanfall_nag_1", "og_titanfall_nag_2" ]

	DialogueGroup callInTitan = GetDialogueGroup( "callInTitan" )
	while ( !Flag( "PlayerStartedTitanfall" ) )
	{
		FlagWaitWithTimeout( "PlayerStartedTitanfall", nagDelay )
		if ( Flag( "PlayerStartedTitanfall" ) )
			break

		thread OnscreenHint_DisplayAfterDelay( player, "titanfall_hint", onscreenHintDisplayTime, 2.5 )

		string line = DialogueGroup_GetNextLine( callInTitan )
		Titanfall_ResetHintVOTimer()
		waitthread Training_OG_Talks_Sitting( line, ogRef, "OG_first_titan_talk", "OG_first_titan_idle" )
	}

	Objective_SetSilent( "#TRAINING_OBJ_DEFAULT" )
	ClearOnscreenHint( player )
}


// CUSTOM HOTDROP
bool function Training_RequestTitanfall( entity player, array<string> args )
{
	Training_ReplacementTitan( player ) //Separate function because other functions will call ReplacementTitan
	return true
}

bool function Training_ReplacementTitan( entity player )
{
	Assert( IsAlive( player ) )

	Assert ( !GetPlayerTitanInMap( player ) )

	Point spawnPoint = GetTitanReplacementPoint( player, false )
	vector origin = spawnPoint.origin
	vector angles = spawnPoint.angles

	file.playerTitanCallInPos = origin

	FlagSet( "PlayerStartedTitanfall" )
	SetGlobalNetBool( "trainingTitanfallEnabled", false )

	thread Training_CreateTitanForPlayerAndHotdrop( player, origin, angles )

	return true
}

#if DEV
void function testglitch()
{
	thread Training_CreateTitanForPlayerAndHotdrop( GetPlayerArray()[0], <2048, -2852, -349>, <0,0,0> )
}
#endif

void function Training_CreateTitanForPlayerAndHotdrop( entity player, vector spawnOrg, vector spawnAng )
{
	Assert( IsValid( player ) )
	OnThreadEnd(
		function() : ( player )
		{
			if ( !IsValid( player ) )
				return

			player.ClearHotDropImpactTime()
		}
	)

	player.EndSignal( "OnDestroy" )

	vector origin = spawnOrg
	vector angles
	if ( spawnAng != < 0.0, 0.0, 0.0 > )
		angles = spawnAng
	else
		angles = VectorToAngles( FlattenVector( player.GetViewVector() ) * -1 )	// face the player

	printt( "Dropping replacement titan at " + origin + " with angles " + angles )

	player.Signal( "CalledInReplacementTitan" )

	int playerTeam = player.GetTeam()

	// spawn the Titan that will drop
	TitanLoadoutDef loadout = GetTitanLoadoutForPlayer( player )
	entity titan = CreateAutoTitanForPlayer_FromTitanLoadout( player, loadout, origin, angles )
	DispatchSpawn( titan )
	titan.EndSignal( "OnDeath" )

	titan.SetSkin( 2 )  // "Sarah Briggs" Vanguard skin
	titan.SetTitle( "#NPC_BT_SPARE_NAME" )
	HideName( titan )
	TakeAllWeapons( titan )
	titan.SetEfficientMode( true )
	titan.SetTouchTriggers( false )
	titan.SetNoTarget( true )
	titan.UnsetUsable() // Disable titan embark

	titan.Hide()

	OnThreadEnd(
		function() : ( titan )
		{
			if ( !IsValid( titan ) )
				return

			// removed so that model highlight always works for you autotitan
			//	titan.DisableRenderAlways()
		}
	)

	// based on "at_hotdrop_drop_2knee_turbo"
	string animation = "bt_hotdrop_glitch_descent"
	string postButtonPressSFX = "training_scr_titan_glitch_button_press"
	string hotdropToGlitchSFX = "training_anim_glitch_scene"

	EmitSoundOnEntity( player, postButtonPressSFX )

	float hotDropAnimDuration = titan.GetSequenceDuration( animation )

	float extraSpawnDelay = 1.5  // bit of extra padding time for "Look up, to the sky" VO to sink in
	extraSpawnDelay += Titanfall_GetHintVORemainingDuration()

	// Glitched hotdrop anim created by trimming the end from normal hotdrop anim (glitch starts just before the Titan hits the ground)
	//  - add this little bit back so the timer looks "correct" (longer than actual anim duration)
	float arrivalTimerDuration = 0.7
	arrivalTimerDuration += (hotDropAnimDuration + extraSpawnDelay)  // now add the rest of the normal delays before arrival
	thread Training_DrawReplacementTitanLocation( player, origin, arrivalTimerDuration )

	wait extraSpawnDelay

	titan.Show()
	ShowName( titan )

	Attachment result = titan.Anim_GetAttachmentAtTime( animation, "OFFSET", (hotDropAnimDuration - 0.1) )
	vector maxs = titan.GetBoundingMaxs()
	vector mins = titan.GetBoundingMins()
	int mask = titan.GetPhysicsSolidMask()
	origin = ModifyOriginForDrop( origin, mins, maxs, result.position, mask )

	titan.SetInvulnerable() //Make Titan invulnerable until bubble shield is up. Cleared in OnTitanHotdropImpact
	titan.EnableRenderAlways()

	int teamNum = TEAM_UNASSIGNED
	if ( IsValid( player ) )
		teamNum = player.GetTeam()

	vector fwdToPlayer = player.GetOrigin() - origin
	vector facingAngles = VectorToAngles( fwdToPlayer )
	vector facingAngles2D = <facingAngles.x, facingAngles.y, 0>
	angles = facingAngles2D

	//FadeOutSoundOnEntity( player, postButtonPressSFX, 1.0 )
	EmitSoundOnEntity( player, hotdropToGlitchSFX )

	thread PlayAnimTeleport( titan, animation, origin, angles )
	wait hotDropAnimDuration - 0.1

	titan.SetTouchTriggers( true )

	thread TitanfallGlitch( player, titan, origin, angles )
}

void function Titanfall_ResetHintVOTimer()
{
	file.titanfallNagStartTime = Time()
}

float function Titanfall_GetHintVORemainingDuration()
{
	if ( file.titanfallNagStartTime == -1 )
		return 0

	float duration = TITANFALL_NAG_DURATION - (Time() - file.titanfallNagStartTime)
	if ( duration < 0 )
		duration = 0

	return duration
}

bool function Titanfall_IsHintVOStillPlaying()
{
	 return Titanfall_GetHintVORemainingDuration() >= 0
}

void function TitanfallGlitch( entity player, entity titan, vector origin, vector angles )
{
	if ( Flag( "PodOutroStarted" ) )
		return
	FlagEnd( "PodOutroStarted" )

	player.EndSignal( "OnDestroy" )
	titan.EndSignal( "OnDestroy" )

	titan.Signal( "glitch_start" )
	FlagSet( "TitanfallGlitchStart" )

	if ( IsValid( file.titanTwin ) )
		file.titanTwin.Destroy()

	entity titanTwin = CreatePropScript( BUDDY_MODEL, titan.GetOrigin(), titan.GetAngles() )
	file.titanTwin = titanTwin
	vector twinOrigin = TitanfallGlitch_WorldChange_GetOtherWorldPos( origin, true )

	array<entity> sceneTitans = [ titan, titanTwin ]

	// idle on last frame of descent anim
	titanTwin.Anim_Stop()
	titan.Anim_Stop()
	string endIdleAnim = GetDefaultTitanfallGlitchAnim()
	thread PlayAnimTeleport( titanTwin, endIdleAnim, twinOrigin, angles )
	thread PlayAnimTeleport( titan, endIdleAnim, origin, angles )

	// DEPRECATED no more glitchy anims
	// do this on the hotdropping titan to blend out of the hotdrop better (but makes the proxy on the client out of sync)
	// - in the future, need to play all the hotdrop anims on the proxy as well, to let it blend the same
	//thread PlayAnim( titan, endIdleAnim, origin, angles, 0.1 )

	// START GLITCH SEQUENCE

	// setup for client extra flicker
	titan.Hide()
	titanTwin.Hide()
	int eHandle_titan = titan.GetEncodedEHandle()
	int eHandle_twin = titanTwin.GetEncodedEHandle()
	Remote_CallFunction_Replay( player, "ScriptCallback_TitanfallGlitch_ExtraFlicker", eHandle_titan )
	Remote_CallFunction_Replay( player, "ScriptCallback_TitanfallGlitch_ExtraFlicker", eHandle_twin, true )
	SetGlobalNetBool( "titanGlitch_extraFlicker", true )  // makes him flicker until the world starts changing

	// DEPRECATED Not doing the huge anim moves might work better for the glitch moment, trying it out
	//thread TitanfallGlitch_CycleTitanGlitchAnims_OnWorldChange( player, titan, titanTwin, origin, twinOrigin, angles )

	float screenFXTime = 4.5
	float screenFXStartDelay = 0.1
	thread StartGlitchScreenFX_Delayed( player, screenFXTime, screenFXStartDelay )

	// FIRST IMPACT
	float firstShakeDuration = 3.0

	float shakeAmplitude = 14.0
	float screenBlurFrac = 0.25
	SimpleScreenShake( player, firstShakeDuration, shakeAmplitude, screenBlurFrac )

	// juice it with extra rumble
	// note- this is not juicing it as much as I would expect... even cranking the amplitude doesn't really work that well
	float rumbleAmplitude = 50.0
	float rumbleFrequency = 170
	float rumbleDuration = 4.5
	CreateShakeRumbleOnly( player.GetOrigin(), rumbleAmplitude, rumbleFrequency, rumbleDuration )

	// let the titan idle for a moment
	float postDescentIdleTime = 1.0
	wait postDescentIdleTime

	float firstShakeDuration_remaining = firstShakeDuration - postDescentIdleTime
	// DEPRECATED trying without world changes
	//thread TitanfallGlitch_PlayerWorldChange( player, firstShakeDuration_remaining * 0.9, 0.0 )

	wait firstShakeDuration_remaining

	/* DEPRECATED don't need smaller shakes now that the scene only lasts a short time
	printt( "FIRST IMPACT DONE")

	// LOOPING SMALLER IMPACTS
	float shakeDuration_min = 2.5
	float shakeDuration_max = 3.0
	shakeAmplitude = 5.5
	screenBlurFrac = 0.6
	while ( 1 )
	{
		float shakeDuration = RandomFloatRange( shakeDuration_min, shakeDuration_max )

		SimpleScreenShake( player, shakeDuration, shakeAmplitude, screenBlurFrac )
		thread TitanfallGlitch_PlayerWorldChange( player, shakeDuration * 0.85, shakeDuration * 0.1 )

		wait shakeDuration
	}
	*/
}

void function StartGlitchScreenFX_Delayed( entity player, float screenFXTime, float delay )
{
	if ( Flag( "PodOutroStarted" ) )
		return
	FlagEnd( "PodOutroStarted" )

	EndSignal( player, "OnDestroy" )

	if ( delay > 0 )
		wait delay

	Remote_CallFunction_Replay( player, "ScriptCallback_PodGlitch_PlayerScreenFX", screenFXTime )
}

const float GLITCH_WORLD_CHANGE_WAIT_MIN = 0.1
const float GLITCH_WORLD_CHANGE_WAIT_MAX = 0.35
const float GLITCH_WORLD_CHANGE_MINWAIT_FOR_EXTRA_FLICKER = 0.25

void function TitanfallGlitch_CycleTitanGlitchAnims_OnWorldChange( entity player, entity mainTitan, entity titanTwin, vector origin, vector twinOrigin, vector angles, float delay = 0.0 )
{
	player.EndSignal( "OnDestroy" )
	mainTitan.EndSignal( "OnDestroy" )
	titanTwin.EndSignal( "OnDestroy" )

	array<entity> sceneTitans = [ mainTitan, titanTwin ]

	OnThreadEnd(
	function() : ( player, sceneTitans )
		{
			if ( IsValid( player ) )
			{
				FlagClear( "PlayerWorldChangeThread" )
				SetGlobalNetBool( "titanGlitch_extraFlicker", false )
			}

			foreach ( titan in sceneTitans )
				if ( IsValid( titan ) )
					titan.Show()
		}
	)

	if ( delay > 0 )
		wait delay

	array<string> titanAnims = GetTitanfallGlitchAnims()
	array<string> twinAnims = GetTitanfallGlitchTwinAnims()
	Assert( titanAnims.len() == twinAnims.len() )
	int animIdx = GetGlobalNetInt( "titanfallGlitchAnimIdx" )

	while ( 1 )
	{
		table result = WaitSignal( player, "Glitch_WorldChanging_Zen", "Glitch_WorldChanging_NonZen" )
		string signal = expect string( result.signal )

		float worldChangeDuration = expect float( result.postChangeWait )

		//printt( "titan anim:", titanAnims[animIdx] )

		mainTitan.Anim_Stop()
		titanTwin.Anim_Stop()
		thread PlayAnimTeleport( mainTitan, titanAnims[animIdx], origin, angles )
		thread PlayAnimTeleport( titanTwin, twinAnims[animIdx], twinOrigin, angles )

		animIdx++
		if ( animIdx >= titanAnims.len() )
			animIdx = 0

		SetGlobalNetInt( "titanfallGlitchAnimIdx", animIdx )

		// update flicker settings & show/hide server versions of the titans
		if ( signal == "Glitch_WorldChanging_Zen" )
		{
			// only do extra flicker if a longer world change pause is happening
			if ( worldChangeDuration >= GLITCH_WORLD_CHANGE_MINWAIT_FOR_EXTRA_FLICKER )
			{
				SetGlobalNetBool( "titanGlitch_extraFlicker", true )

				foreach ( titan in sceneTitans )
					titan.Hide()
			}
		}
		else if ( signal == "Glitch_WorldChanging_NonZen" )
		{
			SetGlobalNetBool( "titanGlitch_extraFlicker", false )

			foreach ( titan in sceneTitans )
				titan.Show()
		}
		else
		{
			Assert( false, "Couldn't find signal: " + signal )
		}
	}
}


void function TitanfallGlitch_PlayerWorldChange( entity player, float duration, float delay = 0.0 )
{
	if ( Flag( "PodOutroStarted" ) )
		return
	FlagEnd( "PodOutroStarted" )

	EndSignal( player, "OnDestroy" )

	if ( delay > 0 )
		wait delay

	FlagWaitClear( "PlayerWorldChangeThread" )
	FlagSet( "PlayerWorldChangeThread" )

	OnThreadEnd(
	function() : ( player )
		{
			if ( IsValid( player ) )
				FlagClear( "PlayerWorldChangeThread" )
		}
	)

	bool isInZenWorld = true

	float endTime = Time() + duration

	float minWait = GLITCH_WORLD_CHANGE_WAIT_MIN
	float maxWait = GLITCH_WORLD_CHANGE_WAIT_MAX

	while ( 1 )
	{
		// at end time, make sure player pos resets back to zen world before breaking
		if ( Time() >= endTime && isInZenWorld )
			break

		vector newpos = TitanfallGlitch_WorldChange_GetOtherWorldPos( player.GetOrigin(), isInZenWorld )

		float postChangeWait
		string changeSignal
		entity newSkyCam

		if ( isInZenWorld )
		{
			// Switch to non zen world
			changeSignal = "Glitch_WorldChanging_NonZen"
			postChangeWait = minWait // always wait min time in non zen world

			newSkyCam = file.skycam_glitch
			isInZenWorld = false
		}
		else
		{
			// Switch back to zen world
			postChangeWait = RandomFloatRange( minWait, maxWait )
			changeSignal = "Glitch_WorldChanging_Zen"

			newSkyCam = file.skycam_default
			isInZenWorld = true
		}

		table<string,float> extraInfo = {}
		extraInfo["postChangeWait"] <- postChangeWait
		Signal( player, changeSignal, extraInfo )

		player.SetSkyCamera( newSkyCam )
		player.SetOrigin( newpos )

		wait postChangeWait
	}
}


vector function TitanfallGlitch_WorldChange_GetOtherWorldPos( vector currentPos, bool startInZenWorld )
{
	entity zenEnt 		= GetEntByScriptName( "titan_glitch_swap_ref1" )
	entity nonZenEnt 	= GetEntByScriptName( "titan_glitch_swap_ref2" )
	Assert( zenEnt && nonZenEnt )
	vector zenPos 		= zenEnt.GetOrigin()
	vector nonZenPos 	= nonZenEnt.GetOrigin()

	float offsetX
	float offsetY
	float offsetZ
	float newPosX
	float newPosY
	float newPosZ

	if ( startInZenWorld )
	{
		offsetX = currentPos.x - zenPos.x
		offsetY = currentPos.y - zenPos.y
		offsetZ = currentPos.z - zenPos.z

		newPosX = nonZenPos.x + offsetX
		newPosY = nonZenPos.y + offsetY
		newPosZ = nonZenPos.z + offsetZ
	}
	else
	{
		offsetX = currentPos.x - nonZenPos.x
		offsetY = currentPos.y - nonZenPos.y
		offsetZ = currentPos.z - nonZenPos.z

		newPosX = zenPos.x + offsetX
		newPosY = zenPos.y + offsetY
		newPosZ = zenPos.z + offsetZ
	}

	vector newPos = < newPosX, newPosY, newPosZ >
	return newPos
}


void function Training_DrawReplacementTitanLocation( entity player, vector origin, float delay )
{
	float endTime = Time() + delay

	player.SetHotDropImpactDelay( endTime )
	Remote_CallFunction_Replay( player, "ServerCallback_ReplacementTitanSpawnpoint", origin.x, origin.y, origin.z, endTime )
	player.WaitSignal( "OnDeath" )
}


// ===================================
// ============ POD OUTRO ============
// ===================================
void function Training_Setup_PodOutro( entity player )
{
}

void function Training_Skipped_PodOutro( entity player )
{
	Training_EnvArtColorCorrection_SetEnabled( false )
	SetDoF_Hangar( player )

	Objective_Clear()

	FlagSet( "PodOutroStarted" )
	FlagSet( "SimPodShutdown_LoudspeakerVO_Done" )
}

#if DEV
// bare bones start in pod
void function DEV_PodOutro( entity player )
{
	player.EndSignal( "OnDestroy" )

	TakeAllWeapons( player )

	player.SetExtraWeaponMods( [ "low_ammo_disable" ] )
	SetWeaponHUDEnabled( player, false )

	Training_EnvArtColorCorrection_SetEnabled( false )
	SetDoF_Hangar( player )

	thread MeetOG_BackgroundSkits( player )

	entity pod = file.trainingPod

	TrainingPod_PlayerSequence_DoorsOpenIdle( player, false )

	// anim starts at a slightly different spot
	player.SetOrigin( < 10564, -10235, -6056.9 > )
	player.SetAngles( < -6, 90, 0 > )

	WaitForever()
}
#endif //DEV

void function Training_PodOutro( entity player )
{
	player.EndSignal( "OnDestroy" )

	Objective_Clear()
	CheckPoint_Silent()

	entity pod = file.trainingPod

	FlagSet( "PodOutroStarted" )

	OnThreadEnd(
		function() : ( player, pod )
		{
			if ( IsValid( player ) )
			{
				//StopSoundOnEntity( player, "NPE_Scr_SimPod_End" )

				// Not sure if we need any of this
				//player.Anim_Stop()
				//ClearAnimViewEntity( player )
				//player.ClearParent()
				//player.UnforceStand()
			}

			if ( IsValid ( pod ) )
			{
				// Not sure if we need any of this
				//pod.Anim_Stop()
				//thread TrainingPod_ResetLaserEmitterRotation( pod )
				//thread TrainingPod_KillLasers( pod )
				//thread TrainingPod_KillGlowFX( pod )
				//TrainingPod_KillInteriorDLights()
			}
		}
	)

	// Have to do this first so the anim starts centered on the ref attachment angles
	string podAttach = "REF"
	int attachID = pod.LookupAttachment( podAttach )
	vector podRefOrg = pod.GetAttachmentOrigin( attachID )
	vector podRefAng = pod.GetAttachmentAngles( attachID )
	player.SetOrigin( podRefOrg )
	player.SetAngles( podRefAng )

	player.ForceStand()

	TakeAllWeapons( player )

	// start closed idle
	FirstPersonSequenceStruct playerSequence
	playerSequence.blendTime 			= 0.0
	playerSequence.attachment 			= podAttach
	playerSequence.firstPersonAnimIdle 	= "ptpov_trainingpod_idle"
	playerSequence.thirdPersonAnimIdle 	= "pt_trainingpod_idle"
	playerSequence.viewConeFunction 	= TrainingPod_ViewConeLock_Strict  // so player can't move camera under the pod shutdown screen
	playerSequence.renderWithViewModels = true

	FirstPersonSequenceStruct podSequence
	podSequence.blendTime 				= 0.0
	podSequence.thirdPersonAnimIdle 	= "trainingpod_doors_close_idle"
	podSequence.renderWithViewModels 	= true

	thread FirstPersonSequence( playerSequence, player, pod )
	thread FirstPersonSequence( podSequence, pod )

	thread CadillacMoment_MeetOG( player )

	//thread PodOutro_ScreenShake( player )

	Training_EnvArtColorCorrection_SetEnabled( false )
	SetDoF_Hangar( player )

	// show the "pod shutdown screen"
	float shutdownScreenWait = 7.0
	float screenFadeWait = 7.0
	ScreenFade( player, 0, 0, 0, 255, 0, screenFadeWait, FFADE_OUT | FFADE_STAYOUT )
	Remote_CallFunction_Replay( player, "ScriptCallback_SimPodShutdownScreen", shutdownScreenWait )

	thread SimPodShutdown_Dialogue( player )

	// HACK, need to wait a bit so player moves into pod before initing shutdown sequence
	// - otherwise, interior emitter angle setup math vs player eye position will crash the game
	float waitForPlayerToBeMoved = 1.0
	wait waitForPlayerToBeMoved

	float shutdownSequence_waitBeforeAnimStart = 10.0
	thread TrainingPod_Interior_ShutdownSequence( player, shutdownSequence_waitBeforeAnimStart )

	wait screenFadeWait - waitForPlayerToBeMoved

	// HACK reparent the emitters so they look correct, I didn't expect to have to do this
	TrainingPod_SnapLaserEmittersToAttachPoints()

	// Transition screen FX
	thread PlayFXOnEntity( FX_POD_SCREEN_OUT, player )

	float fadeInFromShutdownScreenTime = 0.2
	ScreenFade( player, 0, 0, 0, 255, fadeInFromShutdownScreenTime, 1, FFADE_IN | FFADE_PURGE )
	wait fadeInFromShutdownScreenTime

	TrainingPod_ViewConeLock_PodClosed( player )

	// start shutdown sequence
	// HACK- eventually one sound will cover the whole sequence
	thread HACK_DelayedShutdownSequenceSFX( player, 3.0 )

	player.Signal( "TrainingPod_BeginInteriorShutdown" )
	wait shutdownSequence_waitBeforeAnimStart

	FirstPersonSequenceStruct playerSequence_podOpens
	playerSequence_podOpens.blendTime 			= 0.25
	playerSequence_podOpens.attachment 			= podAttach
	playerSequence_podOpens.firstPersonAnim 	= "ptpov_trainingpod_doors_open"
	playerSequence_podOpens.firstPersonAnimIdle = "ptpov_trainingpod_idle"
	playerSequence_podOpens.thirdPersonAnim 	= "pt_trainingpod_doors_open"
	playerSequence_podOpens.thirdPersonAnimIdle = "pt_trainingpod_idle"
	playerSequence_podOpens.viewConeFunction 	= TrainingPod_ViewConeLock_SemiStrict
	playerSequence_podOpens.renderWithViewModels = true

	FirstPersonSequenceStruct podSequence_podOpens
	podSequence_podOpens.blendTime 				= 0.25
	podSequence_podOpens.thirdPersonAnim 		= "trainingpod_doors_open"
	podSequence_podOpens.thirdPersonAnimIdle 	= "trainingpod_doors_open_idle"
	podSequence_podOpens.renderWithViewModels 	= true

	thread TrainingPod_TurnOnInteriorDLights_Delayed( player, 1.5 )

	thread FirstPersonSequence( podSequence_podOpens, pod )
	thread FirstPersonSequence( playerSequence_podOpens, player, pod )

	wait 2.1  // wait until scene starts animating for Meet OG
}

void function HACK_DelayedShutdownSequenceSFX( entity player, float delayTime )
{
	EndSignal( player, "OnDestroy" )

	wait delayTime
	EmitSoundOnEntityOnlyToPlayerWithSeek( player, player, "NPE_Scr_SimPod_End", 0.7 )
}

void function PodOutro_ScreenShake( entity player )
{
	if ( Flag( "MeetOG_StartScene" ) )
		return
	FlagEnd( "MeetOG_StartScene" )

	player.EndSignal( "OnDestroy" )

	float shakeDuration = 2.0
	float shakeAmplitude = 0.2
	float screenBlurFrac = 0.0
	float shakeDelayMin = 1.75
	float shakeDelayMax = 2.25
	while ( 1 )
	{
		SimpleScreenShake( player, shakeDuration, shakeAmplitude, screenBlurFrac )
		wait shakeDuration - (shakeDuration * 0.25)  // HACK shake dies down
		wait RandomFloatRange( shakeDelayMin, shakeDelayMax )
	}
}

void function SimPodShutdown_LoudspeakerVO( entity player )
{
	player.EndSignal( "OnDestroy" )

	wait 4.0  // wait for "I'm pulling you out"

	// "Powering down all non-essential systems."
	waitthread PlayLoudspeakerVO( "outro_01_1" )

	// "Prepare for Typhon atmospheric entry in less than three minutes."
	//waitthread PlayLoudspeakerVO( "outro_01" )

	wait 7.0

	// "All personnel to battle stations."
	waitthread PlayLoudspeakerVO( "outro_01_2" )

	// "This is not a drill."
	waitthread PlayLoudspeakerVO( "outro_01_3" )

	FlagSet( "SimPodShutdown_LoudspeakerVO_Done" )
}

void function SimPodShutdown_Dialogue( entity player )
{
	player.EndSignal( "OnDestroy" )

	thread SimPodShutdown_LoudspeakerVO( player )

	Assert( IsValid( file.ogPilot ), "Can't find scene entity ogPilot" )

	// "Alright Rifleman, sounds like it's about to hit the fan."
	waitthread PlayDialogue( "og_hit_the_fan", file.ogPilot )

	// "I'm pulling you out."
	waitthread PlayDialogue( "og_pulling_you_out", file.ogPilot )

	wait 2.0

	// "Cooper! Ready up!"
	waitthread PlayDialogue( "grunt_closed_pod_yell_at_player", file.ogPilot )  // HACK play it off OG until the animation idle is legit

	// "Easy Cole, he just left VR. Needs a minute to decompress. He'll be ready to go... trust me."
	waitthread PlayDialogue( "og_closed_pod_respond_to_grunt", file.ogPilot )

	// "Yes sir."
	waitthread PlayDialogue( "grunt_yes_sir", file.ogPilot )
}

#if DEV
void function shutdownscreentest( float duration = 5.0 )
{
	entity player = file.player
	EndSignal( player, "OnDestroy" )

	float fadeTime = 0.2

	ScreenFade( player, 0, 0, 0, 255, fadeTime, duration, FFADE_OUT | FFADE_STAYOUT )
	Remote_CallFunction_Replay( player, "ScriptCallback_SimPodShutdownScreen", duration )
	wait duration
	ScreenFade( player, 0,0,0, 255, fadeTime, fadeTime, FFADE_IN | FFADE_PURGE )
}
#endif



// =================================
// ============ MEET OG ============
// =================================
void function Training_Setup_MeetOG( entity player )
{
	TakeAllWeapons( player )

	thread CadillacMoment_MeetOG( player )
	TrainingPod_PlayerSequence_DoorsOpenIdle( player )

	wait 0.2
}

void function Training_Skipped_MeetOG( entity player )
{
	// settings for checkpoints after the normal level progression
	SetDoF_Default( player )
	player.SetExtraWeaponMods( [] )  // turn off low_ammo_disable
	SetWeaponHUDEnabled( player, true )
}

void function Training_MeetOG( entity player )
{
	thread MeetOG_BackgroundSkits( player )

	FlagSet( "MeetOG_StartScene" )

	thread MeetOG_ControllerRumble( player )

	FlagWait( "CadillacMoment_MeetOG_StartFadeOut" )

	UnlockAchievement( player, achievements.COMPLETE_TRAINING )

	// Free SP trial? Load Beacon next.
	if( Script_IsRunningTrialVersion() )
	{
		thread FreeTrial_OutroPopup( player, 2.5 )
		PickStartPoint( "sp_beacon", "Level Start" )
	}
	else
	{
		thread OutroDifficultyPopup( player, 2.5 )

		// load next level
		// NOTE this does a screen fade already
		PickStartPoint( "sp_crashsite", "LevelStart" )
	}

	// don't ever progress from here to the dev functions beyond
	WaitForever()
}

void function FreeTrial_OutroPopup( entity player, float delay )
{
	EndSignal( player, "OnDestroy" )
	wait delay

	Remote_CallFunction_UI( player, "ScriptCallback_Training_FreeTrialMessage" )
}

void function OutroDifficultyPopup( entity player, float delay )
{
	EndSignal( player, "OnDestroy" )
	wait delay

	Remote_CallFunction_UI( player, "ScriptCallback_Training_SelectSPDifficulty" )
}

// can't do screen shake for this part because it looks bad (not connected) when player view is 1P animating while parented to the pod
void function MeetOG_ControllerRumble( entity player )
{
	player.EndSignal( "OnDestroy" )
	FlagEnd( "CadillacMoment_MeetOG_StartFadeOut" )

	float shakeDuration = 2.8
	float shakeAmplitudeMin = 13.5
	float shakeAmplitudeMax = 14.5
	float frequency = 155
	float shakeDelayMin = 4.0
	float shakeDelayMax = 7.0
	while ( 1 )
	{
		float amplitude = RandomFloatRange( shakeAmplitudeMin, shakeAmplitudeMax )

		//vector org, float amplitude = 16, float frequency = 150, float duration = 1.5, float radius = 2048
		CreateAirShakeRumbleOnly( player.GetOrigin(), amplitude, frequency, shakeDuration )
		printt( "Shake Rumble:", amplitude )
		wait shakeDuration * 0.75  // HACK shake dies down pretty early

		wait RandomFloatRange( shakeDelayMin, shakeDelayMax )
	}
}

void function CadillacMoment_MeetOG( entity player )
{
	thread MeetOG_LoudspeakerVO( player )

	int friendlyTeam = player.GetTeam()

	entity animref = file.animref_hangar
	vector animrefOrigin = animref.GetOrigin()
	vector animrefAngles = animref.GetAngles()
	vector btSpawnOrg = <0,0,0>  // to avoid red text errors about BT spawning in solid

	entity animEnt = CreateScriptMover( animrefOrigin, animrefAngles )

	// Spawn scene actors
	entity og = Training_SpawnOGPilot( animref )
	Training_OGPilot_SetHelmetOn( og, false )
	SetTeam( og, TEAM_SPECTATOR )  // turn off his glowy bits so they're accentuated when helmet turns on later

	entity anderson = CreateSoldier( friendlyTeam, animrefOrigin, animrefAngles )
	DispatchSpawn( anderson )
	anderson.SetModel( ANDERSON_PILOT_MODEL )
	anderson.SetTitle( "#TRAINING_ANDERSON_NAME" )
	//ShowName( anderson )
	HideName( anderson )

	entity redshirt = CreateSoldier( friendlyTeam, animrefOrigin, animrefAngles )
	DispatchSpawn( redshirt )
	redshirt.SetModel( TEAM_MIL_GRUNT_MODEL_LMG )
	redshirt.SetTitle( "#CPT_COLE" )
	//ShowName( redshirt )
	HideName( redshirt )

	TitanLoadoutDef loadout = GetTitanLoadoutForCurrentMap()
	entity bt = CreateAutoTitanForPlayer_FromTitanLoadout( player, loadout, btSpawnOrg, animrefAngles )
	SetSpawnOption_AISettings( bt, "npc_titan_buddy" )
	bt.kv.spawnflags = SF_NPC_ALLOW_SPAWN_SOLID
	DispatchSpawn( bt )
	FreeAutoTitan( bt )  // HACK this disables the worldspace BT locator icon
	TakeAllWeapons( bt )

	array<entity> actors = [ player, bt, og, anderson, redshirt ]

	// Setup scene props

	entity ogHelmet = CreatePropDynamic( OG_PILOT_HELMET_MODEL )
	ogHelmet.DisableHibernation()
	file.ogHelmet = ogHelmet

	string knifeTag = "KNIFE"
	int knifeTagID = og.LookupAttachment( knifeTag )
	entity dataKnife = CreatePropScript( DATA_KNIFE_MODEL, og.GetAttachmentOrigin( knifeTagID ), og.GetAttachmentAngles( knifeTagID ) )
	dataKnife.DisableHibernation()
  	dataKnife.SetParent( og, knifeTag, false, 0.0 )

	asset btWeaponModel = GetWeaponInfoFileKeyFieldAsset_Global( "mp_titanweapon_xo16_shorty", "playermodel" )
	Assert( btWeaponModel != $"" )
	entity btWeapon = CreatePropDynamic( btWeaponModel )
	btWeapon.SetParent( bt, "PROPGUN" )

	string gruntRifleName 		= "mp_weapon_rspn101"
	string andersonWeaponName 	= "mp_weapon_car"
	asset gruntRifleModel = GetWeaponInfoFileKeyFieldAsset_Global( gruntRifleName, "playermodel" )
	asset andersonWeaponModel = GetWeaponInfoFileKeyFieldAsset_Global( andersonWeaponName, "playermodel" )
	asset ogWeaponModel = GetWeaponInfoFileKeyFieldAsset_Global( OG_WEAPON, "playermodel" )
	Assert( gruntRifleModel != $"" )
	Assert( andersonWeaponModel != $"" )
	Assert( ogWeaponModel != $"" )

	entity ogWeapon = CreatePropDynamic( ogWeaponModel )
	ogWeapon.DisableHibernation()
	ogWeapon.SetParent( og, "PROPGUN" )

	entity andersonWeapon = CreatePropDynamic( andersonWeaponModel )
	andersonWeapon.DisableHibernation()
	andersonWeapon.SetParent( anderson, "PROPGUN" )

	entity redshirtWeapon = CreatePropDynamic( gruntRifleModel )
	redshirtWeapon.DisableHibernation()
	redshirtWeapon.SetParent( redshirt, "PROPGUN" )

	array<entity> props = [ btWeapon, redshirtWeapon, andersonWeapon, ogWeapon, ogHelmet, dataKnife ]

	OnThreadEnd(
	function() : ( actors, props, animEnt )
		{
			foreach ( weapon in props )
			{
				if ( IsValid( weapon ) )
				{
					weapon.ClearParent()
					weapon.Destroy()
				}
			}

			foreach ( actor in actors )
			{
				if ( IsValid( actor ) )
					actor.ClearParent()

				if ( IsInvincible( actor ) )
					ClearInvincible( actor )

				if ( !actor.IsPlayer() )
					actor.Destroy()
			}

			if ( IsValid( animEnt ) )
				animEnt.Destroy()
		}
	)

	foreach ( guy in actors )
	{
		if ( guy.IsPlayer() )
			continue

		MakeInvincible( guy )
		guy.SetEfficientMode( true )
		Highlight_ClearFriendlyHighlight( guy )
	}

	string anim_og 				= "pt_intro_scene_OG"
	string anim_og_helmet 		= "helmet_intro_scene_OG"
	string anim_bt 				= "BT_intro_scene_OG"
	string anim_anderson 		= "pt_intro_scene_Anderson"
	string anim_redshirt 		= "pt_intro_scene_grunt"

	string anim_og_idle 		= "pt_intro_scene_OG_idle"
	string anim_og_helmet_idle 	= "helmet_intro_scene_OG_idle"
	string anim_bt_idle 		= "BT_intro_scene_OG_idle"
	string anim_anderson_idle 	= "pt_intro_scene_Anderson_idle"
	string anim_redshirt_idle 	= "pt_intro_scene_grunt_idle"

	thread PlayAnimTeleport( og, anim_og_idle, animEnt )
	thread PlayAnimTeleport( ogHelmet, anim_og_helmet_idle, animEnt )
	thread PlayAnimTeleport( bt, anim_bt_idle, animEnt )
	thread PlayAnimTeleport( anderson, anim_anderson_idle, animEnt )
	thread PlayAnimTeleport( redshirt, anim_redshirt_idle, animEnt )

	FlagWait( "MeetOG_StartScene" )
	printt( "STARTING ANIMS: MEET OG" )

	foreach ( guy in actors )
		guy.Anim_Stop()

	AddAnimEvent( og, "helmet_on", AnimEventCallback_MeetOG_HelmetTurnsOn )

	thread PlayAnimTeleport( og, anim_og, animEnt )
	thread PlayAnimTeleport( ogHelmet, anim_og_helmet, animEnt )
	thread PlayAnimTeleport( bt, anim_bt, animEnt )
	thread PlayAnimTeleport( anderson, anim_anderson, animEnt )
	thread PlayAnimTeleport( redshirt, anim_redshirt, animEnt )

	player.Anim_Stop()

	// give player weapon for the toss moment
	entity fpProxy = player.GetFirstPersonProxy()
	int attachID = fpProxy.LookupAttachment( "PROPGUN" )
	asset playerWeaponModel = GetWeaponInfoFileKeyFieldAsset_Global( "mp_weapon_vinson", "playermodel" )
	entity playerWeapon = CreatePropDynamic( playerWeaponModel, fpProxy.GetAttachmentOrigin( attachID ), fpProxy.GetAttachmentAngles( attachID ) )
	file.playerAnimWeapon = playerWeapon
	playerWeapon.DisableHibernation()
	playerWeapon.SetParent( fpProxy, "PROPGUN", false, 0.0 )

	AddAnimEvent( player, "gun_catch", AnimEventCallback_MeetOG_PlayerCatchesWeapon )

	FirstPersonSequenceStruct playerSequence_meetOG

	float viewAnimDelay = 4.0
	//playerSequence_meetOG.setInitialTime 		= viewAnimDelay  // DEPRECATED animators will adjust so start position is good again}
	playerSequence_meetOG.blendTime 			= 0.0
	playerSequence_meetOG.teleport 				= false
	playerSequence_meetOG.attachment 			= "REF"
	playerSequence_meetOG.firstPersonAnim 		= "pov_intro_scene_player"
	playerSequence_meetOG.thirdPersonAnim 		= "pt_intro_scene_player"
	playerSequence_meetOG.viewConeFunction 		= TrainingPod_ViewConeLock_SemiStrict
	playerSequence_meetOG.renderWithViewModels 	= true

	// HACK delay sequence so it transitions better from previous anim
	TrainingPod_ViewConeLock_SemiStrict( player )  // set this to cover any time between viewmodel anims
	thread FirstPersonSequence_Delayed( viewAnimDelay, playerSequence_meetOG, player, animEnt )
	//thread FirstPersonSequence( playerSequence_meetOG, player, animEnt )

	// gradual DOF racking during the scene
	RackDoF_NearDepth( player, 0, 22, 12.0 )
	RackDoF_FarDepth( player, 350, 950, 20.0 )

	// find longest anim duration
	array<string> sceneAnims = [ anim_og, anim_bt, anim_anderson, anim_redshirt ]//, "pt_intro_scene_player" ]
	float sceneDuration = -1
	foreach ( anim in sceneAnims )
	{
		entity animActor = og
		if ( anim.find( "BT_") != null )
			animActor = bt
		else if ( anim.find( "_player") != null )
			animActor = player

		float duration = animActor.GetSequenceDuration( anim )
		if ( duration > sceneDuration )
			sceneDuration = duration
	}
	Assert( sceneDuration > 0 )

	float fadeTime = SP_LEVEL_TRANSITION_FADETIME

	wait sceneDuration - fadeTime
	FlagSet( "CadillacMoment_MeetOG_StartFadeOut" )

	wait fadeTime
	FlagSet( "CadillacMoment_MeetOG_Done" )
}

void function FirstPersonSequence_Delayed( float delay, FirstPersonSequenceStruct sequence, entity player, entity animEnt )
{
	EndSignal( player, "OnDestroy" )

	if ( delay > 0 )
		wait delay

	thread FirstPersonSequence( sequence, player, animEnt )
}

void function MeetOG_LoudspeakerVO( entity player )
{
	EndSignal( player, "OnDestroy" )
	FlagWait( "SimPodShutdown_LoudspeakerVO_Done" )

	array<string> aliases
	// "Incoming hostile ship - Designation: IMS Malta. Battle stations."
	aliases.append( "outro_08" )
	// "Caution - Fuel leak in Cargo Bay eighty - five. Activating airlock procedures."
	aliases.append( "outro_12" )
	// "Titan bays two through five, drop clearance confirmed."
	aliases.append( "outro_03" )
	// "All available medical personnel, report to Med Central for tasking."
	aliases.append( "outro_05" )
	// "We need all Riflemen to docking bay four. Dropships standing by."
	aliases.append( "outro_07" )
	// "Infantry teams Stork three, Elk four, Shark six, Badger one, prepare for emergency atmospheric drop sequence"
	aliases.append( "outro_04" )
	// "Titan mech team - Rabbit six, prep the Vanguards."
	aliases.append( "outro_06" )
	// "Infantry teams 2nd Militia Fusiliers, Raptor three, target the IMS Malta."
	aliases.append( "outro_11" )
	// "Special Recon Squad deploy from Drop Bay thirty-seven - now."
	aliases.append( "outro_10" )

	thread LoopLoudspeakerVO( aliases )
}

void function AnimEventCallback_MeetOG_PlayerCatchesWeapon( entity player )
{
	Assert( IsValid( file.playerAnimWeapon ) )
	file.playerAnimWeapon.RenderWithViewModels( true )

	thread MeetOG_PlayerCatchesWeapon_RackNearDOF( player )
}

void function MeetOG_PlayerCatchesWeapon_RackNearDOF( entity player )
{
	EndSignal( player, "OnDestroy" )

	wait 0.7

	RackDOF_NearDepth_ToDefault( player, 1.5 )

	wait 2.0

	RackDoF_NearDepth( player, 0, 22, 1.25 )
}


// ------ OG HELMET TURNING ON ------
void function AnimEventCallback_MeetOG_HelmetTurnsOn( entity og )
{
	thread MeetOG_HelmetTurnsOn( og )
}

// script MeetOG_HelmetTurnsOn( GetOGPilot() )
void function MeetOG_HelmetTurnsOn( entity og )
{
	entity og 		= file.ogPilot
	entity ogHelmet = file.ogHelmet
	EndSignal( og, "OnDestroy" )
	EndSignal( ogHelmet, "OnDestroy" )

	// setting his team to friendly makes the helmet light up
	if ( og.GetTeam() == TEAM_MILITIA )
		SetTeam( og, TEAM_SPECTATOR )

	ogHelmet.Hide()
	Training_OGPilot_SetHelmetOn( og, true )
	wait 0.2

	SetTeam( og, TEAM_MILITIA )
	wait 0.1
	SetTeam( og, TEAM_SPECTATOR )
	wait 0.4
	SetTeam( og, TEAM_MILITIA )
	wait 0.1
	SetTeam( og, TEAM_SPECTATOR )
	wait 0.1
	SetTeam( og, TEAM_MILITIA )
}

#if DEV
void function MeetOG_HelmetTurnsOff( entity og )
{
	entity og 		= file.ogPilot
	entity ogHelmet = file.ogHelmet

	if ( og.GetTeam() == TEAM_SPECTATOR )
		SetTeam( og, TEAM_MILITIA )

	ogHelmet.Show()
	Training_OGPilot_SetHelmetOn( og, false )
}
#endif


// ------ POD OUTRO BACKGROUND SKITS ------
void function MeetOG_BackgroundSkits( entity player, float delay = 0.0 )
{
	string endFlag = "CadillacMoment_MeetOG_Done"
	FlagEnd( endFlag )

	if ( delay > 0 )
		wait delay

	printt( "!!!! Pod Outro Background Skits START !!!!" )

	thread PodOutro_TitanRacks( endFlag )

	thread PodOutro_Background_Runners( player )
	thread PodOutro_Foreground_Runners( player )

	thread PodOutro_Background_ATC_Marvins()

	OnThreadEnd(
	function() : ()
		{
			DeleteAllSkitGuys()
		}
	)

	WaitForever()
}

void function PodOutro_TitanRacks( string endFlag )
{
	FlagEnd( endFlag )

	array<HangarTitanGroup> hangarTitanGroups

	OnThreadEnd(
	function() : ( hangarTitanGroups )
		{
			foreach ( group in hangarTitanGroups )
				HangarTitanGroup_Cleanup( group )
		}
	)

	float wait_earlyEnd 	= 24.0
	bool cleanupAfterAnim 	= false

	// ---  BAY 1 ---
	HangarTitanGroup bay1
	entity rack_bay1 	= GetEntByScriptName( "hangar_titan_rack_1" )
	bay1.ref 			= rack_bay1
	bay1.rack 	 		= rack_bay1
	bay1.titan 			= GetEntByScriptName( "hangar_titan_1" )
	bay1.titanAnim 		= "bt_rack_prep_titan2"
	bay1.rackAnim 		= "rack_rack_prep_rack2"
	bay1.marvinAnim 	= "mv_rack_prep_marvin2"
	bay1.pilotAnim 		= "pt_rack_prep_pilot2"
	bay1.pilotModel 	= PILOT_MODEL_BAY1
	HangarTitanGroup_Init( bay1 )
	hangarTitanGroups.append( bay1 )
	thread HangarTitanGroup_Animate( bay1, endFlag, -1, cleanupAfterAnim )


	// ---  BAY 2 ---
	//thread PodOutro_TitanBoot( endFlag, 15.0 )

	HangarTitanGroup bay2
	entity rack_bay2 		= GetEntByScriptName( "hangar_titan_rack_2" )
	bay2.ref 				= rack_bay2
	bay2.rack 	 			= rack_bay2
	bay2.titan 				= GetEntByScriptName( "hangar_titan_2" )
	bay2.titanAnim 			= "bt_rack_prep_titan1"
	bay2.rackAnim 			= "rack_rack_prep_rack1"
	bay2.marvinAnim 		= "mv_rack_prep_marvin1"
	bay2.pilotAnim 			= "pt_rack_prep_pilot1"
	bay2.pilotModel 		= PILOT_MODEL_BAY2
	HangarTitanGroup_Init( bay2 )
	hangarTitanGroups.append( bay2 )
	waitthread HangarTitanGroup_Animate( bay2, endFlag, -1, cleanupAfterAnim )
}

void function PodOutro_TitanBoot( string endFlag, float delay )
{
	FlagEnd( endFlag )

	entity refTitan = GetEntByScriptName( "hangar_titan_2" )
	refTitan.Hide()

	vector refOrg = refTitan.GetOrigin()
	vector refAng = refTitan.GetAngles()
	refOrg += < -20, 40, 0> // HACK
	refOrg = OriginToGround( refOrg )

	entity animref = CreateScriptRef( refOrg, refAng )

	entity titan = CreatePropScript( BUDDY_MODEL, refOrg, refAng )
	titan.DisableHibernation()

	AddAnimEvent( titan, "hatch_closed", TitanBoot_HatchClosed )
	entity cockpitLightFX = PlayFXOnEntity( FX_COCKPIT_LIGHT, titan, "HIJACK" )

	SkitGuyInfo titanInfo = AddSkitGuy_Manually( "bootup_titan", titan )

	SkitGuyInfo titanPilotInfo = SpawnSkitGuy( "bootup_pilot", "", animref.GetOrigin(), animref.GetAngles(), TEAM_MILITIA, "npc_soldier" )
	entity titanPilot = titanPilotInfo.guy
	titanPilot.SetParent( titan, "HIJACK", false, 0.0 )
	titanPilot.MarkAsNonMovingAttachment()

	SkitGuyInfo crewInfo = SpawnSkitGuy( "bootup_crew", "", animref.GetOrigin(), animref.GetAngles(), TEAM_MILITIA, "npc_soldier_bish" )
	entity crew = crewInfo.guy

	OnThreadEnd(
		function() : ( titanPilotInfo, crewInfo, titanInfo, cockpitLightFX, animref, refTitan )
		{
			if ( IsValid_ThisFrame( cockpitLightFX ) )
			{
				EntFireByHandle( cockpitLightFX, "Stop", "", 0, null, null )
				cockpitLightFX.ClearParent()
				cockpitLightFX.Destroy()
			}

			if ( IsAlive( titanInfo.guy ) )
				StopSoundOnEntity( titanInfo.guy, "Wargames_MCOR_TitanActivate" )

			if ( IsValid( animref ) )
				animref.Destroy()

			DeleteSkitGuy( titanPilotInfo )
			DeleteSkitGuy( crewInfo )
			DeleteSkitGuy( titanInfo )

			if ( IsValid( refTitan ) )
				refTitan.Show()
		}
	)

	EmitSoundOnEntity( titan, "Wargames_MCOR_TitanActivate" )

	string pilotAnim 		= "pt_titan_activation_pilot"
	string pilotAnim_idle 	= "pt_titan_activation_pilot_idle"
	string titanAnim 		= "at_titan_activation_training_meetOG"
	string titanAnim_idle 	= "at_titan_activation_idle"
	string titanAnim_endIdle = "at_titan_activation_training_meetOG_end_idle"
	string crewAnim 		= "pt_titan_activation_crew"
	string crewAnim_idle 	= "pt_titan_activation_crew_idle"

	if ( delay > 0 )
	{
		thread PlayAnim( crew, crewAnim_idle, animref, null, 0.0 )
		thread PlayAnim( titan, titanAnim_idle, animref, null, 0.0 )
		titanPilot.Anim_ScriptedPlay( pilotAnim_idle )
		titanPilot.Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion()

		wait delay

		titanPilot.Anim_Stop()
		crew.Anim_Stop()
		titan.Anim_Stop()
	}

	titanPilot.Anim_ScriptedPlay( pilotAnim )
	titanPilot.Anim_EnableUseAnimatedRefAttachmentInsteadOfRootMotion()
	thread PlayAnim( crew, crewAnim, animref, null, DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME )
	thread PlayAnim( titan, titanAnim, animref, null, DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME )

	// end it early so he doesn't make stomping sounds when the pod is closed
	//wait 15.0
	float duration = titan.GetSequenceDuration( titanAnim )
	wait duration - 0.1

	printt( "Ending titan boot anim" )

	thread PlayAnim( titan, titanAnim_endIdle, animref, null, DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME )
	crew.Freeze()

	WaitForever()
}

void function TitanBoot_HatchClosed( entity titan )
{
	SkitGuyInfo info = GetSkitGuyInfo_ByName( "bootup_pilot" )
	DeleteSkitGuy( info )
}

void function PodOutro_Background_Runners( entity player )
{
	EndSignal( player, "OnDestroy" )

	// right to left, across the whole hangar
	array<Point> path1 = []
	ScriptedPath_AddPoint( path1, < 11080.5, -10017.2, -6079.97 >, < 0, 177.587, 0 > )
	ScriptedPath_AddPoint( path1, < 9619.14, -10004.8, -6079.97 >, < 0, 183.021, 0 > )

	// right to left, starts closer to player POV
	array<Point> path2 = []
	ScriptedPath_AddPoint( path2, < 11000, -9946.33, -6079.97 >, < 0, 177.587, 0 > )
	ScriptedPath_AddPoint( path2, < 9619.14, -10004.8, -6079.97 >, < 0, 183.021, 0 > )

	wait 2.0  // wait for OG's first line to be nearly over

	printt( "BACKGROUND RUNNER GROUP 1" )

	thread SpawnSkitGuy_AndRun( "runner_1_1", path2, 0.85, TEAM_MILITIA, "npc_soldier_specialist_militia", "mp_weapon_hemlok_smg" )
	wait 1.0
	thread SpawnSkitGuy_AndRun( "runner_1_2", path2, 0.85, TEAM_MILITIA, "npc_soldier", "mp_weapon_rspn101" )

	wait 6.5  // wait until OG hands the eye to BT

	printt( "BACKGROUND RUNNER GROUP 2" )

	thread SpawnSkitGuy_AndRun( "runner_2_1", path2, 0.8, TEAM_MILITIA, "npc_soldier", "mp_weapon_rspn101" )
	wait 1.0
	thread SpawnSkitGuy_AndRun( "runner_2_2", path2, 0.8, TEAM_MILITIA, "npc_soldier", "mp_weapon_shotgun" )

	wait 4.5  // wait until OG is shaking Anderson's hand

	printt( "BACKGROUND RUNNER GROUP 3" )

	thread SpawnSkitGuy_AndRun( "runner_3_1", path2, 0.8, TEAM_MILITIA, "npc_soldier", "mp_weapon_rspn101" )
	wait 1.0
	thread SpawnSkitGuy_AndRun( "runner_3_2", path2, 0.8, TEAM_MILITIA, "npc_soldier", "mp_weapon_shotgun" )
	wait 1.0
	thread SpawnSkitGuy_AndRun( "runner_3_3", path2, 0.8, TEAM_MILITIA, "npc_soldier_specialist_militia", "mp_weapon_hemlok_smg" )
	wait 1.0
	thread SpawnSkitGuy_AndRun( "runner_3_4", path2, 0.8, TEAM_MILITIA, "npc_soldier", "mp_weapon_rspn101" )

	wait 4.5  // wait until OG is mounting up

	printt( "BACKGROUND RUNNER GROUP 4" )

	thread SpawnSkitGuy_AndRun( "runner_4_1", path2, 0.8, TEAM_MILITIA, "npc_soldier", "mp_weapon_rspn101" )
	wait 1.0
	thread SpawnSkitGuy_AndRun( "runner_4_2", path2, 0.8, TEAM_MILITIA, "npc_soldier", "mp_weapon_shotgun" )

	wait 6.5  // wait until OG thumbs up

	printt( "BACKGROUND RUNNER GROUP 5" )

	thread SpawnSkitGuy_AndRun( "runner_5_1", path2, 0.85, TEAM_MILITIA, "npc_soldier_specialist_militia", "mp_weapon_hemlok_smg" )
	wait 1.2
	thread SpawnSkitGuy_AndRun( "runner_5_2", path2, 0.8, TEAM_MILITIA, "npc_soldier", "mp_weapon_rspn101" )
	wait 1.0
	thread SpawnSkitGuy_AndRun( "runner_5_3", path2, 0.8, TEAM_MILITIA, "npc_soldier", "mp_weapon_shotgun" )
	wait 1.5
	thread SpawnSkitGuy_AndRun( "runner_5_4", path2, 0.85, TEAM_MILITIA, "npc_soldier", "mp_weapon_rspn101" )
	wait 1.0
	thread SpawnSkitGuy_AndRun( "runner_5_3", path2, 0.8, TEAM_MILITIA, "npc_soldier", "mp_weapon_shotgun" )
	wait 1.5
	thread SpawnSkitGuy_AndRun( "runner_5_4", path2, 0.85, TEAM_MILITIA, "npc_soldier", "mp_weapon_rspn101" )

	/*
	wait 5.0

	wait 4.0

	thread SpawnSkitGuy_AndRun( "runner_2_1", path2, 0.8, TEAM_MILITIA, "npc_soldier", "mp_weapon_rspn101" )
	wait 1.0
	thread SpawnSkitGuy_AndRun( "runner_2_2", path2, 0.8, TEAM_MILITIA, "npc_soldier", "mp_weapon_shotgun" )
	*/
}

void function PodOutro_Foreground_Runners( entity player )
{
	EndSignal( player, "OnDestroy" )

	// right in front of pod
	array<Point> pathClose = []
	ScriptedPath_AddPoint( pathClose, < 10728.2, -10194.2, -6055.97 >, < 0, 178.246, 0 > )
	ScriptedPath_AddPoint( pathClose, < 10236.8, -10180.3, -6055.97 >, < 0, 178.41, 0 > )

	wait 11.0  // wait for OG to hand eyeball to BT

	thread SpawnSkitGuy_AndRun( "close_runner_1", pathClose, 0.7, TEAM_MILITIA, "npc_soldier", "mp_weapon_rspn101" )
	wait 1.2
	thread SpawnSkitGuy_AndRun( "close_runner_2", pathClose, 0.75, TEAM_MILITIA, "npc_soldier", "mp_weapon_rspn101" )

	wait 10.0  // wait for OG to start embarking BT

	thread SpawnSkitGuy_AndRun( "close_runner_4", pathClose, 0.75, TEAM_MILITIA, "npc_soldier", "mp_weapon_rspn101" )
	wait 1.3
	thread SpawnSkitGuy_AndRun( "close_runner_5", pathClose, 0.8, TEAM_MILITIA, "npc_soldier_specialist_militia", "mp_weapon_g2" )

	wait 11  // wait for grunt to hand player the weapon

	thread SpawnSkitGuy_AndRun( "close_runner_10", pathClose, 0.8, TEAM_MILITIA, "npc_soldier", "mp_weapon_rspn101" )
	wait 1.8
	thread SpawnSkitGuy_AndRun( "close_runner_11", pathClose, 0.8, TEAM_MILITIA, "npc_soldier", "mp_weapon_rspn101" )
	wait 1.0
	thread SpawnSkitGuy_AndRun( "close_runner_12", pathClose, 0.8, TEAM_MILITIA, "npc_soldier", "mp_weapon_rspn101" )
}

void function PodOutro_Background_ATC_Marvins()
{
	// 1, 2, 3- matches titan bay numbering (right to left)
	// plain numbers = farther from camera
	// "a" variants = closer to camera
	//SkitGuyInfo marvin_1 	= SpawnSkitGuy( "atc_marvin_1", "", < 10600, -9841.5, -6079.97 >, < 0, -20, 0 >, TEAM_MILITIA )
	//thread ATC_Marvin_Think( marvin_1, 	"mv_trafic_controller_A", 0.0 )
	//SkitGuyInfo marvin_1a 	= SpawnSkitGuy( "atc_marvin_1a", "", < 10683.8, -10077.7, -6094.65 >, < 0, 20, 0 >, TEAM_MILITIA )
	//thread ATC_Marvin_Think( marvin_1a, "mv_trafic_controller_B", 0.0 )
	SkitGuyInfo marvin_2 	= SpawnSkitGuy( "atc_marvin_2", "", < 10460.6, -9861.5, -6079.97 >, < 0, -30, 0 >, TEAM_MILITIA )
	thread ATC_Marvin_Think( marvin_2, 	"mv_trafic_controller_B", 0.25 )
	//SkitGuyInfo marvin_2a 	= SpawnSkitGuy( "atc_marvin_2a", "", < 10410.6, -10075.6, -6079.97 >, < 0, 30, 0 >, TEAM_MILITIA )
	//thread ATC_Marvin_Think( marvin_2a, "mv_trafic_controller_A", 0.25 )
	SkitGuyInfo marvin_3 	= SpawnSkitGuy( "atc_marvin_3", "", < 10214.8, -9891.5, -6079.97 >, < 0, -10, 0 >, TEAM_MILITIA )
	thread ATC_Marvin_Think( marvin_3, 	"mv_trafic_controller_A", 0.5 )
	SkitGuyInfo marvin_3a 	= SpawnSkitGuy( "atc_marvin_3a", "", < 10207.5, -10079.4, -6079.97 >, < 0, 10, 0 >, TEAM_MILITIA )
	thread ATC_Marvin_Think( marvin_3a, "mv_trafic_controller_B", 0.5 )
}

void function ATC_Marvin_Think( SkitGuyInfo marvinInfo, string anim, float skipAheadTime = 0.0 )
{
	entity marvin = marvinInfo.guy

	EndSignal( marvin, "OnDestroy" )

	entity batonRight = CreatePropDynamic( SAFETY_BATON_MODEL )
	batonRight.SetOrigin( marvin.GetAttachmentOrigin( marvin.LookupAttachment( "R_HAND" ) ) )
	// HACK adjust the angles since the tags are different
	vector angs = marvin.GetAttachmentAngles( marvin.LookupAttachment( "R_HAND" ) ) + Vector( 0, 0, 180 )
	batonRight.SetAngles( angs )
	batonRight.SetParent( marvin, "R_HAND", true )

	entity batonLeft = CreatePropDynamic( SAFETY_BATON_MODEL )
	batonLeft.SetParent( marvin, "L_HAND" )

	marvin.NotSolid() // don't want other NPCs to path around the ATC marvins

	array<entity> cleanupEnts = [ batonRight, batonLeft ]

	OnThreadEnd(
	function() : ( cleanupEnts )
		{
			foreach ( ent in cleanupEnts )
			{
				if ( IsValid( ent ) )
				{
					ent.ClearParent()
					ent.Destroy()
				}
			}
		}
	)

	WaitFrame()
	marvinInfo.skitAnim = anim
	/*
	array<string> anims = [ "mv_trafic_controller_A", "mv_trafic_controller_B" ]
	while( 1 )
	{
		marvin.Anim_Play( anims.getrandom() )
		marvin.SetPlaybackRate( RandomFloatRange( 0.9, 1.0 ) )
		waitthread WaittillAnimDone( marvin )
	}
	*/
	marvin.SetPlaybackRate( RandomFloatRange( 0.9, 1.0 ) )
	SkitGuy_PlayAnim( marvinInfo, skipAheadTime )

	WaitForever()
}



// =======================================
// ============ GAUNTLET MODE ============
// =======================================
// Just runs the Gauntlet over and over.

void function Training_Setup_GauntletMode( entity player )
{
	Training_EnvArtColorCorrection_SetEnabled( true )

	entity ogStart = GetEntByScriptName( "og_near_leaderboard" )
	entity og = Training_SpawnOGPilot( ogStart )
	Training_OG_Idles( ogStart, "OG_Leaderboard_D_idle" )

	//TeleportPlayerAndBT( "playerstart_gauntlet_challenge" )
	// HACK better start position
	player.SetOrigin( < -5179, 279.129, 32.0313 > )
	player.SetAngles( < 0, 80.7242, 0 > )
}

void function Training_GauntletModeStart( entity player )
{
	file.gauntletMode = true

	waitthread Training_GauntletChallenge( player )
}

void function GauntletMode_Finished( entity player )
{
	Assert( file.gauntletMode )

	float fadeTime = 3.0
	ScreenFade( player, 0, 0, 0, 255, fadeTime, -1, FFADE_OUT | FFADE_STAYOUT )
	wait fadeTime

	// Dump player back to menu
	ClientCommand( player, "disconnect" )

	WaitForever()  // defensive- don't want any extra stuff happening right before level transition
}



#if DEV
// ===============================================
// ============ RECORD GAUNTLET GHOSTS ===========
// ===============================================
void function TrainingGauntlet_RecordGhostStart_FirstRun( entity player )
{
	TrainingGauntlet_RecordGhost_CommonStart( player, GetTrainingGauntlet(), GHOST_NAME_FIRSTRUN )
}

void function TrainingGauntlet_RecordGhostStart_Challenge_WIP( entity player )
{
	TrainingGauntlet_RecordGhost_CommonStart( player, GetTrainingGauntlet(), GHOST_NAME_CHAL_WIP )
}

void function TrainingGauntlet_RecordGhostStart_Challenge_01( entity player )
{
	TrainingGauntlet_RecordGhost_CommonStart( player, GetTrainingGauntlet(), GHOST_NAME_CHAL_01 )
}

void function TrainingGauntlet_RecordGhostStart_Challenge_02( entity player )
{
	TrainingGauntlet_RecordGhost_CommonStart( player, GetTrainingGauntlet(), GHOST_NAME_CHAL_02 )
}

void function TrainingGauntlet_RecordGhostStart_Challenge_03( entity player )
{
	TrainingGauntlet_RecordGhost_CommonStart( player, GetTrainingGauntlet(), GHOST_NAME_CHAL_03 )
}

void function TrainingGauntlet_RecordGhostStart_Challenge_04( entity player )
{
	TrainingGauntlet_RecordGhost_CommonStart( player, GetTrainingGauntlet(), GHOST_NAME_CHAL_04 )
}

void function TrainingGauntlet_RecordGhostStart_Challenge_05( entity player )
{
	TrainingGauntlet_RecordGhost_CommonStart( player, GetTrainingGauntlet(), GHOST_NAME_CHAL_05 )
}

void function TrainingGauntlet_RecordGhostStart_Challenge_06( entity player )
{
	TrainingGauntlet_RecordGhost_CommonStart( player, GetTrainingGauntlet(), GHOST_NAME_CHAL_06 )
}

void function TrainingGauntlet_RecordGhostStart_Challenge_07( entity player )
{
	TrainingGauntlet_RecordGhost_CommonStart( player, GetTrainingGauntlet(), GHOST_NAME_CHAL_07 )
}

void function TrainingGauntlet_RecordGhostStart_Challenge_08( entity player )
{
	TrainingGauntlet_RecordGhost_CommonStart( player, GetTrainingGauntlet(), GHOST_NAME_CHAL_08 )
}

void function TrainingGauntlet_RecordGhostStart_Challenge_09( entity player )
{
	TrainingGauntlet_RecordGhost_CommonStart( player, GetTrainingGauntlet(), GHOST_NAME_CHAL_09 )
}


void function TrainingGauntlet_RecordGhost_CommonStart( entity player, GauntletInfo gauntlet, string ghostFileName )
{
	thread TrainingGauntlet_TeleportPlayerAtFinishLine( player )

	TeleportPlayerAndBT( "gauntlet_startpoint" )

	Gauntlet_Player_GhostRecordOrPlayback( player, gauntlet, ghostFileName )

	while ( 1 )
		wait 5
}
#endif //DEV



// ============================================
// ============ TRAINING POD STUFF ============
// ============================================
void function SetupTrainingPod()
{
	file.trainingPod = GetEntByScriptName( "training_pod" )
	file.trainingPod.DisableHibernation()

	TrainingPod_SetupInteriorDLights()

	array<string> laserAttachNames = [ "fx_laser_L", "fx_laser_R" ]

	foreach ( attachName in laserAttachNames )
	{
		entity emitterEnt = CreateScriptMover( file.trainingPod.GetOrigin() )
		int attachID = file.trainingPod.LookupAttachment( attachName )
		vector attachAng = file.trainingPod.GetAttachmentAngles( attachID )

		TrainingPod_LaserEmitter emitter
		emitter.ent 		= emitterEnt
		emitter.attachName 	= attachName
		emitter.ogAng 		= attachAng

		file.trainingPodLaserEmitters.append( emitter )
	}

	// HACK we do this later as well to reset the emitter positions, so it's a separate function
	TrainingPod_SnapLaserEmittersToAttachPoints()

	//file.trainingPod.SetAngles( Vector( 0, 109, 0 ) )  // these angles are a little better for seeing the room
}

void function TrainingPod_SetupInteriorDLights()
{
	entity pod = file.trainingPod

	TrainingPod_dLightMapping m1
	m1.scriptAlias = "console1"
	m1.fxName = FX_POD_DLIGHT_CONSOLE1
	m1.attachName = "light_console1"
	file.trainingPodDLightMappings.append( m1 )

	TrainingPod_dLightMapping m2
	m2.scriptAlias = "console2"
	m2.fxName = FX_POD_DLIGHT_CONSOLE2
	m2.attachName = "light_console2"
	file.trainingPodDLightMappings.append( m2 )

	//TrainingPod_dLightMapping m3
	//m3.scriptAlias = "backlight_side_L"
	//m3.fxName = FX_POD_DLIGHT_BACKLIGHT_SIDE
	//m3.attachName = "light_back1"
	//file.trainingPodDLightMappings.append( m3 )

	//TrainingPod_dLightMapping m4
	//m4.scriptAlias = "backlight_side_R"
	//m4.fxName = FX_POD_DLIGHT_BACKLIGHT_SIDE
	//m4.attachName = "light_back2"
	//file.trainingPodDLightMappings.append( m4 )

	//TrainingPod_dLightMapping m5
	//m5.scriptAlias = "backlight_top"
	//m5.fxName = FX_POD_DLIGHT_BACKLIGHT_TOP
	//m5.attachName = "light_backtop"
	//file.trainingPodDLightMappings.append( m5 )
}

void function TrainingPod_TurnOnInteriorDLights_Delayed( entity player, float delay )
{
	player.EndSignal( "OnDestroy" )

	wait delay

	TrainingPod_TurnOnInteriorDLight( "console1" )
	TrainingPod_TurnOnInteriorDLight( "console2" )
}

void function TrainingPod_TurnOnInteriorDLight( string scriptAlias )
{
	entity pod = file.trainingPod

	int idx
	TrainingPod_dLightMapping thisMapping
	foreach ( mappingIdx, mapping in file.trainingPodDLightMappings )
	{
		if ( mapping.scriptAlias == scriptAlias )
		{
			thisMapping = mapping
			idx = mappingIdx
			break
		}
	}

	Assert ( thisMapping.scriptAlias != "", "Couldn't find pod dlight mapping for alias " + scriptAlias )

	entity fxHandle = PlayLoopFXOnEntity( thisMapping.fxName, pod, thisMapping.attachName )
	file.trainingPodDLightMappings[ idx ].fxHandle = fxHandle
}

void function TrainingPod_KillInteriorDLights_Delayed( entity player, float delay )
{
	player.EndSignal( "OnDestroy" )

	wait delay

	TrainingPod_KillInteriorDLights()
}

void function TrainingPod_KillInteriorDLights()
{
	foreach ( idx, mapping in file.trainingPodDLightMappings )
	{
		if ( !IsValid_ThisFrame( mapping.fxHandle ) )
			continue

		KillFX( mapping.fxHandle )

		file.trainingPodDLightMappings[ idx ].fxHandle = null
	}
}

void function TrainingPod_SnapLaserEmittersToAttachPoints()
{
	foreach ( TrainingPod_LaserEmitter emitter in file.trainingPodLaserEmitters )
	{
		int attachID = file.trainingPod.LookupAttachment( emitter.attachName )
		vector attachOrg = file.trainingPod.GetAttachmentOrigin( attachID )
		vector attachAng = file.trainingPod.GetAttachmentAngles( attachID )

		emitter.ent.ClearParent()
		emitter.ent.SetOrigin( attachOrg )  // HACK set this to ANYTHING  (even 0, 0, 0) and the position is correct, otherwise it's offset from the attachpoint when parented
		emitter.ent.SetParent( file.trainingPod, emitter.attachName )
	}
}

void function TrainingPod_Interior_BootSequence( entity player )
{
	player.EndSignal( "OnDestroy" )

	entity pod = file.trainingPod

	TrainingPod_InteriorFX_CommonSetup( pod )

	FlagSet( "PodIntro_InteriorBootSequence_Starting" )

	EmitSoundOnEntity( player, "NPE_Scr_SimPod_PowerUp" )

	// Transition screen FX
	thread PlayFXOnEntity_Delayed( player, FX_POD_SCREEN_IN, player, 2.35 )

	// GLOW LIGHTS
	TrainingPod_GlowLightsTurnOn()

    // LASERS
    float longestSweepTime = -1
	foreach ( emitter in file.trainingPodLaserEmitters )
	{
		float sweepTime = RandomFloatRange( 2.9, 3.15 )
		if ( sweepTime > longestSweepTime )
			longestSweepTime = sweepTime

		thread LaserSweep( player, sweepTime, emitter, pod, "top" )
	}

	wait longestSweepTime

    player.Signal( "PodInteriorSequenceDone" )
}

void function TrainingPod_InteriorFX_CommonSetup( entity pod )
{
	if ( file.trainingPodLaserEmitters.len() )
	{
		TrainingPod_KillLasers( pod )
		TrainingPod_ResetLaserEmitterRotation( pod )
	}

	TrainingPod_KillGlowFX( pod )
}

// NOTE startPosition is actually inverted from what I think it should be. Tag orientation issue, maybe?
void function LaserSweep( entity player, float totalTime, TrainingPod_LaserEmitter emitter, entity pod, string startPosition = "bottom" )
{
	//float startTime = Time()

	player.EndSignal( "OnDestroy" )
	emitter.ent.EndSignal( "OnDeath" )

	emitter.sweepDone = false

	//printt( "emitter og angles:", emitter.GetAngles() )

	vector vecToPlayerEye = ( player.EyePosition() + Vector( 0, 0, 7 ) ) - emitter.ent.GetOrigin()  // eye position offset is a HACK, not sure why I need to do that here.
	vector centerAng = VectorToAngles( vecToPlayerEye )
	vector topAng = centerAng + Vector( -270, 0, 0 )
	vector bottomAng = centerAng + Vector( -90, 0, 0 )

	//vector topAng 	= emitter.GetAngles() + < 90, -8, 0 >
	//vector bottomAng 	= emitter.GetAngles() + < -90, 8, 0 >

	//printt( "==== starting at:", startPosition )
	//printt( "topAng:", topAng )
	//printt( "bottomAng:", bottomAng )
	//printt( "centerAng:", centerAng )

	vector lastBigSweepAng

	if ( startPosition == "bottom")
	{
		emitter.ent.SetAbsAngles( bottomAng )
		lastBigSweepAng = bottomAng
	}
	else
	{
		emitter.ent.SetAbsAngles( topAng )
		lastBigSweepAng = topAng
	}
	//printt( "setting start angles to:", lastBigSweepAng )

	entity fxHandle = PlayLoopFXOnEntity( FX_POD_LASER, emitter.ent )
	emitter.fxHandle = fxHandle

	int numBigSweeps = 2
	float finalCenterTime = totalTime * 0.15
	float bigSweepTime = ( totalTime - finalCenterTime ) / numBigSweeps

	float bigSweep_AccelTime = 0
	float bigSweep_DecelTime = bigSweepTime * 0.2

	// do the big sweeps
	vector nextBigSweepAng
	for ( int i = 0; i < numBigSweeps; i++ )
	{
		nextBigSweepAng = topAng
		if ( lastBigSweepAng == topAng )
			nextBigSweepAng = bottomAng

		//printt( "rotating to", nextBigSweepAng )

		emitter.ent.NonPhysicsRotateTo( nextBigSweepAng, bigSweepTime, bigSweep_AccelTime, bigSweep_DecelTime )

		float waitTime = bigSweepTime
		if ( i < numBigSweeps - 1 )
			waitTime = bigSweepTime - 0.1

		wait waitTime

		lastBigSweepAng = nextBigSweepAng
	}

	// finish with centering move
	//printt( "centering to", centerAng )

	float finalCenter_AccelTime = 0
	float finalCenter_DecelTime = finalCenterTime * 0.2

	emitter.ent.NonPhysicsRotateTo( centerAng, finalCenterTime, finalCenter_AccelTime, finalCenter_DecelTime )
	wait finalCenterTime

	emitter.sweepDone = true
	//printt( "laser sweep done, total time", Time() - startTime, "should have been", totalTime )
}

void function TrainingPod_KillLasers( entity pod, bool doEndCap = false )
{
	foreach ( emitter in file.trainingPodLaserEmitters )
	{
		if ( IsValid_ThisFrame( emitter.fxHandle ) )
		{
			if ( !doEndCap )
			{
				//printt( "killing laser FX", emitter.fxHandle )
				KillFX( emitter.fxHandle )
			}
			else
			{
				//printt( "killing laser FX with endcap", emitter.fxHandle )
				KillFXWithEndcap( emitter.fxHandle )
			}
		}

		emitter.fxHandle = null
	}
}

void function TrainingPod_ResetLaserEmitterRotation( entity pod )
{
	if ( !file.trainingPodLaserEmitters.len() )
		return

	foreach ( emitter in file.trainingPodLaserEmitters )
	{
		//reset to start position
		emitter.ent.NonPhysicsRotateTo( emitter.ogAng, 0.05, 0.0, 0.0 )
	}
}

void function TrainingPod_GlowLightsArraySetup()
{
	array<TrainingPod_GlowLightRow> rows

	// rows are set up bottom to top
	// lights are set up outside to in (in = door close seam; opposite for each side)
	// process two rows per loop (one for each door side)

	TrainingPod_GlowLightRow row1
	row1.fxSpotsL = [ "fx_glow_L_door012", "fx_glow_L_door013" ]
	row1.fxSpotsR = [ "fx_glow_R_door014", "fx_glow_R_door013" ]
	rows.append( row1 )

	TrainingPod_GlowLightRow row2
	row2.fxSpotsL = [ "fx_glow_L_door014", "fx_glow_L_door011" ]
	row2.fxSpotsR = [ "fx_glow_R_door012", "fx_glow_R_door011" ]
	rows.append( row2 )

	TrainingPod_GlowLightRow row3
	row3.fxSpotsL = [ "fx_glow_L_door09", "fx_glow_L_door010" ]
	row3.fxSpotsR = [ "fx_glow_R_door09", "fx_glow_R_door010" ]
	rows.append( row3 )

	TrainingPod_GlowLightRow row4
	row4.fxSpotsL = [ "fx_glow_L_door07", "fx_glow_L_door08" ]
	row4.fxSpotsR = [ "fx_glow_R_door07", "fx_glow_R_door08" ]
	rows.append( row4 )

	TrainingPod_GlowLightRow row5
	row5.fxSpotsL = [ "fx_glow_L_door05", "fx_glow_L_door06" ]
	row5.fxSpotsR = [ "fx_glow_R_door05", "fx_glow_R_door06" ]
	rows.append( row5 )

	TrainingPod_GlowLightRow row6
	row6.fxSpotsL = [ "fx_glow_L_door03", "fx_glow_L_door04" ]
	row6.fxSpotsR = [ "fx_glow_R_door03", "fx_glow_R_door04" ]
	rows.append( row6 )

	TrainingPod_GlowLightRow row7
	row7.fxSpotsL = [ "fx_glow_L_door01", "fx_glow_L_door02" ]
	row7.fxSpotsR = [ "fx_glow_R_door01", "fx_glow_R_door02" ]
	rows.append( row7 )

	file.trainingPodGlowLightRows = rows
}

void function TrainingPod_GlowLightsTurnOn( bool instantOn = false )
{
	//float startTime = Time()

	entity pod = file.trainingPod

	foreach ( TrainingPod_GlowLightRow row in file.trainingPodGlowLightRows )
	{
		float loopTime = Time()

		array<string> group1 = [ row.fxSpotsL[0], row.fxSpotsR[0] ]
		array<string> group2 = [ row.fxSpotsL[1], row.fxSpotsR[1] ]
		table< int, array < string > > lightgroups
		lightgroups[0] <- group1
		lightgroups[1] <- group2

		foreach ( idx, group in lightgroups )
		{
			foreach ( attachName in group )
			{
				entity fxHandle = PlayLoopFXOnEntity( FX_POD_GLOWLIGHT, pod, attachName )
				file.trainingPodGlowLightFXHandles.append( fxHandle )
			}

			if ( !instantOn )
				wait 0.1
		}

		/*
		// both sides have same number of lights
		int numLights = 2
		for ( int i = 0; i < numLights; i++ )
		{
			foreach ( var side in row )
			{
				string attachName = side[ i ]
				entity fxHandle = PlayLoopFXOnEntity( FX_POD_GLOWLIGHT, pod, attachName )
				file.trainingPodGlowLightFXHandles.append( fxHandle )
			}

			if ( lightWait > 0 )
				wait lightWait
		}

		if ( rowWait > 0)
			wait rowWait
		*/
	}

	//printt( "glow lights turn on took", Time() - startTime, "secs" )
}

void function TrainingPod_KillGlowFX( entity pod )
{
	foreach ( fxHandle in file.trainingPodGlowLightFXHandles )
	{
		if ( !IsValid_ThisFrame( fxHandle ) )
			continue

		KillFX( fxHandle )
	}

	file.trainingPodGlowLightFXHandles = []
}

void function TrainingPod_Interior_ShutdownSequence( entity player, float shutdownTime )
{
	player.EndSignal( "OnDestroy" )

	entity pod = file.trainingPod

	TrainingPod_InteriorFX_CommonSetup( pod )

	// TURN ON GLOW LIGHTS
	TrainingPod_GlowLightsTurnOn( true )

	// TURN ON LASERS
	TrainingPod_LasersInstantOn( player, pod )

	player.WaitSignal( "TrainingPod_BeginInteriorShutdown" )

	thread TrainingPod_LasersShutDown( player, pod, shutdownTime * 0.6 )
	thread TrainingPod_GlowLightsShutDown( player, pod, shutdownTime )

	wait shutdownTime
	printt( "interior shutdown done" )
}

void function TrainingPod_LasersInstantOn( entity player, entity pod )
{
	foreach ( emitter in file.trainingPodLaserEmitters )
	{
		float dist = Distance( player.EyePosition(), emitter.ent.GetOrigin() )
		Assert( dist <= 30, "player is usually about 20 units away when we try to set the laser angles. If very far away, the math will crash the game. Dist: " + dist )

		vector vecToPlayerEye = ( player.EyePosition() + Vector( 0, 0, 7 ) ) - emitter.ent.GetOrigin()  // eye position offset is a HACK, not sure why I need to do that here.
		vector centerAng = VectorToAngles( vecToPlayerEye )
		emitter.ent.NonPhysicsRotateTo( centerAng, 0.1, 0.0, 0.0 )  // SETANGLES DOES NOT WORK! You have to rotate it for the FX to follow.

		emitter.fxHandle = PlayLoopFXOnEntity( FX_POD_LASER, emitter.ent )
	}
}

void function TrainingPod_LasersShutDown( entity player, entity pod, float shutdownTime )
{
	player.EndSignal( "OnDestroy" )

	foreach ( emitter in file.trainingPodLaserEmitters )
	{
		vector vecToPlayerEye = ( player.EyePosition() + Vector( 0, 0, 7 ) ) - emitter.ent.GetOrigin()  // eye position offset is a HACK, not sure why I need to do that here.
		vector centerAng = VectorToAngles( vecToPlayerEye )
		emitter.ent.NonPhysicsRotateTo( centerAng, 0.1, 0.0, 0.0 )  // SETANGLES DOES NOT WORK! You have to rotate it for the FX to follow.
	}

	wait shutdownTime * 0.25

	float moveDownTime = shutdownTime * 0.75
	float accelTime = moveDownTime * 0.25
	float decelTime = moveDownTime * 0.1

	foreach ( TrainingPod_LaserEmitter emitter in file.trainingPodLaserEmitters )
	{
		vector finalAng = emitter.ent.GetAngles() + Vector( 30, 0, 0 )  // not sure why adding pitch makes them appear to drop down
		emitter.ent.NonPhysicsRotateTo( finalAng, moveDownTime, accelTime, decelTime )
	}

	wait moveDownTime
	TrainingPod_KillLasers( pod, true )
}

void function TrainingPod_GlowLightsShutDown( entity player, entity pod, float shutdownTime )
{
	player.EndSignal( "OnDestroy" )

	float shutdownDelay = shutdownTime * 0.65
	float finishEarly = shutdownTime * 0.1
	float glowLightShutDownDuration = shutdownTime - shutdownDelay - finishEarly

	wait shutdownDelay

	Assert( glowLightShutDownDuration > 0.0 )

	float timePerLight = glowLightShutDownDuration / file.trainingPodGlowLightFXHandles.len().tofloat()

	foreach ( entity fxHandle in file.trainingPodGlowLightFXHandles )
	{
		if ( !IsValid_ThisFrame( fxHandle ) )
			continue

		thread KillFXWithEndcap( fxHandle )
		wait timePerLight
	}

	file.trainingPodGlowLightFXHandles = []
}

void function TrainingPod_ViewConeLock_Shared( entity player )
{
	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -25 )
	player.PlayerCone_SetMaxYaw( 25 )
	player.PlayerCone_SetMinPitch( -30 )
}

void function TrainingPod_ViewConeLock_PodOpen( entity player )
{
	TrainingPod_ViewConeLock_Shared( player )
	player.PlayerCone_SetMaxPitch( 35 )
}

void function TrainingPod_ViewConeLock_PodClosed( entity player )
{
	TrainingPod_ViewConeLock_Shared( player )
	player.PlayerCone_SetMaxPitch( 32 )
}

void function TrainingPod_ViewConeLock_SemiStrict( entity player )
{
	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( -10 )
	player.PlayerCone_SetMaxYaw( 10 )
	player.PlayerCone_SetMinPitch( -10 )
	player.PlayerCone_SetMaxPitch( 10 )
}

void function TrainingPod_ViewConeLock_Strict( entity player )
{
	player.PlayerCone_FromAnim()
	player.PlayerCone_SetMinYaw( 0 )
	player.PlayerCone_SetMaxYaw( 0 )
	player.PlayerCone_SetMinPitch( 0 )
	player.PlayerCone_SetMaxPitch( 0 )
}


// ==================================================
// ============ CLIENT COMMAND CALLBACKS ============
// ==================================================

bool function ClientCommand_Training_SetInputType( entity player, array<string> args )
{
	int inputType = args[0].tointeger()

	Assert( inputType == INPUT_TYPE_CONTROLLER || inputType == INPUT_TYPE_KBM )
	//printt( "Training- client input type updated:", inputType )
	file.playerInputType = inputType
	return true
}

bool function ClientCommand_Training_PlayerPressedUse( entity player, array<string> args )
{
	FlagSet( "PlayerPressedUse" )
	return true
}

bool function ClientCommand_Training_PlayerReloaded( entity player, array<string> args )
{
	FlagSet( "PlayerReloaded" )
	return true
}

bool function ClientCommand_LookTarget_Top( entity player, array<string> args )
{
	player.ResetIdleTimer()
	printt( "ClientCommand_LookTarget_Top" )
	FlagSet( "PlayerLookedAtTopTarget" )
	return true
}

bool function ClientCommand_LookTarget_Bottom( entity player, array<string> args )
{
	player.ResetIdleTimer()
	printt( "ClientCommand_LookTarget_Bottom" )
	FlagSet( "PlayerLookedAtBottomTarget" )
	return true
}



// ===============================
// ============ DOORS ============
// ===============================
void function DoorOpenFast( string doorEntName )
{
	entity door = GetEntByScriptName( doorEntName )
	door.Hide()
	door.NotSolid()

	entity navBlocker = door.GetLinkEnt()
	navBlocker.NotSolid()
	ToggleNPCPathsForEntity( navBlocker, true )
}

void function DoorCloseFast( string doorEntName )
{
	entity door = GetEntByScriptName( doorEntName )
	door.Show()
	door.Solid()

	entity navBlocker = door.GetLinkEnt()
	navBlocker.Solid()
	ToggleNPCPathsForEntity( navBlocker, false )
}


void function OpenZenGardenExitDoor()
{
	DoorOpenFast( "zengarden_door" )
}

void function CloseZenGardenExitDoor()
{
	DoorCloseFast( "zengarden_door" )
}

void function OpenGauntletDoor()
{
	DoorOpenFast( "gauntlet_door" )
}



// ===================================
// ========= LOUDSPEAKER VO ==========
// ===================================
void function LoudspeakerVO_Setup()
{
	vector loudspeakerPos = <10524, -9660, -5896>  // HACK
	file.loudspeaker = CreateScriptMover( loudspeakerPos, <0,0,0> )

	// ======= PA ANNOUNCEMENTS: POD INTRO =======
	// "Inbound to Planet Typhon. Subspace rendezvous in approximately 20 minutes."
	RegisterLoudspeakerVO( "intro_0", "diag_sp_addtional_TR411_01_mcor_shipPA", 8.0 )

	// "Major Anderson, please report to the briefing room."
	RegisterLoudspeakerVO( "intro_1", "diag_sp_addtional_TR411_02_mcor_grunt1", 3.0 )

	// "Reminder to dock personnel: Titan ordnance is a Type 3 Hazardous Material."
	RegisterLoudspeakerVO( "intro_2", "diag_sp_addtional_TR411_03_mcor_shipPA", 6.0 )

	// "Captain Cole to communications."
	RegisterLoudspeakerVO( "intro_3", "diag_sp_addtional_TR411_04_mcor_grunt1", 3.0 )

	// "Running Lifeboat diagnostic test two point one. All Mark Eight lifeboats are in the green."
	RegisterLoudspeakerVO( "intro_4", "diag_sp_addtional_TR411_05_mcor_shipPA", 6.0 )

	// "3rd Militia Grenadiers - prep dropship MacAllan 17."
	RegisterLoudspeakerVO( "intro_5", "diag_sp_addtional_TR411_06_mcor_grunt1", 4.0 )


	// ======= PA ANNOUNCEMENTS: MEET OG =======
	// "Prepare for Typhon atmospheric entry in less than three minutes."
	RegisterLoudspeakerVO( "outro_01", "diag_sp_addtional_TR411_07_mcor_shipPA", 7.0 )

	// "Powering down all non-essential systems."
	RegisterLoudspeakerVO( "outro_01_1", "diag_sp_outro_TR171_01_01_mcor_shipPA", 4.0 )

	// "All personnel to battle stations."
	RegisterLoudspeakerVO( "outro_01_2", "diag_sp_outro_TR171_02_01_mcor_shipPA", 3.0 )

	// "This is not a drill."
	RegisterLoudspeakerVO( "outro_01_3", "diag_sp_outro_TR171_03_01_mcor_shipPA", 3.0 )

	// "Titan bays two through five, drop clearance confirmed."
	RegisterLoudspeakerVO( "outro_03", "diag_sp_addtional_TR411_09_mcor_shipPA", 5.0 )

	// "Infantry teams Stork three, Elk four, Shark six, Badger one, prepare for emergency atmospheric drop sequence"
	RegisterLoudspeakerVO( "outro_04", "diag_sp_addtional_TR411_10_mcor_grunt1", 7.0 )

	// "All available medical personnel, report to Med Central for tasking."
	RegisterLoudspeakerVO( "outro_05", "diag_sp_addtional_TR411_11_mcor_grunt2", 5.0 )

	// "Titan mech team - Rabbit six, prep the Vanguards."
	RegisterLoudspeakerVO( "outro_06", "diag_sp_addtional_TR411_12_mcor_grunt3", 4.0 )

	// "We need all Riflemen to docking bay four. Dropships standing by."
	RegisterLoudspeakerVO( "outro_07", "diag_sp_addtional_TR411_13_mcor_grunt1", 5.0 )

	// "Incoming hostile ship - Designation: IMS Malta. Battle stations."
	RegisterLoudspeakerVO( "outro_08", "diag_sp_addtional_TR411_14_mcor_shipPA", 6.0 )

	// "Special Recon Squad deploy from Drop Bay thirty-seven - now."
	RegisterLoudspeakerVO( "outro_10", "diag_sp_addtional_TR411_16_mcor_grunt2", 5.0 )

	// "Infantry teams 2nd Militia Fusiliers, Raptor three, target the IMS Malta."
	RegisterLoudspeakerVO( "outro_11", "diag_sp_addtional_TR411_17_mcor_grunt3", 6.0 )

	// "Caution - Fuel leak in Cargo Bay eighty - five. Decompressing for fire suppression."
	RegisterLoudspeakerVO( "outro_12", "diag_sp_addtional_TR411_18_mcor_shipPA", 6.0 )
}

void function RegisterLoudspeakerVO( string scriptAlias, string soundAlias, float duration = 6.0 )
{
	Assert( !( scriptAlias in file.loudspeakerVO ), "duplicate scriptAlias " + scriptAlias )

	LoudspeakerVO_Info voInfo
	voInfo.scriptAlias = scriptAlias
	voInfo.soundAlias = soundAlias
	voInfo.duration = duration

	file.loudspeakerVO[ scriptAlias ] <- voInfo
}

void function PlayLoudspeakerVO( string scriptAlias, float delay = 0.0 )
{
	Assert( scriptAlias in file.loudspeakerVO )
	LoudspeakerVO_Info voInfo = file.loudspeakerVO[ scriptAlias ]

	string soundAlias = voInfo.soundAlias

	if ( delay > 0 )
		wait delay

	entity emitter = file.loudspeaker
	emitter.Signal( "LoudspeakerVO_Stop" )
	emitter.EndSignal( "LoudspeakerVO_Stop" )

	OnThreadEnd(
	function() : ( emitter, soundAlias )
		{
			if ( IsValid( emitter ) )
				FadeOutSoundOnEntity( emitter, soundAlias, 2.0 )
		}
	)

	//printt( "playing loudspeaker VO", scriptAlias, "/", soundAlias )
	EmitSoundOnEntity( emitter, soundAlias )
	wait voInfo.duration
}

void function LoopLoudspeakerVO( array<string> scriptAliases, string endFlag = "", float minPause = -1, float maxPause = -1 )
{
	if ( endFlag != "" )
	{
		if ( Flag( endFlag ) )
			return

		FlagEnd( endFlag )
	}

	while ( 1 )
	{
		foreach ( scriptAlias in scriptAliases )
		{
			waitthread PlayLoudspeakerVO( scriptAlias )

			if ( minPause > 0 && maxPause >= minPause )
				wait RandomFloatRange( minPause, maxPause )
		}
	}
}



// ==============================
// ============ MISC ============
// ==============================

entity function Training_SpawnAnOG( entity startSpot )
{
	entity og = CreateSoldier( TEAM_MILITIA, startSpot.GetOrigin(), startSpot.GetAngles() )
	og.kv.spawnflags = SF_NPC_ALLOW_SPAWN_SOLID
	DispatchSpawn( og )

	TakeAllWeapons( og )

	og.SetModel( OG_PILOT_MODEL )

	og.SetTitle( "#TRAINING_OG_PILOT_NAME" )
	ShowName( og )

	Training_OGPilot_SetHelmetOn( og, true )

	og.DisableHibernation()
	og.SetNoTarget( true )
	og.UseSequenceBounds( true )
	MakeInvincible( og )
	og.kv.scriptedAnimForceInterrupt = true

	og.DisableNPCFlag( NPC_ALLOW_FLEE | NPC_ALLOW_HAND_SIGNALS )
	og.SetHologram()

	return og
}

void function Training_OGPilot_SetHelmetOn( entity og, bool setOn )
{
	int headIdx = og.FindBodyGroup( "head" )

	int submodelIdx = OG_PILOT_MODEL_HEAD_IDX_BARE
	if ( setOn )
		submodelIdx = OG_PILOT_MODEL_HEAD_IDX_HELMET

	og.SetBodygroup( headIdx, submodelIdx )

	/*
	int decalIdx = og.FindBodyGroup( "decal" )
	if ( decalIdx == -1 )
		return

	submodelIdx = OG_PILOT_MODEL_DECAL_IDX_BARE
	if ( setOn )
		submodelIdx = OG_PILOT_MODEL_DECAL_IDX

	og.SetBodygroup( decalIdx, submodelIdx )
	*/
}

entity function Training_SpawnOGPilot( entity startSpot )
{
	if ( IsValid( file.ogPilot ) )
		file.ogPilot.Destroy()

	entity og = Training_SpawnAnOG( startSpot )
	file.ogPilot = og

	return og
	}

entity function Training_SpawnOGTwin( entity startSpot )
{
	if ( IsValid( file.ogTwin ) )
		file.ogTwin.Destroy()

	entity ogTwin = Training_SpawnAnOG( startSpot )
	file.ogTwin = ogTwin

	return ogTwin
}

entity function GetOGPilot()
{
	Assert( IsValid( file.ogPilot ) )
	return file.ogPilot
}

entity function GetOGTwin()
{
	if ( !IsValid( file.ogTwin ) )
		return null

	return file.ogTwin
}


void function Training_OG_NagPlayerUntilFlag_Sitting( entity player, array<string> nagAliases, float nagInterval, entity idleRef, string endFlag, string talkAnim = "", string idleAnim = "" )
{
	entity og = GetOGPilot()
	Training_NPC_NagPlayerUntilFlag_Sitting( og, player, nagAliases, nagInterval, idleRef, endFlag, talkAnim, idleAnim )
}

void function Training_OG_NagPlayerUntilFlag( entity player, array<string> nagAliases, float nagInterval, entity idleRef, string endFlag, string talkAnim = "", string idleAnim = "" )
{
	entity og = GetOGPilot()
	Training_NPC_NagPlayerUntilFlag( og, player, nagAliases, nagInterval, idleRef, endFlag, talkAnim, idleAnim )
}

void function Training_NPC_NagPlayerUntilFlag_Sitting( entity npc, entity player, array<string> nagAliases, float nagInterval, entity idleRef, string endFlag, string talkAnim = "", string idleAnim = "" )
{
	if ( talkAnim == "" )
		talkAnim = ANIM_OG_SITTING_TALK

	if ( idleAnim == "" )
		idleAnim = ANIM_OG_SITTING_IDLE

	Training_OG_NagPlayerUntilFlag( player, nagAliases, nagInterval, idleRef, endFlag, talkAnim, idleAnim )
}

void function Training_NPC_NagPlayerUntilFlag( entity npc, entity player, array<string> nagAliases, float nagInterval, entity idleRef, string endFlag, string talkAnim = "", string idleAnim = "" )
{
	player.EndSignal( "OnDestroy" )

	if ( talkAnim == "" )
		talkAnim = ANIM_OG_STANDING_TALK

	if ( idleAnim == "" )
		idleAnim = ANIM_OG_STANDING_IDLE

	int nagIdx = 0
	float nextNagTime = Time() + nagInterval

	while ( !Flag( endFlag ) )
	{
		if ( Time() > nextNagTime )
		{
			waitthread Training_OG_Talks( nagAliases[nagIdx], idleRef, talkAnim, idleAnim, true )
			nextNagTime = Time() + nagInterval

			nagIdx++
			if ( nagIdx >= nagAliases.len() )
				nagIdx = 0
		}

		wait 0.1
	}
}

void function Training_OG_Talks_Sitting( string voScriptAlias, entity idleRef, string talkAnim = "", string idleAnim = "", bool useBlend = false )
{
	entity og = GetOGPilot()
	Training_NPC_Talks_Sitting( og, voScriptAlias, idleRef, talkAnim, idleAnim, useBlend )
}

void function Training_OG_Talks_Leaning( string voScriptAlias, entity idleRef, string talkAnim = "", string idleAnim = "", bool useBlend = false )
{
	entity og = GetOGPilot()
	Training_NPC_Talks_Leaning( og, voScriptAlias, idleRef, talkAnim, idleAnim, useBlend )
}

void function Training_OG_Talks( string voScriptAlias, entity idleRef, string talkAnim = "", string idleAnim = "", bool useBlend = false )
{
	entity og = GetOGPilot()
	Training_NPC_Talks( og, voScriptAlias, idleRef, talkAnim, idleAnim, useBlend )
}

void function Training_OG_Idles_Sitting( entity idleRef, string anim = "", bool useBlend = false )
{
	entity og = GetOGPilot()
	Training_NPC_Idles_Sitting( og, idleRef, anim, useBlend )
}

void function Training_OG_Idles_SittingAndTalking( entity idleRef, string anim = "", bool useBlend = false )
{
	entity og = GetOGPilot()
	Training_NPC_Idles_SittingAndTalking( og, idleRef, anim, useBlend )
}

void function Training_OG_Idles_Talking( entity idleRef, string anim = "", bool useBlend = false )
{
	entity og = GetOGPilot()
	Training_NPC_Idles_Talking( og, idleRef, anim, useBlend )
}

void function Training_OG_Idles( entity idleRef, string anim = "", bool useBlend = false )
{
	entity og = GetOGPilot()
	thread Training_NPC_Idles( og, idleRef, anim, useBlend )
}

void function Training_OG_ScriptedAnim( entity idleRef, string anim, bool useBlend = false )
{
	entity og = GetOGPilot()
	Training_NPC_ScriptedAnim( og, idleRef, anim, useBlend )
}


void function Training_NPC_Talks_Sitting( entity npc, string voScriptAlias, entity idleRef, string talkAnim = "", string idleAnim = "", bool useBlend = false )
{
	if ( talkAnim == "" )
		talkAnim = ANIM_OG_SITTING_TALK

	if ( idleAnim == "" )
		idleAnim = ANIM_OG_SITTING_IDLE

	Training_NPC_Talks( npc, voScriptAlias, idleRef, talkAnim, idleAnim, useBlend )
}

void function Training_NPC_Talks_Leaning( entity npc, string voScriptAlias, entity idleRef, string talkAnim = "", string idleAnim = "", bool useBlend = false )
{
	if ( talkAnim == "" )
		talkAnim = ANIM_OG_LEANING_TALK

	if ( idleAnim == "" )
		idleAnim = ANIM_OG_LEANING_IDLE

	Training_NPC_Talks( npc, voScriptAlias, idleRef, talkAnim, idleAnim, useBlend )
}

void function Training_NPC_Talks( entity npc, string voScriptAlias, entity idleRef, string talkAnim = "", string idleAnim = "", bool useBlend = false )
{
	npc.EndSignal( "OnDestroy" )
	npc.EndSignal( "NPC_NewCommand" )

	if ( talkAnim == "" )
		talkAnim = ANIM_OG_STANDING_TALK

	if ( idleAnim == "" )
		idleAnim = ANIM_OG_STANDING_IDLE

	npc.Anim_Stop()
	if ( useBlend )
		thread PlayAnim( npc, talkAnim, idleRef )
	else
		thread PlayAnim( npc, talkAnim, idleRef, null, 0.0 )

	OnThreadEnd(
	function() : ( npc, idleRef, idleAnim, useBlend )
		{
			if ( IsValid( npc ) )
				Training_NPC_Idles( npc, idleRef, idleAnim, useBlend )
		}
	)

	waitthread PlayDialogue( voScriptAlias, npc )
}

void function Training_NPC_Idles_Sitting( entity npc, entity idleRef, string anim = "", bool useBlend = false )
{
	if ( anim == "" )
		anim = ANIM_OG_SITTING_IDLE

	Training_NPC_Idles( npc, idleRef, anim, useBlend )
}

void function Training_NPC_Idles_SittingAndTalking( entity npc, entity idleRef, string anim = "", bool useBlend = false )
{
	if ( anim == "" )
		anim = ANIM_OG_SITTING_TALK

	Training_NPC_Idles( npc, idleRef, anim, useBlend )
}

void function Training_NPC_Idles_Talking( entity npc, entity idleRef, string anim = "", bool useBlend = false )
{
	if ( anim == "" )
		anim = ANIM_OG_STANDING_TALK

	thread Training_NPC_Idles( npc, idleRef, anim, useBlend )
}

void function Training_NPC_Idles( entity npc, entity idleRef, string anim = "", bool useBlend = false )
{
	npc.Signal( "NPC_NewCommand" )

	if ( anim == "" )
		anim = ANIM_OG_STANDING_IDLE

	npc.Anim_Stop()

	if ( useBlend )
		thread PlayAnim( npc, anim, idleRef )
	else
		thread PlayAnim( npc, anim, idleRef, null, 0.0 )
}

void function Training_NPC_ScriptedAnim( entity npc, entity idleRef, string anim, bool useBlend = false )
{
	npc.Signal( "NPC_NewCommand" )

	npc.Anim_Stop()

	if ( useBlend )
		PlayAnim( npc, anim, idleRef )
	else
		PlayAnim( npc, anim, idleRef, null, 0.0 )
}

void function Training_OG_Moves_ToSitting( entity moveToRef, string destAnim = "", float moveTimeOverride = -1 )
{
	if ( destAnim == "" )
		destAnim = ANIM_OG_SITTING_IDLE

	Training_OG_Moves( moveToRef, destAnim, moveTimeOverride, true )
}

void function Training_OG_Moves( entity moveToRef, string destAnim = "", float moveTimeOverride = -1, bool destAnim_isSitting = false )
{
	entity og = GetOGPilot()
	og.Signal( "NPC_NewCommand" )

	int ogAttachIdx = og.LookupAttachment( "CHESTFOCUS" )
	vector startOrigin = og.GetAttachmentOrigin( ogAttachIdx )

	const vector standingOffset = <0, 0, 42>
	const vector sittingOffset = <0, 0, 20>
	vector destHeightOffset 	= destAnim_isSitting ? sittingOffset : standingOffset
	vector endOrigin = moveToRef.GetOrigin() + destHeightOffset

	og.Freeze()

	file.ogPilot = null

	if ( IsValid( og ) )
	{
		og.NotSolid()
		DissolveGhost( og )
	}

	entity newOG = Training_SpawnOGPilot( moveToRef )
	newOG.Hide()

	entity mover = CreateScriptMover( startOrigin, <0,0,0> )
	int moverAttachIdx = mover.LookupAttachment( "REF" )
	EmitSoundOnEntity( mover, "og_dissolve_trail" )
	file.ogPathMover = mover

	newOG.EndSignal( "OnDestroy" )
	mover.EndSignal( "OnDestroy" )

	OnThreadEnd(
	function() : ( mover, newOG, moveToRef, destAnim_isSitting, destAnim, ogAttachIdx )
		{
			if ( IsValid( mover ) )
			{
				StopSoundOnEntity( mover, "og_dissolve_trail" )
				mover.Destroy()
				file.ogPathMover = null
			}

			if ( IsValid( newOG ) )
			{
				StartParticleEffectOnEntity( newOG, GetParticleSystemIndex( GHOST_FLASH_EFFECT ), FX_PATTACH_POINT, ogAttachIdx )
				newOG.Show()

				if ( destAnim_isSitting )
					Training_OG_Idles_Sitting( moveToRef, destAnim )
				else
					Training_OG_Idles( moveToRef, destAnim )
			}
		}
	)

	StartParticleEffectOnEntity( mover, GetParticleSystemIndex( GHOST_TRAIL_EFFECT ), FX_PATTACH_POINT_FOLLOW, moverAttachIdx )
	StartParticleEffectOnEntity( mover, GetParticleSystemIndex( GHOST_FLASH_EFFECT ), FX_PATTACH_POINT, moverAttachIdx )
	wait 0.5

	float moveSpeed = 1350.0
	float moveDist = Distance( startOrigin, endOrigin )
	float moveTime = moveDist / moveSpeed
	if ( moveTimeOverride > 0 )
		moveTime = moveTimeOverride

	float accel = moveTime * 0.1
	float decel = moveTime * 0.1
	mover.NonPhysicsMoveTo( endOrigin, moveTime, accel, decel )
	wait moveTime - 0.1

	EmitSoundAtPosition( TEAM_UNASSIGNED, endOrigin, "PathHologram_Materialized_training" )
	StartParticleEffectOnEntity( mover, GetParticleSystemIndex( GHOST_FLASH_EFFECT ), FX_PATTACH_POINT, moverAttachIdx )
	wait 0.1
}

entity function TeleportOG( string entName )
{
	Assert( IsValid( file.ogPilot ) )

	file.ogPilot.Signal( "NPC_NewCommand" )
	file.ogPilot.Anim_Stop()

	entity teleportSpot = GetEntByScriptName( entName )

	vector org = teleportSpot.GetOrigin()
	vector ang = teleportSpot.GetAngles()
	file.ogPilot.SetOrigin( org )
	file.ogPilot.SetAngles( ang )

	return teleportSpot
}

void function NPC_DisableArrivals( entity npc )
{
	printt( "disabling arrivals" )
	npc.EnableNPCMoveFlag( NPCMF_DISABLE_ARRIVALS )
}

void function NPC_EnableArrivals( entity npc )
{
	printt( "enabling arrivals" )
	npc.DisableNPCMoveFlag( NPCMF_DISABLE_ARRIVALS )
}


void function PlayerAndOGTeleport_Fancy( entity player, vector destPos, string ogTeleportSpotName, vector destAng = < -1, -1, -1 > )
{
	EndSignal( player, "OnDeath" )
	thread FancyTeleport_EffectsAndSound( player, destPos )

	player.WaitSignal( "FancyTeleportStart" )

	entity ogTeleportSpot = TeleportOG( ogTeleportSpotName )
	Training_OG_Idles_Sitting( ogTeleportSpot )

	MakeInvincible( player )
	WaitEndFrame() // player will take damage from random hazard triggers otherwise

	player.SetOrigin( destPos )
	if ( destAng != < -1, -1, -1 > )
		player.SetAngles( destAng )

	ClearInvincible( player )
}

void function FancyTeleport_EffectsAndSound( entity player, vector teleportPos )
{
	EndSignal( player, "OnDeath" )

	float statusEffect_severity = 2.5
	float statusEffect_totalDuration = 0.8
	float statusEffect_easeOutTime = 0.1
	StatusEffect_AddTimed( player, eStatusEffect.timeshift_visual_effect, statusEffect_severity, statusEffect_totalDuration, statusEffect_easeOutTime )

	wait 0.1

	Remote_CallFunction_Replay( player, "ScriptCallback_PodTransition_PlayerScreenFX" )

	EmitSoundOnEntity( player, "Timeshift_Scr_DeviceShift2Present" )

	wait 0.25  // let screen FX fade screen

	player.Signal( "FancyTeleportStart" )

	//wait holdTime - 0.1

	wait 0.5  // let white screen fade

	EmitSoundOnEntity( player, "training_scr_zen_player_fall" )

	wait 0.2  // let screen clear before pulsing

	entity pulseFXHandle = PlayFX( FX_FANCY_TELEPORT_ENV_PULSE, teleportPos, <0,0,0> )
	EffectSetControlPointVector( pulseFXHandle, 1, <2.5,50,0> )
	thread KillFX_Delayed( pulseFXHandle, 0.5 )
}

entity function WaitForPlayerActiveWeapon( entity player )
{
	player.EndSignal( "OnDestroy" )

	entity weapon = null
	while ( !weapon )
	{
		WaitFrame()
		weapon = player.GetActiveWeapon()
	}

	return weapon
}


void function GhostRecorder_RepeatUntilFlag( entity player, string endFlag, entity animRef, asset recordedAnim, float extraRepeatDelay = 0.0, bool silentDissolve = false )
{
	EndSignal( player, "OnDestroy" )
	EndSignal( level, "StopRepeatingGhostRecorder" )

	if ( Flag( endFlag ) )
		return
	FlagEnd( endFlag )

	string dissolveSFX = "object_dissolve_training"
	if ( silentDissolve )
		dissolveSFX = ""

	table<int,entity> t = {}
	t[0] <- null

	OnThreadEnd(
	function() : ( t, dissolveSFX )
		{
			if ( !t.len() )
				return

			entity ghost = t[0]

			if ( IsValid( ghost ) )
			{
				StopSoundOnEntity( ghost, "PathHologram_Sustain_Loop_3P" )
				DissolveGhost( ghost, dissolveSFX )
			}
		}
	)

	var rec = LoadRecordedAnimation( recordedAnim )
	float duration = GetRecordedAnimationDuration( rec )

	const float ghostFadeTime = 1.2

	while ( 1 )
	{
		entity ghost = CreateGhost( animRef.GetOrigin() )
		t[0] = ghost

		EmitSoundOnEntity( ghost, "PathHologram_Sustain_Loop_3P" )

		ghost.PlayRecordedAnimation( rec, <0,0,0>, <0,0,0>, DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME, animRef )
		wait duration - ghostFadeTime

		DissolveGhost( ghost, dissolveSFX )

		wait ghostFadeTime
		wait extraRepeatDelay
	}
}

void function Training_TeleportEffect( entity player )
{
	player.EndSignal( "OnDestroy" )

	player.MovementDisable()

	OnThreadEnd(
	function() : ( player )
		{
			if ( IsValid( player ) )
				player.MovementEnable()
		}
	)

	float fadeTime = 0.3
	float holdTime = 0.5

	ScreenFade( player, 255, 255, 255, 254, fadeTime, holdTime, FFADE_IN | FFADE_PURGE )
	EmitSoundOnEntity( player, "NPE_VisualImpair" )
	wait fadeTime
	wait holdTime
	FadeOutSoundOnEntity( player, "NPE_VisualImpair", fadeTime )
}

void function TakeAmmoFromPlayerASAP( entity player )
{
	player.EndSignal( "OnDestroy" )

	entity weapon = WaitForPlayerActiveWeapon( player )

	array<entity> weapons = player.GetMainWeapons()

	foreach ( weapon in weapons )
	{
		weapon.SetWeaponPrimaryAmmoCount( 0 )
		weapon.SetWeaponPrimaryClipCount( 0 )
	}

	// take offhand weapons player may have collected
	array<entity> offhands = player.GetOffhandWeapons()
	foreach ( index, weapon in clone offhands )
		player.TakeOffhandWeapon( index )
}

void function Training_WeaponPickups_Init( entity player )
{
	Assert( Flag( "EntitiesDidLoad" ) )

	LeveledScriptedWeapons leveledScriptedWeapons = GetAllLeveledScriptWeapons()

	foreach ( ent in leveledScriptedWeapons.infoTargets )
		thread Training_RecreateWeaponPickup_Think( ent, player )
}

void function Training_SetWeaponPickupsEmptyAmmo()
{
	file.weaponPickupsHaveAmmo = false

	LeveledScriptedWeapons leveledScriptedWeapons = GetAllLeveledScriptWeapons()
	foreach ( ent in leveledScriptedWeapons.infoTargets )
	{
		// fix for player picking up a weapon right before calling this- attachedEnt is empty because it hasn't been recreated yet
		// - actual fix is to thread, wait for attachedEnts to get the recreated weapon again, and timeout, but going with less risk for now
		if ( !ent.e.attachedEnts.len() )
			continue

		entity weaponEnt = ent.e.attachedEnts[0]
		if ( !IsValid( weaponEnt ) )
			continue

		weaponEnt.SetWeaponPrimaryAmmoCount( 0 )
		weaponEnt.SetWeaponPrimaryClipCount( 0 )
	}
}

void function Training_SetWeaponPickupsFullAmmo()
{
	file.weaponPickupsHaveAmmo = true

	LeveledScriptedWeapons leveledScriptedWeapons = GetAllLeveledScriptWeapons()
	foreach ( ent in leveledScriptedWeapons.infoTargets )
	{
		// fix for player picking up a weapon right before calling this- attachedEnt is empty because it hasn't been recreated yet
		// - actual fix is to thread, wait for attachedEnts to get the recreated weapon again, and timeout, but going with less risk for now
		if ( !ent.e.attachedEnts.len() )
			continue

		entity weaponEnt = ent.e.attachedEnts[0]
		if( !IsValid( weaponEnt ) )
			continue

		string weaponClass = weaponEnt.GetWeaponClassName()
		int defaultTotal 	= GetWeaponInfoFileKeyField_GlobalInt( weaponClass, "ammo_default_total" )
		int defaultMag 		= GetWeaponInfoFileKeyField_GlobalInt( weaponClass, "ammo_clip_size" )

		weaponEnt.SetWeaponPrimaryAmmoCount( defaultTotal )
	}
}

void function Training_RecreateWeaponPickup_Think( entity ent, entity player )
{
	EndSignal( player, "OnDestroy" )
	EndSignal( ent, "OnDestroy" )

	const float MATCHING_PICKUP_DIST = 0.5
	const float NEARBY_SIMILAR_DIST = 200.0

	string pickupEntWeaponClass = ent.GetValueForKey( "script_weapon" )

	while ( ent.e.attachedEnts.len() && IsValid( ent.e.attachedEnts[0] ) )
	{
		entity weaponEnt = ent.e.attachedEnts[0]

		while ( IsValid( weaponEnt ) && !weaponEnt.GetOwner() )
			wait 0.1

		// this is the most reliable way to get a good push vector for if we need to kick another weapon out (pickup ent angles are often not optimal)
		vector playerPos_onPickup = player.GetOrigin()
		vector vecToPlayer_whenPickedUp = Normalize( playerPos_onPickup - ent.GetOrigin() )

		ent.e.attachedEnts.remove( 0 )

		wait 2.2  // don't respawn it right away

		bool oldWeapon_similarPickupNearby = false
		bool pickupEnt_similarPickupNearby = false

		// previous player weapon may be here after swapping
		array<entity> allPickups = GetWeaponArray( true )
		entity oldWeapon
		foreach ( pickup in allPickups )
		{
			float distToThisPickup = Distance( pickup.GetOrigin(), ent.GetOrigin() )
			if ( distToThisPickup <= MATCHING_PICKUP_DIST )
			{
				oldWeapon = pickup
				break
			}
		}

		if ( IsValid( oldWeapon ) )
		{
			foreach ( pickup in allPickups )
			{
				if ( oldWeapon == pickup )
					continue

				float distToThisPickup = Distance( pickup.GetOrigin(), ent.GetOrigin() )
				if ( distToThisPickup <= NEARBY_SIMILAR_DIST )
				{
					string pickupWeaponClass = pickup.GetWeaponClassName()

					if ( pickupWeaponClass == oldWeapon.GetWeaponClassName() && !oldWeapon_similarPickupNearby )
					{
						//printt( "found similar pickup nearby to one the player dropped:", pickupWeaponClass )
						oldWeapon_similarPickupNearby = true
					}

					if ( pickupWeaponClass == pickupEntWeaponClass && !pickupEnt_similarPickupNearby )
					{
						//printt( "found similar pickup nearby to one that would be recreated:", pickupWeaponClass )
						pickupEnt_similarPickupNearby = true
					}
				}
			}
		}

		bool recreatePickup = true
		bool destroyOldWeapon = false
		if ( IsValid( oldWeapon ) )
		{
			if ( oldWeapon.GetWeaponClassName() == pickupEntWeaponClass )
			{
				printt( "old weapon that is here is the same kind of weapon as we would spawn, so don't recreate:", pickupEntWeaponClass )
				recreatePickup = false  // old weapon that is here is the same kind of weapon as we would spawn, so don't recreate
			}

			if ( oldWeapon_similarPickupNearby )
			{
				printt( "Old weapon can be destroyed, because a similar pickup is nearby:", oldWeapon.GetWeaponClassName() )
				destroyOldWeapon = true
			}

			if ( !oldWeapon_similarPickupNearby && pickupEnt_similarPickupNearby )
			{
				printt( "old weapon is unique to this area and pickup ent has a similar pickup nearby, so don't recreate pickup ent. Old weapon:", oldWeapon.GetWeaponClassName(), "/ pickup ent class:", pickupEntWeaponClass )
				recreatePickup = false
			}
		}

		if ( recreatePickup )
		{
			if ( IsValid( oldWeapon ) )
			{
				if ( destroyOldWeapon )
				{
					printt( "destroying old weapon because similar pickup is nearby:", oldWeapon.GetWeaponClassName() )
					oldWeapon.Destroy()
				}
				else
				{
					MoveOldWeapon( ent, oldWeapon, vecToPlayer_whenPickedUp )  // kick the old weapon out of this spot
				}
			}

			// cover respawn with a flash effect
			EmitSoundAtPosition( TEAM_UNASSIGNED, ent.GetOrigin(), "training_scr_rack_weapon_appear" )
			StartParticleEffectInWorld( GetParticleSystemIndex( GHOST_FLASH_EFFECT ), ent.GetOrigin(), ent.GetAngles() )
			CreateScriptWeapon( ent )

			// defensive checks
			if ( !ent.e.attachedEnts.len() || !IsValid( ent.e.attachedEnts[0] ) )
			{
				printt( "WARNING! Recreated script pickup FAILED to recreate:", pickupEntWeaponClass, "on ent", ent )
				continue
			}

			entity recreatedPickup = ent.e.attachedEnts[0]
			printt( "training: recreated weapon pickup:", pickupEntWeaponClass, "by spawning:", recreatedPickup )

			if ( !file.weaponPickupsHaveAmmo )
			{
				recreatedPickup.SetWeaponPrimaryAmmoCount( 0 )
				recreatedPickup.SetWeaponPrimaryClipCount( 0 )
			}
		}
		else
		{
			if ( IsValid( oldWeapon ) )
				ent.e.attachedEnts.append( oldWeapon )
		}
	}

	printt( "WARNING- Stopping think on pickupEntWeapon:", pickupEntWeaponClass )
}

void function MoveOldWeapon( entity pickupEnt, entity oldWeapon, vector pushVec = <0,0,0> )
{
	// recreate weapon as unconstrained so we can physics push it
	entity recreatedOldWeapon = Training_RecreatePlayerWeaponPickup( oldWeapon )
	string recreatedClassName = recreatedOldWeapon.GetWeaponClassName()

	float velocityScalar = 300.0

	var hasSubClass = GetWeaponInfoFileKeyField_Global( recreatedClassName, "weaponSubClass" )
	if ( hasSubClass )
	{
		string weaponSubClass = GetWeaponInfoFileKeyField_GlobalString( recreatedClassName, "weaponSubClass" )

		switch ( weaponSubClass )
		{
			case "offhand":
			case "pistol":
				velocityScalar = 200
				break

			case "smg":
				velocityScalar = 300
				break

			case "rifle":
				velocityScalar = 400
				break

			case "lmg":
			case "at":
				velocityScalar = 500
				break
		}
	}

	if ( pushVec == <0,0,0> )
		pushVec = AnglesToForward( pickupEnt.GetAngles() )

	//vector pushAng = VectorToAngles( pushVec )
	//vector addVec = AnglesToUp( pushAng ) * (velocityScalar * 0.2)
	//pushVec += addVec
	pushVec += <0,0,1>

	printt( "moving old weapon:", oldWeapon.GetWeaponClassName(), "with velocity scalar:", velocityScalar )
	recreatedOldWeapon.SetVelocity( pushVec * velocityScalar )
}

entity function Training_RecreatePlayerWeaponPickup( entity oldWeapon )
{
	if ( file.scriptCreatedWeaponPickups.len() >= MAX_RECREATED_OLD_WEAPONS )
	{
		entity cleanupWeapon = file.scriptCreatedWeaponPickups[0]

		if ( IsValid( cleanupWeapon ) )
			cleanupWeapon.Destroy()

		file.scriptCreatedWeaponPickups.remove( 0 )
	}

	string oldWeaponClass = oldWeapon.GetWeaponClassName()

	entity weapon = CreateWeaponEntityByNameWithPhysics( oldWeaponClass, oldWeapon.GetOrigin(), oldWeapon.GetAngles() )
	weapon.SetVelocity( <0,0,0> )

	SetTargetName( weapon, "_old_player_weapon_" + oldWeaponClass )
	weapon.kv.fadedist = -1

	array<string> existingMods = oldWeapon.GetMods()
	weapon.SetMods( existingMods )

	bool doMarkAsLoadoutPickup = false
	if ( doMarkAsLoadoutPickup )
		weapon.MarkAsLoadoutPickup()

	HighlightWeapon( weapon )

	oldWeapon.Destroy()

	file.scriptCreatedWeaponPickups.append( weapon )

	return weapon
}


void function Training_WeaponRacks_SetSolidity( bool doSolid )
{
	array<entity> racks = GetEntArrayByScriptName( "ineedguns_racks" )

	foreach ( rack in racks )
	{
		if ( doSolid )
			rack.Solid()
		else
			rack.NotSolid()
	}
}


bool function GetAutosprintEnabled()
{
	int autosprintSetting = GetConVarInt( AUTOSPRINT_CONVAR_NAME )
	bool autoSprintEnabled = autosprintSetting > 0 && autosprintSetting < 3  // 0 = none, 3 = titans only
	return autoSprintEnabled
}


void function EmitSoundOnEntity_Delayed( entity ent, string alias, float delay )
{
	ent.EndSignal( "OnDestroy" )

	if ( delay > 0 )
		wait delay

	EmitSoundOnEntity( ent, alias )
}

void function PlayFXOnEntity_Delayed( entity player, asset fxAsset, entity ent, float delay )
{
	player.EndSignal( "OnDestroy" )
	ent.EndSignal( "OnDeath" )

	wait delay

	PlayFXOnEntity( fxAsset, ent )
}

void function KillFX_Delayed( entity fxHandle, float delay )
{
	fxHandle.EndSignal( "OnDestroy" )

	if ( delay > 0.0 )
		wait delay

	KillFX( fxHandle )
}

void function KillFX( entity fxHandle )
{
	if ( !IsValid_ThisFrame( fxHandle ) )
		return

	fxHandle.SetStopType( "DestroyImmediately" )
	fxHandle.ClearParent()
	fxHandle.Destroy()
}

void function KillFXWithEndcap( entity fxHandle, float killDelay = 1.0 )
{
	if ( !IsValid_ThisFrame( fxHandle ) )
		return

	EffectStop( fxHandle )
	wait killDelay

	if ( !IsValid_ThisFrame( fxHandle ) )
		return

	fxHandle.ClearParent()
	fxHandle.Destroy()
}


void function FlagSetDelayed( string setFlag, float delay )
{
	thread FlagSetDelayed_Think( setFlag, delay )
}

void function FlagSetDelayed_Think( string setFlag, float delay )
{
	EndSignal( level, "OnDestroy" )

	if ( delay > 0 )
		wait delay

	FlagSet( setFlag )
}


void function Training_PlayerQuickdeathSFX( entity player )
{
	EndSignal( player, "OnDestroy" )

	while ( 1 )
	{
		WaitSignal( player, "QuickDeath" )
		EmitSoundOnEntity( player, "training_scr_zen_player_fall" )
	}
}


void function Training_EnvArtColorCorrection_SetEnabled( bool isEnabled )
{
	Assert( IsValid( file.envArt_colorCorrectionEnt ), "Called too early?" )

	string setEnabledStr = "Disable"
	if ( isEnabled)
		setEnabledStr = "Enable"

	EntFireByHandle( file.envArt_colorCorrectionEnt, setEnabledStr, "", 0, null, null )
}


void function SetDoF_Hangar( entity player )
{
	Remote_CallFunction_Replay( player, "ScriptCallback_DoF_SetNearDepth", 	0, 18 )
	Remote_CallFunction_Replay( player, "ScriptCallback_DoF_SetFarDepth", 	450, 1250 )
}

void function SetDoF_Default( entity player )
{
	Remote_CallFunction_Replay( player, "ScriptCallback_DoF_SetNearDepthToDefault" )
	Remote_CallFunction_Replay( player, "ScriptCallback_DoF_SetFarDepthToDefault" )
}

void function RackDoF_NearDepth( entity player, float nearDepthStart, float nearDepthEnd, float rackTime )
{
	Remote_CallFunction_Replay( player, "ScriptCallback_DoF_SetNearDepth", 	nearDepthStart, nearDepthEnd, rackTime )
}

void function RackDOF_NearDepth_ToDefault( entity player, float duration )
{
	Remote_CallFunction_Replay( player, "ScriptCallback_DoF_SetNearDepthToDefault", duration )
}

void function RackDoF_FarDepth( entity player, float farDepthStart, float farDepthEnd, float rackTime )
{
	Remote_CallFunction_Replay( player, "ScriptCallback_DoF_SetFarDepth", 	farDepthStart, farDepthEnd, rackTime )
}

void function SimpleScreenShake( entity player, float duration, float amplitude, float blurMaxIntensity = 0.75 )
{
	Remote_CallFunction_Replay( player, "ScriptCallback_SimpleScreenShake", duration, amplitude, blurMaxIntensity )
}

void function SetWeaponHUDEnabled( entity player, bool setEnabled )
{
	file.displayWeaponHUD = setEnabled
	Remote_CallFunction_Replay( player, "ScriptCallback_SetWeaponHUDEnabled", setEnabled )
}



// ---------------------
// ----- SKIT GUYS -----
// ---------------------
SkitGuyInfo function AddSkitGuy_Manually( string name, entity guy )
{
	if ( SkitGuyExists( name ) )
		DeleteSkitGuy( GetSkitGuyInfo_ByName( name ) )

	SkitGuyInfo info
	info.id 		= file.skitguys.len()
	info.guy 		= guy
	info.name 		= name

	file.skitguys.append( info )

	return info
}

SkitGuyInfo function SpawnSkitGuy( string name, string anim, vector origin, vector angles, int team = TEAM_IMC, string aiSettings = "", string weapon = "mp_weapon_semipistol", bool isRunner = false )
{
	if ( SkitGuyExists( name ) )
		DeleteSkitGuy( GetSkitGuyInfo_ByName( name ) )

	string guyType = "grunt"
	if ( name.find( "marvin" ) != null )
		guyType = "marvin"

	// spawn the guy
	entity guy
	if ( guyType == "marvin" )
	{
		Assert( !isRunner, "Marvins don't run!" )

		guy = CreateEntity( "npc_marvin" )

		DispatchSpawn( guy )

		SetTeam( guy, TEAM_SPECTATOR )
		guy.SetNPCMoveSpeedScale( 0.6 )

		//TakeAllJobs( guy )
	}
	else
	{
		guy = CreateSoldier( team, <0,0,0>, <0,0,0> )  // spawn the guy at worldspawn to avoid "npc spawned in solid" red text`
		SetSpawnOption_Weapon( guy, weapon )
		if ( aiSettings != "" )
			SetSpawnOption_AISettings( guy, aiSettings )

		if ( isRunner )
			guy.kv.alwaysAlert = 1

		DispatchSpawn( guy )
	}

	guy.SetTitle( "" )

	entity ref = CreateOwnedScriptMover( guy )
	ref.SetOrigin( origin )
	ref.SetAngles( angles )

	guy.SetOrigin( ref.GetOrigin() )
	guy.SetAngles( ref.GetAngles() )

	MakeInvincible( guy )
	guy.SetEfficientMode( true )
	guy.EnableNPCFlag( NPC_IGNORE_ALL | NPC_DISABLE_SENSING )
	guy.DisableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE | NPC_ALLOW_FLEE | NPC_ALLOW_HAND_SIGNALS )

	SkitGuyInfo info
	info.id 		= file.skitguys.len()
	info.guy 		= guy
	info.skitRef 	= ref
	info.skitAnim 	= anim
	info.name 		= name

	file.skitguys.append( info )

	return info
}

void function SpawnSkitGuy_AndRun( string name, array<Point> path, float moveSpeedScale, int team, string aiSettings = "", string weaponName = "" )
{
	SkitGuyInfo runnerInfo
	runnerInfo = SpawnSkitGuy( name, "", path[0].origin, path[0].angles, team, aiSettings, weaponName, true )

	entity runner = runnerInfo.guy
	EndSignal( runner, "OnDestroy" )

	OnThreadEnd(
	function() : ( runnerInfo )
		{
			DeleteSkitGuy( runnerInfo )
		}
	)

	waitthread ScriptedPath_Run( runnerInfo, path, moveSpeedScale )
}

void function SpawnSkitGuy_AndRunForever( string name, array<Point> path, float moveSpeedScale, int team, string aiSettings = "", string weaponName = "" )
{
	SkitGuyInfo runnerInfo
	while ( 1 )
	{
		runnerInfo = SpawnSkitGuy( name, "", path[0].origin, path[0].angles, team, aiSettings, weaponName )
		waitthread ScriptedPath_Run( runnerInfo, path, moveSpeedScale )
	}
}

void function SkitGuy_PlayAnim( SkitGuyInfo info, float skipAheadTime = 0 )
{
	Assert( info.skitAnim != "" )
	Assert( IsValid( info.skitRef ) )

	entity guy = info.guy

	thread PlayAnim( guy, info.skitAnim, info.skitRef, null, 0.0, skipAheadTime )
}

bool function SkitGuyExists( string name )
{
	foreach ( info in file.skitguys )
	{
		if ( info.name == name )
			return true
	}

	return false
}

SkitGuyInfo function GetSkitGuyInfo_ByName( string guyName )
{
	SkitGuyInfo thisInfo
	foreach ( info in file.skitguys )
	{
		if ( info.name == guyName )
		{
			thisInfo = info
			return thisInfo
		}
	}

	Assert( false, "couldn't find skit guy info by name: " + guyName )
	unreachable
}

void function DeleteAllSkitGuys()
{
	array<string> deleteNames = []

	foreach ( skitInfo in file.skitguys )
		deleteNames.append( skitInfo.name )

	foreach ( name in deleteNames )
	{
		if ( !SkitGuyExists( name ) )
			continue

		SkitGuyInfo deleteInfo = GetSkitGuyInfo_ByName( name )
		DeleteSkitGuy( deleteInfo )
	}
}

void function DeleteSkitGuy( SkitGuyInfo info )
{
	KillSkitGuy( info )

	int removeIdx = -1
	foreach ( idx, guyInfo in file.skitguys )
	{
		if ( guyInfo.id == info.id )
		{
			removeIdx = idx
			break
		}
	}

	if ( removeIdx == -1 )
	{
		printt( "WARNING: SkitGuy was already deleted!" )
		return
	}


	file.skitguys.remove( removeIdx )
}

void function KillSkitGuy( SkitGuyInfo info )
{
	entity guy = info.guy
	entity skitRef = info.skitRef

	if ( IsValid( skitRef ) )
		skitRef.Destroy()

	info.skitRef = null

	if ( IsAlive( guy ) )
	{
		guy.Anim_Stop()
		ClearInvincible( guy )
	}

	if ( IsValid( guy ) )
		guy.Destroy()

	info.guy = null
}

#if DEV
string function NudgeSkitGuy( string name, float offsetX, float offsetY = 0.0, float offsetZ = 0.0 )
{
	if ( !SkitGuyExists( name ) )
	{
		return "WARNING: SKIT GUY NAME NOT RECOGNIZED: " + name
	}

	SkitGuyInfo info = GetSkitGuyInfo_ByName( name )
	entity guy = info.guy
	entity skitRef 	= info.skitRef
	string name 	= info.name

	vector offset = <offsetX, offsetY, offsetZ>

	if ( IsValid( skitRef ) )
		skitRef.SetOrigin( skitRef.GetOrigin() + offset )
	else
		guy.SetOrigin( guy.GetOrigin() + offset )

	if ( info.skitAnim != "" )
		SkitGuy_PlayAnim( info )

	printt( "NUDGED:")
	return PrintSkitGuy( info )
}

string function PrintSkitGuy( SkitGuyInfo info )
{
	entity guy 		= info.guy
	entity skitRef 	= info.skitRef
	string name 	= info.name

	string returnStr = name + " origin/angles: " + CreateOriginAnglesString( guy.GetOrigin(), guy.GetAngles() )
	if ( IsValid( skitRef ) )
		returnStr = name + " ref origin/angles: " + CreateOriginAnglesString( skitRef.GetOrigin(), skitRef.GetAngles() )

	return returnStr
}
#endif //DEV



// ------------------------------
// ----- SCRIPTED NPC PATHS -----
// ------------------------------
void function ScriptedPath_AddPoint( array<Point> pathpoints, vector origin, vector angles )
{
	Point pathpoint
	pathpoint.origin = origin
	pathpoint.angles = angles

	pathpoints.append( pathpoint )
}

void function ScriptedPath_Walk( SkitGuyInfo info, array<Point> path, float moveSpeedScale = 0.8, string idleAnim = "" )
{
	NPC_ScriptedPath( SCRIPTED_PATH_WALK, info, path, moveSpeedScale, idleAnim )
}

void function ScriptedPath_Run( SkitGuyInfo info, array<Point> path, float moveSpeedScale = 1.0, string idleAnim = "" )
{
	NPC_ScriptedPath( SCRIPTED_PATH_RUN, info, path, moveSpeedScale, idleAnim )
}

void function NPC_ScriptedPath( int pathFollowType, SkitGuyInfo info, array<Point> path, float moveSpeedScale = 1.0, string idleAnim = "" )
{
	entity guy = info.guy

	guy.EndSignal( "OnDestroy" )

	guy.Anim_Stop()

	guy.EnableNPCMoveFlag( NPCMF_DISABLE_MOVE_TRANSITIONS )
	guy.EnableNPCMoveFlag( NPCMF_DISABLE_ARRIVALS )
	guy.SetNPCMoveSpeedScale( moveSpeedScale )

	if ( pathFollowType == SCRIPTED_PATH_RUN )
		guy.SetAlert()  // change his alert state so he will run

	if ( pathFollowType == SCRIPTED_PATH_WALK )
		guy.SetMoveAnim( "patrol_walk_bored" )

	string waitSignal = "OnEnterGoalRadius" //"OnFinishedAssault"
	float pathfindingFailTimeout = 20.0

	guy.SetOrigin( path[0].origin )
	guy.SetAngles( path[0].angles )

	for ( int i = 1; i < path.len(); i++ )
	{
		Point pathpoint = path[i]
		float goalradius = 64.0  // MINIMUM
		//guy.DisableArrivalOnce( true )  // always want arrivals disabled because they are blended from run anim, not walking

		guy.AssaultPoint( pathpoint.origin )
		guy.AssaultSetGoalRadius( goalradius )

		WaitSignalTimeout( guy, pathfindingFailTimeout, waitSignal )

		if ( Distance( guy.GetOrigin(), pathpoint.origin ) >= goalradius )
		{
			printt( guy, " scripted pathfinding stopped, quitting." )
			break
		}
	}

	if ( idleAnim != "" )
	{
		guy.DisableBehavior( "Assault" )

		while ( !guy.IsInterruptable() )
			wait 0.1

		entity ref = CreateOwnedScriptMover( guy )
		thread PlayAnim( guy, idleAnim, ref, null, 0.4 )

		WaitForever()
	}
	else
	{
		DeleteSkitGuy( info )
	}
}



// -----------------------------
// ----- TITAN GROUP SKITS -----
// -----------------------------
void function HangarTitanGroup_Init( HangarTitanGroup group )
{
	group.rack_ogPos = group.rack.GetOrigin()
	group.rack_ogAng = group.rack.GetAngles()

	if ( IsValid( group.titan ) )
	{
		if ( group.titanSkin == -1 )
			group.titanSkin = 1
	}

	if ( group.marvinAnim != "" )
	{
		group.marvin = CreatePropDynamic( MARVIN_MODEL )
		group.marvin.DisableHibernation()
	}

	if ( group.pilotAnim != "" )
	{
		group.pilot = CreatePropDynamic( group.pilotModel )
		group.pilot.DisableHibernation()
	}

	HangarTitanGroup_SetMaxSequenceDuration( group )

	group.isInited = true
}

void function HangarTitanGroup_SetMaxSequenceDuration( HangarTitanGroup group )
{
	table<string,entity> sceneActors = {}
	sceneActors[ group.titanAnim ] <- group.titan
	sceneActors[ group.rackAnim ] <- group.rack
	sceneActors[ group.marvinAnim ] <- group.marvin

	if ( IsValid( group.titan ) )
	{
		// set titan to use non posed model
		group.titan.SetModel( BUDDY_MODEL )
		group.titan.SetSkin( group.titanSkin )
	}

	float maxDuration = 0
	foreach ( anim, actor in sceneActors )
	{
		if ( !IsValid( actor ) )
			continue

		float animDuration = actor.GetSequenceDuration( anim )
		if ( animDuration > maxDuration )
			maxDuration = animDuration
	}

	group.sequenceDuration = maxDuration

	if ( IsValid( group.titan ) )
	{
		// set titan back to posed anim
		group.titan.SetModel( BUDDY_MODEL_POSED_NO_ANIMS )
		//group.titan.SetSkin( group.titanSkin )
	}
}

void function HangarTitanGroup_Animate( HangarTitanGroup group, string endFlag = "", float duration = -1, bool doCleanup = true )
{
	if ( endFlag != "" )
		FlagEnd( endFlag )

	Assert( group.isInited, "Need to call HangarTitanGroup_Init on this group before using" )

	entity ref 				= group.ref
	entity titan 			= group.titan
	entity rack 			= group.rack
	entity marvin 			= group.marvin
	entity pilot 			= group.pilot
	string titanAnim 		= group.titanAnim
	string rackAnim 		= group.rackAnim
	string marvinAnim 		= group.marvinAnim
	string pilotAnim 		= group.pilotAnim
	float animInitialTime 	= group.animInitialTime

	EndSignal( rack, "OnDestroy" )

	if ( IsValid( marvin ) )
		EndSignal( marvin, "OnDestroy")

	if ( IsValid( titan ) )
	{
		EndSignal( titan, "OnDestroy" )

		// set titan to use non posed model
		titan.SetModel( BUDDY_MODEL )
		titan.SetSkin( group.titanSkin )
	}

	OnThreadEnd(
	function() : ( doCleanup, group )
		{
			if ( doCleanup )
				HangarTitanGroup_Cleanup( group )
		}
	)

	if ( duration == -1 || group.sequenceDuration < duration )
		duration = group.sequenceDuration

	thread PlayAnim( rack, rackAnim, ref, null, 0.0, animInitialTime )

	if ( IsValid( titan) )
		thread PlayAnim( titan, titanAnim, ref, null, 0.0, animInitialTime )

	if ( IsValid( marvin ) )
		thread PlayAnim( marvin, marvinAnim, ref, null, 0.0, animInitialTime )

	if ( IsValid( pilot ) )
		thread PlayAnim( pilot, pilotAnim, ref, null, 0.0, animInitialTime )

	wait duration
}

void function HangarTitanGroup_Cleanup( HangarTitanGroup group )
{
	HangarTitanGroup_Reset( group )

	if ( IsValid( group.marvin ) )
		group.marvin.Destroy()

	if ( IsValid( group.pilot ) )
		group.pilot.Destroy()
}

void function HangarTitanGroup_Reset( HangarTitanGroup group )
{
	entity titan = group.titan
	entity rack = group.rack

	if ( IsValid( titan ) )
	{
		titan.Anim_Stop()
		titan.SetModel( BUDDY_MODEL_POSED_NO_ANIMS )
		//titan.SetSkin( group.titanSkin )
	}

	if ( IsValid( rack ) )
	{
		rack.Anim_Stop()
		rack.SetOrigin( group.rack_ogPos )
		rack.SetAngles( group.rack_ogAng )
	}
}



#if DEV
void function skyboxchange( string tName )
{
	entity cam = GetEnt( tName )
	GetPlayerArray()[0].SetSkyCamera( cam )
}


// ======================================================
// ============ GHOST RECORDER DEV FUNCTIONS ============
// ======================================================
void function wallruntest()
{
	entity preWallrunRef = GetEntByScriptName( "basic_movement_wallrun_start_ref" )
	var rec = LoadRecordedAnimation( $"anim_recording/training_record_zengarden_wallrun.rpak" )
	file.ogPilot.Anim_Stop()
	file.ogPilot.PlayRecordedAnimation( rec, <0,0,0>, <0,0,0>, DEFAULT_SCRIPTED_ANIMATION_BLEND_TIME, preWallrunRef )
}

void function Record_ZenGarden_Wallrun()
{
	thread RecordAnimation_Think( "training_record_zengarden_wallrun", "basic_movement_wallrun_start_ref" )
}

void function Record_ZenGarden_Slide()
{
	thread RecordAnimation_Think( "training_record_zengarden_slide", "zengarden_slide_ref" )
}

void function Record_ZenGarden_DoubleJump()
{
	thread RecordAnimation_Think( "training_record_zengarden_doublejump", "zengarden_doublejump_ref" )
}

void function RecordAnimation_Think( string filename, string refName )
{
	entity player = file.player
	player.Signal( "RecordAnimation_Start" )
	player.EndSignal( "RecordAnimation_Start" )

	TeleportPlayerAndBT( refName )

	player.EndSignal( "OnDestroy" )

	entity ref = GetEntByScriptName( refName )

	printt( "READY TO RECORD: " + filename )

	//start recording
	player.WaitSignal( "ButtonPressedAttack" )
	printt( "RECORDING STARTED" )

	player.StartRecordingAnimation( ref.GetOrigin(), ref.GetAngles() )

	//stop
	player.WaitSignal( "ButtonPressedAttack" )

	var recording = player.StopRecordingAnimation()

#if PC_PROG
	SaveRecordedAnimation( recording, filename )
#endif
	printt( "STOP RECORD player org/ang:", player.GetOrigin(), player.GetAngles() )
}
#endif //DEV
