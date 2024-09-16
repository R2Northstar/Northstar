global function ClientCodeCallback_MapInit
global function AddInWorldMinimapObject

// someday, move this to in world minimap

struct
{
	array<var> minimapBGTopos
	array<var> minimapTopos
	array<var> screens
	float mapCornerX
	float mapCornerY
	float mapScale
	float threatMaxDist
} file

void function ClientCodeCallback_MapInit()
{
	AddCallback_EntitiesDidLoad( EntitiesDidLoad )
	AddCallback_MinimapEntSpawned( AddInWorldMinimapObject )
	AddCallback_LocalViewPlayerSpawned( AddInWorldMinimapObject )
}

void function EntitiesDidLoad()
{
	InitMinimapScreens()
}

var function AddInWorldMinimapTopo( entity ent, float width, float height )
{
	vector ang = ent.GetAngles()
	vector right = ( (AnglesToRight( ang )*-1) * width * 0.5 )
	vector down = ( (AnglesToUp( ang )*-1) * height * 0.5 )

	vector org = ent.GetOrigin()

	org = ent.GetOrigin() - right*0.5 - down*0.5

	var topo = RuiTopology_CreatePlane( org, right, down, true )
	return topo
}

void function InitMinimapScreens()
{
	array<entity> screens = GetEntArrayByScriptName( "inworld_minimap" )
	foreach ( screen in screens )
	{
		file.minimapTopos.append( AddInWorldMinimapTopo( screen, 350, 350 ) )
		file.minimapBGTopos.append( AddInWorldMinimapTopo( screen, 450, 450 ) )
	}

	asset mapImage = Minimap_GetAssetForKey( "minimap" )
	file.mapCornerX = Minimap_GetFloatForKey( "pos_x" )
	file.mapCornerY = Minimap_GetFloatForKey( "pos_y" )
	float displayDist = Minimap_GetFloatForKey( "displayDist" )
	float threatDistNear = Minimap_GetFloatForKey( "threatNearDist" )
	float threatDistFar = Minimap_GetFloatForKey( "threatFarDist" )
	file.mapScale = Minimap_GetFloatForKey( "scale" )

	file.threatMaxDist = Minimap_GetFloatForKey( "threatMaxDist" )

	foreach ( screen in file.minimapBGTopos )
	{
		entity player = GetLocalViewPlayer()
		var rui = RuiCreate( $"ui/in_world_minimap_border.rpak", screen, RUI_DRAW_WORLD, 0 )
		string factionChoice = GetFactionChoice( player )
		ItemDisplayData displayData = GetItemDisplayData( factionChoice )
		asset factionLogo = displayData.image
		RuiSetImage( rui, "logo", factionLogo )
		RuiSetImage( rui, "basicImage", $"overviews/mp_glitch_wallmap_bracket" )
	}
	foreach ( screen in file.minimapTopos )
	{
		var rui = RuiCreate( $"ui/in_world_minimap_base.rpak", screen, RUI_DRAW_WORLD, 0 )
		RuiSetImage( rui, "mapImage", $"overviews/mp_glitch_wallmap" )
		RuiSetFloat3( rui, "mapCorner", <file.mapCornerX, file.mapCornerY, 0> )
		RuiSetFloat( rui, "displayDist", max( file.threatMaxDist, 2200 ) )
		RuiSetFloat( rui, "mapScale", file.mapScale )
		file.screens.append( rui )
	}

	foreach ( player in GetPlayerArray() )
	{
		if ( IsValid( player ) )
			AddInWorldMinimapObject( player )
	}
}

void function AddInWorldMinimapObject( entity ent ) //TODO: If we want radar jammer boost to hide friendly players we need to be able to get the rui handles back.
{
	Assert( IsValid( ent ) )

	if ( !ent.IsPlayer() && !ent.IsTitan() )
		return

	ent.SetDoDestroyCallback( true )

	foreach ( screen in file.minimapTopos )
		thread AddInWorldMinimapObjectInternal( ent, screen )
}

void function AddInWorldMinimapObjectInternal( entity ent, var screen )
{
	printt( "AddInWorldMinimapObject" )
	printt( screen )
	printt( ent )

	bool isNPCTitan = ent.IsNPC() && ent.IsTitan()
	bool isPetTitan = ent == GetLocalViewPlayer().GetPetTitan()
	bool isLocalPlayer = ent == GetLocalViewPlayer()
	int customState = ent.Minimap_GetCustomState()
	asset minimapAsset = $"ui/in_world_minimap_player.rpak"
	if ( isNPCTitan )
	{
		minimapAsset = $"ui/in_world_minimap_object.rpak"
	}

	int zOrder = ent.Minimap_GetZOrder()
	entity viewPlayer = GetLocalViewPlayer()

	var rui = RuiCreate( minimapAsset, screen, RUI_DRAW_WORLD, MINIMAP_Z_BASE + zOrder )

	//RuiTrackGameTime( rui, "lastFireTime", ent, RUI_TRACK_LAST_FIRED_TIME )

	RuiSetFloat3( rui, "mapCorner", <file.mapCornerX,file.mapCornerY,0.0> )
	RuiSetFloat( rui, "mapScale", file.mapScale )

	RuiTrackFloat3( rui, "objectPos", ent, RUI_TRACK_ABSORIGIN_FOLLOW )
	RuiTrackFloat3( rui, "objectAngles", ent, RUI_TRACK_EYEANGLES_FOLLOW )
	RuiTrackInt( rui, "objectFlags", ent, RUI_TRACK_MINIMAP_FLAGS )
	RuiTrackInt( rui, "customState", ent, RUI_TRACK_MINIMAP_CUSTOM_STATE )
	RuiSetFloat( rui, "displayDist", max( file.threatMaxDist, 2200 ) )

	if ( isLocalPlayer )
		RuiSetBool( rui, "isLocalPlayer", isLocalPlayer )

	// MinimapPackage_PlayerInit( ent, rui )

	if ( isPetTitan )
	{
		RuiSetBool( rui, "useTeamColor", false )
		RuiSetFloat3( rui, "iconColor", TEAM_COLOR_YOU / 255.0 )
	}

	OnThreadEnd(
		function() : ( rui )
		{
			RuiDestroy( rui )
		}
	)

	ent.EndSignal( "OnDestroy" )

	if ( ent.IsPlayer() )
	{
		while ( IsValid( ent ) )
		{
			WaitSignal( ent, "SettingsChanged", "OnDeath" )
		}
	}
	else
	{
		ent.WaitSignal( "OnDestroy" )
	}
}

void function MinimapPackage_PlayerInit( entity ent, var rui )
{
	RuiTrackGameTime( rui, "lastFireTime", ent, RUI_TRACK_LAST_FIRED_TIME )
	if ( !IsFFAGame() ) //JFS: Too much work to get FFA to work correctly with Minimap logic, so disabling it for FFA
	{
		RuiTrackFloat( rui, "sonarDetectedFrac", ent, RUI_TRACK_STATUS_EFFECT_SEVERITY, eStatusEffect.sonar_detected )
		RuiTrackFloat( rui, "maphackDetectedFrac", ent, RUI_TRACK_STATUS_EFFECT_SEVERITY, eStatusEffect.maphack_detected )
	}
}