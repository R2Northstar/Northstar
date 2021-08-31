
global function SpectreRack_Init
global function IsStalkerRack
global function SpawnFromStalkerRack
global function AddSpectreRackCallback
global function GetSpectreRackFromEnt
global function SetupSpectreRack
global function SpectreRackActivationEffects
global function TrackFriendlySpectre

const FX_GREEN_GLOW 		= $"P_spectre_rack_glow_idle"
const WARNING_LIGHT_BLINK	= $"warning_light_orange_blink"
const SPECTRE_RACK_ACHIEVEMENT_COUNT = 6

global struct SpectreRackSpectre
{
	string attachName
	entity dummyModel
	entity glowFX
	entity spawner
}

global struct SpectreRack
{
	entity rackEnt
	array<SpectreRackSpectre> spectreRackSpectres
}

struct
{
	int playersSpectreArrayIdx
	array<string> spectreRackTypes
	array<SpectreRack> spectreRacks
	array<void functionref( entity, entity )> callbackFuncs
} file

void function AddSpectreRackCallback( void functionref( entity, entity ) func )
{
	Assert( !file.callbackFuncs.contains( func ) )
	file.callbackFuncs.append( func )
}

void function SpectreRack_Init()
{
	if ( reloadingScripts )
		return

	file.spectreRackTypes.append( "npc_spectre_rack_wall" )
	file.spectreRackTypes.append( "npc_spectre_rack_multi" )
	file.spectreRackTypes.append( "npc_spectre_rack_triple" )
	//file.spectreRackTypes.append( "npc_spectre_rack_portable" )
	//file.spectreRackTypes.append( "npc_spectre_rack_palette" )

	PrecacheParticleSystem( FX_GREEN_GLOW )
	PrecacheParticleSystem( WARNING_LIGHT_BLINK )

	foreach ( string rackType in file.spectreRackTypes )
	{
		AddSpawnCallbackEditorClass( "prop_dynamic", rackType, SetupSpectreRack )
	}

	if ( IsSingleplayer() )
	{
		file.playersSpectreArrayIdx = CreateScriptManagedEntArray()
		AddSpectreRackCallback( TrySpectreAchievement )
	}
}

bool function IsStalkerRack( entity ent )
{
	if ( !ent.HasKey( "editorclass" ) )
		return false
	string editorclass = ent.GetValueForKey( "editorclass" )
	return file.spectreRackTypes.contains( editorclass )
}

void function SetupSpectreRack( entity rack )
{
	SpectreRack spectreRack
	spectreRack.rackEnt = rack

	// Get attach point info from the model being used
	while( true )
	{
		int attachIndex = spectreRack.spectreRackSpectres.len() + 1
		string attachment = "spectre_attach_" + attachIndex

		int id = rack.LookupAttachment( attachment )
		if ( id == 0 )
			break

		SpectreRackSpectre spectreRackSpectre
		spectreRackSpectre.attachName = attachment
		spectreRack.spectreRackSpectres.append( spectreRackSpectre )
	}

	// Get linked spawner
	array<entity> linkedEnts = rack.GetLinkEntArray()
	int spawnerCount = 0
	foreach ( index, ent in linkedEnts )
	{
		if ( IsSpawner( ent ) )
		{
			spectreRack.spectreRackSpectres[index].spawner = ent
			spawnerCount++
		}
	}
	Assert( spawnerCount == spectreRack.spectreRackSpectres.len(), "Spectre rack " + rack + " at: " + rack.GetOrigin() + " " + rack.GetValueForKey( "editorclass" ) + " must link to exactly " + spectreRack.spectreRackSpectres.len() + " spawner" )

	// Create dummy spectre models to idle on the rack
	foreach ( spectreRackSpectre in spectreRack.spectreRackSpectres )
	{
		int attachID = rack.LookupAttachment( spectreRackSpectre.attachName )
		vector origin = rack.GetAttachmentOrigin( attachID )
		vector angles = rack.GetAttachmentAngles( attachID )

		var spawnerKeyValues = spectreRackSpectre.spawner.GetSpawnEntityKeyValues()
		expect table( spawnerKeyValues )
		asset model = spectreRackSpectre.spawner.GetSpawnerModelName()
		int skin
		if ( "skin" in spawnerKeyValues )
		{
			skin = int( spawnerKeyValues.skin )
		}

		string idleAnim = GetIdleAnimForSpawner( spectreRackSpectre.spawner )
		entity dummySpectre = CreatePropDynamic( model, origin, angles )
		dummySpectre.SetSkin( skin )
		dummySpectre.SetParent( rack, spectreRackSpectre.attachName )
		thread PlayAnimTeleport( dummySpectre, idleAnim, rack, spectreRackSpectre.attachName )

		spectreRackSpectre.dummyModel = dummySpectre
	}

	// Create effects on the rack
	if ( !rack.HasKey( "DisableStatusLights" ) || rack.GetValueForKey( "DisableStatusLights" ) == "0" )
		SpectreRackCreateFx( spectreRack, FX_GREEN_GLOW )

	file.spectreRacks.append( spectreRack )
}

