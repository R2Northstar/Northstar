untyped

global function IsAudioLogPlaying
global function SaveBoyleAudioLogs
global function InitBoyleAudioLogs
global function SetFlagWhenPlayerWithinRangeOfEnt
global function DeleteUnnecessaryFlyers
global function GetPosInOtherTimeline
global function ObjectiveRemindUntilFlag
global function PlayAnimThenDelete
global function LoudspeakerThread
global function GivePropForAnim
global function ElectricalScreenEffects
global function GetTimelinePosition
global function DisableNavmeshSeperatorTargetedByEnt
global function DropshipSpawnAndRepeat
global function DeleteNpcWhenOutOfSight
global function TitanTimeshiftHint
global function CreateShakeWhileFlagSet
global function CreateShakeTimeshift
global function RingsLocalExplosionNormal
global function RingsLocalExplosionBig
global function PlayerDropLand
global function ProwlersAmbientThink
global function PlayerConversationStopOnFlagImmediate
global function FlagSetDelayed
global function FlagClearDelayed
global function PlayerConversationStopOnFlag
global function HideCritTimeshift
global function TitanRackSpawnersThink
global function TitanRackDeploy
global function SpawnAutoSecurityGroup
global function SpawnPristineStalkersWithDopplegangers
global function TitanTimeshiftLoadout
global function AndersonHologramSequence
global function GunshipSequence
global function GetTimeshiftPlayer
global function GetClosestGrunt
global function EmitSoundAtPositionHack
global function FreezeNPC
global function UnFreezeNPC
global function MakeCivilian
global function DestroyNPCOnFlag
global function AttackPlayer
global function HideStuff
global function ShowStuff
global function SwapTimelinesScripted
global function TS_WithinPlayerFOV
global function SetFlagWhenPlayerLookingAtEnt
global function PlayerInRange
global function HideWeaponsAndAmmoTillFlag
global function DataStab
//global function MakeSpectreOwnedByPlayer
global function SkyboxStart
global function TimeshiftSetObjective
global function TimeshiftSetObjectiveSilent
global function TimeshiftUpdateObjective
global function SPTimeshiftUtilityInit
global function GetSpectreDoorSwitchByDummyName
global function DropHangingOgre
global function DropHangingOgreOnFlag
global function DestroyArray
global function LaserMeshDeactivateByInstanceName
global function LaserMeshDestroyByInstanceName
global function LaserMeshActivateByInstanceName
global function SetCurrentObjectivePos
global function MoveEntityToOppositeTimePeriod
global function HackPlayLoopEffectOnEntity
//global function CreateSoundRefHack
global function DeleteFireHazards
global function DestroyFuncBrushBreakable
//global function SpawnWallSpectreGroupWhenInRange
global function SpawnShowcaseGroupWhenInRange
global function RemoveBlocker
global function RestoreBlocker
global function TempExplosion
global function DestroyEntByScriptName
global function SwapTimelines
global function WaittillSomeDudesAreDead
global function WaittillPlayerSwitchesTimezone
global function TimeshiftPlayerThink
global function TimeshiftHint
global function DestroyInstancesByScriptInstanceName
global function HACK_DisableTurret
global function HACK_EnableTurret
global function GetNpcByScriptName
global function CreateLoudspeakerEnt
global function GiveTimeshiftAbility
global function SetFlagWhenBreakablesDestroyed
global function DestroyIfValid
global function GetEntityTimelinePosition
global function SleepingSpectreFX
global function CleanupAI
global function CleanupEnts
global function CreateBestLoudspeakerEnt
global function GiveLowAmmo
//global function DeleteWaponsWithScriptname
global function QuickSkit
global function KillMyInterdimensionalBrother
global function RingsThink
global function SetLectureHallLineDuration



global struct EntityLevelStruct
{
	bool npcMarkedForCleanup
}

struct
{
	array< entity > flagSetEntities
	array< entity > spectreDoorPanels
	array< entity > spectreDoorTriggers,
	array< entity > spawnProps
	array< entity > spectreSpawnDoors
	array< entity > loudspeakerEnts
	vector currentObjectivePos
	vector lastGoodTimeshiftPosOvergrown
	vector lastGoodTimeshiftPosPristine
	bool isDisplayingDamageText
	float lectureHallTimeBeforePlayerInterrupts
	array<entity> npcsPresent
	array<entity> npcsPast
	entity currentObjectiveEntity
	entity titanCorpseOrg
	entity stalkerCorpseOrg
	array< entity > titanCorpsePieces
	array< entity > stalkerCorpsePieces
	array<string> deathPoses
	bool isDisplayingTimeshiftHint
	bool loudspeakerThreadRunning
	array< entity > ambientDeletableFlyers
	int[5] boyleAudioLogNumberAssignments = [ 0, 0, 0, 0, 0 ]
	int boyleAudioLogsCollected = 0
	bool debugAudioLogs = false
	array< entity > audioLogModels

} file

//---------------------------
// GLOBALS
//---------------------------
const FLYER_TIMESHIFT_HEALTH = 500
const TIME_ZOFFSET_TOEXPLOSION_FROM_PRISTINE = -22144
const TIME_ZOFFSET_TOEXPLOSION_FROM_OVERGROWN = -10624
const TIMEZONE_DAY = 0
const TIMEZONE_NIGHT = 1
const TIMEZONE_ALL = 2
const TIMEZONE_FROZEN = 3

const BREAKABLE_TYPE_SATCHEL_DEBRIS_MEDIUM = 0
const BREAKABLE_TYPE_SATCHEL_DEBRIS_MEDIUM_WIDE = 1
const BREAKABLE_TYPE_AQUARIUM = 2

const DIST_TO_NOT_CARE_ABOUT_AUDIOLOGS = 1500
const MODEL_CIV01 = $"models/Humans/civilian/civilian_sci_v1.mdl"
const MODEL_CIV02 = $"models/Humans/civilian/civilian_sci_v2.mdl"
const MODEL_CIV03 = $"models/Humans/civilian/civilian_sci_v3.mdl"
const MODEL_CIV04 = $"models/Humans/civilian/civilian_sci_v4.mdl"
const MODEL_BUTTON = $"models/props/global_access_panel_button/global_access_panel_button_wall.mdl"
const MODEL_BUTTON_LARGE = $"models/props/global_access_panel_button/global_access_panel_button_console.mdl"
const IMC_CORPSE_MODEL_LMG = $"models/Humans/grunts/imc_grunt_lmg_corpse.mdl"
const IMC_CORPSE_MODEL_RIFLE = $"models/Humans/grunts/imc_grunt_rifle_corpse.mdl"
const IMC_CORPSE_MODEL_SHOTGUN = $"models/Humans/grunts/imc_grunt_shotgun_corpse.mdl"
const IMC_CORPSE_MODEL_SMG = $"models/Humans/grunts/imc_grunt_smg_corpse.mdl"
const IMC_CORPSE_MODEL_HEAVY = $"models/Humans/grunts/imc_grunt_lmg_corpse.mdl"
const HOLOGRAM_KNIFE_MODEL = $"models/weapons/combat_knife/w_combat_knife.mdl"
const ANDERSON_HOLOGRAM_MODEL = $"models/humans/heroes/mlt_hero_anderson.mdl"
const ANDERSON_MODEL = $"models/humans/heroes/mlt_hero_anderson.mdl"
const SARAH_HOLOGRAM_MODEL = $"models/humans/heroes/mlt_hero_jack.mdl"
const ENEMY_HOLOGRAM_MODEL = $"models/humans/grunts/imc_grunt_rifle.mdl"
const ANDERSON_PISTOL_MODEL = $"models/Weapons/b3wing/b3_wingman_ab_01.mdl"
const HOLOGRAM_ENEMY_GUN_MODEL = $"models/Weapons/b3wing/b3_wingman_ab_01.mdl"
const MODEL_IPAD = $"models/props/tablet/tablet.mdl"
const MODEL_COFFEE = $"models/domestic/mug_coffee_white.mdl"
const MARVIN_MODEL_OVERGROWN = $"models/robots/marvin/marvin_mossy.mdl"

//---------------------------
// FX
//---------------------------
const FX_DLIGHT_LIGHT_FLICKER	= $"interior_Dlight_blue_MED"
const FX_TIMESHIFT_ENTITY_MARKER = $"P_ts_entity"
const FX_GREEN_BLINKIE = $"runway_light_green"
const FX_FIRE_HYDRAULIC = $"P_fire_small_FULL"
const FX_DOOR_SCANNER = $"scan_laser_beam_mdl" //scan_laser_beam_mdl_sm
const FX_TIME_PORTAL = $"P_ts_portal"
const FX_BREAKABLE_SATCHEL_DEBRIS_MEDIUM = $"xo_exp_death"
const FX_BREAKABLE_SATCHEL_DEBRIS_MEDIUM_WIDE = $"xo_exp_death"
const FX_FIRE_MEDIUM = $"P_fire_rooftop"
const FX_FIRE_SMALL = $"P_fire_rooftop"
const FX_FIRE_HUGE = $"P_fire_512"
const FX_ELECTRICITY = $"P_elec_arc_LG_1"
//const FX_SPARKS = $"P_sparks_omni_SM_cheap" //this effect stopped working a few weeks ago and no one knows why
const FX_SPARKS = $"xo_sparks_large_trail_cheap"
const FX_LASER = $"P_security_laser"
const FX_RADIATION = $"env_ground_smoke_1024"
const FX_GENERATOR_LOOP_ACTIVE = $"P_drone_cloak_beam"
const FX_GENERATOR_LOOP_DORMANT = $"P_elec_arc_LG_1"
const FX_IMPACT_TABLE_TIMESHIFT = "timeshift_impact"
const FX_HOLOGRAM_FLASH_EFFECT = $"P_ar_holopilot_flash"
const FX_HOLOGRAM_HEX_EFFECT = $"P_ar_holopilot_hextrail"
const FX_HOLO_SCAN_ENVIRONMENT = $"P_ar_holopulse_CP"




//---------------------------
// SOUND
//---------------------------
const SOUND_HOLOGRAM_FLICKER = "Timeshift_Scr_AndersonHolo_FlickerIn"
const SOUND_HYDRAULIC_EXPLOSION = "Goblin_Dropship_Explode"
const SOUND_SCANNER_SPECTRE_DOOR = "SpectreDoorScanner" //LaserScanner.ScanSound_3P"
const SOUND_SCANNER_SPECTRE_DOOR_UNLOCK = "SpectreDoorUnlock"
const SOUND_SCANNER_SPECTRE_DOOR_FAIL = "SpectreDoorFail"
const SOUND_TIME_PORTAL_LOOP = "Time_Vortex_Loop"
const SOUND_BREAKABLE_SATCHEL_DEBRIS_MEDIUM = "Goblin_Dropship_Explode"
const SOUND_BREAKABLE_SATCHEL_DEBRIS_MEDIUM_WIDE = "Goblin_Dropship_Explode"
const SOUND_ELECTRICITY = "electricity_loop"
const SOUND_FIRE_MEDIUM = "amb_colony_fire_medium"
const SOUND_FIRE_HUGE = "amb_colony_fire_medium"
const SOUND_SPARKS = "Timeshift_Emit_Sparks" //
const SOUND_LASER_LOOP = "Timeshift_LaserMesh_Loop"
const SOUND_LASER_DAMAGE = "Timeshift_LaserMesh_Damage"
const SOUND_FAN_DAMAGE = "flesh_fanblade_damage_1p"
const SOUND_LIGHT_FLICKER = "marvin_weld_short"

//---------------------------
// STRINGS
//---------------------------
const HINT_STRING_SPECTRE_REQUIRED = "Security Personnel Required"
const HINT_STRING_SATCHEL_REQUIRED = "Satchel Charge Required"

//----------------------------
// MODELS
//-----------------------------
const POV_MODEL_TIMESHIFT = $"models/weapons/arms/pov_mlt_hero_jack_ts.mdl"



/////////////////////////////////////////////////////////////////////////////////////////
void function SPTimeshiftUtilityInit()
{
	FlyersShared_Init()
	Temp_InitTimeshiftDialogue()

	Riff_ForceSetSpawnAsTitan( eSpawnAsTitan.Never )
	Riff_ForceTitanAvailability( eTitanAvailability.Never )
	AddCallback_EntitiesDidLoad( EntitiesDidLoad )
	AddCallback_OnPlayerRespawned( PlayerSpawned )
	AddDamageCallback( "player", OnPlayerDamage_TimeShift )


	PrecacheModel( MODEL_CIV01 )
	PrecacheModel( MODEL_CIV02 )
	PrecacheModel( MODEL_CIV03 )
	PrecacheModel( MODEL_CIV04 )
	PrecacheModel( MODEL_BUTTON )
	PrecacheModel( MODEL_BUTTON_LARGE )
	PrecacheModel( MODEL_IPAD )
	PrecacheModel( MODEL_COFFEE )
	PrecacheModel( POV_MODEL_TIMESHIFT )
	PrecacheModel( SARAH_HOLOGRAM_MODEL )
	PrecacheModel( ANDERSON_HOLOGRAM_MODEL )
	PrecacheModel( ENEMY_HOLOGRAM_MODEL )
	PrecacheModel( ANDERSON_PISTOL_MODEL )
	PrecacheModel( HOLOGRAM_ENEMY_GUN_MODEL )
	PrecacheModel( IMC_CORPSE_MODEL_LMG )
	PrecacheModel( IMC_CORPSE_MODEL_RIFLE )
	PrecacheModel( IMC_CORPSE_MODEL_SHOTGUN )
	PrecacheModel( IMC_CORPSE_MODEL_SMG )
	PrecacheModel( IMC_CORPSE_MODEL_HEAVY )
	PrecacheModel( HOLOGRAM_KNIFE_MODEL )
	PrecacheModel( ANDERSON_MODEL )
	PrecacheModel( MARVIN_MODEL_OVERGROWN )


	PrecacheImpactEffectTable( FX_IMPACT_TABLE_TIMESHIFT )

	PrecacheParticleSystem( FX_HOLOGRAM_FLASH_EFFECT )
	PrecacheParticleSystem( FX_HOLOGRAM_HEX_EFFECT )
	PrecacheParticleSystem( FX_HOLO_SCAN_ENVIRONMENT )
	PrecacheParticleSystem( FX_DLIGHT_LIGHT_FLICKER )
	PrecacheParticleSystem( FX_FIRE_HYDRAULIC )
	PrecacheParticleSystem( FX_DOOR_SCANNER )
	PrecacheParticleSystem( FX_TIME_PORTAL )
	PrecacheParticleSystem( FX_BREAKABLE_SATCHEL_DEBRIS_MEDIUM )
	PrecacheParticleSystem( FX_BREAKABLE_SATCHEL_DEBRIS_MEDIUM_WIDE )
	PrecacheParticleSystem( FX_RADIATION )
	PrecacheParticleSystem( FX_FIRE_MEDIUM )
	PrecacheParticleSystem( FX_FIRE_SMALL )
	PrecacheParticleSystem( FX_ELECTRICITY )
	PrecacheParticleSystem( FX_SPARKS )
	PrecacheParticleSystem( FX_LASER )
	PrecacheParticleSystem( FX_TIMESHIFT_ENTITY_MARKER )
	PrecacheParticleSystem( FX_GENERATOR_LOOP_ACTIVE )
	PrecacheParticleSystem( FX_GENERATOR_LOOP_DORMANT )
	PrecacheParticleSystem( FX_GREEN_BLINKIE )

	//spawn callbacks
	AddSpectreRackCallback( RackSpawnCallback )
	AddSpawnCallback( "info_target", OnSpawnedInfoTarget )
	AddSpawnCallback( "func_brush", OnSpawnedFuncBrush )
	AddSpawnCallback( "trigger_multiple", OnSpawnedTrigger)
	AddSpawnCallback( "trigger_once", OnSpawnedTrigger )
	AddSpawnCallbackEditorClass( "trigger_multiple", "trigger_quickdeath", OnSpawnedTriggerQuickdeath )



	AddSpawnCallback( "npc_turret_sentry", OnSpawnedNPC )
	AddSpawnCallback( "npc_drone", OnSpawnedNPC )
	AddSpawnCallback( "npc_soldier", OnSpawnedNPC )
	AddSpawnCallback( "npc_titan", OnSpawnedNPC )
	AddSpawnCallback( "npc_spectre", OnSpawnedNPC )
	AddSpawnCallback( "npc_stalker", OnSpawnedNPC )
	AddSpawnCallback( "npc_stalker_zombie", OnSpawnedNPC )
	AddSpawnCallback( "npc_stalker_zombie_mossy", OnSpawnedNPC )
	AddSpawnCallback( "npc_stalker_crawling_mossy", OnSpawnedNPC )
	AddSpawnCallback( "npc_prowler", OnSpawnedNPC )
	AddSpawnCallback( "npc_marvin", OnSpawnedNPC )
	AddSpawnCallback( "npc_frag_drone", OnSpawnedNPC )
	AddSpawnCallback( "npc_super_spectre", OnSpawnedNPC )
	//AddSpawnCallback( "env_fog_controller", OnSpawnedFogController )
	AddSpawnCallback( "info_spawnpoint_marvin", OnSpawnedMarvinSpawner )
	AddSpawnCallback( "prop_dynamic", OnSpawnedPropDynamic )
	AddSpawnCallback( "prop_dynamic_lightweight", OnSpawnedPropDynamic )
	AddSpawnCallbackEditorClass( "prop_dynamic", "script_switch", OnSpawnedScriptedSwitch )
	//AddSpawnCallbackEditorClass( "script_ref", "script_pickup_weapon", WeaponPickupHack )


	//death callbacks
	//AddDeathCallback( "player", TS_PlayerDeath )
	AddDeathCallback( "npc_soldier", TS_OnDeathNPC )
	AddDeathCallback( "npc_spectre", TS_OnDeathNPC )
	AddDeathCallback( "npc_prowler", TS_OnDeathNPC )
	AddDeathCallback( "npc_titan", TS_OnDeathNPC )
	AddDeathCallback( "npc_stalker", TS_OnDeathNPC )
	AddDeathCallback( "npc_marvin", TS_OnDeathNPC )

	AddCallback_OnTimeShiftAbilityUsed( OnTimeShiftAbilityUsed )
	AddCallback_OnTimeShiftTitanAbilityUsed( OnTimeShiftAbilityUsed )
	AddCallback_OnSatchelPlanted( OnSatchelPlanted )

	AddDamageCallback( "func_brush", OnDamagedFuncBrush )

	FlagInit( "AudioLogPlaying" )
	FlagInit( "ShouldPlayGlobalLoudspeker" )
	FlagInit( "ForceFlyerTakeoff" )
	FlagInit( "AndersonHologram1Playing" )
	FlagInit( "AndersonHologram2Playing" )
	FlagInit( "AndersonHologram3Playing" )
	FlagInit( "PlayerInterruptedLecture" )
	FlagInit( "AndersonHologram1Finished" )
	FlagInit( "AndersonHologram2Finished" )
	FlagInit( "AndersonHologram3Finished" )
	FlagInit( "DisplayTheDamageHint" )
	FlagInit( "RingsShouldBeSpinning" )
	FlagSet( "DisableDropships" )
    FlagInit( "PlayerHasTimeTraveledInsideBT" )
    FlagInit( "DoingCinematicTimeshift" )
    FlagInit( "TurretsNearBunkerFenceActivated" )
    FlagInit( "PlayerObtainedC4" )
    FlagInit( "PlayerHasBioCreds")
    FlagInit( "AtLeastOneBunkerTurretRestored" )
    FlagInit( "bunker_battery_teleport" )
	RegisterSignal( "BreakableDestroyed" )
	RegisterSignal( "PropSpawnerActivate" )
	RegisterSignal( "Frozen" )
	RegisterSignal( "UnFrozen" )
	RegisterSignal( "DisplayingSatchelHint" )
	RegisterSignal( "DisplayingDamageHint" )
	RegisterSignal( "PauseLasermesh" )
	RegisterSignal( "AndersonTimeshifts" )
	RegisterSignal( "AndersonEnemyShow" )
	RegisterSignal( "AndersonHideGun" )
	RegisterSignal( "AndersonEnemyShowKnife" )
	RegisterSignal( "FlyerTakeoffOverride" )
	RegisterSignal( "StopCoreEffects" )
	RegisterSignal( "AudioLogDebugDraw" )
	RegisterSignal( "StopAudioLog" )



	file.isDisplayingDamageText = false
	file.isDisplayingTimeshiftHint = false

	level.allowTimeTravel <- false
	//level.isTimeTraveling <- false
	level.timeZone <- TIMEZONE_NIGHT
	level.fogController <- null
	//level.playerSpawn <- null

	SetTimeshiftTimeOfDay_Night()

	if ( file.debugAudioLogs )
		thread AudioLogDebug()
}


