untyped


global function ModelViewer_Init

global function ToggleModelViewer

global modelViewerModels = []

#if DEV
struct
{
	bool initialized
	bool active
	entity gameUIFreezeControls
	array<string> playerWeapons
	array<string> playerOffhands
	bool dpadUpPressed = true
	bool dpadDownPressed = true
	var lastTitanAvailability
} file
#endif // DEV

function ModelViewer_Init()
{
	#if DEV
		if ( reloadingScripts )
			return
		AddClientCommandCallback( "ModelViewer", ClientCommand_ModelViewer )
	#endif
}

function ToggleModelViewer()
{
	#if DEV
		entity player = GetPlayerArray()[ 0 ]
		if ( !file.active )
		{
			file.active = true

			DisablePrecacheErrors()
			wait 0.5

			ModelViewerDisableConflicts()
			Remote_CallFunction_NonReplay( player, "ServerCallback_ModelViewerDisableConflicts" )

			ReloadShared()

			if ( !file.initialized )
			{
				file.initialized = true
				ControlsInit()
			}

			Remote_CallFunction_NonReplay( player, "ServerCallback_MVEnable" )

			file.lastTitanAvailability = level.nv.titanAvailability
			Riff_ForceTitanAvailability( eTitanAvailability.Never )

			WeaponsRemove()
			thread UpdateModelBounds()
		}
		else
		{
			file.active = false

			Remote_CallFunction_NonReplay( player, "ServerCallback_MVDisable" )
			RestorePrecacheErrors()

			Riff_ForceTitanAvailability( file.lastTitanAvailability )

			WeaponsRestore()
		}
	#endif
}

#if DEV
function ModelViewerDisableConflicts()
{
	disable_npcs() //Just disable_npcs() for now, will probably add things later
}

function ReloadShared()
{
	modelViewerModels = GetModelViewerList()
}

function ControlsInit()
{
	file.gameUIFreezeControls = CreateEntity( "game_ui" )
	file.gameUIFreezeControls.kv.spawnflags = 32
	file.gameUIFreezeControls.kv.FieldOfView = -1.0

	DispatchSpawn( file.gameUIFreezeControls )
}

bool function ClientCommand_ModelViewer( entity player, array<string> args )
{
	if ( !args.len() )
		return true

	string command = args[ 0 ]
	switch ( command )
	{
		case "freeze_player":
			file.gameUIFreezeControls.Fire( "Activate", "!player", 0 )
			break

		case "unfreeze_player":
			file.gameUIFreezeControls.Fire( "Deactivate", "!player", 0 )
			break
	}

	return true
}

function UpdateModelBounds()
{
	wait( 0.3 )

	foreach ( index, modelName in modelViewerModels )
	{
		entity model = CreatePropDynamic( expect asset( modelName ) )
		local mins = model.GetBoundingMins()
		local maxs = model.GetBoundingMaxs()

		mins.x = min( -8.0, mins.x )
		mins.y = min( -8.0, mins.y )
		mins.z = min( -8.0, mins.z )

		maxs.x = max( 8.0, maxs.x )
		maxs.y = max( 8.0, maxs.y )
		maxs.z = max( 8.0, maxs.z )

		Remote_CallFunction_NonReplay( GetPlayerArray()[ 0 ], "ServerCallback_MVUpdateModelBounds", index, mins.x, mins.y, mins.z, maxs.x, maxs.y, maxs.z )
		model.Destroy()
	}
}

function WeaponsRemove()
{
	entity player = GetPlayerArray()[0]
	if ( !IsValid( player ) )
		return

	file.playerWeapons.clear()
	file.playerOffhands.clear()

	array<entity> weapons = player.GetMainWeapons()
	foreach ( weaponEnt in weapons )
	{
		string weapon = weaponEnt.GetWeaponClassName()
		file.playerWeapons.append( weapon )
		player.TakeWeapon( weapon )
	}

	array<entity> offhands = player.GetOffhandWeapons()
	foreach ( index, offhandEnt in offhands )
	{
		string offhand = offhandEnt.GetWeaponClassName()
		file.playerOffhands.append( offhand )
		player.TakeOffhandWeapon( index )
	}
}

function WeaponsRestore()
{
	entity player = GetPlayerArray()[0]
	if ( !IsValid( player ) )
		return

	foreach ( weapon in file.playerWeapons )
	{
		player.GiveWeapon( weapon )
	}

	foreach ( index, offhand in file.playerOffhands )
	{
		player.GiveOffhandWeapon( offhand, index )
	}
}

#endif // DEV