void function SpawnFromStalkerRack( entity rack, entity activator = null )
{
	Assert( IsNewThread(), "Must be threaded off." )
	SpectreRack spectreRack = GetSpectreRackFromEnt( rack )
	Assert( IsValid( spectreRack.rackEnt ) )

	thread SpectreRackActivationEffects( spectreRack )
	thread SpectreRackActivationSpawners( spectreRack, activator )

	if ( IsValid( activator )  && activator.IsPlayer() )
		UnlockAchievement( activator, achievements.HACK_STALKERS )
}

void function SpectreRackActivationEffects( SpectreRack spectreRack )
{
	EndSignal( spectreRack, "OnDestroy" )
	EndSignal( spectreRack.rackEnt, "OnDestroy" )

	OnThreadEnd
	(
		function() : ( spectreRack )
		{
			if ( IsValid( spectreRack ) )
				SpectreRackDestroyFx( spectreRack )
		}
	)

	EmitSoundAtPosition( TEAM_UNASSIGNED, spectreRack.rackEnt.GetOrigin() + Vector( 0, 0, 72), "colony_spectre_initialize_beep" )
	EmitSoundAtPosition( TEAM_UNASSIGNED, spectreRack.rackEnt.GetOrigin() + Vector( 0, 0, 72), "corporate_spectrerack_activate" )

	SpectreRackDestroyFx( spectreRack )
	SpectreRackCreateFx( spectreRack, WARNING_LIGHT_BLINK )

	// Let the flash FX linger a bit longer, then the thread end will kill the fx
	wait 6
}

void function SpectreRackActivationSpawners( SpectreRack spectreRack, entity activator = null )
{
	EndSignal( spectreRack, "OnDestroy" )
	EndSignal( spectreRack.rackEnt, "OnDestroy" )

	array<int> spawnOrder
	for ( int i = 0 ; i < spectreRack.spectreRackSpectres.len() ; i++ )
	{
		spawnOrder.append(i)
	}

	spawnOrder.randomize()

	foreach ( int index in spawnOrder )
	{
		thread SpectreRackReleaseSpectre( spectreRack, index, activator )

		wait RandomFloatRange( 0.0, 0.25 )
	}
}

void function SpectreRackReleaseSpectre( SpectreRack spectreRack, int index, entity activator = null )
{
	SpectreRackSpectre spectreRackSpectre = spectreRack.spectreRackSpectres[ index ]
	if ( !IsValid( spectreRackSpectre.dummyModel ) )
		return

	entity rackEnt = spectreRack.rackEnt

	entity dummy = spectreRackSpectre.dummyModel
	Assert( IsValid ( dummy ) )

	entity spawner = spectreRackSpectre.spawner
	Assert( IsValid ( spawner ) )

	EndSignal( spectreRackSpectre, "OnDestroy" )
	EndSignal( rackEnt, "OnDestroy" )

	var spawnerKeyValues = spawner.GetSpawnEntityKeyValues()
	expect table( spawnerKeyValues )
	if ( "script_delay" in spawnerKeyValues )
	{
		float delay = float( spawnerKeyValues.script_delay )
		wait delay
	}

	if ( IsValid( dummy ) )
		dummy.Destroy()
	entity spectre = spawner.SpawnEntity()
	DispatchSpawn( spectre )
	spectre.ContextAction_SetBusy()

	if ( IsValid( activator ) )
	{
		SetTeam( spectre, activator.GetTeam() )
		//spectre.DisableBehavior( "Assault" )
		/*
		if ( activator.IsPlayer() )
		{
			NPCFollowsPlayer( spectre, activator )
		}
		else if ( activator.IsNPC() )
		{
			NPCFollowsNPC( spectre, activator )
		}
		*/
	}

	string deployAnim = GetDeployAnimForSpawner( spectreRackSpectre.spawner )
	string idleAnim = GetIdleAnimForSpawner( spectreRackSpectre.spawner )

	EndSignal( spectre, "OnDeath" )

	string attachment = spectreRackSpectre.attachName
	spectre.SetParent( rackEnt, attachment )
	thread PlayAnimTeleport( spectre, idleAnim, rackEnt, attachment )

	if ( CoinFlip() )
		EmitSoundOnEntity( spectre, "diag_stalker_generic" )

	spectre.SetNoTarget( true )
	waitthread PlayAnim( spectre, deployAnim, rackEnt, attachment )
	spectre.ClearParent()
	float yaw = spectre.GetAngles().y
	spectre.SetAngles( <0,yaw,0> )//spectres released on moving platforms angle correctly

	foreach ( func in file.callbackFuncs )
	{
		thread func( spectre, activator )
	}

	spectre.SetTitle( spectre.GetSettingTitle() )
	Highlight_SetFriendlyHighlight( spectre, "sp_friendly_pilot" )
	ShowName( spectre )
	wait 1
	spectre.SetNoTarget( false )
	spectre.ContextAction_ClearBusy()
}