/////////////////////////////////////////////////////////////////////////////////////////
void function AudioLogDebug()
{
	while ( true )
	{
		wait 1

		printl( "*******************************************************" )
		printt( "boyleAudioLogsCollected: ", file.boyleAudioLogsCollected )
		printt( "boyleAudioLogNumberAssignments:" )
		for ( int i = 0 ; i < file.boyleAudioLogNumberAssignments.len(); i++ )
		{
			printt( i, " = ", file.boyleAudioLogNumberAssignments[ i ] )
		}

	}

}
/////////////////////////////////////////////////////////////////////////////////////////
void function EntitiesDidLoad()
{

	array <entity> flyerSpawners = GetEntArrayByScriptName( "flyer_ambient" )
	array <entity> ambientFlyers
	entity flyer
	foreach( spawner in flyerSpawners )
	{
		flyer = CreatePerchedFlyer( spawner.GetOrigin(), spawner.GetAngles() )
		//flyer.s.health = FLYER_TIMESHIFT_HEALTH
		if ( spawner.HasKey( "script_noteworthy") )
		{
			file.ambientDeletableFlyers.append( flyer )
		}
		ambientFlyers.append( flyer )

		spawner.Destroy()
		thread FlyerAmbientThink( flyer )
	}



	array <entity> spawners = GetSpawnerArrayByClassName( "npc_prowler" )
	spawners.extend( GetSpawnerArrayByClassName( "npc_stalker" ) )
	spawners.extend( GetSpawnerArrayByClassName( "npc_stalker_zombie" ) )
	spawners.extend( GetSpawnerArrayByClassName( "npc_stalker_zombie_mossy" ) )
	spawners.extend( GetSpawnerArrayByClassName( "npc_stalker_crawling_mossy" ) )
	spawners.extend( GetSpawnerArrayByClassName( "npc_marvin" ) )
	Assert( spawners.len() > 0 )
	foreach( spawner in spawners )
	{
		if ( IsSpawner( spawner ) )
			spawner.kv.spawnflags = SF_NPC_ALLOW_SPAWN_SOLID //setting this for all spawners because the error is retarded
	}

	thread PlayerIndorsStatus()

	entity titanCorpseOrg = GetEntByScriptName( "titan_gibs_org" )
	entity stalkerCorpseOrg = GetEntByScriptName( "stalker_gibs_org" )
	Assert( IsValid( titanCorpseOrg ) )
	Assert( IsValid( stalkerCorpseOrg ) )
	thread CorpseSetup( titanCorpseOrg )
	thread CorpseSetup( stalkerCorpseOrg )

	array <string> deathPosesLocal

	deathPosesLocal.append( "pt_timeshift_deathpose_back_01" )
	deathPosesLocal.append( "pt_timeshift_deathpose_back_02" )
	deathPosesLocal.append( "pt_timeshift_deathpose_back_03" )
	deathPosesLocal.append( "pt_timeshift_deathpose_front_01" )
	file.deathPoses = deathPosesLocal

}
/////////////////////////////////////////////////////////////////////////////////////////
void function DeleteUnnecessaryFlyers()
{
	wait 1
	foreach( flyer in file.ambientDeletableFlyers )
	{
		if ( IsValid( flyer ) )
			flyer.Destroy()
	}

}
/////////////////////////////////////////////////////////////////////////////////////////
void function CorpseSetup( entity corpseOrg )
{
	array< entity > linkedEnts = corpseOrg.GetLinkEntArray()
	Assert( linkedEnts.len() > 0 )
	string scriptName = corpseOrg.GetScriptName()

	foreach( entity ent in linkedEnts )
	{
		ent.SetParent( corpseOrg )
		ent.Hide()
		ent.NotSolid()

		if ( scriptName == "titan_gibs_org" )
			file.titanCorpsePieces.append( ent )
		if ( scriptName == "stalker_gibs_org" )
			file.stalkerCorpsePieces.append( ent )
	}

	if ( scriptName == "titan_gibs_org" )
		file.titanCorpseOrg = corpseOrg
	else if ( scriptName == "stalker_gibs_org" )
		file.stalkerCorpseOrg = corpseOrg
	else
		Assert( 0, "Unhandled script_name: " + scriptName )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function TimeshiftSetObjectiveSilent( entity player, string objectiveString, vector objectivePos = < 0, 0, 0 >, entity objectiveEntity = null, silent = false )
{
	TimeshiftSetObjective( player, objectiveString, objectivePos, objectiveEntity, true )
}

void function TimeshiftSetObjective( entity player, string objectiveString, vector objectivePos = < 0, 0, 0 >, entity objectiveEntity = null, silent = false )
{
	if ( objectiveEntity == null )
	{
		SetCurrentObjectivePos( objectivePos )
		if ( silent )
			Objective_SetSilent( objectiveString, objectivePos )
		else
			Objective_Set( objectiveString, objectivePos )
		file.currentObjectiveEntity = null
	}
	else
	{
		if ( silent )
			Objective_SetSilent( objectiveString, < 0, 0, 0 >, objectiveEntity )
		else
			Objective_Set( objectiveString, < 0, 0, 0 >, objectiveEntity )
		file.currentObjectiveEntity = objectiveEntity
	}

	ObjectiveCompensate( player, objectiveEntity )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function TimeshiftUpdateObjective( entity player, vector objectivePos, entity objectiveEntity = null )
{
	if ( objectiveEntity == null )
	{
		SetCurrentObjectivePos( objectivePos )
		Objective_Update( objectivePos )
		file.currentObjectiveEntity = null
	}
	else
	{
		Objective_Update( < 0, 0, 0 >, objectiveEntity )
		file.currentObjectiveEntity = objectiveEntity
	}

	ObjectiveCompensate( player, objectiveEntity )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function SetCurrentObjectivePos( vector pos )
{
	Assert( pos.z != 0 )
	file.currentObjectivePos = pos
}
/////////////////////////////////////////////////////////////////////////////////////////
void function ObjectiveCompensate( entity player, entity objectiveEntity = null )
{
	vector newPos

	if ( !IsValid( objectiveEntity ) )
	{
		if ( GetTimelinePosition( file.currentObjectivePos ) == level.timeZone )
			newPos = file.currentObjectivePos
		else
			newPos = GetPosInOtherTimeline( file.currentObjectivePos )

		Objective_Update( newPos )
	}
	else
	{
		if ( GetEntityTimelinePosition( objectiveEntity ) == level.timeZone )
			Objective_Update( < 0, 0, 0 >, objectiveEntity )
		else
			Objective_Update( GetPosInOtherTimeline( objectiveEntity.GetOrigin() ) )
	}
}
/////////////////////////////////////////////////////////////////////////////////////////
vector function GetPosInOtherTimeline( vector pos )
{
	int zOffset
	if ( GetTimelinePosition( pos ) == TIMEZONE_NIGHT )
		zOffset = TIME_ZOFFSET
	else
		zOffset = TIME_ZOFFSET * -1

	return Vector( pos.x, pos.y, pos.z + ( zOffset ) )

}
/////////////////////////////////////////////////////////////////////////////////////////
/*
function DamagedBreakableHydraulic( func_brush, damageInfo )
{
	int damageSourceID = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	local damageAmount = DamageInfo_GetDamage( damageInfo )
	local entName = func_brush.GetTargetName()

	if ( damageSourceID != eDamageSourceId.mp_weapon_satchel )
	{
		Dev_PrintMessage( attacker, "#BLANK_TEXT", "#HINT_STRING_SATCHEL_REQUIRED", 3.0 )
		return
	}

	Signal( func_brush, "BreakableDestroyed" )
}
*/
/////////////////////////////////////////////////////////////////////////////////////////
void function PlayerSpawned( entity player )
{
	//Need to decide whether we are in past/present based on level.struct
	Remote_CallFunction_NonReplay( player, "ServerCallback_TimeFlipped", TIMEZONE_NIGHT )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function GiveTimeshiftAbility( entity __player )
{
	//give it to everyone, not just the player
	foreach( entity player in GetPlayerArray() )
	{
		player.SetPlayerSettings( "pilot_solo_timeshift" )
		if ( IsValid( player.GetOffhandWeapon( OFFHAND_SPECIAL ) ) )
			player.TakeOffhandWeapon( OFFHAND_SPECIAL )
		player.GiveOffhandWeapon( "mp_ability_timeshift", 1 )
	
		entity viewModel = player.GetFirstPersonProxy()
		viewModel.SetSkin( 1 )
		Remote_CallFunction_NonReplay( player, "ServerCallback_TimeDeviceAcquired" )
	}
	level.allowTimeTravel = true
}

/////////////////////////////////////////////////////////////////////////////////////////
void function DataStab( entity player, entity ref )
{
	vector playerStartPos = player.GetOrigin()
	vector playerStartAng = player.GetAngles()

	vector origin = ref.GetOrigin()
	vector angles = ref.GetAngles()


	ref.SetAngles( ref.GetAngles() + Vector( 0, 0, 18 ) )

	FirstPersonSequenceStruct sequenceStart
	sequenceStart.blendTime = 1.0
	sequenceStart.attachment = "ref"
	sequenceStart.firstPersonAnim = "ptpov_data_core_leech_start"
	sequenceStart.thirdPersonAnim = "pt_core_console_leech_start"
	sequenceStart.viewConeFunction = ViewConeZero

	FirstPersonSequenceStruct sequenceMid
	sequenceMid.blendTime = 0.0
	sequenceMid.attachment = "ref"
	sequenceMid.firstPersonAnim = "ptpov_data_knife_console_leech_idle"
	sequenceMid.thirdPersonAnim = "pt_data_knife_console_leech_idle"
	sequenceMid.viewConeFunction = ViewConeTight


	FirstPersonSequenceStruct sequenceEnd
	sequenceEnd.blendTime = 0.0
	sequenceEnd.attachment = "ref"
	sequenceEnd.firstPersonAnim = "ptpov_core_scan_end"
	sequenceEnd.thirdPersonAnim = "pt_core_scan_end"
	sequenceEnd.viewConeFunction = ViewConeTight

	player.DisableWeaponWithSlowHolster()
	player.ContextAction_SetBusy()
	//player.FreezeControlsOnServer()

	//thread GiveDataknifeForDuration( player, 5 )

	//entity fpProxy = player.GetFirstPersonProxy()
	//int attachID = fpProxy.LookupAttachment( "KNIFE" )
	//entity weaponModel = CreatePropDynamic( DATA_KNIFE_MODEL )
	//weaponModel.SetParent( player.GetFirstPersonProxy(), "PROPGUN", false, 0.0 )


	entity viewModel = player.GetFirstPersonProxy()
	viewModel.Hide()
	Remote_CallFunction_NonReplay( player, "ServerCallback_StopGloveGlow" )

	thread CoreHudHighlight( player )


	//delaythread ( 1 ) KnifePopOut( weaponModel )
	waitthread FirstPersonSequence( sequenceStart, player, ref )


	//EmitSoundOnEntity( player, "dataknife_loopable_beep" )


	FlagEnd( "PlayerAtLevelEnd" )

	OnThreadEnd(
		function() : ( player, viewModel )
		{
			if ( !IsValid( player ) )
				return
			player.Anim_Stop()
			player.ClearParent()
			ClearPlayerAnimViewEntity( player )
			if ( player.ContextAction_IsBusy() )
				player.ContextAction_ClearBusy()
			player.EnableWeapon()

			if ( IsValid( viewModel ) )
				viewModel.Show()
		}
	)

	thread FirstPersonSequence( sequenceMid, player, ref )
	wait 0.5
	//EmitSoundOnEntity( player, "Player.Hitbeep_headshot.Kill.Human_3P_vs_1P" )
	wait 0.5
	//EmitSoundOnEntity( player, "dataknife_ring1" )
	wait 1
	//EmitSoundOnEntity( player, "dataknife_ring2" )
	wait 1
	//EmitSoundOnEntity( player, "dataknife_ring1" )
	wait 15.5
	//EmitSoundOnEntity( player, "dataknife_complete" )
	//EmitSoundOnEntity( player, "Player.Hitbeep_headshot.Kill.Human_3P_vs_1P" )
	waitthread FirstPersonSequence( sequenceEnd, player, ref )

	//StopSoundOnEntity( player, "dataknife_loopable_beep"  )




}

//////////////////////////////////////////////////////////////////////
void function CoreHudHighlight( entity player )
{
	entity core_dummy = GetEntByScriptName( "core_dummy" )

	//core_dummy.Show()
	//SetTeam( core_dummy, TEAM_IMC )
	//core_dummy.Highlight_ShowInside( 1.0 )
	//core_dummy.Highlight_ShowOutline( 1.0 )
	//Highlight_SetEnemyHighlight( core_dummy, "enemy_sonar" )





}
//////////////////////////////////////////////////////////////////////
function KnifePopOut( entity knife )
{
	knife.Anim_Play( "data_knife_console_leech_start" )
}


/////////////////////////////////////////////////////////////////////////////////////////
function GiveDataknifeForDuration( entity player, float time )
{

	entity fpProxy = player.GetFirstPersonProxy()
	int attachID = fpProxy.LookupAttachment( "KNIFE" )
	entity weaponModel = CreatePropDynamic( DATA_KNIFE_MODEL, fpProxy.GetAttachmentOrigin( attachID ), fpProxy.GetAttachmentAngles( attachID ) )
	weaponModel.SetParent( player.GetFirstPersonProxy(), "KNIFE", false, 0.0 )

	OnThreadEnd(
		function() : ( weaponModel )
		{
			if ( IsValid( weaponModel ) )
				weaponModel.Destroy()
		}
	)

	player.EndSignal( "OnDeath" )

	wait time
}


/////////////////////////////////////////////////////////////////////////////////////////
void function OnSpawnedInfoTarget( entity info_target )
{
	string entName = info_target.GetTargetName()
	string scriptName = info_target.GetScriptName()

	if ( scriptName == "loudspeaker_ent" )
	{
		file.loudspeakerEnts.append( info_target )
		info_target.kv.spawnflags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT
	}

	if ( ( entName.find( "flagSetEntity" ) != null ) || ( entName.find( "FlagSetEntity" ) != null ) )
	{
		file.flagSetEntities.append( info_target )
		string flagToSet = info_target.GetScriptName()
		FlagInit( flagToSet )
	}

	//breakables
	/*
	if ( entName.find( "breakable" ) != null )
		thread BreakableSetup( info_target )
	*/

	//generic sparks
	if ( scriptName == "sparks" )
		thread GenericSparks( info_target )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function OnSpawnedFuncBrush( entity func_brush )
{




}

/*
/////////////////////////////////////////////////////////////////////////////////////////
void function TempDoorThink( entity info_target )
{
	entity doorController = info_target
	vector origin = doorController.GetOrigin()
	array< entity > linkedEnts = info_target.GetLinkEntArray()
	Assert( linkedEnts.len() > 0, "Door controller at " + info_target.GetOrigin() + " has no linked ents" )
	string classname
	array< entity > doors
	foreach( entity ent in linkedEnts )
	{
		classname = ent.GetClassName()
		if ( classname == "func_brush" )
			doors.append( ent )
	}
	Assert( doors.len() > 0 )

	string entName

	foreach( door in doors )
	{
		linkedEnts = door.GetLinkEntArray()
		foreach( ent in linkedEnts )
		{
			entName = ent.GetTargetName()
			if ( entName.find( "start" ) != null )
				door.s.startEnt <- ent
			if ( entName.find( "end" ) != null )
				door.s.endEnt <- ent
		}
		Assert( IsValid( door.s.startEnt ) )
		Assert( IsValid( door.s.endEnt ) )

		entity mover = TSCreateScriptMoverLight( expect entity( door.s.startEnt ), door.s.startEnt.GetOrigin(), door.s.startEnt.GetAngles() )
		door.s.mover <- mover
		door.SetParent( mover )
		door.s.openPos <- door.s.endEnt.GetOrigin()
	}

	wait 1

	entity flagEnt = GetClosest( file.flagSetEntities, doorController.GetOrigin() )
	Assert( IsValid( flagEnt ) )
	Assert( Distance( flagEnt.GetOrigin(), doorController.GetOrigin() ) < 50, "No flag entity within 50 units of doorController at " + doorController.GetOrigin() )
	string flagToWaitFor = flagEnt.GetScriptName()

	FlagWait( flagToWaitFor )

	EmitSoundAtPosition( TEAM_UNASSIGNED, origin, "door_stop" )
	EmitSoundOnEntity( doors[ 0 ], "door_open_loop" )
	foreach( door in doors )
		door.s.mover.NonPhysicsMoveTo( door.s.openPos, 2, 0.0, 0.0 )

	wait 2

	StopSoundOnEntity( doors[ 0 ], "door_open_loop" )
	EmitSoundAtPosition( TEAM_UNASSIGNED, origin, "door_stop" )

}
*/
/////////////////////////////////////////////////////////////////////////////////////////

/*
void function OnSpawnedFogController( entity fogController )
{
	if ( GetBugReproNum() != 007 )
	{
		fogController.Destroy()
		return
	}

	level.fogController = fogController
	ChangeFog( TIMEZONE_NIGHT )
}
*/


/////////////////////////////////////////////////////////////////////////////////////////
void function OnSpawnedPropDynamic( entity propDynamic )
{
	int contextId = 0
	string entName = propDynamic.GetTargetName()
	string scriptName = propDynamic.GetScriptName()

	if ( scriptName == "button_overgrown_large" )
		thread ButtonOvergrownThink( propDynamic, "large" )

	if ( scriptName == "button_overgrown" )
		thread ButtonOvergrownThink( propDynamic, "small" )

	if ( scriptName == "spectre_door_spawner" )
		thread SpectreDoorSpawnerThink( propDynamic )

	if ( scriptName == "door_out_of_order" )
		thread DoorOutOfOrderThink( propDynamic )


	if ( scriptName == "light_flicker" )
		thread LightFlickerThink( propDynamic )

	//----------------------------------------------------
	// Objective highlighting needs to be done onSpawn
	//----------------------------------------------------
	if 	(
			( scriptName.find( "helmet_dogtag" ) != null ) ||
			( scriptName.find( "core_dummy" ) != null ) ||
			( scriptName.find( "anderson_first_half" ) != null )

		)
	{
		Highlight_ClearEnemyHighlight( propDynamic )
		propDynamic.Highlight_SetFunctions( contextId, 0, true, HIGHLIGHT_OUTLINE_INTERACT_BUTTON, 1, 0, false )
		propDynamic.Highlight_SetParam( contextId, 0, HIGHLIGHT_COLOR_INTERACT )
		propDynamic.Highlight_SetCurrentContext( contextId )
		propDynamic.Highlight_ShowInside( 0 )
		propDynamic.Highlight_ShowOutline( 0 )

		Objective_InitEntity( propDynamic )
	}

	if ( scriptName == "audio_log_model" )
	{
		propDynamic.Highlight_SetFunctions( contextId, 0, true, HIGHLIGHT_OUTLINE_INTERACT_BUTTON, 1, 0, false )
		propDynamic.Highlight_SetParam( contextId, 0, HIGHLIGHT_COLOR_INTERACT )
		propDynamic.Highlight_SetCurrentContext( contextId )
		propDynamic.Highlight_ShowInside( 0 )
		propDynamic.Highlight_ShowOutline( 0 )
		thread AudioLogModelThink( propDynamic )
	}

	/*
	asset modelName = propDynamic.GetModelName()
	if 	(
			( modelName == SARAH_HOLOGRAM_MODEL ) ||
			( modelName == ANDERSON_HOLOGRAM_MODEL ) ||
			( modelName == ENEMY_HOLOGRAM_MODEL )
		)
		{
			propDynamic.SetSkin( 1 )
		}
	*/

}
/////////////////////////////////////////////////////////////////////////////////////////
void function SpectreDoorSpawnerThink( entity spawnProp )
{
	asset modelName = spawnProp.GetModelName()
	file.spawnProps.append( spawnProp )
	entity spawnerRack
	entity spawnerSpectre
	array< entity > linkedEnts = spawnProp.GetLinkEntArray()
	Assert( linkedEnts.len() > 0 )
	string editorClassname
	string classname

	foreach( entity ent in linkedEnts )
	{
		editorClassname = GetEditorClass( ent )
		classname = ent.GetClassName()

		if ( editorClassname == "npc_spectre_rack_wall" )
			spawnerRack = ent
		if ( classname == "spawner" )
			spawnerSpectre = ent
	}

	Assert( IsValid( spawnerRack ) )
	Assert( IsValid( spawnerSpectre ) )

	entity mover

	vector origin = spawnProp.GetOrigin()
	vector angles = spawnProp.GetAngles()
	vector originOffset
	vector reverseOriginOffset

	string sound
	float doorOpenTime
	float zHeight
	entity ref = CreateEntity( "info_target" )
	ref.SetOrigin( origin )
	ref.SetAngles( angles )
	DispatchSpawn( ref )

	var doorOpenDelayTime
	float spawnDelayTime
	if ( spawnProp.HasKey( "script_delay" ) )
		doorOpenDelayTime = spawnProp.kv.script_delay
	else
		doorOpenDelayTime = 0

	mover = TSCreateScriptMoverLight( ref, origin, angles )
	spawnProp.SetParent( mover )

	switch( modelName )
	{

		case $"models/levels_terrain/sp_timeshift/door_custom_timeshift_lobby_01.mdl":
			file.spectreSpawnDoors.append( spawnProp )
			originOffset = PositionOffsetFromEnt( spawnProp, 0, 2, 0 )
			reverseOriginOffset = PositionOffsetFromEnt( spawnProp, 0, -2, 0 )
			sound = "Timeshift_Scr_StalkerPodOpen"
			doorOpenTime = 0.5
			spawnDelayTime = 0.1
			zHeight = 72
			break
		case $"models/levels_terrain/sp_timeshift/door_custom_timeshift_concourse_01.mdl":
			file.spectreSpawnDoors.append( spawnProp )
			originOffset = PositionOffsetFromEnt( spawnProp, 4, 0, 0 )
			reverseOriginOffset = PositionOffsetFromEnt( spawnProp, -4, 0, 0 )
			sound = "Timeshift_Scr_StalkerPodOpen"
			doorOpenTime = 2
			spawnDelayTime = 0.1
			zHeight = 85
			break
		case $"models/timeshift/timeshift_column_panel_09_destroyed.mdl":
		case $"models/timeshift/timeshift_column_panel_09.mdl":
		case $"models/timeshift/timeshift_column_panel_10_destroyed.mdl":
		case $"models/timeshift/timeshift_column_panel_10.mdl":
			file.spectreSpawnDoors.append( spawnProp )
			originOffset = PositionOffsetFromEnt( spawnProp, 0, 2, 0 )
			reverseOriginOffset = PositionOffsetFromEnt( spawnProp, 0, -2, 0 )
			sound = "Timeshift_Scr_StalkerPodOpen"
			doorOpenTime = 0.5
			spawnDelayTime = 0.1
			zHeight = 88
			break
		default:
			Assert( 0, "Unhandled spectre door type at " + spawnProp.GetOrigin() )
			break
	}

	while( true )
	{
		spawnProp.WaitSignal( "PropSpawnerActivate" )

		wait doorOpenDelayTime

		EmitSoundAtPosition( TEAM_UNASSIGNED, origin, sound )
		mover.NonPhysicsMoveTo( originOffset, 0.5, 0.0, 0.0 )
		wait 0.5
		mover.NonPhysicsMoveTo( spawnProp.GetOrigin() + Vector( 0, 0, zHeight ), doorOpenTime, 0.0, 0.0 )
		delaythread ( spawnDelayTime ) SpawnFromStalkerRack( spawnerRack )

		wait doorOpenTime + 3

		mover.NonPhysicsMoveTo( spawnProp.GetOrigin() + Vector( 0, 0, -zHeight ), doorOpenTime, 0.0, 0.0 )
		//EmitSoundAtPosition( TEAM_UNASSIGNED, origin, sound )
		EmitSoundOnEntity( mover, "Timeshift_Scr_StalkerPodClose" )
		wait doorOpenTime
		mover.NonPhysicsMoveTo( reverseOriginOffset, 0.5, 0.0, 0.0 )

	}

}


/////////////////////////////////////////////////////////////////////////////////////////
void function DoorControlPanelSpectreDisable( entity doorSwitch )
{
	doorSwitch.s.enabled = false
	doorSwitch.s.hintTrigger.kv.enabled = 0
}

/////////////////////////////////////////////////////////////////////////////////////////
void function DoorControlPanelSpectreEnable( entity doorSwitch )
{
	doorSwitch.s.enabled = true
	doorSwitch.s.hintTrigger.kv.enabled = 1
}

/////////////////////////////////////////////////////////////////////////////////////////
bool function IsDoorHacking( playerSpectre )
{
	if ( !( "doorHacking" in playerSpectre.s ) )
		return false
	if ( playerSpectre.s.doorHacking )
		return true
	return false
}

/////////////////////////////////////////////////////////////////////////////////////////
/*
void function DoorControlPanelSpectreTryToHack( playerSpectre, entity doorSwitch )
{
	playerSpectre.EndSignal( "OnDeath" )

	if ( !( "doorHacking" in playerSpectre.s ) )
		playerSpectre.s.doorHacking <- null
	playerSpectre.s.doorHacking = true

	//playerSpectre.SetTouchTriggers( false )
	playerSpectre.DisableBehavior( "Follow" )
	playerSpectre.EnableBehavior( "Assault" )
	playerSpectre.EnableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE | NPC_USE_SHOOTING_COVER )

	var animEnt = doorSwitch.s.animEnt
	animEnt.SetAngles( animEnt.GetAngles() + Vector( 0, 0, 0 ) )
	waitthread RunToAndPlayAnim( playerSpectre, "sp_casual_idle", animEnt.GetOrigin(), false, animEnt.GetAngles() )
	thread PlayAnim( playerSpectre, "sp_casual_idle", animEnt.GetOrigin(), animEnt.GetAngles() )

	bool scanSuccess = true
	waitthread DoorControlPanelSpectreScan( doorSwitch, scanSuccess )

	//if we make it this far, unlock the door
	doorSwitch.s.unlocked = true
}

*/


void function OnSpawnedTriggerQuickdeath( entity trigger )
{

	vector triggerOrigin = trigger.GetOrigin()
	var timelinePositionTrigger = GetTimelinePosition( triggerOrigin )
	if ( timelinePositionTrigger == TIMEZONE_FROZEN )
		return

	var timelinePositionPlayer
	trigger.EndSignal( "OnDestroy" )
	vector playerRespawnOrigin
	var timelinePositionRespawnOrg
	entity player
	var result


	while ( IsValid( trigger) )
	{
		player = null
		result = trigger.WaitSignal( "OnTrigger" )

		if ( !IsValid( result.activator ) )
			continue

		if ( !result.activator.IsPlayer() )
			continue

		player = expect entity( result.activator )
		player.WaitSignal( "QuickDeathPlayerTeleported" )

		timelinePositionPlayer = GetEntityTimelinePosition( player )
		playerRespawnOrigin = player.GetOrigin()
		timelinePositionRespawnOrg = GetTimelinePosition( playerRespawnOrigin )


		// player respawn origin matches the timeZone he's supposed to be in
		if ( timelinePositionRespawnOrg == level.timeZone )
			continue

		player.FreezeControlsOnServer()
		if ( ( level.timeZone == TIMEZONE_NIGHT ) && ( timelinePositionRespawnOrg == TIMEZONE_DAY ) )
		{
			player.SetOrigin( playerRespawnOrigin + Vector( 0, 0, TIME_ZOFFSET * -1 ) )
		}
		else
		{
			player.SetOrigin( playerRespawnOrigin + Vector( 0, 0, TIME_ZOFFSET ) )
		}
		player.UnfreezeControlsOnServer()


		/*
		if ( timelinePositionPlayer == timelinePositionTrigger )
			continue


		if ( timelinePositionTrigger == TIMEZONE_DAY )
			player.SetOrigin( playerRespawnOrigin + Vector( 0, 0, TIME_ZOFFSET ) ) //player hit a pristine death trig but respawned in overgrown
		else
			player.SetOrigin( playerRespawnOrigin + Vector( 0, 0, ( TIME_ZOFFSET * -1 ) ) ) //player hit a overgrown death trig but respawned in pristine
		*/
	}



}
/////////////////////////////////////////////////////////////////////////////////////////
void function OnSpawnedTrigger( entity trigger )
{
	local entName = trigger.GetTargetName()
	string scriptName = trigger.GetScriptName()


	//laser mesh
	if ( scriptName == "trig_propspawner" )
		thread TriggerShowcaseSpawnInit( trigger )


	//spectre wall spawner
	//if ( scriptName.find( "trig_spectre_wall_spawner" ) != null )
		//thread TriggerSpectreWallSpawnerThink( trigger )

	//laser mesh
	if ( scriptName == "laser_mesh" )
		thread TriggerPushbackDamageThink( trigger )

	//laser mesh
	if ( scriptName == "spinning_fan" )
		thread TriggerPushbackDamageThink( trigger )

	//Dudes spawning in elevators
	if ( scriptName == "trigger_elevator_npc" )
		thread trigger_elevator_npc_think( trigger )

	/*
	if ( scriptName == "trigger_time_hint" )
		thread TriggerTimehintThink( trigger )
	*/


	//Spectre activated door panel triggers
	if ( scriptName.find( "trigger_spectre_door_control" ) != null )
		file.spectreDoorTriggers.append( trigger )


	//HACK: need to switch over to script_name for these ones


	//Spectre activated door panel triggers
	if ( entName.find( "trigger_spectre_door_control" ) != null )
		file.spectreDoorTriggers.append( trigger )


	//Hazard triggers
	if ( entName.find( "trigger_hazard" ) != null )
		thread TriggerHazardThink( trigger )




}
/////////////////////////////////////////////////////////////////////////////////////////
void function trigger_elevator_npc_think( entity trigger )
{
	trigger.EndSignal( "OnDestroy" )

	vector soundOrigin
	entity door
	entity elevatorLightEntity
	//entity button
	string classname
	string editorClassname

	array< entity > linkedEnts = trigger.GetLinkEntArray()
	Assert( linkedEnts.len() > 0 )
	foreach( entity ent in linkedEnts )
	{
		classname = ent.GetClassName()
		editorClassname = GetEditorClass( ent )

		if ( classname == "info_target" )
		{
			elevatorLightEntity = ent
			continue
		}
		if ( editorClassname == "script_door" )
		{
			door = ent
			continue
		}
		/*if ( editorClassname == "script_switch" )
		{
			button = ent
			continue
		}
		*/
	}
	Assert( IsValid( door ) )
	Assert( IsValid( elevatorLightEntity ) )
	//Assert( IsValid( button ) )

	string flagToOpenDoor = expect string( door.kv.script_flag )
	Assert( flagToOpenDoor != "" )
	soundOrigin = elevatorLightEntity.GetOrigin()
	//elevatorLightEntity.kv.spawnflags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT

	//---------------------------------------
	// Guys spawn inside elevator, bell dings
	//---------------------------------------
	trigger.WaitSignal( "OnTrigger" )

	EmitSoundAtPosition( TEAM_UNASSIGNED, soundOrigin, "Timeshift_ElevatorBell" )
	entity fxHandle = PlayFX( FX_GREEN_BLINKIE, elevatorLightEntity.GetOrigin() )

	OnThreadEnd(
		function() : ( fxHandle )
		{
			if ( !IsValid( fxHandle) )
				return
			fxHandle.Fire( "Stop" )
			fxHandle.Fire( "DestroyImmediately" )
		}
	)

	wait 1.25

	//--------------
	// Door opens
	//--------------
	FlagSet( flagToOpenDoor )

	wait 5
}

/////////////////////////////////////////////////////////////////////////////////////////
void function TriggerPushbackDamageThink( entity trigger )
{
	trigger.EndSignal( "OnDestroy" )
	trigger.EndSignal( "PauseLasermesh" )

	string scriptName = trigger.GetScriptName()

	vector triggerOrigin = trigger.GetOrigin()
	vector soundOrigin = triggerOrigin

	array< entity > linkedEnts = trigger.GetLinkEntArray()
	Assert( linkedEnts.len() > 0, "Laser mesh trigger at " +  trigger.GetOrigin() + " not linked to anything" )
	entity centerEnt
	entity blockerBrush
	foreach( entity ent in linkedEnts )
	{
		if ( ent.GetClassName() == "info_target" )
			centerEnt = ent
		if ( ent.GetClassName() == "func_brush" )
			blockerBrush = ent
	}

	Assert( IsValid( centerEnt ) )
	Assert( IsValid( blockerBrush ), "trigger at " + trigger.GetOrigin() + " does not link to a valid blockerbrush" )

	//In case this was deactivated and we are re-activating it now
	blockerBrush.Solid()


	vector centerEntOrigin = centerEnt.GetOrigin()


	//DebugDrawLine( topCorner, topCornerConnect, 255, 255, 0, true, 60.0 )
	//DebugDrawSphere( topCorner, 10.0, 255, 200, 0, true, 60.0 )
	//DebugDrawSphere( topCornerConnect, 10.0, 0, 255, 0, true, 60.0 )
	//DebugDrawSphere( botCorner, 10.0, 255, 200, 0, true, 60.0 )
	//DebugDrawBox( triggerOrigin, triggerMins, triggerMaxs, 255, 255, 0, 1, 60.0 )

	string soundLoop
	string soundDeactivate
	string soundDamage

	int damageID

	switch ( scriptName )
	{
		case "laser_mesh":
			//soundLoop = SOUND_LASER_LOOP  //doing this on the client
			soundDamage = SOUND_LASER_DAMAGE
			damageID = eDamageSourceId.lasergrid
			break
		case "spinning_fan":
			soundDamage = SOUND_FAN_DAMAGE
			damageID = eDamageSourceId.burn
			break
	}

	int statusEffectHandle
	entity maxsCornerEnt

	//-------------------
	// setup laser mesh
	//-------------------
	if ( scriptName == "laser_mesh" )
	{
		// Get the trigger bounds
		vector triggerMins = trigger.GetBoundingMins()
		vector triggerMaxs = trigger.GetBoundingMaxs()
		vector topCorner = PositionOffsetFromEnt( trigger, triggerMaxs.x, triggerMaxs.y, triggerMaxs.z )
		vector topCornerConnect = PositionOffsetFromEnt( trigger, triggerMins.x, triggerMins.y, triggerMaxs.z )
		vector botCorner = PositionOffsetFromEnt( trigger, triggerMaxs.x, triggerMaxs.y, triggerMins.z )

		maxsCornerEnt = CreateEntity( "info_target" )
		maxsCornerEnt.SetOrigin( trigger.GetOrigin() + triggerMaxs )
		entity minsCornerEnt = CreateEntity( "info_target" )
		minsCornerEnt.SetOrigin( trigger.GetOrigin() + triggerMins )
		maxsCornerEnt.LinkToEnt( minsCornerEnt )

		maxsCornerEnt.kv.spawnflags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT
		minsCornerEnt.kv.spawnflags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT
		maxsCornerEnt.EnableNetworkedEntityLinks()
		DispatchSpawn( maxsCornerEnt )
		DispatchSpawn( minsCornerEnt )

		statusEffectHandle = StatusEffect_AddEndless( maxsCornerEnt, eStatusEffect.laser_mesh, 1.0 )
	}


	if ( soundLoop != "" )
		thread EmitSoundAtPositionHack( TEAM_UNASSIGNED, soundOrigin, soundLoop )

	var scriptTypeMask = damageTypes.dissolve | DF_STOPS_TITAN_REGEN
	entity player
	var result
	vector playerOriginXYonly
	vector triggerOriginXYonly = Vector( centerEntOrigin.x, centerEntOrigin.y, 0 )
	vector vecToEnt

	//---------------------------
	// Cleanup when destroyed
	//---------------------------
	OnThreadEnd(
	function() : ( trigger, maxsCornerEnt, soundOrigin, blockerBrush, soundLoop, soundDeactivate, statusEffectHandle )
		{
			//------------------------------------------------
			//Don't destroy blocker brush if we are just pausing
			//------------------------------------------------
			if ( IsValid( trigger ) )
			{
				blockerBrush.NotSolid()
				blockerBrush.Hide()
				blockerBrush.MakeInvisible()
			}
			else
				blockerBrush.Destroy()

			if ( IsValid( maxsCornerEnt ) )
				StatusEffect_Stop( maxsCornerEnt, statusEffectHandle )

			//--------------------------------------------------------------------------------
			// Stop and destroy all sounds and particles regardless of pausing or destroying
			//--------------------------------------------------------------------------------
			if ( soundLoop != "" )
				StopSoundAtPosition( soundOrigin, soundLoop )

			if ( soundDeactivate != "" )
				EmitSoundAtPosition( TEAM_UNASSIGNED, soundOrigin, soundDeactivate )
		}
	)


	//---------------------------
	// Wait to do damage
	//---------------------------
	while ( IsValid( trigger) )
	{
		player = null
		result = trigger.WaitSignal( "OnStartTouch" )

		//if ( level.isTimeTraveling )
		//	continue

		if ( !IsValid( result.activator ) )
			continue

		if ( result.activator.IsNPC() )
		{
			thread LaserMeshDamageNPC( expect entity( result.activator ) )
			continue
		}
		if ( !result.activator.IsPlayer() )
			continue

		//Damage and pushback player
		player = expect entity( result.activator )
		
		if ( player.s.isTimeTraveling )
			continue

		player.TakeDamage( 50, svGlobal.worldspawn, svGlobal.worldspawn, { origin = player.GetOrigin(), scriptType = scriptTypeMask, damageSourceId = damageID } )
		CreateShakeRumbleOnly( player.GetOrigin(), 10, 105, 1 )

		playerOriginXYonly = player.GetOrigin()
		playerOriginXYonly = Vector( playerOriginXYonly.x, playerOriginXYonly.y, 0 )

		vecToEnt = ( playerOriginXYonly - triggerOriginXYonly )
		vecToEnt = Normalize( vecToEnt )

		printt( "vecToEnt: ", vecToEnt )
		player.SetVelocity( vecToEnt * 1000 )
		printt( "Velocity: ", vecToEnt * 1000 )

		EmitSoundOnEntity( player, soundDamage )


		//DebugDrawSphere( playerOriginXYonly, 16, 255, 0, 0, true, 3 )
		//DebugDrawSphere( triggerOriginXYonly, 16, 255, 0, 0, true, 3 )

		//SetVelocity( Normalize( triigerOrigin - playerOrigin ) * 1000 )

	}

}

/////////////////////////////////////////////////////////////////////////////////////////
void function LaserMeshDamageNPC( entity npc )
{
	if ( !IsAlive( npc ) )
		return

	if ( npc.GetClassName() == "npc_marvin" )
		return

	if ( npc.GetClassName() == "npc_stalker" )
		return

	npc.Gib( < 0, 0, 100> )
}

/////////////////////////////////////////////////////////////////////////////////////////
void function LaserMeshDeactivateByInstanceName( string instanceName )
{
	array< entity > triggers = GetEntArrayByScriptNameInInstance( "laser_mesh", instanceName )
	foreach( trigger in triggers )
	{
		if( IsValid( trigger ) )
			trigger.Signal( "PauseLasermesh" )

	}
}

/////////////////////////////////////////////////////////////////////////////////////////
void function LaserMeshDestroyByInstanceName( string instanceName )
{
	array< entity > triggers = GetEntArrayByScriptNameInInstance( "laser_mesh", instanceName )
	foreach( trigger in triggers )
	{
		if( IsValid( trigger ) )
			trigger.Destroy()
	}
}

/////////////////////////////////////////////////////////////////////////////////////////
void function LaserMeshActivateByInstanceName( string instanceName )
{
	array< entity > lasermeshTriggers = GetEntArrayByScriptNameInInstance( "laser_mesh", instanceName )
	foreach( trigger in lasermeshTriggers )
	{
		if( IsValid( trigger ) )
			thread TriggerPushbackDamageThink( trigger )
	}
}

/////////////////////////////////////////////////////////////////////////////////////////
var function CreateLaserMeshBeam( startPos, endPos )
{
	entity cpoint = CreateEntity( "info_placement_helper" )
	cpoint.SetOrigin( endPos )
	SetTargetName( cpoint, UniqueString( "controlpoint" ) )
	DispatchSpawn( cpoint )

	entity serverEffect = CreateEntity( "info_particle_system" )
	serverEffect.SetOrigin( startPos )
	serverEffect.SetValueForEffectNameKey( FX_LASER )
	serverEffect.kv.start_active = 1
	serverEffect.SetControlPointEnt( 1, cpoint )

	DispatchSpawn( serverEffect )

	return serverEffect
}

/////////////////////////////////////////////////////////////////////////////////////////
/*
void function TriggerSpectreWallSpawnerThink( entity trigger )
{
	trigger.EndSignal( "OnDeath" )

	entity spectreSpawnDoor
	array< entity > linkedEnts = trigger.GetLinkEntArray()
	Assert( linkedEnts.len() > 0, "Trigger at " + trigger.GetOrigin() + " is not linked to any spectre spawn doors" )
	entity spectreRack
	//entity spawner

	vector hackRackOrigin

	foreach( entity ent in linkedEnts )
	{
		spectreSpawnDoor = ent
		Assert( spectreSpawnDoor.GetClassName() == "prop_dynamic" )
		spectreRack = spectreSpawnDoor.GetLinkEnt()
		Assert( IsValid( spectreRack ), "Spectre door at " + spectreSpawnDoor.GetOrigin() + " with angles: " + spectreSpawnDoor.GetAngles() + " needs to target a valid spectre rack." )
		//spawner = spectreRack.GetLinkEnt()
		//Assert( IsValid( spawner ), "spectreRack at " + spectreRack.GetOrigin() + " needs to target a valid spectre spawner." )

		//push racks back a bit so they don't clip thru doors...too difficult to do all in LevelEd...another reason we need instance_names!
		hackRackOrigin = PositionOffsetFromEnt( spectreRack, -8, 0, 0 )
		spectreRack.SetOrigin( hackRackOrigin )

		thread PropSpawnerThink( trigger, spectreSpawnDoor, spectreRack )
	}

}
*/

/////////////////////////////////////////////////////////////////////////////////////////
int function GetPlayerSatchelCount( var player )
{

	return 0

	/*
	int numSatchels

	local weapon = player.GetOffhandWeapon( 0 )
	if ( !IsValid( weapon ) )

	if ( weapon )
	local clipCount = player.GetWeaponAmmoMaxLoaded( weapon )


	return numSatchels

	*/
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function SwapTimelines( entity player, var timeZone )
{
	//needs to be threaded off since need to do a
	//WaitEndFrame()...player will take damage from random hazard triggers otherwise
	thread SwapTimelinesThread( player, timeZone )
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function DeviceUsedInFrozenWorld( entity player )
{
	const float EFFECT_DURATION_TOTAL = 0.5
	const float EFFECT_DURATION_EASE_OUT = 0.5
	StatusEffect_AddTimed( player, eStatusEffect.timeshift_visual_effect, 1.0, EFFECT_DURATION_TOTAL, EFFECT_DURATION_EASE_OUT )

	//StopSoundOnEntity( player, "Timeshift_Scr_DeviceShift2Past" )
	//EmitSoundOnEntity( player, "Timeshift_Scr_DeviceShift2Present" )
	StopSoundOnEntity( player, "Timeshift_Scr_BrokenDeviceUse" )
	EmitSoundOnEntity( player, "Timeshift_Scr_BrokenDeviceUse" )

	//entity timeShiftOffhand = player.GetFirstPersonProxy()
	//timeShiftOffhand.SetSkin( 0 )

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function SwapTimelinesThread( entity player, var timeZoneDestination )
{
	if ( !CanTimeShift( player ) )
		return

	player.s.isTimeTraveling = true

	// no idea why respawn did this, but removing it doesn't seem to break anything
	//entity player = GetPlayerArray()[0]
	//if ( !player )
	//	return

	player.ClearTraverse()

	player.EndSignal( "OnDeath" )

	var skyCam
	vector playerPos = player.GetOrigin()
	vector newPlayerPos
	int timeOffset

	player.SetCloakReactEndTime( Time() )


	if ( timeZoneDestination == TIMEZONE_NIGHT )
	{
		//--------------------------
		// switch to night/overgrown
		//--------------------------
		SetGlobalNetBool( "PlayerInOvergrownTimeline", true )
		skyCam = GetEnt( "skybox_cam_night" )
		
		//level.timeZone = TIMEZONE_NIGHT
		player.s.timeline = TIMEZONE_NIGHT
		
		timeOffset = TIME_ZOFFSET * -1
		
		// make this not use global stuff
		//FreezeNpcs( TIMEZONE_DAY )
		if ( GetPlayersInTimeline( TIMEZONE_DAY ).len() == 0 )
			FreezeNpcs( TIMEZONE_DAY )
		
		player.Signal( "OnTimeFlippedTimezoneNight" )
		SetTimeshiftTimeOfDay_Night()
		if ( Flag( "PlayerPickedUpTimeshiftDevice" ) )
			SetTimeshiftArmDeviceSkin( 1 )
		if ( Flag( "HidePlayerWeaponsDuringShifts") )
			player.EnableWeapon()
	}

	else if ( timeZoneDestination == TIMEZONE_DAY )
	{
		//------------------------
		//switch to day/pristine
		//------------------------
		SetGlobalNetBool( "PlayerInOvergrownTimeline", false )
		skyCam = GetEnt( "skybox_cam_day" )
		
		//level.timeZone = TIMEZONE_DAY
		player.s.timeline = TIMEZONE_DAY
		
		timeOffset = TIME_ZOFFSET
		FreezeNpcs( TIMEZONE_NIGHT )
		
		// make this not use global stuff
		//FreezeNpcs( TIMEZONE_NIGHT )
		if ( GetPlayersInTimeline( TIMEZONE_NIGHT ).len() == 0 )
			FreezeNpcs( TIMEZONE_NIGHT )
		
		player.Signal( "OnTimeFlippedTimezoneDay" )

		SetTimeshiftTimeOfDay_Day()
		if ( Flag( "PlayerPickedUpTimeshiftDevice" ) )
			SetTimeshiftArmDeviceSkin( 0 )
		if ( Flag( "HidePlayerWeaponsDuringShifts") )
			player.DisableWeapon()
	}
	else
		SetGlobalNetBool( "PlayerInOvergrownTimeline", false )


	SatchelManagement( player, timeZoneDestination )

	if ( ( player.IsTitan() ) && ( !Flag( "PlayerHasTimeTraveledInsideBT" ) ) )
	{
		FlagSet( "PlayerHasTimeTraveledInsideBT" )
	}

	TimeshiftUntrackLockedTargets( player )

	vector positionOffset = Vector( 0, 0, timeOffset );
	newPlayerPos = playerPos + positionOffset;

	if ( PlayerPosInSolid( player, newPlayerPos ) )
	{
		if ( timeZoneDestination == TIMEZONE_DAY )
		{
			printt( "***WARNING: Destination TimeShiftPos " + newPlayerPos + " is in solid. Using file.lastGoodTimeshiftPosPristine instead" )
			//newPlayerPos = file.lastGoodTimeshiftPosPristine
			// use player script var instead
			// this won't compile if we don't manually do type safety stuff here
			var pos = player.s.lastGoodTimeshiftPosPristine
			newPlayerPos = expect vector( pos )
		}
		else if ( timeZoneDestination == TIMEZONE_NIGHT )
		{
			printt( "***WARNING: Destination TimeShiftPos " + newPlayerPos + " is in solid. Using file.lastGoodTimeshiftPosOvergrown instead" )
			//newPlayerPos = file.lastGoodTimeshiftPosOvergrown
			// use player script var instead
			// this won't compile if we don't manually do type safety stuff here
			var pos = player.s.lastGoodTimeshiftPosOvergrown
			newPlayerPos = expect vector( pos )
		}
	}
	else
	{
		//Not in solid, just use the offset
		newPlayerPos = Vector( playerPos.x, playerPos.y, playerPos.z + timeOffset )
	}

	thread SwapTimelineEffectsAndSound( player, timeZoneDestination )

	const float EFFECT_DURATION_TOTAL = 0.5
	const float EFFECT_DURATION_EASE_OUT = 0.5
	StatusEffect_AddTimed( player, eStatusEffect.timeshift_visual_effect, 1.0, EFFECT_DURATION_TOTAL, EFFECT_DURATION_EASE_OUT )

	Remote_CallFunction_NonReplay( player, "ServerCallback_TimeFlipped", player.s.timeline )
	player.SetSkyCamera( skyCam )
	if ( !IsAlive( player ) )
		return
	MakeInvincible( player )
	WaitEndFrame() //player will take damage from random hazard triggers otherwise

	if ( Flag( "DoingCinematicTimeshift" ) )
		player.SetAbsOrigin( newPlayerPos )
	else
		player.SetOrigin( newPlayerPos )

	EmitAISoundWithOwner( player, SOUND_PLAYER, 0, newPlayerPos, 150, 0.2 )

	SetRapidShiftOffset( -positionOffset );
	ClearInvincible( player )

	if ( timeZoneDestination == TIMEZONE_DAY )
		GruntChatter_TryEnemyTimeShifted( player )

	ObjectiveCompensate( player, file.currentObjectiveEntity )
	player.s.isTimeTraveling = false

	//thread SonarColorCorrection( player, 0.5, null )
}



void function TimeshiftUntrackLockedTargets( entity player )
{
	if ( !IsValid( player ) )
		return

	entity trackingWeapon
	entity offhand

	if ( !player.IsTitan() )
		return


	offhand = player.GetOffhandWeapon( OFFHAND_RIGHT )
	if ( !IsValid( offhand ) )
		return
	if ( offhand.GetWeaponClassName() == "mp_titanweapon_tracker_rockets" )
		trackingWeapon = offhand


	if ( !IsValid( trackingWeapon ) )
		return

	trackingWeapon.SmartAmmo_Clear( true, true )

	/*
	var allTargets = trackingWeapon.SmartAmmo_GetTargets()
	foreach ( target in allTargets )
	{
		if ( !IsValid( target.ent ) )
			continue
		trackingWeapon.SmartAmmo_UntrackEntity( target.ent )

	}
	*/


}
/////////////////////////////////////////////////////////////////////////////////////////////////////////
void function PlayerIndorsStatus()
{
	while( GetPlayerArray().len() == 0 )
		wait 0.1

	entity player = GetPlayerArray()[ 0 ]
	Assert( IsValid( player ) )
	player.EndSignal( "OnDeath" )


	if ( GetMapName() == "sp_timeshift_spoke02" )
	{
		Remote_CallFunction_NonReplay( player, "ServerCallback_PlayerIndoorsChanged", 1 )
		return
	}


	Remote_CallFunction_NonReplay( player, "ServerCallback_PlayerIndoorsChanged", 0 )

	while( true )
	{
		wait 0.1

		FlagWait( "player_is_indoors" )
		Remote_CallFunction_NonReplay( player, "ServerCallback_PlayerIndoorsChanged", 1 )

		FlagWaitClear( "player_is_indoors" )
		Remote_CallFunction_NonReplay( player, "ServerCallback_PlayerIndoorsChanged", 0 )

	}
}


/////////////////////////////////////////////////////////////////////////////////////////////////////////
void function SatchelManagement( entity player, var timeZone )
{
	if ( !IsValid( player ) )
		return

	array<entity> traps = GetScriptManagedEntArray( player.s.activeTrapArrayId )
	foreach ( index, satchel in traps )
	{
		if ( !IsValid( satchel ) )
			continue
		if ( GetEntityTimelinePosition( satchel ) == timeZone )
			DisableSatchel( satchel, false )
		else
			DisableSatchel( satchel, true )
	}

}
/////////////////////////////////////////////////////////////////////////////////////////////////////////
void function DisableSatchel( entity satchel, bool isDisabled )
{
	satchel.e.isDisabled = isDisabled
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
bool function CanTimeShift( entity player )
{
	if ( Flag( "DoingCinematicTimeshift" ) )
		return true

	if ( player.GetParent() )
	{
		printl( "Can't teleport...parented")
		return false
	}

	/*
	if ( player.IsTraversing() )
	{
		printl( "Can't teleport...traversing")
		return false
	}
	*/
	/*
	if ( ( player.IsTitan() ) && ( level.titanCanTimeTravel == false ) )
	{
		printl( "Can't teleport...Titan")
		return false
	}
	*/

	if ( player.s.isTimeTraveling )
		return false

	return true
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
function OnTimeShiftAbilityUsed( player )
{
	if ( level.allowTimeTravel == false )
	{
		if ( Flag( "SwappedToFrozenWorld" ) )
			thread DeviceUsedInFrozenWorld( expect entity( player ) )
		return

	}

	//if ( level.timeZone == TIMEZONE_DAY )
	if ( player.s.timeline == TIMEZONE_DAY )
		SwapTimelines( expect entity( player ), TIMEZONE_NIGHT )
	else
		SwapTimelines( expect entity( player ), TIMEZONE_DAY )
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////
function OnSatchelPlanted( player, collisionParams )
{
	expect entity( player )
	if ( !IsValid( player ) )
		return

	expect table( collisionParams )

	vector plantAngles = VectorToAngles( collisionParams.normal )
	vector plantPosition = expect vector( collisionParams.pos )

	//thread SatchelHint( player )

	//----------------------------------------------------------------
	//create a duplicate satchel in the present if planted in the past
	//----------------------------------------------------------------
	if ( GetTimelinePosition( plantPosition ) == TIMEZONE_NIGHT )
		return

	if ( collisionParams.hitEnt != null ) //forget it if it's attached to an AI or anything moving
		return

	//TO DO - plant a dupe satchel here
	//bool result = PlantStickyEntity( weapon, collisionParams )

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
function SatchelHint( entity player )
{
	player.EndSignal( "OnDeath" )
	player.Signal( "DisplayingSatchelHint" )
	player.EndSignal( "DisplayingSatchelHint" )

	array<entity> traps
	entity playerCurrentWeapon
	string playerCurrentWeaponClassname
	bool isDisplayingHint = false

	entity closestSatchel
	entity offHandOrdinance
	while ( true )
	{
		wait 1.5

		if ( isDisplayingHint == true )
		{
			isDisplayingHint = false
			ClearOnscreenHint( player )
		}

		offHandOrdinance = player.GetOffhandWeapon( 0 )
		if ( !offHandOrdinance )
			break
		if ( offHandOrdinance.GetWeaponClassName() != "mp_weapon_satchel" )
			break

		traps = GetScriptManagedEntArray( player.s.activeTrapArrayId )
		if ( traps.len() < 1 )
			break

		playerCurrentWeapon = player.GetActiveWeapon()

		// No current weapon selected
		if ( !IsValid( playerCurrentWeapon ) )
			continue

		playerCurrentWeaponClassname = playerCurrentWeapon.GetWeaponClassName()

		//Player is equipped with the clacker, clear message
		if ( playerCurrentWeaponClassname == "mp_weapon_satchel" )
			continue

		closestSatchel = GetClosest( traps, player.GetOrigin() )
		if ( !IsValid( closestSatchel ) )
			continue

		if ( DistanceSqr( player.GetOrigin(), closestSatchel.GetOrigin() ) > ( 1024 * 1024 ) )
			continue


		//player is not equipped with the clacker, display message
		else
		{
			if ( file.isDisplayingTimeshiftHint)
				continue
			if ( file.isDisplayingDamageText )
				continue

			DisplayOnscreenHint( player, "satchel_hint_tap_twice", 3.0 )
			isDisplayingHint = true
			continue
		}

	}

	ClearOnscreenHint( player )


}

*/

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool function PlayerHasSatchels( entity player )
{
	if ( !IsValid( player ) )
		return false

	entity weapon = player.GetOffhandWeapon( 0 )
	if ( !IsValid( weapon ) )
		return false

	int satchelCount = player.GetWeaponAmmoMaxLoaded( weapon )
	if ( satchelCount == 0 )
		return false

	return true

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////


function FreezeNpcs( timeZone )
{
	array<entity> npcsToFreeze
	array<entity> npcsToUnFreeze
	ArrayRemoveDead( file.npcsPresent )
	ArrayRemoveDead( file.npcsPast )

	if ( timeZone == TIMEZONE_NIGHT )
	{
		npcsToFreeze = file.npcsPresent
		npcsToUnFreeze = file.npcsPast
	}


	else if ( timeZone == TIMEZONE_DAY )
	{
		npcsToFreeze = file.npcsPast
		npcsToUnFreeze = file.npcsPresent
	}


	foreach( npc in npcsToFreeze )
		FreezeNPC( npc )

	foreach( npc in npcsToUnFreeze )
		UnFreezeNPC( npc )
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
function FreezeNPC( entity npc )
{
	if ( !IsValid( npc ) )
		return

	if ( IsFreezeProof( npc ) )
		return

	if ( IsFrozen( npc ) == true )
		return

	npc.Freeze()
	npc.Signal( "Frozen" )

	if ( !( "isFrozen" in npc.s ) )
		npc.s.isFrozen <- null
	npc.s.isFrozen = true
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
function UnFreezeNPC( entity npc )
{
	if ( !IsValid( npc ) )
		return

	if ( IsFrozen( npc ) == false )
		return

	npc.Unfreeze()
	npc.Signal( "UnFrozen" )
	if ( !( "isFrozen" in npc.s ) )
		npc.s.isFrozen <- null
	npc.s.isFrozen = false
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
function IsFrozen( npc )
{
	if ( !( "isFrozen" in npc.s ) )
		return false

	return npc.s.isFrozen
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool function IsFreezeProof( entity npc )
{
	if ( !IsValid( npc ) )
		return false
	if ( "dontAllowFreeze" in npc.s )
		return true

	return false
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function DontAllowFreeze( entity npc, bool state )
{
	if ( !IsValid( npc ) )
		return

	if ( state == true )
	{
		if ( !( "dontAllowFreeze" in npc.s ) )
			npc.s.dontAllowFreeze <- null
		npc.s.dontAllowFreeze = true
	}
	else
	{
		if ( "dontAllowFreeze" in npc.s )
			delete npc.s.dontAllowFreeze
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function OnSpawnedNPC( entity npc )
{
	string classname = npc.GetClassName()
	string editorClassname = GetEditorClass( npc )

	if ( editorClassname == "npc_marvin_drone" )
		return

	var timeZone = GetEntityTimelinePosition( npc )
	expect int(timeZone)

	int difficulty = GetSpDifficulty()


	if ( timeZone == TIMEZONE_NIGHT )
		file.npcsPresent.append( npc )
	else if ( timeZone == TIMEZONE_DAY )
		file.npcsPast.append( npc )
	else
	{
		//Frozen world - do nothing
	}

	//If I just spawned in the opposite time zone as the player, freeze me
	//if ( ( level.timeZone != timeZone ) && ( timeZone != TIMEZONE_FROZEN ) )
	if ( GetPlayersInTimeline( timeZone ).len() == 0 && timeZone != TIMEZONE_FROZEN )
		FreezeNPC( npc )

	if ( timeZone == TIMEZONE_FROZEN )
		return

	//Do blue afterglow if we have the device now
	if ( level.allowTimeTravel )
		thread TimeshiftAfterglowThink( npc, timeZone )




	int maxHealth = npc.GetMaxHealth()
	switch( classname )
	{
		case "npc_marvin":
			if ( timeZone == TIMEZONE_NIGHT )
			{
				npc.SetModel( MARVIN_MODEL_OVERGROWN )
				npc.SetSkin( 1 ) //mossy
			}
			break
		case "npc_stalker":
		case "npc_stalker_zombie":
		case "npc_stalker_zombie_mossy":
		case "npc_stalker_crawling_mossy":
			thread StalkerThink( npc, classname )

			break
		case "npc_drone":
			break
		case "npc_turret_sentry":
			if ( difficulty < DIFFICULTY_MASTER )
				npc.kv.AccuracyMultiplier = 4
			else
				npc.kv.AccuracyMultiplier = 3
			break
		case "npc_titan":
			thread TitanEnemyThink( npc )
			break
	}

	string scriptName = npc.GetScriptName()
	//--------------------------
	// Civilians
	//--------------------------
	if ( scriptName.find( "civilian_walker_" ) != null )
		thread CivilianWalkerThink( npc )
	if ( scriptName.find( "civilian_actor_" ) != null )
		thread CivilianActorThink( npc )
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function TitanEnemyThink( entity npc )
{
	if ( npc.GetTeam() != TEAM_IMC )
		return

	//npc.WaitSignal( "WeakTitanHealthInitialized" )
	//DeregisterBossTitan( npc )
	//npc.SetHealth( 100 )

	var timeZone = GetEntityTimelinePosition( npc )

	if ( timeZone == TIMEZONE_DAY )
		thread TitanEnemyThinkPristine( npc )
	else
		thread TitanEnemyThinkOvergrown( npc )
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function TitanEnemyThinkOvergrown( npc )
{
	npc.WaitSignal( "WeakTitanHealthInitialized" )
	npc.TakeDamage( npc.GetMaxHealth()/2, null, null, { damageSourceId=damagedef_suicide } )
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function TitanEnemyThinkPristine( npc )
{
	npc.WaitSignal( "WeakTitanHealthInitialized" )
	printt( "Titan health: ", npc.GetHealth() )
	npc.SetMaxHealth( 10000 )
	npc.SetHealth( 10000 )
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function StalkerThink( entity npc, string classname )
{
	npc.SetSkin( 1 ) //mossy
	TakeAllWeapons( npc )

	if ( ( GetMapName() == "sp_hub_timeshift" ) && ( !Flag( "player_back_in_amenities_lobby") ) )
		return

	if ( ( GetMapName() == "sp_timeshift_spoke02" ) && ( !Flag( "StartAndersonHologram1" ) ) )
		return

	npc.GiveWeapon( "mp_weapon_mgl" )

	npc.EndSignal( "OnDeath" )
	while( true )
	{
		npc.kv.allowshoot = 0
		wait RandomFloatRange( 4, 6 )
		npc.kv.allowshoot = 1
		wait RandomFloatRange( 3, 5 )
	}
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function TimeshiftAfterglowThink( entity npc, var timeZone )
{

	if( !IsValid( npc ) )
		return

	npc.EndSignal( "OnDestroy" )
	npc.EndSignal( "OnDeath" )

	//don't do glows for friendlies
	int team = npc.GetTeam()
	if ( team == TEAM_MILITIA )
		return

	if ( team == TEAM_UNASSIGNED )
		return

	//don't do glow for certain scripted things
	string scriptName = npc.GetScriptName()
	if ( ( IsValid( scriptName ) ) && ( scriptName == "lab_prowlers" ) )
		return

	if ( ( IsValid( scriptName ) ) && ( scriptName == "bio_pod_body" ) )
		return



	string classname = npc.GetClassName()
	string glowSound = "Timeshift_Scr_TimeResidue_Generic"
	int zOffset
	vector fxAfterglowAdditionalOffset

	switch( classname )
	{
		case "npc_marvin":
			return
		case "npc_soldier":
			glowSound = "Timeshift_Scr_TimeResidue_Grunt"
			fxAfterglowAdditionalOffset = Vector( 0, 0, 32 )
			break
		case "npc_spectre":
		case "npc_stalker_zombie":
		case "npc_stalker_zombie_mossy":
		case "npc_stalker_crawling_mossy":
			fxAfterglowAdditionalOffset = Vector( 0, 0, 32 )
			glowSound = "Timeshift_Scr_TimeResidue_ZombieStalker"
			break
		case "npc_stalker":
			glowSound = "Timeshift_Scr_TimeResidue_Stalker"
			fxAfterglowAdditionalOffset = Vector( 0, 0, 32 )
			break
		case "npc_prowler":
			glowSound = "Timeshift_Scr_TimeResidue_Prowler"
			fxAfterglowAdditionalOffset = Vector( 0, 0, 32 )
			break
		case "npc_drone":
			glowSound = "Timeshift_Scr_TimeResidue_Drone"
			fxAfterglowAdditionalOffset = Vector( 0, 0, 0 )
			break
		case "npc_titan":
			fxAfterglowAdditionalOffset = Vector( 0, 0, 80 )
			break
		case "npc_super_spectre":
			fxAfterglowAdditionalOffset = Vector( 0, 0, 64 )
			break
		case "npc_frag_drone":
			fxAfterglowAdditionalOffset = Vector( 0, 0, 32 )
			break
		case "npc_turret_sentry":
			fxAfterglowAdditionalOffset = Vector( 0, 0, 16 )
			break
		default:
			Assert( 0, "Unhandled npc: " + classname )
			break
	}


	if ( GetEditorClass( npc ) == "npc_specialist_imc" )
		glowSound = "Timeshift_Scr_TimeResidue_Generic"

	if ( timeZone == TIMEZONE_NIGHT )
		zOffset = TIME_ZOFFSET
	else
		zOffset = TIME_ZOFFSET * -1

	vector fxAfterglowPos
	vector fxAfterglowAng

	entity fx
	while( true )
	{
		npc.WaitSignal( "Frozen" )
		fxAfterglowPos = npc.GetOrigin()
		fxAfterglowPos = fxAfterglowPos + fxAfterglowAdditionalOffset
		fxAfterglowPos = Vector( fxAfterglowPos.x, fxAfterglowPos.y, fxAfterglowPos.z + zOffset )
		fxAfterglowAng = npc.GetAngles()
		fx = PlayFX( FX_TIMESHIFT_ENTITY_MARKER, fxAfterglowPos, fxAfterglowAng )
		if ( glowSound != "" )
			EmitSoundAtPosition( TEAM_UNASSIGNED, fxAfterglowPos, glowSound )

		OnThreadEnd(
		function() : ( fx, glowSound, fxAfterglowPos )
			{
				DestroyFxIfValid( fx )
				if ( glowSound != "" )
					StopSoundAtPosition( fxAfterglowPos, glowSound )
			}
		)

		npc.WaitSignal( "UnFrozen" )
		DestroyFxIfValid( fx )
		if ( glowSound != "" )
			StopSoundAtPosition( fxAfterglowPos, glowSound )
	}
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function DestroyFxIfValid( entity fx )
{
	if ( !IsValid( fx) )
		return
	fx.Fire( "Stop" )
	fx.Fire( "DestroyImmediately" )
	fx.Destroy()
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function TS_OnDeathNPC( entity npc, var damageInfo )
{
	thread TS_OnDeathNPCThread( npc, damageInfo )
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function TS_OnDeathNPCThread( entity npc, var damageInfo )
{
	if ( !IsValid( npc ) )
		return

	string editorClassname = GetEditorClass( npc )

	if ( GetEntityTimelinePosition( npc ) == TIMEZONE_NIGHT )
	{
		if ( editorClassname == "npc_marvin" )
			npc.SetSkin( 1 ) //bug where Marvins revert to base skin when killed

		//TryTimeshiftGibDeath( npc, damageInfo )

		//get out of here because we don't care about npcs in the present
		return
	}

	int damageType = DamageInfo_GetCustomDamageType( damageInfo )

	if ( !damageType )
		return

	printt( "explosive: " + ( damageType & DF_EXPLOSION ) )
	printt( "bullet: " + ( damageType & DF_BULLET ) )
	printt( "gib: " + ( damageType & DF_GIB ) )

	if ( damageType & DF_GIB )
	{
		return
	}

	//if ( TryTimeshiftGibDeath( npc, damageInfo ) )
		//return


	//vector deathPos = npc.GetOrigin()
	vector deathPos = npc.GetOrigin() + Vector( 0, 0, ( TIME_ZOFFSET * -1 ) )
	//vector deathPos = npc.GetOrigin()




	asset deathModel
	entity corpseOrg
	bool usesSingleDeathModel = true
	int additionalZoffset = 0
	if ( editorClassname == "" )
		editorClassname = npc.GetClassName()

	switch( editorClassname )
	{
		case "npc_prowler":
			break
		case "npc_marvin":
			deathModel = MARVIN_MODEL_OVERGROWN
			break
		case "npc_stalker":
			corpseOrg = file.stalkerCorpseOrg
			usesSingleDeathModel = false
			additionalZoffset = 16
			break
		case "npc_titan_ogre_minigun":
		case "npc_titan":
			corpseOrg = file.titanCorpseOrg
			usesSingleDeathModel = false
			additionalZoffset = 64
			break
		case "npc_soldier_imc_shotgun":
			deathModel = IMC_CORPSE_MODEL_SHOTGUN
			break
		case "npc_soldier_imc_rifle":
		case "npc_soldier":
			deathModel = IMC_CORPSE_MODEL_RIFLE
			break
		case "npc_shield_captain_imc":
			deathModel = IMC_CORPSE_MODEL_HEAVY
			break
		case "npc_soldier_imc_smg":
			deathModel = IMC_CORPSE_MODEL_SMG
			break
	}


	/*
	int xAngle = 90
	if ( CoinFlip() )
		xAngle = -90
	vector deathAng = Vector( xAngle, RandomFloatRange( 0, 360 ), RandomFloatRange( 0, 360 ) )
	*/

	//randomly spin the body/gib collection on it's y axis
	vector deathAng = Vector( 0, RandomFloatRange( 0, 360 ), 0 )

	if ( ( deathModel == $"" ) && ( usesSingleDeathModel ) )
	{
		printt( "Unhandled corpse type: '" + editorClassname + "'")
		return
	}


	array<entity> corpseModels

	if ( usesSingleDeathModel )
	{
		entity corpse = CreatePropDynamic( deathModel, deathPos + Vector( 0, 0, 5), deathAng, 6 ) // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
		corpse.Hide()
		if ( deathModel == MARVIN_MODEL_OVERGROWN )
			corpse.SetSkin( 1 ) //mossy
		corpseModels.append( corpse )
		string anim = GetrandomDeathPose( deathModel )
		vector newOrg = HackGetDeltaToRef( corpse.GetOrigin(), corpse.GetAngles(), corpse, anim )
		thread PlayAnimTeleport( corpse, anim, newOrg, corpse.GetAngles() )
	}
	else
	{

		corpseOrg.SetOrigin( deathPos )
		corpseOrg.SetAngles( deathAng )
		array<entity> bodyPartArray = file.titanCorpsePieces
		if ( editorClassname == "npc_stalker" )
			bodyPartArray = file.stalkerCorpsePieces

		foreach( bodypart in bodyPartArray )
		{
			asset modelName = bodypart.GetModelName()
			vector angles = bodypart.GetAngles()
			vector origin = bodypart.GetOrigin()
			entity clonedModel = CreatePropPhysics( modelName, origin + Vector( 0, 0, 20 + additionalZoffset ), angles ) // 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only
			clonedModel.Hide()
			corpseModels.append( clonedModel )
		}


	}

	waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_NIGHT )

	foreach( corpse in corpseModels )
	{
		corpse.Show()

		if ( usesSingleDeathModel )
			corpse.BecomeRagdoll( Vector( 0,0,0 ), false )
	}

}

/*
	array<string> idles = [ "pt_S2S_crew_A_idle",
						"pt_S2S_crew_B_idle",
						"pt_S2S_crew_C_idle",
						"pt_S2S_crew_D_idle" ]
*/


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//HACK: need a better global way to spawn marvins using levelEd ents
void function OnSpawnedMarvinSpawner( entity spawner )
{
	SpawnMarvin( spawner )
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool function TryTimeshiftGibDeath( entity npc, var damageInfo )
{
	if ( !IsValid( npc ) )
		return false

	int damageSourceId = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	if ( !IsValid( damageSourceId ) )
		return false
	if ( damageSourceId != eDamageSourceId.mp_weapon_satchel )
		return false


	//string editorClassname = GetEditorClass( npc )
	string classname = npc.GetClassName()

	if ( !IsValidGibTarget( classname ) )
		return false


	vector npcOrigin = npc.GetOrigin()
	vector damageOrigin = DamageInfo_GetDamagePosition( damageInfo )

	if ( !IsValid( npcOrigin ) )
		return false

	if ( !IsValid( damageOrigin ) )
		return false

	float minDist = 100
	if ( Distance( npcOrigin, damageOrigin ) > minDist )
		return false

	EmitSoundAtPosition( TEAM_ANY, npcOrigin, "death.pinkmist" )
	npc.Dissolve( ENTITY_DISSOLVE_PINKMIST, Vector( 0, 0, 0 ), 500 )

	return true

}

bool function IsValidGibTarget( string classname )
{
	if ( classname == "npc_prowler" )
		return true

	if ( classname == "npc_soldier" )
		return true

	return false

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
//HACK: need a better global way to spawn marvins using levelEd ents
function SpawnMarvin( spawner )
{
	local origin = spawner.GetOrigin()
	local angles = spawner.GetAngles()
	entity npc_marvin = CreateEntity( "npc_marvin" )
	SetTargetName( npc_marvin, UniqueString( "mp_random_marvin") )
	npc_marvin.SetOrigin( origin )
	npc_marvin.SetAngles( angles )
	//npc_marvin.kv.rendercolor = "255 255 255"
	npc_marvin.kv.health = -1
	npc_marvin.kv.max_health = -1
	npc_marvin.kv.spawnflags = 516  // Fall to ground, Fade Corpse
	//npc_marvin.kv.FieldOfView = 0.5
	//npc_marvin.kv.FieldOfViewAlert = 0.2
	npc_marvin.kv.AccuracyMultiplier = 1.0
	npc_marvin.kv.physdamagescale = 1.0
	npc_marvin.kv.WeaponProficiency = eWeaponProficiency.GOOD

	npc_marvin.s.bodytype <- MARVIN_TYPE_WORKER
	npc_marvin.SetValueForModelKey( $"models/robots/marvin/marvin.mdl" )

	DispatchSpawn( npc_marvin )

	SetTeam( npc_marvin, TEAM_UNASSIGNED )

	return npc_marvin
}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
bool function PlayerInRange( vector pos1, vector pos2, float minRange )
{

	if ( Distance( pos1 , pos2 ) > minRange )
		return false

	return true

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
entity function GetSpectreDoorSwitchByDummyName( string dummyName )
{
	entity dummy = GetEntByScriptName( dummyName )
	entity doorSwitch = GetClosest( file.spectreDoorPanels, dummy.GetOrigin() )

	Assert( IsValid( doorSwitch ) )
	Assert( Distance( doorSwitch.GetOrigin(), dummy.GetOrigin() ) < 50, "No doorSwitch within 50 units of dummy: " + dummyName )

	return doorSwitch
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
void function TimeVortexThink( entity trigger )
{
	trigger.EndSignal( "OnDestroy" )

	local result
	entity player
	entity fxEnt = trigger.GetLinkEnt()
	Assert( IsValid( fxEnt ), "Time vortex trig at " + trigger.GetOrigin() + " isn't linked to anything")

	var destinationTimeline = GetOppositeTimeline( GetEntityTimelinePosition( fxEnt ) )

	//----------------
	// Play looping fx
	//----------------
	entity FX = CreateEntity( "info_particle_system" )
	FX.SetValueForEffectNameKey( FX_TIME_PORTAL )
	FX.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	FX.kv.start_active = 1
	FX.SetOrigin( fxEnt.GetOrigin() )
	FX.SetAngles( fxEnt.GetAngles() + Vector( 90, 0, 0 ) )
	DispatchSpawn( FX )
	EmitSoundAtPosition( TEAM_UNASSIGNED, fxEnt.GetOrigin(), SOUND_TIME_PORTAL_LOOP )


	OnThreadEnd(
	function() : ( FX, fxEnt )
		{
			StopSoundAtPosition( fxEnt.GetOrigin(), SOUND_TIME_PORTAL_LOOP )
			DestroyFxIfValid( FX )
			fxEnt.Destroy()
		}
	)


	//----------------
	// Think...
	//----------------
	while( 1 )
	{
		player = null
		wait 0.1
		result = trigger.WaitSignal( "OnTrigger" )

		if ( !IsValid( result.activator ) )
			continue
		if ( result.activator.IsTitan() )
			continue
		if ( !result.activator.IsPlayer() )
			continue

		player = expect entity( result.activator )
		player.EndSignal( "OnDeath" )
		thread TimeVortexSoundThread( player )


		SwapTimelines( player, destinationTimeline )

		//thread TimeShiftSwapEffect( player )
		wait 4

		EmitSoundOnEntity( player, "Pilot_Time_Vortex_Deactivate" )

		wait 1
		float fadeTime = 0.3
		float holdTime = 0
				//(player, r, g, b, a, fadeTime, fadeHold, FFADE_ flags)
		wait 0.75
		ScreenFade( player, 255, 255, 255, 254, fadeTime, holdTime, FFADE_OUT | FFADE_PURGE )
		wait 0.25

		//HACK: can't time shift if player in the middle of hacking a panel
		while ( !CanTimeShift( player ) )
			wait 0.1

		StopSoundOnEntity( player, "Pilot_Time_Vortex_Loop" )
		SwapTimelines( player, GetOppositeTimeline( destinationTimeline ) )
		wait 1
	}

}

*/

///////////////////////////////////////////////////////////////////////////////////////////////////////

/*
void function TimeVortexSoundThread( player )
{
	player.EndSignal( "OnDeath" )

	//need to delay 0.1 otherwise won't hear the sound when he is teleported
	wait 0.1
	EmitSoundOnEntity( player, "Pilot_Time_Vortex_Activate" )
	EmitSoundOnEntity( player, "Pilot_Time_Vortex_Loop" )

}

*/



///////////////////////////////////////////////////////////////////////////////////////////////////////
void function SwapTimelineEffectsAndSound( entity player, timeZone )
{




	//---------------------------------
	// Player has wrist mounted device
	//---------------------------------
	if ( Flag( "PlayerPickedUpTimeshiftDevice" ) )
	{
								//(		 amplitude 	frequency 	duration
		CreateAirShake( player.GetOrigin(), 10, 		50, 		0.2,     10000 )

		if ( player.IsTitan() )
		{
			float fadeTime = 0.1
			float holdTime = 0.03
			ScreenFade( player, 255, 255, 255, 254, fadeTime, holdTime, FFADE_IN | FFADE_PURGE )
			CreateAirShake( player.GetOrigin(), 10, 		50, 		1,     20000 )
		}


		if ( timeZone == TIMEZONE_NIGHT )
		{
			//--------------------------
			// switch to night/overgrown
			//--------------------------
			StopSoundOnEntity( player, "Timeshift_Scr_DeviceShift2Past" )
			EmitSoundOnEntity( player, "Timeshift_Scr_DeviceShift2Present" )
		}
		else
		{
			//--------------------------
			// switch to day/pristine
			//--------------------------
			StopSoundOnEntity( player, "Timeshift_Scr_DeviceShift2Present" )
			EmitSoundOnEntity( player, "Timeshift_Scr_DeviceShift2Past" )

		}

	}
	//---------------------------------
	// Scripted timeshift, no device
	//---------------------------------
	else
	{
		float fadeTime = 0.1
		float holdTime = 0.05
		ScreenFade( player, 255, 255, 255, 254, fadeTime, holdTime, FFADE_IN | FFADE_PURGE )

		//--------------
		// FX
		//--------------
		EmitSoundOnEntity( player, "Timeshift_Scr_InvoluntaryShift" )
	}





	//-----------------------------------
	// Impact table on ground
	//-----------------------------------
	TraceResults results = TraceLine( player.GetOrigin() + Vector( 0, 0, 32 ), player.GetOrigin() + Vector( 0, 0, -200 ), [ player ], TRACE_MASK_NPCSOLID_BRUSHONLY | TRACE_MASK_WATER, TRACE_COLLISION_GROUP_NONE )
	if ( !results.startSolid && !results.allSolid )
		PlayImpactFXTable( GetPosInOtherTimeline( results.endPos ), player, FX_IMPACT_TABLE_TIMESHIFT )

	//-----------------------------------
	// FX for viewmodel device
	//-----------------------------------
	if ( !Flag( "PlayerPickedUpTimeshiftDevice" ) )
		return

	entity timeShiftOffhand



	//-------------------------------------
	// Skin change for cinematic device equip only
	//---------------------------------------
	if ( !Flag( "DoingCinematicTimeshift" ) )
		return

	timeShiftOffhand = player.GetFirstPersonProxy()

	if ( !IsValid( timeShiftOffhand) )
		return

	if ( timeZone == TIMEZONE_DAY )
	{
		timeShiftOffhand.SetSkin( 0 ) //orange 0
	}

	else if ( timeZone == TIMEZONE_NIGHT )
	{
		timeShiftOffhand.SetSkin( 1 ) //blue 1
	}


	//{ "hero_mil_jack_gauntlet_timeshift_skn_01"} // present amber
	//{ "hero_mil_jack_gauntlet_timeshift_skn_01_v1"} // past blue
	//{ "hero_mil_jack_gauntlet_timeshift_skn_01_v2"} // error red
	//{ "hero_mil_jack_gauntlet_timeshift_skn_01_v3"} // off

}

///////////////////////////////////////////////////////////////////////////////////////////////////////
var function GetOppositeTimeline( timeline )
{
	var destinationTimeline
	if ( timeline == TIMEZONE_NIGHT )
		destinationTimeline = TIMEZONE_DAY
	else
		destinationTimeline = TIMEZONE_NIGHT

	return destinationTimeline

}
///////////////////////////////////////////////////////////////////////////////////////////////////////
var function GetEntityTimelinePosition( ent )
{
	//What time period does this ent live in?
	local z = ent.GetOrigin().z
	if ( z < -6000 )
		return TIMEZONE_FROZEN
	else if ( z < 5300 )
		return TIMEZONE_NIGHT
	else
		return TIMEZONE_DAY
}
///////////////////////////////////////////////////////////////////////////////////////////////////////
var function GetTimelinePosition( vector pos )
{
	//What time period does this pos live in?
	local z = pos.z
	if ( z < -6000 )
		return TIMEZONE_FROZEN
	else if ( z < 5300 )
		return TIMEZONE_NIGHT
	else
		return TIMEZONE_DAY
}
///////////////////////////////////////////////////////////////////////////////////////////////////////
void function DebugDrawOnEnt( ent )
{
	expect entity( ent )

	while ( true )
	{
		DebugDrawSphere( ent.GetOrigin(), 16, 255, 255, 255, true, 0.22 )
		wait 0.2
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////
void function WaitTillPlayerTouchesTrigger( trigger )
{
	local result
	while ( 1 )
	{
		result = trigger.WaitSignal( "OnStartTouch" )

		if ( !IsValid( result.activator ) )
			continue
		if ( !result.activator.IsPlayer() )
			continue
		break
	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
function SetFlagWhenBreakablesDestroyed( string flagToSet, string scriptName, string instanceName )
{
	array < entity > breakableFuncBrushes = GetEntArrayByScriptNameInInstance( scriptName, instanceName )
	foreach ( funcBrush in breakableFuncBrushes )
	{
		Assert( !( "flagToSetWhenDestroyed" in funcBrush.s ), "func brush '" + scriptName + "' instanceName '" + instanceName + "' has flag: " +  flagToSet)
		funcBrush.s.flagToSetWhenDestroyed <- flagToSet
	}

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function OnDamagedFuncBrush( entity funcBrush, var damageInfo )
{

	//----------------------
	// Return if not player
	//----------------------
	int damageSourceID = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	float damageAmount = DamageInfo_GetDamage( damageInfo )

	if ( !damageSourceID )
		return

	if ( !damageAmount )
		return

	if ( !attacker )
		return

	if ( !attacker.IsPlayer() )
		return

	//-----------------------------------
	// Do damage if correct damage type
	//-----------------------------------
	var health = funcBrush.s.health
	var breakableType = funcBrush.s.breakableType
	switch( breakableType )
	{
		case BREAKABLE_TYPE_AQUARIUM:
		case BREAKABLE_TYPE_SATCHEL_DEBRIS_MEDIUM_WIDE:
		case BREAKABLE_TYPE_SATCHEL_DEBRIS_MEDIUM:
			DamageSatchelDebris( funcBrush, damageSourceID, damageAmount )
			break
		default:
			Assert( 0, "Unhandled breakableType ' " + breakableType + "' at " + funcBrush.GetOrigin() )
	}


	if ( funcBrush.s.health > 0 )
		return

	DestroyFuncBrushBreakable( funcBrush )
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function DestroyFuncBrushBreakable( funcBrush )
{
	expect entity( funcBrush )

	if ( !IsValid( funcBrush ) )
		return

	//----------------------
	// Debris blows up
	//----------------------
	Signal( funcBrush, "BreakableDestroyed" )

	entity hintTrigger
	if ( ( "hintTrigger" in funcBrush.s ) )
		hintTrigger = expect entity( funcBrush.s.hintTrigger )

	entity fxEnt = expect entity( funcBrush.s.fxEnt )
	asset explosionFx = expect asset( funcBrush.s.fxExplode )
	var explosionSound = funcBrush.s.soundExplode
	vector origin = fxEnt.GetOrigin()
	vector angles = fxEnt.GetAngles()

	PlayFX( explosionFx, origin, angles )
	EmitSoundAtPosition( TEAM_UNASSIGNED, origin, explosionSound )

	//--------------------------------------
	// Swap out damaged/intact if applicable
	//-------------------------------------
	if ( ( "brokenState" in funcBrush.s ) && ( funcBrush.s.brokenState != null ) )
		funcBrush.s.brokenState.Show()

	//--------------------------------------
	// Delete intact version
	//-------------------------------------
	funcBrush.Destroy()

	if ( "flagToSetWhenDestroyed" in funcBrush.s )
	{
		FlagSet( expect string( funcBrush.s.flagToSetWhenDestroyed ) )
	}

	//----------------------
	// Cleanup
	//----------------------
	if ( IsValid( hintTrigger ) )
		hintTrigger.Destroy()
	fxEnt.Destroy()
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function DamageSatchelDebris( funcBrush, damageSourceID, damageAmount )
{
	if ( damageSourceID != eDamageSourceId.mp_weapon_satchel )
		return
	funcBrush.s.health = funcBrush.s.health - damageAmount
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function TriggerHazardThink( entity trigger )
{
	trigger.EndSignal( "OnDeath" )
	trigger.EndSignal( "OnDestroy" )

	int damageAmt
	float interval
	string scriptName = trigger.GetScriptName()
	asset fx
	var sound
	local scriptTypeMask = damageTypes.dissolve | DF_STOPS_TITAN_REGEN

	if ( scriptName.find( "fireSmall" ) != null )
		scriptName = "fireSmall"

	if ( scriptName.find( "fireHuge" ) != null )
		scriptName = "fireHuge"

	if ( scriptName.find( "fireMedium" ) != null )
		scriptName = "fireMedium"

	if ( scriptName.find( "radiation" ) != null )
		scriptName = "radiation"

	string soundDamage = ""
	int damageID = eDamageSourceId.burn

	switch( scriptName )
	{
		case "electricity":
			fx = FX_ELECTRICITY
			sound = SOUND_ELECTRICITY
			scriptTypeMask = damageTypes.dissolve | DF_STOPS_TITAN_REGEN
			damageAmt = 25
			interval = 0.75
			soundDamage = "flesh_electrical_damage_1p"
			damageID = eDamageSourceId.electric_conduit
			break
		case "fireMedium":
			fx = FX_FIRE_MEDIUM
			sound = SOUND_FIRE_MEDIUM
			scriptTypeMask = damageTypes.dissolve | DF_STOPS_TITAN_REGEN
			damageAmt = 25
			interval = 1
			soundDamage = "flesh_fire_damage_1p"
			damageID = eDamageSourceId.burn
			break
		case "fireSmall":
			fx = FX_FIRE_SMALL
			sound = SOUND_FIRE_MEDIUM
			scriptTypeMask = damageTypes.dissolve | DF_STOPS_TITAN_REGEN
			damageAmt = 25
			interval = 1
			soundDamage = "flesh_fire_damage_1p"
			damageID = eDamageSourceId.burn
			break
		case "fireHuge":
			fx = FX_FIRE_HUGE
			sound = SOUND_FIRE_HUGE
			scriptTypeMask = damageTypes.dissolve | DF_STOPS_TITAN_REGEN
			damageAmt = 25
			interval = 1
			soundDamage = "flesh_fire_damage_1p"
			damageID = eDamageSourceId.burn
			break
		case "radiation":
		case "trigger_concourse_radiation":
			fx = FX_RADIATION
			scriptTypeMask = damageTypes.dissolve | DF_STOPS_TITAN_REGEN
			damageAmt = 100
			interval = 1
			soundDamage = "flesh_fire_damage_1p"
			damageID = eDamageSourceId.burn
			break
		default:
			Assert( 0, "Unhandled hazard type ' " + scriptName + "' at " + trigger.GetOrigin() )
	}

	array< entity > linkedEnts = trigger.GetLinkEntArray()
	array< var > fxHandles
	//Assert( linkedEnts.len() > 0, "Hazard trigger at " + trigger.GetOrigin() + " has no linked ents to play fx on" )

	//-------------------
	// Hazard sound/FX
	//--------------------
	foreach( ent in linkedEnts )
		thread HackPlayLoopEffectOnEntity( fx, ent )

	if ( sound )
		thread EmitSoundAtPositionHack( TEAM_UNASSIGNED, trigger.GetOrigin(), sound )

	OnThreadEnd(
		function() : ( trigger, linkedEnts )
		{
			if ( IsValid( trigger ) )
				trigger.Destroy()
			foreach( ent in linkedEnts )
			{
				if ( IsValid( ent ) )
					ent.Destroy()
			}
		}
	)
	//-------------------
	// Damage player
	//--------------------

	var player
	local result
	vector origin
	while ( IsValid( trigger) )
	{

		wait 0.1

		player = null
		result = trigger.WaitSignal( "OnTrigger" )

		//if ( level.isTimeTraveling )
		//	continue

		if ( !IsValid( result.activator ) )
			continue
		if ( result.activator.IsPlayer() )
		{
			player = result.activator
			
			if ( player.s.isTimeTraveling )
				continue

			while ( trigger.IsTouching( player ) )
			{
				player.TakeDamage( damageAmt, svGlobal.worldspawn, svGlobal.worldspawn, { origin = player.GetOrigin(), scriptType = scriptTypeMask, damageSourceId = damageID } )
				CreateShakeRumbleOnly( expect entity( player ).GetOrigin(), 10, 105, interval )
				if ( soundDamage != "" )
					EmitSoundOnEntity( player, soundDamage )
				printt( "Player taking damage: " + damageAmt )
				wait interval
			}
		}
	}

}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function EmitSoundAtPositionHack( int team, vector origin, var sound )
{
	//Need to delay 0.2 before playing at level start, Baker/Barb know this is a big but said will fix next game
	wait 0.2
	EmitSoundAtPosition( team, origin, sound )

}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
// HACK - need better way to play fx on server
void function HackPlayLoopEffectOnEntity( asset fxName, entity ent )
{
	ent.EndSignal( "OnDeath" )
	ent.EndSignal( "OnDestroy" )
	entity fxHandle
	float waitTime



	fxHandle = CreateEntity( "info_particle_system" )
	fxHandle.SetValueForEffectNameKey( fxName )
	fxHandle.kv.VisibilityFlags = ENTITY_VISIBLE_TO_EVERYONE
	fxHandle.kv.start_active = 1
	fxHandle.SetOrigin( ent.GetOrigin() )
	fxHandle.SetAngles( ent.GetAngles() )
	DispatchSpawn( fxHandle )


	OnThreadEnd(
		function() : ( fxHandle )
		{
			DestroyFxIfValid( fxHandle )
		}
	)


	WaitForever()

}


///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function DropHangingOgre( entity titan, entity player )
{
	thread PlayAnim( titan.s.rack, "tr_AI_titanrack_bootup_heavy" )
	PlayAnimTeleport( titan, "ht_AI_titanrack_bootup_heavy", titan.s.rack )
	wait 0.5
	Embark_Allow( player )
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function DropHangingOgreOnFlag( entity titan, string flagToDrop, entity player )
{
	Assert( IsValid( titan ) )
	FlagWait( flagToDrop )
	thread DropHangingOgre( titan, player )
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function GenericSparks( entity ent )
{
	vector origin = ent.GetOrigin()
	vector angles = ent.GetAngles()

	entity fxHandle
	wait ( RandomFloatRange( 0.1, 2.5 ) )

	while( IsValid( ent ) )
	{
		if ( GetBugReproNum() == 007 )
		{
			//fails silently to play fx/sound when it's an info_target
			fxHandle = PlayLoopFXOnEntity( FX_SPARKS, ent )
			EmitSoundOnEntity( ent, SOUND_SPARKS )
		}
		else
		{
			fxHandle = PlayFX( FX_SPARKS, origin, angles )
			EmitSoundAtPosition( TEAM_UNASSIGNED, origin, SOUND_SPARKS )
		}

		wait ( RandomFloatRange( 1.7, 5.2 ) )

		if ( IsValid( fxHandle ) )
		{
			DestroyFxIfValid( fxHandle )
		}
		wait ( RandomFloatRange( 0.1, 0.4 ) )
	}
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function ZombieSpectreSpawnAndDie( entity npc )
{
	npc.EndSignal( "OnDeath" )

	wait ( RandomFloatRange( 0.2, 1.75 ) )

	npc.Die()
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function RackSpawnCallback( entity npc, entity activator )
{
	string scriptName = npc.GetScriptName()

	if ( scriptName == "rusted_spectre" )
		thread ZombieSpectreSpawnAndDie( npc )

}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function DestroyArray( array entities )
{
	foreach( ent in entities )
	{
		if( IsValid( ent ) )
			ent.Destroy()
	}
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function MoveEntityToOppositeTimePeriod( entity ent )
{
	int zOffset = TIME_ZOFFSET
	if ( GetEntityTimelinePosition( ent ) == TIMEZONE_DAY )
		zOffset = TIME_ZOFFSET * -1

	ent.SetOrigin( ent.GetOrigin() + Vector( 0, 0, TIME_ZOFFSET ) )
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function DeleteFireHazards( string scriptName )
{
array< entity > fireTriggers = GetEntArrayByScriptName( scriptName )
	entity fxEnt
	foreach( trigger in fireTriggers )
	{
		fxEnt = trigger.GetLinkEnt()
		fxEnt.Destroy()
		trigger.Destroy()
	}

}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
void function SpawnWallSpectreGroupWhenInRange( entity player, array< entity > propSpawners, int maxToSpawn, string flagToAbort = "", string flagToSetWhenDone = "", float delayMin = 3, float delayMax = 5, string flagToSet = "", bool requireLookAt = false )
{
	Assert( propSpawners.len() >= maxToSpawn,  "Max to spawn( " + maxToSpawn + ") is greater than number of propSpawners (" + propSpawners.len() + ") " )
	int spectresSpawned = 0
	entity spawner

	var spawnerTimezone = GetEntityTimelinePosition( propSpawners[ 0 ] )

	while( spectresSpawned < maxToSpawn )
	{
		if ( ( flagToAbort != "") && ( Flag( flagToAbort ) ) )
			break


		// Don't spawn if player not in the same timezone
		if ( spawnerTimezone != GetEntityTimelinePosition( player ) )
		{
			wait 0.1
			continue

		}

		spawner = GetBestPropSpawnerFromGroup( propSpawners, player, requireLookAt )
		if ( !IsValid( spawner ) )
		{
			wait 0.1
			continue
		}

		spawner.Signal( "PropSpawnerActivate" )
		spectresSpawned++

		if ( ( flagToSet != "" ) && ( !Flag( flagToSet ) ) )
			FlagSet( flagToSet )

		propSpawners.fastremovebyvalue( spawner )
		if ( ( spectresSpawned == maxToSpawn ) && ( flagToSetWhenDone != "" ) )
		{
			FlagSet( flagToSetWhenDone )
			break
		}

		wait( RandomFloatRange( delayMin, delayMax ) )
	}
}
*/

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function SpawnShowcaseGroupWhenInRange( entity player, array< entity > propSpawners, int maxToSpawn, string flagToAbort = "", string flagToSetWhenDone = "", float delayMin = 3, float delayMax = 5, string flagToSet = "", bool requireLookAt = false )
{
	Assert( propSpawners.len() >= maxToSpawn,  "Max to spawn( " + maxToSpawn + ") is greater than number of propSpawners (" + propSpawners.len() + ") " )
	int dudesSpawned = 0
	entity spawnProp

	var spawnerTimezone = GetEntityTimelinePosition( propSpawners[ 0 ] )

	while( dudesSpawned < maxToSpawn )
	{
		if ( ( flagToAbort != "") && ( Flag( flagToAbort ) ) )
			break


		// Don't spawn if player not in the same timezone
		if ( spawnerTimezone != GetEntityTimelinePosition( player ) )
		{
			wait 0.1
			continue

		}

		spawnProp = GetBestPropSpawnerFromGroup( propSpawners, player, requireLookAt )
		if ( !IsValid( spawnProp ) )
		{
			wait 0.1
			continue
		}

		if ( IsSpectreRackDoorSpawner( spawnProp ) )
			spawnProp.Signal( "PropSpawnerActivate" )
		else
			thread ShowcaseSpawn( spawnProp )

		dudesSpawned++

		if ( ( flagToSet != "" ) && ( !Flag( flagToSet ) ) )
			FlagSet( flagToSet )

		propSpawners.fastremovebyvalue( spawnProp )
		if ( ( dudesSpawned == maxToSpawn ) && ( flagToSetWhenDone != "" ) )
		{
			FlagSet( flagToSetWhenDone )
			break
		}

		wait( RandomFloatRange( delayMin, delayMax ) )
	}

	if ( FlagExists( flagToSetWhenDone ) )
		FlagSet( flagToSetWhenDone )

}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
entity function GetBestPropSpawnerFromGroup( array< entity > propSpawners, entity player, bool requireLookAt = false )
{
	entity bestSpawnerProp

	array< entity > propSpawnersOrderedClosest = ArrayClosest( propSpawners, player.GetOrigin() )

	float minDistSqr = 128 * 128
	bool doTrace = true
	float degrees = 90

	foreach( spawnerProp in propSpawnersOrderedClosest )
	{
		if ( DistanceSqr( player.GetOrigin(), spawnerProp.GetOrigin() ) < minDistSqr )
			continue

		if ( TS_WithinPlayerFOV( spawnerProp.GetOrigin() + Vector( 0, 0, 16) ) )
		{
			bestSpawnerProp = spawnerProp
			break
		}
	}

	if ( ( !IsValid( bestSpawnerProp ) ) && ( requireLookAt == false ) )
		bestSpawnerProp = GetClosest( propSpawners, player.GetOrigin() )

	return bestSpawnerProp
}

//////////////////////////////////////////////////////////////
// HACK: Move to utility?
bool function TS_WithinPlayerFOV( targetPos, MinDot = 0.8 )
{
	expect vector( targetPos )
	entity player = GetPlayerArray()[0]
	if ( !player )
		return false

	float dot = VectorDot_PlayerToOrigin( player, targetPos )
	if ( dot < MinDot )
		return false

	return true
}
//////////////////////////////////////////////////////////////
void function RemoveBlocker( string scriptName )
{
	array <entity> blockers = GetEntArrayByScriptName( scriptName )
	Assert( blockers.len() > 0, "No blockers found with scriptName " + scriptName )
	foreach( blocker in blockers )
	{
		blocker.Hide() //Does this even do anything anymore?
		blocker.MakeInvisible()
		blocker.NotSolid()
	}

}
//////////////////////////////////////////////////////////////
void function RestoreBlocker( string scriptName )
{
	array <entity> blockers = GetEntArrayByScriptName( scriptName )
	Assert( blockers.len() > 0, "No blockers found with scriptName " + scriptName )
	foreach( blocker in blockers )
	{
		blocker.Show() //Does this even do anything anymore?
		blocker.MakeVisible()
		blocker.Solid()
	}
}

//////////////////////////////////////////////////////////////
void function TempExplosion( vector origin )
{
	CreateAirShake( origin, 10, 105, 1.25 )
	PlayFX( FX_BREAKABLE_SATCHEL_DEBRIS_MEDIUM, origin )
	EmitSoundAtPosition( TEAM_UNASSIGNED, origin, SOUND_BREAKABLE_SATCHEL_DEBRIS_MEDIUM )
}
//////////////////////////////////////////////////////////////
void function DestroyEntByScriptName( string scriptName )
{
	entity ent = GetEntByScriptName( scriptName )
	Assert( IsValid( ent ) )
	ent.Destroy()

}

//////////////////////////////////////////////////////////////
void function DestroyInstancesByScriptInstanceName( string scriptName, string instanceName )
{
	array< entity > ents = GetEntArrayByScriptNameInInstance( scriptName, instanceName )
	Assert( ents.len() > 0, "No entities with script_name/instance_name combo: " + scriptName + " / " + instanceName )
	foreach( ent in ents )
		ent.Destroy()
}


/////////////////////////////////////////////////////////////////////////////////////////
void function WaittillSomeDudesAreDead( string scriptName, int numberToWaitToBeDead, string flagToSet = "" )
{
	array< entity > entities = GetEntArrayByScriptName( scriptName )
	Assert( entities.len() > 0 )
	array< entity > dudes
	foreach( ent in entities )
	{
		if ( ent.IsNPC() )
			dudes.append( ent )
	}
	if ( dudes.len() == 0 )
	{
		printt( "Warning: WaittillSomeDudesAreDead returning. No npcs exist for scriptName " + scriptName )
		return
	}
	Assert( dudes.len() >= numberToWaitToBeDead )
	int dudesThatHaveDied = 0

	while( dudesThatHaveDied < numberToWaitToBeDead )
	{
		wait 0.1
		foreach( dude in dudes )
		{
			if ( !IsAlive( dude ) )
			{
				dudesThatHaveDied++
				dudes.fastremovebyvalue( dude )
			}
		}
	}

	if ( flagToSet != "" )
		FlagSet( flagToSet )

}


/////////////////////////////////////////////////////////////////////////////////////////
void function WaittillPlayerSwitchesTimezone( var timeZoneToWaitFor )
{

	if ( level.timeZone == timeZoneToWaitFor )
		return

	while( level.timeZone != timeZoneToWaitFor )
		wait 0.1

	wait 0.1
}

/////////////////////////////////////////////////////////////////////////////////////////
void function TimeshiftPlayerThink( entity player )
{
	player.EndSignal( "OnDeath" )

	vector posInOtherTimeline
	vector playerOrigin
	var timeZoneCurrent
	float minDist = 32
	float minDistSqr = minDist * minDist
	vector idealPosInOvergrown
	vector idealPosInPristine

	wait 0.1

	while( true )
	{
		WaitFrame()

		playerOrigin = player.GetOrigin()
		timeZoneCurrent = GetTimelinePosition( playerOrigin )
		if ( timeZoneCurrent == TIMEZONE_FROZEN )
			return

		posInOtherTimeline = GetPosInOtherTimeline( playerOrigin )

		if ( timeZoneCurrent == TIMEZONE_NIGHT )
		{
			idealPosInOvergrown = playerOrigin
			idealPosInPristine = posInOtherTimeline
		}
		else if ( timeZoneCurrent == TIMEZONE_DAY )
		{
			idealPosInOvergrown = posInOtherTimeline
			idealPosInPristine = playerOrigin
		}
		else
			printl( "Player in frozen world, no need to run the TimeshiftPlayerThinkThread anymore" )

		//-------------------------------------------------------------
		// get last good pos in current timeline (player's pos, usually)
		//-------------------------------------------------------------
		if ( !PlayerPosInSolid( player, playerOrigin ) )
		{
			if ( timeZoneCurrent == TIMEZONE_NIGHT )
				//file.lastGoodTimeshiftPosOvergrown = playerOrigin
				player.s.lastGoodTimeshiftPosOvergrown = playerOrigin
			else if ( timeZoneCurrent == TIMEZONE_DAY )
				//file.lastGoodTimeshiftPosPristine = playerOrigin
				player.s.lastGoodTimeshiftPosPristine = playerOrigin
			else
				printl( "Player in frozen world, no need to run the TimeshiftPlayerThinkThread anymore" )
		}
		else
		{
			if ( GetBugReproNum() == 88 )
				printt( "Player is stuck in solid in home timeline: " + playerOrigin )
		}

		//--------------------------------------
		// get last good pos in other timeline
		//--------------------------------------
		if ( !PlayerPosInSolid( player, posInOtherTimeline ) )
		{
			if ( timeZoneCurrent == TIMEZONE_NIGHT )
			{
				//file.lastGoodTimeshiftPosPristine = posInOtherTimeline
				player.s.lastGoodTimeshiftPosPristine = posInOtherTimeline

			}
			else if ( timeZoneCurrent == TIMEZONE_DAY )
			{
				//file.lastGoodTimeshiftPosOvergrown = posInOtherTimeline
				player.s.lastGoodTimeshiftPosOvergrown = posInOtherTimeline
			}
			else
				printl( "Player in frozen world, no need to run the TimeshiftPlayerThinkThread anymore" )
		}
		else
		{
			if ( GetBugReproNum() == 88 )
			{
				printt( "******WARNING: player would be in solid in other timeline: " + posInOtherTimeline )
				thread DebugDrawBadCollisionBox( posInOtherTimeline )
			}


		}

		//-------------------------------------------
		// Assert if vectors are in the wrong timeline
		//-------------------------------------------
		//Assert ( GetTimelinePosition( file.lastGoodTimeshiftPosPristine ) == TIMEZONE_DAY, "lastGoodTimeshiftPosPristine ( " + file.lastGoodTimeshiftPosPristine + " ) is not in the proper timeZone" )
		//Assert ( GetTimelinePosition( file.lastGoodTimeshiftPosOvergrown ) == TIMEZONE_NIGHT, "lastGoodTimeshiftPosPristine ( " + file.lastGoodTimeshiftPosPristine + " ) is not in the proper timeZone" )
		Assert ( GetTimelinePosition( player.s.lastGoodTimeshiftPosPristine ) == TIMEZONE_DAY, "lastGoodTimeshiftPosPristine ( " + player.s.lastGoodTimeshiftPosPristine + " ) is not in the proper timeZone" )
        Assert ( GetTimelinePosition( player.s.lastGoodTimeshiftPosOvergrown ) == TIMEZONE_NIGHT, "lastGoodTimeshiftPosPristine ( " + player.s.lastGoodTimeshiftPosPristine + " ) is not in the proper timeZone" )
		
		//---------------------------------------------------------------
		// Check if disparity between ideal pos and proposed is too huge
		//----------------------------------------------------------------
		//if ( ( DistanceSqr( file.lastGoodTimeshiftPosOvergrown, idealPosInOvergrown ) > minDistSqr ) && ( GetBugReproNum() == 88 ) )
		if ( ( DistanceSqr( player.s.lastGoodTimeshiftPosOvergrown, idealPosInOvergrown ) > minDistSqr ) && ( GetBugReproNum() == 88 ) )
		{
			printl( "*****************WARNING:")
			//printt( "lastGoodTimeshiftPosOvergrown( " + file.lastGoodTimeshiftPosOvergrown + " > " + minDist + " from ( " +  idealPosInOvergrown + ")" )
			printt( "lastGoodTimeshiftPosOvergrown( " + player.s.lastGoodTimeshiftPosOvergrown + " > " + minDist + " from ( " +  idealPosInOvergrown + ")" )
			//thread DebugDrawBadTeleportBoxes( file.lastGoodTimeshiftPosOvergrown, idealPosInOvergrown )
			var pos = player.s.lastGoodTimeshiftPosOvergrown
			thread DebugDrawBadTeleportBoxes( expect vector( pos ), idealPosInOvergrown )
		}
		//if ( ( DistanceSqr( file.lastGoodTimeshiftPosPristine, idealPosInPristine ) > minDistSqr ) && ( GetBugReproNum() == 88 ) )
		if ( ( DistanceSqr( player.s.lastGoodTimeshiftPosPristine, idealPosInPristine ) > minDistSqr ) && ( GetBugReproNum() == 88 ) )
		{
			printl( "*****************WARNING:")
			//printt( "lastGoodTimeshiftPosPristine( " + file.lastGoodTimeshiftPosPristine + " > " + minDist + " from ( " +  idealPosInPristine + ")" )
			printt( "lastGoodTimeshiftPosPristine( " + player.s.lastGoodTimeshiftPosPristine + " > " + minDist + " from ( " +  idealPosInPristine + ")" )
			//thread DebugDrawBadTeleportBoxes( file.lastGoodTimeshiftPosPristine, idealPosInPristine )
			var pos = player.s.lastGoodTimeshiftPosPristine
			thread DebugDrawBadTeleportBoxes( expect vector( pos ), idealPosInPristine )
		}
		//Assert( DistanceSqr( file.lastGoodTimeshiftPosOvergrown, idealPosInOvergrown ) < minDistSqr, "lastGoodTimeshiftPosOvergrown( " + file.lastGoodTimeshiftPosOvergrown + " > " + minDist + " from ( " +  idealPosInOvergrown + ")" )
		//Assert( DistanceSqr( file.lastGoodTimeshiftPosPristine, idealPosInPristine ) < minDistSqr, "lastGoodTimeshiftPosPristine( " + file.lastGoodTimeshiftPosPristine + " > " + minDist + " from ( " +  idealPosInPristine + ")" )

	}
}


void function DebugDrawBadTeleportBoxes( vector badPos, vector goodPos )
{

	vector boxSize1 = Vector(-16,-16,0)
	vector boxSize2 = Vector(16,16,72)
	vector zOffset = Vector( 0, 0, 36)

	while( true )
	{
		wait 0.15
												//r, g, b, a, drwTime
		DebugDrawBox( badPos, boxSize1, boxSize2, 255, 0, 0, 1, 0.15 )
		DebugDrawBox( goodPos, boxSize1, boxSize2, 0, 255, 0, 1, 0.15 )
		DebugDrawLine( badPos + zOffset, goodPos + zOffset, 255, 0, 0, true, 0.15 )
		DebugDrawText( badPos + zOffset, "Bad TimeTravel Teleports", true, 0.15 )
	}

}


void function DebugDrawAudioLogNumber( entity audioLogModel, string number )
{
	audioLogModel.Signal( "AudioLogDebugDraw" )
	audioLogModel.EndSignal( "AudioLogDebugDraw" )

	vector pos = audioLogModel.GetOrigin()
	while( true )
	{
		wait 0.15
		DebugDrawText( pos, number, true, 0.15 )
	}


}
void function DebugDrawBadCollisionBox( vector badPos )
{

	vector boxSize1 = Vector(-16,-16,0)
	vector boxSize2 = Vector(16,16,72)
	vector zOffset = Vector( 0, 0, 36)

	while( true )
	{
		wait 0.15
												//r, g, b, a, drwTime
		DebugDrawBox( badPos, boxSize1, boxSize2, 255, 255, 0, 1, 0.15 )
		DebugDrawText( badPos + zOffset, "Timeshift into solid", true, 0.15 )
	}

}


//////////////////////////////////////////////////////////////////////////////////////
void function OnPlayerDamage_TimeShift( entity player, var damageInfo )
{
	if ( level.allowTimeTravel == false )
		return

	int damageSourceID = DamageInfo_GetDamageSourceIdentifier( damageInfo )
	entity attacker = DamageInfo_GetAttacker( damageInfo )
	local damageAmount = DamageInfo_GetDamage( damageInfo )

	if ( !IsValid( attacker ) )
		return

	if ( !attacker.IsNPC() )
		return

	int playerHealth = player.GetHealth()
	int playerMaxHealth = player.GetMaxHealth()

	if ( !Flag( "DisplayTheDamageHint" ) )
		return

	//if ( playerHealth > ( playerMaxHealth - 50 ) )
		//return

	//Show damage hint if we are at 60% or lower
	printt( "Player health: ", playerHealth / playerMaxHealth.tofloat() )
	if ( playerHealth / playerMaxHealth.tofloat() <= 0.90 )
		thread DamageHintTillTimetravel( player )

}

//////////////////////////////////////////////////////////////////////////////////////
function DamageHintTillTimetravel( entity player )
{

	if ( file.isDisplayingDamageText )
		return

	file.isDisplayingDamageText = true
	file.isDisplayingTimeshiftHint = true

	player.EndSignal( "OnDeath" )
	player.Signal( "DisplayingDamageHint" )
	player.EndSignal( "DisplayingDamageHint" )
	EndSignal( player, "OnTimeFlippedTimezoneNight" )
	EndSignal( player, "OnTimeFlippedTimezoneDay" )

	OnThreadEnd(
	function() : ( player )
		{
			ClearOnscreenHint( player )
			file.isDisplayingDamageText = false
			file.isDisplayingTimeshiftHint = false
		}
	)

	thread DisplayOnscreenHint( player, "timeshift_hint_combat", 3.0 )
	wait 3

}


/////////////////////////////////////////////////////////////////////////////////////////

/*
void function TriggerTimehintThink( entity trigger )
{
	wait 1

	trigger.EndSignal( "OnDestroy" )
	string flagToAbort = trigger.GetTargetName()
	Assert( IsValid( flagToAbort ) )
	if ( Flag( flagToAbort ) )
		return
	FlagEnd( flagToAbort )

	var timeZoneToShowHint = GetEntityTimelinePosition( trigger )


	local result
	entity player

	while( true )
	{
		result = trigger.WaitSignal( "OnTrigger" )

		if ( !IsValid( result.activator ) )
			continue
		if ( !result.activator.IsPlayer() )
			continue
		if ( result.activator.IsTitan() )
			continue

		player = expect entity( result.activator )

		break
	}

	thread TimeshiftHint( player, timeZoneToShowHint, flagToAbort, "#BLANK_TEXT", trigger )

}
*/

/////////////////////////////////////////////////////////////////////////////////////////
void function TimeshiftHint( entity player, var timeZoneToShowHint, string flagToAbort, string message, entity trigger = null )
{
	player.EndSignal( "OnDeath" )
	if( !IsValid( player ) )
		return

	if ( IsValid( trigger ) )
		trigger.EndSignal( "OnDestroy")

	Assert( FlagExists( flagToAbort ) )
	if ( Flag( flagToAbort ) )
		return
	FlagEnd( flagToAbort )

	//--------------------------------
	// Display in any timezone?
	//--------------------------------
	bool hintIsTimezoneSpecific = true
	if ( timeZoneToShowHint == TIMEZONE_ALL )
		hintIsTimezoneSpecific = false

	//--------------------------------`
	// Custom hint message or default?
	//--------------------------------
	string hintMessage
	if ( message != "" )
		hintMessage = message
	else
	{
		if ( timeZoneToShowHint == TIMEZONE_DAY )
			hintMessage = "timeshift_hint_present"
		else if ( timeZoneToShowHint == TIMEZONE_NIGHT )
			hintMessage = "timeshift_hint_past"
		else if ( timeZoneToShowHint == TIMEZONE_ALL )
			hintMessage = "timeshift_hint_default"
	}

	//-----------
	// Cleanup
	//-----------
	/*
	OnThreadEnd(
	function() : ( trigger )
		{
			ClearOnscreenHint( player )
			if ( IsValid( trigger ) )
				trigger.Destroy()
		}
	)
	*/

	//----------------------------
	// Hint message display logic
	//----------------------------

	var hintTimezone = GetOppositeTimeline( timeZoneToShowHint )

	bool isDisplayingMsg = false
	file.isDisplayingTimeshiftHint = false

	float ticker = 0.0
	float displayTime = 5.0
	float increment = 0.25

	//---------------------------------------------
	// Don't be condescending, before displaying
	//------------------------------------------------
	wait 2

	while( true )
	{
		wait increment

		//----------------------------------------------------
		// No message if player not touching (optional) trigger
		//----------------------------------------------------
		if ( IsValid( trigger ) )
		{
			if ( !trigger.IsTouching( player ) )
			{
				ClearOnscreenHint( player )
				continue
			}

		}

		//----------------------------------------------------
		// No message if player has swapped to correct timeline
		//----------------------------------------------------
		if ( ( GetEntityTimelinePosition( player ) != timeZoneToShowHint ) && ( hintIsTimezoneSpecific ) )
		{
			ClearOnscreenHint( player )
			continue
		}

		//----------------------------------------------------
		// Clear msg and wait if we've displayed it long enough
		//----------------------------------------------------
		if ( ticker >= displayTime )
		{
			ClearOnscreenHint( player )
			isDisplayingMsg = false
			file.isDisplayingTimeshiftHint = false
			wait 5
		}

		//----------------------------------------------------
		// Increment ticker if we are already displaying message
		//----------------------------------------------------
		if ( isDisplayingMsg )
		{
			ticker = ticker + increment
			continue
		}
		//------------------------------------
		// Display the hint, reset the ticker
		//------------------------------------
		else
		{
			ticker = 0.0
			DisplayOnscreenHint( player, hintMessage, displayTime )
			isDisplayingMsg = true
			file.isDisplayingTimeshiftHint = true
		}

	}
}

///////////////////////////////////////////////////////////////////////////////////////////////////
function HACK_DisableTurret( turret, shield = false )
{
	//turret.EndSignal( "OnDestroy" )


	turret.EnableNPCFlag( NPC_IGNORE_ALL )
	turret.SetNoTarget( true )
	//turret.EnableNPCFlag( NPC_DISABLE_SENSING )
	turret.Anim_ScriptedPlay( "undeploy" )
	wait 1.0
	turret.DisableTurret()
	turret.UnsetUsable()
	turret.SetTitle( "" )

	if ( !shield )
		turret.Signal( "TurretShieldWallRelease" )
	//turret.Anim_Stop()
}

function HACK_EnableTurret( turret )
{
	//turret.EndSignal( "OnDestroy" )

	turret.Anim_ScriptedPlay( "deploy" )
	wait 1.0
	turret.EnableTurret()
	turret.kv.AccuracyMultiplier = 100

	//wait 1.0
	//turret.Anim_Stop()
	turret.DisableNPCFlag( NPC_IGNORE_ALL )
	turret.SetNoTarget( false )
	//turret.DisableNPCFlag( NPC_DISABLE_SENSING )
}

void function OnSpawnedScriptedSwitch( entity button )
{
	array< entity > linkedEnts = button.GetLinkEntArray()
	array< entity > turrets

	foreach( entity ent in linkedEnts )
	{
		if ( ent.GetClassName() == "npc_turret_sentry")
			turrets.append( ent )
	}

	if ( turrets.len() > 0 )
		thread TurretButtonThink( button, turrets )
}
//////////////////////////////////////////////////////////////////////////////////////////
void function TurretButtonThink( entity button, array< entity > turrets )
{

	foreach( turret in turrets )
		thread HACK_DisableTurret( turret )

	var player //hack: have to use "var" when waiting on a usable signal or trigger

	string flagRequired = expect string( button.kv.scr_flagRequired )
	if ( flagRequired != "" )
		FlagWait( flagRequired )

	button.SetUsePrompts( "#TIMESHIFT_HINT_TURRET_USE" , "#TIMESHIFT_HINT_TURRET_USE" )

	while( true )
	{
		button.WaitSignal( "OnActivate" )
		break
	}

	if ( !Flag( "AtLeastOneBunkerTurretRestored" ) )
		FlagSet( "AtLeastOneBunkerTurretRestored" )


	string scriptName = button.GetScriptName()
	if ( ( IsValid( scriptName ) ) && ( scriptName == "button_bunker_turrets_fence" ) )
		FlagSet( "TurretsNearBunkerFenceActivated" )

	foreach( turret in turrets )
	{
		thread HACK_EnableTurret( turret )
	}
}


/////////////////////////////////////////////////////////////////////////////////////////
entity function GetNpcByScriptName( string scriptName )
{

	array< entity > ents = GetEntArrayByScriptName( scriptName )
	array< entity > npcs
	foreach( ent in ents )
	{
		if ( ent.IsNPC() )
			npcs.append( ent )
	}

	Assert( npcs.len() > 0, "No NPCs found with script name: " + scriptName )
	Assert( npcs.len() < 2, "Multiple NPCs ( " + npcs.len() + " ) found with scriptName: " + scriptName )

	return npcs[ 0 ]
}


entity function CreateLoudspeakerEnt( vector origin )
{
	entity loudspeakerEnt = CreateEntity( "info_target" )
	loudspeakerEnt.kv.spawnflags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT
	DispatchSpawn( loudspeakerEnt )
	loudspeakerEnt.SetOrigin( origin )

	return loudspeakerEnt
}

/*
void function BatteryMoveSounds( entity leftBattery, entity rightBattery )
{
	entity soundEnt = leftBattery
	EmitSoundOnEntity( soundEnt, "timeshift_battery_conduit_stop" )
	EmitSoundOnEntity( soundEnt, "timeshift_battery_conduit_move_loop" )
	wait 1.5
	StopSoundOnEntity( soundEnt, "timeshift_battery_conduit_move_loop" )
	soundEnt = rightBattery
	EmitSoundOnEntity( soundEnt, "timeshift_battery_conduit_stop" )
}
*/


/*
void function BrokenBatteryMoveSounds( entity leftBattery )
{
	FlagEnd( "bunker_move_battery" )

	entity soundEnt = leftBattery

	while( !Flag( "bunker_move_battery" ) )
	{


		OnThreadEnd(
		function() : ( soundEnt )
			{
				StopSoundOnEntity( soundEnt, "timeshift_battery_conduit_move_loop" )
			}
		)

		FlagWait( "broken_battery_moved_to_node0" )
		StopSoundOnEntity( soundEnt, "timeshift_battery_conduit_move_loop" )
		EmitSoundOnEntity( soundEnt, "timeshift_battery_conduit_stop" )
		wait 1
		EmitSoundOnEntity( soundEnt, "timeshift_battery_conduit_move_loop" )

		FlagWait( "broken_battery_moved_to_node1" )
		EmitSoundOnEntity( soundEnt, "timeshift_battery_conduit_stop" )

		FlagWait( "broken_battery_moved_to_node2" )
		EmitSoundOnEntity( soundEnt, "timeshift_battery_conduit_stop" )
		StopSoundOnEntity( soundEnt, "timeshift_battery_conduit_move_loop" )
		wait 0.75

		EmitSoundOnEntity( soundEnt, "timeshift_battery_conduit_move_loop" )
		FlagWait( "broken_battery_moved_to_node3" )
		EmitSoundOnEntity( soundEnt, "timeshift_battery_conduit_stop" )
		StopSoundOnEntity( soundEnt, "timeshift_battery_conduit_move_loop" )
		wait 0.75

		EmitSoundOnEntity( soundEnt, "timeshift_battery_conduit_move_loop" )

	}
}

*/


/*

void function FuelPanelSounds( vector origin, string flagToStart, string flagToStop )
{
	FlagWait( flagToStart )
	EmitSoundAtPosition( TEAM_UNASSIGNED, origin, "door_stop" )


	EmitSoundAtPosition( TEAM_UNASSIGNED, origin, "door_open_loop" )

	FlagWait( flagToStop )
	StopSoundAtPosition( origin, "door_open_loop")
	EmitSoundAtPosition( TEAM_UNASSIGNED, origin, "door_stop" )
}

*/


void function DestroyIfValid( string scriptName )
{
	array< entity > ents = GetEntArrayByScriptName( scriptName )
	foreach( ent in ents )
	{
		if ( IsValid( ent ) )
			ent.Destroy()
	}
}


/////////////////////////////////////////////////////////////////////////////////////////
function SkyboxStart()
{
	wait 1.5
	local skyCam = GetEnt( "skybox_cam_night" )
	foreach ( player in GetPlayerArray() )
	{
		player.SetSkyCamera( skyCam )
	}
}



////////////////////////////////////////////////////////////////////////////////////////////////////
void function SleepingSpectreFX( entity spectreModel, string signalToAbort )
{
	spectreModel.EndSignal( "OnDestroy" )
	spectreModel.EndSignal( signalToAbort )

	entity fxEyeSparksLeft
	entity fxEyeSparksRight

	array< entity > fxArray
	fxArray.append( fxEyeSparksLeft )
	fxArray.append( fxEyeSparksRight )

	//fxFullBodyEffect = PlayFXOnEntity( <whatever>, spectreModel, "TAG" )

	while( true )
	{

		OnThreadEnd(
		function() : ( fxArray )
			{
				foreach( fx in fxArray )
					DestroyFxIfValid( fx )
			}
		)

//		ModelFX_EnableGroup( spectreModel, "friend_lights" )

		wait( RandomFloatRange( 2, 3.75 ) )

//		ModelFX_DisableGroup( spectreModel, "friend_lights" )

		fxEyeSparksLeft = PlayFXOnEntity( FX_SPARKS, spectreModel, "vent_left_out" )
		fxEyeSparksRight = PlayFXOnEntity( FX_SPARKS, spectreModel, "vent_right_out" )
		EmitSoundOnEntity( spectreModel, SOUND_SPARKS )
		wait( RandomFloatRange( 0.2, 0.25 ) )
		fxEyeSparksLeft.Fire( "Stop" )
		fxEyeSparksLeft.Fire( "DestroyImmediately" )
		fxEyeSparksLeft.Destroy()
		fxEyeSparksRight.Fire( "Stop" )
		fxEyeSparksRight.Fire( "DestroyImmediately" )
		fxEyeSparksRight.Destroy()


		fxEyeSparksLeft = PlayFXOnEntity( FX_SPARKS, spectreModel, "vent_left_out" )
		fxEyeSparksRight = PlayFXOnEntity( FX_SPARKS, spectreModel, "vent_right_out" )
		EmitSoundOnEntity( spectreModel, SOUND_SPARKS )
		wait( RandomFloatRange( 0.3, 0.5 ) )
		fxEyeSparksLeft.Fire( "Stop" )
		fxEyeSparksLeft.Fire( "DestroyImmediately" )
		fxEyeSparksLeft.Destroy()
		fxEyeSparksRight.Fire( "Stop" )
		fxEyeSparksRight.Fire( "DestroyImmediately" )
		fxEyeSparksRight.Destroy()

		wait( RandomFloatRange( 0.1, 0.25 ) )


	}
}

///////////////////////////////////////////////////////////////
void function CleanupEnts( string scriptName )
{
	array<entity> entArray = GetEntArrayByScriptName( scriptName )
	foreach( ent in entArray )
	{
		if( IsValid( ent ) )
			ent.Destroy()
	}

}

///////////////////////////////////////////////////////////////
void function CleanupAI( entity player, string triggerScriptName = "", immediate = false )
{
	if ( !IsValid( player ) )
		return

	array<entity> npcArray = GetNPCArray()

	if ( npcArray.len() == 0 )
		return

	//--------------------------------------------------
	// Optional trigger to specify which npcs to select
	//--------------------------------------------------
	if ( triggerScriptName != "" )
	{

		entity trigger = GetEntByScriptName( triggerScriptName )
		vector triggerMins = trigger.GetBoundingMins()
		vector triggerMaxs = trigger.GetBoundingMaxs()
		bool entIsInsideTrigger

		for ( int i = npcArray.len() - 1; i >= 0; i-- ) //loop backward through array since we are removing entries
		{


			//HACK: Titans and marvins aren't registering IsTouching
			if ( ( triggerScriptName == "trigger_ai_pristine" ) && ( GetEntityTimelinePosition( npcArray[ i ] ) == TIMEZONE_DAY ) )
			{
				if ( !trigger.IsTouching( npcArray[ i ] ) )
				{
					printl( "Ent " + ( npcArray[ i ] ).GetClassName() + " at " + npcArray[ i ].GetOrigin() + " is within trigger " + triggerScriptName + " but IsTouching returns false" )
					continue
				}
			}

			if ( !trigger.IsTouching( npcArray[ i ] ) )
			{
				//Remove the npc
				npcArray.fastremove( i )
			}
		}
	}


	if ( npcArray.len() == 0	 )
		return

	if ( immediate )
	{
		foreach( npc in npcArray )
		{
			if ( ( IsAlive( npc ) ) && ( npc.GetTeam() != TEAM_MILITIA ) )
				npc.Destroy()
		}

		return
	}

	//--------------------------------------------------
	// Delete all NPCs when out of sight
	//--------------------------------------------------
	while ( npcArray.len() > 0 )
	{
		ArrayRemoveDead( npcArray )
		for ( int i = npcArray.len() - 1; i >= 0; i-- ) //loop backward through array since we are removing entries
		{
			if ( npcArray[ i ].GetTeam() != TEAM_IMC )
			{
				npcArray.fastremove( i )
				continue
			}
			thread DeleteNpcWhenOutOfSight( npcArray[ i ], player )
			npcArray.fastremove( i )
		}
		wait 0.1
	}
}

///////////////////////////////////////////////////////////////
void function DeleteNpcWhenOutOfSight( entity npc, entity player )
{
	if ( !IsValid( npc ) )
		return

	if ( !IsValid( player ) )
		return

	if ( !npc.IsNPC() )
		return

	npc.EndSignal( "OnDestroy" )
	player.EndSignal( "OnDeath" )

	//don't run this func twice on the same npc)
	if ( npc.l.npcMarkedForCleanup == true )
		return

	npc.l.npcMarkedForCleanup = true

	float minDistSqr = 1024 * 1024
	bool doTrace = true
	float degrees = 90

	while( IsAlive( npc ) )
	{
		WaitFrame()

		if ( DistanceSqr( player.GetOrigin(), npc.GetOrigin() ) < minDistSqr )
			continue

		if ( PlayerCanSee( player, npc, doTrace, degrees ) )
			continue

		npc.Destroy()
		break
	}

}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/*
void function TimeFlux( entity player, string triggerNameToDoFlux, string flagToAbort = "", int maxSwaps = -1, float minFluxTime = 0.75, maxFluxTime = 2 )
{
	if ( !IsValid( player ) )
		return
	if ( ( flagToAbort != "" ) && ( Flag( flagToAbort ) ) )
		return

	entity triggerToDoFluxIn = GetEntByScriptName( triggerNameToDoFlux )
	entity lookTarget = triggerToDoFluxIn.GetLinkEnt()
	var homeTimeZone = GetEntityTimelinePosition( triggerToDoFluxIn )
	var destTimeZone = GetOppositeTimeline( homeTimeZone )
	float fluxTime
	int swapCount = 0

	float fadeTime = 0.3
	float holdFadeTime = 0


	player.EndSignal( "OnDeath" )

	if ( flagToAbort != "" )
		FlagEnd( flagToAbort )


	OnThreadEnd(
	function() : ( player, homeTimeZone )
		{
			if ( !IsValid( player ) )
				return
			if ( GetEntityTimelinePosition( player ) != homeTimeZone )
				thread SwapTimelinesScripted( player, homeTimeZone )
		}
	)



	while( true )
	{
		wait RandomFloatRange( 0.2, 0.5 )

		//--------------------------------------------------
		// Player in home timezone with all requirements met
		//--------------------------------------------------
		if ( ( GetEntityTimelinePosition( player ) == homeTimeZone ) && ( TS_WithinPlayerFOV( lookTarget.GetOrigin(), 0.7 ) ) && ( triggerToDoFluxIn.IsTouching( player ) ) )
		{
			thread SwapTimelinesScripted( player, destTimeZone )
			fluxTime = RandomFloatRange( minFluxTime, maxFluxTime )
			wait fluxTime

		}

		//--------------------------------------------------
		// Player in dest timezone...swap back to home timezone
		//--------------------------------------------------
		if ( GetEntityTimelinePosition( player ) == destTimeZone )
		{
			thread SwapTimelinesScripted( player, homeTimeZone )
			fluxTime = RandomFloatRange( minFluxTime, maxFluxTime )
			wait fluxTime
			swapCount++
		}

		//---------------------------------------
		// Early out if we've done enough swaps
		//----------------------------------------
		if ( ( maxSwaps != -1 ) && ( swapCount >= maxSwaps ) )
			break

	}

}

*/

///////////////////////////////////////////////////////////////////////////////////////////////////////
void function SwapTimelinesScripted( entity player, var timeZone )
{
	Remote_CallFunction_NonReplay( player, "ServerCallback_ScriptedTimeshiftStart", timeZone )

	//-------------------
	// crescendo sound
	//-------------------
	if ( timeZone == TIMEZONE_DAY )
		EmitSoundOnEntity( player, "Timeshift_Scr_InvoluntaryShift2Past_Start" )
	else
		EmitSoundOnEntity( player, "Timeshift_Scr_InvoluntaryShift2Present_Start" )

	wait 0.55
	//-------------------
	// Scripted timeshift FX
	//-------------------

	//Mostly done on the client

	wait 0.8
							//(		 amplitude 	frequency 	duration
	CreateAirShake( player.GetOrigin(), 10, 		50, 		1.4,     20000 )
	wait 0.4

	//-------------------
	// Swap timelines
	//-------------------
	SwapTimelines( player, timeZone )


	//phaseshift_postfx_forceOn 1
}

///////////////////////////////////////////////////////////////////////////////////////////////////////




/*
void function MakeSpectreOwnedByPlayer( entity spectre, entity player )
{
	spectre.EnableNPCFlag( NPC_IGNORE_ALL )
	spectre.SetNoTarget( true )
	//spectre.SetOwner( player )
	//spectre.SetOwnerPlayer( player )
	//spectre.SetBossPlayer( player )
	SetTeam( spectre, TEAM_MILITIA )

	spectre.SetTitle( "" )
	SetTargetName( spectre, "" )


	int followBehavior = GetDefaultNPCFollowBehavior( spectre )
	spectre.InitFollowBehavior( player, followBehavior )
	spectre.DisableBehavior( "Assault" )
	spectre.DisableNPCFlag( NPC_ALLOW_PATROL | NPC_ALLOW_INVESTIGATE | NPC_USE_SHOOTING_COVER )
	spectre.EnableBehavior( "Follow" )

}
*/

/////////////////////////////////////////////////////////////////////////////////////////
entity function CreateBestLoudspeakerEnt( entity player, var timeZone, entity existingEnt = null )
{
	entity soundEnt = existingEnt
	if ( existingEnt == null)
		soundEnt = CreateLoudspeakerEnt( player.GetOrigin() + Vector( 0, 0, 100 ) )
	if ( GetEntityTimelinePosition( soundEnt ) != timeZone )
		soundEnt.SetOrigin( GetPosInOtherTimeline( soundEnt.GetOrigin() ) )

	//randomize position
	vector baseOrigin = soundEnt.GetOrigin()
	soundEnt.SetOrigin( baseOrigin + Vector( RandomIntRange( 0, 150 ), RandomIntRange( 0, 150 ), 0 ) )

	return soundEnt
}
/////////////////////////////////////////////////////////////////////////////////////////
void function HideWeaponsAndAmmoTillFlag( string scriptName, string flagToRestore )
{
	array <entity> weapons = GetWeaponArray( true )
	foreach ( weapon in weapons )
	{
		if ( ( weapon.HasKey( "script_name" ) ) && ( weapon.kv.script_name == scriptName ) )
		{
			weapon.Hide()
			weapon.MakeInvisible()
			weapon.UnsetUsable()
			thread ShowEntityOnFlag( weapon, flagToRestore )
		}

	}
}

/////////////////////////////////////////////////////////////////////////////////////////
/*
void function DeleteWaponsWithScriptname( string scriptName )
{
	array <entity> weapons = GetWeaponArray( true )
	foreach ( weapon in weapons )
	{
		if ( ( weapon.HasKey( "script_name" ) ) && ( weapon.kv.script_name == scriptName ) )
			weapon.Destroy()

	}
}
*/
/////////////////////////////////////////////////////////////////////////////////////
void function ShowEntityOnFlag( entity weapon, string flagToRestore )
{
	FlagWait( flagToRestore )
	weapon.Show()
	weapon.MakeVisible()
	weapon.SetUsable()
}

/////////////////////////////////////////////////////////////////////////////////////
void function SetFlagWhenPlayerLookingAtEnt( entity player, string flagToSet, entity ent, entity trigger = null )
{
	if ( Flag( flagToSet ) )
		return
	FlagEnd( flagToSet )

			//WaitTillLookingAt( entity player, entity ent, bool doTrace, float degrees, float minDist = 0, float timeOut = 0, entity trigger = null )
	waitthread WaitTillLookingAt( player, 		ent, 			true, 			45, 			0, 					0 )
	FlagSet( flagToSet )
}


void function DoorOutOfOrderThink( entity propDynamic )
{
	thread PlayAnim( propDynamic, "stutter01", propDynamic.GetOrigin(), propDynamic.GetAngles() )
}



entity function TSCreateScriptMoverLight( entity owner = null, origin = null, angles = null, solidType = 0 )
{
	if ( owner == null )
	{
		entity script_mover = CreateEntity( "script_mover_lightweight" )
		script_mover.kv.solid = solidType
		script_mover.SetValueForModelKey( $"models/dev/empty_model.mdl" )
		script_mover.kv.SpawnAsPhysicsMover = 0
		if ( origin )
			script_mover.SetOrigin( origin)
		if ( angles )
			script_mover.SetAngles( angles )

		DispatchSpawn( script_mover )
		return script_mover
	}

	entity script_mover = CreateEntity( "script_mover_lightweight" )
	script_mover.kv.solid = solidType
	script_mover.SetValueForModelKey( $"models/dev/empty_model.mdl" )
	script_mover.kv.SpawnAsPhysicsMover = 0
	script_mover.SetOrigin( owner.GetOrigin() )
	script_mover.SetAngles( owner.GetAngles() )
	DispatchSpawn( script_mover )
	script_mover.Hide()

	script_mover.SetOwner( owner )
	return script_mover
}

void function GiveLowAmmo( entity player )
{
	//give player one clip of ammo
	int clipBulletCapacity
	int currentAmmo

    entity weapon = player.GetMainWeapons()[ 0 ]
    clipBulletCapacity = player.GetWeaponAmmoMaxLoaded( weapon )
    currentAmmo = player.GetActiveWeaponPrimaryAmmoLoaded()

    //hack - just refill the current clips if ammo is picked up
    weapon.SetWeaponPrimaryClipCount( clipBulletCapacity )
    player.SetActiveWeaponPrimaryAmmoTotal( 1 )
}


//////////////////////////////////////////////////////////////////////////////////////////////////////
void function CivilianSkitThink( entity civilian, entity player, string flagToReact = "" )
{
	/*
	//---------------------------------------------
	// Does civilian have props or escape nodes?
	//---------------------------------------------
	array< entity > linkedEnts = civilian.GetLinkEntArray()
	string classname
	entity escapeOrg
	entity animProp
	foreach( entity ent in linkedEnts )
	{
		classname = ent.GetClassName()
		if ( classname == "prop_dynamic" )
			animProp = ent
		if ( classname == "info_move_target" )
			escapeOrg = ent
	}

	*/


}

/////////////////////////////////////////////////////////////////////////////////////////////////////////
void function CivilianWalkerThink( entity civilian )
{
	if ( !civilian.HasKey( "script_noteworthy" ) )
		return

	string walkAnim = expect string( civilian.kv.script_noteworthy )
	Assert( IsValid( walkAnim ), "Ent at " + civilian.GetOrigin() +  " needs a walk anim name in its script_noteworthy" )

	thread GivePropForAnim( civilian, walkAnim )

	/*
	entity spawner = civilian.spawner
	Assert( IsValid ( spawner ) )
	asset model = civilian.spawner.GetSpawnerModelName()
	*/

	civilian.SetModel( GetRandomCivilianModel() )
	civilian.SetMoveAnim( walkAnim )
	MakeCivilian( civilian )



	array< entity > linkedEnts = civilian.GetLinkEntArray()
	string editorClassname
	entity destinationOrg
	foreach( entity ent in linkedEnts )
	{
		editorClassname = GetEditorClass( ent )
		if ( editorClassname == "info_move_target" )
			destinationOrg = ent

	}
	Assert( IsValid( destinationOrg ) )
	civilian.AssaultPoint( destinationOrg.GetOrigin() )
}
/////////////////////////////////////////////////////////////////////////////////////////////////////////
void function CivilianActorThink( entity civilian )
{
	civilian.SetModel( GetRandomCivilianModel() )
	MakeCivilian( civilian )
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function QuickSkit( entity player, entity skitNode, string failsafeFlagToStart = "", entity lookAtEnt = null, entity lookAtTrigger = null  )
{
	array< entity > linkedEnts = skitNode.GetLinkEntArray()
	Assert( linkedEnts.len() > 0, "skitNode at " + skitNode.GetOrigin() + " has no linked ents")
	vector origin = skitNode.GetOrigin()
	vector angles = skitNode.GetAngles()
	skitNode.Destroy()
	bool isLooping = false
	bool showIdle = false
	bool isSpawnSkit = false
	bool isDeleteSkit = false


	string scriptName
	if ( ( skitNode.HasKey( "script_noteworthy") ) && ( skitNode.kv.script_noteworthy == "looping" ) )
		isLooping = true
	if ( ( skitNode.HasKey( "script_noteworthy") ) && ( skitNode.kv.script_noteworthy == "show_idle" ) )
		showIdle = true
	if ( ( skitNode.HasKey( "script_noteworthy") ) && ( skitNode.kv.script_noteworthy == "delete" ) )
		isDeleteSkit = true

	entity actor
	array <entity> skitActors
	bool isDoorSkit = false
	asset modelName

	foreach( entity ent in linkedEnts )
	{
		modelName = ent.GetModelName()
		if ( modelName == $"models/door/door_imc_interior_03_128_animated.mdl" )
			isDoorSkit = true

	}


	foreach( entity ent in linkedEnts )
	{

		if( IsSpawner( ent ) )
		{
			actor = ent.SpawnEntity()
			actor.kv.spawnflags = SF_NPC_ALLOW_SPAWN_SOLID
			DispatchSpawn( actor )
			isSpawnSkit = true
			actor.EnableNPCFlag( NPC_DISABLE_SENSING )
			actor.kv.alwaysAlert = 0
			actor.EnableNPCFlag( NPC_IGNORE_ALL )
			actor.SetNoTarget( true )
			actor.EnableNPCFlag( NPC_NO_MOVING_PLATFORM_DEATH )
		}
		else
			actor = ent


		actor.EndSignal( "OnDestroy" )
		actor.EndSignal( "OnDeath" )

		actor.s.anim <- expect string( actor.kv.script_noteworthy )
		Assert( IsValid( actor.s.anim  ), "Ent at " + actor.GetOrigin() +  " needs an anim name in its script_noteworthy" )
		Assert( actor.s.anim != "", "Ent at " + actor.GetOrigin() +  " needs an anim name in its script_noteworthy" )

		if ( isDoorSkit == true )
			DontAllowFreeze( actor, true )


		if ( ( actor.GetScriptName().find( "civilian_" ) != null ) && ( isSpawnSkit == true ) )
		{
			actor.SetMoveAnim( GetRandomCivilianRunAnim() )
			MakeCivilian( actor )
			isDeleteSkit = true
		}

		if ( !isLooping )
		{
			actor.s.animIdle <- actor.s.anim + "_idle"
			thread PlayAnimTeleport( actor, actor.s.animIdle, origin, angles )
		}
		else if ( ( isLooping ) && ( actor.IsNPC() ) )
			actor.EnableNPCFlag( NPC_DISABLE_SENSING )

		if ( !showIdle )
			actor.Hide()

		skitActors.append( actor )
	}

	if ( lookAtEnt )
		waitthread WaitTillLookingAt( player, lookAtEnt, 	true, 		30, 		0, 			0, 			lookAtTrigger, 	failsafeFlagToStart )
	else if ( failsafeFlagToStart != "" )
		FlagWait( failsafeFlagToStart )


	float animLength


	foreach( entity actor in skitActors )
	{


		modelName = actor.GetModelName()
		if ( modelName == $"models/door/door_imc_interior_03_128_animated.mdl" )
		{
			//actor.NotSolid()
			//actor.kv.solid = 0
			// 0 = no collision, 2 = bounding box, 6 = use vPhysics, 8 = hitboxes only

			animLength = actor.GetSequenceDuration( actor.s.anim )
			delaythread ( animLength ) DisableNavmeshSeperatorTargetedByEnt( actor )
			//ToggleNPCPathsForEntity( actor, true )
			DisableNavmeshSeperatorTargetedByEnt( actor )
		}

		actor.Show()
		if ( ( isSpawnSkit ) && ( isDeleteSkit ) )
			thread PlayAnimThenDelete( actor, expect string( actor.s.anim ), origin, angles )
		else if ( isSpawnSkit )
		{
			thread PlayAnim( actor, expect string( actor.s.anim ), origin, angles )
			animLength = actor.GetSequenceDuration( actor.s.anim )
			if ( actor.IsNPC() )
			{
				actor.DisableNPCFlag( NPC_DISABLE_SENSING )
				actor.DisableNPCFlag( NPC_IGNORE_ALL )
				actor.SetNoTarget( false )

			}

			if ( isDoorSkit == true )
				thread AllowFreezeWhenAnimDone( actor, animLength )
		}
		else if ( isLooping )
			thread PlayAnim( actor, expect string( actor.s.anim ), origin, angles )
		else
			thread PlayAnimThenDelete( actor, expect string( actor.s.anim ), origin, angles )
	}

}


void function AllowFreezeWhenAnimDone( entity npc, float animLength )
{
	if ( !IsValid( npc ) )
		return
	npc.EndSignal( "OnDeath" )

	wait animLength

	DontAllowFreeze( npc, false )

}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
string function GetRandomCivilianRunAnim()
{
	array<string> anims
	//anims.append( "pt_civ_walk_swagger" )
	anims.append( "pt_civ_fleeing_run_flail" )
	anims.append( "pt_civ_fleeing_run_hunched" )
	//anims.append( "pt_civ_fleeing_run_lookback" )
	//anims.append( "pt_civ_fleeing_run_pause" )
	//anims.append( "pt_civ_fleeing_run_spin" )
	anims.randomize()
	return anims[ 0 ]
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////

void function MakeCivilian( entity npc )
{

	TakeAllWeapons( npc )
	npc.EnableNPCFlag( NPC_DISABLE_SENSING )
	npc.kv.alwaysAlert = 0
	npc.EnableNPCFlag( NPC_IGNORE_ALL )
	npc.EnableNPCMoveFlag( NPCMF_DISABLE_MOVE_TRANSITIONS )
	SetTeam( npc, TEAM_UNASSIGNED )
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
asset function GetRandomCivilianModel()
{
	array<asset> models
	models.append( MODEL_CIV01 )
	models.append( MODEL_CIV02 )
	models.append( MODEL_CIV03 )
	models.append( MODEL_CIV04 )
	models.randomize()
	return models[ 0 ]
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function PlayAnimThenDelete( entity actor, string anim, origin, angles )
{
	actor.EndSignal( "OnDeath" )
	actor.EndSignal( "OnDestroy" )
	entity node = actor.GetLinkEnt()
	if ( ( actor.IsNPC ) && ( IsValid( node ) ) )
		actor.AssaultPoint( node.GetOrigin() )

	float animLength = actor.GetSequenceDuration( anim )
	thread PlayAnimTeleport( actor, anim, origin, angles )
	wait animLength

	if ( ( actor.IsNPC ) && ( IsValid( node ) ) )
		actor.WaitSignal( "OnFinishedAssault" )

	if ( IsValid( actor ) )
		actor.Destroy()
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function TriggerShowcaseSpawnInit( entity trigger )
{
	bool requiresLookAt = false
	if ( ( trigger.HasKey( "script_noteworthy") ) && ( trigger.kv.script_noteworthy == "lookat" ) )
		requiresLookAt = true

	array< entity > linkedEnts = trigger.GetLinkEntArray()
	Assert( linkedEnts.len() > 0, "Showcase spawn trigger at " + trigger.GetOrigin() + " has no linked ents" )

	foreach( ent in linkedEnts )
	{
		Assert( ent.GetClassName() == "prop_dynamic", "Showcase spawn trigger at " + trigger.GetOrigin() + " Should only link to prop_dynamics " + ( ent.GetClassName() ) )
		thread SpawnerShowcaseSpawnerThink( trigger, ent, requiresLookAt )
	}

}
////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function SpawnerShowcaseSpawnerThink( entity trigger, entity spawnProp, bool requiresLookAt )
{
	FlagWait( "PlayerDidSpawn" )
	entity player = GetPlayerArray()[ 0 ]
	if ( !IsValid( player ) )
		return
	player.EndSignal( "OnDeath" )
	trigger.EndSignal( "OnDestroy" )

	//---------------------------------------------
	// Get spawner and associated animated prop
	//---------------------------------------------
	entity spawner = spawnProp.GetLinkEnt()
	Assert( IsSpawner( spawner ), "Entity at " + spawner.GetOrigin() + " is not a spawner" )
	var spawnerKeyValues = spawner.GetSpawnEntityKeyValues()
	expect table( spawnerKeyValues )
	int spawnCount = 1
	float spawnDelayTime = 0.0

	if ( "script_delay" in spawnerKeyValues )
		spawnDelayTime = float( spawnerKeyValues.script_delay )

	if ( "spawn_count" in spawnerKeyValues ) //spawn_count not implemented yet, but will add later
		spawnCount = int( spawnerKeyValues.script_delay )

	string spawnModel = expect string( spawnerKeyValues.model )

	int npcsSpawned = 0


	//--------------------------
	// Wait for trigger to be hit
	//--------------------------

	entity npc

	while ( GetTriggerEnabled( trigger ) == false )
		wait 0.1

	while( true )
	{
		wait 0.1
		trigger.WaitSignal( "OnTrigger" )

		wait spawnDelayTime

		if ( requiresLookAt )
		{
										//player, 	entity,  	doTrace,	degrees		minDist, 	timeOut,	trigger
			waitthread WaitTillLookingAt( player, 	spawnProp, 	true, 		45, 		0, 			0,			trigger	)
		}

		thread ShowcaseSpawn( spawnProp )

		npcsSpawned++
		if ( npcsSpawned == spawnCount )
			break

	}
}

//////////////////////////////////////////////////////////////////////////
void function ShowcaseSpawn( entity spawnProp )
{
	vector origin = spawnProp.GetOrigin()
	vector angles = spawnProp.GetAngles()
	string spawnAnimNPC = ""
	string spawnAnimProp = ""
	entity spawner = spawnProp.GetLinkEnt()
	Assert( IsSpawner( spawner ), "Entity at " + spawner.GetOrigin() + " is not a spawner" )
	var spawnerKeyValues = spawner.GetSpawnEntityKeyValues()
	expect table( spawnerKeyValues )
	string spawnModel = expect string( spawnerKeyValues.model ).tolower()

	switch( spawnProp.GetModelName() )
	{
		//--------------------------
		// Floor panel prop
		//--------------------------
		case $"models/props/floor_panel_animated.mdl":
		case $"models/props/floor_vent_d_animated.mdl":
			if ( spawnModel == "models/creatures/prowler/r2_prowler.mdl" )
			{
				//spawnAnimProp = "floor_timeshift_prowler_spawn_01"
				//spawnAnimNPC = "pr_timeshift_floor_spawn_01"
				spawnAnimProp = "floor_timeshift_prowler_spawn_01_long"
				spawnAnimNPC = "pr_timeshift_floor_spawn_01_long"

			}
			else if ( spawnModel == "models/robots/stalker/robot_stalker_mossy.mdl" )
			{
				if ( CoinFlip() )
				{
					//spawnAnimProp = "floor_breakout_spawn_floorpanel"
					//spawnAnimNPC = "st_breakout_spawn_floorpanel"
					spawnAnimProp = "floor_breakout_spawn_floorpanel_long"
					spawnAnimNPC = "st_breakout_spawn_floorpanel_long"
				}
				else
				{
					//spawnAnimProp = "floor_breakout_spawn_floordeath"
					//spawnAnimNPC = "st_breakout_spawn_floordeath"
					spawnAnimProp = "floor_breakout_spawn_floordeath_long"
					spawnAnimNPC = "st_breakout_spawn_floordeath_long"
				}
			}
			else
				Assert( 0, "Unhandled spawn prop: " + spawnProp.GetModelName() )
			break
		//--------------------------
		// Wall panel prop
		//--------------------------
		case $"models/props/wall_vent_animated.mdl":
			if ( spawnModel == "models/creatures/prowler/r2_prowler.mdl" )
			{
				if ( ( spawnProp.HasKey( "script_noteworthy") ) && ( spawnProp.kv.script_noteworthy == "ground_vent" ) )
				{
					//spawnAnimProp = "vent_low_timeshift_prowler_spawn_01"
					//spawnAnimNPC = "pr_timeshift_vent_low_spawn_01"
					spawnAnimProp = "vent_low_timeshift_prowler_spawn_01_long"
					spawnAnimNPC = "pr_timeshift_vent_low_spawn_01_long"
				}
				else
				{
					//spawnAnimProp = "vent_timeshift_prowler_spawn_01"
					//spawnAnimNPC = "pr_timeshift_vent_spawn_01"
					spawnAnimProp = "vent_timeshift_prowler_spawn_01_long"
					spawnAnimNPC = "pr_timeshift_vent_spawn_01_long"
				}

			}
			else if ( spawnModel == "models/robots/stalker/robot_stalker_mossy.mdl" )
			{
				//spawnAnimProp = "vent_vent_spawn_core"
				//spawnAnimNPC = "st_vent_spawn_core"
				spawnAnimProp = "vent_vent_spawn_damaged_longintro"
				spawnAnimNPC = "st_vent_spawn_damaged_longintro"
			}
			else
			{
				Assert( 0, "Unhandled spawnModel: " + spawnModel )
			}
			break
		default:
			Assert( 0, "Unhandled spawn prop: " + spawnProp.GetModelName() )

	}

	//------------------
	//Spawn the npc
	//------------------
	entity npc = spawner.SpawnEntity()
	npc.Hide()
	npc.kv.spawnflags = SF_NPC_ALLOW_SPAWN_SOLID
	DispatchSpawn( npc )

	//----------------------------------
	// Animate the spawned npc and prop
	//----------------------------------
	thread PlayAnim( npc, spawnAnimNPC, origin, angles )
	npc.Show()
	thread PlayAnim( spawnProp, spawnAnimProp, origin, angles )

}

///////////////////////////////////////////////////////////////////

bool function IsSpectreRackDoorSpawner( entity spawnProp )
{
	array validModels = [
		$"models/timeshift/timeshift_column_panel_09_destroyed.mdl",
		$"models/timeshift/timeshift_column_panel_10_destroyed.mdl",
		$"models/timeshift/timeshift_column_panel_09.mdl",
		$"models/timeshift/timeshift_column_panel_10.mdl"
	]

	if ( validModels.contains( spawnProp.GetModelName() ) )
		return true

	return false
}

///////////////////////////////////////////////////////////////////
void function HideStuff( string scriptName )
{
	array <entity> stuff = GetEntArrayByScriptName( scriptName )
	foreach( thing in stuff )
	{
		thing.Hide()
		thing.MakeInvisible()
		thing.NotSolid()
	}

}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function ShowStuff( string scriptName )
{
	array <entity> stuff = GetEntArrayByScriptName( scriptName )
	foreach( thing in stuff )
	{
		thing.Show()
		thing.Solid()
		thing.MakeVisible()
	}

}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function AttackPlayer( entity npc )
{
	if ( !IsValid( npc ) )
		return

	array<entity> players = GetPlayerArray()
	if ( players.len() <= 0 )
		return

	npc.SetEnemy( players[ 0 ] )
	printt( "Attacking player..." )
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/*
void function ChangeIMCCorpse( entity model, string corpseType )
{
	//disable all bodygroups
	int stateIndex = 1  // 0 = show, 1 = hide
	model.SetBodygroup( model.FindBodyGroup( "imc_corpse_rifle" ), 1 )
	model.SetBodygroup( model.FindBodyGroup( "imc_corpse_shotgun" ), 1 )
	model.SetBodygroup( model.FindBodyGroup( "imc_corpse_smg" ), 1 )
	model.SetBodygroup( model.FindBodyGroup( "imc_corpse_lmg" ), 1 )

	//enable the right one
	int bodyGroupIndex = model.FindBodyGroup( corpseType )
	stateIndex = 0  // 0 = show, 1 = hide
	model.SetBodygroup( bodyGroupIndex, stateIndex )
}
*/

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function DestroyNPCOnFlag( entity npc, string flagToDestroy )
{
	npc.EndSignal( "OnDeath" )
	FlagEnd( flagToDestroy )

	OnThreadEnd(
	function() : ( npc )
		{
			if ( IsAlive( npc ) )
				npc.Destroy()
		}
	)
	WaitForever()
}


////////////////////////////////////////////////////////////////////////////////////////////////
entity function GetClosestGrunt( entity player, var timeZone, string scriptName = "" )
{
	if ( !IsValid( player ) )
		return
	player.EndSignal( "OnDeath" )

	vector playerOrigin = player.GetOrigin()
	if ( level.timeZone != timeZone )
		playerOrigin = GetPosInOtherTimeline( player.GetOrigin() )

	array <entity> npcs = GetNPCArray()
	array <entity> grunts
	string classname
	foreach( npc in npcs )
	{
		if ( !IsValid( npc ) )
			continue
		if ( !npc.IsNPC() )
			continue
		if ( !IsAlive( npc ) )
			continue
		if ( ( scriptName != "" ) && ( npc.GetScriptName() != scriptName ) )
			continue
		if ( !npc.IsHuman() )
			continue

		grunts.append( npc )
	}

	ArrayRemoveDead( grunts )
	if ( grunts.len() == 0 )
		return null

	entity closestDude = GetClosest( grunts, playerOrigin )

	if ( IsValid( closestDude ) )
		return closestDude
	else
		return null

}
/////////////////////////////////////////////////////////////////////////////////////////
entity function GetTimeshiftPlayer()
{
	array<entity> players = GetPlayerArray()
	if ( players.len() <= 0 )
		return null
	entity player = players[ 0 ]
	return player
}



/////////////////////////////////////////////////////////////////////////////////////////
void function GunshipSequence( string instanceName, entity player, string nodeName, string whichSequence, string flagToStart )
{

	entity gunship = GetEntByScriptNameInInstance( "gunship_artifact_hauler", instanceName )
	entity artifact = GetEntByScriptNameInInstance( "artifact_cargo", instanceName )
	entity harness = GetEntByScriptNameInInstance( "artifact_cargo_containment", instanceName )
	array <entity> ropeLinks = GetEntArrayByScriptNameInInstance( "harness_rope_points", instanceName )

	foreach( ropeAttachEnt in ropeLinks )
		ropeAttachEnt.SetParent( harness )

	gunship.SetFadeDistance( 1000000 )
	artifact.SetFadeDistance( 1000000 )
	harness.SetFadeDistance( 1000000 )

	entity animEnt = GetEntByScriptName( nodeName )


	artifact.SetParent( gunship, "", true )
	harness.SetParent( gunship, "", true )


	string animIdle = ""
	string animLeave = ""

	if ( whichSequence == "rings" )
	{
		artifact.Destroy()
		animIdle = "gunship_timeshift_fly_from_rings_idle"
		animLeave = "gunship_timeshift_fly_from_rings"

	}
	else if ( whichSequence == "pad" )
	{
		animIdle = "st_AngelCity_IMC_Win_Idle"
		//EmitSoundOnEntity( gunship, "Timeshift_Scr_DropshipTowingCore_Hover" )
		//animLeave = "st_AngelCity_IMC_Win_Leave"
	}
	else
		Assert( 0, "Invalid sequence: " + whichSequence )



	entity gunshipAttachEnt = CreateScriptRef( gunship.GetOrigin(), gunship.GetAngles() )
	gunshipAttachEnt.SetParent( gunship )
	local subdivisions = 15 // 25
	local slack = 25 // 25

	wait 0.1

	if ( whichSequence == "pad" )
		animEnt.SetOrigin( animEnt.GetOrigin() + Vector( 0, 0, -400 ) )

	thread PlayAnimTeleport( gunship, animIdle, animEnt )


	wait 0.1

	if ( whichSequence == "pad" )
	{
		foreach( ropeAttachEnt in ropeLinks )
		{

			string startpointName = UniqueString( "rope_startpoint" )
			string endpointName = UniqueString( "rope_endpoint" )

			entity rope_start = CreateEntity( "move_rope" )
			SetTargetName( rope_start, startpointName )
			rope_start.kv.NextKey = endpointName
			rope_start.kv.MoveSpeed = 32
			rope_start.kv.Slack = slack
			rope_start.kv.Subdiv = subdivisions
			rope_start.kv.Width = "3"
			rope_start.kv.TextureScale = "1"
			rope_start.kv.RopeMaterial = "cable/cable.vmt"
			rope_start.kv.PositionInterpolator = 2
			rope_start.SetOrigin( gunshipAttachEnt.GetOrigin() )

			entity rope_end = CreateEntity( "keyframe_rope" )
			SetTargetName( rope_end, endpointName )
			rope_end.kv.MoveSpeed = 32
			rope_end.kv.Slack = slack
			rope_end.kv.Subdiv = subdivisions
			rope_end.kv.Width = "3"
			rope_end.kv.TextureScale = "1"
			rope_end.kv.RopeMaterial = "cable/cable.vmt"
			rope_end.SetOrigin( ropeAttachEnt.GetOrigin() )


			DispatchSpawn( rope_start )
			DispatchSpawn( rope_end   )

			rope_start.SetParent( gunship )
			rope_end.SetParent( harness )
		}
		//

	}
	else
	{
		harness.Destroy()

	}



	wait 0.1

	FlagWait( flagToStart )

	if ( whichSequence == "rings" )
	{
		EmitSoundAtPosition( TEAM_UNASSIGNED, GetEntByScriptName( "lookent_rings" ).GetOrigin(), "timeshift_scr_dropshipcoreflyover_long_muffled" )
		waitthread PlayAnim( gunship, animLeave, animEnt )

	}

	else if ( whichSequence == "pad" )
	{

		int attachID = gunship.LookupAttachment( "REF" )
		vector attachOrg = gunship.GetAttachmentOrigin( attachID )
		vector attachAng = gunship.GetAttachmentAngles( attachID )
		entity mover = CreateScriptMover( attachOrg, attachAng )
		gunship.SetParent( mover, "", true )
		float duration = 30
		//StopSoundOnEntity( gunship, "Timeshift_Scr_DropshipTowingCore_Hover" )
		EmitSoundOnEntity( gunship, "Timeshift_Scr_DropshipTowingCore_Takeoff" )

		mover.NonPhysicsMoveTo( gunship.GetOrigin() + Vector( 0, 0, 3200 ),  duration, 0, 0 ) //, duration*0.4, duration*0.4 )
		wait duration
		mover.Destroy()
	}


}

/////////////////////////////////////////////////////////////////////////////
void function AndersonHologramSequence( entity player, string nodeName, string flagToStart )
{
	//Double the geo, double the fun
	entity node = GetEntByScriptName( nodeName )
	entity node2 = CreateScriptRef( node.GetOrigin() + Vector( 0, 0, TIME_ZOFFSET ), node.GetAngles() )
	node2.kv.script_name = nodeName

	thread AndersonHologramSequenceThread( player, node, flagToStart )
	thread AndersonHologramSequenceThread( player, node2, flagToStart )
}

/////////////////////////////////////////////////////////////////////////////
void function AndersonHologramSequenceThread( entity player, entity node, string flagToStart )
{
	player.EndSignal( "OnDeath" )
	vector origin = node.GetOrigin()
	vector angles = node.GetAngles()
	entity anderson = CreatePropDynamic( ANDERSON_HOLOGRAM_MODEL, origin, angles, 0 ) // 0 = no collision
	anderson.kv.script_name = "anderson_holo"
	entity andersonWeapon = CreatePropDynamic( ANDERSON_PISTOL_MODEL, origin, angles, 0 ) // 0 = no collision
	andersonWeapon.SetSkin( 1 )
	anderson.SetSkin( 1 )
	string nodeName = node.GetScriptName()
	Assert( nodeName != "" )

	bool isOvergrownHolo = false
	if ( GetEntityTimelinePosition( node ) == TIMEZONE_NIGHT )
		isOvergrownHolo = true

	anderson.Hide()
	andersonWeapon.Hide()

	//string attachment = "PROPGUN"
	//int attachIndex = anderson.LookupAttachment( attachment )
	//vector attachOrigin = anderson.GetAttachmentOrigin( attachIndex )
	andersonWeapon.SetParent( anderson, "PROPGUN", false, 0.0 )

	string animAnderson
	string animAndersonIdle
	string animEnemy
	string animEnemyIdle
	entity andersonEnemy
	entity enemyKnife
	entity enemyGun
	string flagToSetWhenDone
	string flagToSetWhenPlaying

	switch( nodeName )
	{
		case "node_hologram_lab1":
			animAndersonIdle = "anderson_ghost_A_scene_idle"
			animAnderson = "anderson_ghost_A_scene"
			flagToSetWhenDone = "AndersonHologram1Finished"
			flagToSetWhenPlaying = "AndersonHologram1Playing"
			break
		case "node_hologram_lab2":
			animAndersonIdle = "anderson_ghost_B_scene_idle"
			animAnderson = "anderson_ghost_B_scene"
			flagToSetWhenDone = "AndersonHologram2Finished"
			flagToSetWhenPlaying = "AndersonHologram2Playing"
			break
		case "node_hologram_lab3":
			animAndersonIdle = "anderson_ghost_C_scene_idle"
			animAnderson = "anderson_ghost_C_scene"
			flagToSetWhenPlaying = "AndersonHologram3Playing"
			andersonEnemy = CreatePropDynamic( ENEMY_HOLOGRAM_MODEL, origin, angles, 0 ) // 0 = no collision
			andersonEnemy.SetSkin( 1 )
			enemyKnife = CreatePropDynamic( HOLOGRAM_KNIFE_MODEL, origin, angles, 0 ) // 0 = no collision
			enemyKnife.SetSkin( 1 )
			enemyGun = CreatePropDynamic( HOLOGRAM_ENEMY_GUN_MODEL, origin, angles, 0 ) // 0 = no collision
			enemyGun.SetSkin( 1 )
			enemyGun.SetParent( andersonEnemy, "PROPGUN", false, 0.0 )
			enemyKnife.SetParent( andersonEnemy, "KNIFE", false, 0.0 )
			andersonEnemy.Hide()
			andersonEnemy.MakeInvisible()
			enemyKnife.Hide()
			enemyKnife.MakeInvisible()
			animEnemy = "pt_ghost_C_scene"
			animEnemyIdle = "pt_ghost_C_scene_idle"
			flagToSetWhenDone = "AndersonHologram3Finished"
			thread AndersonHologram3Think( anderson, andersonWeapon )
			thread AndersonEnemyHologram3Think( andersonEnemy, enemyKnife, enemyGun )
			break
		default:
			Assert( 0, "Unhandled nodeName: " + nodeName )
	}

	if ( IsValid( andersonEnemy) )
	{
		Assert( animEnemyIdle != "" )
		thread PlayAnimTeleport( andersonEnemy, animEnemyIdle, node )
	}
	Assert( animAndersonIdle != "" )
	thread PlayAnimTeleport( anderson, animAndersonIdle, node )


	FlagWait( flagToStart )








	//only display HUD stuff once
	if ( isOvergrownHolo )
		thread DecodingLogsScreenPrint( player )

	anderson.Show()
	//spawn effects
	int attachIndex = anderson.LookupAttachment( "CHESTFOCUS" )
	StartParticleEffectOnEntity( anderson, GetParticleSystemIndex( FX_HOLOGRAM_FLASH_EFFECT ), FX_PATTACH_POINT_FOLLOW, attachIndex )
	StartParticleEffectOnEntity( anderson, GetParticleSystemIndex( FX_HOLOGRAM_HEX_EFFECT ), FX_PATTACH_POINT_FOLLOW, attachIndex )

	/*
	int scanEffectIndex = GetParticleSystemIndex( FX_HOLO_SCAN_ENVIRONMENT )
	int particleIndex = StartParticleEffectInWorldWithHandle( scanEffectIndex, anderson.GetOrigin(), <0,0,0> )
	EffectSetControlPointVector( particleIndex, 1, <2.5,50,0> )
	*/

	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.1

	anderson.Hide()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.1

	anderson.Show()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.1

	anderson.Hide()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.1

	anderson.Show()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.1

	anderson.Hide()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.1

	anderson.Show()
	StartParticleEffectOnEntity( anderson, GetParticleSystemIndex( FX_HOLOGRAM_FLASH_EFFECT ), FX_PATTACH_POINT_FOLLOW, attachIndex )
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.1

	anderson.Hide()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.25

	anderson.Show()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.5

	anderson.Hide()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.25

	anderson.Show()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.01

	anderson.Hide()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.25

	anderson.Show()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.03

	anderson.Hide()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.2


	anderson.Show()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.3

	anderson.Hide()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.2

	anderson.Show()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.05

	anderson.Hide()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.5

	anderson.Show()
	StartParticleEffectOnEntity( anderson, GetParticleSystemIndex( FX_HOLOGRAM_FLASH_EFFECT ), FX_PATTACH_POINT_FOLLOW, attachIndex )
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.1

	anderson.Hide()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.2

	anderson.Show()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.1

	anderson.Hide()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.2

	anderson.Show()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.1

	anderson.Hide()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.1

	anderson.Show()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.1

	anderson.Hide()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.1

	anderson.Show()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.1

	anderson.Hide()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.1

	anderson.Show()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.1

	anderson.Hide()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.1

	anderson.Show()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.1

	anderson.Hide()
	EmitSoundOnEntity( anderson, SOUND_HOLOGRAM_FLICKER )
	wait 0.1


	FlagSet( flagToSetWhenPlaying )

	EmitSoundOnEntity( anderson, "PathHologram_Materialized_3P" )
	//EmitSoundOnEntity( anderson, "PathHologram_Sustain_Loop_3P" )

	if ( IsValid( andersonEnemy) )
	{
		Assert( animEnemy != "" )
		thread PlayAnim( andersonEnemy, animEnemy, node )
		int attachIndexEnemy = andersonEnemy.LookupAttachment( "CHESTFOCUS" )
		StartParticleEffectOnEntity( andersonEnemy, GetParticleSystemIndex( FX_HOLOGRAM_HEX_EFFECT ), FX_PATTACH_POINT_FOLLOW, attachIndexEnemy )
	}
	anderson.Show()
	andersonWeapon.Show()
	Assert( animAnderson != "" )
	StartParticleEffectOnEntity( anderson, GetParticleSystemIndex( FX_HOLOGRAM_FLASH_EFFECT ), FX_PATTACH_POINT_FOLLOW, attachIndex )
	waitthread PlayAnim( anderson, animAnderson, node )

	vector andersonEndPos = anderson.GetAttachmentOrigin( attachIndex )

	//hologram 3 we need to manually deal with Anderson disappearing at the end...all others he can just blink out
	if ( nodeName != "node_hologram_lab3" )
	{
		EmitSoundAtPosition( TEAM_UNASSIGNED, andersonEndPos, "AndersonHologram_Deactivate" )
		PlayFX( FX_HOLOGRAM_FLASH_EFFECT, andersonEndPos )
	}

	FlagSet( flagToSetWhenDone )
	anderson.Destroy()
	if ( IsValid( andersonEnemy) )
	{
		int attachIndexEnemy = andersonEnemy.LookupAttachment( "CHESTFOCUS" )
		vector andersonEnemyEndPos = andersonEnemy.GetAttachmentOrigin( attachIndexEnemy )
		PlayFX( FX_HOLOGRAM_FLASH_EFFECT, andersonEnemyEndPos )
		andersonEnemy.Destroy()
	}



	if ( isOvergrownHolo )
		Remote_CallFunction_NonReplay( player, "ServerCallback_ClearScanningHudElem" )


}
//////////////////////////////////////////////////////////////////
void function AndersonHologram3Think( entity anderson, entity andersonGun )
{
	anderson.EndSignal( "OnDestroy" )

	anderson.WaitSignal( "AndersonHideGun" )
	andersonGun.Destroy()

	anderson.WaitSignal( "AndersonTimeshifts" )

	anderson.Dissolve( ENTITY_DISSOLVE_CHAR, Vector( 0, 0, 0 ), 0 )

}
//////////////////////////////////////////////////////////////////
void function AndersonEnemyHologram3Think( entity andersonEnemy, entity knife, entity andersonEnemyGun )
{
	andersonEnemy.EndSignal( "OnDestroy" )

	andersonEnemy.WaitSignal( "AndersonEnemyShow" )
	andersonEnemy.Show()
	andersonEnemy.MakeVisible()

	andersonEnemy.WaitSignal( "AndersonEnemyShowKnife" )
	knife.Show()
	knife.MakeVisible()
}


/*
//////////////////////////////////////////////////////////////////
void function TitanTimeshiftLoadoutOLD( entity player )
{
	wait 1
	Assert( IsValid( player ) )
	entity bt = player.GetPetTitan()
	Assert( IsValid( bt ) )
	//TitanLoadoutDef loadout = bt.ai.titanSpawnLoadout
	//loadout.special = "mp_titanability_timeshift"
	entity weapon = bt.GetOffhandWeapon( OFFHAND_SPECIAL )
	bt.TakeWeapon( weapon.GetWeaponClassName() )
	//entity offhand2weapon = bt.GetOffhandWeapon( OFFHAND_ANTIRODEO )
	//bt.TakeWeapon( offhand2weapon.GetWeaponClassName() )
	bt.GiveOffhandWeapon( "mp_titanability_timeshift", OFFHAND_SPECIAL, [] )
	LockOffhandSlot( player, OFFHAND_SPECIAL )
}

*/



//////////////////////////////////////////////////////////////////
void function TitanTimeshiftLoadout( entity player )
{
	entity weapon = player.GetOffhandWeapon( OFFHAND_SPECIAL )
	if ( IsValid( weapon ) )
	{
		string weaponName = weapon.GetWeaponClassName()
		if ( weaponName == "mp_titanability_timeshift" )
			return

		player.TakeWeapon( weaponName )
	}

	player.GiveOffhandWeapon( "mp_titanability_timeshift", OFFHAND_SPECIAL, [] )
//	LockOffhandSlot( player, OFFHAND_SPECIAL )
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function KillMyInterdimensionalBrother( entity baseNpc, entity brotherNpc = null )
{
	if ( !IsValid( baseNpc ) )
		return

	if ( baseNpc.IsTitan() )
		baseNpc.WaitSignal( "OnDeath" ) //may change to Doomed if not weak
	else
		baseNpc.WaitSignal( "OnDeath" )

	entity brother = brotherNpc

	if ( !IsValid( brother ) )
		return
	if ( !IsAlive( brother ) )
		return
	if ( !brother.IsNPC() )
		return

	vector origin = brother.GetOrigin()

	TakeAllWeapons( brother )
	UnFreezeNPC( brother )


	if( level.timeZone == TIMEZONE_NIGHT )
		brother.TakeDamage( brother.GetMaxHealth() + 1, null, null, { damageSourceId=damagedef_suicide } ) //Kill npc manually if player can see him
	else
		brother.Destroy() //otherwise delete as if he never existed

}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function SpawnPristineStalkersWithDopplegangers( string scriptName )
{
	array <entity> spawners = GetEntArrayByScriptName( scriptName )
	Assert( spawners.len() > 0 )


	foreach( spawner in spawners )
	{
		Assert( IsSpawner( spawner ) )
		entity baseStalker = spawner.SpawnEntity()
		DispatchSpawn( baseStalker )
		baseStalker.kv.alwaysAlert = 1


		entity doppleganger = CreateZombieStalkerMossy( TEAM_IMC, baseStalker.GetOrigin() + Vector( 0, 0, ( TIME_ZOFFSET * -1 ) ), baseStalker.GetAngles() )
		DispatchSpawn( doppleganger )
		SetSquad( doppleganger, "bridge_room_overgrown" )
		doppleganger.kv.alwaysAlert = 1
		thread KillMyInterdimensionalBrother( baseStalker, doppleganger )
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function SpawnAutoSecurityGroup( string scriptName )
{
	array <entity> spawners = GetEntArrayByScriptName( scriptName )
	Assert( spawners.len() > 0 )
	array <entity> pristineRobots
	array <entity> overgrownRobots

	foreach( spawner in spawners )
	{
		Assert( IsSpawner( spawner ) )
		entity npc = spawner.SpawnEntity()
		DispatchSpawn( npc )
		if ( GetEntityTimelinePosition( npc ) == TIMEZONE_DAY )
			pristineRobots.append( npc )
		else
			overgrownRobots.append( npc )

	}

	Assert( overgrownRobots.len() == pristineRobots.len(), "Arrays of pristine and overgrown robots are not equal: " + scriptName )

	int i = 0
	foreach( robot in pristineRobots )
	{
		thread KillMyInterdimensionalBrother( robot, overgrownRobots[ i ] )
		i++
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function TitanRackSpawnersThink( string scriptName )
{
	array <entity> spawners = GetEntArrayByScriptName( scriptName )
	Assert( spawners.len() > 0 )
	entity pristineTitan
	entity overgrownTitan

	foreach( spawner in spawners )
	{
		Assert( IsSpawner( spawner ) )

		array <entity> linkedEnts = spawner.GetLinkEntArray()
		entity rack
		foreach( ent in linkedEnts )
		{
			if ( ent.GetClassName() == "info_target" )
				rack = ent
		}
		Assert( IsValid( rack ) )
		entity npc = spawner.SpawnEntity()
		npc.kv.spawnflags = SF_NPC_ALLOW_SPAWN_SOLID
		DispatchSpawn( npc )
		npc.EnableNPCFlag( NPC_IGNORE_ALL )
		npc.SetNoTarget( true )
		npc.SetTitle( "" )
		npc.SetValidHealthBarTarget( false )
		DisableTitanRodeo( npc )
		HideName( npc )
		//thread PlayAnimTeleport( npc, "bt_TDay_drop_titan1", rack )
		thread PlayAnimTeleport( npc, "at_titanrack_bootup_idle", rack ) //bt_TDay_drop_titan1
		//thread PlayAnim( rack, "tr_titanrack_bootup_idle" )

		npc.s.rack <- rack

		if ( GetEntityTimelinePosition( npc ) == TIMEZONE_DAY )
		{
			pristineTitan = npc
			thread TitanRackHealthThink( pristineTitan, TIMEZONE_DAY )
		}
		else
		{
			overgrownTitan = npc
			thread TitanRackHealthThink( overgrownTitan, TIMEZONE_DAY )
		}
	}

	thread KillMyInterdimensionalBrother( pristineTitan, overgrownTitan )
}


void function TitanRackHealthThink( entity titan, var timeZone )
{
	titan.EndSignal( "OnDeath" )
	if ( timeZone == TIMEZONE_DAY )
		FlagWait( "player_inside_bridge_room_pristine" )
	else
		FlagWait( "player_inside_bridge_room_overgrown" )

	titan.SetMaxHealth( 1000 )
	titan.SetHealth( 1000 )
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

void function TitanRackDeploy( string scriptName, var timeZone  )
{
	array <entity> ents = GetEntArrayByScriptName( scriptName )
	foreach( ent in ents )
	{
		if ( !IsValid( ent ) )
			continue
		if ( ent.IsNPC() )
			thread TitanRackDeployThread( ent, timeZone )
	}
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function TitanRackDeployThread( entity titan, var timeZone )
{
	if( !IsValid( titan ) )
		return
	if( !IsAlive( titan ) )
		return

	titan.EndSignal( "OnDeath" )
	titan.EndSignal( "OnDestroy" )

	if ( ( GetEntityTimelinePosition( titan ) == TIMEZONE_DAY ) && ( timeZone == TIMEZONE_NIGHT ) )
		return
	if ( ( GetEntityTimelinePosition( titan ) == TIMEZONE_NIGHT ) && ( timeZone == TIMEZONE_DAY ) )
		return

	float animLength = titan.GetSequenceDuration( "at_titanrack_bootup" )
	entity rack = titan.GetLinkEnt()
	Assert( IsValid( rack ) )
	thread PlayAnim( titan, "at_titanrack_bootup", rack )
	thread PlayAnim( rack, "tr_titanrack_bootup" )
	titan.SetNoTarget( false )

	wait animLength

	titan.DisableNPCFlag( NPC_IGNORE_ALL )
}


void function HideCritTimeshift( entity ent )
{
	int bodyGroupIndex = ent.FindBodyGroup( "hitpoints" )

	if ( bodyGroupIndex == -1 )
	{
		return
	}

	ent.SetBodygroup( bodyGroupIndex, 1 )
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function RingsThink()
{
	entity rings = GetEntByScriptName( "rings_pristine" )
	if ( !IsValid( rings ) )
		return

	rings.EndSignal( "OnDestroy" )
	thread PlayAnim( rings, "idle" )

	FlagWait( "RingsShouldBeSpinning" )

	string spinAnim = "animated_slow"
	if ( Flag( "player_back_in_amenities_lobby" ) )
		spinAnim = "animated"

	//rings.Anim_Stop()
	thread PlayAnim( rings, spinAnim )

}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function PlayerConversationStopOnFlagImmediate( string name, entity player, string flagToAbort )
{
	Assert( flagToAbort != "" )
	waitthread PlayerConversationStopOnFlag( name, player, flagToAbort, true )
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function PlayerConversationStopOnFlag( string name, entity player, string flagToAbort = "", bool immediate = false )
{
	if ( flagToAbort != "" )
	{
		if ( Flag( flagToAbort ) )
			return

		FlagEnd( flagToAbort )
	}

	OnThreadEnd(
		function() : ( player, immediate, flagToAbort )
		{
			if ( flagToAbort == "" )
				return
			if ( !IsValid( player ) )
				return
			if ( immediate == false )
				StopConversation( player )
			else if ( immediate == true )
				StopConversationNow( player )
		}
	)

	thread PlayerConversation( name, player )
	WaitSignal( player, "ConversationEnded" )
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function FlagSetDelayed( string flagToSet, float delay )
{
	thread FlagSetDelayedThread( flagToSet, delay )
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function FlagSetDelayedThread( string flagToSet, float delay )
{
	wait delay
	FlagSet( flagToSet )
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function FlagClearDelayed( string flagToClear, float delay )
{
	thread FlagClearDelayedThread( flagToClear, delay )
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function FlagClearDelayedThread( string flagToClear, float delay )
{
	wait delay
	FlagClear( flagToClear )
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function DecodingLogsScreenPrint( entity player )
{
	Remote_CallFunction_NonReplay( player, "ServerCallback_ShowHoloDecoding" )

}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
void function AudioLogModelThink( entity audioLogModel )
{
	wait 0.25

	file.audioLogModels.append( audioLogModel )
	audioLogModel.SetFadeDistance( 2048 )
	EmitSoundAtPosition( TEAM_UNASSIGNED, audioLogModel.GetOrigin(), "LSTAR_Reloading_Beep_low" )
	audioLogModel.Highlight_ShowInside( 1.0 )
	audioLogModel.Highlight_ShowOutline( 1.0 )

	string instanceName = audioLogModel.GetInstanceName()
	string audioLogAlias
	int logIndex
	bool isTempAudioLog = false
	bool isBoyleAudioLog = false
	int boyleAudioLogNumber = 0
	int boyleLogInstanceNumber = 0

	Assert( instanceName != "", "Audio log has no instance name: " + audioLogModel.GetOrigin() )

	if ( instanceName == "audiolog_lobby_overgrown" )
	{
		// Audio Log - Scientist 2	The trial-run of the Sculptor Core will continue as planned, but you have to get security to evacuate all Tier 1 personnel.
		// General Marder and his key team members are transferring to remote observation.
		audioLogAlias = "diag_sp_anderson_TS171_02_01_imc_scientist2"
		logIndex = 1
	}
	else if ( instanceName == "audiolog_security_overgrown" )
	{
		// Dr. Alexander Darren log fourteen point six. The intruder has some kind of advanced tech and is slaughtering our response teams.
		//Tyler in Wildlife Research said 2 teams were taken out at the elevator banks in a matter of seconds...by one guy!
		audioLogAlias = "diag_sp_anderson_TS171_01_01_imc_scientist1"
		logIndex = 2
	}
	else if ( instanceName == "audiolog_lecture_overgrown" )
	{

		bool doLongSpeechAtLectern = false

		if ( doLongSpeechAtLectern == true )
		{
			// Full ted talk, 1-28
			instanceName = "audiolog_ted_talk"
			audioLogAlias = "tedTalk01"
			logIndex = 9
		}
		else
		{
			//General Marder
			//But lest we lose sight of the bigger picture - remember those losses are ultimately
			//replaceable by the inexorable march of human civilization.
			audioLogAlias = "lectureLogA"
			logIndex = 3
		}

	}
	else if ( instanceName == "audiolog_upper_hub1_overgrown" )
	{

		//Audio log 4	This is Dr. Colby Marvin. I don't know how to explain it, but a Vanguard-Class Titan just appeared out of nowhere. The test is still underway. It will be completed.
		audioLogAlias = "diag_sp_ambScience_TS551_09_01_imc_sci"
		logIndex = 4

	}
	else if ( instanceName == "audiolog_upper_hub2_overgrown" )
	{
		//Audio log 5	 Dr. Altamirano log seven point six. General Marder is gone. He's making us stay to complete the test. I don't trust this thing. The Ark is unstable.
		audioLogAlias = "diag_sp_ambScience_TS551_10_01_imc_sci"
		logIndex = 5

	}
	else if ( IsAudioLogBoyle( instanceName ) )
	{
		isBoyleAudioLog = true
		logIndex = 6
		boyleLogInstanceNumber = GetBoyleLogInstanceNumber( instanceName )

		if ( file.debugAudioLogs )
			thread DebugDrawAudioLogNumber( audioLogModel, file.boyleAudioLogNumberAssignments[ boyleLogInstanceNumber ].tostring() )
	}

	else if ( instanceName == "audiolog_humanroom" )
	{

		//Marders Log 21b - Human specimen 3 point 4. The experiments on the IMS Odyssey's colonists are underway.
		//Soon we will discover the long lasting effects the Ark has on organic matter and brain function.
		audioLogAlias = "diag_sp_audioLog_TS132_01_01_imc_genMarder"
		logIndex = 7

	}
	else if ( instanceName == "audiolog_humanroom_tower" )
	{
		//Audio log 7	Dr. Ehrenberg log eleven point four. Further research still leaves questions about the Fold Weapon and its intended purpose.
		//I don't think we're using it right and that may cause a problem. Marder thinks it's worth it. Well I'm going on record - this is a bad idea.
		audioLogAlias = "diag_sp_ambScience_TS551_12_01_imc_sci"
		logIndex = 8
	}

	else if ( instanceName == "audiolog_ted_talk" )
	{
		// Full ted talk, 1-28
		audioLogAlias = "tedTalk01"
		logIndex = 9
	}


	else
		Assert( 0, "Unhandled audio log instance name: " + instanceName )


	audioLogModel.SetUsable()
	audioLogModel.SetUsableByGroup( "pilot" )
	audioLogModel.SetUsePrompts( "#TIMESHIFT_HINT_AUDIO_LOG" , "#TIMESHIFT_HINT_AUDIO_LOG_PC" )
	local playerActivator
	while( true )
	{
		playerActivator = audioLogModel.WaitSignal( "OnPlayerUse" ).player
		if ( IsValid( playerActivator ) && playerActivator.IsPlayer() )
			break
	}

	FlagSet( "AudioLogPlaying" )

	EmitSoundAtPosition( TEAM_UNASSIGNED, audioLogModel.GetOrigin(), "LSTAR_Reloading_Beep_low" )
	audioLogModel.UnsetUsable()
	audioLogModel.Highlight_HideInside( 0 )
	audioLogModel.Highlight_HideOutline( 0 )

	wait 0.5

	entity player = GetPlayerArray()[ 0 ]
	if ( !IsValid( player ) )
		return

	player.EndSignal( "OnDeath" )


	//Remote_CallFunction_NonReplay( player, "ServerCallback_ShowHoloDecoding", logIndex )

	//wait 2

	thread StopAudioLogWhenPlayerFarAway( audioLogModel )

	audioLogModel.EndSignal( "StopAudioLog" )

	OnThreadEnd(
		function() : ( player, audioLogModel )
		{
			Remote_CallFunction_NonReplay( player, "ServerCallback_ClearScanningHudElem" )
			FlagClear( "AudioLogPlaying" )
			if ( IsValid( audioLogModel ) )
			{
				audioLogModel.Signal( "StopAudioLog" )
				EmitSoundAtPosition( TEAM_UNASSIGNED, audioLogModel.GetOrigin(), "LSTAR_Reloading_Beep_low" )
				delaythread( 2 ) AudioLogModelThink( audioLogModel )
			}


		}
	)


	if ( isBoyleAudioLog )
	{
		boyleAudioLogNumber = GetBoyleLogNumber( boyleLogInstanceNumber, audioLogModel )
		file.boyleAudioLogNumberAssignments[ boyleLogInstanceNumber ] = boyleAudioLogNumber
	}
	else
		waitthread PlayTimeShiftDialogue( player, audioLogModel, audioLogAlias )




	//------------------------------------------------
	//	If this is the lecture hall, play the tail lines
	//-------------------------------------------------
	if ( instanceName == "audiolog_lecture_overgrown" )
	{
		if ( !Flag( "PlayerInterruptedLecture") )
		{

			//General Marder	By decisively neutralizing the Militia forces,
			//we will in fact, safeguard the existence of the human race, extending its reach and power towards a prosperous, and bright future.
			waitthread PlayTimeShiftDialogue( player, audioLogModel, "lectureLogB" )
		}
		else
		{
			entity soundDummy = CreateLoudspeakerEnt( audioLogModel.GetOrigin() )

			//General Marder	By decisively neutralizing the Militia forces,
			//we will in fact, safeguard the existence of the human race, extending its reach and power towards a prosperous, and bright future.
			thread PlayTimeShiftDialogue( player, soundDummy, "lectureLogB" )
			wait file.lectureHallTimeBeforePlayerInterrupts

			 //General Marder	Yes, test Pilot? May I help you?
			soundDummy.Destroy()
			waitthread PlayTimeShiftDialogue( player, audioLogModel, "lectureLogC" )

		}
	}

	//------------------------------------------------
	//	If this is a Boyle log, play all the aliases for the log number
	//-------------------------------------------------
	else if ( isBoyleAudioLog )
	{
		array <string> aliases
		if ( boyleAudioLogNumber == 1 )
		{
			//---------------------------------------
			// Boyle audio logs: 1
			//---------------------------------------
			//Dr. Jefferson Boyle - Log one. Looks like they went forward with the Ark test despite my warnings to postpone, but what Marder wants - Marder gets.
			aliases.append( "diag_sp_BoyleLog1_TS701_01_01_imc_boyle" )

			//I don’t know how I survived, but I did...for now. 	I don’t know how I survived, but I did...for now.
			aliases.append( "diag_sp_BoyleLog1_TS701_02_01_imc_boyle" )

			//I’ve tried all exits but I’m trapped; damn place is locked down good. All I have is Hope. That’s what I get for picking a lab underground... What can say? I like archaeology.
			aliases.append( "diag_sp_BoyleLog1_TS701_03_01_imc_boyle" )
		}
		else if ( boyleAudioLogNumber == 2 )
		{

			//---------------------------------------
			// Boyle audio logs: 2
			//---------------------------------------
			//Dr. Jefferson Boyle	Log 2	Dr. Jefferson Boyle - Log two. I found myself a standard IMC survival kit, which provides me with enough flavorless rations to keep me alive for a few days.	Dr. Jefferson Boyle. Log two. I found myself a standard IMC survival kit, which provides me with enough flavorless rations to keep me alive for a few days.
			aliases.append( "diag_sp_BoyleLog2_TS701_04_01_imc_boyle" )

			//Dr. Jefferson Boyle	Log 2	I’m hoping that’s all I need otherwise I’m going to have to get creative.  I hate getting creative...	I’m hoping that’s all I need otherwise I’m going to have to get creative.  I hate getting creative...
			aliases.append( "diag_sp_BoyleLog2_TS701_05_01_imc_boyle" )

			//Dr. Jefferson Boyle	Log 2	I hate getting creative...
			//aliases.append( "diag_sp_BoyleLog2_TS701_06_01_imc_boyle" )

		}
		else if ( boyleAudioLogNumber == 3 )
		{

			//---------------------------------------
			// Boyle audio logs: 3
			//---------------------------------------
			//Dr. Jefferson Boyle	Log 3	Dr. Jefferson Boyle - Log three. I had to get creative. Failed experiments on Typhon’s indigenous wildlife are unfortunately next door...in other words, I cooked a prowler.  	Dr. Jefferson Boyle. Log three. I had to get creative. Failed experiments on Typhon’s indigenous wildlife are unfortunately next door...in other words, I cooked a prowler.
			aliases.append( "diag_sp_BoyleLog3_TS701_07_01_imc_boyle" )

			//Dr. Jefferson Boyle	Log 3	It tasted like chicken if chicken was a weird dinosaur-like creature injected with IMC meds and steroids.	It tasted like chicken if chicken was a weird dinosaur-like creature injected with IMC meds and steroids.
			aliases.append( "diag_sp_BoyleLog3_TS701_08_01_imc_boyle" )

			//Dr. Jefferson Boyle	Log 3	On a lighter note, I think I found a way to upload these logs to what's left of the IMC network here. Maybe someone's monitoring...here's to Hope.	On a lighter note, I think I found a way to upload these logs to what's left of the IMC network here. Maybe someone's monitoring...here's to Hope.
			aliases.append( "diag_sp_BoyleLog3_TS701_09_01_imc_boyle" )

		}
		else if ( boyleAudioLogNumber == 4 )
		{
			//---------------------------------------
			// Boyle audio logs: 4
			//---------------------------------------
			//Dr. Jefferson Boyle	Log 4	Dr. Jefferson Boyle - Log four. All right, my logs are on the network but unfortunately, I am out of Prowler so I'm pretty disappointed. 	Dr. Jefferson Boyle. Log four. All right, my logs are on the network but unfortunately, I am out of Prowler so I'm pretty disappointed.
			aliases.append( "diag_sp_BoyleLog4_TS701_10_01_imc_boyle" )

			//Dr. Jefferson Boyle	Log 4	I’ve moved on to the vines and plants growing throughout this facility.	I’ve moved on to the vines and plants growing throughout this facility.
			aliases.append( "diag_sp_BoyleLog4_TS701_11_01_imc_boyle" )

			//Dr. Jefferson Boyle	Log 4	It’s raining non-stop so I have water, at least I think it’s water.	It’s raining non-stop so I have water, at least I think it’s water.
			aliases.append( "diag_sp_BoyleLog4_TS701_12_01_imc_boyle" )

			//Dr. Jefferson Boyle	Log 4	Yeah, it's water. It's definitely water....I think. Um, I gotta go run some tests...	Yeah, it's water. It's definitely water...I think. Um, I got to go run some tests...
			aliases.append( "diag_sp_BoyleLog4_TS701_13_01_imc_boyle" )

		}
		else if ( boyleAudioLogNumber == 5 )
		{
			//---------------------------------------
			// Boyle audio logs: 5
			//---------------------------------------

			//Dr. Jefferson Boyle	Log 5	Dr. Jefferson Boyle - Log five. Okay, good news, tests came back negative...it is water. Bad news... Literally everything else. Nothing's good. 	Dr. Jefferson Boyle. Log five. Okay, good news, tests came back negative...it is water. Bad news... Literally everything else. Nothing's good.
			aliases.append( "diag_sp_BoyleLog5_TS701_14_01_imc_boyle" )

			//Dr. Jefferson Boyle	Log 5	I think it's time I get out of this place. I've managed to breach a hole in the wall, it leads up to the main campus.	I think it's time I get out of this place. I've managed to breach a hole in the wall, it leads up to the main campus.
			aliases.append( "diag_sp_BoyleLog5_TS701_15_01_imc_boyle" )

			//Dr. Jefferson Boyle	Log 5	I'm about 100 meters underground. I have no idea how long it'll take me to get to the top because I'm horrible at math, but I am an archaeologist; I've done some climbing before. 	I'm about 100 meters underground. I have no idea how long it'll take me to get to the top because I'm horrible at math, but I am an archaeologist; I've done some climbing before.
			aliases.append( "diag_sp_BoyleLog5_TS701_16_01_imc_boyle" )

			//Dr. Jefferson Boyle	Log 5	I just don't know what I'll find when I get up there but I have no choice. Okay, I have a choice but right now, it's not to die.	I just don't know what I'll find when I get up there but I have no choice. Okay, I have a choice but right now, it's not to die.
			aliases.append( "diag_sp_BoyleLog5_TS701_17_01_imc_boyle" )

			//Dr. Jefferson Boyle	Log 5	So, that's it. This is my final entry. Wish me luck. 	So, that's it. This is my final entry. Wish me luck.
			aliases.append( "diag_sp_BoyleLog5_TS701_18_01_imc_boyle" )

			//Dr. Jefferson Boyle	Log 5	See you soon, Hope. 	See you soon, Hope.
			aliases.append( "diag_sp_BoyleLog5_TS701_19_01_imc_boyle" )

			//Dr. Jefferson Boyle	Log 5	Dr. Jefferson Boyle - Signing Off. Err.. over and out. Is that how you say it? Whatever... bye.	Dr. Jefferson Boyle. Signing Off. Err.. over and out. Is that how you say it? Whatever... bye.
			aliases.append( "diag_sp_BoyleLog5_TS701_20_01_imc_boyle" )

		}
		else
			Assert( 0, "Invalid Boyle audio log number " + boyleAudioLogNumber )

		foreach( alias in aliases )
			waitthread PlayTimeShiftDialogue( player, audioLogModel, alias )
	}




	//-------------------------------------------------------------
	//	If this is the full ted talk, play the whole damn thing
	//--------------------------------------------------------------
	else if ( instanceName == "audiolog_ted_talk" )
	{
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk02" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk03" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk04" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk05" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk06" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk07" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk08" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk09" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk10" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk11" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk12" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk13" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk14" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk15" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk16" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk17" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk18" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk19" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk20" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk21" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk22" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk23" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk24" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk25" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk26" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk27" )
		waitthread PlayTimeShiftDialogue( player, audioLogModel, "tedTalk28" )
	}
}

///////////////////////////////////////////////////////////////////////////
void function StopAudioLogWhenPlayerFarAway( entity audioLogModel )
{
	if ( !IsValid( audioLogModel ) )
		return

	audioLogModel.EndSignal( "StopAudioLog" )

	array<entity> players = GetPlayerArray()
	if ( players.len() == 0 )
		return

	entity player = players[ 0 ]
	if ( !IsValid( player ) )
		return

	var timeZoneAudioLog = GetEntityTimelinePosition( audioLogModel )
	player.EndSignal( "OnDeath" )

	while( true )
	{
		wait 0.25
		if ( timeZoneAudioLog != level.timeZone ) //don't do distance check if we are in other timezone
			continue
		if ( !PlayerInRange( player.GetOrigin(), audioLogModel.GetOrigin(), DIST_TO_NOT_CARE_ABOUT_AUDIOLOGS ) )
			break
	}


	audioLogModel.Signal( "StopAudioLog" )
}
///////////////////////////////////////////////////////////////////////////
bool function IsAudioLogBoyle( string instanceName )
{
	if ( instanceName.find( "audiolog_boyle" ) == null )
		return false
	return true

}
///////////////////////////////////////////////////////////////////////////
int function GetBoyleLogInstanceNumber( string instanceName )
{
	int instanceNumber = -1

	if ( instanceName == "audiolog_boyle_0" )
		instanceNumber = 0
	else if ( instanceName == "audiolog_boyle_1" )
		instanceNumber = 1
	else if ( instanceName == "audiolog_boyle_2" )
		instanceNumber = 2
	else if ( instanceName == "audiolog_boyle_3" )
		instanceNumber = 3
	else if ( instanceName == "audiolog_boyle_4" )
		instanceNumber = 4
	else
		Assert( 0, "Unhandled instance name " + instanceName )

	Assert( instanceNumber > -1 )

	return instanceNumber
}
///////////////////////////////////////////////////////////////////////////
int function GetBoyleLogNumber( int instanceNumber, entity audioLogModel )
{
	int logNumber = file.boyleAudioLogNumberAssignments[ instanceNumber ]
	if ( logNumber == 0 )
		logNumber = GetNextBoyleLogNumber( audioLogModel )

	return logNumber

}

///////////////////////////////////////////////////////////////////////////
int function GetNextBoyleLogNumber( entity audioLogModel )
{
	int logNumber = file.boyleAudioLogsCollected + 1
	Assert( logNumber > 0 && logNumber < 6, "Boyle log at " + audioLogModel.GetOrigin() + " is trying to get assigned a number greater than 5: " + logNumber )
	file.boyleAudioLogsCollected++

	return logNumber
}
///////////////////////////////////////////////////////////////////////////
void function TempAudioLogDevMsg( entity player )
{
	Dev_PrintMessage( player, "#BLANK_TEXT", "#AUDIOLLOG_TEMPTEXT_TIMESHIFT", 3.0 )
}

////////////////////////////////////////////////////////////////////////////
void function InitBoyleAudioLogs()
{
	LevelTransitionStruct ornull trans = GetLevelTransitionStruct()
	if ( trans == null )
		return

	expect LevelTransitionStruct( trans )
	file.boyleAudioLogsCollected = trans.boyleAudioLogsCollected

	for ( int i = 0 ; i < file.boyleAudioLogNumberAssignments.len(); i++ )
	{
		file.boyleAudioLogNumberAssignments[ i ] = trans.boyleAudioLogNumberAssignments[ i ]
	}
}

////////////////////////////////////////////////////////////////////////////
LevelTransitionStruct function SaveBoyleAudioLogs()
{
	LevelTransitionStruct trans
	trans.boyleAudioLogsCollected = file.boyleAudioLogsCollected

	for ( int i = 0 ; i < trans.boyleAudioLogNumberAssignments.len(); i++ )
	{
		trans.boyleAudioLogNumberAssignments[ i ] = file.boyleAudioLogNumberAssignments[ i ]
	}

	return trans
}


///////////////////////////////////////////////////////////////////////////
void function SetLectureHallLineDuration( float duration )
{
	file. lectureHallTimeBeforePlayerInterrupts = duration
}
///////////////////////////////////////////////////////////////////////////

void function ProwlersAmbientThink( entity npc )
{
	npc.EnableNPCFlag( NPC_IGNORE_ALL )
	npc.SetNoTarget( true )
}
///////////////////////////////////////////////////////////////////////////

void function LightFlickerThink( entity lightModelOff )
{
	entity lightModelOn = lightModelOff.GetLinkEnt()
	Assert( IsValid( lightModelOn ), "Light model at " + lightModelOff.GetOrigin() + " needs to target a lit version of the same model" )

	lightModelOn.Hide()
	entity fx

	while( true )
	{

		wait RandomFloatRange( 0.5, 0.6 )
		lightModelOn.Show()
		lightModelOff.Hide()
		fx = PlayFXOnEntity( FX_DLIGHT_LIGHT_FLICKER, lightModelOn )
		EmitSoundOnEntity( lightModelOn, SOUND_LIGHT_FLICKER )

		wait RandomFloatRange( 0.3, 0.4 )
		lightModelOff.Show()
		lightModelOn.Hide()
		EntFireByHandle( fx, "Stop", "", 0, null, null )

		wait RandomFloatRange( 0.5, 0.6 )
		lightModelOn.Show()
		lightModelOff.Hide()
		fx = PlayFXOnEntity( FX_DLIGHT_LIGHT_FLICKER, lightModelOn )

		wait RandomFloatRange( 0.5, 0.6 )
		lightModelOff.Show()
		lightModelOn.Hide()
		EntFireByHandle( fx, "Stop", "", 0, null, null )

		wait RandomFloatRange( 0.5, 0.6 )
		lightModelOn.Show()
		lightModelOff.Hide()
		fx = PlayFXOnEntity( FX_DLIGHT_LIGHT_FLICKER, lightModelOn )


		wait RandomFloatRange( 0.01, 0.02 )
		lightModelOff.Show()
		lightModelOn.Hide()
		EntFireByHandle( fx, "Stop", "", 0, null, null )

		wait RandomFloatRange( 0.01, 0.02 )
		lightModelOn.Show()
		lightModelOff.Hide()
		fx = PlayFXOnEntity( FX_DLIGHT_LIGHT_FLICKER, lightModelOn )
		EmitSoundOnEntity( lightModelOn, SOUND_LIGHT_FLICKER )

		wait RandomFloatRange( 0.02, 0.03 )
		lightModelOff.Show()
		lightModelOn.Hide()
		EntFireByHandle( fx, "Stop", "", 0, null, null )

		wait RandomFloatRange( 1, 1.1 )
		lightModelOn.Show()
		lightModelOff.Hide()
		fx = PlayFXOnEntity( FX_DLIGHT_LIGHT_FLICKER, lightModelOn )


		wait RandomFloatRange( 0.2, 0.3 )
		lightModelOff.Show()
		lightModelOn.Hide()
		EntFireByHandle( fx, "Stop", "", 0, null, null )

		wait RandomFloatRange( 1, 1.1 )
		lightModelOn.Show()
		lightModelOff.Hide()
		fx = PlayFXOnEntity( FX_DLIGHT_LIGHT_FLICKER, lightModelOn )
		EmitSoundOnEntity( lightModelOn, SOUND_LIGHT_FLICKER )

		wait RandomFloatRange( 0.2, 0.3 )
		lightModelOff.Show()
		lightModelOn.Hide()
		EntFireByHandle( fx, "Stop", "", 0, null, null )

		wait RandomFloatRange( 0.2, 0.3 )
		lightModelOn.Show()
		lightModelOff.Hide()
		fx = PlayFXOnEntity( FX_DLIGHT_LIGHT_FLICKER, lightModelOn )



		wait RandomFloatRange( 0.01, 0.02 )
		lightModelOff.Show()
		lightModelOn.Hide()
		EntFireByHandle( fx, "Stop", "", 0, null, null )

		wait RandomFloatRange( 0.01, 0.02 )
		lightModelOn.Show()
		lightModelOff.Hide()
		fx = PlayFXOnEntity( FX_DLIGHT_LIGHT_FLICKER, lightModelOn )
		EmitSoundOnEntity( lightModelOn, SOUND_LIGHT_FLICKER )

		wait RandomFloatRange( 0.01, 0.02 )
		lightModelOff.Show()
		lightModelOn.Hide()
		EntFireByHandle( fx, "Stop", "", 0, null, null )

		wait RandomFloatRange( 0.01, 0.02 )
		lightModelOn.Show()
		lightModelOff.Hide()
		fx = PlayFXOnEntity( FX_DLIGHT_LIGHT_FLICKER, lightModelOn )


		wait RandomFloatRange( 0.02, 0.03 )
		lightModelOff.Show()
		lightModelOn.Hide()
		EntFireByHandle( fx, "Stop", "", 0, null, null )


	}

}

//////////////////////////////////////////////////////////////////////////////////////////////////
void function PlayerDropLand( entity player, entity node, bool doBlur = false )
{
	entity moverNode = CreateScriptMover( node.GetOrigin(), node.GetAngles() )

	float targetZpos = node.GetOrigin().z + 16

	while( player.GetOrigin().z > targetZpos )
		WaitFrame()

	player.UnfreezeControlsOnServer()
	player.ClearInvulnerable()

	string anim3rd= "pt_timeshift_fall_land"
	string animPOV = "ptpov_timeshift_fall_land"

	player.SetAnimNearZ( 3 )

	if ( doBlur )
		Remote_CallFunction_Replay( player, "ServerCallback_FanDropBlur" )

		//PlayFPSAnimTeleportShowProxy(  player, 		anim3rd, 		anim1st 	ref = null	optionalTag, 	animView = null, float initialTime = 0.0 )
	waitthread PlayFPSAnimTeleportShowProxy( player, 		anim3rd, 		animPOV, 	moverNode, 		"REF", 			ViewConeTight )
	//wait 2
	player.ClearAnimNearZ()
	player.ClearParent()
	moverNode.Destroy()
	player.UnforceStand()
	player.Anim_Stop()
	ClearPlayerAnimViewEntity( player )
	player.ClearParent()
	player.EnableWeaponWithSlowDeploy()
}


/////////////////////////////////////////////////////////////////////////////////////////
void function RingsLocalExplosionNormal( entity rings )
{
	if ( level.timeZone == TIMEZONE_NIGHT )
		return
	vector origin = rings.GetOrigin()
		//CreateShake( 	org, 	amplitude = 16,  	frequency = 150, 	duration = 1.5,  	radius = 2048 )
	thread CreateAirShake( origin, 4, 					10, 				1, 					32000 )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function RingsLocalExplosionBig( entity rings )
{
	if ( level.timeZone == TIMEZONE_NIGHT )
		return

	vector origin = rings.GetOrigin()
	//CreateShake( vector org, float amplitude = 16, float frequency = 150, float duration = 1.5, float radius = 2048 )
	thread CreateAirShake( origin, 4, 10, 1, 32000 )
}



/////////////////////////////////////////////////////////////////////////////////////////
void function CreateShakeTimeshift( float amplitude, float frequency, float duration )
{
	array<entity> players = GetPlayerArray()
	if ( players.len() == 0 )
		return

	entity player = players[ 0 ]
	if ( !IsValid( player ) )
		return

	CreateAirShake( player.GetOrigin(), amplitude, frequency, duration )
	//Remote_CallFunction_Replay( player, "ServerCallback_ScreenShake", amplitude, frequency, duration )
}
/////////////////////////////////////////////////////////////////////////////////////////
void function CreateShakeWhileFlagSet( float amplitude, float frequency, float duration, string flagToShake, string flagToAbort )
{
	array<entity> players = GetPlayerArray()
	if ( players.len() == 0 )
		return

	entity player = players[ 0 ]
	if ( !IsValid( player ) )
		return

	player.EndSignal( "OnDeath" )
	FlagEnd( flagToAbort )

	while ( true )
	{
		wait 0.1
		if ( Flag( flagToShake ) )
		{
			CreateAirShake( player.GetOrigin(), amplitude, frequency, duration )
			//Remote_CallFunction_Replay( player, "ServerCallback_ScreenShake", amplitude, frequency, duration )
			wait duration / 4
		}
	}

}

void function TitanTimeshiftHint( entity player )
{
	Remote_CallFunction_Replay( player, "ServerCallback_ShowTitanTimeshiftHint" )
}

/////////////////////////////////////////////////////////////////////////////
string function GetrandomDeathPose( asset deathModel )
{
	if ( deathModel == MARVIN_MODEL_OVERGROWN )
		return "mv_timeshift_death_pose_01"

	array <string> deathPosesLocal = file.deathPoses
	deathPosesLocal.randomize()
	return deathPosesLocal[ 0 ]
}

/////////////////////////////////////////////////////////////////////////////
void function FlyerAmbientThink( entity flyer )
{
	if ( GetMapName() == "sp_hub_timeshift" )
		return

	flyer.EndSignal( "OnDeath" )
	flyer.EndSignal( "OnDestroy" )

	FlagWait( "ForceFlyerTakeoff" )
	flyer.Signal( "FlyerStopThink" )
	//flyer.WaitSignal( "FlyerTakeoffOverride" )
	wait RandomFloatRange( 0, 6 )
	thread FlyerTakeOff( flyer )
}

void function DropshipSpawnAndRepeat( entity dropship )
{
	dropship.EndSignal( "OnDeath" )
	dropship.EndSignal( "OnDestroy" )
	dropship.EndSignal( "OnAnimationInterrupted" )
	entity animNode = dropship.GetLinkEnt()
	Assert( IsValid( animNode ) )
	string anim = expect string( animNode.kv.leveled_animation )
	float animLength = dropship.GetSequenceDuration( anim )
	Assert( IsValid( anim ) )

	bool repeat = true
	if ( dropship.GetScriptName() == "dropships_skybridge" )
		repeat = false

	OnThreadEnd(
		function() : ( dropship )
		{
			if ( IsValid( dropship ) )
				dropship.Destroy()
		}
	)

	while( true )
	{

		wait animLength

		if ( repeat == false )
			break

	}

}


void function DisableNavmeshSeperatorTargetedByEnt( entity doorModel )
{
	array <entity> linkedEnts = doorModel.GetLinkEntArray()
	Assert( linkedEnts.len() > 0 )
	string classname
	entity navmeshBrush

	foreach( entity ent in linkedEnts )
	{
		classname = GetEditorClass( ent )
		if ( classname == "func_brush_navmesh_separator" )
		{
			navmeshBrush = ent
			break
		}
	}

	Assert( IsValid( navmeshBrush ), "Entity at " + doorModel.GetOrigin() + " isn't targeting a func_brush_navmesh_separator" )

	//navmeshBrush.Hide()
	navmeshBrush.NotSolid()
	ToggleNPCPathsForEntity( navmeshBrush, true )


}




void function ElectricalScreenEffects( entity player, string enabledFlag = "" )
{
	EndSignal( player, "OnDeath" )
	EndSignal( player, "StopCoreEffects" )
	OnThreadEnd(
		function() : ( player )
		{
			if ( IsValid ( player ) )
				StopSoundOnEntity( player, EMP_IMPARED_SOUND )
		}
	)

	if ( enabledFlag != "" )
	{
		if ( !Flag( enabledFlag ) )
			FlagWait( enabledFlag )
	}

	array<entity> ents = GetEntArrayByScriptName( "BeaconScreenEffect" )
	array<vector> start
	array<vector> end
	array<float> radius
	foreach( entity ent in ents )
	{
		start.append( ent.GetOrigin() )
		end.append( ent.GetLinkEnt().GetOrigin() )
		radius.append( float( ent.kv.radius ) )
	}

	bool soundPlaying
	float maxAmount
	vector p
	while( true )
	{
		maxAmount = 0
		p = player.GetOrigin()
		for ( int i = 0 ; i < ents.len() ; i++ )
		{
			float d = GetDistanceFromLineSegment( start[i], end[i], p )
			float amount = GraphCapped( d, 0.0, radius[i], 1.0, 0.0 )
			maxAmount = max( amount, maxAmount )
		}

		if ( maxAmount > 0 )
		{
			StatusEffect_AddTimed( player, eStatusEffect.emp, maxAmount, 0.25, 0.05 )
			if ( !soundPlaying )
			{
				EmitSoundOnEntity( player, EMP_IMPARED_SOUND )
				soundPlaying = true
			}
		}
		else if ( soundPlaying )
		{
			StopSoundOnEntity( player, EMP_IMPARED_SOUND )
			soundPlaying = false
		}

		wait 0.1
	}
}


void function GivePropForAnim( entity npc, string anim )
{
	if ( !IsValid( npc ) )
		return

	string tagName
	asset model

	if ( anim == "pt_lecture_student_1_idle" )
	{
		tagName = "L_HAND"
		model = MODEL_IPAD
	}

	else if ( anim == "pt_lecture_student_2_idle" )
	{
		tagName = "R_HAND"
		model = MODEL_COFFEE
	}

	else if ( anim == "pt_lecture_student_5_idle" )
	{
		tagName = "L_HAND"
		model = MODEL_IPAD
	}
	else if ( anim == "pt_civ_walk_tablet" )
	{
		tagName = "R_HAND"
		model = MODEL_IPAD
	}

	else if ( anim == "pt_civ_walk_tablet_reading" )
	{
		tagName = "R_HAND"
		model = MODEL_IPAD
	}

	else if ( anim == "pt_civ_walk_drink" )
	{
		tagName = "R_HAND"
		model = MODEL_COFFEE
	}

	else
		return

	entity prop = CreatePropDynamic( model )
	prop.SetParent( npc, tagName, false )
}



void function LoudspeakerThread( entity player )
{

	//if ( GetBugReproNum() != 202020 )
		//return

	if ( !IsValid( player ) )
		return

	if ( file.loudspeakerThreadRunning )
		return

	FlagSet( "ShouldPlayGlobalLoudspeker" )

	file.loudspeakerThreadRunning = true

	player.EndSignal( "OnDeath" )

	wait 3

	array <string> arrayLoudspeakerLines
	arrayLoudspeakerLines.append( "diag_sp_ambScience_TS551_01_01_imc_sci" )
	arrayLoudspeakerLines.append( "diag_sp_ambScience_TS551_02_01_imc_sci" )
	arrayLoudspeakerLines.append( "diag_sp_ambScience_TS551_03_01_imc_sci" )
	arrayLoudspeakerLines.append( "diag_sp_ambScience_TS551_04_01_imc_sci" )
	arrayLoudspeakerLines.append( "diag_sp_ambScience_TS551_05_01_imc_sci" )
	arrayLoudspeakerLines.append( "diag_sp_ambScience_TS551_06_01_imc_sci" )
	arrayLoudspeakerLines.append( "diag_sp_ambScience_TS551_07_01_imc_sci" )
	arrayLoudspeakerLines.append( "diag_sp_ambScience_TS551_08_01_imc_sci" )

	int numberOfLoudspeakerLines = arrayLoudspeakerLines.len() -1

	entity loudspeakerEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY )
	int loudspeakerLineCount = 0
	//bool playSpectreLine = false


	while( true )
	{
		waitthread WaittillPlayerSwitchesTimezone( TIMEZONE_DAY )

		if ( !Flag( "ShouldPlayGlobalLoudspeker" ) )
		{
			FlagWait( "ShouldPlayGlobalLoudspeker" )
			continue
		}

		loudspeakerEnt = CreateBestLoudspeakerEnt( player, TIMEZONE_DAY, loudspeakerEnt )

		waitthread PlayTimeShiftDialogue( player, loudspeakerEnt, "Timeshift_Scr_AnnouncementChime" )

		//if ( playSpectreLine )
			//waitthread PlayTimeShiftDialogue( player, loudspeakerEnt, "Timeshift_Scr_SpectreAnnouncement" )

		waitthread PlayTimeShiftDialogue( player, loudspeakerEnt, arrayLoudspeakerLines[ loudspeakerLineCount ] )
		loudspeakerLineCount++
		if ( loudspeakerLineCount > numberOfLoudspeakerLines )
			loudspeakerLineCount = 0


		wait RandomFloatRange( 60, 70 )

		/*
		if ( playSpectreLine == false )
			playSpectreLine = true
		else if ( playSpectreLine == true )
			playSpectreLine = false
		*/
	}
}


void function ButtonOvergrownThink( entity propDynamic, string whichButton )
{
	asset swapModelName
	entity swapModel

	if ( whichButton == "small" )
		swapModelName = MODEL_BUTTON
	else
		swapModelName = MODEL_BUTTON_LARGE

	swapModel = CreatePropDynamic( swapModelName, propDynamic.GetOrigin(), propDynamic.GetAngles() )

	while( true )
	{
		swapModel.Hide()
		propDynamic.Show()

		wait RandomFloatRange( 2, 3 )

		swapModel.Show()
		propDynamic.Hide()

		wait 0.2

		swapModel.Hide()
		propDynamic.Show()

		wait 0.1

		swapModel.Show()
		propDynamic.Hide()

		wait 0.2

		swapModel.Hide()
		propDynamic.Show()

		wait 0.05

		swapModel.Show()
		propDynamic.Hide()

		wait 0.05

		swapModel.Hide()
		propDynamic.Show()

		wait 0.05

		swapModel.Show()
		propDynamic.Hide()

		wait 0.4

		swapModel.Hide()
		propDynamic.Show()

		wait 0.1

		swapModel.Show()
		propDynamic.Hide()

		wait 0.2

		swapModel.Hide()
		propDynamic.Show()

		wait 0.05

		swapModel.Show()
		propDynamic.Hide()

	}
}


entity function CreateTimeshiftCinematicFlyer( entity flyerModel, entity victim = null )
{
	entity newFlyer = CreateServerFlyer( flyerModel.GetOrigin(), flyerModel.GetAngles(), 100 )
	flyerModel.Destroy()
	return newFlyer

}

///////////////////////////////////////////////////////////////////
void function ObjectiveRemindUntilFlag( string flagToAbort )
{
	Assert( IsNewThread(), "Must be threaded off" )

	if ( Flag( flagToAbort ) )
		return
	FlagEnd( flagToAbort )

	while( true )
	{
		wait RandomFloatRange( 45, 50 )
		if ( Flag( flagToAbort ) )
			break
		Objective_Remind()

	}


}
///////////////////////////////////////////////////////////////////
void function SetFlagWhenPlayerWithinRangeOfEnt( entity player, entity ent, float minDist, string flagToSet )
{
	if ( Flag( flagToSet ) )
		return

	if ( !IsValid( ent ) )
		return

	if ( !IsValid( player ) )
		return

	FlagEnd( flagToSet )
	ent.EndSignal( "OnDestroy" )
	ent.EndSignal( "OnDeath" )
	player.EndSignal( "OnDeath" )

	while( true )
	{
		wait 0.25
		if ( Distance( player.GetOrigin(), ent.GetOrigin() ) < minDist )
		{
			FlagSet( flagToSet )
			break
		}

	}

}
///////////////////////////////////////////////////////////////////

bool function IsAudioLogPlaying( entity player )
{
	if ( !IsValid( player ) )
		return false

	if ( !Flag( "AudioLogPlaying" ) )
		return false

	if ( !PlayerInRangeOfAnyLaptopWhatsoever( player ) )
		return false

	return true
}
///////////////////////////////////////////////////////////////////
bool function PlayerInRangeOfAnyLaptopWhatsoever( entity player )
{
	//even if an audio log is "playing", we don't care if player is more than X units away from any laptop
	foreach( model in file.audioLogModels )
	{
		if ( PlayerInRange( player.GetOrigin(), model.GetOrigin(), DIST_TO_NOT_CARE_ABOUT_AUDIOLOGS ) )
			return true
	}

	return false
}