global function CodeCallback_MapInit

struct {
	int batteryIndex = 0
} file

const array<vector> BATTERY_SPAWNS = [
	< 3960, 1215.04, 942 >,     // cliff
	< 31, 462.459, 797 >,       // mid
	< -4150.21, 693.654, 1123 > // mountain
]

void function CodeCallback_MapInit()
{
	// Battery spawns (in LTS/Free Agents) are in old locations, so we move them to the proper locations
	AddSpawnCallbackEditorClass( "script_ref", "script_power_up_other", FixBatterySpawns )
}

void function FixBatterySpawns( entity spawn )
{
	if ( GAMETYPE != LAST_TITAN_STANDING && GAMETYPE != FREE_AGENCY )
		return

	PowerUp powerupDef = GetPowerUpFromItemRef( expect string( spawn.kv.powerUpType ) )
	if ( powerupDef.spawnFunc() )
		spawn.SetOrigin( BATTERY_SPAWNS[file.batteryIndex++] )
}