void function SpectreRackCreateFx( SpectreRack spectreRack, asset fxName )
{
	for ( int i = 0 ; i < spectreRack.spectreRackSpectres.len() ; i++ )
	{
		string attachment = "glow_" + i
		int id = spectreRack.rackEnt.LookupAttachment( attachment )
		Assert( id != 0, "Missing attachment \"" + attachment + "\" in model " + spectreRack.rackEnt.GetModelName() )

		entity fx = PlayLoopFXOnEntity( fxName, spectreRack.rackEnt, attachment )
		Assert( !IsValid( spectreRack.spectreRackSpectres[i].glowFX ) )
		spectreRack.spectreRackSpectres[i].glowFX = fx
	}
}

void function SpectreRackDestroyFx( SpectreRack spectreRack )
{
	foreach ( spectreRackSpectre in spectreRack.spectreRackSpectres )
	{
		entity fx = spectreRackSpectre.glowFX
		if ( !IsValid_ThisFrame( fx ) )
			continue
		fx.ClearParent()
		fx.Destroy()
	}
}

SpectreRack function GetSpectreRackFromEnt( entity rack )
{
	// Get the spectre rack struct from the placed entity
	foreach ( SpectreRack rackStruct in file.spectreRacks )
	{
		if ( rackStruct.rackEnt == rack )
			return rackStruct
	}
	SpectreRack rackStruct
	return rackStruct
}

string function GetIdleAnimForSpawner( entity spawner )
{
	string idleAnim
	string spawnClassName = GetEditorClass( spawner )
	if ( spawnClassName == "" )
		spawnClassName = spawner.GetSpawnEntityClassName()

	switch( spawnClassName )
	{
		case "npc_stalker":
		case "npc_stalker_zombie":
		case "npc_stalker_zombie_mossy":
			idleAnim = "st_medbay_idle_armed"
			break
		case "npc_spectre":
			idleAnim = "sp_med_bay_dropidle_A"
			break
		default:
			idleAnim = "st_medbay_idle_armed"
			break
	}

	return idleAnim
}

string function GetDeployAnimForSpawner( entity spawner )
{
	string deployAnim
	string spawnClassName = GetEditorClass( spawner )
	if ( spawnClassName == "" )
		spawnClassName = spawner.GetSpawnEntityClassName()

	switch( spawnClassName )
	{
		case "npc_stalker":
		case "npc_stalker_zombie":
		case "npc_stalker_zombie_mossy":
			deployAnim = "st_medbay_drop_armed"
			break
		case "npc_spectre_suicide":
			deployAnim = "sp_med_bay_drop_unarmed"
			break
		case "npc_spectre":
			deployAnim = "sp_med_bay_drop_A"
			break
		default:
			deployAnim = "st_medbay_drop_armed"
			break
	}

	return deployAnim
}

void function TrySpectreAchievement( entity npc, entity activator )
{
	if ( !IsValid( activator ) )
		return

	if ( !activator.IsPlayer() )
		return

	TrackFriendlySpectre( npc, activator )
}

void function TrackFriendlySpectre( entity npc, entity player )
{
	if ( player.GetTeam() != npc.GetTeam() )
		return

	if ( IsStalker( npc ) )
		AddToScriptManagedEntArray( file.playersSpectreArrayIdx, npc )
	else
		return

	printt( "Achievment tracking stalker: " + GetScriptManagedEntArrayLen( file.playersSpectreArrayIdx ) )
	if ( GetScriptManagedEntArrayLen( file.playersSpectreArrayIdx ) >= SPECTRE_RACK_ACHIEVEMENT_COUNT )
	{
		UnlockAchievement( player, achievements.HACK_ROBOTS )
	}
}