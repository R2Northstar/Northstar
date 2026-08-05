global function CodeCallback_MapInit

struct
{
	int batteryIndex = 0
} file

const array<vector> BATTERY_SPAWNS = [
	< -1444.55, -1108.55, 127 >, // field
	< -730, 644, 121 >, // mid
	< 535, 2657.67, 119 > // bridge
]

void function CodeCallback_MapInit()
{
	AddEvacNode( CreateScriptRef( Vector( 2527.889893, -2865.360107, 753.002991 ), Vector( 0, -80.54, 0 ) ) )
	AddEvacNode( CreateScriptRef( Vector( 1253.530029, -554.075012, 811.125 ), Vector( 0, 180, 0 ) ) )
	AddEvacNode( CreateScriptRef( Vector( 2446.98999, 809.364014, 576.0 ), Vector( 0, 90.253, 0 ) ) )
	AddEvacNode( CreateScriptRef( Vector( -2027.430054, 960.39502, 609.007996 ), Vector( 0, 179.604, 0 ) ) )

	SetEvacSpaceNode( CreateScriptRef( Vector( -1700, -5500, -7600 ), Vector( -3.620642, 270.307129, 0 ) ) )

	// spectator cams
	array<vector> positions = [
		Vector( 2154.047852, -2074.73877, 942.299316 ),
		Vector( 1903.05896, -1322.483521, 823.097656 ),
		Vector( 2714.390625, 45.400002, 759.743164 ),
		Vector( -1138.018311, 195.28157, 691.62793 )
	]
	array<vector> angles = [
		Vector( 7.924948, -65.822983, 0 ),
		Vector( 4.037039, -229.682098, 0 ),
		Vector( 0.014044, -234.180573, 0 ),
		Vector( -4.035686, 140.311783, 0 )
	]

	for ( int i = 0; i < positions.len(); i++ )
	{
		entity spec_cam = CreateEntity( "info_target" )

		spec_cam.SetOrigin( positions[ i ] )
		spec_cam.SetAngles( angles[ i ] )
		spec_cam.kv.spawnFlags = SF_INFOTARGET_ALWAYS_TRANSMIT_TO_CLIENT

		DispatchSpawn( spec_cam )

		SetTargetName( spec_cam, "spec_cam" + ( i + 1 ) )

		spec_cam.DisableHibernation()
	}

	// Battery spawns (in LTS/Free Agents) are in old locations, so we move them to the proper locations
	AddSpawnCallbackEditorClass( "script_ref", "script_power_up_other", FixBatterySpawns )

	// there are some really busted titan startspawns that are on the fucking other side of the map from where they should be, so we remove them
	AddSpawnCallback( "info_spawnpoint_titan_start", TrimBadTitanStartSpawns )
	AddSpawnCallback( "sky_camera", FixSkycamFog )
}

void function FixBatterySpawns( entity spawn )
{
	if ( GAMETYPE != LAST_TITAN_STANDING && GAMETYPE != FREE_AGENCY )
		return

	PowerUp powerupDef = GetPowerUpFromItemRef( expect string( spawn.kv.powerUpType ) )
	if ( powerupDef.spawnFunc() )
		spawn.SetOrigin( BATTERY_SPAWNS[ file.batteryIndex++ ] )
}

void function TrimBadTitanStartSpawns( entity spawn )
{
	if ( spawn.GetTeam() == TEAM_MILITIA )
		return // mil spawns are fine on this map

	vector comparisonOrigin = < 2281.39, -3333.06, 200.031 >

	if ( Distance2D( spawn.GetOrigin(), comparisonOrigin ) >= 2000.0 )
		spawn.Destroy()
}

void function FixSkycamFog( entity skycam )
{
	if ( skycam.GetTargetName() == "skybox_cam_level" )
		skycam.kv.useworldfog = 1
}
