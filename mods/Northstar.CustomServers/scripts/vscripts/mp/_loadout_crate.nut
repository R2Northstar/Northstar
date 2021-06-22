untyped

global function LoadoutCrate_Init

const LOADOUT_CRATE_MODEL				= $"models/containers/pelican_case_ammobox.mdl"
global function AddLoadoutCrate
global function DestroyAllLoadoutCrates

function LoadoutCrate_Init()
{
	level.loadoutCrateManagedEntArrayID <- CreateScriptManagedEntArray()
	PrecacheModel( LOADOUT_CRATE_MODEL )

	AddSpawnCallback( "prop_dynamic", LoadoutCreatePrePlaced )
}

function AddLoadoutCrate( team, vector origin, vector angles, bool showOnMinimap = true, entity crate = null )
{
	expect int( team )

	local crateCount = GetScriptManagedEntArray( level.loadoutCrateManagedEntArrayID ).len()
	Assert( crateCount < MAX_LOADOUT_CRATE_COUNT, "Can't have more than " + MAX_LOADOUT_CRATE_COUNT + " Loadout Crates" )

	angles += Vector( 0, -90, 0 )

	if ( !IsValid( crate ) )
	{
		crate = CreatePropScript( LOADOUT_CRATE_MODEL, origin, angles, 6 )
		SetTargetName( crate, "loadoutCrate" )
	}

	SetTeam( crate, team )
	crate.SetUsable()
	if ( team == TEAM_MILITIA || team == TEAM_IMC )
		crate.SetUsableByGroup( "friendlies pilot" )
	else
		crate.SetUsableByGroup( "pilot" )

	crate.SetUsePrompts( "#LOADOUT_CRATE_HOLD_USE", "#LOADOUT_CRATE_PRESS_USE" )
	crate.SetForceVisibleInPhaseShift( true )

	if ( showOnMinimap )
	{
		#if R1_VGUI_MINIMAP
			crate.Minimap_SetDefaultMaterial( $"vgui/hud/coop/coop_ammo_locker_icon" )
		#endif
		crate.Minimap_SetObjectScale( MINIMAP_LOADOUT_CRATE_SCALE )
		crate.Minimap_SetAlignUpright( true )
		crate.Minimap_AlwaysShow( TEAM_IMC, null )
		crate.Minimap_AlwaysShow( TEAM_MILITIA, null )
		crate.Minimap_SetHeightTracking( true )
		crate.Minimap_SetZOrder( MINIMAP_Z_OBJECT )
		crate.Minimap_SetCustomState( eMinimapObject_prop_script.FD_LOADOUT_CHEST )
	}

	AddToScriptManagedEntArray( level.loadoutCrateManagedEntArrayID, crate )

	//thread LoadoutCrateMarkerThink( "LoadoutCrateMarker" + string( crateCount ), crate )
	thread LoadoutCrateThink( crate )
	thread LoadoutCrateRestockAmmoThink( crate )

	Highlight_SetNeutralHighlight( crate, "interact_object_los" )
}

void function LoadoutCreatePrePlaced( entity ent )
{
	if ( ent.GetTargetName().find( "loot_crate" ) == 0 )
	{
		ent.Destroy()
		return
	}

	if ( ent.GetTargetName().find( "loadout_crate" ) != 0 )
		return

	if ( IsSingleplayer() )
		return

	vector angles = ent.GetAngles() + Vector( 0, 90, 0 )
	AddLoadoutCrate( TEAM_BOTH, ent.GetOrigin(), angles, false, ent )
}

function LoadoutCrateMarkerThink( marker, crate )
{
	crate.EndSignal( "OnDestroy" )
	crate.EndSignal( "OnDeath" )

	OnThreadEnd(
		function() : ( marker )
		{
			ClearMarker( marker )
		}
	)

	while ( 1 )
	{
		if ( GetGameState() <= eGameState.Prematch )
			ClearMarker( marker )
		else
			SetMarker( marker, crate )

		svGlobal.levelEnt.WaitSignal( "GameStateChanged" )
	}
}

function LoadoutCrateThink( crate )
{
	crate.EndSignal( "OnDestroy" )
	while ( true )
	{
		var player = crate.WaitSignal( "OnPlayerUse" ).player

		if ( player.IsPlayer() )
		{
			thread UsingLoadoutCrate( crate, player )
			wait 1	// debounce on using the crate to minimize the risk of using it twice before the menu opens.
		}
	}
}

function LoadoutCrateRestockAmmoThink( crate )
{
	crate.EndSignal( "OnDestroy" )
	local distSqr
	local crateOrigin = crate.GetOrigin()
	local triggerDistSqr = 96 * 96
	local resetDistSqr = 384 * 384

	while ( true )
	{
		wait 1 // check every second
		array<entity> playerArray = GetPlayerArray_Alive()
		foreach( player in playerArray )
		{
			if ( player.IsTitan() )
				continue

			if ( player.ContextAction_IsBusy() )
				continue

			distSqr = DistanceSqr( crateOrigin, player.GetOrigin() )
			if ( distSqr <= triggerDistSqr && player.s.restockAmmoTime < Time() )
			{
				if ( TraceLineSimple( player.EyePosition(), crate.GetOrigin() + Vector( 0.0, 0.0, 24.0 ), crate ) == 1.0 )
				{
					player.s.restockAmmoCrate = crate
					player.s.restockAmmoTime = Time() + 10 // debounce time before you can get new ammo again if you stay next to the crate.
					//MessageToPlayer( player, eEventNotifications.CoopAmmoRefilled, null, null )
					RestockPlayerAmmo( player )
				}
			}

			if ( distSqr > resetDistSqr && player.s.restockAmmoTime > 0 && player.s.restockAmmoCrate == crate )
			{
				player.s.restockAmmoCrate = null
				player.s.restockAmmoTime = 0
			}
		}
	}
}

function UsingLoadoutCrate( crate, player )
{
	expect entity( player )

	player.p.usingLoadoutCrate = true
	player.s.usedLoadoutCrate = true
	EmitSoundOnEntityOnlyToPlayer( player, player, "Coop_AmmoBox_Open" )
	Remote_CallFunction_UI( player, "ServerCallback_OpenPilotLoadoutMenu" )
}

// should be called if we enter an epilogue ... maybe?
function DestroyAllLoadoutCrates()
{
	local crateArray = GetScriptManagedEntArray( level.loadoutCrateManagedEntArrayID )
	foreach( crate in crateArray )
		crate.Destroy()

	//dissolve didn't work
	//Dissolve( ENTITY_DISSOLVE_CHAR, Vector( 0, 0, 0 ), 0 )
	//ENTITY_DISSOLVE_CORE
	//ENTITY_DISSOLVE_NORMAL
}